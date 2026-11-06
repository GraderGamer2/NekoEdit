.intel_syntax noprefix

.equ SYS_read,          0
.equ SYS_close,         3
.equ SYS_socket,       41
.equ SYS_connect,      42
.equ SYS_sendmsg,      46
.equ SYS_ftruncate,    77
.equ SYS_mmap,          9
.equ SYS_memfd_create, 319
.equ AF_UNIX,            1
.equ SOCK_STREAM,       1
.equ SOCK_CLOEXEC, 0x80000
.equ PROT_READ,          1
.equ PROT_WRITE,         2
.equ MAP_SHARED,         1
.equ MFD_CLOEXEC,        1
.equ SOL_SOCKET,         1
.equ SCM_RIGHTS,         1
.equ WIDTH,            800
.equ HEIGHT,           480
.equ STRIDE,           (WIDTH * 4)
.equ BUFFER_SIZE,      (STRIDE * HEIGHT)

.section .rodata
wayland_socket_env_key: .asciz "WAYLAND_SOCKET"
wayland_env_key:       .asciz "WAYLAND_DISPLAY"
xdg_runtime_env_key:   .asciz "XDG_RUNTIME_DIR"
default_wayland_name:  .asciz "wayland-0"
wayland_title:         .asciz "NekoEdit - development window"
memfd_label:           .asciz "nekoedit-shm"
iface_compositor:      .asciz "wl_compositor"
iface_shm:             .asciz "wl_shm"
iface_xdg_wm_base:     .asciz "xdg_wm_base"
msg_no_env:            .ascii "NekoEdit: XDG_RUNTIME_DIR is not set; cannot locate the Wayland socket.\n"
msg_no_env_end:
msg_connect:           .ascii "NekoEdit: could not connect to the Wayland display using WAYLAND_SOCKET or its socket path.\n"
msg_connect_end:
msg_globals:           .ascii "NekoEdit: compositor, wl_shm, or xdg_wm_base is unavailable.\n"
msg_globals_end:
msg_protocol:          .ascii "NekoEdit: Wayland protocol or shared-memory setup failed.\n"
msg_protocol_end:
newline_text:            .ascii "\n"
msg_protocol_error_prefix: .ascii "NekoEdit: Wayland compositor protocol error: "
msg_protocol_error_prefix_end:
stage_registry:       .asciz "Wayland stage: registry discovery"
stage_registry_read:  .asciz "Wayland stage: registry roundtrip"
stage_bind:           .asciz "Wayland stage: bind globals"
stage_bind_roundtrip: .asciz "Wayland stage: bind roundtrip"
stage_xdg_create:     .asciz "Wayland stage: create xdg window"
stage_xdg_configure:  .asciz "Wayland stage: wait for xdg configure"
stage_memfd:          .asciz "Wayland stage: allocate shared memory"
stage_pool:           .asciz "Wayland stage: send shm pool"
stage_buffer:         .asciz "Wayland stage: create wl_buffer"
stage_attach:         .asciz "Wayland stage: attach and commit"
stage_event_loop:     .asciz "Wayland stage: event loop"

.section .bss
.balign 16
failure_stage:         .quad 0
.global process_envp
process_envp:          .quad 0
runtime_dir_ptr:       .quad 0
wayland_name_ptr:      .quad 0
socket_fd:             .quad 0
shm_fd:                .quad 0
shm_mapping:           .quad 0
compositor_global:     .long 0
shm_global:            .long 0
xdg_global:            .long 0
last_object:           .long 0
last_opcode:           .long 0
last_size:             .long 0
event_header:          .zero 8
event_payload:         .zero 4096
request_buffer:        .zero 8192
payload_buffer:        .zero 256
socket_address:        .zero 110
socket_path_len:       .long 0
.balign 8
mmap_result:           .quad 0
.balign 8
msg_iov:               .zero 16
.balign 8
msg_header:            .zero 56
.balign 8
msg_control:           .zero 24

