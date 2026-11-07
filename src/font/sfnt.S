.intel_syntax noprefix

# Bounded, dependency-free reader for single-face TrueType-outline SFNT files.
# The glyph rasterizer is a later layer; this module owns discovery, mapping,
# table validation, cmap lookup, metrics and bounded outline decoding.

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
.equ FONT_MAX_GLYPH_CONTOURS, 256
.equ FONT_MAX_GLYPH_POINTS, 4096
.equ FONT_MAX_COMPOSITE_DEPTH, 16
.equ FONT_FRAME_FLAGS_OFFSET, 24
.equ FONT_FRAME_X_OFFSET, 4120
.equ FONT_FRAME_Y_OFFSET, 20504
.equ FONT_FRAME_ENDS_OFFSET, 36888
.equ FONT_GLYPH_FRAME_STRIDE, 37912

# Four-byte table tags expressed as their little-endian in-memory integers.
.equ FONT_TAG_CMAP, 0x70616d63
.equ FONT_TAG_GLYF, 0x66796c67
.equ FONT_TAG_HEAD, 0x64616568
.equ FONT_TAG_HHEA, 0x61656868
.equ FONT_TAG_OS2, 0x322f534f
.equ FONT_TAG_HMTX, 0x78746d68
.equ FONT_TAG_LOCA, 0x61636f6c
.equ FONT_TAG_MAXP, 0x7078616d

.section .rodata
.balign 4
font_env_key:
    .ascii "NEKOEDIT_FONT"
font_env_key_end:
font_disable_env_key:
    .ascii "NEKOEDIT_DISABLE_FONT"
font_disable_env_key_end:
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
.global font_ascent, font_descent, font_line_gap, font_num_hmetrics, font_index_to_loc_format
.global font_cmap_format, font_cmap_subtable_offset, font_cmap_subtable_length
.global font_head_offset, font_hhea_offset, font_maxp_offset
.global font_cmap_offset, font_cmap_length, font_hmtx_offset, font_hmtx_length
.global font_glyf_offset, font_glyf_length, font_loca_offset, font_loca_length
.global font_probe_A_glyph, font_probe_A_advance
.global font_probe_A_outline_result, font_probe_A_contours, font_probe_A_points
.global font_probe_A_last_x, font_probe_A_last_y
.global font_probe_empty_result, font_probe_empty_contours, font_probe_empty_points
.global font_probe_oob_result
.global font_probe_composite_result, font_probe_composite_contours, font_probe_composite_points
.global font_probe_composite_first_x, font_probe_composite_first_y
.global font_probe_composite_last_x, font_probe_composite_last_y
.global font_probe_nested_result, font_probe_nested_contours, font_probe_nested_points
.global font_probe_nested_last_x, font_probe_nested_last_y
.global font_probe_pointmatch_result, font_probe_pointmatch_contours, font_probe_pointmatch_points
.global font_probe_pointmatch_last_x, font_probe_pointmatch_last_y
.global font_probe_cycle_result
.global font_probe_anisotropic_result, font_probe_anisotropic_contours, font_probe_anisotropic_points
.global font_probe_anisotropic_last_x, font_probe_anisotropic_last_y
.global font_probe_matrix_result, font_probe_matrix_contours, font_probe_matrix_points
.global font_probe_matrix_last_x, font_probe_matrix_last_y
.global font_probe_byte_result, font_probe_byte_contours, font_probe_byte_points
.global font_probe_byte_first_x, font_probe_byte_first_y, font_probe_byte_last_x, font_probe_byte_last_y
.global font_glyph_contour_count, font_glyph_point_count
.global font_glyph_x_min, font_glyph_y_min, font_glyph_x_max, font_glyph_y_max
.global font_glyph_contour_ends, font_glyph_point_flags
.global font_glyph_points_x, font_glyph_points_y
font_loaded:                    .long 0
font_num_tables:                .long 0
font_units_per_em:              .long 0
font_num_glyphs:                .long 0
font_ascent:                    .long 0
font_descent:                   .long 0
font_line_gap:                  .long 0
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
font_probe_A_outline_result:    .long 0
font_probe_A_contours:          .long 0
font_probe_A_points:            .long 0
font_probe_A_last_x:            .long 0
font_probe_A_last_y:            .long 0
font_probe_empty_result:        .long 0
font_probe_empty_contours:      .long 0
font_probe_empty_points:        .long 0
font_probe_oob_result:          .long 0
font_probe_composite_result:     .long 0
font_probe_composite_contours:   .long 0
font_probe_composite_points:     .long 0
font_probe_composite_first_x:   .long 0
font_probe_composite_first_y:   .long 0
font_probe_composite_last_x:    .long 0
font_probe_composite_last_y:    .long 0
font_probe_nested_result:        .long 0
font_probe_nested_contours:      .long 0
font_probe_nested_points:        .long 0
font_probe_nested_last_x:       .long 0
font_probe_nested_last_y:       .long 0
font_probe_pointmatch_result:    .long 0
font_probe_pointmatch_contours:  .long 0
font_probe_pointmatch_points:    .long 0
font_probe_pointmatch_last_x:   .long 0
font_probe_pointmatch_last_y:   .long 0
font_probe_cycle_result:         .long 0
font_probe_anisotropic_result:    .long 0
font_probe_anisotropic_contours:  .long 0
font_probe_anisotropic_points:    .long 0
font_probe_anisotropic_last_x:   .long 0
font_probe_anisotropic_last_y:   .long 0
font_probe_matrix_result:         .long 0
font_probe_matrix_contours:       .long 0
font_probe_matrix_points:         .long 0
font_probe_matrix_last_x:        .long 0
font_probe_matrix_last_y:        .long 0
font_probe_byte_result:           .long 0
font_probe_byte_contours:         .long 0
font_probe_byte_points:           .long 0
font_probe_byte_first_x:         .long 0
font_probe_byte_first_y:         .long 0
font_probe_byte_last_x:          .long 0
font_probe_byte_last_y:          .long 0
font_glyph_contour_count:       .long 0
font_glyph_point_count:         .long 0
font_glyph_x_min:               .long 0
font_glyph_y_min:               .long 0
font_glyph_x_max:               .long 0
font_glyph_y_max:               .long 0
.balign 4
font_glyph_contour_ends:        .zero FONT_MAX_GLYPH_CONTOURS * 4
font_glyph_point_flags:         .zero FONT_MAX_GLYPH_POINTS
.balign 4
font_glyph_points_x:            .zero FONT_MAX_GLYPH_POINTS * 4
font_glyph_points_y:            .zero FONT_MAX_GLYPH_POINTS * 4
.balign 4
font_glyph_decode_stack:         .zero FONT_MAX_COMPOSITE_DEPTH * 4
.balign 8
font_glyph_frames:               .zero FONT_MAX_COMPOSITE_DEPTH * FONT_GLYPH_FRAME_STRIDE
.balign 8
font_file_map:                  .quad 0
font_file_size:                 .quad 0


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
    lea rsp, [rsp + 8]       # preserve CF for callers testing table lookup
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
    mov eax, dword ptr [rip + font_cmap_offset]
    add r8, rax
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
    lea rdi, [rax + 8]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_line_gap], eax
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

    # Prefer OS/2 typographic metrics only for version 4+ fonts that set
    # fsSelection.USE_TYPO_METRICS. Otherwise the hhea values above remain active.
    mov edi, FONT_TAG_OS2
    call font_find_table
    jc .Lfont_typo_metrics_done
    cmp edx, 74
    jb .Lfont_typo_metrics_done
    mov r14d, eax
    mov rax, qword ptr [rip + font_file_map]
    add rax, r14
    mov rdi, rax
    call font_be16
    cmp eax, 4
    jb .Lfont_typo_metrics_done
    mov rax, qword ptr [rip + font_file_map]
    add rax, r14
    lea rdi, [rax + 62]
    call font_be16
    test eax, 0x80
    jz .Lfont_typo_metrics_done
    mov rax, qword ptr [rip + font_file_map]
    add rax, r14
    lea rdi, [rax + 68]
    call font_be16
    movsx r10d, ax
    test r10d, r10d
    jle .Lfont_typo_metrics_done
    mov rax, qword ptr [rip + font_file_map]
    add rax, r14
    lea rdi, [rax + 70]
    call font_be16
    movsx r11d, ax
    test r11d, r11d
    jg .Lfont_typo_metrics_done
    mov rax, qword ptr [rip + font_file_map]
    add rax, r14
    lea rdi, [rax + 72]
    call font_be16
    movsx r9d, ax
    mov eax, r10d
    sub eax, r11d
    add eax, r9d
    test eax, eax
    jle .Lfont_typo_metrics_done
    mov dword ptr [rip + font_ascent], r10d
    mov dword ptr [rip + font_descent], r11d
    mov dword ptr [rip + font_line_gap], r9d
