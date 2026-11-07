# Wayland interactive window resizing

NekoEdit uses compositor-driven interactive resizing. It does not resize the application surface locally in response to mouse motion.

## Starting a resize

When a primary-button press lands in the resize hit band, NekoEdit sends `xdg_toplevel.resize` with:

- the bound `wl_seat` object;
- the serial from the current `wl_pointer.button` press event;
- the `xdg_toplevel.resize_edge` bitmask for the selected side or corner.

The request must be associated with a user action and its serial. The compositor then owns the interactive drag, sends new xdg configure events, and determines the resulting window position and size. NekoEdit acknowledges configure events and replaces the shared-memory buffer only after the previous buffer is released. A compositor may ignore a resize request while the window is maximized or fullscreen.

Protocol reference: [xdg-shell — xdg_toplevel.resize](https://wayland.app/protocols/xdg-shell).

## Pointer focus during startup

A pointer can enter the surface after NekoEdit creates `wl_pointer` but before its initial seat roundtrip callback arrives. That event is valid even though the normal event loop has not started.

The startup roundtrip must therefore dispatch pointer enter, leave, and motion events rather than discarding them. In particular, retain:

- `pointer_inside`, so button presses are not rejected as outside the surface;
- surface-local pointer coordinates, for edge/corner hit-testing;
- the serial from the latest `wl_pointer.enter`, for cursor-shape requests.

The normal event loop uses the same capture helpers. A leave clears pointer focus; a later enter refreshes both coordinates and the enter serial.

## Hit areas and cursor feedback

The resize hit band is 16 logical surface units on each edge. Corner hits combine the corresponding horizontal and vertical edge bits. The top-edge hit band preserves the app-drawn File menu and window-control slots; the outermost top-right corner remains resizable. The same edge-calculation routine is used for both the button press and hover feedback, so the indicated resize direction matches the request that will be sent.

When the compositor advertises the optional `wp_cursor_shape_manager_v1` extension, NekoEdit obtains a cursor-shape device with `get_pointer`. That request carries two arguments in order: the newly allocated `wp_cursor_shape_device_v1` object ID, followed by the existing `wl_pointer` object ID. NekoEdit then requests horizontal, vertical, and diagonal resize cursors. The extension is only a visual affordance: resizing still uses `xdg_toplevel.resize`. Its `set_shape` request must use the serial from the latest pointer-enter event, not the button-press serial or motion timestamp.

Protocol reference: [cursor-shape-v1](https://wayland.app/protocols/cursor-shape-v1), especially `get_pointer`, `set_shape`, and the resize shape enum.

If the compositor does not advertise the cursor-shape extension, NekoEdit skips the hover-cursor requests but keeps the same pointer hit-testing and `xdg_toplevel.resize` behavior.

## Responsive layout geometry

The renderer recalculates layout geometry whenever a compositor configure changes the surface size.

- The status/footer row follows the lower edge at `window_height - 20`. The byte-count and mode labels use width-derived horizontal anchors rather than the original 800-pixel positions.
- The document view uses the configured width for wrapping and the configured height for its visible-row count. Cursor visibility and selection/document rendering use those current row and column bounds.
- The file picker keeps its 720×408 design size when it fits; otherwise it is centered and scaled to the available surface with a 16-pixel margin. The path prompt follows the same rule using its 704×176 design size.
- Rectangle and glyph origins are transformed through the same modal coordinate mapping. Pointer hit-testing and picker scrollbar dragging apply the inverse mapping, so the visible controls and their interactive regions stay aligned.

The responsive layout is exercised at 1920×1080 (Maximize), 800×480 (Restore), 720×480 (interactive resize), and the declared 480×360 minimum. The mock checks footer pixels, fitted modal geometry, the Cancel button's drawn position, and its actual click target at resized widths.

## Regression coverage

`tests/wayland_mock.py` verifies the exact eight-byte `get_pointer` payload (new device ID followed by the existing `wl_pointer` ID), startup pointer-enter ordering, button-press serial and edge mask, all four edges and four corners, cursor-shape mapping and refreshed enter serials, plus the no-extension fallback. The mock verifies protocol sequencing; a real GNOME/Mutter session is still required to confirm the interactive drag behavior end to end.
