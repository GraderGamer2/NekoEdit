#define _GNU_SOURCE 1
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TEST_POINT_CAPACITY 4096u
#define TEST_CONTOUR_CAPACITY 256u
#define GLYPH_COUNT 128u
#define TOTAL_TEST_GLYPHS (GLYPH_COUNT * 2u)
#define COLD_RASTER_ITERATIONS 256u
#define WARM_DRAW_ITERATIONS 50000u
#define BENCH_SAMPLE_COUNT 7u
#define SURFACE_WIDTH 128
#define SURFACE_HEIGHT 64
#define SURFACE_STRIDE (SURFACE_WIDTH * 4)

int32_t font_loaded = 1;
int32_t font_units_per_em = 1000;
int32_t font_num_glyphs = 512;
uint32_t outline_load_count;
int32_t font_ascent = 800;
int32_t doc_font_size = 12;
int32_t font_glyph_contour_count;
int32_t font_glyph_point_count;
int32_t font_glyph_contour_ends[TEST_CONTOUR_CAPACITY];
uint8_t font_glyph_point_flags[TEST_POINT_CAPACITY];
int32_t font_glyph_points_x[TEST_POINT_CAPACITY];
int32_t font_glyph_points_y[TEST_POINT_CAPACITY];

extern uint8_t font_bitmap_pixels[128u * 128u];
extern uint32_t font_bitmap_width, font_bitmap_height, font_bitmap_pixel_count;
extern int font_rasterize_glyph(uint32_t glyph_id, uint32_t size);
extern void font_cache_clear(void);
extern int font_draw_codepoint_size(
    uint32_t codepoint, int32_t x, int32_t y, uint8_t *surface,
    int32_t width, int32_t height, int32_t stride,
    uint32_t size, uint32_t transform,
    int32_t surface_width, int32_t surface_height
);

uint32_t font_cmap_lookup(uint32_t codepoint) {
    return codepoint >= 33u && codepoint < 33u + TOTAL_TEST_GLYPHS
        ? codepoint : 0u;
}

uint32_t font_glyph_advance(uint32_t glyph_id) {
    (void)glyph_id;
    return 560u;
}

/* Deterministic eight-point contour, supplied through the same outline-loader
 * interface used by sfnt.S. This isolates rasterizer/cache work from font file
 * I/O, installed fonts, Wayland, and compositor scheduling. */
int font_glyph_load_outline(uint32_t glyph_id) {
    static const int32_t outline_x[8] = {
        160, 420, 520, 520, 420, 160, 60, 60
    };
    static const int32_t outline_y[8] = {
        80, 80, 180, 580, 680, 680, 580, 180
    };
    if (glyph_id == 0u || glyph_id >= 512u) return -1;
    ++outline_load_count;
    font_glyph_contour_count = 1;
    font_glyph_point_count = 8;
    font_glyph_contour_ends[0] = 7;
    for (uint32_t i = 0; i < 8u; ++i) {
        font_glyph_points_x[i] = outline_x[i] + (int32_t)(glyph_id & 3u);
        font_glyph_points_y[i] = outline_y[i];
        font_glyph_point_flags[i] = 1u;
    }
    return 0;
}