.Lfont_typo_metrics_done:

    # The optional OS/2 lookup clobbers EAX; reload the validated hhea metric count.
    # hmtx must contain all long metrics and the trailing side bearings.
    mov ecx, dword ptr [rip + font_num_hmetrics]
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

    call font_parse_cmap
    test rax, rax
    js .Lfont_parse_failed
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
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    # Open read-only. No symlink following is needed for explicit font files.
    mov eax, FONT_SYS_openat
    mov edi, FONT_AT_FDCWD
    mov rsi, r12
    xor edx, edx
    xor r10d, r10d
    syscall
    test rax, rax
    js .Lfont_try_path_failed
    mov r13d, eax
    # Determine a bounded file length.
    mov eax, FONT_SYS_lseek
    mov edi, r13d
    xor esi, esi
    mov edx, 2               # SEEK_END
    syscall
    test rax, rax
    jle .Lfont_try_path_close_failed
    cmp rax, FONT_MAX_FILE_SIZE
    ja .Lfont_try_path_close_failed
    mov r14, rax
    # mmap(NULL, length, PROT_READ, MAP_PRIVATE, fd, 0)
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
    mov eax, FONT_SYS_close
    mov edi, r13d
    syscall
    mov qword ptr [rip + font_file_map], r15
    mov qword ptr [rip + font_file_size], r14
    mov dword ptr [rip + font_loaded], 0
    mov dword ptr [rip + font_num_tables], 0
    call font_parse_mapped
    test rax, rax
    js .Lfont_try_path_unmap_failed
    # Prove that the chosen Unicode cmap and horizontal metrics work.
    mov edi, 0x41             # 'A'
    call font_cmap_lookup
    mov dword ptr [rip + font_probe_A_glyph], eax
    mov edi, eax
    call font_glyph_advance
    mov dword ptr [rip + font_probe_A_advance], eax

    # Probe the simple-outline decoder without making composite glyphs fatal
    # to font selection; the renderer may fall back for unsupported glyphs.
    mov edi, dword ptr [rip + font_probe_A_glyph]
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_A_outline_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_A_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_A_points], eax
    test eax, eax
    jz .Lfont_probe_empty_outline
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_A_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_A_last_y], eax
.Lfont_probe_empty_outline:
    xor edi, edi
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_empty_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_empty_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_empty_points], eax
    mov edi, dword ptr [rip + font_num_glyphs]
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_oob_result], eax

    # Probe XY-offset composites, nested scale transforms, point matching,
    # and a recursive cycle. These checks exercise the complete merge path.
    mov edi, 2
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_composite_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_composite_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_composite_points], eax
    test eax, eax
    jz .Lfont_probe_composite_done
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi]
    mov dword ptr [rip + font_probe_composite_first_x], eax
    mov eax, dword ptr [rip + font_glyph_points_y]
    mov dword ptr [rip + font_probe_composite_first_y], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_composite_last_x], eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_composite_last_y], eax
.Lfont_probe_composite_done:
    mov edi, 3
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_nested_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_nested_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_nested_points], eax
    test eax, eax
    jz .Lfont_probe_nested_done
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_nested_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_nested_last_y], eax
.Lfont_probe_nested_done:
    mov edi, 4
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_pointmatch_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_pointmatch_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_pointmatch_points], eax
    test eax, eax
    jz .Lfont_probe_pointmatch_done
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_pointmatch_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_pointmatch_last_y], eax
.Lfont_probe_pointmatch_done:
    mov edi, 5
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_cycle_result], eax

    mov edi, 6
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_anisotropic_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_anisotropic_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_anisotropic_points], eax
    test eax, eax
    jz .Lfont_probe_anisotropic_done
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_anisotropic_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_anisotropic_last_y], eax
.Lfont_probe_anisotropic_done:
    mov edi, 7
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_matrix_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_matrix_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_matrix_points], eax
    test eax, eax
    jz .Lfont_probe_matrix_done
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_matrix_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_matrix_last_y], eax
.Lfont_probe_matrix_done:
    mov edi, 8
    call font_glyph_load_outline
    mov dword ptr [rip + font_probe_byte_result], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rip + font_probe_byte_contours], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rip + font_probe_byte_points], eax
    test eax, eax
    jz .Lfont_probe_byte_done
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi]
    mov dword ptr [rip + font_probe_byte_first_x], eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi]
    mov dword ptr [rip + font_probe_byte_first_y], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_byte_last_x], eax
    mov eax, dword ptr [rip + font_glyph_point_count]
    dec eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rdi + rax * 4]
    mov dword ptr [rip + font_probe_byte_last_y], eax
