#include <stdint.h>

#define MAX_POINTS 4096u
#define MAX_CONTOURS 256u
#define MAX_FLAT_POINTS 16384u
#define BITMAP_SIDE 32u
#define BITMAP_BYTES (BITMAP_SIDE * BITMAP_SIDE)
#define CACHE_SLOTS 128u
#define SAMPLES 4u

extern int32_t font_loaded, font_units_per_em, font_num_glyphs, font_ascent;
extern int32_t font_glyph_contour_count, font_glyph_point_count;
extern int32_t font_glyph_contour_ends[MAX_CONTOURS];
extern uint8_t font_glyph_point_flags[MAX_POINTS];
extern int32_t font_glyph_points_x[MAX_POINTS], font_glyph_points_y[MAX_POINTS];
extern int font_glyph_load_outline(uint32_t glyph_id);
extern uint32_t font_cmap_lookup(uint32_t codepoint);
extern uint32_t font_glyph_advance(uint32_t glyph_id);

uint8_t font_bitmap_pixels[BITMAP_BYTES];
uint32_t font_bitmap_width, font_bitmap_height, font_bitmap_pixel_count;
int32_t font_bitmap_left, font_bitmap_top;
int32_t font_probe_raster_result, font_probe_raster_width;
int32_t font_probe_raster_height, font_probe_raster_pixels;
int32_t font_probe_curve_result, font_probe_curve_width;
int32_t font_probe_curve_height, font_probe_curve_pixels;

static int32_t flat_x[MAX_FLAT_POINTS], flat_y[MAX_FLAT_POINTS];
static uint32_t flat_ends[MAX_CONTOURS], flat_count;

struct cache_entry {
    uint32_t glyph_id, stamp;
    int16_t left, top;
    uint8_t width, height, size, valid;
    uint8_t pixels[BITMAP_BYTES];
};
static struct cache_entry cache[CACHE_SLOTS];
static uint32_t cache_clock;

static int64_t floor_div(int64_t n, int64_t d) {
    int64_t q=n/d, r=n%d;
    return q-(r<0);
}
static int64_t ceil_div(int64_t n, int64_t d) {
    int64_t q=n/d, r=n%d;
    return q+(r>0);
}
static int32_t mid(int32_t a, int32_t b) {
    return (int32_t)(((int64_t)a+b)/2);
}
static int append(int32_t x, int32_t y) {
    if (flat_count && flat_x[flat_count-1]==x && flat_y[flat_count-1]==y) return 0;
    if (flat_count>=MAX_FLAT_POINTS) return -1;
    flat_x[flat_count]=x; flat_y[flat_count]=y; ++flat_count;
    return 0;
}
static int quadratic(int32_t x0,int32_t y0,int32_t cx,int32_t cy,int32_t x1,int32_t y1) {
    int64_t x[3],y[3];
    x[0]=(9*(int64_t)x0+6*(int64_t)cx+x1)/16;
    x[1]=((int64_t)x0+2*(int64_t)cx+x1)/4;
    x[2]=((int64_t)x0+6*(int64_t)cx+9*(int64_t)x1)/16;
    y[0]=(9*(int64_t)y0+6*(int64_t)cy+y1)/16;
    y[1]=((int64_t)y0+2*(int64_t)cy+y1)/4;
    y[2]=((int64_t)y0+6*(int64_t)cy+9*(int64_t)y1)/16;
    if (append((int32_t)x[0],(int32_t)y[0])<0) return -1;
    if (append((int32_t)x[1],(int32_t)y[1])<0) return -1;
    if (append((int32_t)x[2],(int32_t)y[2])<0) return -1;
    return append(x1,y1);
}

/* Resolve cyclic TrueType contour starts and implied midpoints between
 * consecutive off-curve points, then flatten each quadratic into four steps. */
static int flatten(void) {
    uint32_t contours=(uint32_t)font_glyph_contour_count;
    uint32_t points=(uint32_t)font_glyph_point_count, first=0;
    flat_count=0;
    if (contours>MAX_CONTOURS || points>MAX_POINTS) return -1;
    for (uint32_t c=0;c<contours;++c) {
        uint32_t last=(uint32_t)font_glyph_contour_ends[c];
        if (last<first || last>=points) return -1;
        uint32_t count=last-first+1;
        int32_t sx,sy;
        uint32_t index,remaining;
        if (font_glyph_point_flags[first]&1u) {
            sx=font_glyph_points_x[first]; sy=font_glyph_points_y[first];
            index=first+1; remaining=count-1;
        } else if (font_glyph_point_flags[last]&1u) {
            sx=font_glyph_points_x[last]; sy=font_glyph_points_y[last];
            index=first; remaining=count-1;
        } else {
            sx=mid(font_glyph_points_x[last],font_glyph_points_x[first]);
            sy=mid(font_glyph_points_y[last],font_glyph_points_y[first]);
            index=first; remaining=count;
        }
        if (append(sx,sy)<0) return -1;
        int32_t x=sx,y=sy;
        while (remaining) {
            if (index>last) index=first;
            int32_t px=font_glyph_points_x[index], py=font_glyph_points_y[index];
            if (font_glyph_point_flags[index]&1u) {
                if (append(px,py)<0) return -1;
                x=px; y=py; ++index; --remaining;
                continue;
            }
            int32_t ex,ey;
            uint32_t consumed;
            if (remaining==1) {
                ex=sx; ey=sy; consumed=1;
            } else {
                uint32_t next=index+1;
                if (next>last) next=first;
                if (font_glyph_point_flags[next]&1u) {
                    ex=font_glyph_points_x[next]; ey=font_glyph_points_y[next];
                    consumed=2;
                } else {
                    ex=mid(px,font_glyph_points_x[next]);
                    ey=mid(py,font_glyph_points_y[next]);
                    consumed=1;
                }
            }
            if (quadratic(x,y,px,py,ex,ey)<0) return -1;
            x=ex; y=ey; index+=consumed; remaining-=consumed;
        }
        flat_ends[c]=flat_count-1;
        first=last+1;
    }
    return first==points ? 0 : -1;
}

