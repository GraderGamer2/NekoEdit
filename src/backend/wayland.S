.intel_syntax noprefix

.equ SYS_read,          0
.equ SYS_write,         1
.equ SYS_close,         3
.equ SYS_lseek,          8
.equ SYS_getcwd,        79
.equ SYS_getdents64,   217
.equ SYS_newfstatat,   262
.equ SYS_openat,      257
.equ SYS_poll,          7
.equ SYS_timerfd_create, 283
.equ SYS_timerfd_settime, 286
.equ SYS_socket,       41
.equ SYS_connect,      42
.equ SYS_sendmsg,      46
.equ SYS_recvmsg,      47
.equ SYS_munmap,       11
.equ SYS_ftruncate,    77
.equ SYS_mmap,          9
.equ SYS_memfd_create, 319
.equ AF_UNIX,            1
.equ SOCK_STREAM,       1
.equ SOCK_CLOEXEC, 0x80000
.equ PROT_READ,          1
.equ PROT_WRITE,         2
.equ MAP_SHARED,         1
.equ MAP_PRIVATE,        2
.equ MFD_CLOEXEC,        1
.equ AT_FDCWD,          -100
.equ O_WRONLY,             1
.equ O_CREAT,             64
.equ O_CLOEXEC,       0x80000
.equ O_DIRECTORY,    0x10000
.equ AT_SYMLINK_NOFOLLOW, 0x100
.equ STAT_S_IFMT,     0xf000
.equ STAT_S_IFDIR,    0x4000
.equ STAT_S_IFREG,    0x8000
.equ SYS_fsync,         74
.equ SYS_getpid,        39
.equ SYS_renameat,     264
.equ SYS_unlinkat,     263
.equ O_EXCL,           128
.equ SOL_SOCKET,         1
.equ SCM_RIGHTS,         1
.equ MSG_CMSG_CLOEXEC, 0x40000000
.equ MSG_CTRUNC,          8
.equ XKB_KEYMAP_MAX_SIZE, 1048576
.equ WIDTH,            800
.equ HEIGHT,           480
.equ STRIDE,           (WIDTH * 4)
.equ BUFFER_SIZE,      (STRIDE * HEIGHT)
.equ BTN_LEFT,          0x110
.equ CLOCK_MONOTONIC,      1
.equ TFD_CLOEXEC,     0x80000
.equ POLLIN,              1
.equ REPEAT_DEFAULT_DELAY_MS, 300
.equ REPEAT_DEFAULT_RATE, 30
.equ REPEAT_NS_PER_SECOND, 1000000000
.equ REPEAT_MAX_RATE, 1000
.equ DOC_CAPACITY,    65536
.equ PATH_CAPACITY,    4096
.equ PICKER_MAX_ENTRIES, 128
.equ PICKER_ENTRY_SIZE, 260
.equ PICKER_DIR_BYTES, 8192
.equ PICKER_VISIBLE_ROWS, 15
.equ DOC_LEFT,           16
.equ DOC_TOP,            92
.equ STATUS_TOP,         460
.equ CELL_WIDTH,          8
.equ LINE_HEIGHT,        12
.equ DOC_COLUMNS,        ((WIDTH - DOC_LEFT - 8) / CELL_WIDTH)
.equ DOC_VISIBLE_ROWS,   ((STATUS_TOP - DOC_TOP) / LINE_HEIGHT)

.section .rodata
wayland_socket_env_key: .asciz "WAYLAND_SOCKET"
wayland_env_key:       .asciz "WAYLAND_DISPLAY"
xdg_runtime_env_key:   .asciz "XDG_RUNTIME_DIR"
default_wayland_name:  .asciz "wayland-0"
ui_app_name:           .asciz "NekoEdit"
ui_mode_error:         .asciz "SAVE ERR"
ui_document_name:      .asciz "Untitled"
ui_mode_name:          .asciz "ASCII"
ui_file_label:         .asciz "File"
ui_menu_open_label:    .asciz "Open"
ui_menu_save_label:    .asciz "Save"
ui_menu_save_as_label: .asciz "Save As"
ui_prompt_open_title:  .asciz "OPEN FILE PATH"
ui_prompt_save_title:  .asciz "SAVE AS PATH"
ui_prompt_help:        .asciz "ENTER: CONFIRM   ESC: CANCEL"
ui_open_error:         .asciz "OPEN ERR"
ui_picker_open_title:  .asciz "OPEN FILE"
ui_picker_save_title:  .asciz "SAVE FILE AS"
ui_picker_path_label:  .asciz "LOCATION"
ui_picker_name_label:  .asciz "FILE NAME"
ui_picker_up_label:   .asciz "UP"
ui_picker_home_label: .asciz "HOME"
ui_picker_hidden_label: .asciz "SHOW HIDDEN"
ui_picker_cancel_label: .asciz "CANCEL"
ui_picker_open_label: .asciz "OPEN"
ui_picker_save_label: .asciz "SAVE"
ui_picker_dir_marker: .asciz "[D]"
ui_picker_file_marker: .asciz "[F]"
ui_picker_empty: .asciz "(EMPTY DIRECTORY)"
ui_picker_truncated: .asciz "LIST LIMITED TO FIRST 128 ENTRIES"
ui_picker_error_path: .asciz "CANNOT OPEN DIRECTORY"
ui_picker_error_file: .asciz "CANNOT OPEN FILE"
ui_picker_error_save: .asciz "SAVE FAILED"
ui_picker_overwrite: .asciz "FILE EXISTS - OVERWRITE?  Y / N"
ui_picker_home_env: .asciz "HOME"
ui_picker_dot: .asciz "."
ui_picker_parent: .asciz ".."
ui_label_line:         .asciz "Ln "
ui_label_column:       .asciz ", Col "
ui_label_bytes:        .asciz "Bytes "
wayland_title:         .asciz "NekoEdit - development window"
memfd_label:           .asciz "nekoedit-shm"
xkb_keymap_magic:      .ascii "xkb_keymap"
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
msg_file_error:        .ascii "NekoEdit: could not open file or file exceeds the 64 KiB document limit.\n"
msg_file_error_end:
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

    # Additional printable-ASCII punctuation glyphs (indices 50 through 67).
    .byte 10, 10, 31, 10, 31, 10, 10       # #
    .byte 4, 15, 20, 14, 5, 30, 4          # $
    .byte 24, 25, 1, 2, 4, 19, 3           # %
    .byte 12, 18, 20, 8, 21, 18, 13        # &
    .byte 0, 21, 14, 31, 14, 21, 0         # *
    .byte 0, 12, 12, 0, 12, 12, 8          # ;
    .byte 2, 4, 8, 16, 8, 4, 2            # <
    .byte 8, 4, 2, 1, 2, 4, 8              # >
    .byte 14, 17, 23, 21, 23, 16, 14       # @
    .byte 14, 8, 8, 8, 8, 8, 14            # [
    .byte 16, 8, 8, 4, 2, 2, 1             # backslash
    .byte 14, 2, 2, 2, 2, 2, 14            # ]
    .byte 4, 10, 17, 0, 0, 0, 0            # ^
    .byte 8, 4, 2, 0, 0, 0, 0              # grave accent
    .byte 3, 4, 4, 8, 4, 4, 3              # {
    .byte 4, 4, 4, 4, 4, 4, 4              # |
    .byte 24, 4, 4, 2, 4, 4, 24            # }
    .byte 0, 0, 9, 22, 0, 0, 0             # ~

.section .data
.balign 4
repeat_rate:            .long REPEAT_DEFAULT_RATE
repeat_delay_ms:        .long REPEAT_DEFAULT_DELAY_MS
active_document_name:   .ascii "Untitled"
                        .byte 0
                        .zero 24

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
seat_version:          .long 0
pointer_x:             .long 0
pointer_y:             .long 0
pointer_inside:         .long 0
pointer_created:        .long 0
pointer_object:         .long 0
keyboard_created:       .long 0
keyboard_object:        .long 0
keyboard_focused:       .long 0
keyboard_group:         .long 0
level3_down:            .long 0
event_fd:               .long 0       # initialized to -1 in wayland_main
keymap_format:          .long 0
keymap_size:            .long 0
keymap_processing_complete: .long 0
.balign 8
keymap_mapping:         .quad 0
next_input_object:      .long 0
seat_capabilities:      .long 0
pointer_button_down:    .long 0
doc_selection_active:   .long 0
doc_selection_anchor:   .long 0
doc_selection_start:    .long 0
doc_selection_end:      .long 0
doc_view_top_row:       .long 0
repeat_timer_fd:         .long 0
repeat_keycode:          .long 0
poll_fds:               .zero 16
repeat_timer_spec:      .zero 32
repeat_timer_read:      .quad 0
buffer_busy:            .long 0
redraw_pending:         .long 0
shift_down:             .long 0
caps_lock:              .long 0
ctrl_down:              .long 0
doc_length:             .long 0
doc_cursor:             .long 0
# Logical document bytes are stored before and after [doc_gap_start, doc_gap_end).
doc_gap_start:          .long 0
doc_gap_end:            .long 0
doc_buffer:             .zero DOC_CAPACITY
current_file_path:      .quad 0
doc_save_error:         .long 0
doc_open_error:         .long 0
file_menu_open:         .long 0
path_prompt_mode:       .long 0
path_prompt_length:     .long 0
file_probe_byte:        .byte 0
.balign 8
save_target_path:       .quad 0
.balign 16
path_prompt_buffer:     .zero PATH_CAPACITY
current_path_buffer:    .zero PATH_CAPACITY
.global picker_mode, picker_dir_fd, picker_error, picker_entry_count, picker_selected, picker_last_click_index, picker_last_click_time, picker_name_length, picker_name_buffer, doc_length, doc_buffer, current_file_path, current_path_buffer, picker_target_buffer, doc_save_error
picker_mode:            .long 0
picker_focus:           .long 0
picker_dir_fd:          .long 0
picker_error:           .long 0
picker_entry_count:     .long 0
picker_selected:        .long 0
picker_scroll:          .long 0
picker_show_hidden:     .long 0
picker_truncated:       .long 0
picker_path_length:     .long 0
picker_name_length:     .long 0
picker_last_click_index: .long 0
picker_last_click_time: .long 0
picker_overwrite_pending: .long 0
picker_dirents:         .zero PICKER_DIR_BYTES
picker_stat_buffer:     .zero 144
picker_entries:         .zero (PICKER_MAX_ENTRIES * PICKER_ENTRY_SIZE)
picker_candidate:       .zero PICKER_ENTRY_SIZE
picker_current_path:    .zero PATH_CAPACITY
picker_path_buffer:     .zero PATH_CAPACITY
picker_name_buffer:     .zero 256
picker_target_buffer:   .zero PATH_CAPACITY
load_buffer:            .zero DOC_CAPACITY
temp_path_buffer:       .zero PATH_CAPACITY
temp_pid_digits:        .zero 16
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
.balign 8
recv_iov:              .zero 16
.balign 8
recv_msg_header:       .zero 56
.balign 8
recv_msg_control:      .zero 64

.section .text
.extern linux_write_all
.extern linux_read_exact
.extern linux_exit
.extern initial_file_path
.extern xkb_parse_keymap
.extern xkb_reset_keymap
.extern xkb_lookup_ascii
.global wayland_main
.type wayland_main, @function
wayland_main:
    push rbp                    # keep 16-byte call-site stack alignment
    mov dword ptr [rip + event_fd], -1
    call load_initial_document
    test rax, rax
    js .initial_file_error
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
    mov ecx, dword ptr [rip + seat_version]
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

    # Main event loop: pointer input edits the document. The single
    # wl_buffer is only rewritten after wl_buffer.release.
.event_loop:
    lea rax, [rip + stage_event_loop]
    mov qword ptr [rip + failure_stage], rax
    cmp dword ptr [rip + repeat_timer_fd], 0
    jne .event_poll_prepare
    # A monotonic timerfd lets key repetition proceed while the Wayland
    # socket is otherwise idle, without introducing a userspace runtime.
    mov eax, SYS_timerfd_create
    mov edi, CLOCK_MONOTONIC
    mov esi, TFD_CLOEXEC
    syscall
    test rax, rax
    js .protocol_error
    mov dword ptr [rip + repeat_timer_fd], eax
.event_poll_prepare:
    mov eax, dword ptr [rip + socket_fd]
    mov dword ptr [rip + poll_fds], eax
    mov word ptr [rip + poll_fds + 4], POLLIN
    mov eax, dword ptr [rip + repeat_timer_fd]
    mov dword ptr [rip + poll_fds + 8], eax
    mov word ptr [rip + poll_fds + 12], POLLIN
    mov eax, SYS_poll
    lea rdi, [rip + poll_fds]
    mov esi, 2
    mov edx, -1
    syscall
    test rax, rax
    js .protocol_error
    # Drain compositor events before a simultaneous repeat timeout so key
    # releases always get a chance to cancel repetition first.
    movzx eax, word ptr [rip + poll_fds + 6]
    test eax, eax
    jnz .event_read_wayland
    movzx eax, word ptr [rip + poll_fds + 14]
    test eax, eax
    jnz .event_repeat_timer
    jmp .event_loop
.event_read_wayland:
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
    cmp dword ptr [rip + pointer_button_down], 1
    jne .event_loop
    cmp dword ptr [rip + pointer_inside], 1
    jne .event_loop
    mov eax, dword ptr [rip + pointer_y]
    cmp eax, DOC_TOP
    jl .event_loop
    cmp eax, HEIGHT
    jae .event_loop
    mov eax, dword ptr [rip + pointer_x]
    test eax, eax
    js .event_loop
    cmp eax, WIDTH
    ja .event_loop
    mov edi, eax
    mov esi, dword ptr [rip + pointer_y]
    call doc_place_cursor_from_pointer
    mov eax, dword ptr [rip + doc_selection_anchor]
    cmp eax, dword ptr [rip + doc_cursor]
    jne .Lneko_pointer_selection_set
    mov dword ptr [rip + doc_selection_active], 0
    jmp .keyboard_changed
.Lneko_pointer_selection_set:
    mov dword ptr [rip + doc_selection_active], 1
    jmp .keyboard_changed
.pointer_button:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + event_payload + 8], BTN_LEFT
    jne .event_loop
    cmp dword ptr [rip + event_payload + 12], 1
    je .pointer_button_press
    cmp dword ptr [rip + event_payload + 12], 0
    jne .event_loop
    cmp dword ptr [rip + pointer_button_down], 1
    jne .event_loop
    mov dword ptr [rip + pointer_button_down], 0
    mov eax, dword ptr [rip + doc_selection_anchor]
    cmp eax, dword ptr [rip + doc_cursor]
    jne .Lneko_pointer_button_released
    mov dword ptr [rip + doc_selection_active], 0
.Lneko_pointer_button_released:
    jmp .event_loop
.pointer_button_press:
    cmp dword ptr [rip + pointer_inside], 1
    jne .event_loop
    # The directory picker is modal; pointer input belongs to its controls.
    cmp dword ptr [rip + picker_mode], 0
    jne .picker_pointer
    # A path prompt is modal: clicking through it must never reposition the
    # document caret or insert text into the document.
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .event_loop
    mov eax, dword ptr [rip + pointer_x]
    mov edx, dword ptr [rip + pointer_y]
    # The File control is part of the application header.
    cmp edx, 32
    jae .pointer_menu_rows
    cmp eax, 104
    jb .pointer_header_outside
    cmp eax, 160
    jae .pointer_header_outside
    xor dword ptr [rip + file_menu_open], 1
    jmp .keyboard_changed