.Lfont_probe_byte_done:
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

# Save the current aggregate outline into the frame for one composite depth.
# EDI=depth. This is called immediately before a recursive child decode.
.type font_outline_frame_save, @function
font_outline_frame_save:
    push rbx
    push r12
    push r13
    push r14
    mov ebx, edi
    cmp ebx, FONT_MAX_COMPOSITE_DEPTH
    jae .Lfont_frame_save_done
    imul rbx, FONT_GLYPH_FRAME_STRIDE
    lea rax, [rip + font_glyph_frames]
    add rbx, rax
    mov eax, dword ptr [rip + font_glyph_point_count]
    mov dword ptr [rbx], eax
    mov eax, dword ptr [rip + font_glyph_contour_count]
    mov dword ptr [rbx + 4], eax
    mov eax, dword ptr [rip + font_glyph_x_min]
    mov dword ptr [rbx + 8], eax
    mov eax, dword ptr [rip + font_glyph_y_min]
    mov dword ptr [rbx + 12], eax
    mov eax, dword ptr [rip + font_glyph_x_max]
    mov dword ptr [rbx + 16], eax
    mov eax, dword ptr [rip + font_glyph_y_max]
    mov dword ptr [rbx + 20], eax
    mov r12d, dword ptr [rbx]
    lea rsi, [rip + font_glyph_point_flags]
    lea rdi, [rbx + FONT_FRAME_FLAGS_OFFSET]
    mov ecx, r12d
    rep movsb
    lea rsi, [rip + font_glyph_points_x]
    lea rdi, [rbx + FONT_FRAME_X_OFFSET]
    mov ecx, r12d
    rep movsd
    lea rsi, [rip + font_glyph_points_y]
    lea rdi, [rbx + FONT_FRAME_Y_OFFSET]
    mov ecx, r12d
    rep movsd
    mov r13d, dword ptr [rbx + 4]
    lea rsi, [rip + font_glyph_contour_ends]
    lea rdi, [rbx + FONT_FRAME_ENDS_OFFSET]
    mov ecx, r13d
    rep movsd
.Lfont_frame_save_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size font_outline_frame_save, . - font_outline_frame_save

# Merge the decoded child outline into the saved parent aggregate.
# EDI=depth, ESI/EDX=XY offsets or parent/child point indices,
# ECX/R8D/R9D/R10D=(xscale, scale01, scale10, yscale), R11D=1 for XY args.
.type font_outline_frame_merge, @function
font_outline_frame_merge:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40
    mov dword ptr [rsp], edi
    mov dword ptr [rsp + 4], esi
    mov dword ptr [rsp + 8], edx
    mov dword ptr [rsp + 12], ecx
    mov dword ptr [rsp + 16], r8d
    mov dword ptr [rsp + 20], r9d
    mov dword ptr [rsp + 24], r10d
    mov dword ptr [rsp + 28], r11d
    cmp edi, FONT_MAX_COMPOSITE_DEPTH
    jae .Lfont_frame_merge_bad
    imul rax, rdi, FONT_GLYPH_FRAME_STRIDE
    lea rbx, [rip + font_glyph_frames]
    add rbx, rax
    mov ebp, dword ptr [rbx]
    mov r12d, dword ptr [rbx + 4]
    mov r13d, dword ptr [rip + font_glyph_point_count]
    mov r14d, dword ptr [rip + font_glyph_contour_count]
    lea eax, [rbp + r13]
    cmp eax, FONT_MAX_GLYPH_POINTS
    ja .Lfont_frame_merge_bad
    lea eax, [r12 + r14]
    cmp eax, FONT_MAX_GLYPH_CONTOURS
    ja .Lfont_frame_merge_bad

    # Resolve point-matching arguments after the child has been transformed
    # by its linear matrix. The parent index refers to already accumulated
    # points; the child index refers to this component's decoded point array.
    cmp dword ptr [rsp + 28], 0
    jne .Lfont_frame_merge_xy_offset
    mov eax, dword ptr [rsp + 4]
    cmp eax, ebp
    jae .Lfont_frame_merge_bad
    mov ecx, dword ptr [rsp + 8]
    cmp ecx, r13d
    jae .Lfont_frame_merge_bad
    movsxd r8, dword ptr [rbx + FONT_FRAME_X_OFFSET + rax * 4]
    movsxd r9, dword ptr [rbx + FONT_FRAME_Y_OFFSET + rax * 4]
    lea rsi, [rip + font_glyph_points_x]
    movsxd rax, dword ptr [rsi + rcx * 4]
    lea rsi, [rip + font_glyph_points_y]
    movsxd rdx, dword ptr [rsi + rcx * 4]
    movsxd rcx, dword ptr [rsp + 12]
    imul rax, rcx
    movsxd rcx, dword ptr [rsp + 20]
    imul rdx, rcx
    add rax, rdx
    sar rax, 14
    sub r8, rax
    mov rax, 0x7fffffff
    cmp r8, rax
    jg .Lfont_frame_merge_bad
    mov rax, -2147483648
    cmp r8, rax
    jl .Lfont_frame_merge_bad
    mov dword ptr [rsp + 32], r8d
    mov ecx, dword ptr [rsp + 8]
    lea rsi, [rip + font_glyph_points_x]
    movsxd rax, dword ptr [rsi + rcx * 4]
    lea rsi, [rip + font_glyph_points_y]
    movsxd rdx, dword ptr [rsi + rcx * 4]
    movsxd rcx, dword ptr [rsp + 16]
    imul rax, rcx
    movsxd rcx, dword ptr [rsp + 24]
    imul rdx, rcx
    add rax, rdx
    sar rax, 14
    sub r9, rax
    mov rax, 0x7fffffff
    cmp r9, rax
    jg .Lfont_frame_merge_bad
    mov rax, -2147483648
    cmp r9, rax
    jl .Lfont_frame_merge_bad
    mov dword ptr [rsp + 36], r9d
    jmp .Lfont_frame_merge_offsets_ready
