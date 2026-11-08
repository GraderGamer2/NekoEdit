# Clipboard behavior

## Wayland integration

The Wayland backend uses the core wl_data_device_manager, wl_data_device, wl_data_source, and wl_data_offer interfaces. It has no clipboard-library dependency.

- Ctrl+C copies the selected bytes into a dedicated immutable mmap-backed snapshot and offers text/plain;charset=utf-8 and text/plain.
- Ctrl+X publishes the independent snapshot before deleting the selection. If the source cannot be established, the selected document bytes are retained.
- Ctrl+V prefers UTF-8 plain text, falls back to text/plain, and receives the data asynchronously through a nonblocking pipe.

The snapshot is independent of the document gap buffer and stays valid after the source text is deleted, edited, reallocated, or its document is closed. The active implementation currently has eight reusable source records, four concurrent outgoing-send slots, and a 64 MiB payload/receive ceiling. These are bounded resource/concurrency limits, not a lifetime count of sequential clipboard operations. Completed and retired slots can be reused.

Paste targets the document editor, not file-picker or path fields. Clipboard history is not accumulated: the service retains the current clipboard selection only. Both local paste and asynchronous external paste are committed as one Undo/Redo transaction.

## Persistence after editor exit

The Clipboard Service setting is in Settings and is enabled by default. It is persisted in ~/.nekoedit/preferences as clipboard_persistence=1 (or 0 when disabled). The toggle is evaluated when the editor closes; it does not leave a helper running while the editor is open.

When enabled and NekoEdit owns a clipboard source at window close, NekoEdit forks a very small helper from the same executable. The child inherits the original Wayland connection, clipboard source object, and immutable snapshot. This is important: it does not connect as a second Wayland client and attempt to steal selection ownership, which the core data-device protocol does not authorize without a new valid input serial.

The child changes its Linux process `comm` name to `nekoedit-clip`, drops the editor's pending FD, and runs only the small Wayland/clipboard polling loop needed to answer later wl_data_source.send requests. The main editor process then closes its own Wayland connection and exits normally. A separate PID exists only after the editor closes; it is not expected to appear as a second process while the editor window is open. Because it is the same executable, a process viewer that displays the executable basename or command line may still label it `nekoedit` rather than `nekoedit-clip`. No second executable, daemon manager, D-Bus service, or runtime library is installed.

The helper exits when another client replaces the clipboard selection (after any already-started transfers drain), when the compositor cancels the source, or when the Wayland connection closes. It keeps the most recently copied or cut text available after NekoEdit exits, but not after logout, compositor shutdown, or reboot. It is intentionally not a general-purpose clipboard manager and does not keep old clipboard entries.

Turn Clipboard Service OFF in Settings to skip the handoff on subsequent editor exits. Setting NEKOEDIT_DISABLE_PREFERENCES=1 disables preferences and clipboard persistence, which is useful for isolated tests.

## Limits and interoperability

The text source offers standard UTF-8 plain-text MIME types. As with any Wayland data source, the compositor and receiving clients control when they request the bytes. A compositor that disconnects the client or ends the session terminates the helper. The service does not provide X11 clipboard interoperability; X11 support belongs to the future X11 backend.

See the implementation in src/backend/clipboard.c.


## Regression coverage

The Wayland mock compositor verifies repeated Ctrl+C source replacement, Ctrl+C/X snapshot independence, asynchronous external Ctrl+V, Undo/Redo of the completed asynchronous paste, and the post-exit helper lifecycle: it requests the data only after the editor closes, then replaces the selection and verifies the helper disconnects. GitHub Actions [Build and test #600](https://github.com/GraderGamer2/NekoEdit/actions/runs/42445630695) passed the helper lifecycle test; [#601](https://github.com/GraderGamer2/NekoEdit/actions/runs/42445779246) also passed asynchronous-paste Undo/Redo. The helper is mock-compositor tested; a live GNOME/Mutter clipboard-manager interoperability check remains a separate manual desktop test.