.pointer_header_outside:
    cmp dword ptr [rip + file_menu_open], 0
    je .pointer_document_click
    mov dword ptr [rip + file_menu_open], 0
    jmp .keyboard_changed
.pointer_menu_rows:
    cmp dword ptr [rip + file_menu_open], 1
    jne .pointer_document_click
    cmp eax, 104
    jb .pointer_menu_outside
    cmp eax, 232
    jae .pointer_menu_outside
    cmp edx, 32
    jb .pointer_menu_outside
    cmp edx, 112
    jae .pointer_menu_outside
    mov dword ptr [rip + file_menu_open], 0
    cmp edx, 60
    jb .pointer_menu_open
    cmp edx, 84
    jb .pointer_menu_save
    jmp .pointer_menu_save_as
.pointer_menu_open:
    call start_open_prompt
    jmp .keyboard_changed
.pointer_menu_save:
    call save_current_document
    jmp .keyboard_changed
.pointer_menu_save_as:
    call start_save_as_prompt
    jmp .keyboard_changed
.pointer_menu_outside:
    mov dword ptr [rip + file_menu_open], 0
.pointer_document_click:
    cmp edx, DOC_TOP
    jl .event_loop
    cmp edx, HEIGHT - 20
    jae .event_loop
    test eax, eax
    js .event_loop
    cmp eax, WIDTH
    ja .event_loop
    mov dword ptr [rip + pointer_button_down], 1
    mov edi, eax
    mov esi, edx
    call doc_place_cursor_from_pointer
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
    mov dword ptr [rip + doc_selection_active], 0
    jmp .keyboard_changed
.check_keyboard_event:
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .check_toplevel_close
    cmp dword ptr [rip + last_object], eax
    jne .check_toplevel_close
    cmp dword ptr [rip + last_opcode], 0
    je .keyboard_keymap
    cmp dword ptr [rip + last_opcode], 1
    je .keyboard_enter
    cmp dword ptr [rip + last_opcode], 2
    je .keyboard_leave
    cmp dword ptr [rip + last_opcode], 3
    je .keyboard_key
    cmp dword ptr [rip + last_opcode], 4
    je .keyboard_modifiers
    cmp dword ptr [rip + last_opcode], 5
    je .keyboard_repeat_info
    jmp .event_loop
.keyboard_keymap:
    cmp dword ptr [rip + last_size], 8
    jne .protocol_error
    cmp dword ptr [rip + event_fd], -1
    je .protocol_error
    call keyboard_keymap_update
    test rax, rax
    js .protocol_error
    jmp .event_loop
.event_repeat_timer:
    mov edi, dword ptr [rip + repeat_timer_fd]
    lea rsi, [rip + repeat_timer_read]
    mov edx, 8
    call linux_read_exact
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + repeat_keycode], 0
    je .event_loop
    cmp dword ptr [rip + keyboard_focused], 1
    jne .event_repeat_cancel
    mov eax, dword ptr [rip + repeat_keycode]
    mov edx, 1
    jmp .keyboard_non_modifier
.event_repeat_cancel:
    call repeat_cancel
    jmp .event_loop

.keyboard_repeat_info:
    cmp dword ptr [rip + last_size], 8
    jb .event_loop
    # wl_keyboard.repeat_info(rate, delay). Negative values violate the
    # protocol; a zero rate disables client-side repetition.
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    js .protocol_error
    mov edx, dword ptr [rip + event_payload + 4]
    test edx, edx
    js .protocol_error
    # Defend the timerfd path against pathological rates while preserving
    # practical compositor settings (the normal desktop range is far lower).
    cmp eax, REPEAT_MAX_RATE
    jbe .Lneko_repeat_rate_capped
    mov eax, REPEAT_MAX_RATE
.Lneko_repeat_rate_capped:
    mov dword ptr [rip + repeat_rate], eax
    mov dword ptr [rip + repeat_delay_ms], edx
    test eax, eax
    jnz .Lneko_repeat_info_reconfigure
    call repeat_cancel
    jmp .event_loop
.Lneko_repeat_info_reconfigure:
    mov eax, dword ptr [rip + repeat_keycode]
    test eax, eax
    jz .event_loop
    # A changed rate/delay takes effect for the currently held key too.
    call repeat_start_if_supported
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
    mov eax, dword ptr [rip + event_payload + 16]
    mov dword ptr [rip + keyboard_group], eax
    # The standard XKB Control modifier is bit 2. Physical Ctrl key
    # transitions below are also tracked so this works before a modifier
    # update is delivered and when a compositor omits modifier events.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    and eax, 4
    setnz al
    movzx eax, al
    mov dword ptr [rip + ctrl_down], eax
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
    mov dword ptr [rip + ctrl_down], 0
    mov dword ptr [rip + level3_down], 0
    call repeat_cancel
    jmp .event_loop
.keyboard_key:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + keyboard_focused], 1
    jne .event_loop
    mov eax, dword ptr [rip + event_payload + 8]  # evdev keycode
    mov edx, dword ptr [rip + event_payload + 12] # 1=pressed, 0=released
    cmp eax, 29
    je .keyboard_control
    cmp eax, 97
    je .keyboard_control
    cmp eax, 42
    je .keyboard_shift
    cmp eax, 54
    je .keyboard_shift
    cmp eax, 100                # Right Alt / common LevelThree key
    je .keyboard_level3
    test edx, edx
    jz .keyboard_key_release
    cmp eax, 58
    jne .keyboard_key_pressed
    xor dword ptr [rip + caps_lock], 1
    jmp .keyboard_changed
.keyboard_key_pressed:
    cmp dword ptr [rip + ctrl_down], 0
    jne .keyboard_key_no_repeat
    call repeat_start_if_supported
.keyboard_key_no_repeat:
    mov eax, dword ptr [rip + event_payload + 8]
    mov edx, 1
    jmp .keyboard_non_modifier
.keyboard_key_release:
    cmp eax, dword ptr [rip + repeat_keycode]
    jne .event_loop
    call repeat_cancel
    jmp .event_loop
.keyboard_shift:
    mov dword ptr [rip + shift_down], edx
    jmp .event_loop
.keyboard_level3:
    mov dword ptr [rip + level3_down], edx
    jmp .event_loop
.keyboard_control:
    mov dword ptr [rip + ctrl_down], edx
    jmp .event_loop
.keyboard_non_modifier:
    test edx, edx
    jz .event_loop
    cmp dword ptr [rip + picker_mode], 0
    jne .keyboard_picker
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .keyboard_path_prompt
    cmp dword ptr [rip + ctrl_down], 0
    je .keyboard_unmodified
    cmp eax, 24
    je .keyboard_open_command
    cmp eax, 30
    je .keyboard_select_all
    cmp eax, 31
    jne .event_loop
    cmp dword ptr [rip + shift_down], 0
    jne .keyboard_save_as_command
    cmp qword ptr [rip + current_file_path], 0
    je .keyboard_save_as_command
    jmp .keyboard_save
.keyboard_unmodified:
    cmp eax, 1
    jne .keyboard_unmodified_dispatch
    cmp dword ptr [rip + file_menu_open], 0
    je .event_loop
    mov dword ptr [rip + file_menu_open], 0
    jmp .keyboard_changed
.keyboard_unmodified_dispatch:
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
    mov r12d, eax
    call doc_delete_selection
    mov edi, r12d
    call doc_insert_byte
    jmp .keyboard_changed
.keyboard_open_command:
    call start_open_prompt
    jmp .keyboard_changed
.keyboard_save_as_command:
    call start_save_as_prompt
    jmp .keyboard_changed
.keyboard_save:
    call save_document_file
    jmp .keyboard_changed

# The path editor owns all non-modifier keys while its prompt is visible.
.picker_pointer:
    mov edi, dword ptr [rip + pointer_x]
    mov esi, dword ptr [rip + pointer_y]
    mov edx, dword ptr [rip + event_payload + 4]
    call picker_handle_pointer
    jmp .keyboard_changed

.keyboard_picker:
    mov edi, eax
    call picker_handle_key
    jmp .keyboard_changed

.keyboard_path_prompt:
    cmp dword ptr [rip + ctrl_down], 0
    jne .event_loop
    cmp eax, 1
    je .keyboard_path_escape
    cmp eax, 28
    je .keyboard_path_enter
    cmp eax, 14
    je .keyboard_path_backspace
    mov edi, eax
    call keycode_to_ascii
    test eax, eax
    jz .event_loop
    mov ecx, dword ptr [rip + path_prompt_length]
    cmp ecx, PATH_CAPACITY - 1
    jae .event_loop
    lea rdx, [rip + path_prompt_buffer]
    mov byte ptr [rdx + rcx], al
    inc ecx
    mov dword ptr [rip + path_prompt_length], ecx
    mov byte ptr [rdx + rcx], 0
    jmp .keyboard_changed
.keyboard_path_backspace:
    mov ecx, dword ptr [rip + path_prompt_length]
    test ecx, ecx
    jz .event_loop
    dec ecx
    mov dword ptr [rip + path_prompt_length], ecx
    lea rdx, [rip + path_prompt_buffer]
    mov byte ptr [rdx + rcx], 0
    jmp .keyboard_changed
.keyboard_path_escape:
    call repeat_cancel
    call cancel_path_prompt
    jmp .keyboard_changed
.keyboard_path_enter:
    call repeat_cancel
    call confirm_path_prompt
    jmp .keyboard_changed

.keyboard_select_all:
    # Ctrl+A selects the full document using the same anchor/cursor model
    # as Shift+navigation and pointer dragging.
    mov dword ptr [rip + doc_selection_anchor], 0
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_cursor], eax
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_left:
    cmp dword ptr [rip + shift_down], 0
    jne .Lneko_keyboard_left_extend
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_keyboard_left_plain
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_keyboard_left_collapse
    mov eax, edx
.Lneko_keyboard_left_collapse:
    mov dword ptr [rip + doc_cursor], eax
    call doc_clear_selection
    jmp .keyboard_changed
.Lneko_keyboard_left_plain:
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    mov edi, dword ptr [rip + doc_cursor]
    call doc_utf8_prev
    mov dword ptr [rip + doc_cursor], eax
    jmp .keyboard_changed
.Lneko_keyboard_left_extend:
    call doc_begin_keyboard_selection
    cmp dword ptr [rip + doc_cursor], 0
    je .Lneko_keyboard_left_extend_finish
    mov edi, dword ptr [rip + doc_cursor]
    call doc_utf8_prev
    mov dword ptr [rip + doc_cursor], eax
.Lneko_keyboard_left_extend_finish:
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_right:
    cmp dword ptr [rip + shift_down], 0
    jne .Lneko_keyboard_right_extend
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_keyboard_right_plain
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jae .Lneko_keyboard_right_collapse
    mov eax, edx
.Lneko_keyboard_right_collapse:
    mov dword ptr [rip + doc_cursor], eax
    call doc_clear_selection
    jmp .keyboard_changed
.Lneko_keyboard_right_plain:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    mov edi, eax
    call doc_utf8_next
    mov dword ptr [rip + doc_cursor], eax
    jmp .keyboard_changed
.Lneko_keyboard_right_extend:
    call doc_begin_keyboard_selection
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .Lneko_keyboard_right_extend_finish
    mov edi, eax
    call doc_utf8_next
    mov dword ptr [rip + doc_cursor], eax
.Lneko_keyboard_right_extend_finish:
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_up:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_up_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_vertical
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_up_plain:
    xor edi, edi
    call doc_move_vertical
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_down:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_down_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_vertical
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_down_plain:
    mov edi, 1
    call doc_move_vertical
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_home:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_home_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_line_edge
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_home_plain:
    xor edi, edi
    call doc_move_line_edge
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_end:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_end_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_line_edge
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_end_plain:
    mov edi, 1
    call doc_move_line_edge
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_backspace:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_keyboard_backspace_selection
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    mov edi, dword ptr [rip + doc_cursor]
    call doc_utf8_prev
    mov dword ptr [rip + doc_cursor], eax
    call doc_delete_at_cursor
    jmp .keyboard_changed
.Lneko_keyboard_backspace_selection:
    call doc_delete_selection
    jmp .keyboard_changed
.keyboard_delete:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_keyboard_delete_selection
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    call doc_delete_at_cursor
    jmp .keyboard_changed
.Lneko_keyboard_delete_selection:
    call doc_delete_selection
    jmp .keyboard_changed
.keyboard_enter_key:
    call doc_delete_selection
    mov edi, 10
    call doc_insert_byte
    jmp .keyboard_changed
.keyboard_tab:
    call doc_delete_selection
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
.keyboard_changed:
    call doc_ensure_cursor_visible
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

.initial_file_error:
    mov edi, 2
    lea rsi, [rip + msg_file_error]
    mov edx, msg_file_error_end - msg_file_error
    call linux_write_all
    mov edi, 1
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

# Load an optional initial file. A nonexistent path is a new, empty document;
# existing files larger than the bounded document buffer are rejected.
.type load_initial_document, @function
load_initial_document:
    push rbx
    push r12
    push r13
    push r14
    mov r12, qword ptr [rip + initial_file_path]
    test r12, r12
    jz .load_file_empty
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name

    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    xor edx, edx                 # O_RDONLY
    xor r10d, r10d
    syscall
    cmp rax, -2                  # ENOENT: retain path for a later Ctrl+S
    je .load_file_empty
    test rax, rax
    js .load_file_error
    mov r14d, eax
    xor r13d, r13d
.load_file_read:
    cmp r13d, DOC_CAPACITY
    jae .load_file_probe
    mov eax, SYS_read
    mov edi, r14d
    lea rsi, [rip + doc_buffer]
    add rsi, r13
    mov edx, DOC_CAPACITY
    sub edx, r13d
    syscall
    test rax, rax
    jg .load_file_advance
    je .load_file_done
    cmp rax, -4                  # EINTR
    je .load_file_read
    jmp .load_file_close_error
.load_file_advance:
    add r13, rax
    jmp .load_file_read
.load_file_probe:
    # Read one extra byte to distinguish an exactly-full file from truncation.
    mov eax, SYS_read
    mov edi, r14d
    lea rsi, [rip + file_probe_byte]
    mov edx, 1
    syscall
    test rax, rax
    jg .load_file_close_error
    je .load_file_done
    cmp rax, -4
    je .load_file_probe
    jmp .load_file_close_error
.load_file_done:
    mov edi, r14d
    mov eax, SYS_close
    syscall
    test rax, rax
    js .load_file_error
    mov dword ptr [rip + doc_length], r13d
    jmp .load_file_reset
.load_file_close_error:
    mov edi, r14d
    mov eax, SYS_close
    syscall
.load_file_error:
    mov rax, -5
    jmp .load_file_return
.load_file_empty:
    mov dword ptr [rip + doc_length], 0
.load_file_reset:
    # The file was read contiguously at the start of the allocation. Put the
    # initial gap after its bytes; the unused tail becomes the insertion space.
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_gap_start], eax
    mov dword ptr [rip + doc_gap_end], DOC_CAPACITY
    mov dword ptr [rip + doc_cursor], 0
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_selection_active], 0
    mov dword ptr [rip + doc_save_error], 0
    xor eax, eax
.load_file_return:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size load_initial_document, . - load_initial_document

# Copy the basename into the tab label without retaining or rewriting argv.