.Lfont_frame_merge_xy_offset:
    mov eax, dword ptr [rsp + 4]
    mov dword ptr [rsp + 32], eax
    mov eax, dword ptr [rsp + 8]
    mov dword ptr [rsp + 36], eax
.Lfont_frame_merge_offsets_ready:
    xor r15d, r15d
.Lfont_frame_merge_point_loop:
    cmp r15d, r13d
    jae .Lfont_frame_merge_points_done
    lea rsi, [rip + font_glyph_points_x]
    movsxd rax, dword ptr [rsi + r15 * 4]
    lea rsi, [rip + font_glyph_points_y]
    movsxd rdx, dword ptr [rsi + r15 * 4]
    movsxd r8, dword ptr [rsp + 12]
    imul rax, r8
    movsxd r8, dword ptr [rsp + 20]
    imul rdx, r8
    add rax, rdx
    sar rax, 14
    movsxd r8, dword ptr [rsp + 32]
    add rax, r8
    mov rdx, 0x7fffffff
    cmp rax, rdx
    jg .Lfont_frame_merge_bad
    mov rdx, -2147483648
    cmp rax, rdx
    jl .Lfont_frame_merge_bad
    # Store the checked transformed X coordinate at the appended point index.
    lea rsi, [rip + font_glyph_points_x]
    movsxd rax, dword ptr [rsi + r15 * 4]
    lea rsi, [rip + font_glyph_points_y]
    movsxd rdx, dword ptr [rsi + r15 * 4]
    movsxd r8, dword ptr [rsp + 12]
    imul rax, r8
    movsxd r8, dword ptr [rsp + 20]
    imul rdx, r8
    add rax, rdx
    sar rax, 14
    movsxd r8, dword ptr [rsp + 32]
    add rax, r8
    lea rdi, [rbx + FONT_FRAME_X_OFFSET]
    lea ecx, [rbp + r15]
    mov dword ptr [rdi + rcx * 4], eax

    lea rsi, [rip + font_glyph_points_x]
    movsxd rax, dword ptr [rsi + r15 * 4]
    lea rsi, [rip + font_glyph_points_y]
    movsxd rdx, dword ptr [rsi + r15 * 4]
    movsxd r8, dword ptr [rsp + 16]
    imul rax, r8
    movsxd r8, dword ptr [rsp + 24]
    imul rdx, r8
    add rax, rdx
    sar rax, 14
    movsxd r8, dword ptr [rsp + 36]
    add rax, r8
    mov rdx, 0x7fffffff
    cmp rax, rdx
    jg .Lfont_frame_merge_bad
    mov rdx, -2147483648
    cmp rax, rdx
    jl .Lfont_frame_merge_bad
    lea rdi, [rbx + FONT_FRAME_Y_OFFSET]
    lea ecx, [rbp + r15]
    mov dword ptr [rdi + rcx * 4], eax

    lea rsi, [rip + font_glyph_point_flags]
    movzx eax, byte ptr [rsi + r15]
    lea rdi, [rbx + FONT_FRAME_FLAGS_OFFSET]
    lea ecx, [rbp + r15]
    mov byte ptr [rdi + rcx], al
    inc r15d
    jmp .Lfont_frame_merge_point_loop
.Lfont_frame_merge_points_done:
    xor r15d, r15d
.Lfont_frame_merge_contour_loop:
    cmp r15d, r14d
    jae .Lfont_frame_merge_contours_done
    lea rsi, [rip + font_glyph_contour_ends]
    mov eax, dword ptr [rsi + r15 * 4]
    cmp eax, r13d
    jae .Lfont_frame_merge_bad
    add eax, ebp
    lea rdi, [rbx + FONT_FRAME_ENDS_OFFSET]
    lea ecx, [r12 + r15]
    mov dword ptr [rdi + rcx * 4], eax
    inc r15d
    jmp .Lfont_frame_merge_contour_loop
.Lfont_frame_merge_contours_done:
    add ebp, r13d
    add r12d, r14d
    mov dword ptr [rbx], ebp
    mov dword ptr [rbx + 4], r12d

    # Restore the merged aggregate into the public scratch arrays.
    lea rsi, [rbx + FONT_FRAME_FLAGS_OFFSET]
    lea rdi, [rip + font_glyph_point_flags]
    mov ecx, ebp
    rep movsb
    lea rsi, [rbx + FONT_FRAME_X_OFFSET]
    lea rdi, [rip + font_glyph_points_x]
    mov ecx, ebp
    rep movsd
    lea rsi, [rbx + FONT_FRAME_Y_OFFSET]
    lea rdi, [rip + font_glyph_points_y]
    mov ecx, ebp
    rep movsd
    lea rsi, [rbx + FONT_FRAME_ENDS_OFFSET]
    lea rdi, [rip + font_glyph_contour_ends]
    mov ecx, r12d
    rep movsd
    mov dword ptr [rip + font_glyph_point_count], ebp
    mov dword ptr [rip + font_glyph_contour_count], r12d
    mov eax, dword ptr [rbx + 8]
    mov dword ptr [rip + font_glyph_x_min], eax
    mov eax, dword ptr [rbx + 12]
    mov dword ptr [rip + font_glyph_y_min], eax
    mov eax, dword ptr [rbx + 16]
    mov dword ptr [rip + font_glyph_x_max], eax
    mov eax, dword ptr [rbx + 20]
    mov dword ptr [rip + font_glyph_y_max], eax

    # Recompute the aggregate bounding box from the transformed points.
    test ebp, ebp
    jz .Lfont_frame_merge_success
    lea rsi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rsi]
    mov dword ptr [rip + font_glyph_x_min], eax
    mov dword ptr [rip + font_glyph_x_max], eax
    lea rsi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rsi]
    mov dword ptr [rip + font_glyph_y_min], eax
    mov dword ptr [rip + font_glyph_y_max], eax
    mov r15d, 1
.Lfont_frame_merge_bbox_loop:
    cmp r15d, ebp
    jae .Lfont_frame_merge_success
    lea rsi, [rip + font_glyph_points_x]
    mov eax, dword ptr [rsi + r15 * 4]
    cmp eax, dword ptr [rip + font_glyph_x_min]
    jge .Lfont_frame_merge_bbox_xmax
    mov dword ptr [rip + font_glyph_x_min], eax
