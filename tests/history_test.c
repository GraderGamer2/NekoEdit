#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

char **process_envp;
extern char **environ;

uint32_t doc_length;
uint32_t doc_cursor;
uint32_t doc_selection_anchor;
uint32_t doc_selection_active;
uint32_t doc_capacity;
uint32_t doc_gap_start;
uint32_t doc_gap_end;
uint32_t doc_line_index_valid;
uint32_t doc_storage_error;
uint8_t *doc_buffer;

void history_open(const char *path);
void history_reset(void);
void history_begin_action(void);
void history_note_insert(uint32_t offset, uint32_t value);
void history_note_delete(uint32_t offset, uint32_t length);
void history_commit_action(void);
int history_undo(void);
int history_redo(void);
void history_mark_saved(void);
uint32_t history_undo_count(void);
uint32_t history_redo_count(void);
uint32_t history_has_error(void);
int history_delete_current(void);
int history_export_to(const char *destination);

static void fail(const char *message)
{
    fprintf(stderr, "history test: %s\n", message);
    exit(1);
}

static void move_gap(uint32_t position)
{
    if (position < doc_gap_start) {
        uint32_t count = doc_gap_start - position;
        memmove(doc_buffer + doc_gap_end - count,
                doc_buffer + position, count);
        doc_gap_start -= count;
        doc_gap_end -= count;
    } else if (position > doc_gap_start) {
        uint32_t count = position - doc_gap_start;
        memmove(doc_buffer + doc_gap_start,
                doc_buffer + doc_gap_end, count);
        doc_gap_start += count;
        doc_gap_end += count;
    }
}

uint32_t doc_byte_at(uint32_t offset)
{
    if (offset >= doc_length)
        return 0;
    if (offset < doc_gap_start)
        return doc_buffer[offset];
    return doc_buffer[offset + doc_gap_end - doc_gap_start];
}

long doc_buffer_grow(void)
{
    uint32_t next = doc_capacity ? doc_capacity * 2u : 65536u;
    uint32_t suffix = doc_capacity - doc_gap_end;
    uint8_t *replacement = (uint8_t *)calloc(next, 1);
    if (!replacement)
        return -12;
    if (doc_gap_start)
        memcpy(replacement, doc_buffer, doc_gap_start);
    if (suffix)
        memcpy(replacement + next - suffix, doc_buffer + doc_gap_end, suffix);
    free(doc_buffer);
    doc_buffer = replacement;
    doc_capacity = next;
    doc_gap_end = next - suffix;
    return 0;
}

long doc_insert_byte(uint32_t value)
{
    history_note_insert(doc_cursor, value);
    move_gap(doc_cursor);
    if (doc_gap_start == doc_gap_end && doc_buffer_grow() < 0) {
        doc_storage_error = 1;
        return -12;
    }
    doc_buffer[doc_gap_start++] = (uint8_t)value;
    ++doc_length;
    ++doc_cursor;
    doc_storage_error = 0;
    return 0;
}

void doc_delete_selection(void)
{
    uint32_t begin, end;
    if (!doc_selection_active)
        return;
    begin = doc_selection_anchor;
    end = doc_cursor;
    if (begin > end) {
        uint32_t temporary = begin;
        begin = end;
        end = temporary;
    }
    history_note_delete(begin, end - begin);
    move_gap(begin);
    doc_gap_end += end - begin;
    doc_length -= end - begin;
    doc_cursor = begin;
    doc_selection_anchor = begin;
    doc_selection_active = 0;
}

void doc_ensure_cursor_visible(void)
{
}

static void document_reset(const uint8_t *bytes, uint32_t length)
{
    if (length > doc_capacity) {
        uint8_t *replacement = (uint8_t *)realloc(doc_buffer, length + 65536u);
        if (!replacement)
            fail("could not allocate document fixture");
        doc_buffer = replacement;
        doc_capacity = length + 65536u;
    }
    if (length)
        memcpy(doc_buffer, bytes, length);
    doc_length = length;
    doc_cursor = length;
    doc_selection_anchor = length;
    doc_selection_active = 0;
    doc_gap_start = length;
    doc_gap_end = doc_capacity;
    doc_line_index_valid = 0;
    doc_storage_error = 0;
}

