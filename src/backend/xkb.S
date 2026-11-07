.intel_syntax noprefix

# Bounded, dependency-free reader for the common XKB text-v1 subset used by
# keyboard layouts. This intentionally handles compiled xkbcomp sections,
# keycodes, symbols[GroupN], and the common TWO_LEVEL/ALPHABETIC/FOUR_LEVEL
# type families. It is not a replacement for libxkbcommon: actions, virtual
# modifier resolution, compose/dead keys, and Unicode text input are outside
# this ASCII editor's current document model.

.section .rodata
.Lxkb_section_keycodes: .asciz "xkb_keycodes"
.Lxkb_section_symbols:  .asciz "xkb_symbols"
.Lxkb_word_key:         .asciz "key"
.Lxkb_word_type:        .asciz "type"
.Lxkb_word_symbols:     .asciz "symbols"
.Lxkb_type_one_level:    .asciz "ONE_LEVEL"
.Lxkb_type_alphabetic:  .asciz "ALPHABETIC"
.Lxkb_type_four_level:  .asciz "FOUR_LEVEL"
.Lxkb_type_eight_level: .asciz "EIGHT_LEVEL"
.Lxkb_type_three_level: .asciz "THREE_LEVEL"
.Lxkb_type_separate:    .asciz "SEPARATE_CAPS_AND_SHIFT_ALPHABETIC"

# Encoded as: one-byte name length, name bytes, one-byte ASCII value.
.Lxkb_ascii_symbols:
    .byte 5
    .ascii "comma"
    .byte 44
    .byte 6
    .ascii "period"
    .byte 46
    .byte 5
    .ascii "slash"
    .byte 47
    .byte 5
    .ascii "minus"
    .byte 45
    .byte 5
    .ascii "equal"
    .byte 61
    .byte 4
    .ascii "plus"
    .byte 43
    .byte 9
    .ascii "semicolon"
    .byte 59
    .byte 10
    .ascii "apostrophe"
    .byte 39
    .byte 5
    .ascii "grave"
    .byte 96
    .byte 9
    .ascii "backslash"
    .byte 92
    .byte 11
    .ascii "bracketleft"
    .byte 91
    .byte 12
    .ascii "bracketright"
    .byte 93
    .byte 9
    .ascii "braceleft"
    .byte 123
    .byte 10
    .ascii "braceright"
    .byte 125
    .byte 4
    .ascii "less"
    .byte 60
    .byte 7
    .ascii "greater"
    .byte 62
    .byte 8
    .ascii "question"
    .byte 63
    .byte 6
    .ascii "exclam"
    .byte 33
    .byte 2
    .ascii "at"
    .byte 64
    .byte 10
    .ascii "numbersign"
    .byte 35
    .byte 6
    .ascii "dollar"
    .byte 36
    .byte 7
    .ascii "percent"
    .byte 37
    .byte 11
    .ascii "asciicircum"
    .byte 94
    .byte 9
    .ascii "ampersand"
    .byte 38
    .byte 8
    .ascii "asterisk"
    .byte 42
    .byte 9
    .ascii "parenleft"
    .byte 40
    .byte 10
    .ascii "parenright"
    .byte 41
    .byte 10
    .ascii "underscore"
    .byte 95
    .byte 8
    .ascii "quotedbl"
    .byte 34
    .byte 5
    .ascii "colon"
    .byte 58
    .byte 3
    .ascii "bar"
    .byte 124
    .byte 10
    .ascii "asciitilde"
    .byte 126
    .byte 5
    .ascii "space"
    .byte 32
    .byte 0

.section .bss
.balign 16
.Lxkb_text_ptr:         .quad 0
.Lxkb_text_end:         .quad 0
.Lxkb_token_length:     .long 0
.Lxkb_token_kind:       .long 0
.Lxkb_depth:            .long 0
.Lxkb_keycode:          .long 0
.Lxkb_group:            .long 0
.Lxkb_level:            .long 0
.Lxkb_type_flags:       .long 0
.Lxkb_key_block_first:  .long 0
.Lxkb_symbol_count:     .long 0
.Lxkb_alpha_key_count:  .long 0
.Lxkb_number:           .long 0
.Lxkb_keyname_tmp:      .zero 4
.Lxkb_keyname_alias:    .zero 4
.Lxkb_token:            .zero 64
.balign 16
.global xkb_key_names
xkb_key_names:          .zero 1024        # 256 XKB keycodes, four-byte names
.global xkb_ascii_levels
xkb_ascii_levels:       .zero 16384       # 256 codes * 4 groups * 4 levels
.balign 16
.global xkb_unicode_levels
xkb_unicode_levels:     .zero 65536       # 256 codes * 4 groups * 4 levels, uint32 scalars
.global xkb_key_types
xkb_key_types:          .zero 256         # bit 0: alphabetic, bit 1: level-three
.global xkb_keymap_ready
xkb_keymap_ready:       .long 0