.Lfont_frame_merge_bbox_xmax:
    cmp eax, dword ptr [rip + font_glyph_x_max]
    jle .Lfont_frame_merge_bbox_y
    mov dword ptr [rip + font_glyph_x_max], eax
.Lfont_frame_merge_bbox_y:
    lea rsi, [rip + font_glyph_points_y]
    mov eax, dword ptr [rsi + r15 * 4]
    cmp eax, dword ptr [rip + font_glyph_y_min]
    jge .Lfont_frame_merge_bbox_ymax
    mov dword ptr [rip + font_glyph_y_min], eax
.Lfont_frame_merge_bbox_ymax:
    cmp eax, dword ptr [rip + font_glyph_y_max]
    jle .Lfont_frame_merge_bbox_next
    mov dword ptr [rip + font_glyph_y_max], eax
.Lfont_frame_merge_bbox_next:
    inc r15d
    jmp .Lfont_frame_merge_bbox_loop
.Lfont_frame_merge_success:
    xor eax, eax
    jmp .Lfont_frame_merge_return
.Lfont_frame_merge_bad:
    mov eax, -1
.Lfont_frame_merge_return:
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size font_outline_frame_merge, . - font_outline_frame_merge

# Public wrapper starts a fresh bounded recursion chain. Internal recursive
# calls use a depth-specific frame to preserve each parent's partial outline.
.global font_glyph_load_outline
.type font_glyph_load_outline, @function
font_glyph_load_outline:
    sub rsp, 8
    xor esi, esi
    call font_glyph_load_outline_internal
    add rsp, 8
    ret
.size font_glyph_load_outline, . - font_glyph_load_outline

# Decode simple or composite TrueType glyphs into bounded design-unit arrays.
# EDI=glyph ID, ESI=recursion depth. Returns 0 on success or -1 for malformed/unsupported data.
.type font_glyph_load_outline_internal, @function
font_glyph_load_outline_internal:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 56
    mov r12d, edi
    mov dword ptr [rsp + 32], esi
    mov dword ptr [rsp + 36], 0
    cmp esi, FONT_MAX_COMPOSITE_DEPTH
    jae .Lfont_glyph_outline_bad

    # Reject recursive cycles as well as excessive nesting.
    xor ebx, ebx
    lea rdi, [rip + font_glyph_decode_stack]
.Lfont_glyph_outline_cycle_loop:
    cmp ebx, esi
    jae .Lfont_glyph_outline_cycle_store
    cmp dword ptr [rdi + rbx * 4], r12d
    je .Lfont_glyph_outline_bad
    inc ebx
    jmp .Lfont_glyph_outline_cycle_loop
.Lfont_glyph_outline_cycle_store:
    mov dword ptr [rdi + rbx * 4], r12d
    mov dword ptr [rip + font_glyph_contour_count], 0
    mov dword ptr [rip + font_glyph_point_count], 0
    mov dword ptr [rip + font_glyph_x_min], 0
    mov dword ptr [rip + font_glyph_y_min], 0
    mov dword ptr [rip + font_glyph_x_max], 0
    mov dword ptr [rip + font_glyph_y_max], 0

    cmp r12d, dword ptr [rip + font_num_glyphs]
    jae .Lfont_glyph_outline_bad
    mov dword ptr [rip + font_glyph_contour_count], 0
    mov dword ptr [rip + font_glyph_point_count], 0
    mov dword ptr [rip + font_glyph_x_min], 0
    mov dword ptr [rip + font_glyph_y_min], 0
    mov dword ptr [rip + font_glyph_x_max], 0
    mov dword ptr [rip + font_glyph_y_max], 0

    cmp r12d, dword ptr [rip + font_num_glyphs]
    jae .Lfont_glyph_outline_bad

    # Resolve the glyph's two loca entries. Short entries are divided by two.
    mov eax, r12d
    cmp dword ptr [rip + font_index_to_loc_format], 0
    jne .Lfont_glyph_outline_loca_long
    lea eax, [rax + rax]
    mov rdi, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_loca_offset]
    add rdi, rdx
    add rdi, rax
    call font_be16
    mov r13d, eax
    shl r13d, 1
    lea rdi, [rdi + 2]
    call font_be16
    mov r14d, eax
    shl r14d, 1
    jmp .Lfont_glyph_outline_loca_ready
.Lfont_glyph_outline_loca_long:
    shl eax, 2
    mov rdi, qword ptr [rip + font_file_map]
    mov edx, dword ptr [rip + font_loca_offset]
    add rdi, rdx
    add rdi, rax
    call font_be32
    mov r13d, eax
    lea rdi, [rdi + 4]
    call font_be32
    mov r14d, eax

.Lfont_glyph_outline_loca_ready:
    # Both offsets must be ordered and contained by the glyf table.
    cmp r14d, r13d
    jb .Lfont_glyph_outline_bad
    cmp r14d, dword ptr [rip + font_glyf_length]
    ja .Lfont_glyph_outline_bad
    mov ebp, r14d
    sub ebp, r13d
    test ebp, ebp
    jz .Lfont_glyph_outline_success

    mov r15, qword ptr [rip + font_file_map]
    mov eax, dword ptr [rip + font_glyf_offset]
    add r15, rax
    add r15, r13
    lea rbx, [r15 + rbp]
    cmp ebp, 10
    jb .Lfont_glyph_outline_bad

    # Glyph header: signed contour count followed by xMin/yMin/xMax/yMax.
    mov rdi, r15
    call font_be16
    movsx ebp, ax
    cmp ebp, -1
    je .Lfont_glyph_outline_composite
    test ebp, ebp
    js .Lfont_glyph_outline_bad
    cmp ebp, FONT_MAX_GLYPH_CONTOURS
    ja .Lfont_glyph_outline_bad
    mov dword ptr [rip + font_glyph_contour_count], ebp

    lea rdi, [r15 + 2]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_x_min], eax
    lea rdi, [r15 + 4]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_y_min], eax
    lea rdi, [r15 + 6]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_x_max], eax
    lea rdi, [r15 + 8]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_y_max], eax

    # endPtsOfContours plus the two-byte instruction length must fit.
    mov eax, ebp
    lea r13, [r15 + 10]
    lea r14, [r13 + rax * 2 + 2]
    cmp r14, rbx
    ja .Lfont_glyph_outline_bad

    # End-point indices are strictly increasing; the last one sets point count.
    xor r8d, r8d
    mov r9d, -1
