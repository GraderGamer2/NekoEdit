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
#define AT_FDCWD (-100)
#define O_WRONLY 1
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
    header.version = 1;
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
    return 1;
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
static int replace_range(uint32_t offset, uint32_t removed,
                         const uint8_t *inserted, uint32_t inserted_length)
{
    uint32_t i;
    uint64_t final_length = (uint64_t)doc_length - removed + inserted_length;
    if (offset > doc_length || removed > doc_length - offset ||
        final_length > 0x7fffffffu || !reserve_doc((uint32_t)final_length)) return 0;
    doc_cursor = offset + removed;
    doc_selection_anchor = offset;
    doc_selection_active = removed != 0;
    if (removed) doc_delete_selection();
    else { doc_cursor = offset; doc_selection_anchor = offset; doc_selection_active = 0; }
    for (i = 0; i < inserted_length; ++i) {
        (void)doc_insert_byte(inserted[i]);
        if (doc_storage_error) return 0;
    }
    doc_cursor = offset + inserted_length;
    doc_selection_anchor = doc_cursor;
    doc_selection_active = 0;
    doc_line_index_valid = 0;
    return 1;
}
static int apply_record(uint32_t index, int forward)
{
    record_header_t rh;
    uint64_t start;
    long map_record, map_ops;
    uint8_t *record;
    uint32_t *positions;
    uint32_t map_size, cursor, i;
    int ok = 0;
    if (index >= record_count) return 0;
    start = index ? record_ends[index - 1u] : base_offset;
    if (!read_at(journal_fd, start, &rh, sizeof(rh)) ||
        rh.magic != RECORD_MAGIC || rh.total_size < sizeof(rh) ||
        rh.total_size > MAX_RECORD_SIZE || !rh.operation_count) return 0;
    map_record = map_mem(rh.total_size);
    if (err(map_record)) return 0;
    record = (uint8_t *)(uintptr_t)map_record;
    if (!read_at(journal_fd, start, record, rh.total_size)) goto done;
    map_size = rh.operation_count * 4u;
    map_ops = map_mem(map_size ? map_size : PAGE_SIZE);
    if (err(map_ops)) goto done;
    positions = (uint32_t *)(uintptr_t)map_ops;
    cursor = sizeof(record_header_t);
    for (i = 0; i < rh.operation_count; ++i) {
        operation_header_t op;
        uint32_t j;
        uint64_t next;
        if (cursor > rh.total_size || sizeof(op) > rh.total_size - cursor) goto done_ops;
        positions[i] = cursor;
        for (j = 0; j < sizeof(op); ++j) ((uint8_t *)&op)[j] = record[cursor + j];
        next = (uint64_t)cursor + sizeof(op) + op.removed_length + op.inserted_length;
        if (next > rh.total_size) goto done_ops;
        cursor = (uint32_t)next;
    }
    if (cursor != rh.total_size) goto done_ops;
    replaying = 1;
    if (forward) {
        for (i = 0; i < rh.operation_count; ++i) {
            operation_header_t op;
            uint32_t j, at = positions[i];
            for (j = 0; j < sizeof(op); ++j) ((uint8_t *)&op)[j] = record[at + j];
            if (!replace_range(op.offset, op.removed_length,
                record + at + sizeof(op) + op.removed_length, op.inserted_length))
                goto replay_done;
        }
        doc_cursor = rh.after_cursor;
        doc_selection_anchor = rh.after_anchor;
        doc_selection_active = rh.after_active && doc_cursor != doc_selection_anchor;
    } else {
        for (i = rh.operation_count; i > 0; --i) {
            operation_header_t op;
            uint32_t j, at = positions[i - 1u];
            for (j = 0; j < sizeof(op); ++j) ((uint8_t *)&op)[j] = record[at + j];
            if (!replace_range(op.offset, op.inserted_length,
                               record + at + sizeof(op), op.removed_length))
                goto replay_done;
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
    (void)sc6(SYS_munmap, map_ops, map_size ? map_size : PAGE_SIZE, 0, 0, 0, 0);
done:
    (void)sc6(SYS_munmap, map_record, rh.total_size, 0, 0, 0, 0);
    return ok;
}
static int scan_records(uint64_t file_size)
{
    uint64_t off = base_offset;
    uint32_t found = 0;
    record_header_t rh;
    if (!grow_records(64)) return 0;
    while (off < file_size) {
        if (file_size - off < sizeof(rh) ||
            !read_at(journal_fd, off, &rh, sizeof(rh)) ||
            rh.magic != RECORD_MAGIC || rh.total_size < sizeof(rh) ||
            rh.total_size > file_size - off || !rh.operation_count) break;
        off += rh.total_size;
        if (!grow_records(found + 1u)) return 0;
        record_ends[found++] = off;
    }
    record_count = found;
    return 1;
}
static int open_identity_file(void)
{
    long r;
    uint64_t size;
    uint32_t i, base_length;
    char disk_identity[PATH_CAPACITY];
    r = sc6(SYS_openat, AT_FDCWD, (long)journal_path,
            O_RDWR | O_CREAT | O_CLOEXEC, 0600, 0, 0);
    if (err(r)) return 0;
    journal_fd = (int32_t)r;
    r = sc6(SYS_lseek, journal_fd, 0, 2, 0, 0, 0);
    if (err(r)) return 0;
    size = (uint64_t)r;
    if (size < sizeof(header)) return reset_file_to_current();
    if (!read_at(journal_fd, 0, &header, sizeof(header)) ||
        header.magic[0]!='N' || header.magic[1]!='E' || header.magic[2]!='K' ||
        header.magic[3]!='O' || header.magic[4]!='H' || header.magic[5]!='S' ||
        header.magic[6]!='T' || header.magic[7]!='1' || header.version != 1 ||
        header.path_hash != hash_identity(identity, identity_length) ||
        header.path_length != identity_length ||
        header.base_length > 0x7fffffffu ||
        header.header_size != sizeof(header) + identity_length + header.base_length ||
        header.header_size > size)
        return reset_file_to_current();
    if (!read_at(journal_fd, sizeof(header), disk_identity, identity_length))
        return reset_file_to_current();
    for (i = 0; i < identity_length; ++i)
        if (disk_identity[i] != identity[i]) return reset_file_to_current();
    /* A changed external file must not be overwritten by stale recovery data. */
    if (hash_doc() != header.saved_hash) return reset_file_to_current();
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

void history_open(const char *path)
{
    free_journal_state();
    storage_error = 0;
    if (!build_paths(path) || !open_identity_file()) {
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
    if (!ready && journal_path[0]) (void)open_identity_file();
    if (!ready) return;
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
    if (tx_active && !replaying && !append_op(offset, 0, 1, &b)) storage_error = 1;
}
void history_note_delete(uint32_t offset, uint32_t length)
{
    if (tx_active && !replaying && !append_op(offset, length, 0, (const uint8_t *)0))
        storage_error = 1;
}
void history_commit_action(void)
{
    record_header_t rh;
    uint64_t start, end;
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
    rh.magic = RECORD_MAGIC;
    rh.total_size = (uint32_t)(sizeof(rh) + tx_used);
    rh.operation_count = tx_operations;
    rh.before_cursor = before_cursor;
    rh.before_anchor = before_anchor;
    rh.before_active = before_active;
    rh.after_cursor = doc_cursor;
    rh.after_anchor = doc_selection_anchor;
    rh.after_active = doc_selection_active;
    if (!grow_records(record_count + 1u) ||
        !write_at(journal_fd, start, &rh, sizeof(rh)) ||
        !write_at(journal_fd, start + sizeof(rh), tx_buffer, tx_used) ||
        err(sc6(SYS_fsync, journal_fd, 0, 0, 0, 0, 0))) {
        storage_error = 1; return;
    }
    end = start + rh.total_size;
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
    if (journal_fd >= 0) {
        (void)sc6(SYS_close, journal_fd, 0, 0, 0, 0, 0);
        journal_fd = -1;
    }
    if (err(sc6(SYS_unlinkat, AT_FDCWD, (long)journal_path, 0, 0, 0, 0))) {
        storage_error = 1; return 0;
    }
    ready = 0; record_count = 0; tx_active = 0;
    tx_used = tx_operations = 0; storage_error = 0;
    return 1;
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
