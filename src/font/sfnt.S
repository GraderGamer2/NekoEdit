.intel_syntax noprefix

# Bounded, dependency-free reader for single-face TrueType-outline SFNT files.
# The glyph rasterizer is a later layer; this module owns discovery, mapping,
# table validation, cmap lookup and horizontal metrics only.

.equ FONT_SYS_openat, 257
.equ FONT_SYS_close, 3
.equ FONT_SYS_lseek, 8
.equ FONT_SYS_mmap, 9
.equ FONT_SYS_munmap, 11
.equ FONT_AT_FDCWD, -100
.equ FONT_PROT_READ, 1
.equ FONT_MAP_PRIVATE, 2
.equ FONT_MAX_FILE_SIZE, 67108864
.equ FONT_MAX_TABLES, 256
.equ FONT_MAX_CMAP_RECORDS, 128
.equ FONT_MAX_CMAP_GROUPS, 65536

# Four-byte table tags expressed as their little-endian in-memory integers.
.equ FONT_TAG_CMAP, 0x70616d63
.equ FONT_TAG_GLYF, 0x66796c67
.equ FONT_TAG_HEAD, 0x64616568
.equ FONT_TAG_HHEA, 0x61656868
.equ FONT_TAG_HMTX, 0x78746d68
.equ FONT_TAG_LOCA, 0x61636f6c
.equ FONT_TAG_MAXP, 0x7078616d

.section .rodata
.balign 4
font_env_key:
    .ascii "NEKOEDIT_FONT"
font_env_key_end:
font_default_candidates:
    .quad font_path_dejavu_mono
    .quad font_path_liberation_mono
    .quad font_path_dejavu_sans
    .quad 0
font_path_dejavu_mono:
    .asciz "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
font_path_liberation_mono:
    .asciz "/usr/share/fonts/truetype/liberation2/LiberationMono-Regular.ttf"
font_path_dejavu_sans:
    .asciz "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

.section .bss
.balign 8
.global font_loaded, font_file_map, font_file_size
.global font_num_tables, font_units_per_em, font_num_glyphs
.global font_ascent, font_descent, font_num_hmetrics, font_index_to_loc_format
.global font_cmap_format, font_cmap_subtable_offset, font_cmap_subtable_length
.global font_head_offset, font_hhea_offset, font_maxp_offset
.global font_cmap_offset, font_cmap_length, font_hmtx_offset, font_hmtx_length
.global font_glyf_offset, font_glyf_length, font_loca_offset, font_loca_length
.global font_probe_A_glyph, font_probe_A_advance
font_loaded:                    .long 0
font_num_tables:                .long 0
font_units_per_em:              .long 0
font_num_glyphs:                .long 0
font_ascent:                    .long 0
font_descent:                   .long 0
font_num_hmetrics:              .long 0
font_index_to_loc_format:       .long 0
font_cmap_format:               .long 0
font_head_offset:               .long 0
font_hhea_offset:               .long 0
font_maxp_offset:               .long 0
font_cmap_offset:               .long 0
font_cmap_length:               .long 0
font_cmap_subtable_offset:      .long 0
font_cmap_subtable_length:      .long 0
font_hmtx_offset:               .long 0
font_hmtx_length:               .long 0
font_glyf_offset:               .long 0
font_glyf_length:               .long 0
font_loca_offset:               .long 0
font_loca_length:               .long 0
font_probe_A_glyph:             .long 0
font_probe_A_advance:           .long 0
.balign 8
font_file_map:                  .quad 0
font_file_size:                 .quad 0


# Temporary one-byte startup trace for SFNT parser isolation.
.section .bss
.balign 1
font_debug_byte: .byte 0
.section .text
.type font_debug_mark, @function
font_debug_mark:
    mov byte ptr [rip + font_debug_byte], dil
    mov eax, 1
    mov edi, 2
    lea rsi, [rip + font_debug_byte]
    mov edx, 1
    syscall
    ret
.size font_debug_mark, . - font_debug_mark

.section .text
.extern process_envp

