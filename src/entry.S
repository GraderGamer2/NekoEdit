.intel_syntax noprefix

.section .rodata
arg_help:
    .asciz "--help"
arg_version:
    .asciz "--version"

help_text:
    .ascii "NekoEdit - a tiny native Linux text editor\n"
    .ascii "\n"
    .ascii "Usage: nekoedit [--help|--version]\n"
    .ascii "\n"
    .ascii "This repository is an early development scaffold.\n"
    .ascii "The graphical Wayland and X11 backends are not implemented yet.\n"
help_text_end:

version_text:
    .ascii "NekoEdit 0.0.1-dev\n"
version_text_end:

not_ready_text:
    .ascii "NekoEdit: this development build has no graphical backend yet.\n"
    .ascii "Run 'nekoedit --help' for information.\n"
not_ready_text_end:

unknown_text:
    .ascii "NekoEdit: unknown argument. Try 'nekoedit --help'.\n"
unknown_text_end:

.section .text
.global _start
.type _start, @function
_start:
    mov rax, qword ptr [rsp]
    cmp rax, 1
    je .no_arguments
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

    jmp .unknown_argument

.no_arguments:
    mov edi, 2
    lea rsi, [rip + not_ready_text]
    mov edx, not_ready_text_end - not_ready_text
    call linux_write_all
    mov edi, 2
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

.section .note.GNU-stack,"",@progbits