static uint64_t monotonic_raw_ns(void) {
    struct timespec now;
    if (clock_gettime(CLOCK_MONOTONIC_RAW, &now) != 0) {
        perror("clock_gettime(CLOCK_MONOTONIC_RAW)");
        exit(2);
    }
    return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

static void fail(const char *message) {
    fprintf(stderr, "rasterizer benchmark setup failed: %s\n", message);
    exit(1);
}

static uint64_t median_sample(const uint64_t *samples) {
    uint64_t sorted[BENCH_SAMPLE_COUNT];
    for (uint32_t i = 0; i < BENCH_SAMPLE_COUNT; ++i) {
        uint32_t pos = i;
        while (pos && sorted[pos - 1] > samples[i]) {
            sorted[pos] = sorted[pos - 1];
            --pos;
        }
        sorted[pos] = samples[i];
    }
    return sorted[BENCH_SAMPLE_COUNT / 2u];
}

static void print_samples(const char *label, const uint64_t *samples,
                          uint32_t iterations) {
    printf("%s: %u samples x %u iterations, median %.1f ns/iteration; samples=",
           label, BENCH_SAMPLE_COUNT, iterations,
           (double)median_sample(samples) / (double)iterations);
    for (uint32_t i = 0; i < BENCH_SAMPLE_COUNT; ++i) {
        printf("%s%.1f", i ? "," : "[",
               (double)samples[i] / (double)iterations);
    }
    puts("]");
}

int main(void) {
    uint32_t framebuffer[SURFACE_WIDTH * SURFACE_HEIGHT];
    uint64_t cold_samples[BENCH_SAMPLE_COUNT], warm_samples[BENCH_SAMPLE_COUNT];
    uint64_t checksum = 0;
    struct timespec resolution;

    if (clock_getres(CLOCK_MONOTONIC_RAW, &resolution) != 0)
        fail("CLOCK_MONOTONIC_RAW resolution query failed");

    for (uint32_t sample = 0; sample < BENCH_SAMPLE_COUNT; ++sample) {
        uint64_t start = monotonic_raw_ns();
        for (uint32_t i = 0; i < COLD_RASTER_ITERATIONS; ++i) {
            uint32_t glyph_id = 33u + (i % GLYPH_COUNT);
            if (font_rasterize_glyph(glyph_id, 12u) != 0)
                fail("cold glyph rasterization returned an error");
        }
        cold_samples[sample] = monotonic_raw_ns() - start;
        if (!font_bitmap_pixel_count || !font_bitmap_width || !font_bitmap_height)
            fail("cold rasterization produced an empty mask");
    }

    /* Prime every entry, then repeatedly draw a deterministic pseudorandom
     * sequence over the full cache working set. Each sample starts with the
     * same framebuffer and key sequence; the cache remains warm throughout. */
    font_cache_clear();
    outline_load_count = 0;
    for (uint32_t i = 0; i < GLYPH_COUNT; ++i) {
        uint32_t codepoint = 33u + i;
        if (font_draw_codepoint_size(
                codepoint, (int32_t)((i & 7u) * 14u),
                (int32_t)(((i >> 3) & 3u) * 14u),
                (uint8_t *)framebuffer, SURFACE_WIDTH, SURFACE_HEIGHT,
                SURFACE_STRIDE, 12u, 0u, SURFACE_WIDTH, SURFACE_HEIGHT) != 1)
            fail("failed to populate the complete glyph cache");
    }
    if (outline_load_count != GLYPH_COUNT)
        fail("warm-cache priming did not rasterize exactly 128 unique glyphs");

    for (uint32_t sample = 0; sample < BENCH_SAMPLE_COUNT; ++sample) {
        for (uint32_t i = 0; i < SURFACE_WIDTH * SURFACE_HEIGHT; ++i)
            framebuffer[i] = 0xff252a33u;
        uint32_t random_state = 0x4e454b4fu;
        uint64_t start = monotonic_raw_ns();
        for (uint32_t i = 0; i < WARM_DRAW_ITERATIONS; ++i) {
            random_state = random_state * 1664525u + 1013904223u;
            uint32_t codepoint = 33u + ((random_state >> 16) & 127u);
            int32_t x = (int32_t)((i & 7u) * 14u);
            int32_t y = (int32_t)(((i >> 3) & 3u) * 14u);
            if (font_draw_codepoint_size(
                    codepoint, x, y, (uint8_t *)framebuffer,
                    SURFACE_WIDTH, SURFACE_HEIGHT, SURFACE_STRIDE,
                    12u, 0u, SURFACE_WIDTH, SURFACE_HEIGHT) != 1)
                fail("warm glyph-cache draw returned an error");
        }
        warm_samples[sample] = monotonic_raw_ns() - start;
    }
    if (outline_load_count != GLYPH_COUNT)
        fail("warm working-set draws unexpectedly rerasterized a cached glyph");
    for (uint32_t i = 0; i < SURFACE_WIDTH * SURFACE_HEIGHT; ++i)
        checksum += framebuffer[i];

    /* Force every LRU slot to be replaced with a disjoint 128-glyph set. The
     * second pass must hit those entries, and clearing must make them reload. */
    for (uint32_t i = 0; i < GLYPH_COUNT; ++i) {
        uint32_t codepoint = 33u + GLYPH_COUNT + i;
        if (font_draw_codepoint_size(
                codepoint, (int32_t)((i & 7u) * 14u),
                (int32_t)(((i >> 3) & 3u) * 14u),
                (uint8_t *)framebuffer, SURFACE_WIDTH, SURFACE_HEIGHT,
                SURFACE_STRIDE, 12u, 0u, SURFACE_WIDTH, SURFACE_HEIGHT) != 1)
            fail("cache replacement pass failed");
    }
    if (outline_load_count != TOTAL_TEST_GLYPHS)
        fail("replacing the full cache did not rasterize the second glyph set");
    for (uint32_t i = 0; i < GLYPH_COUNT; ++i) {
        uint32_t codepoint = 33u + GLYPH_COUNT + i;
        if (font_draw_codepoint_size(
                codepoint, (int32_t)((i & 7u) * 14u),
                (int32_t)(((i >> 3) & 3u) * 14u),
                (uint8_t *)framebuffer, SURFACE_WIDTH, SURFACE_HEIGHT,
                SURFACE_STRIDE, 12u, 0u, SURFACE_WIDTH, SURFACE_HEIGHT) != 1)
            fail("replacement working set did not produce cache hits");
    }
    if (outline_load_count != TOTAL_TEST_GLYPHS)
        fail("replacement working set was rerasterized unexpectedly");
    font_cache_clear();
    for (uint32_t i = 0; i < GLYPH_COUNT; ++i) {
        uint32_t codepoint = 33u + GLYPH_COUNT + i;
        if (font_draw_codepoint_size(
                codepoint, (int32_t)((i & 7u) * 14u),
                (int32_t)(((i >> 3) & 3u) * 14u),
                (uint8_t *)framebuffer, SURFACE_WIDTH, SURFACE_HEIGHT,
                SURFACE_STRIDE, 12u, 0u, SURFACE_WIDTH, SURFACE_HEIGHT) != 1)
            fail("drawing after cache clear failed");
    }
    if (outline_load_count != TOTAL_TEST_GLYPHS + GLYPH_COUNT)
        fail("font_cache_clear left stale cache entries behind");

    puts("NekoEdit rasterizer microbenchmark (synthetic 8-point outline)");
#ifdef FONT_CACHE_LINEAR_REFERENCE
    puts("cache implementation: pre-hash linear LRU reference");
#else
    puts("cache implementation: hash-indexed warm hits");
#endif
    printf("CLOCK_MONOTONIC_RAW resolution: %ld ns\n",
           resolution.tv_sec * 1000000000L + resolution.tv_nsec);
    print_samples("cold rasterization", cold_samples, COLD_RASTER_ITERATIONS);
    print_samples("warm 128-glyph cache draw", warm_samples, WARM_DRAW_ITERATIONS);
#ifdef FONT_CACHE_LINEAR_REFERENCE
    printf("cache correctness: warm reuse, LRU replacement, and clear passed (%u outline loads)\n",
           outline_load_count);
#else
    printf("cache correctness: hit reuse, collision chains, LRU replacement, and clear passed (%u outline loads)\n",
           outline_load_count);
#endif
    printf("framebuffer checksum: %" PRIu64 "\n", checksum);
    return 0;
}
