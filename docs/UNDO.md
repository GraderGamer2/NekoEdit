# Undo and Redo history

## Current implementation

The current implementation is in `src/editor/history.c`. It stores complete document snapshots, including the document bytes, caret, selection anchor, selection-active state, and revision.

Current hard limits:

- `SNAPSHOT_LIMIT`: 4 MiB for an individual full-document snapshot.
- `HISTORY_BUDGET`: 32 MiB of mapped snapshot memory across the baseline, Undo stack, and Redo stack.
- `HISTORY_DEPTH`: 16 entries per stack.
- A new edit after Undo clears the Redo branch.

These limits are independent: the aggregate memory budget may evict older entries before a stack reaches its depth limit. More importantly, when a new snapshot cannot be captured (including when the document exceeds the 4 MiB snapshot ceiling or memory cannot be allocated), `history_checkpoint()` clears the existing history. This means the current implementation is deliberately bounded and can lose all undo history when it can no longer capture the next full document snapshot.

## User-requested goal

The user wants Undo and Redo to be effectively unlimited for ordinary editing, rather than being restricted to 16 operations or a 32 MiB snapshot budget.

This means there should be no arbitrary lifetime operation-count ceiling. It does not mean the history can consume infinite RAM or disk. A practical implementation must account for the finite storage available and must report a storage-limit condition instead of silently presenting a truncated history as unlimited.

## Recommended design for review

Replace repeated full-document snapshots with an append-only edit journal or equivalent delta-based history.

A journal record should capture enough information to reverse and replay an edit:

- Logical document byte offset.
- Removed bytes and inserted bytes (or a safely encoded reference to their payloads).
- Pre-edit and post-edit caret positions.
- Pre-edit and post-edit selection anchor/active state.
- An operation/group identifier and record length/version for validation.

Undo applies the inverse delta; Redo reapplies the forward delta. Consecutive typing, deletion, and navigation boundaries should be grouped into sensible user-visible undo units. Paste and cut should each be reversible as one operation, including large selections. All offsets and payload lengths must be checked against the document's UTF-8 and storage invariants.

A disk-backed journal is the preferred direction for long histories:

- Keep only a small active window/index of journal metadata in RAM.
- Append change payloads to bounded sequential storage rather than copying the entire document for every keystroke.
- Use periodic recovery checkpoints if needed to avoid replaying the entire edit log after a crash or when opening a saved session.
- Preserve the current rule that a new edit after Undo invalidates the Redo branch.
- Define explicit cleanup, corruption detection, and disk-space handling. When storage is exhausted, do not corrupt the document or silently discard history; report the limit and define whether new edits continue without history or are blocked.
- Avoid a large RAM-only snapshot stack. A delta history should scale mainly with the bytes changed, plus metadata, rather than document size multiplied by operation count.

## Persistence scope not yet decided

The user explicitly requested unlimited Undo/Redo, but has not specified whether Undo history must survive closing and reopening NekoEdit. Treat these as separate requirements:

1. **Long-lived session history:** retain history without a fixed operation-count limit while NekoEdit is running.
2. **Restart-persistent history:** restore Undo/Redo after process exit and application restart, which requires a durable journal, document identity/version checks, recovery rules, and storage cleanup.

Do not assume restart-persistent history is required until the user confirms it. No implementation changes are authorized by this design note.

## Required tests before implementation is considered complete

- More than 16 sequential undoable edits and matching Redo operations.
- Long typing/deletion runs with grouping boundaries.
- Copy-independent paste, cut, and large paste undo/redo.
- Undo/Redo with non-ASCII UTF-8, multi-byte scalars, grapheme clusters, and selections.
- New edit after Undo clears only the Redo branch.
- Journal growth across many edits without a fixed operation-count cap.
- Memory remains bounded as history grows; payload data is stored in the intended journal backing.
- Disk full, allocation failure, truncated/corrupt journal, and recovery behavior.
- If restart persistence is later selected: clean close/reopen and crash-recovery cases.
- File Open/new-document transitions cannot apply history to the wrong document.