.section .text
.extern linux_write_all
.extern linux_read_exact
.extern linux_exit
.global wayland_main
.type wayland_main, @function
wayland_main:
    push rbp                    # keep 16-byte call-site stack alignment
    # WAYLAND_SOCKET is an inherited, already-connected descriptor. It takes
    # precedence over WAYLAND_DISPLAY when supplied by a session launcher.
    lea rdi, [rip + wayland_socket_env_key]
    mov esi, 14
    call env_lookup
    test rax, rax
    jz .connect_using_display_name
    mov rsi, rax
    call parse_socket_fd
    test rax, rax
    js .connect_error
    mov qword ptr [rip + socket_fd], rax
    jmp .socket_connected

.connect_using_display_name:
    # Resolve WAYLAND_DISPLAY (default wayland-0) and XDG_RUNTIME_DIR.
    lea rdi, [rip + wayland_env_key]
    mov esi, 15
    call env_lookup
    test rax, rax
    jnz .have_wayland_name
    lea rax, [rip + default_wayland_name]
.have_wayland_name:
    mov qword ptr [rip + wayland_name_ptr], rax

    # An absolute WAYLAND_DISPLAY is self-contained and does not need XDG_RUNTIME_DIR.
    mov rsi, qword ptr [rip + wayland_name_ptr]
    cmp byte ptr [rsi], '/'
    je .absolute_socket_path

    lea rdi, [rip + xdg_runtime_env_key]
    mov esi, 15
    call env_lookup
    test rax, rax
    jz .missing_runtime_dir
    mov qword ptr [rip + runtime_dir_ptr], rax

    lea rdi, [rip + socket_address + 2]
    mov rsi, qword ptr [rip + runtime_dir_ptr]
    mov edx, 100
    call copy_cstr
    test rax, rax
    js .connect_error
    mov r12d, eax
    lea rdi, [rip + socket_address + 2]
    add rdi, r12
    mov byte ptr [rdi], '/'
    inc r12d
    inc rdi
    mov rsi, qword ptr [rip + wayland_name_ptr]
    mov edx, 108
    sub edx, r12d
    call copy_cstr
    test rax, rax
    js .connect_error
    add eax, r12d
    jmp .socket_path_ready

.absolute_socket_path:
    lea rdi, [rip + socket_address + 2]
    mov rsi, qword ptr [rip + wayland_name_ptr]
    mov edx, 108
    call copy_cstr
    test rax, rax
    js .connect_error
.socket_path_ready:
    mov dword ptr [rip + socket_path_len], eax
    mov word ptr [rip + socket_address], AF_UNIX

    # socket(AF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0)
    mov eax, SYS_socket
    mov edi, AF_UNIX
    mov esi, SOCK_STREAM | SOCK_CLOEXEC
    xor edx, edx
    syscall
    test rax, rax
    js .connect_error
    mov qword ptr [rip + socket_fd], rax

    # connect(fd, sockaddr_un, offsetof(path)+strlen(path)+1)
    mov eax, SYS_connect
    mov rdi, qword ptr [rip + socket_fd]
    lea rsi, [rip + socket_address]
    mov edx, dword ptr [rip + socket_path_len]
    add edx, 3
    syscall
    test rax, rax
    js .connect_error

.socket_connected:
    lea rax, [rip + stage_registry]
    mov qword ptr [rip + failure_stage], rax
    # wl_display.get_registry(new_id=2)
    mov dword ptr [rip + payload_buffer], 2
    mov edi, 1
    mov esi, 1                  # wl_display.get_registry opcode
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # wl_display.sync(new_id=3)
    mov dword ptr [rip + payload_buffer], 3
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Process registry.global events until callback 3 completes.
.registry_roundtrip:
    lea rax, [rip + stage_registry_read]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 2
    jne .registry_check_done
    cmp dword ptr [rip + last_opcode], 0
    jne .registry_check_done
    call registry_capture_global
