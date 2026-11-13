#include <stdint.h>
#include <stddef.h>

/* Freestanding, append-only edit journal. One keyboard action is one record. */
#define SYS_read 0
#define SYS_write 1
#define SYS_close 3
#define SYS_lseek 8
#define SYS_mmap 9
#define SYS_munmap 11
#define SYS_mremap 25
#define SYS_openat 257
#define SYS_mkdirat 258
#define SYS_unlinkat 263
#define SYS_renameat 264
#define SYS_fsync 74
#define SYS_ftruncate 77
#define SYS_getpid 39
#define SYS_getdents64 217
#define AT_FDCWD (-100)
#define O_RDONLY 0
#define O_WRONLY 1
#define O_DIRECTORY 0x10000
#define O_RDWR 2
#define O_CREAT 64
#define O_EXCL 128
#define O_CLOEXEC 0x80000
#define SEEK_SET 0
#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_PRIVATE 2
#define MAP_ANONYMOUS 0x20
#define MREMAP_MAYMOVE 1
#define PAGE_SIZE 4096u
#define PATH_CAPACITY 4096u
#define INITIAL_TX_CAPACITY 4096u
#define RECORD_MAGIC 0x31434552u
#define MAX_RECORD_SIZE 0x7fffffffu

typedef struct {
    char magic[8];
    uint32_t version;
    uint32_t header_size;
    uint64_t path_hash;
    uint64_t base_length;
    uint64_t saved_hash;
    uint64_t record_count;
    uint64_t cursor;
    uint32_t path_length;
    uint32_t flags;
} journal_header_t;

typedef struct {
    uint32_t magic;
    uint32_t total_size;
    uint32_t operation_count;
    uint32_t before_cursor;
    uint32_t before_anchor;
    uint32_t before_active;
    uint32_t after_cursor;
    uint32_t after_anchor;
    uint32_t after_active;
} record_header_t;

typedef struct {
    uint32_t offset;
    uint32_t removed_length;
    uint32_t inserted_length;
} operation_header_t;

/* Version 2 compacts the common typing case. Version 1 remains supported so
   existing per-document journals remain readable and writable. */
typedef struct {
    uint32_t magic;
    uint32_t total_size;
    uint32_t operation_count;
    uint32_t before_cursor;
    uint32_t after_cursor;
    uint32_t flags;
} record_header_v2_t;

typedef struct __attribute__((packed)) {
    uint32_t before_anchor;
    uint32_t after_anchor;
    uint8_t before_active;
    uint8_t after_active;
} record_state_v2_t;

#define RECORD_FLAG_EXPLICIT_STATE 1u

extern char **process_envp;
extern uint32_t doc_length, doc_cursor, doc_selection_anchor, doc_selection_active;
extern uint32_t doc_capacity, doc_gap_start, doc_gap_end;
extern uint32_t doc_line_index_valid, doc_storage_error;
extern uint8_t *doc_buffer;
extern uint32_t doc_byte_at(uint32_t);
extern long doc_buffer_grow(void);
extern long doc_insert_byte(uint32_t);
extern void doc_delete_selection(void);
extern void doc_ensure_cursor_visible(void);

static int32_t journal_fd = -1;
static journal_header_t header;
static char app_dir[PATH_CAPACITY], journal_path[PATH_CAPACITY];
static char identity[PATH_CAPACITY];
static uint32_t identity_length, ready, storage_error;
static uint64_t base_offset;
static uint64_t *record_ends;
static uint32_t record_capacity, record_count;
static uint8_t *tx_buffer;
static uint32_t tx_capacity, tx_used, tx_operations, tx_active, replaying, tx_error;
static uint32_t before_cursor, before_anchor, before_active;

#define HISTORY_SEARCH_MAX 64u
#define HISTORY_SEARCH_QUERY_CAPACITY 128u
#define HISTORY_SEARCH_DIRENT_CAPACITY 8192u
static char history_search_results[HISTORY_SEARCH_MAX][PATH_CAPACITY];
static uint32_t history_search_count;
static char history_search_query_cache[HISTORY_SEARCH_QUERY_CAPACITY];
static uint32_t history_search_cache_valid;
static uint8_t history_search_dirents[HISTORY_SEARCH_DIRENT_CAPACITY];
static char history_search_display_buffer[256];

typedef struct __attribute__((packed)) {
    uint64_t inode;
    int64_t offset;
    uint16_t record_length;
    uint8_t type;
    char name[];
} linux_dirent64_t;

static long sc6(long n, long a, long b, long c, long d, long e, long f)
{
    register long rax __asm__("rax") = n;
    register long r10 __asm__("r10") = d;
    register long r8 __asm__("r8") = e;
    register long r9 __asm__("r9") = f;
    __asm__ volatile ("syscall" : "+a"(rax)
        : "D"(a), "S"(b), "d"(c), "r"(r10), "r"(r8), "r"(r9)
        : "rcx", "r11", "memory");
    return rax;
}
static int err(long v) { return v < 0 && v >= -4095; }

static uint32_t slen(const char *s, uint32_t cap)
{
    uint32_t n = 0;
    if (!s) return 0;
    while (n < cap && s[n]) ++n;
    return n;
}
static int scopy(char *d, uint32_t cap, const char *s, uint32_t n)
{
    uint32_t i;
    if (!d || !s || n >= cap) return 0;
    for (i = 0; i < n; ++i) d[i] = s[i];
    d[n] = 0;
    return 1;
}
static int append_text(char *d, uint32_t cap, uint32_t *used,
                       const char *s, uint32_t n)
{
    uint32_t i;
    if (*used > cap || n >= cap - *used) return 0;
    for (i = 0; i < n; ++i) d[(*used)++] = s[i];
    d[*used] = 0;
    return 1;
}
static const char *env(const char *key)
{
    uint32_t n = slen(key, 128);
    char **p = process_envp;
    if (!p || !n) return (const char *)0;
    while (*p) {
        uint32_t i = 0;
        while (i < n && (*p)[i] == key[i]) ++i;
        if (i == n && (*p)[i] == '=') return *p + i + 1u;
        ++p;
    }
    return (const char *)0;
}
static uint64_t hash_mem(uint64_t h, const uint8_t *p, uint32_t n)
{
    uint32_t i;
    for (i = 0; i < n; ++i) { h ^= p[i]; h *= 1099511628211ull; }
    return h;
}
static uint64_t hash_doc(void)
{
    uint64_t h = 1469598103934665603ull;
    uint32_t i;
    for (i = 0; i < doc_length; ++i) {
        uint8_t b = (uint8_t)doc_byte_at(i);
        h = hash_mem(h, &b, 1);
    }
    return h;
}
static uint64_t hash_identity(const char *p, uint32_t n)
{
    return hash_mem(1469598103934665603ull, (const uint8_t *)p, n);
}
static int read_all(int fd, void *p, uint32_t n)
{
    uint32_t done = 0;
    while (done < n) {
        long r = sc6(SYS_read, fd, (long)((uint8_t *)p + done), n - done, 0, 0, 0);
        if (r > 0) { done += (uint32_t)r; continue; }
        if (r == -4) continue;
        return 0;
    }
    return 1;
}
static int write_all(int fd, const void *p, uint32_t n)
{
    uint32_t done = 0;
    while (done < n) {
        long r = sc6(SYS_write, fd, (long)((const uint8_t *)p + done), n - done, 0, 0, 0);
        if (r > 0) { done += (uint32_t)r; continue; }
        if (r == -4) continue;
        return 0;
    }
    return 1;
}
static int read_at(int fd, uint64_t off, void *p, uint32_t n)
{
    long r = sc6(SYS_lseek, fd, (long)off, SEEK_SET, 0, 0, 0);
    return !err(r) && read_all(fd, p, n);
}
static int write_at(int fd, uint64_t off, const void *p, uint32_t n)
{
    long r = sc6(SYS_lseek, fd, (long)off, SEEK_SET, 0, 0, 0);
    return !err(r) && write_all(fd, p, n);
}
static long map_mem(uint32_t n);