.type picker_start, @function
picker_start:
    push rbx
    push r12
    sub rsp, 8
    mov dword ptr [rip + picker_mode], edi
    mov dword ptr [rip + picker_dir_fd], -1
    mov dword ptr [rip + picker_selected], -1
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_focus], 0
    mov dword ptr [rip + picker_error], 0
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_name_length], 0
    mov byte ptr [rip + picker_name_buffer], 0
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0

    # Begin in the process working directory and keep an absolute display path.
    mov eax, SYS_getcwd
    lea rdi, [rip + picker_current_path]
    mov esi, PATH_CAPACITY
    syscall
    test rax, rax
    js .picker_start_path_failed
    mov r12d, eax
    lea rdi, [rip + picker_path_buffer]
    lea rsi, [rip + picker_current_path]
    mov ecx, r12d
    rep movsb
    dec r12d
    mov dword ptr [rip + picker_path_length], r12d
    jmp .picker_start_open_directory

.picker_start_path_failed:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    lea rdi, [rip + picker_path_buffer]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1

.picker_start_open_directory:
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    lea rsi, [rip + ui_picker_dot]
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_start_failed
    mov ebx, dword ptr [rip + picker_dir_fd]
    mov dword ptr [rip + picker_dir_fd], eax
    cmp ebx, 0
    jl .picker_start_scan
    mov eax, SYS_close
    mov edi, ebx
    syscall
.picker_start_scan:
    call picker_scan_directory
    test rax, rax
    js .picker_start_failed
    xor eax, eax
    jmp .picker_start_done
.picker_start_failed:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_start_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_start, . - picker_start

.type picker_scan_directory, @function
picker_scan_directory:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov dword ptr [rip + picker_entry_count], 0
    mov dword ptr [rip + picker_selected], -1
    mov dword ptr [rip + picker_scroll], 0
    # A rebuilt listing invalidates the previous row identity and click timing.
    # Without this, a click on row 0 after navigation can be mistaken for the
    # second half of a double-click from the directory we just left.
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_last_click_time], 0
    mov dword ptr [rip + picker_truncated], 0
    mov dword ptr [rip + picker_error], 0
    mov eax, SYS_lseek
    mov edi, dword ptr [rip + picker_dir_fd]
    xor esi, esi
    xor edx, edx
    syscall
    test rax, rax
    js .picker_scan_error
.picker_scan_read:
    mov eax, SYS_getdents64
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_dirents]
    mov edx, PICKER_DIR_BYTES
    syscall
    test rax, rax
    js .picker_scan_error
    jz .picker_scan_done
    mov r13, rax
    lea r12, [rip + picker_dirents]
.picker_scan_record:
    test r13, r13
    jz .picker_scan_read
    cmp r13, 20
    jb .picker_scan_error
    movzx ebp, word ptr [r12 + 16]
    cmp ebp, 20
    jb .picker_scan_error
    mov eax, ebp
    cmp rax, r13
    ja .picker_scan_error
    lea r14, [r12 + 19]
    movzx eax, byte ptr [r14]
    test al, al
    jz .picker_scan_advance
    cmp al, '.'
    jne .picker_scan_hidden_check
    cmp byte ptr [r14 + 1], 0
    je .picker_scan_advance
    cmp byte ptr [r14 + 1], '.'
    jne .picker_scan_hidden_check
    cmp byte ptr [r14 + 2], 0
    je .picker_scan_advance
.picker_scan_hidden_check:
    cmp dword ptr [rip + picker_show_hidden], 0
    jne .picker_scan_stat
    cmp byte ptr [r14], '.'
    je .picker_scan_advance
.picker_scan_stat:
    # Do not rely on dirent.d_type: query the entry without following symlinks.
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    mov rsi, r14
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_scan_advance
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFDIR
    je .picker_scan_is_directory
    cmp eax, STAT_S_IFREG
    jne .picker_scan_advance
    mov byte ptr [rip + picker_candidate], 0
    jmp .picker_scan_name
.picker_scan_is_directory:
    mov byte ptr [rip + picker_candidate], 1
.picker_scan_name:
    mov ecx, ebp
    sub ecx, 19
    cmp ecx, 255
    jbe .picker_scan_name_limit
    mov ecx, 255
.picker_scan_name_limit:
    xor ebx, ebx
.picker_scan_name_length:
    cmp ebx, ecx
    jae .picker_scan_advance
    cmp byte ptr [r14 + rbx], 0
    je .picker_scan_name_ready
    inc ebx
    jmp .picker_scan_name_length
.picker_scan_name_ready:
    test ebx, ebx
    jz .picker_scan_advance
    lea rdi, [rip + picker_candidate + 4]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    mov byte ptr [rdi], 0
    call picker_insert_candidate
.picker_scan_advance:
    add r12, rbp
    sub r13, rbp
    jmp .picker_scan_record
.picker_scan_done:
    xor eax, eax
    jmp .picker_scan_return
.picker_scan_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_scan_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size picker_scan_directory, . - picker_scan_directory

.type picker_insert_candidate, @function
picker_insert_candidate:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, dword ptr [rip + picker_entry_count]
    cmp r12d, PICKER_MAX_ENTRIES
    jb .picker_insert_find
    mov dword ptr [rip + picker_truncated], 1
    jmp .picker_insert_done
.picker_insert_find:
    xor r13d, r13d
.picker_insert_compare:
    cmp r13d, r12d
    jae .picker_insert_at_end
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea r14, [rip + picker_entries]
    add r14, rax
    movzx eax, byte ptr [rip + picker_candidate]
    movzx edx, byte ptr [r14]
    cmp eax, edx
    ja .picker_insert_found
    jb .picker_insert_next
    lea rbx, [rip + picker_candidate + 4]
    lea r15, [r14 + 4]
.picker_insert_name_compare:
    movzx eax, byte ptr [rbx]
    movzx edx, byte ptr [r15]
    cmp eax, edx
    jb .picker_insert_found
    ja .picker_insert_next
    test eax, eax
    jz .picker_insert_next
    inc rbx
    inc r15
    jmp .picker_insert_name_compare
.picker_insert_next:
    inc r13d
    jmp .picker_insert_compare
.picker_insert_at_end:
    mov r13d, r12d
    jmp .picker_insert_copy
.picker_insert_found:
.picker_insert_copy:
    cmp r13d, r12d
    je .picker_insert_copy_candidate
    mov eax, r12d
    imul eax, PICKER_ENTRY_SIZE
    lea rsi, [rip + picker_entries]
    add rsi, rax
    dec rsi
    lea rdi, [rsi + PICKER_ENTRY_SIZE]
    mov eax, r12d
    sub eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    mov ecx, eax
    std
    rep movsb
    cld
.picker_insert_copy_candidate:
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea rdi, [rip + picker_entries]
    add rdi, rax
    lea rsi, [rip + picker_candidate]
    mov ecx, PICKER_ENTRY_SIZE
    rep movsb
    inc dword ptr [rip + picker_entry_count]
.picker_insert_done:
    cld
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_insert_candidate, . - picker_insert_candidate


.type picker_close, @function
picker_close:
    mov dword ptr [rip + picker_mode], 0
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_close_done
    mov edi, eax
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], -1
.picker_close_done:
    ret
.size picker_close, . - picker_close

.type picker_copy_path_to_field, @function
picker_copy_path_to_field:
    lea rsi, [rip + picker_current_path]
    lea rdi, [rip + picker_path_buffer]
    mov ecx, dword ptr [rip + picker_path_length]
    rep movsb
    mov byte ptr [rdi], 0
    ret
.size picker_copy_path_to_field, . - picker_copy_path_to_field

.type picker_enter_directory, @function
picker_enter_directory:
    # RDI points to a NUL-terminated name relative to picker_dir_fd.
    push rbx
    push r12
    push r13
    mov r12, rdi
    # Validate path capacity before changing the active descriptor.
    mov ebx, dword ptr [rip + picker_path_length]
    test ebx, ebx
    jz .picker_enter_need_slash
    lea rdx, [rip + picker_current_path]
    cmp byte ptr [rdx + rbx - 1], '/'
    je .picker_enter_path_capacity_ready
.picker_enter_need_slash:
    inc ebx
.picker_enter_path_capacity_ready:
    xor ecx, ecx
.picker_enter_name_len:
    cmp ecx, 255
    jae .picker_enter_path_capacity_ready2
    cmp byte ptr [r12 + rcx], 0
    je .picker_enter_path_capacity_ready2
    inc ecx
    jmp .picker_enter_name_len
.picker_enter_path_capacity_ready2:
    add ebx, ecx
    cmp ebx, PATH_CAPACITY - 1
    ja .picker_enter_directory_error
    mov eax, SYS_openat
    mov edi, dword ptr [rip + picker_dir_fd]
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_enter_directory_error
    mov r13d, eax
    # The target was opened successfully; now replace the old descriptor.
    mov edi, dword ptr [rip + picker_dir_fd]
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], r13d
    mov ebx, dword ptr [rip + picker_path_length]
    lea rdi, [rip + picker_current_path]
    test ebx, ebx
    jz .picker_enter_append_slash
    cmp byte ptr [rdi + rbx - 1], '/'
    je .picker_enter_append_name
.picker_enter_append_slash:
    mov byte ptr [rdi + rbx], '/'
    inc ebx
.picker_enter_append_name:
    add rdi, rbx
    mov rsi, r12
    xor ecx, ecx
.picker_enter_copy_name:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_enter_path_done
    inc ecx
    jmp .picker_enter_copy_name
.picker_enter_path_done:
    add ebx, ecx
    mov dword ptr [rip + picker_path_length], ebx
    call picker_copy_path_to_field
    call picker_scan_directory
    test rax, rax
    js .picker_enter_directory_error
    xor eax, eax
    jmp .picker_enter_directory_done
.picker_enter_directory_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_enter_directory_done:
    pop r13
    pop r12
    pop rbx
    ret
.size picker_enter_directory, . - picker_enter_directory

.type picker_go_parent, @function
picker_go_parent:
    push rbx
    push r12
    sub rsp, 8
    mov eax, SYS_openat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + ui_picker_parent]
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_parent_error
    mov r12d, eax
    mov edi, dword ptr [rip + picker_dir_fd]
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], r12d
    mov ebx, dword ptr [rip + picker_path_length]
    cmp ebx, 1
    jbe .picker_parent_root
    lea rdi, [rip + picker_current_path]
    dec ebx
    cmp byte ptr [rdi + rbx], '/'
    jne .picker_parent_find_slash
    dec ebx
.picker_parent_find_slash:
    cmp ebx, 0
    je .picker_parent_make_root
    cmp byte ptr [rdi + rbx], '/'
    je .picker_parent_truncate
    dec ebx
    jmp .picker_parent_find_slash
.picker_parent_make_root:
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1
    jmp .picker_parent_rescan
.picker_parent_truncate:
    cmp ebx, 0
    jne .picker_parent_set_terminator
.picker_parent_root:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1
    jmp .picker_parent_rescan
.picker_parent_set_terminator:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi + rbx], 0
    mov dword ptr [rip + picker_path_length], ebx
.picker_parent_rescan:
    call picker_copy_path_to_field
    call picker_scan_directory
    jmp .picker_parent_done
.picker_parent_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_parent_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_go_parent, . - picker_go_parent

.type picker_go_home, @function
picker_go_home:
    push rbx
    push r12
    sub rsp, 8
    lea rdi, [rip + ui_picker_home_env]
    mov esi, 4
    call env_lookup
    test rax, rax
    jz .picker_home_error
    mov r12, rax
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_home_error
    mov ebx, eax
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_home_replace
    mov edi, eax
    mov eax, SYS_close
    syscall
.picker_home_replace:
    mov dword ptr [rip + picker_dir_fd], ebx
    lea rdi, [rip + picker_current_path]
    mov rsi, r12
    mov edx, PATH_CAPACITY
    call copy_cstr
    test rax, rax
    js .picker_home_error
    mov dword ptr [rip + picker_path_length], eax
    call picker_copy_path_to_field
    call picker_scan_directory
    jmp .picker_home_done
.picker_home_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_home_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_go_home, . - picker_go_home

.type picker_navigate_path, @function
picker_navigate_path:
    push rbx
    push r12
    sub rsp, 8
    lea r12, [rip + picker_path_buffer]
    cmp byte ptr [r12], 0
    je .picker_navigate_path_error
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_navigate_path_error
    mov ebx, eax
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_navigate_replace
    mov edi, eax
    mov eax, SYS_close
    syscall
.picker_navigate_replace:
    mov dword ptr [rip + picker_dir_fd], ebx
    lea rdi, [rip + picker_current_path]
    mov rsi, r12
    mov edx, PATH_CAPACITY
    call copy_cstr
    test rax, rax
    js .picker_navigate_path_error
    mov dword ptr [rip + picker_path_length], eax
    call picker_scan_directory
    jmp .picker_navigate_done
.picker_navigate_path_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_navigate_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_navigate_path, . - picker_navigate_path

.type picker_copy_selected_name, @function
picker_copy_selected_name:
    push rbx
    mov eax, dword ptr [rip + picker_selected]
    cmp eax, 0
    jl .picker_copy_name_empty
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_copy_name_empty
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    cmp byte ptr [rbx], 0
    jne .picker_copy_name_empty
    lea rsi, [rbx + 4]
    lea rdi, [rip + picker_name_buffer]
    xor edx, edx
.picker_copy_name_loop:
    cmp edx, 255
    jae .picker_copy_name_done
    mov al, byte ptr [rsi + rdx]
    mov byte ptr [rdi + rdx], al
    test al, al
    jz .picker_copy_name_done
    inc edx
    jmp .picker_copy_name_loop
.picker_copy_name_done:
    mov dword ptr [rip + picker_name_length], edx
    jmp .picker_copy_name_return
.picker_copy_name_empty:
    mov dword ptr [rip + picker_name_length], 0
    mov byte ptr [rip + picker_name_buffer], 0
.picker_copy_name_return:
    pop rbx
    ret
.size picker_copy_selected_name, . - picker_copy_selected_name

.type picker_build_target, @function
picker_build_target:
    push rbx
    push r12
    push r13
    lea r12, [rip + picker_name_buffer]
    cmp byte ptr [r12], 0
    je .picker_build_target_error
    lea rdi, [rip + picker_target_buffer]
    cmp byte ptr [r12], '/'
    je .picker_build_absolute
    lea rsi, [rip + picker_current_path]
    xor ecx, ecx
.picker_build_copy_dir:
    mov al, byte ptr [rsi + rcx]
    test al, al
    jz .picker_build_dir_done
    cmp ecx, PATH_CAPACITY - 2
    jae .picker_build_target_error
    mov byte ptr [rdi + rcx], al
    inc ecx
    jmp .picker_build_copy_dir
.picker_build_dir_done:
    cmp ecx, 0
    je .picker_build_separator
    cmp byte ptr [rdi + rcx - 1], '/'
    je .picker_build_name
.picker_build_separator:
    cmp ecx, PATH_CAPACITY - 2
    jae .picker_build_target_error
    mov byte ptr [rdi + rcx], '/'
    inc ecx
.picker_build_name:
    mov rsi, r12
    xor edx, edx
.picker_build_name_loop:
    mov al, byte ptr [rsi + rdx]
    test al, al
    jz .picker_build_target_done
    lea r8d, [rcx + rdx]
    cmp r8d, PATH_CAPACITY - 1
    jae .picker_build_target_error
    mov byte ptr [rdi + r8], al
    inc edx
    jmp .picker_build_name_loop
.picker_build_absolute:
    mov rsi, r12
    xor ecx, ecx
.picker_build_absolute_loop:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_build_target_done
    inc ecx
    cmp ecx, PATH_CAPACITY - 1
    jb .picker_build_absolute_loop
    jmp .picker_build_target_error
.picker_build_target_done:
    lea rax, [rip + picker_target_buffer]
    jmp .picker_build_target_return
