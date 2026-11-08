#include <stdint.h>
#include <stddef.h>

/* Native Wayland text clipboard; raw syscalls only, no libc or runtime library. */
#define SYS_read 0
#define SYS_write 1
#define SYS_close 3
#define SYS_fcntl 72
#define SYS_mmap 9
#define SYS_munmap 11
#define SYS_mprotect 10
#define SYS_pipe2 293
#define SYS_mremap 25
#define SYS_rt_sigaction 13
#define SYS_poll 7
#define SYS_recvmsg 47
#define SYS_fork 57
#define SYS_prctl 157

#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_PRIVATE 2
#define MAP_ANONYMOUS 0x20
#define MREMAP_MAYMOVE 1
#define O_NONBLOCK 0x800
#define O_CLOEXEC 0x80000
#define F_GETFL 3
#define F_SETFL 4
#define POLLIN 0x001
#define POLLOUT 0x004
#define POLLERR 0x008
#define POLLHUP 0x010
#define POLLNVAL 0x020
#define MSG_CMSG_CLOEXEC 0x40000000
#define MSG_CTRUNC 0x008

#define SOURCE_COUNT 8u
#define SEND_COUNT 4u
#define RECEIVE_INITIAL 65536u
#define RECEIVE_LIMIT (64u * 1024u * 1024u)
#define SOURCE_LIVE 1u
#define SOURCE_RETIRED 2u

typedef struct {
    int32_t fd;
    int16_t events;
    int16_t revents;
} pollfd_t;

typedef struct {
    uint32_t object_id;
    uint32_t flags;
    uint8_t *snapshot;
    uint32_t length;
    uint32_t mapping_size;
    uint32_t active_sends;
    uint32_t reserved;
} source_t;

typedef struct {
    int32_t fd;
    int32_t source_index;
    uint32_t offset;
    uint32_t length;
    uint8_t *bytes;
    uint32_t reserved;
} send_t;

extern uint32_t clipboard_manager_global;
extern uint32_t next_client_object_id;
extern uint32_t keyboard_serial;
extern int32_t event_fd;
extern int32_t clipboard_persistence_enabled;
extern uint8_t event_payload[4096];
extern void linux_exit(int);
extern uint32_t doc_selection_active;
extern uint32_t doc_selection_anchor;
extern uint32_t doc_cursor;
extern uint32_t doc_storage_error;
extern uint32_t doc_gap_start;
extern uint32_t doc_gap_end;
extern uint8_t *doc_buffer;

extern long wl_registry_bind(uint32_t, const char *, uint32_t, uint32_t, uint32_t);
extern long wl_send_request(uint32_t, uint32_t, const void *, uint32_t);
extern long wl_send_request_fd(uint32_t, uint32_t, const void *, uint32_t, int32_t);
extern uint32_t doc_byte_at(uint32_t);
extern long doc_insert_byte(uint32_t);
extern void doc_delete_selection(void);
extern void doc_clear_selection(void);
extern void doc_ensure_cursor_visible(void);
extern long doc_buffer_grow(void);
extern void history_begin_action(void);
extern void history_commit_action(void);

static const char manager_interface[] = "wl_data_device_manager";
static const char mime_utf8[] = "text/plain;charset=utf-8";
static const char mime_plain[] = "text/plain";

static uint32_t manager_object;
static uint32_t device_object;
static uint32_t pending_offer;
static uint32_t selected_offer;
static uint32_t pending_mimes;
static uint32_t selected_mimes;
static uint32_t current_source;
static source_t sources[SOURCE_COUNT];
static send_t sends[SEND_COUNT];
static int32_t receive_fd = -1;
static uint8_t *receive_buffer;
static uint32_t receive_length;
static uint32_t receive_capacity;
static uint32_t clipboard_service_mode;
static uint32_t clipboard_service_should_exit;
static int32_t service_socket_fd = -1;

static long syscall6(long n, long a1, long a2, long a3,
                     long a4, long a5, long a6)
{
    register long rax __asm__("rax") = n;
    register long r10 __asm__("r10") = a4;
    register long r8 __asm__("r8") = a5;
    register long r9 __asm__("r9") = a6;
    __asm__ volatile ("syscall"
        : "+a"(rax)
        : "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8), "r"(r9)
        : "rcx", "r11", "memory");
    return rax;
}

