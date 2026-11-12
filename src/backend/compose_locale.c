#include <stdint.h>
#include <stddef.h>

#define SYS_read 0
#define SYS_write 1
#define SYS_close 3
#define SYS_fstat 5
#define SYS_lseek 8
#define SYS_mmap 9
#define SYS_munmap 11
#define SYS_getpid 39
#define SYS_fsync 74
#define SYS_fchmod 91
#define SYS_openat 257
#define SYS_mkdirat 258
#define SYS_unlinkat 263
#define SYS_renameat 264
#define SYS_linkat 265
#define PROT_WRITE 2
#define MAP_ANONYMOUS 0x20
#define AT_FDCWD (-100)
#define O_RDONLY 0
#define O_WRONLY 1
#define O_CREAT 64
#define O_EXCL 128
#define O_CLOEXEC 0x80000
#define O_NONBLOCK 0x800
#define O_NOFOLLOW 0x20000
#define O_DIRECTORY 0x10000
#define S_IFMT 0xf000
#define S_IFREG 0x8000
#define DIR_MODE 0700u
#define FILE_MODE 0600u
#define SEEK_END 2
#define PROT_READ 1
#define MAP_PRIVATE 2
#define HEADER_SIZE 72u
#define RECORD_SIZE_V1 52u
#define RECORD_SIZE 68u
#define FORMAT_VERSION_V1 1u
#define FORMAT_VERSION 2u
#define MAX_RECORDS 32768u
#define MAX_PACK_SIZE (2u * 1024u * 1024u)
#define MAX_TAG_LENGTH 31u
#define MAX_INPUTS 8u
#define MAX_MULTI_KEY_INPUTS 4u
#define MAX_OUTPUTS 8u

extern char **process_envp;
/* Share the XKB parser's embedded Unicode-annotated X.Org name table. */
extern uint32_t xkb_keysym_name_to_unicode(const char *name, uint32_t length);
uint32_t compose_locale_active;
uint32_t compose_locale_output[MAX_OUTPUTS];
char compose_locale_current_tag[MAX_TAG_LENGTH + 1u];
char compose_locale_installed_tag[MAX_TAG_LENGTH + 1u];

static const uint8_t magic[8] = {'N','E','K','O','L','O','C','1'};
static const char locale_env[] = "NEKOEDIT_LOCALE";
static const char lc_all_env[] = "LC_ALL";
static const char lc_ctype_env[] = "LC_CTYPE";
static const char lang_env[] = "LANG";
static const char home_env[] = "HOME";
static const char system_root_env[] = "NEKOEDIT_XCOMPOSE_SYSTEM_ROOT";
static const char default_system_root[] = "/usr/share/X11/locale";
static const char directory_suffix[] = "/.nekoedit/locales/";
static const char extension[] = ".nlp";
static const uint8_t *mapped_pack;
static uint32_t mapped_pack_size;
static uint32_t mapped_record_count;
static uint32_t mapped_record_size;
static uint32_t mapped_input_capacity;

static long syscall6(long number, long a1, long a2, long a3,
                     long a4, long a5, long a6)
{
    register long rax __asm__("rax") = number;
    register long r10 __asm__("r10") = a4;
    register long r8 __asm__("r8") = a5;
    register long r9 __asm__("r9") = a6;
    __asm__ volatile ("syscall"
        : "+a"(rax)
        : "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8), "r"(r9)
        : "rcx", "r11", "memory");
    return rax;
}

static int failed(long result)
{
    return result < 0 && result >= -4095;
}

static uint32_t string_length(const char *text, uint32_t limit)
{
    uint32_t length = 0;
    if (!text) return 0;
    while (length < limit && text[length]) ++length;
    return length;
}

static const char *environment_value(const char *name)
{
    uint32_t length = string_length(name, 128u);
    char **entry = process_envp;
    if (!entry || !length) return (const char *)0;
    while (*entry) {
        const char *candidate = *entry;
        uint32_t i = 0;
        while (i < length && candidate[i] == name[i]) ++i;
        if (i == length && candidate[i] == '=') return candidate + i + 1u;
        ++entry;
    }
    return (const char *)0;
}

static int equals(const char *a, const char *b)
{
    uint32_t i = 0;
    if (!a || !b) return 0;
    while (a[i] && b[i] && a[i] == b[i]) ++i;
    return a[i] == 0 && b[i] == 0;
}

static int valid_tag(const char *tag, uint32_t length)
{
    uint32_t i;
    if (!tag || !length || length > MAX_TAG_LENGTH ||
        tag[0] == '.' || tag[length - 1u] == '.') return 0;
    for (i = 0; i < length; ++i) {
        char c = tag[i];
        int allowed = (c >= 'a' && c <= 'z') ||
                      (c >= 'A' && c <= 'Z') ||
                      (c >= '0' && c <= '9') ||
                      c == '_' || c == '-' || c == '.' || c == '@';
        if (!allowed || (c == '.' && i + 1u < length && tag[i + 1u] == '.'))
            return 0;
    }
    return 1;
}
static char ascii_lower(char value)
{
    return value >= 'A' && value <= 'Z' ? (char)(value - 'A' + 'a') : value;
}

static char ascii_upper(char value)
{
    return value >= 'a' && value <= 'z' ? (char)(value - 'a' + 'A') : value;
}

static int segment_equals_ascii_case(const char *value, uint32_t length,
                                     const char *expected)
{
    uint32_t i, expected_length = string_length(expected, 32u);
    if (length != expected_length) return 0;
    for (i = 0; i < length; ++i)
        if (ascii_lower(value[i]) != ascii_lower(expected[i])) return 0;
    return 1;
}

/* Normalize language_territory locale tags without libc locale APIs.
 * Language becomes lower-case, territory upper-case and UTF8/utf-8 -> UTF-8.
 * A language_territory name without a codeset defaults to a UTF-8 pack.
 */
static uint32_t normalize_locale_tag(const char *input, char *output,
                                     uint32_t capacity)
{
    uint32_t length, underscore = 0xffffffffu, dot = 0xffffffffu;
    uint32_t modifier = 0xffffffffu, language_end, region_end;
    uint32_t region_start, at = 0, i;
    int has_region = 0, special_language;

    if (!input || !output || !capacity) return 0;
    length = string_length(input, MAX_TAG_LENGTH + 1u);
    if (!valid_tag(input, length)) return 0;

    if (equals(input, "C") || equals(input, "POSIX")) {
        for (i = 0; i < length; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = input[i];
        }
        output[at] = 0;
        return at;
    }

    for (i = 0; i < length; ++i) {
        if (input[i] == '_' && underscore == 0xffffffffu) underscore = i;
        if (input[i] == '.' && dot == 0xffffffffu) dot = i;
        if (input[i] == '@' && modifier == 0xffffffffu) modifier = i;
    }
    language_end = length;
    if (underscore < language_end) language_end = underscore;
    if (dot < language_end) language_end = dot;
    if (modifier < language_end) language_end = modifier;
    special_language = segment_equals_ascii_case(input, language_end, "C") ||
                       segment_equals_ascii_case(input, language_end, "POSIX");

    if (special_language) {
        for (i = 0; i < language_end; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = ascii_upper(input[i]);
        }
    } else {
        for (i = 0; i < language_end; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = ascii_lower(input[i]);
        }
    }

    if (underscore < length && (dot == 0xffffffffu || underscore < dot) &&
        (modifier == 0xffffffffu || underscore < modifier)) {
        has_region = 1;
        if (at + 1u >= capacity) return 0;
        output[at++] = '_';
        region_start = underscore + 1u;
        region_end = length;
        if (dot < region_end) region_end = dot;
        if (modifier < region_end) region_end = modifier;
        for (i = region_start; i < region_end; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = ascii_upper(input[i]);
        }
    }

    if (dot < length && (modifier == 0xffffffffu || dot < modifier)) {
        uint32_t codeset_end = modifier < length ? modifier : length;
        uint32_t codeset_length = codeset_end - dot - 1u;
        if (segment_equals_ascii_case(input + dot + 1u, codeset_length, "UTF8") ||
            segment_equals_ascii_case(input + dot + 1u, codeset_length, "UTF-8")) {
            const char canonical[] = ".UTF-8";
            for (i = 0; i < sizeof(canonical) - 1u; ++i) {
                if (at + 1u >= capacity) return 0;
                output[at++] = canonical[i];
            }
        } else {
            for (i = dot; i < codeset_end; ++i) {
                if (at + 1u >= capacity) return 0;
                output[at++] = input[i];
            }
        }
    } else if (has_region) {
        const char canonical[] = ".UTF-8";
        for (i = 0; i < sizeof(canonical) - 1u; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = canonical[i];
        }
    }

    if (modifier < length) {
        for (i = modifier; i < length; ++i) {
            if (at + 1u >= capacity) return 0;
            output[at++] = input[i];
        }
    }
    if (!valid_tag(output, at)) return 0;
    output[at] = 0;
    return at;
}

static uint32_t read32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static uint16_t read16(const uint8_t *p)
{
    return (uint16_t)((uint16_t)p[0] | ((uint16_t)p[1] << 8));
}

static int scalar_valid(uint32_t value)
{
    return value && value <= 0x10ffffu &&
           !(value >= 0xd800u && value <= 0xdfffu);
}

static uint32_t crc32(const uint8_t *bytes, uint32_t length)
{
    uint32_t crc = 0xffffffffu, i;
    for (i = 0; i < length; ++i) {
        uint32_t bit;
        crc ^= bytes[i];
        for (bit = 0; bit < 8u; ++bit)
            crc = (crc >> 1) ^ (0xedb88320u & (0u - (crc & 1u)));
    }
    return ~crc;
}

static int compare_records(const uint8_t *a, const uint8_t *b)
{
    uint32_t a_kind = read16(a + 2), b_kind = read16(b + 2);
    uint32_t ac, bc, shared, i;
    if (a_kind < b_kind) return -1;
    if (a_kind > b_kind) return 1;
    ac = a[0];
    bc = b[0];
    shared = ac < bc ? ac : bc;
    for (i = 0; i < shared; ++i) {
        uint32_t av = read32(a + 4u + i * 4u);
        uint32_t bv = read32(b + 4u + i * 4u);
        if (av < bv) return -1;
        if (av > bv) return 1;
    }
    /* Equality across the shared prefix also rejects duplicate and
     * prefix-ambiguous records, regardless of which one is shorter. */
    return 0;
}