# Read an unsigned big-endian 16-bit integer. RDI points at two validated bytes.
.type font_be16, @function
font_be16:
    movzx eax, word ptr [rdi]
    rol ax, 8
    ret
.size font_be16, . - font_be16

# Read an unsigned big-endian 32-bit integer. RDI points at four validated bytes.
.type font_be32, @function
font_be32:
    mov eax, dword ptr [rdi]
    bswap eax
    ret
.size font_be32, . - font_be32

# Find a top-level table by its four-byte little-endian tag.
# EDI=tag; returns EAX=file offset, EDX=length, CF=0; CF=1 if absent/invalid.
.type font_find_table, @function
font_find_table:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov ebx, edi
    mov r12, qword ptr [rip + font_file_map]
    add r12, 12
    mov r13d, dword ptr [rip + font_num_tables]
.Lfont_find_table_loop:
    test r13d, r13d
    jz .Lfont_find_table_missing
    cmp dword ptr [r12], ebx
    je .Lfont_find_table_found
    add r12, 16
    dec r13d
    jmp .Lfont_find_table_loop
.Lfont_find_table_found:
    lea rdi, [r12 + 8]
    call font_be32
    mov r14d, eax
    lea rdi, [r12 + 12]
    call font_be32
    mov edx, eax
    mov rax, qword ptr [rip + font_file_size]
    mov ecx, r14d
    cmp rcx, rax
    ja .Lfont_find_table_invalid
    sub rax, rcx
    cmp rdx, rax
    ja .Lfont_find_table_invalid
    mov eax, r14d
    clc
    jmp .Lfont_find_table_return
.Lfont_find_table_missing:
.Lfont_find_table_invalid:
    stc
.Lfont_find_table_return:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size font_find_table, . - font_find_table

# Validate cmap header and select a Unicode format 12 or 4 subtable.
# Uses the best available Unicode platform/encoding record; rejects unsafe lengths.
.type font_parse_cmap, @function
font_parse_cmap:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, qword ptr [rip + font_file_map]
    mov eax, dword ptr [rip + font_cmap_offset]
    add r12, rax
    mov r13d, dword ptr [rip + font_cmap_length]
    cmp r13d, 4
    jb .Lfont_cmap_failed
    mov rdi, r12
    call font_be16
    test eax, eax
    jnz .Lfont_cmap_failed
    lea rdi, [r12 + 2]
    call font_be16
    test eax, eax
    jz .Lfont_cmap_failed
    cmp eax, FONT_MAX_CMAP_RECORDS
    ja .Lfont_cmap_failed
    mov ebx, eax
    lea eax, [rbx * 8 + 4]
    cmp eax, r13d
    ja .Lfont_cmap_failed
    mov ebp, -1                 # best score
    xor r14d, r14d              # chosen format
    xor r15d, r15d              # chosen relative offset
    mov dword ptr [rsp], 0      # chosen subtable length
    lea r12, [r12 + 4]
.Lfont_cmap_record_loop:
    test ebx, ebx
    jz .Lfont_cmap_records_done
    mov rdi, r12
    call font_be16
    mov esi, eax                # platform
    lea rdi, [r12 + 2]
    call font_be16
    mov edx, eax                # encoding
    lea rdi, [r12 + 4]
    call font_be32
    mov ecx, eax                # relative subtable offset
    cmp ecx, r13d
    jae .Lfont_cmap_record_next
    mov eax, r13d
    sub eax, ecx
    cmp eax, 2
    jb .Lfont_cmap_record_next
    mov r8, qword ptr [rip + font_file_map]
    add r8, qword ptr [rip + font_cmap_offset]
    add r8, rcx
    mov rdi, r8
    call font_be16
    mov r9d, eax                # format
    xor r10d, r10d              # score
    cmp r9d, 12
    je .Lfont_cmap_score_format12
    cmp r9d, 4
    jne .Lfont_cmap_record_next
    cmp esi, 3
    je .Lfont_cmap_score_win_format4
    test esi, esi
    je .Lfont_cmap_score_unicode_format4
    jmp .Lfont_cmap_record_next