/* TrueType uses a non-zero winding fill rule. Sample coordinates are in
 * eighths of a design unit to support the 4x4 subpixel grid. */
static int inside(int64_t sx,int64_t sy,uint32_t contours) {
    int winding=0;
    uint32_t first=0;
    for (uint32_t c=0;c<contours;++c) {
        uint32_t last=flat_ends[c];
        if (last>=first+2) {
            for (uint32_t i=first;i<=last;++i) {
                uint32_t j=(i==last)?first:i+1;
                int64_t x1=(int64_t)flat_x[i]*8, y1=(int64_t)flat_y[i]*8;
                int64_t x2=(int64_t)flat_x[j]*8, y2=(int64_t)flat_y[j]*8;
                if (y1<=sy && sy<y2) {
                    int64_t cross=(x2-x1)*(sy-y1)-(sx-x1)*(y2-y1);
                    if (cross>0) ++winding;
                } else if (y2<=sy && sy<y1) {
                    int64_t cross=(x1-x2)*(sy-y2)-(sx-x2)*(y1-y2);
                    if (cross>0) --winding;
                }
            }
        }
        first=last+1;
    }
    return winding!=0;
}

int font_rasterize_glyph(uint32_t glyph_id,uint32_t size) {
    int64_t minx,miny,maxx,maxy,left,right,bottom,top,ascent;
    uint32_t upem,contours;
    font_bitmap_width=font_bitmap_height=font_bitmap_pixel_count=0;
    font_bitmap_left=font_bitmap_top=0;
    for (uint32_t i=0;i<BITMAP_BYTES;++i) font_bitmap_pixels[i]=0;
    if (!font_loaded || glyph_id>=(uint32_t)font_num_glyphs || !size || size>BITMAP_SIDE)
        return -1;
    upem=(uint32_t)font_units_per_em;
    if (upem<16 || upem>16384 || font_glyph_load_outline(glyph_id)<0) return -1;
    contours=(uint32_t)font_glyph_contour_count;
    if (!contours || !font_glyph_point_count) return 0;
    if (flatten()<0 || flat_count<3) return -1;
    minx=maxx=flat_x[0]; miny=maxy=flat_y[0];
    for (uint32_t i=0;i<flat_count;++i) {
        int64_t x=flat_x[i], y=flat_y[i];
        if (x < -131072 || x > 131072 || y < -131072 || y > 131072) return -1;
        if (x < minx) minx = x;
        if (x > maxx) maxx = x;
        if (y < miny) miny = y;
        if (y > maxy) maxy = y;
    }
    /* Padding captures extrema between the deterministic quadratic samples. */
    left=floor_div(minx*size,upem)-1;
    right=ceil_div(maxx*size,upem)+1;
    bottom=floor_div(miny*size,upem)-1;
    top=ceil_div(maxy*size,upem)+1;
    if (right<=left || top<=bottom || right-left>BITMAP_SIDE || top-bottom>BITMAP_SIDE)
        return -1;
    font_bitmap_width=(uint32_t)(right-left);
    font_bitmap_height=(uint32_t)(top-bottom);
    font_bitmap_left=(int32_t)left;
    ascent=ceil_div((int64_t)font_ascent*size,upem);
    font_bitmap_top=(int32_t)(ascent-top);
    for (uint32_t row=0;row<font_bitmap_height;++row) {
        for (uint32_t col=0;col<font_bitmap_width;++col) {
            uint32_t covered=0;
            for (uint32_t sy=0;sy<SAMPLES;++sy) {
                int64_t py=(((top-(int64_t)row)*8)-(int64_t)(sy*2+1))*upem/size;
                for (uint32_t sx=0;sx<SAMPLES;++sx) {
                    int64_t px=(((left+(int64_t)col)*8)+(int64_t)(sx*2+1))*upem/size;
                    if (inside(px,py,contours)) ++covered;
                }
            }
            if (covered) {
                font_bitmap_pixels[row*BITMAP_SIDE+col]=(uint8_t)((covered*255u+8u)/16u);
                ++font_bitmap_pixel_count;
            }
        }
    }
    return 0;
}

