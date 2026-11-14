#define _GNU_SOURCE 1
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "../src/editor/gap_buffer.h"

#define DOCUMENT_LENGTH 19u
#define MAX_GAP_SIZE 31u

int main(void)
{
    static const uint32_t gap_sizes[] = {1u, 7u, 16u, MAX_GAP_SIZE};
    uint8_t logical[DOCUMENT_LENGTH];
    uint8_t physical[DOCUMENT_LENGTH + MAX_GAP_SIZE];

    for (uint32_t i = 0; i < DOCUMENT_LENGTH; ++i)
        logical[i] = (uint8_t)(i * 37u + 11u);

    for (uint32_t g = 0; g < sizeof(gap_sizes) / sizeof(gap_sizes[0]); ++g) {
        uint32_t gap_size = gap_sizes[g];
        for (uint32_t gap_at = 0; gap_at <= DOCUMENT_LENGTH; ++gap_at) {
            memset(physical, 0xa5, sizeof(physical));
            for (uint32_t i = 0; i < gap_at; ++i)
                physical[i] = logical[i];
            for (uint32_t i = gap_at; i < DOCUMENT_LENGTH; ++i)
                physical[i + gap_size] = logical[i];

            for (uint32_t begin = 0; begin <= DOCUMENT_LENGTH; ++begin) {
                for (uint32_t end = begin; end <= DOCUMENT_LENGTH; ++end) {
                    uint8_t actual[DOCUMENT_LENGTH];
                    uint32_t length = end - begin;
                    memset(actual, 0xcc, sizeof(actual));
                    gap_buffer_copy_range(actual, physical, gap_at,
                                          gap_at + gap_size, begin, end);
                    if (memcmp(actual, logical + begin, length) != 0) {
                        fprintf(stderr,
                                "clipboard gap-copy mismatch: gap=%u at=%u range=[%u,%u)\n",
                                gap_size, gap_at, begin, end);
                        return 1;
                    }
                }
            }
        }
    }

    puts("PASS: gap-buffer range copy covers every selection across every tested gap position and size");
    return 0;
}