.registry_check_done:
    cmp dword ptr [rip + last_object], 3
    jne .registry_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .registry_roundtrip

    # Require the three globals used by the initial window.
    cmp dword ptr [rip + compositor_global], 0
    je .missing_globals
    cmp dword ptr [rip + shm_global], 0
    je .missing_globals
    cmp dword ptr [rip + xdg_global], 0
    je .missing_globals

    lea rax, [rip + stage_bind]
    mov qword ptr [rip + failure_stage], rax
    # Bind compositor as object 4, wl_shm as 5, xdg_wm_base as 6.
    mov edi, dword ptr [rip + compositor_global]
    lea rsi, [rip + iface_compositor]
    mov edx, 14                 # strlen("wl_compositor") + NUL
    mov ecx, 1
    mov r8d, 4
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    mov edi, dword ptr [rip + shm_global]
    lea rsi, [rip + iface_shm]
    mov edx, 7                  # strlen("wl_shm") + NUL
    mov ecx, 1
    mov r8d, 5
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    mov edi, dword ptr [rip + xdg_global]
    lea rsi, [rip + iface_xdg_wm_base]
    mov edx, 12                 # strlen("xdg_wm_base") + NUL
    mov ecx, 1
    mov r8d, 6
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_bind_roundtrip]
    mov qword ptr [rip + failure_stage], rax
    # Roundtrip callback 7 preserves dense client object IDs.
    mov dword ptr [rip + payload_buffer], 7
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error
.bind_roundtrip:
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .bind_check_done
    cmp dword ptr [rip + last_opcode], 0
    jne .bind_check_done
    call handle_xdg_ping
.bind_check_done:
    cmp dword ptr [rip + last_object], 7
    jne .bind_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .bind_roundtrip

    lea rax, [rip + stage_xdg_create]
    mov qword ptr [rip + failure_stage], rax
    # wl_compositor.create_surface(new_id=8)
    mov dword ptr [rip + payload_buffer], 8
    mov edi, 4
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_wm_base.get_xdg_surface(new_id=9, surface=8)
    mov dword ptr [rip + payload_buffer], 9
    mov dword ptr [rip + payload_buffer + 4], 8
    mov edi, 6
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_surface.get_toplevel(new_id=10)
    mov dword ptr [rip + payload_buffer], 10
    mov edi, 9
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_toplevel.set_title("NekoEdit - development window")
    lea rsi, [rip + wayland_title]
    mov ecx, 30                 # string length including NUL
    mov dword ptr [rip + payload_buffer], 30
    lea rdi, [rip + payload_buffer + 4]
    rep movsb
    mov edi, 10
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 36
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Initial empty commit requests the first xdg_surface.configure.
    mov edi, 8
    mov esi, 6
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error

.wait_configure:
    lea rax, [rip + stage_xdg_configure]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .configure_check_surface
    cmp dword ptr [rip + last_opcode], 0
    jne .configure_check_surface
    call handle_xdg_ping
    jmp .wait_configure