static uint32_t write_varuint(uint8_t *out, uint32_t value)
{
    uint32_t used = 0;
    while (value >= 0x80u) {
        out[used++] = (uint8_t)((value & 0x7fu) | 0x80u);
        value >>= 7;
    }
    out[used++] = (uint8_t)value;
    return used;
}
static int read_varuint(const uint8_t *data, uint32_t limit,
                        uint32_t *position, uint32_t *value)
{
    uint32_t result = 0, shift = 0;
    while (*position < limit && shift <= 28u) {
        uint8_t byte = data[(*position)++];
        if (shift == 28u && (byte & 0xf0u)) return 0;
        result |= (uint32_t)(byte & 0x7fu) << shift;
        if (!(byte & 0x80u)) {
            *value = result;
            return 1;
        }
        shift += 7u;
    }
    return 0;
}
/* The temporary allocation includes the worst-case 5-byte encoding for each
   of the three uint32 fields per operation, plus all changed document bytes. */
static int encode_transaction_v2(uint8_t **output, uint32_t *output_size,
                                 uint32_t *allocation_size)
{
    uint64_t capacity64 = (uint64_t)tx_used + (uint64_t)tx_operations * 15u;
    uint32_t source = 0, destination = 0, i, map_size;
    uint8_t *encoded;
    long memory;
    if (!output || !output_size || !allocation_size ||
        capacity64 > MAX_RECORD_SIZE) return 0;
    map_size = (uint32_t)(capacity64 ? capacity64 : PAGE_SIZE);
    memory = map_mem(map_size);
    if (err(memory)) return 0;
    encoded = (uint8_t *)(uintptr_t)memory;
    for (i = 0; i < tx_operations; ++i) {
        operation_header_t op;
        uint32_t j;
        uint64_t payload_end;
        if (source > tx_used || sizeof(op) > tx_used - source) goto failed;
        for (j = 0; j < sizeof(op); ++j)
            ((uint8_t *)&op)[j] = tx_buffer[source + j];
        source += sizeof(op);
        payload_end = (uint64_t)source + op.removed_length + op.inserted_length;
        if (payload_end > tx_used) goto failed;
        destination += write_varuint(encoded + destination, op.offset);
        destination += write_varuint(encoded + destination, op.removed_length);
        destination += write_varuint(encoded + destination, op.inserted_length);
        for (j = 0; j < op.removed_length + op.inserted_length; ++j)
            encoded[destination + j] = tx_buffer[source + j];
        destination += op.removed_length + op.inserted_length;
        source = (uint32_t)payload_end;
    }
    if (source != tx_used || destination > map_size) goto failed;
    *output = encoded;
    *output_size = destination;
    *allocation_size = map_size;
    return 1;
failed:
    (void)sc6(SYS_munmap, memory, map_size, 0, 0, 0, 0);
    return 0;
}
static long map_mem(uint32_t n)
{
    return sc6(SYS_mmap, 0, n, PROT_READ | PROT_WRITE,
               MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
}
static int grow_records(uint32_t needed)
{
    uint32_t next = record_capacity ? record_capacity : 64u;
    long r;
    if (needed <= record_capacity) return 1;
    while (next < needed) {
        if (next > 0x3fffffffu) return 0;
        next *= 2u;
    }
    if (!record_ends) r = map_mem(next * 8u);
    else r = sc6(SYS_mremap, (long)record_ends, record_capacity * 8u,
                 next * 8u, MREMAP_MAYMOVE, 0, 0);
    if (err(r)) return 0;
    record_ends = (uint64_t *)(uintptr_t)r;
    record_capacity = next;
    return 1;
}
static int grow_tx(uint32_t needed)
{
    uint32_t next = tx_capacity ? tx_capacity : INITIAL_TX_CAPACITY;
    long r;
    if (needed <= tx_capacity) return 1;
    while (next < needed) {
        if (next > 0x3fffffffu) return 0;
        next *= 2u;
    }
    if (!tx_buffer) r = map_mem(next);
    else r = sc6(SYS_mremap, (long)tx_buffer, tx_capacity, next, MREMAP_MAYMOVE, 0, 0);
    if (err(r)) return 0;
    tx_buffer = (uint8_t *)(uintptr_t)r;
    tx_capacity = next;
    return 1;
}
static void free_journal_state(void)
{
    if (journal_fd >= 0) (void)sc6(SYS_close, journal_fd, 0, 0, 0, 0, 0);
    journal_fd = -1;
    if (record_ends && record_capacity)
        (void)sc6(SYS_munmap, (long)record_ends, record_capacity * 8u, 0, 0, 0, 0);
    if (tx_buffer && tx_capacity)
        (void)sc6(SYS_munmap, (long)tx_buffer, tx_capacity, 0, 0, 0, 0);
    record_ends = (uint64_t *)0; record_capacity = 0;
    tx_buffer = (uint8_t *)0; tx_capacity = 0;
    record_count = 0; ready = 0;
    tx_active = tx_used = tx_operations = tx_error = 0;
}
static int build_paths(const char *path)
{
    const char *home = env("HOME");
    uint32_t hn = slen(home, PATH_CAPACITY), n, i;
    uint64_t h;
    static const char hex[] = "0123456789abcdef";
    static const char ext[] = ".history";
    long r;
    char digit;
    if (!home || !hn || home[0] != '/' || hn + 12u >= PATH_CAPACITY)
        return 0;
    if (path && path[0]) {
        n = slen(path, PATH_CAPACITY);
        if (!n || n >= PATH_CAPACITY || !scopy(identity, PATH_CAPACITY, path, n)) return 0;
    } else {
        static const char prefix[] = "untitled-";
        char digits[10];
        uint32_t count = 0, pid = (uint32_t)sc6(SYS_getpid, 0, 0, 0, 0, 0, 0);
        for (i = 0; i < sizeof(prefix) - 1u; ++i) identity[i] = prefix[i];
        do { digits[count++] = (char)('0' + pid % 10u); pid /= 10u; }
        while (pid && count < sizeof(digits));
        for (i = 0; i < count; ++i)
            identity[sizeof(prefix) - 1u + i] = digits[count - i - 1u];
        n = (uint32_t)sizeof(prefix) - 1u + count;
        identity[n] = 0;
    }
    identity_length = n;
    if (!scopy(app_dir, PATH_CAPACITY, home, hn)) return 0;
    n = hn;
    if (!append_text(app_dir, PATH_CAPACITY, &n, "/.nekoedit", 10u)) return 0;
    r = sc6(SYS_mkdirat, AT_FDCWD, (long)app_dir, 0700, 0, 0, 0);
    if (err(r) && r != -17) return 0;
    h = hash_identity(identity, identity_length);
    if (!scopy(journal_path, PATH_CAPACITY, app_dir, n)) return 0;
    n = slen(journal_path, PATH_CAPACITY);
    if (!append_text(journal_path, PATH_CAPACITY, &n, "/", 1u)) return 0;
    for (i = 0; i < 16u; ++i) {
        digit = hex[(h >> ((15u - i) * 4u)) & 15u];
        if (!append_text(journal_path, PATH_CAPACITY, &n, &digit, 1u)) return 0;
    }
    return append_text(journal_path, PATH_CAPACITY, &n, ext, sizeof(ext) - 1u);
}
static int reserve_doc(uint32_t n)
{
    while (doc_capacity < n) {
        long r = doc_buffer_grow();
        if (err(r)) return 0;
    }
    return 1;
}
static uint64_t base_file_offset(void) { return header.header_size; }

static int reset_file_to_current(void)
{
    uint32_t i;
    long r = sc6(SYS_ftruncate, journal_fd, 0, 0, 0, 0, 0);
    if (err(r)) return 0;
    header.magic[0]='N'; header.magic[1]='E'; header.magic[2]='K'; header.magic[3]='O';
    header.magic[4]='H'; header.magic[5]='S'; header.magic[6]='T'; header.magic[7]='1';
    header.version = 2;
    header.path_length = identity_length;
    header.header_size = (uint32_t)(sizeof(header) + identity_length + doc_length);
    header.path_hash = hash_identity(identity, identity_length);
    header.base_length = doc_length;
    header.saved_hash = hash_doc();
    header.record_count = header.cursor = 0;
    header.flags = 0;
    if (!write_all(journal_fd, &header, sizeof(header)) ||
        !write_all(journal_fd, identity, identity_length)) return 0;
    for (i = 0; i < doc_length; ++i) {
        uint8_t b = (uint8_t)doc_byte_at(i);
        if (!write_all(journal_fd, &b, 1)) return 0;
    }
    if (err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) return 0;
    base_offset = base_file_offset();
    record_count = 0;
    if (!grow_records(1)) return 0;
    ready = 1;
    history_search_cache_valid = 0;
    return 1;
}
static int discard_existing_journal(void)
{
    if (journal_fd >= 0) {
        (void)sc6(SYS_close, journal_fd, 0, 0, 0, 0, 0);
        journal_fd = -1;
    }
    ready = 0;
    record_count = 0;
    if (err(sc6(SYS_unlinkat, AT_FDCWD, (long)journal_path, 0, 0, 0, 0)))
        return 0;
    return 2; /* No useful history remains; this is not a storage failure. */
}
static int discard_or_reset_existing_journal(int create_if_missing)
{
    if (create_if_missing) return reset_file_to_current();
    return discard_existing_journal();
}
static int append_op(uint32_t offset, uint32_t removed, uint32_t inserted,
                     const uint8_t *inserted_bytes)
{
    operation_header_t op;
    uint64_t needed = (uint64_t)tx_used + sizeof(op) + removed + inserted;
    uint32_t i;
    if (!tx_active || replaying) return 1;
    if (needed > MAX_RECORD_SIZE || !grow_tx((uint32_t)needed)) {
        tx_error = storage_error = 1; return 0;
    }
    op.offset = offset; op.removed_length = removed; op.inserted_length = inserted;
    for (i = 0; i < sizeof(op); ++i) tx_buffer[tx_used + i] = ((uint8_t *)&op)[i];
    tx_used += sizeof(op);
    for (i = 0; i < removed; ++i) tx_buffer[tx_used + i] = (uint8_t)doc_byte_at(offset + i);
    tx_used += removed;
    if (inserted && inserted_bytes) {
        for (i = 0; i < inserted; ++i) tx_buffer[tx_used + i] = inserted_bytes[i];
        tx_used += inserted;
    }
    ++tx_operations;
    return 1;
}
extern long doc_insert_bytes(const uint8_t *, uint32_t);

static int replace_range(uint32_t offset, uint32_t removed,
                         const uint8_t *inserted, uint32_t inserted_length)
{
    uint64_t final_length = (uint64_t)doc_length - removed + inserted_length;
    if (offset > doc_length || removed > doc_length - offset ||
        final_length > 0x7fffffffu || !reserve_doc((uint32_t)final_length)) return 0;
    doc_cursor = offset + removed;
    doc_selection_anchor = offset;
    doc_selection_active = removed != 0;
    if (removed) doc_delete_selection();
    else { doc_cursor = offset; doc_selection_anchor = offset; doc_selection_active = 0; }
    if (inserted_length &&
        (doc_insert_bytes(inserted, inserted_length) < 0 || doc_storage_error))
        return 0;
    doc_cursor = offset + inserted_length;
    doc_selection_anchor = doc_cursor;
    doc_selection_active = 0;
    doc_line_index_valid = 0;
    return 1;
}
static int apply_record(uint32_t index, int forward)
{
    record_header_t rh;
    record_header_v2_t rh2;
    record_state_v2_t state2;
    uint64_t start;
    long map_record = 0, map_ops = 0;
    uint8_t *record;
    uint32_t *positions;
    uint32_t map_size, map_ops_size, cursor, i, record_prefix;
    uint32_t version;
    int ok = 0;
    rh.total_size = 0;
    if (index >= record_count) return 0;
    start = index ? record_ends[index - 1u] : base_offset;
    version = header.version;
    if (version == 1u) {
        if (!read_at(journal_fd, start, &rh, sizeof(rh)) ||
            rh.magic != RECORD_MAGIC || rh.total_size < sizeof(rh) ||
            rh.total_size > MAX_RECORD_SIZE || !rh.operation_count) return 0;
        record_prefix = sizeof(record_header_t);
    } else if (version == 2u) {
        if (!read_at(journal_fd, start, &rh2, sizeof(rh2)) ||
            rh2.magic != RECORD_MAGIC ||
            rh2.total_size < sizeof(record_header_v2_t) ||
            rh2.total_size > MAX_RECORD_SIZE || !rh2.operation_count ||
            (rh2.flags & ~RECORD_FLAG_EXPLICIT_STATE)) return 0;
        rh.magic = rh2.magic;
        rh.total_size = rh2.total_size;
        rh.operation_count = rh2.operation_count;
        rh.before_cursor = rh2.before_cursor;
        rh.after_cursor = rh2.after_cursor;
        if (rh2.flags & RECORD_FLAG_EXPLICIT_STATE) {
            if (rh.total_size < sizeof(record_header_v2_t) + sizeof(state2) ||
                !read_at(journal_fd, start + sizeof(record_header_v2_t),
                         &state2, sizeof(state2))) return 0;
            rh.before_anchor = state2.before_anchor;
            rh.after_anchor = state2.after_anchor;
            rh.before_active = state2.before_active;
            rh.after_active = state2.after_active;
            record_prefix = sizeof(record_header_v2_t) + sizeof(state2);
        } else {
            rh.before_anchor = rh.before_cursor;
            rh.after_anchor = rh.after_cursor;
            rh.before_active = 0;
            rh.after_active = 0;
            record_prefix = sizeof(record_header_v2_t);
        }
    } else {
        return 0;
    }
    if (rh.operation_count > 0x1fffffffu) return 0;
    map_record = map_mem(rh.total_size);
    if (err(map_record)) return 0;
    record = (uint8_t *)(uintptr_t)map_record;
    if (!read_at(journal_fd, start, record, rh.total_size)) goto done;
    map_size = rh.operation_count * 4u;
    map_ops_size = map_size ? map_size : PAGE_SIZE;
    map_ops = map_mem(map_ops_size);
    if (err(map_ops)) { map_ops = 0; goto done; }
    positions = (uint32_t *)(uintptr_t)map_ops;
    cursor = record_prefix;
    for (i = 0; i < rh.operation_count; ++i) {
        if (version == 1u) {
            operation_header_t op;
            uint32_t j;
            uint64_t next;
            if (cursor > rh.total_size || sizeof(op) > rh.total_size - cursor)
                goto done_ops;
            positions[i] = cursor;
            for (j = 0; j < sizeof(op); ++j)
                ((uint8_t *)&op)[j] = record[cursor + j];
            next = (uint64_t)cursor + sizeof(op) +
                   op.removed_length + op.inserted_length;
            if (next > rh.total_size) goto done_ops;
            cursor = (uint32_t)next;
        } else {
            uint32_t offset, removed, inserted;
            positions[i] = cursor;
            if (!read_varuint(record, rh.total_size, &cursor, &offset) ||
                !read_varuint(record, rh.total_size, &cursor, &removed) ||
                !read_varuint(record, rh.total_size, &cursor, &inserted) ||
                (uint64_t)cursor + removed + inserted > rh.total_size)
                goto done_ops;
            cursor += removed + inserted;
        }
    }
    if (cursor != rh.total_size) goto done_ops;
    replaying = 1;
    if (forward) {
        for (i = 0; i < rh.operation_count; ++i) {
            uint32_t at = positions[i];
            if (version == 1u) {
                operation_header_t op;
                uint32_t j;
                for (j = 0; j < sizeof(op); ++j)
                    ((uint8_t *)&op)[j] = record[at + j];
                if (!replace_range(op.offset, op.removed_length,
                    record + at + sizeof(op) + op.removed_length,
                    op.inserted_length))
                    goto replay_done;
            } else {
                uint32_t offset, removed, inserted;
                if (!read_varuint(record, rh.total_size, &at, &offset) ||
                    !read_varuint(record, rh.total_size, &at, &removed) ||
                    !read_varuint(record, rh.total_size, &at, &inserted) ||
                    (uint64_t)at + removed + inserted > rh.total_size)
                    goto replay_done;
                if (!replace_range(offset, removed,
                    record + at + removed, inserted))
                    goto replay_done;
            }
        }
        doc_cursor = rh.after_cursor;
        doc_selection_anchor = rh.after_anchor;
        doc_selection_active = rh.after_active && doc_cursor != doc_selection_anchor;
    } else {
        for (i = rh.operation_count; i > 0; --i) {
            uint32_t at = positions[i - 1u];
            if (version == 1u) {
                operation_header_t op;
                uint32_t j;
                for (j = 0; j < sizeof(op); ++j)
                    ((uint8_t *)&op)[j] = record[at + j];
                if (!replace_range(op.offset, op.inserted_length,
                                   record + at + sizeof(op), op.removed_length))
                    goto replay_done;
            } else {
                uint32_t offset, removed, inserted;
                if (!read_varuint(record, rh.total_size, &at, &offset) ||
                    !read_varuint(record, rh.total_size, &at, &removed) ||
                    !read_varuint(record, rh.total_size, &at, &inserted) ||
                    (uint64_t)at + removed + inserted > rh.total_size)
                    goto replay_done;
                if (!replace_range(offset, inserted, record + at, removed))
                    goto replay_done;
            }
        }
        doc_cursor = rh.before_cursor;
        doc_selection_anchor = rh.before_anchor;
        doc_selection_active = rh.before_active && doc_cursor != doc_selection_anchor;
    }
    doc_line_index_valid = 0;
    doc_ensure_cursor_visible();
    ok = 1;
replay_done:
    replaying = 0;
done_ops:
    if (map_ops)
        (void)sc6(SYS_munmap, map_ops, map_ops_size, 0, 0, 0, 0);
done:
    if (map_record)
        (void)sc6(SYS_munmap, map_record, rh.total_size, 0, 0, 0, 0);
    return ok;
}
static int scan_records(uint64_t file_size)
{
    uint64_t off = base_offset;
    uint32_t found = 0;
    if (!grow_records(64)) return 0;
    while (off < file_size) {
        uint32_t total_size = 0, operation_count = 0;
        uint32_t minimum_size, magic = 0;
        if (header.version == 1u) {
            record_header_t rh;
            if (file_size - off < sizeof(rh) ||
                !read_at(journal_fd, off, &rh, sizeof(rh)))
                break;
            magic = rh.magic;
            total_size = rh.total_size;
            operation_count = rh.operation_count;
            minimum_size = sizeof(rh);
        } else if (header.version == 2u) {
            record_header_v2_t rh;
            if (file_size - off < sizeof(rh) ||
                !read_at(journal_fd, off, &rh, sizeof(rh)) ||
                (rh.flags & ~RECORD_FLAG_EXPLICIT_STATE))
                break;
            magic = rh.magic;
            total_size = rh.total_size;
            operation_count = rh.operation_count;
            minimum_size = sizeof(rh) +
                ((rh.flags & RECORD_FLAG_EXPLICIT_STATE) ?
                 sizeof(record_state_v2_t) : 0u);
        } else {
            return 0;
        }
        if (magic != RECORD_MAGIC || total_size < minimum_size ||
            total_size > file_size - off || !operation_count)
            break;
        off += total_size;
        if (!grow_records(found + 1u)) return 0;
        record_ends[found++] = off;
    }
    record_count = found;
    return 1;
}
static int open_identity_file(int create_if_missing)
{
    long r;
    uint64_t size;
    uint32_t i, base_length;
    char disk_identity[PATH_CAPACITY];
    long flags = O_RDWR | O_CLOEXEC;
    if (create_if_missing) flags |= O_CREAT;
    r = sc6(SYS_openat, AT_FDCWD, (long)journal_path,
            flags, 0600, 0, 0);
    if (err(r)) return (!create_if_missing && r == -2) ? 2 : 0;
    journal_fd = (int32_t)r;
    r = sc6(SYS_lseek, journal_fd, 0, 2, 0, 0, 0);
    if (err(r)) return 0;
    size = (uint64_t)r;
    if (!size && !create_if_missing) {
        /* Remove a zero-byte remnant from an interrupted older startup. */
        (void)sc6(SYS_close, journal_fd, 0, 0, 0, 0, 0);
        journal_fd = -1;
        (void)sc6(SYS_unlinkat, AT_FDCWD, (long)journal_path, 0, 0, 0, 0);
        return 2;
    }
    if (size < sizeof(header))
        return discard_or_reset_existing_journal(create_if_missing);
    if (!read_at(journal_fd, 0, &header, sizeof(header)) ||
        header.magic[0]!='N' || header.magic[1]!='E' || header.magic[2]!='K' ||
        header.magic[3]!='O' || header.magic[4]!='H' || header.magic[5]!='S' ||
        header.magic[6]!='T' || header.magic[7]!='1' ||
        (header.version != 1u && header.version != 2u) ||
        header.path_hash != hash_identity(identity, identity_length) ||
        header.path_length != identity_length ||
        header.base_length > 0x7fffffffu ||
        header.header_size != sizeof(header) + identity_length + header.base_length ||
        header.header_size > size)
        return discard_or_reset_existing_journal(create_if_missing);
    if (!read_at(journal_fd, sizeof(header), disk_identity, identity_length))
        return discard_or_reset_existing_journal(create_if_missing);
    for (i = 0; i < identity_length; ++i)
        if (disk_identity[i] != identity[i])
            return discard_or_reset_existing_journal(create_if_missing);
    /* Older builds eagerly wrote a baseline even when the document was never
       edited. Such a journal has no useful Undo/Redo state, so remove it
       regardless of whether the document has since changed externally. */
    if (!header.record_count && !header.cursor) {
        if (create_if_missing) return reset_file_to_current();
        return discard_existing_journal();
    }
    /* A changed external file invalidates that journal. Remove it on open;
       only recreate a baseline when the caller is recording a real edit. */
    if (hash_doc() != header.saved_hash)
        return discard_or_reset_existing_journal(create_if_missing);
    base_offset = header.header_size;
    if (!scan_records(size)) return 0;
    if (header.record_count > record_count) header.record_count = record_count;
    else record_count = (uint32_t)header.record_count;
    if (header.cursor > header.record_count) header.cursor = header.record_count;
    base_length = (uint32_t)header.base_length;
    {
        uint32_t map_size = base_length ? base_length : 1u;
        long mem = map_mem(map_size);
        if (err(mem)) return 0;
        if (base_length && !read_at(journal_fd, sizeof(header) + identity_length,
                                    (void *)(uintptr_t)mem, base_length)) {
            (void)sc6(SYS_munmap, mem, map_size, 0, 0, 0, 0);
            return 0;
        }
        if (!reserve_doc(base_length)) {
            (void)sc6(SYS_munmap, mem, map_size, 0, 0, 0, 0);
            return 0;
        }
        for (i = 0; i < base_length; ++i)
            doc_buffer[i] = ((uint8_t *)(uintptr_t)mem)[i];
        doc_length = base_length;
        doc_gap_start = base_length;
        doc_gap_end = doc_capacity;
        doc_cursor = base_length;
        doc_selection_anchor = base_length;
        doc_selection_active = 0;
        doc_line_index_valid = 0;
        (void)sc6(SYS_munmap, mem, map_size, 0, 0, 0, 0);
    }
    ready = 1;
    for (i = 0; i < (uint32_t)header.cursor; ++i)
        if (!apply_record(i, 1)) { storage_error = 1; return 0; }
    doc_line_index_valid = 0;
    (void)write_at(journal_fd, 0, &header, sizeof(header));
    (void)sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0);
    return 1;
}