.section .text
.global xkb_reset_keymap
.type xkb_reset_keymap, @function
xkb_reset_keymap:
    push rdi
    push rcx
    xor eax, eax
    lea rdi, [rip + xkb_key_names]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_ascii_levels]
    mov ecx, 16384
    rep stosb
    lea rdi, [rip + xkb_unicode_levels]
    mov ecx, 65536
    rep stosb
    lea rdi, [rip + xkb_key_types]
    mov ecx, 256
    rep stosb
    mov dword ptr [rip + xkb_keymap_ready], 0
    mov dword ptr [rip + .Lxkb_key_block_first], 0
    mov dword ptr [rip + .Lxkb_symbol_count], 0
    mov dword ptr [rip + .Lxkb_alpha_key_count], 0
    pop rcx
    pop rdi
    ret
.size xkb_reset_keymap, . - xkb_reset_keymap

# Returns token kind in EAX: 0=end, 1=word/string, 2=<KEYNAME>, punctuation=ASCII.
# Token contents are copied to .Lxkb_token (truncated safely at 63 bytes).
.type .Lxkb_next_token, @function
.Lxkb_next_token:
    push rbx
    push r12
    push r13
    push r14
    push r15
    lea rdi, [rip + .Lxkb_token]
    xor eax, eax
    mov ecx, 64
    rep stosb
    mov dword ptr [rip + .Lxkb_token_length], 0
    mov dword ptr [rip + .Lxkb_token_kind], 0
.Lxkb_skip:
    mov rbx, qword ptr [rip + .Lxkb_text_ptr]
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_token_eof
    movzx eax, byte ptr [rbx]
    test eax, eax
    jz .Lxkb_token_eof
    cmp eax, 33
    jae .Lxkb_check_comment
    inc rbx
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip
.Lxkb_check_comment:
    cmp al, '#'
    je .Lxkb_skip_line_comment
    cmp al, '/'
    jne .Lxkb_begin_token
    lea r12, [rbx + 1]
    cmp r12, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_begin_token
    movzx eax, byte ptr [r12]
    cmp al, '/'
    je .Lxkb_skip_line_comment
    cmp al, '*'
    je .Lxkb_skip_block_comment
    jmp .Lxkb_begin_token
.Lxkb_skip_line_comment:
    mov rbx, qword ptr [rip + .Lxkb_text_ptr]
.Lxkb_line_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_line_done
    movzx eax, byte ptr [rbx]
    inc rbx
    cmp al, 10
    jne .Lxkb_line_loop
.Lxkb_line_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip
.Lxkb_skip_block_comment:
    add rbx, 2
.Lxkb_block_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_block_done
    movzx eax, byte ptr [rbx]
    cmp al, '*'
    jne .Lxkb_block_advance
    lea r12, [rbx + 1]
    cmp r12, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_block_advance
    cmp byte ptr [r12], '/'
    je .Lxkb_block_end
.Lxkb_block_advance:
    inc rbx
    jmp .Lxkb_block_loop
.Lxkb_block_end:
    add rbx, 2
.Lxkb_block_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip

.Lxkb_begin_token:
    mov r12, rbx
    movzx eax, byte ptr [rbx]
    cmp al, '<'
    je .Lxkb_collect_keyname
    cmp al, '"'
    je .Lxkb_collect_quote
    # XKB identifiers and numeric literals contain ASCII letters, digits,
    # and underscores. Hyphens are punctuation outside quoted strings.
    cmp al, 'A'
    jb .Lxkb_check_lower
    cmp al, 'Z'
    jbe .Lxkb_collect_word
.Lxkb_check_lower:
    cmp al, 'a'
    jb .Lxkb_check_digit
    cmp al, 'z'
    jbe .Lxkb_collect_word
.Lxkb_check_digit:
    cmp al, '0'
    jb .Lxkb_check_underscore
    cmp al, '9'
    jbe .Lxkb_collect_word
.Lxkb_check_underscore:
    cmp al, '_'
    je .Lxkb_collect_word
    # Single-character punctuation token.
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi], al
    mov dword ptr [rip + .Lxkb_token_length], 1
    mov dword ptr [rip + .Lxkb_token_kind], eax
    inc rbx
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, dword ptr [rip + .Lxkb_token_kind]
    jmp .Lxkb_token_done

.Lxkb_collect_word:
    mov dword ptr [rip + .Lxkb_token_kind], 1
.Lxkb_word_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_word_done
    movzx eax, byte ptr [rbx]
    cmp al, 'A'
    jb .Lxkb_word_lower
    cmp al, 'Z'
    jbe .Lxkb_word_copy
