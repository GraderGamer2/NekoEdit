# Clipboard behavior

Clipboard copy and paste are first-release requirements. They must interoperate with ordinary desktop applications and must not depend on a third-party clipboard library. A new user-requested goal is to keep copied text available after NekoEdit exits; this requires cooperation from a desktop clipboard manager or a small first-party companion process, because an exited Wayland client cannot continue serving its data source.

## Current Wayland implementation

The Wayland backend binds the optional `wl_data_device_manager`, creates a data device for the editor seat, and implements document shortcuts:

- **Ctrl+C:** copies the selection into an immutable mmap-backed snapshot and publishes UTF-8 plain-text MIME offers.
- **Ctrl+X:** establishes clipboard ownership from that independent snapshot first, then deletes the selected range. If ownership cannot be established, the selected text remains.
- **Ctrl+V:** requests `text/plain;charset=utf-8` first and falls back to `text/plain`, receiving the payload through an asynchronous nonblocking pipe. Received bytes replace the active selection or are inserted at the caret.

Clipboard transfers are serviced by the existing `poll()` loop in bounded chunks. Outgoing snapshots are independent of the document gap buffer and remain available during in-flight sends. The current payload ceiling is 64 MiB, the implementation has eight source records and four simultaneous outgoing-send slots, and it has one asynchronous receive buffer capped at 64 MiB. These are resource/concurrency limits, not a lifetime counter on how many sequential Ctrl+C/Ctrl+V commands a user may issue; completed/retired transfers release their slots for reuse. Paste targets the document editor only: paste into picker/path fields, PRIMARY selection, X11 clipboard support, and external UTF-8 validation/replacement policy are not implemented. Clipboard-manager handoff after process exit is not yet implemented.

## Ownership rule: copy is a snapshot

When the user invokes Copy, NekoEdit copies the selected UTF-8 byte range into a dedicated immutable clipboard allocation. The clipboard must never point into the live document buffer or the gap buffer.

Consequences:

- Deleting or replacing the original selection does not change the copied text.
- Closing the source document does not invalidate the copied text.
- Editing or reallocating the document buffer does not invalidate the copied text.
- A pending transfer holds a reference to the immutable snapshot until that transfer completes, even if a later copy replaces the current clipboard snapshot.

Cut must first establish clipboard ownership using the snapshot, then remove the selected range. If ownership cannot be established, do not delete the selected text.

The current snapshot remains available while NekoEdit owns the system clipboard. If another application replaces the clipboard, mark the snapshot as no longer current; free it only after all in-flight sends finish. This needs explicit reference counting or an equivalent lifetime mechanism.

NekoEdit currently does not guarantee clipboard persistence after its process exits. This is now a requested feature, not an implemented guarantee. First investigate whether the desktop's existing clipboard manager reliably captures the current offer before the editor exits. Prefer that integration over creating another resident process. If desktop-manager behavior cannot meet the requirement, evaluate an optional small first-party companion service. A companion could retain the last copied snapshot in memory (survives editor exit but not logout/reboot) or use an app-private file (survives editor exit and potentially logout/reboot); the latter adds disk writes, privacy/permissions requirements, cleanup policy, and data-at-rest considerations. Persistence across logout/reboot has not been requested or decided.

## Requested next target: repeated use and process-exit persistence

The user wants Ctrl+C/Ctrl+V use to be effectively unlimited in normal editing, and wants the last copied text to remain available after NekoEdit is closed.

Acceptance goals for a future implementation:

- Do not impose a lifetime command-count limit on sequential copy, cut, or paste operations.
- Reuse source and send records after their protocol references and in-flight transfers are finished. Replace fixed concurrent-slot ceilings with safely managed records if they become a practical obstacle; keep resource limits for concurrent work and payload size rather than silently exhausting RAM.
- Keep the copied payload immutable and independent of document storage. A later edit, cut, new document, or document close must not corrupt it.
- Preserve the last copied/cut payload after the editor process exits. First test handoff to the desktop clipboard manager. Only add an optional first-party companion service if the desktop manager cannot provide reliable handoff.
- Keep process-exit persistence distinct from session/reboot persistence. The latter remains undecided.
- Do not turn ordinary Copy into an accumulating clipboard-history database unless explicitly requested; the current requirement is to retain the latest clipboard contents, not every previous copy.

Current limits are not a total number of clipboard uses: eight source records, four simultaneous outgoing transfers, and 64 MiB maximum payload/receive size are the present implementation bounds. The source slots can be reused after retirement and transfer completion. The 64 MiB payload ceiling should be reviewed separately rather than removed without checked allocation, overflow handling, and memory-pressure behavior.

## Common editor interface

The editor core uses a small backend-neutral API:

```text
clipboard_copy(selection_start, selection_end)
clipboard_cut(selection_start, selection_end)
clipboard_paste()
clipboard_backend_selection_changed()
clipboard_transfer_finished(transfer_id)
```

The backend owns protocol objects and descriptors. The core owns the immutable snapshot and defines the text insertion behavior. Clipboard transfers are asynchronous and must not block the UI event loop.

## MIME types and text targets

### Wayland

Advertise UTF-8 plain text using:

- `text/plain;charset=utf-8`
- `text/plain`

When pasting, prefer the UTF-8-specific type, then `text/plain`. The data source writes the snapshot to the file descriptor supplied by the receiving client. The data offer receives data through a file descriptor supplied by NekoEdit. Handle short reads/writes, `EINTR`, `EAGAIN`, EOF, and peer closure.

Use the core `wl_data_device_manager`, `wl_data_device`, `wl_data_source`, and `wl_data_offer` interfaces when available. Clipboard selection is tied to a seat and requires a valid input serial for setting the selection.

### X11

Use the `CLIPBOARD` selection for explicit Ctrl+C/Ctrl+V. Implement the normal selection conversion flow and support at least:

- `TARGETS`
- `UTF8_STRING`
- `TEXT` where practical
- `STRING` as a legacy fallback with explicit Latin-1 conversion rules
- `TIMESTAMP` where required by the ICCCM conventions
- `INCR` for transfers too large for a single property

The X11 `PRIMARY` selection (mouse-selection / middle-click convention) can be added as a separate compatibility feature. It must not replace or corrupt the explicit `CLIPBOARD` selection. Wayland primary-selection support is an optional protocol extension and is not a requirement for baseline clipboard support.

## Paste validation

- The document model is UTF-8.
- Validate incoming text incrementally, without assuming a transfer arrives in one read.
- Preserve valid UTF-8 sequences exactly.
- For invalid byte sequences, use a documented replacement policy; do not overread or write past the destination buffer.
- Treat a clipboard payload as plain text, never as commands or markup.
- Support empty clipboard contents as a no-op.

## Event-loop requirements

Clipboard sending and receiving are nonblocking state machines. Large transfers must make progress in bounded chunks and must not freeze key handling, redraw, or window-close processing. Each transfer tracks its descriptor, offset, remaining bytes, and snapshot reference. Close descriptors on success, cancellation, peer failure, and shutdown.