static int ensure_journal_for_edit(void)
{
    if (ready && journal_fd >= 0) return 1;
    if (!journal_path[0] || !open_identity_file(1)) return 0;
    return ready && journal_fd >= 0;
}

void history_open(const char *path)
{
    int opened;
    free_journal_state();
    storage_error = 0;
    history_search_cache_valid = 0;
    if (!build_paths(path)) {
        storage_error = 1;
        ready = 0;
        return;
    }
    opened = open_identity_file(0);
    /* Missing history is normal. Create the baseline only before the first
       actual byte insertion/deletion, never merely because a document opens. */
    if (!opened) {
        storage_error = 1;
        ready = 0;
    }
}
void history_reset(void)
{
    free_journal_state();
    storage_error = 0;
    replaying = 0;
}
void history_begin_action(void)
{
    if (replaying) return;
    tx_active = 1;
    tx_error = 0;
    tx_used = 0;
    tx_operations = 0;
    before_cursor = doc_cursor;
    before_anchor = doc_selection_anchor;
    before_active = doc_selection_active;
}
void history_note_insert(uint32_t offset, uint32_t byte)
{
    uint8_t b = (uint8_t)byte;
    if (!tx_active || replaying) return;
    if (!ensure_journal_for_edit() || !append_op(offset, 0, 1, &b))
        storage_error = tx_error = 1;
}
void history_note_insert_bytes(uint32_t offset, const uint8_t *bytes,
                                uint32_t length)
{
    if (!length || !tx_active || replaying) return;
    if (!ensure_journal_for_edit() ||
        !append_op(offset, 0, length, bytes))
        storage_error = tx_error = 1;
}
void history_note_delete(uint32_t offset, uint32_t length)
{
    if (!tx_active || replaying) return;
    if (!ensure_journal_for_edit() ||
        !append_op(offset, length, 0, (const uint8_t *)0))
        storage_error = tx_error = 1;
}
void history_commit_action(void)
{
    record_header_t rh;
    record_header_v2_t rh2;
    record_state_v2_t state2;
    uint64_t start, end;
    uint32_t record_size, compact_size = 0, compact_allocation = 0;
    uint8_t *compact = (uint8_t *)0;
    long compact_memory = 0;
    if (!tx_active) return;
    tx_active = 0;
    if (!tx_operations || tx_error || doc_storage_error || !ready) {
        tx_used = tx_operations = 0;
        if (tx_error || doc_storage_error) storage_error = 1;
        return;
    }
    if (header.cursor < header.record_count) {
        start = header.cursor ? record_ends[(uint32_t)header.cursor - 1u] : base_offset;
        if (err(sc6(SYS_ftruncate, journal_fd, (long)start, 0, 0, 0, 0))) {
            storage_error = 1; return;
        }
        record_count = (uint32_t)header.cursor;
        header.record_count = header.cursor;
    } else start = record_count ? record_ends[record_count - 1u] : base_offset;

    if (header.version == 1u) {
        rh.magic = RECORD_MAGIC;
        rh.total_size = (uint32_t)(sizeof(rh) + tx_used);
        rh.operation_count = tx_operations;
        rh.before_cursor = before_cursor;
        rh.before_anchor = before_anchor;
        rh.before_active = before_active;
        rh.after_cursor = doc_cursor;
        rh.after_anchor = doc_selection_anchor;
        rh.after_active = doc_selection_active;
        record_size = rh.total_size;
        if (!grow_records(record_count + 1u) ||
            !write_at(journal_fd, start, &rh, sizeof(rh)) ||
            !write_at(journal_fd, start + sizeof(rh), tx_buffer, tx_used) ||
            err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) {
            storage_error = 1; return;
        }
    } else if (header.version == 2u) {
        /* A collapsed caret has no meaningful selection anchor. Preserve
           the extra anchors only when a selection is actually active. */
        uint32_t explicit_state =
            (before_active || doc_selection_active) ? 1u : 0u;
        if (!encode_transaction_v2(&compact, &compact_size, &compact_allocation)) {
            storage_error = 1; return;
        }
        compact_memory = (long)(uintptr_t)compact;
        rh2.magic = RECORD_MAGIC;
        rh2.operation_count = tx_operations;
        rh2.before_cursor = before_cursor;
        rh2.after_cursor = doc_cursor;
        rh2.flags = explicit_state ? RECORD_FLAG_EXPLICIT_STATE : 0u;
        rh2.total_size = (uint32_t)(sizeof(rh2) +
            (explicit_state ? sizeof(state2) : 0u) + compact_size);
        record_size = rh2.total_size;
        if (explicit_state) {
            state2.before_anchor = before_anchor;
            state2.after_anchor = doc_selection_anchor;
            state2.before_active = (uint8_t)(before_active != 0);
            state2.after_active = (uint8_t)(doc_selection_active != 0);
        }
        if (record_size > MAX_RECORD_SIZE ||
            !grow_records(record_count + 1u) ||
            !write_at(journal_fd, start, &rh2, sizeof(rh2)) ||
            (explicit_state &&
             !write_at(journal_fd, start + sizeof(rh2), &state2, sizeof(state2))) ||
            !write_at(journal_fd, start + sizeof(rh2) +
                (explicit_state ? sizeof(state2) : 0u), compact, compact_size) ||
            err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) {
            if (compact_memory)
                (void)sc6(SYS_munmap, compact_memory, compact_allocation, 0, 0, 0, 0);
            storage_error = 1; return;
        }
        if (compact_memory)
            (void)sc6(SYS_munmap, compact_memory, compact_allocation, 0, 0, 0, 0);
    } else {
        storage_error = 1;
        return;
    }
    end = start + record_size;
    record_ends[record_count++] = end;
    header.record_count = record_count;
    header.cursor = record_count;
    if (!write_at(journal_fd, 0, &header, sizeof(header)) ||
        err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0)))
        storage_error = 1;
    tx_used = tx_operations = 0;
}
static int move_history(int forward)
{
    uint64_t index;
    if (!ready || (!forward && !header.cursor) ||
        (forward && header.cursor >= header.record_count)) return 0;
    index = forward ? header.cursor : header.cursor - 1u;
    if (!apply_record((uint32_t)index, forward)) {
        storage_error = 1; return 0;
    }
    if (forward) ++header.cursor;
    else --header.cursor;
    if (!write_at(journal_fd, 0, &header, sizeof(header)) ||
        err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) {
        storage_error = 1; return 0;
    }
    return 1;
}
int history_undo(void)
{
    tx_active = 0; tx_used = tx_operations = 0;
    return move_history(0);
}
int history_redo(void)
{
    tx_active = 0; tx_used = tx_operations = 0;
    return move_history(1);
}
void history_mark_saved(void)
{
    if (!ready || journal_fd < 0) return;
    header.saved_hash = hash_doc();
    if (!write_at(journal_fd, 0, &header, sizeof(header)) ||
        err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) storage_error = 1;
}
uint32_t history_undo_count(void) { return ready ? (uint32_t)header.cursor : 0; }
uint32_t history_redo_count(void)
{
    return ready && header.record_count >= header.cursor ?
           (uint32_t)(header.record_count - header.cursor) : 0;
}
uint32_t history_has_error(void) { return storage_error; }
int history_delete_current(void)
{
    if (!journal_path[0]) return 0;
    if (journal_fd < 0 && !ready) {
        storage_error = 0;
        history_search_cache_valid = 0;
        return 1;
    }
    if (journal_fd >= 0) {
        (void)sc6(SYS_close, journal_fd, 0, 0, 0, 0, 0);
        journal_fd = -1;
    }
    if (err(sc6(SYS_unlinkat, AT_FDCWD, (long)journal_path, 0, 0, 0, 0))) {
        storage_error = 1; return 0;
    }
    ready = 0; record_count = 0; tx_active = 0;
    tx_used = tx_operations = 0; storage_error = 0;
    history_search_cache_valid = 0;
    return 1;
}