.configure_check_surface:
    cmp dword ptr [rip + last_object], 9
    jne .wait_configure
    cmp dword ptr [rip + last_opcode], 0
    jne .wait_configure
    # xdg_surface.configure(serial)
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 9
    mov esi, 4
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_memfd]
    mov qword ptr [rip + failure_stage], rax
    # Allocate a memfd-backed wl_shm buffer.
    mov eax, SYS_memfd_create
    lea rdi, [rip + memfd_label]
    mov esi, MFD_CLOEXEC
    syscall
    test rax, rax
    js .protocol_error
    mov qword ptr [rip + shm_fd], rax

    mov eax, SYS_ftruncate
    mov rdi, qword ptr [rip + shm_fd]
    mov esi, BUFFER_SIZE
    syscall
    test rax, rax
    js .protocol_error

    mov eax, SYS_mmap
    xor edi, edi
    mov esi, BUFFER_SIZE
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_SHARED
    mov r8, qword ptr [rip + shm_fd]
    xor r9d, r9d
    syscall
    test rax, rax
    js .protocol_error
    mov qword ptr [rip + mmap_result], rax
    mov qword ptr [rip + shm_mapping], rax

    # Paint a simple dark surface with an accent header bar (XRGB8888).
    mov rdi, rax
    mov ecx, (WIDTH * HEIGHT)
    mov eax, 0xff252a33
    rep stosd
    mov rdi, qword ptr [rip + shm_mapping]
    mov ecx, (WIDTH * 36)
    mov eax, 0xff343d4b
    rep stosd
    mov rdi, qword ptr [rip + shm_mapping]
    add rdi, (48 * 4)
    mov ecx, (4 * 4)
    mov eax, 0xff78a9d4
    rep stosd

    lea rax, [rip + stage_pool]
    mov qword ptr [rip + failure_stage], rax
    # wl_shm.create_pool(new_id=11, fd, size=BUFFER_SIZE)
    mov dword ptr [rip + payload_buffer], 11
    mov dword ptr [rip + payload_buffer + 4], BUFFER_SIZE
    mov edi, 5
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    mov r8, qword ptr [rip + shm_fd]
    call wl_send_request_fd
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_buffer]
    mov qword ptr [rip + failure_stage], rax
    # wl_shm_pool.create_buffer(new_id=12, offset=0, width, height, stride, XRGB8888=1)
    mov dword ptr [rip + payload_buffer], 12
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], WIDTH
    mov dword ptr [rip + payload_buffer + 12], HEIGHT
    mov dword ptr [rip + payload_buffer + 16], STRIDE
    mov dword ptr [rip + payload_buffer + 20], 1
    mov edi, 11
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 24
    call wl_send_request
    test rax, rax
    js .protocol_error

    # The wl_buffer retains the backing storage; release the pool object.
    mov edi, 11
    mov esi, 1                  # wl_shm_pool.destroy
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_attach]
    mov qword ptr [rip + failure_stage], rax
    # wl_surface.attach(buffer=12, x=0, y=0)
    mov dword ptr [rip + payload_buffer], 12
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], 0
    mov edi, 8
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 12
    call wl_send_request
    test rax, rax
    js .protocol_error

    # wl_surface.damage(0,0,WIDTH,HEIGHT)
    mov dword ptr [rip + payload_buffer], 0
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], WIDTH
    mov dword ptr [rip + payload_buffer + 12], HEIGHT
    mov edi, 8
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 16
    call wl_send_request
    test rax, rax
    js .protocol_error

    # wl_surface.commit()
    mov edi, 8
    mov esi, 6
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Minimal event loop: answer shell pings and honor the compositor close event.
.event_loop:
    lea rax, [rip + stage_event_loop]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .check_toplevel_close
    cmp dword ptr [rip + last_opcode], 0
    jne .check_toplevel_close
    call handle_xdg_ping
    jmp .event_loop
.check_toplevel_close:
    cmp dword ptr [rip + last_object], 10
    jne .event_loop
    cmp dword ptr [rip + last_opcode], 1
    jne .event_loop
    mov rdi, qword ptr [rip + socket_fd]
    mov eax, SYS_close
    syscall
    xor edi, edi
    jmp linux_exit

.missing_runtime_dir:
    mov edi, 2
    lea rsi, [rip + msg_no_env]
    mov edx, msg_no_env_end - msg_no_env
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.connect_error:
    mov edi, 2
    lea rsi, [rip + msg_connect]
    mov edx, msg_connect_end - msg_connect
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.missing_globals:
    mov edi, 2
    lea rsi, [rip + msg_globals]
    mov edx, msg_globals_end - msg_globals
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.protocol_error:
    mov edi, 2
    lea rsi, [rip + msg_protocol]
    mov edx, msg_protocol_end - msg_protocol
    call linux_write_all
    mov rsi, qword ptr [rip + failure_stage]
    test rsi, rsi
    jz .protocol_check_display_error
    call write_stderr_cstr
