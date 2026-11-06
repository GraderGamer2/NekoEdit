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
.equ BTN_LEFT,          0x110
.equ DOC_CAPACITY,    65536
.equ DOC_LEFT,           16
.equ DOC_TOP,           164
.equ CELL_WIDTH,          8
.equ LINE_HEIGHT,        12

.section .rodata
wayland_socket_env_key: .asciz "WAYLAND_SOCKET"
wayland_env_key:       .asciz "WAYLAND_DISPLAY"
xdg_runtime_env_key:   .asciz "XDG_RUNTIME_DIR"
default_wayland_name:  .asciz "wayland-0"
empty_document_hint:   .asciz "TYPE HERE..."
wayland_title:         .asciz "NekoEdit - development window"
memfd_label:           .asciz "nekoedit-shm"
iface_compositor:      .asciz "wl_compositor"
iface_shm:             .asciz "wl_shm"
iface_xdg_wm_base:     .asciz "xdg_wm_base"
iface_seat:            .asciz "wl_seat"
keymap_base:
    .byte 0, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 0, 0
    .byte 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 0, 0, 97, 115
    .byte 100, 102, 103, 104, 106, 107, 108, 59, 39, 96, 0, 92, 122, 120, 99, 118
    .byte 98, 110, 109, 44, 46, 47, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
keymap_shift:
    .byte 0, 0, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 123, 125, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 58, 34, 126, 0, 124, 0, 0, 0, 0
    .byte 0, 0, 0, 60, 62, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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

.section .rodata
.balign 1
font_5x7:
    .byte 14, 17, 17, 31, 17, 17, 17
    .byte 30, 17, 17, 30, 17, 17, 30
    .byte 15, 16, 16, 16, 16, 16, 15
    .byte 30, 17, 17, 17, 17, 17, 30
    .byte 31, 16, 16, 30, 16, 16, 31
    .byte 31, 16, 16, 30, 16, 16, 16
    .byte 15, 16, 16, 23, 17, 17, 15
    .byte 17, 17, 17, 31, 17, 17, 17
    .byte 14, 4, 4, 4, 4, 4, 14
    .byte 7, 2, 2, 2, 18, 18, 12
    .byte 17, 18, 20, 24, 20, 18, 17
    .byte 16, 16, 16, 16, 16, 16, 31
    .byte 17, 27, 21, 21, 17, 17, 17
    .byte 17, 25, 21, 19, 17, 17, 17
    .byte 14, 17, 17, 17, 17, 17, 14
    .byte 30, 17, 17, 30, 16, 16, 16
    .byte 14, 17, 17, 17, 21, 18, 13
    .byte 30, 17, 17, 30, 20, 18, 17
    .byte 15, 16, 16, 14, 1, 1, 30
    .byte 31, 4, 4, 4, 4, 4, 4
    .byte 17, 17, 17, 17, 17, 17, 14
    .byte 17, 17, 17, 17, 17, 10, 4
    .byte 17, 17, 17, 21, 21, 21, 10
    .byte 17, 17, 10, 4, 10, 17, 17
    .byte 17, 17, 10, 4, 4, 4, 4
    .byte 31, 1, 2, 4, 8, 16, 31
    .byte 14, 17, 19, 21, 25, 17, 14
    .byte 4, 12, 4, 4, 4, 4, 14
    .byte 14, 17, 1, 2, 4, 8, 31
    .byte 30, 1, 1, 14, 1, 1, 30
    .byte 2, 6, 10, 18, 31, 2, 2
    .byte 31, 16, 16, 30, 1, 1, 30
    .byte 14, 16, 16, 30, 17, 17, 14
    .byte 31, 1, 2, 4, 8, 8, 8
    .byte 14, 17, 17, 14, 17, 17, 14
    .byte 14, 17, 17, 15, 1, 1, 14
    .byte 14, 17, 1, 2, 4, 0, 4
    .byte 0, 0, 0, 0, 0, 12, 12
    .byte 0, 0, 0, 0, 12, 12, 8
    .byte 0, 0, 12, 12, 0, 12, 12
    .byte 0, 0, 0, 31, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 31
    .byte 4, 4, 4, 4, 4, 0, 4
    .byte 10, 10, 0, 0, 0, 0, 0
    .byte 4, 4, 8, 0, 0, 0, 0
    .byte 2, 4, 8, 8, 8, 4, 2
    .byte 8, 4, 2, 2, 2, 4, 8
    .byte 0, 4, 4, 31, 4, 4, 0
    .byte 0, 0, 31, 0, 31, 0, 0
    .byte 1, 2, 2, 4, 8, 8, 16
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
seat_global:           .long 0
pointer_x:             .long 0
pointer_y:             .long 0
pointer_inside:         .long 0
pointer_created:        .long 0
pointer_object:         .long 0
keyboard_created:       .long 0
keyboard_object:        .long 0
keyboard_focused:       .long 0
next_input_object:      .long 0
seat_capabilities:      .long 0
palette_selection:      .long 0
buffer_busy:            .long 0
redraw_pending:         .long 0
shift_down:             .long 0
caps_lock:              .long 0
doc_length:             .long 0
doc_cursor:             .long 0
doc_buffer:             .zero DOC_CAPACITY
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

    # Draw the initial software-rendered palette surface.
    call render_surface

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
    mov dword ptr [rip + buffer_busy], 1

    # Bind the optional wl_seat after the window objects so IDs 13-15 remain
    # dense: seat=13, roundtrip callback=14, pointer=15.
    cmp dword ptr [rip + seat_global], 0
    je .event_loop
    lea rax, [rip + stage_bind_roundtrip]
    mov qword ptr [rip + failure_stage], rax
    mov edi, dword ptr [rip + seat_global]
    lea rsi, [rip + iface_seat]
    mov edx, 8
    mov ecx, 1
    mov r8d, 13
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    # Input objects are allocated from 15 onward, in capability order.
    mov dword ptr [rip + next_input_object], 15
    # Roundtrip so the compositor can announce seat capabilities.
    mov dword ptr [rip + payload_buffer], 14
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error
.seat_roundtrip:
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .seat_check_capabilities
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_capabilities
    call handle_xdg_ping