.Lxkb_word_lower:
    cmp al, 'a'
    jb .Lxkb_word_digit
    cmp al, 'z'
    jbe .Lxkb_word_copy
.Lxkb_word_digit:
    cmp al, '0'
    jb .Lxkb_word_underscore
    cmp al, '9'
    jbe .Lxkb_word_copy
.Lxkb_word_underscore:
    cmp al, '_'
    jne .Lxkb_word_done
.Lxkb_word_copy:
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_word_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_word_skip_copy:
    inc rbx
    jmp .Lxkb_word_loop
.Lxkb_word_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 1
    jmp .Lxkb_token_done

.Lxkb_collect_keyname:
    inc rbx
    mov dword ptr [rip + .Lxkb_token_kind], 2
.Lxkb_keyname_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_keyname_done
    movzx eax, byte ptr [rbx]
    cmp al, '>'
    je .Lxkb_keyname_end
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_keyname_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_keyname_skip_copy:
    inc rbx
    jmp .Lxkb_keyname_loop
.Lxkb_keyname_end:
    inc rbx
.Lxkb_keyname_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 2
    jmp .Lxkb_token_done

.Lxkb_collect_quote:
    inc rbx
    mov dword ptr [rip + .Lxkb_token_kind], 1
.Lxkb_quote_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_quote_done
    movzx eax, byte ptr [rbx]
    cmp al, '"'
    je .Lxkb_quote_end
    cmp al, '\\'
    jne .Lxkb_quote_copy
    # Escaped bytes are not needed for the supported type/symbol names.
    inc rbx
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_quote_done
    movzx eax, byte ptr [rbx]
.Lxkb_quote_copy:
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_quote_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_quote_skip_copy:
    inc rbx
    jmp .Lxkb_quote_loop
.Lxkb_quote_end:
    inc rbx
.Lxkb_quote_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 1
.Lxkb_token_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.Lxkb_token_eof:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    xor eax, eax
    jmp .Lxkb_token_done
.size .Lxkb_next_token, . - .Lxkb_next_token

# RDI points to a NUL-terminated expected token; EAX=1 for equality.
.type .Lxkb_token_is, @function
.Lxkb_token_is:
    push rbx
    push r12
    mov rbx, rdi
    lea r12, [rip + .Lxkb_token]
.Lxkb_token_cmp:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r12]
    jne .Lxkb_token_ne
    test al, al
    jz .Lxkb_token_eq
    inc rbx
    inc r12
    jmp .Lxkb_token_cmp
.Lxkb_token_eq:
    mov eax, 1
    jmp .Lxkb_token_cmp_done
.Lxkb_token_ne:
    xor eax, eax
.Lxkb_token_cmp_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_token_is, . - .Lxkb_token_is

# Convert current decimal token to EAX; EDX=1 if valid, else EDX=0.
.type .Lxkb_parse_decimal, @function
.Lxkb_parse_decimal:
    push rbx
    push r12
    lea rbx, [rip + .Lxkb_token]
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    test ecx, ecx
    jz .Lxkb_decimal_bad
    xor eax, eax
    xor r12d, r12d
.Lxkb_decimal_loop:
    movzx edx, byte ptr [rbx + r12]
    cmp dl, '0'
    jb .Lxkb_decimal_bad
    cmp dl, '9'
    ja .Lxkb_decimal_bad
    imul eax, eax, 10
    sub edx, '0'
    add eax, edx
    cmp eax, 65535
    ja .Lxkb_decimal_bad
    inc r12d
    cmp r12d, ecx
    jb .Lxkb_decimal_loop
    mov edx, 1
    jmp .Lxkb_decimal_done
.Lxkb_decimal_bad:
    xor eax, eax
    xor edx, edx
.Lxkb_decimal_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_decimal, . - .Lxkb_parse_decimal

# Current token is Group1..Group4; EAX=zero-based group or -1.
.type .Lxkb_parse_group, @function
.Lxkb_parse_group:
    push rbx
    cmp dword ptr [rip + .Lxkb_token_length], 6
    jb .Lxkb_group_bad
    lea rbx, [rip + .Lxkb_token]
    cmp dword ptr [rbx], 0x756f7247   # "Grou"
    jne .Lxkb_group_bad
    cmp byte ptr [rbx + 4], 'p'
    jne .Lxkb_group_bad
    movzx eax, byte ptr [rbx + 5]
    cmp al, '1'
    jb .Lxkb_group_bad
    cmp al, '4'
    ja .Lxkb_group_bad
    sub eax, '1'
    jmp .Lxkb_group_done
.Lxkb_group_bad:
    mov eax, -1
.Lxkb_group_done:
    pop rbx
    ret
.size .Lxkb_parse_group, . - .Lxkb_parse_group

