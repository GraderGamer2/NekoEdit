#ifndef NEKOEDIT_GAP_BUFFER_H
#define NEKOEDIT_GAP_BUFFER_H

#include <stdint.h>

/* Copy a contiguous byte span without introducing a libc dependency. */
static inline void gap_buffer_copy_bytes(uint8_t *destination,
                                         const uint8_t *source,
                                         uint32_t length)
{
    __asm__ volatile ("rep movsb"
        : "+D"(destination), "+S"(source), "+c"(length)
        :
        : "memory");
}

/* Copy logical [begin,end) from a gap buffer. The logical range crosses the
 * gap at most once, so it can be transferred as no more than two bulk spans. */
static inline void gap_buffer_copy_range(uint8_t *destination,
                                         const uint8_t *buffer,
                                         uint32_t gap_start,
                                         uint32_t gap_end,
                                         uint32_t begin,
                                         uint32_t end)
{
    uint32_t length = end - begin;
    uint32_t before = 0;
    uint32_t gap_size = gap_end - gap_start;

    if (begin < gap_start) {
        before = gap_start - begin;
        if (before > length)
            before = length;
    }
    if (before)
        gap_buffer_copy_bytes(destination, buffer + begin, before);

    if (length > before) {
        uint32_t after_offset = begin + before;
        gap_buffer_copy_bytes(destination + before,
                              buffer + after_offset + gap_size,
                              length - before);
    }
}

#endif