.protocol_check_display_error:
    # wl_display.error payload: object_id, code, then a length-prefixed
    # Wayland string. Validate both the declared event size and NUL terminator.
    cmp dword ptr [rip + last_object], 1
    jne .protocol_exit
    cmp dword ptr [rip + last_opcode], 0
    jne .protocol_exit
    mov ecx, dword ptr [rip + last_size]
    cmp ecx, 12
    jb .protocol_exit
    mov eax, dword ptr [rip + event_payload + 8]
    cmp eax, 1
    jb .protocol_exit
    cmp eax, 4000
    ja .protocol_exit
    # The declared string may be shorter than the remaining padded payload.
    # Clamp output to bytes actually received; never read beyond last_size.
    dec eax
    mov edx, ecx
    sub edx, 12
    cmp eax, edx
    cmova eax, edx
    mov r12d, eax
    mov edi, 2
    lea rsi, [rip + msg_protocol_error_prefix]
    mov edx, msg_protocol_error_prefix_end - msg_protocol_error_prefix
    call linux_write_all
    test r12d, r12d
    jz .protocol_error_message_newline
    mov edi, 2
    lea rsi, [rip + event_payload + 12]
    mov edx, r12d
    call linux_write_all
.protocol_error_message_newline:
    mov edi, 2
    lea rsi, [rip + newline_text]
    mov edx, 1
    call linux_write_all
.protocol_exit:
    mov edi, 1
    jmp linux_exit
.size wayland_main, . - wayland_main

# Print a NUL-terminated string to stderr. Input: RSI = string.
.type write_stderr_cstr, @function
write_stderr_cstr:
    push rbx
    push r12
    push r13
    mov r12, rsi
    mov rdi, rsi
    xor eax, eax
    mov rcx, -1
    repne scasb
    not rcx
    dec rcx
    mov r13, rcx
    mov edi, 2
    mov rsi, r12
    mov rdx, r13
    call linux_write_all
    mov edi, 2
    lea rsi, [rip + newline_text]
    mov edx, 1
    call linux_write_all
    pop r13
    pop r12
    pop rbx
    ret
.size write_stderr_cstr, . - write_stderr_cstr

# env_lookup(key=rdi, key_length=esi) -> rax=value pointer or 0.
.type env_lookup, @function
env_lookup:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13d, esi
    mov rbx, qword ptr [rip + process_envp]
.env_next:
    mov r8, qword ptr [rbx]
    test r8, r8
    jz .env_not_found
    mov r9d, r13d
    mov r10, r8
    mov r11, r12
.env_compare:
    test r9d, r9d
    jz .env_equal_prefix
    mov al, byte ptr [r10]
    cmp al, byte ptr [r11]
    jne .env_advance
    inc r10
    inc r11
    dec r9d
    jmp .env_compare
.env_equal_prefix:
    cmp byte ptr [r10], '='
    jne .env_advance
    lea rax, [r10 + 1]
    jmp .env_return
.env_advance:
    add rbx, 8
    jmp .env_next
.env_not_found:
    xor eax, eax
.env_return:
    pop r13
    pop r12
    pop rbx
    ret
.size env_lookup, . - env_lookup

# copy_cstr(dst=rdi, src=rsi, max=edx) -> eax length, -1 if not terminated in bound.
.type copy_cstr, @function
copy_cstr:
    xor ecx, ecx
.copy_loop:
    cmp ecx, edx
    jae .copy_fail
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .copy_ok
    inc ecx
    jmp .copy_loop
.copy_ok:
    mov eax, ecx
    ret
.copy_fail:
    mov eax, -1
    ret
.size copy_cstr, . - copy_cstr

# Parse WAYLAND_SOCKET as a non-negative decimal file descriptor.
# RSI = NUL-terminated decimal string. RAX = fd or -EINVAL.
.type parse_socket_fd, @function
parse_socket_fd:
    xor eax, eax
    xor ecx, ecx