/* A stored longer sequence compares equal when it begins with input[]. */
static int compare_record_input(const uint8_t *record, uint32_t kind,
                                const uint32_t *input, uint32_t input_count)
{
    uint32_t record_kind = read16(record + 2);
    uint32_t count, shared, i;
    if (record_kind < kind) return -1;
    if (record_kind > kind) return 1;
    count = record[0];
    shared = count < input_count ? count : input_count;
    for (i = 0; i < shared; ++i) {
        uint32_t value = read32(record + 4u + i * 4u);
        if (value < input[i]) return -1;
        if (value > input[i]) return 1;
    }
    return count < input_count ? -1 : 0;
}

static int validate_pack(const uint8_t *data, uint32_t size,
                         const char *tag, uint32_t tag_length,
                         uint32_t *record_count, uint32_t *record_size_out,
                         uint32_t *input_capacity_out)
{
    const uint8_t *payload;
    uint32_t count, payload_size, record_size, input_capacity, output_offset;
    uint32_t version, i;
    if (!data || size < HEADER_SIZE || size > MAX_PACK_SIZE ||
        !record_count) return 0;
    for (i = 0; i < sizeof(magic); ++i)
        if (data[i] != magic[i]) return 0;

    version = read32(data + 8u);
    if (version == FORMAT_VERSION_V1) {
        record_size = RECORD_SIZE_V1;
        input_capacity = 4u;
    } else if (version == FORMAT_VERSION) {
        record_size = RECORD_SIZE;
        input_capacity = MAX_INPUTS;
    } else {
        return 0;
    }
    if (read32(data + 12u) != HEADER_SIZE ||
        read32(data + 16u) != record_size || read32(data + 32u) != 0u ||
        read32(data + 68u) != 0u) return 0;

    count = read32(data + 20u);
    payload_size = read32(data + 24u);
    if (!count || count > MAX_RECORDS ||
        payload_size != count * record_size ||
        size != HEADER_SIZE + payload_size) return 0;
    if (tag_length >= 32u || data[36u + tag_length] != 0u) return 0;
    for (i = 0; i < tag_length; ++i)
        if (data[36u + i] != (uint8_t)tag[i]) return 0;
    for (i = tag_length + 1u; i < 32u; ++i)
        if (data[36u + i] != 0u) return 0;

    payload = data + HEADER_SIZE;
    if (crc32(payload, payload_size) != read32(data + 28u)) return 0;
    output_offset = 4u + input_capacity * 4u;
    for (i = 0; i < count; ++i) {
        const uint8_t *record = payload + i * record_size;
        uint32_t inputs = record[0], outputs = record[1], j;
        uint32_t kind = read16(record + 2u);
        uint32_t max_inputs = kind == 0u ? MAX_MULTI_KEY_INPUTS : input_capacity;
        if (kind > 1u || inputs < 2u || inputs > max_inputs ||
            outputs < 1u || outputs > MAX_OUTPUTS) return 0;
        for (j = 0; j < input_capacity; ++j) {
            uint32_t value = read32(record + 4u + j * 4u);
            if (j < inputs) {
                if (!scalar_valid(value)) return 0;
            } else if (value) return 0;
        }
        for (j = 0; j < MAX_OUTPUTS; ++j) {
            uint32_t value = read32(record + output_offset + j * 4u);
            if (j < outputs) {
                if (!scalar_valid(value)) return 0;
            } else if (value) return 0;
        }
        if (i && compare_records(record - record_size, record) >= 0)
            return 0;
    }
    *record_count = count;
    if (record_size_out) *record_size_out = record_size;
    if (input_capacity_out) *input_capacity_out = input_capacity;
    return 1;
}

static int make_path(char *path, uint32_t capacity,
                     const char *home, uint32_t home_length,
                     const char *tag, uint32_t tag_length)
{
    uint32_t at = 0, i;
    if (!path || !home || !home_length || home[0] != '/' ||
        home_length >= capacity) return 0;
    for (i = 0; i < home_length; ++i) path[at++] = home[i];
    if (at && path[at - 1u] == '/') --at;
    for (i = 0; i < sizeof(directory_suffix) - 1u; ++i) {
        if (at + 1u >= capacity) return 0;
        path[at++] = directory_suffix[i];
    }
    for (i = 0; i < tag_length; ++i) {
        if (at + 1u >= capacity) return 0;
        path[at++] = tag[i];
    }
    for (i = 0; i < sizeof(extension) - 1u; ++i) {
        if (at + 1u >= capacity) return 0;
        path[at++] = extension[i];
    }
    path[at] = 0;
    return 1;
}