.Lfont_glyph_outline_endpoint_loop:
    cmp r8d, ebp
    jae .Lfont_glyph_outline_endpoints_done
    mov eax, r8d
    lea rdi, [r13 + rax * 2]
    call font_be16
    test r8d, r8d
    jz .Lfont_glyph_outline_endpoint_first
    cmp eax, r9d
    jbe .Lfont_glyph_outline_bad
.Lfont_glyph_outline_endpoint_first:
    cmp eax, FONT_MAX_GLYPH_POINTS - 1
    ja .Lfont_glyph_outline_bad
    mov r9d, eax
    lea rdi, [rip + font_glyph_contour_ends]
    mov eax, r8d
    mov dword ptr [rdi + rax * 4], r9d
    inc r8d
    jmp .Lfont_glyph_outline_endpoint_loop
.Lfont_glyph_outline_endpoints_done:
    test ebp, ebp
    jz .Lfont_glyph_outline_no_points
    lea eax, [r9d + 1]
    mov dword ptr [rip + font_glyph_point_count], eax
    jmp .Lfont_glyph_outline_read_instructions
.Lfont_glyph_outline_no_points:
    mov dword ptr [rip + font_glyph_point_count], 0

.Lfont_glyph_outline_read_instructions:
    # instructionLength follows the end-point array.
    mov eax, ebp
    shl eax, 1
    lea r13, [r15 + 10]
    add r13, rax
    mov rdi, r13
    call font_be16
    mov r9d, eax
    lea r14, [r13 + 2]
    add r14, r9
    cmp r14, rbx
    ja .Lfont_glyph_outline_bad
    mov r15, r14              # first flag byte

    # Decode the run-length encoded point flags.
    mov r13d, dword ptr [rip + font_glyph_point_count]
    xor r14d, r14d
.Lfont_glyph_outline_flags_loop:
    cmp r14d, r13d
    jae .Lfont_glyph_outline_flags_done
    cmp r15, rbx
    jae .Lfont_glyph_outline_bad
    movzx r8d, byte ptr [r15]
    inc r15
    mov r9d, 1
    test r8d, 8               # REPEAT_FLAG
    jz .Lfont_glyph_outline_flags_fill
    cmp r15, rbx
    jae .Lfont_glyph_outline_bad
    movzx r9d, byte ptr [r15]
    inc r15
    inc r9d                   # repeat count includes the current flag
.Lfont_glyph_outline_flags_fill:
    mov eax, r13d
    sub eax, r14d
    cmp r9d, eax
    ja .Lfont_glyph_outline_bad
.Lfont_glyph_outline_flags_fill_loop:
    lea rdi, [rip + font_glyph_point_flags]
    mov byte ptr [rdi + r14], r8b
    inc r14d
    dec r9d
    jnz .Lfont_glyph_outline_flags_fill_loop
    jmp .Lfont_glyph_outline_flags_loop

.Lfont_glyph_outline_flags_done:
    # X coordinates: short-vector, same/positive, or signed 16-bit delta.
    mov r13d, dword ptr [rip + font_glyph_point_count]
    xor r14d, r14d
    xor r10d, r10d
.Lfont_glyph_outline_x_loop:
    cmp r14d, r13d
    jae .Lfont_glyph_outline_x_done
    lea rdi, [rip + font_glyph_point_flags]
    movzx r8d, byte ptr [rdi + r14]
    test r8d, 2               # X_SHORT_VECTOR
    jz .Lfont_glyph_outline_x_not_short
    cmp r15, rbx
    jae .Lfont_glyph_outline_bad
    movzx eax, byte ptr [r15]
    inc r15
    test r8d, 16              # X_IS_SAME_OR_POSITIVE
    jnz .Lfont_glyph_outline_x_delta
    neg eax
    jmp .Lfont_glyph_outline_x_delta
.Lfont_glyph_outline_x_not_short:
    test r8d, 16
    jnz .Lfont_glyph_outline_x_zero
    lea rax, [r15 + 2]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r15
    call font_be16
    movsx eax, ax
    add r15, 2
    jmp .Lfont_glyph_outline_x_delta
.Lfont_glyph_outline_x_zero:
    xor eax, eax
.Lfont_glyph_outline_x_delta:
    add r10d, eax
    lea rdi, [rip + font_glyph_points_x]
    mov eax, r14d
    mov dword ptr [rdi + rax * 4], r10d
    inc r14d
    jmp .Lfont_glyph_outline_x_loop
.Lfont_glyph_outline_x_done:
    # Y coordinates use the corresponding bit pair in each point flag.
    mov r13d, dword ptr [rip + font_glyph_point_count]
    xor r14d, r14d
    xor r10d, r10d
.Lfont_glyph_outline_y_loop:
    cmp r14d, r13d
    jae .Lfont_glyph_outline_success
    lea rdi, [rip + font_glyph_point_flags]
    movzx r8d, byte ptr [rdi + r14]
    test r8d, 4               # Y_SHORT_VECTOR
    jz .Lfont_glyph_outline_y_not_short
    cmp r15, rbx
    jae .Lfont_glyph_outline_bad
    movzx eax, byte ptr [r15]
    inc r15
    test r8d, 32              # Y_IS_SAME_OR_POSITIVE
    jnz .Lfont_glyph_outline_y_delta
    neg eax
    jmp .Lfont_glyph_outline_y_delta
.Lfont_glyph_outline_y_not_short:
    test r8d, 32
    jnz .Lfont_glyph_outline_y_zero
    lea rax, [r15 + 2]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r15
    call font_be16
    movsx eax, ax
    add r15, 2
    jmp .Lfont_glyph_outline_y_delta
.Lfont_glyph_outline_y_zero:
    xor eax, eax
.Lfont_glyph_outline_y_delta:
    add r10d, eax
    lea rdi, [rip + font_glyph_points_y]
    mov eax, r14d
    mov dword ptr [rdi + rax * 4], r10d
    inc r14d
    jmp .Lfont_glyph_outline_y_loop

.Lfont_glyph_outline_composite:
    # Composite header bounds are retained for the all-empty-component case.
    lea rdi, [r15 + 2]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_x_min], eax
    lea rdi, [r15 + 4]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_y_min], eax
    lea rdi, [r15 + 6]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_x_max], eax
    lea rdi, [r15 + 8]
    call font_be16
    movsx eax, ax
    mov dword ptr [rip + font_glyph_y_max], eax
    lea r13, [r15 + 10]
    mov dword ptr [rsp + 36], 0