# Search xkb_key_names for the four-byte .Lxkb_keyname_tmp; EAX=keycode or 0.
.type .Lxkb_find_keycode, @function
.Lxkb_find_keycode:
    push rbx
    push r12
    mov r12d, 8
.Lxkb_find_keycode_loop:
    cmp r12d, 256
    jae .Lxkb_find_keycode_missing
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rbx]
    cmp eax, dword ptr [rip + .Lxkb_keyname_tmp]
    je .Lxkb_find_keycode_found
    inc r12d
    jmp .Lxkb_find_keycode_loop
.Lxkb_find_keycode_found:
    mov eax, r12d
    jmp .Lxkb_find_keycode_done
.Lxkb_find_keycode_missing:
    xor eax, eax
.Lxkb_find_keycode_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_find_keycode, . - .Lxkb_find_keycode

# Parse xkb_keycodes entries of the form <NAME> = decimal;.
.type .Lxkb_parse_keycodes, @function
.Lxkb_parse_keycodes:
    push rbx
    push r12
    push r13
    push r14
    push r15
.Lxkb_find_keycodes_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    lea rdi, [rip + .Lxkb_section_keycodes]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_find_keycodes_section
.Lxkb_find_keycodes_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    cmp eax, '{'
    jne .Lxkb_find_keycodes_open
    mov dword ptr [rip + .Lxkb_depth], 1
.Lxkb_keycodes_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    cmp eax, '{'
    je .Lxkb_keycodes_nested_open
    cmp eax, '}'
    je .Lxkb_keycodes_close
    cmp eax, 2
    jne .Lxkb_keycodes_loop
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_keycodes_loop
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 2
    je .Lxkb_keycodes_alias
    call .Lxkb_parse_decimal
    test edx, edx
    jz .Lxkb_keycodes_loop
    cmp eax, 8
    jb .Lxkb_keycodes_loop
    cmp eax, 255
    ja .Lxkb_keycodes_loop
    mov r12d, eax
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    mov dword ptr [rbx], eax
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_alias:
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_alias], eax
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    push rax
    mov eax, dword ptr [rip + .Lxkb_keyname_alias]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_find_keycode
    mov r12d, eax
    pop rax
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    test r12d, r12d
    jz .Lxkb_keycodes_loop
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    mov dword ptr [rbx], eax
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_nested_open:
    inc dword ptr [rip + .Lxkb_depth]
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_close:
    dec dword ptr [rip + .Lxkb_depth]
    jnz .Lxkb_keycodes_loop
    xor eax, eax
    jmp .Lxkb_keycodes_done
.Lxkb_keycodes_fail:
    mov eax, -1
.Lxkb_keycodes_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_keycodes, . - .Lxkb_parse_keycodes

# Return type flags for the current type token in EAX.
# Search the current token for a case-sensitive NUL-terminated substring.
# RDI=needle; EAX=1 when found.
.type .Lxkb_token_contains, @function
.Lxkb_token_contains:
    push rbx
    push r12
    push r13
    mov r12, rdi
    lea rbx, [rip + .Lxkb_token]
.Lxkb_contains_outer:
    mov al, byte ptr [rbx]
    test al, al
    jz .Lxkb_contains_no
    mov r13, rbx
    mov rdi, r12
.Lxkb_contains_inner:
    mov dl, byte ptr [rdi]
    test dl, dl
    jz .Lxkb_contains_yes
    cmp dl, byte ptr [r13]
    jne .Lxkb_contains_next
    inc rdi
    inc r13
    jmp .Lxkb_contains_inner
.Lxkb_contains_next:
    inc rbx
    jmp .Lxkb_contains_outer
.Lxkb_contains_yes:
    mov eax, 1
    jmp .Lxkb_contains_done
.Lxkb_contains_no:
    xor eax, eax
.Lxkb_contains_done:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_token_contains, . - .Lxkb_token_contains

.type .Lxkb_classify_type, @function
.Lxkb_classify_type:
    push rbx
    xor ebx, ebx
    # ONE_LEVEL key types ignore Shift, Lock, and LevelThree. Keep this
    # distinction instead of treating every non-alphabetic type as TWO_LEVEL.
    lea rdi, [rip + .Lxkb_type_one_level]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_type_check_alpha
    mov ebx, 4
    jmp .Lxkb_type_done
.Lxkb_type_check_alpha:
    lea rdi, [rip + .Lxkb_type_alphabetic]
    call .Lxkb_token_contains
    test eax, eax
    jz .Lxkb_type_check_level3
    or ebx, 1
.Lxkb_type_check_level3:
    lea rdi, [rip + .Lxkb_type_four_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_eight_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_three_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_separate]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_type_done
.Lxkb_type_level3:
    or ebx, 2
.Lxkb_type_done:
    mov eax, ebx
    pop rbx
    ret