uint32_t compose_locale_load(const char *requested_tag)
{
    const char *tag = requested_tag;
    const char *home = environment_value(home_env);
    uint32_t tag_length, home_length, count = 0;
    uint32_t record_size = 0, input_capacity = 0;
    char path[4096];
    char normalized_tag[MAX_TAG_LENGTH + 9u];
    long fd, size, address;
    const uint8_t *candidate;

    if (!tag || !tag[0])
        tag = environment_value(locale_env);
    if (!tag || !tag[0])
        tag = environment_value(lc_all_env);
    if (!tag || !tag[0])
        tag = environment_value(lc_ctype_env);
    if (!tag || !tag[0])
        tag = environment_value(lang_env);

    if (tag) {
        if (normalize_locale_tag(tag, normalized_tag, sizeof(normalized_tag)))
            tag = normalized_tag;
        else
            tag = (const char *)0;
    }
    compose_locale_active = 0;
    compose_locale_current_tag[0] = 0;
    if (mapped_pack && mapped_pack_size)
        (void)syscall6(SYS_munmap, (long)mapped_pack, mapped_pack_size, 0, 0, 0, 0);
    mapped_pack = (const uint8_t *)0;
    mapped_pack_size = 0;
    mapped_record_count = 0;
    mapped_record_size = 0;
    mapped_input_capacity = 0;
    if (!tag || !tag[0] || equals(tag, "en_US") ||
        equals(tag, "en_US.UTF-8") || equals(tag, "en_US.utf8") ||
        equals(tag, "en_US.UTF8") || equals(tag, "C") ||
        equals(tag, "C.UTF-8") || equals(tag, "C.utf8") ||
        equals(tag, "C.UTF8") || equals(tag, "POSIX")) {
        static const char builtin[] = "en_US.UTF-8";
        uint32_t i;
        for (i = 0; i < sizeof(builtin); ++i)
            compose_locale_current_tag[i] = builtin[i];
        return 0;
    }

    tag_length = string_length(tag, MAX_TAG_LENGTH + 1u);
    home_length = string_length(home, sizeof(path));
    if (!valid_tag(tag, tag_length) || !home || !home_length ||
        home_length >= sizeof(path) ||
        !make_path(path, sizeof(path), home, home_length, tag, tag_length))
        return 0;

    fd = syscall6(SYS_openat, AT_FDCWD, (long)path,
                  O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK, 0, 0, 0);
    if (failed(fd)) return 0;
    size = syscall6(SYS_lseek, fd, 0, SEEK_END, 0, 0, 0);
    if (size < (long)HEADER_SIZE || size > (long)MAX_PACK_SIZE) {
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    address = syscall6(SYS_mmap, 0, size, PROT_READ, MAP_PRIVATE, fd, 0);
    (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
    if (failed(address)) return 0;
    candidate = (const uint8_t *)(uintptr_t)address;
    if (!validate_pack(candidate, (uint32_t)size, tag, tag_length,
                        &count, &record_size, &input_capacity)) {
        (void)syscall6(SYS_munmap, address, size, 0, 0, 0, 0);
        return 0;
    }
    mapped_pack = candidate;
    mapped_pack_size = (uint32_t)size;
    mapped_record_count = count;
    mapped_record_size = record_size;
    mapped_input_capacity = input_capacity;
    compose_locale_active = 1;
    {
        uint32_t i;
        for (i = 0; i < tag_length; ++i) compose_locale_current_tag[i] = tag[i];
        compose_locale_current_tag[tag_length] = 0;
    }
    return 1;
}

static uint32_t find_lower_bound(uint32_t kind, const uint32_t *input,
                                 uint32_t input_count)
{
    uint32_t low = 0, high = mapped_record_count;
    const uint8_t *records = mapped_pack + HEADER_SIZE;
    while (low < high) {
        uint32_t mid = low + (high - low) / 2u;
        const uint8_t *record = records + mid * mapped_record_size;
        if (compare_record_input(record, kind, input, input_count) < 0)
            low = mid + 1u;
        else
            high = mid;
    }
    return low;
}

uint32_t compose_locale_lookup(uint32_t kind, uint32_t input_count,
                               const uint32_t *input, uint32_t *output)
{
    const uint8_t *records, *record;
    uint32_t index, i;
    if (!compose_locale_active || !mapped_pack || !input || !output ||
        kind > 1u || input_count < 2u ||
        (kind == 0u ? input_count > MAX_MULTI_KEY_INPUTS :
                      input_count > mapped_input_capacity)) return 0;
    records = mapped_pack + HEADER_SIZE;
    index = find_lower_bound(kind, input, input_count);
    if (index >= mapped_record_count) return 0;
    record = records + index * mapped_record_size;
    if (record[0] != input_count ||
        compare_record_input(record, kind, input, input_count) != 0) return 0;
    for (i = 0; i < record[1]; ++i)
        output[i] = read32(record + 4u + mapped_input_capacity * 4u + i * 4u);
    return record[1];
}

uint32_t compose_locale_prefix(uint32_t kind, uint32_t input_count,
                               const uint32_t *input)
{
    const uint8_t *records, *record;
    uint32_t index;
    if (!compose_locale_active || !mapped_pack || !input ||
        kind > 1u || input_count < 1u ||
        (kind == 0u ? input_count >= MAX_MULTI_KEY_INPUTS :
                      input_count >= mapped_input_capacity)) return 0;
    records = mapped_pack + HEADER_SIZE;
    index = find_lower_bound(kind, input, input_count);
    if (index >= mapped_record_count) return 0;
    record = records + index * mapped_record_size;
    return record[0] > input_count &&
           compare_record_input(record, kind, input, input_count) == 0;
}


static int copy_ascii(char *destination, uint32_t capacity,
                      const char *source, uint32_t length)
{
    uint32_t i;
    if (!destination || !source || !capacity || length >= capacity) return 0;
    for (i = 0; i < length; ++i) destination[i] = source[i];
    destination[length] = 0;
    return 1;
}

static int append_ascii(char *destination, uint32_t capacity,
                        uint32_t *used, const char *source, uint32_t length)
{
    uint32_t i;
    if (!destination || !used || !source || *used >= capacity ||
        length >= capacity - *used) return 0;
    for (i = 0; i < length; ++i) destination[(*used)++] = source[i];
    destination[*used] = 0;
    return 1;
}

static uint32_t append_decimal(char *destination, uint32_t capacity,
                               uint32_t used, uint32_t value)
{
    char digits[10];
    uint32_t count = 0;
    if (!value) digits[count++] = '0';
    while (value && count < sizeof(digits)) {
        digits[count++] = (char)('0' + value % 10u);
        value /= 10u;
    }
    while (count) {
        if (used + 1u >= capacity) return UINT32_MAX;
        destination[used++] = digits[--count];
    }
    destination[used] = 0;
    return used;
}

/* The final component is opened with O_NOFOLLOW. This prevents a replaced
 * .nekoedit or locales entry from redirecting pack writes outside HOME. */
static long open_locale_directory(void)
{
    const char *home = environment_value(home_env);
    long root_fd, app_fd, locale_fd, result;
    if (!home || home[0] != '/' || !home[1]) return -1;
    root_fd = syscall6(SYS_openat, AT_FDCWD, (long)home,
                       O_RDONLY | O_DIRECTORY | O_CLOEXEC, 0, 0, 0);
    if (failed(root_fd)) return -1;
    result = syscall6(SYS_mkdirat, root_fd, (long)".nekoedit",
                      DIR_MODE, 0, 0, 0);
    if (failed(result) && result != -17) {
        (void)syscall6(SYS_close, root_fd, 0, 0, 0, 0, 0);
        return -1;
    }
    app_fd = syscall6(SYS_openat, root_fd, (long)".nekoedit",
                      O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW, 0, 0, 0);
    (void)syscall6(SYS_close, root_fd, 0, 0, 0, 0, 0);
    if (failed(app_fd)) return -1;
    if (failed(syscall6(SYS_fchmod, app_fd, DIR_MODE, 0, 0, 0, 0))) {
        (void)syscall6(SYS_close, app_fd, 0, 0, 0, 0, 0);
        return -1;
    }
    result = syscall6(SYS_mkdirat, app_fd, (long)"locales",
                      DIR_MODE, 0, 0, 0);
    if (failed(result) && result != -17) {
        (void)syscall6(SYS_close, app_fd, 0, 0, 0, 0, 0);
        return -1;
    }
    locale_fd = syscall6(SYS_openat, app_fd, (long)"locales",
                         O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW, 0, 0, 0);
    (void)syscall6(SYS_close, app_fd, 0, 0, 0, 0, 0);
    if (failed(locale_fd)) return -1;
    if (failed(syscall6(SYS_fchmod, locale_fd, DIR_MODE, 0, 0, 0, 0))) {
        (void)syscall6(SYS_close, locale_fd, 0, 0, 0, 0, 0);
        return -1;
    }
    return locale_fd;
}

static int pack_tag(const uint8_t *bytes, uint32_t size,
                    char tag[MAX_TAG_LENGTH + 1u], uint32_t *tag_length)
{
    uint32_t i, length = 0;
    if (!bytes || size < HEADER_SIZE || !tag || !tag_length) return 0;
    while (length < 32u && bytes[36u + length]) ++length;
    if (!valid_tag((const char *)(bytes + 36u), length)) return 0;
    for (i = 0; i < length; ++i) tag[i] = (char)bytes[36u + i];
    tag[length] = 0;
    *tag_length = length;
    return 1;
}

static int builtin_tag(const char *tag)
{
    return equals(tag, "en_US") || equals(tag, "en_US.UTF-8") ||
           equals(tag, "en_US.utf8") || equals(tag, "en_US.UTF8") ||
           equals(tag, "C") || equals(tag, "C.UTF-8") ||
           equals(tag, "C.utf8") || equals(tag, "C.UTF8") ||
           equals(tag, "POSIX");
}

static int write_all_fd(long fd, const uint8_t *bytes, uint32_t length)
{
    uint32_t offset = 0;
    while (offset < length) {
        long result = syscall6(SYS_write, fd, (long)(bytes + offset),
                               length - offset, 0, 0, 0);
        if (result > 0) {
            offset += (uint32_t)result;
            continue;
        }
        if (result == -4) continue;
        return 0;
    }
    return 1;
}

static int make_pack_names(const char *tag, uint32_t tag_length,
                           char *destination, uint32_t destination_capacity,
                           char *temporary, uint32_t temporary_capacity)
{
    static const char suffix[] = ".nlp";
    uint32_t used = tag_length;
    if (!copy_ascii(destination, destination_capacity, tag, tag_length) ||
        !append_ascii(destination, destination_capacity, &used,
                      suffix, sizeof(suffix) - 1u))
        return 0;
    used = 0;
    if (!append_ascii(temporary, temporary_capacity, &used, ".", 1u) ||
        !append_ascii(temporary, temporary_capacity, &used, tag, tag_length) ||
        !append_ascii(temporary, temporary_capacity, &used, ".", 1u))
        return 0;
    {
        long pid = syscall6(SYS_getpid, 0, 0, 0, 0, 0, 0);
        uint32_t next;
        if (failed(pid)) return 0;
        next = append_decimal(temporary, temporary_capacity, used, (uint32_t)pid);
        if (next == UINT32_MAX) return 0;
        used = next;
    }
    return append_ascii(temporary, temporary_capacity, &used, ".tmp",
                        sizeof(".tmp") - 1u);
}

static int map_pack_file(const char *path, long *fd_out,
                         const uint8_t **map_out, uint32_t *size_out,
                         char tag[MAX_TAG_LENGTH + 1u], uint32_t *tag_length,
                         uint32_t *record_count)
{
    uint8_t stat_buffer[256] __attribute__((aligned(16)));
    long fd, size, address, result;
    const uint8_t *bytes;
    uint32_t i;
    if (!path || !fd_out || !map_out || !size_out || !tag_length ||
        !record_count) return 0;
    fd = syscall6(SYS_openat, AT_FDCWD, (long)path,
                  O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK, 0, 0, 0);
    if (failed(fd)) return 0;
    for (i = 0; i < sizeof(stat_buffer); ++i) stat_buffer[i] = 0;
    result = syscall6(SYS_fstat, fd, (long)stat_buffer, 0, 0, 0, 0);
    if (failed(result) || (read32(stat_buffer + 24u) & S_IFMT) != S_IFREG) {
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    size = syscall6(SYS_lseek, fd, 0, SEEK_END, 0, 0, 0);
    if (size < (long)HEADER_SIZE || size > (long)MAX_PACK_SIZE) {
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    address = syscall6(SYS_mmap, 0, size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (failed(address)) {
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    bytes = (const uint8_t *)(uintptr_t)address;
    if (!pack_tag(bytes, (uint32_t)size, tag, tag_length) ||
        !validate_pack(bytes, (uint32_t)size, tag, *tag_length, record_count, 0, 0)) {
        (void)syscall6(SYS_munmap, address, size, 0, 0, 0, 0);
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    *fd_out = fd;
    *map_out = bytes;
    *size_out = (uint32_t)size;
    return 1;
}

/* Only a complete, validated, data-only pack reaches the private locale
 * directory. A per-directory temporary and rename prevent partial installs. */
uint32_t compose_locale_install_pack(const char *source_path)
{
    char tag[MAX_TAG_LENGTH + 1u], destination[48], temporary[80];
    const uint8_t *mapped = (const uint8_t *)0;
    uint32_t size = 0, tag_length = 0, records = 0;
    long source_fd = -1, locale_fd = -1, target_fd = -1, result;
    uint32_t ok = 0;
    if (!map_pack_file(source_path, &source_fd, &mapped, &size,
                       tag, &tag_length, &records))
        return 0;
    if (builtin_tag(tag)) goto install_done;
    if (!make_pack_names(tag, tag_length, destination, sizeof(destination),
                         temporary, sizeof(temporary)))
        goto install_done;
    locale_fd = open_locale_directory();
    if (failed(locale_fd)) {
        locale_fd = -1;
        goto install_done;
    }
    (void)syscall6(SYS_unlinkat, locale_fd, (long)temporary, 0, 0, 0, 0);
    target_fd = syscall6(SYS_openat, locale_fd, (long)temporary,
                         O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW,
                         FILE_MODE, 0, 0);
    if (failed(target_fd)) {
        target_fd = -1;
        goto install_done;
    }
    if (!write_all_fd(target_fd, mapped, size)) goto install_done;
    result = syscall6(SYS_fsync, target_fd, 0, 0, 0, 0, 0);
    if (failed(result)) goto install_done;
    (void)syscall6(SYS_close, target_fd, 0, 0, 0, 0, 0);
    target_fd = -1;
    result = syscall6(SYS_renameat, locale_fd, (long)temporary,
                      locale_fd, (long)destination, 0, 0);
    if (failed(result)) goto install_done;
    (void)syscall6(SYS_fsync, locale_fd, 0, 0, 0, 0, 0);
    for (uint32_t i = 0; i < tag_length; ++i) compose_locale_installed_tag[i] = tag[i];
    compose_locale_installed_tag[tag_length] = 0;
    ok = 1;
install_done:
    if (target_fd >= 0)
        (void)syscall6(SYS_close, target_fd, 0, 0, 0, 0, 0);
    if (locale_fd >= 0) {
        if (!ok) (void)syscall6(SYS_unlinkat, locale_fd, (long)temporary, 0, 0, 0, 0);
        (void)syscall6(SYS_close, locale_fd, 0, 0, 0, 0, 0);
    }
    if (mapped) (void)syscall6(SYS_munmap, (long)mapped, size, 0, 0, 0, 0);
    if (source_fd >= 0) (void)syscall6(SYS_close, source_fd, 0, 0, 0, 0, 0);
    return ok;
}


/* Return the private locale-pack directory after ensuring its permissions. */
uint32_t compose_locale_get_directory(char *destination, uint32_t capacity)
{
    const char *home = environment_value(home_env);
    uint32_t home_length, used = 0, i;
    long directory_fd;
    if (!destination || capacity < 2u || !home || home[0] != '/')
        return 0;
    directory_fd = open_locale_directory();
    if (failed(directory_fd))
        return 0;
    (void)syscall6(SYS_close, directory_fd, 0, 0, 0, 0, 0);
    home_length = string_length(home, capacity);
    if (!home_length || home_length >= capacity)
        return 0;
    for (i = 0; i < home_length; ++i)
        destination[used++] = home[i];
    if (used && destination[used - 1u] == '/')
        --used;
    for (i = 0; i < sizeof(directory_suffix) - 2u; ++i) {
        if (used + 1u >= capacity)
            return 0;
        destination[used++] = directory_suffix[i];
    }
    destination[used] = 0;
    return used;
}

/* A filename is removable only when it opens without following symlinks and
 * its embedded locale tag, CRC, scalar records, and ordering all validate. */
uint32_t compose_locale_remove_pack(const char *tag)
{
    char tag_copy[MAX_TAG_LENGTH + 1u], destination[48], temporary[80];
    uint8_t stat_buffer[256] __attribute__((aligned(16)));
    uint32_t tag_length, records = 0, i;
    long locale_fd, source_fd, result, file_size, address;
    const uint8_t *mapped;
    (void)temporary;
    if (!tag) return 0;
    tag_length = string_length(tag, MAX_TAG_LENGTH + 1u);
    if (!valid_tag(tag, tag_length) || builtin_tag(tag) ||
        !copy_ascii(tag_copy, sizeof(tag_copy), tag, tag_length))
        return 0;
    {
        uint32_t unused_length = 0;
        if (!make_pack_names(tag_copy, tag_length, destination, sizeof(destination),
                             temporary, sizeof(temporary)) ||
            unused_length != 0)
            return 0;
    }
    locale_fd = open_locale_directory();
    if (failed(locale_fd)) return 0;
    source_fd = syscall6(SYS_openat, locale_fd, (long)destination,
                         O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK, 0, 0, 0);
    if (failed(source_fd)) {
        (void)syscall6(SYS_close, locale_fd, 0, 0, 0, 0, 0);
        return 0;
    }
    for (i = 0; i < sizeof(stat_buffer); ++i) stat_buffer[i] = 0;
    result = syscall6(SYS_fstat, source_fd, (long)stat_buffer, 0, 0, 0, 0);
    if (failed(result) || (read32(stat_buffer + 24u) & S_IFMT) != S_IFREG)
        goto remove_done;
    file_size = syscall6(SYS_lseek, source_fd, 0, SEEK_END, 0, 0, 0);
    if (file_size < (long)HEADER_SIZE || file_size > (long)MAX_PACK_SIZE)
        goto remove_done;
    address = syscall6(SYS_mmap, 0, file_size, PROT_READ, MAP_PRIVATE, source_fd, 0);
    if (failed(address)) goto remove_done;
    mapped = (const uint8_t *)(uintptr_t)address;
    {
        char embedded[MAX_TAG_LENGTH + 1u];
        uint32_t embedded_length = 0;
        if (!pack_tag(mapped, (uint32_t)file_size, embedded, &embedded_length) ||
            !equals(embedded, tag_copy) ||
            !validate_pack(mapped, (uint32_t)file_size, tag_copy, tag_length, &records, 0, 0)) {
            (void)syscall6(SYS_munmap, address, file_size, 0, 0, 0, 0);
            goto remove_done;
        }
    }
    (void)syscall6(SYS_munmap, address, file_size, 0, 0, 0, 0);
    result = syscall6(SYS_unlinkat, locale_fd, (long)destination, 0, 0, 0, 0);
    if (failed(result)) goto remove_done;
    (void)syscall6(SYS_fsync, locale_fd, 0, 0, 0, 0, 0);
    if (equals(compose_locale_current_tag, tag_copy))
        (void)compose_locale_load("en_US.UTF-8");
    (void)syscall6(SYS_close, source_fd, 0, 0, 0, 0, 0);
    (void)syscall6(SYS_close, locale_fd, 0, 0, 0, 0, 0);
    return 1;
remove_done:
    (void)syscall6(SYS_close, source_fd, 0, 0, 0, 0, 0);
    (void)syscall6(SYS_close, locale_fd, 0, 0, 0, 0, 0);
    return 0;
}

/* Native bounded .XCompose -> separate NLP1 pack importer. */
#define XCOMPOSE_FILE_LIMIT (512u * 1024u)
#define XCOMPOSE_LINE_LIMIT (64u * 1024u)
#define XCOMPOSE_MAX_NAME 63u
#define XCOMPOSE_TAG_BASE 25u
#define XCOMPOSE_INCLUDE_DEPTH 16u
#define XCOMPOSE_INCLUDE_FILES 32u
#define XCOMPOSE_INCLUDE_EXPANSIONS 64u
#define XCOMPOSE_INCLUDE_NAME 127u
#define XCOMPOSE_WORKSPACE_SIZE (XCOMPOSE_FILE_LIMIT + XCOMPOSE_INCLUDE_DEPTH + 1u)
#define XCOMPOSE_PATH_SIZE 4096u
#define XCOMPOSE_NAME_SIZE 256u

struct native_compose_rule {
    uint32_t input[MAX_INPUTS];
    uint32_t output[MAX_OUTPUTS];
    uint32_t order;
    uint8_t input_count, output_count, kind, reserved;
};

static char nx_lower(char c)
{
    return c >= 'A' && c <= 'Z' ? (char)(c - 'A' + 'a') : c;
}
static int nx_equal(const char *a, const char *b)
{
    uint32_t i = 0;
    if (!a || !b) return 0;
    while (a[i] && b[i]) { if (a[i] != b[i]) return 0; ++i; }
    return a[i] == 0 && b[i] == 0;
}
static int nx_equal_ci(const char *a, const char *b)
{
    uint32_t i = 0;
    if (!a || !b) return 0;
    while (a[i] && b[i]) { if (nx_lower(a[i]) != nx_lower(b[i])) return 0; ++i; }
    return b[i] == 0;
}
static int nx_space(char c)
{
    return c == ' ' || c == '\t' || c == '\r' || c == '\f';
}
static int nx_hex(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    c = nx_lower(c);
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    return -1;
}
static int nx_put_byte(uint8_t *b, uint32_t *n, uint32_t cap, uint32_t v)
{
    if (*n >= cap || v > 255u) return 0;
    b[(*n)++] = (uint8_t)v;
    return 1;
}
static int nx_put_utf8(uint8_t *b, uint32_t *n, uint32_t cap, uint32_t v)
{
    if (!scalar_valid(v)) return 0;
    if (v <= 0x7fu) return nx_put_byte(b,n,cap,v);
    if (v <= 0x7ffu)
        return nx_put_byte(b,n,cap,0xc0u|(v>>6)) &&
               nx_put_byte(b,n,cap,0x80u|(v&0x3fu));
    if (v <= 0xffffu)
        return nx_put_byte(b,n,cap,0xe0u|(v>>12)) &&
               nx_put_byte(b,n,cap,0x80u|((v>>6)&0x3fu)) &&
               nx_put_byte(b,n,cap,0x80u|(v&0x3fu));
    return nx_put_byte(b,n,cap,0xf0u|(v>>18)) &&
           nx_put_byte(b,n,cap,0x80u|((v>>12)&0x3fu)) &&
           nx_put_byte(b,n,cap,0x80u|((v>>6)&0x3fu)) &&
           nx_put_byte(b,n,cap,0x80u|(v&0x3fu));
}
static int nx_utf8_scalars(const uint8_t *b, uint32_t n,
                           uint32_t out[MAX_OUTPUTS], uint32_t *out_n)
{
    uint32_t at=0,count=0;
    while (at<n) {
        uint32_t v,need,min,i;
        uint8_t first=b[at++];
        if(first<0x80u){v=first;need=0;min=0;}
        else if(first>=0xc2u&&first<=0xdfu){v=first&0x1fu;need=1;min=0x80u;}
        else if(first>=0xe0u&&first<=0xefu){v=first&0x0fu;need=2;min=0x800u;}
        else if(first>=0xf0u&&first<=0xf4u){v=first&7u;need=3;min=0x10000u;}
        else return 0;
        if(need>n-at) return 0;
        for(i=0;i<need;++i){uint8_t x=b[at++];if((x&0xc0u)!=0x80u)return 0;v=(v<<6)|(x&0x3fu);}
        if((need&&v<min)||!scalar_valid(v)||count>=MAX_OUTPUTS)return 0;
        out[count++]=v;
    }
    if(!count)return 0;
    *out_n=count;
    return 1;
}
static uint32_t nx_dead_mark(const char *s)
{
#define NX_DEAD(n,v) if(nx_equal(s,n))return(v)
    NX_DEAD("dead_acute",0x0301u);
    NX_DEAD("dead_apostrophe",0x0301u);
    NX_DEAD("dead_grave",0x0300u);
    NX_DEAD("dead_diaeresis",0x0308u);
    NX_DEAD("dead_circumflex",0x0302u);
    NX_DEAD("dead_tilde",0x0303u);
    NX_DEAD("dead_macron",0x0304u);
    NX_DEAD("dead_breve",0x0306u);
    NX_DEAD("dead_abovedot",0x0307u);
    NX_DEAD("dead_cedilla",0x0327u);
    NX_DEAD("dead_ogonek",0x0328u);
    NX_DEAD("dead_caron",0x030cu);
    NX_DEAD("dead_doubleacute",0x030bu);
    NX_DEAD("dead_ring",0x030au);
    NX_DEAD("dead_stroke",0x0338u);
#undef NX_DEAD
    return 0;
}
static uint32_t nx_keysym(const char *s)
{
    uint32_t n=string_length(s,XCOMPOSE_MAX_NAME+1u),v=0,i;
    if(!n||n>XCOMPOSE_MAX_NAME)return 0;
    /* Preserve the existing explicit Uxxxx scalar policy; the shared XKB
     * resolver's stricter keymap filter is only used for named keysyms. */
    if(n>=5u&&n<=7u&&s[0]=='U'){
        for(i=1;i<n;++i){int d=nx_hex(s[i]);if(d<0)return 0;v=(v<<4)|(uint32_t)d;}
        return scalar_valid(v)?v:0;
    }
    /* X11 defines dead keys as function keysyms, not as text character
     * keysyms. They are accepted only in the dedicated dead-key lead path. */
    if(n>=5u&&s[0]=='d'&&s[1]=='e'&&s[2]=='a'&&s[3]=='d'&&s[4]=='_')
        return 0;
    return xkb_keysym_name_to_unicode(s,n);
}
static int nx_quoted(const char *s,uint32_t out[MAX_OUTPUTS],
                     uint32_t *out_n,uint32_t *end)
{
    uint8_t bytes[MAX_OUTPUTS*4u];
    uint32_t n=0,at=1;
    if(!s||s[0]!='"')return 0;
    while(s[at]){
        uint32_t v,digits,i;
        char ch=s[at++];
        if(ch=='"'){if(!nx_utf8_scalars(bytes,n,out,out_n))return 0;*end=at;return 1;}
        if(ch!='\\'){if(!nx_put_byte(bytes,&n,sizeof(bytes),(uint8_t)ch))return 0;continue;}
        ch=s[at++];if(!ch)return 0;
        switch(ch){
        case '"':v='"';break;case '\\':v='\\';break;case '\'':v='\'';break;
        case 'a':v=7;break;case 'b':v=8;break;case 'f':v=12;break;
        case 'n':v=10;break;case 'r':v=13;break;case 't':v=9;break;case 'v':v=11;break;
        case 'x':
            v=0;digits=0;
            while(digits<2u&&nx_hex(s[at])>=0){v=(v<<4)|(uint32_t)nx_hex(s[at++]);++digits;}
            if(!digits||!nx_put_byte(bytes,&n,sizeof(bytes),v))return 0;
            continue;
        case 'u':case 'U':
            digits=ch=='u'?4u:8u;v=0;
            for(i=0;i<digits;++i){int d=nx_hex(s[at++]);if(d<0)return 0;v=(v<<4)|(uint32_t)d;}
            if(!nx_put_utf8(bytes,&n,sizeof(bytes),v))return 0;
            continue;
        default:
            if(ch>='0'&&ch<='7'){
                v=(uint32_t)(ch-'0');digits=1;
                while(digits<3u&&s[at]>='0'&&s[at]<='7'){v=(v<<3)|(uint32_t)(s[at++]-'0');++digits;}
                if(!nx_put_byte(bytes,&n,sizeof(bytes),v))return 0;
                continue;
            }
            return 0;
        }
        if(!nx_put_byte(bytes,&n,sizeof(bytes),v))return 0;
    }
    return 0;
}
static int nx_same(const struct native_compose_rule *a,const struct native_compose_rule *b)
{
    uint32_t i;
    if(a->kind!=b->kind||a->input_count!=b->input_count)return 0;
    for(i=0;i<a->input_count;++i)if(a->input[i]!=b->input[i])return 0;
    return 1;
}
static int nx_prefix(const struct native_compose_rule *a,const struct native_compose_rule *b)
{
    uint32_t i;
    if(a->kind!=b->kind||a->input_count>=b->input_count)return 0;
    for(i=0;i<a->input_count;++i)if(a->input[i]!=b->input[i])return 0;
    return 1;
}
static int nx_compare(const struct native_compose_rule *a,const struct native_compose_rule *b)
{
    uint32_t i,shared;
    if(a->kind<b->kind)return -1;
    if(a->kind>b->kind)return 1;
    shared=a->input_count<b->input_count?a->input_count:b->input_count;
    for(i=0;i<shared;++i){if(a->input[i]<b->input[i])return -1;if(a->input[i]>b->input[i])return 1;}
    if(a->input_count<b->input_count)return -1;
    if(a->input_count>b->input_count)return 1;
    if(a->order>b->order)return -1;
    if(a->order<b->order)return 1;
    return 0;
}
static void nx_swap(struct native_compose_rule *a,struct native_compose_rule *b)
{
    struct native_compose_rule t=*a;*a=*b;*b=t;
}
static void nx_sift(struct native_compose_rule *r,uint32_t root,uint32_t end)
{
    while(root<end/2u){
        uint32_t child=root*2u+1u;
        if(child+1u<end&&nx_compare(&r[child],&r[child+1u])<0)++child;
        if(nx_compare(&r[root],&r[child])>=0)break;
        nx_swap(&r[root],&r[child]);root=child;
    }
}
static void nx_sort(struct native_compose_rule *r,uint32_t n)
{
    uint32_t i,end;
    for(i=n/2u;i>0;--i)nx_sift(r,i-1u,n);
    for(end=n;end>1u;--end){nx_swap(&r[0],&r[end-1u]);nx_sift(r,0,end-1u);}
}
static uint32_t nx_left(const char *s,uint32_t a,uint32_t b)
{
    while(a<b&&nx_space(s[a]))++a;
    return a;
}
static uint32_t nx_right(const char *s,uint32_t a,uint32_t b)
{
    while(b>a&&nx_space(s[b-1u]))--b;
    return b;
}
static int nx_events(const char *s,uint32_t n,char names[8][XCOMPOSE_MAX_NAME+1u],uint32_t *count)
{
    uint32_t at=0,num=0,residue=0;
    while(at<n){
        if(nx_space(s[at])){++at;continue;}
        if(s[at]!='<'){residue=1;++at;continue;}
        {
            uint32_t start=++at,end,i;
            while(at<n&&s[at]!='>')++at;
            if(at>=n)return 0;
            end=at++;
            if(end==start||end-start>XCOMPOSE_MAX_NAME||num>=8u)return 0;
            for(i=start;i<end;++i){if(nx_space(s[i])||s[i]=='<')return 0;names[num][i-start]=s[i];}
            names[num][end-start]=0;++num;
        }
    }
    if(residue||!num)return 0;
    *count=num;return 1;
}
static int nx_add(struct native_compose_rule *rules,uint32_t *n,uint32_t kind,
                  const uint32_t *in,uint32_t ni,const uint32_t *out,uint32_t no,uint32_t order)
{
    struct native_compose_rule *r;
    uint32_t i;
    if(*n>=MAX_RECORDS||kind>1u||ni<2u||
       ni>(kind==0u?MAX_MULTI_KEY_INPUTS:MAX_INPUTS)||
       no<1u||no>MAX_OUTPUTS)return 0;
    r=&rules[(*n)++];
    for(i=0;i<MAX_INPUTS;++i)r->input[i]=i<ni?in[i]:0;
    for(i=0;i<MAX_OUTPUTS;++i)r->output[i]=i<no?out[i]:0;
    r->input_count=(uint8_t)ni;r->output_count=(uint8_t)no;r->kind=(uint8_t)kind;r->reserved=0;r->order=order;
    return 1;
}
struct nx_import_state {
    long home_root_fd;
    long system_root_fd;
    uint8_t *workspace;
    uint32_t workspace_capacity;
    uint32_t workspace_used;
    uint32_t total_bytes;
    uint32_t opened_files;
    uint32_t unique_files;
    uint32_t stack_depth;
    uint32_t record_count;
    uint32_t order;
    uint32_t system_locale_ready;
    char system_locale_path[XCOMPOSE_INCLUDE_NAME+1u];
    uint64_t stack_device[XCOMPOSE_INCLUDE_DEPTH];
    uint64_t stack_inode[XCOMPOSE_INCLUDE_DEPTH];
    uint64_t seen_device[XCOMPOSE_INCLUDE_FILES];
    uint64_t seen_inode[XCOMPOSE_INCLUDE_FILES];
};

static uint64_t nx_read64(const uint8_t *p)
{
    return (uint64_t)read32(p) | ((uint64_t)read32(p + 4u) << 32);
}

static int nx_parse_buffer(struct nx_import_state *state,uint8_t *source,
                           uint32_t length,long parent_fd,
                           struct native_compose_rule *rules);

#define NX_INCLUDE_SIBLING 0u
#define NX_INCLUDE_HOME 1u
#define NX_INCLUDE_SYSTEM 2u
#define NX_INCLUDE_LOCALE 3u

static int nx_component_valid(const char *name,uint32_t length)
{
    uint32_t i;
    if(!name||!length||length>=XCOMPOSE_NAME_SIZE||
       (length==1u&&name[0]=='.')||
       (length==2u&&name[0]=='.'&&name[1]=='.'))return 0;
    for(i=0;i<length;++i){
        unsigned char ch=(unsigned char)name[i];
        if(ch<0x21u||ch==0x7fu||ch=='/'||ch=='\\'||ch=='%'||
           ch=='$'||ch=='~'||ch==':'||ch=='"')return 0;
    }
    return 1;
}

/* Open each component beneath root_fd without following symlinks. */
static long nx_open_relative_file(long root_fd,const char *path,long *parent_out)
{
    char component[XCOMPOSE_NAME_SIZE];
    uint32_t length,start=0,end,i;
    long directory,next,file;
    if(root_fd<0||!path||!parent_out)return -1;
    length=string_length(path,XCOMPOSE_NAME_SIZE);
    if(!length||length>=XCOMPOSE_NAME_SIZE||
       path[0]=='/'||path[length-1u]=='/')return -1;
    directory=syscall6(SYS_openat,root_fd,(long)".",
                       O_RDONLY|O_CLOEXEC|O_DIRECTORY|O_NOFOLLOW,0,0,0);
    if(failed(directory))return -1;
    while(start<length){
        end=start;
        while(end<length&&path[end]!='/')++end;
        if(!nx_component_valid(path+start,end-start))goto fail;
        for(i=start;i<end;++i)component[i-start]=path[i];
        component[end-start]=0;
        if(end<length){
            next=syscall6(SYS_openat,directory,(long)component,
                          O_RDONLY|O_CLOEXEC|O_DIRECTORY|O_NOFOLLOW,0,0,0);
            if(failed(next))goto fail;
            (void)syscall6(SYS_close,directory,0,0,0,0,0);
            directory=next;
            start=end+1u;
        }else{
            file=syscall6(SYS_openat,directory,(long)component,
                          O_RDONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK,0,0,0);
            if(failed(file))goto fail;
            *parent_out=directory;
            return file;
        }
    }
fail:
    (void)syscall6(SYS_close,directory,0,0,0,0,0);
    return -1;
}

static int nx_parse_include_name(const char *text,uint32_t length,
                                 char name[XCOMPOSE_INCLUDE_NAME+1u],
                                 uint32_t *kind)
{
    uint32_t at=7u,start,end,i,n;
    if(!text||!kind||length<9u||!nx_equal_ci(text,"include")||
       !nx_space(text[7]))return 0;
    while(at<length&&nx_space(text[at]))++at;
    if(at>=length||text[at]!='"')return 0;
    start=++at;
    while(at<length&&text[at]!='"')++at;
    if(at>=length)return 0;
    end=at++;
    if(end==start||end-start>XCOMPOSE_INCLUDE_NAME)return 0;
    while(at<length&&nx_space(text[at]))++at;
    if(at!=length)return 0;

    n=end-start;
    if(n==2u&&text[start]=='%'&&text[start+1u]=='L'){
        *kind=NX_INCLUDE_LOCALE;
        name[0]=0;
        return 1;
    }
    if(n>3u&&text[start]=='%'&&text[start+2u]=='/'){
        if(text[start+1u]=='H')*kind=NX_INCLUDE_HOME;
        else if(text[start+1u]=='S')*kind=NX_INCLUDE_SYSTEM;
        else return 0;
        start+=3u;
        n-=3u;
    }else{
        *kind=NX_INCLUDE_SIBLING;
        for(i=0;i<n;++i)
            if(text[start+i]=='/'||text[start+i]=='%')return 0;
    }
    if(!n||n>XCOMPOSE_INCLUDE_NAME||
       text[start]=='/'||text[start+n-1u]=='/')return 0;
    for(i=0;i<n;++i){
        unsigned char ch=(unsigned char)text[start+i];
        if(ch<0x21u||ch==0x7fu||ch=='\\'||ch=='%'||ch=='$'||
           ch=='~'||ch==':'||ch=='"')return 0;
        name[i]=text[start+i];
    }
    name[n]=0;
    return 1;
}

static long nx_include_root(struct nx_import_state *state,uint32_t kind)
{
    const char *path;
    long fd;
    if(!state)return -1;
    if(kind==NX_INCLUDE_HOME){
        if(state->home_root_fd>=0)return state->home_root_fd;
        path=environment_value(home_env);
        if(!path||!path[0]||path[0]!='/')return -1;
        fd=syscall6(SYS_openat,AT_FDCWD,(long)path,
                    O_RDONLY|O_CLOEXEC|O_DIRECTORY|O_NOFOLLOW,0,0,0);
        if(failed(fd))return -1;
        state->home_root_fd=fd;
        return fd;
    }
    if(kind==NX_INCLUDE_SYSTEM||kind==NX_INCLUDE_LOCALE){
        if(state->system_root_fd>=0)return state->system_root_fd;
        path=environment_value(system_root_env);
        if(!path||!path[0])path=default_system_root;
        if(path[0]!='/')return -1;
        fd=syscall6(SYS_openat,AT_FDCWD,(long)path,
                    O_RDONLY|O_CLOEXEC|O_DIRECTORY|O_NOFOLLOW,0,0,0);
        if(failed(fd))return -1;
        state->system_root_fd=fd;
        return fd;
    }
    return -1;
}

static int nx_path_components_valid(const char *path,uint32_t length)
{
    uint32_t start=0,end,i;
    if(!path||!length||length>XCOMPOSE_INCLUDE_NAME||
       path[0]=='/'||path[length-1u]=='/')return 0;
    while(start<length){
        end=start;
        while(end<length&&path[end]!='/')++end;
        if(!nx_component_valid(path+start,end-start))return 0;
        for(i=start;i<end;++i){
            unsigned char ch=(unsigned char)path[i];
            if(ch=='\\'||ch=='%'||ch=='$'||ch=='~'||ch==':'||ch=='"')
                return 0;
        }
        start=end+1u;
    }
    return 1;
}

/* %L uses X.Org compose.dir to map the process locale to a Compose file. */
static int nx_system_locale_path(struct nx_import_state *state,
                                 char path[XCOMPOSE_INCLUDE_NAME+1u])
{
    const char *value=environment_value(lc_all_env);
    char tag[MAX_TAG_LENGTH+1u];
    uint32_t n,old_used=0,workspace_start=0,offset=0;
    uint32_t line_end,colon,left_a,left_b,right_a,right_b,i;
    long root,fd=-1,parent_fd=-1,result,size;
    int ok=0,reserved=0;
    if(!state||!path)return 0;
    if(state->system_locale_ready){
        n=string_length(state->system_locale_path,
                        XCOMPOSE_INCLUDE_NAME+1u);
        if(!n||n>XCOMPOSE_INCLUDE_NAME)return 0;
        for(i=0;i<=n;++i)path[i]=state->system_locale_path[i];
        return 1;
    }
    if(!value||!value[0])value=environment_value(lc_ctype_env);
    if(!value||!value[0])value=environment_value(lang_env);
    if(!value||!value[0])value="C";
    n=normalize_locale_tag(value,tag,sizeof(tag));
    if(!n)return 0;
    if(equals(tag,"POSIX")){
        tag[0]='C';tag[1]=0;n=1u;
    }

    root=nx_include_root(state,NX_INCLUDE_SYSTEM);
    if(failed(root)||root<0)return 0;
    fd=nx_open_relative_file(root,"compose.dir",&parent_fd);
    if(failed(fd))goto nx_system_locale_done;
    {
        uint8_t stat_buffer[256] __attribute__((aligned(16)));
        for(i=0;i<sizeof(stat_buffer);++i)stat_buffer[i]=0;
        result=syscall6(SYS_fstat,fd,(long)stat_buffer,0,0,0,0);
        if(failed(result)||(read32(stat_buffer+24u)&S_IFMT)!=S_IFREG)
            goto nx_system_locale_done;
    }
    size=syscall6(SYS_lseek,fd,0,SEEK_END,0,0,0);
    if(size<=0||size>(long)XCOMPOSE_FILE_LIMIT||
       (uint64_t)size>(uint64_t)(XCOMPOSE_FILE_LIMIT-state->total_bytes))
        goto nx_system_locale_done;
    old_used=state->workspace_used;
    if((uint64_t)size+1u>
       (uint64_t)(state->workspace_capacity-state->workspace_used))
        goto nx_system_locale_done;
    workspace_start=state->workspace_used;
    state->workspace_used+=(uint32_t)size+1u;
    state->total_bytes+=(uint32_t)size;
    reserved=1;
    result=syscall6(SYS_lseek,fd,0,0,0,0,0);
    if(failed(result))goto nx_system_locale_done;
    while(offset<(uint32_t)size){
        result=syscall6(SYS_read,fd,
                        (long)(state->workspace+workspace_start+offset),
                        (uint32_t)size-offset,0,0,0);
        if(result>0){offset+=(uint32_t)result;continue;}
        if(result==-4)continue;
        goto nx_system_locale_done;
    }
    result=syscall6(SYS_read,fd,
                    (long)(state->workspace+workspace_start+offset),
                    1u,0,0,0);
    if(result!=0)goto nx_system_locale_done;
    for(offset=0;offset<(uint32_t)size;++offset)
        if(!state->workspace[workspace_start+offset])
            goto nx_system_locale_done;
    state->workspace[workspace_start+(uint32_t)size]=0;

    offset=0;
    while(offset<(uint32_t)size){
        char *line=(char *)(state->workspace+workspace_start+offset);
        uint32_t line_start=offset;
        line_end=offset;
        while(line_end<(uint32_t)size&&
              state->workspace[workspace_start+line_end]!='\n')
            ++line_end;
        if(line_end-line_start>XCOMPOSE_LINE_LIMIT)
            goto nx_system_locale_done;
        offset=line_end<(uint32_t)size?line_end+1u:line_end;
        if(line_end>line_start&&line[line_end-line_start-1u]=='\r')
            line[line_end-line_start-1u]=0;
        else
            line[line_end-line_start]=0;
        n=(uint32_t)string_length(line,XCOMPOSE_LINE_LIMIT+1u);
        left_a=nx_left(line,0u,n);
        left_b=nx_right(line,left_a,n);
        if(left_a==left_b)continue;
        if(line[left_a]=='#'||nx_equal_ci(line+left_a,"XCOMM"))
            continue;
        colon=0xffffffffu;
        for(i=left_a;i<left_b;++i)
            if(line[i]==':'){colon=i;break;}
        if(colon==0xffffffffu)continue;
        left_b=nx_right(line,left_a,colon);
        right_a=nx_left(line,colon+1u,n);
        right_b=nx_right(line,right_a,n);
        if(left_a==left_b||right_a==right_b)continue;
        if(right_b-right_a!=string_length(tag,MAX_TAG_LENGTH+1u))
            continue;
        for(i=0;i<right_b-right_a;++i)
            if(line[right_a+i]!=tag[i])break;
        if(i!=right_b-right_a)continue;
        if(left_b-left_a>XCOMPOSE_INCLUDE_NAME||
           !nx_path_components_valid(line+left_a,left_b-left_a))
            goto nx_system_locale_done;
        for(i=0;i<left_b-left_a;++i)
            state->system_locale_path[i]=line[left_a+i];
        state->system_locale_path[left_b-left_a]=0;
        state->system_locale_ready=1u;
        for(i=0;i<=left_b-left_a;++i)
            path[i]=state->system_locale_path[i];
        ok=1;
        break;
    }

nx_system_locale_done:
    if(reserved)state->workspace_used=old_used;
    if(fd>=0)(void)syscall6(SYS_close,fd,0,0,0,0,0);
    if(parent_fd>=0)(void)syscall6(SYS_close,parent_fd,0,0,0,0,0);
    return ok;
}

static int nx_parse_file(struct nx_import_state *state,long base_fd,
                         const char *name,struct native_compose_rule *rules)
{
    uint8_t stat_buffer[256] __attribute__((aligned(16)));
    uint64_t device, inode;
    long fd,parent_fd=-1,result,size;
    uint32_t i,offset,workspace_start,unique=0;
    int ok=0;
    if(!state||!name||!name[0]||
       state->stack_depth>=XCOMPOSE_INCLUDE_DEPTH||
       state->opened_files>=XCOMPOSE_INCLUDE_EXPANSIONS+1u)
        return 0;
    fd=nx_open_relative_file(base_fd,name,&parent_fd);
    if(failed(fd))return 0;
    for (i = 0; i < sizeof(stat_buffer); ++i) stat_buffer[i] = 0;
    result = syscall6(SYS_fstat, fd, (long)stat_buffer, 0, 0, 0, 0);
    if (failed(result) || (read32(stat_buffer + 24u) & S_IFMT) != S_IFREG)
        goto nx_parse_file_done;
    device = nx_read64(stat_buffer);
    inode = nx_read64(stat_buffer + 8u);

    for (i = 0; i < state->stack_depth; ++i) {
        if (state->stack_device[i] == device && state->stack_inode[i] == inode)
            goto nx_parse_file_done;
    }
    for (i = 0; i < state->unique_files; ++i) {
        if (state->seen_device[i] == device && state->seen_inode[i] == inode) {
            unique = 1u;
            break;
        }
    }
    if (!unique) {
        if (state->unique_files >= XCOMPOSE_INCLUDE_FILES)
            goto nx_parse_file_done;
        state->seen_device[state->unique_files] = device;
        state->seen_inode[state->unique_files] = inode;
        ++state->unique_files;
    }

    size = syscall6(SYS_lseek, fd, 0, SEEK_END, 0, 0, 0);
    if (size < 0 || size > (long)XCOMPOSE_FILE_LIMIT ||
        (uint64_t)size > (uint64_t)(XCOMPOSE_FILE_LIMIT - state->total_bytes))
        goto nx_parse_file_done;
    if ((uint64_t)size + 1u >
        (uint64_t)(state->workspace_capacity - state->workspace_used))
        goto nx_parse_file_done;
    result = syscall6(SYS_lseek, fd, 0, 0, 0, 0, 0);
    if (failed(result)) goto nx_parse_file_done;

    workspace_start = state->workspace_used;
    state->workspace_used += (uint32_t)size + 1u;
    state->total_bytes += (uint32_t)size;
    ++state->opened_files;
    state->stack_device[state->stack_depth] = device;
    state->stack_inode[state->stack_depth] = inode;
    ++state->stack_depth;

    offset = 0;
    while (offset < (uint32_t)size) {
        result = syscall6(SYS_read, fd,
                          (long)(state->workspace + workspace_start + offset),
                          (uint32_t)size - offset, 0, 0, 0);
        if (result > 0) {
            offset += (uint32_t)result;
            continue;
        }
        if (result == -4) continue;
        goto nx_parse_file_unwind;
    }
    result = syscall6(SYS_read, fd,
                      (long)(state->workspace + workspace_start + offset),
                      1u, 0, 0, 0);
    if (result != 0) goto nx_parse_file_unwind;
    for (offset = 0; offset < (uint32_t)size; ++offset)
        if (!state->workspace[workspace_start + offset])
            goto nx_parse_file_unwind;
    state->workspace[workspace_start + (uint32_t)size] = 0;

    ok = nx_parse_buffer(state,state->workspace+workspace_start,
                         (uint32_t)size,parent_fd,rules);

nx_parse_file_unwind:
    --state->stack_depth;
    state->workspace_used = workspace_start;
nx_parse_file_done:
    (void)syscall6(SYS_close,fd,0,0,0,0,0);
    if(parent_fd>=0)(void)syscall6(SYS_close,parent_fd,0,0,0,0,0);
    return ok;
}

static int nx_parse_buffer(struct nx_import_state *state,uint8_t *source,
                           uint32_t length,long parent_fd,
                           struct native_compose_rule *rules)
{
    uint32_t at = 0;
    if (length >= 3u && source[0] == 0xefu &&
        source[1] == 0xbbu && source[2] == 0xbfu)
        at = 3u;
    while (at < length) {
        uint32_t start = at, end, comment = 0xffffffffu;
        uint32_t colon = 0xffffffffu, quote = 0, escape = 0;
        uint32_t left_a, left_b, right_a, names_n = 0, i;
        char names[8][XCOMPOSE_MAX_NAME + 1u], *line;
        while (at < length && source[at] != '\n') ++at;
        end = at;
        if (at < length) ++at;
        if (end - start > XCOMPOSE_LINE_LIMIT) return 0;
        if (end < length) source[end] = 0;
        else source[length] = 0;
        line = (char *)(source + start);
        if (end > start && line[end - start - 1u] == '\r')
            line[end - start - 1u] = 0;
        {
            uint32_t len = (uint32_t)string_length(line, XCOMPOSE_LINE_LIMIT + 1u);
            for (i = 0; i < len; ++i) {
                char ch = line[i];
                if (quote) {
                    if (escape) escape = 0;
                    else if (ch == '\\') escape = 1;
                    else if (ch == '"') quote = 0;
                } else if (ch == '"') {
                    quote = 1;
                } else {
                    if (ch == '#') { comment = i; break; }
                    if (ch == ':' && colon == 0xffffffffu) colon = i;
                }
            }
            if (comment != 0xffffffffu) {
                line[comment] = 0;
                len = comment;
            }
            left_a = nx_left(line, 0u, colon < len ? colon : len);
            left_b = nx_right(line, left_a, colon < len ? colon : len);
            if (left_a == left_b) continue;

            if (left_b - left_a >= 7u &&
                nx_equal_ci(line + left_a, "include") &&
                (left_b - left_a == 7u || nx_space(line[left_a + 7u]))) {
                char include_name[XCOMPOSE_INCLUDE_NAME + 1u];
                uint32_t include_kind=NX_INCLUDE_SIBLING;
                long include_root=parent_fd;
                if(!nx_parse_include_name(line+left_a,left_b-left_a,
                                          include_name,&include_kind))
                    return 0;
                if(include_kind==NX_INCLUDE_HOME||
                   include_kind==NX_INCLUDE_SYSTEM||
                   include_kind==NX_INCLUDE_LOCALE)
                    include_root=nx_include_root(state,include_kind);
                if(include_kind==NX_INCLUDE_LOCALE&&
                   !nx_system_locale_path(state,include_name))
                    return 0;
                if(failed(include_root)||include_root<0||!include_name[0]||
                   !nx_parse_file(state,include_root,include_name,rules))
                    return 0;
                continue;
            }

            if (left_b - left_a >= 5u && line[left_a] == 'X' &&
                line[left_a + 1u] == 'C' && line[left_a + 2u] == 'O' &&
                line[left_a + 3u] == 'M' && line[left_a + 4u] == 'M')
                continue;
            if (colon == 0xffffffffu || colon >= len) continue;
            if (!nx_events(line + left_a, left_b - left_a, names, &names_n))
                continue;
            {
                uint32_t kind, inputs[MAX_INPUTS], ni = 0;
                uint32_t outputs[MAX_OUTPUTS], no = 0, j, mark;
                if (nx_equal(names[0], "Multi_key")) {
                    kind = 0;
                    if (names_n < 3u || names_n > 5u) continue;
                } else {
                    mark = nx_dead_mark(names[0]);
                    if (!mark || names_n < 2u || names_n > 8u) continue;
                    kind = 1;
                    inputs[ni++] = mark;
                }
                for (j = 1u; j < names_n; ++j) {
                    uint32_t scalar;
                    if (kind == 1u && j + 1u < names_n) {
                        /* Every intermediate event in a dead-key chain must
                         * itself be a recognized dead action. */
                        scalar = nx_dead_mark(names[j]);
                    } else {
                        /* The final event is the ordinary base character. */
                        if (kind == 1u && nx_dead_mark(names[j])) break;
                        scalar = nx_keysym(names[j]);
                    }
                    if (!scalar || !scalar_valid(scalar) ||
                        ni >= (kind == 0u ? MAX_MULTI_KEY_INPUTS : MAX_INPUTS))
                        break;
                    inputs[ni++] = scalar;
                }
                if (j != names_n || ni < 2u ||
                    ni > (kind == 0u ? MAX_MULTI_KEY_INPUTS : MAX_INPUTS)) continue;
                right_a = nx_left(line, colon + 1u, len);
                if (right_a >= len) continue;
                if (line[right_a] == '"') {
                    uint32_t end_quote = 0;
                    if (!nx_quoted(line + right_a, outputs, &no, &end_quote))
                        continue;
                } else {
                    char result[XCOMPOSE_MAX_NAME + 1u];
                    uint32_t right_b = right_a;
                    while (right_b < len && !nx_space(line[right_b])) ++right_b;
                    if (right_b == right_a || right_b - right_a > XCOMPOSE_MAX_NAME)
                        continue;
                    for (j = right_a; j < right_b; ++j)
                        result[j - right_a] = line[j];
                    result[right_b - right_a] = 0;
                    outputs[0] = nx_keysym(result);
                    if (!scalar_valid(outputs[0])) continue;
                    no = 1u;
                }
                if (!nx_add(rules, &state->record_count, kind, inputs, ni,
                            outputs, no, state->order++))
                    return 0;
            }
        }
    }
    return 1;
}

static uint32_t nx_parse_path(int root_fd, const char *root_name,
                             uint8_t *workspace, uint32_t workspace_capacity,
                             struct native_compose_rule *rules)
{
    struct nx_import_state state;
    uint32_t i, unique = 0, kept = 0;
    state.home_root_fd=-1;
    state.system_root_fd=-1;
    state.workspace = workspace;
    state.workspace_capacity = workspace_capacity;
    state.workspace_used = 0;
    state.total_bytes = 0;
    state.opened_files = 0;
    state.unique_files = 0;
    state.stack_depth = 0;
    state.record_count = 0;
    state.order = 0;
    state.system_locale_ready=0;
    state.system_locale_path[0]=0;
    if(!nx_parse_file(&state,root_fd,root_name,rules)||!state.record_count)
        goto nx_parse_path_cleanup;

    nx_sort(rules,state.record_count);
    for (i = 0; i < state.record_count; ++i) {
        if (unique && nx_same(&rules[unique - 1u], &rules[i]))
            continue;
        if (unique != i) rules[unique] = rules[i];
        ++unique;
    }
    for (i = 0; i < unique; ++i) {
        if (i + 1u < unique && nx_prefix(&rules[i], &rules[i + 1u]))
            continue;
        if (kept != i) rules[kept] = rules[i];
        ++kept;
    }
nx_parse_path_cleanup:
    if(state.home_root_fd>=0)
        (void)syscall6(SYS_close,state.home_root_fd,0,0,0,0,0);
    if(state.system_root_fd>=0)
        (void)syscall6(SYS_close,state.system_root_fd,0,0,0,0,0);
    return kept;
}

static int nx_split_source_path(const char *path,
                                char directory[XCOMPOSE_PATH_SIZE],
                                char basename[XCOMPOSE_NAME_SIZE])
{
    uint32_t length, slash = 0xffffffffu, i;
    if (!path || !path[0] || !directory || !basename) return 0;
    length = string_length(path, XCOMPOSE_PATH_SIZE);
    if (!length || length >= XCOMPOSE_PATH_SIZE) return 0;
    for (i = 0; i < length; ++i)
        if (path[i] == '/') slash = i;
    if (slash == 0xffffffffu) {
        directory[0] = '.';
        directory[1] = 0;
        i = 0;
    } else {
        i = slash + 1u;
        if (slash == 0u) {
            directory[0] = '/';
            directory[1] = 0;
        } else {
            for (uint32_t j = 0; j < slash; ++j) directory[j] = path[j];
            directory[slash] = 0;
        }
    }
    if (i >= length || length - i >= XCOMPOSE_NAME_SIZE)
        return 0;
    for (uint32_t j = 0; j < length - i; ++j) basename[j] = path[i + j];
    basename[length - i] = 0;
    if (nx_equal(basename, ".") || nx_equal(basename, "..")) return 0;
    return 1;
}

static int nx_make_tag(const char *path,char tag[MAX_TAG_LENGTH+1u],uint32_t *length)
{
    const char *base=path,*p;
    static const char ext[]=".XCompose",suffix[]=".UTF-8";
    uint32_t n,used=0,i;
    for(p=path;*p;++p)if(*p=='/')base=p+1;
    n=string_length(base,4096u);
    if(n>=sizeof(ext)-1u){
        uint32_t at=n-(sizeof(ext)-1u);int match=1;
        for(i=0;i<sizeof(ext)-1u;++i)if(nx_lower(base[at+i])!=nx_lower(ext[i]))match=0;
        if(match)n=at;
    }
    if(!n){base="user";n=4u;}
    for(i=0;i<n&&used<XCOMPOSE_TAG_BASE;++i){
        char ch=base[i];
        int valid=(ch>='a'&&ch<='z')||(ch>='A'&&ch<='Z')||
                  (ch>='0'&&ch<='9')||ch=='_'||ch=='-';
        tag[used++]=valid?ch:'_';
    }
    while(used&&(tag[used-1u]=='_'||tag[used-1u]=='-'))--used;
    if(!used){tag[used++]='u';tag[used++]='s';tag[used++]='e';tag[used++]='r';}
    for(i=0;i<sizeof(suffix)-1u;++i)tag[used++]=suffix[i];
    tag[used]=0;
    if(!valid_tag(tag,used)||builtin_tag(tag))return 0;
    *length=used;return 1;
}
static void nx_store16(uint8_t *p,uint16_t v){p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8);}
static void nx_store32(uint8_t *p,uint32_t v){p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8);p[2]=(uint8_t)(v>>16);p[3]=(uint8_t)(v>>24);}
static int nx_build_pack(uint8_t *pack,const char *tag,uint32_t tag_n,
                         struct native_compose_rule *rules,uint32_t count,uint32_t *size)
{
    uint32_t i,payload;
    if(!pack||!tag||!tag_n||!rules||!count||count>MAX_RECORDS||!size)return 0;
    payload=count*RECORD_SIZE;if(HEADER_SIZE+payload>MAX_PACK_SIZE)return 0;
    for(i=0;i<8u;++i)pack[i]=magic[i];
    nx_store32(pack+8u,FORMAT_VERSION);nx_store32(pack+12u,HEADER_SIZE);nx_store32(pack+16u,RECORD_SIZE);
    nx_store32(pack+20u,count);nx_store32(pack+24u,payload);nx_store32(pack+28u,0u);nx_store32(pack+32u,0u);
    for(i=0;i<32u;++i)pack[36u+i]=i<tag_n?(uint8_t)tag[i]:0u;
    nx_store32(pack+68u,0u);
    for(i=0;i<count;++i){
        uint32_t j;uint8_t *record=pack+HEADER_SIZE+i*RECORD_SIZE;
        record[0]=rules[i].input_count;record[1]=rules[i].output_count;nx_store16(record+2u,rules[i].kind);
        for(j=0;j<MAX_INPUTS;++j)nx_store32(record+4u+j*4u,rules[i].input[j]);
        for(j=0;j<MAX_OUTPUTS;++j)nx_store32(record+36u+j*4u,rules[i].output[j]);
    }
    nx_store32(pack+28u,crc32(pack+HEADER_SIZE,payload));*size=HEADER_SIZE+payload;return 1;
}

/* Imports bounded UTF-8 rule files with fail-closed sibling includes. */
uint32_t compose_locale_import_xcompose(const char *source_path)
{
    char tag[MAX_TAG_LENGTH+1u],destination[48],temporary[80];
    char source_directory[XCOMPOSE_PATH_SIZE],source_name[XCOMPOSE_NAME_SIZE];
    struct native_compose_rule *rules=(struct native_compose_rule *)0;
    uint8_t *source=(uint8_t *)0,*pack=(uint8_t *)0;
    uint32_t tag_n=0,count=0,pack_size=0,validated=0;
    uint32_t rules_size=MAX_RECORDS*sizeof(*rules),ok=0,temp_ready=0;
    long source_dir=-1,dir=-1,out=-1,result,mr,ms,mp;
    if(!source_path||!source_path[0]||!nx_make_tag(source_path,tag,&tag_n)||
       !nx_split_source_path(source_path,source_directory,source_name))return 0;
    mr=syscall6(SYS_mmap,0,rules_size,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(failed(mr))goto done;
    rules=(struct native_compose_rule *)(uintptr_t)mr;
    ms=syscall6(SYS_mmap,0,XCOMPOSE_WORKSPACE_SIZE,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(failed(ms))goto done;
    source=(uint8_t *)(uintptr_t)ms;
    mp=syscall6(SYS_mmap,0,MAX_PACK_SIZE,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(failed(mp))goto done;
    pack=(uint8_t *)(uintptr_t)mp;
    source_dir=syscall6(SYS_openat,AT_FDCWD,(long)source_directory,
                        O_RDONLY|O_CLOEXEC|O_DIRECTORY|O_NOFOLLOW,0,0,0);
    if(failed(source_dir)){source_dir=-1;goto done;}
    count=nx_parse_path((int)source_dir,source_name,source,
                        XCOMPOSE_WORKSPACE_SIZE,rules);
    if(!count)goto done;
    (void)syscall6(SYS_close,source_dir,0,0,0,0,0);
    source_dir=-1;
    if(!nx_build_pack(pack,tag,tag_n,rules,count,&pack_size)||
       !validate_pack(pack,pack_size,tag,tag_n,&validated,0,0)||validated!=count)goto done;
    if(!make_pack_names(tag,tag_n,destination,sizeof(destination),temporary,sizeof(temporary)))goto done;
    temp_ready=1;
    dir=open_locale_directory();if(failed(dir)){dir=-1;goto done;}
    (void)syscall6(SYS_unlinkat,dir,(long)temporary,0,0,0,0);
    out=syscall6(SYS_openat,dir,(long)temporary,O_WRONLY|O_CREAT|O_EXCL|O_CLOEXEC|O_NOFOLLOW,FILE_MODE,0,0);
    if(failed(out)){out=-1;goto done;}
    if(!write_all_fd(out,pack,pack_size))goto done;
    result=syscall6(SYS_fsync,out,0,0,0,0,0);if(failed(result))goto done;
    (void)syscall6(SYS_close,out,0,0,0,0,0);out=-1;
    result=syscall6(SYS_linkat,dir,(long)temporary,dir,(long)destination,0,0);
    if(failed(result))goto done;
    result=syscall6(SYS_unlinkat,dir,(long)temporary,0,0,0,0);
    if(failed(result)){
        (void)syscall6(SYS_unlinkat,dir,(long)destination,0,0,0,0);
        goto done;
    }
    result=syscall6(SYS_fsync,dir,0,0,0,0,0);
    if(failed(result)){(void)syscall6(SYS_unlinkat,dir,(long)destination,0,0,0,0);goto done;}
    for(uint32_t i=0;i<tag_n;++i)compose_locale_installed_tag[i]=tag[i];
    compose_locale_installed_tag[tag_n]=0;ok=1;
done:
    if(out>=0)(void)syscall6(SYS_close,out,0,0,0,0,0);
    if(dir>=0){
        if(!ok&&temp_ready)(void)syscall6(SYS_unlinkat,dir,(long)temporary,0,0,0,0);
        (void)syscall6(SYS_close,dir,0,0,0,0,0);
    }
    if(source_dir>=0)(void)syscall6(SYS_close,source_dir,0,0,0,0,0);
    if(pack)(void)syscall6(SYS_munmap,(long)pack,MAX_PACK_SIZE,0,0,0,0);
    if(source)(void)syscall6(SYS_munmap,(long)source,XCOMPOSE_WORKSPACE_SIZE,0,0,0,0);
    if(rules)(void)syscall6(SYS_munmap,(long)rules,rules_size,0,0,0,0);
    return ok;
}
