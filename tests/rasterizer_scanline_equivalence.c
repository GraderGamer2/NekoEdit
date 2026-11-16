#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int32_t font_loaded=1;
int32_t font_units_per_em=1000;
int32_t font_num_glyphs=16;
int32_t font_ascent=820;
int32_t font_glyph_contour_count;
int32_t font_glyph_point_count;
int32_t font_glyph_contour_ends[256];
uint8_t font_glyph_point_flags[4096];
int32_t font_glyph_points_x[4096];
int32_t font_glyph_points_y[4096];

extern uint8_t font_bitmap_pixels[128u*128u];
extern uint32_t font_bitmap_width,font_bitmap_height,font_bitmap_pixel_count;
extern int32_t font_bitmap_left,font_bitmap_top;
extern int font_rasterize_glyph(uint32_t glyph_id,uint32_t size);

static void point(uint32_t index,int32_t x,int32_t y,uint8_t on_curve) {
    font_glyph_points_x[index]=x;
    font_glyph_points_y[index]=y;
    font_glyph_point_flags[index]=on_curve;
}

static void set_single_contour(uint32_t count) {
    font_glyph_contour_count=1;
    font_glyph_point_count=(int32_t)count;
    font_glyph_contour_ends[0]=(int32_t)count-1;
}

int font_glyph_load_outline(uint32_t glyph_id) {
    font_glyph_contour_count=0;
    font_glyph_point_count=0;
    switch (glyph_id) {
    case 1: /* Straight, asymmetric polygon. */
        set_single_contour(7);
        point(0,90,120,1); point(1,820,80,1); point(2,940,420,1);
        point(3,690,910,1); point(4,360,760,1); point(5,130,930,1);
        point(6,40,430,1);
        return 0;
    case 2: /* A reversed inner contour must remain a hole under non-zero winding. */
        font_glyph_contour_count=2;
        font_glyph_point_count=8;
        font_glyph_contour_ends[0]=3;
        font_glyph_contour_ends[1]=7;
        point(0,100,100,1); point(1,900,100,1);
        point(2,900,900,1); point(3,100,900,1);
        point(4,300,300,1); point(5,300,700,1);
        point(6,700,700,1); point(7,700,300,1);
        return 0;
    case 3: /* Four quadratic corners, each with an off-curve control point. */
        set_single_contour(8);
        point(0,100,100,1); point(1,500,60,0);
        point(2,900,100,1); point(3,940,500,0);
        point(4,900,900,1); point(5,500,940,0);
        point(6,100,900,1); point(7,60,500,0);
        return 0;
    case 4: /* Same-orientation overlap tests winding magnitudes greater than one. */
        font_glyph_contour_count=2;
        font_glyph_point_count=8;
        font_glyph_contour_ends[0]=3;
        font_glyph_contour_ends[1]=7;
        point(0,100,100,1); point(1,700,100,1);
        point(2,700,700,1); point(3,100,700,1);
        point(4,400,400,1); point(5,950,400,1);
        point(6,950,950,1); point(7,400,950,1);
        return 0;
    case 5: /* Negative bearings and a deep descender. */
        set_single_contour(6);
        point(0,-180,-220,1); point(1,320,-120,1);
        point(2,260,520,1); point(3,120,1040,1);
        point(4,-100,560,1); point(5,-80,40,1);
        return 0;
    case 6: /* Empty glyph outline. */
        return 0;
    default:
        return -1;
    }
}

uint32_t font_cmap_lookup(uint32_t codepoint) {
    (void)codepoint;
    return 0;
}

uint32_t font_glyph_advance(uint32_t glyph_id) {
    (void)glyph_id;
    return 500;
}

static uint64_t mix_u32(uint64_t hash,uint32_t value) {
    for (uint32_t byte=0;byte<4;++byte) {
        hash^=(uint8_t)(value>>(byte*8u));
        hash*=UINT64_C(1099511628211);
    }
    return hash;
}

int main(void) {
    static const uint32_t sizes[]={8,12,16,24,32,48,64};
    uint64_t hash=UINT64_C(1469598103934665603);
    for (uint32_t glyph=1;glyph<=6;++glyph) {
        for (uint32_t s=0;s<sizeof(sizes)/sizeof(sizes[0]);++s) {
            uint32_t size=sizes[s];
            if (font_rasterize_glyph(glyph,size)!=0) {
                fprintf(stderr,"rasterizer rejected glyph %u at %upx\n",glyph,size);
                return 1;
            }
            hash=mix_u32(hash,glyph);
            hash=mix_u32(hash,size);
            hash=mix_u32(hash,font_bitmap_width);
            hash=mix_u32(hash,font_bitmap_height);
            hash=mix_u32(hash,font_bitmap_pixel_count);
            hash=mix_u32(hash,(uint32_t)font_bitmap_left);
            hash=mix_u32(hash,(uint32_t)font_bitmap_top);
            for (uint32_t row=0;row<font_bitmap_height;++row) {
                for (uint32_t col=0;col<font_bitmap_width;++col) {
                    hash^=font_bitmap_pixels[row*128u+col];
                    hash*=UINT64_C(1099511628211);
                }
            }
        }
    }
    printf("rasterizer exact-mask checksum: %016" PRIx64 "\n",hash);
    return 0;
}