static int is_error(long value)
{
    return value < 0 && value >= -4095;
}

static long map_memory(uint32_t bytes)
{
    return syscall6(SYS_mmap, 0, bytes, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
}

static void unmap_memory(void *address, uint32_t bytes)
{
    if (address && bytes)
        (void)syscall6(SYS_munmap, (long)address, bytes, 0, 0, 0, 0);
}

static void close_fd(int fd)
{
    if (fd >= 0)
        (void)syscall6(SYS_close, fd, 0, 0, 0, 0, 0);
}

static uint32_t text_length(const char *text)
{
    uint32_t length = 0;
    while (text[length])
        ++length;
    return length;
}

static uint32_t encode_string(uint8_t *payload, const char *text)
{
    uint32_t length = text_length(text) + 1u;
    uint32_t padded = (length + 3u) & ~3u;
    uint32_t i;
    *(uint32_t *)(void *)payload = length;
    for (i = 0; i < padded; ++i)
        payload[4u + i] = i < length ? (uint8_t)text[i] : 0;
    return 4u + padded;
}

static int equal_mime(const uint8_t *candidate, const char *expected, uint32_t length)
{
    uint32_t i;
    uint32_t expected_length = text_length(expected);
    if (length != expected_length + 1u)
        return 0;
    for (i = 0; i < expected_length; ++i)
        if (candidate[i] != (uint8_t)expected[i])
            return 0;
    return candidate[expected_length] == 0;
}

static long source_offer_mime(uint32_t source, const char *mime)
{
    uint8_t payload[40];
    uint32_t length = encode_string(payload, mime);
    return wl_send_request(source, 0, payload, length);
}

static int find_source(uint32_t object_id)
{
    uint32_t i;
    for (i = 0; i < SOURCE_COUNT; ++i)
        if ((sources[i].flags & SOURCE_LIVE) && sources[i].object_id == object_id)
            return (int)i;
    return -1;
}

static int find_free_source(void)
{
    uint32_t i;
    for (i = 0; i < SOURCE_COUNT; ++i)
        if (!(sources[i].flags & SOURCE_LIVE))
            return (int)i;
    return -1;
}

static int find_free_send(void)
{
    uint32_t i;
    for (i = 0; i < SEND_COUNT; ++i)
        if (sends[i].fd < 0)
            return (int)i;
    return -1;
}

static void maybe_release_source(uint32_t index)
{
    source_t *source;
    if (index >= SOURCE_COUNT)
        return;
    source = &sources[index];
    if (!(source->flags & SOURCE_LIVE) ||
        !(source->flags & SOURCE_RETIRED) || source->active_sends)
        return;
    unmap_memory(source->snapshot, source->mapping_size);
    source->object_id = 0;
    source->flags = 0;
    source->snapshot = (uint8_t *)0;
    source->length = 0;
    source->mapping_size = 0;
}

static void finish_send(uint32_t index)
{
    send_t *send;
    int32_t source_index;
    if (index >= SEND_COUNT || sends[index].fd < 0)
        return;
    send = &sends[index];
    close_fd(send->fd);
    source_index = send->source_index;
    send->fd = -1;
    send->source_index = -1;
    send->offset = 0;
    send->length = 0;
    send->bytes = (uint8_t *)0;
    if (source_index >= 0 && source_index < (int32_t)SOURCE_COUNT) {
        if (sources[source_index].active_sends)
            --sources[source_index].active_sends;
        maybe_release_source((uint32_t)source_index);
    }
}

static void service_send(uint32_t index, int16_t revents)
{
    send_t *send = &sends[index];
    uint32_t remaining;
    uint32_t count;
    long result;
    if (send->fd < 0)
        return;
    if (revents & (POLLERR | POLLHUP | POLLNVAL)) {
        finish_send(index);
        return;
    }
    remaining = send->length - send->offset;
    if (!remaining) {
        finish_send(index);
        return;
    }
    count = remaining > 16384u ? 16384u : remaining;
    result = syscall6(SYS_write, send->fd,
                      (long)(send->bytes + send->offset), count, 0, 0, 0);
    if (result > 0) {
        send->offset += (uint32_t)result;
        if (send->offset == send->length)
            finish_send(index);
        return;
    }
    if (result == -4 || result == -11)
        return;
    finish_send(index);
}

static int insert_text(const uint8_t *bytes, uint32_t length)
{
    uint32_t selected = 0;
    uint32_t needed;
    uint32_t i;
    if (!length)
        return 0;
    if (doc_selection_active) {
        uint32_t a = doc_selection_anchor;
        uint32_t b = doc_cursor;
        selected = a > b ? a - b : b - a;
    }
    needed = length > selected ? length - selected : 0;
    while ((doc_gap_end - doc_gap_start) < needed) {
        long grown = doc_buffer_grow();
        if (is_error(grown))
            return 0;
    }
    history_begin_action();
    if (doc_selection_active)
        doc_delete_selection();
    for (i = 0; i < length; ++i) {
        (void)doc_insert_byte(bytes[i]);
        if (doc_storage_error) {
            history_commit_action();
            return 0;
        }
    }
    doc_clear_selection();
    history_commit_action();
    doc_ensure_cursor_visible();
    return 1;
}

static int grow_receive_buffer(void)
{
    uint32_t next = receive_capacity * 2u;
    long result;
    if (next < receive_capacity || next > RECEIVE_LIMIT)
        next = RECEIVE_LIMIT;
    if (next <= receive_capacity)
        return 0;
    result = syscall6(SYS_mremap, (long)receive_buffer, receive_capacity,
                      next, MREMAP_MAYMOVE, 0, 0);
    if (is_error(result))
        return 0;
    receive_buffer = (uint8_t *)(uintptr_t)result;
    receive_capacity = next;
    return 1;
}

static int finish_receive(void)
{
    int changed = insert_text(receive_buffer, receive_length);
    close_fd(receive_fd);
    unmap_memory(receive_buffer, receive_capacity);
    receive_fd = -1;
    receive_buffer = (uint8_t *)0;
    receive_length = 0;
    receive_capacity = 0;
    return changed;
}

static int service_receive(int16_t revents)
{
    uint32_t available;
    long result;
    if (receive_fd < 0)
        return 0;
    if (revents & POLLNVAL)
        goto receive_failed;
    if (receive_length == receive_capacity && !grow_receive_buffer())
        goto receive_failed;
    available = receive_capacity - receive_length;
    result = syscall6(SYS_read, receive_fd,
                      (long)(receive_buffer + receive_length), available, 0, 0, 0);
    if (result > 0) {
        receive_length += (uint32_t)result;
        return 0;
    }
    if (result == 0)
        return finish_receive();
    if (result == -4 || result == -11) {
        if (!(revents & (POLLERR | POLLHUP)))
            return 0;
    }
receive_failed:
    close_fd(receive_fd);
    unmap_memory(receive_buffer, receive_capacity);
    receive_fd = -1;
    receive_buffer = (uint8_t *)0;
    receive_length = 0;
    receive_capacity = 0;
    return 0;
}

static int start_receive(uint32_t offer)
{
    int32_t pipe_fds[2] = {-1, -1};
    uint8_t payload[40];
    const char *mime;
    uint32_t message_size;
    uint8_t *buffer;
    long result;
    if (receive_fd >= 0)
        return 0;
    if (selected_mimes & 1u)
        mime = mime_utf8;
    else if (selected_mimes & 2u)
        mime = mime_plain;
    else
        return 0;
    result = syscall6(SYS_pipe2, (long)pipe_fds, O_NONBLOCK | O_CLOEXEC,
                      0, 0, 0, 0);
    if (is_error(result))
        return 0;
    result = map_memory(RECEIVE_INITIAL);
    if (is_error(result)) {
        close_fd(pipe_fds[0]);
        close_fd(pipe_fds[1]);
        return 0;
    }
    buffer = (uint8_t *)(uintptr_t)result;
    message_size = encode_string(payload, mime);
    result = wl_send_request_fd(offer, 1, payload, message_size, pipe_fds[1]);
    close_fd(pipe_fds[1]);
    if (result < 0) {
        close_fd(pipe_fds[0]);
        unmap_memory(buffer, RECEIVE_INITIAL);
        return 0;
    }
    receive_fd = pipe_fds[0];
    receive_buffer = buffer;
    receive_length = 0;
    receive_capacity = RECEIVE_INITIAL;
    return 1;
}

static int copy_selection(int cut)
{
    uint32_t begin, end, length, source_id, serial, i;
    int index;
    uint8_t *snapshot;
    uint32_t args[2];
    source_t *source;
    long result;
    if (!device_object || !clipboard_manager_global || !doc_selection_active)
        return 0;
    begin = doc_selection_anchor;
    end = doc_cursor;
    if (begin > end) {
        uint32_t temporary = begin;
        begin = end;
        end = temporary;
    }
    if (begin == end)
        return 0;
    length = end - begin;
    if (length > RECEIVE_LIMIT)
        return 0;
    index = find_free_source();
    if (index < 0)
        return 0;
    result = map_memory(length);
    if (is_error(result))
        return 0;
    snapshot = (uint8_t *)(uintptr_t)result;
    for (i = 0; i < length; ++i)
        snapshot[i] = (uint8_t)doc_byte_at(begin + i);

    source_id = next_client_object_id++;
    source = &sources[index];
    source->object_id = source_id;
    source->flags = SOURCE_LIVE;
    source->snapshot = snapshot;
    source->length = length;
    source->mapping_size = length;
    source->active_sends = 0;

    args[0] = source_id;
    result = wl_send_request(manager_object, 0, args, 4);
    if (result < 0)
        goto copy_failed;
    if (syscall6(SYS_mprotect, (long)snapshot, length, PROT_READ, 0, 0, 0) < 0)
        goto copy_destroy_source;
    if (source_offer_mime(source_id, mime_utf8) < 0 ||
        source_offer_mime(source_id, mime_plain) < 0)
        goto copy_destroy_source;
    serial = keyboard_serial;
    args[0] = source_id;
    args[1] = serial;
    result = wl_send_request(device_object, 1, args, 8);
    if (result < 0)
        goto copy_destroy_source;
    current_source = source_id;
    if (cut) {
        doc_delete_selection();
        return 1;
    }
    return 0;

copy_destroy_source:
    (void)wl_send_request(source_id, 1, (const void *)0, 0);
copy_failed:
    unmap_memory(snapshot, length);
    source->object_id = 0;
    source->flags = 0;
    source->snapshot = (uint8_t *)0;
    source->length = 0;
    source->mapping_size = 0;
    source->active_sends = 0;
    return 0;
}

static int paste_local(void)
{
    int index = find_source(current_source);
    if (index < 0 || (sources[index].flags & SOURCE_RETIRED))
        return 0;
    return insert_text(sources[index].snapshot, sources[index].length);
}

int clipboard_setup(void)
{
    struct {
        uintptr_t handler;
        uint64_t flags;
        uintptr_t restorer;
        uint64_t mask;
    } ignore_sigpipe = {1, 0, 0, 0};
    uint32_t manager_id, data_id, args[2];
    uint32_t i;
    long result;
    for (i = 0; i < SEND_COUNT; ++i) {
        sends[i].fd = -1;
        sends[i].source_index = -1;
    }
    receive_fd = -1;
    if (!clipboard_manager_global || !doc_buffer)
        return 0;
    /* A reader can close its pipe early; retire the transfer instead of
       allowing the default SIGPIPE action to terminate the editor. */
    (void)syscall6(SYS_rt_sigaction, 13, (long)&ignore_sigpipe, 0, 8, 0, 0);
    manager_id = next_client_object_id++;
    result = wl_registry_bind(clipboard_manager_global, manager_interface,
                              (uint32_t)sizeof(manager_interface), 1, manager_id);
    if (result < 0)
        return result;
    manager_object = manager_id;
    data_id = next_client_object_id++;
    args[0] = data_id;
    args[1] = 13; /* wl_seat object */
    result = wl_send_request(manager_id, 1, args, 8);
    if (result < 0)
        return result;
    device_object = data_id;
    return 0;
}

int clipboard_key_command(uint32_t action)
{
    if (action == 1u)
        return copy_selection(0);
    if (action == 2u)
        return copy_selection(1);
    if (action == 3u) {
        if (selected_offer)
            (void)start_receive(selected_offer);
        else
            return paste_local();
    }
    return 0;
}

void clipboard_poll_prepare(pollfd_t *pollfds)
{
    uint32_t i;
    for (i = 0; i < SEND_COUNT; ++i) {
        pollfds[2u + i].fd = sends[i].fd;
        pollfds[2u + i].events = POLLOUT;
        pollfds[2u + i].revents = 0;
    }
    pollfds[6].fd = receive_fd;
    pollfds[6].events = POLLIN;
    pollfds[6].revents = 0;
}

int clipboard_poll_dispatch(pollfd_t *pollfds)
{
    uint32_t i;
    int changed = 0;
    for (i = 0; i < SEND_COUNT; ++i)
        if (pollfds[2u + i].revents)
            service_send(i, pollfds[2u + i].revents);
    if (pollfds[6].revents)
        changed = service_receive(pollfds[6].revents);
    return changed;
}

int clipboard_handle_event(uint32_t object_id, uint32_t opcode,
                           const uint8_t *payload, uint32_t size, int32_t fd)
{
    if (device_object && object_id == device_object) {
        if (opcode == 0 && size >= 4) {
            pending_offer = *(const uint32_t *)(const void *)payload;
            pending_mimes = 0;
            return 1;
        }
        if (opcode == 5 && size >= 4) {
            selected_offer = *(const uint32_t *)(const void *)payload;
            selected_mimes = selected_offer == pending_offer ? pending_mimes : 0;
            if (clipboard_service_mode && current_source)
                clipboard_service_should_exit = 1;
            if (!selected_offer)
                selected_mimes = 0;
            return 1;
        }
    }

    if (pending_offer && object_id == pending_offer && opcode == 0) {
        uint32_t length;
        if (size < 4)
            return 1;
        length = *(const uint32_t *)(const void *)payload;
        if (!length || length > size - 4u)
            return 1;
        if (equal_mime(payload + 4, mime_utf8, length))
            pending_mimes |= 1u;
        else if (equal_mime(payload + 4, mime_plain, length))
            pending_mimes |= 2u;
        if (selected_offer == pending_offer)
            selected_mimes = pending_mimes;
        return 1;
    }

    {
        int index = find_source(object_id);
        if (index >= 0) {
            source_t *source = &sources[index];
            if (opcode == 1) {
                if (fd >= 0) {
                    int slot = find_free_send();
                    long flags = syscall6(SYS_fcntl, fd, F_GETFL, 0, 0, 0, 0);
                    if (flags >= 0)
                        (void)syscall6(SYS_fcntl, fd, F_SETFL,
                                       flags | O_NONBLOCK, 0, 0, 0);
                    if (slot < 0) {
                        close_fd(fd);
                    } else {
                        sends[slot].fd = fd;
                        sends[slot].source_index = index;
                        sends[slot].offset = 0;
                        sends[slot].length = source->length;
                        sends[slot].bytes = source->snapshot;
                        ++source->active_sends;
                    }
                    event_fd = -1; /* ownership moved to the transfer slot */
                }
                return 1;
            }
            if (opcode == 2) {
                source->flags |= SOURCE_RETIRED;
                if (current_source == object_id) {
                    current_source = 0;
                    if (clipboard_service_mode)
                        clipboard_service_should_exit = 1;
                }
                (void)wl_send_request(object_id, 1, (const void *)0, 0);
                maybe_release_source((uint32_t)index);
                return 1;
            }
            if (opcode == 0)
                return 1; /* wl_data_source.target */
        }
    }
    return 0;
}


/* Retain the exact existing Wayland client and source across editor exit. */
typedef struct { uint64_t base, length; } service_iovec_t;
typedef struct {
    uint64_t name;
    uint32_t name_length, name_padding;
    uint64_t iov, iov_count, control, control_length;
    uint32_t flags, padding;
} service_msghdr_t;
typedef struct { uint64_t length; int32_t level, type; } service_cmsghdr_t;

static int service_receive_exact(uint8_t *bytes, uint32_t length)
{
    uint32_t done = 0;
    while (done < length) {
        service_iovec_t iov;
        service_msghdr_t msg;
        uint8_t control[64] __attribute__((aligned(8)));
        long result;
        uint32_t i;
        iov.base = (uint64_t)(uintptr_t)(bytes + done);
        iov.length = length - done;
        for (i = 0; i < sizeof(msg); ++i) ((uint8_t *)&msg)[i] = 0;
        for (i = 0; i < sizeof(control); ++i) control[i] = 0;
        msg.iov = (uint64_t)(uintptr_t)&iov;
        msg.iov_count = 1;
        msg.control = (uint64_t)(uintptr_t)control;
        msg.control_length = sizeof(control);
        result = syscall6(SYS_recvmsg, service_socket_fd, (long)&msg,
                          MSG_CMSG_CLOEXEC, 0, 0, 0);
        if (result > 0) {
            if (msg.flags & MSG_CTRUNC) return 0;
            if (msg.control_length >= sizeof(service_cmsghdr_t) + 4u) {
                service_cmsghdr_t *ch = (service_cmsghdr_t *)(void *)control;
                if (ch->length >= sizeof(service_cmsghdr_t) + 4u &&
                    ch->level == 1 && ch->type == 1) {
                    uint32_t count = (uint32_t)(ch->length - sizeof(service_cmsghdr_t)) / 4u;
                    uint32_t j;
                    for (j = 0; j < count; ++j) {
                        int32_t incoming = *(int32_t *)(void *)(
                            control + sizeof(service_cmsghdr_t) + j * 4u);
                        if (event_fd < 0) event_fd = incoming;
                        else close_fd(incoming);
                    }
                }
            }
            done += (uint32_t)result;
            continue;
        }
        if (result == -4) continue;
        return 0;
    }
    return 1;
}

static int service_read_event(void)
{
    uint8_t header[8];
    uint32_t object_id, word, opcode, size;
    if (!service_receive_exact(header, sizeof(header))) return 0;
    object_id = *(uint32_t *)(void *)header;
    word = *(uint32_t *)(void *)(header + 4);
    opcode = word & 0xffffu;
    size = word >> 16;
    if (size < 8u || size - 8u > 4096u) return 0;
    size -= 8u;
    if (size && !service_receive_exact(event_payload, size)) return 0;

    /* Continue answering xdg_wm_base.ping after the toplevel has closed. */
    if (object_id == 6u && opcode == 0u && size >= 4u) {
        uint32_t serial = *(uint32_t *)(void *)event_payload;
        return wl_send_request(6u, 3u, &serial, 4u) >= 0;
    }
    {
        int32_t descriptor = event_fd;
        (void)clipboard_handle_event(object_id, opcode, event_payload, size, descriptor);
        if (event_fd >= 0) {
            close_fd(event_fd);
            event_fd = -1;
        }
    }
    return 1;
}

static int service_has_pending_sends(void)
{
    uint32_t i;
    for (i = 0; i < SEND_COUNT; ++i)
        if (sends[i].fd >= 0) return 1;
    return 0;
}

static void clipboard_service_loop(void)
{
    pollfd_t fds[7];
    clipboard_service_mode = 1;
    clipboard_service_should_exit = 0;
    (void)syscall6(SYS_prctl, 15, (long)"nekoedit-clip", 0, 0, 0, 0);
    if (event_fd >= 0) { close_fd(event_fd); event_fd = -1; }
    for (;;) {
        long result;
        fds[0].fd = service_socket_fd;
        fds[0].events = POLLIN;
        fds[0].revents = 0;
        fds[1].fd = -1;
        fds[1].events = 0;
        fds[1].revents = 0;
        clipboard_poll_prepare(fds);
        result = syscall6(SYS_poll, (long)fds, 7, -1, 0, 0, 0);
        if (result == -4) continue;
        if (result < 0 || (fds[0].revents & (POLLERR | POLLHUP | POLLNVAL))) break;
        if ((fds[0].revents & POLLIN) && !service_read_event()) break;
        (void)clipboard_poll_dispatch(fds);
        if (clipboard_service_should_exit && !service_has_pending_sends()) break;
    }
    close_fd(service_socket_fd);
    service_socket_fd = -1;
    linux_exit(0);
}

long clipboard_service_handoff(int32_t socket_descriptor)
{
    long child;
    if (!clipboard_persistence_enabled || !current_source ||
        find_source(current_source) < 0 || socket_descriptor < 0)
        return 0;
    child = syscall6(SYS_fork, 0, 0, 0, 0, 0, 0);
    if (child < 0) return child;
    if (child == 0) {
        service_socket_fd = socket_descriptor;
        clipboard_service_loop();
    }
    return child;
}