.Lfont_cmap_score_format12:
    cmp esi, 3
    jne .Lfont_cmap_score_unicode_format12
    cmp edx, 10
    jne .Lfont_cmap_record_next
    mov r10d, 100
    jmp .Lfont_cmap_score_ready
.Lfont_cmap_score_unicode_format12:
    test esi, esi
    jne .Lfont_cmap_record_next
    cmp edx, 4
    jne .Lfont_cmap_record_next
    mov r10d, 90
    jmp .Lfont_cmap_score_ready
.Lfont_cmap_score_win_format4:
    cmp edx, 1
    jne .Lfont_cmap_record_next
    mov r10d, 70
    jmp .Lfont_cmap_score_ready
.Lfont_cmap_score_unicode_format4:
    cmp edx, 3
    jne .Lfont_cmap_record_next
    mov r10d, 60
.Lfont_cmap_score_ready:
    cmp r10d, ebp
    jle .Lfont_cmap_record_next
    # Validate the selected subtable's complete declared length.
    cmp r9d, 4
    jne .Lfont_cmap_validate_format12
    mov rdi, r8
    add rdi, 2
    call font_be16
    mov r11d, eax
    cmp r11d, 16
    jb .Lfont_cmap_record_next
    mov eax, r13d
    sub eax, ecx
    cmp r11d, eax
    ja .Lfont_cmap_record_next
    mov rdi, r8
    add rdi, 6
    call font_be16
    test eax, 1
    jnz .Lfont_cmap_record_next
    test eax, eax
    jz .Lfont_cmap_record_next
    mov edx, eax
    shr edx, 1
    imul edx, 8
    add edx, 16
    cmp r11d, edx
    jb .Lfont_cmap_record_next
    jmp .Lfont_cmap_store
.Lfont_cmap_validate_format12:
    mov rdi, r8
    add rdi, 4
    call font_be32
    mov r11d, eax
    cmp r11d, 16
    jb .Lfont_cmap_record_next
    mov eax, r13d
    sub eax, ecx
    cmp r11d, eax
    ja .Lfont_cmap_record_next
    mov rdi, r8
    add rdi, 12
    call font_be32
    cmp eax, FONT_MAX_CMAP_GROUPS
    ja .Lfont_cmap_record_next
    imul eax, 12
    add eax, 16
    cmp r11d, eax
    jb .Lfont_cmap_record_next
.Lfont_cmap_store:
    mov ebp, r10d
    mov r14d, r9d
    mov r15d, ecx
    mov dword ptr [rsp], r11d
.Lfont_cmap_record_next:
    add r12, 8
    dec ebx
    jmp .Lfont_cmap_record_loop
.Lfont_cmap_records_done:
    cmp r14d, 4
    je .Lfont_cmap_selected
    cmp r14d, 12
    jne .Lfont_cmap_failed
.Lfont_cmap_selected:
    mov dword ptr [rip + font_cmap_format], r14d
    mov eax, dword ptr [rip + font_cmap_offset]
    add eax, r15d
    mov dword ptr [rip + font_cmap_subtable_offset], eax
    mov eax, dword ptr [rsp]
    mov dword ptr [rip + font_cmap_subtable_length], eax
    xor eax, eax
    jmp .Lfont_cmap_return
.Lfont_cmap_failed:
    mov rax, -1
.Lfont_cmap_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size font_parse_cmap, . - font_parse_cmap

