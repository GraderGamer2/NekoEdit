#include <stdint.h>
#include <stddef.h>

/* Persistent user preferences. Raw Linux syscalls only; no libc dependency. */
#define SYS_read 0
#define SYS_write 1
#define SYS_close 3
#define SYS_fsync 74
#define SYS_getpid 39
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
#define O_DIRECTORY 0x10000

#define PATH_CAPACITY 4096u
#define CONFIG_CAPACITY 8192u
#define FILE_MODE 0600u
#define DIRECTORY_MODE 0700u

extern char **process_envp;
extern int32_t doc_font_size;
extern int32_t ui_font_size;
extern int32_t doc_wrap_enabled;
extern int32_t save_confirm_enabled;
int32_t clipboard_persistence_enabled = 1;
/* text-input-v3 takes over printable input, so require an explicit opt-in
 * until live GNOME/Mutter IME handoff is verified. */
int32_t text_input_opt_in = 0;

char *preferences_font_path_ptr;
char *preferences_locale_ptr;

static char application_directory[PATH_CAPACITY];
static char preferences_path[PATH_CAPACITY];
static char temporary_path[PATH_CAPACITY];
static char saved_font_path[PATH_CAPACITY];
static char saved_locale_tag[32];
static uint8_t config_buffer[CONFIG_CAPACITY];
static uint8_t output_buffer[CONFIG_CAPACITY];

static long syscall6(long number, long a1, long a2, long a3,
                     long a4, long a5, long a6)
{
    register long rax __asm__("rax") = number;
    register long r10 __asm__("r10") = a4;
    register long r8 __asm__("r8") = a5;
    register long r9 __asm__("r9") = a6;
    __asm__ volatile ("syscall"
        : "+a"(rax)
        : "D"(a1), "S"(a2), "d"(a3),
          "r"(r10), "r"(r8), "r"(r9)
        : "rcx", "r11", "memory");
    return rax;
}

static int syscall_error(long value)
{
    return value < 0 && value >= -4095;
}

static uint32_t bounded_length(const char *text, uint32_t limit)
{
    uint32_t length = 0;
    if (!text)
        return 0;
    while (length < limit && text[length])
        ++length;
    return length;
}

static int prefix_matches(const char *line, const char *prefix, uint32_t length)
{
    uint32_t i;
    for (i = 0; i < length; ++i)
        if (line[i] != prefix[i])
            return 0;
    return 1;
}

static const char *environment_value(const char *key)
{
    uint32_t key_length = bounded_length(key, 128);
    char **entry = process_envp;
    if (!entry || !key_length)
        return (const char *)0;
    while (*entry) {
        const char *candidate = *entry;
        uint32_t i = 0;
        while (i < key_length && candidate[i] == key[i])
            ++i;
        if (i == key_length && candidate[i] == '=')
            return candidate + i + 1;
        ++entry;
    }
    return (const char *)0;
}

static int disabled(void)
{
    const char *value = environment_value("NEKOEDIT_DISABLE_PREFERENCES");
    return value && value[0] == '1' && value[1] == 0;
}

static int copy_text(char *destination, uint32_t capacity,
                     const char *source, uint32_t length)
{
    uint32_t i;
    if (!destination || !source || !capacity || length >= capacity)
        return 0;
    for (i = 0; i < length; ++i)
        destination[i] = source[i];
    destination[length] = 0;
    return 1;
}


static int valid_locale_tag(const char *tag, uint32_t length)
{
    uint32_t i;
    if (!tag || !length || length > 31u ||
        tag[0] == '.' || tag[length - 1u] == '.')
        return 0;
    for (i = 0; i < length; ++i) {
        char value = tag[i];
        int valid = (value >= 'a' && value <= 'z') ||
                    (value >= 'A' && value <= 'Z') ||
                    (value >= '0' && value <= '9') ||
                    value == '_' || value == '-' || value == '.' || value == '@';
        if (!valid || (value == '.' && i + 1u < length && tag[i + 1u] == '.'))
            return 0;
    }
    return 1;
}