.Lfont_glyph_outline_component_loop:
    lea rax, [r13 + 4]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    mov dword ptr [rsp], eax
    add r13, 2
    mov rdi, r13
    call font_be16
    mov dword ptr [rsp + 4], eax
    add r13, 2
    cmp eax, dword ptr [rip + font_num_glyphs]
    jae .Lfont_glyph_outline_bad
    inc dword ptr [rsp + 36]
    cmp dword ptr [rsp + 36], 256
    ja .Lfont_glyph_outline_bad

    # Reject reserved high bits and the reserved bit 4 in component flags.
    mov eax, dword ptr [rsp]
    test eax, 0xe000
    jnz .Lfont_glyph_outline_bad
    test eax, 0x0010
    jnz .Lfont_glyph_outline_bad
    mov edx, eax
    and edx, 0x00c8
    cmp edx, 0x0008
    je .Lfont_glyph_outline_transform_ok
    cmp edx, 0x0040
    je .Lfont_glyph_outline_transform_ok
    cmp edx, 0x0080
    jne .Lfont_glyph_outline_transform_zero
    jmp .Lfont_glyph_outline_transform_ok
.Lfont_glyph_outline_transform_zero:
    test edx, edx
    jnz .Lfont_glyph_outline_bad
.Lfont_glyph_outline_transform_ok:
    mov eax, dword ptr [rsp]
    mov edx, eax
    and edx, 0x1800
    cmp edx, 0x1800
    je .Lfont_glyph_outline_bad
    mov dword ptr [rsp + 16], 16384
    mov dword ptr [rsp + 20], 0
    mov dword ptr [rsp + 24], 0
    mov dword ptr [rsp + 28], 16384

    # Read the two arguments. XY offsets are signed; point numbers are unsigned.
    test eax, 1
    jz .Lfont_glyph_outline_args_bytes
    lea rax, [r13 + 4]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    test dword ptr [rsp], 2
    jz .Lfont_glyph_outline_args_words_points
    movsx eax, ax
    jmp .Lfont_glyph_outline_args_words_store
.Lfont_glyph_outline_args_words_points:
    movzx eax, ax
.Lfont_glyph_outline_args_words_store:
    mov dword ptr [rsp + 8], eax
    lea rdi, [r13 + 2]
    call font_be16
    test dword ptr [rsp], 2
    jz .Lfont_glyph_outline_args_words_points_y
    movsx eax, ax
    jmp .Lfont_glyph_outline_args_words_store_y
.Lfont_glyph_outline_args_words_points_y:
    movzx eax, ax
.Lfont_glyph_outline_args_words_store_y:
    mov dword ptr [rsp + 12], eax
    add r13, 4
    jmp .Lfont_glyph_outline_args_ready
.Lfont_glyph_outline_args_bytes:
    lea rax, [r13 + 2]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    movzx eax, byte ptr [r13]
    test dword ptr [rsp], 2
    jz .Lfont_glyph_outline_args_bytes_points
    movsx eax, al
    jmp .Lfont_glyph_outline_args_bytes_store
.Lfont_glyph_outline_args_bytes_points:
    movzx eax, al
.Lfont_glyph_outline_args_bytes_store:
    mov dword ptr [rsp + 8], eax
    movzx eax, byte ptr [r13 + 1]
    test dword ptr [rsp], 2
    jz .Lfont_glyph_outline_args_bytes_points_y
    movsx eax, al
    jmp .Lfont_glyph_outline_args_bytes_store_y
.Lfont_glyph_outline_args_bytes_points_y:
    movzx eax, al
.Lfont_glyph_outline_args_bytes_store_y:
    mov dword ptr [rsp + 12], eax
    add r13, 2

.Lfont_glyph_outline_args_ready:
    mov eax, dword ptr [rsp + 8]
    mov dword ptr [rsp + 40], eax
    mov eax, dword ptr [rsp + 12]
    mov dword ptr [rsp + 44], eax
    # Offset-coordinate flags have no meaning for point-matching arguments.
    test dword ptr [rsp], 2
    jnz .Lfont_glyph_outline_args_flags_ok
    test dword ptr [rsp], 0x1800
    jnz .Lfont_glyph_outline_bad
.Lfont_glyph_outline_args_flags_ok:
    # Read one of the three mutually exclusive F2Dot14 transform encodings.
    mov eax, dword ptr [rsp]
    test eax, 8
    jz .Lfont_glyph_outline_check_xy_scale
    lea rax, [r13 + 2]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 16], eax
    mov dword ptr [rsp + 28], eax
    add r13, 2
    jmp .Lfont_glyph_outline_transform_ready
.Lfont_glyph_outline_check_xy_scale:
    test eax, 0x0040
    jz .Lfont_glyph_outline_check_2x2
    lea rax, [r13 + 4]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 16], eax
    lea rdi, [r13 + 2]
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 28], eax
    add r13, 4
    jmp .Lfont_glyph_outline_transform_ready
.Lfont_glyph_outline_check_2x2:
    test eax, 0x0080
    jz .Lfont_glyph_outline_transform_ready
    lea rax, [r13 + 8]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 16], eax
    lea rdi, [r13 + 2]
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 20], eax
    lea rdi, [r13 + 4]
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 24], eax
    lea rdi, [r13 + 6]
    call font_be16
    movsx eax, ax
    mov dword ptr [rsp + 28], eax
    add r13, 8

.Lfont_glyph_outline_transform_ready:
    # Apply SCALED_COMPONENT_OFFSET when explicitly requested. The documented
    # default remains unscaled; point matching computes its own translation.
    test dword ptr [rsp], 2
    jz .Lfont_glyph_outline_offset_ready
    test dword ptr [rsp], 0x0800
    jz .Lfont_glyph_outline_offset_ready
    movsxd rax, dword ptr [rsp + 40]
    movsxd rdx, dword ptr [rsp + 44]
    movsxd rcx, dword ptr [rsp + 16]
    imul rax, rcx
    movsxd rcx, dword ptr [rsp + 24]
    imul rdx, rcx
    add rax, rdx
    sar rax, 14
    mov rdx, 0x7fffffff
    cmp rax, rdx
    jg .Lfont_glyph_outline_bad
    mov rdx, -2147483648
    cmp rax, rdx
    jl .Lfont_glyph_outline_bad
    mov dword ptr [rsp + 8], eax
    movsxd rax, dword ptr [rsp + 40]
    movsxd rdx, dword ptr [rsp + 44]
    movsxd rcx, dword ptr [rsp + 20]
    imul rax, rcx
    movsxd rcx, dword ptr [rsp + 28]
    imul rdx, rcx
    add rax, rdx
    sar rax, 14
    mov rdx, 0x7fffffff
    cmp rax, rdx
    jg .Lfont_glyph_outline_bad
    mov rdx, -2147483648
    cmp rax, rdx
    jl .Lfont_glyph_outline_bad
    mov dword ptr [rsp + 12], eax