.picker_build_target_error:
    xor eax, eax
.picker_build_target_return:
    pop r13
    pop r12
    pop rbx
    ret
.size picker_build_target, . - picker_build_target

.type picker_commit_active_path, @function
picker_commit_active_path:
    push r12
    lea rsi, [rip + picker_target_buffer]
    lea rdi, [rip + current_path_buffer]
    xor ecx, ecx
.picker_commit_path_copy:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_commit_path_done
    inc ecx
    cmp ecx, PATH_CAPACITY - 1
    jb .picker_commit_path_copy
    mov byte ptr [rdi + PATH_CAPACITY - 1], 0
.picker_commit_path_done:
    lea r12, [rip + current_path_buffer]
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name
    pop r12
    ret
.size picker_commit_active_path, . - picker_commit_active_path

.type picker_open_file, @function
picker_open_file:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_open_file_error
    mov r12, rax
    # Do not attempt to load a directory, symlink, or special file.
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_name_buffer]
    cmp byte ptr [rip + picker_name_buffer], '/'
    jne .picker_open_stat_relative
    mov edi, AT_FDCWD
    mov rsi, r12
.picker_open_stat_relative:
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_open_file_error
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFREG
    jne .picker_open_file_error
    mov rdi, r12
    call load_document_from_path
    test rax, rax
    js .picker_open_file_error
    call picker_commit_active_path
    call picker_close
    xor eax, eax
    jmp .picker_open_file_done
.picker_open_file_error:
    mov dword ptr [rip + picker_error], 2
    mov rax, -5
.picker_open_file_done:
    pop r12
    ret
.size picker_open_file, . - picker_open_file

.type picker_save_file, @function
picker_save_file:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_save_file_error
    mov r12, rax
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_name_buffer]
    cmp byte ptr [rip + picker_name_buffer], '/'
    jne .picker_save_stat_relative
    mov rdi, AT_FDCWD
.picker_save_stat_relative:
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_save_new_target
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFREG
    jne .picker_save_file_error
    mov dword ptr [rip + picker_overwrite_pending], 1
    xor eax, eax
    jmp .picker_save_file_done
.picker_save_new_target:
    cmp rax, -2
    jne .picker_save_file_error
    mov rdi, r12
    call save_document_to_path
    test rax, rax
    js .picker_save_file_error
    call picker_commit_active_path
    call picker_close
    xor eax, eax
    jmp .picker_save_file_done
.picker_save_file_error:
    mov dword ptr [rip + picker_error], 3
    mov rax, -5
.picker_save_file_done:
    pop r12
    ret
.size picker_save_file, . - picker_save_file

.type picker_confirm_overwrite, @function
picker_confirm_overwrite:
    push r12
    lea rdi, [rip + picker_target_buffer]
    call save_document_to_path
    test rax, rax
    js .picker_overwrite_error
    call picker_commit_active_path
    call picker_close
    xor eax, eax
    jmp .picker_overwrite_done
.picker_overwrite_error:
    mov dword ptr [rip + picker_error], 3
    mov rax, -5
.picker_overwrite_done:
    pop r12
    ret
.size picker_confirm_overwrite, . - picker_confirm_overwrite

.type picker_confirm_action, @function
picker_confirm_action:
    cmp dword ptr [rip + picker_name_length], 0
    jne .picker_confirm_action_ready
    call picker_copy_selected_name
.picker_confirm_action_ready:
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_confirm_action_save
    jmp picker_open_file
.picker_confirm_action_save:
    jmp picker_save_file
.picker_confirm_action_error:
    mov dword ptr [rip + picker_error], 3
    mov rax, -2
    ret
.size picker_confirm_action, . - picker_confirm_action

.type picker_move_selection, @function
picker_move_selection:
    mov eax, dword ptr [rip + picker_entry_count]
    test eax, eax
    jz .picker_move_done
    mov edx, dword ptr [rip + picker_selected]
    test edx, edx
    jns .picker_move_existing
    xor edx, edx
    jmp .picker_move_store
.picker_move_existing:
    add edx, edi
    cmp edx, 0
    jge .picker_move_upper
    xor edx, edx
    jmp .picker_move_store
.picker_move_upper:
    cmp edx, eax
    jb .picker_move_store
    lea edx, [rax - 1]
.picker_move_store:
    mov dword ptr [rip + picker_selected], edx
    mov eax, dword ptr [rip + picker_scroll]
    cmp edx, eax
    jae .picker_move_check_bottom
    mov dword ptr [rip + picker_scroll], edx
    ret
.picker_move_check_bottom:
    mov ecx, edx
    sub ecx, eax
    cmp ecx, PICKER_VISIBLE_ROWS
    jb .picker_move_done
    sub edx, PICKER_VISIBLE_ROWS - 1
    mov dword ptr [rip + picker_scroll], edx
.picker_move_done:
    ret
.size picker_move_selection, . - picker_move_selection


.type picker_handle_key, @function
picker_handle_key:
    push rbx
    push r12
    sub rsp, 8
    mov ebx, edi
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .picker_key_normal
    cmp ebx, 1
    je .picker_key_overwrite_no
    mov edi, ebx
    call keycode_to_ascii
    cmp al, 'y'
    je .picker_key_overwrite_yes
    cmp al, 'Y'
    je .picker_key_overwrite_yes
    cmp al, 'n'
    je .picker_key_overwrite_no
    cmp al, 'N'
    je .picker_key_overwrite_no
    jmp .picker_key_done
.picker_key_overwrite_yes:
    mov dword ptr [rip + picker_overwrite_pending], 0
    call picker_confirm_overwrite
    jmp .picker_key_done
.picker_key_overwrite_no:
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_key_done

.picker_key_normal:
    cmp ebx, 1
    je .picker_key_cancel
    cmp ebx, 15
    je .picker_key_tab
    cmp ebx, 28
    je .picker_key_enter
    cmp ebx, 14
    je .picker_key_backspace
    cmp ebx, 111
    je .picker_key_delete
    cmp ebx, 103
    je .picker_key_up
    cmp ebx, 108
    je .picker_key_down
    cmp ebx, 104
    je .picker_key_page_up
    cmp ebx, 109
    je .picker_key_page_down
    cmp ebx, 102
    je .picker_key_home
    cmp ebx, 105
    je .picker_key_left
    cmp ebx, 106
    je .picker_key_right
    cmp dword ptr [rip + ctrl_down], 0
    jne .picker_key_done
    mov edi, ebx
    call keycode_to_ascii
    test eax, eax
    jz .picker_key_done
    mov r12d, eax
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_append_path
    # Typing from the list is a convenient shortcut to the filename field.
    mov dword ptr [rip + picker_focus], 2
.picker_key_append_name:
    mov ecx, dword ptr [rip + picker_name_length]
    cmp ecx, 255
    jae .picker_key_done
    lea rdx, [rip + picker_name_buffer]
    mov byte ptr [rdx + rcx], r12b
    inc ecx
    mov dword ptr [rip + picker_name_length], ecx
    mov byte ptr [rdx + rcx], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_key_done
.picker_key_append_path:
    mov ecx, dword ptr [rip + picker_path_length]
    cmp ecx, PATH_CAPACITY - 1
    jae .picker_key_done
    lea rdx, [rip + picker_path_buffer]
    mov byte ptr [rdx + rcx], r12b
    inc ecx
    mov dword ptr [rip + picker_path_length], ecx
    mov byte ptr [rdx + rcx], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_key_done

.picker_key_cancel:
    call picker_close
    jmp .picker_key_done
.picker_key_tab:
    mov eax, dword ptr [rip + picker_focus]
    inc eax
    cmp eax, 3
    jb .picker_key_tab_store
    xor eax, eax
.picker_key_tab_store:
    mov dword ptr [rip + picker_focus], eax
    jmp .picker_key_done
.picker_key_enter:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_enter_path
    cmp dword ptr [rip + picker_focus], 2
    je .picker_key_enter_action
    mov eax, dword ptr [rip + picker_selected]
    test eax, eax
    js .picker_key_enter_action
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_key_enter_action
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    je .picker_key_enter_directory
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_key_enter_action
    call picker_open_file
    jmp .picker_key_done
.picker_key_enter_directory:
    lea rdi, [rdx + 4]
    call picker_enter_directory
    jmp .picker_key_done
.picker_key_enter_path:
    call picker_navigate_path
    jmp .picker_key_done
.picker_key_enter_action:
    call picker_confirm_action
    jmp .picker_key_done

.picker_key_backspace:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_backspace_path
    cmp dword ptr [rip + picker_focus], 2
    je .picker_key_backspace_name
    call picker_go_parent
    jmp .picker_key_done
.picker_key_backspace_path:
    mov ecx, dword ptr [rip + picker_path_length]
    test ecx, ecx
    jz .picker_key_done
    dec ecx
    mov dword ptr [rip + picker_path_length], ecx
    lea rdx, [rip + picker_path_buffer]
    mov byte ptr [rdx + rcx], 0
    jmp .picker_key_done
.picker_key_backspace_name:
    mov ecx, dword ptr [rip + picker_name_length]
    test ecx, ecx
    jz .picker_key_done
    dec ecx
    mov dword ptr [rip + picker_name_length], ecx
    lea rdx, [rip + picker_name_buffer]
    mov byte ptr [rdx + rcx], 0
    jmp .picker_key_done
.picker_key_delete:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_clear_path
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_key_done
    mov dword ptr [rip + picker_name_length], 0
    mov byte ptr [rip + picker_name_buffer], 0
    jmp .picker_key_done
.picker_key_clear_path:
    mov dword ptr [rip + picker_path_length], 0
    mov byte ptr [rip + picker_path_buffer], 0
    jmp .picker_key_done
.picker_key_up:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, -1
    call picker_move_selection
    jmp .picker_key_done
.picker_key_down:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, 1
    call picker_move_selection
    jmp .picker_key_done
.picker_key_page_up:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, -PICKER_VISIBLE_ROWS
    call picker_move_selection
    jmp .picker_key_done
.picker_key_page_down:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, PICKER_VISIBLE_ROWS
    call picker_move_selection
    jmp .picker_key_done
.picker_key_home:
    call picker_go_home
    jmp .picker_key_done
.picker_key_left:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    call picker_go_parent
    jmp .picker_key_done
.picker_key_right:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov eax, dword ptr [rip + picker_selected]
    test eax, eax
    js .picker_key_done
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_key_done
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    jne .picker_key_done
    lea rdi, [rdx + 4]
    call picker_enter_directory
.picker_key_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_handle_key, . - picker_handle_key

.type picker_handle_pointer, @function
picker_handle_pointer:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .picker_pointer_normal
    # Confirm and cancel zones in the overwrite prompt.
    cmp r13d, 232
    jb .picker_pointer_done
    cmp r13d, 272
    jae .picker_pointer_done
    cmp r12d, 600
    jb .picker_pointer_done
    cmp r12d, 672
    jb .picker_pointer_overwrite_no
    cmp r12d, 752
    jae .picker_pointer_done
    jmp .picker_pointer_overwrite_yes
.picker_pointer_overwrite_no:
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_pointer_done
.picker_pointer_overwrite_yes:
    mov dword ptr [rip + picker_overwrite_pending], 0
    call picker_confirm_overwrite
    jmp .picker_pointer_done

.picker_pointer_normal:
    # Footer actions.
    cmp r13d, 396
    jb .picker_pointer_controls
    cmp r13d, 432
    jae .picker_pointer_done
    cmp r12d, 600
    jb .picker_pointer_done
    cmp r12d, 672
    jb .picker_pointer_cancel
    cmp r12d, 752
    jae .picker_pointer_done
    call picker_confirm_action
    jmp .picker_pointer_done
.picker_pointer_cancel:
    call picker_close
    jmp .picker_pointer_done

.picker_pointer_controls:
    # Editable location field.
    cmp r13d, 64
    jb .picker_pointer_toolbar
    cmp r13d, 92
    jae .picker_pointer_toolbar
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 744
    jae .picker_pointer_done
    mov dword ptr [rip + picker_focus], 1
    jmp .picker_pointer_done

.picker_pointer_toolbar:
    cmp r13d, 96
    jb .picker_pointer_list
    cmp r13d, 124
    jae .picker_pointer_list
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 104
    jb .picker_pointer_up
    cmp r12d, 160
    jb .picker_pointer_home
    cmp r12d, 600
    jb .picker_pointer_list
    cmp r12d, 744
    jae .picker_pointer_list
    xor dword ptr [rip + picker_show_hidden], 1
    call picker_scan_directory
    jmp .picker_pointer_done
.picker_pointer_up:
    call picker_go_parent
    jmp .picker_pointer_done
.picker_pointer_home:
    call picker_go_home
    jmp .picker_pointer_done

.picker_pointer_list:
    cmp r13d, 128
    jb .picker_pointer_name
    cmp r13d, 350
    jae .picker_pointer_name
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 744
    jae .picker_pointer_done
    mov eax, r13d
    sub eax, 132
    xor edx, edx
    mov ecx, 14
    div ecx
    add eax, dword ptr [rip + picker_scroll]
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_pointer_done
    mov dword ptr [rip + picker_selected], eax
    mov dword ptr [rip + picker_focus], 0
    call picker_copy_selected_name
    # Directories are navigated on double-click only.
    mov eax, dword ptr [rip + picker_selected]
    cmp eax, dword ptr [rip + picker_last_click_index]
    jne .picker_pointer_record_click
    mov ecx, r14d
    sub ecx, dword ptr [rip + picker_last_click_time]
    cmp ecx, 450
    ja .picker_pointer_record_click
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_pointer_record_click
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    je .picker_pointer_double_directory
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_pointer_record_click
    call picker_open_file
    jmp .picker_pointer_done
.picker_pointer_double_directory:
    lea rdi, [rdx + 4]
    call picker_enter_directory
    jmp .picker_pointer_done
.picker_pointer_record_click:
    mov eax, dword ptr [rip + picker_selected]
    mov dword ptr [rip + picker_last_click_index], eax
    mov dword ptr [rip + picker_last_click_time], r14d
    jmp .picker_pointer_done

.picker_pointer_name:
    cmp r13d, 360
    jb .picker_pointer_done
    cmp r13d, 390
    jae .picker_pointer_done
    cmp r12d, 128
    jb .picker_pointer_done
    cmp r12d, 608
    jae .picker_pointer_done
    mov dword ptr [rip + picker_focus], 2
.picker_pointer_done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_handle_pointer, . - picker_handle_pointer

.type set_active_document_name, @function
set_active_document_name:
    lea rdi, [rip + active_document_name]
    mov rsi, r12
    mov r8, r12
.set_name_find_end:
    mov al, byte ptr [rsi]
    test al, al
    jz .set_name_copy
    cmp al, '/'
    jne .set_name_next
    lea r8, [rsi + 1]
.set_name_next:
    inc rsi
    jmp .set_name_find_end
.set_name_copy:
    xor ecx, ecx
.set_name_copy_loop:
    cmp ecx, 15
    jae .set_name_done
    mov al, byte ptr [r8 + rcx]
    test al, al
    jz .set_name_done
    mov byte ptr [rdi + rcx], al
    inc ecx
    jmp .set_name_copy_loop
.set_name_done:
    mov byte ptr [rdi + rcx], 0
    ret
.size set_active_document_name, . - set_active_document_name

# Save the active document. Untitled is routed to the in-window Save As
# prompt by its caller; this routine deliberately refuses a null path.
.type save_document_file, @function
save_document_file:
    mov rdi, qword ptr [rip + current_file_path]
    test rdi, rdi
    jz .save_file_no_path
    jmp save_document_to_path