static uint8_t history_search_lower(uint8_t value)
{
    return value >= 'A' && value <= 'Z' ? (uint8_t)(value + ('a' - 'A')) : value;
}
static int history_search_contains(const char *path, uint32_t path_length,
                                   const char *query, uint32_t query_length)
{
    uint32_t i, j;
    if (!query_length) return 1;
    if (query_length > path_length) return 0;
    for (i = 0; i <= path_length - query_length; ++i) {
        for (j = 0; j < query_length; ++j)
            if (history_search_lower((uint8_t)path[i + j]) !=
                history_search_lower((uint8_t)query[j])) break;
        if (j == query_length) return 1;
    }
    return 0;
}
static int history_search_ends_with(const char *name, uint32_t length,
                                    const char *suffix, uint32_t suffix_length)
{
    uint32_t i;
    if (length < suffix_length) return 0;
    for (i = 0; i < suffix_length; ++i)
        if (name[length - suffix_length + i] != suffix[i]) return 0;
    return 1;
}
static int history_search_path_before(const char *left, const char *right)
{
    uint32_t i = 0;
    while (left[i] && right[i] && left[i] == right[i]) ++i;
    return (uint8_t)left[i] < (uint8_t)right[i];
}
uint32_t history_search_refresh(const char *query)
{
    static const char suffix[] = ".history";
    static const char untitled[] = "untitled-";
    uint32_t query_length = slen(query, HISTORY_SEARCH_QUERY_CAPACITY);
    long directory;
    if (query_length >= HISTORY_SEARCH_QUERY_CAPACITY)
        query_length = HISTORY_SEARCH_QUERY_CAPACITY - 1u;
    if (history_search_cache_valid) {
        uint32_t i;
        for (i = 0; i < query_length &&
             history_search_query_cache[i] == query[i]; ++i) {}
        if (i == query_length && !history_search_query_cache[i])
            return history_search_count;
    }
    history_search_count = 0;
    for (uint32_t i = 0; i < query_length; ++i)
        history_search_query_cache[i] = query[i];
    history_search_query_cache[query_length] = 0;
    history_search_cache_valid = 1;
    if (!app_dir[0]) return 0;

    directory = sc6(SYS_openat, AT_FDCWD, (long)app_dir,
                    O_RDONLY | O_DIRECTORY | O_CLOEXEC, 0, 0, 0);
    if (err(directory)) return 0;
    for (;;) {
        long bytes = sc6(SYS_getdents64, directory,
                         (long)history_search_dirents,
                         HISTORY_SEARCH_DIRENT_CAPACITY, 0, 0, 0);
        uint32_t offset = 0;
        if (bytes == 0) break;
        if (err(bytes)) break;
        while (offset + 19u < (uint32_t)bytes) {
            linux_dirent64_t *entry =
                (linux_dirent64_t *)(void *)(history_search_dirents + offset);
            uint32_t record_length = entry->record_length;
            uint32_t name_length = 0;
            long candidate_fd;
            journal_header_t candidate_header;
            char candidate_path[PATH_CAPACITY];
            uint32_t j;
            if (record_length < 20u || record_length > (uint32_t)bytes - offset)
                break;
            while (name_length < record_length - 19u &&
                   entry->name[name_length]) ++name_length;
            if (name_length && history_search_ends_with(
                    entry->name, name_length, suffix, sizeof(suffix) - 1u)) {
                candidate_fd = sc6(SYS_openat, directory, (long)entry->name,
                                   O_RDONLY | O_CLOEXEC, 0, 0, 0);
                if (!err(candidate_fd)) {
                    int valid = read_all((int)candidate_fd, &candidate_header,
                                         sizeof(candidate_header));
                    long file_size = sc6(SYS_lseek, candidate_fd, 0, 2, 0, 0, 0);
                    if (valid && !err(file_size) &&
                        candidate_header.magic[0] == 'N' &&
                        candidate_header.magic[1] == 'E' &&
                        candidate_header.magic[2] == 'K' &&
                        candidate_header.magic[3] == 'O' &&
                        candidate_header.magic[4] == 'H' &&
                        candidate_header.magic[5] == 'S' &&
                        candidate_header.magic[6] == 'T' &&
                        candidate_header.magic[7] == '1' &&
                        (candidate_header.version == 1u ||
                         candidate_header.version == 2u) &&
                        candidate_header.path_length > 0u &&
                        candidate_header.path_length < PATH_CAPACITY &&
                        candidate_header.base_length <= 0x7fffffffu &&
                        candidate_header.header_size ==
                            sizeof(candidate_header) + candidate_header.path_length +
                            candidate_header.base_length &&
                        candidate_header.header_size <= (uint64_t)file_size &&
                        candidate_header.cursor <= candidate_header.record_count &&
                        read_at((int)candidate_fd,
                            sizeof(candidate_header), candidate_path,
                            candidate_header.path_length)) {
                        uint32_t path_length = candidate_header.path_length;
                        candidate_path[path_length] = 0;
                        valid = hash_identity(candidate_path, path_length) ==
                                candidate_header.path_hash;
                        for (j = 0; valid && j < sizeof(untitled) - 1u; ++j)
                            if (candidate_path[j] != untitled[j]) break;
                        /* Remove no-op journals left by older eager-create
                           builds; they contain no recoverable user actions. */
                        if (valid && !candidate_header.record_count &&
                            !candidate_header.cursor) {
                            (void)sc6(SYS_close, candidate_fd, 0, 0, 0, 0, 0);
                            candidate_fd = -1;
                            (void)sc6(SYS_unlinkat, directory,
                                      (long)entry->name, 0, 0, 0, 0);
                        } else if (valid && candidate_header.record_count > 0u &&
                            j != sizeof(untitled) - 1u &&
                            history_search_contains(candidate_path, path_length,
                                history_search_query_cache, query_length) &&
                            history_search_count < HISTORY_SEARCH_MAX) {
                            scopy(history_search_results[history_search_count],
                                  PATH_CAPACITY, candidate_path, path_length);
                            ++history_search_count;
                        }
                    }
                    if (candidate_fd >= 0)
                        (void)sc6(SYS_close, candidate_fd, 0, 0, 0, 0, 0);
                }
            }
            offset += record_length;
        }
    }
    (void)sc6(SYS_close, directory, 0, 0, 0, 0, 0);

    /* Deterministic path order makes keyboard selection stable across refreshes. */
    for (uint32_t i = 1; i < history_search_count; ++i) {
        char temporary[PATH_CAPACITY];
        uint32_t n = slen(history_search_results[i], PATH_CAPACITY);
        uint32_t j = i;
        scopy(temporary, PATH_CAPACITY, history_search_results[i], n);
        while (j && history_search_path_before(
                    temporary, history_search_results[j - 1u])) {
            uint32_t previous_length = slen(history_search_results[j - 1u],
                                            PATH_CAPACITY);
            scopy(history_search_results[j], PATH_CAPACITY,
                  history_search_results[j - 1u], previous_length);
            --j;
        }
        scopy(history_search_results[j], PATH_CAPACITY, temporary, n);
    }
    return history_search_count;
}
uint32_t history_search_result_count(void)
{
    return history_search_count;
}
const char *history_search_result(uint32_t index)
{
    return index < history_search_count ? history_search_results[index] :
           (const char *)0;
}