static void expect_document(const uint8_t *expected, uint32_t length,
                            const char *label)
{
    uint32_t i;
    if (doc_length != length) {
        fprintf(stderr, "history test: %s length mismatch: %u != %u\n",
                label, doc_length, length);
        exit(1);
    }
    for (i = 0; i < length; ++i) {
        if (doc_byte_at(i) != expected[i]) {
            fprintf(stderr, "history test: %s byte mismatch at %u\n", label, i);
            exit(1);
        }
    }
}

static void save_document(const char *path)
{
    FILE *file = fopen(path, "wb");
    uint32_t i;
    if (!file)
        fail("could not create saved-document fixture");
    for (i = 0; i < doc_length; ++i) {
        uint8_t byte = (uint8_t)doc_byte_at(i);
        if (fwrite(&byte, 1, 1, file) != 1)
            fail("could not write saved-document fixture");
    }
    if (fclose(file) != 0)
        fail("could not close saved-document fixture");
}

static uint32_t load_document(const char *path, uint8_t *buffer, uint32_t capacity)
{
    FILE *file = fopen(path, "rb");
    size_t length;
    if (!file)
        fail("could not reopen saved-document fixture");
    length = fread(buffer, 1, capacity, file);
    if (ferror(file))
        fail("could not read saved-document fixture");
    if (fclose(file) != 0)
        fail("could not close reopened document fixture");
    return (uint32_t)length;
}

static int history_file_count(const char *directory, char *first, uint32_t capacity)
{
    DIR *dir = opendir(directory);
    struct dirent *entry;
    int count = 0;
    if (!dir)
        fail("could not inspect ~/.nekoedit");
    while ((entry = readdir(dir)) != NULL) {
        size_t length = strlen(entry->d_name);
        if (length >= 8 && strcmp(entry->d_name + length - 8, ".history") == 0) {
            ++count;
            if (first && count == 1) {
                if (snprintf(first, capacity, "%s/%s", directory, entry->d_name) <= 0)
                    fail("could not construct .history path");
            }
        }
    }
    closedir(dir);
    return count;
}