static int store_locale_tag(const char *tag, uint32_t length)
{
    if (!tag || !length || !valid_locale_tag(tag, length) ||
        !copy_text(saved_locale_tag, sizeof(saved_locale_tag), tag, length))
        return 0;
    preferences_locale_ptr = saved_locale_tag;
    return 1;
}

int preferences_set_locale_tag(const char *tag)
{
    uint32_t length;
    if (!tag || !tag[0]) {
        saved_locale_tag[0] = 0;
        preferences_locale_ptr = (char *)0;
        return 1;
    }
    length = bounded_length(tag, sizeof(saved_locale_tag));
    return store_locale_tag(tag, length);
}

int preferences_locale_is_pt_br(void)
{
    static const char target[] = "pt_BR.UTF-8";
    uint32_t i;
    if (!preferences_locale_ptr)
        return 0;
    for (i = 0; i < sizeof(target); ++i)
        if (preferences_locale_ptr[i] != target[i])
            return 0;
    return 1;
}

int preferences_locale_is_builtin(void)
{
    static const char en_us_utf8[] = "en_US.UTF-8";
    static const char en_us[] = "en_US";
    static const char c_locale[] = "C";
    static const char c_utf8[] = "C.UTF-8";
    static const char posix[] = "POSIX";
    const char *choices[] = {en_us_utf8, en_us, c_locale, c_utf8, posix};
    const char *value = preferences_locale_ptr;
    uint32_t choice, i;
    if (!value)
        return 0;
    for (choice = 0; choice < sizeof(choices) / sizeof(choices[0]); ++choice) {
        const char *candidate = choices[choice];
        for (i = 0; value[i] && candidate[i] && value[i] == candidate[i]; ++i) {}
        if (!value[i] && !candidate[i])
            return 1;
    }
    return 0;
}

static int append_component(char *destination, uint32_t capacity,
                            uint32_t *length, const char *component)
{
    uint32_t component_length = bounded_length(component, capacity);
    uint32_t i;
    if (!component || component_length >= capacity)
        return 0;
    if (*length && destination[*length - 1] != '/') {
        if (*length + 1 >= capacity)
            return 0;
        destination[(*length)++] = '/';
    }
    if (*length + component_length >= capacity)
        return 0;
    for (i = 0; i < component_length; ++i)
        destination[(*length)++] = component[i];
    destination[*length] = 0;
    return 1;
}

static int append_literal(char *destination, uint32_t capacity,
                          uint32_t *length, const char *literal)
{
    return append_component(destination, capacity, length, literal);
}

static int build_paths(void)
{
    const char *home = environment_value("HOME");
    uint32_t home_length, length;

    application_directory[0] = 0;
    preferences_path[0] = 0;
    temporary_path[0] = 0;

    home_length = bounded_length(home, PATH_CAPACITY);
    if (!home || !home_length || home[0] != '/' ||
        home_length >= PATH_CAPACITY - 12u)
        return 0;
    if (!copy_text(application_directory, PATH_CAPACITY, home, home_length))
        return 0;
    length = home_length;
    if (!append_literal(application_directory, PATH_CAPACITY, &length, ".nekoedit"))
        return 0;

    if (!copy_text(preferences_path, PATH_CAPACITY,
                   application_directory, bounded_length(application_directory, PATH_CAPACITY)))
        return 0;
    length = bounded_length(preferences_path, PATH_CAPACITY);
    if (!append_literal(preferences_path, PATH_CAPACITY, &length, "preferences"))
        return 0;

    if (!copy_text(temporary_path, PATH_CAPACITY,
                   application_directory, bounded_length(application_directory, PATH_CAPACITY)))
        return 0;
    length = bounded_length(temporary_path, PATH_CAPACITY);
    if (!append_literal(temporary_path, PATH_CAPACITY, &length, ".preferences.tmp"))
        return 0;
    if (length + 12u >= PATH_CAPACITY)
        return 0;
    temporary_path[length++] = '.';
    {
        uint32_t pid = (uint32_t)syscall6(SYS_getpid, 0, 0, 0, 0, 0, 0);
        char digits[10];
        uint32_t count = 0;
        do {
            digits[count++] = (char)('0' + (pid % 10u));
            pid /= 10u;
        } while (pid && count < sizeof(digits));
        while (count)
            temporary_path[length++] = digits[--count];
        temporary_path[length] = 0;
    }
    return 1;
}

