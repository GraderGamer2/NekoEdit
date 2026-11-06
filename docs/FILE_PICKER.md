# Simple directory-browser file picker

NekoEdit will implement its own small file picker (the directory-browser approach). It will not call a desktop portal, D-Bus service, GTK/Qt dialog, or external file manager.

The file picker is a utility for opening and saving a text file, not a general-purpose file manager.

## Interface

Keep the dialog visually quiet and predictable:

```text
+-------------------------------------------------------+
| Open File                                              |
| [ /home/user/Documents___________________________ ]   |
| [Up] [Home]                         [ ] Show hidden    |
|-------------------------------------------------------|
| Folders                                                |
|   <folder>  Notes/                                     |
|   <folder>  Projects/                                  |
|                                                       |
| Files                                                  |
|   file      todo.txt                                   |
|   file      ideas.md                                   |
|   file      config.ini                                 |
|-------------------------------------------------------|
| File name: [______________________________________]    |
|                              [Cancel] [Open]           |
+-------------------------------------------------------+
```

The path field is editable so users can enter or paste a path directly. The listing has two simple groups: directories first, files second. Use compact rows with a name and a small type marker; no thumbnails, previews, metadata columns, or elaborate icons.

## Interaction

- Single-click a file to select it and populate the file-name field.
- Double-click a directory to enter it.
- Double-click a file to open it.
- Enter opens the selected file or enters the selected directory.
- Up moves to the parent directory; Home navigates to the user's home directory.
- The hidden-files toggle controls whether dotfiles are shown; hidden files are initially hidden.
- The Open button opens the selected file. Directories are never opened as documents.
- The Save dialog reuses the same browser and adds a filename field. If the target exists, ask before overwriting it.
- Escape closes the dialog. Keyboard focus and arrow-key navigation must be supported.

Do not add bookmarks, a search index, file previews, tabs, a places sidebar, network discovery, mount management, recursive browsing, or file operations such as rename/delete/create-directory to the initial picker.

## Filesystem implementation

Use Linux syscalls directly:

- `openat` to open the current directory and selected file.
- `getdents64` to enumerate directory entries.
- `newfstatat` (or `statx` only if a future need justifies it) to determine entry type and obtain safe metadata.
- `read`, `write`, and `close` for document content.

Do not rely solely on `d_type`; it can be `DT_UNKNOWN`. Never follow a directory entry by concatenating unchecked user input into a shell command. Paths are handled as byte strings and passed directly to syscalls.

The directory browser should maintain a current directory descriptor and a display path. Navigation should open the target directory before replacing the current descriptor, so a permission error leaves the user in the directory they were already browsing. Be careful with symlinks and path display: the descriptor is authoritative for operations; the displayed path is informational and must not be used as a security boundary.

Sort entries in a deterministic, locale-independent way: directories first, then files, with bytewise filename order within each group. If an entry name is not valid UTF-8, retain its original bytes for filesystem operations and render a safe escaped/replacement representation.

## Error behavior

Show concise messages for permission denied, missing directory, file disappeared, not a regular file, and read/write failure. Do not silently skip a failed Open or Save. The picker must handle empty directories and directories with many entries without blocking the main event loop for a long time; large listings can be read in batches.
