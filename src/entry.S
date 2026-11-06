.intel_syntax noprefix

.section .rodata
arg_help:             .asciz "--help"
arg_version:          .asciz "--version"
arg_backend_wayland:  .asciz "--backend=wayland"
arg_backend_x11:      .asciz "--backend=x11"

help_text:
    .ascii "NekoEdit - a tiny native Linux text editor\n"
    .ascii "\n"
    .ascii "Usage: nekoedit [--help|--version|--backend=wayland|--backend=x11]\n"
    .ascii "\n"
    .ascii "The current development build opens a minimal Wayland test window.\n"
    .ascii "The X11 backend and text editor UI are still under development.\n"
help_text_end:

version_text:
    .ascii "NekoEdit 0.1.0-dev\n"
version_text_end:

x11_todo_text:
    .ascii "NekoEdit: the X11 backend is not implemented yet.\n"
    .ascii "Use a Wayland session for the current development build.\n"
x11_todo_text_end:

unknown_text:
    .ascii "NekoEdit: unknown argument. Try 'nekoedit --help'.\n"
unknown_text_end:

.section .text
.extern process_envp
.extern wayland_main
.extern linux_write_all
.extern linux_exit
.global _start
.type _start, @function
_start:
    # Preserve envp for the freestanding backend: envp = &argv[argc + 1].
    mov rax, qword ptr [rsp]
    lea rdi, [rsp + rax*8 + 16]
    mov qword ptr [rip + process_envp], rdi

    cmp rax, 1
    je .start_wayland
    cmp rax, 2
    jne .unknown_argument

    mov rsi, qword ptr [rsp + 16]
    lea rdi, [rip + arg_help]
    call string_equal
    test eax, eax
    jnz .show_help

    mov rsi, qword ptr [rsp + 16]
    lea rdi, [rip + arg_version]
    call string_equal
    test eax, eax
    jnz .show_version

    mov rsi, qword ptr [rsp + 16]
    lea rdi, [rip + arg_backend_wayland]
    call string_equal
    test eax, eax
    jnz .start_wayland

    mov rsi, qword ptr [rsp + 16]
    lea rdi, [rip + arg_backend_x11]
    call string_equal
    test eax, eax
    jnz .x11_not_ready

    jmp .unknown_argument

.start_wayland:
    call wayland_main
    mov edi, 1
    jmp linux_exit

.show_help:
    mov edi, 1
    lea rsi, [rip + help_text]
    mov edx, help_text_end - help_text
    call linux_write_all
    xor edi, edi
    jmp linux_exit

.show_version:
    mov edi, 1
    lea rsi, [rip + version_text]
    mov edx, version_text_end - version_text
    call linux_write_all
    xor edi, edi
    jmp linux_exit

.x11_not_ready:
    mov edi, 2
    lea rsi, [rip + x11_todo_text]
    mov edx, x11_todo_text_end - x11_todo_text
    call linux_write_all
    mov edi, 69
    jmp linux_exit

.unknown_argument:
    mov edi, 2
    lea rsi, [rip + unknown_text]
    mov edx, unknown_text_end - unknown_text
    call linux_write_all
    mov edi, 64
    jmp linux_exit

.size _start, . - _start

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

.section .note.GNU-stack,"",@progbits
