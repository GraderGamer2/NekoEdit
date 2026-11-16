#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int32_t font_loaded;
int32_t font_units_per_em = 1000;
int32_t font_num_glyphs = 512;
int32_t font_ascent = 800;
int32_t doc_font_size = 12;
int32_t font_glyph_contour_count;
int32_t font_glyph_point_count;
int32_t font_glyph_contour_ends[256];
uint8_t font_glyph_point_flags[4096];
int32_t font_glyph_points_x[4096];
int32_t font_glyph_points_y[4096];

extern uint8_t font_ascii_advance_cache[33][128];
extern uint32_t font_ascii_advance_fast_hits;
extern void font_cache_clear(void);
extern int font_codepoint_advance_pixels(uint32_t codepoint);

static void fail(const char *message) {
    fprintf(stderr, "advance test failed: %s\n", message);
    exit(1);
}

uint32_t font_cmap_lookup(uint32_t codepoint) {
    if (codepoint < 128u) return codepoint + 1u;
    if (codepoint == 0x03a9u) return 200u;
    return 0u;
}

uint32_t font_glyph_advance(uint32_t glyph_id) {
    switch (glyph_id) {
    case (uint32_t)'A' + 1u: return 650u;
    case (uint32_t)'B' + 1u: return 420u;
    case (uint32_t)' ' + 1u: return 250u;
    case (uint32_t)'?' + 1u: return 500u;
    case 200u: return 700u;
    default: return 510u;
    }
}

int font_glyph_load_outline(uint32_t glyph_id) {
    (void)glyph_id;
    return -1;
}

static void expect_advance(uint32_t cp, int expected, const char *label) {
    int actual = font_codepoint_advance_pixels(cp);
    if (actual != expected) {
        fprintf(stderr, "%s: expected %d, got %d\n", label, expected, actual);
        exit(1);
    }
}

int main(void) {
    uint32_t hits_before;

    font_loaded = 0;
    expect_advance('A', 8, "no-font ASCII fallback");
    if (font_ascii_advance_cache[12]['A'] != 0u)
        fail("no-font fallback unexpectedly populated the TrueType cache");

    font_loaded = 1;
    doc_font_size = 12;
    font_cache_clear();

    expect_advance('A', 8, "cold A advance");
    if (font_ascii_advance_cache[12]['A'] != 8u)
        fail("cold A lookup did not populate its cache slot");
    hits_before = font_ascii_advance_fast_hits;

    expect_advance('A', 8, "warm A advance");
    if (font_ascii_advance_fast_hits != hits_before + 1u)
        fail("warm A lookup did not use the assembly fast path");

    expect_advance('B', 5, "cold B advance");
    expect_advance('B', 5, "warm B advance");
    expect_advance(' ', 3, "cold space advance");
    expect_advance(' ', 3, "warm space advance");

    expect_advance('!', 6, "unknown ASCII fallback");
    if (font_ascii_advance_cache[12]['!'] != 6u)
        fail("unknown ASCII fallback width was not cached");
    expect_advance('!', 6, "warm unknown ASCII fallback");

    doc_font_size = 16;
    expect_advance('A', 10, "16px A advance");
    if (font_ascii_advance_cache[16]['A'] != 10u)
        fail("16px A advance was stored in the wrong cache row");

    doc_font_size = 0;
    expect_advance('A', 8, "zero-size normalization");
    doc_font_size = 33;
    expect_advance('A', 8, "oversized normalization");
    doc_font_size = -1;
    expect_advance('A', 8, "negative-size normalization");

    doc_font_size = 12;
    hits_before = font_ascii_advance_fast_hits;
    if (font_codepoint_advance_pixels(0x03a9u) != 9)
        fail("Unicode C fallback returned the wrong advance");
    if (font_ascii_advance_fast_hits != hits_before)
        fail("Unicode code point incorrectly used the ASCII fast path");

    font_loaded = 0;
    expect_advance('A', 8, "font-disabled cached ASCII result");

    font_loaded = 1;
    font_cache_clear();
    if (font_ascii_advance_cache[12]['A'] != 0u ||
        font_ascii_advance_cache[16]['A'] != 0u)
        fail("font cache clear left stale ASCII advances");
    expect_advance('A', 8, "advance after cache invalidation");

    puts("Assembly ASCII advance cache tests passed.");
    return 0;
}