.parse_socket_fd_loop:
    movzx edx, byte ptr [rsi + rcx]
    test edx, edx
    jz .parse_socket_fd_done
    cmp edx, '0'
    jb .parse_socket_fd_invalid
    cmp edx, '9'
    ja .parse_socket_fd_invalid
    sub edx, '0'
    imul rax, rax, 10
    add rax, rdx
    cmp rax, 0x7fffffff
    ja .parse_socket_fd_invalid
    inc ecx
    jmp .parse_socket_fd_loop
.parse_socket_fd_done:
    test ecx, ecx
    jz .parse_socket_fd_invalid
    ret
.parse_socket_fd_invalid:
    mov rax, -22
    ret
.size parse_socket_fd, . - parse_socket_fd

# wl_send_request(object=rdi, opcode=esi, payload=rdx, payload_length=ecx).
.type wl_send_request, @function
wl_send_request:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8                  # align stack before calling linux_write_all
    mov r12d, edi
    mov r13d, esi
    mov r14, rdx
    mov ebx, ecx
    lea rdi, [rip + request_buffer]
    mov dword ptr [rdi], r12d
    lea eax, [rbx + 8]
    shl eax, 16
    or eax, r13d
    mov dword ptr [rdi + 4], eax
    lea rdi, [rdi + 8]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + request_buffer]
    lea edx, [rbx + 8]
    call linux_write_all
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_send_request, . - wl_send_request

# wl_send_request_fd(object=rdi, opcode=esi, payload=rdx, payload_length=ecx, fd=r8).
.type wl_send_request_fd, @function
wl_send_request_fd:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r14, rdx
    mov ebx, ecx
    mov r15d, r8d
    lea rdi, [rip + request_buffer]
    mov dword ptr [rdi], r12d
    lea eax, [rbx + 8]
    shl eax, 16
    or eax, r13d
    mov dword ptr [rdi + 4], eax
    lea rdi, [rdi + 8]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    # iovec { request_buffer, total_length }
    lea rax, [rip + request_buffer]
    mov qword ptr [rip + msg_iov], rax
    lea rax, [rbx + 8]
    mov qword ptr [rip + msg_iov + 8], rax
    # cmsghdr: cmsg_len=20, SOL_SOCKET, SCM_RIGHTS, fd
    mov qword ptr [rip + msg_control], 20
    mov dword ptr [rip + msg_control + 8], SOL_SOCKET
    mov dword ptr [rip + msg_control + 12], SCM_RIGHTS
    mov dword ptr [rip + msg_control + 16], r15d
    # msghdr
    mov qword ptr [rip + msg_header], 0
    mov qword ptr [rip + msg_header + 8], 0
    lea rax, [rip + msg_iov]
    mov qword ptr [rip + msg_header + 16], rax
    mov qword ptr [rip + msg_header + 24], 1
    lea rax, [rip + msg_control]
    mov qword ptr [rip + msg_header + 32], rax
    mov qword ptr [rip + msg_header + 40], 24
    mov qword ptr [rip + msg_header + 48], 0
.send_fd_call:
    mov eax, SYS_sendmsg
    mov rdi, qword ptr [rip + socket_fd]
    lea rsi, [rip + msg_header]
    xor edx, edx
    syscall
    cmp rax, -4                 # retry sendmsg after EINTR
    je .send_fd_call
    test rax, rax
    js .send_fd_done
    lea rdi, [rip + request_buffer]
    lea rsi, [rdi + rax]
    lea edx, [rbx + 8]
    sub rdx, rax
    jz .send_fd_success
    mov edi, dword ptr [rip + socket_fd]
    call linux_write_all
    jmp .send_fd_done
.send_fd_success:
    xor eax, eax
.send_fd_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_send_request_fd, . - wl_send_request_fd