.seat_check_capabilities:
    cmp dword ptr [rip + last_object], 13
    jne .seat_check_buffer_release
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_buffer_release
    call handle_seat_capabilities
    test rax, rax
    js .protocol_error
    jmp .seat_check_sync
.seat_check_buffer_release:
    cmp dword ptr [rip + last_object], 12
    jne .seat_check_sync
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_sync
    mov dword ptr [rip + buffer_busy], 0
.seat_check_sync:
    cmp dword ptr [rip + last_object], 14
    jne .seat_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_roundtrip

    # Main event loop: pointer input selects a palette swatch. The single
    # wl_buffer is only rewritten after wl_buffer.release.
.event_loop:
    lea rax, [rip + stage_event_loop]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .check_buffer_release
    cmp dword ptr [rip + last_opcode], 0
    jne .check_buffer_release
    call handle_xdg_ping
    jmp .event_loop
.check_buffer_release:
    cmp dword ptr [rip + last_object], 12
    jne .check_seat_event
    cmp dword ptr [rip + last_opcode], 0
    jne .check_seat_event
    mov dword ptr [rip + buffer_busy], 0
    cmp dword ptr [rip + redraw_pending], 0
    je .event_loop
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_seat_event:
    cmp dword ptr [rip + last_object], 13
    jne .check_pointer_event
    cmp dword ptr [rip + last_opcode], 0
    jne .check_pointer_event
    call handle_seat_capabilities
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_pointer_event:
    mov eax, dword ptr [rip + pointer_object]
    test eax, eax
    jz .check_keyboard_event
    cmp dword ptr [rip + last_object], eax
    jne .check_keyboard_event
    cmp dword ptr [rip + last_opcode], 0
    je .pointer_enter
    cmp dword ptr [rip + last_opcode], 1
    je .pointer_leave
    cmp dword ptr [rip + last_opcode], 2
    je .pointer_motion
    cmp dword ptr [rip + last_opcode], 3
    je .pointer_button
    jmp .event_loop
