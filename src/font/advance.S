.intel_syntax noprefix

# Assembly-side fast path for the active document font's cached ASCII advances.
# The cache remains owned and invalidated by rasterizer.c. Only nonzero entries
# are read here; misses and all non-ASCII code points use the C implementation.

.extern font_loaded
.extern doc_font_size
.extern font_ascii_advance_cache
.extern font_codepoint_advance_pixels_size

.ifdef NEKOEDIT_TESTING
.section .bss
.balign 4
.global font_ascii_advance_fast_hits
font_ascii_advance_fast_hits: .long 0
.endif

.section .text.font_codepoint_advance_pixels,"ax",@progbits
.type font_codepoint_advance_pixels, @function
.global font_codepoint_advance_pixels
font_codepoint_advance_pixels:
    # Preserve the legacy no-font result without crossing into C.
    cmp dword ptr [rip + font_loaded], 0
    je .Lfont_advance_default

    # doc_font_size is normalized exactly as in the former C wrapper.
    mov esi, dword ptr [rip + doc_font_size]
    test esi, esi
    jz .Lfont_advance_default_size
    cmp esi, 32
    ja .Lfont_advance_default_size
    jmp .Lfont_advance_size_ready

.Lfont_advance_default_size:
    mov esi, 12

.Lfont_advance_size_ready:
    # Only ASCII has a direct byte-indexed advance cache. Zero denotes a miss.
    cmp edi, 128
    jae .Lfont_advance_slow
    mov eax, esi
    shl eax, 7
    add eax, edi
    lea rdx, [rip + font_ascii_advance_cache]
    movzx eax, byte ptr [rdx + rax]
    test eax, eax
    jz .Lfont_advance_slow

.ifdef NEKOEDIT_TESTING
    inc dword ptr [rip + font_ascii_advance_fast_hits]
.endif
    ret

.Lfont_advance_slow:
    # C resolves misses and Unicode code points, and populates the ASCII cache.
    # Entry RSP is 8 mod 16; align before the nested System V call.
    sub rsp, 8
    call font_codepoint_advance_pixels_size
    add rsp, 8
    ret

.Lfont_advance_default:
    mov eax, 8
    ret
.size font_codepoint_advance_pixels, . - font_codepoint_advance_pixels

.section .note.GNU-stack,"",@progbits