.save_file_no_path:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -2
    ret
.size save_document_file, . - save_document_file

# Atomically replace PATH with the current document. The temporary is created
# in the destination directory (exclusive create), fully written, fsynced,
# closed, then renamed over the target. A failed write never truncates target.
.type save_document_to_path, @function
save_document_to_path:
    mov qword ptr [rip + save_target_path], rdi
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    test r12, r12
    jz .save_atomic_error
    cmp byte ptr [r12], 0
    je .save_atomic_error

    # Keep the temporary beside the destination so renameat stays on one FS.
    xor r14d, r14d
    mov rsi, r12
.save_atomic_scan_path:
    mov al, byte ptr [rsi]
    test al, al
    jz .save_atomic_path_scanned
    inc rsi
    cmp al, '/'
    jne .save_atomic_scan_path
    mov r14, rsi
    sub r14, r12
    jmp .save_atomic_scan_path
.save_atomic_path_scanned:
    cmp r14d, PATH_CAPACITY - 32
    ja .save_atomic_error
    lea rdi, [rip + temp_path_buffer]
    mov rsi, r12
    mov rcx, r14
    rep movsb
    mov r13, rdi
    lea rsi, [rip + temp_prefix]
    mov ecx, temp_prefix_end - temp_prefix
    rep movsb
    mov r13, rdi

    mov eax, SYS_getpid
    syscall
    test rax, rax
    js .save_atomic_error
    lea rdi, [rip + temp_pid_digits + 15]
    mov byte ptr [rdi], 0
    mov ecx, 10
.save_atomic_pid_digits:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rdi
    mov byte ptr [rdi], dl
    test eax, eax
    jnz .save_atomic_pid_digits
    mov rsi, rdi
    mov rdi, r13
    lea rdx, [rip + temp_pid_digits + 15]
    sub rdx, rsi
    mov rcx, rdx
    rep movsb
    mov r13, rdi
    lea rsi, [rip + temp_suffix]
    mov ecx, temp_suffix_end - temp_suffix
    rep movsb
    mov byte ptr [rdi], 0

    mov eax, SYS_openat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    mov edx, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC
    mov r10d, 0644
    syscall
    test rax, rax
    js .save_atomic_error
    mov ebx, eax
    # Write the prefix before the gap, then the suffix after it. The physical
    # gap is never serialized into the file.
    lea r12, [rip + doc_buffer]
    mov ebp, dword ptr [rip + doc_gap_start]
    xor r15d, r15d
.save_atomic_write:
    test ebp, ebp
    jnz .save_atomic_issue_write
    test r15d, r15d
    jnz .save_atomic_fsync
    mov r15d, 1
    lea r12, [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add r12, rax
    mov ebp, dword ptr [rip + doc_length]
    sub ebp, dword ptr [rip + doc_gap_start]
    jmp .save_atomic_write
.save_atomic_issue_write:
    mov eax, SYS_write
    mov edi, ebx
    mov rsi, r12
    mov edx, ebp
    syscall
    test rax, rax
    jg .save_atomic_advance
    cmp rax, -4
    je .save_atomic_issue_write
    jmp .save_atomic_close_error
.save_atomic_advance:
    add r12, rax
    sub ebp, eax
    jmp .save_atomic_write
.save_atomic_fsync:
    mov eax, SYS_fsync
    mov edi, ebx
    syscall
    cmp rax, -4
    je .save_atomic_fsync
    test rax, rax
    js .save_atomic_close_error
    mov eax, SYS_close
    mov edi, ebx
    syscall
    test rax, rax
    js .save_atomic_unlink_error
    mov ebx, -1

    mov eax, SYS_renameat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    mov edx, AT_FDCWD
    mov r10, qword ptr [rip + save_target_path]
    syscall
    test rax, rax
    js .save_atomic_unlink_error
    mov dword ptr [rip + doc_save_error], 0
    xor eax, eax
    jmp .save_atomic_return

.save_atomic_close_error:
    mov eax, SYS_close
    mov edi, ebx
    syscall
    mov ebx, -1
.save_atomic_unlink_error:
    mov eax, SYS_unlinkat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    xor edx, edx
    syscall
    jmp .save_atomic_error
.save_atomic_error:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -5
.save_atomic_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size save_document_to_path, . - save_document_to_path

# Open a replacement document into a scratch buffer first. The live document,
# path, and tab label are changed only after EOF and a successful close.
.type load_document_from_path, @function
load_document_from_path:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    test r12, r12
    jz .load_path_error
    cmp byte ptr [r12], 0
    je .load_path_error
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    xor edx, edx
    xor r10d, r10d
    syscall
    test rax, rax
    js .load_path_error
    mov ebx, eax
    xor r13d, r13d
.load_path_read:
    cmp r13d, DOC_CAPACITY
    jae .load_path_probe
    mov eax, SYS_read
    mov edi, ebx
    lea rsi, [rip + load_buffer]
    add rsi, r13
    mov edx, DOC_CAPACITY
    sub edx, r13d
    syscall
    test rax, rax
    jg .load_path_advance
    je .load_path_close
    cmp rax, -4
    je .load_path_read
    jmp .load_path_close_error
.load_path_advance:
    add r13, rax
    jmp .load_path_read
.load_path_probe:
    mov eax, SYS_read
    mov edi, ebx
    lea rsi, [rip + file_probe_byte]
    mov edx, 1
    syscall
    test rax, rax
    jg .load_path_close_error
    je .load_path_close
    cmp rax, -4
    je .load_path_probe
    jmp .load_path_close_error
.load_path_close:
    mov eax, SYS_close
    mov edi, ebx
    syscall
    test rax, rax
    js .load_path_error
    lea rsi, [rip + load_buffer]
    lea rdi, [rip + doc_buffer]
    mov ecx, r13d
    rep movsb
    mov dword ptr [rip + doc_length], r13d
    mov dword ptr [rip + doc_gap_start], r13d
    mov dword ptr [rip + doc_gap_end], DOC_CAPACITY
    mov dword ptr [rip + doc_cursor], 0
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_selection_active], 0
    mov dword ptr [rip + doc_selection_anchor], 0
    mov dword ptr [rip + doc_selection_start], 0
    mov dword ptr [rip + doc_selection_end], 0
    mov dword ptr [rip + doc_save_error], 0
    mov dword ptr [rip + doc_open_error], 0
    xor eax, eax
    jmp .load_path_return
.load_path_close_error:
    mov eax, SYS_close
    mov edi, ebx
    syscall
.load_path_error:
    mov dword ptr [rip + doc_open_error], 1
    mov rax, -5
.load_path_return:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size load_document_from_path, . - load_document_from_path

.type start_open_prompt, @function
start_open_prompt:
    mov edi, 1
    jmp picker_start
.size start_open_prompt, . - start_open_prompt

.type start_save_as_prompt, @function
start_save_as_prompt:
    mov edi, 2
    jmp picker_start
.size start_save_as_prompt, . - start_save_as_prompt

.type begin_path_prompt, @function
begin_path_prompt:
    mov dword ptr [rip + path_prompt_mode], edi
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    ret
.size begin_path_prompt, . - begin_path_prompt

.type cancel_path_prompt, @function
cancel_path_prompt:
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    ret
.size cancel_path_prompt, . - cancel_path_prompt

# Commit the entered path only after the corresponding file operation succeeds.
.type commit_path_prompt, @function
commit_path_prompt:
    push r12
    lea rsi, [rip + path_prompt_buffer]
    lea rdi, [rip + current_path_buffer]
    mov ecx, dword ptr [rip + path_prompt_length]
    rep movsb
    mov byte ptr [rdi], 0
    lea r12, [rip + current_path_buffer]
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    pop r12
    ret
.size commit_path_prompt, . - commit_path_prompt

.type confirm_path_prompt, @function
confirm_path_prompt:
    push rbp
    cmp dword ptr [rip + path_prompt_length], 0
    je .confirm_path_error
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .confirm_path_save
    lea rdi, [rip + path_prompt_buffer]
    call load_document_from_path
    test rax, rax
    js .confirm_path_failed
    call commit_path_prompt
    xor eax, eax
    pop rbp
    ret
.confirm_path_save:
    lea rdi, [rip + path_prompt_buffer]
    call save_document_to_path
    test rax, rax
    js .confirm_path_failed
    call commit_path_prompt
    xor eax, eax
    pop rbp
    ret
.confirm_path_error:
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .confirm_path_save_error
    mov dword ptr [rip + doc_open_error], 1
    mov rax, -2
    pop rbp
    ret
.confirm_path_save_error:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -2
    pop rbp
    ret
.confirm_path_failed:
    mov rax, -5
    pop rbp
    ret
.size confirm_path_prompt, . - confirm_path_prompt

.type save_current_document, @function
save_current_document:
    cmp qword ptr [rip + current_file_path], 0
    je .save_current_prompt
    jmp save_document_file
.save_current_prompt:
    jmp start_save_as_prompt
.size save_current_document, . - save_current_document

.section .rodata
temp_prefix: .ascii ".nekoedit-"
temp_prefix_end:
temp_suffix: .ascii ".tmp"
temp_suffix_end:
.section .text

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
    mov rax, -1
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

# Receive exactly RDX bytes from an AF_UNIX stream while preserving SCM_RIGHTS.
# RDI=socket, RSI=destination, RDX=length. RAX=0 or negative errno.
.type wl_recv_exact, @function
wl_recv_exact:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13, rsi
    mov r14, rdx
.recv_exact_loop:
    test r14, r14
    jz .recv_exact_success
    # Rebuild msghdr/iovec for every partial receive; ancillary data is tied
    # to stream position and can arrive before the event payload is complete.
    mov qword ptr [rip + recv_iov], r13
    mov qword ptr [rip + recv_iov + 8], r14
    lea rdi, [rip + recv_msg_header]
    xor eax, eax
    mov ecx, 14
    rep stosd
    lea rax, [rip + recv_iov]
    mov qword ptr [rip + recv_msg_header + 16], rax
    mov qword ptr [rip + recv_msg_header + 24], 1
    lea rax, [rip + recv_msg_control]
    mov qword ptr [rip + recv_msg_header + 32], rax
    mov qword ptr [rip + recv_msg_header + 40], 64
    lea rdi, [rip + recv_msg_control]
    xor eax, eax
    mov ecx, 16
    rep stosd

    mov eax, SYS_recvmsg
    mov edi, r12d
    lea rsi, [rip + recv_msg_header]
    mov edx, MSG_CMSG_CLOEXEC
    syscall
    cmp rax, -4                 # EINTR
    je .recv_exact_loop
    test rax, rax
    js .recv_exact_done
    jz .recv_exact_eof
    mov r15, rax

    # A truncated control buffer may have silently lost SCM_RIGHTS handles;
    # reject it rather than continue with a keymap whose FD was not retained.
    mov eax, dword ptr [rip + recv_msg_header + 48]
    test eax, MSG_CTRUNC
    jnz .recv_exact_bad_control
    mov rcx, qword ptr [rip + recv_msg_header + 40]
    test rcx, rcx
    jz .recv_exact_advance
    cmp rcx, 16
    jb .recv_exact_bad_control
    lea rsi, [rip + recv_msg_control]
    mov rax, qword ptr [rsi]
    cmp rax, 16
    jb .recv_exact_bad_control
    cmp rax, rcx
    ja .recv_exact_bad_control
    cmp dword ptr [rsi + 8], SOL_SOCKET
    jne .recv_exact_advance
    cmp dword ptr [rsi + 12], SCM_RIGHTS
    jne .recv_exact_advance
    cmp rax, 20
    jb .recv_exact_bad_control
    mov rdx, rax
    sub rdx, 16
    test edx, 3
    jnz .recv_exact_bad_control
    shr rdx, 2
    xor ebx, ebx
.recv_exact_rights_loop:
    cmp rbx, rdx
    jae .recv_exact_advance
    mov eax, dword ptr [rsi + rbx*4 + 16]
    cmp dword ptr [rip + event_fd], -1
    jne .recv_exact_close_extra
    mov dword ptr [rip + event_fd], eax
    jmp .recv_exact_next_right
.recv_exact_close_extra:
    mov edi, eax
    mov eax, SYS_close
    syscall
.recv_exact_next_right:
    inc rbx
    jmp .recv_exact_rights_loop

.recv_exact_advance:
    add r13, r15
    sub r14, r15
    jmp .recv_exact_loop
.recv_exact_success:
    xor eax, eax
    jmp .recv_exact_done
.recv_exact_eof:
    mov rax, -5                 # EIO / unexpected EOF
    jmp .recv_exact_done
.recv_exact_bad_control:
    mov rax, -71                # EPROTO
.recv_exact_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_recv_exact, . - wl_recv_exact

# Consume and validate the wl_keyboard.keymap event's descriptor.
# XKB_V1 is retained as a bounded, read-only MAP_PRIVATE mapping for the
# upcoming parser; this stage deliberately leaves the legacy key translator
# active until keysyms and modifier levels are implemented.
.type keyboard_keymap_update, @function
keyboard_keymap_update:
    push rbx
    push r12
    push r13
    push r14
    mov dword ptr [rip + keymap_processing_complete], 0
    mov ebx, dword ptr [rip + event_fd]
    mov dword ptr [rip + event_fd], -1
    cmp ebx, 0
    jl .keyboard_keymap_no_fd

    # Replace a prior keymap only after releasing its mapping.
    mov rdi, qword ptr [rip + keymap_mapping]
    test rdi, rdi
    jz .keyboard_keymap_clear_state
    mov esi, dword ptr [rip + keymap_size]
    mov eax, SYS_munmap
    syscall
.keyboard_keymap_clear_state:
    mov qword ptr [rip + keymap_mapping], 0
    mov dword ptr [rip + keymap_size], 0
    mov dword ptr [rip + keymap_format], 0
    call xkb_reset_keymap

    mov r14d, dword ptr [rip + event_payload]
    mov r12d, dword ptr [rip + event_payload + 4]
    test r14d, r14d
    jz .keyboard_keymap_no_map
    cmp r14d, 1                  # WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1
    jne .keyboard_keymap_bad
    cmp r12d, 11                 # "xkb_keymap" plus the terminating NUL
    jb .keyboard_keymap_bad
    cmp r12d, XKB_KEYMAP_MAX_SIZE
    ja .keyboard_keymap_bad

    mov eax, SYS_mmap
    xor edi, edi
    mov esi, r12d
    mov edx, PROT_READ
    mov r10d, MAP_PRIVATE
    mov r8d, ebx
    xor r9d, r9d
    syscall
    test rax, rax
    js .keyboard_keymap_map_error
    mov r13, rax
    cmp byte ptr [r13 + r12 - 1], 0
    jne .keyboard_keymap_unmap_bad
    lea rsi, [rip + xkb_keymap_magic]
    mov rdi, r13
    mov ecx, 10
    repe cmpsb
    jne .keyboard_keymap_unmap_bad

    mov qword ptr [rip + keymap_mapping], r13
    mov dword ptr [rip + keymap_size], r12d
    mov edi, ebx
    mov eax, SYS_close
    syscall
    # Keep the mapped file only when the supported XKB text subset parsed.
    mov rdi, r13
    mov esi, r12d
    call xkb_parse_keymap
    test rax, rax
    js .keyboard_keymap_parser_fallback
    mov dword ptr [rip + keymap_format], 1
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done
.keyboard_keymap_parser_fallback:
    mov dword ptr [rip + keymap_format], 0
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done