static int make_directory(const char *path)
{
    long result = syscall6(SYS_mkdirat, AT_FDCWD, (long)path,
                           DIRECTORY_MODE, 0, 0, 0);
    return !syscall_error(result) || result == -17; /* EEXIST */
}

static int parse_decimal(const char *value, uint32_t length, uint32_t *number)
{
    uint32_t result = 0, i;
    if (!length || length > 3)
        return 0;
    for (i = 0; i < length; ++i) {
        uint32_t digit;
        if (value[i] < '0' || value[i] > '9')
            return 0;
        digit = (uint32_t)(value[i] - '0');
        result = result * 10u + digit;
    }
    *number = result;
    return 1;
}

static void parse_line(const char *line, uint32_t length)
{
    static const char key_document[] = "document_font_size=";
    static const char key_ui[] = "ui_font_size=";
    static const char key_wrap[] = "wrap_lines=";
    static const char key_confirm[] = "confirm_before_save=";
    static const char key_clipboard[] = "clipboard_persistence=";
    static const char key_font[] = "font_path=";
    static const char key_locale[] = "compose_locale=";
    uint32_t number;
    uint32_t prefix;

    prefix = (uint32_t)(sizeof(key_document) - 1u);
    if (length > prefix && prefix_matches(line, key_document, prefix)) {
        if (parse_decimal(line + prefix, length - prefix, &number) &&
            number >= 8u && number <= 32u && !(number & 1u))
            doc_font_size = (int32_t)number;
        return;
    }

    prefix = (uint32_t)(sizeof(key_ui) - 1u);
    if (length > prefix && prefix_matches(line, key_ui, prefix)) {
        if (parse_decimal(line + prefix, length - prefix, &number) &&
            number >= 8u && number <= 16u)
            ui_font_size = (int32_t)number;
        return;
    }

    prefix = (uint32_t)(sizeof(key_wrap) - 1u);
    if (length > prefix && prefix_matches(line, key_wrap, prefix)) {
        if (parse_decimal(line + prefix, length - prefix, &number) && number <= 1u)
            doc_wrap_enabled = (int32_t)number;
        return;
    }

    prefix = (uint32_t)(sizeof(key_confirm) - 1u);
    if (length > prefix && prefix_matches(line, key_confirm, prefix)) {
        if (parse_decimal(line + prefix, length - prefix, &number) && number <= 1u)
            save_confirm_enabled = (int32_t)number;
        return;
    }

    prefix = (uint32_t)(sizeof(key_clipboard) - 1u);
    if (length > prefix && prefix_matches(line, key_clipboard, prefix)) {
        if (parse_decimal(line + prefix, length - prefix, &number) && number <= 1u)
            clipboard_persistence_enabled = (int32_t)number;
        return;
    }

    prefix = (uint32_t)(sizeof(key_locale) - 1u);
    if (length > prefix && prefix_matches(line, key_locale, prefix)) {
        (void)store_locale_tag(line + prefix, length - prefix);
        return;
    }

    prefix = (uint32_t)(sizeof(key_font) - 1u);
    if (length > prefix && prefix_matches(line, key_font, prefix)) {
        uint32_t path_length = length - prefix;
        if (path_length && path_length < PATH_CAPACITY &&
            line[prefix] == '/' &&
            copy_text(saved_font_path, PATH_CAPACITY, line + prefix, path_length))
            preferences_font_path_ptr = saved_font_path;
    }
}