.pointer_enter:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    mov eax, dword ptr [rip + event_payload + 8]
    sar eax, 8
    mov dword ptr [rip + pointer_x], eax
    mov eax, dword ptr [rip + event_payload + 12]
    sar eax, 8
    mov dword ptr [rip + pointer_y], eax
    mov dword ptr [rip + pointer_inside], 1
    jmp .event_loop
.pointer_leave:
    mov dword ptr [rip + pointer_inside], 0
    jmp .event_loop
.pointer_motion:
    cmp dword ptr [rip + last_size], 12
    jb .event_loop
    mov eax, dword ptr [rip + event_payload + 4]
    sar eax, 8
    mov dword ptr [rip + pointer_x], eax
    mov eax, dword ptr [rip + event_payload + 8]
    sar eax, 8
    mov dword ptr [rip + pointer_y], eax
    jmp .event_loop
.pointer_button:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + event_payload + 8], BTN_LEFT
    jne .event_loop
    cmp dword ptr [rip + event_payload + 12], 1
    jne .event_loop
    cmp dword ptr [rip + pointer_inside], 1
    jne .event_loop
    mov eax, dword ptr [rip + pointer_x]
    mov edx, dword ptr [rip + pointer_y]
    cmp edx, 96
    jl .event_loop
    cmp edx, 144
    jge .event_loop
    cmp eax, 80
    jl .palette_second
    cmp eax, 128
    jge .palette_second
    cmp dword ptr [rip + palette_selection], 0
    je .event_loop
    mov dword ptr [rip + palette_selection], 0
    jmp .palette_changed
.palette_second:
    cmp eax, 160
    jl .palette_third
    cmp eax, 208
    jge .palette_third
    cmp dword ptr [rip + palette_selection], 1
    je .event_loop
    mov dword ptr [rip + palette_selection], 1
    jmp .palette_changed
.palette_third:
    cmp eax, 240
    jl .event_loop
    cmp eax, 288
    jge .event_loop
    cmp dword ptr [rip + palette_selection], 2
    je .event_loop
    mov dword ptr [rip + palette_selection], 2
.palette_changed:
    mov dword ptr [rip + redraw_pending], 1
    cmp dword ptr [rip + buffer_busy], 0
    jne .event_loop
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_keyboard_event:
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .check_toplevel_close
    cmp dword ptr [rip + last_object], eax
    jne .check_toplevel_close
    cmp dword ptr [rip + last_opcode], 1
    je .keyboard_enter
    cmp dword ptr [rip + last_opcode], 2
    je .keyboard_leave
    cmp dword ptr [rip + last_opcode], 3
    je .keyboard_key
    cmp dword ptr [rip + last_opcode], 4
    je .keyboard_modifiers
    # The XKB keymap FD and repeat-info are still deferred. Modifier masks
    # are consumed below so Shift/Lock state follows the compositor.
    jmp .event_loop
.keyboard_modifiers:
    cmp dword ptr [rip + last_size], 20
    jb .event_loop
    # wl_keyboard.modifiers: serial, depressed, latched, locked, group.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    test eax, 1
    setnz al
    movzx eax, al
    mov dword ptr [rip + shift_down], eax
    mov eax, dword ptr [rip + event_payload + 12]
    and eax, 2
    shr eax, 1
    mov dword ptr [rip + caps_lock], eax
    jmp .event_loop
.keyboard_enter:
    cmp dword ptr [rip + last_size], 12
    jb .event_loop
    cmp dword ptr [rip + event_payload + 4], 8
    jne .event_loop
    mov dword ptr [rip + keyboard_focused], 1
    jmp .event_loop
.keyboard_leave:
    cmp dword ptr [rip + last_size], 8
    jb .event_loop
    mov dword ptr [rip + keyboard_focused], 0
    jmp .event_loop