.keyboard_keymap_no_map:
    # WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP still carries an FD argument.
    mov edi, ebx
    mov eax, SYS_close
    syscall
    call xkb_reset_keymap
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done
.keyboard_keymap_unmap_bad:
    mov rdi, r13
    mov esi, r12d
    mov eax, SYS_munmap
    syscall
.keyboard_keymap_bad:
    mov edi, ebx
    mov eax, SYS_close
    syscall
    mov rax, -71                # EPROTO: malformed/unsupported keymap
    jmp .keyboard_keymap_done
.keyboard_keymap_map_error:
    mov r14, rax
    mov edi, ebx
    mov eax, SYS_close
    syscall
    mov rax, r14
    jmp .keyboard_keymap_done
.keyboard_keymap_no_fd:
    mov rax, -71
.keyboard_keymap_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size keyboard_keymap_update, . - keyboard_keymap_update

# Read one complete Wayland event; records last_object/opcode/size and payload.
.type wl_read_event, @function
wl_read_event:
    push rbp
    # Any descriptor not consumed by the preceding event is not allowed to
    # leak into the next dispatch cycle.
    mov edi, dword ptr [rip + event_fd]
    cmp edi, -1
    je .read_event_start
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + event_fd], -1
.read_event_start:
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + event_header]
    mov edx, 8
    call wl_recv_exact
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
    call wl_recv_exact
    test rax, rax
    js .read_event_done
.read_event_ok:
    # wl_display.error is fatal; return an error while preserving its payload
    # so the caller can print the compositor-provided diagnostic safely.
    cmp dword ptr [rip + last_object], 1
    jne .read_event_success
    cmp dword ptr [rip + last_opcode], 0
    jne .read_event_success
    mov rax, -71                 # EPROTO
    jmp .read_event_done
.read_event_success:
    xor eax, eax
.read_event_done:
    pop rbp
    ret
.read_event_bad:
    mov rax, -71
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
    # Request at most wl_seat version 4, which exposes wl_keyboard.repeat_info.
    # Keep older compositor versions working with the local default timings.
    mov eax, dword ptr [rip + event_payload + 4]
    add eax, 3
    and eax, -4
    lea rdi, [rip + event_payload + 8]
    add rdi, rax
    mov edx, dword ptr [rdi]
    cmp edx, 4
    jbe .Lneko_seat_version_ready
    mov edx, 4
.Lneko_seat_version_ready:
    mov dword ptr [rip + seat_version], edx
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

# Repaint the editor surface, including document chrome and status information.
.type render_surface, @function
render_surface:
    push rbp
    # Main application background.
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, WIDTH
    mov r8d, HEIGHT
    mov r9d, 0xff252a33
    call draw_rect

    # Compact title bar with a narrow accent rail.
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, WIDTH
    mov r8d, 32
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, 3
    mov r8d, 32
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 16
    mov esi, 12
    lea rdx, [rip + ui_app_name]
    call draw_text
    cmp dword ptr [rip + doc_save_error], 0
    jne .render_save_error
    cmp dword ptr [rip + doc_open_error], 0
    jne .render_open_error
    cmp dword ptr [rip + doc_save_error], 0
    jne .render_save_error
    mov edi, 744
    mov esi, 12
    lea rdx, [rip + ui_mode_name]
    call draw_text
    jmp .render_file_button
.render_open_error:
    mov edi, 704
    mov esi, 12
    lea rdx, [rip + ui_open_error]
    call draw_text
    jmp .render_file_button
.render_save_error:
    mov edi, 720
    mov esi, 12
    lea rdx, [rip + ui_mode_error]
    call draw_text

.render_file_button:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 4
    mov ecx, 48
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 112
    mov esi, 12
    lea rdx, [rip + ui_file_label]
    call draw_text

.render_document_tab:
    # A single active document tab; the launch-time basename replaces Untitled.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 8
    mov edx, 40
    mov ecx, 152
    mov r8d, 36
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 8
    mov edx, 74
    mov ecx, 152
    mov r8d, 2
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 24
    mov esi, 54
    lea rdx, [rip + active_document_name]
    call draw_text

    call render_selection
    call render_document
    call render_status_bar
    call render_file_menu
    call render_path_prompt
    call render_picker
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
    mov rax, -16
.present_buffer_done:
    add rsp, 8
    ret
.size present_buffer, . - present_buffer

# Return the byte offset after one valid UTF-8 scalar. Invalid bytes are treated
# as single-byte replacement units so the original file bytes remain editable.
# EDI=byte offset; EAX=next byte offset.
.type doc_byte_at, @function
# Read one logical document byte, translating around the movable gap.
# EDI=logical byte offset; EAX=byte value (zero for an out-of-range offset).
doc_byte_at:
    mov eax, edi
    cmp eax, dword ptr [rip + doc_length]
    jae .doc_byte_at_out_of_range
    cmp eax, dword ptr [rip + doc_gap_start]
    jb .doc_byte_at_physical
    mov edx, dword ptr [rip + doc_gap_end]
    sub edx, dword ptr [rip + doc_gap_start]
    add eax, edx
.doc_byte_at_physical:
    lea rdx, [rip + doc_buffer]
    movzx eax, byte ptr [rdx + rax]
    ret
.doc_byte_at_out_of_range:
    xor eax, eax
    ret
.size doc_byte_at, . - doc_byte_at

# Move the gap to a logical byte offset. EDI is clamped to doc_length.
# The gap is [doc_gap_start, doc_gap_end); bytes outside it stay in order.
.type doc_move_gap, @function
doc_move_gap:
    push rbx
    push r12
    push r13
    mov ebx, edi
    mov eax, dword ptr [rip + doc_length]
    cmp ebx, eax
    jbe .doc_move_gap_target_valid
    mov ebx, eax
.doc_move_gap_target_valid:
    mov r12d, dword ptr [rip + doc_gap_start]
    cmp ebx, r12d
    jb .doc_move_gap_left
    ja .doc_move_gap_right
    jmp .doc_move_gap_done

.doc_move_gap_left:
    # Move the prefix tail backwards into the end of the current gap.
    mov r13d, r12d
    sub r13d, ebx
    test r13d, r13d
    jz .doc_move_gap_done
    lea rsi, [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_start]
    add rsi, rax
    dec rsi
    lea rdi, [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add rdi, rax
    dec rdi
    mov ecx, r13d
    std
    rep movsb
    cld
    mov dword ptr [rip + doc_gap_start], ebx
    sub dword ptr [rip + doc_gap_end], r13d
    jmp .doc_move_gap_done

.doc_move_gap_right:
    # Move the suffix head forwards into the beginning of the current gap.
    mov r13d, ebx
    sub r13d, r12d
    test r13d, r13d
    jz .doc_move_gap_done
    lea rsi, [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add rsi, rax
    lea rdi, [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_start]
    add rdi, rax
    mov ecx, r13d
    cld
    rep movsb
    add dword ptr [rip + doc_gap_start], r13d
    add dword ptr [rip + doc_gap_end], r13d
.doc_move_gap_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_move_gap, . - doc_move_gap

# Return the byte offset after one valid UTF-8 scalar. Invalid bytes are treated
# as single-byte replacement units so the original file bytes remain editable.
# EDI=logical byte offset; EAX=next logical byte offset.
.type doc_utf8_next, @function
doc_utf8_next:
    push rbx
    mov r8d, edi
    mov r9d, dword ptr [rip + doc_length]
    mov eax, r8d
    cmp r8d, r9d
    jae .Lneko_utf8_next_done
    mov edi, r8d
    call doc_byte_at
    mov r11d, eax
    cmp r11d, 0xc2
    jb .Lneko_utf8_next_single
    cmp r11d, 0xdf
    jbe .Lneko_utf8_next_two
    cmp r11d, 0xef
    jbe .Lneko_utf8_next_three
    cmp r11d, 0xf4
    jbe .Lneko_utf8_next_four
    jmp .Lneko_utf8_next_single

.Lneko_utf8_next_two:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 2]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_three:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    cmp r10d, 0x80
    jb .Lneko_utf8_next_single
    cmp r10d, 0xbf
    ja .Lneko_utf8_next_single
    cmp r11d, 0xe0
    jne .Lneko_utf8_next_three_check_ed
    cmp r10d, 0xa0
    jb .Lneko_utf8_next_single
    jmp .Lneko_utf8_next_three_second_ok
.Lneko_utf8_next_three_check_ed:
    cmp r11d, 0xed
    jne .Lneko_utf8_next_three_second_ok
    cmp r10d, 0x9f
    ja .Lneko_utf8_next_single
.Lneko_utf8_next_three_second_ok:
    lea edi, [r8d + 2]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 3]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_four:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    cmp r10d, 0x80
    jb .Lneko_utf8_next_single
    cmp r10d, 0xbf
    ja .Lneko_utf8_next_single
    cmp r11d, 0xf0
    jne .Lneko_utf8_next_four_check_f4
    cmp r10d, 0x90
    jb .Lneko_utf8_next_single
    jmp .Lneko_utf8_next_four_second_ok
.Lneko_utf8_next_four_check_f4:
    cmp r11d, 0xf4
    jne .Lneko_utf8_next_four_second_ok
    cmp r10d, 0x8f
    ja .Lneko_utf8_next_single
.Lneko_utf8_next_four_second_ok:
    lea edi, [r8d + 2]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea edi, [r8d + 3]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 4]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_single:
    lea eax, [r8d + 1]
.Lneko_utf8_next_done:
    pop rbx
    ret
.size doc_utf8_next, . - doc_utf8_next

# Return the start of the valid UTF-8 scalar ending at EDI. Invalid trailing
# bytes remain individually addressable. EDI=byte offset; EAX=previous offset.
.type doc_utf8_prev, @function
doc_utf8_prev:
    push rbx
    push r12
    mov r12d, edi
    test r12d, r12d
    jz .Lneko_utf8_prev_zero
    cmp r12d, 2
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 2]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
    cmp r12d, 3
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 3]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
    cmp r12d, 4
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 4]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
.Lneko_utf8_prev_fallback:
    lea eax, [r12d - 1]
    jmp .Lneko_utf8_prev_done
.Lneko_utf8_prev_found:
    mov eax, ebx
    jmp .Lneko_utf8_prev_done
.Lneko_utf8_prev_zero:
    xor eax, eax
.Lneko_utf8_prev_done:
    pop r12
    pop rbx
    ret
.size doc_utf8_prev, . - doc_utf8_prev

# Insert one byte at the cursor. The bounded buffer never writes past its allocation.
.type doc_insert_byte, @function
# Insert a byte at the logical cursor by consuming one byte from the gap.
doc_insert_byte:
    push rbx
    push r12
    push r13
    mov r13d, edi
    mov edi, dword ptr [rip + doc_cursor]
    call doc_move_gap
    mov eax, dword ptr [rip + doc_gap_start]
    cmp eax, dword ptr [rip + doc_gap_end]
    jae .doc_insert_done
    lea r12, [rip + doc_buffer]
    mov byte ptr [r12 + rax], r13b
    inc dword ptr [rip + doc_gap_start]
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
    mov r12d, dword ptr [rip + doc_cursor]
    cmp r12d, dword ptr [rip + doc_length]
    jae .doc_delete_done
    mov edi, r12d
    call doc_utf8_next
    mov r13d, eax
    mov edi, r12d
    call doc_move_gap
    mov eax, r13d
    sub eax, r12d
    add dword ptr [rip + doc_gap_end], eax
    sub dword ptr [rip + doc_length], eax
.doc_delete_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_delete_at_cursor, . - doc_delete_at_cursor

.type doc_delete_selection, @function
# Remove a logical selection by extending the gap over its selected bytes.
doc_delete_selection:
    push rbx
    push r12
    push r13
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_delete_selection_done
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_delete_selection_bounds
    xchg eax, edx
.Lneko_delete_selection_bounds:
    mov ebx, eax
    mov r12d, edx
    mov edi, ebx
    call doc_move_gap
    mov r13d, r12d
    sub r13d, ebx
    add dword ptr [rip + doc_gap_end], r13d
    sub dword ptr [rip + doc_length], r13d
    mov dword ptr [rip + doc_cursor], ebx
    mov dword ptr [rip + doc_selection_anchor], ebx
    mov dword ptr [rip + doc_selection_active], 0
.Lneko_delete_selection_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_delete_selection, . - doc_delete_selection

# Clear selection state while retaining the current insertion point.
.type doc_clear_selection, @function
doc_clear_selection:
    mov dword ptr [rip + doc_selection_active], 0
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
    ret
.size doc_clear_selection, . - doc_clear_selection

# Start compositor-configured repeat for ordinary keys. Modifier and lock
# keys are intentionally excluded. EAX=Linux evdev keycode.
.type repeat_start_if_supported, @function
repeat_start_if_supported:
    # Shift, Ctrl, Alt, Meta/Super, Caps/Num/Scroll Lock and Compose do not repeat.
    cmp eax, 42
    je .Lneko_repeat_start_done
    cmp eax, 54
    je .Lneko_repeat_start_done
    cmp eax, 29
    je .Lneko_repeat_start_done
    cmp eax, 97
    je .Lneko_repeat_start_done
    cmp eax, 56
    je .Lneko_repeat_start_done
    cmp eax, 100
    je .Lneko_repeat_start_done
    cmp eax, 125
    je .Lneko_repeat_start_done
    cmp eax, 126
    je .Lneko_repeat_start_done
    cmp eax, 58
    je .Lneko_repeat_start_done
    cmp eax, 69
    je .Lneko_repeat_start_done
    cmp eax, 70
    je .Lneko_repeat_start_done
    cmp eax, 127
    je .Lneko_repeat_start_done
    cmp dword ptr [rip + repeat_rate], 0
    je .Lneko_repeat_start_done
    mov dword ptr [rip + repeat_keycode], eax
    # itimerspec.it_interval = 1 second / repeat_rate.
    mov qword ptr [rip + repeat_timer_spec], 0
    mov qword ptr [rip + repeat_timer_spec + 8], 0
    mov rax, REPEAT_NS_PER_SECOND
    xor edx, edx
    mov ecx, dword ptr [rip + repeat_rate]
    div rcx
    mov rcx, REPEAT_NS_PER_SECOND
    xor edx, edx
    div rcx
    mov qword ptr [rip + repeat_timer_spec], rax
    mov qword ptr [rip + repeat_timer_spec + 8], rdx
    # itimerspec.it_value = configured initial delay in milliseconds.
    mov eax, dword ptr [rip + repeat_delay_ms]
    imul rax, rax, 1000000
    mov rcx, REPEAT_NS_PER_SECOND
    xor edx, edx
    div rcx
    mov qword ptr [rip + repeat_timer_spec + 16], rax
    mov qword ptr [rip + repeat_timer_spec + 24], rdx
    # timerfd interprets a zero it_value as disarmed; represent a zero-delay
    # repeat with the smallest non-zero expiration.
    cmp dword ptr [rip + repeat_delay_ms], 0
    jne .Lneko_repeat_timer_arm
    mov qword ptr [rip + repeat_timer_spec + 24], 1
.Lneko_repeat_timer_arm:
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + repeat_timer_fd]
    xor esi, esi
    lea rdx, [rip + repeat_timer_spec]
    xor r10d, r10d
    syscall
.Lneko_repeat_start_done:
    ret
.size repeat_start_if_supported, . - repeat_start_if_supported

