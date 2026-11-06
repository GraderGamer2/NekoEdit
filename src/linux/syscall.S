.intel_syntax noprefix

.section .text
.global linux_write_all
.type linux_write_all, @function
# RDI = fd, RSI = buffer, RDX = byte count. EAX = 0 or negative errno.
linux_write_all:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.write_loop:
    test r13, r13
    jz .write_success
    mov eax, 1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    syscall
    test rax, rax
    jg .write_advance
    je .write_zero
    cmp rax, -4
    je .write_loop
    jmp .write_done
.write_advance:
    add r12, rax
    sub r13, rax
    jmp .write_loop
.write_zero:
    mov rax, -5
    jmp .write_done
.write_success:
    xor eax, eax
.write_done:
    pop r13
    pop r12
    pop rbx
    ret
.size linux_write_all, . - linux_write_all

.global linux_exit
.type linux_exit, @function
# EDI = exit status. Does not return.
linux_exit:
    mov eax, 60
    syscall
    ud2
.size linux_exit, . - linux_exit

.section .note.GNU-stack,"",@progbits