.keyboard_key:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + keyboard_focused], 1
    jne .event_loop
    mov eax, dword ptr [rip + event_payload + 8]  # evdev keycode
    mov edx, dword ptr [rip + event_payload + 12] # 1=pressed, 0=released
    cmp eax, 42
    je .keyboard_shift
    cmp eax, 54
    je .keyboard_shift
    cmp eax, 58
    jne .keyboard_non_modifier
    test edx, edx
    jz .event_loop
    xor dword ptr [rip + caps_lock], 1
    jmp .keyboard_changed
.keyboard_shift:
    mov dword ptr [rip + shift_down], edx
    jmp .event_loop
.keyboard_non_modifier:
    test edx, edx
    jz .event_loop
    cmp eax, 105
    je .keyboard_left
    cmp eax, 106
    je .keyboard_right
    cmp eax, 103
    je .keyboard_up
    cmp eax, 108
    je .keyboard_down
    cmp eax, 102
    je .keyboard_home
    cmp eax, 107
    je .keyboard_end
    cmp eax, 14
    je .keyboard_backspace
    cmp eax, 111
    je .keyboard_delete
    cmp eax, 28
    je .keyboard_enter_key
    cmp eax, 15
    je .keyboard_tab
    mov edi, eax
    call keycode_to_ascii
    test eax, eax
    jz .event_loop
    mov edi, eax
    call doc_insert_byte
    jmp .keyboard_changed
.keyboard_left:
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    dec dword ptr [rip + doc_cursor]
    jmp .keyboard_changed
.keyboard_right:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    inc dword ptr [rip + doc_cursor]
    jmp .keyboard_changed
.keyboard_up:
    xor edi, edi
    call doc_move_vertical
    jmp .keyboard_changed
.keyboard_down:
    mov edi, 1
    call doc_move_vertical
    jmp .keyboard_changed
.keyboard_home:
    xor edi, edi
    call doc_move_line_edge
    jmp .keyboard_changed
.keyboard_end:
    mov edi, 1
    call doc_move_line_edge
    jmp .keyboard_changed
.keyboard_backspace:
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    dec dword ptr [rip + doc_cursor]
    call doc_delete_at_cursor
    jmp .keyboard_changed
.keyboard_delete:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    call doc_delete_at_cursor
    jmp .keyboard_changed
.keyboard_enter_key:
    mov edi, 10
    call doc_insert_byte
    jmp .keyboard_changed
.keyboard_tab:
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
.keyboard_changed:
    mov dword ptr [rip + redraw_pending], 1
    cmp dword ptr [rip + buffer_busy], 0
    jne .event_loop
    call present_buffer
    test rax, rax
    js .protocol_error
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
    jz .registry_try_seat
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + xdg_global], eax
    jmp .registry_done
.registry_try_seat:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_seat]
    call string_equal
    test eax, eax
    jz .registry_done
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + seat_global], eax
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

# Draw a filled rectangle.
# Inputs: RDI=base, ESI=x, EDX=y, ECX=width, R8D=height, R9D=XRGB8888.
.type draw_rect, @function
draw_rect:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx
    mov r15d, r8d
    mov r11d, r9d
    xor r10d, r10d
.draw_rect_row:
    cmp r10d, r15d
    jae .draw_rect_done
    mov eax, r13d
    add eax, r10d
    imul rax, STRIDE
    mov edx, r12d
    shl edx, 2
    add rax, rdx
    add rax, rbx
    mov rdi, rax
    mov ecx, r14d
    mov eax, r11d
    rep stosd
    inc r10d
    jmp .draw_rect_row
.draw_rect_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_rect, . - draw_rect

# Repaint the small input demo: clicking a swatch changes the selected border.
.type render_surface, @function
render_surface:
    push rbp
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, WIDTH
    mov r8d, HEIGHT
    mov r9d, 0xff252a33
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, WIDTH
    mov r8d, 36
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    xor edx, edx
    mov ecx, 4
    mov r8d, 4
    mov r9d, 0xff78a9d4
    call draw_rect

    cmp dword ptr [rip + palette_selection], 0
    jne .render_tile0_idle
    mov r9d, 0xffffffff
    jmp .render_tile0_border
.render_tile0_idle:
    mov r9d, 0xff596273
