# Undo and Redo history

## Storage model

src/editor/history.c implements a per-document, disk-backed delta journal. Journals live in ~/.nekoedit and use the .history extension. The filename is a stable hash of the document path string supplied by the editor; the journal also stores and verifies that path identity. A path opened under a different spelling (for example, a different symlink path) has a different journal identity.

The directory is created with mode 0700 when a document identity is opened; **a .history file is not created merely by opening a file**. The journal is created on the first actual byte insertion or deletion, with the pre-edit document as its baseline. Opening, navigating, selecting, copying, or other no-op actions do not leave empty journal files behind. Journal files and exported copies use mode 0600. NekoEdit does not create a central history database or copy the full document for every keystroke.

Each journal contains:

- The document's baseline bytes when the journal was created.
- Grouped edit records containing byte offsets, removed bytes, inserted bytes, and the before/after caret and selection state.
- A current Undo/Redo cursor and the checksum of the last successfully saved document.

A keyboard editing action becomes one record. Replacement of a selection, typing a multi-byte UTF-8 scalar, deletion, and local paste undo as one grouped action. External Wayland paste completes asynchronously, so `insert_text()` explicitly opens and commits a single history transaction when the received bytes are finally inserted. The journal is delta-based: disk growth follows the bytes changed and per-action metadata rather than document size multiplied by undo depth. It has no former 16-entry stack or 32 MiB RAM snapshot ceiling. The file format uses checked 32-bit record lengths and 64-bit file offsets, so it remains bounded by available disk space and addressable journal size rather than being literally infinite.

## Restart recovery and safety

For a named document, NekoEdit records the checksum of the last successful save. On restart, it compares that checksum with the current file before replaying the journal. If they match, it reconstructs the baseline and reapplies committed records up to the saved Undo cursor. If the document was changed outside NekoEdit, it starts a fresh journal from the current file instead of applying stale edits to external content.

An unsaved file launched by its explicit path can also recover while that path still resolves to the same on-disk baseline. An Untitled document receives a per-process identity and its history is not associated with a durable user filename; save the document to a named path to retain a stable history identity across launches.

The journal is synchronously written and checked at each completed editing action. If storage or journal I/O fails, the document edit itself remains applied and NekoEdit reports a history-storage error in the History page; the editor does not silently claim the failed action was recorded. A malformed or truncated tail is ignored when scanning records. The checksum guard prevents a stale journal from replacing a document that changed independently.

A new edit after Undo truncates the abandoned Redo branch. Undo and Redo restore the caret and selection state captured for that action. Opening another document switches to that document's own journal.

## History tab and file management

The History tab beside the document tab includes a built-in path search over document identities stored in existing journals. Results display the original source path rather than the opaque hashed journal filename. Type to filter (ASCII case-insensitively), select a result with the mouse or Up/Down, and press Enter or choose Open Selected to reload that document and its own Undo/Redo state. Up to 64 results are displayed at once; searching narrows the complete set. Documents without journals do not appear, and Untitled per-process identities are excluded because they cannot be reliably reopened by path.

The active document's Undo and Redo counts and controls remain available:

- Undo / Redo: the same journal operations as Ctrl+Z and Ctrl+Y.
- Export: opens NekoEdit's normal file picker and atomically copies the active .history file to the chosen destination. The exported file retains the .history format.
- Delete: removes the active document's journal without changing the document. The next actual byte edit creates a fresh journal for the document.

This makes histories searchable, exportable, and removable without opening the hidden ~/.nekoedit directory. The search uses only validated journal headers; it does not scan document contents.

## Validation

make test includes a host-side journal test covering grouped replacement, branch invalidation, more than 16 edits, save/checksum-based restart recovery, export, delete, and file permissions. The Wayland mock suite separately exercises the editor's keyboard and UI routes.


The Wayland mock additionally verifies the visible History tab (search results, opening a selected document, Undo/Redo buttons, Export picker opening/cancellation, and Delete). It also confirms repeated Ctrl+C leaves no .history file when the editor document has not been modified. The host-side journal test verifies lazy creation, multi-document search, and independent deletion.

## Lazy creation and search validation

The host journal test verifies that opening an unedited file and committing a no-op transaction create no `.history` file, while the first actual insertion/deletion creates exactly one journal. It creates two independent histories, filters their original paths case-insensitively, and verifies deleting one journal removes only that document from the search results. The Wayland mock exercises the History search field, opening a selected source path, and then the active document's Undo/Redo and Export/Delete controls.