.size .Lxkb_classify_type, . - .Lxkb_classify_type

# Convert current keysym token to printable ASCII in EAX, otherwise zero.
.type .Lxkb_keysym_ascii, @function
.Lxkb_keysym_ascii:
    push rbx
    push r12
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 1
    jne .Lxkb_keysym_named
    lea rbx, [rip + .Lxkb_token]
    movzx eax, byte ptr [rbx]
    cmp eax, 32
    jb .Lxkb_keysym_none
    cmp eax, 126
    ja .Lxkb_keysym_none
    jmp .Lxkb_keysym_done
.Lxkb_keysym_named:
    lea rbx, [rip + .Lxkb_ascii_symbols]
.Lxkb_ascii_table_loop:
    movzx ecx, byte ptr [rbx]
    test ecx, ecx
    jz .Lxkb_keysym_none
    mov r12d, ecx                # Preserve the table record length on every path.
    cmp ecx, dword ptr [rip + .Lxkb_token_length]
    jne .Lxkb_ascii_table_next
    lea rsi, [rbx + 1]
    lea rdi, [rip + .Lxkb_token]
    mov edx, ecx
    repe cmpsb
    je .Lxkb_ascii_table_found
.Lxkb_ascii_table_next:
    # REP CMPSB consumes RCX on a partial match; never use it to step records.
    lea rbx, [rbx + r12 + 2]
    jmp .Lxkb_ascii_table_loop
.Lxkb_ascii_table_found:
    movzx eax, byte ptr [rbx + r12 + 1]
    jmp .Lxkb_keysym_done
.Lxkb_keysym_none:
    xor eax, eax
.Lxkb_keysym_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_keysym_ascii, . - .Lxkb_keysym_ascii

# Convert a printable ASCII or XKB Unicode keysym token to a Unicode scalar.
# XKB's Uxxxx/Uxxxxx/Uxxxxxx forms are accepted; invalid scalars return zero.
.type .Lxkb_keysym_unicode, @function
.Lxkb_keysym_unicode:
    push rbx
    push r12
    push r13
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 5
    jb .Lxkb_unicode_ascii
    cmp ecx, 7
    ja .Lxkb_unicode_ascii
    lea rbx, [rip + .Lxkb_token]
    cmp byte ptr [rbx], 'U'
    jne .Lxkb_unicode_ascii
    inc rbx
    lea r13d, [rcx - 1]
    xor r12d, r12d
.Lxkb_unicode_hex_loop:
    movzx eax, byte ptr [rbx]
    cmp al, '0'
    jb .Lxkb_unicode_hex_lower
    cmp al, '9'
    jbe .Lxkb_unicode_hex_digit
.Lxkb_unicode_hex_lower:
    cmp al, 'a'
    jb .Lxkb_unicode_hex_upper
    cmp al, 'f'
    jbe .Lxkb_unicode_hex_alpha
.Lxkb_unicode_hex_upper:
    cmp al, 'A'
    jb .Lxkb_unicode_invalid
    cmp al, 'F'
    ja .Lxkb_unicode_invalid
    sub eax, 'A' - 10
    jmp .Lxkb_unicode_hex_accumulate
.Lxkb_unicode_hex_alpha:
    sub eax, 'a' - 10
    jmp .Lxkb_unicode_hex_accumulate
.Lxkb_unicode_hex_digit:
    sub eax, '0'
.Lxkb_unicode_hex_accumulate:
    shl r12d, 4
    add r12d, eax
    inc rbx
    dec r13d
    jnz .Lxkb_unicode_hex_loop
    cmp r12d, 0x10ffff
    ja .Lxkb_unicode_invalid
    cmp r12d, 0x20
    jb .Lxkb_unicode_invalid
    cmp r12d, 0x7f
    jb .Lxkb_unicode_valid
    cmp r12d, 0x9f
    jbe .Lxkb_unicode_invalid
    cmp r12d, 0xd800
    jb .Lxkb_unicode_valid
    cmp r12d, 0xdfff
    jbe .Lxkb_unicode_invalid
.Lxkb_unicode_valid:
    mov eax, r12d
    jmp .Lxkb_unicode_done
.Lxkb_unicode_ascii:
    call .Lxkb_keysym_ascii
    jmp .Lxkb_unicode_done
.Lxkb_unicode_invalid:
    xor eax, eax
.Lxkb_unicode_done:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_keysym_unicode, . - .Lxkb_keysym_unicode

# Parse the symbols array following symbols[GroupN] = [ ... ].
.type .Lxkb_parse_symbol_array, @function
.Lxkb_parse_symbol_array:
    push rbx
    push r12
    push r13
    push r14
    # Caller has just consumed "symbols".
    mov dword ptr [rip + .Lxkb_group], 0
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_symbol_array_expect_equals
    call .Lxkb_next_token
    call .Lxkb_parse_group
    test eax, eax
    js .Lxkb_symbol_array_group_default
    mov dword ptr [rip + .Lxkb_group], eax