.render_tile0_border:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 77
    mov edx, 93
    mov ecx, 54
    mov r8d, 54
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 80
    mov edx, 96
    mov ecx, 48
    mov r8d, 48
    mov r9d, 0xff78a9d4
    call draw_rect

    cmp dword ptr [rip + palette_selection], 1
    jne .render_tile1_idle
    mov r9d, 0xffffffff
    jmp .render_tile1_border
.render_tile1_idle:
    mov r9d, 0xff596273
.render_tile1_border:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 157
    mov edx, 93
    mov ecx, 54
    mov r8d, 54
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 160
    mov edx, 96
    mov ecx, 48
    mov r8d, 48
    mov r9d, 0xffe09f7d
    call draw_rect

    cmp dword ptr [rip + palette_selection], 2
    jne .render_tile2_idle
    mov r9d, 0xffffffff
    jmp .render_tile2_border
.render_tile2_idle:
    mov r9d, 0xff596273
.render_tile2_border:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 237
    mov edx, 93
    mov ecx, 54
    mov r8d, 54
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 240
    mov edx, 96
    mov ecx, 48
    mov r8d, 48
    mov r9d, 0xff9dc58a
    call draw_rect
    call render_document
    pop rbp
    ret
.size render_surface, . - render_surface

# Attach and repaint the one buffer, but only after wl_buffer.release.
# RAX = 0 on success, negative on failure.
.type present_buffer, @function
present_buffer:
    sub rsp, 8                  # maintain 16-byte alignment for nested calls
    cmp dword ptr [rip + buffer_busy], 0
    jne .present_buffer_busy
    call render_surface
    mov dword ptr [rip + payload_buffer], 12
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], 0
    mov edi, 8
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 12
    call wl_send_request
    test rax, rax
    js .present_buffer_done
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
    js .present_buffer_done
    mov edi, 8
    mov esi, 6
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + buffer_busy], 1
    mov dword ptr [rip + redraw_pending], 0
    xor eax, eax
    add rsp, 8
    ret
.present_buffer_busy:
    mov eax, -16
.present_buffer_done:
    add rsp, 8
    ret
.size present_buffer, . - present_buffer

# Insert one byte at the cursor. The bounded buffer never writes past its allocation.
.type doc_insert_byte, @function
doc_insert_byte:
    push rbx
    push r12
    push r13
    mov r13d, edi
    mov eax, dword ptr [rip + doc_length]
    cmp eax, DOC_CAPACITY
    jae .doc_insert_done
    mov edx, dword ptr [rip + doc_cursor]
    lea r12, [rip + doc_buffer]
.doc_insert_shift:
    cmp eax, edx
    jbe .doc_insert_store
    mov bl, byte ptr [r12 + rax - 1]
    mov byte ptr [r12 + rax], bl
    dec eax
    jmp .doc_insert_shift
.doc_insert_store:
    mov byte ptr [r12 + rdx], r13b
    inc dword ptr [rip + doc_length]
    inc dword ptr [rip + doc_cursor]
.doc_insert_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_insert_byte, . - doc_insert_byte

.type doc_delete_at_cursor, @function
doc_delete_at_cursor:
    push rbx
    push r12
    push r13
    mov edx, dword ptr [rip + doc_cursor]
    mov eax, dword ptr [rip + doc_length]
    cmp edx, eax
    jae .doc_delete_done
    lea r12, [rip + doc_buffer]
    mov ecx, edx
.doc_delete_shift:
    lea r13d, [rcx + 1]
    cmp r13d, eax
    jae .doc_delete_finish
    mov bl, byte ptr [r12 + r13]
    mov byte ptr [r12 + rcx], bl
    inc ecx
    jmp .doc_delete_shift
.doc_delete_finish:
    dec dword ptr [rip + doc_length]
.doc_delete_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_delete_at_cursor, . - doc_delete_at_cursor

# EDI=0 Home, EDI=1 End.
.type doc_move_line_edge, @function
doc_move_line_edge:
    push rbx
    push r12
    mov ebx, dword ptr [rip + doc_cursor]
    lea r12, [rip + doc_buffer]
    test edi, edi
    jnz .doc_edge_end
