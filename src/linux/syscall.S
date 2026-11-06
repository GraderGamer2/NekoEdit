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
    mov eax, 1                  # __NR_write
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    syscall
    test rax, rax
    jg .write_advance
    je .write_zero
    cmp rax, -4                 # EINTR
    je .write_loop
    jmp .write_done
.write_advance:
    add r12, rax
    sub r13, rax
    jmp .write_loop
.write_zero:
    mov rax, -5                 # EIO
    jmp .write_done
.write_success:
    xor eax, eax
.write_done:
    pop r13
    pop r12
    pop rbx
    ret
.size linux_write_all, . - linux_write_all

.global linux_read_exact
.type linux_read_exact, @function
# RDI = fd, RSI = buffer, RDX = byte count. EAX = 0 or negative errno.
linux_read_exact:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.read_loop:
    test r13, r13
    jz .read_success
    xor eax, eax                # __NR_read
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    syscall
    test rax, rax
    jg .read_advance
    je .read_eof
    cmp rax, -4                 # EINTR
    je .read_loop
    jmp .read_done
.read_advance:
    add r12, rax
    sub r13, rax
    jmp .read_loop
.read_eof:
    mov rax, -5                 # EIO / unexpected EOF
    jmp .read_done
.read_success:
    xor eax, eax
.read_done:
    pop r13
    pop r12
    pop rbx
    ret
.size linux_read_exact, . - linux_read_exact

.global linux_exit
.type linux_exit, @function
# EDI = exit status. Does not return.
linux_exit:
    mov eax, 60                 # __NR_exit
    syscall
    ud2
.size linux_exit, . - linux_exit

.section .note.GNU-stack,"",@progbits
