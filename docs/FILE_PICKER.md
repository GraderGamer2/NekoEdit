# Native directory-browser file picker

NekoEdit implements its own small file picker inside the Wayland window. It does not call a desktop portal, D-Bus service, GTK/Qt dialog, or external file manager.

The picker is an Open/Save utility for text documents, not a general-purpose file manager. Its implementation remains freestanding GNU assembly using direct Linux syscalls.

## Interface

The dialog contains:
- An editable location field with a text cursor and horizontal follow behavior.
- Up and Home navigation controls.
- A real Show hidden checkbox; both the checkbox and label toggle it. New picker sessions start with hidden files disabled.
- A directory-first, then regular-file listing with a proportional scrollbar. The list supports vertical mouse-wheel scrolling, scrollbar track clicks, and thumb dragging.
- In Open mode, an editable **Search** field that performs case-insensitive filename-prefix matching against regular files in the current directory listing.
- In Save mode, an editable **File name** field, plus Cancel and Save actions.
- An overwrite confirmation prompt for an existing regular-file target.

Keep the dialog visually quiet and predictable. Rows use a compact type marker and filename; there are no thumbnails, previews, metadata columns, or elaborate icons.

## Interaction

### Directory listing

- Single-click a file to select it and populate the filename/search field.
- Double-click a directory to enter it.
- Double-click a regular file to open it in Open mode.
- Enter opens the selected/matched file, or enters the selected directory when list focus is active.
- Up moves to the parent directory; Home navigates to the user's home directory.
- The Show hidden checkbox controls whether dotfiles are listed. The setting resets to unchecked when a new picker session starts.
- The list scrolls vertically using `wl_pointer.axis`. A visible proportional scrollbar can be dragged or track-clicked.
- The current implementation holds at most 128 directory entries and displays 15 rows at a time. It is not an incremental large-directory browser.

### Location and filename fields

- Clicking inside a text field positions its caret at the nearest visible character.
- Left/Right moves the caret. Home/End moves it to the start/end of the field.
- Printable ASCII keys insert at the caret. Backspace and Delete remove the byte before/at the caret.
- Ctrl+A selects the entire focused field; typing replaces the full field contents.
- The visible text follows the caret horizontally when the field is longer than its viewport.
- Pressing Enter in the location field attempts to open that directory and, on success, returns focus to the listing.
- In Open mode, the Search field selects the first regular file in the current listing whose name begins with the typed prefix (ASCII case-insensitive). A query with no match clears the selected row; Open does not silently reuse a previous selection.
- Search text is scoped to the current directory listing and is cleared when navigation or a Show hidden rescan rebuilds that listing. When the directory list has focus, Open accepts only the explicitly selected regular-file row; it never treats leftover search text as a fallback filename. A complete literal path/name with no prefix match can be opened only while the Search field itself has focus.
- The listing includes every regular file regardless of extension or executable permission. A file with its execute bit set is still handled as plain document bytes; the picker does not execute files.
- In Save mode, the File name field accepts a relative filename or an absolute path and uses the existing overwrite-confirmation flow.

Clipboard paste, Shift-based partial field selection, and non-ASCII typed filename/path input are not implemented yet. These require separate work; the picker does not introduce a clipboard library or text-input runtime dependency.

## Scope boundaries

Do not add bookmarks, recursive browsing, network discovery, mount management, file previews, rename/delete/create-directory actions, or a separate file manager.

Search is a prefix match over the current in-memory listing, not a recursive search index or fuzzy search. The directory list is capped at 128 entries. The picker currently does not follow symbolic links and does not prompt before discarding unsaved document edits.

## Filesystem implementation

Use Linux syscalls directly:

- `openat` to open the current directory and selected file.
- `getdents64` to enumerate directory entries.
- `newfstatat` (or `statx` only if a future need justifies it) to determine entry type and obtain metadata.
- `read`, `write`, and `close` for document content.

Do not rely solely on `d_type`; it can be `DT_UNKNOWN`. Never follow a directory entry by concatenating unchecked user input into a shell command. Paths are handled as byte strings and passed directly to syscalls.

The directory browser maintains a current directory descriptor and a display path. Navigation should open the target directory before replacing the current descriptor, so a permission error leaves the user in the directory they were already browsing. The descriptor is authoritative for operations; the displayed path is informational and must not be used as a security boundary.

Entries are sorted deterministically and locale-independently: directories first, then files, with bytewise filename order within each group. Filename bytes are retained for filesystem operations; names that cannot be rendered as printable ASCII use a safe replacement glyph in the UI.

## Error behavior

Show concise messages for permission denied, missing directory, file disappeared, not a regular file, and read/write failure. Do not silently skip a failed Open or Save. Empty directories and zero-byte files are valid inputs; Open must activate the exact selected path and produce a zero-length document for an empty file.