.doc_edge_home:
    test ebx, ebx
    jz .doc_edge_store
    dec ebx
    cmp byte ptr [r12 + rbx], 10
    jne .doc_edge_home
    inc ebx
    jmp .doc_edge_store
.doc_edge_end:
    mov eax, dword ptr [rip + doc_length]
.doc_edge_end_scan:
    cmp ebx, eax
    jae .doc_edge_store
    cmp byte ptr [r12 + rbx], 10
    je .doc_edge_store
    inc ebx
    jmp .doc_edge_end_scan
.doc_edge_store:
    mov dword ptr [rip + doc_cursor], ebx
    pop r12
    pop rbx
    ret
.size doc_move_line_edge, . - doc_move_line_edge

# EDI=0 moves up; EDI=1 moves down, preserving the byte column when possible.
.type doc_move_vertical, @function
doc_move_vertical:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov ebx, dword ptr [rip + doc_cursor]
    lea r12, [rip + doc_buffer]
    mov r13d, ebx
.doc_vertical_find_start:
    test r13d, r13d
    jz .doc_vertical_column
    dec r13d
    cmp byte ptr [r12 + r13], 10
    jne .doc_vertical_find_start
    inc r13d
.doc_vertical_column:
    mov r14d, ebx
    sub r14d, r13d
    test edi, edi
    jnz .doc_vertical_down
    test r13d, r13d
    jz .doc_vertical_done
    lea r15d, [r13d - 1]
    mov eax, r15d
.doc_vertical_up_start:
    test eax, eax
    jz .doc_vertical_up_ready
    dec eax
    cmp byte ptr [r12 + rax], 10
    jne .doc_vertical_up_start
    inc eax
.doc_vertical_up_ready:
    mov ecx, r15d
    sub ecx, eax
    cmp r14d, ecx
    cmova r14d, ecx
    add eax, r14d
    mov dword ptr [rip + doc_cursor], eax
    jmp .doc_vertical_done
.doc_vertical_down:
    mov eax, ebx
    mov ecx, dword ptr [rip + doc_length]
.doc_vertical_find_end:
    cmp eax, ecx
    jae .doc_vertical_done
    cmp byte ptr [r12 + rax], 10
    je .doc_vertical_next_start
    inc eax
    jmp .doc_vertical_find_end
.doc_vertical_next_start:
    inc eax
    mov r15d, eax
.doc_vertical_next_end:
    cmp eax, ecx
    jae .doc_vertical_down_ready
    cmp byte ptr [r12 + rax], 10
    je .doc_vertical_down_ready
    inc eax
    jmp .doc_vertical_next_end
.doc_vertical_down_ready:
    sub eax, r15d
    cmp r14d, eax
    cmova r14d, eax
    lea eax, [r15d + r14d]
    mov dword ptr [rip + doc_cursor], eax
.doc_vertical_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_move_vertical, . - doc_move_vertical

# Temporary US-QWERTY evdev mapping. XKB parsing is a separate next milestone.
.type keycode_to_ascii, @function
keycode_to_ascii:
    cmp edi, 128
    jae .keymap_unknown
    mov ecx, edi
    lea r8, [rip + keymap_base]
    movzx eax, byte ptr [r8 + rcx]
    test eax, eax
    jz .keymap_unknown
    cmp eax, 'a'
    jb .keymap_shift_punctuation
    cmp eax, 'z'
    ja .keymap_shift_punctuation
    mov edx, dword ptr [rip + shift_down]
    xor edx, dword ptr [rip + caps_lock]
    test edx, edx
    jz .keymap_done
    sub eax, 32
    ret
.keymap_shift_punctuation:
    cmp dword ptr [rip + shift_down], 0
    je .keymap_done
    lea r8, [rip + keymap_shift]
    movzx edx, byte ptr [r8 + rcx]
    test edx, edx
    jz .keymap_done
    mov eax, edx
.keymap_done:
    ret
.keymap_unknown:
    xor eax, eax
    ret
.size keycode_to_ascii, . - keycode_to_ascii