.Lxkb_symbol_array_group_default:
    call .Lxkb_next_token
    cmp eax, ']'
    jne .Lxkb_symbol_array_fail
    call .Lxkb_next_token
.Lxkb_symbol_array_expect_equals:
    cmp eax, '='
    jne .Lxkb_symbol_array_fail
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_symbol_array_fail
    mov dword ptr [rip + .Lxkb_level], 0
.Lxkb_symbol_array_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbol_array_fail
    cmp eax, ']'
    je .Lxkb_symbol_array_success
    cmp eax, ','
    je .Lxkb_symbol_array_loop
    call .Lxkb_keysym_unicode
    mov r12d, eax
    mov eax, dword ptr [rip + .Lxkb_level]
    cmp eax, 4
    jae .Lxkb_symbol_array_advance
    mov r13d, dword ptr [rip + .Lxkb_keycode]
    mov r14d, dword ptr [rip + .Lxkb_group]
    shl r13d, 4
    lea eax, [r13d + r14d*4]
    add eax, dword ptr [rip + .Lxkb_level]
    lea rbx, [rip + xkb_unicode_levels]
    mov dword ptr [rbx + rax*4], r12d
    # Keep the legacy byte table for existing ASCII layout heuristics and
    # callers; non-ASCII symbols are retained in the parallel scalar table.
    lea rbx, [rip + xkb_ascii_levels]
    add rbx, r13
    lea rbx, [rbx + r14*4]
    mov eax, dword ptr [rip + .Lxkb_level]
    cmp r12d, 0x7e
    ja .Lxkb_symbol_array_ascii_done
    mov byte ptr [rbx + rax], r12b
.Lxkb_symbol_array_ascii_done:
    test r12d, r12d
    jz .Lxkb_symbol_array_advance
    inc dword ptr [rip + .Lxkb_symbol_count]
.Lxkb_symbol_array_advance:
    inc dword ptr [rip + .Lxkb_level]
    jmp .Lxkb_symbol_array_loop
.Lxkb_symbol_array_success:
    xor eax, eax
    jmp .Lxkb_symbol_array_done
.Lxkb_symbol_array_fail:
    mov eax, -1
.Lxkb_symbol_array_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_symbol_array, . - .Lxkb_parse_symbol_array

# Parse the shorthand XKB form: key <NAME> { [ symbol, shifted_symbol ] }.
# The opening '[' has already been consumed. Reuse the same bounded symbol
# array parser with Group1 and level zero as the starting position.
.type .Lxkb_parse_inline_symbol_array, @function
.Lxkb_parse_inline_symbol_array:
    push rbx
    push r12
    push r13
    push r14
    mov dword ptr [rip + .Lxkb_group], 0
    mov dword ptr [rip + .Lxkb_level], 0
    jmp .Lxkb_symbol_array_loop
.size .Lxkb_parse_inline_symbol_array, . - .Lxkb_parse_inline_symbol_array

# Parse attributes inside one key <NAME> { ... } block.
.type .Lxkb_parse_key_block, @function
.Lxkb_parse_key_block:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov dword ptr [rip + .Lxkb_key_block_first], 1
.Lxkb_key_block_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_key_block_fail
    cmp eax, '}'
    je .Lxkb_key_block_done
    # xkbcomp emits common two-level keys in shorthand form:
    # key <AE01> { [ 1, exclam ] };. Only treat '[' as symbols when it is
    # the first token in the key block; later arrays may describe actions.
    cmp dword ptr [rip + .Lxkb_key_block_first], 1
    jne .Lxkb_key_block_not_first
    mov dword ptr [rip + .Lxkb_key_block_first], 0
    cmp eax, '['
    je .Lxkb_key_block_inline_symbols