int history_delete_selected(uint32_t index)
{
    const char *path = history_search_result(index);
    char target[PATH_CAPACITY];
    static const char hex[] = "0123456789abcdef";
    static const char suffix[] = ".history";
    uint32_t length, n, i;
    uint64_t hash;
    long result;
    if (!path) return 0;
    length = slen(path, PATH_CAPACITY);
    if (!length || length >= PATH_CAPACITY) return 0;
    if (length == identity_length) {
        for (i = 0; i < length && path[i] == identity[i]; ++i) {}
        if (i == length) return history_delete_current();
    }
    if (!app_dir[0] || !scopy(target, PATH_CAPACITY, app_dir,
                               slen(app_dir, PATH_CAPACITY)))
        return 0;
    n = slen(target, PATH_CAPACITY);
    if (!append_text(target, PATH_CAPACITY, &n, "/", 1u)) return 0;
    hash = hash_identity(path, length);
    for (i = 0; i < 16u; ++i) {
        char digit = hex[(hash >> ((15u - i) * 4u)) & 15u];
        if (!append_text(target, PATH_CAPACITY, &n, &digit, 1u)) return 0;
    }
    if (!append_text(target, PATH_CAPACITY, &n, suffix, sizeof(suffix) - 1u))
        return 0;
    result = sc6(SYS_unlinkat, AT_FDCWD, (long)target, 0, 0, 0, 0);
    if (err(result) && result != -2) return 0;
    history_search_cache_valid = 0;
    return 1;
}
const char *history_search_display(uint32_t index)
{
    const char *path;
    uint32_t length, head, tail, i, out = 0;
    if (index >= history_search_count) return (const char *)0;
    path = history_search_results[index];
    length = slen(path, PATH_CAPACITY);
    if (length <= 34u) {
        for (i = 0; i < length; ++i)
            history_search_display_buffer[out++] = path[i];
    } else {
        /* Keep rows inside the narrowest supported window at a 16px UI font. */
        head = 14u;
        tail = 17u;
        for (i = 0; i < head; ++i)
            history_search_display_buffer[out++] = path[i];
        history_search_display_buffer[out++] = '.';
        history_search_display_buffer[out++] = '.';
        history_search_display_buffer[out++] = '.';
        for (i = length - tail; i < length; ++i)
            history_search_display_buffer[out++] = path[i];
    }
    history_search_display_buffer[out] = 0;
    return history_search_display_buffer;
}