.type repeat_cancel, @function
repeat_cancel:
    mov dword ptr [rip + repeat_keycode], 0
    cmp dword ptr [rip + repeat_timer_fd], 0
    je .Lneko_repeat_cancel_done
    mov qword ptr [rip + repeat_timer_spec], 0
    mov qword ptr [rip + repeat_timer_spec + 8], 0
    mov qword ptr [rip + repeat_timer_spec + 16], 0
    mov qword ptr [rip + repeat_timer_spec + 24], 0
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + repeat_timer_fd]
    xor esi, esi
    lea rdx, [rip + repeat_timer_spec]
    xor r10d, r10d
    syscall
.Lneko_repeat_cancel_done:
    ret
.size repeat_cancel, . - repeat_cancel

# Begin or update a selection driven by Shift+navigation.
.type doc_begin_keyboard_selection, @function
doc_begin_keyboard_selection:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_begin_keyboard_selection_done
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
.Lneko_begin_keyboard_selection_done:
    ret
.size doc_begin_keyboard_selection, . - doc_begin_keyboard_selection

.type doc_finish_keyboard_selection, @function
doc_finish_keyboard_selection:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_selection_anchor]
    je .Lneko_finish_keyboard_selection_clear
    mov dword ptr [rip + doc_selection_active], 1
    ret
.Lneko_finish_keyboard_selection_clear:
    mov dword ptr [rip + doc_selection_active], 0
    ret
.size doc_finish_keyboard_selection, . - doc_finish_keyboard_selection

# EDI=0 Home, EDI=1 End.
.type doc_move_line_edge, @function
doc_move_line_edge:
    push rbx
    push r12
    mov r12d, edi
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov ebx, eax
    mov edi, ebx
    xor esi, esi
    test r12d, r12d
    jz .Lneko_visual_edge_lookup
    inc edi
.Lneko_visual_edge_lookup:
    call doc_visual_to_offset
    test r12d, r12d
    jz .Lneko_visual_edge_store
    test eax, eax
    jz .Lneko_visual_edge_store
    mov ebx, eax
    lea edi, [rbx - 1]
    call doc_byte_at
    cmp eax, 10
    jne .Lneko_visual_edge_store_ebx
    dec ebx
.Lneko_visual_edge_store_ebx:
    mov eax, ebx
.Lneko_visual_edge_store:
    mov dword ptr [rip + doc_cursor], eax
    pop r12
    pop rbx
    ret
.size doc_move_line_edge, . - doc_move_line_edge

# Place the document cursor from surface-local pixel coordinates.
# EDI=x, ESI=y. Clicks snap to the nearest character insertion boundary;
# tabs occupy four cells and UTF-8 continuation bytes are never cursor stops.
# Map a document byte offset to its soft-wrapped visual row and column.
# EDI=byte offset; returns EAX=row and EDX=column.
.type doc_offset_to_visual, @function
doc_offset_to_visual:
    push rbx
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, dword ptr [rip + doc_length]
    cmp r12d, r13d
    cmova r12d, r13d
    xor r14d, r14d
    xor ebx, ebx
    xor ecx, ecx
.Lneko_offset_visual_scan:
    cmp ecx, r12d
    jae .Lneko_offset_visual_boundary
    mov edi, ecx
    call doc_byte_at
    cmp eax, 10
    je .Lneko_offset_visual_newline
    cmp eax, 9
    je .Lneko_offset_visual_tab
    cmp eax, 32
    jb .Lneko_offset_visual_skip
    cmp eax, 128
    jb .Lneko_offset_visual_glyph
.Lneko_offset_visual_glyph:
    cmp ebx, DOC_COLUMNS
    jb .Lneko_offset_visual_glyph_fit
    inc r14d
    xor ebx, ebx
.Lneko_offset_visual_glyph_fit:
    inc ebx
    mov edi, ecx
    call doc_utf8_next
    mov ecx, eax
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_newline:
    inc r14d
    xor ebx, ebx
    inc ecx
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_tab:
    lea edx, [rbx + 4]
    cmp edx, DOC_COLUMNS
    jbe .Lneko_offset_visual_tab_fit
    inc r14d
    xor ebx, ebx
.Lneko_offset_visual_tab_fit:
    add ebx, 4
    inc ecx
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_skip:
    inc ecx
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_boundary:
    # An insertion boundary immediately before a token that would wrap belongs
    # at the start of the next visual row, not just beyond the right edge.
    cmp r12d, r13d
    jae .Lneko_offset_visual_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_offset_visual_done
    cmp eax, 9
    je .Lneko_offset_visual_boundary_tab
    cmp eax, 32
    jb .Lneko_offset_visual_done
    cmp eax, 128
    jb .Lneko_offset_visual_boundary_glyph
.Lneko_offset_visual_boundary_glyph:
    cmp ebx, DOC_COLUMNS
    jb .Lneko_offset_visual_done
    inc r14d
    xor ebx, ebx
    jmp .Lneko_offset_visual_done
.Lneko_offset_visual_boundary_tab:
    lea edx, [rbx + 4]
    cmp edx, DOC_COLUMNS
    jbe .Lneko_offset_visual_done
    inc r14d
    xor ebx, ebx
.Lneko_offset_visual_done:
    mov eax, r14d
    mov edx, ebx
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_offset_to_visual, . - doc_offset_to_visual

# Map a visual row/column to the nearest byte insertion boundary.
# EDI=visual row, ESI=visual column; returns EAX=byte offset.
.type doc_visual_to_offset, @function
doc_visual_to_offset:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r15d, dword ptr [rip + doc_length]
    xor r14d, r14d
    xor ebx, ebx
    xor ecx, ecx
.Lneko_visual_offset_scan:
    cmp r14d, r15d
    jae .Lneko_visual_offset_end
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_visual_offset_newline
    cmp eax, 9
    je .Lneko_visual_offset_tab
    cmp eax, 32
    jb .Lneko_visual_offset_skip
    cmp eax, 128
    jb .Lneko_visual_offset_glyph
.Lneko_visual_offset_glyph:
    cmp ecx, DOC_COLUMNS
    jb .Lneko_visual_offset_glyph_row_ready
    inc ebx
    xor ecx, ecx
.Lneko_visual_offset_glyph_row_ready:
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    cmp ebx, r12d
    jne .Lneko_visual_offset_consume_glyph
    cmp ecx, r13d
    jae .Lneko_visual_offset_end
.Lneko_visual_offset_consume_glyph:
    inc ecx
    mov edi, r14d
    call doc_utf8_next
    mov r14d, eax
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_newline:
    cmp ebx, r12d
    je .Lneko_visual_offset_end
    inc ebx
    xor ecx, ecx
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_tab:
    lea edx, [rcx + 4]
    cmp edx, DOC_COLUMNS
    jbe .Lneko_visual_offset_tab_row_ready
    inc ebx
    xor ecx, ecx
.Lneko_visual_offset_tab_row_ready:
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    cmp ebx, r12d
    jne .Lneko_visual_offset_consume_tab
    lea edx, [rcx + 2]
    cmp r13d, edx
    jb .Lneko_visual_offset_end
.Lneko_visual_offset_consume_tab:
    add ecx, 4
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_skip:
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_end:
    mov eax, r14d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_visual_to_offset, . - doc_visual_to_offset

# Keep the active insertion point within the vertically visible document rows.
.type doc_ensure_cursor_visible, @function
doc_ensure_cursor_visible:
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov edx, dword ptr [rip + doc_view_top_row]
    cmp eax, edx
    jae .Lneko_ensure_cursor_lower
    mov dword ptr [rip + doc_view_top_row], eax
    ret
.Lneko_ensure_cursor_lower:
    lea ecx, [edx + DOC_VISIBLE_ROWS]
    cmp eax, ecx
    jb .Lneko_ensure_cursor_done
    sub eax, DOC_VISIBLE_ROWS - 1
    mov dword ptr [rip + doc_view_top_row], eax
.Lneko_ensure_cursor_done:
    ret
.size doc_ensure_cursor_visible, . - doc_ensure_cursor_visible

# Place cursor from surface-local coordinates; rows include the current scroll.
.type doc_place_cursor_from_pointer, @function
doc_place_cursor_from_pointer:
    mov r8d, edi
    mov eax, edi
    sub eax, DOC_LEFT
    test eax, eax
    jns .Lneko_pointer_x_nonnegative
    xor eax, eax
.Lneko_pointer_x_nonnegative:
    add eax, CELL_WIDTH / 2
    xor edx, edx
    mov ecx, CELL_WIDTH
    div ecx
    mov esi, eax
    mov eax, dword ptr [rip + pointer_y]
    sub eax, DOC_TOP
    test eax, eax
    jns .Lneko_pointer_y_nonnegative
    xor eax, eax
.Lneko_pointer_y_nonnegative:
    xor edx, edx
    mov ecx, LINE_HEIGHT
    div ecx
    add eax, dword ptr [rip + doc_view_top_row]
    mov edi, eax
    call doc_visual_to_offset
    mov dword ptr [rip + doc_cursor], eax
    ret
.size doc_place_cursor_from_pointer, . - doc_place_cursor_from_pointer

# EDI=0 moves up; EDI=1 moves down by one visual row.
.type doc_move_vertical, @function
doc_move_vertical:
    push rbx
    push r12
    mov r12d, edi
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov ebx, eax
    test r12d, r12d
    jnz .Lneko_vertical_move_down
    test ebx, ebx
    jz .Lneko_vertical_move_done
    dec ebx
    jmp .Lneko_vertical_move_lookup
.Lneko_vertical_move_down:
    inc ebx
.Lneko_vertical_move_lookup:
    mov edi, ebx
    mov esi, edx
    call doc_visual_to_offset
    mov dword ptr [rip + doc_cursor], eax
.Lneko_vertical_move_done:
    pop r12
    pop rbx
    ret
.size doc_move_vertical, . - doc_move_vertical

# Translate printable input from the active XKB keymap when the supported
# text-v1 subset was parsed. A parsed map's non-ASCII keys are deliberately
# ignored rather than silently producing an unrelated US-QWERTY character.
.type keycode_to_ascii, @function
keycode_to_ascii:
    push rbx
    mov ebx, edi
    cmp dword ptr [rip + keymap_format], 1
    jne .Lneko_keymap_fallback
    mov edi, ebx
    mov esi, dword ptr [rip + shift_down]
    mov edx, dword ptr [rip + caps_lock]
    mov ecx, dword ptr [rip + level3_down]
    mov r8d, dword ptr [rip + keyboard_group]
    call xkb_lookup_ascii
    pop rbx
    ret
.Lneko_keymap_fallback:
    mov edi, ebx
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
    pop rbx
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
    pop rbx
    ret
.keymap_unknown:
    xor eax, eax
    pop rbx
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
    cmp eax, 35
    je .glyph_numbersign
    cmp eax, 36
    je .glyph_dollar
    cmp eax, 37
    je .glyph_percent
    cmp eax, 38
    je .glyph_ampersand
    cmp eax, 42
    je .glyph_asterisk
    cmp eax, 59
    je .glyph_semicolon
    cmp eax, 60
    je .glyph_less
    cmp eax, 62
    je .glyph_greater
    cmp eax, 64
    je .glyph_at
    cmp eax, 91
    je .glyph_open_bracket
    cmp eax, 92
    je .glyph_backslash
    cmp eax, 93
    je .glyph_close_bracket
    cmp eax, 94
    je .glyph_caret
    cmp eax, 96
    je .glyph_grave
    cmp eax, 123
    je .glyph_open_brace
    cmp eax, 124
    je .glyph_bar
    cmp eax, 125
    je .glyph_close_brace
    cmp eax, 126
    je .glyph_tilde
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
    jmp .glyph_index_ready
.glyph_numbersign:
    mov eax, 50
    jmp .glyph_index_ready
.glyph_dollar:
    mov eax, 51
    jmp .glyph_index_ready
.glyph_percent:
    mov eax, 52
    jmp .glyph_index_ready
.glyph_ampersand:
    mov eax, 53
    jmp .glyph_index_ready
.glyph_asterisk:
    mov eax, 54
    jmp .glyph_index_ready
.glyph_semicolon:
    mov eax, 55
    jmp .glyph_index_ready
.glyph_less:
    mov eax, 56
    jmp .glyph_index_ready
.glyph_greater:
    mov eax, 57
    jmp .glyph_index_ready
.glyph_at:
    mov eax, 58
    jmp .glyph_index_ready
.glyph_open_bracket:
    mov eax, 59
    jmp .glyph_index_ready
.glyph_backslash:
    mov eax, 60
    jmp .glyph_index_ready
.glyph_close_bracket:
    mov eax, 61
    jmp .glyph_index_ready
.glyph_caret:
    mov eax, 62
    jmp .glyph_index_ready
.glyph_grave:
    mov eax, 63
    jmp .glyph_index_ready
.glyph_open_brace:
    mov eax, 64
    jmp .glyph_index_ready
.glyph_bar:
    mov eax, 65
    jmp .glyph_index_ready
.glyph_close_brace:
    mov eax, 66
    jmp .glyph_index_ready
.glyph_tilde:
    mov eax, 67
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

# Draw a NUL-terminated ASCII label. EDI=x, ESI=y, RDX=string; EAX=next x.
.type draw_text, @function
draw_text:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    mov rbx, rdx
.Lneko_draw_text_loop:
    movzx edx, byte ptr [rbx]
    test edx, edx
    jz .Lneko_draw_text_done
    mov edi, r12d
    mov esi, r13d
    call draw_glyph
    add r12d, CELL_WIDTH
    inc rbx
    jmp .Lneko_draw_text_loop
.Lneko_draw_text_done:
    mov eax, r12d
    pop r13
    pop r12
    pop rbx
    ret
.size draw_text, . - draw_text

# Draw an unsigned decimal value. EAX=value, EDI=x, ESI=y; returns next x.
.type draw_decimal, @function
draw_decimal:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16
    mov r13d, edi
    mov r14d, esi
    mov ebx, eax
    lea r12, [rsp + 15]
    mov byte ptr [r12], 0
.Lneko_draw_decimal_convert:
    mov eax, ebx
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    dec r12
    mov byte ptr [r12], dl
    mov ebx, eax
    test ebx, ebx
    jnz .Lneko_draw_decimal_convert
.Lneko_draw_decimal_paint:
    movzx edx, byte ptr [r12]
    test edx, edx
    jz .Lneko_draw_decimal_done
    mov edi, r13d
    mov esi, r14d
    call draw_glyph
    add r13d, CELL_WIDTH
    inc r12
    jmp .Lneko_draw_decimal_paint
.Lneko_draw_decimal_done:
    mov eax, r13d
    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size draw_decimal, . - draw_decimal

# Render the live logical line/column and current byte count in the footer.
# Columns are one-based; tabs advance to the next four-column stop.
.type render_status_bar, @function
render_status_bar:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    mov edx, STATUS_TOP
    mov ecx, WIDTH
    mov r8d, HEIGHT - STATUS_TOP
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    mov edx, STATUS_TOP
    mov ecx, WIDTH
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect

    # Derive logical line and column from the cursor's byte offset.
    mov ebx, dword ptr [rip + doc_cursor]
    cmp ebx, dword ptr [rip + doc_length]
    jbe .Lneko_status_cursor_bounded
    mov ebx, dword ptr [rip + doc_length]
.Lneko_status_cursor_bounded:
    xor r14d, r14d
    mov r13d, 1
    mov ebp, 1