static uint32_t append_bytes(uint8_t *buffer, uint32_t offset,
                             uint32_t capacity, const char *text,
                             uint32_t length)
{
    uint32_t i;
    if (offset > capacity || length > capacity - offset)
        return UINT32_MAX;
    for (i = 0; i < length; ++i)
        buffer[offset + i] = (uint8_t)text[i];
    return offset + length;
}

static uint32_t append_number(uint8_t *buffer, uint32_t offset,
                              uint32_t capacity, uint32_t number)
{
    char digits[10];
    uint32_t count = 0;
    if (number == 0)
        digits[count++] = '0';
    else {
        while (number && count < sizeof(digits)) {
            digits[count++] = (char)('0' + (number % 10u));
            number /= 10u;
        }
    }
    while (count) {
        if (offset >= capacity)
            return UINT32_MAX;
        buffer[offset++] = (uint8_t)digits[--count];
    }
    return offset;
}

static int write_all(int fd, const uint8_t *bytes, uint32_t length)
{
    uint32_t offset = 0;
    while (offset < length) {
        long result = syscall6(SYS_write, fd, (long)(bytes + offset),
                               length - offset, 0, 0, 0);
        if (result > 0) {
            offset += (uint32_t)result;
            continue;
        }
        if (result == -4)
            continue;
        return 0;
    }
    return 1;
}