int history_export_to(const char *destination)
{
    char temporary[PATH_CAPACITY], digits[10];
    uint32_t n = slen(destination, PATH_CAPACITY), used, pid, dc = 0;
    uint8_t buffer[16384];
    int32_t out;
    uint64_t offset = 0, size;
    long r;
    if (!ready || journal_fd < 0 || !destination || !n || n >= PATH_CAPACITY - 32u)
        return 0;
    if (!scopy(temporary, PATH_CAPACITY, destination, n)) return 0;
    used = n;
    if (!append_text(temporary, PATH_CAPACITY, &used, ".tmp-", 5u)) return 0;
    pid = (uint32_t)sc6(SYS_getpid, 0, 0, 0, 0, 0, 0);
    do { digits[dc++] = (char)('0' + pid % 10u); pid /= 10u; }
    while (pid && dc < sizeof(digits));
    while (dc) {
        char d = digits[--dc];
        if (!append_text(temporary, PATH_CAPACITY, &used, &d, 1u)) return 0;
    }
    out = (int32_t)sc6(SYS_openat, AT_FDCWD, (long)temporary,
                       O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC, 0600, 0, 0);
    if (err(out)) return 0;
    r = sc6(SYS_lseek, journal_fd, 0, 2, 0, 0, 0);
    if (err(r)) goto export_fail;
    size = (uint64_t)r;
    while (offset < size) {
        uint32_t chunk = size - offset > sizeof(buffer) ?
                         sizeof(buffer) : (uint32_t)(size - offset);
        if (!read_at(journal_fd, offset, buffer, chunk) || !write_all(out, buffer, chunk))
            goto export_fail;
        offset += chunk;
    }
    if (err(sc6(SYS_fsync, out, 0, 0, 0, 0, 0))) goto export_fail;
    (void)sc6(SYS_close, out, 0, 0, 0, 0, 0);
    if (err(sc6(SYS_renameat, AT_FDCWD, (long)temporary,
                AT_FDCWD, (long)destination, 0, 0))) {
        (void)sc6(SYS_unlinkat, AT_FDCWD, (long)temporary, 0, 0, 0, 0);
        return 0;
    }
    return 1;
export_fail:
    (void)sc6(SYS_close, out, 0, 0, 0, 0, 0);
    (void)sc6(SYS_unlinkat, AT_FDCWD, (long)temporary, 0, 0, 0, 0);
    return 0;
}