.Lfont_glyph_outline_offset_ready:
    # Preserve the parent aggregate, then recursively decode the component.
    mov edi, dword ptr [rsp + 32]
    call font_outline_frame_save
    mov edi, dword ptr [rsp + 4]
    mov esi, dword ptr [rsp + 32]
    inc esi
    call font_glyph_load_outline_internal
    test eax, eax
    js .Lfont_glyph_outline_child_failed

    mov edi, dword ptr [rsp + 32]
    mov esi, dword ptr [rsp + 8]
    mov edx, dword ptr [rsp + 12]
    mov ecx, dword ptr [rsp + 16]
    mov r8d, dword ptr [rsp + 20]
    mov r9d, dword ptr [rsp + 24]
    mov r10d, dword ptr [rsp + 28]
    xor r11d, r11d
    test dword ptr [rsp], 2
    setnz r11b
    call font_outline_frame_merge
    test eax, eax
    js .Lfont_glyph_outline_bad

    # Continue with another component, or consume the optional instruction
    # payload after the final component.
    test dword ptr [rsp], 0x0020
    jnz .Lfont_glyph_outline_component_loop
    test dword ptr [rsp], 0x0100
    jz .Lfont_glyph_outline_success
    lea rax, [r13 + 2]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    mov rdi, r13
    call font_be16
    mov edx, eax
    add r13, 2
    lea rax, [r13 + rdx]
    cmp rax, rbx
    ja .Lfont_glyph_outline_bad
    jmp .Lfont_glyph_outline_success

.Lfont_glyph_outline_child_failed:
    jmp .Lfont_glyph_outline_bad
.Lfont_glyph_outline_bad:
    mov dword ptr [rip + font_glyph_contour_count], 0
    mov dword ptr [rip + font_glyph_point_count], 0
    mov eax, -1
    jmp .Lfont_glyph_outline_return
.Lfont_glyph_outline_success:
    xor eax, eax
.Lfont_glyph_outline_return:
    add rsp, 56
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size font_glyph_load_outline_internal, . - font_glyph_load_outline_internal

# Initialize the optional font engine. NEKOEDIT_DISABLE_FONT=1 forces the
# embedded bitmap for deterministic legacy tests. Otherwise explicit
# NEKOEDIT_FONT takes precedence over deterministic common system-font paths.
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
    mov dword ptr [rip + font_probe_advance_space], 0
    # The test harness can request the legacy embedded renderer explicitly.
    # This keeps old pixel-level UI tests deterministic while the font fixture
    # separately exercises the real outline-to-framebuffer path.
    mov r12, qword ptr [rip + process_envp]
    test r12, r12
    jz .Lfont_find_override
.Lfont_disable_next:
    mov r13, qword ptr [r12]
    test r13, r13
    jz .Lfont_find_override
    lea r14, [rip + font_disable_env_key]
    mov r15d, font_disable_env_key_end - font_disable_env_key
.Lfont_disable_compare:
    test r15d, r15d
    jz .Lfont_disable_equal
    mov al, byte ptr [r13]
    cmp al, byte ptr [r14]
    jne .Lfont_disable_advance
    inc r13
    inc r14
    dec r15d
    jmp .Lfont_disable_compare
.Lfont_disable_equal:
    cmp byte ptr [r13], '='
    jne .Lfont_disable_advance
    cmp byte ptr [r13 + 1], '1'
    jne .Lfont_disable_advance
    cmp byte ptr [r13 + 2], 0
    je .Lfont_init_failed
.Lfont_disable_advance:
    add r12, 8
    jmp .Lfont_disable_next

.Lfont_find_override:
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
    lea rdi, [r13 + 1]
    call font_try_path
    test rax, rax
    jz .Lfont_init_success
    jmp .Lfont_try_defaults
.Lfont_env_advance:
    add r12, 8
    jmp .Lfont_env_next

.Lfont_try_defaults:
    # Deterministic fallback discovery; NEKOEDIT_FONT has already been tried.
    lea rbx, [rip + font_default_candidates]
.Lfont_default_candidate_loop:
    mov rdi, qword ptr [rbx]
    test rdi, rdi
    jz .Lfont_init_failed
    call font_try_path
    test rax, rax
    jz .Lfont_init_success
    add rbx, 8
    jmp .Lfont_default_candidate_loop
.Lfont_init_success:
    mov edi, 'A'
    call font_codepoint_advance_pixels
    mov dword ptr [rip + font_probe_advance_A], eax
    mov edi, 'B'
    call font_codepoint_advance_pixels
    mov dword ptr [rip + font_probe_advance_B], eax
    mov edi, 0x20
    mov esi, 10
    call font_codepoint_advance_pixels_size
    mov dword ptr [rip + font_probe_advance_space], eax
    mov edi, 1
    mov esi, 12
    call font_rasterize_glyph
    mov dword ptr [rip + font_probe_raster_result], eax
    mov eax, dword ptr [rip + font_bitmap_width]
    mov dword ptr [rip + font_probe_raster_width], eax
    mov eax, dword ptr [rip + font_bitmap_height]
    mov dword ptr [rip + font_probe_raster_height], eax
    mov eax, dword ptr [rip + font_bitmap_pixel_count]
    mov dword ptr [rip + font_probe_raster_pixels], eax
    cmp dword ptr [rip + font_num_glyphs], 10
    jb .Lfont_init_no_curve_probe
    mov edi, 9
    mov esi, 12
    call font_rasterize_glyph
    mov dword ptr [rip + font_probe_curve_result], eax
    mov eax, dword ptr [rip + font_bitmap_width]
    mov dword ptr [rip + font_probe_curve_width], eax
    mov eax, dword ptr [rip + font_bitmap_height]
    mov dword ptr [rip + font_probe_curve_height], eax
    mov eax, dword ptr [rip + font_bitmap_pixel_count]
    mov dword ptr [rip + font_probe_curve_pixels], eax
    jmp .Lfont_init_success_done
.Lfont_init_no_curve_probe:
    mov dword ptr [rip + font_probe_curve_result], -1
.Lfont_init_success_done:
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