.type draw_glyph, @function
draw_glyph:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov eax, edx
    cmp eax, ' '
    je .glyph_done
    cmp eax, 'a'
    jb .glyph_upper
    cmp eax, 'z'
    ja .glyph_upper
    sub eax, 32
.glyph_upper:
    cmp eax, 'A'
    jb .glyph_digit
    cmp eax, 'Z'
    ja .glyph_digit
    sub eax, 'A'
    jmp .glyph_index_ready
.glyph_digit:
    cmp eax, '0'
    jb .glyph_punctuation
    cmp eax, '9'
    ja .glyph_punctuation
    sub eax, '0'
    add eax, 26
    jmp .glyph_index_ready
.glyph_punctuation:
    cmp eax, '?'
    je .glyph_question
    cmp eax, '.'
    je .glyph_period
    cmp eax, ','
    je .glyph_comma
    cmp eax, ':'
    je .glyph_colon
    cmp eax, '-'
    je .glyph_dash
    cmp eax, '_'
    je .glyph_underscore
    cmp eax, '!'
    je .glyph_exclamation
    cmp eax, '"'
    je .glyph_quote
    cmp eax, 39
    je .glyph_apostrophe
    cmp eax, '('
    je .glyph_open_paren
    cmp eax, ')'
    je .glyph_close_paren
    cmp eax, '+'
    je .glyph_plus
    cmp eax, '='
    je .glyph_equals
    cmp eax, '/'
    je .glyph_slash
    mov eax, 36
    jmp .glyph_index_ready
.glyph_question:
    mov eax, 36
    jmp .glyph_index_ready
.glyph_period:
    mov eax, 37
    jmp .glyph_index_ready
.glyph_comma:
    mov eax, 38
    jmp .glyph_index_ready
.glyph_colon:
    mov eax, 39
    jmp .glyph_index_ready
.glyph_dash:
    mov eax, 40
    jmp .glyph_index_ready
.glyph_underscore:
    mov eax, 41
    jmp .glyph_index_ready
.glyph_exclamation:
    mov eax, 42
    jmp .glyph_index_ready
.glyph_quote:
    mov eax, 43
    jmp .glyph_index_ready
.glyph_apostrophe:
    mov eax, 44
    jmp .glyph_index_ready
.glyph_open_paren:
    mov eax, 45
    jmp .glyph_index_ready
.glyph_close_paren:
    mov eax, 46
    jmp .glyph_index_ready
.glyph_plus:
    mov eax, 47
    jmp .glyph_index_ready
.glyph_equals:
    mov eax, 48
    jmp .glyph_index_ready
.glyph_slash:
    mov eax, 49
.glyph_index_ready:
    imul eax, 7
    lea rbx, [rip + font_5x7]
    add rbx, rax
    xor r14d, r14d
.glyph_row:
    cmp r14d, 7
    jae .glyph_done
    movzx r8d, byte ptr [rbx + r14]
    xor r15d, r15d
.glyph_column:
    cmp r15d, 5
    jae .glyph_next_row
    mov eax, 4
    sub eax, r15d
    bt r8d, eax
    jnc .glyph_next_column
    mov eax, r13d
    add eax, r14d
    imul eax, STRIDE
    mov edx, r12d
    add edx, r15d
    shl edx, 2
    add eax, edx
    mov rdi, qword ptr [rip + shm_mapping]
    add rdi, rax
    mov dword ptr [rdi], 0xffd8dee9
.glyph_next_column:
    inc r15d
    jmp .glyph_column
.glyph_next_row:
    inc r14d
    jmp .glyph_row
.glyph_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_glyph, . - draw_glyph

.type render_document, @function
render_document:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, DOC_LEFT
    mov r13d, DOC_TOP
    mov r14d, 0
    mov r15d, dword ptr [rip + doc_length]
    test r15d, r15d
    jnz .document_have_text
    lea rbx, [rip + empty_document_hint]
.document_hint_loop:
    movzx edx, byte ptr [rbx]
    test edx, edx
    jz .document_draw_cursor
    mov edi, r12d
    mov esi, r13d
    call draw_glyph
    add r12d, CELL_WIDTH
    inc rbx
    jmp .document_hint_loop