# Validate the core TrueType table directory and metadata.
# Returns EAX=0 on success, -1 on malformed/unsupported input.
.type font_parse_mapped, @function
font_parse_mapped:
    mov edi, '1'
    call font_debug_mark
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, qword ptr [rip + font_file_map]
    mov rdi, r12
    call font_be32
    cmp eax, 0x00010000       # TrueType outlines only; CFF/collections deferred.
    jne .Lfont_parse_failed
    lea rdi, [r12 + 4]
    call font_be16
    test eax, eax
    jz .Lfont_parse_failed
    cmp eax, FONT_MAX_TABLES
    ja .Lfont_parse_failed
    mov dword ptr [rip + font_num_tables], eax
    mov edi, '2'
    call font_debug_mark
    shl eax, 4
    add eax, 12
    cmp rax, qword ptr [rip + font_file_size]
    ja .Lfont_parse_failed

    mov edi, FONT_TAG_CMAP
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_cmap_offset], eax
    mov dword ptr [rip + font_cmap_length], edx

    mov edi, FONT_TAG_HEAD
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_head_offset], eax
    cmp edx, 54
    jb .Lfont_parse_failed

    mov edi, FONT_TAG_HHEA
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_hhea_offset], eax
    cmp edx, 36
    jb .Lfont_parse_failed

    mov edi, FONT_TAG_MAXP
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_maxp_offset], eax
    cmp edx, 6
    jb .Lfont_parse_failed

    mov edi, FONT_TAG_HMTX
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_hmtx_offset], eax
    mov dword ptr [rip + font_hmtx_length], edx

    mov edi, FONT_TAG_GLYF
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_glyf_offset], eax
    mov dword ptr [rip + font_glyf_length], edx

    mov edi, FONT_TAG_LOCA
    call font_find_table
    jc .Lfont_parse_failed
    mov dword ptr [rip + font_loca_offset], eax
    mov dword ptr [rip + font_loca_length], edx
    mov edi, '3'
    call font_debug_mark

    # head: magicNumber, unitsPerEm and indexToLocFormat.
    mov r12, qword ptr [rip + font_file_map]
    mov eax, dword ptr [rip + font_head_offset]
    add r12, rax
    lea rdi, [r12 + 12]
    call font_be32
    cmp eax, 0x5f0f3cf5
    jne .Lfont_parse_failed
    lea rdi, [r12 + 18]
    call font_be16
    cmp eax, 16
    jb .Lfont_parse_failed
    cmp eax, 16384
    ja .Lfont_parse_failed
    mov dword ptr [rip + font_units_per_em], eax
    lea rdi, [r12 + 50]
    call font_be16
    cmp eax, 0
    je .Lfont_loca_short_format
    cmp eax, 1
    jne .Lfont_parse_failed
    mov dword ptr [rip + font_index_to_loc_format], 1
    jmp .Lfont_loca_format_ready
.Lfont_loca_short_format:
    mov dword ptr [rip + font_index_to_loc_format], 0
.Lfont_loca_format_ready:

    # maxp: numGlyphs.
    mov rax, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_maxp_offset]
    add rax, rdx
    lea rdi, [rax + 4]
    call font_be16
    test eax, eax
    jz .Lfont_parse_failed
    mov dword ptr [rip + font_num_glyphs], eax
    mov r13d, eax

    # hhea: ascent, descent and numberOfHMetrics.
    mov rax, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_hhea_offset]
    add rax, rdx
    lea rdi, [rax + 4]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_ascent], eax
    mov rax, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_hhea_offset]
    add rax, rdx
    lea rdi, [rax + 6]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_descent], eax
    mov rax, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_hhea_offset]
    add rax, rdx
    lea rdi, [rax + 34]
    call font_be16
    test eax, eax
    jz .Lfont_parse_failed
    cmp eax, r13d
    ja .Lfont_parse_failed
    mov dword ptr [rip + font_num_hmetrics], eax

    # hmtx must contain all long metrics and the trailing side bearings.
    mov ecx, eax
    shl ecx, 2
    mov edx, r13d
    sub edx, eax
    shl edx, 1
    add ecx, edx
    cmp dword ptr [rip + font_hmtx_length], ecx
    jb .Lfont_parse_failed

    # loca length must cover glyphCount+1 offsets.
    lea ecx, [r13d + 1]
    cmp dword ptr [rip + font_index_to_loc_format], 0
    jne .Lfont_loca_long
    shl ecx, 1
    jmp .Lfont_loca_required
.Lfont_loca_long:
    shl ecx, 2
