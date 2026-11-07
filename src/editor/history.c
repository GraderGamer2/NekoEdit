#include <stdint.h>
#include <stddef.h>

/*
 * Bounded snapshot undo/redo for the document gap buffer.
 * The pre-key hook captures the state before an input action; the post-edit
 * hook commits one new state after the action's byte operations have ended.
 */
#define SYS_mmap 9
#define SYS_munmap 11
#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_PRIVATE 2
#define MAP_ANONYMOUS 0x20
#define SNAPSHOT_LIMIT (4u * 1024u * 1024u)
#define HISTORY_BUDGET (32u * 1024u * 1024u)
#define HISTORY_DEPTH 16u
#define PAGE_SIZE 4096u

typedef struct {
    uint8_t *bytes;
    uint32_t length;
    uint32_t mapping_size;
    uint32_t cursor;
    uint32_t selection_anchor;
    uint32_t selection_active;
    uint32_t revision;
} snapshot_t;

extern uint32_t doc_revision;
extern uint32_t doc_length;
extern uint32_t doc_cursor;
extern uint32_t doc_selection_anchor;
extern uint32_t doc_selection_active;
extern uint32_t doc_capacity;
extern uint32_t doc_gap_start;
extern uint32_t doc_gap_end;
extern uint32_t doc_line_index_valid;
extern uint32_t doc_storage_error;
extern uint8_t *doc_buffer;
extern uint32_t doc_byte_at(uint32_t offset);
extern long doc_buffer_grow(void);
extern void doc_ensure_cursor_visible(void);

static snapshot_t baseline;
static snapshot_t undo_stack[HISTORY_DEPTH];
static snapshot_t redo_stack[HISTORY_DEPTH];
static uint32_t undo_count;
static uint32_t redo_count;
static uint32_t baseline_valid;
static uint32_t history_bytes;