# Bind global: rdi=name, rsi=interface string, edx=string bytes including NUL,
# ecx=version, r8d=new object id.
.type wl_registry_bind, @function
wl_registry_bind:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13, rsi
    mov r14d, edx
    mov r15d, ecx
    mov ebx, r8d
    lea rdi, [rip + payload_buffer]
    xor eax, eax
    mov ecx, 64
    rep stosd
    lea rdi, [rip + payload_buffer]
    mov dword ptr [rdi], r12d
    mov dword ptr [rdi + 4], r14d
    lea rdi, [rdi + 8]
    mov rsi, r13
    mov ecx, r14d
    rep movsb
    # Pad string bytes to a 4-byte boundary.
    mov eax, r14d
    add eax, 3
    and eax, -4
    lea rdi, [rip + payload_buffer + 8]
    add rdi, rax
    mov dword ptr [rdi], r15d
    mov dword ptr [rdi + 4], ebx
    lea ecx, [rax + 16]
    mov edi, 2
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    call wl_send_request
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_registry_bind, . - wl_registry_bind

# Read one complete Wayland event; records last_object/opcode/size and payload.
.type wl_read_event, @function
wl_read_event:
    push rbp
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + event_header]
    mov edx, 8
    call linux_read_exact
    test rax, rax
    js .read_event_done
    mov eax, dword ptr [rip + event_header]
    mov dword ptr [rip + last_object], eax
    mov eax, dword ptr [rip + event_header + 4]
    mov edx, eax
    and edx, 0xffff
    mov dword ptr [rip + last_opcode], edx
    shr eax, 16
    cmp eax, 8
    jb .read_event_bad
    sub eax, 8
    cmp eax, 4096
    ja .read_event_bad
    mov dword ptr [rip + last_size], eax
    test eax, eax
    jz .read_event_ok
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + event_payload]
    mov edx, eax
    call linux_read_exact
    test rax, rax
    js .read_event_done
.read_event_ok:
    # wl_display.error is fatal; return an error while preserving its payload
    # so the caller can print the compositor-provided diagnostic safely.
    cmp dword ptr [rip + last_object], 1
    jne .read_event_success
    cmp dword ptr [rip + last_opcode], 0
    jne .read_event_success
    mov eax, -71                 # EPROTO
    jmp .read_event_done
.read_event_success:
    xor eax, eax
.read_event_done:
    pop rbp
    ret
.read_event_bad:
    mov eax, -71
    jmp .read_event_done
.size wl_read_event, . - wl_read_event

# Registry.global payload: name, interface string, version.
.type registry_capture_global, @function
registry_capture_global:
    push rbp
    lea r8, [rip + event_payload + 8]
    mov rdi, r8
    lea rsi, [rip + iface_compositor]
    call string_equal
    test eax, eax
    jz .registry_try_shm
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + compositor_global], eax
    jmp .registry_done
.registry_try_shm:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_shm]
    call string_equal
    test eax, eax
    jz .registry_try_xdg
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + shm_global], eax
    jmp .registry_done
.registry_try_xdg:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_xdg_wm_base]
    call string_equal
    test eax, eax
    jz .registry_done
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + xdg_global], eax
.registry_done:
    pop rbp
    ret
.size registry_capture_global, . - registry_capture_global

.type string_equal, @function
string_equal:
    mov r8, rdi
    mov r9, rsi
.string_equal_loop:
    mov al, byte ptr [r8]
    cmp al, byte ptr [r9]
    jne .string_equal_no
    test al, al
    je .string_equal_yes
    inc r8
    inc r9
    jmp .string_equal_loop
.string_equal_yes:
    mov eax, 1
    ret
.string_equal_no:
    xor eax, eax
    ret
.size string_equal, . - string_equal

# Answer xdg_wm_base.ping (object 6, opcode 0, serial payload).
.type handle_xdg_ping, @function
handle_xdg_ping:
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 6
    mov esi, 3
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    jmp wl_send_request
.size handle_xdg_ping, . - handle_xdg_ping

.section .note.GNU-stack,"",@progbits