int preferences_load(void)
{
    long fd, result;
    uint32_t used = 0, offset = 0;
    const char *text_input = environment_value("NEKOEDIT_ENABLE_TEXT_INPUT");
    text_input_opt_in = text_input && text_input[0] == '1' && text_input[1] == 0 ? 1 : 0;
    preferences_locale_ptr = (char *)0;
    saved_locale_tag[0] = 0;
    if (disabled()) {
        preferences_font_path_ptr = (char *)0;
        saved_font_path[0] = 0;
        clipboard_persistence_enabled = 0;
        return 0;
    }
    preferences_font_path_ptr = (char *)0;
    saved_font_path[0] = 0;
    if (!build_paths() || !make_directory(application_directory))
        return 0;
    fd = syscall6(SYS_openat, AT_FDCWD, (long)preferences_path,
                  O_RDONLY | O_CLOEXEC, 0, 0, 0);
    if (syscall_error(fd))
        return 0;
    while (used < sizeof(config_buffer) - 1u) {
        result = syscall6(SYS_read, fd, (long)(config_buffer + used),
                          sizeof(config_buffer) - 1u - used, 0, 0, 0);
        if (result > 0) {
            used += (uint32_t)result;
            continue;
        }
        if (result == 0)
            break;
        if (result == -4)
            continue;
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        return 0;
    }
    (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
    if (used == sizeof(config_buffer) - 1u)
        return 0; /* Refuse a truncated or oversized file. */
    config_buffer[used] = 0;

    while (offset < used) {
        uint32_t end = offset;
        while (end < used && config_buffer[end] != '\n' && config_buffer[end] != '\r')
            ++end;
        if (end > offset)
            parse_line((const char *)(config_buffer + offset), end - offset);
        offset = end;
        while (offset < used && (config_buffer[offset] == '\n' || config_buffer[offset] == '\r'))
            ++offset;
    }
    return 1;
}

void preferences_set_font_path(const char *path)
{
    uint32_t length = bounded_length(path, PATH_CAPACITY);
    uint32_t i;
    if (!path || !length || length >= PATH_CAPACITY || path[0] != '/') {
        preferences_font_path_ptr = (char *)0;
        saved_font_path[0] = 0;
        return;
    }
    /* The line-oriented on-disk format cannot represent newline characters. */
    for (i = 0; i < length; ++i) {
        if (path[i] == '\n' || path[i] == '\r') {
            preferences_font_path_ptr = (char *)0;
            saved_font_path[0] = 0;
            return;
        }
    }
    if (copy_text(saved_font_path, PATH_CAPACITY, path, length))
        preferences_font_path_ptr = saved_font_path;
}

int preferences_save(void)
{
    long fd, result, directory_fd;
    uint32_t offset = 0;
    uint32_t font_length;
    uint32_t locale_length;
    if (disabled() || !build_paths())
        return 0;
    if (!make_directory(application_directory))
        return 0;

    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                          "version=1\ndocument_font_size=", 29u);
    if (offset == UINT32_MAX)
        return 0;
    offset = append_number(output_buffer, offset, CONFIG_CAPACITY,
                           (uint32_t)doc_font_size);
    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                          "\nui_font_size=", 14u);
    if (offset == UINT32_MAX)
        return 0;
    offset = append_number(output_buffer, offset, CONFIG_CAPACITY,
                           (uint32_t)ui_font_size);
    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                          "\nwrap_lines=", 12u);
    if (offset == UINT32_MAX)
        return 0;
    offset = append_number(output_buffer, offset, CONFIG_CAPACITY,
                           doc_wrap_enabled ? 1u : 0u);
    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                          "\nconfirm_before_save=", 21u);
    if (offset == UINT32_MAX)
        return 0;
    offset = append_number(output_buffer, offset, CONFIG_CAPACITY,
                           save_confirm_enabled ? 1u : 0u);
    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                          "\nclipboard_persistence=", 23u);
    if (offset == UINT32_MAX)
        return 0;
    offset = append_number(output_buffer, offset, CONFIG_CAPACITY,
                           clipboard_persistence_enabled ? 1u : 0u);
    locale_length = bounded_length(preferences_locale_ptr, sizeof(saved_locale_tag));
    if (locale_length && locale_length < sizeof(saved_locale_tag)) {
        static const char locale_prefix[] = "\ncompose_locale=";
        offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                              locale_prefix, sizeof(locale_prefix) - 1u);
        if (offset == UINT32_MAX)
            return 0;
        offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                              preferences_locale_ptr, locale_length);
        if (offset == UINT32_MAX)
            return 0;
    }
    font_length = bounded_length(preferences_font_path_ptr, PATH_CAPACITY);
    if (font_length && font_length < PATH_CAPACITY) {
        offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                              "\nfont_path=", 11u);
        if (offset == UINT32_MAX)
            return 0;
        offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY,
                              preferences_font_path_ptr, font_length);
        if (offset == UINT32_MAX)
            return 0;
    }
    offset = append_bytes(output_buffer, offset, CONFIG_CAPACITY, "\n", 1u);
    if (offset == UINT32_MAX)
        return 0;

    (void)syscall6(SYS_unlinkat, AT_FDCWD, (long)temporary_path, 0, 0, 0, 0);
    fd = syscall6(SYS_openat, AT_FDCWD, (long)temporary_path,
                  O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
                  FILE_MODE, 0, 0);
    if (syscall_error(fd))
        return 0;
    if (!write_all((int)fd, output_buffer, offset)) {
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
        (void)syscall6(SYS_unlinkat, AT_FDCWD, (long)temporary_path, 0, 0, 0, 0);
        return 0;
    }
    result = syscall6(SYS_fsync, fd, 0, 0, 0, 0, 0);
    (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
    if (syscall_error(result)) {
        (void)syscall6(SYS_unlinkat, AT_FDCWD, (long)temporary_path, 0, 0, 0, 0);
        return 0;
    }
    result = syscall6(SYS_renameat, AT_FDCWD, (long)temporary_path,
                      AT_FDCWD, (long)preferences_path, 0, 0);
    if (syscall_error(result)) {
        (void)syscall6(SYS_unlinkat, AT_FDCWD, (long)temporary_path, 0, 0, 0, 0);
        return 0;
    }
    directory_fd = syscall6(SYS_openat, AT_FDCWD, (long)application_directory,
                             O_RDONLY | O_DIRECTORY | O_CLOEXEC, 0, 0, 0);
    if (!syscall_error(directory_fd)) {
        (void)syscall6(SYS_fsync, directory_fd, 0, 0, 0, 0, 0);
        (void)syscall6(SYS_close, directory_fd, 0, 0, 0, 0, 0);
    }
    return 1;
}