static long raw_syscall6(long number, long a1, long a2, long a3,
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

static int syscall_failed(long result)
{
    return result < 0 && result >= -4095;
}

static uint32_t mapping_size_for(uint32_t length)
{
    uint32_t wanted = length ? length : 1u;
    if (wanted > SNAPSHOT_LIMIT || wanted > UINT32_MAX - (PAGE_SIZE - 1u))
        return 0;
    return (wanted + PAGE_SIZE - 1u) & ~(PAGE_SIZE - 1u);
}

static void snapshot_drop(snapshot_t *snapshot)
{
    if (snapshot->bytes) {
        (void)raw_syscall6(SYS_munmap, (long)snapshot->bytes,
                           snapshot->mapping_size, 0, 0, 0, 0);
        if (history_bytes >= snapshot->mapping_size)
            history_bytes -= snapshot->mapping_size;
        else
            history_bytes = 0;
    }
    snapshot->bytes = (uint8_t *)0;
    snapshot->length = 0;
    snapshot->mapping_size = 0;
    snapshot->cursor = 0;
    snapshot->selection_anchor = 0;
    snapshot->selection_active = 0;
    snapshot->revision = 0;
}

static void stack_drop_oldest(snapshot_t *stack, uint32_t *count)
{
    uint32_t i;
    if (!*count)
        return;
    snapshot_drop(&stack[0]);
    for (i = 1; i < *count; ++i)
        stack[i - 1] = stack[i];
    --*count;
    stack[*count].bytes = (uint8_t *)0;
    stack[*count].length = 0;
    stack[*count].mapping_size = 0;
}

static void stack_clear(snapshot_t *stack, uint32_t *count)
{
    while (*count)
        stack_drop_oldest(stack, count);
}

static void history_clear_all(void)
{
    stack_clear(undo_stack, &undo_count);
    stack_clear(redo_stack, &redo_count);
    if (baseline_valid)
        snapshot_drop(&baseline);
    baseline_valid = 0;
}

static int make_room(uint32_t bytes)
{
    while ((uint64_t)history_bytes + bytes > HISTORY_BUDGET) {
        if (undo_count)
            stack_drop_oldest(undo_stack, &undo_count);
        else if (redo_count)
            stack_drop_oldest(redo_stack, &redo_count);
        else if (baseline_valid) {
            snapshot_drop(&baseline);
            baseline_valid = 0;
        } else {
            return 0;
        }
    }
    return 1;
}

static int snapshot_capture(snapshot_t *snapshot)
{
    uint32_t length = doc_length;
    uint32_t size = mapping_size_for(length);
    long mapped;
    uint32_t i;
    if (!size || !make_room(size))
        return 0;
    mapped = raw_syscall6(SYS_mmap, 0, size, PROT_READ | PROT_WRITE,
                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (syscall_failed(mapped))
        return 0;
    snapshot->bytes = (uint8_t *)(uintptr_t)mapped;
    snapshot->length = length;
    snapshot->mapping_size = size;
    snapshot->cursor = doc_cursor;
    snapshot->selection_anchor = doc_selection_anchor;
    snapshot->selection_active = doc_selection_active;
    snapshot->revision = doc_revision;
    for (i = 0; i < length; ++i)
        snapshot->bytes[i] = (uint8_t)doc_byte_at(i);
    history_bytes += size;
    return 1;
}

static void stack_push(snapshot_t *stack, uint32_t *count,
                       snapshot_t snapshot)
{
    if (*count == HISTORY_DEPTH)
        stack_drop_oldest(stack, count);
    stack[*count] = snapshot;
    ++*count;
}

static snapshot_t stack_pop(snapshot_t *stack, uint32_t *count)
{
    snapshot_t snapshot = stack[*count - 1u];
    stack[*count - 1u].bytes = (uint8_t *)0;
    stack[*count - 1u].length = 0;
    stack[*count - 1u].mapping_size = 0;
    --*count;
    return snapshot;
}

static int reserve_document(uint32_t length)
{
    if (!doc_buffer)
        return 0;
    while (doc_capacity < length) {
        long result = doc_buffer_grow();
        if (syscall_failed(result))
            return 0;
    }
    return 1;
}

static int snapshot_restore(const snapshot_t *snapshot)
{
    uint32_t i;
    uint32_t length = snapshot->length;
    if (!snapshot->bytes || !reserve_document(length))
        return 0;

    doc_gap_start = 0;
    doc_gap_end = doc_capacity;
    doc_length = 0;
    for (i = 0; i < length; ++i)
        doc_buffer[i] = snapshot->bytes[i];
    doc_gap_start = length;
    doc_gap_end = doc_capacity;
    doc_length = length;
    doc_cursor = snapshot->cursor <= length ? snapshot->cursor : length;
    doc_selection_anchor =
        snapshot->selection_anchor <= length ? snapshot->selection_anchor : length;
    doc_selection_active =
        snapshot->selection_active && doc_selection_anchor != doc_cursor;
    doc_line_index_valid = 0;
    doc_storage_error = 0;
    ++doc_revision;
    doc_ensure_cursor_visible();
    return 1;
}

void history_reset(void)
{
    history_clear_all();
}

void history_checkpoint(void)
{
    snapshot_t current = {0};
    if (baseline_valid && baseline.revision == doc_revision) {
        /* Navigation/selection do not change the content revision, but the
           next undo should restore the actual pre-edit caret and selection. */
        baseline.cursor = doc_cursor;
        baseline.selection_anchor = doc_selection_anchor;
        baseline.selection_active = doc_selection_active;
        return;
    }

    /* An edit after Undo starts a new branch and invalidates Redo. */
    stack_clear(redo_stack, &redo_count);
    if (!snapshot_capture(&current)) {
        history_clear_all();
        return;
    }
    if (!baseline_valid) {
        baseline = current;
        baseline_valid = 1;
        return;
    }
    stack_push(undo_stack, &undo_count, baseline);
    baseline = current;
    baseline_valid = 1;
}

static int history_move(snapshot_t *from_stack, uint32_t *from_count,
                        snapshot_t *to_stack, uint32_t *to_count)
{
    snapshot_t target;
    if (!*from_count || !baseline_valid)
        return 0;
    target = from_stack[*from_count - 1u];
    if (!target.bytes || !reserve_document(target.length))
        return 0;

    if (*to_count == HISTORY_DEPTH)
        stack_drop_oldest(to_stack, to_count);
    target = stack_pop(from_stack, from_count);
    stack_push(to_stack, to_count, baseline);
    baseline = target;
    if (!snapshot_restore(&baseline)) {
        baseline = stack_pop(to_stack, to_count);
        stack_push(from_stack, from_count, target);
        return 0;
    }
    baseline.revision = doc_revision;
    return 1;
}

int history_undo(void)
{
    return history_move(undo_stack, &undo_count, redo_stack, &redo_count);
}

int history_redo(void)
{
    return history_move(redo_stack, &redo_count, undo_stack, &undo_count);
}