.document_have_text:
    lea rbx, [rip + doc_buffer]
.document_render_loop:
    cmp r14d, r15d
    jae .document_draw_cursor
    cmp r13d, HEIGHT - 10
    ja .document_draw_cursor
    cmp r12d, WIDTH - 8
    jae .document_next_byte
    movzx edx, byte ptr [rbx + r14]
    cmp edx, 10
    je .document_newline
    cmp edx, 9
    je .document_tab
    cmp edx, 32
    jb .document_control
    cmp edx, 127
    jb .document_printable
.document_control:
    cmp edx, 128
    jb .document_next_byte
    mov eax, edx
    and eax, 0xc0
    cmp eax, 0x80
    je .document_next_byte
    mov edx, '?'
.document_printable:
    mov edi, r12d
    mov esi, r13d
    call draw_glyph
    add r12d, CELL_WIDTH
    jmp .document_next_byte
.document_tab:
    add r12d, CELL_WIDTH * 4
    jmp .document_next_byte
.document_newline:
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
.document_next_byte:
    inc r14d
    jmp .document_render_loop
.document_draw_cursor:
    xor r14d, r14d
    xor r12d, r12d
    xor r13d, r13d
.document_cursor_scan:
    cmp r14d, dword ptr [rip + doc_cursor]
    jae .document_cursor_ready
    lea rbx, [rip + doc_buffer]
    movzx eax, byte ptr [rbx + r14]
    cmp eax, 10
    je .document_cursor_newline
    cmp eax, 9
    je .document_cursor_tab
    cmp eax, 32
    jb .document_cursor_next
    cmp eax, 127
    jbe .document_cursor_column
    cmp eax, 0xc0
    jb .document_cursor_next
.document_cursor_column:
    inc r12d
    jmp .document_cursor_next
.document_cursor_tab:
    add r12d, 4
    jmp .document_cursor_next
.document_cursor_newline:
    xor r12d, r12d
    inc r13d
.document_cursor_next:
    inc r14d
    jmp .document_cursor_scan
.document_cursor_ready:
    imul r12d, CELL_WIDTH
    add r12d, DOC_LEFT
    imul r13d, LINE_HEIGHT
    add r13d, DOC_TOP
    cmp r12d, WIDTH - 2
    ja .document_render_done
    cmp r13d, HEIGHT - 10
    ja .document_render_done
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, 1
    mov r8d, 9
    mov r9d, 0xffffffff
    call draw_rect
.document_render_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size render_document, . - render_document

# Create input objects after wl_seat advertises their capabilities.
# Pointer is allocated before keyboard when both appear in the same event.
.type handle_seat_capabilities, @function
handle_seat_capabilities:
    push rbp
    cmp dword ptr [rip + last_size], 4
    jb .seat_caps_success
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + seat_capabilities], eax

    test eax, 1
    jz .seat_caps_keyboard
    cmp dword ptr [rip + pointer_created], 0
    jne .seat_caps_keyboard
    mov eax, dword ptr [rip + next_input_object]
    mov dword ptr [rip + pointer_object], eax
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 13
    xor esi, esi                  # wl_seat.get_pointer
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .seat_caps_done
    mov dword ptr [rip + pointer_created], 1
    inc dword ptr [rip + next_input_object]

.seat_caps_keyboard:
    test dword ptr [rip + seat_capabilities], 2
    jz .seat_caps_success
    cmp dword ptr [rip + keyboard_created], 0
    jne .seat_caps_success
    mov eax, dword ptr [rip + next_input_object]
    mov dword ptr [rip + keyboard_object], eax
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 13
    mov esi, 1                    # wl_seat.get_keyboard
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .seat_caps_done
    mov dword ptr [rip + keyboard_created], 1
    inc dword ptr [rip + next_input_object]

.seat_caps_success:
    xor eax, eax
.seat_caps_done:
    pop rbp
    ret
.size handle_seat_capabilities, . - handle_seat_capabilities

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