.Lfont_loca_required:
    cmp dword ptr [rip + font_loca_length], ecx
    jb .Lfont_parse_failed
    mov edi, '4'
    call font_debug_mark

    call font_parse_cmap
    test rax, rax
    js .Lfont_parse_failed
    mov edi, '5'
    call font_debug_mark
    xor eax, eax
    jmp .Lfont_parse_return
.Lfont_parse_failed:
    mov dword ptr [rip + font_loaded], 0
    mov rax, -1
.Lfont_parse_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size font_parse_mapped, . - font_parse_mapped

# Load and validate one font path, retaining its read-only mapping on success.
# RDI=NUL-terminated path; EAX=0 success, negative on failure.
.type font_try_path, @function
font_try_path:
    mov edi, 'T'
    call font_debug_mark
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    # Open read-only. No symlink following is needed for explicit font files.
    mov edi, 'O'
    call font_debug_mark
    mov eax, FONT_SYS_openat
    mov edi, FONT_AT_FDCWD
    mov rsi, r12
    xor edx, edx
    xor r10d, r10d
    syscall
    mov edi, 'o'
    call font_debug_mark
    test rax, rax
    js .Lfont_try_path_failed
    mov r13d, eax
    # Determine a bounded file length.
    mov edi, 'L'
    call font_debug_mark
    mov eax, FONT_SYS_lseek
    mov edi, r13d
    xor esi, esi
    mov edx, 2               # SEEK_END
    syscall
    mov edi, 'l'
    call font_debug_mark
    test rax, rax
    jle .Lfont_try_path_close_failed
    cmp rax, FONT_MAX_FILE_SIZE
    ja .Lfont_try_path_close_failed
    mov r14, rax
    # mmap(NULL, length, PROT_READ, MAP_PRIVATE, fd, 0)
    mov edi, 'm'
    call font_debug_mark
    xor edi, edi
    mov rsi, r14
    mov edx, FONT_PROT_READ
    mov r10d, FONT_MAP_PRIVATE
    mov r8d, r13d
    xor r9d, r9d
    mov eax, FONT_SYS_mmap
    syscall
    test rax, rax
    js .Lfont_try_path_close_failed
    mov r15, rax
    mov edi, 'M'
    call font_debug_mark
    mov eax, FONT_SYS_close
    mov edi, r13d
    syscall
    mov qword ptr [rip + font_file_map], r15
    mov qword ptr [rip + font_file_size], r14
    mov dword ptr [rip + font_loaded], 0
    mov dword ptr [rip + font_num_tables], 0
    mov edi, 'P'
    call font_debug_mark
    call font_parse_mapped
    mov edi, 'p'
    call font_debug_mark
    test rax, rax
    js .Lfont_try_path_unmap_failed
    # Prove that the chosen Unicode cmap and horizontal metrics work.
    mov edi, 'C'
    call font_debug_mark
    mov edi, 0x41             # 'A'
    call font_cmap_lookup
    mov edi, 'c'
    call font_debug_mark
    mov dword ptr [rip + font_probe_A_glyph], eax
    mov edi, eax
    call font_glyph_advance
    mov edi, 'a'
    call font_debug_mark
    mov dword ptr [rip + font_probe_A_advance], eax
    mov dword ptr [rip + font_loaded], 1
    xor eax, eax
    jmp .Lfont_try_path_return
.Lfont_try_path_unmap_failed:
    mov rdi, r15
    mov rsi, r14
    mov eax, FONT_SYS_munmap
    syscall
    mov qword ptr [rip + font_file_map], 0
    mov qword ptr [rip + font_file_size], 0
    jmp .Lfont_try_path_failed
.Lfont_try_path_close_failed:
    mov eax, FONT_SYS_close
    mov edi, r13d
    syscall
.Lfont_try_path_failed:
    mov rax, -1
.Lfont_try_path_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size font_try_path, . - font_try_path