int main(void)
{
    char home[] = "/tmp/nekoedit-history-test-XXXXXX";
    char document_path[512];
    char app_directory[512];
    char exported_path[512];
    char history_path[512] = {0};
    uint8_t persisted[4096];
    uint8_t expected[4096];
    uint32_t expected_length, persisted_length, i;
    struct stat st;
    FILE *exported;
    char signature[8];

    if (!mkdtemp(home))
        fail("mkdtemp failed");
    if (setenv("HOME", home, 1) < 0)
        fail("could not set HOME");
    process_envp = environ;

    if (snprintf(document_path, sizeof(document_path), "%s/document.txt", home) <= 0 ||
        snprintf(app_directory, sizeof(app_directory), "%s/.nekoedit", home) <= 0 ||
        snprintf(exported_path, sizeof(exported_path), "%s/exported.history", home) <= 0)
        fail("could not construct test paths");

    doc_capacity = 65536;
    doc_buffer = (uint8_t *)calloc(doc_capacity, 1);
    if (!doc_buffer)
        fail("could not allocate initial document buffer");
    document_reset((const uint8_t *)"abc", 3);
    save_document(document_path);
    history_open(document_path);
    if (history_has_error())
        fail("initial journal creation failed");

    /* Replacement of a non-empty selection is one reversible transaction. */
    doc_cursor = 3;
    doc_selection_anchor = 0;
    doc_selection_active = 1;
    history_begin_action();
    doc_delete_selection();
    if (doc_insert_byte('Z') < 0)
        fail("replacement insertion failed");
    history_commit_action();
    expect_document((const uint8_t *)"Z", 1, "selection replacement");
    if (history_undo_count() != 1 || !history_undo())
        fail("replacement was not recorded as one undo operation");
    expect_document((const uint8_t *)"abc", 3, "undo replacement");
    if (!history_redo())
        fail("replacement redo was unavailable");
    expect_document((const uint8_t *)"Z", 1, "redo replacement");
    if (!history_undo())
        fail("second replacement undo failed");
    expect_document((const uint8_t *)"abc", 3, "second undo replacement");

    /* A new edit after Undo replaces the old Redo branch. */
    doc_cursor = 3;
    doc_selection_anchor = 3;
    doc_selection_active = 0;
    history_begin_action();
    if (doc_insert_byte('q') < 0)
        fail("branch insertion failed");
    history_commit_action();
    expect_document((const uint8_t *)"abcq", 4, "new branch");
    if (history_redo())
        fail("redo from the abandoned branch remained available");
    if (!history_undo())
        fail("could not undo the replacement branch before long-history test");
    expect_document((const uint8_t *)"abc", 3, "undo replacement branch");

    /* Exercise substantially more than the former 16-operation ceiling. */
    for (i = 0; i < 24; ++i) {
        doc_cursor = doc_length;
        doc_selection_anchor = doc_cursor;
        doc_selection_active = 0;
        history_begin_action();
        if (doc_insert_byte((uint32_t)('A' + i)) < 0)
            fail("long-history insertion failed");
        history_commit_action();
    }
    if (history_undo_count() != 24)
        fail("delta journal did not retain more than 16 grouped edits");
    for (i = 0; i < 24; ++i)
        if (!history_undo())
            fail("long-history undo failed before reaching the initial document");
    expect_document((const uint8_t *)"abc", 3, "undo all long-history edits");
    if (history_redo_count() != 24)
        fail("redo count is incorrect after the long undo sequence");
    for (i = 0; i < 24; ++i)
        if (!history_redo())
            fail("long-history redo failed");
    expected_length = 27;
    memcpy(expected, "abc", 3);
    for (i = 0; i < 24; ++i)
        expected[3 + i] = (uint8_t)('A' + i);
    expect_document(expected, expected_length, "redo all long-history edits");

    /* Save the current document and mark the journal's recovery checksum. */
    save_document(document_path);
    history_mark_saved();
    if (history_has_error())
        fail("saving the journal checksum reported an error");

    /* Simulate a process restart: load the on-disk file, then recover the
       original base plus committed delta records from the .history journal. */
    persisted_length = load_document(document_path, persisted, sizeof(persisted));
    document_reset(persisted, persisted_length);
    history_reset();
    history_open(document_path);
    expect_document(expected, expected_length, "restart recovery");
    if (history_undo_count() != 24 || history_redo_count() != 0) {
        fprintf(stderr, "history test: restart counts: undo=%u redo=%u error=%u\\n",
                history_undo_count(), history_redo_count(), history_has_error());
        fail("restart recovery did not restore the active journal position");
    }
    if (!history_undo())
        fail("undo after restart was unavailable");
    expect_document(expected, expected_length - 1u, "undo after restart");
    if (!history_redo())
        fail("redo after restart was unavailable");
    expect_document(expected, expected_length, "redo after restart");

    /* Private storage and an exported copy can be managed outside the
       hidden application folder without shell access to ~/.nekoedit. */
    if (stat(app_directory, &st) < 0 || (st.st_mode & 0777) != 0700)
        fail("history directory is not private mode 0700");
    if (history_file_count(app_directory, history_path, sizeof(history_path)) != 1)
        fail("expected exactly one active .history file");
    if (stat(history_path, &st) < 0 || (st.st_mode & 0777) != 0600)
        fail(".history journal is not private mode 0600");
    if (!history_export_to(exported_path))
        fail("History tab export operation failed");
    exported = fopen(exported_path, "rb");
    if (!exported)
        fail("could not open exported journal");
    if (fread(signature, 1, sizeof(signature), exported) != sizeof(signature))
        fail("exported journal header is truncated");
    fclose(exported);
    if (memcmp(signature, "NEKOHST1", 8) != 0)
        fail("exported file is not a NekoEdit history journal");

    if (!history_delete_current())
        fail("History tab delete operation failed");
    if (history_file_count(app_directory, NULL, 0) != 0)
        fail("deleted .history journal still exists");
    if (history_undo_count() != 0 || history_redo_count() != 0)
        fail("deleted journal still exposes undo or redo entries");

    /* Deleting history is non-destructive to the document and the next edit
       creates a fresh journal for the same document identity. */
    doc_cursor = doc_length;
    doc_selection_anchor = doc_cursor;
    doc_selection_active = 0;
    history_begin_action();
    if (doc_insert_byte('!') < 0)
        fail("post-delete insertion failed");
    history_commit_action();
    if (history_undo_count() != 1 || !history_undo())
        fail("a fresh journal was not created after deletion");
    expect_document(expected, expected_length, "post-delete undo");
    if (history_has_error())
        fail("history storage error flag was unexpectedly set");

    history_reset();
    free(doc_buffer);
    unlink(document_path);
    unlink(exported_path);
    if (history_file_count(app_directory, history_path, sizeof(history_path)) == 1)
        unlink(history_path);
    rmdir(app_directory);
    rmdir(home);
    puts("Disk-backed history tests passed (grouping, branching, >16 edits, recovery, export, delete, permissions).");
    return 0;
}
