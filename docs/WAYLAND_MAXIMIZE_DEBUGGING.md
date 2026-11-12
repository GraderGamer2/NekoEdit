# Wayland Maximize/resize debugging notes

This document preserves the useful findings and source-history pointers from the GNOME/Mutter Maximize crash investigation without keeping temporary tracing and synchronization probes in the normal runtime.

## Confirmed root cause and retained fix

The failure was caused by invalid Wayland client object IDs, not by the configured buffer dimensions or stride.

The resize path originally used a separate object-ID counter starting at 256. Meanwhile, the Wayland connection had already allocated IDs 2–14 during setup, then IDs 15 and 16 for the pointer and keyboard. A newly created replacement buffer must receive the next available client ID, 17. Using 256 skipped IDs 17–255, and libwayland rejected the wl_shm_pool.create_buffer request while decoding it.

The permanent fix is the shared next_client_object_id allocator in src/backend/wayland.S. It is intentionally retained. Do not restore the old independent resize counter or hard-code high object IDs. Every client-created object must use the next available dense ID. The mock test should continue to verify the pointer/keyboard allocation and the buffer IDs across Maximize, Restore, and further resizes.

The user has manually confirmed that the corrected Maximize action no longer crashes and the window remains usable.

## Why the old diagnostic code existed

The investigation added two temporary mechanisms:

1. A request/event trace printed the failed request object/opcode/errno, the last completely written request, and the last received event. This helped distinguish a failed wl_surface.attach send from the earlier compositor-side rejection that actually triggered the disconnect.
2. A one-shot wl_display.sync barrier after the first replacement wl_buffer creation waited for the compositor's callback before sending wl_surface.attach. That made a compositor wl_display.error for the preceding wl_shm_pool.create_buffer visible before a later attach could obscure the sequence. It was an investigative probe, not a required part of normal resize behavior.

Both temporary runtime mechanisms have been removed. The current code still uses MSG_NOSIGNAL for ordinary Wayland sends and FD-bearing sendmsg requests. Keep that behavior: it turns a closed-socket send into a normal error return instead of a process-ending SIGPIPE. The concise protocol failure message, setup-stage reporting, and compositor-provided wl_display.error message are also retained.

## Reopening the investigation if the failure returns

Start with the current source and the mock regression rather than reintroducing every historical patch:

- Inspect the dense allocator and resize path in src/backend/wayland.S, especially next_client_object_id, handle_seat_capabilities, and window_apply_pending_resize.
- Inspect the Maximize/Restore/edge-resize sequence in tests/wayland_mock.py. Keep the assertions for dense client IDs and buffer-release ordering.
- Review the historical change that added the one-shot barrier: commit a0d226f3207b50b26c530fd213dc6a6eb52658ae. Later commits refined it and its test: 054deba34a0e6c4aaeb537723275ddcc3d458a7b, 268bc234753baa254763a49b2a19d66cd008bf53, 532de03974493c712b02dc7aae74125ffb65d1e8, and 7dca6ccfe92c092bf30eb29854496998eb5b63f4.
- Review the request/event tracking history starting at 10df996a0b51de4b36287d4e78180b52dfd5c4ec and 41b819eae69db66c9f61f0f313027cf056965418. The bounded-output fixes are 5765d1dc7dc0d1cd2f6c928b91363d0b5aa2988c and c2a9f0d08597ed3f2d0a8a4d7ba97b62bf38af45.
- Use git show <commit> to inspect the relevant historical patch. Do not blindly cherry-pick a whole diagnostic commit: it predates the dense-ID fix and may restore the incorrect sparse allocator or add unnecessary changes.
- If a sync barrier is temporarily reintroduced, allocate its callback ID from the current next_client_object_id counter, never from a fixed value or a separate range. Keep it behind a focused test and remove it again once the failure is understood.

Build and run make test and make test-wayland, then verify the exact new binary on GNOME/Mutter. The mock compositor is useful for protocol sequencing, but it cannot substitute for a real desktop retest.

## Historical context

- Root-cause fix: 2273306b519d2787d387d2013e7f32a416ff3a4b — use one dense client-object allocator.
- Diagnostic sync barrier: a0d226f3207b50b26c530fd213dc6a6eb52658ae — temporary ordering probe, now removed.
- Request/event trace: 10df996a0b51de4b36287d4e78180b52dfd5c4ec and 41b819eae69db66c9f61f0f313027cf056965418 — historical diagnostics, now removed from normal execution.