# Map a Unicode scalar to a glyph index using cmap format 4 or 12.
# EDI=code point; EAX=glyph ID or zero for missing/invalid.
.global font_cmap_lookup
.type font_cmap_lookup, @function
font_cmap_lookup:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12d, edi
    mov rax, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_cmap_subtable_offset]
    add rax, rdx
    mov r13, rax
    cmp dword ptr [rip + font_cmap_format], 12
    je .Lfont_cmap_lookup_format12
    cmp r12d, 0xffff
    ja .Lfont_cmap_lookup_missing
    # Format 4 segment arrays, relative to the subtable.
    lea rdi, [r13 + 6]
    call font_be16
    test eax, 1
    jnz .Lfont_cmap_lookup_missing
    shr eax, 1
    test eax, eax
    jz .Lfont_cmap_lookup_missing
    mov r14d, eax             # segment count
    lea r15, [r13 + 14]        # endCode[]
    xor ebx, ebx
.Lfont_cmap_f4_find:
    cmp ebx, r14d
    jae .Lfont_cmap_lookup_missing
    mov eax, ebx
    lea eax, [rax + rax]
    mov rdi, r15
    add rdi, rax
    call font_be16
    cmp r12d, eax
    jbe .Lfont_cmap_f4_candidate
    inc ebx
    jmp .Lfont_cmap_f4_find
.Lfont_cmap_f4_candidate:
    # startCode[] begins after endCode[] and reservedPad.
    mov eax, r14d
    lea rdi, [r13 + 16]
    lea rdi, [rdi + rax * 2]
    mov edx, ebx
    lea edx, [rdx + rdx]
    add rdi, rdx
    call font_be16
    mov ebp, eax
    cmp r12d, eax
    jb .Lfont_cmap_lookup_missing
    mov eax, r14d
    lea rdi, [r13 + 16]
    lea rdi, [rdi + rax * 4]
    mov edx, ebx
    lea edx, [rdx + rdx]
    add rdi, rdx
    call font_be16
    movsx r15d, ax           # idDelta
    mov eax, r14d
    imul eax, 6
    lea rdi, [r13 + 16]
    add rdi, rax
    mov eax, ebx
    lea eax, [rax + rax]
    add rdi, rax
    call font_be16
    movzx r14d, ax
    test r14d, r14d
    jnz .Lfont_cmap_f4_range_offset
    lea eax, [r12d + r15d]
    and eax, 0xffff
    jmp .Lfont_cmap_lookup_check_glyph
.Lfont_cmap_f4_range_offset:
    # idRangeOffset is relative to its own word in the idRangeOffset array.
    mov rax, rdi
    add rax, r14
    mov edx, r12d
    sub edx, ebp
    add edx, edx
    add rax, rdx
    mov rdi, rax
    mov eax, dword ptr [rip + font_cmap_subtable_length]
    mov rdx, r13
    add rdx, rax
    lea rax, [rdi + 2]
    cmp rax, rdx
    ja .Lfont_cmap_lookup_missing
    mov rdx, qword ptr [rip + font_file_map]
    sub rdi, rdx
    mov rdx, rdi
    add rdx, 2
    cmp rdx, qword ptr [rip + font_file_size]
    ja .Lfont_cmap_lookup_missing
    add rdi, qword ptr [rip + font_file_map]
    call font_be16
    test eax, eax
    jz .Lfont_cmap_lookup_check_glyph
    add eax, r15d
    and eax, 0xffff
    jmp .Lfont_cmap_lookup_check_glyph
.Lfont_cmap_lookup_format12:
    lea rdi, [r13 + 12]
    call font_be32
    cmp eax, FONT_MAX_CMAP_GROUPS
    ja .Lfont_cmap_lookup_missing
    mov r14d, eax
    xor ebx, ebx
    mov ebp, r14d
