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
#define RECORD_SIZE 52u
#define MAX_RECORDS 32768u
#define MAX_PACK_SIZE (2u * 1024u * 1024u)
#define MAX_TAG_LENGTH 31u
#define MAX_INPUTS 4u
#define MAX_OUTPUTS 8u

extern char **process_envp;
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
static const char directory_suffix[] = "/.nekoedit/locales/";
static const char extension[] = ".nlp";
static const uint8_t *mapped_pack;
static uint32_t mapped_pack_size;
static uint32_t mapped_record_count;

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
    uint32_t ac = a[0], bc = b[0], shared = ac < bc ? ac : bc, i;
    for (i = 0; i < shared; ++i) {
        uint32_t av = read32(a + 4u + i * 4u);
        uint32_t bv = read32(b + 4u + i * 4u);
        if (av < bv) return -1;
        if (av > bv) return 1;
    }
    return 0;
}

/* A stored longer sequence compares equal when it begins with the input prefix. */
static int compare_record_input(const uint8_t *record,
                                const uint32_t *input, uint32_t input_count)
{
    uint32_t count = record[0], shared = count < input_count ? count : input_count, i;
    for (i = 0; i < shared; ++i) {
        uint32_t value = read32(record + 4u + i * 4u);
        if (value < input[i]) return -1;
        if (value > input[i]) return 1;
    }
    return count < input_count ? -1 : 0;
}

static int validate_pack(const uint8_t *data, uint32_t size,
                         const char *tag, uint32_t tag_length,
                         uint32_t *record_count)
{
    const uint8_t *payload;
    uint32_t count, payload_size, i;
    if (!data || size < HEADER_SIZE || size > MAX_PACK_SIZE) return 0;
    for (i = 0; i < sizeof(magic); ++i)
        if (data[i] != magic[i]) return 0;
    if (read32(data + 8) != 1u || read32(data + 12) != HEADER_SIZE ||
        read32(data + 16) != RECORD_SIZE || read32(data + 32) != 0u ||
        read32(data + 68) != 0u) return 0;

    count = read32(data + 20);
    payload_size = read32(data + 24);
    if (!count || count > MAX_RECORDS ||
        payload_size != count * RECORD_SIZE ||
        size != HEADER_SIZE + payload_size) return 0;
    if (data[36u + tag_length] != 0u) return 0;
    for (i = 0; i < tag_length; ++i)
        if (data[36u + i] != (uint8_t)tag[i]) return 0;
    for (i = tag_length + 1u; i < 32u; ++i)
        if (data[36u + i] != 0u) return 0;

    payload = data + HEADER_SIZE;
    if (crc32(payload, payload_size) != read32(data + 28)) return 0;
    for (i = 0; i < count; ++i) {
        const uint8_t *record = payload + i * RECORD_SIZE;
        uint32_t inputs = record[0], outputs = record[1], j;
        if (inputs < 2u || inputs > MAX_INPUTS ||
            outputs < 1u || outputs > MAX_OUTPUTS ||
            read16(record + 2) != 0u) return 0;
        for (j = 0; j < MAX_INPUTS; ++j) {
            uint32_t value = read32(record + 4u + j * 4u);
            if (j < inputs) {
                if (!scalar_valid(value)) return 0;
            } else if (value) return 0;
        }
        for (j = 0; j < MAX_OUTPUTS; ++j) {
            uint32_t value = read32(record + 20u + j * 4u);
            if (j < outputs) {
                if (!scalar_valid(value)) return 0;
            } else if (value) return 0;
        }
        if (i && compare_records(record - RECORD_SIZE, record) >= 0)
            return 0;
    }
    *record_count = count;
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
    static const char pt_br_canonical[] = "pt_BR.UTF-8";
    const char *tag = requested_tag;
    const char *home = environment_value(home_env);
    uint32_t tag_length, home_length, count = 0;
    char path[4096];
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

    /* Normalize common glibc locale spellings to the one packaged table tag. */
    if (tag && (equals(tag, "pt_BR") || equals(tag, "pt_BR.utf8") ||
                equals(tag, "pt_BR.UTF8") || equals(tag, "pt_br") ||
                equals(tag, "pt_br.utf8") || equals(tag, "pt_br.UTF-8")))
        tag = pt_br_canonical;
    compose_locale_active = 0;
    compose_locale_current_tag[0] = 0;
    if (mapped_pack && mapped_pack_size)
        (void)syscall6(SYS_munmap, (long)mapped_pack, mapped_pack_size, 0, 0, 0, 0);
    mapped_pack = (const uint8_t *)0;
    mapped_pack_size = 0;
    mapped_record_count = 0;
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
    if (!validate_pack(candidate, (uint32_t)size, tag, tag_length, &count)) {
        (void)syscall6(SYS_munmap, address, size, 0, 0, 0, 0);
        return 0;
    }
    mapped_pack = candidate;
    mapped_pack_size = (uint32_t)size;
    mapped_record_count = count;
    compose_locale_active = 1;
    {
        uint32_t i;
        for (i = 0; i < tag_length; ++i) compose_locale_current_tag[i] = tag[i];
        compose_locale_current_tag[tag_length] = 0;
    }
    return 1;
}

static uint32_t find_lower_bound(const uint32_t *input, uint32_t input_count)
{
    uint32_t low = 0, high = mapped_record_count;
    const uint8_t *records = mapped_pack + HEADER_SIZE;
    while (low < high) {
        uint32_t mid = low + (high - low) / 2u;
        const uint8_t *record = records + mid * RECORD_SIZE;
        if (compare_record_input(record, input, input_count) < 0)
            low = mid + 1u;
        else
            high = mid;
    }
    return low;
}

uint32_t compose_locale_lookup(uint32_t input_count,
                               const uint32_t *input, uint32_t *output)
{
    const uint8_t *records, *record;
    uint32_t index, i;
    if (!compose_locale_active || !mapped_pack || !input || !output ||
        input_count < 2u || input_count > MAX_INPUTS) return 0;
    records = mapped_pack + HEADER_SIZE;
    index = find_lower_bound(input, input_count);
    if (index >= mapped_record_count) return 0;
    record = records + index * RECORD_SIZE;
    if (record[0] != input_count ||
        compare_record_input(record, input, input_count) != 0) return 0;
    for (i = 0; i < record[1]; ++i)
        output[i] = read32(record + 20u + i * 4u);
    return record[1];
}

uint32_t compose_locale_prefix(uint32_t input_count, const uint32_t *input)
{
    const uint8_t *records, *record;
    uint32_t index;
    if (!compose_locale_active || !mapped_pack || !input ||
        input_count < 1u || input_count >= MAX_INPUTS) return 0;
    records = mapped_pack + HEADER_SIZE;
    index = find_lower_bound(input, input_count);
    if (index >= mapped_record_count) return 0;
    record = records + index * RECORD_SIZE;
    return record[0] > input_count &&
           compare_record_input(record, input, input_count) == 0;
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
        !validate_pack(bytes, (uint32_t)size, tag, *tag_length, record_count)) {
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
            !validate_pack(mapped, (uint32_t)file_size, tag_copy, tag_length, &records)) {
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