.Lxkb_key_block_not_first:
    lea rdi, [rip + .Lxkb_word_type]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_type
    lea rdi, [rip + .Lxkb_word_symbols]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_symbols
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_type:
.Lxkb_key_block_type_seek_equals:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_key_block_fail
    cmp eax, '='
    jne .Lxkb_key_block_type_seek_equals
    call .Lxkb_next_token
    call .Lxkb_classify_type
    mov dword ptr [rip + .Lxkb_type_flags], eax
    mov eax, dword ptr [rip + .Lxkb_keycode]
    lea rbx, [rip + xkb_key_types]
    mov ecx, dword ptr [rip + .Lxkb_type_flags]
    mov byte ptr [rbx + rax], cl
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_symbols:
    call .Lxkb_parse_symbol_array
    test eax, eax
    js .Lxkb_key_block_fail
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_inline_symbols:
    call .Lxkb_parse_inline_symbol_array
    test eax, eax
    js .Lxkb_key_block_fail
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_done:
    # If the key has no explicit type, infer the common alphabetic two-level
    # case from [lowercase, uppercase]. Other unspecified keys use Shift.
    mov r15d, dword ptr [rip + .Lxkb_keycode]
    lea rbx, [rip + xkb_key_types]
    cmp byte ptr [rbx + r15], 0
    jne .Lxkb_key_block_success
    lea rbx, [rip + xkb_ascii_levels]
    mov eax, r15d
    shl eax, 4
    lea rbx, [rbx + rax]
    movzx eax, byte ptr [rbx]
    cmp al, 'a'
    jb .Lxkb_key_block_success
    cmp al, 'z'
    ja .Lxkb_key_block_success
    movzx edx, byte ptr [rbx + 1]
    cmp edx, eax
    je .Lxkb_key_block_success
    sub eax, 'a'
    sub edx, 'A'
    cmp eax, edx
    jne .Lxkb_key_block_success
    lea rbx, [rip + xkb_key_types]
    mov byte ptr [rbx + r15], 1
.Lxkb_key_block_success:
    # Count real Group1 ASCII alphabetic keys. A sparse or malformed parse
    # must not disable the working US fallback just because punctuation was
    # understood successfully.
    lea rbx, [rip + xkb_key_types]
    test byte ptr [rbx + r15], 1
    jz .Lxkb_key_block_return
    lea rbx, [rip + xkb_ascii_levels]
    mov eax, r15d
    shl eax, 4
    cmp byte ptr [rbx + rax], 0
    je .Lxkb_key_block_return
    inc dword ptr [rip + .Lxkb_alpha_key_count]
.Lxkb_key_block_return:
    xor eax, eax
    jmp .Lxkb_key_block_exit
.Lxkb_key_block_fail:
    mov eax, -1
.Lxkb_key_block_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_key_block, . - .Lxkb_parse_key_block

# Parse xkb_symbols key definitions.
.type .Lxkb_parse_symbols, @function
.Lxkb_parse_symbols:
    push rbx
    push r12
    push r13
    push r14
    push r15
.Lxkb_find_symbols_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    lea rdi, [rip + .Lxkb_section_symbols]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_find_symbols_section
.Lxkb_find_symbols_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_find_symbols_open
.Lxkb_symbols_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '}'
    je .Lxkb_symbols_done
    lea rdi, [rip + .Lxkb_word_key]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_symbols_loop
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 2
    jne .Lxkb_symbols_loop
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_find_keycode
    test eax, eax
    jz .Lxkb_symbols_skip_key
    mov dword ptr [rip + .Lxkb_keycode], eax
.Lxkb_symbols_find_key_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_symbols_find_key_open
    call .Lxkb_parse_key_block
    test eax, eax
    js .Lxkb_symbols_fail
    jmp .Lxkb_symbols_loop
.Lxkb_symbols_skip_key:
    # Unknown key name: consume through the next closing brace without
    # modifying any valid entry.
.Lxkb_symbols_skip_key_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_symbols_skip_key_open
.Lxkb_symbols_skip_key_body:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '}'
    jne .Lxkb_symbols_skip_key_body
    jmp .Lxkb_symbols_loop
.Lxkb_symbols_done:
    # Do not activate a partially understood map (for example one isolated
    # punctuation key). Require a reasonable ASCII symbol population; normal
    # desktop layouts contain many more entries than this minimum.
    cmp dword ptr [rip + .Lxkb_symbol_count], 16
    jb .Lxkb_symbols_fail
    cmp dword ptr [rip + .Lxkb_alpha_key_count], 12
    jb .Lxkb_symbols_fail
    mov dword ptr [rip + xkb_keymap_ready], 1
    xor eax, eax
    jmp .Lxkb_symbols_exit
.Lxkb_symbols_fail:
    mov eax, -1
.Lxkb_symbols_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_symbols, . - .Lxkb_parse_symbols

# RDI=text, ESI=size. Returns zero when at least one keycode/symbol pair is
# usable, otherwise negative. Invalid/unsupported maps leave the fallback live.
.global xkb_parse_keymap
.type xkb_parse_keymap, @function
xkb_parse_keymap:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13d, esi
    call xkb_reset_keymap
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    lea rax, [r12 + r13]
    mov qword ptr [rip + .Lxkb_text_end], rax
    call .Lxkb_parse_keycodes
    test eax, eax
    js .Lxkb_parse_keymap_fail
    # Start section search from the current token cursor.
    call .Lxkb_parse_symbols
    test eax, eax
    js .Lxkb_parse_keymap_fail
    xor eax, eax
    jmp .Lxkb_parse_keymap_done