.Lfont_cmap_f12_find:
    cmp ebx, ebp
    jae .Lfont_cmap_lookup_missing
    lea ecx, [rbx + rbp]
    shr ecx, 1
    mov eax, ecx
    imul rax, 12
    lea r15, [r13 + 16]
    add r15, rax
    mov rdi, r15
    call font_be32
    mov r8d, eax
    mov rdi, r15
    add rdi, 4
    call font_be32
    mov r9d, eax
    cmp r12d, r8d
    jb .Lfont_cmap_f12_lower
    cmp r12d, r9d
    ja .Lfont_cmap_f12_upper
    mov rdi, r15
    add rdi, 8
    call font_be32
    sub r12d, r8d
    add eax, r12d
    jmp .Lfont_cmap_lookup_check_glyph
.Lfont_cmap_f12_lower:
    mov ebp, ecx
    jmp .Lfont_cmap_f12_find
.Lfont_cmap_f12_upper:
    lea ebx, [ecx + 1]
    jmp .Lfont_cmap_f12_find
.Lfont_cmap_lookup_check_glyph:
    cmp eax, dword ptr [rip + font_num_glyphs]
    jae .Lfont_cmap_lookup_missing
    jmp .Lfont_cmap_lookup_return
.Lfont_cmap_lookup_missing:
    xor eax, eax
.Lfont_cmap_lookup_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size font_cmap_lookup, . - font_cmap_lookup

# Return an advance width in font units for EDI=glyph ID.
.global font_glyph_advance
.type font_glyph_advance, @function
font_glyph_advance:
    sub rsp, 8
    cmp edi, dword ptr [rip + font_num_glyphs]
    jae .Lfont_advance_missing
    mov eax, edi
    cmp eax, dword ptr [rip + font_num_hmetrics]
    jb .Lfont_advance_index_ready
    mov eax, dword ptr [rip + font_num_hmetrics]
    dec eax
.Lfont_advance_index_ready:
    shl eax, 2
    mov rdx, qword ptr [rip + font_file_map]
    mov ecx, dword ptr [rip + font_hmtx_offset]
    add rdx, rcx
    add rdx, rax
    mov rdi, rdx
    call font_be16
    add rsp, 8
    ret
.Lfont_advance_missing:
    xor eax, eax
    add rsp, 8
    ret
.size font_glyph_advance, . - font_glyph_advance

# Initialize the optional font engine. Explicit NEKOEDIT_FONT takes precedence;
# otherwise try deterministic common system-font paths. EAX=0 on success.
.global font_init
.type font_init, @function
font_init:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov dword ptr [rip + font_loaded], 0
    mov dword ptr [rip + font_probe_A_glyph], 0
    mov dword ptr [rip + font_probe_A_advance], 0
    # Walk the process environment for NEKOEDIT_FONT.
    mov r12, qword ptr [rip + process_envp]
    test r12, r12
    jz .Lfont_try_defaults
.Lfont_env_next:
    mov r13, qword ptr [r12]
    test r13, r13
    jz .Lfont_try_defaults
    lea r14, [rip + font_env_key]
    mov r15d, font_env_key_end - font_env_key
.Lfont_env_compare:
    test r15d, r15d
    jz .Lfont_env_equal
    mov al, byte ptr [r13]
    cmp al, byte ptr [r14]
    jne .Lfont_env_advance
    inc r13
    inc r14
    dec r15d
    jmp .Lfont_env_compare
.Lfont_env_equal:
    cmp byte ptr [r13], '='
    jne .Lfont_env_advance
    lea rdi, [r13 + 1]
    cmp byte ptr [rdi], 0
    je .Lfont_try_defaults
    mov edi, 'E'
    call font_debug_mark
    call font_try_path
    test rax, rax
    jz .Lfont_init_success
    jmp .Lfont_try_defaults
.Lfont_env_advance:
    add r12, 8
    jmp .Lfont_env_next

.Lfont_try_defaults:
    # Automatic directory discovery is added after explicit-path parsing is
    # independently validated. Until then a missing/invalid override preserves
    # the embedded bitmap fallback without probing unrelated host files.
    jmp .Lfont_init_failed
.Lfont_init_success:
    xor eax, eax
    jmp .Lfont_init_return
.Lfont_init_failed:
    mov rax, -1
.Lfont_init_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size font_init, . - font_init

.section .note.GNU-stack,"",@progbits