static struct cache_entry *cached(uint32_t glyph_id,uint32_t size) {
    struct cache_entry *slot=&cache[0];
    for (uint32_t i=0;i<CACHE_SLOTS;++i) {
        struct cache_entry *e=&cache[i];
        if (e->valid && e->glyph_id==glyph_id && e->size==size) {
            e->stamp=++cache_clock;
            return e;
        }
        if (!e->valid) slot=e;
        else if (slot->valid && e->stamp<slot->stamp) slot=e;
    }
    if (++cache_clock==0) {
        cache_clock=1;
        for (uint32_t i=0;i<CACHE_SLOTS;++i) cache[i].stamp=0;
    }
    if (font_rasterize_glyph(glyph_id,size)<0) return (struct cache_entry *)0;
    slot->glyph_id=glyph_id; slot->stamp=cache_clock;
    slot->left=(int16_t)font_bitmap_left; slot->top=(int16_t)font_bitmap_top;
    slot->width=(uint8_t)font_bitmap_width; slot->height=(uint8_t)font_bitmap_height;
    slot->size=(uint8_t)size; slot->valid=1;
    for (uint32_t i=0;i<BITMAP_BYTES;++i) slot->pixels[i]=font_bitmap_pixels[i];
    return slot;
}

/* Wayland backend entry point. Document layout uses the same 12px-em
 * horizontal advances and hhea-derived vertical line box as this rasterizer.
 * The cache keeps outline work off the repaint hot path. */
/*
 * The layout and renderer share this hmtx-derived pixel advance. It uses the
 * current 12px em and rounds to the nearest pixel. The legacy eight-pixel
 * advance remains active when no supported font is loaded.
 */
int32_t font_probe_advance_A, font_probe_advance_B;
int font_codepoint_advance_pixels_size(uint32_t codepoint,uint32_t size) {
    uint32_t glyph_id, advance, upem;
    uint64_t scaled;
    if (!font_loaded || !size || size>32) return 8;
    if (codepoint == 0x20) {
        glyph_id = 0;
    } else {
        glyph_id = font_cmap_lookup(codepoint);
        if (glyph_id == 0 && codepoint != 0x3f)
            glyph_id = font_cmap_lookup(0x3f);
    }
    if (!glyph_id || glyph_id >= (uint32_t)font_num_glyphs) return 8;
    advance = font_glyph_advance(glyph_id);
    upem = (uint32_t)font_units_per_em;
    if (!advance || upem < 16 || upem > 16384) return 8;
    scaled = (uint64_t)advance * size + upem / 2u;
    scaled /= upem;
    if (scaled < 1) scaled = 1;
    if (scaled > 32) scaled = 32;
    return (int)scaled;
}

int font_codepoint_advance_pixels(uint32_t codepoint) {
    return font_codepoint_advance_pixels_size(codepoint,12);
}

int font_draw_codepoint_size(uint32_t cp,int32_t x,int32_t y,uint8_t *surface,
                             int32_t width,int32_t height,int32_t stride,
                             uint32_t size) {
    uint32_t gid;
    struct cache_entry *e;
    if (cp==0x20) return 1;
    if (!font_loaded || !surface || width<=0 || height<=0 || stride<width*4 ||
        !size || size>32) return 0;
    gid=font_cmap_lookup(cp);
    if (!gid && cp!=0x3f) gid=font_cmap_lookup(0x3f);
    if (!gid || gid>=(uint32_t)font_num_glyphs) return 0;
    e=cached(gid,size);
    if (!e || !e->width || !e->height) return 0;
    for (uint32_t row=0;row<e->height;++row) {
        int32_t py=y+e->top+(int32_t)row;
        if (py<0 || py>=height) continue;
        for (uint32_t col=0;col<e->width;++col) {
            uint8_t a=e->pixels[row*BITMAP_SIDE+col];
            int32_t px=x+e->left+(int32_t)col;
            if (!a || px<0 || px>=width) continue;
            uint32_t *dst=(uint32_t *)(surface+(int64_t)py*stride+px*4);
            uint32_t old=*dst, inv=255u-a;
            uint32_t r=(0xd8u*a+((old>>16)&255u)*inv+127u)/255u;
            uint32_t g=(0xdeu*a+((old>>8)&255u)*inv+127u)/255u;
            uint32_t b=(0xe9u*a+(old&255u)*inv+127u)/255u;
            *dst=0xff000000u|(r<<16)|(g<<8)|b;
        }
    }
    return 1;
}

int font_draw_codepoint(uint32_t cp,int32_t x,int32_t y,uint8_t *surface,
                        int32_t width,int32_t height,int32_t stride) {
    return font_draw_codepoint_size(cp,x,y,surface,width,height,stride,12);
}