.Lxkb_parse_keymap_fail:
    call xkb_reset_keymap
    mov rax, -1
.Lxkb_parse_keymap_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_parse_keymap, . - xkb_parse_keymap

# RDI=evdev keycode, ESI=Shift, EDX=Caps, ECX=LevelThree, R8D=group.
# Returns an ASCII byte or zero. Wayland keycodes need the XKB +8 offset.
.global xkb_lookup_ascii
.type xkb_lookup_ascii, @function
xkb_lookup_ascii:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_lookup_none
    cmp edi, 247
    ja .Lxkb_lookup_none
    lea r12d, [rdi + 8]
    mov r13d, esi
    mov r14d, edx
    mov r15d, ecx
    mov ebx, r8d
    cmp ebx, 3
    jbe .Lxkb_group_in_range
    xor ebx, ebx
.Lxkb_group_in_range:
    lea rax, [rip + xkb_key_types]
    movzx eax, byte ptr [rax + r12]
    # ONE_LEVEL has no modifier-selected alternatives. Do not try to read
    # Level 2 when Shift or Caps Lock is active on a one-symbol key.
    test eax, 4
    jnz .Lxkb_level_one
    test eax, 1
    jz .Lxkb_caps_done
    xor r13d, r14d
.Lxkb_caps_done:
    and r13d, 1
    test eax, 2
    jz .Lxkb_level_done
    test r15d, r15d
    jz .Lxkb_level_done
    add r13d, 2
    jmp .Lxkb_level_ready
.Lxkb_level_one:
    xor r13d, r13d
.Lxkb_level_done:
.Lxkb_level_ready:
    mov eax, r12d
    shl eax, 4
    lea rdx, [rip + xkb_ascii_levels]
    lea rdx, [rdx + rax]
    lea rdx, [rdx + rbx*4]
    movzx eax, byte ptr [rdx + r13]
    test eax, eax
    jnz .Lxkb_lookup_done
    # If the compositor reports a group with no symbols for this key, retry
    # group one rather than injecting a US-QWERTY character for that key.
    test ebx, ebx
    jz .Lxkb_lookup_done
    lea rdx, [rip + xkb_ascii_levels]
    mov eax, r12d
    shl eax, 4
    add rdx, rax
    movzx eax, byte ptr [rdx + r13]
    jmp .Lxkb_lookup_done
.Lxkb_lookup_none:
    xor eax, eax
.Lxkb_lookup_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_lookup_ascii, . - xkb_lookup_ascii

# RDI=evdev keycode, ESI=Shift, EDX=Caps, ECX=LevelThree, R8D=group.
# Returns an XKB Unicode keysym scalar or zero.
.global xkb_lookup_unicode
.type xkb_lookup_unicode, @function
xkb_lookup_unicode:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_unicode_lookup_none
    cmp edi, 247
    ja .Lxkb_unicode_lookup_none
    lea r12d, [rdi + 8]
    mov r13d, esi
    mov r14d, edx
    mov r15d, ecx
    mov ebx, r8d
    cmp ebx, 3
    jbe .Lxkb_unicode_group_ready
    xor ebx, ebx
.Lxkb_unicode_group_ready:
    lea rax, [rip + xkb_key_types]
    movzx eax, byte ptr [rax + r12]
    test eax, 4
    jnz .Lxkb_unicode_level_one
    test eax, 1
    jz .Lxkb_unicode_caps_done
    xor r13d, r14d
.Lxkb_unicode_caps_done:
    and r13d, 1
    test eax, 2
    jz .Lxkb_unicode_level_done
    test r15d, r15d
    jz .Lxkb_unicode_level_done
    add r13d, 2
    jmp .Lxkb_unicode_level_ready
.Lxkb_unicode_level_one:
    xor r13d, r13d
.Lxkb_unicode_level_done:
.Lxkb_unicode_level_ready:
    mov eax, r12d
    shl eax, 4
    add eax, ebx
    lea rdx, [rip + xkb_unicode_levels]
    lea rdx, [rdx + rax*4]
    movzx eax, r13d
    mov eax, dword ptr [rdx + rax*4]
    test eax, eax
    jnz .Lxkb_unicode_lookup_done
    # Preserve the same Group1 retry used by the ASCII lookup path.
    test ebx, ebx
    jz .Lxkb_unicode_lookup_done
    mov eax, r12d
    shl eax, 4
    lea rdx, [rip + xkb_unicode_levels]
    add rdx, rax
    movzx eax, r13d
    mov eax, dword ptr [rdx + rax*4]
    jmp .Lxkb_unicode_lookup_done
.Lxkb_unicode_lookup_none:
    xor eax, eax
.Lxkb_unicode_lookup_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_lookup_unicode, . - xkb_lookup_unicode

.section .note.GNU-stack,"",@progbits
