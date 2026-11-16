#define _GNU_SOURCE 1
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SAMPLE_COUNT 7u
#define ITERATIONS 5000000u
#define TEXT_LENGTH 32u

int32_t font_loaded = 1;
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

extern void font_cache_clear(void);
extern int font_codepoint_advance_pixels(uint32_t codepoint);
extern int font_codepoint_advance_pixels_size(uint32_t codepoint, uint32_t size);

static const uint8_t workload[TEXT_LENGTH] =
    "NekoEdit: efficient ASCII advances 0123456789.";

static volatile uint64_t benchmark_sink;

uint32_t font_cmap_lookup(uint32_t codepoint) {
    if (codepoint < 128u) return codepoint + 1u;
    return 0u;
}

uint32_t font_glyph_advance(uint32_t glyph_id) {
    return 300u + ((glyph_id * 37u) % 401u);
}

int font_glyph_load_outline(uint32_t glyph_id) {
    (void)glyph_id;
    return -1;
}

static __attribute__((noinline)) int reference_advance(uint32_t codepoint) {
    uint32_t size = (uint32_t)doc_font_size;
    if (!size || size > 32u) size = 12u;
    return font_codepoint_advance_pixels_size(codepoint, size);
}

static uint64_t monotonic_raw_ns(void) {
    struct timespec now;
    if (clock_gettime(CLOCK_MONOTONIC_RAW, &now) != 0) {
        perror("clock_gettime");
        exit(2);
    }
    return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

static uint64_t run_assembly(uint32_t iterations) {
    uint64_t sum = 0;
    for (uint32_t i = 0; i < iterations; ++i)
        sum += (uint32_t)font_codepoint_advance_pixels(workload[i % TEXT_LENGTH]);
    benchmark_sink ^= sum;
    return sum;
}

static uint64_t run_reference(uint32_t iterations) {
    uint64_t sum = 0;
    for (uint32_t i = 0; i < iterations; ++i)
        sum += (uint32_t)reference_advance(workload[i % TEXT_LENGTH]);
    benchmark_sink ^= sum;
    return sum;
}

static uint64_t median(uint64_t values[SAMPLE_COUNT]) {
    uint64_t sorted[SAMPLE_COUNT];
    for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) {
        uint32_t j = i;
        while (j && sorted[j - 1u] > values[i]) {
            sorted[j] = sorted[j - 1u];
            --j;
        }
        sorted[j] = values[i];
    }
    return sorted[SAMPLE_COUNT / 2u];
}

int main(void) {
    uint64_t assembly_samples[SAMPLE_COUNT];
    uint64_t reference_samples[SAMPLE_COUNT];
    uint64_t assembly_checksum = 0, reference_checksum = 0;

    font_cache_clear();
    for (uint32_t cp = 0; cp < 128u; ++cp)
        (void)font_codepoint_advance_pixels(cp);

    for (uint32_t sample = 0; sample < SAMPLE_COUNT; ++sample) {
        if ((sample & 1u) == 0u) {
            uint64_t start = monotonic_raw_ns();
            assembly_checksum = run_assembly(ITERATIONS);
            assembly_samples[sample] = monotonic_raw_ns() - start;
            start = monotonic_raw_ns();
            reference_checksum = run_reference(ITERATIONS);
            reference_samples[sample] = monotonic_raw_ns() - start;
        } else {
            uint64_t start = monotonic_raw_ns();
            reference_checksum = run_reference(ITERATIONS);
            reference_samples[sample] = monotonic_raw_ns() - start;
            start = monotonic_raw_ns();
            assembly_checksum = run_assembly(ITERATIONS);
            assembly_samples[sample] = monotonic_raw_ns() - start;
        }
        if (assembly_checksum != reference_checksum) {
            fprintf(stderr, "advance benchmark checksum mismatch at sample %u\n", sample);
            return 1;
        }
    }

    uint64_t assembly_ns = median(assembly_samples);
    uint64_t reference_ns = median(reference_samples);
    double assembly_per_call = (double)assembly_ns / (double)ITERATIONS;
    double reference_per_call = (double)reference_ns / (double)ITERATIONS;
    double improvement = (reference_per_call - assembly_per_call) * 100.0 /
                         reference_per_call;

    printf("Assembly direct-cache hit: %.2f ns/character (median of %u samples)\n",
           assembly_per_call, SAMPLE_COUNT);
    printf("C cached-advance reference: %.2f ns/character (median of %u samples)\n",
           reference_per_call, SAMPLE_COUNT);
    printf("Assembly change: %.1f%% lower call cost\n", improvement);
    printf("Matching workload checksum: %" PRIu64 "\n", assembly_checksum);
    (void)benchmark_sink;
    return 0;
}