.Lneko_status_scan:
    cmp r14d, ebx
    jae .Lneko_status_scan_done
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_status_newline
    cmp eax, 9
    je .Lneko_status_tab
    inc ebp
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_newline:
    inc r13d
    mov ebp, 1
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_tab:
    dec ebp
    add ebp, 4
    and ebp, -4
    inc ebp
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_scan_done:
    mov edi, 16
    mov esi, 466
    lea rdx, [rip + ui_label_line]
    call draw_text
    mov edi, eax
    mov esi, 466
    mov eax, r13d
    call draw_decimal
    add eax, 4
    mov edi, eax
    mov esi, 466
    lea rdx, [rip + ui_label_column]
    call draw_text
    mov edi, eax
    mov esi, 466
    mov eax, ebp
    call draw_decimal

    mov edi, 480
    mov esi, 466
    lea rdx, [rip + ui_label_bytes]
    call draw_text
    mov edi, eax
    mov esi, 466
    mov eax, dword ptr [rip + doc_length]
    call draw_decimal
    mov edi, 744
    mov esi, 466
    lea rdx, [rip + ui_mode_name]
    call draw_text
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size render_status_bar, . - render_status_bar


.type draw_bounded_ascii, @function
# RDI=x, ESI=y, RDX=NUL-terminated byte string, ECX=maximum bytes.
# Non-printable and non-ASCII bytes are rendered as '?' while path operations
# continue to use the untouched original name/path bytes.
draw_bounded_ascii:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdx
    mov r12d, edi
    mov r13d, esi
    mov r14d, ecx
.draw_bounded_ascii_loop:
    test r14d, r14d
    jz .draw_bounded_ascii_done
    movzx edx, byte ptr [rbx]
    test dl, dl
    jz .draw_bounded_ascii_done
    cmp dl, 32
    jb .draw_bounded_ascii_replacement
    cmp dl, 126
    ja .draw_bounded_ascii_replacement
    jmp .draw_bounded_ascii_glyph
.draw_bounded_ascii_replacement:
    mov edx, '?'
.draw_bounded_ascii_glyph:
    mov edi, r12d
    mov esi, r13d
    call draw_glyph
    add r12d, CELL_WIDTH
    inc rbx
    dec r14d
    jmp .draw_bounded_ascii_loop
.draw_bounded_ascii_done:
    mov eax, r12d
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_bounded_ascii, . - draw_bounded_ascii

.type render_picker, @function
render_picker:
    cmp dword ptr [rip + picker_mode], 0
    je .render_picker_done
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    # Modal panel and title strip.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 40
    mov edx, 36
    mov ecx, 720
    mov r8d, 408
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 40
    mov edx, 36
    mov ecx, 720
    mov r8d, 28
    mov r9d, 0xff343d4b
    call draw_rect
    cmp dword ptr [rip + picker_mode], 1
    jne .render_picker_title_save
    mov edi, 56
    mov esi, 46
    lea rdx, [rip + ui_picker_open_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_save:
    mov edi, 56
    mov esi, 46
    lea rdx, [rip + ui_picker_save_title]
    call draw_text

.render_picker_path:
    mov edi, 56
    mov esi, 55
    lea rdx, [rip + ui_picker_path_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 64
    mov ecx, 688
    mov r8d, 28
    mov r9d, 0xff252a33
    call draw_rect
    cmp dword ptr [rip + picker_focus], 1
    jne .render_picker_path_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 64
    mov ecx, 688
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect
.render_picker_path_text:
    lea rdx, [rip + picker_path_buffer]
    mov edi, 64
    mov esi, 74
    mov ecx, 84
    call draw_bounded_ascii

    # Up, Home, and hidden-file visibility controls.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 96
    mov ecx, 44
    mov r8d, 26
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 68
    mov esi, 105
    lea rdx, [rip + ui_picker_up_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 96
    mov ecx, 56
    mov r8d, 26
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 116
    mov esi, 105
    lea rdx, [rip + ui_picker_home_label]
    call draw_text
    mov edi, 600
    mov esi, 105
    lea rdx, [rip + ui_picker_hidden_label]
    call draw_text
    cmp dword ptr [rip + picker_show_hidden], 0
    je .render_picker_list
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 744
    mov edx, 101
    mov ecx, 7
    mov r8d, 7
    mov r9d, 0xff78a9d4
    call draw_rect

.render_picker_list:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 128
    mov ecx, 688
    mov r8d, 222
    mov r9d, 0xff252a33
    call draw_rect
    mov r12d, dword ptr [rip + picker_scroll]
    xor r13d, r13d
.render_picker_rows:
    cmp r13d, PICKER_VISIBLE_ROWS
    jae .render_picker_empty_or_name
    mov r14d, r12d
    add r14d, r13d
    cmp r14d, dword ptr [rip + picker_entry_count]
    jae .render_picker_empty_or_name
    cmp r14d, dword ptr [rip + picker_selected]
    jne .render_picker_row_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 58
    mov eax, r13d
    imul eax, 14
    lea edx, [rax + 130]
    mov ecx, 684
    mov r8d, 14
    mov r9d, 0xff414b5a
    call draw_rect
.render_picker_row_text:
    mov eax, r14d
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    mov edi, 64
    mov eax, r13d
    imul eax, 14
    lea esi, [rax + 133]
    cmp byte ptr [rbx], 1
    jne .render_picker_file_marker
    lea rdx, [rip + ui_picker_dir_marker]
    call draw_text
    jmp .render_picker_draw_name
.render_picker_file_marker:
    lea rdx, [rip + ui_picker_file_marker]
    call draw_text
.render_picker_draw_name:
    lea rdx, [rbx + 4]
    mov edi, 96
    mov eax, r13d
    imul eax, 14
    lea esi, [rax + 133]
    mov ecx, 78
    call draw_bounded_ascii
    inc r13d
    jmp .render_picker_rows

.render_picker_empty_or_name:
    cmp dword ptr [rip + picker_entry_count], 0
    jne .render_picker_name
    mov edi, 72
    mov esi, 142
    lea rdx, [rip + ui_picker_empty]
    call draw_text

.render_picker_name:
    mov edi, 56
    mov esi, 363
    lea rdx, [rip + ui_picker_name_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 128
    mov edx, 360
    mov ecx, 480
    mov r8d, 28
    mov r9d, 0xff252a33
    call draw_rect
    cmp dword ptr [rip + picker_focus], 2
    jne .render_picker_name_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 128
    mov edx, 360
    mov ecx, 480
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect
.render_picker_name_text:
    lea rdx, [rip + picker_name_buffer]
    mov edi, 136
    mov esi, 370
    mov ecx, 72
    call draw_bounded_ascii

    # Cancel and Open/Save action buttons.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 600
    mov edx, 396
    mov ecx, 72
    mov r8d, 32
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 612
    mov esi, 407
    lea rdx, [rip + ui_picker_cancel_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 680
    mov edx, 396
    mov ecx, 72
    mov r8d, 32
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 692
    mov esi, 407
    cmp dword ptr [rip + picker_mode], 1
    jne .render_picker_save_label
    lea rdx, [rip + ui_picker_open_label]
    jmp .render_picker_action_label
.render_picker_save_label:
    lea rdx, [rip + ui_picker_save_label]
.render_picker_action_label:
    call draw_text

    cmp dword ptr [rip + picker_truncated], 0
    je .render_picker_messages
    mov edi, 56
    mov esi, 434
    lea rdx, [rip + ui_picker_truncated]
    call draw_text
.render_picker_messages:
    cmp dword ptr [rip + picker_error], 0
    je .render_picker_overwrite
    mov edi, 352
    mov esi, 434
    cmp dword ptr [rip + picker_error], 1
    jne .render_picker_error_file
    lea rdx, [rip + ui_picker_error_path]
    jmp .render_picker_error_draw
.render_picker_error_file:
    cmp dword ptr [rip + picker_error], 2
    jne .render_picker_error_save
    lea rdx, [rip + ui_picker_error_file]
    jmp .render_picker_error_draw
.render_picker_error_save:
    lea rdx, [rip + ui_picker_error_save]
.render_picker_error_draw:
    call draw_text

.render_picker_overwrite:
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .render_picker_done_pop
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 184
    mov edx, 176
    mov ecx, 432
    mov r8d, 80
    mov r9d, 0xff343d4b
    call draw_rect
    mov edi, 208
    mov esi, 190
    lea rdx, [rip + ui_picker_overwrite]
    call draw_text

.render_picker_done_pop:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
.render_picker_done:
    ret
.size render_picker, . - render_picker

.type render_file_menu, @function
render_file_menu:
    cmp dword ptr [rip + file_menu_open], 1
    jne .render_file_menu_done
    push rbp
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 32
    mov ecx, 128
    mov r8d, 80
    mov r9d, 0xff1f242d
    call draw_rect
    mov edi, 116
    mov esi, 42
    lea rdx, [rip + ui_menu_open_label]
    call draw_text
    mov edi, 116
    mov esi, 66
    lea rdx, [rip + ui_menu_save_label]
    call draw_text
    mov edi, 116
    mov esi, 90
    lea rdx, [rip + ui_menu_save_as_label]
    call draw_text
    pop rbp
.render_file_menu_done:
    ret
.size render_file_menu, . - render_file_menu

.type render_path_prompt, @function
render_path_prompt:
    cmp dword ptr [rip + path_prompt_mode], 0
    je .render_path_prompt_done
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 148
    mov ecx, 704
    mov r8d, 176
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 148
    mov ecx, 704
    mov r8d, 32
    mov r9d, 0xff343d4b
    call draw_rect
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .render_path_prompt_save_title
    mov edi, 72
    mov esi, 160
    lea rdx, [rip + ui_prompt_open_title]
    call draw_text
    jmp .render_path_prompt_entry
.render_path_prompt_save_title:
    mov edi, 72
    mov esi, 160
    lea rdx, [rip + ui_prompt_save_title]
    call draw_text
.render_path_prompt_entry:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 72
    mov edx, 204
    mov ecx, 656
    mov r8d, 36
    mov r9d, 0xff252a33
    call draw_rect
    mov r12d, dword ptr [rip + path_prompt_length]
    xor r14d, r14d
    cmp r12d, 76
    jbe .render_path_prompt_start_ready
    mov r14d, r12d
    sub r14d, 76
.render_path_prompt_start_ready:
    lea rbx, [rip + path_prompt_buffer]
    add rbx, r14
    mov r13d, 96
    xor r12d, r12d
.render_path_prompt_chars:
    cmp r12d, 76
    jae .render_path_prompt_caret
    movzx edx, byte ptr [rbx]
    test edx, edx
    jz .render_path_prompt_caret
    mov edi, r13d
    mov esi, 218
    call draw_glyph
    inc rbx
    add r13d, CELL_WIDTH
    inc r12d
    jmp .render_path_prompt_chars
.render_path_prompt_caret:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r13d
    mov edx, 216
    mov ecx, 1
    mov r8d, 12
    mov r9d, 0xffffffff
    call draw_rect
    mov edi, 72
    mov esi, 264
    lea rdx, [rip + ui_prompt_help]
    call draw_text
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
.render_path_prompt_done:
    ret
.size render_path_prompt, . - render_path_prompt


# Paint selected document cells before glyphs and the caret are rendered.
.type render_selection, @function
render_selection:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_render_selection_done

    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_render_selection_bounds
    xchg eax, edx
.Lneko_render_selection_bounds:
    mov dword ptr [rip + doc_selection_start], eax
    mov dword ptr [rip + doc_selection_end], edx

    mov r15d, dword ptr [rip + doc_length]
    mov r12d, DOC_LEFT
    mov r13d, DOC_TOP
    mov eax, dword ptr [rip + doc_view_top_row]
    imul eax, LINE_HEIGHT
    sub r13d, eax
    xor r14d, r14d
.Lneko_render_selection_scan:
    cmp r14d, r15d
    jae .Lneko_render_selection_done
    mov eax, dword ptr [rip + doc_selection_end]
    cmp r14d, eax
    jae .Lneko_render_selection_done
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_render_selection_newline
    cmp eax, 9
    je .Lneko_render_selection_tab
    cmp eax, 32
    jb .Lneko_render_selection_control
    cmp eax, 127
    jb .Lneko_render_selection_character

.Lneko_render_selection_character:
    cmp r12d, WIDTH - 8
    jb .Lneko_render_selection_character_fit
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
.Lneko_render_selection_character_fit:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_advance_cell
    cmp r12d, WIDTH - CELL_WIDTH
    ja .Lneko_render_selection_advance_cell
    cmp r13d, DOC_TOP
    jl .Lneko_render_selection_advance_cell
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jae .Lneko_render_selection_advance_cell
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, CELL_WIDTH
    mov r8d, LINE_HEIGHT
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_advance_cell:
    add r12d, CELL_WIDTH
    mov edi, r14d
    call doc_utf8_next
    mov r14d, eax
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_newline:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_newline_advance
    cmp r12d, WIDTH - CELL_WIDTH
    jae .Lneko_render_selection_newline_advance
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jae .Lneko_render_selection_newline_advance
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, CELL_WIDTH
    mov r8d, LINE_HEIGHT
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_newline_advance:
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
    inc r14d
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_tab:
    lea eax, [r12d + CELL_WIDTH * 4]
    cmp eax, WIDTH - 8
    jbe .Lneko_render_selection_tab_fit
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
.Lneko_render_selection_tab_fit:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_tab_advance
    cmp r12d, WIDTH - CELL_WIDTH * 4
    ja .Lneko_render_selection_tab_advance
    cmp r13d, DOC_TOP
    jl .Lneko_render_selection_tab_advance
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jae .Lneko_render_selection_tab_advance
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, CELL_WIDTH * 4
    mov r8d, LINE_HEIGHT
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_tab_advance:
    add r12d, CELL_WIDTH * 4
    inc r14d
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_control:
.Lneko_render_selection_byte_only:
    inc r14d
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size render_selection, . - render_selection

.type render_document, @function
render_document:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, DOC_LEFT
    mov r13d, DOC_TOP
    mov eax, dword ptr [rip + doc_view_top_row]
    imul eax, LINE_HEIGHT
    sub r13d, eax
    xor r14d, r14d
    mov r15d, dword ptr [rip + doc_length]
    test r15d, r15d
    jz .document_draw_cursor
.document_render_loop:
    cmp r14d, r15d
    jae .document_draw_cursor
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jge .document_draw_cursor
    mov edi, r14d
    call doc_byte_at
    mov edx, eax
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
    mov edx, '?'
.document_printable:
    cmp r12d, WIDTH - 8
    jb .document_printable_fit
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jge .document_draw_cursor
.document_printable_fit:
    cmp r13d, DOC_TOP
    jl .document_printable_skip_draw
    mov edi, r12d
    mov esi, r13d
    call draw_glyph
.document_printable_skip_draw:
    add r12d, CELL_WIDTH
    mov edi, r14d
    call doc_utf8_next
    mov r14d, eax
    jmp .document_render_loop

.document_tab:
    lea eax, [r12d + CELL_WIDTH * 4]
    cmp eax, WIDTH - 8
    jbe .document_tab_fit
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
    cmp r13d, STATUS_TOP - LINE_HEIGHT
    jge .document_draw_cursor
.document_tab_fit:
    add r12d, CELL_WIDTH * 4
    jmp .document_next_byte

.document_newline:
    mov r12d, DOC_LEFT
    add r13d, LINE_HEIGHT
.document_next_byte:
    inc r14d
    jmp .document_render_loop

.document_draw_cursor:
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov r12d, edx
    mov r13d, eax
    sub r13d, dword ptr [rip + doc_view_top_row]
    test r13d, r13d
    js .document_render_done
    cmp r13d, DOC_VISIBLE_ROWS
    jae .document_render_done
    imul r12d, CELL_WIDTH
    add r12d, DOC_LEFT
    imul r13d, LINE_HEIGHT
    add r13d, DOC_TOP
    cmp r12d, WIDTH - 2
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
