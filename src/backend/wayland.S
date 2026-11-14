.intel_syntax noprefix

.equ SYS_read,          0
.equ SYS_write,         1
.equ SYS_close,         3
.equ SYS_fchmod,        91
.equ SYS_lseek,          8
.equ SYS_getcwd,        79
.equ SYS_getdents64,   217
.equ SYS_newfstatat,   262
.equ SYS_openat,      257
.equ SYS_poll,          7
.equ SYS_timerfd_create, 283
.equ SYS_timerfd_settime, 286
.equ SYS_socket,       41
.equ SYS_connect,      42
.equ SYS_sendmsg,      46
.equ SYS_sendto,       44
.equ MSG_NOSIGNAL, 0x4000
.equ SYS_recvmsg,      47
.equ SYS_munmap,       11
.equ SYS_mremap,       25
.equ SYS_ftruncate,    77
.equ SYS_mmap,          9
.equ SYS_memfd_create, 319
.equ AF_UNIX,            1
.equ SOCK_STREAM,       1
.equ SOCK_CLOEXEC, 0x80000
.equ PROT_READ,          1
.equ PROT_WRITE,         2
.equ MAP_SHARED,         1
.equ MAP_PRIVATE,        2
.equ MAP_ANONYMOUS,   0x20
.equ MREMAP_MAYMOVE,     1
.equ MFD_CLOEXEC,        1
.equ AT_FDCWD,          -100
.equ O_WRONLY,             1
.equ O_CREAT,             64
.equ O_CLOEXEC,       0x80000
.equ O_DIRECTORY,    0x10000
.equ AT_SYMLINK_NOFOLLOW, 0x100
.equ STAT_S_IFMT,     0xf000
.equ STAT_S_IFDIR,    0x4000
.equ STAT_S_IFREG,    0x8000
.equ SYS_fsync,         74
.equ SYS_getpid,        39
.equ SYS_renameat,     264
.equ SYS_unlinkat,     263
.equ O_EXCL,           128
.equ SOL_SOCKET,         1
.equ SCM_RIGHTS,         1
.equ MSG_CMSG_CLOEXEC, 0x40000000
.equ MSG_CTRUNC,          8
.equ XKB_KEYMAP_MAX_SIZE, 1048576
.equ WIDTH,            800
.equ HEIGHT,           480
.equ STRIDE,           (WIDTH * 4)
.equ BUFFER_SIZE,      (STRIDE * HEIGHT)
.equ MAX_WINDOW_WIDTH, 3840
.equ MAX_WINDOW_HEIGHT, 2160
.equ MAX_BUFFER_SCALE, 2
.equ SHM_BUFFER_CAPACITY, (MAX_WINDOW_WIDTH * MAX_WINDOW_HEIGHT * 4)
.equ SHM_POOL_CAPACITY, (SHM_BUFFER_CAPACITY * 2)
.equ WINDOW_MIN_WIDTH, 480
.equ WINDOW_MIN_HEIGHT, 360
.equ WINDOW_RESIZE_BORDER, 16
.equ CURSOR_SHAPE_DEFAULT,  1
.equ CURSOR_SHAPE_EW_RESIZE, 26
.equ CURSOR_SHAPE_NS_RESIZE, 27
.equ CURSOR_SHAPE_NESW_RESIZE, 28
.equ CURSOR_SHAPE_NWSE_RESIZE, 29
.equ BTN_LEFT,          0x110
.equ BTN_RIGHT,         0x111
.equ CONTEXT_MENU_WIDTH, 128
.equ CONTEXT_MENU_HEIGHT, 78
.equ CONTEXT_MENU_ROW_HEIGHT, 26
.equ CLOCK_MONOTONIC,      1
.equ TFD_CLOEXEC,     0x80000
.equ POLLIN,              1
.equ REPEAT_DEFAULT_DELAY_MS, 300
.equ REPEAT_DEFAULT_RATE, 30
.equ REPEAT_NS_PER_SECOND, 1000000000
.equ REPEAT_MAX_RATE, 1000
.equ DOC_INITIAL_CAPACITY, 65536
.equ DOC_MAX_CAPACITY, 0x40000000
.equ DOC_INDEX_INITIAL_LINES, 256
.equ DOC_INDEX_MAX_LINES, 0x01000000
.equ DOC_INDEX_RECORD_SIZE, 16
.equ DOC_INDEX_BYTES_OFFSET, 0
.equ DOC_INDEX_ROWS_OFFSET, 4
.equ DOC_INDEX_BYTE_TREE_OFFSET, 8
.equ DOC_INDEX_ROW_TREE_OFFSET, 12
.equ PATH_CAPACITY,    4096
.equ PICKER_MAX_ENTRIES, 128
.equ PICKER_ENTRY_SIZE, 260
.equ PICKER_ROW_HEIGHT, 16
.equ PICKER_DIR_BYTES, 8192
.equ PICKER_VISIBLE_ROWS, 13
.equ PICKER_SUGGESTION_MAX, 5
.equ PICKER_SUGGESTION_TOP, 264
.equ PICKER_SUGGESTION_ROW_HEIGHT, 16
.equ PICKER_SUGGESTION_BOTTOM, 348
.equ PICKER_PATH_VISIBLE_CHARS, 82
.equ PICKER_NAME_VISIBLE_CHARS, 52
.equ PICKER_TRACK_TOP, 144
.equ PICKER_TRACK_HEIGHT, 208
.equ PICKER_TRACK_X, 724
.equ PICKER_TRACK_WIDTH, 12
.equ PICKER_TRACK_MIN_THUMB, 18
.equ PICKER_WHEEL_ROW_FIXED, (16 * 256)
.equ DOC_SCROLL_TRACK_WIDTH, 6
.equ DOC_SCROLL_TRACK_X_OFFSET, 24
.equ DOC_SCROLL_MIN_THUMB, 20
.equ DOC_HSCROLL_HEIGHT, 14
.equ DOC_HSCROLL_TRACK_HEIGHT, 6
.equ DOC_HSCROLL_MIN_THUMB, 24
.equ DOC_SCROLL_WHEEL_ROW_FIXED, (14 * 256)
.equ DOC_DRAG_SCROLL_TICK_NS, 50000000
.equ DOC_DRAG_SCROLL_INITIAL_NS, 120000000
.equ DOC_DRAG_SCROLL_MAX_STEPS, 8
.equ DOC_DRAG_SCROLL_ROW_PIXELS, 24
.equ DOC_DRAG_SCROLL_COLUMN_PIXELS, 32
.equ DOC_LEFT,           16
.equ DOC_TOP,            92
.equ STATUS_TOP,         460
.equ LINE_HEIGHT,        12

.section .rodata
wayland_socket_env_key: .asciz "WAYLAND_SOCKET"
wayland_env_key:       .asciz "WAYLAND_DISPLAY"
xdg_runtime_env_key:   .asciz "XDG_RUNTIME_DIR"
default_wayland_name:  .asciz "wayland-0"
ui_app_name:           .asciz "NekoEdit"
ui_mode_error:         .asciz "SAVE ERR"
ui_storage_error:      .asciz "MEM ERR"
msg_document_storage:  .ascii "NekoEdit: unable to allocate document storage\n"
msg_document_storage_end:
ui_document_name:      .asciz "Untitled"
ui_mode_name:          .asciz "ASCII"
ui_file_label:         .asciz "File"
ui_settings_label:     .asciz "Settings"
ui_menu_open_label:    .asciz "Open"
ui_menu_save_label:    .asciz "Save"
ui_menu_save_as_label: .asciz "Save As"
ui_context_menu_copy_label: .asciz "Copy"
ui_context_menu_paste_label: .asciz "Paste"
ui_context_menu_cut_label: .asciz "Cut"
ui_menu_confirm_save_label: .asciz "Confirm before saving"
ui_menu_state_on:      .asciz "ON"
ui_menu_state_off:     .asciz "OFF"
ui_menu_font_size_label: .asciz "FONT SIZE"
ui_menu_ui_font_size_label: .asciz "UI FONT"
ui_menu_wrap_lines_label: .asciz "WRAP LINES"
ui_menu_clipboard_label: .asciz "CLIPBOARD SERVICE"
ui_menu_compose_locale_label: .asciz "COMPOSE LOCALE"
ui_menu_locale_en: .asciz "en_US"
ui_menu_locale_ptbr: .asciz "pt_BR"
ui_menu_locale_select: .asciz "LOCALE"
ui_menu_locale_builtin: .asciz "en_US (built-in)"
ui_menu_locale_base: .asciz "BASE"
ui_menu_locale_missing: .asciz "MISSING"
ui_menu_locale_active: .asciz "ACTIVE"
ui_menu_locale_add: .asciz "ADD"
ui_menu_locale_remove: .asciz "REMOVE"
ui_menu_locale_import: .asciz "IMPORT"
ui_menu_locale_error: .asciz "ERROR"
ui_locale_en_tag: .asciz "en_US.UTF-8"
ui_locale_ptbr_tag: .asciz "pt_BR.UTF-8"
ui_history_label: .asciz "History"
ui_history_title: .asciz "DOCUMENT HISTORY"
ui_history_undo_label: .asciz "UNDO"
ui_history_redo_label: .asciz "REDO"
ui_history_export_label: .asciz "EXPORT"
ui_history_delete_label: .asciz "DELETE"
ui_history_browse_label: .asciz "BROWSE"
ui_history_undo_count_label: .asciz "UNDO RECORDS"
ui_history_redo_count_label: .asciz "REDO RECORDS"
ui_history_storage_error: .asciz "JOURNAL STORAGE ERROR"
ui_history_search_label: .asciz "SEARCH DOCUMENTS"
ui_history_results_label: .asciz "MATCHING HISTORIES"
ui_history_no_results_label: .asciz "NO MATCHING HISTORIES"
ui_history_open_label: .asciz "OPEN SELECTED"
ui_history_open_error_label: .asciz "COULD NOT OPEN THIS DOCUMENT"
ui_history_message: .asciz "Stored in ~/.nekoedit as a .history file."
ui_menu_font_file_label: .asciz "FONT FILE"
ui_menu_select_label:   .asciz "SELECT"
ui_menu_minus_label:   .asciz "-"
ui_menu_plus_label:    .asciz "+"
ui_menu_px_label:      .asciz "px"
iface_data_device_manager: .asciz "wl_data_device_manager"
ui_save_confirm_title: .asciz "CONFIRM SAVE"
ui_save_confirm_message: .asciz "SAVE THIS DOCUMENT?"
ui_save_confirm_save_label: .asciz "SAVE"
ui_save_confirm_cancel_label: .asciz "CANCEL"
ui_locale_remove_title: .asciz "REMOVE COMPOSE PACK"
ui_locale_remove_message: .asciz "REMOVE THE SELECTED COMPOSE PACK?"
ui_locale_remove_label: .asciz "REMOVE"
ui_prompt_open_title:  .asciz "OPEN FILE PATH"
ui_prompt_save_title:  .asciz "SAVE AS PATH"
ui_prompt_help:        .asciz "ENTER: CONFIRM   ESC: CANCEL"
ui_open_error:         .asciz "OPEN ERR"
ui_picker_open_title:  .asciz "OPEN FILE"
ui_picker_save_title:  .asciz "SAVE FILE AS"
ui_picker_font_title:  .asciz "SELECT TRUE TYPE FONT"
ui_picker_install_title: .asciz "INSTALL COMPOSE PACK"
ui_picker_import_xcompose_title: .asciz "IMPORT XCOMPOSE"
ui_picker_select_locale_title: .asciz "SELECT COMPOSE LOCALE"
ui_picker_path_label:  .asciz "LOCATION"
ui_picker_source_label: .asciz "SOURCE"
ui_picker_install_target_label: .asciz "TARGET: ~/.nekoedit/locales/"
ui_picker_name_label:  .asciz "FILE NAME"
ui_picker_search_label: .asciz "SEARCH"
ui_picker_up_label:   .asciz "UP"
ui_picker_home_label: .asciz "HOME"
ui_picker_hidden_label: .asciz "SHOW HIDDEN"
ui_picker_check_mark: .asciz "x"
ui_picker_cancel_label: .asciz "CANCEL"
ui_picker_open_label: .asciz "OPEN"
ui_picker_load_label: .asciz "LOAD"
ui_picker_save_label: .asciz "SAVE"
ui_picker_install_label: .asciz "INSTALL"
ui_picker_import_label: .asciz "IMPORT"
ui_picker_select_locale_label: .asciz "SELECT"
ui_picker_dir_marker: .asciz "[D]"
ui_picker_file_marker: .asciz "[F]"
ui_picker_empty: .asciz "(EMPTY DIRECTORY)"
ui_picker_truncated: .asciz "LIST LIMITED TO FIRST 128 ENTRIES"
ui_picker_error_path: .asciz "CANNOT OPEN DIRECTORY"
ui_picker_error_file: .asciz "CANNOT OPEN FILE"
ui_picker_error_save: .asciz "SAVE FAILED"
ui_picker_error_font: .asciz "INVALID FONT FILE"
ui_picker_error_locale: .asciz "INVALID COMPOSE PACK"
ui_picker_error_xcompose: .asciz "XCOMPOSE IMPORT FAILED"
ui_picker_overwrite: .asciz "FILE EXISTS - OVERWRITE?  Y / N"
ui_picker_home_env: .asciz "HOME"
ui_picker_dot: .asciz "."
ui_picker_parent: .asciz ".."
ui_label_line:         .asciz "Ln "
ui_label_column:       .asciz ", Col "
ui_label_bytes:        .asciz "Bytes "
wayland_title:         .asciz "NekoEdit - development window"
memfd_label:           .asciz "nekoedit-shm"
xkb_keymap_magic:      .ascii "xkb_keymap"
iface_compositor:      .asciz "wl_compositor"
iface_shm:             .asciz "wl_shm"
iface_xdg_wm_base:     .asciz "xdg_wm_base"
iface_seat:            .asciz "wl_seat"
iface_output:          .asciz "wl_output"
iface_cursor_shape:   .asciz "wp_cursor_shape_manager_v1"
iface_text_input_manager_v3: .asciz "zwp_text_input_manager_v3"
iface_fractional_scale_manager: .asciz "wp_fractional_scale_manager_v1"
iface_viewporter: .asciz "wp_viewporter"
keymap_base:
    .byte 0, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 0, 0
    .byte 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 0, 0, 97, 115
    .byte 100, 102, 103, 104, 106, 107, 108, 59, 39, 96, 0, 92, 122, 120, 99, 118
    .byte 98, 110, 109, 44, 46, 47, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
keymap_shift:
    .byte 0, 0, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 123, 125, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 58, 34, 126, 0, 124, 0, 0, 0, 0
    .byte 0, 0, 0, 60, 62, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
msg_no_env:            .ascii "NekoEdit: XDG_RUNTIME_DIR is not set; cannot locate the Wayland socket.\n"
msg_no_env_end:
msg_connect:           .ascii "NekoEdit: could not connect to the Wayland display using WAYLAND_SOCKET or its socket path.\n"
msg_connect_end:
msg_file_error:        .ascii "NekoEdit: could not open file or file exceeds the 64 KiB document limit.\n"
msg_file_error_end:
msg_globals:           .ascii "NekoEdit: compositor, wl_shm, or xdg_wm_base is unavailable.\n"
msg_globals_end:
msg_protocol:          .ascii "NekoEdit: Wayland protocol or shared-memory setup failed.\n"
msg_protocol_end:
newline_text:            .ascii "\n"
msg_protocol_error_prefix: .ascii "NekoEdit: Wayland compositor protocol error: "
msg_protocol_error_prefix_end:
stage_registry:       .asciz "Wayland stage: registry discovery"
stage_registry_read:  .asciz "Wayland stage: registry roundtrip"
stage_bind:           .asciz "Wayland stage: bind globals"
stage_bind_roundtrip: .asciz "Wayland stage: bind roundtrip"
stage_xdg_create:     .asciz "Wayland stage: create xdg window"
stage_xdg_configure:  .asciz "Wayland stage: wait for xdg configure"
stage_memfd:          .asciz "Wayland stage: allocate shared memory"
stage_pool:           .asciz "Wayland stage: send shm pool"
stage_buffer:         .asciz "Wayland stage: create wl_buffer"
stage_attach:         .asciz "Wayland stage: attach and commit"
stage_event_loop:     .asciz "Wayland stage: event loop"

.section .rodata
.balign 1
font_5x7:
    .byte 14, 17, 17, 31, 17, 17, 17
    .byte 30, 17, 17, 30, 17, 17, 30
    .byte 15, 16, 16, 16, 16, 16, 15
    .byte 30, 17, 17, 17, 17, 17, 30
    .byte 31, 16, 16, 30, 16, 16, 31
    .byte 31, 16, 16, 30, 16, 16, 16
    .byte 15, 16, 16, 23, 17, 17, 15
    .byte 17, 17, 17, 31, 17, 17, 17
    .byte 14, 4, 4, 4, 4, 4, 14
    .byte 7, 2, 2, 2, 18, 18, 12
    .byte 17, 18, 20, 24, 20, 18, 17
    .byte 16, 16, 16, 16, 16, 16, 31
    .byte 17, 27, 21, 21, 17, 17, 17
    .byte 17, 25, 21, 19, 17, 17, 17
    .byte 14, 17, 17, 17, 17, 17, 14
    .byte 30, 17, 17, 30, 16, 16, 16
    .byte 14, 17, 17, 17, 21, 18, 13
    .byte 30, 17, 17, 30, 20, 18, 17
    .byte 15, 16, 16, 14, 1, 1, 30
    .byte 31, 4, 4, 4, 4, 4, 4
    .byte 17, 17, 17, 17, 17, 17, 14
    .byte 17, 17, 17, 17, 17, 10, 4
    .byte 17, 17, 17, 21, 21, 21, 10
    .byte 17, 17, 10, 4, 10, 17, 17
    .byte 17, 17, 10, 4, 4, 4, 4
    .byte 31, 1, 2, 4, 8, 16, 31
    .byte 14, 17, 19, 21, 25, 17, 14
    .byte 4, 12, 4, 4, 4, 4, 14
    .byte 14, 17, 1, 2, 4, 8, 31
    .byte 30, 1, 1, 14, 1, 1, 30
    .byte 2, 6, 10, 18, 31, 2, 2
    .byte 31, 16, 16, 30, 1, 1, 30
    .byte 14, 16, 16, 30, 17, 17, 14
    .byte 31, 1, 2, 4, 8, 8, 8
    .byte 14, 17, 17, 14, 17, 17, 14
    .byte 14, 17, 17, 15, 1, 1, 14
    .byte 14, 17, 1, 2, 4, 0, 4
    .byte 0, 0, 0, 0, 0, 12, 12
    .byte 0, 0, 0, 0, 12, 12, 8
    .byte 0, 0, 12, 12, 0, 12, 12
    .byte 0, 0, 0, 31, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 31
    .byte 4, 4, 4, 4, 4, 0, 4
    .byte 10, 10, 0, 0, 0, 0, 0
    .byte 4, 4, 8, 0, 0, 0, 0
    .byte 2, 4, 8, 8, 8, 4, 2
    .byte 8, 4, 2, 2, 2, 4, 8
    .byte 0, 4, 4, 31, 4, 4, 0
    .byte 0, 0, 31, 0, 31, 0, 0
    .byte 1, 2, 2, 4, 8, 8, 16

    # Additional printable-ASCII punctuation glyphs (indices 50 through 67).
    .byte 10, 10, 31, 10, 31, 10, 10       # #
    .byte 4, 15, 20, 14, 5, 30, 4          # $
    .byte 24, 25, 1, 2, 4, 19, 3           # %
    .byte 12, 18, 20, 8, 21, 18, 13        # &
    .byte 0, 21, 14, 31, 14, 21, 0         # *
    .byte 0, 12, 12, 0, 12, 12, 8          # ;
    .byte 2, 4, 8, 16, 8, 4, 2            # <
    .byte 8, 4, 2, 1, 2, 4, 8              # >
    .byte 14, 17, 23, 21, 23, 16, 14       # @
    .byte 14, 8, 8, 8, 8, 8, 14            # [
    .byte 16, 8, 8, 4, 2, 2, 1             # backslash
    .byte 14, 2, 2, 2, 2, 2, 14            # ]
    .byte 4, 10, 17, 0, 0, 0, 0            # ^
    .byte 8, 4, 2, 0, 0, 0, 0              # grave accent
    .byte 3, 4, 4, 8, 4, 4, 3              # {
    .byte 4, 4, 4, 4, 4, 4, 4              # |
    .byte 24, 4, 4, 2, 4, 4, 24            # }
    .byte 0, 0, 9, 22, 0, 0, 0             # ~


.section .rodata
# Unicode 18.0.0 extended grapheme-cluster property tables.
# Generated from the Unicode Character Database 18.0.0:
# GraphemeBreakProperty.txt, DerivedCoreProperties.txt and emoji-data.txt.
# Hangul LV/LVT syllables are classified arithmetically in doc_grapheme_property.
# Grapheme_Cluster_Break ranges.
.balign 4
unicode_gcb_ranges:
    .long 0x0, 0x9, 3
    .long 0xA, 0xA, 2
    .long 0xB, 0xC, 3
    .long 0xD, 0xD, 1
    .long 0xE, 0x1F, 3
    .long 0x7F, 0x9F, 3
    .long 0xAD, 0xAD, 3
    .long 0x300, 0x36F, 4
    .long 0x483, 0x487, 4
    .long 0x488, 0x489, 4
    .long 0x591, 0x5BD, 4
    .long 0x5BF, 0x5BF, 4
    .long 0x5C1, 0x5C2, 4
    .long 0x5C4, 0x5C5, 4
    .long 0x5C7, 0x5C9, 4
    .long 0x600, 0x605, 7
    .long 0x610, 0x61A, 4
    .long 0x61C, 0x61C, 3
    .long 0x64B, 0x65F, 4
    .long 0x670, 0x670, 4
    .long 0x6D6, 0x6DC, 4
    .long 0x6DD, 0x6DD, 7
    .long 0x6DF, 0x6E4, 4
    .long 0x6E7, 0x6E8, 4
    .long 0x6EA, 0x6ED, 4
    .long 0x70F, 0x70F, 7
    .long 0x711, 0x711, 4
    .long 0x730, 0x74A, 4
    .long 0x7A6, 0x7B0, 4
    .long 0x7EB, 0x7F3, 4
    .long 0x7FD, 0x7FD, 4
    .long 0x816, 0x819, 4
    .long 0x81B, 0x823, 4
    .long 0x825, 0x827, 4
    .long 0x829, 0x82D, 4
    .long 0x859, 0x85B, 4
    .long 0x890, 0x891, 7
    .long 0x897, 0x89F, 4
    .long 0x8CA, 0x8E1, 4
    .long 0x8E2, 0x8E2, 7
    .long 0x8E3, 0x902, 4
    .long 0x903, 0x903, 8
    .long 0x93A, 0x93A, 4
    .long 0x93B, 0x93B, 8
    .long 0x93C, 0x93C, 4
    .long 0x93E, 0x940, 8
    .long 0x941, 0x948, 4
    .long 0x949, 0x94C, 8
    .long 0x94D, 0x94D, 4
    .long 0x94E, 0x94F, 8
    .long 0x951, 0x957, 4
    .long 0x962, 0x963, 4
    .long 0x981, 0x981, 4
    .long 0x982, 0x983, 8
    .long 0x9BC, 0x9BC, 4
    .long 0x9BE, 0x9BE, 4
    .long 0x9BF, 0x9C0, 8
    .long 0x9C1, 0x9C4, 4
    .long 0x9C7, 0x9C8, 8
    .long 0x9CB, 0x9CC, 8
    .long 0x9CD, 0x9CD, 4
    .long 0x9D7, 0x9D7, 4
    .long 0x9E2, 0x9E3, 4
    .long 0x9FE, 0x9FE, 4
    .long 0xA01, 0xA02, 4
    .long 0xA03, 0xA03, 8
    .long 0xA3C, 0xA3C, 4
    .long 0xA3E, 0xA40, 8
    .long 0xA41, 0xA42, 4
    .long 0xA47, 0xA48, 4
    .long 0xA4B, 0xA4D, 4
    .long 0xA51, 0xA51, 4
    .long 0xA70, 0xA71, 4
    .long 0xA75, 0xA75, 4
    .long 0xA81, 0xA82, 4
    .long 0xA83, 0xA83, 8
    .long 0xABC, 0xABC, 4
    .long 0xABE, 0xAC0, 8
    .long 0xAC1, 0xAC5, 4
    .long 0xAC7, 0xAC8, 4
    .long 0xAC9, 0xAC9, 8
    .long 0xACB, 0xACC, 8
    .long 0xACD, 0xACD, 4
    .long 0xAE2, 0xAE3, 4
    .long 0xAFA, 0xAFF, 4
    .long 0xB01, 0xB01, 4
    .long 0xB02, 0xB03, 8
    .long 0xB3C, 0xB3C, 4
    .long 0xB3E, 0xB3E, 4
    .long 0xB3F, 0xB3F, 4
    .long 0xB40, 0xB40, 8
    .long 0xB41, 0xB44, 4
    .long 0xB47, 0xB48, 8
    .long 0xB4B, 0xB4C, 8
    .long 0xB4D, 0xB4D, 4
    .long 0xB53, 0xB56, 4
    .long 0xB57, 0xB57, 4
    .long 0xB62, 0xB63, 4
    .long 0xB82, 0xB82, 4
    .long 0xBBE, 0xBBE, 4
    .long 0xBBF, 0xBBF, 8
    .long 0xBC0, 0xBC0, 4
    .long 0xBC1, 0xBC2, 8
    .long 0xBC6, 0xBC8, 8
    .long 0xBCA, 0xBCC, 8
    .long 0xBCD, 0xBCD, 4
    .long 0xBD7, 0xBD7, 4
    .long 0xC00, 0xC00, 4
    .long 0xC01, 0xC03, 8
    .long 0xC04, 0xC04, 4
    .long 0xC3C, 0xC3C, 4
    .long 0xC3E, 0xC40, 4
    .long 0xC41, 0xC44, 8
    .long 0xC46, 0xC48, 4
    .long 0xC4A, 0xC4D, 4
    .long 0xC55, 0xC56, 4
    .long 0xC62, 0xC63, 4
    .long 0xC81, 0xC81, 4
    .long 0xC82, 0xC83, 8
    .long 0xCBC, 0xCBC, 4
    .long 0xCBE, 0xCBE, 8
    .long 0xCBF, 0xCBF, 4
    .long 0xCC0, 0xCC0, 4
    .long 0xCC1, 0xCC1, 8
    .long 0xCC2, 0xCC2, 4
    .long 0xCC3, 0xCC4, 8
    .long 0xCC6, 0xCC6, 4
    .long 0xCC7, 0xCC8, 4
    .long 0xCCA, 0xCCB, 4
    .long 0xCCC, 0xCCD, 4
    .long 0xCD5, 0xCD6, 4
    .long 0xCE2, 0xCE3, 4
    .long 0xCF3, 0xCF3, 8
    .long 0xD00, 0xD01, 4
    .long 0xD02, 0xD03, 8
    .long 0xD3B, 0xD3C, 4
    .long 0xD3E, 0xD3E, 4
    .long 0xD3F, 0xD40, 8
    .long 0xD41, 0xD44, 4
    .long 0xD46, 0xD48, 8
    .long 0xD4A, 0xD4C, 8
    .long 0xD4D, 0xD4D, 4
    .long 0xD4E, 0xD4E, 7
    .long 0xD57, 0xD57, 4
    .long 0xD62, 0xD63, 4
    .long 0xD81, 0xD81, 4
    .long 0xD82, 0xD83, 8
    .long 0xDCA, 0xDCA, 4
    .long 0xDCF, 0xDCF, 4
    .long 0xDD0, 0xDD1, 8
    .long 0xDD2, 0xDD4, 4
    .long 0xDD6, 0xDD6, 4
    .long 0xDD8, 0xDDE, 8
    .long 0xDDF, 0xDDF, 4
    .long 0xDF2, 0xDF3, 8
    .long 0xE31, 0xE31, 4
    .long 0xE33, 0xE33, 8
    .long 0xE34, 0xE3A, 4
    .long 0xE47, 0xE4E, 4
    .long 0xEB1, 0xEB1, 4
    .long 0xEB3, 0xEB3, 8
    .long 0xEB4, 0xEBC, 4
    .long 0xEC8, 0xECE, 4
    .long 0xF18, 0xF19, 4
    .long 0xF35, 0xF35, 4
    .long 0xF37, 0xF37, 4
    .long 0xF39, 0xF39, 4
    .long 0xF3E, 0xF3F, 8
    .long 0xF71, 0xF7E, 4
    .long 0xF7F, 0xF7F, 8
    .long 0xF80, 0xF84, 4
    .long 0xF86, 0xF87, 4
    .long 0xF8D, 0xF97, 4
    .long 0xF99, 0xFBC, 4
    .long 0xFC6, 0xFC6, 4
    .long 0x102D, 0x1030, 4
    .long 0x1031, 0x1031, 8
    .long 0x1032, 0x1037, 4
    .long 0x1039, 0x103A, 4
    .long 0x103B, 0x103C, 8
    .long 0x103D, 0x103E, 4
    .long 0x1056, 0x1057, 8
    .long 0x1058, 0x1059, 4
    .long 0x105E, 0x1060, 4
    .long 0x1071, 0x1074, 4
    .long 0x1082, 0x1082, 4
    .long 0x1084, 0x1084, 8
    .long 0x1085, 0x1086, 4
    .long 0x108D, 0x108D, 4
    .long 0x109D, 0x109D, 4
    .long 0x1100, 0x115F, 9
    .long 0x1160, 0x11A7, 10
    .long 0x11A8, 0x11FF, 11
    .long 0x135D, 0x135F, 4
    .long 0x1712, 0x1714, 4
    .long 0x1715, 0x1715, 4
    .long 0x1732, 0x1733, 4
    .long 0x1734, 0x1734, 4
    .long 0x1752, 0x1753, 4
    .long 0x1772, 0x1773, 4
    .long 0x17B4, 0x17B5, 4
    .long 0x17B6, 0x17B6, 8
    .long 0x17B7, 0x17BD, 4
    .long 0x17BE, 0x17C5, 8
    .long 0x17C6, 0x17C6, 4
    .long 0x17C7, 0x17C8, 8
    .long 0x17C9, 0x17D3, 4
    .long 0x17DD, 0x17DD, 4
    .long 0x180B, 0x180D, 4
    .long 0x180E, 0x180E, 3
    .long 0x180F, 0x180F, 4
    .long 0x1885, 0x1886, 4
    .long 0x18A9, 0x18A9, 4
    .long 0x1920, 0x1922, 4
    .long 0x1923, 0x1926, 8
    .long 0x1927, 0x1928, 4
    .long 0x1929, 0x192B, 8
    .long 0x1930, 0x1931, 8
    .long 0x1932, 0x1932, 4
    .long 0x1933, 0x1938, 8
    .long 0x1939, 0x193B, 4
    .long 0x1A17, 0x1A18, 4
    .long 0x1A19, 0x1A1A, 8
    .long 0x1A1B, 0x1A1B, 4
    .long 0x1A55, 0x1A55, 8
    .long 0x1A56, 0x1A56, 4
    .long 0x1A57, 0x1A57, 8
    .long 0x1A58, 0x1A5E, 4
    .long 0x1A60, 0x1A60, 4
    .long 0x1A62, 0x1A62, 4
    .long 0x1A65, 0x1A6C, 4
    .long 0x1A6D, 0x1A72, 8
    .long 0x1A73, 0x1A7C, 4
    .long 0x1A7F, 0x1A7F, 4
    .long 0x1AB0, 0x1ABD, 4
    .long 0x1ABE, 0x1ABE, 4
    .long 0x1ABF, 0x1AF0, 4
    .long 0x1B00, 0x1B03, 4
    .long 0x1B04, 0x1B04, 8
    .long 0x1B34, 0x1B34, 4
    .long 0x1B35, 0x1B35, 4
    .long 0x1B36, 0x1B3A, 4
    .long 0x1B3B, 0x1B3B, 4
    .long 0x1B3C, 0x1B3C, 4
    .long 0x1B3D, 0x1B3D, 4
    .long 0x1B3E, 0x1B41, 8
    .long 0x1B42, 0x1B42, 4
    .long 0x1B43, 0x1B44, 4
    .long 0x1B6B, 0x1B73, 4
    .long 0x1B80, 0x1B81, 4
    .long 0x1B82, 0x1B82, 8
    .long 0x1BA1, 0x1BA1, 8
    .long 0x1BA2, 0x1BA5, 4
    .long 0x1BA6, 0x1BA7, 8
    .long 0x1BA8, 0x1BA9, 4
    .long 0x1BAA, 0x1BAA, 4
    .long 0x1BAB, 0x1BAD, 4
    .long 0x1BE6, 0x1BE6, 4
    .long 0x1BE7, 0x1BE7, 8
    .long 0x1BE8, 0x1BE9, 4
    .long 0x1BEA, 0x1BEC, 8
    .long 0x1BED, 0x1BED, 4
    .long 0x1BEE, 0x1BEE, 8
    .long 0x1BEF, 0x1BF1, 4
    .long 0x1BF2, 0x1BF3, 4
    .long 0x1C24, 0x1C2B, 8
    .long 0x1C2C, 0x1C33, 4
    .long 0x1C34, 0x1C35, 8
    .long 0x1C36, 0x1C37, 4
    .long 0x1CD0, 0x1CD2, 4
    .long 0x1CD4, 0x1CE0, 4
    .long 0x1CE1, 0x1CE1, 8
    .long 0x1CE2, 0x1CE8, 4
    .long 0x1CED, 0x1CED, 4
    .long 0x1CF4, 0x1CF4, 4
    .long 0x1CF7, 0x1CF7, 8
    .long 0x1CF8, 0x1CF9, 4
    .long 0x1DC0, 0x1DFF, 4
    .long 0x200B, 0x200B, 3
    .long 0x200C, 0x200C, 4
    .long 0x200D, 0x200D, 5
    .long 0x200E, 0x200F, 3
    .long 0x2028, 0x2028, 3
    .long 0x2029, 0x2029, 3
    .long 0x202A, 0x202E, 3
    .long 0x2060, 0x2064, 3
    .long 0x2065, 0x2065, 3
    .long 0x2066, 0x206F, 3
    .long 0x20D0, 0x20DC, 4
    .long 0x20DD, 0x20E0, 4
    .long 0x20E1, 0x20E1, 4
    .long 0x20E2, 0x20E4, 4
    .long 0x20E5, 0x20F0, 4
    .long 0x2CEF, 0x2CF1, 4
    .long 0x2D7F, 0x2D7F, 4
    .long 0x2DE0, 0x2DFF, 4
    .long 0x302A, 0x302D, 4
    .long 0x302E, 0x302F, 4
    .long 0x3099, 0x309A, 4
    .long 0xA66F, 0xA66F, 4
    .long 0xA670, 0xA672, 4
    .long 0xA674, 0xA67D, 4
    .long 0xA69E, 0xA69F, 4
    .long 0xA6F0, 0xA6F1, 4
    .long 0xA802, 0xA802, 4
    .long 0xA806, 0xA806, 4
    .long 0xA80B, 0xA80B, 4
    .long 0xA823, 0xA824, 8
    .long 0xA825, 0xA826, 4
    .long 0xA827, 0xA827, 8
    .long 0xA82C, 0xA82C, 4
    .long 0xA880, 0xA881, 8
    .long 0xA8B4, 0xA8C3, 8
    .long 0xA8C4, 0xA8C5, 4
    .long 0xA8E0, 0xA8F1, 4
    .long 0xA8FF, 0xA8FF, 4
    .long 0xA926, 0xA92D, 4
    .long 0xA947, 0xA951, 4
    .long 0xA952, 0xA952, 8
    .long 0xA953, 0xA953, 4
    .long 0xA960, 0xA97C, 9
    .long 0xA980, 0xA982, 4
    .long 0xA983, 0xA983, 8
    .long 0xA9B3, 0xA9B3, 4
    .long 0xA9B4, 0xA9B5, 8
    .long 0xA9B6, 0xA9B9, 4
    .long 0xA9BA, 0xA9BB, 8
    .long 0xA9BC, 0xA9BD, 4
    .long 0xA9BE, 0xA9BF, 8
    .long 0xA9C0, 0xA9C0, 4
    .long 0xA9E5, 0xA9E5, 4
    .long 0xAA29, 0xAA2E, 4
    .long 0xAA2F, 0xAA30, 8
    .long 0xAA31, 0xAA32, 4
    .long 0xAA33, 0xAA34, 8
    .long 0xAA35, 0xAA36, 4
    .long 0xAA43, 0xAA43, 4
    .long 0xAA4C, 0xAA4C, 4
    .long 0xAA4D, 0xAA4D, 8
    .long 0xAA7C, 0xAA7C, 4
    .long 0xAAB0, 0xAAB0, 4
    .long 0xAAB2, 0xAAB4, 4
    .long 0xAAB7, 0xAAB8, 4
    .long 0xAABE, 0xAABF, 4
    .long 0xAAC1, 0xAAC1, 4
    .long 0xAAEB, 0xAAEB, 8
    .long 0xAAEC, 0xAAED, 4
    .long 0xAAEE, 0xAAEF, 8
    .long 0xAAF5, 0xAAF5, 8
    .long 0xAAF6, 0xAAF6, 4
    .long 0xABE3, 0xABE4, 8
    .long 0xABE5, 0xABE5, 4
    .long 0xABE6, 0xABE7, 8
    .long 0xABE8, 0xABE8, 4
    .long 0xABE9, 0xABEA, 8
    .long 0xABEC, 0xABEC, 8
    .long 0xABED, 0xABED, 4
    .long 0xD7B0, 0xD7C6, 10
    .long 0xD7CB, 0xD7FB, 11
    .long 0xFB1E, 0xFB1E, 4
    .long 0xFE00, 0xFE0F, 4
    .long 0xFE20, 0xFE2F, 4
    .long 0xFEFF, 0xFEFF, 3
    .long 0xFF9E, 0xFF9F, 4
    .long 0xFFF0, 0xFFF8, 3
    .long 0xFFF9, 0xFFFB, 3
    .long 0x101FD, 0x101FD, 4
    .long 0x102E0, 0x102E0, 4
    .long 0x10376, 0x1037A, 4
    .long 0x10A01, 0x10A03, 4
    .long 0x10A05, 0x10A06, 4
    .long 0x10A0C, 0x10A0F, 4
    .long 0x10A38, 0x10A3A, 4
    .long 0x10A3F, 0x10A3F, 4
    .long 0x10AE5, 0x10AE6, 4
    .long 0x10D24, 0x10D27, 4
    .long 0x10D69, 0x10D6D, 4
    .long 0x10EAB, 0x10EAC, 4
    .long 0x10ECB, 0x10ECF, 4
    .long 0x10EF0, 0x10EFF, 4
    .long 0x10F46, 0x10F50, 4
    .long 0x10F82, 0x10F85, 4
    .long 0x11000, 0x11000, 8
    .long 0x11001, 0x11001, 4
    .long 0x11002, 0x11002, 8
    .long 0x11038, 0x11046, 4
    .long 0x11070, 0x11070, 4
    .long 0x11073, 0x11074, 4
    .long 0x1107F, 0x11081, 4
    .long 0x11082, 0x11082, 8
    .long 0x110B0, 0x110B2, 8
    .long 0x110B3, 0x110B6, 4
    .long 0x110B7, 0x110B8, 8
    .long 0x110B9, 0x110BA, 4
    .long 0x110BD, 0x110BD, 7
    .long 0x110C2, 0x110C2, 4
    .long 0x110CD, 0x110CD, 7
    .long 0x11100, 0x11102, 4
    .long 0x11127, 0x1112B, 4
    .long 0x1112C, 0x1112C, 8
    .long 0x1112D, 0x11134, 4
    .long 0x11145, 0x11146, 8
    .long 0x11173, 0x11173, 4
    .long 0x11180, 0x11181, 4
    .long 0x11182, 0x11182, 8
    .long 0x111B3, 0x111B5, 8
    .long 0x111B6, 0x111BE, 4
    .long 0x111BF, 0x111BF, 8
    .long 0x111C0, 0x111C0, 4
    .long 0x111C2, 0x111C3, 7
    .long 0x111C9, 0x111CC, 4
    .long 0x111CE, 0x111CE, 8
    .long 0x111CF, 0x111CF, 4
    .long 0x1122C, 0x1122E, 8
    .long 0x1122F, 0x11231, 4
    .long 0x11232, 0x11233, 8
    .long 0x11234, 0x11234, 4
    .long 0x11235, 0x11235, 4
    .long 0x11236, 0x11237, 4
    .long 0x1123E, 0x1123E, 4
    .long 0x11241, 0x11241, 4
    .long 0x112DF, 0x112DF, 4
    .long 0x112E0, 0x112E2, 8
    .long 0x112E3, 0x112EA, 4
    .long 0x11300, 0x11301, 4
    .long 0x11302, 0x11303, 8
    .long 0x1133B, 0x1133C, 4
    .long 0x1133E, 0x1133E, 4
    .long 0x1133F, 0x1133F, 8
    .long 0x11340, 0x11340, 4
    .long 0x11341, 0x11344, 8
    .long 0x11347, 0x11348, 8
    .long 0x1134B, 0x1134C, 8
    .long 0x1134D, 0x1134D, 4
    .long 0x11357, 0x11357, 4
    .long 0x11362, 0x11363, 8
    .long 0x11366, 0x1136C, 4
    .long 0x11370, 0x11374, 4
    .long 0x113B8, 0x113B8, 4
    .long 0x113B9, 0x113BA, 8
    .long 0x113BB, 0x113C0, 4
    .long 0x113C2, 0x113C2, 4
    .long 0x113C5, 0x113C5, 4
    .long 0x113C7, 0x113C9, 4
    .long 0x113CA, 0x113CA, 8
    .long 0x113CC, 0x113CD, 8
    .long 0x113CE, 0x113CE, 4
    .long 0x113CF, 0x113CF, 4
    .long 0x113D0, 0x113D0, 4
    .long 0x113D1, 0x113D1, 7
    .long 0x113D2, 0x113D2, 4
    .long 0x113E1, 0x113E2, 4
    .long 0x11435, 0x11437, 8
    .long 0x11438, 0x1143F, 4
    .long 0x11440, 0x11441, 8
    .long 0x11442, 0x11444, 4
    .long 0x11445, 0x11445, 8
    .long 0x11446, 0x11446, 4
    .long 0x1145E, 0x1145E, 4
    .long 0x114B0, 0x114B0, 4
    .long 0x114B1, 0x114B2, 8
    .long 0x114B3, 0x114B8, 4
    .long 0x114B9, 0x114B9, 8
    .long 0x114BA, 0x114BA, 4
    .long 0x114BB, 0x114BC, 8
    .long 0x114BD, 0x114BD, 4
    .long 0x114BE, 0x114BE, 8
    .long 0x114BF, 0x114C0, 4
    .long 0x114C1, 0x114C1, 8
    .long 0x114C2, 0x114C3, 4
    .long 0x115AF, 0x115AF, 4
    .long 0x115B0, 0x115B1, 8
    .long 0x115B2, 0x115B5, 4
    .long 0x115B8, 0x115BB, 8
    .long 0x115BC, 0x115BD, 4
    .long 0x115BE, 0x115BE, 8
    .long 0x115BF, 0x115C0, 4
    .long 0x115DC, 0x115DD, 4
    .long 0x11630, 0x11632, 8
    .long 0x11633, 0x1163A, 4
    .long 0x1163B, 0x1163C, 8
    .long 0x1163D, 0x1163D, 4
    .long 0x1163E, 0x1163E, 8
    .long 0x1163F, 0x11640, 4
    .long 0x116AB, 0x116AB, 4
    .long 0x116AC, 0x116AC, 8
    .long 0x116AD, 0x116AD, 4
    .long 0x116AE, 0x116AF, 8
    .long 0x116B0, 0x116B5, 4
    .long 0x116B6, 0x116B6, 4
    .long 0x116B7, 0x116B7, 4
    .long 0x1171D, 0x1171D, 4
    .long 0x1171E, 0x1171E, 8
    .long 0x1171F, 0x1171F, 4
    .long 0x11722, 0x11725, 4
    .long 0x11726, 0x11726, 8
    .long 0x11727, 0x1172B, 4
    .long 0x1182C, 0x1182E, 8
    .long 0x1182F, 0x11837, 4
    .long 0x11838, 0x11838, 8
    .long 0x11839, 0x1183A, 4
    .long 0x11930, 0x11930, 4
    .long 0x11931, 0x11935, 8
    .long 0x11937, 0x11938, 8
    .long 0x1193B, 0x1193C, 4
    .long 0x1193D, 0x1193D, 4
    .long 0x1193E, 0x1193E, 4
    .long 0x1193F, 0x1193F, 7
    .long 0x11940, 0x11940, 8
    .long 0x11941, 0x11941, 7
    .long 0x11942, 0x11942, 8
    .long 0x11943, 0x11943, 4
    .long 0x119D1, 0x119D3, 8
    .long 0x119D4, 0x119D7, 4
    .long 0x119DA, 0x119DB, 4
    .long 0x119DC, 0x119DF, 8
    .long 0x119E0, 0x119E0, 4
    .long 0x119E4, 0x119E4, 8
    .long 0x11A01, 0x11A0A, 4
    .long 0x11A33, 0x11A38, 4
    .long 0x11A39, 0x11A39, 8
    .long 0x11A3B, 0x11A3E, 4
    .long 0x11A47, 0x11A47, 4
    .long 0x11A51, 0x11A56, 4
    .long 0x11A57, 0x11A58, 8
    .long 0x11A59, 0x11A5B, 4
    .long 0x11A84, 0x11A89, 7
    .long 0x11A8A, 0x11A96, 4
    .long 0x11A97, 0x11A97, 8
    .long 0x11A98, 0x11A99, 4
    .long 0x11B60, 0x11B60, 4
    .long 0x11B61, 0x11B61, 8
    .long 0x11B62, 0x11B64, 4
    .long 0x11B65, 0x11B65, 8
    .long 0x11B66, 0x11B66, 4
    .long 0x11B67, 0x11B67, 8
    .long 0x11C2F, 0x11C2F, 8
    .long 0x11C30, 0x11C36, 4
    .long 0x11C38, 0x11C3D, 4
    .long 0x11C3E, 0x11C3E, 8
    .long 0x11C3F, 0x11C3F, 4
    .long 0x11C92, 0x11CA7, 4
    .long 0x11CA9, 0x11CA9, 8
    .long 0x11CAA, 0x11CB0, 4
    .long 0x11CB1, 0x11CB1, 8
    .long 0x11CB2, 0x11CB3, 4
    .long 0x11CB4, 0x11CB4, 8
    .long 0x11CB5, 0x11CB6, 4
    .long 0x11D31, 0x11D36, 4
    .long 0x11D3A, 0x11D3A, 4
    .long 0x11D3C, 0x11D3D, 4
    .long 0x11D3F, 0x11D45, 4
    .long 0x11D46, 0x11D46, 7
    .long 0x11D47, 0x11D47, 4
    .long 0x11D8A, 0x11D8E, 8
    .long 0x11D90, 0x11D91, 4
    .long 0x11D93, 0x11D94, 8
    .long 0x11D95, 0x11D95, 4
    .long 0x11D96, 0x11D96, 8
    .long 0x11D97, 0x11D97, 4
    .long 0x11DF0, 0x11DF0, 4
    .long 0x11EF3, 0x11EF4, 4
    .long 0x11EF5, 0x11EF6, 8
    .long 0x11F00, 0x11F01, 4
    .long 0x11F02, 0x11F02, 7
    .long 0x11F03, 0x11F03, 8
    .long 0x11F34, 0x11F35, 8
    .long 0x11F36, 0x11F3A, 4
    .long 0x11F3E, 0x11F3F, 8
    .long 0x11F40, 0x11F40, 4
    .long 0x11F41, 0x11F41, 4
    .long 0x11F42, 0x11F42, 4
    .long 0x11F5A, 0x11F5A, 4
    .long 0x13430, 0x1343F, 3
    .long 0x13440, 0x13440, 4
    .long 0x13447, 0x13455, 4
    .long 0x1611E, 0x16129, 4
    .long 0x1612A, 0x1612C, 8
    .long 0x1612D, 0x1612F, 4
    .long 0x16AF0, 0x16AF4, 4
    .long 0x16B30, 0x16B36, 4
    .long 0x16D63, 0x16D63, 10
    .long 0x16D67, 0x16D6A, 10
    .long 0x16F4F, 0x16F4F, 4
    .long 0x16F51, 0x16F87, 8
    .long 0x16F8F, 0x16F92, 4
    .long 0x16FE4, 0x16FE4, 4
    .long 0x16FF0, 0x16FF1, 4
    .long 0x1BC9D, 0x1BC9E, 4
    .long 0x1BCA0, 0x1BCA3, 3
    .long 0x1CF00, 0x1CF2D, 4
    .long 0x1CF30, 0x1CF46, 4
    .long 0x1D127, 0x1D128, 4
    .long 0x1D165, 0x1D166, 4
    .long 0x1D167, 0x1D169, 4
    .long 0x1D16D, 0x1D172, 4
    .long 0x1D173, 0x1D17A, 3
    .long 0x1D17B, 0x1D182, 4
    .long 0x1D185, 0x1D18B, 4
    .long 0x1D1AA, 0x1D1AD, 4
    .long 0x1D242, 0x1D244, 4
    .long 0x1D250, 0x1D252, 4
    .long 0x1D25B, 0x1D25C, 4
    .long 0x1D25F, 0x1D25F, 4
    .long 0x1D280, 0x1D281, 4
    .long 0x1DA00, 0x1DA36, 4
    .long 0x1DA3B, 0x1DA6C, 4
    .long 0x1DA75, 0x1DA75, 4
    .long 0x1DA84, 0x1DA84, 4
    .long 0x1DA9B, 0x1DA9F, 4
    .long 0x1DAA1, 0x1DAAF, 4
    .long 0x1E000, 0x1E006, 4
    .long 0x1E008, 0x1E018, 4
    .long 0x1E01B, 0x1E021, 4
    .long 0x1E023, 0x1E024, 4
    .long 0x1E026, 0x1E02A, 4
    .long 0x1E08F, 0x1E08F, 4
    .long 0x1E130, 0x1E136, 4
    .long 0x1E2AE, 0x1E2AE, 4
    .long 0x1E2EC, 0x1E2EF, 4
    .long 0x1E4EC, 0x1E4EF, 4
    .long 0x1E5EE, 0x1E5EF, 4
    .long 0x1E6E3, 0x1E6E3, 4
    .long 0x1E6E6, 0x1E6E6, 4
    .long 0x1E6EE, 0x1E6EF, 4
    .long 0x1E6F5, 0x1E6F5, 4
    .long 0x1E8D0, 0x1E8D6, 4
    .long 0x1E944, 0x1E94A, 4
    .long 0x1F1E6, 0x1F1FF, 6
    .long 0x1F3FB, 0x1F3FF, 4
    .long 0xE0000, 0xE0000, 3
    .long 0xE0001, 0xE0001, 3
    .long 0xE0002, 0xE001F, 3
    .long 0xE0020, 0xE007F, 4
    .long 0xE0080, 0xE00FF, 3
    .long 0xE0100, 0xE01EF, 4
    .long 0xE01F0, 0xE0FFF, 3
unicode_gcb_ranges_end:

# Indic_Conjunct_Break: Consonant=1, Extend=2, Linker=3.
.balign 4
unicode_incb_ranges:
    .long 0x300, 0x36F, 2
    .long 0x483, 0x487, 2
    .long 0x488, 0x489, 2
    .long 0x591, 0x5BD, 2
    .long 0x5BF, 0x5BF, 2
    .long 0x5C1, 0x5C2, 2
    .long 0x5C4, 0x5C5, 2
    .long 0x5C7, 0x5C9, 2
    .long 0x610, 0x61A, 2
    .long 0x64B, 0x65F, 2
    .long 0x670, 0x670, 2
    .long 0x6D6, 0x6DC, 2
    .long 0x6DF, 0x6E4, 2
    .long 0x6E7, 0x6E8, 2
    .long 0x6EA, 0x6ED, 2
    .long 0x711, 0x711, 2
    .long 0x730, 0x74A, 2
    .long 0x7A6, 0x7B0, 2
    .long 0x7EB, 0x7F3, 2
    .long 0x7FD, 0x7FD, 2
    .long 0x816, 0x819, 2
    .long 0x81B, 0x823, 2
    .long 0x825, 0x827, 2
    .long 0x829, 0x82D, 2
    .long 0x859, 0x85B, 2
    .long 0x897, 0x89F, 2
    .long 0x8CA, 0x8E1, 2
    .long 0x8E3, 0x902, 2
    .long 0x915, 0x939, 1
    .long 0x93A, 0x93A, 2
    .long 0x93C, 0x93C, 2
    .long 0x941, 0x948, 2
    .long 0x94D, 0x94D, 3
    .long 0x951, 0x957, 2
    .long 0x958, 0x95F, 1
    .long 0x962, 0x963, 2
    .long 0x978, 0x97F, 1
    .long 0x981, 0x981, 2
    .long 0x995, 0x9A8, 1
    .long 0x9AA, 0x9B0, 1
    .long 0x9B2, 0x9B2, 1
    .long 0x9B6, 0x9B9, 1
    .long 0x9BC, 0x9BC, 2
    .long 0x9BE, 0x9BE, 2
    .long 0x9C1, 0x9C4, 2
    .long 0x9CD, 0x9CD, 3
    .long 0x9D7, 0x9D7, 2
    .long 0x9DC, 0x9DD, 1
    .long 0x9DF, 0x9DF, 1
    .long 0x9E2, 0x9E3, 2
    .long 0x9F0, 0x9F1, 1
    .long 0x9FE, 0x9FE, 2
    .long 0xA01, 0xA02, 2
    .long 0xA3C, 0xA3C, 2
    .long 0xA41, 0xA42, 2
    .long 0xA47, 0xA48, 2
    .long 0xA4B, 0xA4D, 2
    .long 0xA51, 0xA51, 2
    .long 0xA70, 0xA71, 2
    .long 0xA75, 0xA75, 2
    .long 0xA81, 0xA82, 2
    .long 0xA95, 0xAA8, 1
    .long 0xAAA, 0xAB0, 1
    .long 0xAB2, 0xAB3, 1
    .long 0xAB5, 0xAB9, 1
    .long 0xABC, 0xABC, 2
    .long 0xAC1, 0xAC5, 2
    .long 0xAC7, 0xAC8, 2
    .long 0xACD, 0xACD, 3
    .long 0xAE2, 0xAE3, 2
    .long 0xAF9, 0xAF9, 1
    .long 0xAFA, 0xAFF, 2
    .long 0xB01, 0xB01, 2
    .long 0xB15, 0xB28, 1
    .long 0xB2A, 0xB30, 1
    .long 0xB32, 0xB33, 1
    .long 0xB35, 0xB39, 1
    .long 0xB3C, 0xB3C, 2
    .long 0xB3E, 0xB3E, 2
    .long 0xB3F, 0xB3F, 2
    .long 0xB41, 0xB44, 2
    .long 0xB4D, 0xB4D, 3
    .long 0xB53, 0xB56, 2
    .long 0xB57, 0xB57, 2
    .long 0xB5C, 0xB5D, 1
    .long 0xB5F, 0xB5F, 1
    .long 0xB62, 0xB63, 2
    .long 0xB71, 0xB71, 1
    .long 0xB82, 0xB82, 2
    .long 0xBBE, 0xBBE, 2
    .long 0xBC0, 0xBC0, 2
    .long 0xBCD, 0xBCD, 2
    .long 0xBD7, 0xBD7, 2
    .long 0xC00, 0xC00, 2
    .long 0xC04, 0xC04, 2
    .long 0xC15, 0xC28, 1
    .long 0xC2A, 0xC39, 1
    .long 0xC3C, 0xC3C, 2
    .long 0xC3E, 0xC40, 2
    .long 0xC46, 0xC48, 2
    .long 0xC4A, 0xC4C, 2
    .long 0xC4D, 0xC4D, 3
    .long 0xC55, 0xC56, 2
    .long 0xC58, 0xC5A, 1
    .long 0xC62, 0xC63, 2
    .long 0xC81, 0xC81, 2
    .long 0xCBC, 0xCBC, 2
    .long 0xCBF, 0xCBF, 2
    .long 0xCC0, 0xCC0, 2
    .long 0xCC2, 0xCC2, 2
    .long 0xCC6, 0xCC6, 2
    .long 0xCC7, 0xCC8, 2
    .long 0xCCA, 0xCCB, 2
    .long 0xCCC, 0xCCD, 2
    .long 0xCD5, 0xCD6, 2
    .long 0xCE2, 0xCE3, 2
    .long 0xD00, 0xD01, 2
    .long 0xD15, 0xD3A, 1
    .long 0xD3B, 0xD3C, 2
    .long 0xD3E, 0xD3E, 2
    .long 0xD41, 0xD44, 2
    .long 0xD4D, 0xD4D, 3
    .long 0xD57, 0xD57, 2
    .long 0xD62, 0xD63, 2
    .long 0xD81, 0xD81, 2
    .long 0xDCA, 0xDCA, 2
    .long 0xDCF, 0xDCF, 2
    .long 0xDD2, 0xDD4, 2
    .long 0xDD6, 0xDD6, 2
    .long 0xDDF, 0xDDF, 2
    .long 0xE31, 0xE31, 2
    .long 0xE34, 0xE3A, 2
    .long 0xE47, 0xE4E, 2
    .long 0xEB1, 0xEB1, 2
    .long 0xEB4, 0xEBC, 2
    .long 0xEC8, 0xECE, 2
    .long 0xF18, 0xF19, 2
    .long 0xF35, 0xF35, 2
    .long 0xF37, 0xF37, 2
    .long 0xF39, 0xF39, 2
    .long 0xF71, 0xF7E, 2
    .long 0xF80, 0xF84, 2
    .long 0xF86, 0xF87, 2
    .long 0xF8D, 0xF97, 2
    .long 0xF99, 0xFBC, 2
    .long 0xFC6, 0xFC6, 2
    .long 0x1000, 0x102A, 1
    .long 0x102D, 0x1030, 2
    .long 0x1032, 0x1037, 2
    .long 0x1039, 0x1039, 3
    .long 0x103A, 0x103A, 2
    .long 0x103D, 0x103E, 2
    .long 0x103F, 0x103F, 1
    .long 0x1050, 0x1055, 1
    .long 0x1058, 0x1059, 2
    .long 0x105A, 0x105D, 1
    .long 0x105E, 0x1060, 2
    .long 0x1061, 0x1061, 1
    .long 0x1065, 0x1066, 1
    .long 0x106E, 0x1070, 1
    .long 0x1071, 0x1074, 2
    .long 0x1075, 0x1081, 1
    .long 0x1082, 0x1082, 2
    .long 0x1085, 0x1086, 2
    .long 0x108D, 0x108D, 2
    .long 0x108E, 0x108E, 1
    .long 0x109D, 0x109D, 2
    .long 0x135D, 0x135F, 2
    .long 0x1712, 0x1714, 2
    .long 0x1715, 0x1715, 2
    .long 0x1732, 0x1733, 2
    .long 0x1734, 0x1734, 2
    .long 0x1752, 0x1753, 2
    .long 0x1772, 0x1773, 2
    .long 0x1780, 0x17B3, 1
    .long 0x17B4, 0x17B5, 2
    .long 0x17B7, 0x17BD, 2
    .long 0x17C6, 0x17C6, 2
    .long 0x17C9, 0x17D1, 2
    .long 0x17D2, 0x17D2, 3
    .long 0x17D3, 0x17D3, 2
    .long 0x17DD, 0x17DD, 2
    .long 0x180B, 0x180D, 2
    .long 0x180F, 0x180F, 2
    .long 0x1885, 0x1886, 2
    .long 0x18A9, 0x18A9, 2
    .long 0x1920, 0x1922, 2
    .long 0x1927, 0x1928, 2
    .long 0x1932, 0x1932, 2
    .long 0x1939, 0x193B, 2
    .long 0x1A17, 0x1A18, 2
    .long 0x1A1B, 0x1A1B, 2
    .long 0x1A20, 0x1A54, 1
    .long 0x1A56, 0x1A56, 2
    .long 0x1A58, 0x1A5E, 2
    .long 0x1A60, 0x1A60, 3
    .long 0x1A62, 0x1A62, 2
    .long 0x1A65, 0x1A6C, 2
    .long 0x1A73, 0x1A7C, 2
    .long 0x1A7F, 0x1A7F, 2
    .long 0x1AB0, 0x1ABD, 2
    .long 0x1ABE, 0x1ABE, 2
    .long 0x1ABF, 0x1AF0, 2
    .long 0x1B00, 0x1B03, 2
    .long 0x1B0B, 0x1B0C, 1
    .long 0x1B13, 0x1B33, 1
    .long 0x1B34, 0x1B34, 2
    .long 0x1B35, 0x1B35, 2
    .long 0x1B36, 0x1B3A, 2
    .long 0x1B3B, 0x1B3B, 2
    .long 0x1B3C, 0x1B3C, 2
    .long 0x1B3D, 0x1B3D, 2
    .long 0x1B42, 0x1B42, 2
    .long 0x1B43, 0x1B43, 2
    .long 0x1B44, 0x1B44, 3
    .long 0x1B45, 0x1B4C, 1
    .long 0x1B6B, 0x1B73, 2
    .long 0x1B80, 0x1B81, 2
    .long 0x1B83, 0x1BA0, 1
    .long 0x1BA2, 0x1BA5, 2
    .long 0x1BA8, 0x1BA9, 2
    .long 0x1BAA, 0x1BAA, 2
    .long 0x1BAB, 0x1BAB, 3
    .long 0x1BAC, 0x1BAD, 2
    .long 0x1BAE, 0x1BAF, 1
    .long 0x1BBB, 0x1BBD, 1
    .long 0x1BE6, 0x1BE6, 2
    .long 0x1BE8, 0x1BE9, 2
    .long 0x1BED, 0x1BED, 2
    .long 0x1BEF, 0x1BF1, 2
    .long 0x1BF2, 0x1BF3, 2
    .long 0x1C2C, 0x1C33, 2
    .long 0x1C36, 0x1C37, 2
    .long 0x1CD0, 0x1CD2, 2
    .long 0x1CD4, 0x1CE0, 2
    .long 0x1CE2, 0x1CE8, 2
    .long 0x1CED, 0x1CED, 2
    .long 0x1CF4, 0x1CF4, 2
    .long 0x1CF5, 0x1CF6, 3
    .long 0x1CF8, 0x1CF9, 2
    .long 0x1DC0, 0x1DFF, 2
    .long 0x200D, 0x200D, 2
    .long 0x20D0, 0x20DC, 2
    .long 0x20DD, 0x20E0, 2
    .long 0x20E1, 0x20E1, 2
    .long 0x20E2, 0x20E4, 2
    .long 0x20E5, 0x20F0, 2
    .long 0x2CEF, 0x2CF1, 2
    .long 0x2D7F, 0x2D7F, 2
    .long 0x2DE0, 0x2DFF, 2
    .long 0x302A, 0x302D, 2
    .long 0x302E, 0x302F, 2
    .long 0x3099, 0x309A, 2
    .long 0xA66F, 0xA66F, 2
    .long 0xA670, 0xA672, 2
    .long 0xA674, 0xA67D, 2
    .long 0xA69E, 0xA69F, 2
    .long 0xA6F0, 0xA6F1, 2
    .long 0xA802, 0xA802, 2
    .long 0xA806, 0xA806, 2
    .long 0xA80B, 0xA80B, 2
    .long 0xA825, 0xA826, 2
    .long 0xA82C, 0xA82C, 2
    .long 0xA8C4, 0xA8C5, 2
    .long 0xA8E0, 0xA8F1, 2
    .long 0xA8FF, 0xA8FF, 2
    .long 0xA926, 0xA92D, 2
    .long 0xA947, 0xA951, 2
    .long 0xA953, 0xA953, 2
    .long 0xA980, 0xA982, 2
    .long 0xA989, 0xA98B, 1
    .long 0xA98F, 0xA9B2, 1
    .long 0xA9B3, 0xA9B3, 2
    .long 0xA9B6, 0xA9B9, 2
    .long 0xA9BC, 0xA9BD, 2
    .long 0xA9C0, 0xA9C0, 3
    .long 0xA9E0, 0xA9E4, 1
    .long 0xA9E5, 0xA9E5, 2
    .long 0xA9E7, 0xA9EF, 1
    .long 0xA9FA, 0xA9FE, 1
    .long 0xAA29, 0xAA2E, 2
    .long 0xAA31, 0xAA32, 2
    .long 0xAA35, 0xAA36, 2
    .long 0xAA43, 0xAA43, 2
    .long 0xAA4C, 0xAA4C, 2
    .long 0xAA60, 0xAA6F, 1
    .long 0xAA71, 0xAA73, 1
    .long 0xAA7A, 0xAA7A, 1
    .long 0xAA7C, 0xAA7C, 2
    .long 0xAA7E, 0xAA7F, 1
    .long 0xAAB0, 0xAAB0, 2
    .long 0xAAB2, 0xAAB4, 2
    .long 0xAAB7, 0xAAB8, 2
    .long 0xAABE, 0xAABF, 2
    .long 0xAAC1, 0xAAC1, 2
    .long 0xAAE0, 0xAAEA, 1
    .long 0xAAEC, 0xAAED, 2
    .long 0xAAF6, 0xAAF6, 3
    .long 0xABC0, 0xABDA, 1
    .long 0xABE5, 0xABE5, 2
    .long 0xABE8, 0xABE8, 2
    .long 0xABED, 0xABED, 2
    .long 0xFB1E, 0xFB1E, 2
    .long 0xFE00, 0xFE0F, 2
    .long 0xFE20, 0xFE2F, 2
    .long 0xFF9E, 0xFF9F, 2
    .long 0x101FD, 0x101FD, 2
    .long 0x102E0, 0x102E0, 2
    .long 0x10376, 0x1037A, 2
    .long 0x10A00, 0x10A00, 1
    .long 0x10A01, 0x10A03, 2
    .long 0x10A05, 0x10A06, 2
    .long 0x10A0C, 0x10A0F, 2
    .long 0x10A10, 0x10A13, 1
    .long 0x10A15, 0x10A17, 1
    .long 0x10A19, 0x10A35, 1
    .long 0x10A38, 0x10A3A, 2
    .long 0x10A3F, 0x10A3F, 3
    .long 0x10AE5, 0x10AE6, 2
    .long 0x10D24, 0x10D27, 2
    .long 0x10D69, 0x10D6D, 2
    .long 0x10EAB, 0x10EAC, 2
    .long 0x10ECB, 0x10ECF, 2
    .long 0x10EF0, 0x10EFF, 2
    .long 0x10F46, 0x10F50, 2
    .long 0x10F82, 0x10F85, 2
    .long 0x11001, 0x11001, 2
    .long 0x11038, 0x11046, 2
    .long 0x11070, 0x11070, 2
    .long 0x11073, 0x11074, 2
    .long 0x1107F, 0x11081, 2
    .long 0x110B3, 0x110B6, 2
    .long 0x110B9, 0x110BA, 2
    .long 0x110C2, 0x110C2, 2
    .long 0x11100, 0x11102, 2
    .long 0x11103, 0x11126, 1
    .long 0x11127, 0x1112B, 2
    .long 0x1112D, 0x11132, 2
    .long 0x11133, 0x11133, 3
    .long 0x11134, 0x11134, 2
    .long 0x11144, 0x11144, 1
    .long 0x11147, 0x11147, 1
    .long 0x11173, 0x11173, 2
    .long 0x11180, 0x11181, 2
    .long 0x111B6, 0x111BE, 2
    .long 0x111C0, 0x111C0, 2
    .long 0x111C9, 0x111CC, 2
    .long 0x111CF, 0x111CF, 2
    .long 0x1122F, 0x11231, 2
    .long 0x11234, 0x11234, 2
    .long 0x11235, 0x11235, 2
    .long 0x11236, 0x11237, 2
    .long 0x1123E, 0x1123E, 2
    .long 0x11241, 0x11241, 2
    .long 0x112DF, 0x112DF, 2
    .long 0x112E3, 0x112EA, 2
    .long 0x11300, 0x11301, 2
    .long 0x1133B, 0x1133C, 2
    .long 0x1133E, 0x1133E, 2
    .long 0x11340, 0x11340, 2
    .long 0x1134D, 0x1134D, 2
    .long 0x11357, 0x11357, 2
    .long 0x11366, 0x1136C, 2
    .long 0x11370, 0x11374, 2
    .long 0x11380, 0x11389, 1
    .long 0x1138B, 0x1138B, 1
    .long 0x1138E, 0x1138E, 1
    .long 0x11390, 0x113B5, 1
    .long 0x113B8, 0x113B8, 2
    .long 0x113BB, 0x113C0, 2
    .long 0x113C2, 0x113C2, 2
    .long 0x113C5, 0x113C5, 2
    .long 0x113C7, 0x113C9, 2
    .long 0x113CE, 0x113CE, 2
    .long 0x113CF, 0x113CF, 2
    .long 0x113D0, 0x113D0, 3
    .long 0x113D2, 0x113D2, 2
    .long 0x113E1, 0x113E2, 2
    .long 0x11438, 0x1143F, 2
    .long 0x11442, 0x11444, 2
    .long 0x11446, 0x11446, 2
    .long 0x1145E, 0x1145E, 2
    .long 0x114B0, 0x114B0, 2
    .long 0x114B3, 0x114B8, 2
    .long 0x114BA, 0x114BA, 2
    .long 0x114BD, 0x114BD, 2
    .long 0x114BF, 0x114C0, 2
    .long 0x114C2, 0x114C3, 2
    .long 0x115AF, 0x115AF, 2
    .long 0x115B2, 0x115B5, 2
    .long 0x115BC, 0x115BD, 2
    .long 0x115BF, 0x115C0, 2
    .long 0x115DC, 0x115DD, 2
    .long 0x11633, 0x1163A, 2
    .long 0x1163D, 0x1163D, 2
    .long 0x1163F, 0x11640, 2
    .long 0x116AB, 0x116AB, 2
    .long 0x116AD, 0x116AD, 2
    .long 0x116B0, 0x116B5, 2
    .long 0x116B6, 0x116B6, 2
    .long 0x116B7, 0x116B7, 2
    .long 0x1171D, 0x1171D, 2
    .long 0x1171F, 0x1171F, 2
    .long 0x11722, 0x11725, 2
    .long 0x11727, 0x1172B, 2
    .long 0x1182F, 0x11837, 2
    .long 0x11839, 0x1183A, 2
    .long 0x11900, 0x11906, 1
    .long 0x11909, 0x11909, 1
    .long 0x1190C, 0x11913, 1
    .long 0x11915, 0x11916, 1
    .long 0x11918, 0x1192F, 1
    .long 0x11930, 0x11930, 2
    .long 0x1193B, 0x1193C, 2
    .long 0x1193D, 0x1193D, 2
    .long 0x1193E, 0x1193E, 3
    .long 0x11943, 0x11943, 2
    .long 0x119D4, 0x119D7, 2
    .long 0x119DA, 0x119DB, 2
    .long 0x119E0, 0x119E0, 2
    .long 0x11A00, 0x11A00, 1
    .long 0x11A01, 0x11A0A, 2
    .long 0x11A0B, 0x11A32, 1
    .long 0x11A33, 0x11A38, 2
    .long 0x11A3A, 0x11A3A, 3
    .long 0x11A3B, 0x11A3E, 2
    .long 0x11A47, 0x11A47, 3
    .long 0x11A50, 0x11A50, 1
    .long 0x11A51, 0x11A56, 2
    .long 0x11A59, 0x11A5B, 2
    .long 0x11A5C, 0x11A83, 1
    .long 0x11A8A, 0x11A96, 2
    .long 0x11A98, 0x11A98, 2
    .long 0x11A99, 0x11A99, 3
    .long 0x11B0A, 0x11B0A, 1
    .long 0x11B60, 0x11B60, 2
    .long 0x11B62, 0x11B64, 2
    .long 0x11B66, 0x11B66, 2
    .long 0x11C30, 0x11C36, 2
    .long 0x11C38, 0x11C3D, 2
    .long 0x11C3F, 0x11C3F, 2
    .long 0x11C92, 0x11CA7, 2
    .long 0x11CAA, 0x11CB0, 2
    .long 0x11CB2, 0x11CB3, 2
    .long 0x11CB5, 0x11CB6, 2
    .long 0x11D31, 0x11D36, 2
    .long 0x11D3A, 0x11D3A, 2
    .long 0x11D3C, 0x11D3D, 2
    .long 0x11D3F, 0x11D45, 2
    .long 0x11D47, 0x11D47, 2
    .long 0x11D90, 0x11D91, 2
    .long 0x11D95, 0x11D95, 2
    .long 0x11D97, 0x11D97, 2
    .long 0x11DF0, 0x11DF0, 2
    .long 0x11DF1, 0x11DF1, 1
    .long 0x11EF3, 0x11EF4, 2
    .long 0x11F00, 0x11F01, 2
    .long 0x11F04, 0x11F10, 1
    .long 0x11F12, 0x11F33, 1
    .long 0x11F36, 0x11F3A, 2
    .long 0x11F40, 0x11F40, 2
    .long 0x11F41, 0x11F41, 2
    .long 0x11F42, 0x11F42, 3
    .long 0x11F5A, 0x11F5A, 2
    .long 0x13440, 0x13440, 2
    .long 0x13447, 0x13455, 2
    .long 0x1611E, 0x16129, 2
    .long 0x1612D, 0x1612F, 2
    .long 0x16AF0, 0x16AF4, 2
    .long 0x16B30, 0x16B36, 2
    .long 0x16F4F, 0x16F4F, 2
    .long 0x16F8F, 0x16F92, 2
    .long 0x16FE4, 0x16FE4, 2
    .long 0x16FF0, 0x16FF1, 2
    .long 0x1BC9D, 0x1BC9E, 2
    .long 0x1CF00, 0x1CF2D, 2
    .long 0x1CF30, 0x1CF46, 2
    .long 0x1D127, 0x1D128, 2
    .long 0x1D165, 0x1D166, 2
    .long 0x1D167, 0x1D169, 2
    .long 0x1D16D, 0x1D172, 2
    .long 0x1D17B, 0x1D182, 2
    .long 0x1D185, 0x1D18B, 2
    .long 0x1D1AA, 0x1D1AD, 2
    .long 0x1D242, 0x1D244, 2
    .long 0x1D250, 0x1D252, 2
    .long 0x1D25B, 0x1D25C, 2
    .long 0x1D25F, 0x1D25F, 2
    .long 0x1D280, 0x1D281, 2
    .long 0x1DA00, 0x1DA36, 2
    .long 0x1DA3B, 0x1DA6C, 2
    .long 0x1DA75, 0x1DA75, 2
    .long 0x1DA84, 0x1DA84, 2
    .long 0x1DA9B, 0x1DA9F, 2
    .long 0x1DAA1, 0x1DAAF, 2
    .long 0x1E000, 0x1E006, 2
    .long 0x1E008, 0x1E018, 2
    .long 0x1E01B, 0x1E021, 2
    .long 0x1E023, 0x1E024, 2
    .long 0x1E026, 0x1E02A, 2
    .long 0x1E08F, 0x1E08F, 2
    .long 0x1E130, 0x1E136, 2
    .long 0x1E2AE, 0x1E2AE, 2
    .long 0x1E2EC, 0x1E2EF, 2
    .long 0x1E4EC, 0x1E4EF, 2
    .long 0x1E5EE, 0x1E5EF, 2
    .long 0x1E6E3, 0x1E6E3, 2
    .long 0x1E6E6, 0x1E6E6, 2
    .long 0x1E6EE, 0x1E6EF, 2
    .long 0x1E6F5, 0x1E6F5, 2
    .long 0x1E8D0, 0x1E8D6, 2
    .long 0x1E944, 0x1E94A, 2
    .long 0x1F3FB, 0x1F3FF, 2
    .long 0xE0020, 0xE007F, 2
    .long 0xE0100, 0xE01EF, 2
unicode_incb_ranges_end:

# Extended_Pictographic ranges: true=1.
.balign 4
unicode_extended_pictographic_ranges:
    .long 0xA9, 0xA9, 1
    .long 0xAE, 0xAE, 1
    .long 0x203C, 0x203C, 1
    .long 0x2049, 0x2049, 1
    .long 0x2122, 0x2122, 1
    .long 0x2139, 0x2139, 1
    .long 0x2194, 0x2199, 1
    .long 0x21A9, 0x21AA, 1
    .long 0x231A, 0x231B, 1
    .long 0x2328, 0x2328, 1
    .long 0x23CF, 0x23CF, 1
    .long 0x23E9, 0x23EC, 1
    .long 0x23ED, 0x23EE, 1
    .long 0x23EF, 0x23EF, 1
    .long 0x23F0, 0x23F0, 1
    .long 0x23F1, 0x23F2, 1
    .long 0x23F3, 0x23F3, 1
    .long 0x23F8, 0x23FA, 1
    .long 0x24C2, 0x24C2, 1
    .long 0x25AA, 0x25AB, 1
    .long 0x25B6, 0x25B6, 1
    .long 0x25C0, 0x25C0, 1
    .long 0x25FB, 0x25FE, 1
    .long 0x2600, 0x2601, 1
    .long 0x2602, 0x2603, 1
    .long 0x2604, 0x2604, 1
    .long 0x260E, 0x260E, 1
    .long 0x2611, 0x2611, 1
    .long 0x2614, 0x2615, 1
    .long 0x2618, 0x2618, 1
    .long 0x261D, 0x261D, 1
    .long 0x2620, 0x2620, 1
    .long 0x2622, 0x2623, 1
    .long 0x2626, 0x2626, 1
    .long 0x262A, 0x262A, 1
    .long 0x262E, 0x262E, 1
    .long 0x262F, 0x262F, 1
    .long 0x2638, 0x2639, 1
    .long 0x263A, 0x263A, 1
    .long 0x2640, 0x2640, 1
    .long 0x2642, 0x2642, 1
    .long 0x2648, 0x2653, 1
    .long 0x265F, 0x265F, 1
    .long 0x2660, 0x2660, 1
    .long 0x2663, 0x2663, 1
    .long 0x2665, 0x2666, 1
    .long 0x2668, 0x2668, 1
    .long 0x267B, 0x267B, 1
    .long 0x267E, 0x267E, 1
    .long 0x267F, 0x267F, 1
    .long 0x2692, 0x2692, 1
    .long 0x2693, 0x2693, 1
    .long 0x2694, 0x2694, 1
    .long 0x2695, 0x2695, 1
    .long 0x2696, 0x2697, 1
    .long 0x2699, 0x2699, 1
    .long 0x269B, 0x269C, 1
    .long 0x26A0, 0x26A1, 1
    .long 0x26A7, 0x26A7, 1
    .long 0x26AA, 0x26AB, 1
    .long 0x26B0, 0x26B1, 1
    .long 0x26BD, 0x26BE, 1
    .long 0x26C4, 0x26C5, 1
    .long 0x26C8, 0x26C8, 1
    .long 0x26CE, 0x26CE, 1
    .long 0x26CF, 0x26CF, 1
    .long 0x26D1, 0x26D1, 1
    .long 0x26D3, 0x26D3, 1
    .long 0x26D4, 0x26D4, 1
    .long 0x26E9, 0x26E9, 1
    .long 0x26EA, 0x26EA, 1
    .long 0x26F0, 0x26F1, 1
    .long 0x26F2, 0x26F3, 1
    .long 0x26F4, 0x26F4, 1
    .long 0x26F5, 0x26F5, 1
    .long 0x26F7, 0x26F9, 1
    .long 0x26FA, 0x26FA, 1
    .long 0x26FD, 0x26FD, 1
    .long 0x2702, 0x2702, 1
    .long 0x2705, 0x2705, 1
    .long 0x2708, 0x270C, 1
    .long 0x270D, 0x270D, 1
    .long 0x270F, 0x270F, 1
    .long 0x2712, 0x2712, 1
    .long 0x2714, 0x2714, 1
    .long 0x2716, 0x2716, 1
    .long 0x271D, 0x271D, 1
    .long 0x2721, 0x2721, 1
    .long 0x2728, 0x2728, 1
    .long 0x2733, 0x2734, 1
    .long 0x2744, 0x2744, 1
    .long 0x2747, 0x2747, 1
    .long 0x274C, 0x274C, 1
    .long 0x274E, 0x274E, 1
    .long 0x2753, 0x2755, 1
    .long 0x2757, 0x2757, 1
    .long 0x2763, 0x2763, 1
    .long 0x2764, 0x2764, 1
    .long 0x2795, 0x2797, 1
    .long 0x27A1, 0x27A1, 1
    .long 0x27B0, 0x27B0, 1
    .long 0x27BF, 0x27BF, 1
    .long 0x2934, 0x2935, 1
    .long 0x2B05, 0x2B07, 1
    .long 0x2B1B, 0x2B1C, 1
    .long 0x2B50, 0x2B50, 1
    .long 0x2B55, 0x2B55, 1
    .long 0x3030, 0x3030, 1
    .long 0x303D, 0x303D, 1
    .long 0x3297, 0x3297, 1
    .long 0x3299, 0x3299, 1
    .long 0x1F004, 0x1F004, 1
    .long 0x1F02C, 0x1F02F, 1
    .long 0x1F094, 0x1F09F, 1
    .long 0x1F0AF, 0x1F0B0, 1
    .long 0x1F0C0, 0x1F0C0, 1
    .long 0x1F0CF, 0x1F0CF, 1
    .long 0x1F0D0, 0x1F0D0, 1
    .long 0x1F0F6, 0x1F0FF, 1
    .long 0x1F170, 0x1F171, 1
    .long 0x1F17E, 0x1F17F, 1
    .long 0x1F18E, 0x1F18E, 1
    .long 0x1F191, 0x1F19A, 1
    .long 0x1F1AF, 0x1F1E5, 1
    .long 0x1F201, 0x1F202, 1
    .long 0x1F203, 0x1F20F, 1
    .long 0x1F21A, 0x1F21A, 1
    .long 0x1F22F, 0x1F22F, 1
    .long 0x1F232, 0x1F23A, 1
    .long 0x1F23C, 0x1F23F, 1
    .long 0x1F249, 0x1F24F, 1
    .long 0x1F250, 0x1F251, 1
    .long 0x1F252, 0x1F25F, 1
    .long 0x1F266, 0x1F2FF, 1
    .long 0x1F300, 0x1F30C, 1
    .long 0x1F30D, 0x1F30E, 1
    .long 0x1F30F, 0x1F30F, 1
    .long 0x1F310, 0x1F310, 1
    .long 0x1F311, 0x1F311, 1
    .long 0x1F312, 0x1F312, 1
    .long 0x1F313, 0x1F315, 1
    .long 0x1F316, 0x1F318, 1
    .long 0x1F319, 0x1F319, 1
    .long 0x1F31A, 0x1F31A, 1
    .long 0x1F31B, 0x1F31B, 1
    .long 0x1F31C, 0x1F31C, 1
    .long 0x1F31D, 0x1F31E, 1
    .long 0x1F31F, 0x1F320, 1
    .long 0x1F321, 0x1F321, 1
    .long 0x1F324, 0x1F32C, 1
    .long 0x1F32D, 0x1F32F, 1
    .long 0x1F330, 0x1F331, 1
    .long 0x1F332, 0x1F333, 1
    .long 0x1F334, 0x1F335, 1
    .long 0x1F336, 0x1F336, 1
    .long 0x1F337, 0x1F34A, 1
    .long 0x1F34B, 0x1F34B, 1
    .long 0x1F34C, 0x1F34F, 1
    .long 0x1F350, 0x1F350, 1
    .long 0x1F351, 0x1F37B, 1
    .long 0x1F37C, 0x1F37C, 1
    .long 0x1F37D, 0x1F37D, 1
    .long 0x1F37E, 0x1F37F, 1
    .long 0x1F380, 0x1F393, 1
    .long 0x1F396, 0x1F397, 1
    .long 0x1F399, 0x1F39B, 1
    .long 0x1F39E, 0x1F39F, 1
    .long 0x1F3A0, 0x1F3C4, 1
    .long 0x1F3C5, 0x1F3C5, 1
    .long 0x1F3C6, 0x1F3C6, 1
    .long 0x1F3C7, 0x1F3C7, 1
    .long 0x1F3C8, 0x1F3C8, 1
    .long 0x1F3C9, 0x1F3C9, 1
    .long 0x1F3CA, 0x1F3CA, 1
    .long 0x1F3CB, 0x1F3CE, 1
    .long 0x1F3CF, 0x1F3D3, 1
    .long 0x1F3D4, 0x1F3DF, 1
    .long 0x1F3E0, 0x1F3E3, 1
    .long 0x1F3E4, 0x1F3E4, 1
    .long 0x1F3E5, 0x1F3F0, 1
    .long 0x1F3F3, 0x1F3F3, 1
    .long 0x1F3F4, 0x1F3F4, 1
    .long 0x1F3F5, 0x1F3F5, 1
    .long 0x1F3F7, 0x1F3F7, 1
    .long 0x1F3F8, 0x1F3FA, 1
    .long 0x1F400, 0x1F407, 1
    .long 0x1F408, 0x1F408, 1
    .long 0x1F409, 0x1F40B, 1
    .long 0x1F40C, 0x1F40E, 1
    .long 0x1F40F, 0x1F410, 1
    .long 0x1F411, 0x1F412, 1
    .long 0x1F413, 0x1F413, 1
    .long 0x1F414, 0x1F414, 1
    .long 0x1F415, 0x1F415, 1
    .long 0x1F416, 0x1F416, 1
    .long 0x1F417, 0x1F429, 1
    .long 0x1F42A, 0x1F42A, 1
    .long 0x1F42B, 0x1F43E, 1
    .long 0x1F43F, 0x1F43F, 1
    .long 0x1F440, 0x1F440, 1
    .long 0x1F441, 0x1F441, 1
    .long 0x1F442, 0x1F464, 1
    .long 0x1F465, 0x1F465, 1
    .long 0x1F466, 0x1F46B, 1
    .long 0x1F46C, 0x1F46D, 1
    .long 0x1F46E, 0x1F4AC, 1
    .long 0x1F4AD, 0x1F4AD, 1
    .long 0x1F4AE, 0x1F4B5, 1
    .long 0x1F4B6, 0x1F4B7, 1
    .long 0x1F4B8, 0x1F4EB, 1
    .long 0x1F4EC, 0x1F4ED, 1
    .long 0x1F4EE, 0x1F4EE, 1
    .long 0x1F4EF, 0x1F4EF, 1
    .long 0x1F4F0, 0x1F4F4, 1
    .long 0x1F4F5, 0x1F4F5, 1
    .long 0x1F4F6, 0x1F4F7, 1
    .long 0x1F4F8, 0x1F4F8, 1
    .long 0x1F4F9, 0x1F4FC, 1
    .long 0x1F4FD, 0x1F4FD, 1
    .long 0x1F4FF, 0x1F502, 1
    .long 0x1F503, 0x1F503, 1
    .long 0x1F504, 0x1F507, 1
    .long 0x1F508, 0x1F508, 1
    .long 0x1F509, 0x1F509, 1
    .long 0x1F50A, 0x1F514, 1
    .long 0x1F515, 0x1F515, 1
    .long 0x1F516, 0x1F52B, 1
    .long 0x1F52C, 0x1F52D, 1
    .long 0x1F52E, 0x1F53D, 1
    .long 0x1F549, 0x1F54A, 1
    .long 0x1F54B, 0x1F54E, 1
    .long 0x1F550, 0x1F55B, 1
    .long 0x1F55C, 0x1F567, 1
    .long 0x1F56F, 0x1F570, 1
    .long 0x1F573, 0x1F579, 1
    .long 0x1F57A, 0x1F57A, 1
    .long 0x1F587, 0x1F587, 1
    .long 0x1F58A, 0x1F58D, 1
    .long 0x1F590, 0x1F590, 1
    .long 0x1F595, 0x1F596, 1
    .long 0x1F5A4, 0x1F5A4, 1
    .long 0x1F5A5, 0x1F5A5, 1
    .long 0x1F5A8, 0x1F5A8, 1
    .long 0x1F5B1, 0x1F5B2, 1
    .long 0x1F5BC, 0x1F5BC, 1
    .long 0x1F5C2, 0x1F5C4, 1
    .long 0x1F5D1, 0x1F5D3, 1
    .long 0x1F5DC, 0x1F5DE, 1
    .long 0x1F5E1, 0x1F5E1, 1
    .long 0x1F5E3, 0x1F5E3, 1
    .long 0x1F5E8, 0x1F5E8, 1
    .long 0x1F5EF, 0x1F5EF, 1
    .long 0x1F5F3, 0x1F5F3, 1
    .long 0x1F5FA, 0x1F5FA, 1
    .long 0x1F5FB, 0x1F5FF, 1
    .long 0x1F600, 0x1F600, 1
    .long 0x1F601, 0x1F606, 1
    .long 0x1F607, 0x1F608, 1
    .long 0x1F609, 0x1F60D, 1
    .long 0x1F60E, 0x1F60E, 1
    .long 0x1F60F, 0x1F60F, 1
    .long 0x1F610, 0x1F610, 1
    .long 0x1F611, 0x1F611, 1
    .long 0x1F612, 0x1F614, 1
    .long 0x1F615, 0x1F615, 1
    .long 0x1F616, 0x1F616, 1
    .long 0x1F617, 0x1F617, 1
    .long 0x1F618, 0x1F618, 1
    .long 0x1F619, 0x1F619, 1
    .long 0x1F61A, 0x1F61A, 1
    .long 0x1F61B, 0x1F61B, 1
    .long 0x1F61C, 0x1F61E, 1
    .long 0x1F61F, 0x1F61F, 1
    .long 0x1F620, 0x1F625, 1
    .long 0x1F626, 0x1F627, 1
    .long 0x1F628, 0x1F62B, 1
    .long 0x1F62C, 0x1F62C, 1
    .long 0x1F62D, 0x1F62D, 1
    .long 0x1F62E, 0x1F62F, 1
    .long 0x1F630, 0x1F633, 1
    .long 0x1F634, 0x1F634, 1
    .long 0x1F635, 0x1F635, 1
    .long 0x1F636, 0x1F636, 1
    .long 0x1F637, 0x1F640, 1
    .long 0x1F641, 0x1F644, 1
    .long 0x1F645, 0x1F64F, 1
    .long 0x1F680, 0x1F680, 1
    .long 0x1F681, 0x1F682, 1
    .long 0x1F683, 0x1F685, 1
    .long 0x1F686, 0x1F686, 1
    .long 0x1F687, 0x1F687, 1
    .long 0x1F688, 0x1F688, 1
    .long 0x1F689, 0x1F689, 1
    .long 0x1F68A, 0x1F68B, 1
    .long 0x1F68C, 0x1F68C, 1
    .long 0x1F68D, 0x1F68D, 1
    .long 0x1F68E, 0x1F68E, 1
    .long 0x1F68F, 0x1F68F, 1
    .long 0x1F690, 0x1F690, 1
    .long 0x1F691, 0x1F693, 1
    .long 0x1F694, 0x1F694, 1
    .long 0x1F695, 0x1F695, 1
    .long 0x1F696, 0x1F696, 1
    .long 0x1F697, 0x1F697, 1
    .long 0x1F698, 0x1F698, 1
    .long 0x1F699, 0x1F69A, 1
    .long 0x1F69B, 0x1F6A1, 1
    .long 0x1F6A2, 0x1F6A2, 1
    .long 0x1F6A3, 0x1F6A3, 1
    .long 0x1F6A4, 0x1F6A5, 1
    .long 0x1F6A6, 0x1F6A6, 1
    .long 0x1F6A7, 0x1F6AD, 1
    .long 0x1F6AE, 0x1F6B1, 1
    .long 0x1F6B2, 0x1F6B2, 1
    .long 0x1F6B3, 0x1F6B5, 1
    .long 0x1F6B6, 0x1F6B6, 1
    .long 0x1F6B7, 0x1F6B8, 1
    .long 0x1F6B9, 0x1F6BE, 1
    .long 0x1F6BF, 0x1F6BF, 1
    .long 0x1F6C0, 0x1F6C0, 1
    .long 0x1F6C1, 0x1F6C5, 1
    .long 0x1F6CB, 0x1F6CB, 1
    .long 0x1F6CC, 0x1F6CC, 1
    .long 0x1F6CD, 0x1F6CF, 1
    .long 0x1F6D0, 0x1F6D0, 1
    .long 0x1F6D1, 0x1F6D2, 1
    .long 0x1F6D5, 0x1F6D5, 1
    .long 0x1F6D6, 0x1F6D7, 1
    .long 0x1F6D8, 0x1F6D8, 1
    .long 0x1F6D9, 0x1F6D9, 1
    .long 0x1F6DA, 0x1F6DB, 1
    .long 0x1F6DC, 0x1F6DC, 1
    .long 0x1F6DD, 0x1F6DF, 1
    .long 0x1F6E0, 0x1F6E5, 1
    .long 0x1F6E9, 0x1F6E9, 1
    .long 0x1F6EB, 0x1F6EC, 1
    .long 0x1F6ED, 0x1F6EF, 1
    .long 0x1F6F0, 0x1F6F0, 1
    .long 0x1F6F3, 0x1F6F3, 1
    .long 0x1F6F4, 0x1F6F6, 1
    .long 0x1F6F7, 0x1F6F8, 1
    .long 0x1F6F9, 0x1F6F9, 1
    .long 0x1F6FA, 0x1F6FA, 1
    .long 0x1F6FB, 0x1F6FC, 1
    .long 0x1F6FD, 0x1F6FF, 1
    .long 0x1F7DC, 0x1F7DF, 1
    .long 0x1F7E0, 0x1F7EB, 1
    .long 0x1F7EC, 0x1F7EF, 1
    .long 0x1F7F0, 0x1F7F0, 1
    .long 0x1F80C, 0x1F80F, 1
    .long 0x1F848, 0x1F84F, 1
    .long 0x1F85A, 0x1F85F, 1
    .long 0x1F888, 0x1F88F, 1
    .long 0x1F8AE, 0x1F8AF, 1
    .long 0x1F8BC, 0x1F8BF, 1
    .long 0x1F8C2, 0x1F8CF, 1
    .long 0x1F8D9, 0x1F8FF, 1
    .long 0x1F90C, 0x1F90C, 1
    .long 0x1F90D, 0x1F90F, 1
    .long 0x1F910, 0x1F918, 1
    .long 0x1F919, 0x1F91E, 1
    .long 0x1F91F, 0x1F91F, 1
    .long 0x1F920, 0x1F927, 1
    .long 0x1F928, 0x1F92F, 1
    .long 0x1F930, 0x1F930, 1
    .long 0x1F931, 0x1F932, 1
    .long 0x1F933, 0x1F93A, 1
    .long 0x1F93C, 0x1F93E, 1
    .long 0x1F93F, 0x1F93F, 1
    .long 0x1F940, 0x1F945, 1
    .long 0x1F947, 0x1F94B, 1
    .long 0x1F94C, 0x1F94C, 1
    .long 0x1F94D, 0x1F94F, 1
    .long 0x1F950, 0x1F95E, 1
    .long 0x1F95F, 0x1F96B, 1
    .long 0x1F96C, 0x1F970, 1
    .long 0x1F971, 0x1F971, 1
    .long 0x1F972, 0x1F972, 1
    .long 0x1F973, 0x1F976, 1
    .long 0x1F977, 0x1F978, 1
    .long 0x1F979, 0x1F979, 1
    .long 0x1F97A, 0x1F97A, 1
    .long 0x1F97B, 0x1F97B, 1
    .long 0x1F97C, 0x1F97F, 1
    .long 0x1F980, 0x1F984, 1
    .long 0x1F985, 0x1F991, 1
    .long 0x1F992, 0x1F997, 1
    .long 0x1F998, 0x1F9A2, 1
    .long 0x1F9A3, 0x1F9A4, 1
    .long 0x1F9A5, 0x1F9AA, 1
    .long 0x1F9AB, 0x1F9AD, 1
    .long 0x1F9AE, 0x1F9AF, 1
    .long 0x1F9B0, 0x1F9B9, 1
    .long 0x1F9BA, 0x1F9BF, 1
    .long 0x1F9C0, 0x1F9C0, 1
    .long 0x1F9C1, 0x1F9C2, 1
    .long 0x1F9C3, 0x1F9CA, 1
    .long 0x1F9CB, 0x1F9CB, 1
    .long 0x1F9CC, 0x1F9CC, 1
    .long 0x1F9CD, 0x1F9CF, 1
    .long 0x1F9D0, 0x1F9E6, 1
    .long 0x1F9E7, 0x1F9FF, 1
    .long 0x1FA58, 0x1FA5F, 1
    .long 0x1FA6E, 0x1FA6F, 1
    .long 0x1FA70, 0x1FA73, 1
    .long 0x1FA74, 0x1FA74, 1
    .long 0x1FA75, 0x1FA77, 1
    .long 0x1FA78, 0x1FA7A, 1
    .long 0x1FA7B, 0x1FA7C, 1
    .long 0x1FA7D, 0x1FA7F, 1
    .long 0x1FA80, 0x1FA82, 1
    .long 0x1FA83, 0x1FA86, 1
    .long 0x1FA87, 0x1FA88, 1
    .long 0x1FA89, 0x1FA89, 1
    .long 0x1FA8A, 0x1FA8A, 1
    .long 0x1FA8B, 0x1FA8D, 1
    .long 0x1FA8E, 0x1FA8E, 1
    .long 0x1FA8F, 0x1FA8F, 1
    .long 0x1FA90, 0x1FA95, 1
    .long 0x1FA96, 0x1FAA8, 1
    .long 0x1FAA9, 0x1FAAC, 1
    .long 0x1FAAD, 0x1FAAF, 1
    .long 0x1FAB0, 0x1FAB6, 1
    .long 0x1FAB7, 0x1FABA, 1
    .long 0x1FABB, 0x1FABD, 1
    .long 0x1FABE, 0x1FABE, 1
    .long 0x1FABF, 0x1FABF, 1
    .long 0x1FAC0, 0x1FAC2, 1
    .long 0x1FAC3, 0x1FAC5, 1
    .long 0x1FAC6, 0x1FAC6, 1
    .long 0x1FAC7, 0x1FAC7, 1
    .long 0x1FAC8, 0x1FAC8, 1
    .long 0x1FAC9, 0x1FACB, 1
    .long 0x1FACC, 0x1FACC, 1
    .long 0x1FACD, 0x1FACD, 1
    .long 0x1FACE, 0x1FACF, 1
    .long 0x1FAD0, 0x1FAD6, 1
    .long 0x1FAD7, 0x1FAD9, 1
    .long 0x1FADA, 0x1FADB, 1
    .long 0x1FADC, 0x1FADC, 1
    .long 0x1FADD, 0x1FADD, 1
    .long 0x1FADE, 0x1FADE, 1
    .long 0x1FADF, 0x1FADF, 1
    .long 0x1FAE0, 0x1FAE7, 1
    .long 0x1FAE8, 0x1FAE8, 1
    .long 0x1FAE9, 0x1FAE9, 1
    .long 0x1FAEA, 0x1FAEA, 1
    .long 0x1FAEB, 0x1FAEB, 1
    .long 0x1FAEC, 0x1FAEE, 1
    .long 0x1FAEF, 0x1FAEF, 1
    .long 0x1FAF0, 0x1FAF6, 1
    .long 0x1FAF7, 0x1FAF8, 1
    .long 0x1FAF9, 0x1FAFA, 1
    .long 0x1FAFB, 0x1FAFF, 1
    .long 0x1FC00, 0x1FFFD, 1
unicode_extended_pictographic_ranges_end:


.Ldoc_compose_sequence_table:
    # 2140 two-symbol Multi_key rules: X.Org libX11 en_US.UTF-8
    # plus all 40 legacy editor pairs (which take precedence on overlap).
    # Record encoding: first scalar, second scalar, result scalar; zero first scalar terminates.
    .long 0x20, 0x20, 0xa0
    .long 0x20, 0x28, 0x2d8
    .long 0x20, 0x2c, 0xb8
    .long 0x20, 0x2d, 0x7e
    .long 0x20, 0x2e, 0x2008
    .long 0x20, 0x3c, 0x2c7
    .long 0x20, 0x3e, 0x5e
    .long 0x20, 0x5f, 0xaf
    .long 0x21, 0x21, 0xa1
    .long 0x21, 0x3d, 0x2260
    .long 0x21, 0x3f, 0x203d
    .long 0x21, 0x41, 0x1ea0
    .long 0x21, 0x42, 0x1e04
    .long 0x21, 0x44, 0x1e0c
    .long 0x21, 0x45, 0x1eb8
    .long 0x21, 0x48, 0x1e24
    .long 0x21, 0x49, 0x1eca
    .long 0x21, 0x4b, 0x1e32
    .long 0x21, 0x4c, 0x1e36
    .long 0x21, 0x4d, 0x1e42
    .long 0x21, 0x4e, 0x1e46
    .long 0x21, 0x4f, 0x1ecc
    .long 0x21, 0x52, 0x1e5a
    .long 0x21, 0x53, 0x1e62
    .long 0x21, 0x54, 0x1e6c
    .long 0x21, 0x55, 0x1ee4
    .long 0x21, 0x56, 0x1e7e
    .long 0x21, 0x57, 0x1e88
    .long 0x21, 0x59, 0x1ef4
    .long 0x21, 0x5a, 0x1e92
    .long 0x21, 0x5e, 0xa6
    .long 0x21, 0x61, 0x1ea1
    .long 0x21, 0x62, 0x1e05
    .long 0x21, 0x64, 0x1e0d
    .long 0x21, 0x65, 0x1eb9
    .long 0x21, 0x68, 0x1e25
    .long 0x21, 0x69, 0x1ecb
    .long 0x21, 0x6b, 0x1e33
    .long 0x21, 0x6c, 0x1e37
    .long 0x21, 0x6d, 0x1e43
    .long 0x21, 0x6e, 0x1e47
    .long 0x21, 0x6f, 0x1ecd
    .long 0x21, 0x72, 0x1e5b
    .long 0x21, 0x73, 0x1e63
    .long 0x21, 0x74, 0x1e6d
    .long 0x21, 0x75, 0x1ee5
    .long 0x21, 0x76, 0x1e7f
    .long 0x21, 0x77, 0x1e89
    .long 0x21, 0x79, 0x1ef5
    .long 0x21, 0x7a, 0x1e93
    .long 0x21, 0x1a0, 0x1ee2
    .long 0x21, 0x1a1, 0x1ee3
    .long 0x21, 0x1af, 0x1ef0
    .long 0x21, 0x1b0, 0x1ef1
    .long 0x22, 0x20, 0xa8
    .long 0x22, 0x22, 0xa8
    .long 0x22, 0x27, 0x344
    .long 0x22, 0x2c, 0x201e
    .long 0x22, 0x3c, 0x201c
    .long 0x22, 0x3e, 0x201d
    .long 0x22, 0x41, 0xc4
    .long 0x22, 0x45, 0xcb
    .long 0x22, 0x48, 0x1e26
    .long 0x22, 0x49, 0xcf
    .long 0x22, 0x4f, 0xd6
    .long 0x22, 0x55, 0xdc
    .long 0x22, 0x57, 0x1e84
    .long 0x22, 0x58, 0x1e8c
    .long 0x22, 0x59, 0x178
    .long 0x22, 0x61, 0xe4
    .long 0x22, 0x65, 0xeb
    .long 0x22, 0x68, 0x1e27
    .long 0x22, 0x69, 0xef
    .long 0x22, 0x6f, 0xf6
    .long 0x22, 0x74, 0x1e97
    .long 0x22, 0x75, 0xfc
    .long 0x22, 0x77, 0x1e85
    .long 0x22, 0x78, 0x1e8d
    .long 0x22, 0x79, 0xff
    .long 0x22, 0xb4, 0x344
    .long 0x22, 0xd5, 0x1e4e
    .long 0x22, 0xf5, 0x1e4f
    .long 0x22, 0x16a, 0x1e7a
    .long 0x22, 0x16b, 0x1e7b
    .long 0x22, 0x399, 0x3aa
    .long 0x22, 0x3a5, 0x3ab
    .long 0x22, 0x3b9, 0x3ca
    .long 0x22, 0x3c5, 0x3cb
    .long 0x22, 0x3d2, 0x3d4
    .long 0x22, 0x406, 0x407
    .long 0x22, 0x410, 0x4d2
    .long 0x22, 0x415, 0x401
    .long 0x22, 0x416, 0x4dc
    .long 0x22, 0x417, 0x4de
    .long 0x22, 0x418, 0x4e4
    .long 0x22, 0x41e, 0x4e6
    .long 0x22, 0x423, 0x4f0
    .long 0x22, 0x427, 0x4f4
    .long 0x22, 0x42b, 0x4f8
    .long 0x22, 0x42d, 0x4ec
    .long 0x22, 0x430, 0x4d3
    .long 0x22, 0x435, 0x451
    .long 0x22, 0x436, 0x4dd
    .long 0x22, 0x437, 0x4df
    .long 0x22, 0x438, 0x4e5
    .long 0x22, 0x43e, 0x4e7
    .long 0x22, 0x443, 0x4f1
    .long 0x22, 0x447, 0x4f5
    .long 0x22, 0x44b, 0x4f9
    .long 0x22, 0x44d, 0x4ed
    .long 0x22, 0x456, 0x457
    .long 0x22, 0x4d8, 0x4da
    .long 0x22, 0x4d9, 0x4db
    .long 0x22, 0x4e8, 0x4ea
    .long 0x22, 0x4e9, 0x4eb
    .long 0x23, 0x23, 0x266f
    .long 0x23, 0x45, 0x266b
    .long 0x23, 0x53, 0x266c
    .long 0x23, 0x62, 0x266d
    .long 0x23, 0x65, 0x266a
    .long 0x23, 0x66, 0x266e
    .long 0x23, 0x71, 0x2669
    .long 0x25, 0x6f, 0x2030
    .long 0x27, 0x27, 0xb4
    .long 0x27, 0x2c, 0x201a
    .long 0x27, 0x3c, 0x2018
    .long 0x27, 0x3e, 0x2019
    .long 0x27, 0x41, 0xc1
    .long 0x27, 0x43, 0x106
    .long 0x27, 0x45, 0xc9
    .long 0x27, 0x47, 0x1f4
    .long 0x27, 0x49, 0xcd
    .long 0x27, 0x4b, 0x1e30
    .long 0x27, 0x4c, 0x139
    .long 0x27, 0x4d, 0x1e3e
    .long 0x27, 0x4e, 0x143
    .long 0x27, 0x4f, 0xd3
    .long 0x27, 0x50, 0x1e54
    .long 0x27, 0x52, 0x154
    .long 0x27, 0x53, 0x15a
    .long 0x27, 0x55, 0xda
    .long 0x27, 0x57, 0x1e82
    .long 0x27, 0x59, 0xdd
    .long 0x27, 0x5a, 0x179
    .long 0x27, 0x61, 0xe1
    .long 0x27, 0x63, 0x107
    .long 0x27, 0x65, 0xe9
    .long 0x27, 0x67, 0x1f5
    .long 0x27, 0x69, 0xed
    .long 0x27, 0x6b, 0x1e31
    .long 0x27, 0x6c, 0x13a
    .long 0x27, 0x6d, 0x1e3f
    .long 0x27, 0x6e, 0x144
    .long 0x27, 0x6f, 0xf3
    .long 0x27, 0x70, 0x1e55
    .long 0x27, 0x72, 0x155
    .long 0x27, 0x73, 0x15b
    .long 0x27, 0x75, 0xfa
    .long 0x27, 0x77, 0x1e83
    .long 0x27, 0x79, 0xfd
    .long 0x27, 0x7a, 0x17a
    .long 0x27, 0xc2, 0x1ea4
    .long 0x27, 0xc5, 0x1fa
    .long 0x27, 0xc6, 0x1fc
    .long 0x27, 0xc7, 0x1e08
    .long 0x27, 0xca, 0x1ebe
    .long 0x27, 0xcf, 0x1e2e
    .long 0x27, 0xd4, 0x1ed0
    .long 0x27, 0xd5, 0x1e4c
    .long 0x27, 0xd8, 0x1fe
    .long 0x27, 0xdc, 0x1d7
    .long 0x27, 0xe2, 0x1ea5
    .long 0x27, 0xe5, 0x1fb
    .long 0x27, 0xe6, 0x1fd
    .long 0x27, 0xe7, 0x1e09
    .long 0x27, 0xea, 0x1ebf
    .long 0x27, 0xef, 0x1e2f
    .long 0x27, 0xf4, 0x1ed1
    .long 0x27, 0xf5, 0x1e4d
    .long 0x27, 0xf8, 0x1ff
    .long 0x27, 0xfc, 0x1d8
    .long 0x27, 0x102, 0x1eae
    .long 0x27, 0x103, 0x1eaf
    .long 0x27, 0x112, 0x1e16
    .long 0x27, 0x113, 0x1e17
    .long 0x27, 0x14c, 0x1e52
    .long 0x27, 0x14d, 0x1e53
    .long 0x27, 0x168, 0x1e78
    .long 0x27, 0x169, 0x1e79
    .long 0x27, 0x1a0, 0x1eda
    .long 0x27, 0x1a1, 0x1edb
    .long 0x27, 0x1af, 0x1ee8
    .long 0x27, 0x1b0, 0x1ee9
    .long 0x27, 0x391, 0x386
    .long 0x27, 0x395, 0x388
    .long 0x27, 0x397, 0x389
    .long 0x27, 0x399, 0x38a
    .long 0x27, 0x39f, 0x38c
    .long 0x27, 0x3a5, 0x38e
    .long 0x27, 0x3a9, 0x38f
    .long 0x27, 0x3b1, 0x3ac
    .long 0x27, 0x3b5, 0x3ad
    .long 0x27, 0x3b7, 0x3ae
    .long 0x27, 0x3b9, 0x3af
    .long 0x27, 0x3bf, 0x3cc
    .long 0x27, 0x3c5, 0x3cd
    .long 0x27, 0x3c9, 0x3ce
    .long 0x27, 0x3ca, 0x390
    .long 0x27, 0x3cb, 0x3b0
    .long 0x27, 0x413, 0x403
    .long 0x27, 0x41a, 0x40c
    .long 0x27, 0x433, 0x453
    .long 0x27, 0x43a, 0x45c
    .long 0x27, 0x1f00, 0x1f04
    .long 0x27, 0x1f01, 0x1f05
    .long 0x27, 0x1f08, 0x1f0c
    .long 0x27, 0x1f09, 0x1f0d
    .long 0x27, 0x1f10, 0x1f14
    .long 0x27, 0x1f11, 0x1f15
    .long 0x27, 0x1f18, 0x1f1c
    .long 0x27, 0x1f19, 0x1f1d
    .long 0x27, 0x1f20, 0x1f24
    .long 0x27, 0x1f21, 0x1f25
    .long 0x27, 0x1f28, 0x1f2c
    .long 0x27, 0x1f29, 0x1f2d
    .long 0x27, 0x1f30, 0x1f34
    .long 0x27, 0x1f31, 0x1f35
    .long 0x27, 0x1f38, 0x1f3c
    .long 0x27, 0x1f39, 0x1f3d
    .long 0x27, 0x1f40, 0x1f44
    .long 0x27, 0x1f41, 0x1f45
    .long 0x27, 0x1f48, 0x1f4c
    .long 0x27, 0x1f49, 0x1f4d
    .long 0x27, 0x1f50, 0x1f54
    .long 0x27, 0x1f51, 0x1f55
    .long 0x27, 0x1f59, 0x1f5d
    .long 0x27, 0x1f60, 0x1f64
    .long 0x27, 0x1f61, 0x1f65
    .long 0x27, 0x1f68, 0x1f6c
    .long 0x27, 0x1f69, 0x1f6d
    .long 0x27, 0x2395, 0x235e
    .long 0x28, 0x20, 0x2d8
    .long 0x28, 0x28, 0x5b
    .long 0x28, 0x2d, 0x7b
    .long 0x28, 0x391, 0x1f09
    .long 0x28, 0x395, 0x1f19
    .long 0x28, 0x397, 0x1f29
    .long 0x28, 0x399, 0x1f39
    .long 0x28, 0x39f, 0x1f49
    .long 0x28, 0x3a1, 0x1fec
    .long 0x28, 0x3a5, 0x1f59
    .long 0x28, 0x3a9, 0x1f69
    .long 0x28, 0x3b1, 0x1f01
    .long 0x28, 0x3b5, 0x1f11
    .long 0x28, 0x3b7, 0x1f21
    .long 0x28, 0x3b9, 0x1f31
    .long 0x28, 0x3bf, 0x1f41
    .long 0x28, 0x3c1, 0x1fe5
    .long 0x28, 0x3c5, 0x1f51
    .long 0x28, 0x3c9, 0x1f61
    .long 0x29, 0x29, 0x5d
    .long 0x29, 0x2d, 0x7d
    .long 0x29, 0x391, 0x1f08
    .long 0x29, 0x395, 0x1f18
    .long 0x29, 0x397, 0x1f28
    .long 0x29, 0x399, 0x1f38
    .long 0x29, 0x39f, 0x1f48
    .long 0x29, 0x3a9, 0x1f68
    .long 0x29, 0x3b1, 0x1f00
    .long 0x29, 0x3b5, 0x1f10
    .long 0x29, 0x3b7, 0x1f20
    .long 0x29, 0x3b9, 0x1f30
    .long 0x29, 0x3bf, 0x1f40
    .long 0x29, 0x3c1, 0x1fe4
    .long 0x29, 0x3c5, 0x1f50
    .long 0x29, 0x3c9, 0x1f60
    .long 0x2a, 0x2a, 0x2605
    .long 0x2a, 0x30, 0xb0
    .long 0x2a, 0x41, 0xc5
    .long 0x2a, 0x55, 0x16e
    .long 0x2a, 0x61, 0xe5
    .long 0x2a, 0x75, 0x16f
    .long 0x2a, 0xa8, 0x2363
    .long 0x2a, 0x25cb, 0x235f
    .long 0x2b, 0x2b, 0x23
    .long 0x2b, 0x2d, 0xb1
    .long 0x2b, 0x4f, 0x1a0
    .long 0x2b, 0x55, 0x1af
    .long 0x2b, 0x6f, 0x1a1
    .long 0x2b, 0x75, 0x1b0
    .long 0x2c, 0x20, 0xb8
    .long 0x2c, 0x22, 0x201e
    .long 0x2c, 0x27, 0x201a
    .long 0x2c, 0x2c, 0xb8
    .long 0x2c, 0x2d, 0xac
    .long 0x2c, 0x41, 0x104
    .long 0x2c, 0x43, 0xc7
    .long 0x2c, 0x44, 0x1e10
    .long 0x2c, 0x45, 0x118
    .long 0x2c, 0x47, 0x122
    .long 0x2c, 0x48, 0x1e28
    .long 0x2c, 0x49, 0x12e
    .long 0x2c, 0x4b, 0x136
    .long 0x2c, 0x4c, 0x13b
    .long 0x2c, 0x4e, 0x145
    .long 0x2c, 0x4f, 0x1ea
    .long 0x2c, 0x52, 0x156
    .long 0x2c, 0x53, 0x15e
    .long 0x2c, 0x54, 0x162
    .long 0x2c, 0x55, 0x172
    .long 0x2c, 0x61, 0x105
    .long 0x2c, 0x63, 0xe7
    .long 0x2c, 0x64, 0x1e11
    .long 0x2c, 0x65, 0x119
    .long 0x2c, 0x67, 0x123
    .long 0x2c, 0x68, 0x1e29
    .long 0x2c, 0x69, 0x12f
    .long 0x2c, 0x6b, 0x137
    .long 0x2c, 0x6c, 0x13c
    .long 0x2c, 0x6e, 0x146
    .long 0x2c, 0x6f, 0x1eb
    .long 0x2c, 0x72, 0x157
    .long 0x2c, 0x73, 0x15f
    .long 0x2c, 0x74, 0x163
    .long 0x2c, 0x75, 0x173
    .long 0x2d, 0x20, 0x7e
    .long 0x2d, 0x28, 0x7b
    .long 0x2d, 0x29, 0x7d
    .long 0x2d, 0x2b, 0xb1
    .long 0x2d, 0x2c, 0xac
    .long 0x2d, 0x2f, 0x233f
    .long 0x2d, 0x3a, 0xf7
    .long 0x2d, 0x3e, 0x2192
    .long 0x2d, 0x41, 0x100
    .long 0x2d, 0x44, 0x110
    .long 0x2d, 0x45, 0x112
    .long 0x2d, 0x49, 0x12a
    .long 0x2d, 0x4c, 0xa3
    .long 0x2d, 0x4f, 0x14c
    .long 0x2d, 0x55, 0x16a
    .long 0x2d, 0x59, 0xa5
    .long 0x2d, 0x5c, 0x2340
    .long 0x2d, 0x5e, 0xaf
    .long 0x2d, 0x5f, 0x2212
    .long 0x2d, 0x61, 0x101
    .long 0x2d, 0x64, 0x111
    .long 0x2d, 0x65, 0x113
    .long 0x2d, 0x69, 0x12b
    .long 0x2d, 0x6c, 0xa3
    .long 0x2d, 0x6f, 0x14d
    .long 0x2d, 0x75, 0x16b
    .long 0x2d, 0x79, 0xa5
    .long 0x2d, 0x2191, 0x234f
    .long 0x2d, 0x2193, 0x2356
    .long 0x2d, 0x25cb, 0x2296
    .long 0x2e, 0x20, 0x2d9
    .long 0x2e, 0x2d, 0xb7
    .long 0x2e, 0x2e, 0x2026
    .long 0x2e, 0x3a, 0x2235
    .long 0x2e, 0x3c, 0x2039
    .long 0x2e, 0x3d, 0x2022
    .long 0x2e, 0x3e, 0x203a
    .long 0x2e, 0x41, 0x226
    .long 0x2e, 0x42, 0x1e02
    .long 0x2e, 0x43, 0x10a
    .long 0x2e, 0x44, 0x1e0a
    .long 0x2e, 0x45, 0x116
    .long 0x2e, 0x46, 0x1e1e
    .long 0x2e, 0x47, 0x120
    .long 0x2e, 0x48, 0x1e22
    .long 0x2e, 0x49, 0x130
    .long 0x2e, 0x4d, 0x1e40
    .long 0x2e, 0x4e, 0x1e44
    .long 0x2e, 0x4f, 0x22e
    .long 0x2e, 0x50, 0x1e56
    .long 0x2e, 0x52, 0x1e58
    .long 0x2e, 0x53, 0x1e60
    .long 0x2e, 0x54, 0x1e6a
    .long 0x2e, 0x57, 0x1e86
    .long 0x2e, 0x58, 0x1e8a
    .long 0x2e, 0x59, 0x1e8e
    .long 0x2e, 0x5a, 0x17b
    .long 0x2e, 0x5e, 0xb7
    .long 0x2e, 0x61, 0x227
    .long 0x2e, 0x62, 0x1e03
    .long 0x2e, 0x63, 0x10b
    .long 0x2e, 0x64, 0x1e0b
    .long 0x2e, 0x65, 0x117
    .long 0x2e, 0x66, 0x1e1f
    .long 0x2e, 0x67, 0x121
    .long 0x2e, 0x68, 0x1e23
    .long 0x2e, 0x69, 0x131
    .long 0x2e, 0x6d, 0x1e41
    .long 0x2e, 0x6e, 0x1e45
    .long 0x2e, 0x6f, 0x22f
    .long 0x2e, 0x70, 0x1e57
    .long 0x2e, 0x72, 0x1e59
    .long 0x2e, 0x73, 0x1e61
    .long 0x2e, 0x74, 0x1e6b
    .long 0x2e, 0x77, 0x1e87
    .long 0x2e, 0x78, 0x1e8b
    .long 0x2e, 0x79, 0x1e8f
    .long 0x2e, 0x7a, 0x17c
    .long 0x2e, 0x15a, 0x1e64
    .long 0x2e, 0x15b, 0x1e65
    .long 0x2e, 0x160, 0x1e66
    .long 0x2e, 0x161, 0x1e67
    .long 0x2e, 0x17f, 0x1e9b
    .long 0x2e, 0x1e62, 0x1e68
    .long 0x2e, 0x1e63, 0x1e69
    .long 0x2e, 0x25cb, 0x2299
    .long 0x2f, 0x2d, 0x233f
    .long 0x2f, 0x2f, 0xf7
    .long 0x2f, 0x3c, 0x5c
    .long 0x2f, 0x3d, 0x2260
    .long 0x2f, 0x42, 0x243
    .long 0x2f, 0x43, 0x20a1
    .long 0x2f, 0x44, 0x110
    .long 0x2f, 0x47, 0x1e4
    .long 0x2f, 0x48, 0x126
    .long 0x2f, 0x49, 0x197
    .long 0x2f, 0x4c, 0x141
    .long 0x2f, 0x4f, 0xd8
    .long 0x2f, 0x54, 0x166
    .long 0x2f, 0x5a, 0x1b5
    .long 0x2f, 0x5e, 0x7c
    .long 0x2f, 0x62, 0x180
    .long 0x2f, 0x63, 0xa2
    .long 0x2f, 0x64, 0x111
    .long 0x2f, 0x67, 0x1e5
    .long 0x2f, 0x68, 0x127
    .long 0x2f, 0x69, 0x268
    .long 0x2f, 0x6c, 0x142
    .long 0x2f, 0x6d, 0x20a5
    .long 0x2f, 0x6f, 0xf8
    .long 0x2f, 0x74, 0x167
    .long 0x2f, 0x75, 0xb5
    .long 0x2f, 0x76, 0x221a
    .long 0x2f, 0x7a, 0x1b6
    .long 0x2f, 0x294, 0x2a1
    .long 0x2f, 0x413, 0x492
    .long 0x2f, 0x41a, 0x49e
    .long 0x2f, 0x433, 0x493
    .long 0x2f, 0x43a, 0x49f
    .long 0x2f, 0x4ae, 0x4b0
    .long 0x2f, 0x4af, 0x4b1
    .long 0x2f, 0x2190, 0x219a
    .long 0x2f, 0x2192, 0x219b
    .long 0x2f, 0x2194, 0x21ae
    .long 0x2f, 0x2395, 0x2341
    .long 0x30, 0x2a, 0xb0
    .long 0x30, 0x33, 0x2189
    .long 0x30, 0x7e, 0x236c
    .long 0x31, 0x32, 0xbd
    .long 0x31, 0x33, 0x2153
    .long 0x31, 0x34, 0xbc
    .long 0x31, 0x35, 0x2155
    .long 0x31, 0x36, 0x2159
    .long 0x31, 0x37, 0x2150
    .long 0x31, 0x38, 0x215b
    .long 0x31, 0x39, 0x2151
    .long 0x31, 0x5e, 0xb9
    .long 0x32, 0x33, 0x2154
    .long 0x32, 0x35, 0x2156
    .long 0x32, 0x5e, 0xb2
    .long 0x33, 0x34, 0xbe
    .long 0x33, 0x35, 0x2157
    .long 0x33, 0x38, 0x215c
    .long 0x33, 0x5e, 0xb3
    .long 0x34, 0x35, 0x2158
    .long 0x35, 0x36, 0x215a
    .long 0x35, 0x38, 0x215d
    .long 0x37, 0x38, 0x215e
    .long 0x38, 0x38, 0x221e
    .long 0x3a, 0x28, 0x2639
    .long 0x3a, 0x29, 0x263a
    .long 0x3a, 0x2d, 0xf7
    .long 0x3a, 0x2e, 0x2234
    .long 0x3a, 0x2395, 0x2360
    .long 0x3b, 0x20, 0x2db
    .long 0x3b, 0x41, 0x104
    .long 0x3b, 0x45, 0x118
    .long 0x3b, 0x49, 0x12e
    .long 0x3b, 0x4f, 0x1ea
    .long 0x3b, 0x53, 0x218
    .long 0x3b, 0x54, 0x21a
    .long 0x3b, 0x55, 0x172
    .long 0x3b, 0x5f, 0x236e
    .long 0x3b, 0x61, 0x105
    .long 0x3b, 0x65, 0x119
    .long 0x3b, 0x69, 0x12f
    .long 0x3b, 0x6f, 0x1eb
    .long 0x3b, 0x73, 0x219
    .long 0x3b, 0x74, 0x21b
    .long 0x3b, 0x75, 0x173
    .long 0x3c, 0x20, 0x2c7
    .long 0x3c, 0x22, 0x201c
    .long 0x3c, 0x27, 0x2018
    .long 0x3c, 0x2d, 0x2190
    .long 0x3c, 0x2f, 0x5c
    .long 0x3c, 0x33, 0x2665
    .long 0x3c, 0x3c, 0xab
    .long 0x3c, 0x3d, 0x2264
    .long 0x3c, 0x3e, 0x22c4
    .long 0x3c, 0x43, 0x10c
    .long 0x3c, 0x44, 0x10e
    .long 0x3c, 0x45, 0x11a
    .long 0x3c, 0x4c, 0x13d
    .long 0x3c, 0x4e, 0x147
    .long 0x3c, 0x52, 0x158
    .long 0x3c, 0x53, 0x160
    .long 0x3c, 0x54, 0x164
    .long 0x3c, 0x5a, 0x17d
    .long 0x3c, 0x5f, 0x2264
    .long 0x3c, 0x63, 0x10d
    .long 0x3c, 0x64, 0x10f
    .long 0x3c, 0x65, 0x11b
    .long 0x3c, 0x6c, 0x13e
    .long 0x3c, 0x6e, 0x148
    .long 0x3c, 0x72, 0x159
    .long 0x3c, 0x73, 0x161
    .long 0x3c, 0x74, 0x165
    .long 0x3c, 0x7a, 0x17e
    .long 0x3c, 0x338, 0x226e
    .long 0x3c, 0x2395, 0x2343
    .long 0x3d, 0x2f, 0x2260
    .long 0x3d, 0x3c, 0x21d0
    .long 0x3d, 0x3e, 0x21d2
    .long 0x3d, 0x43, 0x20ac
    .long 0x3d, 0x45, 0x20ac
    .long 0x3d, 0x4c, 0x20a4
    .long 0x3d, 0x4e, 0x20a6
    .long 0x3d, 0x4f, 0x150
    .long 0x3d, 0x50, 0x20bd
    .long 0x3d, 0x52, 0x20b9
    .long 0x3d, 0x55, 0x170
    .long 0x3d, 0x57, 0x20a9
    .long 0x3d, 0x59, 0xa5
    .long 0x3d, 0x5e, 0x21d1
    .long 0x3d, 0x5f, 0x2261
    .long 0x3d, 0x63, 0x20ac
    .long 0x3d, 0x64, 0x20ab
    .long 0x3d, 0x65, 0x20ac
    .long 0x3d, 0x6f, 0x151
    .long 0x3d, 0x70, 0x20bd
    .long 0x3d, 0x72, 0x20b9
    .long 0x3d, 0x75, 0x171
    .long 0x3d, 0x76, 0x21d3
    .long 0x3d, 0x79, 0xa5
    .long 0x3d, 0x338, 0x2260
    .long 0x3d, 0x415, 0x20ac
    .long 0x3d, 0x417, 0x20bd
    .long 0x3d, 0x421, 0x20ac
    .long 0x3d, 0x423, 0x4f2
    .long 0x3d, 0x437, 0x20bd
    .long 0x3d, 0x443, 0x4f3
    .long 0x3d, 0x2395, 0x2338
    .long 0x3e, 0x20, 0x5e
    .long 0x3e, 0x22, 0x201d
    .long 0x3e, 0x27, 0x2019
    .long 0x3e, 0x3c, 0x22c4
    .long 0x3e, 0x3d, 0x2265
    .long 0x3e, 0x3e, 0xbb
    .long 0x3e, 0x41, 0xc2
    .long 0x3e, 0x45, 0xca
    .long 0x3e, 0x49, 0xce
    .long 0x3e, 0x4f, 0xd4
    .long 0x3e, 0x55, 0xdb
    .long 0x3e, 0x5f, 0x2265
    .long 0x3e, 0x61, 0xe2
    .long 0x3e, 0x65, 0xea
    .long 0x3e, 0x69, 0xee
    .long 0x3e, 0x6f, 0xf4
    .long 0x3e, 0x75, 0xfb
    .long 0x3e, 0xa8, 0x2369
    .long 0x3e, 0x338, 0x226f
    .long 0x3e, 0x2395, 0x2344
    .long 0x3f, 0x21, 0x2e18
    .long 0x3f, 0x3f, 0xbf
    .long 0x3f, 0x41, 0x1ea2
    .long 0x3f, 0x45, 0x1eba
    .long 0x3f, 0x49, 0x1ec8
    .long 0x3f, 0x4f, 0x1ece
    .long 0x3f, 0x55, 0x1ee6
    .long 0x3f, 0x59, 0x1ef6
    .long 0x3f, 0x5c, 0x262d
    .long 0x3f, 0x61, 0x1ea3
    .long 0x3f, 0x65, 0x1ebb
    .long 0x3f, 0x69, 0x1ec9
    .long 0x3f, 0x6f, 0x1ecf
    .long 0x3f, 0x75, 0x1ee7
    .long 0x3f, 0x79, 0x1ef7
    .long 0x3f, 0xc2, 0x1ea8
    .long 0x3f, 0xca, 0x1ec2
    .long 0x3f, 0xd4, 0x1ed4
    .long 0x3f, 0xe2, 0x1ea9
    .long 0x3f, 0xea, 0x1ec3
    .long 0x3f, 0xf4, 0x1ed5
    .long 0x3f, 0x102, 0x1eb2
    .long 0x3f, 0x103, 0x1eb3
    .long 0x3f, 0x1a0, 0x1ede
    .long 0x3f, 0x1a1, 0x1edf
    .long 0x3f, 0x1af, 0x1eec
    .long 0x3f, 0x1b0, 0x1eed
    .long 0x3f, 0x2395, 0x2370
    .long 0x41, 0x22, 0xc4
    .long 0x41, 0x27, 0xc1
    .long 0x41, 0x28, 0x102
    .long 0x41, 0x2a, 0xc5
    .long 0x41, 0x2c, 0x104
    .long 0x41, 0x2d, 0x100
    .long 0x41, 0x3b, 0x104
    .long 0x41, 0x3e, 0xc2
    .long 0x41, 0x41, 0xc5
    .long 0x41, 0x45, 0xc6
    .long 0x41, 0x54, 0x40
    .long 0x41, 0x5e, 0xc2
    .long 0x41, 0x5f, 0x100
    .long 0x41, 0x60, 0xc0
    .long 0x41, 0x7e, 0xc3
    .long 0x41, 0xa8, 0xc4
    .long 0x41, 0xb4, 0xc1
    .long 0x42, 0x2e, 0x1e02
    .long 0x43, 0x27, 0x106
    .long 0x43, 0x2c, 0xc7
    .long 0x43, 0x2e, 0x10a
    .long 0x43, 0x2f, 0x20a1
    .long 0x43, 0x3c, 0x10c
    .long 0x43, 0x3d, 0x20ac
    .long 0x43, 0x43, 0x2102
    .long 0x43, 0x45, 0x20a0
    .long 0x43, 0x4f, 0xa9
    .long 0x43, 0x72, 0x20a2
    .long 0x43, 0x7c, 0xa2
    .long 0x44, 0x2c, 0x1e10
    .long 0x44, 0x2d, 0x110
    .long 0x44, 0x2e, 0x1e0a
    .long 0x44, 0x3c, 0x10e
    .long 0x44, 0x48, 0xd0
    .long 0x45, 0x22, 0xcb
    .long 0x45, 0x27, 0xc9
    .long 0x45, 0x2c, 0x118
    .long 0x45, 0x2d, 0x112
    .long 0x45, 0x2e, 0x116
    .long 0x45, 0x3b, 0x118
    .long 0x45, 0x3c, 0x11a
    .long 0x45, 0x3d, 0x20ac
    .long 0x45, 0x3e, 0xca
    .long 0x45, 0x5e, 0xca
    .long 0x45, 0x5f, 0x112
    .long 0x45, 0x60, 0xc8
    .long 0x45, 0xa8, 0xcb
    .long 0x45, 0xb4, 0xc9
    .long 0x46, 0x2e, 0x1e1e
    .long 0x46, 0x55, 0x1f595
    .long 0x46, 0x69, 0xfb03
    .long 0x46, 0x6c, 0xfb04
    .long 0x46, 0x72, 0x20a3
    .long 0x47, 0x28, 0x11e
    .long 0x47, 0x2c, 0x122
    .long 0x47, 0x2e, 0x120
    .long 0x47, 0x54, 0x3e
    .long 0x47, 0x55, 0x11e
    .long 0x47, 0x2d8, 0x11e
    .long 0x48, 0x2c, 0x1e28
    .long 0x49, 0x22, 0xcf
    .long 0x49, 0x27, 0xcd
    .long 0x49, 0x2c, 0x12e
    .long 0x49, 0x2d, 0x12a
    .long 0x49, 0x2e, 0x130
    .long 0x49, 0x3b, 0x12e
    .long 0x49, 0x3e, 0xce
    .long 0x49, 0x4a, 0x132
    .long 0x49, 0x5e, 0xce
    .long 0x49, 0x5f, 0x12a
    .long 0x49, 0x60, 0xcc
    .long 0x49, 0x6a, 0x132
    .long 0x49, 0x7e, 0x128
    .long 0x49, 0xa8, 0xcf
    .long 0x49, 0xb4, 0xcd
    .long 0x4b, 0x2c, 0x136
    .long 0x4c, 0x27, 0x139
    .long 0x4c, 0x2c, 0x13b
    .long 0x4c, 0x2d, 0xa3
    .long 0x4c, 0x2f, 0x141
    .long 0x4c, 0x3c, 0x13d
    .long 0x4c, 0x3d, 0x20a4
    .long 0x4c, 0x54, 0x3c
    .long 0x4c, 0x56, 0x7c
    .long 0x4d, 0x2e, 0x1e40
    .long 0x4e, 0x27, 0x143
    .long 0x4e, 0x2c, 0x145
    .long 0x4e, 0x3c, 0x147
    .long 0x4e, 0x3d, 0x20a6
    .long 0x4e, 0x47, 0x14a
    .long 0x4e, 0x4e, 0x2115
    .long 0x4e, 0x4f, 0x2116
    .long 0x4e, 0x6f, 0x2116
    .long 0x4e, 0x7e, 0xd1
    .long 0x4f, 0x22, 0xd6
    .long 0x4f, 0x27, 0xd3
    .long 0x4f, 0x2c, 0x1ea
    .long 0x4f, 0x2d, 0x14c
    .long 0x4f, 0x2f, 0xd8
    .long 0x4f, 0x3b, 0x1ea
    .long 0x4f, 0x3e, 0xd4
    .long 0x4f, 0x41, 0x24b6
    .long 0x4f, 0x43, 0xa9
    .long 0x4f, 0x45, 0x152
    .long 0x4f, 0x52, 0xae
    .long 0x4f, 0x53, 0xa7
    .long 0x4f, 0x58, 0xa4
    .long 0x4f, 0x59, 0x262e
    .long 0x4f, 0x5e, 0xd4
    .long 0x4f, 0x5f, 0x14c
    .long 0x4f, 0x60, 0xd2
    .long 0x4f, 0x7e, 0xd5
    .long 0x4f, 0xa8, 0xd6
    .long 0x4f, 0xb4, 0xd3
    .long 0x50, 0x21, 0xb6
    .long 0x50, 0x2e, 0x1e56
    .long 0x50, 0x3d, 0x20bd
    .long 0x50, 0x50, 0xb6
    .long 0x50, 0x74, 0x20a7
    .long 0x51, 0x51, 0x211a
    .long 0x52, 0x27, 0x154
    .long 0x52, 0x2c, 0x156
    .long 0x52, 0x3c, 0x158
    .long 0x52, 0x3d, 0x20b9
    .long 0x52, 0x4f, 0xae
    .long 0x52, 0x52, 0x211d
    .long 0x52, 0x73, 0x20a8
    .long 0x53, 0x21, 0xa7
    .long 0x53, 0x27, 0x15a
    .long 0x53, 0x2c, 0x15e
    .long 0x53, 0x2e, 0x1e60
    .long 0x53, 0x3b, 0x218
    .long 0x53, 0x3c, 0x160
    .long 0x53, 0x4d, 0x2120
    .long 0x53, 0x4f, 0xa7
    .long 0x53, 0x53, 0x1e9e
    .long 0x54, 0x2c, 0x162
    .long 0x54, 0x2d, 0x166
    .long 0x54, 0x2e, 0x1e6a
    .long 0x54, 0x2f, 0x166
    .long 0x54, 0x3b, 0x21a
    .long 0x54, 0x3c, 0x164
    .long 0x54, 0x48, 0xde
    .long 0x54, 0x4d, 0x2122
    .long 0x55, 0x22, 0xdc
    .long 0x55, 0x27, 0xda
    .long 0x55, 0x2a, 0x16e
    .long 0x55, 0x2c, 0x172
    .long 0x55, 0x2d, 0x16a
    .long 0x55, 0x3b, 0x172
    .long 0x55, 0x3e, 0xdb
    .long 0x55, 0x41, 0x102
    .long 0x55, 0x45, 0x114
    .long 0x55, 0x47, 0x11e
    .long 0x55, 0x49, 0x12c
    .long 0x55, 0x4f, 0x14e
    .long 0x55, 0x55, 0x16c
    .long 0x55, 0x5e, 0xdb
    .long 0x55, 0x5f, 0x16a
    .long 0x55, 0x60, 0xd9
    .long 0x55, 0x61, 0x103
    .long 0x55, 0x65, 0x115
    .long 0x55, 0x67, 0x11f
    .long 0x55, 0x69, 0x12d
    .long 0x55, 0x6f, 0x14f
    .long 0x55, 0x75, 0x16d
    .long 0x55, 0x7e, 0x168
    .long 0x55, 0xa8, 0xdc
    .long 0x55, 0xb4, 0xda
    .long 0x55, 0x228, 0x1e1c
    .long 0x55, 0x229, 0x1e1d
    .long 0x55, 0x391, 0x1fb8
    .long 0x55, 0x399, 0x1fd8
    .long 0x55, 0x3a5, 0x1fe8
    .long 0x55, 0x3b1, 0x1fb0
    .long 0x55, 0x3b9, 0x1fd0
    .long 0x55, 0x3c5, 0x1fe0
    .long 0x55, 0x410, 0x4d0
    .long 0x55, 0x415, 0x4d6
    .long 0x55, 0x416, 0x4c1
    .long 0x55, 0x418, 0x419
    .long 0x55, 0x423, 0x40e
    .long 0x55, 0x430, 0x4d1
    .long 0x55, 0x435, 0x4d7
    .long 0x55, 0x436, 0x4c2
    .long 0x55, 0x438, 0x439
    .long 0x55, 0x443, 0x45e
    .long 0x55, 0x1ea0, 0x1eb6
    .long 0x55, 0x1ea1, 0x1eb7
    .long 0x56, 0x4c, 0x7c
    .long 0x57, 0x3d, 0x20a9
    .long 0x57, 0x5e, 0x174
    .long 0x58, 0x4f, 0xa4
    .long 0x59, 0x22, 0x178
    .long 0x59, 0x27, 0xdd
    .long 0x59, 0x2d, 0xa5
    .long 0x59, 0x3d, 0xa5
    .long 0x59, 0x5e, 0x176
    .long 0x59, 0xa8, 0x178
    .long 0x59, 0xb4, 0xdd
    .long 0x5a, 0x27, 0x179
    .long 0x5a, 0x2e, 0x17b
    .long 0x5a, 0x3c, 0x17d
    .long 0x5a, 0x5a, 0x2124
    .long 0x5b, 0x5d, 0x2337
    .long 0x5c, 0x2d, 0x2340
    .long 0x5c, 0x3f, 0x262d
    .long 0x5c, 0x2395, 0x2342
    .long 0x5c, 0x25cb, 0x2349
    .long 0x5d, 0x5b, 0x2337
    .long 0x5e, 0x28, 0x207d
    .long 0x5e, 0x29, 0x207e
    .long 0x5e, 0x2b, 0x207a
    .long 0x5e, 0x2d, 0x207b
    .long 0x5e, 0x2e, 0xb7
    .long 0x5e, 0x2f, 0x7c
    .long 0x5e, 0x30, 0x2070
    .long 0x5e, 0x31, 0xb9
    .long 0x5e, 0x32, 0xb2
    .long 0x5e, 0x33, 0xb3
    .long 0x5e, 0x34, 0x2074
    .long 0x5e, 0x35, 0x2075
    .long 0x5e, 0x36, 0x2076
    .long 0x5e, 0x37, 0x2077
    .long 0x5e, 0x38, 0x2078
    .long 0x5e, 0x39, 0x2079
    .long 0x5e, 0x3d, 0x207c
    .long 0x5e, 0x41, 0xc2
    .long 0x5e, 0x43, 0x108
    .long 0x5e, 0x45, 0xca
    .long 0x5e, 0x47, 0x11c
    .long 0x5e, 0x48, 0x124
    .long 0x5e, 0x49, 0xce
    .long 0x5e, 0x4a, 0x134
    .long 0x5e, 0x4f, 0xd4
    .long 0x5e, 0x53, 0x15c
    .long 0x5e, 0x55, 0xdb
    .long 0x5e, 0x57, 0x174
    .long 0x5e, 0x59, 0x176
    .long 0x5e, 0x5a, 0x1e90
    .long 0x5e, 0x5e, 0x2191
    .long 0x5e, 0x61, 0xe2
    .long 0x5e, 0x63, 0x109
    .long 0x5e, 0x65, 0xea
    .long 0x5e, 0x67, 0x11d
    .long 0x5e, 0x68, 0x125
    .long 0x5e, 0x69, 0xee
    .long 0x5e, 0x6a, 0x135
    .long 0x5e, 0x6f, 0xf4
    .long 0x5e, 0x73, 0x15d
    .long 0x5e, 0x75, 0xfb
    .long 0x5e, 0x77, 0x175
    .long 0x5e, 0x79, 0x177
    .long 0x5e, 0x7a, 0x1e91
    .long 0x5e, 0x7c, 0x2191
    .long 0x5e, 0x1ea0, 0x1eac
    .long 0x5e, 0x1ea1, 0x1ead
    .long 0x5e, 0x1eb8, 0x1ec6
    .long 0x5e, 0x1eb9, 0x1ec7
    .long 0x5e, 0x1ecc, 0x1ed8
    .long 0x5e, 0x1ecd, 0x1ed9
    .long 0x5e, 0x2212, 0x207b
    .long 0x5e, 0x4e00, 0x3192
    .long 0x5e, 0x4e01, 0x319c
    .long 0x5e, 0x4e09, 0x3194
    .long 0x5e, 0x4e0a, 0x3196
    .long 0x5e, 0x4e0b, 0x3198
    .long 0x5e, 0x4e19, 0x319b
    .long 0x5e, 0x4e2d, 0x3197
    .long 0x5e, 0x4e59, 0x319a
    .long 0x5e, 0x4e8c, 0x3193
    .long 0x5e, 0x4eba, 0x319f
    .long 0x5e, 0x56db, 0x3195
    .long 0x5e, 0x5730, 0x319e
    .long 0x5e, 0x5929, 0x319d
    .long 0x5e, 0x7532, 0x3199
    .long 0x5f, 0x20, 0xaf
    .long 0x5f, 0x27, 0x2358
    .long 0x5f, 0x28, 0x208d
    .long 0x5f, 0x29, 0x208e
    .long 0x5f, 0x2b, 0x208a
    .long 0x5f, 0x2d, 0x208b
    .long 0x5f, 0x30, 0x2080
    .long 0x5f, 0x31, 0x2081
    .long 0x5f, 0x32, 0x2082
    .long 0x5f, 0x33, 0x2083
    .long 0x5f, 0x34, 0x2084
    .long 0x5f, 0x35, 0x2085
    .long 0x5f, 0x36, 0x2086
    .long 0x5f, 0x37, 0x2087
    .long 0x5f, 0x38, 0x2088
    .long 0x5f, 0x39, 0x2089
    .long 0x5f, 0x3c, 0x2264
    .long 0x5f, 0x3d, 0x208c
    .long 0x5f, 0x3e, 0x2265
    .long 0x5f, 0x41, 0x100
    .long 0x5f, 0x45, 0x112
    .long 0x5f, 0x47, 0x1e20
    .long 0x5f, 0x49, 0x12a
    .long 0x5f, 0x4f, 0x14c
    .long 0x5f, 0x55, 0x16a
    .long 0x5f, 0x59, 0x232
    .long 0x5f, 0x5e, 0xaf
    .long 0x5f, 0x5f, 0xaf
    .long 0x5f, 0x61, 0x101
    .long 0x5f, 0x65, 0x113
    .long 0x5f, 0x67, 0x1e21
    .long 0x5f, 0x69, 0x12b
    .long 0x5f, 0x6f, 0x14d
    .long 0x5f, 0x75, 0x16b
    .long 0x5f, 0x79, 0x233
    .long 0x5f, 0xc4, 0x1de
    .long 0x5f, 0xc6, 0x1e2
    .long 0x5f, 0xd5, 0x22c
    .long 0x5f, 0xd6, 0x22a
    .long 0x5f, 0xdc, 0x1d5
    .long 0x5f, 0xe4, 0x1df
    .long 0x5f, 0xe6, 0x1e3
    .long 0x5f, 0xf5, 0x22d
    .long 0x5f, 0xf6, 0x22b
    .long 0x5f, 0xfc, 0x1d6
    .long 0x5f, 0x1ea, 0x1ec
    .long 0x5f, 0x1eb, 0x1ed
    .long 0x5f, 0x226, 0x1e0
    .long 0x5f, 0x227, 0x1e1
    .long 0x5f, 0x22e, 0x230
    .long 0x5f, 0x22f, 0x231
    .long 0x5f, 0x391, 0x1fb9
    .long 0x5f, 0x399, 0x1fd9
    .long 0x5f, 0x3a5, 0x1fe9
    .long 0x5f, 0x3b1, 0x1fb1
    .long 0x5f, 0x3b9, 0x1fd1
    .long 0x5f, 0x3c5, 0x1fe1
    .long 0x5f, 0x418, 0x4e2
    .long 0x5f, 0x423, 0x4ee
    .long 0x5f, 0x438, 0x4e3
    .long 0x5f, 0x443, 0x4ef
    .long 0x5f, 0x1e36, 0x1e38
    .long 0x5f, 0x1e37, 0x1e39
    .long 0x5f, 0x1e5a, 0x1e5c
    .long 0x5f, 0x1e5b, 0x1e5d
    .long 0x5f, 0x2206, 0x2359
    .long 0x5f, 0x220a, 0x2377
    .long 0x5f, 0x2212, 0x208b
    .long 0x5f, 0x2218, 0x235b
    .long 0x5f, 0x2260, 0x2262
    .long 0x5f, 0x2282, 0x2286
    .long 0x5f, 0x2283, 0x2287
    .long 0x5f, 0x22a5, 0x234a
    .long 0x5f, 0x22c4, 0x235a
    .long 0x5f, 0x2373, 0x2378
    .long 0x5f, 0x2375, 0x2379
    .long 0x5f, 0x237a, 0x2376
    .long 0x5f, 0x25cb, 0x235c
    .long 0x60, 0x41, 0xc0
    .long 0x60, 0x45, 0xc8
    .long 0x60, 0x49, 0xcc
    .long 0x60, 0x4e, 0x1f8
    .long 0x60, 0x4f, 0xd2
    .long 0x60, 0x55, 0xd9
    .long 0x60, 0x57, 0x1e80
    .long 0x60, 0x59, 0x1ef2
    .long 0x60, 0x61, 0xe0
    .long 0x60, 0x65, 0xe8
    .long 0x60, 0x69, 0xec
    .long 0x60, 0x6e, 0x1f9
    .long 0x60, 0x6f, 0xf2
    .long 0x60, 0x75, 0xf9
    .long 0x60, 0x77, 0x1e81
    .long 0x60, 0x79, 0x1ef3
    .long 0x60, 0xc2, 0x1ea6
    .long 0x60, 0xca, 0x1ec0
    .long 0x60, 0xd4, 0x1ed2
    .long 0x60, 0xdc, 0x1db
    .long 0x60, 0xe2, 0x1ea7
    .long 0x60, 0xea, 0x1ec1
    .long 0x60, 0xf4, 0x1ed3
    .long 0x60, 0xfc, 0x1dc
    .long 0x60, 0x102, 0x1eb0
    .long 0x60, 0x103, 0x1eb1
    .long 0x60, 0x112, 0x1e14
    .long 0x60, 0x113, 0x1e15
    .long 0x60, 0x14c, 0x1e50
    .long 0x60, 0x14d, 0x1e51
    .long 0x60, 0x1a0, 0x1edc
    .long 0x60, 0x1a1, 0x1edd
    .long 0x60, 0x1af, 0x1eea
    .long 0x60, 0x1b0, 0x1eeb
    .long 0x60, 0x391, 0x1fba
    .long 0x60, 0x395, 0x1fc8
    .long 0x60, 0x397, 0x1fca
    .long 0x60, 0x399, 0x1fda
    .long 0x60, 0x39f, 0x1ff8
    .long 0x60, 0x3a5, 0x1fea
    .long 0x60, 0x3a9, 0x1ffa
    .long 0x60, 0x3b1, 0x1f70
    .long 0x60, 0x3b5, 0x1f72
    .long 0x60, 0x3b7, 0x1f74
    .long 0x60, 0x3b9, 0x1f76
    .long 0x60, 0x3bf, 0x1f78
    .long 0x60, 0x3c5, 0x1f7a
    .long 0x60, 0x3c9, 0x1f7c
    .long 0x60, 0x3ca, 0x1fd2
    .long 0x60, 0x3cb, 0x1fe2
    .long 0x60, 0x415, 0x400
    .long 0x60, 0x418, 0x40d
    .long 0x60, 0x435, 0x450
    .long 0x60, 0x438, 0x45d
    .long 0x60, 0x1f00, 0x1f02
    .long 0x60, 0x1f01, 0x1f03
    .long 0x60, 0x1f08, 0x1f0a
    .long 0x60, 0x1f09, 0x1f0b
    .long 0x60, 0x1f10, 0x1f12
    .long 0x60, 0x1f11, 0x1f13
    .long 0x60, 0x1f18, 0x1f1a
    .long 0x60, 0x1f19, 0x1f1b
    .long 0x60, 0x1f20, 0x1f22
    .long 0x60, 0x1f21, 0x1f23
    .long 0x60, 0x1f28, 0x1f2a
    .long 0x60, 0x1f29, 0x1f2b
    .long 0x60, 0x1f30, 0x1f32
    .long 0x60, 0x1f31, 0x1f33
    .long 0x60, 0x1f38, 0x1f3a
    .long 0x60, 0x1f39, 0x1f3b
    .long 0x60, 0x1f40, 0x1f42
    .long 0x60, 0x1f41, 0x1f43
    .long 0x60, 0x1f48, 0x1f4a
    .long 0x60, 0x1f49, 0x1f4b
    .long 0x60, 0x1f50, 0x1f52
    .long 0x60, 0x1f51, 0x1f53
    .long 0x60, 0x1f59, 0x1f5b
    .long 0x60, 0x1f60, 0x1f62
    .long 0x60, 0x1f61, 0x1f63
    .long 0x60, 0x1f68, 0x1f6a
    .long 0x60, 0x1f69, 0x1f6b
    .long 0x61, 0x22, 0xe4
    .long 0x61, 0x27, 0xe1
    .long 0x61, 0x28, 0x103
    .long 0x61, 0x2a, 0xe5
    .long 0x61, 0x2c, 0x105
    .long 0x61, 0x2d, 0x101
    .long 0x61, 0x3b, 0x105
    .long 0x61, 0x3e, 0xe2
    .long 0x61, 0x5e, 0xe2
    .long 0x61, 0x5f, 0x101
    .long 0x61, 0x60, 0xe0
    .long 0x61, 0x61, 0xe5
    .long 0x61, 0x65, 0xe6
    .long 0x61, 0x7e, 0xe3
    .long 0x61, 0xa8, 0xe4
    .long 0x61, 0xb4, 0xe1
    .long 0x62, 0x2e, 0x1e03
    .long 0x62, 0x41, 0x102
    .long 0x62, 0x45, 0x114
    .long 0x62, 0x47, 0x11e
    .long 0x62, 0x49, 0x12c
    .long 0x62, 0x4f, 0x14e
    .long 0x62, 0x55, 0x16c
    .long 0x62, 0x61, 0x103
    .long 0x62, 0x65, 0x115
    .long 0x62, 0x67, 0x11f
    .long 0x62, 0x69, 0x12d
    .long 0x62, 0x6f, 0x14f
    .long 0x62, 0x75, 0x16d
    .long 0x62, 0x228, 0x1e1c
    .long 0x62, 0x229, 0x1e1d
    .long 0x62, 0x391, 0x1fb8
    .long 0x62, 0x399, 0x1fd8
    .long 0x62, 0x3a5, 0x1fe8
    .long 0x62, 0x3b1, 0x1fb0
    .long 0x62, 0x3b9, 0x1fd0
    .long 0x62, 0x3c5, 0x1fe0
    .long 0x62, 0x410, 0x4d0
    .long 0x62, 0x415, 0x4d6
    .long 0x62, 0x416, 0x4c1
    .long 0x62, 0x418, 0x419
    .long 0x62, 0x423, 0x40e
    .long 0x62, 0x430, 0x4d1
    .long 0x62, 0x435, 0x4d7
    .long 0x62, 0x436, 0x4c2
    .long 0x62, 0x438, 0x439
    .long 0x62, 0x443, 0x45e
    .long 0x62, 0x1ea0, 0x1eb6
    .long 0x62, 0x1ea1, 0x1eb7
    .long 0x63, 0x27, 0x107
    .long 0x63, 0x2c, 0xe7
    .long 0x63, 0x2e, 0x10b
    .long 0x63, 0x2f, 0xa2
    .long 0x63, 0x3c, 0x10d
    .long 0x63, 0x3d, 0x20ac
    .long 0x63, 0x41, 0x1cd
    .long 0x63, 0x43, 0x10c
    .long 0x63, 0x44, 0x10e
    .long 0x63, 0x45, 0x11a
    .long 0x63, 0x47, 0x1e6
    .long 0x63, 0x48, 0x21e
    .long 0x63, 0x49, 0x1cf
    .long 0x63, 0x4b, 0x1e8
    .long 0x63, 0x4c, 0x13d
    .long 0x63, 0x4e, 0x147
    .long 0x63, 0x4f, 0x1d1
    .long 0x63, 0x52, 0x158
    .long 0x63, 0x53, 0x160
    .long 0x63, 0x54, 0x164
    .long 0x63, 0x55, 0x1d3
    .long 0x63, 0x5a, 0x17d
    .long 0x63, 0x61, 0x1ce
    .long 0x63, 0x63, 0x10d
    .long 0x63, 0x64, 0x10f
    .long 0x63, 0x65, 0x11b
    .long 0x63, 0x67, 0x1e7
    .long 0x63, 0x68, 0x21f
    .long 0x63, 0x69, 0x1d0
    .long 0x63, 0x6a, 0x1f0
    .long 0x63, 0x6b, 0x1e9
    .long 0x63, 0x6c, 0x13e
    .long 0x63, 0x6e, 0x148
    .long 0x63, 0x6f, 0x1d2
    .long 0x63, 0x72, 0x159
    .long 0x63, 0x73, 0x161
    .long 0x63, 0x74, 0x165
    .long 0x63, 0x75, 0x1d4
    .long 0x63, 0x7a, 0x17e
    .long 0x63, 0x7c, 0xa2
    .long 0x63, 0xdc, 0x1d9
    .long 0x63, 0xfc, 0x1da
    .long 0x63, 0x1b7, 0x1ee
    .long 0x63, 0x292, 0x1ef
    .long 0x64, 0x2c, 0x1e11
    .long 0x64, 0x2d, 0x111
    .long 0x64, 0x2e, 0x1e0b
    .long 0x64, 0x3c, 0x10f
    .long 0x64, 0x3d, 0x20ab
    .long 0x64, 0x68, 0xf0
    .long 0x64, 0x69, 0x2300
    .long 0x65, 0x22, 0xeb
    .long 0x65, 0x27, 0xe9
    .long 0x65, 0x2c, 0x119
    .long 0x65, 0x2d, 0x113
    .long 0x65, 0x2e, 0x117
    .long 0x65, 0x3b, 0x119
    .long 0x65, 0x3c, 0x11b
    .long 0x65, 0x3d, 0x20ac
    .long 0x65, 0x3e, 0xea
    .long 0x65, 0x5e, 0xea
    .long 0x65, 0x5f, 0x113
    .long 0x65, 0x60, 0xe8
    .long 0x65, 0x65, 0x259
    .long 0x65, 0xa8, 0xeb
    .long 0x65, 0xb4, 0xe9
    .long 0x66, 0x2e, 0x1e1f
    .long 0x66, 0x53, 0x17f
    .long 0x66, 0x66, 0xfb00
    .long 0x66, 0x69, 0xfb01
    .long 0x66, 0x6c, 0xfb02
    .long 0x66, 0x73, 0x17f
    .long 0x67, 0x28, 0x11f
    .long 0x67, 0x2c, 0x123
    .long 0x67, 0x2e, 0x121
    .long 0x67, 0x55, 0x11f
    .long 0x67, 0x74, 0x3e
    .long 0x67, 0x2d8, 0x11f
    .long 0x68, 0x2c, 0x1e29
    .long 0x69, 0x22, 0xef
    .long 0x69, 0x27, 0xed
    .long 0x69, 0x2c, 0x12f
    .long 0x69, 0x2d, 0x12b
    .long 0x69, 0x2e, 0x131
    .long 0x69, 0x3b, 0x12f
    .long 0x69, 0x3e, 0xee
    .long 0x69, 0x5e, 0xee
    .long 0x69, 0x5f, 0x12b
    .long 0x69, 0x60, 0xec
    .long 0x69, 0x6a, 0x133
    .long 0x69, 0x7e, 0x129
    .long 0x69, 0xa8, 0xef
    .long 0x69, 0xb4, 0xed
    .long 0x6b, 0x2c, 0x137
    .long 0x6b, 0x6b, 0x138
    .long 0x6c, 0x27, 0x13a
    .long 0x6c, 0x2c, 0x13c
    .long 0x6c, 0x2d, 0xa3
    .long 0x6c, 0x2f, 0x142
    .long 0x6c, 0x3c, 0x13e
    .long 0x6c, 0x74, 0x3c
    .long 0x6c, 0x76, 0x7c
    .long 0x6d, 0x2e, 0x1e41
    .long 0x6d, 0x2f, 0x20a5
    .long 0x6d, 0x75, 0xb5
    .long 0x6e, 0x27, 0x144
    .long 0x6e, 0x2c, 0x146
    .long 0x6e, 0x3c, 0x148
    .long 0x6e, 0x67, 0x14b
    .long 0x6e, 0x6f, 0xac
    .long 0x6e, 0x7e, 0xf1
    .long 0x6f, 0x22, 0xf6
    .long 0x6f, 0x27, 0xf3
    .long 0x6f, 0x2c, 0x1eb
    .long 0x6f, 0x2d, 0x14d
    .long 0x6f, 0x2f, 0xf8
    .long 0x6f, 0x3b, 0x1eb
    .long 0x6f, 0x3e, 0xf4
    .long 0x6f, 0x41, 0xc5
    .long 0x6f, 0x55, 0x16e
    .long 0x6f, 0x5e, 0xf4
    .long 0x6f, 0x5f, 0x14d
    .long 0x6f, 0x60, 0xf2
    .long 0x6f, 0x61, 0xe5
    .long 0x6f, 0x63, 0xa9
    .long 0x6f, 0x65, 0x153
    .long 0x6f, 0x6f, 0xb0
    .long 0x6f, 0x72, 0xae
    .long 0x6f, 0x73, 0xa7
    .long 0x6f, 0x75, 0x16f
    .long 0x6f, 0x77, 0x1e98
    .long 0x6f, 0x78, 0xa4
    .long 0x6f, 0x79, 0x1e99
    .long 0x6f, 0x7e, 0xf5
    .long 0x6f, 0xa8, 0xf6
    .long 0x6f, 0xb4, 0xf3
    .long 0x70, 0x21, 0xb6
    .long 0x70, 0x2e, 0x1e57
    .long 0x70, 0x3d, 0x20bd
    .long 0x70, 0x70, 0xb6
    .long 0x72, 0x27, 0x155
    .long 0x72, 0x2c, 0x157
    .long 0x72, 0x3c, 0x159
    .long 0x72, 0x3d, 0x20b9
    .long 0x72, 0x6f, 0xae
    .long 0x73, 0x21, 0xa7
    .long 0x73, 0x27, 0x15b
    .long 0x73, 0x2c, 0x15f
    .long 0x73, 0x2e, 0x1e61
    .long 0x73, 0x3b, 0x219
    .long 0x73, 0x3c, 0x161
    .long 0x73, 0x6d, 0x2120
    .long 0x73, 0x6f, 0xa7
    .long 0x73, 0x73, 0xdf
    .long 0x73, 0xb8, 0x15f
    .long 0x74, 0x2c, 0x163
    .long 0x74, 0x2d, 0x167
    .long 0x74, 0x2e, 0x1e6b
    .long 0x74, 0x2f, 0x167
    .long 0x74, 0x3b, 0x21b
    .long 0x74, 0x3c, 0x165
    .long 0x74, 0x68, 0xfe
    .long 0x74, 0x6d, 0x2122
    .long 0x75, 0x22, 0xfc
    .long 0x75, 0x27, 0xfa
    .long 0x75, 0x2a, 0x16f
    .long 0x75, 0x2c, 0x173
    .long 0x75, 0x2d, 0x16b
    .long 0x75, 0x2f, 0xb5
    .long 0x75, 0x3b, 0x173
    .long 0x75, 0x3e, 0xfb
    .long 0x75, 0x41, 0x102
    .long 0x75, 0x45, 0x114
    .long 0x75, 0x47, 0x11e
    .long 0x75, 0x49, 0x12c
    .long 0x75, 0x4f, 0x14e
    .long 0x75, 0x55, 0x16c
    .long 0x75, 0x5e, 0xfb
    .long 0x75, 0x5f, 0x16b
    .long 0x75, 0x60, 0xf9
    .long 0x75, 0x61, 0x103
    .long 0x75, 0x65, 0x115
    .long 0x75, 0x67, 0x11f
    .long 0x75, 0x69, 0x12d
    .long 0x75, 0x6f, 0x14f
    .long 0x75, 0x75, 0x16d
    .long 0x75, 0x7e, 0x169
    .long 0x75, 0xa8, 0xfc
    .long 0x75, 0xb4, 0xfa
    .long 0x76, 0x2f, 0x221a
    .long 0x76, 0x41, 0x1cd
    .long 0x76, 0x43, 0x10c
    .long 0x76, 0x44, 0x10e
    .long 0x76, 0x45, 0x11a
    .long 0x76, 0x47, 0x1e6
    .long 0x76, 0x48, 0x21e
    .long 0x76, 0x49, 0x1cf
    .long 0x76, 0x4b, 0x1e8
    .long 0x76, 0x4e, 0x147
    .long 0x76, 0x4f, 0x1d1
    .long 0x76, 0x52, 0x158
    .long 0x76, 0x53, 0x160
    .long 0x76, 0x54, 0x164
    .long 0x76, 0x55, 0x1d3
    .long 0x76, 0x5a, 0x17d
    .long 0x76, 0x61, 0x1ce
    .long 0x76, 0x63, 0x10d
    .long 0x76, 0x64, 0x10f
    .long 0x76, 0x65, 0x11b
    .long 0x76, 0x67, 0x1e7
    .long 0x76, 0x68, 0x21f
    .long 0x76, 0x69, 0x1d0
    .long 0x76, 0x6a, 0x1f0
    .long 0x76, 0x6b, 0x1e9
    .long 0x76, 0x6c, 0x7c
    .long 0x76, 0x6e, 0x148
    .long 0x76, 0x6f, 0x1d2
    .long 0x76, 0x72, 0x159
    .long 0x76, 0x73, 0x161
    .long 0x76, 0x74, 0x165
    .long 0x76, 0x75, 0x1d4
    .long 0x76, 0x76, 0x2193
    .long 0x76, 0x7a, 0x17e
    .long 0x76, 0x7c, 0x2193
    .long 0x76, 0x1b7, 0x1ee
    .long 0x76, 0x292, 0x1ef
    .long 0x77, 0x5e, 0x175
    .long 0x78, 0x6f, 0xa4
    .long 0x78, 0x78, 0xd7
    .long 0x79, 0x22, 0xff
    .long 0x79, 0x27, 0xfd
    .long 0x79, 0x2d, 0xa5
    .long 0x79, 0x3d, 0xa5
    .long 0x79, 0x5e, 0x177
    .long 0x79, 0xa8, 0xff
    .long 0x79, 0xb4, 0xfd
    .long 0x7a, 0x27, 0x17a
    .long 0x7a, 0x2e, 0x17c
    .long 0x7a, 0x3c, 0x17e
    .long 0x7b, 0x7d, 0x2205
    .long 0x7c, 0x43, 0xa2
    .long 0x7c, 0x5e, 0x2191
    .long 0x7c, 0x63, 0xa2
    .long 0x7c, 0x76, 0x2193
    .long 0x7c, 0x7e, 0x236d
    .long 0x7c, 0x2190, 0x2345
    .long 0x7c, 0x2192, 0x2346
    .long 0x7c, 0x2206, 0x234b
    .long 0x7c, 0x2207, 0x2352
    .long 0x7c, 0x222a, 0x2366
    .long 0x7c, 0x2282, 0x2367
    .long 0x7c, 0x25cb, 0x233d
    .long 0x7e, 0x30, 0x236c
    .long 0x7e, 0x41, 0xc3
    .long 0x7e, 0x45, 0x1ebc
    .long 0x7e, 0x49, 0x128
    .long 0x7e, 0x4e, 0xd1
    .long 0x7e, 0x4f, 0xd5
    .long 0x7e, 0x55, 0x168
    .long 0x7e, 0x56, 0x1e7c
    .long 0x7e, 0x59, 0x1ef8
    .long 0x7e, 0x61, 0xe3
    .long 0x7e, 0x65, 0x1ebd
    .long 0x7e, 0x69, 0x129
    .long 0x7e, 0x6e, 0xf1
    .long 0x7e, 0x6f, 0xf5
    .long 0x7e, 0x75, 0x169
    .long 0x7e, 0x76, 0x1e7d
    .long 0x7e, 0x79, 0x1ef9
    .long 0x7e, 0x7c, 0x236d
    .long 0x7e, 0x7e, 0x2248
    .long 0x7e, 0xa8, 0x2368
    .long 0x7e, 0xc2, 0x1eaa
    .long 0x7e, 0xca, 0x1ec4
    .long 0x7e, 0xd4, 0x1ed6
    .long 0x7e, 0xe2, 0x1eab
    .long 0x7e, 0xea, 0x1ec5
    .long 0x7e, 0xf4, 0x1ed7
    .long 0x7e, 0x102, 0x1eb4
    .long 0x7e, 0x103, 0x1eb5
    .long 0x7e, 0x1a0, 0x1ee0
    .long 0x7e, 0x1a1, 0x1ee1
    .long 0x7e, 0x1af, 0x1eee
    .long 0x7e, 0x1b0, 0x1eef
    .long 0x7e, 0x3b1, 0x1fb6
    .long 0x7e, 0x3b7, 0x1fc6
    .long 0x7e, 0x3b9, 0x1fd6
    .long 0x7e, 0x3c5, 0x1fe6
    .long 0x7e, 0x3c9, 0x1ff6
    .long 0x7e, 0x3ca, 0x1fd7
    .long 0x7e, 0x3cb, 0x1fe7
    .long 0x7e, 0x1f00, 0x1f06
    .long 0x7e, 0x1f01, 0x1f07
    .long 0x7e, 0x1f08, 0x1f0e
    .long 0x7e, 0x1f09, 0x1f0f
    .long 0x7e, 0x1f20, 0x1f26
    .long 0x7e, 0x1f21, 0x1f27
    .long 0x7e, 0x1f28, 0x1f2e
    .long 0x7e, 0x1f29, 0x1f2f
    .long 0x7e, 0x1f30, 0x1f36
    .long 0x7e, 0x1f31, 0x1f37
    .long 0x7e, 0x1f38, 0x1f3e
    .long 0x7e, 0x1f39, 0x1f3f
    .long 0x7e, 0x1f50, 0x1f56
    .long 0x7e, 0x1f51, 0x1f57
    .long 0x7e, 0x1f59, 0x1f5f
    .long 0x7e, 0x1f60, 0x1f66
    .long 0x7e, 0x1f61, 0x1f67
    .long 0x7e, 0x1f68, 0x1f6e
    .long 0x7e, 0x1f69, 0x1f6f
    .long 0x7e, 0x2207, 0x236b
    .long 0x7e, 0x2227, 0x2372
    .long 0x7e, 0x2228, 0x2371
    .long 0xa8, 0x27, 0x385
    .long 0xa8, 0x2a, 0x2363
    .long 0xa8, 0x3e, 0x2369
    .long 0xa8, 0x41, 0xc4
    .long 0xa8, 0x45, 0xcb
    .long 0xa8, 0x49, 0xcf
    .long 0xa8, 0x4f, 0xd6
    .long 0xa8, 0x55, 0xdc
    .long 0xa8, 0x59, 0x178
    .long 0xa8, 0x60, 0x1fed
    .long 0xa8, 0x61, 0xe4
    .long 0xa8, 0x65, 0xeb
    .long 0xa8, 0x69, 0xef
    .long 0xa8, 0x6f, 0xf6
    .long 0xa8, 0x75, 0xfc
    .long 0xa8, 0x79, 0xff
    .long 0xa8, 0x7e, 0x1fc1
    .long 0xa8, 0xb4, 0x385
    .long 0xa8, 0x2207, 0x2362
    .long 0xa8, 0x2218, 0x2364
    .long 0xa8, 0x22a4, 0x2361
    .long 0xa8, 0x25cb, 0x2365
    .long 0xaf, 0x41, 0x100
    .long 0xaf, 0x45, 0x112
    .long 0xaf, 0x47, 0x1e20
    .long 0xaf, 0x49, 0x12a
    .long 0xaf, 0x4f, 0x14c
    .long 0xaf, 0x55, 0x16a
    .long 0xaf, 0x59, 0x232
    .long 0xaf, 0x61, 0x101
    .long 0xaf, 0x65, 0x113
    .long 0xaf, 0x67, 0x1e21
    .long 0xaf, 0x69, 0x12b
    .long 0xaf, 0x6f, 0x14d
    .long 0xaf, 0x75, 0x16b
    .long 0xaf, 0x79, 0x233
    .long 0xaf, 0xc4, 0x1de
    .long 0xaf, 0xc6, 0x1e2
    .long 0xaf, 0xd5, 0x22c
    .long 0xaf, 0xd6, 0x22a
    .long 0xaf, 0xdc, 0x1d5
    .long 0xaf, 0xe4, 0x1df
    .long 0xaf, 0xe6, 0x1e3
    .long 0xaf, 0xf5, 0x22d
    .long 0xaf, 0xf6, 0x22b
    .long 0xaf, 0xfc, 0x1d6
    .long 0xaf, 0x1ea, 0x1ec
    .long 0xaf, 0x1eb, 0x1ed
    .long 0xaf, 0x226, 0x1e0
    .long 0xaf, 0x227, 0x1e1
    .long 0xaf, 0x22e, 0x230
    .long 0xaf, 0x22f, 0x231
    .long 0xaf, 0x391, 0x1fb9
    .long 0xaf, 0x399, 0x1fd9
    .long 0xaf, 0x3a5, 0x1fe9
    .long 0xaf, 0x3b1, 0x1fb1
    .long 0xaf, 0x3b9, 0x1fd1
    .long 0xaf, 0x3c5, 0x1fe1
    .long 0xaf, 0x418, 0x4e2
    .long 0xaf, 0x423, 0x4ee
    .long 0xaf, 0x438, 0x4e3
    .long 0xaf, 0x443, 0x4ef
    .long 0xaf, 0x1e36, 0x1e38
    .long 0xaf, 0x1e37, 0x1e39
    .long 0xaf, 0x1e5a, 0x1e5c
    .long 0xaf, 0x1e5b, 0x1e5d
    .long 0xaf, 0x22a4, 0x2351
    .long 0xb4, 0x41, 0xc1
    .long 0xb4, 0x43, 0x106
    .long 0xb4, 0x45, 0xc9
    .long 0xb4, 0x47, 0x1f4
    .long 0xb4, 0x49, 0xcd
    .long 0xb4, 0x4b, 0x1e30
    .long 0xb4, 0x4c, 0x139
    .long 0xb4, 0x4d, 0x1e3e
    .long 0xb4, 0x4e, 0x143
    .long 0xb4, 0x4f, 0xd3
    .long 0xb4, 0x50, 0x1e54
    .long 0xb4, 0x52, 0x154
    .long 0xb4, 0x53, 0x15a
    .long 0xb4, 0x55, 0xda
    .long 0xb4, 0x57, 0x1e82
    .long 0xb4, 0x59, 0xdd
    .long 0xb4, 0x5a, 0x179
    .long 0xb4, 0x61, 0xe1
    .long 0xb4, 0x63, 0x107
    .long 0xb4, 0x65, 0xe9
    .long 0xb4, 0x67, 0x1f5
    .long 0xb4, 0x69, 0xed
    .long 0xb4, 0x6b, 0x1e31
    .long 0xb4, 0x6c, 0x13a
    .long 0xb4, 0x6d, 0x1e3f
    .long 0xb4, 0x6e, 0x144
    .long 0xb4, 0x6f, 0xf3
    .long 0xb4, 0x70, 0x1e55
    .long 0xb4, 0x72, 0x155
    .long 0xb4, 0x73, 0x15b
    .long 0xb4, 0x75, 0xfa
    .long 0xb4, 0x77, 0x1e83
    .long 0xb4, 0x79, 0xfd
    .long 0xb4, 0x7a, 0x17a
    .long 0xb4, 0xc2, 0x1ea4
    .long 0xb4, 0xc5, 0x1fa
    .long 0xb4, 0xc6, 0x1fc
    .long 0xb4, 0xc7, 0x1e08
    .long 0xb4, 0xca, 0x1ebe
    .long 0xb4, 0xcf, 0x1e2e
    .long 0xb4, 0xd4, 0x1ed0
    .long 0xb4, 0xd5, 0x1e4c
    .long 0xb4, 0xd8, 0x1fe
    .long 0xb4, 0xdc, 0x1d7
    .long 0xb4, 0xe2, 0x1ea5
    .long 0xb4, 0xe5, 0x1fb
    .long 0xb4, 0xe6, 0x1fd
    .long 0xb4, 0xe7, 0x1e09
    .long 0xb4, 0xea, 0x1ebf
    .long 0xb4, 0xef, 0x1e2f
    .long 0xb4, 0xf4, 0x1ed1
    .long 0xb4, 0xf5, 0x1e4d
    .long 0xb4, 0xf8, 0x1ff
    .long 0xb4, 0xfc, 0x1d8
    .long 0xb4, 0x102, 0x1eae
    .long 0xb4, 0x103, 0x1eaf
    .long 0xb4, 0x112, 0x1e16
    .long 0xb4, 0x113, 0x1e17
    .long 0xb4, 0x14c, 0x1e52
    .long 0xb4, 0x14d, 0x1e53
    .long 0xb4, 0x168, 0x1e78
    .long 0xb4, 0x169, 0x1e79
    .long 0xb4, 0x1a0, 0x1eda
    .long 0xb4, 0x1a1, 0x1edb
    .long 0xb4, 0x1af, 0x1ee8
    .long 0xb4, 0x1b0, 0x1ee9
    .long 0xb4, 0x391, 0x386
    .long 0xb4, 0x395, 0x388
    .long 0xb4, 0x397, 0x389
    .long 0xb4, 0x399, 0x38a
    .long 0xb4, 0x39f, 0x38c
    .long 0xb4, 0x3a5, 0x38e
    .long 0xb4, 0x3a9, 0x38f
    .long 0xb4, 0x3b1, 0x3ac
    .long 0xb4, 0x3b5, 0x3ad
    .long 0xb4, 0x3b7, 0x3ae
    .long 0xb4, 0x3b9, 0x3af
    .long 0xb4, 0x3bf, 0x3cc
    .long 0xb4, 0x3c5, 0x3cd
    .long 0xb4, 0x3c9, 0x3ce
    .long 0xb4, 0x3ca, 0x390
    .long 0xb4, 0x3cb, 0x3b0
    .long 0xb4, 0x413, 0x403
    .long 0xb4, 0x41a, 0x40c
    .long 0xb4, 0x433, 0x453
    .long 0xb4, 0x43a, 0x45c
    .long 0xb4, 0x1f00, 0x1f04
    .long 0xb4, 0x1f01, 0x1f05
    .long 0xb4, 0x1f08, 0x1f0c
    .long 0xb4, 0x1f09, 0x1f0d
    .long 0xb4, 0x1f10, 0x1f14
    .long 0xb4, 0x1f11, 0x1f15
    .long 0xb4, 0x1f18, 0x1f1c
    .long 0xb4, 0x1f19, 0x1f1d
    .long 0xb4, 0x1f20, 0x1f24
    .long 0xb4, 0x1f21, 0x1f25
    .long 0xb4, 0x1f28, 0x1f2c
    .long 0xb4, 0x1f29, 0x1f2d
    .long 0xb4, 0x1f30, 0x1f34
    .long 0xb4, 0x1f31, 0x1f35
    .long 0xb4, 0x1f38, 0x1f3c
    .long 0xb4, 0x1f39, 0x1f3d
    .long 0xb4, 0x1f40, 0x1f44
    .long 0xb4, 0x1f41, 0x1f45
    .long 0xb4, 0x1f48, 0x1f4c
    .long 0xb4, 0x1f49, 0x1f4d
    .long 0xb4, 0x1f50, 0x1f54
    .long 0xb4, 0x1f51, 0x1f55
    .long 0xb4, 0x1f59, 0x1f5d
    .long 0xb4, 0x1f60, 0x1f64
    .long 0xb4, 0x1f61, 0x1f65
    .long 0xb4, 0x1f68, 0x1f6c
    .long 0xb4, 0x1f69, 0x1f6d
    .long 0xb8, 0x43, 0xc7
    .long 0xb8, 0x44, 0x1e10
    .long 0xb8, 0x45, 0x228
    .long 0xb8, 0x47, 0x122
    .long 0xb8, 0x48, 0x1e28
    .long 0xb8, 0x4b, 0x136
    .long 0xb8, 0x4c, 0x13b
    .long 0xb8, 0x4e, 0x145
    .long 0xb8, 0x52, 0x156
    .long 0xb8, 0x53, 0x15e
    .long 0xb8, 0x54, 0x162
    .long 0xb8, 0x63, 0xe7
    .long 0xb8, 0x64, 0x1e11
    .long 0xb8, 0x65, 0x229
    .long 0xb8, 0x67, 0x123
    .long 0xb8, 0x68, 0x1e29
    .long 0xb8, 0x6b, 0x137
    .long 0xb8, 0x6c, 0x13c
    .long 0xb8, 0x6e, 0x146
    .long 0xb8, 0x72, 0x157
    .long 0xb8, 0x73, 0x15f
    .long 0xb8, 0x74, 0x163
    .long 0xf7, 0x2395, 0x2339
    .long 0x2d8, 0x47, 0x11e
    .long 0x2d8, 0x67, 0x11f
    .long 0x391, 0x27, 0x386
    .long 0x395, 0x27, 0x388
    .long 0x397, 0x27, 0x389
    .long 0x399, 0x22, 0x3aa
    .long 0x399, 0x27, 0x38a
    .long 0x39f, 0x27, 0x38c
    .long 0x3a5, 0x22, 0x3ab
    .long 0x3a5, 0x27, 0x38e
    .long 0x3a9, 0x27, 0x38f
    .long 0x3b1, 0x27, 0x3ac
    .long 0x3b5, 0x27, 0x3ad
    .long 0x3b7, 0x27, 0x3ae
    .long 0x3b9, 0x22, 0x3ca
    .long 0x3b9, 0x391, 0x1fbc
    .long 0x3b9, 0x397, 0x1fcc
    .long 0x3b9, 0x3a9, 0x1ffc
    .long 0x3b9, 0x3ac, 0x1fb4
    .long 0x3b9, 0x3ae, 0x1fc4
    .long 0x3b9, 0x3b1, 0x1fb3
    .long 0x3b9, 0x3b7, 0x1fc3
    .long 0x3b9, 0x3c9, 0x1ff3
    .long 0x3b9, 0x3ce, 0x1ff4
    .long 0x3b9, 0x1f00, 0x1f80
    .long 0x3b9, 0x1f01, 0x1f81
    .long 0x3b9, 0x1f02, 0x1f82
    .long 0x3b9, 0x1f03, 0x1f83
    .long 0x3b9, 0x1f04, 0x1f84
    .long 0x3b9, 0x1f05, 0x1f85
    .long 0x3b9, 0x1f06, 0x1f86
    .long 0x3b9, 0x1f07, 0x1f87
    .long 0x3b9, 0x1f08, 0x1f88
    .long 0x3b9, 0x1f09, 0x1f89
    .long 0x3b9, 0x1f0a, 0x1f8a
    .long 0x3b9, 0x1f0b, 0x1f8b
    .long 0x3b9, 0x1f0c, 0x1f8c
    .long 0x3b9, 0x1f0d, 0x1f8d
    .long 0x3b9, 0x1f0e, 0x1f8e
    .long 0x3b9, 0x1f0f, 0x1f8f
    .long 0x3b9, 0x1f20, 0x1f90
    .long 0x3b9, 0x1f21, 0x1f91
    .long 0x3b9, 0x1f22, 0x1f92
    .long 0x3b9, 0x1f23, 0x1f93
    .long 0x3b9, 0x1f24, 0x1f94
    .long 0x3b9, 0x1f25, 0x1f95
    .long 0x3b9, 0x1f26, 0x1f96
    .long 0x3b9, 0x1f27, 0x1f97
    .long 0x3b9, 0x1f28, 0x1f98
    .long 0x3b9, 0x1f29, 0x1f99
    .long 0x3b9, 0x1f2a, 0x1f9a
    .long 0x3b9, 0x1f2b, 0x1f9b
    .long 0x3b9, 0x1f2c, 0x1f9c
    .long 0x3b9, 0x1f2d, 0x1f9d
    .long 0x3b9, 0x1f2e, 0x1f9e
    .long 0x3b9, 0x1f2f, 0x1f9f
    .long 0x3b9, 0x1f60, 0x1fa0
    .long 0x3b9, 0x1f61, 0x1fa1
    .long 0x3b9, 0x1f62, 0x1fa2
    .long 0x3b9, 0x1f63, 0x1fa3
    .long 0x3b9, 0x1f64, 0x1fa4
    .long 0x3b9, 0x1f65, 0x1fa5
    .long 0x3b9, 0x1f66, 0x1fa6
    .long 0x3b9, 0x1f67, 0x1fa7
    .long 0x3b9, 0x1f68, 0x1fa8
    .long 0x3b9, 0x1f69, 0x1fa9
    .long 0x3b9, 0x1f6a, 0x1faa
    .long 0x3b9, 0x1f6b, 0x1fab
    .long 0x3b9, 0x1f6c, 0x1fac
    .long 0x3b9, 0x1f6d, 0x1fad
    .long 0x3b9, 0x1f6e, 0x1fae
    .long 0x3b9, 0x1f6f, 0x1faf
    .long 0x3b9, 0x1f70, 0x1fb2
    .long 0x3b9, 0x1f74, 0x1fc2
    .long 0x3b9, 0x1f7c, 0x1ff2
    .long 0x3b9, 0x1fb6, 0x1fb7
    .long 0x3b9, 0x1fc6, 0x1fc7
    .long 0x3b9, 0x1ff6, 0x1ff7
    .long 0x3bf, 0x27, 0x3cc
    .long 0x3c5, 0x22, 0x3cb
    .long 0x3c5, 0x27, 0x3cd
    .long 0x3c9, 0x27, 0x3ce
    .long 0x415, 0x3d, 0x20ac
    .long 0x417, 0x3d, 0x20bd
    .long 0x41d, 0x41e, 0x2116
    .long 0x41d, 0x43e, 0x2116
    .long 0x421, 0x3d, 0x20ac
    .long 0x437, 0x3d, 0x20bd
    .long 0x43f, 0x430, 0xa7
    .long 0x5b4, 0x5d9, 0xfb1d
    .long 0x5b7, 0x5d0, 0xfb2e
    .long 0x5b7, 0x5f2, 0xfb1f
    .long 0x5b8, 0x5d0, 0xfb2f
    .long 0x5b9, 0x5d5, 0xfb4b
    .long 0x5bc, 0x5d0, 0xfb30
    .long 0x5bc, 0x5d1, 0xfb31
    .long 0x5bc, 0x5d2, 0xfb32
    .long 0x5bc, 0x5d3, 0xfb33
    .long 0x5bc, 0x5d4, 0xfb34
    .long 0x5bc, 0x5d5, 0xfb35
    .long 0x5bc, 0x5d6, 0xfb36
    .long 0x5bc, 0x5d8, 0xfb38
    .long 0x5bc, 0x5d9, 0xfb39
    .long 0x5bc, 0x5da, 0xfb3a
    .long 0x5bc, 0x5db, 0xfb3b
    .long 0x5bc, 0x5dc, 0xfb3c
    .long 0x5bc, 0x5de, 0xfb3e
    .long 0x5bc, 0x5e0, 0xfb40
    .long 0x5bc, 0x5e1, 0xfb41
    .long 0x5bc, 0x5e3, 0xfb43
    .long 0x5bc, 0x5e4, 0xfb44
    .long 0x5bc, 0x5e6, 0xfb46
    .long 0x5bc, 0x5e7, 0xfb47
    .long 0x5bc, 0x5e8, 0xfb48
    .long 0x5bc, 0x5e9, 0xfb49
    .long 0x5bc, 0x5ea, 0xfb4a
    .long 0x5bf, 0x5d1, 0xfb4c
    .long 0x5bf, 0x5db, 0xfb4d
    .long 0x5bf, 0x5e4, 0xfb4e
    .long 0x5c1, 0x5e9, 0xfb2a
    .long 0x5c1, 0xfb49, 0xfb2c
    .long 0x5c2, 0x5e9, 0xfb2b
    .long 0x5c2, 0xfb49, 0xfb2d
    .long 0x653, 0x627, 0x622
    .long 0x654, 0x627, 0x623
    .long 0x654, 0x648, 0x624
    .long 0x654, 0x64a, 0x626
    .long 0x654, 0x6c1, 0x6c2
    .long 0x654, 0x6d2, 0x6d3
    .long 0x654, 0x6d5, 0x6c0
    .long 0x655, 0x627, 0x625
    .long 0x93c, 0x915, 0x958
    .long 0x93c, 0x916, 0x959
    .long 0x93c, 0x917, 0x95a
    .long 0x93c, 0x91c, 0x95b
    .long 0x93c, 0x921, 0x95c
    .long 0x93c, 0x922, 0x95d
    .long 0x93c, 0x928, 0x929
    .long 0x93c, 0x92b, 0x95e
    .long 0x93c, 0x92f, 0x95f
    .long 0x93c, 0x930, 0x931
    .long 0x93c, 0x933, 0x934
    .long 0x9bc, 0x9a1, 0x9dc
    .long 0x9bc, 0x9a2, 0x9dd
    .long 0x9bc, 0x9af, 0x9df
    .long 0x9c7, 0x9be, 0x9cb
    .long 0x9c7, 0x9d7, 0x9cc
    .long 0xa3c, 0xa16, 0xa59
    .long 0xa3c, 0xa17, 0xa5a
    .long 0xa3c, 0xa1c, 0xa5b
    .long 0xa3c, 0xa2b, 0xa5e
    .long 0xa3c, 0xa32, 0xa33
    .long 0xa3c, 0xa38, 0xa36
    .long 0xb3c, 0xb21, 0xb5c
    .long 0xb3c, 0xb22, 0xb5d
    .long 0xb47, 0xb3e, 0xb4b
    .long 0xb47, 0xb56, 0xb48
    .long 0xb47, 0xb57, 0xb4c
    .long 0xbc6, 0xbbe, 0xbca
    .long 0xbc6, 0xbd7, 0xbcc
    .long 0xbc7, 0xbbe, 0xbcb
    .long 0xbd7, 0xb92, 0xb94
    .long 0xc46, 0xc56, 0xc48
    .long 0xcbf, 0xcd5, 0xcc0
    .long 0xcc6, 0xcc2, 0xcca
    .long 0xcc6, 0xcd5, 0xcc7
    .long 0xcc6, 0xcd6, 0xcc8
    .long 0xcca, 0xcd5, 0xccb
    .long 0xd46, 0xd3e, 0xd4a
    .long 0xd46, 0xd57, 0xd4c
    .long 0xd47, 0xd3e, 0xd4b
    .long 0xdd9, 0xdca, 0xdda
    .long 0xdd9, 0xdcf, 0xddc
    .long 0xdd9, 0xddf, 0xdde
    .long 0xddc, 0xdca, 0xddd
    .long 0xf71, 0xf72, 0xf73
    .long 0xf71, 0xf74, 0xf75
    .long 0xf71, 0xf80, 0xf81
    .long 0xf90, 0xfb5, 0xfb9
    .long 0xf92, 0xfb7, 0xf93
    .long 0xf9c, 0xfb7, 0xf9d
    .long 0xfa1, 0xfb7, 0xfa2
    .long 0xfa6, 0xfb7, 0xfa7
    .long 0xfab, 0xfb7, 0xfac
    .long 0xfb2, 0xf80, 0xf76
    .long 0xfb3, 0xf80, 0xf78
    .long 0xfb5, 0xf40, 0xf69
    .long 0xfb7, 0xf42, 0xf43
    .long 0xfb7, 0xf4c, 0xf4d
    .long 0xfb7, 0xf51, 0xf52
    .long 0xfb7, 0xf56, 0xf57
    .long 0xfb7, 0xf5b, 0xf5c
    .long 0x102e, 0x1025, 0x1026
    .long 0x1100, 0x1100, 0x1101
    .long 0x1102, 0x1100, 0x1113
    .long 0x1102, 0x1102, 0x1114
    .long 0x1102, 0x1103, 0x1115
    .long 0x1102, 0x1107, 0x1116
    .long 0x1103, 0x1100, 0x1117
    .long 0x1103, 0x1103, 0x1104
    .long 0x1105, 0x1102, 0x1118
    .long 0x1105, 0x1105, 0x1119
    .long 0x1105, 0x110b, 0x111b
    .long 0x1105, 0x1112, 0x111a
    .long 0x1106, 0x1107, 0x111c
    .long 0x1106, 0x110b, 0x111d
    .long 0x1107, 0x1100, 0x111e
    .long 0x1107, 0x1102, 0x111f
    .long 0x1107, 0x1103, 0x1120
    .long 0x1107, 0x1107, 0x1108
    .long 0x1107, 0x1109, 0x1121
    .long 0x1107, 0x110a, 0x1125
    .long 0x1107, 0x110b, 0x112b
    .long 0x1107, 0x110c, 0x1127
    .long 0x1107, 0x110e, 0x1128
    .long 0x1107, 0x1110, 0x1129
    .long 0x1107, 0x1111, 0x112a
    .long 0x1107, 0x112b, 0x112c
    .long 0x1107, 0x112d, 0x1122
    .long 0x1107, 0x112f, 0x1123
    .long 0x1107, 0x1132, 0x1124
    .long 0x1107, 0x1136, 0x1126
    .long 0x1108, 0x110b, 0x112c
    .long 0x1109, 0x1100, 0x112d
    .long 0x1109, 0x1102, 0x112e
    .long 0x1109, 0x1103, 0x112f
    .long 0x1109, 0x1105, 0x1130
    .long 0x1109, 0x1106, 0x1131
    .long 0x1109, 0x1107, 0x1132
    .long 0x1109, 0x1109, 0x110a
    .long 0x1109, 0x110a, 0x1134
    .long 0x1109, 0x110b, 0x1135
    .long 0x1109, 0x110c, 0x1136
    .long 0x1109, 0x110e, 0x1137
    .long 0x1109, 0x110f, 0x1138
    .long 0x1109, 0x1110, 0x1139
    .long 0x1109, 0x1111, 0x113a
    .long 0x1109, 0x1112, 0x113b
    .long 0x1109, 0x111e, 0x1133
    .long 0x110a, 0x1109, 0x1134
    .long 0x110b, 0x1100, 0x1141
    .long 0x110b, 0x1103, 0x1142
    .long 0x110b, 0x1106, 0x1143
    .long 0x110b, 0x1107, 0x1144
    .long 0x110b, 0x1109, 0x1145
    .long 0x110b, 0x110b, 0x1147
    .long 0x110b, 0x110c, 0x1148
    .long 0x110b, 0x110e, 0x1149
    .long 0x110b, 0x1110, 0x114a
    .long 0x110b, 0x1111, 0x114b
    .long 0x110b, 0x1140, 0x1146
    .long 0x110c, 0x110b, 0x114d
    .long 0x110c, 0x110c, 0x110d
    .long 0x110e, 0x110f, 0x1152
    .long 0x110e, 0x1112, 0x1153
    .long 0x1111, 0x1107, 0x1156
    .long 0x1111, 0x110b, 0x1157
    .long 0x1112, 0x1112, 0x1158
    .long 0x1121, 0x1100, 0x1122
    .long 0x1121, 0x1103, 0x1123
    .long 0x1121, 0x1107, 0x1124
    .long 0x1121, 0x1109, 0x1125
    .long 0x1121, 0x110c, 0x1126
    .long 0x1132, 0x1100, 0x1133
    .long 0x113c, 0x113c, 0x113d
    .long 0x113e, 0x113e, 0x113f
    .long 0x114e, 0x114e, 0x114f
    .long 0x1150, 0x1150, 0x1151
    .long 0x1161, 0x1169, 0x1176
    .long 0x1161, 0x116e, 0x1177
    .long 0x1161, 0x1175, 0x1162
    .long 0x1163, 0x1169, 0x1178
    .long 0x1163, 0x116d, 0x1179
    .long 0x1163, 0x1175, 0x1164
    .long 0x1165, 0x1169, 0x117a
    .long 0x1165, 0x116e, 0x117b
    .long 0x1165, 0x1173, 0x117c
    .long 0x1165, 0x1175, 0x1166
    .long 0x1167, 0x1169, 0x117d
    .long 0x1167, 0x116e, 0x117e
    .long 0x1167, 0x1175, 0x1168
    .long 0x1169, 0x1161, 0x116a
    .long 0x1169, 0x1162, 0x116b
    .long 0x1169, 0x1165, 0x117f
    .long 0x1169, 0x1166, 0x1180
    .long 0x1169, 0x1168, 0x1181
    .long 0x1169, 0x1169, 0x1182
    .long 0x1169, 0x116e, 0x1183
    .long 0x1169, 0x1175, 0x116c
    .long 0x116a, 0x1175, 0x116b
    .long 0x116d, 0x1163, 0x1184
    .long 0x116d, 0x1164, 0x1185
    .long 0x116d, 0x1167, 0x1186
    .long 0x116d, 0x1169, 0x1187
    .long 0x116d, 0x1175, 0x1188
    .long 0x116e, 0x1161, 0x1189
    .long 0x116e, 0x1162, 0x118a
    .long 0x116e, 0x1165, 0x116f
    .long 0x116e, 0x1166, 0x1170
    .long 0x116e, 0x1168, 0x118c
    .long 0x116e, 0x116e, 0x118d
    .long 0x116e, 0x1175, 0x1171
    .long 0x116e, 0x117c, 0x118b
    .long 0x116f, 0x1173, 0x118b
    .long 0x116f, 0x1175, 0x1170
    .long 0x1172, 0x1161, 0x118e
    .long 0x1172, 0x1165, 0x118f
    .long 0x1172, 0x1166, 0x1190
    .long 0x1172, 0x1167, 0x1191
    .long 0x1172, 0x1168, 0x1192
    .long 0x1172, 0x116e, 0x1193
    .long 0x1172, 0x1175, 0x1194
    .long 0x1173, 0x116e, 0x1195
    .long 0x1173, 0x1173, 0x1196
    .long 0x1173, 0x1175, 0x1174
    .long 0x1174, 0x116e, 0x1197
    .long 0x1175, 0x1161, 0x1198
    .long 0x1175, 0x1163, 0x1199
    .long 0x1175, 0x1169, 0x119a
    .long 0x1175, 0x116e, 0x119b
    .long 0x1175, 0x1173, 0x119c
    .long 0x1175, 0x119e, 0x119d
    .long 0x119e, 0x1165, 0x119f
    .long 0x119e, 0x116e, 0x11a0
    .long 0x119e, 0x1175, 0x11a1
    .long 0x119e, 0x119e, 0x11a2
    .long 0x11a8, 0x11a8, 0x11a9
    .long 0x11a8, 0x11af, 0x11c3
    .long 0x11a8, 0x11ba, 0x11aa
    .long 0x11a8, 0x11e7, 0x11c4
    .long 0x11aa, 0x11a8, 0x11c4
    .long 0x11ab, 0x11a8, 0x11c5
    .long 0x11ab, 0x11ae, 0x11c6
    .long 0x11ab, 0x11ba, 0x11c7
    .long 0x11ab, 0x11bd, 0x11ac
    .long 0x11ab, 0x11c0, 0x11c9
    .long 0x11ab, 0x11c2, 0x11ad
    .long 0x11ab, 0x11eb, 0x11c8
    .long 0x11ae, 0x11a8, 0x11ca
    .long 0x11ae, 0x11af, 0x11cb
    .long 0x11af, 0x11a8, 0x11b0
    .long 0x11af, 0x11aa, 0x11cc
    .long 0x11af, 0x11ab, 0x11cd
    .long 0x11af, 0x11ae, 0x11ce
    .long 0x11af, 0x11af, 0x11d0
    .long 0x11af, 0x11b7, 0x11b1
    .long 0x11af, 0x11b8, 0x11b2
    .long 0x11af, 0x11b9, 0x11d3
    .long 0x11af, 0x11ba, 0x11b3
    .long 0x11af, 0x11bb, 0x11d6
    .long 0x11af, 0x11bf, 0x11d8
    .long 0x11af, 0x11c0, 0x11b4
    .long 0x11af, 0x11c1, 0x11b5
    .long 0x11af, 0x11c2, 0x11b6
    .long 0x11af, 0x11da, 0x11d1
    .long 0x11af, 0x11dd, 0x11d2
    .long 0x11af, 0x11e5, 0x11d4
    .long 0x11af, 0x11e6, 0x11d5
    .long 0x11af, 0x11eb, 0x11d7
    .long 0x11af, 0x11f9, 0x11d9
    .long 0x11b0, 0x11ba, 0x11cc
    .long 0x11b1, 0x11a8, 0x11d1
    .long 0x11b1, 0x11ba, 0x11d2
    .long 0x11b2, 0x11ba, 0x11d3
    .long 0x11b2, 0x11bc, 0x11d5
    .long 0x11b2, 0x11c2, 0x11d4
    .long 0x11b3, 0x11ba, 0x11d6
    .long 0x11b7, 0x11a8, 0x11da
    .long 0x11b7, 0x11af, 0x11db
    .long 0x11b7, 0x11b8, 0x11dc
    .long 0x11b7, 0x11ba, 0x11dd
    .long 0x11b7, 0x11bb, 0x11de
    .long 0x11b7, 0x11bc, 0x11e2
    .long 0x11b7, 0x11be, 0x11e0
    .long 0x11b7, 0x11c2, 0x11e1
    .long 0x11b7, 0x11eb, 0x11df
    .long 0x11b8, 0x11af, 0x11e3
    .long 0x11b8, 0x11ba, 0x11b9
    .long 0x11b8, 0x11bc, 0x11e6
    .long 0x11b8, 0x11c1, 0x11e4
    .long 0x11b8, 0x11c2, 0x11e5
    .long 0x11ba, 0x11a8, 0x11e7
    .long 0x11ba, 0x11ae, 0x11e8
    .long 0x11ba, 0x11af, 0x11e9
    .long 0x11ba, 0x11b8, 0x11ea
    .long 0x11ba, 0x11ba, 0x11bb
    .long 0x11bc, 0x11a8, 0x11ec
    .long 0x11bc, 0x11a9, 0x11ed
    .long 0x11bc, 0x11bc, 0x11ee
    .long 0x11bc, 0x11bf, 0x11ef
    .long 0x11c1, 0x11b8, 0x11f3
    .long 0x11c1, 0x11bc, 0x11f4
    .long 0x11c2, 0x11ab, 0x11f5
    .long 0x11c2, 0x11af, 0x11f6
    .long 0x11c2, 0x11b7, 0x11f7
    .long 0x11c2, 0x11b8, 0x11f8
    .long 0x11ce, 0x11c2, 0x11cf
    .long 0x11dd, 0x11ba, 0x11de
    .long 0x11ec, 0x11a8, 0x11ed
    .long 0x11f0, 0x11ba, 0x11f1
    .long 0x11f0, 0x11eb, 0x11f2
    .long 0x1fbf, 0x27, 0x1fce
    .long 0x1fbf, 0x60, 0x1fcd
    .long 0x1fbf, 0x7e, 0x1fcf
    .long 0x1fbf, 0xb4, 0x1fce
    .long 0x1ffe, 0x27, 0x1fde
    .long 0x1ffe, 0x60, 0x1fdd
    .long 0x1ffe, 0x7e, 0x1fdf
    .long 0x1ffe, 0xb4, 0x1fde
    .long 0x2190, 0x7c, 0x2345
    .long 0x2190, 0x2395, 0x2347
    .long 0x2191, 0x2d, 0x234f
    .long 0x2191, 0x2395, 0x2350
    .long 0x2192, 0x7c, 0x2346
    .long 0x2192, 0x2395, 0x2348
    .long 0x2193, 0x2d, 0x2356
    .long 0x2193, 0x2395, 0x2357
    .long 0x2203, 0x338, 0x2204
    .long 0x2206, 0x5f, 0x2359
    .long 0x2206, 0x7c, 0x234b
    .long 0x2206, 0x2395, 0x234d
    .long 0x2207, 0x7c, 0x2352
    .long 0x2207, 0x7e, 0x236b
    .long 0x2207, 0xa8, 0x2362
    .long 0x2207, 0x2395, 0x2354
    .long 0x2208, 0x338, 0x2209
    .long 0x220a, 0x5f, 0x2377
    .long 0x220b, 0x338, 0x220c
    .long 0x2218, 0x5f, 0x235b
    .long 0x2218, 0xa8, 0x2364
    .long 0x2218, 0x2229, 0x235d
    .long 0x2218, 0x22a4, 0x2355
    .long 0x2218, 0x22a5, 0x234e
    .long 0x2218, 0x2395, 0x233b
    .long 0x2218, 0x25cb, 0x233e
    .long 0x2223, 0x338, 0x2224
    .long 0x2225, 0x338, 0x2226
    .long 0x2227, 0x7e, 0x2372
    .long 0x2227, 0x2228, 0x22c4
    .long 0x2227, 0x2395, 0x2353
    .long 0x2228, 0x7e, 0x2371
    .long 0x2228, 0x2227, 0x22c4
    .long 0x2228, 0x2395, 0x234c
    .long 0x2229, 0x2218, 0x235d
    .long 0x222a, 0x7c, 0x2366
    .long 0x223c, 0x338, 0x2241
    .long 0x2243, 0x338, 0x2244
    .long 0x2248, 0x338, 0x2249
    .long 0x224d, 0x338, 0x226d
    .long 0x2260, 0x5f, 0x2262
    .long 0x2260, 0x2395, 0x236f
    .long 0x2261, 0x338, 0x2262
    .long 0x2264, 0x338, 0x2270
    .long 0x2265, 0x338, 0x2271
    .long 0x2272, 0x338, 0x2274
    .long 0x2273, 0x338, 0x2275
    .long 0x2276, 0x338, 0x2278
    .long 0x2277, 0x338, 0x2279
    .long 0x227a, 0x338, 0x2280
    .long 0x227b, 0x338, 0x2281
    .long 0x227c, 0x338, 0x22e0
    .long 0x227d, 0x338, 0x22e1
    .long 0x2282, 0x5f, 0x2286
    .long 0x2282, 0x7c, 0x2367
    .long 0x2282, 0x338, 0x2284
    .long 0x2283, 0x5f, 0x2287
    .long 0x2283, 0x338, 0x2285
    .long 0x2286, 0x338, 0x2288
    .long 0x2287, 0x338, 0x2289
    .long 0x2291, 0x338, 0x22e2
    .long 0x2292, 0x338, 0x22e3
    .long 0x22a2, 0x338, 0x22ac
    .long 0x22a4, 0xa8, 0x2361
    .long 0x22a4, 0xaf, 0x2351
    .long 0x22a4, 0x2218, 0x2355
    .long 0x22a4, 0x22a5, 0x2336
    .long 0x22a5, 0x5f, 0x234a
    .long 0x22a5, 0x2218, 0x234e
    .long 0x22a5, 0x22a4, 0x2336
    .long 0x22a8, 0x338, 0x22ad
    .long 0x22a9, 0x338, 0x22ae
    .long 0x22ab, 0x338, 0x22af
    .long 0x22b2, 0x338, 0x22ea
    .long 0x22b3, 0x338, 0x22eb
    .long 0x22b4, 0x338, 0x22ec
    .long 0x22b5, 0x338, 0x22ed
    .long 0x22c4, 0x5f, 0x235a
    .long 0x22c4, 0x2395, 0x233a
    .long 0x2373, 0x5f, 0x2378
    .long 0x2375, 0x5f, 0x2379
    .long 0x237a, 0x5f, 0x2376
    .long 0x2395, 0x27, 0x235e
    .long 0x2395, 0x2f, 0x2341
    .long 0x2395, 0x3a, 0x2360
    .long 0x2395, 0x3c, 0x2343
    .long 0x2395, 0x3d, 0x2338
    .long 0x2395, 0x3e, 0x2344
    .long 0x2395, 0x3f, 0x2370
    .long 0x2395, 0x5c, 0x2342
    .long 0x2395, 0xf7, 0x2339
    .long 0x2395, 0x2190, 0x2347
    .long 0x2395, 0x2191, 0x2350
    .long 0x2395, 0x2192, 0x2348
    .long 0x2395, 0x2193, 0x2357
    .long 0x2395, 0x2206, 0x234d
    .long 0x2395, 0x2207, 0x2354
    .long 0x2395, 0x2218, 0x233b
    .long 0x2395, 0x2227, 0x2353
    .long 0x2395, 0x2228, 0x234c
    .long 0x2395, 0x2260, 0x236f
    .long 0x2395, 0x22c4, 0x233a
    .long 0x2395, 0x25cb, 0x233c
    .long 0x25cb, 0x2a, 0x235f
    .long 0x25cb, 0x2d, 0x2296
    .long 0x25cb, 0x2e, 0x2299
    .long 0x25cb, 0x5c, 0x2349
    .long 0x25cb, 0x5f, 0x235c
    .long 0x25cb, 0x7c, 0x233d
    .long 0x25cb, 0xa8, 0x2365
    .long 0x25cb, 0x2218, 0x233e
    .long 0x25cb, 0x2395, 0x233c
    .long 0x2add, 0x338, 0x2adc
    .long 0x1d157, 0x1d165, 0x1d15e
    .long 0x1d158, 0x1d165, 0x1d15f
    .long 0x1d15f, 0x1d16e, 0x1d160
    .long 0x1d15f, 0x1d16f, 0x1d161
    .long 0x1d15f, 0x1d170, 0x1d162
    .long 0x1d15f, 0x1d171, 0x1d163
    .long 0x1d15f, 0x1d172, 0x1d164
    .long 0x1d1b9, 0x1d165, 0x1d1bb
    .long 0x1d1ba, 0x1d165, 0x1d1bc
    .long 0x1d1bb, 0x1d16e, 0x1d1bd
    .long 0x1d1bb, 0x1d16f, 0x1d1bf
    .long 0x1d1bc, 0x1d16e, 0x1d1be
    .long 0x1d1bc, 0x1d16f, 0x1d1c0
    .long 0, 0, 0
.Ldoc_compose_triple_sequence_table:
    # Three-symbol sequences from X.Org libX11 en_US.UTF-8; four-key sequences remain unsupported.
    # Record encoding: first scalar, second scalar, third scalar, result scalar.
    .long 0x21, 0x2b, 0x4f, 0x1ee2
    .long 0x21, 0x2b, 0x55, 0x1ef0
    .long 0x21, 0x2b, 0x6f, 0x1ee3
    .long 0x21, 0x2b, 0x75, 0x1ef1
    .long 0x22, 0x5f, 0x55, 0x1e7a
    .long 0x22, 0x5f, 0x75, 0x1e7b
    .long 0x22, 0x7e, 0x4f, 0x1e4e
    .long 0x22, 0x7e, 0x6f, 0x1e4f
    .long 0x22, 0xaf, 0x55, 0x1e7a
    .long 0x22, 0xaf, 0x75, 0x1e7b
    .long 0x27, 0x22, 0x20, 0x385
    .long 0x27, 0x22, 0x49, 0x1e2e
    .long 0x27, 0x22, 0x55, 0x1d7
    .long 0x27, 0x22, 0x69, 0x1e2f
    .long 0x27, 0x22, 0x75, 0x1d8
    .long 0x27, 0x22, 0x3b9, 0x390
    .long 0x27, 0x22, 0x3c5, 0x3b0
    .long 0x27, 0x28, 0x391, 0x1f0d
    .long 0x27, 0x28, 0x395, 0x1f1d
    .long 0x27, 0x28, 0x397, 0x1f2d
    .long 0x27, 0x28, 0x399, 0x1f3d
    .long 0x27, 0x28, 0x39f, 0x1f4d
    .long 0x27, 0x28, 0x3a5, 0x1f5d
    .long 0x27, 0x28, 0x3a9, 0x1f6d
    .long 0x27, 0x28, 0x3b1, 0x1f05
    .long 0x27, 0x28, 0x3b5, 0x1f15
    .long 0x27, 0x28, 0x3b7, 0x1f25
    .long 0x27, 0x28, 0x3b9, 0x1f35
    .long 0x27, 0x28, 0x3bf, 0x1f45
    .long 0x27, 0x28, 0x3c5, 0x1f55
    .long 0x27, 0x28, 0x3c9, 0x1f65
    .long 0x27, 0x29, 0x391, 0x1f0c
    .long 0x27, 0x29, 0x395, 0x1f1c
    .long 0x27, 0x29, 0x397, 0x1f2c
    .long 0x27, 0x29, 0x399, 0x1f3c
    .long 0x27, 0x29, 0x39f, 0x1f4c
    .long 0x27, 0x29, 0x3a9, 0x1f6c
    .long 0x27, 0x29, 0x3b1, 0x1f04
    .long 0x27, 0x29, 0x3b5, 0x1f14
    .long 0x27, 0x29, 0x3b7, 0x1f24
    .long 0x27, 0x29, 0x3b9, 0x1f34
    .long 0x27, 0x29, 0x3bf, 0x1f44
    .long 0x27, 0x29, 0x3c5, 0x1f54
    .long 0x27, 0x29, 0x3c9, 0x1f64
    .long 0x27, 0x2b, 0x4f, 0x1eda
    .long 0x27, 0x2b, 0x55, 0x1ee8
    .long 0x27, 0x2b, 0x6f, 0x1edb
    .long 0x27, 0x2b, 0x75, 0x1ee9
    .long 0x27, 0x2f, 0x4f, 0x1fe
    .long 0x27, 0x2f, 0x6f, 0x1ff
    .long 0x27, 0x5e, 0x41, 0x1ea4
    .long 0x27, 0x5e, 0x45, 0x1ebe
    .long 0x27, 0x5e, 0x4f, 0x1ed0
    .long 0x27, 0x5e, 0x61, 0x1ea5
    .long 0x27, 0x5e, 0x65, 0x1ebf
    .long 0x27, 0x5e, 0x6f, 0x1ed1
    .long 0x27, 0x5f, 0x45, 0x1e16
    .long 0x27, 0x5f, 0x4f, 0x1e52
    .long 0x27, 0x5f, 0x65, 0x1e17
    .long 0x27, 0x5f, 0x6f, 0x1e53
    .long 0x27, 0x62, 0x41, 0x1eae
    .long 0x27, 0x62, 0x61, 0x1eaf
    .long 0x27, 0x7e, 0x4f, 0x1e4c
    .long 0x27, 0x7e, 0x55, 0x1e78
    .long 0x27, 0x7e, 0x6f, 0x1e4d
    .long 0x27, 0x7e, 0x75, 0x1e79
    .long 0x27, 0xaf, 0x45, 0x1e16
    .long 0x27, 0xaf, 0x4f, 0x1e52
    .long 0x27, 0xaf, 0x65, 0x1e17
    .long 0x27, 0xaf, 0x6f, 0x1e53
    .long 0x27, 0xb8, 0x43, 0x1e08
    .long 0x27, 0xb8, 0x63, 0x1e09
    .long 0x28, 0x29, 0x29, 0x1f12f
    .long 0x28, 0x30, 0x29, 0x24ea
    .long 0x28, 0x31, 0x29, 0x2460
    .long 0x28, 0x32, 0x29, 0x2461
    .long 0x28, 0x33, 0x29, 0x2462
    .long 0x28, 0x34, 0x29, 0x2463
    .long 0x28, 0x35, 0x29, 0x2464
    .long 0x28, 0x36, 0x29, 0x2465
    .long 0x28, 0x37, 0x29, 0x2466
    .long 0x28, 0x38, 0x29, 0x2467
    .long 0x28, 0x39, 0x29, 0x2468
    .long 0x28, 0x41, 0x29, 0x24b6
    .long 0x28, 0x42, 0x29, 0x24b7
    .long 0x28, 0x43, 0x29, 0x24b8
    .long 0x28, 0x44, 0x29, 0x24b9
    .long 0x28, 0x45, 0x29, 0x24ba
    .long 0x28, 0x46, 0x29, 0x24bb
    .long 0x28, 0x47, 0x29, 0x24bc
    .long 0x28, 0x48, 0x29, 0x24bd
    .long 0x28, 0x49, 0x29, 0x24be
    .long 0x28, 0x4a, 0x29, 0x24bf
    .long 0x28, 0x4b, 0x29, 0x24c0
    .long 0x28, 0x4c, 0x29, 0x24c1
    .long 0x28, 0x4d, 0x29, 0x24c2
    .long 0x28, 0x4e, 0x29, 0x24c3
    .long 0x28, 0x4f, 0x29, 0x24c4
    .long 0x28, 0x50, 0x29, 0x24c5
    .long 0x28, 0x51, 0x29, 0x24c6
    .long 0x28, 0x52, 0x29, 0x24c7
    .long 0x28, 0x53, 0x29, 0x24c8
    .long 0x28, 0x54, 0x29, 0x24c9
    .long 0x28, 0x55, 0x29, 0x24ca
    .long 0x28, 0x56, 0x29, 0x24cb
    .long 0x28, 0x57, 0x29, 0x24cc
    .long 0x28, 0x58, 0x29, 0x24cd
    .long 0x28, 0x59, 0x29, 0x24ce
    .long 0x28, 0x5a, 0x29, 0x24cf
    .long 0x28, 0x61, 0x29, 0x24d0
    .long 0x28, 0x62, 0x29, 0x24d1
    .long 0x28, 0x63, 0x29, 0x24d2
    .long 0x28, 0x64, 0x29, 0x24d3
    .long 0x28, 0x65, 0x29, 0x24d4
    .long 0x28, 0x66, 0x29, 0x24d5
    .long 0x28, 0x67, 0x29, 0x24d6
    .long 0x28, 0x68, 0x29, 0x24d7
    .long 0x28, 0x69, 0x29, 0x24d8
    .long 0x28, 0x6a, 0x29, 0x24d9
    .long 0x28, 0x6b, 0x29, 0x24da
    .long 0x28, 0x6c, 0x29, 0x24db
    .long 0x28, 0x6d, 0x29, 0x24dc
    .long 0x28, 0x6e, 0x29, 0x24dd
    .long 0x28, 0x6f, 0x29, 0x24de
    .long 0x28, 0x70, 0x29, 0x24df
    .long 0x28, 0x71, 0x29, 0x24e0
    .long 0x28, 0x72, 0x29, 0x24e1
    .long 0x28, 0x73, 0x29, 0x24e2
    .long 0x28, 0x74, 0x29, 0x24e3
    .long 0x28, 0x75, 0x29, 0x24e4
    .long 0x28, 0x76, 0x29, 0x24e5
    .long 0x28, 0x77, 0x29, 0x24e6
    .long 0x28, 0x78, 0x29, 0x24e7
    .long 0x28, 0x79, 0x29, 0x24e8
    .long 0x28, 0x7a, 0x29, 0x24e9
    .long 0x28, 0x1100, 0x29, 0x3260
    .long 0x28, 0x1102, 0x29, 0x3261
    .long 0x28, 0x1103, 0x29, 0x3262
    .long 0x28, 0x1105, 0x29, 0x3263
    .long 0x28, 0x1106, 0x29, 0x3264
    .long 0x28, 0x1107, 0x29, 0x3265
    .long 0x28, 0x1109, 0x29, 0x3266
    .long 0x28, 0x110b, 0x29, 0x3267
    .long 0x28, 0x110c, 0x29, 0x3268
    .long 0x28, 0x110e, 0x29, 0x3269
    .long 0x28, 0x110f, 0x29, 0x326a
    .long 0x28, 0x1110, 0x29, 0x326b
    .long 0x28, 0x1111, 0x29, 0x326c
    .long 0x28, 0x1112, 0x29, 0x326d
    .long 0x28, 0x30a2, 0x29, 0x32d0
    .long 0x28, 0x30a4, 0x29, 0x32d1
    .long 0x28, 0x30a6, 0x29, 0x32d2
    .long 0x28, 0x30a8, 0x29, 0x32d3
    .long 0x28, 0x30aa, 0x29, 0x32d4
    .long 0x28, 0x30ab, 0x29, 0x32d5
    .long 0x28, 0x30ad, 0x29, 0x32d6
    .long 0x28, 0x30af, 0x29, 0x32d7
    .long 0x28, 0x30b1, 0x29, 0x32d8
    .long 0x28, 0x30b3, 0x29, 0x32d9
    .long 0x28, 0x30b5, 0x29, 0x32da
    .long 0x28, 0x30b7, 0x29, 0x32db
    .long 0x28, 0x30b9, 0x29, 0x32dc
    .long 0x28, 0x30bb, 0x29, 0x32dd
    .long 0x28, 0x30bd, 0x29, 0x32de
    .long 0x28, 0x30bf, 0x29, 0x32df
    .long 0x28, 0x30c1, 0x29, 0x32e0
    .long 0x28, 0x30c4, 0x29, 0x32e1
    .long 0x28, 0x30c6, 0x29, 0x32e2
    .long 0x28, 0x30c8, 0x29, 0x32e3
    .long 0x28, 0x30ca, 0x29, 0x32e4
    .long 0x28, 0x30cb, 0x29, 0x32e5
    .long 0x28, 0x30cc, 0x29, 0x32e6
    .long 0x28, 0x30cd, 0x29, 0x32e7
    .long 0x28, 0x30ce, 0x29, 0x32e8
    .long 0x28, 0x30cf, 0x29, 0x32e9
    .long 0x28, 0x30d2, 0x29, 0x32ea
    .long 0x28, 0x30d5, 0x29, 0x32eb
    .long 0x28, 0x30d8, 0x29, 0x32ec
    .long 0x28, 0x30db, 0x29, 0x32ed
    .long 0x28, 0x30de, 0x29, 0x32ee
    .long 0x28, 0x30df, 0x29, 0x32ef
    .long 0x28, 0x30e0, 0x29, 0x32f0
    .long 0x28, 0x30e1, 0x29, 0x32f1
    .long 0x28, 0x30e2, 0x29, 0x32f2
    .long 0x28, 0x30e4, 0x29, 0x32f3
    .long 0x28, 0x30e6, 0x29, 0x32f4
    .long 0x28, 0x30e8, 0x29, 0x32f5
    .long 0x28, 0x30e9, 0x29, 0x32f6
    .long 0x28, 0x30ea, 0x29, 0x32f7
    .long 0x28, 0x30eb, 0x29, 0x32f8
    .long 0x28, 0x30ec, 0x29, 0x32f9
    .long 0x28, 0x30ed, 0x29, 0x32fa
    .long 0x28, 0x30ef, 0x29, 0x32fb
    .long 0x28, 0x30f0, 0x29, 0x32fc
    .long 0x28, 0x30f1, 0x29, 0x32fd
    .long 0x28, 0x30f2, 0x29, 0x32fe
    .long 0x28, 0x4e00, 0x29, 0x3280
    .long 0x28, 0x4e03, 0x29, 0x3286
    .long 0x28, 0x4e09, 0x29, 0x3282
    .long 0x28, 0x4e0a, 0x29, 0x32a4
    .long 0x28, 0x4e0b, 0x29, 0x32a6
    .long 0x28, 0x4e2d, 0x29, 0x32a5
    .long 0x28, 0x4e5d, 0x29, 0x3288
    .long 0x28, 0x4e8c, 0x29, 0x3281
    .long 0x28, 0x4e94, 0x29, 0x3284
    .long 0x28, 0x4f01, 0x29, 0x32ad
    .long 0x28, 0x4f11, 0x29, 0x32a1
    .long 0x28, 0x512a, 0x29, 0x329d
    .long 0x28, 0x516b, 0x29, 0x3287
    .long 0x28, 0x516d, 0x29, 0x3285
    .long 0x28, 0x5199, 0x29, 0x32a2
    .long 0x28, 0x52b4, 0x29, 0x3298
    .long 0x28, 0x533b, 0x29, 0x32a9
    .long 0x28, 0x5341, 0x29, 0x3289
    .long 0x28, 0x5354, 0x29, 0x32af
    .long 0x28, 0x5370, 0x29, 0x329e
    .long 0x28, 0x53f3, 0x29, 0x32a8
    .long 0x28, 0x540d, 0x29, 0x3294
    .long 0x28, 0x56db, 0x29, 0x3283
    .long 0x28, 0x571f, 0x29, 0x328f
    .long 0x28, 0x591c, 0x29, 0x32b0
    .long 0x28, 0x5973, 0x29, 0x329b
    .long 0x28, 0x5b66, 0x29, 0x32ab
    .long 0x28, 0x5b97, 0x29, 0x32aa
    .long 0x28, 0x5de6, 0x29, 0x32a7
    .long 0x28, 0x65e5, 0x29, 0x3290
    .long 0x28, 0x6708, 0x29, 0x328a
    .long 0x28, 0x6709, 0x29, 0x3292
    .long 0x28, 0x6728, 0x29, 0x328d
    .long 0x28, 0x682a, 0x29, 0x3291
    .long 0x28, 0x6b63, 0x29, 0x32a3
    .long 0x28, 0x6c34, 0x29, 0x328c
    .long 0x28, 0x6ce8, 0x29, 0x329f
    .long 0x28, 0x706b, 0x29, 0x328b
    .long 0x28, 0x7279, 0x29, 0x3295
    .long 0x28, 0x7537, 0x29, 0x329a
    .long 0x28, 0x76e3, 0x29, 0x32ac
    .long 0x28, 0x793e, 0x29, 0x3293
    .long 0x28, 0x795d, 0x29, 0x3297
    .long 0x28, 0x79d8, 0x29, 0x3299
    .long 0x28, 0x8ca1, 0x29, 0x3296
    .long 0x28, 0x8cc7, 0x29, 0x32ae
    .long 0x28, 0x9069, 0x29, 0x329c
    .long 0x28, 0x91d1, 0x29, 0x328e
    .long 0x28, 0x9805, 0x29, 0x32a0
    .long 0x2a, 0x27, 0x41, 0x1fa
    .long 0x2a, 0x27, 0x61, 0x1fb
    .long 0x2d, 0x2d, 0x20, 0xad
    .long 0x2d, 0x2d, 0x2d, 0x2014
    .long 0x2d, 0x2d, 0x2e, 0x2013
    .long 0x2e, 0x21, 0x53, 0x1e68
    .long 0x2e, 0x21, 0x73, 0x1e69
    .long 0x2e, 0x27, 0x53, 0x1e64
    .long 0x2e, 0x27, 0x73, 0x1e65
    .long 0x2e, 0xb4, 0x53, 0x1e64
    .long 0x2e, 0xb4, 0x73, 0x1e65
    .long 0x31, 0x31, 0x30, 0x2152
    .long 0x3f, 0x2b, 0x4f, 0x1ede
    .long 0x3f, 0x2b, 0x55, 0x1eec
    .long 0x3f, 0x2b, 0x6f, 0x1edf
    .long 0x3f, 0x2b, 0x75, 0x1eed
    .long 0x3f, 0x5e, 0x41, 0x1ea8
    .long 0x3f, 0x5e, 0x45, 0x1ec2
    .long 0x3f, 0x5e, 0x4f, 0x1ed4
    .long 0x3f, 0x5e, 0x61, 0x1ea9
    .long 0x3f, 0x5e, 0x65, 0x1ec3
    .long 0x3f, 0x5e, 0x6f, 0x1ed5
    .long 0x3f, 0x62, 0x41, 0x1eb2
    .long 0x3f, 0x62, 0x61, 0x1eb3
    .long 0x55, 0x21, 0x41, 0x1eb6
    .long 0x55, 0x21, 0x61, 0x1eb7
    .long 0x55, 0xb8, 0x45, 0x1e1c
    .long 0x55, 0xb8, 0x65, 0x1e1d
    .long 0x5c, 0x6f, 0x2f, 0x1f64c
    .long 0x5e, 0x21, 0x41, 0x1eac
    .long 0x5e, 0x21, 0x45, 0x1ec6
    .long 0x5e, 0x21, 0x4f, 0x1ed8
    .long 0x5e, 0x21, 0x61, 0x1ead
    .long 0x5e, 0x21, 0x65, 0x1ec7
    .long 0x5e, 0x21, 0x6f, 0x1ed9
    .long 0x5e, 0x5f, 0x61, 0xaa
    .long 0x5e, 0x5f, 0x68, 0x2b0
    .long 0x5e, 0x5f, 0x69, 0x2071
    .long 0x5e, 0x5f, 0x6a, 0x2b2
    .long 0x5e, 0x5f, 0x6c, 0x2e1
    .long 0x5e, 0x5f, 0x6e, 0x207f
    .long 0x5e, 0x5f, 0x6f, 0xba
    .long 0x5e, 0x5f, 0x72, 0x2b3
    .long 0x5e, 0x5f, 0x73, 0x2e2
    .long 0x5e, 0x5f, 0x77, 0x2b7
    .long 0x5e, 0x5f, 0x78, 0x2e3
    .long 0x5e, 0x5f, 0x79, 0x2b8
    .long 0x5e, 0x5f, 0x263, 0x2e0
    .long 0x5e, 0x5f, 0x266, 0x2b1
    .long 0x5e, 0x5f, 0x279, 0x2b4
    .long 0x5e, 0x5f, 0x27b, 0x2b5
    .long 0x5e, 0x5f, 0x281, 0x2b6
    .long 0x5e, 0x5f, 0x295, 0x2e4
    .long 0x5f, 0x21, 0x4c, 0x1e38
    .long 0x5f, 0x21, 0x52, 0x1e5c
    .long 0x5f, 0x21, 0x6c, 0x1e39
    .long 0x5f, 0x21, 0x72, 0x1e5d
    .long 0x5f, 0x22, 0x41, 0x1de
    .long 0x5f, 0x22, 0x4f, 0x22a
    .long 0x5f, 0x22, 0x55, 0x1d5
    .long 0x5f, 0x22, 0x61, 0x1df
    .long 0x5f, 0x22, 0x6f, 0x22b
    .long 0x5f, 0x22, 0x75, 0x1d6
    .long 0x5f, 0x2e, 0x41, 0x1e0
    .long 0x5f, 0x2e, 0x4f, 0x230
    .long 0x5f, 0x2e, 0x61, 0x1e1
    .long 0x5f, 0x2e, 0x6f, 0x231
    .long 0x5f, 0x3b, 0x4f, 0x1ec
    .long 0x5f, 0x3b, 0x6f, 0x1ed
    .long 0x5f, 0x7e, 0x4f, 0x22c
    .long 0x5f, 0x7e, 0x6f, 0x22d
    .long 0x60, 0x22, 0x55, 0x1db
    .long 0x60, 0x22, 0x75, 0x1dc
    .long 0x60, 0x22, 0x3b9, 0x1fd2
    .long 0x60, 0x22, 0x3c5, 0x1fe2
    .long 0x60, 0x28, 0x391, 0x1f0b
    .long 0x60, 0x28, 0x395, 0x1f1b
    .long 0x60, 0x28, 0x397, 0x1f2b
    .long 0x60, 0x28, 0x399, 0x1f3b
    .long 0x60, 0x28, 0x39f, 0x1f4b
    .long 0x60, 0x28, 0x3a5, 0x1f5b
    .long 0x60, 0x28, 0x3a9, 0x1f6b
    .long 0x60, 0x28, 0x3b1, 0x1f03
    .long 0x60, 0x28, 0x3b5, 0x1f13
    .long 0x60, 0x28, 0x3b7, 0x1f23
    .long 0x60, 0x28, 0x3b9, 0x1f33
    .long 0x60, 0x28, 0x3bf, 0x1f43
    .long 0x60, 0x28, 0x3c5, 0x1f53
    .long 0x60, 0x28, 0x3c9, 0x1f63
    .long 0x60, 0x29, 0x391, 0x1f0a
    .long 0x60, 0x29, 0x395, 0x1f1a
    .long 0x60, 0x29, 0x397, 0x1f2a
    .long 0x60, 0x29, 0x399, 0x1f3a
    .long 0x60, 0x29, 0x39f, 0x1f4a
    .long 0x60, 0x29, 0x3a9, 0x1f6a
    .long 0x60, 0x29, 0x3b1, 0x1f02
    .long 0x60, 0x29, 0x3b5, 0x1f12
    .long 0x60, 0x29, 0x3b7, 0x1f22
    .long 0x60, 0x29, 0x3b9, 0x1f32
    .long 0x60, 0x29, 0x3bf, 0x1f42
    .long 0x60, 0x29, 0x3c5, 0x1f52
    .long 0x60, 0x29, 0x3c9, 0x1f62
    .long 0x60, 0x2b, 0x4f, 0x1edc
    .long 0x60, 0x2b, 0x55, 0x1eea
    .long 0x60, 0x2b, 0x6f, 0x1edd
    .long 0x60, 0x2b, 0x75, 0x1eeb
    .long 0x60, 0x5e, 0x41, 0x1ea6
    .long 0x60, 0x5e, 0x45, 0x1ec0
    .long 0x60, 0x5e, 0x4f, 0x1ed2
    .long 0x60, 0x5e, 0x61, 0x1ea7
    .long 0x60, 0x5e, 0x65, 0x1ec1
    .long 0x60, 0x5e, 0x6f, 0x1ed3
    .long 0x60, 0x5f, 0x45, 0x1e14
    .long 0x60, 0x5f, 0x4f, 0x1e50
    .long 0x60, 0x5f, 0x65, 0x1e15
    .long 0x60, 0x5f, 0x6f, 0x1e51
    .long 0x60, 0x62, 0x41, 0x1eb0
    .long 0x60, 0x62, 0x61, 0x1eb1
    .long 0x60, 0xaf, 0x45, 0x1e14
    .long 0x60, 0xaf, 0x4f, 0x1e50
    .long 0x60, 0xaf, 0x65, 0x1e15
    .long 0x60, 0xaf, 0x6f, 0x1e51
    .long 0x62, 0x21, 0x41, 0x1eb6
    .long 0x62, 0x21, 0x61, 0x1eb7
    .long 0x62, 0x2c, 0x45, 0x1e1c
    .long 0x62, 0x2c, 0x65, 0x1e1d
    .long 0x62, 0xb8, 0x45, 0x1e1c
    .long 0x62, 0xb8, 0x65, 0x1e1d
    .long 0x63, 0x22, 0x55, 0x1d9
    .long 0x63, 0x22, 0x75, 0x1da
    .long 0x70, 0x6f, 0x6f, 0x1f4a9
    .long 0x7e, 0x22, 0x3b9, 0x1fd7
    .long 0x7e, 0x22, 0x3c5, 0x1fe7
    .long 0x7e, 0x28, 0x391, 0x1f0f
    .long 0x7e, 0x28, 0x397, 0x1f2f
    .long 0x7e, 0x28, 0x399, 0x1f3f
    .long 0x7e, 0x28, 0x3a5, 0x1f5f
    .long 0x7e, 0x28, 0x3a9, 0x1f6f
    .long 0x7e, 0x28, 0x3b1, 0x1f07
    .long 0x7e, 0x28, 0x3b7, 0x1f27
    .long 0x7e, 0x28, 0x3b9, 0x1f37
    .long 0x7e, 0x28, 0x3c5, 0x1f57
    .long 0x7e, 0x28, 0x3c9, 0x1f67
    .long 0x7e, 0x29, 0x391, 0x1f0e
    .long 0x7e, 0x29, 0x397, 0x1f2e
    .long 0x7e, 0x29, 0x399, 0x1f3e
    .long 0x7e, 0x29, 0x3a9, 0x1f6e
    .long 0x7e, 0x29, 0x3b1, 0x1f06
    .long 0x7e, 0x29, 0x3b7, 0x1f26
    .long 0x7e, 0x29, 0x3b9, 0x1f36
    .long 0x7e, 0x29, 0x3c5, 0x1f56
    .long 0x7e, 0x29, 0x3c9, 0x1f66
    .long 0x7e, 0x2b, 0x4f, 0x1ee0
    .long 0x7e, 0x2b, 0x55, 0x1eee
    .long 0x7e, 0x2b, 0x6f, 0x1ee1
    .long 0x7e, 0x2b, 0x75, 0x1eef
    .long 0x7e, 0x5e, 0x41, 0x1eaa
    .long 0x7e, 0x5e, 0x45, 0x1ec4
    .long 0x7e, 0x5e, 0x4f, 0x1ed6
    .long 0x7e, 0x5e, 0x61, 0x1eab
    .long 0x7e, 0x5e, 0x65, 0x1ec5
    .long 0x7e, 0x5e, 0x6f, 0x1ed7
    .long 0x7e, 0x62, 0x41, 0x1eb4
    .long 0x7e, 0x62, 0x61, 0x1eb5
    .long 0xaf, 0x21, 0x4c, 0x1e38
    .long 0xaf, 0x21, 0x52, 0x1e5c
    .long 0xaf, 0x21, 0x6c, 0x1e39
    .long 0xaf, 0x21, 0x72, 0x1e5d
    .long 0xaf, 0x22, 0x41, 0x1de
    .long 0xaf, 0x22, 0x4f, 0x22a
    .long 0xaf, 0x22, 0x55, 0x1d5
    .long 0xaf, 0x22, 0x61, 0x1df
    .long 0xaf, 0x22, 0x6f, 0x22b
    .long 0xaf, 0x22, 0x75, 0x1d6
    .long 0xaf, 0x2e, 0x41, 0x1e0
    .long 0xaf, 0x2e, 0x4f, 0x230
    .long 0xaf, 0x2e, 0x61, 0x1e1
    .long 0xaf, 0x2e, 0x6f, 0x231
    .long 0xaf, 0x3b, 0x4f, 0x1ec
    .long 0xaf, 0x3b, 0x6f, 0x1ed
    .long 0xaf, 0x7e, 0x4f, 0x22c
    .long 0xaf, 0x7e, 0x6f, 0x22d
    .long 0xb4, 0x22, 0x49, 0x1e2e
    .long 0xb4, 0x22, 0x55, 0x1d7
    .long 0xb4, 0x22, 0x69, 0x1e2f
    .long 0xb4, 0x22, 0x75, 0x1d8
    .long 0xb4, 0x22, 0x3b9, 0x390
    .long 0xb4, 0x22, 0x3c5, 0x3b0
    .long 0xb4, 0x28, 0x391, 0x1f0d
    .long 0xb4, 0x28, 0x395, 0x1f1d
    .long 0xb4, 0x28, 0x397, 0x1f2d
    .long 0xb4, 0x28, 0x399, 0x1f3d
    .long 0xb4, 0x28, 0x39f, 0x1f4d
    .long 0xb4, 0x28, 0x3a5, 0x1f5d
    .long 0xb4, 0x28, 0x3a9, 0x1f6d
    .long 0xb4, 0x28, 0x3b1, 0x1f05
    .long 0xb4, 0x28, 0x3b5, 0x1f15
    .long 0xb4, 0x28, 0x3b7, 0x1f25
    .long 0xb4, 0x28, 0x3b9, 0x1f35
    .long 0xb4, 0x28, 0x3bf, 0x1f45
    .long 0xb4, 0x28, 0x3c5, 0x1f55
    .long 0xb4, 0x28, 0x3c9, 0x1f65
    .long 0xb4, 0x29, 0x391, 0x1f0c
    .long 0xb4, 0x29, 0x395, 0x1f1c
    .long 0xb4, 0x29, 0x397, 0x1f2c
    .long 0xb4, 0x29, 0x399, 0x1f3c
    .long 0xb4, 0x29, 0x39f, 0x1f4c
    .long 0xb4, 0x29, 0x3a9, 0x1f6c
    .long 0xb4, 0x29, 0x3b1, 0x1f04
    .long 0xb4, 0x29, 0x3b5, 0x1f14
    .long 0xb4, 0x29, 0x3b7, 0x1f24
    .long 0xb4, 0x29, 0x3b9, 0x1f34
    .long 0xb4, 0x29, 0x3bf, 0x1f44
    .long 0xb4, 0x29, 0x3c5, 0x1f54
    .long 0xb4, 0x29, 0x3c9, 0x1f64
    .long 0xb4, 0x2b, 0x4f, 0x1eda
    .long 0xb4, 0x2b, 0x55, 0x1ee8
    .long 0xb4, 0x2b, 0x6f, 0x1edb
    .long 0xb4, 0x2b, 0x75, 0x1ee9
    .long 0xb4, 0x2c, 0x43, 0x1e08
    .long 0xb4, 0x2c, 0x63, 0x1e09
    .long 0xb4, 0x2f, 0x4f, 0x1fe
    .long 0xb4, 0x2f, 0x6f, 0x1ff
    .long 0xb4, 0x5e, 0x41, 0x1ea4
    .long 0xb4, 0x5e, 0x45, 0x1ebe
    .long 0xb4, 0x5e, 0x4f, 0x1ed0
    .long 0xb4, 0x5e, 0x61, 0x1ea5
    .long 0xb4, 0x5e, 0x65, 0x1ebf
    .long 0xb4, 0x5e, 0x6f, 0x1ed1
    .long 0xb4, 0x5f, 0x45, 0x1e16
    .long 0xb4, 0x5f, 0x4f, 0x1e52
    .long 0xb4, 0x5f, 0x65, 0x1e17
    .long 0xb4, 0x5f, 0x6f, 0x1e53
    .long 0xb4, 0x62, 0x41, 0x1eae
    .long 0xb4, 0x62, 0x61, 0x1eaf
    .long 0xb4, 0x7e, 0x4f, 0x1e4c
    .long 0xb4, 0x7e, 0x55, 0x1e78
    .long 0xb4, 0x7e, 0x6f, 0x1e4d
    .long 0xb4, 0x7e, 0x75, 0x1e79
    .long 0xb4, 0xaf, 0x45, 0x1e16
    .long 0xb4, 0xaf, 0x4f, 0x1e52
    .long 0xb4, 0xaf, 0x65, 0x1e17
    .long 0xb4, 0xaf, 0x6f, 0x1e53
    .long 0xb4, 0xb8, 0x43, 0x1e08
    .long 0xb4, 0xb8, 0x63, 0x1e09
    .long 0x3b9, 0x27, 0x3b1, 0x1fb4
    .long 0x3b9, 0x27, 0x3b7, 0x1fc4
    .long 0x3b9, 0x27, 0x3c9, 0x1ff4
    .long 0x3b9, 0x27, 0x1f00, 0x1f84
    .long 0x3b9, 0x27, 0x1f01, 0x1f85
    .long 0x3b9, 0x27, 0x1f08, 0x1f8c
    .long 0x3b9, 0x27, 0x1f09, 0x1f8d
    .long 0x3b9, 0x27, 0x1f20, 0x1f94
    .long 0x3b9, 0x27, 0x1f21, 0x1f95
    .long 0x3b9, 0x27, 0x1f28, 0x1f9c
    .long 0x3b9, 0x27, 0x1f29, 0x1f9d
    .long 0x3b9, 0x27, 0x1f60, 0x1fa4
    .long 0x3b9, 0x27, 0x1f61, 0x1fa5
    .long 0x3b9, 0x27, 0x1f68, 0x1fac
    .long 0x3b9, 0x27, 0x1f69, 0x1fad
    .long 0x3b9, 0x28, 0x391, 0x1f89
    .long 0x3b9, 0x28, 0x397, 0x1f99
    .long 0x3b9, 0x28, 0x3a9, 0x1fa9
    .long 0x3b9, 0x28, 0x3b1, 0x1f81
    .long 0x3b9, 0x28, 0x3b7, 0x1f91
    .long 0x3b9, 0x28, 0x3c9, 0x1fa1
    .long 0x3b9, 0x29, 0x391, 0x1f88
    .long 0x3b9, 0x29, 0x397, 0x1f98
    .long 0x3b9, 0x29, 0x3a9, 0x1fa8
    .long 0x3b9, 0x29, 0x3b1, 0x1f80
    .long 0x3b9, 0x29, 0x3b7, 0x1f90
    .long 0x3b9, 0x29, 0x3c9, 0x1fa0
    .long 0x3b9, 0x60, 0x3b1, 0x1fb2
    .long 0x3b9, 0x60, 0x3b7, 0x1fc2
    .long 0x3b9, 0x60, 0x3c9, 0x1ff2
    .long 0x3b9, 0x60, 0x1f00, 0x1f82
    .long 0x3b9, 0x60, 0x1f01, 0x1f83
    .long 0x3b9, 0x60, 0x1f08, 0x1f8a
    .long 0x3b9, 0x60, 0x1f09, 0x1f8b
    .long 0x3b9, 0x60, 0x1f20, 0x1f92
    .long 0x3b9, 0x60, 0x1f21, 0x1f93
    .long 0x3b9, 0x60, 0x1f28, 0x1f9a
    .long 0x3b9, 0x60, 0x1f29, 0x1f9b
    .long 0x3b9, 0x60, 0x1f60, 0x1fa2
    .long 0x3b9, 0x60, 0x1f61, 0x1fa3
    .long 0x3b9, 0x60, 0x1f68, 0x1faa
    .long 0x3b9, 0x60, 0x1f69, 0x1fab
    .long 0x3b9, 0x7e, 0x3b1, 0x1fb7
    .long 0x3b9, 0x7e, 0x3b7, 0x1fc7
    .long 0x3b9, 0x7e, 0x3c9, 0x1ff7
    .long 0x3b9, 0x7e, 0x1f00, 0x1f86
    .long 0x3b9, 0x7e, 0x1f01, 0x1f87
    .long 0x3b9, 0x7e, 0x1f08, 0x1f8e
    .long 0x3b9, 0x7e, 0x1f09, 0x1f8f
    .long 0x3b9, 0x7e, 0x1f20, 0x1f96
    .long 0x3b9, 0x7e, 0x1f21, 0x1f97
    .long 0x3b9, 0x7e, 0x1f28, 0x1f9e
    .long 0x3b9, 0x7e, 0x1f29, 0x1f9f
    .long 0x3b9, 0x7e, 0x1f60, 0x1fa6
    .long 0x3b9, 0x7e, 0x1f61, 0x1fa7
    .long 0x3b9, 0x7e, 0x1f68, 0x1fae
    .long 0x3b9, 0x7e, 0x1f69, 0x1faf
    .long 0x3b9, 0xb4, 0x3b1, 0x1fb4
    .long 0x3b9, 0xb4, 0x3b7, 0x1fc4
    .long 0x3b9, 0xb4, 0x3c9, 0x1ff4
    .long 0x3b9, 0xb4, 0x1f00, 0x1f84
    .long 0x3b9, 0xb4, 0x1f01, 0x1f85
    .long 0x3b9, 0xb4, 0x1f08, 0x1f8c
    .long 0x3b9, 0xb4, 0x1f09, 0x1f8d
    .long 0x3b9, 0xb4, 0x1f20, 0x1f94
    .long 0x3b9, 0xb4, 0x1f21, 0x1f95
    .long 0x3b9, 0xb4, 0x1f28, 0x1f9c
    .long 0x3b9, 0xb4, 0x1f29, 0x1f9d
    .long 0x3b9, 0xb4, 0x1f60, 0x1fa4
    .long 0x3b9, 0xb4, 0x1f61, 0x1fa5
    .long 0x3b9, 0xb4, 0x1f68, 0x1fac
    .long 0x3b9, 0xb4, 0x1f69, 0x1fad
    .long 0x5c1, 0x5bc, 0x5e9, 0xfb2c
    .long 0x5c2, 0x5bc, 0x5e9, 0xfb2d
    .long 0, 0, 0, 0
.Ldoc_dead_marks:
    .long 0x300, 0x301, 0x302, 0x303, 0x308, 0x327
    .long 0x0, 0x304, 0x306, 0x307, 0x30a, 0x30b
    .long 0x30c, 0x328, 0x345, 0x3099, 0x309a, 0x323
    .long 0x309, 0x31b, 0x338, 0x313, 0x314, 0x30f
    .long 0x325, 0x331, 0x32d, 0x330, 0x32e, 0x324
    .long 0x311, 0x326, 0x332, 0x30d, 0x329, 0x338
.Ldoc_dead_compose_table:
    .long 0x41, 0x300, 0xc0
    .long 0x45, 0x300, 0xc8
    .long 0x49, 0x300, 0xcc
    .long 0x4f, 0x300, 0xd2
    .long 0x55, 0x300, 0xd9
    .long 0x61, 0x300, 0xe0
    .long 0x65, 0x300, 0xe8
    .long 0x69, 0x300, 0xec
    .long 0x6f, 0x300, 0xf2
    .long 0x75, 0x300, 0xf9
    .long 0x41, 0x301, 0xc1
    .long 0x45, 0x301, 0xc9
    .long 0x49, 0x301, 0xcd
    .long 0x4f, 0x301, 0xd3
    .long 0x55, 0x301, 0xda
    .long 0x59, 0x301, 0xdd
    .long 0x61, 0x301, 0xe1
    .long 0x65, 0x301, 0xe9
    .long 0x69, 0x301, 0xed
    .long 0x6f, 0x301, 0xf3
    .long 0x75, 0x301, 0xfa
    .long 0x79, 0x301, 0xfd
    .long 0x41, 0x302, 0xc2
    .long 0x45, 0x302, 0xca
    .long 0x49, 0x302, 0xce
    .long 0x4f, 0x302, 0xd4
    .long 0x55, 0x302, 0xdb
    .long 0x61, 0x302, 0xe2
    .long 0x65, 0x302, 0xea
    .long 0x69, 0x302, 0xee
    .long 0x6f, 0x302, 0xf4
    .long 0x75, 0x302, 0xfb
    .long 0x41, 0x303, 0xc3
    .long 0x4e, 0x303, 0xd1
    .long 0x4f, 0x303, 0xd5
    .long 0x61, 0x303, 0xe3
    .long 0x6e, 0x303, 0xf1
    .long 0x6f, 0x303, 0xf5
    .long 0x41, 0x308, 0xc4
    .long 0x45, 0x308, 0xcb
    .long 0x49, 0x308, 0xcf
    .long 0x4f, 0x308, 0xd6
    .long 0x55, 0x308, 0xdc
    .long 0x59, 0x308, 0x178
    .long 0x61, 0x308, 0xe4
    .long 0x65, 0x308, 0xeb
    .long 0x69, 0x308, 0xef
    .long 0x6f, 0x308, 0xf6
    .long 0x75, 0x308, 0xfc
    .long 0x79, 0x308, 0xff
    .long 0x43, 0x327, 0xc7
    .long 0x63, 0x327, 0xe7
    # Macron: common Latin Extended-A forms.
    .long 0x41, 0x304, 0x100
    .long 0x61, 0x304, 0x101
    .long 0x45, 0x304, 0x112
    .long 0x65, 0x304, 0x113
    .long 0x49, 0x304, 0x12a
    .long 0x69, 0x304, 0x12b
    .long 0x4f, 0x304, 0x14c
    .long 0x6f, 0x304, 0x14d
    .long 0x55, 0x304, 0x16a
    .long 0x75, 0x304, 0x16b
    # Breve.
    .long 0x41, 0x306, 0x102
    .long 0x61, 0x306, 0x103
    # Caron.
    .long 0x43, 0x30c, 0x10c
    .long 0x63, 0x30c, 0x10d
    .long 0x44, 0x30c, 0x10e
    .long 0x64, 0x30c, 0x10f
    .long 0x45, 0x30c, 0x11a
    .long 0x65, 0x30c, 0x11b
    .long 0x4e, 0x30c, 0x147
    .long 0x6e, 0x30c, 0x148
    .long 0x53, 0x30c, 0x160
    .long 0x73, 0x30c, 0x161
    .long 0x5a, 0x30c, 0x17d
    .long 0x7a, 0x30c, 0x17e
    # Ogonek.
    .long 0x41, 0x328, 0x104
    .long 0x61, 0x328, 0x105
    .long 0x45, 0x328, 0x118
    .long 0x65, 0x328, 0x119
    # Below-dot.
    .long 0x45, 0x323, 0x1eb8
    .long 0x65, 0x323, 0x1eb9
    .long 0, 0, 0

.section .text

.section .data
.balign 4
repeat_rate:            .long REPEAT_DEFAULT_RATE
repeat_delay_ms:        .long REPEAT_DEFAULT_DELAY_MS
active_document_name:   .ascii "Untitled"
                        .byte 0
                        .zero 24
.global doc_wrap_enabled
doc_wrap_enabled:       .long 1

.section .bss
.balign 16
.global window_width, window_height, window_surface_width, window_surface_height, window_ui_scale_120
.global window_buffer_width, window_buffer_height, window_stride, window_status_top, window_doc_bottom
.global window_buffer_raster_scale_120, window_buffer_created_raster_scale_120
.global window_raster_surface_width, window_raster_surface_height
.global window_status_bytes_x, window_status_mode_x, window_doc_visible_rows, window_doc_line_height
.global picker_ui_font_size, path_prompt_font_size, ui_transform_font_size, picker_focus, picker_mode
.global picker_name_length, picker_name_cursor, picker_name_view_start, picker_name_buffer, picker_selected
.global window_buffer_id, window_is_maximized, picker_panel_x, picker_panel_y, picker_panel_width, picker_panel_height
.global settings_panel_x, settings_panel_y, settings_panel_width, settings_panel_height, settings_ui_font_size
.global find_panel_x, find_panel_y, find_panel_width, find_panel_height, find_ui_font_size, find_replace_mode
.global find_query_length, find_query_cursor, find_replacement_length, find_replacement_cursor, find_replace_count
.global path_prompt_x, path_prompt_y, path_prompt_width, path_prompt_height
window_width:           .long 0      # virtual application-layout width
window_height:          .long 0      # virtual application-layout height
window_surface_width:   .long 0      # compositor logical surface width
window_surface_height:  .long 0      # compositor logical surface height
window_ui_scale_120:     .long 0      # initialized to 120 before first geometry calculation
window_buffer_width:    .long 0
window_buffer_height:   .long 0
window_stride:          .long 0
window_buffer_raster_scale_120: .long 120
window_buffer_created_raster_scale_120: .long 0
window_raster_surface_width: .long 0
window_raster_surface_height: .long 0
.global window_buffer_scale, window_buffer_created_scale, window_surface_mapped, surface_applied_buffer_scale
.global window_buffer_transform, window_buffer_created_transform, surface_applied_buffer_transform
window_buffer_scale:    .long 0
window_buffer_created_scale: .long 0
window_buffer_transform: .long 0
window_buffer_created_transform: .long 0
window_surface_mapped:  .long 0
surface_applied_buffer_scale: .long 0
surface_applied_buffer_transform: .long 0
window_status_top:      .long 0
window_doc_bottom:       .long 0
window_status_bytes_x:  .long 0
window_status_mode_x:   .long 0
window_doc_pixel_width: .long 0
window_doc_line_height: .long 0
window_doc_visible_rows: .long 0
picker_ui_font_size: .long 0
path_prompt_font_size: .long 0
ui_transform_font_size: .long 0
.global window_buffer_slot_ids, window_buffer_slot_busy, window_buffer_last_slot, buffer_busy
.global window_buffer_created_surface_width, window_buffer_created_surface_height
window_buffer_created_surface_width: .long 0
window_buffer_created_surface_height: .long 0
window_buffer_slot_ids: .zero 8
window_buffer_slot_busy: .zero 8
window_buffer_last_slot: .long 0
buffer_slot_new_id:     .long 0
window_buffer_id:       .long 0
window_pending_width:   .long 0
window_pending_height:  .long 0
window_resize_pending:  .long 0
window_is_maximized:    .long 0
window_startup_size_locked: .long 0
window_initial_size_applied: .long 0
failure_stage:         .quad 0
.global process_envp
process_envp:          .quad 0
runtime_dir_ptr:       .quad 0
wayland_name_ptr:      .quad 0
socket_fd:             .quad 0
shm_fd:                .quad 0
shm_mapping:           .quad 0
shm_mapping_base:      .quad 0
compositor_global:     .long 0
compositor_version:    .long 0
shm_global:            .long 0
xdg_global:            .long 0
.global clipboard_manager_global
clipboard_manager_global: .long 0
seat_global:           .long 0
seat_version:          .long 0
cursor_shape_global:   .long 0
cursor_shape_version:  .long 0
cursor_shape_manager:  .long 0
cursor_shape_device:   .long 0
.global output_global_names, output_object_ids, output_versions
.global output_scales, output_pending_scales, output_pending_valid
.global output_mode_width, output_mode_height, output_pending_mode_width, output_pending_mode_height
.global output_pending_mode_valid, output_display_width, output_display_height
.global output_surface_entered, surface_output_count, surface_output_max_scale
.global surface_effective_buffer_scale
output_global_names:      .zero 32
output_object_ids:        .zero 32
output_versions:          .zero 32
output_scales:            .zero 32
output_pending_scales:    .zero 32
output_pending_valid:     .zero 32
output_mode_width:        .zero 32
output_mode_height:       .zero 32
output_pending_mode_width: .zero 32
output_pending_mode_height: .zero 32
output_pending_mode_valid: .zero 32
output_display_width:     .long 0
output_display_height:    .long 0
output_surface_entered:   .zero 32
surface_output_count:     .long 0
surface_output_max_scale: .long 0
surface_effective_buffer_scale: .zero 4
.global surface_preferred_buffer_scale, surface_preferred_scale_seen
.global surface_preferred_buffer_transform, surface_preferred_transform_seen
surface_preferred_buffer_scale:     .long 0
surface_preferred_scale_seen:       .long 0
surface_preferred_buffer_transform: .long 0
surface_preferred_transform_seen:   .long 0
.global fractional_scale_manager_global, viewporter_global
.global fractional_scale_manager_object, viewporter_object
.global fractional_scale_object, viewport_object, fractional_scale_enabled
.global surface_preferred_fractional_scale, viewport_destination_width, viewport_destination_height
fractional_scale_manager_global: .long 0
viewporter_global: .long 0
fractional_scale_manager_object: .long 0
viewporter_object: .long 0
.global fractional_scale_object, viewport_object
fractional_scale_object: .long 0
viewport_object: .long 0
fractional_scale_enabled: .long 0
surface_preferred_fractional_scale: .long 0
viewport_destination_width: .long 0
viewport_destination_height: .long 0
.global text_input_manager_global, text_input_manager_object, text_input_object
.global text_input_entered, text_input_enabled, text_input_commit_serial
.global text_input_preedit_length, text_input_preedit_cursor_begin, text_input_preedit_cursor_end
text_input_manager_global: .long 0
text_input_manager_object: .long 0
text_input_object: .long 0
text_input_entered: .long 0
text_input_enabled: .long 0
text_input_commit_serial: .long 0
text_input_change_cause: .long 0
text_input_state_ready: .long 0
text_input_pending_flags: .long 0
text_input_pending_delete_before: .long 0
text_input_pending_delete_after: .long 0
text_input_pending_commit_length: .long 0
text_input_pending_preedit_length: .long 0
text_input_pending_preedit_cursor_begin: .long 0
text_input_pending_preedit_cursor_end: .long 0
text_input_preedit_length: .long 0
text_input_preedit_cursor_begin: .long 0
text_input_preedit_cursor_end: .long 0
.balign 8
text_input_commit_buffer: .zero 4096
text_input_pending_preedit_buffer: .zero 4096
text_input_preedit_buffer: .zero 4096
text_input_request_buffer: .zero 4112
pointer_enter_serial:  .long 0
cursor_shape_current:  .long 0
pointer_x:             .long 0
pointer_y:             .long 0
pointer_surface_x:     .long 0
pointer_surface_y:     .long 0
pointer_serial:        .long 0
pointer_inside:         .long 0
.global pointer_created, pointer_object, keyboard_created, keyboard_object
pointer_created:        .long 0
pointer_object:         .long 0
keyboard_created:       .long 0
keyboard_object:        .long 0
keyboard_focused:       .long 0
.global keyboard_serial, clipboard_serial
keyboard_serial:        .long 0
clipboard_serial:       .long 0
.global keyboard_group, keyboard_focused
keyboard_group:         .long 0
.global xkb_modifiers
xkb_modifiers:          .long 0
level3_down:            .long 0
level3_physical_down:   .long 0
level3_mod5_down:       .long 0
.global event_fd
event_fd:               .long 0       # initialized to -1 in wayland_main
.global keymap_format, keymap_size, keymap_processing_complete, keymap_mapping
keymap_format:          .long 0
keymap_size:            .long 0
keymap_processing_complete: .long 0
.balign 8
keymap_mapping:         .quad 0
next_client_object_id:  .long 0
.global keymap_event_count, keymap_event_processed_count, keymap_event_last_object, keymap_event_last_size, keymap_event_last_fd
.global keyboard_dispatch_count, keyboard_dispatch_last_opcode, keyboard_dispatch_last_size
keymap_event_count:        .long 0
keymap_event_processed_count: .long 0
keymap_event_last_object:  .long 0
keymap_event_last_size:    .long 0
keymap_event_last_fd:      .long 0
keyboard_dispatch_count:  .long 0
keyboard_dispatch_last_opcode: .long 0
keyboard_dispatch_last_size: .long 0
.global seat_capabilities, next_client_object_id
seat_capabilities:      .long 0
pointer_button_down:    .long 0
.global doc_selection_active, doc_view_top_row, doc_view_left_px
doc_selection_active:   .long 0
.global doc_selection_anchor
doc_selection_anchor:   .long 0
doc_selection_start:    .long 0
doc_selection_end:      .long 0
.global doc_word_drag_active, doc_word_drag_start, doc_word_drag_end
doc_word_drag_active:   .long 0
doc_word_drag_start:     .long 0
doc_word_drag_end:       .long 0
.global doc_pending_dead_mark
doc_pending_dead_mark: .long 0
.global doc_compose_active, doc_compose_first, doc_compose_second, doc_compose_third, doc_compose_fourth
.global doc_compose_fifth, doc_compose_sixth, doc_compose_seventh, doc_compose_eighth
doc_compose_active: .long 0
doc_compose_first:  .long 0
doc_compose_second: .long 0
doc_compose_third:  .long 0
doc_compose_fourth: .long 0
doc_compose_fifth:  .long 0
doc_compose_sixth:  .long 0
doc_compose_seventh: .long 0
doc_compose_eighth: .long 0
doc_view_top_row:       .long 0
doc_view_left_px:       .long 0
doc_hwheel_remainder:   .long 0
doc_scroll_drag:        .long 0
doc_scroll_drag_offset: .long 0
doc_scroll_thumb_top:   .long 0
doc_scroll_thumb_height: .long 0
doc_hscroll_drag:       .long 0
doc_hscroll_drag_offset: .long 0
doc_hscroll_thumb_left: .long 0
doc_hscroll_thumb_width: .long 0
doc_max_line_width:     .long 0
doc_last_click_time:    .long 0
doc_last_click_x:       .long 0
doc_last_click_y:       .long 0
doc_last_click_valid:   .long 0
doc_total_visual_rows:  .long 0
doc_wheel_remainder:    .long 0
doc_grapheme_newline_flag: .long 0
doc_line_index_base:    .quad 0
doc_line_index_bytes:   .quad 0
doc_line_index_capacity: .long 0
doc_line_count:         .long 0
.global doc_line_index_valid
doc_line_index_valid:   .long 0
doc_line_index_columns: .long 0
repeat_timer_fd:         .long 0
doc_drag_timer_fd:       .long 0
repeat_keycode:          .long 0
poll_fds:               .zero 64
repeat_timer_spec:      .zero 32
repeat_timer_read:      .quad 0
doc_drag_timer_spec:    .zero 32
doc_drag_timer_read:    .quad 0
buffer_busy:            .long 0
.global frame_callback_id, present_buffer_stage
frame_callback_id:      .long 0
present_buffer_stage:   .long 0
redraw_pending:         .long 0
shift_down:             .long 0
shift_physical_down:    .long 0
caps_lock:              .long 0
num_lock:               .long 0
ctrl_down:              .long 0
ctrl_physical_down:     .long 0
.global doc_length
doc_length:             .long 0
.global doc_cursor
doc_cursor:             .long 0
.global doc_font_size
 doc_font_size:         .long 0
.global ui_font_size
ui_font_size:           .long 0
# Logical document bytes are stored before and after [doc_gap_start, doc_gap_end).
.global doc_gap_start
doc_gap_start:          .long 0
.global doc_gap_end
doc_gap_end:            .long 0
.balign 8
.global doc_buffer
doc_buffer:             .quad 0
.global doc_capacity
doc_capacity:           .long 0
.global doc_storage_error
doc_storage_error:      .long 0
.global doc_revision
doc_revision:           .long 0
current_file_path:      .quad 0
doc_save_error:         .long 0
doc_open_error:         .long 0
file_menu_open:         .long 0
.global settings_menu_open
settings_menu_open:     .long 0
.global context_menu_open, context_menu_x, context_menu_y
context_menu_open:      .long 0
context_menu_x:         .long 0
context_menu_y:         .long 0
.global history_tab_open, history_export_mode
history_tab_open:       .long 0
history_export_mode:    .long 0
.global history_search_focus, history_search_length, history_search_cursor
.global history_search_selected, history_search_scroll, history_search_match_count
.global history_search_display_start, history_search_caret_x, history_search_query_display_buffer
history_search_focus:   .long 0
history_search_length:  .long 0
history_search_cursor:  .long 0
history_search_selected: .long 0
history_search_scroll:  .long 0
history_search_match_count: .long 0
history_search_display_start: .long 0
history_search_caret_x: .long 0
history_open_error:     .long 0
history_search_query_buffer: .zero 128
history_search_query_display_buffer: .zero 128
.global save_confirm_enabled, settings_locale_dropdown_open, settings_locale_dropdown_selected, settings_locale_dropdown_scroll
save_confirm_enabled:   .long 0
save_confirm_open:      .long 0
save_confirm_action:    .long 0
locale_manager_error:    .long 0
settings_locale_dropdown_open: .long 0
settings_locale_dropdown_selected: .long 0
settings_locale_dropdown_scroll: .long 0
path_prompt_mode:       .long 0
path_prompt_length:     .long 0
file_probe_byte:        .byte 0
.balign 8
save_target_path:       .quad 0
save_target_mode:       .long 0
save_target_mode_valid: .long 0
.balign 8
save_stat_buffer:       .zero 144
.balign 16
path_prompt_buffer:     .zero PATH_CAPACITY
current_path_buffer:    .zero PATH_CAPACITY
.global picker_mode, picker_dir_fd, picker_error, picker_entry_count, picker_selected, picker_scroll, picker_scroll_drag, pointer_x, pointer_y, pointer_inside, picker_path_cursor, picker_name_cursor, picker_name_match, picker_edit_select_all, picker_path_buffer, picker_current_path, picker_last_click_index, picker_last_click_time, picker_name_length, picker_name_buffer, picker_suggestion_count, picker_suggestion_selected, picker_suggestion_indices, doc_length, doc_buffer, doc_capacity, doc_gap_start, doc_gap_end, doc_storage_error, current_file_path, current_path_buffer, picker_target_buffer, doc_save_error, doc_view_top_row, doc_scroll_drag, doc_scroll_drag_offset, doc_scroll_thumb_top, doc_scroll_thumb_height, doc_total_visual_rows, doc_wheel_remainder, doc_line_index_base, doc_line_index_bytes, doc_line_index_capacity, doc_line_count, doc_line_index_valid, doc_line_index_columns
picker_mode:            .long 0
picker_focus:           .long 0
picker_dir_fd:          .long 0
picker_error:           .long 0
picker_entry_count:     .long 0
picker_selected:        .long 0
picker_scroll:          .long 0
picker_scroll_drag:     .long 0
picker_scroll_drag_offset: .long 0
picker_scroll_thumb_top: .long 0
picker_scroll_thumb_height: .long 0
picker_wheel_remainder: .long 0
picker_show_hidden:     .long 0
picker_truncated:       .long 0
picker_path_length:     .long 0
picker_path_cursor:     .long 0
picker_path_view_start: .long 0
picker_name_length:     .long 0
picker_name_cursor:     .long 0
picker_name_view_start: .long 0
picker_name_match:      .long 0
picker_suggestion_count: .long 0
picker_suggestion_selected: .long 0
picker_suggestion_indices: .zero (PICKER_SUGGESTION_MAX * 4)
picker_edit_select_all: .long 0
picker_last_click_index: .long 0
picker_last_click_time: .long 0
picker_overwrite_pending: .long 0
picker_panel_x:         .long 0
picker_panel_y:         .long 0
picker_panel_width:     .long 0
picker_panel_height:    .long 0
settings_panel_x:       .long 0
settings_panel_y:       .long 0
settings_panel_width:   .long 0
settings_panel_height:  .long 0
settings_ui_font_size:  .long 0
find_panel_x:           .long 0
find_panel_y:           .long 0
find_panel_width:       .long 0
find_panel_height:      .long 0
find_ui_font_size:      .long 0
find_replace_mode:      .long 0
find_replace_focus:     .long 0
find_query_length:      .long 0
find_query_cursor:      .long 0
find_replacement_length: .long 0
find_replacement_cursor: .long 0
find_field_select_all:  .long 0
find_status:            .long 0
find_replace_count:     .long 0
find_query_buffer:      .zero 128
find_replacement_buffer: .zero 128
path_prompt_x:          .long 0
path_prompt_y:          .long 0
path_prompt_width:      .long 0
path_prompt_height:     .long 0
ui_transform_active:   .long 0
ui_transform_base_x:    .long 0
ui_transform_base_y:    .long 0
ui_transform_origin_x: .long 0
ui_transform_origin_y: .long 0
ui_transform_x_num:     .long 0
ui_transform_x_den:     .long 0
ui_transform_y_num:     .long 0
ui_transform_y_den:     .long 0
picker_dirents:         .zero PICKER_DIR_BYTES
picker_stat_buffer:     .zero 144
picker_entries:         .zero (PICKER_MAX_ENTRIES * PICKER_ENTRY_SIZE)
picker_candidate:       .zero PICKER_ENTRY_SIZE
picker_current_path:    .zero PATH_CAPACITY
picker_path_buffer:     .zero PATH_CAPACITY
picker_name_buffer:     .zero 256
picker_target_buffer:   .zero PATH_CAPACITY
settings_locale_display_buffer: .zero 64
.balign 8
load_buffer:            .quad 0
load_capacity:          .long 0
temp_path_buffer:       .zero PATH_CAPACITY
temp_pid_digits:        .zero 16
.global last_object
last_object:           .long 0
.global last_opcode
last_opcode:           .long 0
.global last_size
last_size:             .long 0
event_header:          .zero 8
.global event_payload
event_payload:         .zero 4096
request_buffer:        .zero 8192
payload_buffer:        .zero 256
socket_address:        .zero 110
socket_path_len:       .long 0
.balign 8
mmap_result:           .quad 0
.balign 8
msg_iov:               .zero 16
.balign 8
msg_header:            .zero 56
.balign 8
msg_control:           .zero 24
.balign 8
recv_iov:              .zero 16
.balign 8
recv_msg_header:       .zero 56
.balign 8
recv_msg_control:      .zero 64

.section .text
.extern linux_write_all
.extern linux_read_exact
.extern linux_exit
.extern initial_file_path
.extern xkb_parse_keymap
.extern xkb_reset_keymap
.extern xkb_lookup_ascii
.extern xkb_lookup_consumed_modifiers
.extern xkb_key_repeats
.extern xkb_key_is_level_three_modifier
.extern xkb_level_three_mask
.extern xkb_num_lock_mask
.extern font_init
.extern preferences_load
.extern preferences_save
.extern compose_locale_load
.extern compose_locale_active
.extern compose_locale_lookup
.extern compose_locale_prefix
.extern compose_locale_output
.extern preferences_set_font_path
.extern preferences_locale_ptr
.extern preferences_set_locale_tag
.extern preferences_locale_is_pt_br
.extern preferences_locale_is_builtin
.extern compose_locale_install_pack
.extern compose_locale_import_xcompose
.extern compose_locale_remove_pack
.extern compose_locale_installed_tag
.extern compose_locale_get_directory
.extern compose_locale_current_tag
.extern history_open
.extern history_begin_action
.extern history_commit_action
.extern history_note_insert
.extern history_note_delete
.extern history_mark_saved
.extern history_undo_count
.extern history_redo_count
.extern history_has_error
.extern history_delete_current
.extern history_delete_selected
.extern history_export_to
.extern history_search_refresh
.extern history_search_result_count
.extern history_search_result
.extern history_search_display
.extern clipboard_service_handoff
.extern clipboard_persistence_enabled
.extern text_input_opt_in
.global wayland_main
.type wayland_main, @function
wayland_main:
    push rbp                    # keep 16-byte call-site stack alignment
    mov dword ptr [rip + event_fd], -1
    mov dword ptr [rip + window_width], WIDTH
    mov dword ptr [rip + window_height], HEIGHT
    mov dword ptr [rip + window_surface_width], WIDTH
    mov dword ptr [rip + window_surface_height], HEIGHT
    mov dword ptr [rip + window_ui_scale_120], 120
    mov dword ptr [rip + window_buffer_created_surface_width], 0
    mov dword ptr [rip + window_buffer_created_surface_height], 0
    mov dword ptr [rip + window_startup_size_locked], 0
    mov dword ptr [rip + window_initial_size_applied], 0
    mov dword ptr [rip + output_display_width], 0
    mov dword ptr [rip + output_display_height], 0
    mov dword ptr [rip + pointer_surface_x], 0
    mov dword ptr [rip + pointer_surface_y], 0
    mov dword ptr [rip + window_buffer_scale], 1
    mov dword ptr [rip + window_buffer_created_scale], 0
    mov dword ptr [rip + window_buffer_raster_scale_120], 120
    mov dword ptr [rip + window_buffer_created_raster_scale_120], 0
    mov dword ptr [rip + window_raster_surface_width], WIDTH
    mov dword ptr [rip + window_raster_surface_height], HEIGHT
    mov dword ptr [rip + window_buffer_transform], 0
    mov dword ptr [rip + window_buffer_created_transform], 0
    mov dword ptr [rip + window_surface_mapped], 0
    mov dword ptr [rip + surface_applied_buffer_scale], 1
    mov dword ptr [rip + surface_applied_buffer_transform], 0
    mov dword ptr [rip + doc_font_size], 12
    mov dword ptr [rip + ui_font_size], 10
    # Load validated persistent settings before the first layout calculation.
    call preferences_load
    # Persisted selection overrides the environment; no saved choice leaves the env fallback active.
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    mov dword ptr [rip + window_buffer_id], 12
    mov dword ptr [rip + window_buffer_slot_ids], 12
    mov dword ptr [rip + window_buffer_slot_ids + 4], 0
    mov dword ptr [rip + window_buffer_slot_busy], 0
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
    mov dword ptr [rip + window_buffer_last_slot], 1
    mov dword ptr [rip + buffer_busy], 0
    mov dword ptr [rip + window_pending_width], 0
    mov dword ptr [rip + window_pending_height], 0
    mov dword ptr [rip + window_resize_pending], 0
    mov dword ptr [rip + window_is_maximized], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov dword ptr [rip + save_confirm_enabled], 1
    mov dword ptr [rip + save_confirm_open], 0
    mov dword ptr [rip + save_confirm_action], 0
    mov dword ptr [rip + pointer_inside], 0
    mov dword ptr [rip + pointer_enter_serial], 0
    mov dword ptr [rip + surface_output_max_scale], 1
    mov dword ptr [rip + surface_effective_buffer_scale], 1
    mov dword ptr [rip + surface_preferred_buffer_scale], 1
    mov dword ptr [rip + surface_preferred_scale_seen], 0
    mov dword ptr [rip + surface_preferred_buffer_transform], 0
    mov dword ptr [rip + surface_preferred_transform_seen], 0
    mov dword ptr [rip + surface_preferred_fractional_scale], 120
    mov dword ptr [rip + fractional_scale_enabled], 0
    mov dword ptr [rip + viewport_destination_width], 0
    mov dword ptr [rip + viewport_destination_height], 0
    mov dword ptr [rip + cursor_shape_current], 0
    call window_update_geometry
    call doc_storage_init
    test rax, rax
    js .document_storage_error
    call load_initial_document
    test rax, rax
    js .initial_file_error
    # A valid installed/explicit TrueType font is optional for this phase;
    # if discovery fails, the embedded 5x7 glyph renderer remains active.
    call font_init
    # WAYLAND_SOCKET is an inherited, already-connected descriptor. It takes
    # precedence over WAYLAND_DISPLAY when supplied by a session launcher.
    lea rdi, [rip + wayland_socket_env_key]
    mov esi, 14
    call env_lookup
    test rax, rax
    jz .connect_using_display_name
    mov rsi, rax
    call parse_socket_fd
    test rax, rax
    js .connect_error
    mov qword ptr [rip + socket_fd], rax
    jmp .socket_connected

.connect_using_display_name:
    # Resolve WAYLAND_DISPLAY (default wayland-0) and XDG_RUNTIME_DIR.
    lea rdi, [rip + wayland_env_key]
    mov esi, 15
    call env_lookup
    test rax, rax
    jnz .have_wayland_name
    lea rax, [rip + default_wayland_name]
.have_wayland_name:
    mov qword ptr [rip + wayland_name_ptr], rax

    # An absolute WAYLAND_DISPLAY is self-contained and does not need XDG_RUNTIME_DIR.
    mov rsi, qword ptr [rip + wayland_name_ptr]
    cmp byte ptr [rsi], '/'
    je .absolute_socket_path

    lea rdi, [rip + xdg_runtime_env_key]
    mov esi, 15
    call env_lookup
    test rax, rax
    jz .missing_runtime_dir
    mov qword ptr [rip + runtime_dir_ptr], rax

    lea rdi, [rip + socket_address + 2]
    mov rsi, qword ptr [rip + runtime_dir_ptr]
    mov edx, 100
    call copy_cstr
    test rax, rax
    js .connect_error
    mov r12d, eax
    lea rdi, [rip + socket_address + 2]
    add rdi, r12
    mov byte ptr [rdi], '/'
    inc r12d
    inc rdi
    mov rsi, qword ptr [rip + wayland_name_ptr]
    mov edx, 108
    sub edx, r12d
    call copy_cstr
    test rax, rax
    js .connect_error
    add eax, r12d
    jmp .socket_path_ready

.absolute_socket_path:
    lea rdi, [rip + socket_address + 2]
    mov rsi, qword ptr [rip + wayland_name_ptr]
    mov edx, 108
    call copy_cstr
    test rax, rax
    js .connect_error
.socket_path_ready:
    mov dword ptr [rip + socket_path_len], eax
    mov word ptr [rip + socket_address], AF_UNIX

    # socket(AF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0)
    mov eax, SYS_socket
    mov edi, AF_UNIX
    mov esi, SOCK_STREAM | SOCK_CLOEXEC
    xor edx, edx
    syscall
    test rax, rax
    js .connect_error
    mov qword ptr [rip + socket_fd], rax

    # connect(fd, sockaddr_un, offsetof(path)+strlen(path)+1)
    mov eax, SYS_connect
    mov rdi, qword ptr [rip + socket_fd]
    lea rsi, [rip + socket_address]
    mov edx, dword ptr [rip + socket_path_len]
    add edx, 3
    syscall
    test rax, rax
    js .connect_error

.socket_connected:
    lea rax, [rip + stage_registry]
    mov qword ptr [rip + failure_stage], rax
    # wl_display.get_registry(new_id=2)
    mov dword ptr [rip + payload_buffer], 2
    mov edi, 1
    mov esi, 1                  # wl_display.get_registry opcode
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # wl_display.sync(new_id=3)
    mov dword ptr [rip + payload_buffer], 3
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Process registry.global events until callback 3 completes.
.registry_roundtrip:
    lea rax, [rip + stage_registry_read]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 2
    jne .registry_check_done
    cmp dword ptr [rip + last_opcode], 0
    jne .registry_check_done
    call registry_capture_global
.registry_check_done:
    cmp dword ptr [rip + last_object], 3
    jne .registry_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .registry_roundtrip

    # Require the three globals used by the initial window.
    cmp dword ptr [rip + compositor_global], 0
    je .missing_globals
    cmp dword ptr [rip + shm_global], 0
    je .missing_globals
    cmp dword ptr [rip + xdg_global], 0
    je .missing_globals

    lea rax, [rip + stage_bind]
    mov qword ptr [rip + failure_stage], rax
    # Bind compositor as object 4, wl_shm as 5, xdg_wm_base as 6.
    mov edi, dword ptr [rip + compositor_global]
    lea rsi, [rip + iface_compositor]
    mov edx, 14                 # strlen("wl_compositor") + NUL
    mov ecx, dword ptr [rip + compositor_version]
    mov r8d, 4
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    mov edi, dword ptr [rip + shm_global]
    lea rsi, [rip + iface_shm]
    mov edx, 7                  # strlen("wl_shm") + NUL
    mov ecx, 1
    mov r8d, 5
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    mov edi, dword ptr [rip + xdg_global]
    lea rsi, [rip + iface_xdg_wm_base]
    mov edx, 12                 # strlen("xdg_wm_base") + NUL
    mov ecx, 1
    mov r8d, 6
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_bind_roundtrip]
    mov qword ptr [rip + failure_stage], rax
    # Roundtrip callback 7 preserves dense client object IDs.
    mov dword ptr [rip + payload_buffer], 7
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error
.bind_roundtrip:
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 2
    jne .bind_check_xdg_ping
    cmp dword ptr [rip + last_opcode], 0
    je .bind_registry_global
    cmp dword ptr [rip + last_opcode], 1
    je .bind_registry_global_remove
    jmp .bind_check_done
.bind_registry_global:
    call registry_capture_global
    jmp .bind_check_done
.bind_registry_global_remove:
    call handle_output_global_remove
    test eax, eax
    js .protocol_error
    jmp .bind_check_done
.bind_check_xdg_ping:
    cmp dword ptr [rip + last_object], 6
    jne .bind_check_done
    cmp dword ptr [rip + last_opcode], 0
    jne .bind_check_done
    call handle_xdg_ping
.bind_check_done:
    cmp dword ptr [rip + last_object], 7
    jne .bind_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .bind_roundtrip

    # Reserve IDs 8..14 for the core surface, shm buffer, and optional seat
    # bootstrap. Extension proxies are allocated later from the shared ID
    # allocator, after every earlier new_id has been created.
    mov dword ptr [rip + next_client_object_id], 15

    lea rax, [rip + stage_xdg_create]
    mov qword ptr [rip + failure_stage], rax
    # wl_compositor.create_surface(new_id=8)
    mov dword ptr [rip + payload_buffer], 8
    mov edi, 4
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_wm_base.get_xdg_surface(new_id=9, surface=8)
    mov dword ptr [rip + payload_buffer], 9
    mov dword ptr [rip + payload_buffer + 4], 8
    mov edi, 6
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_surface.get_toplevel(new_id=10)
    mov dword ptr [rip + payload_buffer], 10
    mov edi, 9
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Advertise the smallest supported window geometry and the largest geometry
    # covered by the preallocated shared-memory pool. These size hints are
    # double-buffered and take effect with the initial surface commit.
    mov dword ptr [rip + payload_buffer], WINDOW_MIN_WIDTH
    mov dword ptr [rip + payload_buffer + 4], WINDOW_MIN_HEIGHT
    mov edi, 10
    mov esi, 8                  # xdg_toplevel.set_min_size
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .protocol_error

    mov dword ptr [rip + payload_buffer], MAX_WINDOW_WIDTH
    mov dword ptr [rip + payload_buffer + 4], MAX_WINDOW_HEIGHT
    mov edi, 10
    mov esi, 7                  # xdg_toplevel.set_max_size
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .protocol_error

    # xdg_toplevel.set_title("NekoEdit - development window")
    lea rsi, [rip + wayland_title]
    mov ecx, 30                 # string length including NUL
    mov dword ptr [rip + payload_buffer], 30
    lea rdi, [rip + payload_buffer + 4]
    rep movsb
    mov edi, 10
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 36
    call wl_send_request
    test rax, rax
    js .protocol_error

    # Initial empty commit requests the first xdg_surface.configure.
    mov edi, 8
    mov esi, 6
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error

.wait_configure:
    lea rax, [rip + stage_xdg_configure]
    mov qword ptr [rip + failure_stage], rax
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .configure_check_toplevel
    cmp dword ptr [rip + last_opcode], 0
    jne .configure_check_toplevel
    call handle_xdg_ping
    jmp .wait_configure
.configure_check_toplevel:
    cmp dword ptr [rip + last_object], 10
    jne .configure_check_surface
    cmp dword ptr [rip + last_opcode], 0
    jne .wait_configure
    call window_capture_toplevel_configure
    test rax, rax
    js .protocol_error
    jmp .wait_configure
.configure_check_surface:
    cmp dword ptr [rip + last_object], 8
    jne .configure_check_fractional_scale
    call handle_surface_output_event
    test eax, eax
    js .protocol_error
    jmp .wait_configure
.configure_check_fractional_scale:
    mov eax, dword ptr [rip + fractional_scale_object]
    test eax, eax
    jz .configure_check_xdg_surface
    cmp dword ptr [rip + last_object], eax
    jne .configure_check_xdg_surface
    call handle_fractional_scale_event
    test eax, eax
    js .protocol_error
    jmp .wait_configure
.configure_check_xdg_surface:
    cmp dword ptr [rip + last_object], 9
    jne .wait_configure
    cmp dword ptr [rip + last_opcode], 0
    jne .wait_configure
    # xdg_surface.configure(serial)
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 9
    mov esi, 4
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error
    call window_commit_initial_size

    lea rax, [rip + stage_memfd]
    mov qword ptr [rip + failure_stage], rax
    # Allocate a memfd-backed wl_shm buffer.
    mov eax, SYS_memfd_create
    lea rdi, [rip + memfd_label]
    mov esi, MFD_CLOEXEC
    syscall
    test rax, rax
    js .protocol_error
    mov qword ptr [rip + shm_fd], rax

    mov eax, SYS_ftruncate
    mov rdi, qword ptr [rip + shm_fd]
    mov esi, SHM_POOL_CAPACITY
    syscall
    test rax, rax
    js .protocol_error

    mov eax, SYS_mmap
    xor edi, edi
    mov esi, SHM_POOL_CAPACITY
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_SHARED
    mov r8, qword ptr [rip + shm_fd]
    xor r9d, r9d
    syscall
    test rax, rax
    js .protocol_error
    mov qword ptr [rip + mmap_result], rax
    mov qword ptr [rip + shm_mapping], rax
    mov qword ptr [rip + shm_mapping_base], rax

    # Draw the initial software-rendered palette surface.
    call render_surface

    lea rax, [rip + stage_pool]
    mov qword ptr [rip + failure_stage], rax
    # wl_shm.create_pool(new_id=11, fd, size=BUFFER_SIZE)
    mov dword ptr [rip + payload_buffer], 11
    mov dword ptr [rip + payload_buffer + 4], SHM_POOL_CAPACITY
    mov edi, 5
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    mov r8, qword ptr [rip + shm_fd]
    call wl_send_request_fd
    test rax, rax
    js .protocol_error

    lea rax, [rip + stage_buffer]
    mov qword ptr [rip + failure_stage], rax
    # wl_shm_pool.create_buffer(new_id=12, offset=0, width, height, stride, XRGB8888=1)
    mov dword ptr [rip + payload_buffer], 12
    mov dword ptr [rip + payload_buffer + 4], 0
    mov eax, dword ptr [rip + window_buffer_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_buffer_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov eax, dword ptr [rip + window_stride]
    mov dword ptr [rip + payload_buffer + 16], eax
    mov dword ptr [rip + payload_buffer + 20], 1
    mov edi, 11
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 24
    call wl_send_request
    test rax, rax
    js .protocol_error
    mov eax, dword ptr [rip + window_buffer_scale]
    mov dword ptr [rip + window_buffer_created_scale], eax
    mov eax, dword ptr [rip + window_buffer_raster_scale_120]
    mov dword ptr [rip + window_buffer_created_raster_scale_120], eax
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rip + window_buffer_created_transform], eax
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + window_buffer_created_surface_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + window_buffer_created_surface_height], eax
    mov dword ptr [rip + window_resize_pending], 0
    mov dword ptr [rip + redraw_pending], 0

    # Keep wl_shm_pool 11 alive so future configure events can allocate
    # size-specific wl_buffer objects from the same bounded mapping.

    # Bind the optional wl_seat after surface/toplevel/shm objects; the first
    # seat roundtrip uses ID 14 and pointer/keyboard continue at ID 15.
    cmp dword ptr [rip + seat_global], 0
    jne .seat_global_available
    # No seat=13 or roundtrip callback=14 exists in this session. The
    # allocator starts at 13; optional fractional proxies are appended now.
    mov dword ptr [rip + next_client_object_id], 13
    call fractional_scale_startup
    test rax, rax
    js .protocol_error
    call output_bind_pending
    test rax, rax
    js .protocol_error
    call output_initial_roundtrip
    test rax, rax
    js .protocol_error
    call window_prepare_initial_buffer_scale
    test rax, rax
    js .protocol_error
    call window_attach_initial_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.seat_global_available:
    lea rax, [rip + stage_bind_roundtrip]
    mov qword ptr [rip + failure_stage], rax
    mov edi, dword ptr [rip + seat_global]
    lea rsi, [rip + iface_seat]
    mov edx, 8
    mov ecx, dword ptr [rip + seat_version]
    mov r8d, 13
    call wl_registry_bind
    test rax, rax
    js .protocol_error

    # Output proxies have already advanced the shared monotonic allocator.
    # Roundtrip so the compositor can announce seat capabilities.
    mov dword ptr [rip + payload_buffer], 14
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .protocol_error
.seat_roundtrip:
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .seat_check_capabilities
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_capabilities
    call handle_xdg_ping
.seat_check_capabilities:
    cmp dword ptr [rip + last_object], 13
    jne .seat_check_registry_event
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_buffer_release
    call handle_seat_capabilities
    test rax, rax
    js .protocol_error
    jmp .seat_check_sync
.seat_check_registry_event:
    cmp dword ptr [rip + last_object], 2
    jne .seat_check_output_event
    cmp dword ptr [rip + last_opcode], 0
    je .seat_registry_global
    cmp dword ptr [rip + last_opcode], 1
    je .seat_registry_global_remove
    jmp .seat_check_sync
.seat_registry_global:
    call registry_capture_global
    jmp .seat_check_sync
.seat_registry_global_remove:
    call handle_output_global_remove
    test eax, eax
    js .protocol_error
    jmp .seat_check_sync
.seat_check_output_event:
    # Output proxies are already bound at this point; unknown objects fall
    # through to the remaining startup-event handlers.
    call handle_output_event
    test eax, eax
    js .protocol_error
    jnz .seat_check_sync
    call handle_surface_output_event
    test eax, eax
    js .protocol_error
    jnz .seat_check_sync
    call handle_fractional_scale_event
    test eax, eax
    js .protocol_error
    jnz .seat_check_sync

.seat_check_buffer_release:
    call window_handle_buffer_release
    test eax, eax
    jnz .seat_check_sync

.seat_check_pointer_event:
    mov eax, dword ptr [rip + pointer_object]
    test eax, eax
    jz .seat_check_keyboard_event
    cmp dword ptr [rip + last_object], eax
    jne .seat_check_keyboard_event
    cmp dword ptr [rip + last_opcode], 0
    je .seat_pointer_enter
    cmp dword ptr [rip + last_opcode], 1
    je .seat_pointer_leave
    cmp dword ptr [rip + last_opcode], 2
    je .seat_pointer_motion
    jmp .seat_check_sync

.seat_pointer_enter:
    call pointer_capture_enter
    jmp .seat_check_sync
.seat_pointer_leave:
    mov dword ptr [rip + pointer_inside], 0
    mov dword ptr [rip + cursor_shape_current], 0
    jmp .seat_check_sync
.seat_pointer_motion:
    call pointer_capture_motion

.seat_check_keyboard_event:
    # wl_keyboard.keymap can arrive before the initial seat sync callback.
    # Process it after buffer/pointer routing and before testing sync.done.
    # Unmatched events advance to sync handling and cannot cycle between
    # object checks.
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .seat_check_sync
    cmp dword ptr [rip + last_object], eax
    jne .seat_check_sync
    inc dword ptr [rip + keyboard_dispatch_count]
    mov eax, dword ptr [rip + last_opcode]
    mov dword ptr [rip + keyboard_dispatch_last_opcode], eax
    mov eax, dword ptr [rip + last_size]
    mov dword ptr [rip + keyboard_dispatch_last_size], eax
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_check_sync
    call keyboard_keymap_dispatch
    test rax, rax
    js .protocol_error
    jmp .seat_check_sync
.seat_check_sync:
    cmp dword ptr [rip + last_object], 14
    jne .seat_roundtrip
    cmp dword ptr [rip + last_opcode], 0
    jne .seat_roundtrip
    # Bind the optional cursor-shape extension only after pointer/keyboard IDs
    # have been assigned by the seat-capability event.
    call cursor_shape_setup
    test rax, rax
    js .protocol_error
    # Bind the optional text clipboard only after seat/pointer IDs are set.
    call clipboard_setup
    test rax, rax
    js .protocol_error
    call text_input_setup
    test rax, rax
    js .protocol_error
    # Input and cursor proxies now own their monotonically allocated IDs.
    # Add fractional-scale/viewport proxies and wait for the initial preferred
    # scale before sizing or attaching the first shared-memory buffer.
    call fractional_scale_startup
    test rax, rax
    js .protocol_error
    call output_bind_pending
    test rax, rax
    js .protocol_error
    call output_initial_roundtrip
    test rax, rax
    js .protocol_error
    call window_prepare_initial_buffer_scale
    test rax, rax
    js .protocol_error
    call window_attach_initial_buffer
    test rax, rax
    js .protocol_error

    # Main event loop: pointer input edits the document. The single
    # wl_buffer is only rewritten after wl_buffer.release.
.event_loop:
    lea rax, [rip + stage_event_loop]
    mov qword ptr [rip + failure_stage], rax
    cmp dword ptr [rip + repeat_timer_fd], 0
    jne .event_drag_timer_ensure
    # A monotonic timerfd lets key repetition proceed while the Wayland
    # socket is otherwise idle, without introducing a userspace runtime.
    mov eax, SYS_timerfd_create
    mov edi, CLOCK_MONOTONIC
    mov esi, TFD_CLOEXEC
    syscall
    test rax, rax
    js .protocol_error
    mov dword ptr [rip + repeat_timer_fd], eax
.event_drag_timer_ensure:
    cmp dword ptr [rip + doc_drag_timer_fd], 0
    jne .event_poll_prepare
    # Selection auto-scroll has its own timer so it can coexist with XKB key
    # repetition and continue while the pointer is stationary beyond an edge.
    mov eax, SYS_timerfd_create
    mov edi, CLOCK_MONOTONIC
    mov esi, TFD_CLOEXEC
    syscall
    test rax, rax
    js .protocol_error
    mov dword ptr [rip + doc_drag_timer_fd], eax
.event_poll_prepare:
    mov eax, dword ptr [rip + socket_fd]
    mov dword ptr [rip + poll_fds], eax
    mov word ptr [rip + poll_fds + 4], POLLIN
    mov eax, dword ptr [rip + repeat_timer_fd]
    mov dword ptr [rip + poll_fds + 8], eax
    mov word ptr [rip + poll_fds + 12], POLLIN
    mov eax, dword ptr [rip + doc_drag_timer_fd]
    mov dword ptr [rip + poll_fds + 56], eax
    mov word ptr [rip + poll_fds + 60], POLLIN
    lea rdi, [rip + poll_fds]
    call clipboard_poll_prepare
    mov eax, SYS_poll
    lea rdi, [rip + poll_fds]
    mov esi, 8
    mov edx, -1
    syscall
    cmp rax, -4                 # EINTR is a transient wake-up, not a protocol failure
    je .event_loop
    test rax, rax
    js .protocol_error
    # Drain compositor events before a simultaneous repeat timeout so key
    # releases always get a chance to cancel repetition first.
    movzx eax, word ptr [rip + poll_fds + 6]
    test eax, eax
    jnz .event_read_wayland
    movzx eax, word ptr [rip + poll_fds + 14]
    test eax, eax
    jnz .event_repeat_timer
    movzx eax, word ptr [rip + poll_fds + 62]
    test eax, eax
    jnz .event_drag_timer
    lea rdi, [rip + poll_fds]
    call clipboard_poll_dispatch
    test eax, eax
    jnz .keyboard_changed
    jmp .event_loop
.event_read_wayland:
    call wl_read_event
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + last_object], 6
    jne .check_registry_event
    cmp dword ptr [rip + last_opcode], 0
    jne .check_frame_callback
    call handle_xdg_ping
    jmp .event_loop
.check_registry_event:
    cmp dword ptr [rip + last_object], 2
    jne .check_frame_callback
    cmp dword ptr [rip + last_opcode], 0
    je .registry_event_global
    cmp dword ptr [rip + last_opcode], 1
    je .registry_event_global_remove
    jmp .event_loop
.registry_event_global:
    call registry_capture_global
    call output_bind_pending
    test rax, rax
    js .protocol_error
    jmp .event_loop
.registry_event_global_remove:
    call handle_output_global_remove
    test eax, eax
    js .protocol_error
    jmp .event_loop
.check_frame_callback:
    mov eax, dword ptr [rip + frame_callback_id]
    test eax, eax
    jz .check_buffer_release
    cmp dword ptr [rip + last_object], eax
    jne .check_buffer_release
    cmp dword ptr [rip + last_opcode], 0
    jne .protocol_error
    # Frame pacing is independent of wl_buffer storage ownership.
    mov dword ptr [rip + frame_callback_id], 0
    cmp dword ptr [rip + window_resize_pending], 0
    je .check_frame_callback_redraw
    cmp dword ptr [rip + buffer_busy], 0
    jne .event_loop
    jmp .event_apply_window_resize
.check_frame_callback_redraw:
    cmp dword ptr [rip + redraw_pending], 0
    je .event_loop
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_buffer_release:
    call window_handle_buffer_release
    test eax, eax
    jz .check_seat_event
    cmp dword ptr [rip + window_resize_pending], 0
    je .check_buffer_release_redraw
    cmp dword ptr [rip + buffer_busy], 0
    jne .event_loop
    jmp .event_apply_window_resize
.check_buffer_release_redraw:
    cmp dword ptr [rip + frame_callback_id], 0
    jne .event_loop
    cmp dword ptr [rip + redraw_pending], 0
    je .event_loop
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.event_apply_window_resize:
    call window_apply_pending_resize
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_seat_event:
    cmp dword ptr [rip + last_object], 13
    jne .check_output_event
    cmp dword ptr [rip + last_opcode], 0
    jne .check_pointer_event
    call handle_seat_capabilities
    test rax, rax
    js .protocol_error
    call cursor_shape_setup
    test rax, rax
    js .protocol_error
    call text_input_setup
    test rax, rax
    js .protocol_error
    # A seat transition can clear a preedit overlay or other transient input
    # state. Flush that redraw now when both buffer and frame gates are idle;
    # otherwise the existing release/callback path will submit it later.
    cmp dword ptr [rip + redraw_pending], 0
    je .Lseat_event_redraw_done
    cmp dword ptr [rip + buffer_busy], 0
    jne .Lseat_event_redraw_done
    cmp dword ptr [rip + frame_callback_id], 0
    jne .Lseat_event_redraw_done
    call present_buffer
    test rax, rax
    js .protocol_error
.Lseat_event_redraw_done:
    jmp .event_loop
.check_output_event:
    call handle_output_event
    test eax, eax
    js .protocol_error
    jnz .event_loop
    call handle_surface_output_event
    test eax, eax
    js .protocol_error
    jnz .event_loop
    call handle_fractional_scale_event
    test eax, eax
    js .protocol_error
    jnz .event_loop
.check_pointer_event:
    mov eax, dword ptr [rip + pointer_object]
    test eax, eax
    jz .check_keyboard_event
    cmp dword ptr [rip + last_object], eax
    jne .check_keyboard_event
    cmp dword ptr [rip + last_opcode], 0
    je .pointer_enter
    cmp dword ptr [rip + last_opcode], 1
    je .pointer_leave
    cmp dword ptr [rip + last_opcode], 2
    je .pointer_motion
    cmp dword ptr [rip + last_opcode], 3
    je .pointer_button
    cmp dword ptr [rip + last_opcode], 4
    je .pointer_axis
    jmp .event_loop
.pointer_enter:
    call pointer_capture_enter
    call window_update_cursor_shape
    test rax, rax
    js .protocol_error
    jmp .event_loop
.pointer_leave:
    mov dword ptr [rip + pointer_inside], 0
    mov dword ptr [rip + cursor_shape_current], 0
    jmp .event_loop
.pointer_motion:
    call pointer_capture_motion
    call window_update_cursor_shape
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + picker_mode], 0
    jne .pointer_picker_motion
    cmp dword ptr [rip + doc_hscroll_drag], 1
    je .pointer_document_hscroll_motion
    cmp dword ptr [rip + doc_scroll_drag], 1
    je .pointer_document_scroll_motion
    cmp dword ptr [rip + pointer_button_down], 1
    jne .event_loop
    # wl_pointer's implicit button grab continues delivering surface-local
    # motion beyond the window. Do not discard that motion at pointer_leave
    # or at the document bounds: the selection updater clamps the hit-test
    # location and scrolls the viewport as needed.
    xor edi, edi
    call doc_drag_pointer_update
    test eax, eax
    jz .event_loop
    jmp .keyboard_changed
.pointer_picker_motion:
    cmp dword ptr [rip + picker_scroll_drag], 1
    jne .event_loop
    mov esi, dword ptr [rip + pointer_y]
    sub esi, dword ptr [rip + picker_panel_y]
    imul esi, 408
    mov eax, esi
    cdq
    idiv dword ptr [rip + picker_panel_height]
    add eax, 36
    mov esi, eax
    call picker_scrollbar_drag_to_y
    jmp .keyboard_changed
.pointer_document_hscroll_motion:
    mov esi, dword ptr [rip + pointer_x]
    call doc_hscrollbar_drag_to_x
    jmp .document_scroll_redraw
.pointer_document_scroll_motion:
    mov esi, dword ptr [rip + pointer_y]
    call doc_scrollbar_drag_to_y
    jmp .document_scroll_redraw

.pointer_axis:
    cmp dword ptr [rip + last_size], 12
    jb .event_loop
    cmp dword ptr [rip + event_payload + 4], 1
    je .pointer_axis_horizontal
    cmp dword ptr [rip + event_payload + 4], 0
    jne .event_loop
    cmp dword ptr [rip + picker_mode], 0
    jne .pointer_axis_picker
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .event_loop
    cmp dword ptr [rip + shift_down], 0
    jne .pointer_axis_horizontal
    # Accumulate Wayland's signed 24.8 vertical distance in the editor.
    # One 14-pixel unit advances the document by one visual row.
    movsxd rax, dword ptr [rip + doc_wheel_remainder]
    movsxd rcx, dword ptr [rip + event_payload + 8]
    add rax, rcx
    mov ecx, DOC_SCROLL_WHEEL_ROW_FIXED
    cqo
    idiv rcx
    test eax, eax
    jz .pointer_axis_doc_store_remainder
    mov dword ptr [rip + doc_wheel_remainder], edx
    mov edi, eax
    call doc_scroll_by
    jmp .document_scroll_redraw
.pointer_axis_doc_store_remainder:
    mov dword ptr [rip + doc_wheel_remainder], edx
    jmp .event_loop

.pointer_axis_horizontal:
    cmp dword ptr [rip + picker_mode], 0
    jne .event_loop
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .event_loop
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .event_loop
    movsxd rax, dword ptr [rip + doc_hwheel_remainder]
    movsxd rcx, dword ptr [rip + event_payload + 8]
    add rax, rcx
    mov ecx, DOC_SCROLL_WHEEL_ROW_FIXED
    cqo
    idiv rcx
    test eax, eax
    jz .pointer_axis_hdoc_store_remainder
    mov dword ptr [rip + doc_hwheel_remainder], edx
    imul edi, eax, 14
    call doc_scroll_horizontal_by
    jmp .document_scroll_redraw
.pointer_axis_hdoc_store_remainder:
    mov dword ptr [rip + doc_hwheel_remainder], edx
    jmp .event_loop
.pointer_axis_picker:
    # The directory picker retains its independent row-based scroll state.
    movsxd rax, dword ptr [rip + picker_wheel_remainder]
    movsxd rcx, dword ptr [rip + event_payload + 8]
    add rax, rcx
    mov ecx, PICKER_WHEEL_ROW_FIXED
    cqo
    idiv rcx
    test eax, eax
    jz .pointer_axis_store_remainder
    mov dword ptr [rip + picker_wheel_remainder], edx
    mov edi, eax
    call picker_scroll_by
    jmp .keyboard_changed
.pointer_axis_store_remainder:
    mov dword ptr [rip + picker_wheel_remainder], edx
    jmp .event_loop

.pointer_button:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + event_payload + 8], BTN_RIGHT
    je .pointer_context_button
    cmp dword ptr [rip + event_payload + 8], BTN_LEFT
    jne .event_loop
    cmp dword ptr [rip + event_payload + 12], 1
    je .pointer_button_press
    cmp dword ptr [rip + event_payload + 12], 0
    jne .event_loop
    cmp dword ptr [rip + picker_mode], 0
    je .pointer_button_release_document
    cmp dword ptr [rip + picker_scroll_drag], 1
    jne .event_loop
    mov dword ptr [rip + picker_scroll_drag], 0
    jmp .keyboard_changed
.pointer_button_release_document:
    cmp dword ptr [rip + doc_hscroll_drag], 1
    jne .pointer_button_release_vertical_scroll
    mov dword ptr [rip + doc_hscroll_drag], 0
    jmp .document_scroll_redraw
.pointer_button_release_vertical_scroll:
    cmp dword ptr [rip + doc_scroll_drag], 1
    jne .pointer_button_release_selection
    mov dword ptr [rip + doc_scroll_drag], 0
    jmp .document_scroll_redraw
.pointer_button_release_selection:
    cmp dword ptr [rip + pointer_button_down], 1
    jne .event_loop
    mov dword ptr [rip + pointer_button_down], 0
    mov dword ptr [rip + doc_word_drag_active], 0
    call doc_drag_timer_stop
    test rax, rax
    js .protocol_error
    mov eax, dword ptr [rip + doc_selection_anchor]
    cmp eax, dword ptr [rip + doc_cursor]
    jne .Lneko_pointer_button_released
    mov dword ptr [rip + doc_selection_active], 0
.Lneko_pointer_button_released:
    jmp .event_loop
.pointer_context_button:
    # Only right-button presses open/dismiss the document context menu.
    # Dialogs, History, menus, and non-document surface areas stay unaffected.
    cmp dword ptr [rip + event_payload + 12], 1
    jne .event_loop
    cmp dword ptr [rip + context_menu_open], 1
    jne .pointer_context_button_open
    mov dword ptr [rip + context_menu_open], 0
    jmp .keyboard_changed
.pointer_context_button_open:
    cmp dword ptr [rip + pointer_inside], 1
    jne .event_loop
    cmp dword ptr [rip + save_confirm_open], 0
    jne .event_loop
    cmp dword ptr [rip + find_replace_mode], 0
    jne .event_loop
    cmp dword ptr [rip + picker_mode], 0
    jne .event_loop
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .event_loop
    cmp dword ptr [rip + history_tab_open], 0
    jne .event_loop
    cmp dword ptr [rip + file_menu_open], 0
    jne .event_loop
    cmp dword ptr [rip + settings_menu_open], 0
    jne .event_loop
    mov eax, dword ptr [rip + pointer_x]
    cmp eax, DOC_LEFT
    jb .event_loop
    mov ecx, DOC_LEFT
    add ecx, dword ptr [rip + window_doc_pixel_width]
    cmp eax, ecx
    jae .event_loop
    mov edx, dword ptr [rip + pointer_y]
    cmp edx, DOC_TOP
    jl .event_loop
    cmp edx, dword ptr [rip + window_doc_bottom]
    jae .event_loop
    mov dword ptr [rip + context_menu_open], 1
    # Keep the whole menu on-screen and inside the document viewport.
    mov ecx, dword ptr [rip + pointer_x]
    mov eax, dword ptr [rip + window_width]
    sub eax, CONTEXT_MENU_WIDTH
    cmp ecx, eax
    jbe .pointer_context_x_ready
    mov ecx, eax
.pointer_context_x_ready:
    mov dword ptr [rip + context_menu_x], ecx
    mov ecx, dword ptr [rip + pointer_y]
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, CONTEXT_MENU_HEIGHT
    cmp ecx, eax
    jbe .pointer_context_y_ready
    mov ecx, eax
.pointer_context_y_ready:
    mov dword ptr [rip + context_menu_y], ecx
    jmp .keyboard_changed

.pointer_button_press:
    cmp dword ptr [rip + pointer_inside], 1
    jne .event_loop
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + pointer_serial], eax
    mov dword ptr [rip + clipboard_serial], eax
    cmp dword ptr [rip + context_menu_open], 1
    jne .pointer_no_context_menu
    # Menu-item actions use this left-button event's serial for
    # wl_data_device.set_selection, as required by the Wayland protocol.
    mov eax, dword ptr [rip + pointer_x]
    mov ecx, dword ptr [rip + context_menu_x]
    cmp eax, ecx
    jb .pointer_context_menu_dismiss
    add ecx, CONTEXT_MENU_WIDTH
    cmp eax, ecx
    jae .pointer_context_menu_dismiss
    mov edx, dword ptr [rip + pointer_y]
    sub edx, dword ptr [rip + context_menu_y]
    js .pointer_context_menu_dismiss
    cmp edx, CONTEXT_MENU_HEIGHT
    jae .pointer_context_menu_dismiss
    mov dword ptr [rip + context_menu_open], 0
    cmp edx, CONTEXT_MENU_ROW_HEIGHT
    jb .pointer_context_menu_copy
    cmp edx, CONTEXT_MENU_ROW_HEIGHT * 2
    jb .pointer_context_menu_paste
    jmp .pointer_context_menu_cut
.pointer_context_menu_copy:
    call history_begin_action
    mov edi, 1
    call clipboard_key_command
    jmp .keyboard_changed
.pointer_context_menu_paste:
    call history_begin_action
    mov edi, 3
    call clipboard_key_command
    jmp .keyboard_changed
.pointer_context_menu_cut:
    call history_begin_action
    mov edi, 2
    call clipboard_key_command
    jmp .keyboard_changed
.pointer_context_menu_dismiss:
    mov dword ptr [rip + context_menu_open], 0
    jmp .keyboard_changed
.pointer_no_context_menu:
    cmp dword ptr [rip + save_confirm_open], 0
    jne .save_confirm_pointer
    cmp dword ptr [rip + find_replace_mode], 0
    jne .find_replace_pointer
    # The directory picker is modal; pointer input belongs to its controls.
    cmp dword ptr [rip + picker_mode], 0
    jne .picker_pointer
    # A path prompt is modal: clicking through it must never reposition the
    # document caret or insert text into the document.
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .event_loop
    mov eax, dword ptr [rip + pointer_x]
    mov edx, dword ptr [rip + pointer_y]
    cmp dword ptr [rip + file_menu_open], 1
    je .pointer_check_horizontal_scroll
    cmp dword ptr [rip + settings_menu_open], 1
    je .pointer_check_horizontal_scroll
    cmp dword ptr [rip + history_tab_open], 0
    je .pointer_check_horizontal_scroll
    cmp edx, 92
    jb .pointer_check_horizontal_scroll
    cmp edx, 168
    jb .event_loop
    cmp edx, 170
    jb .event_loop
    cmp edx, 204
    jae .pointer_history_after_search_row
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 48
    cmp eax, ecx
    jae .event_loop
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 144
    cmp eax, ecx
    jae .pointer_history_browse
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 160
    cmp eax, ecx
    jae .event_loop
    cmp eax, 48
    jb .event_loop
    jmp .pointer_history_search_focus
.pointer_history_after_search_row:
    cmp edx, 224
    jb .event_loop
    cmp edx, 246
    jb .pointer_history_result_0
    cmp edx, 249
    jb .event_loop
    cmp edx, 272
    jb .pointer_history_result_1
    cmp edx, 274
    jb .event_loop
    cmp edx, 297
    jb .pointer_history_result_2
    cmp edx, 299
    jb .event_loop
    cmp edx, 322
    jb .pointer_history_result_3
    cmp edx, 330
    jb .event_loop
    cmp edx, 358
    jb .pointer_history_open_selected
    cmp edx, 414
    jb .event_loop
    cmp edx, 444
    jae .event_loop
    cmp eax, 48
    jb .event_loop
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 120
    shr ecx, 2
    mov r8d, ecx
    lea r9d, [rcx + 8]
    sub eax, 48
    js .event_loop
    xor edx, edx
    div r9d
    cmp eax, 4
    jae .event_loop
    cmp edx, r8d
    jae .event_loop
    test eax, eax
    jz .pointer_history_undo
    cmp eax, 1
    je .pointer_history_redo
    cmp eax, 2
    je .pointer_history_export
    mov edi, dword ptr [rip + history_search_selected]
    call history_delete_selected
    jmp .keyboard_changed
.pointer_history_browse:
    call start_open_prompt
    jmp .keyboard_changed
.pointer_history_search_focus:
    mov dword ptr [rip + history_search_focus], 1
    mov eax, dword ptr [rip + history_search_length]
    mov dword ptr [rip + history_search_cursor], eax
    jmp .keyboard_changed
.pointer_history_result_0:
    xor eax, eax
    jmp .pointer_history_result_selected
.pointer_history_result_1:
    mov eax, 1
    jmp .pointer_history_result_selected
.pointer_history_result_2:
    mov eax, 2
    jmp .pointer_history_result_selected
.pointer_history_result_3:
    mov eax, 3
.pointer_history_result_selected:
    add eax, dword ptr [rip + history_search_scroll]
    mov dword ptr [rip + history_search_selected], eax
    mov edi, eax
    call history_search_result
    test rax, rax
    jz .event_loop
    mov dword ptr [rip + history_search_focus], 0
    jmp .keyboard_changed
.pointer_history_open_selected:
    cmp eax, 48
    jb .event_loop
    cmp eax, 208
    jae .event_loop
    call history_open_selected
    jmp .keyboard_changed
.pointer_history_undo:
    call history_undo
    jmp .keyboard_changed
.pointer_history_redo:
    call history_redo
    jmp .keyboard_changed
.pointer_history_export:
    mov dword ptr [rip + history_export_mode], 1
    call start_save_as_prompt
    jmp .keyboard_changed
.pointer_check_horizontal_scroll:
    # Bottom horizontal scrolling is a separate document control, not a resize edge.
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .pointer_check_vertical_scrollbar
    mov edx, dword ptr [rip + pointer_y]
    cmp edx, dword ptr [rip + window_doc_bottom]
    jb .pointer_check_vertical_scrollbar
    cmp edx, dword ptr [rip + window_status_top]
    jae .pointer_check_vertical_scrollbar
    mov eax, dword ptr [rip + pointer_x]
    cmp eax, DOC_LEFT
    jb .pointer_check_vertical_scrollbar
    mov ecx, DOC_LEFT
    add ecx, dword ptr [rip + window_doc_pixel_width]
    cmp eax, ecx
    jae .pointer_check_vertical_scrollbar
    call doc_hscrollbar_geometry
    cmp dword ptr [rip + doc_hscroll_thumb_width], 0
    je .pointer_document_hscroll_empty
    mov esi, dword ptr [rip + pointer_x]
    call doc_hscrollbar_begin_drag
    jmp .document_scroll_redraw
.pointer_document_hscroll_empty:
    jmp .event_loop
.pointer_check_vertical_scrollbar:
    # The editor scrollbar sits just inside the right-edge resize band.
    # Test its narrow gutter before edge hit-testing to avoid stealing resize.
    mov eax, dword ptr [rip + pointer_x]
    mov ecx, dword ptr [rip + window_width]
    sub ecx, DOC_SCROLL_TRACK_X_OFFSET
    cmp eax, ecx
    jb .pointer_check_window_resize
    lea ecx, [ecx + DOC_SCROLL_TRACK_WIDTH]
    cmp eax, ecx
    jae .pointer_check_window_resize
    mov edx, dword ptr [rip + pointer_y]
    cmp edx, DOC_TOP
    jb .pointer_check_window_resize
    cmp edx, dword ptr [rip + window_doc_bottom]
    jae .pointer_check_window_resize
    call doc_scrollbar_geometry
    cmp dword ptr [rip + doc_scroll_thumb_height], 0
    je .pointer_document_scroll_gutter_empty
    mov esi, dword ptr [rip + pointer_y]
    call doc_scrollbar_begin_drag
    jmp .document_scroll_redraw
.pointer_document_scroll_gutter_empty:
    jmp .event_loop
.pointer_check_window_resize:
    # Edge/corner hit-testing is shared with the hover cursor so the visual
    # affordance and the actual resize request use identical geometry.
    call window_get_resize_edges
    mov r12d, eax
    mov eax, dword ptr [rip + pointer_x]
    mov edx, dword ptr [rip + pointer_y]
    test r12d, r12d
    jnz .pointer_window_resize

    # Minimize, maximize/restore, and close controls occupy the right edge
    # of the app-drawn title bar; the File button remains on the left.
    cmp edx, 32
    jae .pointer_menu_rows
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 104
    cmp eax, ecx
    jb .pointer_header_file_menu
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 80
    cmp eax, ecx
    jb .pointer_window_minimize
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 72
    cmp eax, ecx
    jb .pointer_header_outside
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 48
    cmp eax, ecx
    jb .pointer_window_maximize
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 40
    cmp eax, ecx
    jb .pointer_header_outside
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 16
    cmp eax, ecx
    jb .pointer_window_close
    jmp .pointer_header_outside
.pointer_window_resize:
    mov dword ptr [rip + payload_buffer], 13
    mov eax, dword ptr [rip + pointer_serial]
    mov dword ptr [rip + payload_buffer + 4], eax
    mov dword ptr [rip + payload_buffer + 8], r12d
    mov edi, 10
    mov esi, 6                  # xdg_toplevel.resize(seat, serial, edges)
    lea rdx, [rip + payload_buffer]
    mov ecx, 12
    call wl_send_request
    test rax, rax
    js .protocol_error
    # The compositor owns the resize interaction and sends configure events.
    jmp .event_loop
.pointer_window_minimize:
    mov edi, 10
    mov esi, 13                 # xdg_toplevel.set_minimized
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error
    # Avoid committing stale-size content after a state request. The compositor's
    # configure sequence will schedule the next application frame.
    jmp .event_loop
.pointer_window_maximize:
    mov edi, 10
    cmp dword ptr [rip + window_is_maximized], 0
    jne .pointer_window_restore
    mov esi, 9                  # xdg_toplevel.set_maximized
    jmp .pointer_window_toggle_send
.pointer_window_restore:
    mov esi, 10                 # xdg_toplevel.unset_maximized
.pointer_window_toggle_send:
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .protocol_error
    # Wait for xdg_toplevel.configure / xdg_surface.configure before painting
    # the compositor-selected state and geometry.
    jmp .event_loop
.pointer_window_close:
    call application_exit
.save_confirm_pointer:
    mov eax, dword ptr [rip + window_width]
    sub eax, 432
    shr eax, 1
    mov ecx, eax
    mov eax, dword ptr [rip + window_height]
    sub eax, 120
    shr eax, 1
    mov edx, eax
    mov eax, dword ptr [rip + pointer_y]
    lea esi, [rdx + 78]
    cmp eax, esi
    jb .save_confirm_pointer_done
    lea esi, [rdx + 106]
    cmp eax, esi
    jae .save_confirm_pointer_done
    mov eax, dword ptr [rip + pointer_x]
    lea esi, [rcx + 64]
    cmp eax, esi
    jb .save_confirm_pointer_cancel_check
    lea esi, [rcx + 200]
    cmp eax, esi
    jb .save_confirm_pointer_accept
.save_confirm_pointer_cancel_check:
    lea esi, [rcx + 232]
    cmp eax, esi
    jb .save_confirm_pointer_done
    lea esi, [rcx + 368]
    cmp eax, esi
    jae .save_confirm_pointer_done
    call cancel_save_confirmation
    jmp .keyboard_changed
.save_confirm_pointer_accept:
    call confirm_save_action
    jmp .keyboard_changed
.save_confirm_pointer_done:
    jmp .event_loop

.pointer_header_file_menu:
    cmp eax, 104
    jb .pointer_header_outside
    cmp eax, 160
    jae .pointer_header_settings_menu
    xor dword ptr [rip + file_menu_open], 1
    mov dword ptr [rip + settings_menu_open], 0
    jmp .keyboard_changed
.pointer_header_settings_menu:
    cmp eax, 160
    jb .pointer_header_outside
    cmp eax, 240
    jae .pointer_header_outside
    xor dword ptr [rip + settings_menu_open], 1
    mov dword ptr [rip + file_menu_open], 0
    cmp dword ptr [rip + settings_menu_open], 0
    je .pointer_header_settings_closed
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    call settings_locale_refresh
    jmp .keyboard_changed
.pointer_header_settings_closed:
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    jmp .keyboard_changed
.pointer_header_outside:
    cmp dword ptr [rip + file_menu_open], 0
    jne .pointer_header_close_menu
    cmp dword ptr [rip + settings_menu_open], 0
    jne .pointer_header_close_menu
    cmp edx, 32
    jae .pointer_document_click
    jmp .pointer_window_move
.pointer_header_close_menu:
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    jmp .keyboard_changed
.pointer_window_move:
    # A drag in blank title-bar space starts an interactive toplevel move.
    mov dword ptr [rip + payload_buffer], 13
    mov eax, dword ptr [rip + pointer_serial]
    mov dword ptr [rip + payload_buffer + 4], eax
    mov edi, 10
    mov esi, 5                  # xdg_toplevel.move(seat, serial)
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .protocol_error
    jmp .event_loop
.pointer_menu_rows:
    cmp dword ptr [rip + file_menu_open], 1
    je .pointer_file_menu_rows
    cmp dword ptr [rip + settings_menu_open], 1
    je .pointer_settings_menu_rows
    cmp edx, 40
    jb .pointer_document_click
    cmp edx, 76
    jae .pointer_document_click
    cmp eax, 8
    jb .pointer_document_click
    cmp eax, 160
    jb .pointer_select_document_tab
    cmp eax, 168
    jb .pointer_document_click
    cmp eax, 320
    jae .pointer_document_click
    mov dword ptr [rip + history_tab_open], 1
    jmp .keyboard_changed
.pointer_select_document_tab:
    mov dword ptr [rip + history_tab_open], 0
    jmp .keyboard_changed
.pointer_file_menu_rows:
    cmp eax, 104
    jb .pointer_menu_outside
    cmp eax, 232
    jae .pointer_menu_outside
    cmp edx, 32
    jb .pointer_menu_outside
    cmp edx, 112
    jae .pointer_menu_outside
    mov dword ptr [rip + file_menu_open], 0
    cmp edx, 60
    jb .pointer_menu_open
    cmp edx, 84
    jb .pointer_menu_save
    jmp .pointer_menu_save_as
.pointer_settings_menu_rows:
    mov edi, eax
    mov esi, edx
    call settings_pointer_to_design
    cmp dword ptr [rip + settings_locale_dropdown_open], 1
    jne .pointer_settings_no_locale_dropdown
    cmp eax, 160
    jb .pointer_settings_no_locale_dropdown
    cmp edx, 88
    jb .pointer_settings_no_locale_dropdown
    cmp edx, 184
    jae .pointer_settings_no_locale_dropdown
    cmp eax, 304
    jae .pointer_settings_no_locale_dropdown
    mov ecx, edx
    sub ecx, 88
    shr ecx, 4
    add ecx, dword ptr [rip + settings_locale_dropdown_scroll]
    mov eax, dword ptr [rip + picker_entry_count]
    inc eax
    cmp ecx, eax
    jae .pointer_settings_locale_dropdown_blank
    mov dword ptr [rip + settings_locale_dropdown_selected], ecx
    call settings_locale_activate
    jmp .keyboard_changed
.pointer_settings_locale_dropdown_blank:
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    jmp .keyboard_changed
.pointer_settings_no_locale_dropdown:
    cmp eax, 160
    jb .pointer_menu_outside
    cmp eax, 416
    jae .pointer_menu_outside
    cmp edx, 32
    jb .pointer_menu_outside
    cmp edx, 224
    jae .pointer_menu_outside
    cmp edx, 184
    jae .pointer_settings_locale_row
    cmp edx, 160
    jae .pointer_settings_clipboard_toggle
    cmp edx, 136
    jae .pointer_settings_font_file
    cmp edx, 64
    jb .pointer_settings_confirm_toggle
    cmp edx, 88
    jb .pointer_settings_document_font
    cmp edx, 112
    jae .pointer_settings_wrap_toggle
    cmp dword ptr [rip + font_loaded], 0
    je .pointer_menu_outside
    cmp eax, 344
    jb .pointer_menu_outside
    cmp eax, 376
    jb .pointer_settings_ui_font_decrease
    cmp eax, 384
    jb .pointer_menu_outside
    cmp eax, 416
    jae .pointer_menu_outside
    jmp .pointer_settings_ui_font_increase

.pointer_settings_locale_row:
    cmp eax, 260
    jb .pointer_settings_locale_select
    cmp eax, 312
    jb .pointer_settings_locale_add
    cmp eax, 368
    jb .pointer_settings_locale_remove
    cmp eax, 416
    jb .pointer_settings_locale_import
    jmp .pointer_menu_outside

.pointer_settings_locale_select:
    xor dword ptr [rip + settings_locale_dropdown_open], 1
    cmp dword ptr [rip + settings_locale_dropdown_open], 0
    je .pointer_settings_locale_dropdown_toggled
    call settings_locale_refresh
    call settings_locale_sync_selection
.pointer_settings_locale_dropdown_toggled:
    jmp .keyboard_changed

.pointer_settings_locale_add:
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    mov dword ptr [rip + locale_manager_error], 0
    mov edi, 4
    call picker_start
    test rax, rax
    js .pointer_settings_locale_add_error
    jmp .keyboard_changed
.pointer_settings_locale_add_error:
    mov dword ptr [rip + locale_manager_error], 1
    jmp .keyboard_changed

.pointer_settings_locale_import:
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    mov dword ptr [rip + locale_manager_error], 0
    mov edi, 6
    call picker_start
    test rax, rax
    js .pointer_settings_locale_add_error
    jmp .keyboard_changed

.pointer_settings_locale_remove:
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    cmp qword ptr [rip + preferences_locale_ptr], 0
    je .pointer_settings_locale_remove_environment
    call preferences_locale_is_builtin
    test eax, eax
    jnz .pointer_settings_locale_remove_disabled
    jmp .pointer_settings_locale_remove_ready
.pointer_settings_locale_remove_environment:
    cmp dword ptr [rip + compose_locale_active], 0
    je .pointer_settings_locale_remove_disabled
.pointer_settings_locale_remove_ready:
    call request_locale_remove_confirmation
    jmp .keyboard_changed
.pointer_settings_locale_remove_disabled:
    mov dword ptr [rip + locale_manager_error], 1
    jmp .keyboard_changed

.pointer_settings_clipboard_toggle:
    xor dword ptr [rip + clipboard_persistence_enabled], 1
    call preferences_save
    jmp .keyboard_changed

.pointer_settings_font_file:
    # Font selection is available even when the embedded bitmap fallback is active.
    mov edi, 3
    call picker_start
    jmp .keyboard_changed

.pointer_settings_wrap_toggle:
    xor dword ptr [rip + doc_wrap_enabled], 1
    mov dword ptr [rip + doc_view_left_px], 0
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_line_index_valid], 0
    call window_update_geometry
    call doc_line_index_rebuild
    call doc_ensure_cursor_visible
    call preferences_save
    jmp .keyboard_changed

.pointer_settings_document_font:
    cmp dword ptr [rip + font_loaded], 0
    je .pointer_menu_outside
    cmp eax, 344
    jb .pointer_menu_outside
    cmp eax, 376
    jb .pointer_settings_font_decrease
    cmp eax, 384
    jb .pointer_menu_outside
    cmp eax, 416
    jae .pointer_menu_outside
    jmp .pointer_settings_font_increase

.pointer_settings_confirm_toggle:
    xor dword ptr [rip + save_confirm_enabled], 1
    mov dword ptr [rip + settings_menu_open], 0
    call preferences_save
    jmp .keyboard_changed

.pointer_settings_font_decrease:
    mov eax, dword ptr [rip + doc_font_size]
    cmp eax, 8
    jbe .pointer_settings_font_close
    sub eax, 2
    jmp .pointer_settings_font_apply

.pointer_settings_font_increase:
    mov eax, dword ptr [rip + doc_font_size]
    cmp eax, 32
    jae .pointer_settings_font_close
    add eax, 2

.pointer_settings_font_apply:
    mov dword ptr [rip + doc_font_size], eax
    # Recompute line pitch and visual-row weights for the new hmtx em.
    mov dword ptr [rip + doc_line_index_valid], 0
    call window_update_geometry
    call doc_line_index_rebuild
    mov dword ptr [rip + doc_view_top_row], 0
    call doc_ensure_cursor_visible
    call preferences_save

.pointer_settings_font_close:
    # Font controls are repeatable: keep the Settings dropdown visible.
    jmp .keyboard_changed

.pointer_settings_ui_font_decrease:
    mov eax, dword ptr [rip + ui_font_size]
    cmp eax, 8
    jbe .pointer_settings_font_close
    dec eax
    mov dword ptr [rip + ui_font_size], eax
    call window_update_geometry
    call doc_ensure_cursor_visible
    call preferences_save
    jmp .pointer_settings_font_close

.pointer_settings_ui_font_increase:
    mov eax, dword ptr [rip + ui_font_size]
    cmp eax, 16
    jae .pointer_settings_font_close
    inc eax
    mov dword ptr [rip + ui_font_size], eax
    call window_update_geometry
    call doc_ensure_cursor_visible
    call preferences_save
    jmp .pointer_settings_font_close

.pointer_menu_open:
    call start_open_prompt
    jmp .keyboard_changed
.pointer_menu_save:
    call save_current_document
    jmp .keyboard_changed
.pointer_menu_save_as:
    call start_save_as_prompt
    jmp .keyboard_changed
.pointer_menu_outside:
    mov dword ptr [rip + file_menu_open], 0
    cmp dword ptr [rip + settings_menu_open], 1
    jne .pointer_menu_outside_document
    # Dismissing a modal must not click through to the document or History.
    mov dword ptr [rip + settings_menu_open], 0
    jmp .keyboard_changed
.pointer_menu_outside_document:
    mov dword ptr [rip + settings_menu_open], 0
.pointer_document_click:
    cmp edx, DOC_TOP
    jl .event_loop
    mov ecx, dword ptr [rip + window_doc_bottom]
    cmp edx, ecx
    jae .event_loop
    test eax, eax
    js .event_loop
    cmp eax, dword ptr [rip + window_width]
    ja .event_loop
    # Two nearby primary presses select the complete word at the caret.
    mov ecx, dword ptr [rip + event_payload + 4]
    sub ecx, dword ptr [rip + doc_last_click_time]
    cmp dword ptr [rip + doc_last_click_valid], 1
    jne .Lpointer_document_single_click
    cmp ecx, 400
    jae .Lpointer_document_single_click
    mov ecx, dword ptr [rip + pointer_x]
    sub ecx, dword ptr [rip + doc_last_click_x]
    test ecx, ecx
    jns .Lpointer_double_click_x_ready
    neg ecx
.Lpointer_double_click_x_ready:
    cmp ecx, 5
    ja .Lpointer_document_single_click
    mov ecx, dword ptr [rip + pointer_y]
    sub ecx, dword ptr [rip + doc_last_click_y]
    test ecx, ecx
    jns .Lpointer_double_click_y_ready
    neg ecx
.Lpointer_double_click_y_ready:
    cmp ecx, 5
    ja .Lpointer_document_single_click
    mov dword ptr [rip + doc_last_click_valid], 0
    mov dword ptr [rip + doc_word_drag_active], 0
    mov dword ptr [rip + pointer_button_down], 1
    mov edi, dword ptr [rip + pointer_x]
    call doc_place_cursor_from_pointer
    call doc_select_word_at_cursor
    # Keep the mouse grab after the second press. The two word boundaries
    # form the fixed edge while the dragged edge advances in whole words.
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov dword ptr [rip + doc_word_drag_start], eax
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_word_drag_end], eax
    mov dword ptr [rip + doc_word_drag_active], 1
    call doc_drag_timer_start
    test rax, rax
    js .protocol_error
    jmp .keyboard_changed
.Lpointer_document_single_click:
    mov eax, dword ptr [rip + event_payload + 4]
    mov dword ptr [rip + doc_last_click_time], eax
    mov eax, dword ptr [rip + pointer_x]
    mov dword ptr [rip + doc_last_click_x], eax
    mov eax, dword ptr [rip + pointer_y]
    mov dword ptr [rip + doc_last_click_y], eax
    mov dword ptr [rip + doc_last_click_valid], 1
    mov dword ptr [rip + pointer_button_down], 1
    mov dword ptr [rip + doc_word_drag_active], 0
    mov edi, dword ptr [rip + pointer_x]
    call doc_place_cursor_from_pointer
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
    mov dword ptr [rip + doc_selection_active], 0
    call doc_drag_timer_start
    test rax, rax
    js .protocol_error
    jmp .keyboard_changed
.check_keyboard_event:
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .check_text_input_event
    cmp dword ptr [rip + last_object], eax
    jne .check_text_input_event
    inc dword ptr [rip + keyboard_dispatch_count]
    mov eax, dword ptr [rip + last_opcode]
    mov dword ptr [rip + keyboard_dispatch_last_opcode], eax
    mov eax, dword ptr [rip + last_size]
    mov dword ptr [rip + keyboard_dispatch_last_size], eax
    cmp dword ptr [rip + last_opcode], 0
    je .keyboard_keymap
    cmp dword ptr [rip + last_opcode], 1
    je .keyboard_enter
    cmp dword ptr [rip + last_opcode], 2
    je .keyboard_leave
    cmp dword ptr [rip + last_opcode], 3
    je .keyboard_key
    cmp dword ptr [rip + last_opcode], 4
    je .keyboard_modifiers
    cmp dword ptr [rip + last_opcode], 5
    je .keyboard_repeat_info
    jmp .event_loop
.keyboard_keymap:
    call keyboard_keymap_dispatch
    test rax, rax
    js .protocol_error
    jmp .event_loop
.event_drag_timer:
    mov edi, dword ptr [rip + doc_drag_timer_fd]
    lea rsi, [rip + doc_drag_timer_read]
    mov edx, 8
    call linux_read_exact
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + pointer_button_down], 1
    jne .event_loop
    mov edi, 1
    call doc_drag_pointer_update
    test eax, eax
    jz .event_loop
    jmp .document_scroll_redraw

.event_repeat_timer:
    mov edi, dword ptr [rip + repeat_timer_fd]
    lea rsi, [rip + repeat_timer_read]
    mov edx, 8
    call linux_read_exact
    test rax, rax
    js .protocol_error
    cmp dword ptr [rip + repeat_keycode], 0
    je .event_loop
    cmp dword ptr [rip + keyboard_focused], 1
    jne .event_repeat_cancel
    mov eax, dword ptr [rip + repeat_keycode]
    mov edx, 1
    jmp .keyboard_non_modifier
.event_repeat_cancel:
    call repeat_cancel
    jmp .event_loop

.keyboard_repeat_info:
    cmp dword ptr [rip + last_size], 8
    jb .event_loop
    # wl_keyboard.repeat_info(rate, delay). Negative values violate the
    # protocol; a zero rate disables client-side repetition.
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    js .protocol_error
    mov edx, dword ptr [rip + event_payload + 4]
    test edx, edx
    js .protocol_error
    # Defend the timerfd path against pathological rates while preserving
    # practical compositor settings (the normal desktop range is far lower).
    cmp eax, REPEAT_MAX_RATE
    jbe .Lneko_repeat_rate_capped
    mov eax, REPEAT_MAX_RATE
.Lneko_repeat_rate_capped:
    mov dword ptr [rip + repeat_rate], eax
    mov dword ptr [rip + repeat_delay_ms], edx
    test eax, eax
    jnz .Lneko_repeat_info_reconfigure
    call repeat_cancel
    jmp .event_loop
.Lneko_repeat_info_reconfigure:
    mov eax, dword ptr [rip + repeat_keycode]
    test eax, eax
    jz .event_loop
    # A changed rate/delay takes effect for the currently held key too.
    call repeat_start_if_supported
    jmp .event_loop

.keyboard_modifiers:
    cmp dword ptr [rip + last_size], 20
    jb .event_loop
    # wl_keyboard.modifiers: serial, depressed, latched, locked, group.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    test eax, 1
    setnz al
    movzx eax, al
    mov dword ptr [rip + shift_physical_down], eax
    mov dword ptr [rip + shift_down], eax
    mov eax, dword ptr [rip + event_payload + 12]
    and eax, 2
    shr eax, 1
    mov dword ptr [rip + caps_lock], eax
    mov eax, dword ptr [rip + event_payload + 12]
    and eax, 16
    shr eax, 4
    mov dword ptr [rip + num_lock], eax
    # Preserve the complete 32-bit XKB state: type maps can refer to any
    # declared virtual modifier, not only the traditional low eight bits.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    or eax, dword ptr [rip + event_payload + 12]
    mov dword ptr [rip + xkb_modifiers], eax
    mov eax, dword ptr [rip + event_payload + 16]
    mov dword ptr [rip + keyboard_group], eax
    # The standard XKB Control modifier is bit 2. Physical Ctrl key
    # transitions below are also tracked so this works before a modifier
    # update is delivered and when a compositor omits modifier events.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    and eax, 4
    setnz al
    movzx eax, al
    mov dword ptr [rip + ctrl_physical_down], eax
    mov dword ptr [rip + ctrl_down], eax

    # Keep the legacy real-Mod5 diagnostic/fallback state separately. The
    # XKB lookup path below receives the full 32-bit modifier-index mask,
    # including declared virtual modifiers from wl_keyboard.modifiers.
    mov eax, dword ptr [rip + event_payload + 4]
    or eax, dword ptr [rip + event_payload + 8]
    and eax, 128
    setnz al
    movzx eax, al
    mov dword ptr [rip + level3_mod5_down], eax
    or eax, dword ptr [rip + level3_physical_down]
    mov dword ptr [rip + level3_down], eax
    jmp .event_loop
.keyboard_enter:
    cmp dword ptr [rip + last_size], 12
    jb .event_loop
    cmp dword ptr [rip + event_payload + 4], 8
    jne .event_loop
    mov dword ptr [rip + keyboard_focused], 1
    cmp dword ptr [rip + text_input_object], 0
    je .event_loop
    jmp .keyboard_changed
.keyboard_leave:
    cmp dword ptr [rip + last_size], 8
    jb .event_loop
    mov dword ptr [rip + keyboard_focused], 0
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    mov dword ptr [rip + ctrl_down], 0
    mov dword ptr [rip + ctrl_physical_down], 0
    mov dword ptr [rip + shift_down], 0
    mov dword ptr [rip + shift_physical_down], 0
    mov dword ptr [rip + level3_down], 0
    mov dword ptr [rip + level3_physical_down], 0
    mov dword ptr [rip + level3_mod5_down], 0
    mov dword ptr [rip + xkb_modifiers], 0
    call repeat_cancel
    cmp dword ptr [rip + text_input_object], 0
    je .event_loop
    jmp .keyboard_changed
.keyboard_key:
    cmp dword ptr [rip + last_size], 16
    jb .event_loop
    cmp dword ptr [rip + keyboard_focused], 1
    jne .event_loop
    mov eax, dword ptr [rip + event_payload]     # input serial for set_selection
    mov dword ptr [rip + keyboard_serial], eax
    mov dword ptr [rip + clipboard_serial], eax
    mov eax, dword ptr [rip + event_payload + 8]  # evdev keycode
    mov edx, dword ptr [rip + event_payload + 12] # 1=pressed, 0=released
    cmp eax, 29
    je .keyboard_control
    cmp eax, 97
    je .keyboard_control
    cmp eax, 42
    je .keyboard_shift
    cmp eax, 54
    je .keyboard_shift
    cmp eax, 100                # Right Alt is LevelThree only if the map says so
    jne .keyboard_key_not_level_three
    cmp dword ptr [rip + keymap_format], 1
    jne .keyboard_level3         # retain the legacy fallback without a parsed map
    push rdx
    mov edi, eax
    call xkb_key_is_level_three_modifier
    pop rdx
    test eax, eax
    jnz .keyboard_level3
    # Otherwise dispatch the active mapping (for example Multi_key).
    mov eax, dword ptr [rip + event_payload + 8]
.keyboard_key_not_level_three:
    test edx, edx
    jz .keyboard_key_release
    cmp eax, 58
    jne .keyboard_key_check_numlock
    xor dword ptr [rip + caps_lock], 1
    xor dword ptr [rip + xkb_modifiers], 2
    jmp .keyboard_changed
.keyboard_key_check_numlock:
    cmp eax, 69
    jne .keyboard_key_pressed
    test edx, edx
    jz .keyboard_key_release
    xor dword ptr [rip + num_lock], 1
    mov ecx, dword ptr [rip + xkb_num_lock_mask]
    xor dword ptr [rip + xkb_modifiers], ecx
    jmp .keyboard_changed
.keyboard_key_pressed:
    # Shortcut processing must not reuse modifiers consumed by this key's
    # XKB type. Keep raw compositor/physical state separately; symbol lookup
    # still receives the complete modifier state. Filtering is scoped to this
    # key event, and both shortcut modifiers are restored on key-up.
    cmp dword ptr [rip + keymap_format], 1
    jne .Lkeyboard_key_modifiers_ready
    mov eax, dword ptr [rip + xkb_modifiers]
    mov ecx, eax
    and eax, 5                       # Shift | Control
    test eax, eax
    jz .Lkeyboard_key_use_physical_modifiers
    mov edi, dword ptr [rip + event_payload + 8]
    mov esi, ecx
    mov edx, dword ptr [rip + keyboard_group]
    call xkb_lookup_consumed_modifiers
    mov ecx, eax                     # consumed modifier mask

    # Control: compositor state includes depressed, latched, and locked bits.
    mov eax, dword ptr [rip + xkb_modifiers]
    test eax, 4
    jz .Lkeyboard_key_ctrl_physical
    test ecx, 4
    jnz .Lkeyboard_key_ctrl_consumed
    mov eax, 1
    jmp .Lkeyboard_key_ctrl_store
.Lkeyboard_key_ctrl_physical:
    mov eax, dword ptr [rip + ctrl_physical_down]
    jmp .Lkeyboard_key_ctrl_store
.Lkeyboard_key_ctrl_consumed:
    xor eax, eax
.Lkeyboard_key_ctrl_store:
    mov dword ptr [rip + ctrl_down], eax

    # Shift follows the same per-key consumed/preserved decision.
    mov eax, dword ptr [rip + xkb_modifiers]
    test eax, 1
    jz .Lkeyboard_key_shift_physical
    test ecx, 1
    jnz .Lkeyboard_key_shift_consumed
    mov eax, 1
    jmp .Lkeyboard_key_shift_store
.Lkeyboard_key_shift_physical:
    mov eax, dword ptr [rip + shift_physical_down]
    jmp .Lkeyboard_key_shift_store
.Lkeyboard_key_shift_consumed:
    xor eax, eax
.Lkeyboard_key_shift_store:
    mov dword ptr [rip + shift_down], eax
    jmp .Lkeyboard_key_modifiers_ready

.Lkeyboard_key_use_physical_modifiers:
    mov eax, dword ptr [rip + ctrl_physical_down]
    mov dword ptr [rip + ctrl_down], eax
    mov eax, dword ptr [rip + shift_physical_down]
    mov dword ptr [rip + shift_down], eax
.Lkeyboard_key_modifiers_ready:
    cmp dword ptr [rip + ctrl_down], 0
    jne .keyboard_key_no_repeat
    mov edi, dword ptr [rip + event_payload + 8]
    call xkb_key_repeats
    test eax, eax
    jnz .keyboard_key_repeat_allowed
    # A non-repeat key must not leave a previous key's timer active.
    call repeat_cancel
    jmp .keyboard_key_no_repeat
.keyboard_key_repeat_allowed:
    mov eax, dword ptr [rip + event_payload + 8]
    call repeat_start_if_supported
.keyboard_key_no_repeat:
    mov eax, dword ptr [rip + event_payload + 8]
    mov edx, 1
    jmp .keyboard_non_modifier
.keyboard_key_release:
    # Restore the unfiltered state after the previous key's consumed check.
    mov eax, dword ptr [rip + xkb_modifiers]
    and eax, 4
    setnz al
    movzx eax, al
    or eax, dword ptr [rip + ctrl_physical_down]
    mov dword ptr [rip + ctrl_down], eax
    mov eax, dword ptr [rip + xkb_modifiers]
    and eax, 1
    setnz al
    movzx eax, al
    or eax, dword ptr [rip + shift_physical_down]
    mov dword ptr [rip + shift_down], eax
    mov eax, dword ptr [rip + event_payload + 8]
    cmp eax, dword ptr [rip + repeat_keycode]
    jne .event_loop
    call repeat_cancel
    jmp .event_loop
.keyboard_shift:
    mov dword ptr [rip + shift_physical_down], edx
    mov dword ptr [rip + shift_down], edx
    mov eax, dword ptr [rip + xkb_modifiers]
    test edx, edx
    jz .keyboard_shift_clear_mask
    or eax, 1
    jmp .keyboard_shift_store_mask
.keyboard_shift_clear_mask:
    and eax, 0xfffffffe
.keyboard_shift_store_mask:
    mov dword ptr [rip + xkb_modifiers], eax
    jmp .event_loop
.keyboard_level3:
    mov dword ptr [rip + level3_physical_down], edx
    mov eax, dword ptr [rip + level3_mod5_down]
    or eax, edx
    mov dword ptr [rip + level3_down], eax
    mov ecx, dword ptr [rip + xkb_level_three_mask]
    mov eax, dword ptr [rip + xkb_modifiers]
    test edx, edx
    jz .keyboard_level3_clear_mask
    or eax, ecx
    jmp .keyboard_level3_store_mask
.keyboard_level3_clear_mask:
    not ecx
    and eax, ecx
.keyboard_level3_store_mask:
    mov dword ptr [rip + xkb_modifiers], eax
    jmp .event_loop
.keyboard_control:
    mov dword ptr [rip + ctrl_physical_down], edx
    mov dword ptr [rip + ctrl_down], edx
    jmp .event_loop
.keyboard_non_modifier:
    test edx, edx
    jz .event_loop
    cmp dword ptr [rip + context_menu_open], 0
    je .keyboard_context_menu_closed
    mov dword ptr [rip + context_menu_open], 0
    cmp eax, 1
    je .keyboard_changed
.keyboard_context_menu_closed:
    cmp dword ptr [rip + save_confirm_open], 0
    jne .keyboard_save_confirmation
    cmp dword ptr [rip + find_replace_mode], 0
    jne .keyboard_find_replace
    cmp dword ptr [rip + picker_mode], 0
    jne .keyboard_picker
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .keyboard_path_prompt
    cmp dword ptr [rip + history_tab_open], 0
    jne .keyboard_history_page_dispatch
    # Preserve the current key/state across the C history call. This path is
    # shared by real key events and repeat-timer events (whose event payload
    # is no longer the source of the repeated keycode).
    push rax
    push rdx
    call history_begin_action
    pop rdx
    pop rax
    jmp .keyboard_history_page_done
.keyboard_history_page_dispatch:
    cmp dword ptr [rip + history_search_focus], 0
    jne .keyboard_history_search
    cmp eax, 1
    je .keyboard_history_page_close
    cmp dword ptr [rip + ctrl_down], 0
    je .event_loop
    cmp eax, 44
    je .keyboard_history_page_undo
    cmp eax, 21
    je .keyboard_history_page_redo
    jmp .event_loop
.keyboard_history_page_undo:
    call history_undo
    jmp .keyboard_changed
.keyboard_history_page_redo:
    call history_redo
    jmp .keyboard_changed
.keyboard_history_page_close:
    mov dword ptr [rip + history_tab_open], 0
    mov dword ptr [rip + history_search_focus], 0
    jmp .keyboard_changed

.keyboard_history_search:
    cmp eax, 1
    je .keyboard_history_search_blur
    cmp eax, 28
    je .keyboard_history_search_open
    cmp eax, 14
    je .keyboard_history_search_backspace
    cmp eax, 111
    je .keyboard_history_search_delete
    cmp eax, 105
    je .keyboard_history_search_left
    cmp eax, 106
    je .keyboard_history_search_right
    cmp eax, 102
    je .keyboard_history_search_home
    cmp eax, 107
    je .keyboard_history_search_end
    cmp eax, 103
    je .keyboard_history_search_up
    cmp eax, 108
    je .keyboard_history_search_down
    cmp dword ptr [rip + ctrl_down], 0
    jne .keyboard_history_search_ctrl
    mov edi, eax
    call keycode_to_ascii
    cmp eax, 32
    jb .event_loop
    cmp eax, 126
    ja .event_loop
    mov r10d, eax
    mov ecx, dword ptr [rip + history_search_length]
    cmp ecx, 127
    jae .keyboard_changed
    mov eax, dword ptr [rip + history_search_cursor]
    lea r8, [rip + history_search_query_buffer]
    mov edx, ecx
.keyboard_history_search_shift_right:
    cmp edx, eax
    jbe .keyboard_history_search_insert
    mov r9b, byte ptr [r8 + rdx - 1]
    mov byte ptr [r8 + rdx], r9b
    dec edx
    jmp .keyboard_history_search_shift_right
.keyboard_history_search_insert:
    mov byte ptr [r8 + rax], r10b
    inc ecx
    inc eax
    mov dword ptr [rip + history_search_length], ecx
    mov dword ptr [rip + history_search_cursor], eax
    mov byte ptr [r8 + rcx], 0
    mov dword ptr [rip + history_search_selected], 0
    mov dword ptr [rip + history_search_scroll], 0
    mov dword ptr [rip + history_open_error], 0
    jmp .keyboard_changed
.keyboard_history_search_backspace:
    mov eax, dword ptr [rip + history_search_cursor]
    test eax, eax
    jz .keyboard_changed
    dec eax
    mov dword ptr [rip + history_search_cursor], eax
    mov ecx, dword ptr [rip + history_search_length]
    lea r8, [rip + history_search_query_buffer]
.keyboard_history_search_backspace_loop:
    cmp eax, ecx
    jae .keyboard_history_search_backspace_done
    mov dl, byte ptr [r8 + rax + 1]
    mov byte ptr [r8 + rax], dl
    inc eax
    jmp .keyboard_history_search_backspace_loop
.keyboard_history_search_backspace_done:
    dec ecx
    mov dword ptr [rip + history_search_length], ecx
    mov byte ptr [r8 + rcx], 0
    mov dword ptr [rip + history_search_selected], 0
    mov dword ptr [rip + history_search_scroll], 0
    jmp .keyboard_changed
.keyboard_history_search_delete:
    mov eax, dword ptr [rip + history_search_cursor]
    mov ecx, dword ptr [rip + history_search_length]
    cmp eax, ecx
    jae .keyboard_changed
    lea r8, [rip + history_search_query_buffer]
.keyboard_history_search_delete_loop:
    mov dl, byte ptr [r8 + rax + 1]
    mov byte ptr [r8 + rax], dl
    test dl, dl
    jz .keyboard_history_search_delete_done
    inc eax
    jmp .keyboard_history_search_delete_loop
.keyboard_history_search_delete_done:
    dec ecx
    mov dword ptr [rip + history_search_length], ecx
    mov dword ptr [rip + history_search_selected], 0
    mov dword ptr [rip + history_search_scroll], 0
    jmp .keyboard_changed
.keyboard_history_search_left:
    cmp dword ptr [rip + history_search_cursor], 0
    je .keyboard_changed
    dec dword ptr [rip + history_search_cursor]
    jmp .keyboard_changed
.keyboard_history_search_right:
    mov eax, dword ptr [rip + history_search_cursor]
    cmp eax, dword ptr [rip + history_search_length]
    jae .keyboard_changed
    inc dword ptr [rip + history_search_cursor]
    jmp .keyboard_changed
.keyboard_history_search_home:
    mov dword ptr [rip + history_search_cursor], 0
    jmp .keyboard_changed
.keyboard_history_search_end:
    mov eax, dword ptr [rip + history_search_length]
    mov dword ptr [rip + history_search_cursor], eax
    jmp .keyboard_changed
.keyboard_history_search_up:
    lea rdi, [rip + history_search_query_buffer]
    call history_search_refresh
    call history_search_result_count
    test eax, eax
    jz .keyboard_changed
    cmp dword ptr [rip + history_search_selected], 0
    je .keyboard_changed
    dec dword ptr [rip + history_search_selected]
    mov eax, dword ptr [rip + history_search_selected]
    cmp eax, dword ptr [rip + history_search_scroll]
    jae .keyboard_changed
    mov dword ptr [rip + history_search_scroll], eax
    jmp .keyboard_changed
.keyboard_history_search_down:
    lea rdi, [rip + history_search_query_buffer]
    call history_search_refresh
    call history_search_result_count
    test eax, eax
    jz .keyboard_changed
    mov edx, dword ptr [rip + history_search_selected]
    lea ecx, [edx + 1]
    cmp ecx, eax
    jae .keyboard_changed
    inc edx
    mov dword ptr [rip + history_search_selected], edx
    mov ecx, dword ptr [rip + history_search_scroll]
    lea ecx, [ecx + 4]
    cmp edx, ecx
    jb .keyboard_changed
    lea ecx, [edx - 3]
    mov dword ptr [rip + history_search_scroll], ecx
    jmp .keyboard_changed
.keyboard_history_search_open:
    call history_open_selected
    jmp .keyboard_changed
.keyboard_history_search_blur:
    mov dword ptr [rip + history_search_focus], 0
    jmp .keyboard_changed
.keyboard_history_search_ctrl:
    cmp eax, 30
    je .keyboard_history_search_clear
    jmp .event_loop
.keyboard_history_search_clear:
    mov dword ptr [rip + history_search_length], 0
    mov dword ptr [rip + history_search_cursor], 0
    mov dword ptr [rip + history_search_selected], 0
    mov dword ptr [rip + history_search_scroll], 0
    mov byte ptr [rip + history_search_query_buffer], 0
    mov dword ptr [rip + history_open_error], 0
    jmp .keyboard_changed

.keyboard_history_page_done:
    cmp dword ptr [rip + ctrl_down], 0
    je .keyboard_unmodified
    cmp eax, 33
    je .keyboard_find_open
    cmp eax, 35
    je .keyboard_replace_open
    cmp eax, 24
    je .keyboard_open_command
    cmp eax, 30
    je .keyboard_select_all
    cmp eax, 105
    je .keyboard_ctrl_left
    cmp eax, 106
    je .keyboard_ctrl_right
    cmp eax, 102
    je .keyboard_ctrl_home
    cmp eax, 107
    je .keyboard_ctrl_end
    cmp eax, 103
    je .keyboard_ctrl_up
    cmp eax, 108
    je .keyboard_ctrl_down
    cmp eax, 14
    je .keyboard_ctrl_backspace
    cmp eax, 111
    je .keyboard_ctrl_delete
    cmp eax, 31
    jne .keyboard_ctrl_clipboard
    cmp dword ptr [rip + shift_down], 0
    jne .keyboard_save_as_command
    cmp qword ptr [rip + current_file_path], 0
    je .keyboard_save_as_command
    jmp .keyboard_save
.keyboard_ctrl_clipboard:
    cmp eax, 46
    je .keyboard_clipboard_copy
    cmp eax, 45
    je .keyboard_clipboard_cut
    cmp eax, 47
    je .keyboard_clipboard_paste
    cmp eax, 44
    je .keyboard_history_undo_or_redo
    cmp eax, 21
    je .keyboard_history_redo
    jmp .event_loop
.keyboard_clipboard_copy:
    mov edi, 1
    call clipboard_key_command
    # Copy is not a document mutation; close the no-op history transaction.
    call history_commit_action
    jmp .event_loop
.keyboard_clipboard_cut:
    mov edi, 2
    call clipboard_key_command
    test eax, eax
    jnz .keyboard_changed
    call history_commit_action
    jmp .event_loop
.keyboard_clipboard_paste:
    mov edi, 3
    call clipboard_key_command
    test eax, eax
    jnz .keyboard_changed
    # A Wayland paste that is still awaiting data commits when insert_text()
    # receives the transfer; close the empty key-event transaction here.
    call history_commit_action
    jmp .event_loop
.keyboard_history_undo_or_redo:
    cmp dword ptr [rip + shift_down], 0
    jne .keyboard_history_redo
    call history_undo
    test eax, eax
    jnz .keyboard_changed
    jmp .event_loop
.keyboard_history_redo:
    call history_redo
    test eax, eax
    jnz .keyboard_changed
    jmp .event_loop

.keyboard_ctrl_left:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_left_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_word
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_left_plain:
    xor edi, edi
    call doc_move_word
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_ctrl_right:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_right_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_word
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_right_plain:
    mov edi, 1
    call doc_move_word
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_ctrl_up:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_up_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_line
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_up_plain:
    xor edi, edi
    call doc_move_line
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_ctrl_down:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_down_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_line
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_down_plain:
    mov edi, 1
    call doc_move_line
    call doc_clear_selection
    jmp .keyboard_changed

.keyboard_ctrl_home:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_home_plain
    call doc_begin_keyboard_selection
    mov dword ptr [rip + doc_cursor], 0
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_home_plain:
    mov dword ptr [rip + doc_cursor], 0
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_ctrl_end:
    cmp dword ptr [rip + shift_down], 0
    je .Lkeyboard_ctrl_end_plain
    call doc_begin_keyboard_selection
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_cursor], eax
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lkeyboard_ctrl_end_plain:
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_cursor], eax
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_ctrl_backspace:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lkeyboard_ctrl_backspace_delete
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_word
    call doc_finish_keyboard_selection
.Lkeyboard_ctrl_backspace_delete:
    call doc_delete_selection
    jmp .keyboard_changed
.keyboard_ctrl_delete:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lkeyboard_ctrl_delete_word
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_word
    call doc_finish_keyboard_selection
.Lkeyboard_ctrl_delete_word:
    call doc_delete_selection
    jmp .keyboard_changed

.keyboard_unmodified:
    cmp eax, 61
    je .keyboard_find_f3
    cmp eax, 1
    jne .keyboard_unmodified_dispatch
    cmp dword ptr [rip + doc_pending_dead_mark], 0
    jne .Lkeyboard_escape_cancel_dead
    cmp dword ptr [rip + doc_compose_active], 0
    je .Lkeyboard_escape_menu_handling
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call repeat_cancel
    jmp .keyboard_changed
.Lkeyboard_escape_cancel_dead:
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call repeat_cancel
    jmp .keyboard_changed
.Lkeyboard_escape_menu_handling:
    cmp dword ptr [rip + settings_locale_dropdown_open], 0
    je .Lkeyboard_escape_menu_check
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    jmp .keyboard_changed
.Lkeyboard_escape_menu_check:
    cmp dword ptr [rip + file_menu_open], 0
    jne .keyboard_close_menus
    cmp dword ptr [rip + settings_menu_open], 0
    je .event_loop
.keyboard_close_menus:
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    jmp .keyboard_changed
.keyboard_unmodified_dispatch:
    cmp dword ptr [rip + settings_locale_dropdown_open], 1
    je .keyboard_locale_dropdown_dispatch
.Lkeyboard_dispatch_navigation:
    cmp eax, 105
    je .keyboard_left
    cmp eax, 106
    je .keyboard_right
    cmp eax, 103
    je .keyboard_up
    cmp eax, 108
    je .keyboard_down
    cmp eax, 102
    je .keyboard_home
    cmp eax, 107
    je .keyboard_end
    cmp eax, 14
    je .keyboard_backspace
    cmp eax, 111
    je .keyboard_delete
    cmp eax, 28
    je .keyboard_enter_key
    cmp eax, 15
    je .keyboard_tab
    cmp dword ptr [rip + text_input_enabled], 1
    je .event_loop
    mov edi, eax
    call keycode_to_unicode
    test eax, eax
    jz .event_loop
    mov edi, eax
    call doc_insert_keyboard_codepoint
    jmp .keyboard_changed
.keyboard_locale_dropdown_dispatch:
    cmp eax, 103
    je .keyboard_locale_dropdown_up
    cmp eax, 108
    je .keyboard_locale_dropdown_down
    cmp eax, 28
    je .keyboard_locale_dropdown_enter
    jmp .event_loop
.keyboard_locale_dropdown_up:
    mov eax, dword ptr [rip + settings_locale_dropdown_selected]
    test eax, eax
    jz .event_loop
    dec eax
    mov dword ptr [rip + settings_locale_dropdown_selected], eax
    call settings_locale_dropdown_adjust
    jmp .keyboard_changed
.keyboard_locale_dropdown_down:
    mov eax, dword ptr [rip + settings_locale_dropdown_selected]
    mov ecx, dword ptr [rip + picker_entry_count]
    cmp eax, ecx
    jae .event_loop
    inc eax
    mov dword ptr [rip + settings_locale_dropdown_selected], eax
    call settings_locale_dropdown_adjust
    jmp .keyboard_changed
.keyboard_locale_dropdown_enter:
    call settings_locale_activate
    jmp .keyboard_changed

.keyboard_open_command:
    call start_open_prompt
    jmp .keyboard_changed
.keyboard_save_as_command:
    call start_save_as_prompt
    jmp .keyboard_changed
.keyboard_save:
    xor edi, edi
    call request_save_confirmation
    jmp .keyboard_changed
.keyboard_save_confirmation:
    cmp eax, 1
    je .keyboard_save_confirmation_cancel
    cmp eax, 28
    je .keyboard_save_confirmation_accept
    mov edi, eax
    call keycode_to_ascii
    cmp al, 'y'
    je .keyboard_save_confirmation_accept
    cmp al, 'Y'
    je .keyboard_save_confirmation_accept
    cmp al, 'n'
    je .keyboard_save_confirmation_cancel
    cmp al, 'N'
    je .keyboard_save_confirmation_cancel
    jmp .event_loop
.keyboard_save_confirmation_accept:
    call confirm_save_action
    jmp .keyboard_changed
.keyboard_save_confirmation_cancel:
    call cancel_save_confirmation
    jmp .keyboard_changed

# The path editor owns all non-modifier keys while its prompt is visible.
.find_replace_pointer:
    mov edi, dword ptr [rip + pointer_x]
    mov esi, dword ptr [rip + pointer_y]
    call find_replace_handle_pointer
    jmp .keyboard_changed

.picker_pointer:
    mov edi, dword ptr [rip + pointer_x]
    mov esi, dword ptr [rip + pointer_y]
    mov edx, dword ptr [rip + event_payload + 4]
    call picker_handle_pointer
    jmp .keyboard_changed

.keyboard_picker:
    mov edi, eax
    call picker_handle_key
    jmp .keyboard_changed

.keyboard_path_prompt:
    cmp dword ptr [rip + ctrl_down], 0
    jne .event_loop
    cmp eax, 1
    je .keyboard_path_escape
    cmp eax, 28
    je .keyboard_path_enter
    cmp eax, 14
    je .keyboard_path_backspace
    mov edi, eax
    call keycode_to_ascii
    test eax, eax
    jz .event_loop
    mov ecx, dword ptr [rip + path_prompt_length]
    cmp ecx, PATH_CAPACITY - 1
    jae .event_loop
    lea rdx, [rip + path_prompt_buffer]
    mov byte ptr [rdx + rcx], al
    inc ecx
    mov dword ptr [rip + path_prompt_length], ecx
    mov byte ptr [rdx + rcx], 0
    jmp .keyboard_changed
.keyboard_path_backspace:
    mov ecx, dword ptr [rip + path_prompt_length]
    test ecx, ecx
    jz .event_loop
    dec ecx
    mov dword ptr [rip + path_prompt_length], ecx
    lea rdx, [rip + path_prompt_buffer]
    mov byte ptr [rdx + rcx], 0
    jmp .keyboard_changed
.keyboard_path_escape:
    call repeat_cancel
    call cancel_path_prompt
    jmp .keyboard_changed
.keyboard_path_enter:
    call repeat_cancel
    call confirm_path_prompt
    jmp .keyboard_changed

.keyboard_find_open:
    mov edi, 1
    call find_replace_open
    jmp .keyboard_changed
.keyboard_replace_open:
    mov edi, 2
    call find_replace_open
    jmp .keyboard_changed
.keyboard_find_f3:
    cmp dword ptr [rip + shift_down], 0
    jne .keyboard_find_f3_previous
    call doc_find_next
    jmp .keyboard_changed
.keyboard_find_f3_previous:
    call doc_find_previous
    jmp .keyboard_changed

.keyboard_find_replace:
    cmp eax, 1
    je .keyboard_find_close
    cmp eax, 15
    je .keyboard_find_tab
    cmp eax, 28
    je .keyboard_find_enter
    cmp eax, 61
    je .keyboard_find_f3
    cmp eax, 105
    je .keyboard_find_left
    cmp eax, 106
    je .keyboard_find_right
    cmp eax, 102
    je .keyboard_find_home
    cmp eax, 107
    je .keyboard_find_end
    cmp eax, 14
    je .keyboard_find_backspace
    cmp eax, 111
    je .keyboard_find_delete
    cmp dword ptr [rip + ctrl_down], 0
    jne .keyboard_find_ctrl
    mov edi, eax
    call keycode_to_ascii
    cmp eax, 32
    jb .event_loop
    cmp eax, 126
    ja .event_loop
    mov edi, eax
    call find_input_insert_byte
    jmp .keyboard_changed
.keyboard_find_ctrl:
    cmp eax, 30
    je .keyboard_find_select_all
    jmp .event_loop
.keyboard_find_select_all:
    mov dword ptr [rip + find_field_select_all], 1
    cmp dword ptr [rip + find_replace_focus], 0
    jne .keyboard_find_select_replacement
    mov eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + find_query_cursor], eax
    jmp .keyboard_changed
.keyboard_find_select_replacement:
    mov eax, dword ptr [rip + find_replacement_length]
    mov dword ptr [rip + find_replacement_cursor], eax
    jmp .keyboard_changed
.keyboard_find_tab:
    cmp dword ptr [rip + find_replace_mode], 2
    jne .event_loop
    xor dword ptr [rip + find_replace_focus], 1
    mov dword ptr [rip + find_field_select_all], 0
    jmp .keyboard_changed
.keyboard_find_enter:
    cmp dword ptr [rip + find_replace_mode], 2
    jne .keyboard_find_enter_next
    cmp dword ptr [rip + ctrl_down], 0
    jne .keyboard_find_enter_replace
.keyboard_find_enter_next:
    call doc_find_next
    jmp .keyboard_changed
.keyboard_find_enter_replace:
    call doc_find_replace_current
    jmp .keyboard_changed
.keyboard_find_left:
    mov dword ptr [rip + find_field_select_all], 0
    cmp dword ptr [rip + find_replace_focus], 0
    jne .keyboard_find_left_replacement
    cmp dword ptr [rip + find_query_cursor], 0
    je .keyboard_changed
    dec dword ptr [rip + find_query_cursor]
    jmp .keyboard_changed
.keyboard_find_left_replacement:
    cmp dword ptr [rip + find_replacement_cursor], 0
    je .keyboard_changed
    dec dword ptr [rip + find_replacement_cursor]
    jmp .keyboard_changed
.keyboard_find_right:
    mov dword ptr [rip + find_field_select_all], 0
    cmp dword ptr [rip + find_replace_focus], 0
    jne .keyboard_find_right_replacement
    mov eax, dword ptr [rip + find_query_cursor]
    cmp eax, dword ptr [rip + find_query_length]
    jae .keyboard_changed
    inc dword ptr [rip + find_query_cursor]
    jmp .keyboard_changed
.keyboard_find_right_replacement:
    mov eax, dword ptr [rip + find_replacement_cursor]
    cmp eax, dword ptr [rip + find_replacement_length]
    jae .keyboard_changed
    inc dword ptr [rip + find_replacement_cursor]
    jmp .keyboard_changed
.keyboard_find_home:
    mov dword ptr [rip + find_field_select_all], 0
    cmp dword ptr [rip + find_replace_focus], 0
    jne .keyboard_find_home_replacement
    mov dword ptr [rip + find_query_cursor], 0
    jmp .keyboard_changed
.keyboard_find_home_replacement:
    mov dword ptr [rip + find_replacement_cursor], 0
    jmp .keyboard_changed
.keyboard_find_end:
    mov dword ptr [rip + find_field_select_all], 0
    cmp dword ptr [rip + find_replace_focus], 0
    jne .keyboard_find_end_replacement
    mov eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + find_query_cursor], eax
    jmp .keyboard_changed
.keyboard_find_end_replacement:
    mov eax, dword ptr [rip + find_replacement_length]
    mov dword ptr [rip + find_replacement_cursor], eax
    jmp .keyboard_changed
.keyboard_find_backspace:
    mov edi, 1
    call find_input_delete
    jmp .keyboard_changed
.keyboard_find_delete:
    xor edi, edi
    call find_input_delete
    jmp .keyboard_changed
.keyboard_find_close:
    call find_replace_close
    jmp .keyboard_changed

.keyboard_select_all:
    # Ctrl+A selects the full document using the same anchor/cursor model
    # as Shift+navigation and pointer dragging.
    mov dword ptr [rip + doc_selection_anchor], 0
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_cursor], eax
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_left:
    cmp dword ptr [rip + shift_down], 0
    jne .Lneko_keyboard_left_extend
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_keyboard_left_plain
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_keyboard_left_collapse
    mov eax, edx
.Lneko_keyboard_left_collapse:
    mov dword ptr [rip + doc_cursor], eax
    call doc_clear_selection
    jmp .keyboard_changed
.Lneko_keyboard_left_plain:
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    mov edi, dword ptr [rip + doc_cursor]
    call doc_grapheme_prev
    mov dword ptr [rip + doc_cursor], eax
    jmp .keyboard_changed
.Lneko_keyboard_left_extend:
    call doc_begin_keyboard_selection
    cmp dword ptr [rip + doc_cursor], 0
    je .Lneko_keyboard_left_extend_finish
    mov edi, dword ptr [rip + doc_cursor]
    call doc_grapheme_prev
    mov dword ptr [rip + doc_cursor], eax
.Lneko_keyboard_left_extend_finish:
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_right:
    cmp dword ptr [rip + shift_down], 0
    jne .Lneko_keyboard_right_extend
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_keyboard_right_plain
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jae .Lneko_keyboard_right_collapse
    mov eax, edx
.Lneko_keyboard_right_collapse:
    mov dword ptr [rip + doc_cursor], eax
    call doc_clear_selection
    jmp .keyboard_changed
.Lneko_keyboard_right_plain:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    mov edi, eax
    call doc_grapheme_next
    mov dword ptr [rip + doc_cursor], eax
    jmp .keyboard_changed
.Lneko_keyboard_right_extend:
    call doc_begin_keyboard_selection
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .Lneko_keyboard_right_extend_finish
    mov edi, eax
    call doc_grapheme_next
    mov dword ptr [rip + doc_cursor], eax
.Lneko_keyboard_right_extend_finish:
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.keyboard_up:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_up_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_vertical
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_up_plain:
    xor edi, edi
    call doc_move_vertical
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_down:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_down_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_vertical
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_down_plain:
    mov edi, 1
    call doc_move_vertical
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_home:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_home_plain
    call doc_begin_keyboard_selection
    xor edi, edi
    call doc_move_line_edge
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_home_plain:
    xor edi, edi
    call doc_move_line_edge
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_end:
    cmp dword ptr [rip + shift_down], 0
    je .Lneko_keyboard_end_plain
    call doc_begin_keyboard_selection
    mov edi, 1
    call doc_move_line_edge
    call doc_finish_keyboard_selection
    jmp .keyboard_changed
.Lneko_keyboard_end_plain:
    mov edi, 1
    call doc_move_line_edge
    call doc_clear_selection
    jmp .keyboard_changed
.keyboard_backspace:
    cmp dword ptr [rip + doc_pending_dead_mark], 0
    jne .Lkeyboard_backspace_cancel_dead
    cmp dword ptr [rip + doc_compose_active], 0
    je .Lkeyboard_backspace_document
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call repeat_cancel
    jmp .keyboard_changed
.Lkeyboard_backspace_cancel_dead:
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call repeat_cancel
    jmp .keyboard_changed
.Lkeyboard_backspace_document:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_keyboard_backspace_selection
    cmp dword ptr [rip + doc_cursor], 0
    je .event_loop
    mov edi, dword ptr [rip + doc_cursor]
    call doc_grapheme_prev
    mov dword ptr [rip + doc_cursor], eax
    call doc_delete_at_cursor
    jmp .keyboard_changed
.Lneko_keyboard_backspace_selection:
    call doc_delete_selection
    jmp .keyboard_changed
.keyboard_delete:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_keyboard_delete_selection
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_length]
    jae .event_loop
    call doc_delete_at_cursor
    jmp .keyboard_changed
.Lneko_keyboard_delete_selection:
    call doc_delete_selection
    jmp .keyboard_changed
.keyboard_enter_key:
    call doc_delete_selection
    mov edi, 10
    call doc_insert_byte
    jmp .keyboard_changed
.keyboard_tab:
    call doc_delete_selection
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
    mov edi, 32
    call doc_insert_byte
.keyboard_changed:
    mov dword ptr [rip + text_input_change_cause], 1
    jmp .Lkeyboard_changed_common
.keyboard_changed_ime:
    mov dword ptr [rip + text_input_change_cause], 0
.Lkeyboard_changed_common:
    call history_commit_action
    call doc_ensure_cursor_visible
    cmp dword ptr [rip + text_input_object], 0
    je .Lkeyboard_changed_without_ime
    call text_input_update_state
    test rax, rax
    js .protocol_error
.Lkeyboard_changed_without_ime:
    mov dword ptr [rip + redraw_pending], 1
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop
.document_scroll_redraw:
    # Manual viewport motion must not call doc_ensure_cursor_visible: the
    # caret may remain outside the viewport until the next keyboard navigation.
    cmp dword ptr [rip + text_input_object], 0
    je .Ldocument_scroll_without_ime
    call text_input_update_state
    test rax, rax
    js .protocol_error
.Ldocument_scroll_without_ime:
    mov dword ptr [rip + redraw_pending], 1
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop

.check_text_input_event:
    mov eax, dword ptr [rip + text_input_object]
    test eax, eax
    jz .check_clipboard_event
    cmp dword ptr [rip + last_object], eax
    jne .check_clipboard_event
    mov edi, dword ptr [rip + last_opcode]
    call text_input_handle_event
    cmp eax, 2
    je .keyboard_changed_ime
    cmp eax, 1
    je .text_input_redraw_only
    jmp .event_loop
.text_input_redraw_only:
    mov dword ptr [rip + redraw_pending], 1
    call present_buffer
    test rax, rax
    js .protocol_error
    jmp .event_loop

.check_clipboard_event:
    mov edi, dword ptr [rip + last_object]
    mov esi, dword ptr [rip + last_opcode]
    lea rdx, [rip + event_payload]
    mov ecx, dword ptr [rip + last_size]
    mov r8d, dword ptr [rip + event_fd]
    call clipboard_handle_event
    test eax, eax
    jnz .event_loop
.check_toplevel_close:
    cmp dword ptr [rip + last_object], 10
    jne .check_xdg_surface_configure
    cmp dword ptr [rip + last_opcode], 0
    jne .check_toplevel_close_event
    call window_capture_toplevel_configure
    test rax, rax
    js .protocol_error
    jmp .event_loop
.check_toplevel_close_event:
    cmp dword ptr [rip + last_opcode], 1
    jne .event_loop
    call application_exit
.check_xdg_surface_configure:
    cmp dword ptr [rip + last_object], 9
    jne .event_loop
    cmp dword ptr [rip + last_opcode], 0
    jne .event_loop
    call window_handle_surface_configure
    test rax, rax
    js .protocol_error
    jmp .event_loop

.document_storage_error:
    mov edi, 2
    lea rsi, [rip + msg_document_storage]
    mov edx, msg_document_storage_end - msg_document_storage
    call linux_write_all
    mov edi, 1
    jmp linux_exit

.initial_file_error:
    mov edi, 2
    lea rsi, [rip + msg_file_error]
    mov edx, msg_file_error_end - msg_file_error
    call linux_write_all
    mov edi, 1
    jmp linux_exit

.missing_runtime_dir:
    mov edi, 2
    lea rsi, [rip + msg_no_env]
    mov edx, msg_no_env_end - msg_no_env
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.connect_error:
    mov edi, 2
    lea rsi, [rip + msg_connect]
    mov edx, msg_connect_end - msg_connect
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.missing_globals:
    mov edi, 2
    lea rsi, [rip + msg_globals]
    mov edx, msg_globals_end - msg_globals
    call linux_write_all
    mov edi, 1
    jmp linux_exit
.protocol_error:
    mov edi, 2
    lea rsi, [rip + msg_protocol]
    mov edx, msg_protocol_end - msg_protocol
    call linux_write_all
    mov rsi, qword ptr [rip + failure_stage]
    test rsi, rsi
    jz .protocol_check_display_error
    call write_stderr_cstr
.protocol_check_display_error:
    # wl_display.error payload: object_id, code, then a length-prefixed
    # Wayland string. Validate both the declared event size and NUL terminator.
    cmp dword ptr [rip + last_object], 1
    jne .protocol_exit
    cmp dword ptr [rip + last_opcode], 0
    jne .protocol_exit
    mov ecx, dword ptr [rip + last_size]
    cmp ecx, 12
    jb .protocol_exit
    mov eax, dword ptr [rip + event_payload + 8]
    cmp eax, 1
    jb .protocol_exit
    cmp eax, 4000
    ja .protocol_exit
    # The declared string may be shorter than the remaining padded payload.
    # Clamp output to bytes actually received; never read beyond last_size.
    dec eax
    mov edx, ecx
    sub edx, 12
    cmp eax, edx
    cmova eax, edx
    mov r12d, eax
    mov edi, 2
    lea rsi, [rip + msg_protocol_error_prefix]
    mov edx, msg_protocol_error_prefix_end - msg_protocol_error_prefix
    call linux_write_all
    test r12d, r12d
    jz .protocol_error_message_newline
    mov edi, 2
    lea rsi, [rip + event_payload + 12]
    mov edx, r12d
    call linux_write_all
.protocol_error_message_newline:
    mov edi, 2
    lea rsi, [rip + newline_text]
    mov edx, 1
    call linux_write_all
.protocol_exit:
    mov edi, 1
    jmp linux_exit
.size wayland_main, . - wayland_main

# Allocate separate growable mappings for the live document and transactional
# Open staging area. Both start small and grow geometrically with mremap.
.type doc_storage_init, @function
doc_storage_init:
    push rbx
    mov eax, SYS_mmap
    xor edi, edi
    mov esi, DOC_INITIAL_CAPACITY
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9d, r9d
    syscall
    test rax, rax
    js .doc_storage_init_failed
    mov qword ptr [rip + doc_buffer], rax
    mov dword ptr [rip + doc_capacity], DOC_INITIAL_CAPACITY
    mov dword ptr [rip + doc_gap_start], 0
    mov dword ptr [rip + doc_gap_end], DOC_INITIAL_CAPACITY

    mov eax, SYS_mmap
    xor edi, edi
    mov esi, DOC_INITIAL_CAPACITY
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9d, r9d
    syscall
    test rax, rax
    js .doc_storage_init_unmap_document
    mov qword ptr [rip + load_buffer], rax
    mov dword ptr [rip + load_capacity], DOC_INITIAL_CAPACITY
    xor eax, eax
    pop rbx
    ret
.doc_storage_init_unmap_document:
    mov rdi, qword ptr [rip + doc_buffer]
    mov esi, DOC_INITIAL_CAPACITY
    mov eax, SYS_munmap
    syscall
    mov qword ptr [rip + doc_buffer], 0
    mov dword ptr [rip + doc_capacity], 0
.doc_storage_init_failed:
    mov rax, -12
    pop rbx
    ret
.size doc_storage_init, . - doc_storage_init

# Grow the live gap buffer geometrically. Existing suffix bytes are relocated
# to the end of the enlarged mapping; logical byte offsets remain unchanged.
# RAX=0 on success, negative errno on failure.
.global doc_buffer_grow
.type doc_buffer_grow, @function
doc_buffer_grow:
    push rbx
    push r12
    push r13
    push r14
    mov r12, qword ptr [rip + doc_buffer]
    mov r13d, dword ptr [rip + doc_capacity]
    test r12, r12
    jz .doc_buffer_grow_failed
    cmp r13d, DOC_MAX_CAPACITY
    jae .doc_buffer_grow_failed
    mov r14d, r13d
    shl r14d, 1
    cmp r14d, DOC_MAX_CAPACITY
    jbe .doc_buffer_grow_size_ready
    mov r14d, DOC_MAX_CAPACITY
.doc_buffer_grow_size_ready:
    mov rdi, r12
    mov esi, r13d
    mov edx, r14d
    mov r10d, MREMAP_MAYMOVE
    mov eax, SYS_mremap
    syscall
    test rax, rax
    js .doc_buffer_grow_return
    mov r12, rax
    mov qword ptr [rip + doc_buffer], rax
    mov dword ptr [rip + doc_capacity], r14d

    # The old suffix occupied [gap_end, old_capacity). Move it backwards
    # into the high end of the new mapping, opening all new bytes as one gap.
    mov ebx, dword ptr [rip + doc_length]
    sub ebx, dword ptr [rip + doc_gap_start]
    mov r13d, r14d
    sub r13d, ebx
    test ebx, ebx
    jz .doc_buffer_grow_store_gap
    mov rsi, r12
    mov eax, dword ptr [rip + doc_gap_end]
    add rsi, rax
    add rsi, rbx
    dec rsi
    mov rdi, r12
    mov eax, r13d
    add rdi, rax
    add rdi, rbx
    dec rdi
    mov ecx, ebx
    std
    rep movsb
    cld
.doc_buffer_grow_store_gap:
    mov dword ptr [rip + doc_gap_end], r13d
    xor eax, eax
.doc_buffer_grow_return:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.doc_buffer_grow_failed:
    mov rax, -12
    jmp .doc_buffer_grow_return
.size doc_buffer_grow, . - doc_buffer_grow

# EDI=minimum required live-document capacity. Preserve the current logical
# document and grow until the requested size is available.
.type doc_buffer_reserve, @function
doc_buffer_reserve:
    push rbx
    mov ebx, edi
    cmp ebx, DOC_MAX_CAPACITY
    ja .doc_buffer_reserve_failed
.doc_buffer_reserve_loop:
    cmp ebx, dword ptr [rip + doc_capacity]
    jbe .doc_buffer_reserve_success
    call doc_buffer_grow
    test rax, rax
    js .doc_buffer_reserve_return
    jmp .doc_buffer_reserve_loop
.doc_buffer_reserve_success:
    xor eax, eax
.doc_buffer_reserve_return:
    pop rbx
    ret
.doc_buffer_reserve_failed:
    mov rax, -12
    jmp .doc_buffer_reserve_return
.size doc_buffer_reserve, . - doc_buffer_reserve

# Grow the independent Open staging mapping. Unlike the live document this is
# a contiguous byte stream, so mremap needs no gap/suffix relocation.
.type load_buffer_grow, @function
load_buffer_grow:
    push r12
    push r13
    push r14
    mov r12, qword ptr [rip + load_buffer]
    mov r13d, dword ptr [rip + load_capacity]
    test r12, r12
    jz .load_buffer_grow_failed
    cmp r13d, DOC_MAX_CAPACITY
    jae .load_buffer_grow_failed
    mov r14d, r13d
    shl r14d, 1
    cmp r14d, DOC_MAX_CAPACITY
    jbe .load_buffer_grow_size_ready
    mov r14d, DOC_MAX_CAPACITY
.load_buffer_grow_size_ready:
    mov rdi, r12
    mov esi, r13d
    mov edx, r14d
    mov r10d, MREMAP_MAYMOVE
    mov eax, SYS_mremap
    syscall
    test rax, rax
    js .load_buffer_grow_return
    mov qword ptr [rip + load_buffer], rax
    mov dword ptr [rip + load_capacity], r14d
    xor eax, eax
    jmp .load_buffer_grow_return
.load_buffer_grow_failed:
    mov rax, -12
.load_buffer_grow_return:
    pop r14
    pop r13
    pop r12
    ret
.size load_buffer_grow, . - load_buffer_grow

# Load an optional initial file. A nonexistent path is a new, empty document.
# The live document mapping grows geometrically if the file fills its capacity.
.type load_initial_document, @function
load_initial_document:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, qword ptr [rip + initial_file_path]
    mov dword ptr [rip + doc_length], 0
    mov dword ptr [rip + doc_line_index_valid], 0
    mov dword ptr [rip + doc_line_count], 0
    mov dword ptr [rip + doc_gap_start], 0
    mov eax, dword ptr [rip + doc_capacity]
    mov dword ptr [rip + doc_gap_end], eax
    test r12, r12
    jz .load_file_empty
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name

    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    xor edx, edx
    xor r10d, r10d
    syscall
    cmp rax, -2                  # ENOENT: retain path for a later Ctrl+S
    je .load_file_empty
    test rax, rax
    js .load_file_error
    mov r14d, eax
    xor r13d, r13d
.load_file_read:
    mov eax, dword ptr [rip + doc_capacity]
    cmp r13d, eax
    jae .load_file_probe
    mov eax, SYS_read
    mov edi, r14d
    mov rsi, qword ptr [rip + doc_buffer]
    add rsi, r13
    mov edx, dword ptr [rip + doc_capacity]
    sub edx, r13d
    syscall
    test rax, rax
    jg .load_file_advance
    je .load_file_done
    cmp rax, -4                  # EINTR
    je .load_file_read
    jmp .load_file_close_error
.load_file_advance:
    add r13, rax
    mov dword ptr [rip + doc_length], r13d
    mov dword ptr [rip + doc_line_index_valid], 0
    mov dword ptr [rip + doc_line_count], 0
    mov dword ptr [rip + doc_gap_start], r13d
    mov eax, dword ptr [rip + doc_capacity]
    mov dword ptr [rip + doc_gap_end], eax
    jmp .load_file_read
.load_file_probe:
    # Read one byte beyond capacity. EOF preserves an exactly-full mapping;
    # data triggers growth and is appended before the next bulk read.
    mov eax, SYS_read
    mov edi, r14d
    lea rsi, [rip + file_probe_byte]
    mov edx, 1
    syscall
    test rax, rax
    jg .load_file_grow_for_probe
    je .load_file_done
    cmp rax, -4
    je .load_file_probe
    jmp .load_file_close_error
.load_file_grow_for_probe:
    call doc_buffer_grow
    test rax, rax
    js .load_file_close_error
    mov rdx, qword ptr [rip + doc_buffer]
    mov al, byte ptr [rip + file_probe_byte]
    mov byte ptr [rdx + r13], al
    inc r13
    mov dword ptr [rip + doc_length], r13d
    mov dword ptr [rip + doc_gap_start], r13d
    mov eax, dword ptr [rip + doc_capacity]
    mov dword ptr [rip + doc_gap_end], eax
    jmp .load_file_read
.load_file_done:
    mov edi, r14d
    mov eax, SYS_close
    syscall
    test rax, rax
    js .load_file_error
    mov dword ptr [rip + doc_length], r13d
    jmp .load_file_reset
.load_file_close_error:
    mov edi, r14d
    mov eax, SYS_close
    syscall
.load_file_error:
    mov rax, -5
    jmp .load_file_return
.load_file_empty:
    mov dword ptr [rip + doc_length], 0
.load_file_reset:
    mov eax, dword ptr [rip + doc_length]
    mov dword ptr [rip + doc_gap_start], eax
    mov edx, dword ptr [rip + doc_capacity]
    mov dword ptr [rip + doc_gap_end], edx
    mov dword ptr [rip + doc_cursor], 0
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_selection_active], 0
    mov dword ptr [rip + doc_selection_anchor], 0
    mov dword ptr [rip + doc_selection_start], 0
    mov dword ptr [rip + doc_selection_end], 0
    mov dword ptr [rip + doc_save_error], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_storage_error], 0
    mov rdi, qword ptr [rip + current_file_path]
    call history_open
    mov dword ptr [rip + history_tab_open], 0
    xor eax, eax
.load_file_return:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size load_initial_document, . - load_initial_document

# Copy the basename into the tab label without retaining or rewriting argv.

.type picker_start, @function
picker_start:
    push rbx
    push r12
    sub rsp, 8
    mov dword ptr [rip + picker_mode], edi
    mov dword ptr [rip + picker_dir_fd], -1
    mov dword ptr [rip + picker_selected], -1
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_focus], 0
    mov dword ptr [rip + picker_error], 0
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_name_length], 0
    mov dword ptr [rip + picker_name_cursor], 0
    mov dword ptr [rip + picker_name_match], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    mov byte ptr [rip + picker_name_buffer], 0
    # Each new dialog starts with dotfiles hidden; the user's toggle applies
    # only to the current browsing session.
    mov dword ptr [rip + picker_show_hidden], 0
    mov dword ptr [rip + picker_scroll_drag], 0
    mov dword ptr [rip + picker_wheel_remainder], 0
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0

    # Begin in the process working directory and keep an absolute display path.
    mov eax, SYS_getcwd
    lea rdi, [rip + picker_current_path]
    mov esi, PATH_CAPACITY
    syscall
    test rax, rax
    js .picker_start_path_failed
    mov r12d, eax
    lea rdi, [rip + picker_path_buffer]
    lea rsi, [rip + picker_current_path]
    mov ecx, r12d
    rep movsb
    dec r12d
    mov dword ptr [rip + picker_path_length], r12d
    mov dword ptr [rip + picker_path_cursor], r12d
    mov dword ptr [rip + picker_path_view_start], 0
    jmp .picker_start_open_directory

.picker_start_path_failed:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    lea rdi, [rip + picker_path_buffer]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1
    mov dword ptr [rip + picker_path_cursor], 1
    mov dword ptr [rip + picker_path_view_start], 0

.picker_start_open_directory:
    cmp dword ptr [rip + picker_mode], 5
    jne .picker_start_open_path
    lea rdi, [rip + picker_current_path]
    mov esi, PATH_CAPACITY
    call compose_locale_get_directory
    test eax, eax
    jz .picker_start_failed
    mov r12d, eax
    lea rdi, [rip + picker_path_buffer]
    lea rsi, [rip + picker_current_path]
    mov ecx, r12d
    rep movsb
    mov byte ptr [rdi], 0
    mov dword ptr [rip + picker_path_length], r12d
    mov dword ptr [rip + picker_path_cursor], r12d
    mov dword ptr [rip + picker_path_view_start], 0
.picker_start_open_path:
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    lea rsi, [rip + picker_current_path]
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_start_failed
    mov ebx, dword ptr [rip + picker_dir_fd]
    mov dword ptr [rip + picker_dir_fd], eax
    cmp ebx, 0
    jl .picker_start_scan
    mov eax, SYS_close
    mov edi, ebx
    syscall
.picker_start_scan:
    call picker_scan_directory
    test rax, rax
    js .picker_start_failed
    xor eax, eax
    jmp .picker_start_done
.picker_start_failed:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_start_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_start, . - picker_start

.type picker_scan_directory, @function
picker_scan_directory:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov dword ptr [rip + picker_entry_count], 0
    mov dword ptr [rip + picker_selected], -1
    mov dword ptr [rip + picker_scroll], 0
    # A rebuilt listing invalidates the previous row identity and click timing.
    # Without this, a click on row 0 after navigation can be mistaken for the
    # second half of a double-click from the directory we just left.
    mov dword ptr [rip + picker_last_click_index], -1
    mov dword ptr [rip + picker_last_click_time], 0
    mov dword ptr [rip + picker_truncated], 0
    mov dword ptr [rip + picker_error], 0
    # An Open-mode search is scoped to the directory that produced its listing.
    # A previous query must not become a literal target after navigation or a
    # Show-hidden rescan, especially when that name exists in the new directory.
    cmp dword ptr [rip + picker_mode], 1
    je .picker_scan_clear_name_field
    cmp dword ptr [rip + picker_mode], 3
    je .picker_scan_clear_name_field
    cmp dword ptr [rip + picker_mode], 4
    je .picker_scan_clear_name_field
    cmp dword ptr [rip + picker_mode], 5
    je .picker_scan_clear_name_field
    cmp dword ptr [rip + picker_mode], 6
    jne .picker_scan_keep_name_field
.picker_scan_clear_name_field:
    mov dword ptr [rip + picker_name_length], 0
    mov dword ptr [rip + picker_name_cursor], 0
    mov dword ptr [rip + picker_name_view_start], 0
    mov dword ptr [rip + picker_name_match], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    mov byte ptr [rip + picker_name_buffer], 0
.picker_scan_keep_name_field:
    mov eax, SYS_lseek
    mov edi, dword ptr [rip + picker_dir_fd]
    xor esi, esi
    xor edx, edx
    syscall
    test rax, rax
    js .picker_scan_error
.picker_scan_read:
    mov eax, SYS_getdents64
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_dirents]
    mov edx, PICKER_DIR_BYTES
    syscall
    test rax, rax
    js .picker_scan_error
    jz .picker_scan_done
    mov r13, rax
    lea r12, [rip + picker_dirents]
.picker_scan_record:
    test r13, r13
    jz .picker_scan_read
    cmp r13, 20
    jb .picker_scan_error
    movzx ebp, word ptr [r12 + 16]
    cmp ebp, 20
    jb .picker_scan_error
    mov eax, ebp
    cmp rax, r13
    ja .picker_scan_error
    lea r14, [r12 + 19]
    movzx eax, byte ptr [r14]
    test al, al
    jz .picker_scan_advance
    cmp al, '.'
    jne .picker_scan_hidden_check
    cmp byte ptr [r14 + 1], 0
    je .picker_scan_advance
    cmp byte ptr [r14 + 1], '.'
    jne .picker_scan_hidden_check
    cmp byte ptr [r14 + 2], 0
    je .picker_scan_advance
.picker_scan_hidden_check:
    cmp dword ptr [rip + picker_show_hidden], 0
    jne .picker_scan_stat
    cmp byte ptr [r14], '.'
    je .picker_scan_advance
.picker_scan_stat:
    # Do not rely on dirent.d_type: query the entry without following symlinks.
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    mov rsi, r14
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_scan_advance
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFDIR
    je .picker_scan_is_directory
    cmp eax, STAT_S_IFREG
    jne .picker_scan_advance
    mov byte ptr [rip + picker_candidate], 0
    jmp .picker_scan_name
.picker_scan_is_directory:
    mov byte ptr [rip + picker_candidate], 1
.picker_scan_name:
    mov ecx, ebp
    sub ecx, 19
    cmp ecx, 255
    jbe .picker_scan_name_limit
    mov ecx, 255
.picker_scan_name_limit:
    xor ebx, ebx
.picker_scan_name_length:
    cmp ebx, ecx
    jae .picker_scan_advance
    cmp byte ptr [r14 + rbx], 0
    je .picker_scan_name_ready
    inc ebx
    jmp .picker_scan_name_length
.picker_scan_name_ready:
    test ebx, ebx
    jz .picker_scan_advance
    # Font mode includes directories and regular .ttf files; locale mode
    # includes directories and regular .nlp data files only.
    cmp dword ptr [rip + picker_mode], 3
    je .picker_scan_filter_font
    cmp dword ptr [rip + picker_mode], 4
    je .picker_scan_filter_locale
    jmp .picker_scan_name_copy
.picker_scan_filter_font:
    cmp byte ptr [rip + picker_candidate], 1
    je .picker_scan_name_copy
    cmp ebx, 4
    jb .picker_scan_advance
    lea rax, [r14 + rbx - 4]
    cmp byte ptr [rax], '.'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 1]
    or dl, 0x20
    cmp dl, 't'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 2]
    or dl, 0x20
    cmp dl, 't'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 3]
    or dl, 0x20
    cmp dl, 'f'
    jne .picker_scan_advance
    jmp .picker_scan_name_copy
.picker_scan_filter_locale:
    cmp dword ptr [rip + picker_mode], 5
    jne .picker_scan_filter_locale_install
    cmp byte ptr [rip + picker_candidate], 1
    je .picker_scan_advance
    jmp .picker_scan_filter_locale_extension
.picker_scan_filter_locale_install:
    cmp byte ptr [rip + picker_candidate], 1
    je .picker_scan_name_copy
.picker_scan_filter_locale_extension:
    cmp ebx, 4
    jb .picker_scan_advance
    lea rax, [r14 + rbx - 4]
    cmp byte ptr [rax], '.'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 1]
    or dl, 0x20
    cmp dl, 'n'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 2]
    or dl, 0x20
    cmp dl, 'l'
    jne .picker_scan_advance
    movzx edx, byte ptr [rax + 3]
    or dl, 0x20
    cmp dl, 'p'
    jne .picker_scan_advance
.picker_scan_name_copy:
    lea rdi, [rip + picker_candidate + 4]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    mov byte ptr [rdi], 0
    call picker_insert_candidate
.picker_scan_advance:
    add r12, rbp
    sub r13, rbp
    jmp .picker_scan_record
.picker_scan_done:
    xor eax, eax
    jmp .picker_scan_return
.picker_scan_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_scan_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size picker_scan_directory, . - picker_scan_directory

.type picker_insert_candidate, @function
picker_insert_candidate:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, dword ptr [rip + picker_entry_count]
    cmp r12d, PICKER_MAX_ENTRIES
    jb .picker_insert_find
    mov dword ptr [rip + picker_truncated], 1
    jmp .picker_insert_done
.picker_insert_find:
    xor r13d, r13d
.picker_insert_compare:
    cmp r13d, r12d
    jae .picker_insert_at_end
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea r14, [rip + picker_entries]
    add r14, rax
    movzx eax, byte ptr [rip + picker_candidate]
    movzx edx, byte ptr [r14]
    cmp eax, edx
    ja .picker_insert_found
    jb .picker_insert_next
    lea rbx, [rip + picker_candidate + 4]
    lea r15, [r14 + 4]
.picker_insert_name_compare:
    movzx eax, byte ptr [rbx]
    movzx edx, byte ptr [r15]
    cmp eax, edx
    jb .picker_insert_found
    ja .picker_insert_next
    test eax, eax
    jz .picker_insert_next
    inc rbx
    inc r15
    jmp .picker_insert_name_compare
.picker_insert_next:
    inc r13d
    jmp .picker_insert_compare
.picker_insert_at_end:
    mov r13d, r12d
    jmp .picker_insert_copy
.picker_insert_found:
.picker_insert_copy:
    cmp r13d, r12d
    je .picker_insert_copy_candidate
    mov eax, r12d
    imul eax, PICKER_ENTRY_SIZE
    lea rsi, [rip + picker_entries]
    add rsi, rax
    dec rsi
    lea rdi, [rsi + PICKER_ENTRY_SIZE]
    mov eax, r12d
    sub eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    mov ecx, eax
    std
    rep movsb
    cld
.picker_insert_copy_candidate:
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea rdi, [rip + picker_entries]
    add rdi, rax
    lea rsi, [rip + picker_candidate]
    mov ecx, PICKER_ENTRY_SIZE
    rep movsb
    inc dword ptr [rip + picker_entry_count]
.picker_insert_done:
    cld
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_insert_candidate, . - picker_insert_candidate



# Reuse the existing bounded .nlp directory scanner to refresh installed packs.
# The scanner's entry array remains available after picker_close().
.type settings_locale_refresh, @function
settings_locale_refresh:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov ebx, dword ptr [rip + settings_menu_open]
    mov edi, 5
    call picker_start
    test rax, rax
    js .settings_locale_refresh_error
    call picker_close
    mov dword ptr [rip + locale_manager_error], 0
    jmp .settings_locale_refresh_restore
.settings_locale_refresh_error:
    call picker_close
    mov dword ptr [rip + locale_manager_error], 1
.settings_locale_refresh_restore:
    mov dword ptr [rip + settings_menu_open], ebx
    call settings_locale_sync_selection
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    xor eax, eax
    ret
.size settings_locale_refresh, . - settings_locale_refresh

# Resolve the current saved/effective tag to the matching dynamic list item.
# Item zero is the built-in en_US locale; installed packs follow scanner order.
.type settings_locale_sync_selection, @function
settings_locale_sync_selection:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov dword ptr [rip + settings_locale_dropdown_selected], 0
    mov dword ptr [rip + settings_locale_dropdown_scroll], 0
    call preferences_locale_is_builtin
    test eax, eax
    jnz .settings_locale_sync_adjust
    mov r12, qword ptr [rip + preferences_locale_ptr]
    test r12, r12
    jnz .settings_locale_sync_tag
    lea r12, [rip + compose_locale_current_tag]
.settings_locale_sync_tag:
    xor r15d, r15d
.settings_locale_sync_tag_length:
    cmp r15d, 31
    jae .settings_locale_sync_adjust
    cmp byte ptr [r12 + r15], 0
    je .settings_locale_sync_loop_start
    inc r15d
    jmp .settings_locale_sync_tag_length
.settings_locale_sync_loop_start:
    test r15d, r15d
    jz .settings_locale_sync_adjust
    xor r13d, r13d
.settings_locale_sync_entry_loop:
    cmp r13d, dword ptr [rip + picker_entry_count]
    jae .settings_locale_sync_adjust
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea r14, [rip + picker_entries]
    add r14, rax
    lea rbx, [r14 + 4]
    xor ecx, ecx
.settings_locale_sync_name_length:
    cmp ecx, 255
    jae .settings_locale_sync_next
    cmp byte ptr [rbx + rcx], 0
    je .settings_locale_sync_name_ready
    inc ecx
    jmp .settings_locale_sync_name_length
.settings_locale_sync_name_ready:
    lea eax, [r15 + 4]
    cmp ecx, eax
    jne .settings_locale_sync_next
    xor edx, edx
.settings_locale_sync_compare:
    cmp edx, r15d
    jae .settings_locale_sync_suffix
    mov al, byte ptr [rbx + rdx]
    cmp al, byte ptr [r12 + rdx]
    jne .settings_locale_sync_next
    inc edx
    jmp .settings_locale_sync_compare
.settings_locale_sync_suffix:
    cmp byte ptr [rbx + r15], '.'
    jne .settings_locale_sync_next
    cmp byte ptr [rbx + r15 + 1], 'n'
    jne .settings_locale_sync_next
    cmp byte ptr [rbx + r15 + 2], 'l'
    jne .settings_locale_sync_next
    cmp byte ptr [rbx + r15 + 3], 'p'
    jne .settings_locale_sync_next
    lea eax, [r13 + 1]
    mov dword ptr [rip + settings_locale_dropdown_selected], eax
    jmp .settings_locale_sync_adjust
.settings_locale_sync_next:
    inc r13d
    jmp .settings_locale_sync_entry_loop
.settings_locale_sync_adjust:
    call settings_locale_dropdown_adjust
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size settings_locale_sync_selection, . - settings_locale_sync_selection

# Keep the highlighted item in the six-row viewport.
.type settings_locale_dropdown_adjust, @function
settings_locale_dropdown_adjust:
    mov eax, dword ptr [rip + settings_locale_dropdown_selected]
    cmp eax, 5
    jbe .settings_locale_dropdown_scroll_zero
    sub eax, 5
    mov dword ptr [rip + settings_locale_dropdown_scroll], eax
    ret
.settings_locale_dropdown_scroll_zero:
    mov dword ptr [rip + settings_locale_dropdown_scroll], 0
    ret
.size settings_locale_dropdown_adjust, . - settings_locale_dropdown_adjust

# Apply the highlighted item. Base is item zero; other rows map to picker_entries.
.type settings_locale_activate, @function
settings_locale_activate:
    push rbx
    push r12
    sub rsp, 8
    mov ebx, dword ptr [rip + settings_locale_dropdown_selected]
    test ebx, ebx
    jnz .settings_locale_activate_pack
    lea rdi, [rip + ui_locale_en_tag]
    call preferences_set_locale_tag
    test eax, eax
    jz .settings_locale_activate_error
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    call preferences_save
    mov dword ptr [rip + locale_manager_error], 0
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    mov dword ptr [rip + settings_locale_dropdown_selected], 0
    mov dword ptr [rip + settings_menu_open], 0
    jmp .settings_locale_activate_done
.settings_locale_activate_pack:
    dec ebx
    mov dword ptr [rip + picker_selected], ebx
    mov dword ptr [rip + picker_focus], 0
    mov dword ptr [rip + picker_mode], 5
    call picker_select_locale
    test rax, rax
    js .settings_locale_activate_error
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov dword ptr [rip + locale_manager_error], 0
    jmp .settings_locale_activate_done
.settings_locale_activate_error:
    mov dword ptr [rip + locale_manager_error], 1
    call picker_close
.settings_locale_activate_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size settings_locale_activate, . - settings_locale_activate

.type render_settings_locale_dropdown, @function
render_settings_locale_dropdown:
    cmp dword ptr [rip + settings_locale_dropdown_open], 1
    jne .render_settings_locale_dropdown_done
    push rbx
    push r12
    push r13
    push r14
    push r15
    # Opaque popup overlays unused Settings rows; six entries fit at current UI scale.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 160
    mov edx, 88
    mov ecx, 144
    mov r8d, 96
    mov r9d, 0xff171c24
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 161
    mov edx, 89
    mov ecx, 142
    mov r8d, 94
    mov r9d, 0xff252a33
    call draw_rect
    mov r12d, dword ptr [rip + settings_locale_dropdown_scroll]
    xor r13d, r13d
.render_settings_locale_dropdown_rows:
    cmp r13d, 6
    jae .render_settings_locale_dropdown_finish
    mov r14d, r12d
    add r14d, r13d
    mov eax, dword ptr [rip + picker_entry_count]
    inc eax
    cmp r14d, eax
    jae .render_settings_locale_dropdown_next
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 162
    mov eax, r13d
    shl eax, 4
    lea edx, [rax + 89]
    mov ecx, 140
    mov r8d, 15
    cmp r14d, dword ptr [rip + settings_locale_dropdown_selected]
    jne .render_settings_locale_dropdown_normal
    mov r9d, 0xff414b5a
    jmp .render_settings_locale_dropdown_fill
.render_settings_locale_dropdown_normal:
    mov r9d, 0xff252a33
.render_settings_locale_dropdown_fill:
    call draw_rect
    cmp r14d, 0
    jne .render_settings_locale_dropdown_pack
    mov edi, 168
    mov eax, r13d
    shl eax, 4
    lea esi, [rax + 101]
    lea rdx, [rip + ui_menu_locale_builtin]
    call draw_text
    jmp .render_settings_locale_dropdown_next
.render_settings_locale_dropdown_pack:
    lea eax, [r14 - 1]
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    add rbx, 4
    xor ecx, ecx
.render_settings_locale_dropdown_name_length:
    cmp ecx, 255
    jae .render_settings_locale_dropdown_next
    cmp byte ptr [rbx + rcx], 0
    je .render_settings_locale_dropdown_name_ready
    inc ecx
    jmp .render_settings_locale_dropdown_name_length
.render_settings_locale_dropdown_name_ready:
    cmp ecx, 4
    jb .render_settings_locale_dropdown_next
    sub ecx, 4
    lea rdi, [rip + settings_locale_display_buffer]
    mov rsi, rbx
    rep movsb
    mov byte ptr [rdi], 0
    mov edi, 168
    mov eax, r13d
    shl eax, 4
    lea esi, [rax + 101]
    lea rdx, [rip + settings_locale_display_buffer]
    mov ecx, 124
    call draw_bounded_ascii_width
.render_settings_locale_dropdown_next:
    inc r13d
    jmp .render_settings_locale_dropdown_rows
.render_settings_locale_dropdown_finish:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
.render_settings_locale_dropdown_done:
    ret
.size render_settings_locale_dropdown, . - render_settings_locale_dropdown

.type picker_close, @function
picker_close:
    mov dword ptr [rip + picker_mode], 0
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + history_export_mode], 0
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_close_done
    mov edi, eax
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], -1
.picker_close_done:
    ret
.size picker_close, . - picker_close

.type picker_copy_path_to_field, @function
picker_copy_path_to_field:
    lea rsi, [rip + picker_current_path]
    lea rdi, [rip + picker_path_buffer]
    mov ecx, dword ptr [rip + picker_path_length]
    rep movsb
    mov byte ptr [rdi], 0
    mov eax, dword ptr [rip + picker_path_length]
    mov dword ptr [rip + picker_path_cursor], eax
    mov dword ptr [rip + picker_path_view_start], 0
    ret
.size picker_copy_path_to_field, . - picker_copy_path_to_field

.type picker_enter_directory, @function
picker_enter_directory:
    # RDI points to a NUL-terminated name relative to picker_dir_fd.
    push rbx
    push r12
    push r13
    mov r12, rdi
    # Validate path capacity before changing the active descriptor.
    mov ebx, dword ptr [rip + picker_path_length]
    test ebx, ebx
    jz .picker_enter_need_slash
    lea rdx, [rip + picker_current_path]
    cmp byte ptr [rdx + rbx - 1], '/'
    je .picker_enter_path_capacity_ready
.picker_enter_need_slash:
    inc ebx
.picker_enter_path_capacity_ready:
    xor ecx, ecx
.picker_enter_name_len:
    cmp ecx, 255
    jae .picker_enter_path_capacity_ready2
    cmp byte ptr [r12 + rcx], 0
    je .picker_enter_path_capacity_ready2
    inc ecx
    jmp .picker_enter_name_len
.picker_enter_path_capacity_ready2:
    add ebx, ecx
    cmp ebx, PATH_CAPACITY - 1
    ja .picker_enter_directory_error
    mov eax, SYS_openat
    mov edi, dword ptr [rip + picker_dir_fd]
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_enter_directory_error
    mov r13d, eax
    # The target was opened successfully; now replace the old descriptor.
    mov edi, dword ptr [rip + picker_dir_fd]
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], r13d
    mov ebx, dword ptr [rip + picker_path_length]
    lea rdi, [rip + picker_current_path]
    test ebx, ebx
    jz .picker_enter_append_slash
    cmp byte ptr [rdi + rbx - 1], '/'
    je .picker_enter_append_name
.picker_enter_append_slash:
    mov byte ptr [rdi + rbx], '/'
    inc ebx
.picker_enter_append_name:
    add rdi, rbx
    mov rsi, r12
    xor ecx, ecx
.picker_enter_copy_name:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_enter_path_done
    inc ecx
    jmp .picker_enter_copy_name
.picker_enter_path_done:
    add ebx, ecx
    mov dword ptr [rip + picker_path_length], ebx
    call picker_copy_path_to_field
    call picker_scan_directory
    test rax, rax
    js .picker_enter_directory_error
    xor eax, eax
    jmp .picker_enter_directory_done
.picker_enter_directory_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_enter_directory_done:
    pop r13
    pop r12
    pop rbx
    ret
.size picker_enter_directory, . - picker_enter_directory

.type picker_go_parent, @function
picker_go_parent:
    push rbx
    push r12
    sub rsp, 8
    mov eax, SYS_openat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + ui_picker_parent]
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_parent_error
    mov r12d, eax
    mov edi, dword ptr [rip + picker_dir_fd]
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + picker_dir_fd], r12d
    mov ebx, dword ptr [rip + picker_path_length]
    cmp ebx, 1
    jbe .picker_parent_root
    lea rdi, [rip + picker_current_path]
    dec ebx
    cmp byte ptr [rdi + rbx], '/'
    jne .picker_parent_find_slash
    dec ebx
.picker_parent_find_slash:
    cmp ebx, 0
    je .picker_parent_make_root
    cmp byte ptr [rdi + rbx], '/'
    je .picker_parent_truncate
    dec ebx
    jmp .picker_parent_find_slash
.picker_parent_make_root:
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1
    jmp .picker_parent_rescan
.picker_parent_truncate:
    cmp ebx, 0
    jne .picker_parent_set_terminator
.picker_parent_root:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi], '/'
    mov byte ptr [rdi + 1], 0
    mov dword ptr [rip + picker_path_length], 1
    jmp .picker_parent_rescan
.picker_parent_set_terminator:
    lea rdi, [rip + picker_current_path]
    mov byte ptr [rdi + rbx], 0
    mov dword ptr [rip + picker_path_length], ebx
.picker_parent_rescan:
    call picker_copy_path_to_field
    call picker_scan_directory
    jmp .picker_parent_done
.picker_parent_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_parent_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_go_parent, . - picker_go_parent

.type picker_go_home, @function
picker_go_home:
    push rbx
    push r12
    sub rsp, 8
    lea rdi, [rip + ui_picker_home_env]
    mov esi, 4
    call env_lookup
    test rax, rax
    jz .picker_home_error
    mov r12, rax
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_home_error
    mov ebx, eax
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_home_replace
    mov edi, eax
    mov eax, SYS_close
    syscall
.picker_home_replace:
    mov dword ptr [rip + picker_dir_fd], ebx
    lea rdi, [rip + picker_current_path]
    mov rsi, r12
    mov edx, PATH_CAPACITY
    call copy_cstr
    test rax, rax
    js .picker_home_error
    mov dword ptr [rip + picker_path_length], eax
    call picker_copy_path_to_field
    call picker_scan_directory
    jmp .picker_home_done
.picker_home_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_home_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_go_home, . - picker_go_home

.type picker_navigate_path, @function
picker_navigate_path:
    push rbx
    push r12
    sub rsp, 8
    lea r12, [rip + picker_path_buffer]
    cmp byte ptr [r12], 0
    je .picker_navigate_path_error
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor r10d, r10d
    syscall
    test rax, rax
    js .picker_navigate_path_error
    mov ebx, eax
    mov eax, dword ptr [rip + picker_dir_fd]
    cmp eax, 0
    jl .picker_navigate_replace
    mov edi, eax
    mov eax, SYS_close
    syscall
.picker_navigate_replace:
    mov dword ptr [rip + picker_dir_fd], ebx
    lea rdi, [rip + picker_current_path]
    mov rsi, r12
    mov edx, PATH_CAPACITY
    call copy_cstr
    test rax, rax
    js .picker_navigate_path_error
    mov dword ptr [rip + picker_path_length], eax
    call picker_copy_path_to_field
    call picker_scan_directory
    test rax, rax
    js .picker_navigate_path_error
    # A committed location change returns keyboard focus to the directory list.
    mov dword ptr [rip + picker_focus], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    xor eax, eax
    jmp .picker_navigate_done
.picker_navigate_path_error:
    mov dword ptr [rip + picker_error], 1
    mov rax, -5
.picker_navigate_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_navigate_path, . - picker_navigate_path

.type picker_copy_selected_name, @function
picker_copy_selected_name:
    push rbx
    mov eax, dword ptr [rip + picker_selected]
    cmp eax, 0
    jl .picker_copy_name_empty
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_copy_name_empty
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    cmp byte ptr [rbx], 0
    jne .picker_copy_name_empty
    mov dword ptr [rip + picker_name_match], 1
    lea rsi, [rbx + 4]
    lea rdi, [rip + picker_name_buffer]
    xor edx, edx
.picker_copy_name_loop:
    cmp edx, 255
    jae .picker_copy_name_done
    mov al, byte ptr [rsi + rdx]
    mov byte ptr [rdi + rdx], al
    test al, al
    jz .picker_copy_name_done
    inc edx
    jmp .picker_copy_name_loop
.picker_copy_name_done:
    mov dword ptr [rip + picker_name_length], edx
    mov dword ptr [rip + picker_name_cursor], edx
    mov dword ptr [rip + picker_name_view_start], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_copy_name_return
.picker_copy_name_empty:
    mov dword ptr [rip + picker_name_length], 0
    mov dword ptr [rip + picker_name_cursor], 0
    mov dword ptr [rip + picker_name_view_start], 0
    mov dword ptr [rip + picker_name_match], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    mov byte ptr [rip + picker_name_buffer], 0
.picker_copy_name_return:
    pop rbx
    ret
.size picker_copy_selected_name, . - picker_copy_selected_name

# Case-insensitive ASCII filename-prefix search. Collect up to five regular-file
# suggestions, default to the first result, and scroll that result into view.
.type picker_find_name_prefix, @function
picker_find_name_prefix:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov dword ptr [rip + picker_suggestion_count], 0
    mov dword ptr [rip + picker_suggestion_selected], 0
    mov dword ptr [rip + picker_selected], -1
    mov dword ptr [rip + picker_name_match], 0
    mov r12d, dword ptr [rip + picker_name_length]
    test r12d, r12d
    jz .picker_find_name_done
    xor r13d, r13d
.picker_find_name_entry:
    cmp r13d, dword ptr [rip + picker_entry_count]
    jae .picker_find_name_done
    mov eax, r13d
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    cmp byte ptr [rbx], 0
    jne .picker_find_name_next
    lea r14, [rbx + 4]
    lea r15, [rip + picker_name_buffer]
    xor ecx, ecx
.picker_find_name_compare:
    cmp ecx, r12d
    jae .picker_find_name_match
    movzx eax, byte ptr [r14 + rcx]
    movzx edx, byte ptr [r15 + rcx]
    cmp al, 'A'
    jb .picker_find_name_left_folded
    cmp al, 'Z'
    ja .picker_find_name_left_folded
    or al, 0x20
.picker_find_name_left_folded:
    cmp dl, 'A'
    jb .picker_find_name_right_folded
    cmp dl, 'Z'
    ja .picker_find_name_right_folded
    or dl, 0x20
.picker_find_name_right_folded:
    cmp al, dl
    jne .picker_find_name_next
    inc ecx
    jmp .picker_find_name_compare
.picker_find_name_match:
    # Keep the first five sorted matches for the visible suggestion popup.
    mov eax, dword ptr [rip + picker_suggestion_count]
    cmp eax, PICKER_SUGGESTION_MAX
    jae .picker_find_name_next
    lea rdx, [rip + picker_suggestion_indices]
    mov dword ptr [rdx + rax*4], r13d
    inc eax
    mov dword ptr [rip + picker_suggestion_count], eax
    cmp eax, 1
    jne .picker_find_name_next
    mov dword ptr [rip + picker_selected], r13d
    mov dword ptr [rip + picker_name_match], 1
    # Scroll the default (first) suggestion into the 15-row directory view.
    mov eax, dword ptr [rip + picker_scroll]
    cmp r13d, eax
    jb .picker_find_name_scroll_top
    mov edx, r13d
    sub edx, eax
    cmp edx, PICKER_VISIBLE_ROWS
    jb .picker_find_name_next
    sub r13d, PICKER_VISIBLE_ROWS - 1
    mov dword ptr [rip + picker_scroll], r13d
    jmp .picker_find_name_next
.picker_find_name_scroll_top:
    mov dword ptr [rip + picker_scroll], r13d
.picker_find_name_next:
    inc r13d
    jmp .picker_find_name_entry
.picker_find_name_done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_find_name_prefix, . - picker_find_name_prefix

# Move the active autocomplete candidate without changing the typed prefix.
# EDI is -1 or +1. The first matching filename remains the default candidate.
.type picker_cycle_suggestion, @function
picker_cycle_suggestion:
    mov ecx, dword ptr [rip + picker_suggestion_count]
    test ecx, ecx
    jz .picker_cycle_suggestion_done
    mov eax, dword ptr [rip + picker_suggestion_selected]
    add eax, edi
    test eax, eax
    jns .picker_cycle_suggestion_upper
    lea eax, [rcx - 1]
    jmp .picker_cycle_suggestion_store
.picker_cycle_suggestion_upper:
    cmp eax, ecx
    jb .picker_cycle_suggestion_store
    xor eax, eax
.picker_cycle_suggestion_store:
    mov dword ptr [rip + picker_suggestion_selected], eax
    lea rdx, [rip + picker_suggestion_indices]
    mov edx, dword ptr [rdx + rax*4]
    mov dword ptr [rip + picker_selected], edx
    mov eax, dword ptr [rip + picker_scroll]
    cmp edx, eax
    jb .picker_cycle_suggestion_scroll_top
    mov ecx, edx
    sub ecx, eax
    cmp ecx, PICKER_VISIBLE_ROWS
    jb .picker_cycle_suggestion_done
    sub edx, PICKER_VISIBLE_ROWS - 1
    mov dword ptr [rip + picker_scroll], edx
    ret
.picker_cycle_suggestion_scroll_top:
    mov dword ptr [rip + picker_scroll], edx
.picker_cycle_suggestion_done:
    ret
.size picker_cycle_suggestion, . - picker_cycle_suggestion

# Accept the highlighted suggestion into the filename field and return focus
# to the list. The user can then press Enter or click Open to activate it.
.type picker_accept_suggestion, @function
picker_accept_suggestion:
    mov eax, dword ptr [rip + picker_suggestion_count]
    test eax, eax
    jz .picker_accept_suggestion_done
    mov eax, dword ptr [rip + picker_suggestion_selected]
    lea rdx, [rip + picker_suggestion_indices]
    mov eax, dword ptr [rdx + rax*4]
    mov dword ptr [rip + picker_selected], eax
    call picker_copy_selected_name
    mov dword ptr [rip + picker_focus], 0
.picker_accept_suggestion_done:
    ret
.size picker_accept_suggestion, . - picker_accept_suggestion

# Insert AL at the current field cursor, replacing the field first after Ctrl+A.
.type picker_edit_insert_byte, @function
picker_edit_insert_byte:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    cmp dword ptr [rip + picker_focus], 1
    je .picker_edit_insert_path
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_edit_insert_done
    lea rbx, [rip + picker_name_buffer]
    mov r13d, dword ptr [rip + picker_name_length]
    mov r14d, dword ptr [rip + picker_name_cursor]
    mov r15d, 255
    jmp .picker_edit_insert_ready
.picker_edit_insert_path:
    lea rbx, [rip + picker_path_buffer]
    mov r13d, dword ptr [rip + picker_path_length]
    mov r14d, dword ptr [rip + picker_path_cursor]
    mov r15d, PATH_CAPACITY - 1
.picker_edit_insert_ready:
    cmp dword ptr [rip + picker_edit_select_all], 0
    je .picker_edit_insert_clamp
    mov r13d, 0
    mov r14d, 0
    mov byte ptr [rbx], 0
    mov dword ptr [rip + picker_edit_select_all], 0
.picker_edit_insert_clamp:
    cmp r14d, r13d
    jbe .picker_edit_insert_cursor_ready
    mov r14d, r13d
.picker_edit_insert_cursor_ready:
    cmp r13d, r15d
    jae .picker_edit_insert_done
    # Shift the suffix, including its NUL terminator, one byte to the right.
    mov ecx, r13d
    sub ecx, r14d
    inc ecx
    lea rsi, [rbx + r13]
    lea rdi, [rbx + r13 + 1]
    std
    rep movsb
    cld
    mov byte ptr [rbx + r14], r12b
    inc r13d
    inc r14d
    mov byte ptr [rbx + r13], 0
    cmp dword ptr [rip + picker_focus], 1
    jne .picker_edit_insert_name_store
    mov dword ptr [rip + picker_path_length], r13d
    mov dword ptr [rip + picker_path_cursor], r14d
    jmp .picker_edit_insert_changed
.picker_edit_insert_name_store:
    mov dword ptr [rip + picker_name_length], r13d
    mov dword ptr [rip + picker_name_cursor], r14d
    mov dword ptr [rip + picker_name_match], 0
.picker_edit_insert_changed:
    mov dword ptr [rip + picker_error], 0
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_edit_insert_done
    cmp dword ptr [rip + picker_mode], 1
    je .picker_edit_insert_find_prefix
    cmp dword ptr [rip + picker_mode], 3
    jne .picker_edit_insert_done
.picker_edit_insert_find_prefix:
    call picker_find_name_prefix
.picker_edit_insert_done:
    cld
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_edit_insert_byte, . - picker_edit_insert_byte

# EDI=1 removes the byte before the cursor; EDI=0 removes the byte at it.
.type picker_edit_delete_byte, @function
picker_edit_delete_byte:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12d, edi
    cmp dword ptr [rip + picker_focus], 1
    je .picker_edit_delete_path
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_edit_delete_done
    lea rbx, [rip + picker_name_buffer]
    mov r13d, dword ptr [rip + picker_name_length]
    mov r14d, dword ptr [rip + picker_name_cursor]
    jmp .picker_edit_delete_ready
.picker_edit_delete_path:
    lea rbx, [rip + picker_path_buffer]
    mov r13d, dword ptr [rip + picker_path_length]
    mov r14d, dword ptr [rip + picker_path_cursor]
.picker_edit_delete_ready:
    cmp dword ptr [rip + picker_edit_select_all], 0
    je .picker_edit_delete_single
    xor r13d, r13d
    xor r14d, r14d
    mov byte ptr [rbx], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_edit_delete_store
.picker_edit_delete_single:
    cmp r12d, 0
    je .picker_edit_delete_forward
    test r14d, r14d
    jz .picker_edit_delete_done
    dec r14d
    jmp .picker_edit_delete_copy
.picker_edit_delete_forward:
    cmp r14d, r13d
    jae .picker_edit_delete_done
.picker_edit_delete_copy:
    mov ecx, r13d
    sub ecx, r14d
    # For Backspace, source and destination are both the new cursor.
    # For Delete, source begins one byte beyond the cursor.
    lea rsi, [rbx + r14 + 1]
    lea rdi, [rbx + r14]
    cld
    rep movsb
    dec r13d
.picker_edit_delete_store:
    mov byte ptr [rbx + r13], 0
    cmp dword ptr [rip + picker_focus], 1
    jne .picker_edit_delete_name_store
    mov dword ptr [rip + picker_path_length], r13d
    mov dword ptr [rip + picker_path_cursor], r14d
    jmp .picker_edit_delete_done
.picker_edit_delete_name_store:
    mov dword ptr [rip + picker_name_length], r13d
    mov dword ptr [rip + picker_name_cursor], r14d
    mov dword ptr [rip + picker_name_match], 0
    cmp dword ptr [rip + picker_mode], 1
    je .picker_edit_delete_find_prefix
    cmp dword ptr [rip + picker_mode], 3
    jne .picker_edit_delete_done
.picker_edit_delete_find_prefix:
    call picker_find_name_prefix
.picker_edit_delete_done:
    cld
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_edit_delete_byte, . - picker_edit_delete_byte


.type picker_build_target, @function
picker_build_target:
    push rbx
    push r12
    push r13
    lea r12, [rip + picker_name_buffer]
    cmp byte ptr [r12], 0
    je .picker_build_target_error
    lea rdi, [rip + picker_target_buffer]
    cmp byte ptr [r12], '/'
    je .picker_build_absolute
    lea rsi, [rip + picker_current_path]
    xor ecx, ecx
.picker_build_copy_dir:
    mov al, byte ptr [rsi + rcx]
    test al, al
    jz .picker_build_dir_done
    cmp ecx, PATH_CAPACITY - 2
    jae .picker_build_target_error
    mov byte ptr [rdi + rcx], al
    inc ecx
    jmp .picker_build_copy_dir
.picker_build_dir_done:
    cmp ecx, 0
    je .picker_build_separator
    cmp byte ptr [rdi + rcx - 1], '/'
    je .picker_build_name
.picker_build_separator:
    cmp ecx, PATH_CAPACITY - 2
    jae .picker_build_target_error
    mov byte ptr [rdi + rcx], '/'
    inc ecx
.picker_build_name:
    mov rsi, r12
    xor edx, edx
.picker_build_name_loop:
    mov al, byte ptr [rsi + rdx]
    test al, al
    jz .picker_build_name_done
    lea r8d, [rcx + rdx]
    cmp r8d, PATH_CAPACITY - 1
    jae .picker_build_target_error
    mov byte ptr [rdi + r8], al
    inc edx
    jmp .picker_build_name_loop
.picker_build_name_done:
    # The old target may have been longer; always terminate the new path.
    lea r8d, [rcx + rdx]
    mov byte ptr [rdi + r8], 0
    jmp .picker_build_target_done
.picker_build_absolute:
    mov rsi, r12
    xor ecx, ecx
.picker_build_absolute_loop:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_build_target_done
    inc ecx
    cmp ecx, PATH_CAPACITY - 1
    jb .picker_build_absolute_loop
    jmp .picker_build_target_error
.picker_build_target_done:
    lea rax, [rip + picker_target_buffer]
    jmp .picker_build_target_return
.picker_build_target_error:
    xor eax, eax
.picker_build_target_return:
    pop r13
    pop r12
    pop rbx
    ret
.size picker_build_target, . - picker_build_target

.type picker_commit_active_path, @function
picker_commit_active_path:
    push r12
    lea rsi, [rip + picker_target_buffer]
    lea rdi, [rip + current_path_buffer]
    xor ecx, ecx
.picker_commit_path_copy:
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .picker_commit_path_done
    inc ecx
    cmp ecx, PATH_CAPACITY - 1
    jb .picker_commit_path_copy
    mov byte ptr [rdi + PATH_CAPACITY - 1], 0
.picker_commit_path_done:
    lea r12, [rip + current_path_buffer]
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name
    pop r12
    ret
.size picker_commit_active_path, . - picker_commit_active_path


.type history_open_selected, @function
history_open_selected:
    push r12
    mov edi, dword ptr [rip + history_search_selected]
    call history_search_result
    test rax, rax
    jz .history_open_selected_failed
    lea rdi, [rip + picker_target_buffer]
    mov rsi, rax
    mov edx, PATH_CAPACITY
    call copy_cstr
    test rax, rax
    js .history_open_selected_failed
    lea rdi, [rip + picker_target_buffer]
    call load_document_from_path
    test rax, rax
    js .history_open_selected_failed
    call picker_commit_active_path
    mov dword ptr [rip + history_tab_open], 1
    mov dword ptr [rip + history_search_focus], 0
    mov dword ptr [rip + history_open_error], 0
    xor eax, eax
    jmp .history_open_selected_done
.history_open_selected_failed:
    mov dword ptr [rip + history_open_error], 1
    mov eax, -5
.history_open_selected_done:
    pop r12
    ret
.size history_open_selected, . - history_open_selected

.type picker_load_font, @function
picker_load_font:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_load_font_error
    mov r12, rax
    # Reject directories, symlinks and special files before mapping the font.
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_name_buffer]
    cmp byte ptr [rip + picker_name_buffer], '/'
    jne .picker_load_font_stat_relative
    mov edi, AT_FDCWD
    mov rsi, r12
.picker_load_font_stat_relative:
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_load_font_error
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFREG
    jne .picker_load_font_error
    mov rdi, r12
    call font_replace_path
    test rax, rax
    js .picker_load_font_error
    # Remember only a face that passed the transactional SFNT validator.
    mov rdi, r12
    call preferences_set_font_path
    call preferences_save
    mov dword ptr [rip + picker_error], 0
    # Face metrics affect every document advance and line box. Rebuild the
    # width-dependent index before returning to the document surface.
    mov dword ptr [rip + doc_line_index_valid], 0
    call window_update_geometry
    call doc_line_index_rebuild
    call doc_ensure_cursor_visible
    call picker_close
    xor eax, eax
    jmp .picker_load_font_done
.picker_load_font_error:
    # font_replace_path is transactional: the previous face and cache survive.
    mov dword ptr [rip + picker_error], 4
    mov rax, -5
.picker_load_font_done:
    pop r12
    ret
.size picker_load_font, . - picker_load_font

.type picker_install_locale, @function
picker_install_locale:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_install_locale_error
    mov r12, rax
    mov rdi, r12
    call compose_locale_install_pack
    test eax, eax
    jz .picker_install_locale_error
    lea rdi, [rip + compose_locale_installed_tag]
    call preferences_set_locale_tag
    test eax, eax
    jz .picker_install_locale_error
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    test eax, eax
    jz .picker_install_locale_error
    call preferences_save
    mov dword ptr [rip + locale_manager_error], 0
    mov dword ptr [rip + picker_error], 0
    call picker_close
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    call settings_locale_refresh
    xor eax, eax
    jmp .picker_install_locale_done
.picker_install_locale_error:
    mov dword ptr [rip + picker_error], 5
    mov rax, -5
.picker_install_locale_done:
    pop r12
    ret
.size picker_install_locale, . - picker_install_locale

.type picker_import_xcompose, @function
picker_import_xcompose:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_import_xcompose_error
    mov r12, rax
    mov rdi, r12
    call compose_locale_import_xcompose
    test eax, eax
    jz .picker_import_xcompose_error
    lea rdi, [rip + compose_locale_installed_tag]
    call preferences_set_locale_tag
    test eax, eax
    jz .picker_import_xcompose_error
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    test eax, eax
    jz .picker_import_xcompose_error
    call preferences_save
    mov dword ptr [rip + locale_manager_error], 0
    mov dword ptr [rip + picker_error], 0
    call picker_close
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    call settings_locale_refresh
    xor eax, eax
    jmp .picker_import_xcompose_done
.picker_import_xcompose_error:
    mov dword ptr [rip + picker_error], 6
    mov rax, -5
.picker_import_xcompose_done:
    pop r12
    ret
.size picker_import_xcompose, . - picker_import_xcompose


.type picker_open_file, @function
picker_open_file:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_open_file_error
    mov r12, rax
    # Do not attempt to load a directory, symlink, or special file.
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_name_buffer]
    cmp byte ptr [rip + picker_name_buffer], '/'
    jne .picker_open_stat_relative
    mov edi, AT_FDCWD
    mov rsi, r12
.picker_open_stat_relative:
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_open_file_error
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFREG
    jne .picker_open_file_error
    mov rdi, r12
    call load_document_from_path
    test rax, rax
    js .picker_open_file_error
    call picker_commit_active_path
    call picker_close
    xor eax, eax
    jmp .picker_open_file_done
.picker_open_file_error:
    mov dword ptr [rip + picker_error], 2
    mov rax, -5
.picker_open_file_done:
    pop r12
    ret
.size picker_open_file, . - picker_open_file

.type picker_save_file, @function
picker_save_file:
    push r12
    call picker_build_target
    test rax, rax
    jz .picker_save_file_error
    mov r12, rax
    mov eax, SYS_newfstatat
    mov edi, dword ptr [rip + picker_dir_fd]
    lea rsi, [rip + picker_name_buffer]
    cmp byte ptr [rip + picker_name_buffer], '/'
    jne .picker_save_stat_relative
    mov rdi, AT_FDCWD
.picker_save_stat_relative:
    lea rdx, [rip + picker_stat_buffer]
    mov r10d, AT_SYMLINK_NOFOLLOW
    syscall
    test rax, rax
    js .picker_save_new_target
    mov eax, dword ptr [rip + picker_stat_buffer + 24]
    and eax, STAT_S_IFMT
    cmp eax, STAT_S_IFREG
    jne .picker_save_file_error
    mov dword ptr [rip + picker_overwrite_pending], 1
    xor eax, eax
    jmp .picker_save_file_done
.picker_save_new_target:
    cmp rax, -2
    jne .picker_save_file_error
    mov edi, 1
    call request_save_confirmation
    test rax, rax
    js .picker_save_file_error
    xor eax, eax
    jmp .picker_save_file_done
.picker_save_file_error:
    mov dword ptr [rip + picker_error], 3
    mov rax, -5
.picker_save_file_done:
    pop r12
    ret
.size picker_save_file, . - picker_save_file

.type picker_confirm_overwrite, @function
picker_confirm_overwrite:
    push r12
    cmp dword ptr [rip + history_export_mode], 0
    je .picker_confirm_overwrite_document
    lea rdi, [rip + picker_target_buffer]
    call history_export_to
    test rax, rax
    js .picker_overwrite_error
    call picker_close
    xor eax, eax
    jmp .picker_overwrite_done
.picker_confirm_overwrite_document:
    lea rdi, [rip + picker_target_buffer]
    call save_document_to_path
    test rax, rax
    js .picker_overwrite_error
    call picker_commit_active_path
    mov rdi, qword ptr [rip + current_file_path]
    call history_open
    call picker_close
    xor eax, eax
    jmp .picker_overwrite_done
.picker_overwrite_error:
    mov dword ptr [rip + picker_error], 3
    mov rax, -5
.picker_overwrite_done:
    pop r12
    ret
.size picker_confirm_overwrite, . - picker_confirm_overwrite

.type picker_select_locale, @function
picker_select_locale:
    push rbx
    push r12
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_select_locale_error
    mov eax, dword ptr [rip + picker_selected]
    test eax, eax
    js .picker_select_locale_error
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_select_locale_error
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 0
    jne .picker_select_locale_error
    call picker_copy_selected_name
    mov r12d, dword ptr [rip + picker_name_length]
    cmp r12d, 5
    jb .picker_select_locale_error
    lea rbx, [rip + picker_name_buffer]
    lea rdx, [rbx + r12 - 4]
    cmp byte ptr [rdx], '.'
    jne .picker_select_locale_error
    movzx eax, byte ptr [rdx + 1]
    or al, 0x20
    cmp al, 'n'
    jne .picker_select_locale_error
    movzx eax, byte ptr [rdx + 2]
    or al, 0x20
    cmp al, 'l'
    jne .picker_select_locale_error
    movzx eax, byte ptr [rdx + 3]
    or al, 0x20
    cmp al, 'p'
    jne .picker_select_locale_error
    mov byte ptr [rdx], 0
    mov rdi, rbx
    call preferences_set_locale_tag
    test eax, eax
    jz .picker_select_locale_error
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    test eax, eax
    jnz .picker_select_locale_loaded
    # Do not persist a selected file that failed pack validation.
    lea rdi, [rip + ui_locale_en_tag]
    call preferences_set_locale_tag
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    call compose_locale_load
    call preferences_save
    jmp .picker_select_locale_error
.picker_select_locale_loaded:
    call preferences_save
    mov dword ptr [rip + locale_manager_error], 0
    mov dword ptr [rip + picker_error], 0
    call picker_close
    xor eax, eax
    jmp .picker_select_locale_done
.picker_select_locale_error:
    mov dword ptr [rip + picker_error], 5
    mov rax, -5
.picker_select_locale_done:
    pop r12
    pop rbx
    ret
.size picker_select_locale, . - picker_select_locale

.type picker_confirm_action, @function
picker_confirm_action:
    cmp dword ptr [rip + picker_mode], 6
    je .picker_confirm_action_import_xcompose
    cmp dword ptr [rip + picker_mode], 5
    je .picker_confirm_action_select_locale
    cmp dword ptr [rip + picker_mode], 4
    je .picker_confirm_action_install
    cmp dword ptr [rip + picker_mode], 3
    je .picker_confirm_action_open
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_confirm_action_save
    jmp .picker_confirm_action_open
.picker_confirm_action_import_xcompose:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_confirm_action_error
    call picker_copy_selected_name
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    jmp picker_import_xcompose
.picker_confirm_action_select_locale:
    # Selection is resolved through the private locale directory by the loader.
    jmp picker_select_locale
.picker_confirm_action_install:
    # Install only a regular-file row selected from the filtered .nlp listing.
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_confirm_action_error
    call picker_copy_selected_name
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    jmp picker_install_locale
.picker_confirm_action_open:
    # When the directory list has focus, Open must operate on the explicitly
    # selected regular-file row. Never fall back to an old search-field value.
    cmp dword ptr [rip + picker_focus], 0
    je .picker_confirm_action_open_copy_selection
    # A literal name/path is allowed only while the Search field has focus.
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_confirm_action_error
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    cmp dword ptr [rip + picker_name_match], 1
    jne .picker_confirm_action_open_ready
.picker_confirm_action_open_copy_selection:
    call picker_copy_selected_name
.picker_confirm_action_open_ready:
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    cmp dword ptr [rip + picker_mode], 3
    je picker_load_font
    cmp dword ptr [rip + picker_mode], 4
    je picker_install_locale
    jmp picker_open_file
.picker_confirm_action_save:
    cmp dword ptr [rip + picker_name_length], 0
    jne .picker_confirm_action_save_ready
    call picker_copy_selected_name
.picker_confirm_action_save_ready:
    cmp dword ptr [rip + picker_name_length], 0
    je .picker_confirm_action_error
    jmp picker_save_file
.picker_confirm_action_error:
    cmp dword ptr [rip + picker_mode], 6
    jne .picker_confirm_action_error_check_pack
    mov dword ptr [rip + picker_error], 6
    jmp .picker_confirm_action_error_return
.picker_confirm_action_error_check_pack:
    cmp dword ptr [rip + picker_mode], 4
    jne .picker_confirm_action_error_save
    mov dword ptr [rip + picker_error], 5
    jmp .picker_confirm_action_error_return
.picker_confirm_action_error_save:
    mov dword ptr [rip + picker_error], 3
.picker_confirm_action_error_return:
    mov rax, -2
    ret
.size picker_confirm_action, . - picker_confirm_action

.type picker_move_selection, @function
picker_move_selection:
    sub rsp, 8
    mov eax, dword ptr [rip + picker_entry_count]
    test eax, eax
    jz .picker_move_done
    mov edx, dword ptr [rip + picker_selected]
    test edx, edx
    jns .picker_move_existing
    xor edx, edx
    jmp .picker_move_store
.picker_move_existing:
    add edx, edi
    cmp edx, 0
    jge .picker_move_upper
    xor edx, edx
    jmp .picker_move_store
.picker_move_upper:
    cmp edx, eax
    jb .picker_move_store
    lea edx, [rax - 1]
.picker_move_store:
    mov dword ptr [rip + picker_selected], edx
    call picker_copy_selected_name
    mov edx, dword ptr [rip + picker_selected]
    mov eax, dword ptr [rip + picker_scroll]
    cmp edx, eax
    jae .picker_move_check_bottom
    mov dword ptr [rip + picker_scroll], edx
    add rsp, 8
    ret
.picker_move_check_bottom:
    mov ecx, edx
    sub ecx, eax
    cmp ecx, PICKER_VISIBLE_ROWS
    jb .picker_move_done
    sub edx, PICKER_VISIBLE_ROWS - 1
    mov dword ptr [rip + picker_scroll], edx
.picker_move_done:
    add rsp, 8
    ret
.size picker_move_selection, . - picker_move_selection

# Clamp a relative row delta to the current directory's valid scroll range.
# EDI=delta rows. EAX=1 when the scroll offset changed, otherwise 0.
.type picker_scroll_by, @function
picker_scroll_by:
    mov eax, dword ptr [rip + picker_entry_count]
    sub eax, PICKER_VISIBLE_ROWS
    jg .picker_scroll_by_max_ready
    xor eax, eax
.picker_scroll_by_max_ready:
    mov edx, dword ptr [rip + picker_scroll]
    add edx, edi
    test edx, edx
    jns .picker_scroll_by_lower_ready
    xor edx, edx
.picker_scroll_by_lower_ready:
    cmp edx, eax
    jle .picker_scroll_by_clamped
    mov edx, eax
.picker_scroll_by_clamped:
    cmp edx, dword ptr [rip + picker_scroll]
    je .picker_scroll_by_unchanged
    mov dword ptr [rip + picker_scroll], edx
    mov eax, 1
    ret
.picker_scroll_by_unchanged:
    xor eax, eax
    ret
.size picker_scroll_by, . - picker_scroll_by

# Recompute scrollbar thumb geometry from the current entry count and offset.
# The track spans PICKER_TRACK_HEIGHT pixels; the thumb has a small minimum.
.type picker_scrollbar_geometry, @function
picker_scrollbar_geometry:
    push rbx
    mov ecx, dword ptr [rip + picker_entry_count]
    cmp ecx, PICKER_VISIBLE_ROWS
    ja .picker_scrollbar_has_overflow
    mov dword ptr [rip + picker_scroll_thumb_height], 0
    mov dword ptr [rip + picker_scroll_thumb_top], PICKER_TRACK_TOP
    pop rbx
    ret
.picker_scrollbar_has_overflow:
    mov eax, PICKER_TRACK_HEIGHT
    imul eax, PICKER_VISIBLE_ROWS
    xor edx, edx
    div ecx
    cmp eax, PICKER_TRACK_MIN_THUMB
    jae .picker_scrollbar_thumb_ready
    mov eax, PICKER_TRACK_MIN_THUMB
    jmp .picker_scrollbar_thumb_ready
.picker_scrollbar_thumb_ready:
    mov dword ptr [rip + picker_scroll_thumb_height], eax
    mov ebx, PICKER_TRACK_HEIGHT
    sub ebx, eax
    mov ecx, dword ptr [rip + picker_entry_count]
    sub ecx, PICKER_VISIBLE_ROWS
    jg .picker_scrollbar_position
    xor eax, eax
    jmp .picker_scrollbar_store
.picker_scrollbar_position:
    mov eax, dword ptr [rip + picker_scroll]
    imul eax, ebx
    xor edx, edx
    div ecx
    add eax, PICKER_TRACK_TOP
.picker_scrollbar_store:
    mov dword ptr [rip + picker_scroll_thumb_top], eax
    pop rbx
    ret
.size picker_scrollbar_geometry, . - picker_scrollbar_geometry

# ESI=pointer y. Convert a dragged thumb top into a clamped row offset.
.type picker_scrollbar_drag_to_y, @function
picker_scrollbar_drag_to_y:
    push rbx
    push r12
    push r13
    mov r12d, esi
    call picker_scrollbar_geometry
    mov eax, r12d
    sub eax, dword ptr [rip + picker_scroll_drag_offset]
    sub eax, PICKER_TRACK_TOP
    mov r13d, eax
    mov ebx, PICKER_TRACK_HEIGHT
    sub ebx, dword ptr [rip + picker_scroll_thumb_height]
    test r13d, r13d
    jns .picker_scroll_drag_lower_ready
    xor r13d, r13d
.picker_scroll_drag_lower_ready:
    cmp r13d, ebx
    jle .picker_scroll_drag_position_ready
    mov r13d, ebx
.picker_scroll_drag_position_ready:
    mov ecx, dword ptr [rip + picker_entry_count]
    sub ecx, PICKER_VISIBLE_ROWS
    jg .picker_scroll_drag_scale
    xor ecx, ecx
    mov dword ptr [rip + picker_scroll], 0
    jmp .picker_scroll_drag_done
.picker_scroll_drag_scale:
    test ebx, ebx
    jz .picker_scroll_drag_done
    mov eax, r13d
    imul eax, ecx
    xor edx, edx
    div ebx
    mov dword ptr [rip + picker_scroll], eax
.picker_scroll_drag_done:
    pop r13
    pop r12
    pop rbx
    ret
.size picker_scrollbar_drag_to_y, . - picker_scrollbar_drag_to_y

# Begin dragging or track-clicking the scrollbar at surface y=ESI.
.type picker_scrollbar_begin_drag, @function
picker_scrollbar_begin_drag:
    push r12
    cmp dword ptr [rip + picker_entry_count], PICKER_VISIBLE_ROWS
    jbe .picker_scrollbar_begin_no_overflow
    mov r12d, esi
    call picker_scrollbar_geometry
    mov eax, r12d
    cmp eax, dword ptr [rip + picker_scroll_thumb_top]
    jl .picker_scrollbar_center_thumb
    mov edx, dword ptr [rip + picker_scroll_thumb_top]
    add edx, dword ptr [rip + picker_scroll_thumb_height]
    cmp eax, edx
    jae .picker_scrollbar_center_thumb
    sub eax, dword ptr [rip + picker_scroll_thumb_top]
    jmp .picker_scrollbar_offset_ready
.picker_scrollbar_center_thumb:
    mov eax, dword ptr [rip + picker_scroll_thumb_height]
    shr eax, 1
.picker_scrollbar_offset_ready:
    mov dword ptr [rip + picker_scroll_drag_offset], eax
    mov dword ptr [rip + picker_scroll_drag], 1
    mov esi, r12d
    call picker_scrollbar_drag_to_y
    pop r12
    ret
.picker_scrollbar_begin_no_overflow:
    pop r12
    ret
.size picker_scrollbar_begin_drag, . - picker_scrollbar_begin_drag


.type picker_handle_key, @function
picker_handle_key:
    push rbx
    push r12
    sub rsp, 8
    mov ebx, edi
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .picker_key_normal
    cmp ebx, 1
    je .picker_key_overwrite_no
    mov edi, ebx
    call keycode_to_ascii
    cmp al, 'y'
    je .picker_key_overwrite_yes
    cmp al, 'Y'
    je .picker_key_overwrite_yes
    cmp al, 'n'
    je .picker_key_overwrite_no
    cmp al, 'N'
    je .picker_key_overwrite_no
    jmp .picker_key_done
.picker_key_overwrite_yes:
    mov dword ptr [rip + picker_overwrite_pending], 0
    call picker_confirm_overwrite
    jmp .picker_key_done
.picker_key_overwrite_no:
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_key_done

.picker_key_normal:
    cmp ebx, 1
    je .picker_key_cancel
    cmp ebx, 15
    je .picker_key_tab
    cmp ebx, 28
    je .picker_key_enter
    cmp ebx, 14
    je .picker_key_backspace
    cmp ebx, 111
    je .picker_key_delete
    cmp ebx, 103
    je .picker_key_up
    cmp ebx, 108
    je .picker_key_down
    cmp ebx, 104
    je .picker_key_page_up
    cmp ebx, 109
    je .picker_key_page_down
    cmp ebx, 102
    je .picker_key_home
    cmp ebx, 107
    je .picker_key_end
    cmp ebx, 105
    je .picker_key_left
    cmp ebx, 106
    je .picker_key_right
    cmp dword ptr [rip + ctrl_down], 0
    je .picker_key_insert_character
    # Ctrl+A selects the contents of the currently focused text field.
    mov edi, ebx
    call keycode_to_ascii
    cmp al, 'a'
    je .picker_key_select_all
    cmp al, 'A'
    je .picker_key_select_all
    jmp .picker_key_done
.picker_key_select_all:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_select_all_set
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_key_done
.picker_key_select_all_set:
    mov dword ptr [rip + picker_edit_select_all], 1
    jmp .picker_key_done

.picker_key_insert_character:
    mov edi, ebx
    call keycode_to_ascii
    test eax, eax
    jz .picker_key_done
    mov r12d, eax
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_insert_dispatch
    # Typing from the list starts a fresh filename search.
    mov dword ptr [rip + picker_focus], 2
    mov dword ptr [rip + picker_name_length], 0
    mov dword ptr [rip + picker_name_cursor], 0
    mov dword ptr [rip + picker_name_match], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    mov byte ptr [rip + picker_name_buffer], 0
    mov dword ptr [rip + picker_selected], -1
.picker_key_insert_dispatch:
    mov edi, r12d
    call picker_edit_insert_byte
    jmp .picker_key_done

.picker_key_cancel:
    call picker_close
    jmp .picker_key_done
.picker_key_tab:
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_key_tab_cycle
    cmp dword ptr [rip + picker_suggestion_count], 0
    je .picker_key_tab_cycle
    call picker_accept_suggestion
    jmp .picker_key_done
.picker_key_tab_cycle:
    mov eax, dword ptr [rip + picker_focus]
    inc eax
    cmp eax, 3
    jb .picker_key_tab_store
    xor eax, eax
.picker_key_tab_store:
    mov dword ptr [rip + picker_focus], eax
    jmp .picker_key_done
.picker_key_enter:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_enter_path
    cmp dword ptr [rip + picker_focus], 2
    je .picker_key_enter_action
    mov eax, dword ptr [rip + picker_selected]
    test eax, eax
    js .picker_key_enter_action
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_key_enter_action
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    je .picker_key_enter_directory
    cmp dword ptr [rip + picker_mode], 3
    je .picker_key_enter_font_file
    cmp dword ptr [rip + picker_mode], 4
    je .picker_key_enter_install_file
    cmp dword ptr [rip + picker_mode], 5
    je .picker_key_enter_select_locale
    cmp dword ptr [rip + picker_mode], 6
    je .picker_key_enter_import_xcompose
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_key_enter_action
    call picker_open_file
    jmp .picker_key_done
.picker_key_enter_font_file:
    call picker_load_font
    jmp .picker_key_done
.picker_key_enter_install_file:
    call picker_confirm_action
    jmp .picker_key_done
.picker_key_enter_select_locale:
    call picker_confirm_action
    jmp .picker_key_done
.picker_key_enter_import_xcompose:
    call picker_confirm_action
    jmp .picker_key_done
.picker_key_enter_directory:
    lea rdi, [rdx + 4]
    call picker_enter_directory
    jmp .picker_key_done
.picker_key_enter_path:
    call picker_navigate_path
    jmp .picker_key_done
.picker_key_enter_action:
    call picker_confirm_action
    jmp .picker_key_done

.picker_key_backspace:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_backspace_field
    call picker_go_parent
    jmp .picker_key_done
.picker_key_backspace_field:
    mov edi, 1
    call picker_edit_delete_byte
    jmp .picker_key_done
.picker_key_delete:
    cmp dword ptr [rip + picker_focus], 0
    je .picker_key_done
    xor edi, edi
    call picker_edit_delete_byte
    jmp .picker_key_done
.picker_key_up:
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_key_up_list
    mov edi, -1
    call picker_cycle_suggestion
    jmp .picker_key_done
.picker_key_up_list:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, -1
    call picker_move_selection
    jmp .picker_key_done
.picker_key_down:
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_key_down_list
    mov edi, 1
    call picker_cycle_suggestion
    jmp .picker_key_done
.picker_key_down_list:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, 1
    call picker_move_selection
    jmp .picker_key_done
.picker_key_page_up:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, -PICKER_VISIBLE_ROWS
    call picker_move_selection
    jmp .picker_key_done
.picker_key_page_down:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_done
    mov edi, PICKER_VISIBLE_ROWS
    call picker_move_selection
    jmp .picker_key_done
.picker_key_home:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_home_path
    cmp dword ptr [rip + picker_focus], 2
    je .picker_key_home_name
    call picker_go_home
    jmp .picker_key_done
.picker_key_home_path:
    mov dword ptr [rip + picker_path_cursor], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_home_name:
    mov dword ptr [rip + picker_name_cursor], 0
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_end:
    cmp dword ptr [rip + picker_focus], 1
    je .picker_key_end_path
    cmp dword ptr [rip + picker_focus], 2
    je .picker_key_end_name
    jmp .picker_key_done
.picker_key_end_path:
    mov eax, dword ptr [rip + picker_path_length]
    mov dword ptr [rip + picker_path_cursor], eax
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_end_name:
    mov eax, dword ptr [rip + picker_name_length]
    mov dword ptr [rip + picker_name_cursor], eax
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_left:
    cmp dword ptr [rip + picker_focus], 0
    je .picker_key_left_list
    cmp dword ptr [rip + picker_focus], 1
    jne .picker_key_left_name
    cmp dword ptr [rip + picker_path_cursor], 0
    je .picker_key_done
    dec dword ptr [rip + picker_path_cursor]
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_left_name:
    cmp dword ptr [rip + picker_name_cursor], 0
    je .picker_key_done
    dec dword ptr [rip + picker_name_cursor]
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_left_list:
    call picker_go_parent
    jmp .picker_key_done
.picker_key_right:
    cmp dword ptr [rip + picker_focus], 0
    jne .picker_key_right_field
    mov eax, dword ptr [rip + picker_selected]
    test eax, eax
    js .picker_key_done
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_key_done
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    jne .picker_key_done
    lea rdi, [rdx + 4]
    call picker_enter_directory
    jmp .picker_key_done
.picker_key_right_field:
    cmp dword ptr [rip + picker_focus], 1
    jne .picker_key_right_name
    mov eax, dword ptr [rip + picker_path_cursor]
    cmp eax, dword ptr [rip + picker_path_length]
    jae .picker_key_done
    inc dword ptr [rip + picker_path_cursor]
    mov dword ptr [rip + picker_edit_select_all], 0
    jmp .picker_key_done
.picker_key_right_name:
    mov eax, dword ptr [rip + picker_name_cursor]
    cmp eax, dword ptr [rip + picker_name_length]
    jae .picker_key_done
    inc dword ptr [rip + picker_name_cursor]
    mov dword ptr [rip + picker_edit_select_all], 0
.picker_key_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size picker_handle_key, . - picker_handle_key

.type picker_handle_pointer, @function
picker_handle_pointer:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r14d, edx
    # Ignore clicks outside the fitted modal. Convert accepted positions back
    # into the original design-space coordinates used by the control map.
    mov eax, edi
    cmp eax, dword ptr [rip + picker_panel_x]
    jl .picker_pointer_done
    mov ecx, dword ptr [rip + picker_panel_x]
    add ecx, dword ptr [rip + picker_panel_width]
    cmp eax, ecx
    jae .picker_pointer_done
    mov eax, esi
    cmp eax, dword ptr [rip + picker_panel_y]
    jl .picker_pointer_done
    mov ecx, dword ptr [rip + picker_panel_y]
    add ecx, dword ptr [rip + picker_panel_height]
    cmp eax, ecx
    jae .picker_pointer_done
    mov eax, edi
    sub eax, dword ptr [rip + picker_panel_x]
    imul eax, 720
    cdq
    idiv dword ptr [rip + picker_panel_width]
    add eax, 40
    mov r12d, eax
    mov eax, esi
    sub eax, dword ptr [rip + picker_panel_y]
    imul eax, 408
    cdq
    idiv dword ptr [rip + picker_panel_height]
    add eax, 36
    mov r13d, eax
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .picker_pointer_normal
    # Confirm and cancel zones in the overwrite prompt.
    cmp r13d, 232
    jb .picker_pointer_done
    cmp r13d, 272
    jae .picker_pointer_done
    cmp r12d, 600
    jb .picker_pointer_done
    cmp r12d, 672
    jb .picker_pointer_overwrite_no
    cmp r12d, 752
    jae .picker_pointer_done
    jmp .picker_pointer_overwrite_yes
.picker_pointer_overwrite_no:
    mov dword ptr [rip + picker_overwrite_pending], 0
    mov dword ptr [rip + picker_error], 0
    jmp .picker_pointer_done
.picker_pointer_overwrite_yes:
    mov dword ptr [rip + picker_overwrite_pending], 0
    call picker_confirm_overwrite
    jmp .picker_pointer_done

.picker_pointer_normal:
    # Footer actions.
    cmp r13d, 396
    jb .picker_pointer_controls
    cmp r13d, 432
    jae .picker_pointer_done
    cmp r12d, 600
    jb .picker_pointer_done
    cmp r12d, 672
    jb .picker_pointer_cancel
    cmp r12d, 752
    jae .picker_pointer_done
    call picker_confirm_action
    jmp .picker_pointer_done
.picker_pointer_cancel:
    call picker_close
    jmp .picker_pointer_done

.picker_pointer_controls:
    # Editable location field.
    cmp r13d, 80
    jb .picker_pointer_toolbar
    cmp r13d, 108
    jae .picker_pointer_toolbar
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 744
    jae .picker_pointer_done
    mov dword ptr [rip + picker_focus], 1
    mov dword ptr [rip + picker_edit_select_all], 0
    lea rdi, [rip + picker_path_buffer]
    mov eax, dword ptr [rip + picker_path_view_start]
    add rdi, rax
    mov esi, dword ptr [rip + picker_path_length]
    sub esi, eax
    mov edx, r12d
    sub edx, 64
    test edx, edx
    jns .picker_pointer_path_target_ready
    xor edx, edx
.picker_pointer_path_target_ready:
    call picker_hit_test_ascii
    add eax, dword ptr [rip + picker_path_view_start]
    cmp eax, dword ptr [rip + picker_path_length]
    jbe .picker_pointer_path_cursor_store
    mov eax, dword ptr [rip + picker_path_length]
.picker_pointer_path_cursor_store:
    mov dword ptr [rip + picker_path_cursor], eax
    jmp .picker_pointer_done

.picker_pointer_toolbar:
    cmp r13d, 112
    jb .picker_pointer_list
    cmp r13d, 138
    jae .picker_pointer_list
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 104
    jb .picker_pointer_up
    cmp r12d, 160
    jb .picker_pointer_home
    cmp r12d, 600
    jb .picker_pointer_list
    cmp r12d, 740
    jae .picker_pointer_list
    # Both the checkbox and its label are clickable.
    xor dword ptr [rip + picker_show_hidden], 1
    call picker_scan_directory
    jmp .picker_pointer_done
.picker_pointer_up:
    call picker_go_parent
    jmp .picker_pointer_done
.picker_pointer_home:
    call picker_go_home
    jmp .picker_pointer_done

.picker_pointer_list:
    # The autocomplete popup overlays the lower part of the listing. Its rows
    # accept a single click and fill the filename field with that candidate.
    cmp dword ptr [rip + picker_focus], 2
    jne .picker_pointer_list_rows_area
    cmp dword ptr [rip + picker_suggestion_count], 0
    je .picker_pointer_list_rows_area
    cmp r13d, PICKER_SUGGESTION_TOP
    jb .picker_pointer_list_rows_area
    cmp r13d, PICKER_SUGGESTION_BOTTOM
    jae .picker_pointer_list_rows_area
    cmp r12d, 168
    jb .picker_pointer_list_rows_area
    cmp r12d, 608
    jae .picker_pointer_list_rows_area
    mov eax, r13d
    sub eax, PICKER_SUGGESTION_TOP
    xor edx, edx
    mov ecx, PICKER_SUGGESTION_ROW_HEIGHT
    div ecx
    cmp eax, dword ptr [rip + picker_suggestion_count]
    jae .picker_pointer_done
    mov dword ptr [rip + picker_suggestion_selected], eax
    call picker_accept_suggestion
    jmp .picker_pointer_done
.picker_pointer_list_rows_area:
    cmp r13d, 144
    jb .picker_pointer_name
    cmp r13d, 352
    jae .picker_pointer_name
    cmp r12d, 56
    jb .picker_pointer_done
    cmp r12d, 744
    jae .picker_pointer_done
    cmp dword ptr [rip + picker_entry_count], PICKER_VISIBLE_ROWS
    jbe .picker_pointer_list_rows
    cmp r12d, 720
    jb .picker_pointer_list_rows
    mov esi, r13d
    call picker_scrollbar_begin_drag
    jmp .picker_pointer_done
.picker_pointer_list_rows:
    mov eax, r13d
    sub eax, PICKER_TRACK_TOP
    xor edx, edx
    mov ecx, PICKER_ROW_HEIGHT
    div ecx
    add eax, dword ptr [rip + picker_scroll]
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_pointer_done
    mov dword ptr [rip + picker_selected], eax
    mov dword ptr [rip + picker_focus], 0
    call picker_copy_selected_name
    # Directories are navigated on double-click only.
    mov eax, dword ptr [rip + picker_selected]
    cmp eax, dword ptr [rip + picker_last_click_index]
    jne .picker_pointer_record_click
    mov ecx, r14d
    sub ecx, dword ptr [rip + picker_last_click_time]
    cmp ecx, 450
    ja .picker_pointer_record_click
    cmp eax, dword ptr [rip + picker_entry_count]
    jae .picker_pointer_record_click
    imul eax, PICKER_ENTRY_SIZE
    lea rdx, [rip + picker_entries]
    add rdx, rax
    cmp byte ptr [rdx], 1
    je .picker_pointer_double_directory
    cmp dword ptr [rip + picker_mode], 3
    je .picker_pointer_load_font
    cmp dword ptr [rip + picker_mode], 4
    je .picker_pointer_install_pack
    cmp dword ptr [rip + picker_mode], 5
    je .picker_pointer_select_locale
    cmp dword ptr [rip + picker_mode], 6
    je .picker_pointer_import_xcompose
    cmp dword ptr [rip + picker_mode], 1
    jne .picker_pointer_record_click
    call picker_open_file
    jmp .picker_pointer_done
.picker_pointer_load_font:
    call picker_load_font
    jmp .picker_pointer_done
.picker_pointer_install_pack:
    call picker_confirm_action
    jmp .picker_pointer_done
.picker_pointer_select_locale:
    call picker_confirm_action
    jmp .picker_pointer_done
.picker_pointer_import_xcompose:
    call picker_confirm_action
    jmp .picker_pointer_done
.picker_pointer_double_directory:
    lea rdi, [rdx + 4]
    call picker_enter_directory
    jmp .picker_pointer_done
.picker_pointer_record_click:
    mov eax, dword ptr [rip + picker_selected]
    mov dword ptr [rip + picker_last_click_index], eax
    mov dword ptr [rip + picker_last_click_time], r14d
    jmp .picker_pointer_done

.picker_pointer_name:
    cmp r13d, 360
    jb .picker_pointer_done
    cmp r13d, 390
    jae .picker_pointer_done
    cmp r12d, 168
    jb .picker_pointer_done
    cmp r12d, 608
    jae .picker_pointer_done
    mov dword ptr [rip + picker_focus], 2
    mov dword ptr [rip + picker_edit_select_all], 0
    lea rdi, [rip + picker_name_buffer]
    mov eax, dword ptr [rip + picker_name_view_start]
    add rdi, rax
    mov esi, dword ptr [rip + picker_name_length]
    sub esi, eax
    mov edx, r12d
    sub edx, 176
    test edx, edx
    jns .picker_pointer_name_target_ready
    xor edx, edx
.picker_pointer_name_target_ready:
    call picker_hit_test_ascii
    add eax, dword ptr [rip + picker_name_view_start]
    cmp eax, dword ptr [rip + picker_name_length]
    jbe .picker_pointer_name_cursor_store
    mov eax, dword ptr [rip + picker_name_length]
.picker_pointer_name_cursor_store:
    mov dword ptr [rip + picker_name_cursor], eax
.picker_pointer_done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_handle_pointer, . - picker_handle_pointer

.type set_active_document_name, @function
set_active_document_name:
    lea rdi, [rip + active_document_name]
    mov rsi, r12
    mov r8, r12
.set_name_find_end:
    mov al, byte ptr [rsi]
    test al, al
    jz .set_name_copy
    cmp al, '/'
    jne .set_name_next
    lea r8, [rsi + 1]
.set_name_next:
    inc rsi
    jmp .set_name_find_end
.set_name_copy:
    xor ecx, ecx
.set_name_copy_loop:
    cmp ecx, 15
    jae .set_name_done
    mov al, byte ptr [r8 + rcx]
    test al, al
    jz .set_name_done
    mov byte ptr [rdi + rcx], al
    inc ecx
    jmp .set_name_copy_loop
.set_name_done:
    mov byte ptr [rdi + rcx], 0
    ret
.size set_active_document_name, . - set_active_document_name

# Save the active document. Untitled is routed to the in-window Save As
# prompt by its caller; this routine deliberately refuses a null path.
.type save_document_file, @function
save_document_file:
    mov rdi, qword ptr [rip + current_file_path]
    test rdi, rdi
    jz .save_file_no_path
    jmp save_document_to_path
.save_file_no_path:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -2
    ret
.size save_document_file, . - save_document_file

# Atomically replace PATH with the current document. The temporary is created
# in the destination directory (exclusive create), fully written, fsynced,
# closed, then renamed over the target. A failed write never truncates target.
.type save_document_to_path, @function
save_document_to_path:
    mov qword ptr [rip + save_target_path], rdi
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    test r12, r12
    jz .save_atomic_error
    cmp byte ptr [r12], 0
    je .save_atomic_error

    # Inspect the current target before creating the replacement. For a
    # regular file, retain its permission/special bits instead of replacing a
    # private 0600 file with the temporary's default 0644 mode. ENOENT means
    # Save As is creating a new file, which continues to use 0644 & umask.
    mov dword ptr [rip + save_target_mode_valid], 0
.save_atomic_stat_retry:
    mov eax, SYS_newfstatat
    mov edi, AT_FDCWD
    mov rsi, r12
    lea rdx, [rip + save_stat_buffer]
    xor r10d, r10d             # follow symlinks, matching normal stat()
    syscall
    cmp rax, -4
    je .save_atomic_stat_retry
    test rax, rax
    jz .save_atomic_have_target
    cmp rax, -2                # ENOENT: new file (or dangling symlink)
    jne .save_atomic_error
    jmp .save_atomic_target_mode_ready
.save_atomic_have_target:
    mov eax, dword ptr [rip + save_stat_buffer + 24]
    mov edx, eax
    and edx, STAT_S_IFMT
    cmp edx, STAT_S_IFREG
    jne .save_atomic_error     # never atomically replace a device, FIFO, or directory
    and eax, 0x0fff            # rwx plus setuid/setgid/sticky permission bits
    mov dword ptr [rip + save_target_mode], eax
    mov dword ptr [rip + save_target_mode_valid], 1
.save_atomic_target_mode_ready:

    # Keep the temporary beside the destination so renameat stays on one FS.
    xor r14d, r14d
    mov rsi, r12
.save_atomic_scan_path:
    mov al, byte ptr [rsi]
    test al, al
    jz .save_atomic_path_scanned
    inc rsi
    cmp al, '/'
    jne .save_atomic_scan_path
    mov r14, rsi
    sub r14, r12
    jmp .save_atomic_scan_path
.save_atomic_path_scanned:
    cmp r14d, PATH_CAPACITY - 32
    ja .save_atomic_error
    lea rdi, [rip + temp_path_buffer]
    mov rsi, r12
    mov rcx, r14
    rep movsb
    mov r13, rdi
    lea rsi, [rip + temp_prefix]
    mov ecx, temp_prefix_end - temp_prefix
    rep movsb
    mov r13, rdi

    mov eax, SYS_getpid
    syscall
    test rax, rax
    js .save_atomic_error
    lea rdi, [rip + temp_pid_digits + 15]
    mov byte ptr [rdi], 0
    mov ecx, 10
.save_atomic_pid_digits:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rdi
    mov byte ptr [rdi], dl
    test eax, eax
    jnz .save_atomic_pid_digits
    mov rsi, rdi
    mov rdi, r13
    lea rdx, [rip + temp_pid_digits + 15]
    sub rdx, rsi
    mov rcx, rdx
    rep movsb
    mov r13, rdi
    lea rsi, [rip + temp_suffix]
    mov ecx, temp_suffix_end - temp_suffix
    rep movsb
    mov byte ptr [rdi], 0

    mov eax, SYS_openat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    mov edx, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC
    mov r10d, 0644
    syscall
    test rax, rax
    js .save_atomic_error
    mov ebx, eax
    # Write the prefix before the gap, then the suffix after it. The physical
    # gap is never serialized into the file.
    mov r12, qword ptr [rip + doc_buffer]
    mov ebp, dword ptr [rip + doc_gap_start]
    xor r15d, r15d
.save_atomic_write:
    test ebp, ebp
    jnz .save_atomic_issue_write
    test r15d, r15d
    jnz .save_atomic_fsync
    mov r15d, 1
    mov r12, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add r12, rax
    mov ebp, dword ptr [rip + doc_length]
    sub ebp, dword ptr [rip + doc_gap_start]
    jmp .save_atomic_write
.save_atomic_issue_write:
    mov eax, SYS_write
    mov edi, ebx
    mov rsi, r12
    mov edx, ebp
    syscall
    test rax, rax
    jg .save_atomic_advance
    cmp rax, -4
    je .save_atomic_issue_write
    jmp .save_atomic_close_error
.save_atomic_advance:
    add r12, rax
    sub ebp, eax
    jmp .save_atomic_write
.save_atomic_fsync:
    # Apply the old target mode after the final write (writes can clear
    # setuid/setgid bits) but before fsync and the atomic rename.
    cmp dword ptr [rip + save_target_mode_valid], 0
    je .save_atomic_file_fsync
.save_atomic_fchmod_retry:
    mov eax, SYS_fchmod
    mov edi, ebx
    mov esi, dword ptr [rip + save_target_mode]
    syscall
    cmp rax, -4
    je .save_atomic_fchmod_retry
    test rax, rax
    js .save_atomic_close_error
.save_atomic_file_fsync:
    mov eax, SYS_fsync
    mov edi, ebx
    syscall
    cmp rax, -4
    je .save_atomic_fsync
    test rax, rax
    js .save_atomic_close_error
    mov eax, SYS_close
    mov edi, ebx
    syscall
    test rax, rax
    js .save_atomic_unlink_error
    mov ebx, -1

    mov eax, SYS_renameat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    mov edx, AT_FDCWD
    mov r10, qword ptr [rip + save_target_path]
    syscall
    test rax, rax
    js .save_atomic_unlink_error
    mov dword ptr [rip + doc_save_error], 0
    call history_mark_saved
    xor eax, eax
    jmp .save_atomic_return

.save_atomic_close_error:
    mov eax, SYS_close
    mov edi, ebx
    syscall
    mov ebx, -1
.save_atomic_unlink_error:
    mov eax, SYS_unlinkat
    mov edi, AT_FDCWD
    lea rsi, [rip + temp_path_buffer]
    xor edx, edx
    syscall
    jmp .save_atomic_error
.save_atomic_error:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -5
.save_atomic_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size save_document_to_path, . - save_document_to_path

# Open a replacement document into a separate growable staging mapping first.
# The active document/path/tab are committed only after EOF and successful close.
.type load_document_from_path, @function
load_document_from_path:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    test r12, r12
    jz .load_path_error
    cmp byte ptr [r12], 0
    je .load_path_error
    mov eax, SYS_openat
    mov edi, AT_FDCWD
    mov rsi, r12
    xor edx, edx
    xor r10d, r10d
    syscall
    test rax, rax
    js .load_path_error
    mov ebx, eax
    xor r13d, r13d
.load_path_read:
    mov eax, dword ptr [rip + load_capacity]
    cmp r13d, eax
    jae .load_path_probe
    mov eax, SYS_read
    mov edi, ebx
    mov rsi, qword ptr [rip + load_buffer]
    add rsi, r13
    mov edx, dword ptr [rip + load_capacity]
    sub edx, r13d
    syscall
    test rax, rax
    jg .load_path_advance
    je .load_path_close
    cmp rax, -4
    je .load_path_read
    jmp .load_path_close_error
.load_path_advance:
    add r13, rax
    jmp .load_path_read
.load_path_probe:
    mov eax, SYS_read
    mov edi, ebx
    lea rsi, [rip + file_probe_byte]
    mov edx, 1
    syscall
    test rax, rax
    jg .load_path_grow_for_probe
    je .load_path_close
    cmp rax, -4
    je .load_path_probe
    jmp .load_path_close_error
.load_path_grow_for_probe:
    call load_buffer_grow
    test rax, rax
    js .load_path_close_error
    mov rdx, qword ptr [rip + load_buffer]
    mov al, byte ptr [rip + file_probe_byte]
    mov byte ptr [rdx + r13], al
    inc r13
    jmp .load_path_read
.load_path_close:
    mov eax, SYS_close
    mov edi, ebx
    syscall
    test rax, rax
    js .load_path_error

    # The staging mapping is already a contiguous document-sized store.
    # Swap mappings only after EOF and close succeed: this keeps Open atomic
    # while avoiding a second full-size memory copy for large documents.
    mov rax, qword ptr [rip + doc_buffer]
    mov rdx, qword ptr [rip + load_buffer]
    mov qword ptr [rip + doc_buffer], rdx
    mov qword ptr [rip + load_buffer], rax
    mov eax, dword ptr [rip + doc_capacity]
    mov edx, dword ptr [rip + load_capacity]
    mov dword ptr [rip + doc_capacity], edx
    mov dword ptr [rip + load_capacity], eax
    mov dword ptr [rip + doc_length], r13d
    mov dword ptr [rip + doc_line_index_valid], 0
    mov dword ptr [rip + doc_line_count], 0
    mov dword ptr [rip + doc_gap_start], r13d
    mov eax, dword ptr [rip + doc_capacity]
    mov dword ptr [rip + doc_gap_end], eax
    mov dword ptr [rip + doc_cursor], 0
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_selection_active], 0
    mov dword ptr [rip + doc_selection_anchor], 0
    mov dword ptr [rip + doc_selection_start], 0
    mov dword ptr [rip + doc_selection_end], 0
    mov dword ptr [rip + doc_save_error], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_storage_error], 0
    mov rdi, r12
    call history_open
    mov dword ptr [rip + history_tab_open], 0
    xor eax, eax
    jmp .load_path_return
.load_path_close_error:
    mov eax, SYS_close
    mov edi, ebx
    syscall
.load_path_error:
    mov dword ptr [rip + doc_open_error], 1
    mov rax, -5
.load_path_return:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size load_document_from_path, . - load_document_from_path


.type start_open_prompt, @function
start_open_prompt:
    mov edi, 1
    jmp picker_start
.size start_open_prompt, . - start_open_prompt

.type start_save_as_prompt, @function
start_save_as_prompt:
    mov edi, 2
    jmp picker_start
.size start_save_as_prompt, . - start_save_as_prompt

.type begin_path_prompt, @function
begin_path_prompt:
    mov dword ptr [rip + path_prompt_mode], edi
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    ret
.size begin_path_prompt, . - begin_path_prompt

.type cancel_path_prompt, @function
cancel_path_prompt:
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    ret
.size cancel_path_prompt, . - cancel_path_prompt

# Commit the entered path only after the corresponding file operation succeeds.
.type commit_path_prompt, @function
commit_path_prompt:
    push r12
    lea rsi, [rip + path_prompt_buffer]
    lea rdi, [rip + current_path_buffer]
    mov ecx, dword ptr [rip + path_prompt_length]
    rep movsb
    mov byte ptr [rdi], 0
    lea r12, [rip + current_path_buffer]
    mov qword ptr [rip + current_file_path], r12
    call set_active_document_name
    mov dword ptr [rip + path_prompt_mode], 0
    mov dword ptr [rip + path_prompt_length], 0
    mov byte ptr [rip + path_prompt_buffer], 0
    mov dword ptr [rip + doc_open_error], 0
    mov dword ptr [rip + doc_save_error], 0
    pop r12
    ret
.size commit_path_prompt, . - commit_path_prompt

.type confirm_path_prompt, @function
confirm_path_prompt:
    push rbp
    cmp dword ptr [rip + path_prompt_length], 0
    je .confirm_path_error
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .confirm_path_save
    lea rdi, [rip + path_prompt_buffer]
    call load_document_from_path
    test rax, rax
    js .confirm_path_failed
    call commit_path_prompt
    xor eax, eax
    pop rbp
    ret
.confirm_path_save:
    mov edi, 2
    call request_save_confirmation
    test rax, rax
    js .confirm_path_failed
    pop rbp
    ret
.confirm_path_error:
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .confirm_path_save_error
    mov dword ptr [rip + doc_open_error], 1
    mov rax, -2
    pop rbp
    ret
.confirm_path_save_error:
    mov dword ptr [rip + doc_save_error], 1
    mov rax, -2
    pop rbp
    ret
.confirm_path_failed:
    mov rax, -5
    pop rbp
    ret
.size confirm_path_prompt, . - confirm_path_prompt

.type save_current_document, @function
save_current_document:
    cmp qword ptr [rip + current_file_path], 0
    je .save_current_prompt
    xor edi, edi
    jmp request_save_confirmation
.save_current_prompt:
    jmp start_save_as_prompt
.size save_current_document, . - save_current_document

# EDI=0 current document, 1 picker target, 2 path-prompt target.
# Return 1 when a modal is pending, otherwise the save result.
.type request_save_confirmation, @function
request_save_confirmation:
    mov dword ptr [rip + save_confirm_action], edi
    cmp dword ptr [rip + save_confirm_enabled], 0
    je confirm_save_action
    mov dword ptr [rip + save_confirm_open], 1
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov eax, 1
    ret
.size request_save_confirmation, . - request_save_confirmation

.type cancel_save_confirmation, @function
cancel_save_confirmation:
    mov dword ptr [rip + save_confirm_open], 0
    mov dword ptr [rip + save_confirm_action], 0
    xor eax, eax
    ret
.size cancel_save_confirmation, . - cancel_save_confirmation

.type request_locale_remove_confirmation, @function
request_locale_remove_confirmation:
    mov dword ptr [rip + save_confirm_action], 3
    mov dword ptr [rip + save_confirm_open], 1
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    mov eax, 1
    ret
.size request_locale_remove_confirmation, . - request_locale_remove_confirmation

.type confirm_save_action, @function
confirm_save_action:
    push rbx
    mov ebx, dword ptr [rip + save_confirm_action]
    mov dword ptr [rip + save_confirm_open], 0
    mov dword ptr [rip + save_confirm_action], 0
    test ebx, ebx
    jz .Lconfirm_save_current
    cmp ebx, 1
    je .Lconfirm_save_picker
    cmp ebx, 2
    je .Lconfirm_save_path_prompt
    cmp ebx, 3
    je .Lconfirm_remove_locale_pack
    mov rax, -22
    jmp .Lconfirm_save_done
.Lconfirm_save_current:
    call save_document_file
    jmp .Lconfirm_save_done
.Lconfirm_save_picker:
    cmp dword ptr [rip + history_export_mode], 0
    je .Lconfirm_save_picker_document
    lea rdi, [rip + picker_target_buffer]
    call history_export_to
    test rax, rax
    js .Lconfirm_save_picker_error
    call picker_close
    xor eax, eax
    jmp .Lconfirm_save_done
.Lconfirm_save_picker_document:
    lea rdi, [rip + picker_target_buffer]
    call save_document_to_path
    test rax, rax
    js .Lconfirm_save_picker_error
    call picker_commit_active_path
    mov rdi, qword ptr [rip + current_file_path]
    call history_open
    call picker_close
    xor eax, eax
    jmp .Lconfirm_save_done
.Lconfirm_save_picker_error:
    mov dword ptr [rip + picker_error], 3
    jmp .Lconfirm_save_done
.Lconfirm_save_path_prompt:
    lea rdi, [rip + path_prompt_buffer]
    call save_document_to_path
    test rax, rax
    js .Lconfirm_save_path_error
    call commit_path_prompt
    mov rdi, qword ptr [rip + current_file_path]
    call history_open
    xor eax, eax
    jmp .Lconfirm_save_done
.Lconfirm_remove_locale_pack:
    mov rdi, qword ptr [rip + preferences_locale_ptr]
    test rdi, rdi
    jnz .Lconfirm_remove_locale_pack_tag_ready
    lea rdi, [rip + compose_locale_current_tag]
.Lconfirm_remove_locale_pack_tag_ready:
    call compose_locale_remove_pack
    test eax, eax
    jz .Lconfirm_remove_locale_pack_error
    mov dword ptr [rip + locale_manager_error], 0
    lea rdi, [rip + ui_locale_en_tag]
    call preferences_set_locale_tag
    call preferences_save
    mov dword ptr [rip + settings_locale_dropdown_open], 0
    call settings_locale_refresh
.Lconfirm_remove_locale_pack_done:
    jmp .Lconfirm_save_done
.Lconfirm_remove_locale_pack_error:
    mov dword ptr [rip + locale_manager_error], 1
    mov dword ptr [rip + settings_menu_open], 1
    mov rax, -2
    jmp .Lconfirm_save_done
.Lconfirm_save_path_error:
    mov dword ptr [rip + doc_save_error], 1
.Lconfirm_save_done:
    pop rbx
    ret
.size confirm_save_action, . - confirm_save_action

.section .rodata
temp_prefix: .ascii ".nekoedit-"
temp_prefix_end:
temp_suffix: .ascii ".tmp"
temp_suffix_end:
ui_find_title: .asciz "FIND"
ui_replace_title: .asciz "FIND / REPLACE"
ui_find_label: .asciz "Find"
ui_replace_label: .asciz "Replace"
ui_find_prev_label: .asciz "Prev"
ui_find_next_label: .asciz "Next"
ui_replace_one_label: .asciz "Replace"
ui_replace_all_label: .asciz "All"
ui_find_close_label: .asciz "Close"
ui_find_empty_label: .asciz "Enter a search term"
ui_find_match_label: .asciz "Match found"
ui_find_none_label: .asciz "No match"
ui_find_replaced_label: .asciz "Replacement complete"
ui_find_all_label: .asciz "Replace All complete"
.section .text

# Print a NUL-terminated string to stderr. Input: RSI = string.
.type write_stderr_cstr, @function
write_stderr_cstr:
    push rbx
    push r12
    push r13
    mov r12, rsi
    mov rdi, rsi
    xor eax, eax
    mov rcx, -1
    repne scasb
    not rcx
    dec rcx
    mov r13, rcx
    mov edi, 2
    mov rsi, r12
    mov rdx, r13
    call linux_write_all
    mov edi, 2
    lea rsi, [rip + newline_text]
    mov edx, 1
    call linux_write_all
    pop r13
    pop r12
    pop rbx
    ret
.size write_stderr_cstr, . - write_stderr_cstr

# Print an unsigned 32-bit integer in decimal to stderr. Input: EDI=value.
# env_lookup(key=rdi, key_length=esi) -> rax=value pointer or 0.
.type env_lookup, @function
env_lookup:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13d, esi
    mov rbx, qword ptr [rip + process_envp]
.env_next:
    mov r8, qword ptr [rbx]
    test r8, r8
    jz .env_not_found
    mov r9d, r13d
    mov r10, r8
    mov r11, r12
.env_compare:
    test r9d, r9d
    jz .env_equal_prefix
    mov al, byte ptr [r10]
    cmp al, byte ptr [r11]
    jne .env_advance
    inc r10
    inc r11
    dec r9d
    jmp .env_compare
.env_equal_prefix:
    cmp byte ptr [r10], '='
    jne .env_advance
    lea rax, [r10 + 1]
    jmp .env_return
.env_advance:
    add rbx, 8
    jmp .env_next
.env_not_found:
    xor eax, eax
.env_return:
    pop r13
    pop r12
    pop rbx
    ret
.size env_lookup, . - env_lookup

# copy_cstr(dst=rdi, src=rsi, max=edx) -> eax length, -1 if not terminated in bound.
.type copy_cstr, @function
copy_cstr:
    xor ecx, ecx
.copy_loop:
    cmp ecx, edx
    jae .copy_fail
    mov al, byte ptr [rsi + rcx]
    mov byte ptr [rdi + rcx], al
    test al, al
    jz .copy_ok
    inc ecx
    jmp .copy_loop
.copy_ok:
    mov eax, ecx
    ret
.copy_fail:
    mov rax, -1
    ret
.size copy_cstr, . - copy_cstr

# Parse WAYLAND_SOCKET as a non-negative decimal file descriptor.
# RSI = NUL-terminated decimal string. RAX = fd or -EINVAL.
.type parse_socket_fd, @function
parse_socket_fd:
    xor eax, eax
    xor ecx, ecx
.parse_socket_fd_loop:
    movzx edx, byte ptr [rsi + rcx]
    test edx, edx
    jz .parse_socket_fd_done
    cmp edx, '0'
    jb .parse_socket_fd_invalid
    cmp edx, '9'
    ja .parse_socket_fd_invalid
    sub edx, '0'
    imul rax, rax, 10
    add rax, rdx
    cmp rax, 0x7fffffff
    ja .parse_socket_fd_invalid
    inc ecx
    jmp .parse_socket_fd_loop
.parse_socket_fd_done:
    test ecx, ecx
    jz .parse_socket_fd_invalid
    ret
.parse_socket_fd_invalid:
    mov rax, -22
    ret
.size parse_socket_fd, . - parse_socket_fd

# Write all bytes to the Wayland stream with MSG_NOSIGNAL so a closed
# compositor socket becomes a normal -EPIPE result instead of killing the app.
# RDI=socket, RSI=buffer, RDX=length. RAX=0 or negative errno.
.type wl_send_all, @function
wl_send_all:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.wl_send_all_loop:
    test r13, r13
    jz .wl_send_all_success
    mov eax, SYS_sendto
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov r10d, MSG_NOSIGNAL
    xor r8d, r8d
    xor r9d, r9d
    syscall
    cmp rax, -4                 # retry after EINTR
    je .wl_send_all_loop
    test rax, rax
    jg .wl_send_all_advance
    je .wl_send_all_zero
    jmp .wl_send_all_done
.wl_send_all_advance:
    add r12, rax
    sub r13, rax
    jmp .wl_send_all_loop
.wl_send_all_zero:
    mov rax, -5                 # EIO: zero-byte send before completion
    jmp .wl_send_all_done
.wl_send_all_success:
    xor eax, eax
.wl_send_all_done:
    pop r13
    pop r12
    pop rbx
    ret
.size wl_send_all, . - wl_send_all

# wl_send_request(object=rdi, opcode=esi, payload=rdx, payload_length=ecx).
.global wl_send_request
.type wl_send_request, @function
wl_send_request:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8                  # align stack before calling wl_send_all
    mov r12d, edi
    mov r13d, esi
    mov r14, rdx
    mov ebx, ecx
    lea rdi, [rip + request_buffer]
    mov dword ptr [rdi], r12d
    lea eax, [rbx + 8]
    shl eax, 16
    or eax, r13d
    mov dword ptr [rdi + 4], eax
    lea rdi, [rdi + 8]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + request_buffer]
    lea edx, [rbx + 8]
    call wl_send_all
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_send_request, . - wl_send_request

# wl_send_request_fd(object=rdi, opcode=esi, payload=rdx, payload_length=ecx, fd=r8).
.global wl_send_request_fd
.type wl_send_request_fd, @function
wl_send_request_fd:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r14, rdx
    mov ebx, ecx
    mov r15d, r8d
    lea rdi, [rip + request_buffer]
    mov dword ptr [rdi], r12d
    lea eax, [rbx + 8]
    shl eax, 16
    or eax, r13d
    mov dword ptr [rdi + 4], eax
    lea rdi, [rdi + 8]
    mov rsi, r14
    mov ecx, ebx
    rep movsb
    # iovec { request_buffer, total_length }
    lea rax, [rip + request_buffer]
    mov qword ptr [rip + msg_iov], rax
    lea rax, [rbx + 8]
    mov qword ptr [rip + msg_iov + 8], rax
    # cmsghdr: cmsg_len=20, SOL_SOCKET, SCM_RIGHTS, fd
    mov qword ptr [rip + msg_control], 20
    mov dword ptr [rip + msg_control + 8], SOL_SOCKET
    mov dword ptr [rip + msg_control + 12], SCM_RIGHTS
    mov dword ptr [rip + msg_control + 16], r15d
    # msghdr
    mov qword ptr [rip + msg_header], 0
    mov qword ptr [rip + msg_header + 8], 0
    lea rax, [rip + msg_iov]
    mov qword ptr [rip + msg_header + 16], rax
    mov qword ptr [rip + msg_header + 24], 1
    lea rax, [rip + msg_control]
    mov qword ptr [rip + msg_header + 32], rax
    mov qword ptr [rip + msg_header + 40], 24
    mov qword ptr [rip + msg_header + 48], 0
.send_fd_call:
    mov eax, SYS_sendmsg
    mov rdi, qword ptr [rip + socket_fd]
    lea rsi, [rip + msg_header]
    mov edx, MSG_NOSIGNAL
    syscall
    cmp rax, -4                 # retry sendmsg after EINTR
    je .send_fd_call
    test rax, rax
    js .send_fd_done
    lea rdi, [rip + request_buffer]
    lea rsi, [rdi + rax]
    lea edx, [rbx + 8]
    sub rdx, rax
    jz .send_fd_success
    mov edi, dword ptr [rip + socket_fd]
    call wl_send_all
    jmp .send_fd_done
.send_fd_success:
    xor eax, eax
.send_fd_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_send_request_fd, . - wl_send_request_fd

# Bind global: rdi=name, rsi=interface string, edx=string bytes including NUL,
# ecx=version, r8d=new object id.
.global wl_registry_bind
.type wl_registry_bind, @function
wl_registry_bind:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13, rsi
    mov r14d, edx
    mov r15d, ecx
    mov ebx, r8d
    lea rdi, [rip + payload_buffer]
    xor eax, eax
    mov ecx, 64
    rep stosd
    lea rdi, [rip + payload_buffer]
    mov dword ptr [rdi], r12d
    mov dword ptr [rdi + 4], r14d
    lea rdi, [rdi + 8]
    mov rsi, r13
    mov ecx, r14d
    rep movsb
    # Pad string bytes to a 4-byte boundary.
    mov eax, r14d
    add eax, 3
    and eax, -4
    lea rdi, [rip + payload_buffer + 8]
    add rdi, rax
    mov dword ptr [rdi], r15d
    mov dword ptr [rdi + 4], ebx
    lea ecx, [rax + 16]
    mov edi, 2
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    call wl_send_request
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_registry_bind, . - wl_registry_bind

# Receive exactly RDX bytes from an AF_UNIX stream while preserving SCM_RIGHTS.
# RDI=socket, RSI=destination, RDX=length. RAX=0 or negative errno.
.type wl_recv_exact, @function
wl_recv_exact:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13, rsi
    mov r14, rdx
.recv_exact_loop:
    test r14, r14
    jz .recv_exact_success
    # Rebuild msghdr/iovec for every partial receive; ancillary data is tied
    # to stream position and can arrive before the event payload is complete.
    mov qword ptr [rip + recv_iov], r13
    mov qword ptr [rip + recv_iov + 8], r14
    lea rdi, [rip + recv_msg_header]
    xor eax, eax
    mov ecx, 14
    rep stosd
    lea rax, [rip + recv_iov]
    mov qword ptr [rip + recv_msg_header + 16], rax
    mov qword ptr [rip + recv_msg_header + 24], 1
    lea rax, [rip + recv_msg_control]
    mov qword ptr [rip + recv_msg_header + 32], rax
    mov qword ptr [rip + recv_msg_header + 40], 64
    lea rdi, [rip + recv_msg_control]
    xor eax, eax
    mov ecx, 16
    rep stosd

    mov eax, SYS_recvmsg
    mov edi, r12d
    lea rsi, [rip + recv_msg_header]
    mov edx, MSG_CMSG_CLOEXEC
    syscall
    cmp rax, -4                 # EINTR
    je .recv_exact_loop
    test rax, rax
    js .recv_exact_done
    jz .recv_exact_eof
    mov r15, rax

    # A truncated control buffer may have silently lost SCM_RIGHTS handles;
    # reject it rather than continue with a keymap whose FD was not retained.
    mov eax, dword ptr [rip + recv_msg_header + 48]
    test eax, MSG_CTRUNC
    jnz .recv_exact_bad_control
    mov rcx, qword ptr [rip + recv_msg_header + 40]
    test rcx, rcx
    jz .recv_exact_advance
    cmp rcx, 16
    jb .recv_exact_bad_control
    lea rsi, [rip + recv_msg_control]
    mov rax, qword ptr [rsi]
    cmp rax, 16
    jb .recv_exact_bad_control
    cmp rax, rcx
    ja .recv_exact_bad_control
    cmp dword ptr [rsi + 8], SOL_SOCKET
    jne .recv_exact_advance
    cmp dword ptr [rsi + 12], SCM_RIGHTS
    jne .recv_exact_advance
    cmp rax, 20
    jb .recv_exact_bad_control
    mov rdx, rax
    sub rdx, 16
    test edx, 3
    jnz .recv_exact_bad_control
    shr rdx, 2
    xor ebx, ebx
.recv_exact_rights_loop:
    cmp rbx, rdx
    jae .recv_exact_advance
    mov eax, dword ptr [rsi + rbx*4 + 16]
    cmp dword ptr [rip + event_fd], -1
    jne .recv_exact_close_extra
    mov dword ptr [rip + event_fd], eax
    jmp .recv_exact_next_right
.recv_exact_close_extra:
    mov edi, eax
    mov eax, SYS_close
    syscall
.recv_exact_next_right:
    inc rbx
    jmp .recv_exact_rights_loop

.recv_exact_advance:
    add r13, r15
    sub r14, r15
    jmp .recv_exact_loop
.recv_exact_success:
    xor eax, eax
    jmp .recv_exact_done
.recv_exact_eof:
    mov rax, -5                 # EIO / unexpected EOF
    jmp .recv_exact_done
.recv_exact_bad_control:
    mov rax, -71                # EPROTO
.recv_exact_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size wl_recv_exact, . - wl_recv_exact

# Consume and validate the wl_keyboard.keymap event's descriptor.
# XKB_V1 is retained as a bounded, read-only MAP_PRIVATE mapping for the
# upcoming parser; this stage deliberately leaves the legacy key translator
# active until keysyms and modifier levels are implemented.
.type keyboard_keymap_update, @function
keyboard_keymap_update:
    push rbx
    push r12
    push r13
    push r14
    mov dword ptr [rip + keymap_processing_complete], 0
    mov ebx, dword ptr [rip + event_fd]
    mov dword ptr [rip + event_fd], -1
    cmp ebx, 0
    jl .keyboard_keymap_no_fd

    # Replace a prior keymap only after releasing its mapping.
    mov rdi, qword ptr [rip + keymap_mapping]
    test rdi, rdi
    jz .keyboard_keymap_clear_state
    mov esi, dword ptr [rip + keymap_size]
    mov eax, SYS_munmap
    syscall
.keyboard_keymap_clear_state:
    mov qword ptr [rip + keymap_mapping], 0
    mov dword ptr [rip + keymap_size], 0
    mov dword ptr [rip + keymap_format], 0
    call xkb_reset_keymap

    mov r14d, dword ptr [rip + event_payload]
    mov r12d, dword ptr [rip + event_payload + 4]
    test r14d, r14d
    jz .keyboard_keymap_no_map
    cmp r14d, 1                  # WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1
    jne .keyboard_keymap_bad
    cmp r12d, 11                 # "xkb_keymap" plus the terminating NUL
    jb .keyboard_keymap_bad
    cmp r12d, XKB_KEYMAP_MAX_SIZE
    ja .keyboard_keymap_bad

    mov eax, SYS_mmap
    xor edi, edi
    mov esi, r12d
    mov edx, PROT_READ
    mov r10d, MAP_PRIVATE
    mov r8d, ebx
    xor r9d, r9d
    syscall
    test rax, rax
    js .keyboard_keymap_map_error
    mov r13, rax
    cmp byte ptr [r13 + r12 - 1], 0
    jne .keyboard_keymap_unmap_bad
    lea rsi, [rip + xkb_keymap_magic]
    mov rdi, r13
    mov ecx, 10
    repe cmpsb
    jne .keyboard_keymap_unmap_bad

    mov qword ptr [rip + keymap_mapping], r13
    mov dword ptr [rip + keymap_size], r12d
    mov edi, ebx
    mov eax, SYS_close
    syscall
    # Keep the mapped file only when the supported XKB text subset parsed.
    mov rdi, r13
    mov esi, r12d
    call xkb_parse_keymap
    test rax, rax
    js .keyboard_keymap_parser_fallback
    mov dword ptr [rip + keymap_format], 1
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done
.keyboard_keymap_parser_fallback:
    mov dword ptr [rip + keymap_format], 0
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done

.keyboard_keymap_no_map:
    # WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP still carries an FD argument.
    mov edi, ebx
    mov eax, SYS_close
    syscall
    call xkb_reset_keymap
    mov dword ptr [rip + keymap_processing_complete], 1
    xor eax, eax
    jmp .keyboard_keymap_done
.keyboard_keymap_unmap_bad:
    mov rdi, r13
    mov esi, r12d
    mov eax, SYS_munmap
    syscall
.keyboard_keymap_bad:
    mov edi, ebx
    mov eax, SYS_close
    syscall
    mov rax, -71                # EPROTO: malformed/unsupported keymap
    jmp .keyboard_keymap_done
.keyboard_keymap_map_error:
    mov r14, rax
    mov edi, ebx
    mov eax, SYS_close
    syscall
    mov rax, r14
    jmp .keyboard_keymap_done
.keyboard_keymap_no_fd:
    mov rax, -71
.keyboard_keymap_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size keyboard_keymap_update, . - keyboard_keymap_update

# Validate/consume wl_keyboard.keymap in both the bootstrap and main dispatchers.
.type keyboard_keymap_dispatch, @function
keyboard_keymap_dispatch:
    inc dword ptr [rip + keymap_event_count]
    mov eax, dword ptr [rip + last_object]
    mov dword ptr [rip + keymap_event_last_object], eax
    mov eax, dword ptr [rip + last_size]
    mov dword ptr [rip + keymap_event_last_size], eax
    mov eax, dword ptr [rip + event_fd]
    mov dword ptr [rip + keymap_event_last_fd], eax
    cmp dword ptr [rip + last_size], 8
    jne .keyboard_keymap_dispatch_bad
    cmp dword ptr [rip + event_fd], -1
    je .keyboard_keymap_dispatch_bad
    call keyboard_keymap_update
    test rax, rax
    js .keyboard_keymap_dispatch_done
    inc dword ptr [rip + keymap_event_processed_count]
.keyboard_keymap_dispatch_done:
    ret
.keyboard_keymap_dispatch_bad:
    mov rax, -71
    ret
.size keyboard_keymap_dispatch, . - keyboard_keymap_dispatch

# Read one complete Wayland event; records last_object/opcode/size and payload.
.type wl_read_event, @function
wl_read_event:
    push rbp
    # Any descriptor not consumed by the preceding event is not allowed to
    # leak into the next dispatch cycle.
    mov edi, dword ptr [rip + event_fd]
    cmp edi, -1
    je .read_event_start
    mov eax, SYS_close
    syscall
    mov dword ptr [rip + event_fd], -1
.read_event_start:
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + event_header]
    mov edx, 8
    call wl_recv_exact
    test rax, rax
    js .read_event_done
    mov eax, dword ptr [rip + event_header]
    mov dword ptr [rip + last_object], eax
    mov eax, dword ptr [rip + event_header + 4]
    mov edx, eax
    and edx, 0xffff
    mov dword ptr [rip + last_opcode], edx
    shr eax, 16
    cmp eax, 8
    jb .read_event_bad
    sub eax, 8
    cmp eax, 4096
    ja .read_event_bad
    mov dword ptr [rip + last_size], eax
    test eax, eax
    jz .read_event_ok
    mov edi, dword ptr [rip + socket_fd]
    lea rsi, [rip + event_payload]
    mov edx, eax
    call wl_recv_exact
    test rax, rax
    js .read_event_done
.read_event_ok:
    # wl_display.error is fatal; return an error while preserving its payload
    # so the caller can print the compositor-provided diagnostic safely.
    cmp dword ptr [rip + last_object], 1
    jne .read_event_success
    cmp dword ptr [rip + last_opcode], 0
    jne .read_event_success
    mov rax, -71                 # EPROTO
    jmp .read_event_done
.read_event_success:
    xor eax, eax
.read_event_done:
    pop rbp
    ret
.read_event_bad:
    mov rax, -71
    jmp .read_event_done
.size wl_read_event, . - wl_read_event

# Registry.global payload: name, interface string, version.
.type registry_capture_global, @function
registry_capture_global:
    push rbp
    push r12
    sub rsp, 8
    lea r8, [rip + event_payload + 8]
    mov rdi, r8
    lea rsi, [rip + iface_compositor]
    call string_equal
    test eax, eax
    jz .registry_try_shm
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + compositor_global], eax
    mov eax, dword ptr [rip + event_payload + 4]
    add eax, 3
    and eax, -4
    lea rdi, [rip + event_payload + 8]
    add rdi, rax
    mov edx, dword ptr [rdi]
    cmp edx, 6
    jbe .registry_compositor_version_ready
    mov edx, 6
.registry_compositor_version_ready:
    mov dword ptr [rip + compositor_version], edx
    jmp .registry_done
.registry_try_shm:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_shm]
    call string_equal
    test eax, eax
    jz .registry_try_xdg
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + shm_global], eax
    jmp .registry_done
.registry_try_xdg:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_xdg_wm_base]
    call string_equal
    test eax, eax
    jz .registry_try_seat
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + xdg_global], eax
    jmp .registry_done
.registry_try_seat:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_seat]
    call string_equal
    test eax, eax
    jz .registry_try_data_device_manager
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + seat_global], eax
    # Request at most wl_seat version 4, which exposes wl_keyboard.repeat_info.
    # Keep older compositor versions working with the local default timings.
    mov eax, dword ptr [rip + event_payload + 4]
    add eax, 3
    and eax, -4
    lea rdi, [rip + event_payload + 8]
    add rdi, rax
    mov edx, dword ptr [rdi]
    cmp edx, 4
    jbe .Lneko_seat_version_ready
    mov edx, 4
.Lneko_seat_version_ready:
    mov dword ptr [rip + seat_version], edx
    jmp .registry_done
.registry_try_data_device_manager:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_data_device_manager]
    call string_equal
    test eax, eax
    jz .registry_try_cursor_shape
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + clipboard_manager_global], eax
    jmp .registry_done
.registry_try_cursor_shape:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_cursor_shape]
    call string_equal
    test eax, eax
    jz .registry_try_text_input
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + cursor_shape_global], eax
    mov eax, dword ptr [rip + event_payload + 4]
    add eax, 3
    and eax, -4
    lea rdi, [rip + event_payload + 8]
    add rdi, rax
    mov edx, dword ptr [rdi]
    test edx, edx
    jz .registry_done
    mov dword ptr [rip + cursor_shape_version], 1
    jmp .registry_done
.registry_try_text_input:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_text_input_manager_v3]
    call string_equal
    test eax, eax
    jz .registry_try_fractional_manager
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + text_input_manager_global], eax
    jmp .registry_done
.registry_try_fractional_manager:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_fractional_scale_manager]
    call string_equal
    test eax, eax
    jz .registry_try_viewporter
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + fractional_scale_manager_global], eax
    jmp .registry_done
.registry_try_viewporter:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_viewporter]
    call string_equal
    test eax, eax
    jz .registry_try_output
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + viewporter_global], eax
    jmp .registry_done
.registry_try_output:
    lea rdi, [rip + event_payload + 8]
    lea rsi, [rip + iface_output]
    call string_equal
    test eax, eax
    jz .registry_done
    xor r12d, r12d
    lea rdi, [rip + output_global_names]
.registry_output_find_slot:
    cmp r12d, 8
    jae .registry_done
    cmp dword ptr [rdi + r12*4], 0
    je .registry_output_slot_found
    inc r12d
    jmp .registry_output_find_slot
.registry_output_slot_found:
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rdi + r12*4], eax
    lea rdi, [rip + output_scales]
    mov dword ptr [rdi + r12*4], 1
    lea rdi, [rip + output_pending_scales]
    mov dword ptr [rdi + r12*4], 1
    lea rdi, [rip + output_pending_valid]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_mode_width]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_mode_height]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_pending_mode_width]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_pending_mode_height]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_pending_mode_valid]
    mov dword ptr [rdi + r12*4], 0
    lea rdi, [rip + output_surface_entered]
    mov dword ptr [rdi + r12*4], 0
    mov eax, dword ptr [rip + event_payload + 4]
    add eax, 3
    and eax, -4
    lea rdi, [rip + event_payload + 8]
    add rdi, rax
    mov edx, dword ptr [rdi]
    cmp edx, 3
    jbe .registry_output_version_ready
    mov edx, 3
.registry_output_version_ready:
    lea rdi, [rip + output_versions]
    mov dword ptr [rdi + r12*4], edx
.registry_done:
    add rsp, 8
    pop r12
    pop rbp
    ret
.size registry_capture_global, . - registry_capture_global

.type string_equal, @function
string_equal:
    mov r8, rdi
    mov r9, rsi
.string_equal_loop:
    mov al, byte ptr [r8]
    cmp al, byte ptr [r9]
    jne .string_equal_no
    test al, al
    je .string_equal_yes
    inc r8
    inc r9
    jmp .string_equal_loop
.string_equal_yes:
    mov eax, 1
    ret
.string_equal_no:
    xor eax, eax
    ret
.size string_equal, . - string_equal

# Draw a filled rectangle.
# Inputs: RDI=base, ESI=x, EDX=y, ECX=width, R8D=height, R9D=XRGB8888.
.type draw_rect, @function
draw_rect:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx
    mov r15d, r8d
    mov r11d, r9d
    cmp dword ptr [rip + ui_transform_active], 0
    je .draw_rect_transform_done
    # Transform rectangle origin from the active dialog's design-space box.
    mov eax, r12d
    sub eax, dword ptr [rip + ui_transform_base_x]
    imul eax, dword ptr [rip + ui_transform_x_num]
    cdq
    idiv dword ptr [rip + ui_transform_x_den]
    add eax, dword ptr [rip + ui_transform_origin_x]
    mov r12d, eax
    mov eax, r13d
    sub eax, dword ptr [rip + ui_transform_base_y]
    imul eax, dword ptr [rip + ui_transform_y_num]
    cdq
    idiv dword ptr [rip + ui_transform_y_den]
    add eax, dword ptr [rip + ui_transform_origin_y]
    mov r13d, eax
    # Scale dimensions upward so thin borders do not disappear at small sizes.
    mov eax, r14d
    imul eax, dword ptr [rip + ui_transform_x_num]
    add eax, dword ptr [rip + ui_transform_x_den]
    dec eax
    xor edx, edx
    div dword ptr [rip + ui_transform_x_den]
    mov r14d, eax
    mov eax, r15d
    imul eax, dword ptr [rip + ui_transform_y_num]
    add eax, dword ptr [rip + ui_transform_y_den]
    dec eax
    xor edx, edx
    div dword ptr [rip + ui_transform_y_den]
    mov r15d, eax
.draw_rect_transform_done:
    mov eax, dword ptr [rip + window_ui_scale_120]
    cmp eax, 120
    je .draw_rect_density_done
    imul r12d, eax
    mov eax, r12d
    cdq
    mov ecx, 120
    idiv ecx
    mov r12d, eax
    mov eax, r13d
    imul eax, dword ptr [rip + window_ui_scale_120]
    cdq
    mov ecx, 120
    idiv ecx
    mov r13d, eax
    mov eax, r14d
    imul eax, dword ptr [rip + window_ui_scale_120]
    add eax, 119
    xor edx, edx
    mov ecx, 120
    div ecx
    mov r14d, eax
    mov eax, r15d
    imul eax, dword ptr [rip + window_ui_scale_120]
    add eax, 119
    xor edx, edx
    mov ecx, 120
    div ecx
    mov r15d, eax
.draw_rect_density_done:
    mov r8d, dword ptr [rip + window_buffer_raster_scale_120]
    cmp r8d, 120
    je .draw_rect_scale_done
    mov eax, r12d
    imul eax, r8d
    cdq
    mov ecx, 120
    idiv ecx
    mov r10d, eax
    mov eax, r12d
    add eax, r14d
    imul eax, r8d
    add eax, 119
    xor edx, edx
    div ecx
    sub eax, r10d
    mov r14d, eax
    mov r12d, r10d
    mov eax, r13d
    imul eax, r8d
    cdq
    mov ecx, 120
    idiv ecx
    mov r10d, eax
    mov eax, r13d
    add eax, r15d
    imul eax, r8d
    add eax, 119
    xor edx, edx
    div ecx
    sub eax, r10d
    mov r15d, eax
    mov r13d, r10d
.draw_rect_scale_done:
    # Convert each logical-surface rectangle to its pre-transformed buffer box.
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, 1
    je .draw_rect_map_90
    cmp eax, 2
    je .draw_rect_map_180
    cmp eax, 3
    je .draw_rect_map_270
    cmp eax, 4
    je .draw_rect_map_flipped
    cmp eax, 5
    je .draw_rect_map_flipped_90
    cmp eax, 6
    je .draw_rect_map_flipped_180
    cmp eax, 7
    je .draw_rect_map_flipped_270
    jmp .draw_rect_map_done
.draw_rect_map_90:
    mov eax, r13d
    mov ecx, dword ptr [rip + window_raster_surface_width]
    sub ecx, r12d
    sub ecx, r14d
    mov r12d, eax
    mov r13d, ecx
    xchg r14d, r15d
    jmp .draw_rect_map_done
.draw_rect_map_180:
    mov eax, dword ptr [rip + window_raster_surface_width]
    sub eax, r12d
    sub eax, r14d
    mov r12d, eax
    mov eax, dword ptr [rip + window_raster_surface_height]
    sub eax, r13d
    sub eax, r15d
    mov r13d, eax
    jmp .draw_rect_map_done
.draw_rect_map_270:
    mov eax, dword ptr [rip + window_raster_surface_height]
    sub eax, r13d
    sub eax, r15d
    mov ecx, r12d
    mov r12d, eax
    mov r13d, ecx
    xchg r14d, r15d
    jmp .draw_rect_map_done
.draw_rect_map_flipped:
    mov eax, dword ptr [rip + window_raster_surface_width]
    sub eax, r12d
    sub eax, r14d
    mov r12d, eax
    jmp .draw_rect_map_done
.draw_rect_map_flipped_90:
    mov eax, r13d
    mov ecx, r12d
    mov r12d, eax
    mov r13d, ecx
    xchg r14d, r15d
    jmp .draw_rect_map_done
.draw_rect_map_flipped_180:
    mov eax, dword ptr [rip + window_raster_surface_height]
    sub eax, r13d
    sub eax, r15d
    mov r13d, eax
    jmp .draw_rect_map_done
.draw_rect_map_flipped_270:
    mov eax, dword ptr [rip + window_raster_surface_height]
    sub eax, r13d
    sub eax, r15d
    mov ecx, dword ptr [rip + window_raster_surface_width]
    sub ecx, r12d
    sub ecx, r14d
    mov r12d, eax
    mov r13d, ecx
    xchg r14d, r15d
.draw_rect_map_done:
    test r12d, r12d
    js .draw_rect_done
    test r13d, r13d
    js .draw_rect_done
    test r14d, r14d
    jle .draw_rect_done
    test r15d, r15d
    jle .draw_rect_done
    mov eax, dword ptr [rip + window_buffer_width]
    cmp r12d, eax
    jae .draw_rect_done
    sub eax, r12d
    cmp r14d, eax
    jbe .draw_rect_width_ready
    mov r14d, eax
.draw_rect_width_ready:
    mov eax, dword ptr [rip + window_buffer_height]
    cmp r13d, eax
    jae .draw_rect_done
    sub eax, r13d
    cmp r15d, eax
    jbe .draw_rect_height_ready
    mov r15d, eax
.draw_rect_height_ready:
    xor r10d, r10d
.draw_rect_row:
    cmp r10d, r15d
    jae .draw_rect_done
    mov eax, r13d
    add eax, r10d
    mov ecx, dword ptr [rip + window_stride]
    imul rax, rcx
    mov edx, r12d
    shl edx, 2
    add rax, rdx
    add rax, rbx
    mov rdi, rax
    mov ecx, r14d
    mov eax, r11d
    rep stosd
    inc r10d
    jmp .draw_rect_row
.draw_rect_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_rect, . - draw_rect

# Repaint the editor surface, including document chrome and status information.
.type render_surface, @function
render_surface:
    push rbp
    # Main application background.
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, dword ptr [rip + window_width]
    mov r8d, dword ptr [rip + window_height]
    mov r9d, 0xff252a33
    call draw_rect

    # Compact title bar with a narrow accent rail.
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, dword ptr [rip + window_width]
    mov r8d, 32
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, 3
    mov r8d, 32
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 16
    mov esi, 12
    lea rdx, [rip + ui_app_name]
    call draw_text
    cmp dword ptr [rip + doc_save_error], 0
    jne .render_save_error
    cmp dword ptr [rip + doc_open_error], 0
    jne .render_open_error
    cmp dword ptr [rip + doc_save_error], 0
    jne .render_save_error
    cmp dword ptr [rip + doc_storage_error], 0
    jne .render_storage_error
    mov edi, dword ptr [rip + window_width]
    sub edi, 184
    mov esi, 12
    lea rdx, [rip + ui_mode_name]
    call draw_text
    jmp .render_file_button
.render_storage_error:
    mov edi, dword ptr [rip + window_width]
    sub edi, 192
    mov esi, 12
    lea rdx, [rip + ui_storage_error]
    call draw_text
    jmp .render_file_button
.render_open_error:
    mov edi, dword ptr [rip + window_width]
    sub edi, 192
    mov esi, 12
    lea rdx, [rip + ui_open_error]
    call draw_text
    jmp .render_file_button
.render_save_error:
    mov edi, dword ptr [rip + window_width]
    sub edi, 192
    mov esi, 12
    lea rdx, [rip + ui_mode_error]
    call draw_text

.render_file_button:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 4
    mov ecx, 48
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 112
    mov esi, 12
    lea rdx, [rip + ui_file_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 160
    mov edx, 4
    mov ecx, 72
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 168
    mov esi, 12
    lea rdx, [rip + ui_settings_label]
    call draw_text

.render_document_tab:
    # A single active document tab; the launch-time basename replaces Untitled.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 8
    mov edx, 40
    mov ecx, 152
    mov r8d, 36
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 8
    mov edx, 74
    mov ecx, 152
    mov r8d, 2
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 24
    mov esi, 54
    lea rdx, [rip + active_document_name]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 168
    mov edx, 40
    mov ecx, 152
    mov r8d, 36
    mov r9d, 0xff343d4b
    cmp dword ptr [rip + history_tab_open], 0
    je .render_history_tab_background
    mov r9d, 0xff414b5a
.render_history_tab_background:
    call draw_rect
    mov edi, 184
    mov esi, 54
    lea rdx, [rip + ui_history_label]
    call draw_text
    cmp dword ptr [rip + history_tab_open], 0
    je .render_history_tab_done
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 168
    mov edx, 74
    mov ecx, 152
    mov r8d, 2
    mov r9d, 0xff78a9d4
    call draw_rect
.render_history_tab_done:
    cmp dword ptr [rip + history_tab_open], 0
    jne .render_history_page

    call doc_scrollbar_geometry
    call doc_hscrollbar_geometry
    call render_find_highlights
    call render_selection
    call render_document
    call render_document_scrollbar
    call render_document_hscrollbar
    call render_status_bar
    call render_file_menu
    call render_window_controls
    call render_path_prompt
    call render_picker
    call render_save_confirmation
    call render_find_replace
    jmp .render_surface_done
.render_history_page:
    call render_history_manager
    call render_file_menu
    call render_window_controls
    call render_path_prompt
    call render_picker
    call render_save_confirmation
    call render_find_replace
.render_surface_done:
    call render_context_menu
    pop rbp
    ret
.size render_surface, . - render_surface

# Attach and repaint the one buffer, but only after wl_buffer.release.
# RAX = 0 on success, negative on failure.
# Retain pointer focus/coordinates even if wl_pointer.enter arrives during
# the initial seat roundtrip, before the regular event loop is running.
.type pointer_capture_enter, @function
pointer_capture_enter:
    cmp dword ptr [rip + last_size], 16
    jb .pointer_capture_enter_done
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + pointer_enter_serial], eax
    mov eax, dword ptr [rip + event_payload + 8]
    sar eax, 8
    mov dword ptr [rip + pointer_surface_x], eax
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_x], eax
    mov eax, dword ptr [rip + event_payload + 12]
    sar eax, 8
    mov dword ptr [rip + pointer_surface_y], eax
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_y], eax
    mov dword ptr [rip + pointer_inside], 1
    mov dword ptr [rip + cursor_shape_current], 0
.pointer_capture_enter_done:
    xor eax, eax
    ret
.size pointer_capture_enter, . - pointer_capture_enter

.type pointer_capture_motion, @function
pointer_capture_motion:
    cmp dword ptr [rip + last_size], 12
    jb .pointer_capture_motion_done
    mov eax, dword ptr [rip + event_payload + 4]
    sar eax, 8
    mov dword ptr [rip + pointer_surface_x], eax
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_x], eax
    mov eax, dword ptr [rip + event_payload + 8]
    sar eax, 8
    mov dword ptr [rip + pointer_surface_y], eax
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_y], eax
.pointer_capture_motion_done:
    xor eax, eax
    ret
.size pointer_capture_motion, . - pointer_capture_motion

# Return xdg_toplevel.resize_edge bits from the last virtual application pointer position.
# The same calculation drives resize cursor feedback and button-press requests.
.type window_get_resize_edges, @function
window_get_resize_edges:
    cmp dword ptr [rip + window_is_maximized], 0
    jne .window_get_resize_edges_none
    mov eax, dword ptr [rip + pointer_x]
    mov edx, dword ptr [rip + pointer_y]
    test eax, eax
    js .window_get_resize_edges_none
    test edx, edx
    js .window_get_resize_edges_none
    xor r8d, r8d
    cmp eax, WINDOW_RESIZE_BORDER
    jae .window_get_resize_edges_right
    or r8d, 4                  # left
    jmp .window_get_resize_edges_vertical
.window_get_resize_edges_right:
    mov ecx, dword ptr [rip + window_width]
    sub ecx, WINDOW_RESIZE_BORDER
    cmp eax, ecx
    jb .window_get_resize_edges_vertical
    or r8d, 8                  # right
.window_get_resize_edges_vertical:
    cmp edx, WINDOW_RESIZE_BORDER
    jae .window_get_resize_edges_bottom
    # The top hit band overlaps the app-drawn title bar. Keep the File menu
    # (x=104..159) and the window-control strip clickable; the top-right
    # resize corner remains available in the outermost 16 units.
    cmp edx, 32
    jae .window_get_resize_edges_top
    cmp eax, 104
    jb .window_get_resize_edges_top
    cmp eax, 160
    jb .window_get_resize_edges_done
    # Keep the File and Settings buttons clickable in the title-bar top band.
    cmp eax, 240
    jb .window_get_resize_edges_done
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 104
    cmp eax, ecx
    jb .window_get_resize_edges_top
    mov ecx, dword ptr [rip + window_width]
    sub ecx, WINDOW_RESIZE_BORDER
    cmp eax, ecx
    jae .window_get_resize_edges_top
    jmp .window_get_resize_edges_done
.window_get_resize_edges_top:
    or r8d, 1                  # top
    jmp .window_get_resize_edges_done
.window_get_resize_edges_bottom:
    mov ecx, dword ptr [rip + window_height]
    sub ecx, WINDOW_RESIZE_BORDER
    cmp edx, ecx
    jb .window_get_resize_edges_done
    or r8d, 2                  # bottom
.window_get_resize_edges_done:
    mov eax, r8d
    ret
.window_get_resize_edges_none:
    xor eax, eax
    ret
.size window_get_resize_edges, . - window_get_resize_edges

# Use the optional wp_cursor_shape_manager_v1 extension to show resize cursors
# while hovering. The actual drag still uses xdg_toplevel.resize and the button serial.
.type window_update_cursor_shape, @function
window_update_cursor_shape:
    push r12
    cmp dword ptr [rip + cursor_shape_device], 0
    je .window_cursor_shape_done
    cmp dword ptr [rip + pointer_inside], 1
    jne .window_cursor_shape_done
    mov r12d, CURSOR_SHAPE_DEFAULT
    cmp dword ptr [rip + picker_mode], 0
    jne .window_cursor_shape_send
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .window_cursor_shape_send
    call window_get_resize_edges
    cmp eax, 1
    je .window_cursor_shape_ns
    cmp eax, 2
    je .window_cursor_shape_ns
    cmp eax, 4
    je .window_cursor_shape_ew
    cmp eax, 8
    je .window_cursor_shape_ew
    cmp eax, 5
    je .window_cursor_shape_nwse
    cmp eax, 10
    je .window_cursor_shape_nwse
    cmp eax, 6
    je .window_cursor_shape_nesw
    cmp eax, 9
    je .window_cursor_shape_nesw
    jmp .window_cursor_shape_send
.window_cursor_shape_ew:
    mov r12d, CURSOR_SHAPE_EW_RESIZE
    jmp .window_cursor_shape_send
.window_cursor_shape_ns:
    mov r12d, CURSOR_SHAPE_NS_RESIZE
    jmp .window_cursor_shape_send
.window_cursor_shape_nesw:
    mov r12d, CURSOR_SHAPE_NESW_RESIZE
    jmp .window_cursor_shape_send
.window_cursor_shape_nwse:
    mov r12d, CURSOR_SHAPE_NWSE_RESIZE
.window_cursor_shape_send:
    cmp r12d, dword ptr [rip + cursor_shape_current]
    je .window_cursor_shape_done
    mov dword ptr [rip + cursor_shape_current], r12d
    mov eax, dword ptr [rip + pointer_enter_serial]
    mov dword ptr [rip + payload_buffer], eax
    mov dword ptr [rip + payload_buffer + 4], r12d
    mov edi, dword ptr [rip + cursor_shape_device]
    mov esi, 1                  # wp_cursor_shape_device_v1.set_shape
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    jmp .window_cursor_shape_return
.window_cursor_shape_done:
    xor eax, eax
.window_cursor_shape_return:
    pop r12
    ret
.size window_update_cursor_shape, . - window_update_cursor_shape

# Bind cursor-shape manager and get a cursor-shape device for the wl_pointer.
# Both objects use the shared dense client-object ID allocator.
.type cursor_shape_setup, @function
cursor_shape_setup:
    push r12
    cmp dword ptr [rip + cursor_shape_global], 0
    je .cursor_shape_setup_done
    cmp dword ptr [rip + pointer_created], 1
    jne .cursor_shape_setup_done

    # Keep the manager bound across pointer hotplug events. Its device object
    # is tied to exactly one wl_pointer and must be recreated after removal.
    mov r12d, dword ptr [rip + cursor_shape_manager]
    test r12d, r12d
    jnz .cursor_shape_manager_ready
    mov r12d, dword ptr [rip + next_client_object_id]
    lea eax, [r12d + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + cursor_shape_manager], r12d
    mov edi, dword ptr [rip + cursor_shape_global]
    lea rsi, [rip + iface_cursor_shape]
    mov edx, 27                 # interface string including NUL
    mov ecx, dword ptr [rip + cursor_shape_version]
    mov r8d, r12d
    call wl_registry_bind
    test rax, rax
    js .cursor_shape_setup_return

.cursor_shape_manager_ready:
    cmp dword ptr [rip + cursor_shape_device], 0
    jne .cursor_shape_setup_done
    mov eax, dword ptr [rip + next_client_object_id]
    lea edx, [rax + 1]
    mov dword ptr [rip + next_client_object_id], edx
    mov dword ptr [rip + cursor_shape_device], eax
    # get_pointer arguments are (new cursor-shape device ID, existing wl_pointer ID).
    mov dword ptr [rip + payload_buffer], eax
    mov eax, dword ptr [rip + pointer_object]
    mov dword ptr [rip + payload_buffer + 4], eax
    mov edi, r12d
    mov esi, 1                  # wp_cursor_shape_manager_v1.get_pointer
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .cursor_shape_setup_return
    # The new pointer has no focus until its next enter event supplies a
    # valid serial. Do not reuse the previous pointer's serial here.
    cmp dword ptr [rip + pointer_inside], 1
    jne .cursor_shape_setup_done
    call window_update_cursor_shape
.cursor_shape_setup_return:
    pop r12
    ret
.cursor_shape_setup_done:
    xor eax, eax
    pop r12
    ret
.size cursor_shape_setup, . - cursor_shape_setup


# Optional Wayland text-input-v3 client. It is deliberately opt-in because
# enabling it suppresses printable wl_keyboard insertion while awaiting IME
# commits; live GNOME/Mutter handoff must be validated before making it default.
.type text_input_setup, @function
text_input_setup:
    push r12
    cmp dword ptr [rip + text_input_opt_in], 1
    jne .Lti_setup_done
    cmp dword ptr [rip + text_input_manager_global], 0
    je .Lti_setup_done
    cmp dword ptr [rip + text_input_manager_object], 0
    jne .Lti_setup_done
    mov r12d, dword ptr [rip + next_client_object_id]
    lea eax, [r12d + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + text_input_manager_object], r12d
    mov edi, dword ptr [rip + text_input_manager_global]
    lea rsi, [rip + iface_text_input_manager_v3]
    mov edx, 26
    mov ecx, 1
    mov r8d, r12d
    call wl_registry_bind
    test rax, rax
    js .Lti_setup_return
    mov eax, dword ptr [rip + next_client_object_id]
    lea edx, [rax + 1]
    mov dword ptr [rip + next_client_object_id], edx
    mov dword ptr [rip + text_input_object], eax
    mov dword ptr [rip + text_input_state_ready], 1
    mov dword ptr [rip + text_input_pending_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_pending_preedit_cursor_end], -1
    mov dword ptr [rip + text_input_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_preedit_cursor_end], -1
    mov dword ptr [rip + payload_buffer], eax
    mov dword ptr [rip + payload_buffer + 4], 13
    mov edi, r12d
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    jmp .Lti_setup_return
.Lti_setup_done:
    xor eax, eax
.Lti_setup_return:
    pop r12
    ret
.size text_input_setup, . - text_input_setup

.type text_input_commit_request, @function
text_input_commit_request:
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 7
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .Lti_commit_request_return
    inc dword ptr [rip + text_input_commit_serial]
    mov dword ptr [rip + text_input_change_cause], 0
.Lti_commit_request_return:
    ret
.size text_input_commit_request, . - text_input_commit_request

# Return the screen-space IME caret position after rendering the preedit prefix.
# EAX=x, EDX=y. Layout follows the document's active wrap/scroll mode.
.type text_input_preedit_caret_position, @function
text_input_preedit_caret_position:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov r12d, eax
    lea r13d, [rdx + DOC_LEFT]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Lti_preedit_caret_base_y
    sub r13d, dword ptr [rip + doc_view_left_px]
.Lti_preedit_caret_base_y:
    mov eax, r12d
    sub eax, dword ptr [rip + doc_view_top_row]
    imul eax, dword ptr [rip + window_doc_line_height]
    add eax, DOC_TOP
    mov r14d, eax
    mov r15d, dword ptr [rip + text_input_preedit_cursor_begin]
    test r15d, r15d
    js .Lti_preedit_caret_return
    xor ebx, ebx
.Lti_preedit_caret_loop:
    cmp ebx, r15d
    jae .Lti_preedit_caret_return
    lea rdi, [rip + text_input_preedit_buffer]
    mov esi, ebx
    mov edx, dword ptr [rip + text_input_preedit_length]
    call text_input_decode_scalar
    mov dword ptr [rsp], edx
    mov edi, eax
    call font_codepoint_advance_pixels
    mov dword ptr [rsp + 4], eax
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lti_preedit_caret_advance
    mov eax, r13d
    add eax, dword ptr [rsp + 4]
    mov edx, DOC_LEFT
    add edx, dword ptr [rip + window_doc_pixel_width]
    cmp eax, edx
    jbe .Lti_preedit_caret_advance
    mov r13d, DOC_LEFT
    add r14d, dword ptr [rip + window_doc_line_height]
.Lti_preedit_caret_advance:
    mov eax, dword ptr [rsp + 4]
    add r13d, eax
    mov eax, dword ptr [rsp]
    add ebx, eax
    jmp .Lti_preedit_caret_loop
.Lti_preedit_caret_return:
    mov eax, r13d
    mov edx, r14d
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size text_input_preedit_caret_position, . - text_input_preedit_caret_position

# Keep text input enabled only while the document itself is the focused target.
.type text_input_update_state, @function
text_input_update_state:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + text_input_object], 0
    je .Lti_update_done
    xor ebx, ebx
    cmp dword ptr [rip + text_input_entered], 1
    jne .Lti_update_choose
    cmp dword ptr [rip + keyboard_focused], 1
    jne .Lti_update_choose
    cmp dword ptr [rip + picker_mode], 0
    jne .Lti_update_choose
    cmp dword ptr [rip + path_prompt_mode], 0
    jne .Lti_update_choose
    cmp dword ptr [rip + find_replace_mode], 0
    jne .Lti_update_choose
    cmp dword ptr [rip + save_confirm_open], 0
    jne .Lti_update_choose
    cmp dword ptr [rip + history_tab_open], 0
    jne .Lti_update_choose
    mov ebx, 1
.Lti_update_choose:
    cmp ebx, dword ptr [rip + text_input_enabled]
    je .Lti_update_same_mode
    test ebx, ebx
    jz .Lti_update_disable
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 1
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .Lti_update_return
    mov dword ptr [rip + text_input_enabled], 1
    mov dword ptr [rip + text_input_state_ready], 1
    mov dword ptr [rip + text_input_preedit_length], 0
    mov dword ptr [rip + text_input_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_preedit_cursor_end], -1
    mov dword ptr [rip + payload_buffer], 0
    mov dword ptr [rip + payload_buffer + 4], 0
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 5
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .Lti_update_return
    jmp .Lti_update_send_state
.Lti_update_disable:
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 2
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .Lti_update_return
    mov dword ptr [rip + text_input_enabled], 0
    mov dword ptr [rip + text_input_preedit_length], 0
    mov dword ptr [rip + text_input_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_preedit_cursor_end], -1
    call text_input_commit_request
    jmp .Lti_update_return
.Lti_update_same_mode:
    cmp ebx, 1
    jne .Lti_update_done
.Lti_update_send_state:
    cmp dword ptr [rip + text_input_state_ready], 1
    jne .Lti_update_done

    # Tell the compositor whether this document-state change came from the
    # editor (keyboard/pointer) or from the input method. The cause and the
    # following surrounding/cursor state are committed atomically.
    mov eax, dword ptr [rip + text_input_change_cause]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 4
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .Lti_update_return

    # Keep no more than 4000 bytes around the caret; offsets remain UTF-8 boundaries.
    mov r12d, dword ptr [rip + doc_cursor]
    mov eax, r12d
    cmp eax, 2000
    ja .Lti_surround_start_ready
    xor eax, eax
    jmp .Lti_surround_start_store
.Lti_surround_start_ready:
    sub eax, 2000
.Lti_surround_start_store:
    mov r13d, eax
.Lti_surround_align_start:
    test r13d, r13d
    jz .Lti_surround_end_init
    mov edi, r13d
    call doc_byte_at
    mov edx, eax
    and edx, 0xc0
    cmp edx, 0x80
    jne .Lti_surround_end_init
    dec r13d
    jmp .Lti_surround_align_start
.Lti_surround_end_init:
    mov eax, r13d
    add eax, 4000
    cmp eax, dword ptr [rip + doc_length]
    jbe .Lti_surround_end_ready
    mov eax, dword ptr [rip + doc_length]
.Lti_surround_end_ready:
    mov r14d, eax
.Lti_surround_align_end:
    cmp r14d, r13d
    jbe .Lti_surround_validate
    cmp r14d, dword ptr [rip + doc_length]
    jae .Lti_surround_validate
    mov edi, r14d
    call doc_byte_at
    mov edx, eax
    and edx, 0xc0
    cmp edx, 0x80
    jne .Lti_surround_validate
    dec r14d
    jmp .Lti_surround_align_end
.Lti_surround_validate:
    mov r15d, r13d
.Lti_surround_validate_loop:
    cmp r15d, r14d
    jae .Lti_surround_valid
    mov edi, r15d
    call doc_byte_at
    test eax, eax
    jz .Lti_surround_invalid
    mov ebx, eax
    mov edi, r15d
    call doc_utf8_next
    cmp eax, r15d
    jbe .Lti_surround_invalid
    lea edx, [r15d + 1]
    cmp eax, edx
    jne .Lti_surround_validate_step
    cmp ebx, 0x80
    jae .Lti_surround_invalid
.Lti_surround_validate_step:
    cmp eax, r14d
    ja .Lti_surround_invalid
    mov r15d, eax
    jmp .Lti_surround_validate_loop
.Lti_surround_invalid:
    xor r12d, r12d
    xor r13d, r13d
    xor r14d, r14d
.Lti_surround_valid:
    mov eax, r14d
    sub eax, r13d
    inc eax
    mov dword ptr [rip + text_input_request_buffer], eax
    mov r15d, r13d
.Lti_surround_copy:
    cmp r15d, r14d
    jae .Lti_surround_copy_done
    mov edi, r15d
    call doc_byte_at
    lea rdx, [rip + text_input_request_buffer + 4]
    mov ecx, r15d
    sub ecx, r13d
    mov byte ptr [rdx + rcx], al
    inc r15d
    jmp .Lti_surround_copy
.Lti_surround_copy_done:
    mov eax, r14d
    sub eax, r13d
    mov ecx, eax
    lea rdx, [rip + text_input_request_buffer + 4]
    mov byte ptr [rdx + rcx], 0
    inc ecx
    lea eax, [rcx + 3]
    and eax, -4
    mov r15d, eax
    mov eax, r12d
    sub eax, r13d
    mov dword ptr [rdx + r15], eax
    mov eax, r12d
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lti_surround_anchor_ready
    mov eax, dword ptr [rip + doc_selection_anchor]
.Lti_surround_anchor_ready:
    sub eax, r13d
    test eax, eax
    jns .Lti_surround_anchor_low
    xor eax, eax
.Lti_surround_anchor_low:
    mov ecx, dword ptr [rip + text_input_request_buffer]
    dec ecx
    cmp eax, ecx
    jbe .Lti_surround_anchor_clamped
    mov eax, ecx
.Lti_surround_anchor_clamped:
    mov dword ptr [rdx + r15 + 4], eax
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 3
    lea rdx, [rip + text_input_request_buffer]
    mov ecx, r15d
    add ecx, 12
    call wl_send_request
    test rax, rax
    js .Lti_update_return

    cmp dword ptr [rip + text_input_preedit_length], 0
    je .Lti_cursor_rect_document
    cmp dword ptr [rip + text_input_preedit_cursor_begin], -1
    je .Lti_cursor_rect_document
    call text_input_preedit_caret_position
    mov r13d, eax
    mov eax, edx
    jmp .Lti_cursor_rect_ready
.Lti_cursor_rect_document:
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov r12d, eax
    lea r13d, [rdx + DOC_LEFT]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Lti_cursor_rect_document_y
    sub r13d, dword ptr [rip + doc_view_left_px]
.Lti_cursor_rect_document_y:
    mov eax, r12d
    sub eax, dword ptr [rip + doc_view_top_row]
    imul eax, dword ptr [rip + window_doc_line_height]
    add eax, DOC_TOP
.Lti_cursor_rect_ready:
    mov dword ptr [rip + payload_buffer], r13d
    mov dword ptr [rip + payload_buffer + 4], eax
    mov dword ptr [rip + payload_buffer + 8], 1
    mov eax, dword ptr [rip + window_doc_line_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov edi, dword ptr [rip + text_input_object]
    mov esi, 6
    lea rdx, [rip + payload_buffer]
    mov ecx, 16
    call wl_send_request
    test rax, rax
    js .Lti_update_return
    call text_input_commit_request
    jmp .Lti_update_return
.Lti_update_done:
    xor eax, eax
.Lti_update_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size text_input_update_state, . - text_input_update_state

# A Wayland string is length-prefixed and NUL-terminated; copy it before the
# protocol event buffer can be reused. RDI=destination, ESI=capacity, EDX=tail bytes.
.type text_input_copy_event_string, @function
text_input_copy_event_string:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13d, esi
    mov r14d, edx
    cmp dword ptr [rip + last_size], 4
    jb .Lti_string_bad
    mov ebx, dword ptr [rip + event_payload]
    test ebx, ebx
    jz .Lti_string_empty
    cmp ebx, r13d
    ja .Lti_string_bad
    mov eax, ebx
    add eax, 3
    and eax, -4
    add eax, 4
    add eax, r14d
    cmp eax, dword ptr [rip + last_size]
    ja .Lti_string_bad
    lea rsi, [rip + event_payload + 4]
    movzx eax, byte ptr [rsi + rbx - 1]
    test eax, eax
    jnz .Lti_string_bad
    dec ebx
    xor ecx, ecx
.Lti_string_copy:
    cmp ecx, ebx
    jae .Lti_string_done
    mov al, byte ptr [rsi + rcx]
    test al, al
    jz .Lti_string_bad
    mov byte ptr [r12 + rcx], al
    inc ecx
    jmp .Lti_string_copy
.Lti_string_done:
    mov eax, ebx
    jmp .Lti_string_return
.Lti_string_empty:
    xor eax, eax
.Lti_string_return:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.Lti_string_bad:
    mov eax, -1
    jmp .Lti_string_return
.size text_input_copy_event_string, . - text_input_copy_event_string

# Reject malformed UTF-8 from protocol strings before they enter the gap buffer.
.type text_input_validate_utf8, @function
text_input_validate_utf8:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13d, esi
    xor ebx, ebx
.Lti_utf8_loop:
    cmp ebx, r13d
    jae .Lti_utf8_valid
    movzx eax, byte ptr [r12 + rbx]
    test eax, eax
    jz .Lti_utf8_invalid
    cmp eax, 0x80
    jb .Lti_utf8_one
    cmp eax, 0xc2
    jb .Lti_utf8_invalid
    cmp eax, 0xdf
    jbe .Lti_utf8_two
    cmp eax, 0xef
    jbe .Lti_utf8_three
    cmp eax, 0xf4
    jbe .Lti_utf8_four
    jmp .Lti_utf8_invalid
.Lti_utf8_one:
    inc ebx
    jmp .Lti_utf8_loop
.Lti_utf8_two:
    lea edx, [rbx + 2]
    cmp edx, r13d
    ja .Lti_utf8_invalid
    movzx eax, byte ptr [r12 + rbx + 1]
    and eax, 0xc0
    cmp eax, 0x80
    jne .Lti_utf8_invalid
    add ebx, 2
    jmp .Lti_utf8_loop
.Lti_utf8_three:
    lea edx, [rbx + 3]
    cmp edx, r13d
    ja .Lti_utf8_invalid
    movzx eax, byte ptr [r12 + rbx + 1]
    cmp eax, 0x80
    jb .Lti_utf8_invalid
    cmp eax, 0xbf
    ja .Lti_utf8_invalid
    movzx edx, byte ptr [r12 + rbx]
    cmp edx, 0xe0
    jne .Lti_utf8_three_ed
    cmp eax, 0xa0
    jb .Lti_utf8_invalid
.Lti_utf8_three_ed:
    cmp edx, 0xed
    jne .Lti_utf8_three_third
    cmp eax, 0x9f
    ja .Lti_utf8_invalid
.Lti_utf8_three_third:
    movzx eax, byte ptr [r12 + rbx + 2]
    and eax, 0xc0
    cmp eax, 0x80
    jne .Lti_utf8_invalid
    add ebx, 3
    jmp .Lti_utf8_loop
.Lti_utf8_four:
    lea edx, [rbx + 4]
    cmp edx, r13d
    ja .Lti_utf8_invalid
    movzx eax, byte ptr [r12 + rbx + 1]
    cmp eax, 0x80
    jb .Lti_utf8_invalid
    cmp eax, 0xbf
    ja .Lti_utf8_invalid
    movzx edx, byte ptr [r12 + rbx]
    cmp edx, 0xf0
    jne .Lti_utf8_four_f4
    cmp eax, 0x90
    jb .Lti_utf8_invalid
    jmp .Lti_utf8_four_tail
.Lti_utf8_four_f4:
    cmp edx, 0xf4
    jne .Lti_utf8_four_tail
    cmp eax, 0x8f
    ja .Lti_utf8_invalid
.Lti_utf8_four_tail:
    movzx eax, byte ptr [r12 + rbx + 2]
    and eax, 0xc0
    cmp eax, 0x80
    jne .Lti_utf8_invalid
    movzx eax, byte ptr [r12 + rbx + 3]
    and eax, 0xc0
    cmp eax, 0x80
    jne .Lti_utf8_invalid
    add ebx, 4
    jmp .Lti_utf8_loop
.Lti_utf8_valid:
    mov eax, 1
    jmp .Lti_utf8_done
.Lti_utf8_invalid:
    xor eax, eax
.Lti_utf8_done:
    pop r13
    pop r12
    pop rbx
    ret
.size text_input_validate_utf8, . - text_input_validate_utf8

.type text_input_handle_event, @function
text_input_handle_event:
    cmp edi, 0
    je .Lti_enter
    cmp edi, 1
    je .Lti_leave
    cmp edi, 2
    je .Lti_preedit
    cmp edi, 3
    je .Lti_commit
    cmp edi, 4
    je .Lti_delete
    cmp edi, 5
    je .Lti_done
    xor eax, eax
    ret
.Lti_enter:
    cmp dword ptr [rip + last_size], 4
    jb .Lti_ignored
    cmp dword ptr [rip + event_payload], 8
    jne .Lti_ignored
    mov dword ptr [rip + text_input_entered], 1
    mov dword ptr [rip + text_input_state_ready], 1
    mov dword ptr [rip + text_input_pending_flags], 0
    mov eax, 2
    ret
.Lti_leave:
    cmp dword ptr [rip + last_size], 4
    jb .Lti_ignored
    cmp dword ptr [rip + event_payload], 8
    jne .Lti_ignored
    mov dword ptr [rip + text_input_entered], 0
    mov dword ptr [rip + text_input_pending_flags], 0
    mov dword ptr [rip + text_input_preedit_length], 0
    mov dword ptr [rip + text_input_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_preedit_cursor_end], -1
    mov eax, 2
    ret
.Lti_preedit:
    cmp dword ptr [rip + last_size], 12
    jb .Lti_ignored
    # Stage candidate bytes and metadata in the unused tail of request_buffer.
    # Do not touch the actual pending preedit until UTF-8 and cursor validation pass.
    lea rdi, [rip + text_input_request_buffer]
    mov esi, 4096
    mov edx, 8
    call text_input_copy_event_string
    test eax, eax
    js .Lti_ignored
    mov dword ptr [rip + text_input_request_buffer + 4096], eax
    lea rdi, [rip + text_input_request_buffer]
    mov esi, eax
    call text_input_validate_utf8
    test eax, eax
    jz .Lti_ignored
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    jz .Lti_preedit_null
    add eax, 3
    and eax, -4
    lea rdx, [rip + event_payload + 4]
    mov ecx, dword ptr [rdx + rax]
    mov dword ptr [rip + text_input_request_buffer + 4100], ecx
    mov ecx, dword ptr [rdx + rax + 4]
    mov dword ptr [rip + text_input_request_buffer + 4104], ecx
    jmp .Lti_preedit_validate
.Lti_preedit_null:
    lea rdx, [rip + event_payload + 4]
    mov ecx, dword ptr [rdx]
    mov dword ptr [rip + text_input_request_buffer + 4100], ecx
    mov ecx, dword ptr [rdx + 4]
    mov dword ptr [rip + text_input_request_buffer + 4104], ecx
.Lti_preedit_validate:
    mov ecx, dword ptr [rip + text_input_request_buffer + 4100]
    mov edx, dword ptr [rip + text_input_request_buffer + 4104]
    cmp ecx, -1
    jne .Lti_preedit_begin_visible
    cmp edx, -1
    jne .Lti_ignored
    jmp .Lti_preedit_commit_candidate
.Lti_preedit_begin_visible:
    test ecx, ecx
    js .Lti_ignored
    cmp ecx, dword ptr [rip + text_input_request_buffer + 4096]
    ja .Lti_ignored
    je .Lti_preedit_validate_end
    lea rax, [rip + text_input_request_buffer]
    movzx eax, byte ptr [rax + rcx]
    and eax, 0xc0
    cmp eax, 0x80
    je .Lti_ignored
.Lti_preedit_validate_end:
    cmp edx, -1
    je .Lti_ignored
    test edx, edx
    js .Lti_ignored
    cmp edx, dword ptr [rip + text_input_request_buffer + 4096]
    jbe .Lti_preedit_validate_end_in_range
    # Mutter 46.0-46.2 also forwards a character-index anchor when the
    # preedit is NULL: Shell calls set_preedit_text(NULL, 1, 1), producing
    # the invalid empty-string byte range (0, 1). Empty preedit has only
    # one valid byte boundary, so repair this exact nullable (0, 1) form.
    cmp dword ptr [rip + event_payload], 0
    jne .Lti_ignored
    cmp dword ptr [rip + text_input_request_buffer + 4096], 0
    jne .Lti_ignored
    test ecx, ecx
    jnz .Lti_ignored
    cmp edx, 1
    jne .Lti_ignored
    xor edx, edx
    mov dword ptr [rip + text_input_request_buffer + 4104], edx
    jmp .Lti_preedit_commit_candidate
.Lti_preedit_validate_end_in_range:
    cmp edx, dword ptr [rip + text_input_request_buffer + 4096]
    je .Lti_preedit_commit_candidate
    lea rax, [rip + text_input_request_buffer]
    movzx eax, byte ptr [rax + rdx]
    and eax, 0xc0
    cmp eax, 0x80
    jne .Lti_preedit_commit_candidate
    # Mutter 46.0-46.2 converted cursor_begin to UTF-8 bytes but sent
    # cursor_end/anchor as a Unicode-character index. Repair only the
    # collapsed-caret case: the end offset is inside a continuation byte,
    # and interpreting it as a character index lands exactly on the already
    # validated byte cursor. Other malformed ranges remain rejected.
    mov r11d, ecx
    mov r10d, edx
    xor r9d, r9d
    xor r8d, r8d
.Lti_preedit_anchor_legacy_convert:
    cmp r8d, r10d
    jae .Lti_preedit_anchor_legacy_check
    cmp r9d, dword ptr [rip + text_input_request_buffer + 4096]
    jae .Lti_ignored
    lea rdi, [rip + text_input_request_buffer]
    mov esi, r9d
    mov edx, dword ptr [rip + text_input_request_buffer + 4096]
    call text_input_decode_scalar
    test edx, edx
    jz .Lti_ignored
    add r9d, edx
    inc r8d
    jmp .Lti_preedit_anchor_legacy_convert
.Lti_preedit_anchor_legacy_check:
    cmp r9d, r11d
    jne .Lti_ignored
    mov edx, r9d
    # The normal acceptance path copies cursor_end from the staged payload,
    # so persist the corrected byte offset before entering that path.
    mov dword ptr [rip + text_input_request_buffer + 4104], edx
    jmp .Lti_preedit_commit_candidate
.Lti_preedit_commit_candidate:
    mov eax, dword ptr [rip + text_input_request_buffer + 4096]
    mov dword ptr [rip + text_input_pending_preedit_length], eax
    mov eax, dword ptr [rip + text_input_request_buffer + 4100]
    mov dword ptr [rip + text_input_pending_preedit_cursor_begin], eax
    mov eax, dword ptr [rip + text_input_request_buffer + 4104]
    mov dword ptr [rip + text_input_pending_preedit_cursor_end], eax
    lea rsi, [rip + text_input_request_buffer]
    lea rdi, [rip + text_input_pending_preedit_buffer]
    mov ecx, dword ptr [rip + text_input_pending_preedit_length]
    rep movsb
    or dword ptr [rip + text_input_pending_flags], 2
    xor eax, eax
    ret
.Lti_commit:
    lea rdi, [rip + text_input_commit_buffer]
    mov esi, 4096
    xor edx, edx
    call text_input_copy_event_string
    test eax, eax
    js .Lti_ignored
    mov dword ptr [rip + text_input_pending_commit_length], eax
    lea rdi, [rip + text_input_commit_buffer]
    mov esi, eax
    call text_input_validate_utf8
    test eax, eax
    jz .Lti_ignored
    or dword ptr [rip + text_input_pending_flags], 1
    xor eax, eax
    ret
.Lti_delete:
    cmp dword ptr [rip + last_size], 8
    jb .Lti_ignored
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + text_input_pending_delete_before], eax
    mov eax, dword ptr [rip + event_payload + 4]
    mov dword ptr [rip + text_input_pending_delete_after], eax
    or dword ptr [rip + text_input_pending_flags], 4
    xor eax, eax
    ret
.Lti_done:
    cmp dword ptr [rip + last_size], 4
    jb .Lti_ignored
    push r12
    mov r12d, dword ptr [rip + text_input_state_ready]
    mov eax, dword ptr [rip + event_payload]
    cmp eax, dword ptr [rip + text_input_commit_serial]
    sete dl
    movzx edx, dl
    mov dword ptr [rip + text_input_state_ready], edx
    call text_input_apply_done
    cmp dword ptr [rip + text_input_state_ready], 1
    jne .Lti_done_redraw_only
    test r12d, r12d
    jz .Lti_done_resync
    test eax, eax
    jnz .Lti_done_resync
.Lti_done_redraw_only:
    mov eax, 1
    pop r12
    ret
.Lti_done_resync:
    mov eax, 2
    pop r12
    ret
.Lti_ignored:
    xor eax, eax
    ret
.size text_input_handle_event, . - text_input_handle_event

# Apply delete-surrounding and commit-string as a single journal operation.
.type text_input_apply_done, @function
text_input_apply_done:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16
    xor r15d, r15d
    xor ebx, ebx
    cmp dword ptr [rip + text_input_enabled], 1
    jne .Lti_apply_clear
    mov ebx, dword ptr [rip + text_input_pending_flags]
    test ebx, 4
    jz .Lti_apply_commit_text
    mov r12d, dword ptr [rip + text_input_pending_delete_before]
    mov r13d, dword ptr [rip + text_input_pending_delete_after]
    mov r14d, dword ptr [rip + doc_cursor]
    cmp r12d, r14d
    jbe .Lti_apply_delete_before_clamped
    mov r12d, r14d
.Lti_apply_delete_before_clamped:
    mov eax, dword ptr [rip + doc_length]
    sub eax, r14d
    cmp r13d, eax
    jbe .Lti_apply_delete_after_clamped
    mov r13d, eax
.Lti_apply_delete_after_clamped:

    # Start/end are byte offsets in the committed document. If the editor
    # currently has a selection, the protocol requires that it be deleted too,
    # even when both surrounding lengths are zero.
    mov edi, r14d
    sub edi, r12d
    mov dword ptr [rsp], edi
    mov eax, r14d
    add eax, r13d
    mov dword ptr [rsp + 4], eax
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lti_apply_delete_selection_union_done
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, r14d
    cmp eax, edx
    jbe .Lti_apply_delete_selection_ordered
    xchg eax, edx
.Lti_apply_delete_selection_ordered:
    cmp eax, dword ptr [rsp]
    jae .Lti_apply_delete_selection_start_ready
    mov dword ptr [rsp], eax
.Lti_apply_delete_selection_start_ready:
    cmp edx, dword ptr [rsp + 4]
    jbe .Lti_apply_delete_selection_union_done
    mov dword ptr [rsp + 4], edx
.Lti_apply_delete_selection_union_done:
    # Expand a byte range outwards when the input method's requested index
    # falls inside a UTF-8 scalar. This guarantees that at least the requested
    # number of bytes is removed without leaving a truncated code point.
.Lti_apply_delete_align_start:
    mov edi, dword ptr [rsp]
    test edi, edi
    jz .Lti_apply_delete_align_end
    call doc_byte_at
    mov edx, eax
    and edx, 0xc0
    cmp edx, 0x80
    jne .Lti_apply_delete_align_end
    dec dword ptr [rsp]
    jmp .Lti_apply_delete_align_start
.Lti_apply_delete_align_end:
    mov edi, dword ptr [rsp + 4]
    cmp edi, dword ptr [rip + doc_length]
    jae .Lti_apply_delete_bounds_ok
    call doc_byte_at
    mov edx, eax
    and edx, 0xc0
    cmp edx, 0x80
    jne .Lti_apply_delete_bounds_ok
    inc dword ptr [rsp + 4]
    jmp .Lti_apply_delete_align_end
.Lti_apply_delete_bounds_ok:
    mov eax, dword ptr [rsp]
    cmp eax, dword ptr [rsp + 4]
    jae .Lti_apply_commit_text
    call history_begin_action
    mov eax, dword ptr [rsp]
    mov dword ptr [rip + doc_selection_anchor], eax
    mov eax, dword ptr [rsp + 4]
    mov dword ptr [rip + doc_cursor], eax
    mov dword ptr [rip + doc_selection_active], 1
    call doc_delete_selection
    mov r15d, 1
    jmp .Lti_apply_commit_text
.Lti_apply_commit_text:
    test ebx, 1
    jz .Lti_apply_history_end
    cmp dword ptr [rip + text_input_pending_commit_length], 0
    je .Lti_apply_history_end
    test r15d, r15d
    jnz .Lti_apply_commit_history_ready
    call history_begin_action
.Lti_apply_commit_history_ready:
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lti_apply_insert
    call doc_delete_selection
    mov r15d, 1
.Lti_apply_insert:
    xor r12d, r12d
.Lti_apply_insert_loop:
    cmp r12d, dword ptr [rip + text_input_pending_commit_length]
    jae .Lti_apply_history_end
    mov r15d, 1
    lea rax, [rip + text_input_commit_buffer]
    movzx edi, byte ptr [rax + r12]
    call doc_insert_byte
    inc r12d
    jmp .Lti_apply_insert_loop
.Lti_apply_history_end:
    test r15d, r15d
    jz .Lti_apply_preedit
    call history_commit_action
.Lti_apply_preedit:
    test ebx, 1
    jz .Lti_apply_new_preedit
    mov dword ptr [rip + text_input_preedit_length], 0
    mov dword ptr [rip + text_input_preedit_cursor_begin], -1
    mov dword ptr [rip + text_input_preedit_cursor_end], -1
.Lti_apply_new_preedit:
    test ebx, 2
    jz .Lti_apply_clear
    mov eax, dword ptr [rip + text_input_pending_preedit_length]
    mov dword ptr [rip + text_input_preedit_length], eax
    mov eax, dword ptr [rip + text_input_pending_preedit_cursor_begin]
    mov dword ptr [rip + text_input_preedit_cursor_begin], eax
    mov eax, dword ptr [rip + text_input_pending_preedit_cursor_end]
    mov dword ptr [rip + text_input_preedit_cursor_end], eax
    lea rsi, [rip + text_input_pending_preedit_buffer]
    lea rdi, [rip + text_input_preedit_buffer]
    mov ecx, dword ptr [rip + text_input_preedit_length]
    rep movsb
.Lti_apply_clear:
    mov dword ptr [rip + text_input_pending_flags], 0
    mov dword ptr [rip + text_input_pending_delete_before], 0
    mov dword ptr [rip + text_input_pending_delete_after], 0
    mov dword ptr [rip + text_input_pending_commit_length], 0
    mov dword ptr [rip + text_input_pending_preedit_length], 0
    mov eax, r15d
    test ebx, 3
    jz .Lti_apply_return_flags_ready
    or eax, 2
.Lti_apply_return_flags_ready:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size text_input_apply_done, . - text_input_apply_done

.type text_input_decode_scalar, @function
text_input_decode_scalar:
    movzx eax, byte ptr [rdi + rsi]
    cmp eax, 0x80
    jb .Lti_decode_one
    cmp eax, 0xe0
    jb .Lti_decode_two
    cmp eax, 0xf0
    jb .Lti_decode_three
    and eax, 7
    shl eax, 18
    movzx ecx, byte ptr [rdi + rsi + 1]
    and ecx, 0x3f
    shl ecx, 12
    or eax, ecx
    movzx ecx, byte ptr [rdi + rsi + 2]
    and ecx, 0x3f
    shl ecx, 6
    or eax, ecx
    movzx ecx, byte ptr [rdi + rsi + 3]
    and ecx, 0x3f
    or eax, ecx
    mov edx, 4
    ret
.Lti_decode_three:
    and eax, 0x0f
    shl eax, 12
    movzx ecx, byte ptr [rdi + rsi + 1]
    and ecx, 0x3f
    shl ecx, 6
    or eax, ecx
    movzx ecx, byte ptr [rdi + rsi + 2]
    and ecx, 0x3f
    or eax, ecx
    mov edx, 3
    ret
.Lti_decode_two:
    and eax, 0x1f
    shl eax, 6
    movzx ecx, byte ptr [rdi + rsi + 1]
    and ecx, 0x3f
    or eax, ecx
    mov edx, 2
    ret
.Lti_decode_one:
    mov edx, 1
    ret
.size text_input_decode_scalar, . - text_input_decode_scalar

# Render the pending composition as underlined text at the document caret.
# The input-method cursor offset is measured in UTF-8 bytes.
.type render_text_input_preedit, @function
render_text_input_preedit:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32
    mov r12d, edi
    mov r13d, esi
    mov dword ptr [rsp], edi
    mov dword ptr [rsp + 4], esi
    mov dword ptr [rsp + 8], 0
    mov dword ptr [rsp + 12], 1
    cmp dword ptr [rip + text_input_enabled], 1
    jne .Lti_preedit_return_base
    mov r15d, dword ptr [rip + text_input_preedit_length]
    test r15d, r15d
    jz .Lti_preedit_return_base
    mov ebx, dword ptr [rip + text_input_preedit_cursor_begin]
    cmp ebx, -1
    je .Lti_preedit_hide_caret
    mov eax, dword ptr [rip + text_input_preedit_cursor_end]
    cmp ebx, eax
    jbe .Lti_preedit_range_ordered
    xchg ebx, eax
.Lti_preedit_range_ordered:
    mov dword ptr [rsp + 24], eax
    cmp ebx, eax
    je .Lti_preedit_collapsed_caret
    # cursor_begin..cursor_end represents a highlighted preedit span; the
    # normal document caret is hidden while this range is selected.
    mov dword ptr [rsp + 12], 0
.Lti_preedit_collapsed_caret:
    xor r14d, r14d
.Lti_preedit_render_loop:
    cmp r14d, r15d
    jae .Lti_preedit_render_end
    cmp r14d, ebx
    jne .Lti_preedit_decode
    mov dword ptr [rsp], r12d
    mov dword ptr [rsp + 4], r13d
    mov dword ptr [rsp + 8], 1
.Lti_preedit_decode:
    lea rdi, [rip + text_input_preedit_buffer]
    mov esi, r14d
    mov edx, r15d
    call text_input_decode_scalar
    mov dword ptr [rsp + 16], eax
    mov dword ptr [rsp + 20], edx
    mov edi, eax
    call font_codepoint_advance_pixels
    mov ebp, eax
    mov eax, r12d
    add eax, ebp
    mov edx, DOC_LEFT
    add edx, dword ptr [rip + window_doc_pixel_width]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lti_preedit_render_fit
    cmp eax, edx
    jbe .Lti_preedit_render_fit
    mov r12d, DOC_LEFT
    add r13d, dword ptr [rip + window_doc_line_height]
.Lti_preedit_render_fit:
    cmp r13d, DOC_TOP
    jl .Lti_preedit_render_advance
    mov eax, dword ptr [rip + window_doc_bottom]
    cmp r13d, eax
    jae .Lti_preedit_render_advance
    mov eax, dword ptr [rsp + 24]
    cmp ebx, eax
    je .Lti_preedit_render_glyph
    cmp r14d, ebx
    jb .Lti_preedit_render_glyph
    cmp r14d, eax
    jae .Lti_preedit_render_glyph
    # Paint a subtle selection fill behind the selected preedit code points.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, ebp
    test ecx, ecx
    jnz .Lti_preedit_highlight_width
    mov ecx, 1
.Lti_preedit_highlight_width:
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_rect
.Lti_preedit_render_glyph:
    mov edi, r12d
    mov esi, r13d
    mov edx, dword ptr [rsp + 16]
    mov ecx, dword ptr [rip + doc_font_size]
    call draw_glyph
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    add edx, dword ptr [rip + window_doc_line_height]
    sub edx, 2
    mov ecx, ebp
    test ecx, ecx
    jnz .Lti_preedit_underline_width
    mov ecx, 1
.Lti_preedit_underline_width:
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect
.Lti_preedit_render_advance:
    add r12d, ebp
    mov eax, dword ptr [rsp + 20]
    add r14d, eax
    jmp .Lti_preedit_render_loop
.Lti_preedit_render_end:
    cmp dword ptr [rsp + 8], 1
    je .Lti_preedit_render_return
    cmp ebx, r15d
    jne .Lti_preedit_render_return
    mov dword ptr [rsp], r12d
    mov dword ptr [rsp + 4], r13d
    mov dword ptr [rsp + 8], 1
    jmp .Lti_preedit_render_return
.Lti_preedit_hide_caret:
    mov dword ptr [rsp + 12], 0
    jmp .Lti_preedit_render_return
.Lti_preedit_return_base:
    mov dword ptr [rsp], r12d
    mov dword ptr [rsp + 4], r13d
.Lti_preedit_render_return:
    mov eax, dword ptr [rsp]
    mov edx, dword ptr [rsp + 4]
    mov ecx, dword ptr [rsp + 12]
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size render_text_input_preedit, . - render_text_input_preedit

# Window geometry is shared by rendering, hit-testing, and buffer allocation.
.type window_update_geometry, @function
window_update_geometry:
    # Uniform density maps the existing virtual UI coordinate space to the
    # compositor surface. Use the smaller axis so text and controls never warp.
    mov eax, dword ptr [rip + window_surface_width]
    imul eax, 120
    xor edx, edx
    mov ecx, WIDTH
    div ecx
    mov r8d, eax
    mov eax, dword ptr [rip + window_surface_height]
    imul eax, 120
    xor edx, edx
    mov ecx, HEIGHT
    div ecx
    cmp eax, r8d
    jae .window_geometry_density_selected
    mov r8d, eax
.window_geometry_density_selected:
    cmp r8d, 90
    jae .window_geometry_density_min_ready
    mov r8d, 90
.window_geometry_density_min_ready:
    cmp r8d, 240
    jbe .window_geometry_density_max_ready
    mov r8d, 240
.window_geometry_density_max_ready:
    test r8d, r8d
    jnz .window_geometry_density_valid
    mov r8d, 120
.window_geometry_density_valid:
    mov dword ptr [rip + window_ui_scale_120], r8d
    mov eax, dword ptr [rip + window_surface_width]
    imul eax, 120
    xor edx, edx
    div r8d
    test eax, eax
    jnz .window_geometry_virtual_width_ready
    mov eax, 1
.window_geometry_virtual_width_ready:
    mov dword ptr [rip + window_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    imul eax, 120
    xor edx, edx
    div r8d
    test eax, eax
    jnz .window_geometry_virtual_height_ready
    mov eax, 1
.window_geometry_virtual_height_ready:
    mov dword ptr [rip + window_height], eax

    # Keep Wayland's integer buffer-scale state separate from raster density.
    # Fractional-scale-v1 uses wl_surface buffer_scale=1 and an exact
    # 120ths backing raster through wp_viewport.
    mov eax, 1
    cmp dword ptr [rip + fractional_scale_enabled], 1
    je .window_geometry_buffer_scale_ready
    cmp dword ptr [rip + compositor_version], 3
    jb .window_geometry_buffer_scale_ready
    mov edx, dword ptr [rip + surface_effective_buffer_scale]
    cmp edx, 2
    jb .window_geometry_buffer_scale_ready
    mov eax, dword ptr [rip + window_surface_width]
    cmp eax, (MAX_WINDOW_WIDTH / MAX_BUFFER_SCALE)
    ja .window_geometry_buffer_scale_ready
    mov eax, dword ptr [rip + window_surface_height]
    cmp eax, (MAX_WINDOW_HEIGHT / MAX_BUFFER_SCALE)
    ja .window_geometry_buffer_scale_ready
    mov eax, MAX_BUFFER_SCALE
.window_geometry_buffer_scale_ready:
    mov dword ptr [rip + window_buffer_scale], eax
    xor edx, edx
    cmp dword ptr [rip + compositor_version], 6
    jb .window_geometry_transform_ready
    mov edx, dword ptr [rip + surface_preferred_buffer_transform]
.window_geometry_transform_ready:
    mov dword ptr [rip + window_buffer_transform], edx

    cmp dword ptr [rip + fractional_scale_enabled], 1
    jne .window_geometry_integer_raster_scale
    mov r8d, dword ptr [rip + surface_preferred_fractional_scale]
    test r8d, r8d
    jnz .window_geometry_fractional_scale_ready
    mov r8d, 120
.window_geometry_fractional_scale_ready:
    # Cap at 2x and at the actual two-slot SHM dimensions. Rotated buffers
    # exchange the width/height capacity axes.
    cmp r8d, (MAX_BUFFER_SCALE * 120)
    jbe .window_geometry_fractional_cap_ready
    mov r8d, (MAX_BUFFER_SCALE * 120)
.window_geometry_fractional_cap_ready:
    test dword ptr [rip + window_buffer_transform], 1
    jnz .window_geometry_fractional_cap_rotated
    mov eax, (MAX_WINDOW_WIDTH * 120)
    xor edx, edx
    div dword ptr [rip + window_surface_width]
    cmp r8d, eax
    jbe .window_geometry_fractional_cap_width_ready
    mov r8d, eax
.window_geometry_fractional_cap_width_ready:
    mov eax, (MAX_WINDOW_HEIGHT * 120)
    xor edx, edx
    div dword ptr [rip + window_surface_height]
    cmp r8d, eax
    jbe .window_geometry_fractional_cap_store
    mov r8d, eax
    jmp .window_geometry_fractional_cap_store
.window_geometry_fractional_cap_rotated:
    mov eax, (MAX_WINDOW_WIDTH * 120)
    xor edx, edx
    div dword ptr [rip + window_surface_height]
    cmp r8d, eax
    jbe .window_geometry_fractional_cap_rotated_width_ready
    mov r8d, eax
.window_geometry_fractional_cap_rotated_width_ready:
    mov eax, (MAX_WINDOW_HEIGHT * 120)
    xor edx, edx
    div dword ptr [rip + window_surface_width]
    cmp r8d, eax
    jbe .window_geometry_fractional_cap_store
    mov r8d, eax
.window_geometry_fractional_cap_store:
    test r8d, r8d
    jnz .window_geometry_fractional_scale_store
    mov r8d, 1
.window_geometry_fractional_scale_store:
    mov dword ptr [rip + window_buffer_raster_scale_120], r8d
    jmp .window_geometry_raster_dimensions

.window_geometry_integer_raster_scale:
    mov eax, dword ptr [rip + window_buffer_scale]
    imul eax, 120
    mov dword ptr [rip + window_buffer_raster_scale_120], eax

.window_geometry_raster_dimensions:
    # Round positive dimensions to nearest; an exact half rounds away from zero.
    mov eax, dword ptr [rip + window_surface_width]
    imul eax, dword ptr [rip + window_buffer_raster_scale_120]
    add eax, 60
    xor edx, edx
    mov ecx, 120
    div ecx
    test eax, eax
    jnz .window_geometry_raster_width_ready
    mov eax, 1
.window_geometry_raster_width_ready:
    mov dword ptr [rip + window_raster_surface_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    imul eax, dword ptr [rip + window_buffer_raster_scale_120]
    add eax, 60
    xor edx, edx
    mov ecx, 120
    div ecx
    test eax, eax
    jnz .window_geometry_raster_height_ready
    mov eax, 1
.window_geometry_raster_height_ready:
    mov dword ptr [rip + window_raster_surface_height], eax
    mov eax, dword ptr [rip + window_raster_surface_width]
    mov edx, dword ptr [rip + window_raster_surface_height]
    test dword ptr [rip + window_buffer_transform], 1
    jnz .window_geometry_swapped_axes
    mov dword ptr [rip + window_buffer_width], eax
    mov dword ptr [rip + window_buffer_height], edx
    jmp .window_geometry_stride
.window_geometry_swapped_axes:
    mov dword ptr [rip + window_buffer_width], edx
    mov dword ptr [rip + window_buffer_height], eax
.window_geometry_stride:
    mov eax, dword ptr [rip + window_buffer_width]
    shl eax, 2
    mov dword ptr [rip + window_stride], eax
    mov eax, dword ptr [rip + window_height]
    sub eax, 20
    mov dword ptr [rip + window_status_top], eax
    mov eax, dword ptr [rip + window_status_top]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .window_geometry_bottom_ready
    sub eax, DOC_HSCROLL_HEIGHT
.window_geometry_bottom_ready:
    mov dword ptr [rip + window_doc_bottom], eax
    mov eax, dword ptr [rip + window_width]
    sub eax, DOC_LEFT + DOC_SCROLL_TRACK_X_OFFSET
    test eax, eax
    jg .window_geometry_pixel_width_ready
    mov eax, 1
.window_geometry_pixel_width_ready:
    mov dword ptr [rip + window_doc_pixel_width], eax
    mov eax, dword ptr [rip + doc_font_size]
    test eax, eax
    jnz .window_geometry_em_ready
    mov eax, LINE_HEIGHT
.window_geometry_em_ready:
    cmp dword ptr [rip + font_loaded], 0
    je .window_geometry_line_height_ready
    mov eax, dword ptr [rip + font_ascent]
    sub eax, dword ptr [rip + font_descent]
    add eax, dword ptr [rip + font_line_gap]
    test eax, eax
    jle .window_geometry_line_height_default
    imul eax, dword ptr [rip + doc_font_size]
    mov ecx, dword ptr [rip + font_units_per_em]
    test ecx, ecx
    jle .window_geometry_line_height_default
    add eax, ecx
    dec eax
    xor edx, edx
    div ecx
    cmp eax, dword ptr [rip + doc_font_size]
    jae .window_geometry_line_height_minimum_ready
    mov eax, dword ptr [rip + doc_font_size]
.window_geometry_line_height_minimum_ready:
    cmp eax, 48
    jbe .window_geometry_line_height_ready
    mov eax, 48
    jmp .window_geometry_line_height_ready
.window_geometry_line_height_default:
    mov eax, dword ptr [rip + doc_font_size]
    test eax, eax
    jnz .window_geometry_line_height_ready
    mov eax, LINE_HEIGHT
.window_geometry_line_height_ready:
    mov dword ptr [rip + window_doc_line_height], eax
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, DOC_TOP
    xor edx, edx
    mov ecx, dword ptr [rip + window_doc_line_height]
    div ecx
    test eax, eax
    jnz .window_geometry_rows_ready
    mov eax, 1
.window_geometry_rows_ready:
    mov dword ptr [rip + window_doc_visible_rows], eax
    call window_update_layout_geometry
    # Pointer enter may precede output discovery; rebase saved surface coordinates.
    mov eax, dword ptr [rip + pointer_surface_x]
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_x], eax
    mov eax, dword ptr [rip + pointer_surface_y]
    imul eax, 120
    xor edx, edx
    div dword ptr [rip + window_ui_scale_120]
    mov dword ptr [rip + pointer_y], eax
    ret
.size window_update_geometry, . - window_update_geometry

# Recalculate window-anchored and centered overlay geometry after every configure.
.type window_update_layout_geometry, @function
window_update_layout_geometry:
    push rbx
    # Footer metadata is distributed across the available width. Preserve the
    # original 800px byte-count position while allowing it to move at all sizes.
    mov eax, dword ptr [rip + window_width]
    imul eax, 5
    xor edx, edx
    mov ecx, 8
    div ecx
    sub eax, 20
    mov dword ptr [rip + window_status_bytes_x], eax
    mov eax, dword ptr [rip + window_width]
    sub eax, 56
    mov dword ptr [rip + window_status_mode_x], eax

    # The picker keeps its 720x408 design size when possible. On smaller
    # windows, both dimensions shrink to a 16px outer margin and are centered.
    mov eax, dword ptr [rip + window_width]
    sub eax, 32
    cmp eax, 744
    jbe .window_layout_picker_width_ready
    mov eax, 744
.window_layout_picker_width_ready:
    mov dword ptr [rip + picker_panel_width], eax
    mov edx, dword ptr [rip + window_width]
    sub edx, eax
    shr edx, 1
    mov dword ptr [rip + picker_panel_x], edx

    mov eax, dword ptr [rip + window_height]
    sub eax, 32
    cmp eax, 424
    jbe .window_layout_picker_height_ready
    mov eax, 424
.window_layout_picker_height_ready:
    mov dword ptr [rip + picker_panel_height], eax
    mov edx, dword ptr [rip + window_height]
    sub edx, eax
    shr edx, 1
    mov dword ptr [rip + picker_panel_y], edx

    # The picker follows the UI font preference and shrinks only when the
    # fitted modal is smaller than its 720x408 design space.
    mov eax, dword ptr [rip + picker_panel_width]
    imul eax, 408
    mov edx, dword ptr [rip + picker_panel_height]
    imul edx, 720
    cmp eax, edx
    ja .window_layout_picker_font_height
    mov eax, dword ptr [rip + picker_panel_width]
    imul eax, dword ptr [rip + ui_font_size]
    xor edx, edx
    mov ecx, 720
    div ecx
    jmp .window_layout_picker_font_clamp
.window_layout_picker_font_height:
    mov eax, dword ptr [rip + picker_panel_height]
    imul eax, dword ptr [rip + ui_font_size]
    xor edx, edx
    mov ecx, 408
    div ecx
.window_layout_picker_font_clamp:
    cmp eax, 6
    jae .window_layout_picker_font_min_ready
    mov eax, 6
.window_layout_picker_font_min_ready:
    cmp eax, dword ptr [rip + ui_font_size]
    jbe .window_layout_picker_font_store
    mov eax, dword ptr [rip + ui_font_size]
.window_layout_picker_font_store:
    mov dword ptr [rip + picker_ui_font_size], eax

    # Settings keeps its 256x168 panel geometry independent of the
    # typography preference. Only the text raster grows/shrinks; the panel
    # still fits and centers against the actual window dimensions.
    mov r8d, 256
    mov ebx, dword ptr [rip + window_width]
    sub ebx, 32
    cmp r8d, ebx
    jbe .window_layout_settings_width_available
    mov r8d, ebx
.window_layout_settings_width_available:
    mov ebx, dword ptr [rip + window_height]
    sub ebx, 40
    imul ebx, 256
    mov eax, ebx
    xor edx, edx
    mov ecx, 192
    div ecx
    cmp r8d, eax
    jbe .window_layout_settings_scale_ready
    mov r8d, eax
.window_layout_settings_scale_ready:
    mov eax, r8d
    mov dword ptr [rip + settings_panel_width], eax
    imul eax, 192
    xor edx, edx
    mov ecx, 256
    div ecx
    mov dword ptr [rip + settings_panel_height], eax
    mov eax, dword ptr [rip + window_width]
    sub eax, dword ptr [rip + settings_panel_width]
    shr eax, 1
    mov dword ptr [rip + settings_panel_x], eax
    mov eax, dword ptr [rip + window_height]
    sub eax, dword ptr [rip + settings_panel_height]
    shr eax, 1
    mov dword ptr [rip + settings_panel_y], eax
    mov eax, dword ptr [rip + ui_font_size]
    imul eax, 256
    xor edx, edx
    mov ecx, dword ptr [rip + settings_panel_width]
    div ecx
    cmp eax, 6
    jae .window_layout_settings_font_min_ready
    mov eax, 6
.window_layout_settings_font_min_ready:
    mov dword ptr [rip + settings_ui_font_size], eax

    # Find/Replace also retains its 448x192 panel geometry while its
    # labels and field text use the selected physical UI font size.
    mov r8d, 448
    mov ebx, dword ptr [rip + window_width]
    sub ebx, 32
    cmp r8d, ebx
    jbe .window_layout_find_width_available
    mov r8d, ebx
.window_layout_find_width_available:
    mov ebx, dword ptr [rip + window_height]
    sub ebx, 32
    imul ebx, 448
    mov eax, ebx
    xor edx, edx
    mov ecx, 192
    div ecx
    cmp r8d, eax
    jbe .window_layout_find_scale_ready
    mov r8d, eax
.window_layout_find_scale_ready:
    mov eax, r8d
    mov dword ptr [rip + find_panel_width], eax
    imul eax, 192
    xor edx, edx
    mov ecx, 448
    div ecx
    mov dword ptr [rip + find_panel_height], eax
    mov eax, dword ptr [rip + window_width]
    sub eax, dword ptr [rip + find_panel_width]
    shr eax, 1
    mov dword ptr [rip + find_panel_x], eax
    mov eax, dword ptr [rip + window_height]
    sub eax, dword ptr [rip + find_panel_height]
    shr eax, 1
    mov dword ptr [rip + find_panel_y], eax
    mov eax, dword ptr [rip + ui_font_size]
    imul eax, 448
    xor edx, edx
    mov ecx, dword ptr [rip + find_panel_width]
    div ecx
    cmp eax, 6
    jae .window_layout_find_font_min_ready
    mov eax, 6
.window_layout_find_font_min_ready:
    mov dword ptr [rip + find_ui_font_size], eax

    # The path prompt uses the same fit-and-center policy with its 704x176
    # design dimensions. Its original four-pixel upward bias is retained.
    mov eax, dword ptr [rip + window_width]
    sub eax, 32
    cmp eax, 704
    jbe .window_layout_prompt_width_ready
    mov eax, 704
.window_layout_prompt_width_ready:
    mov dword ptr [rip + path_prompt_width], eax
    mov edx, dword ptr [rip + window_width]
    sub edx, eax
    shr edx, 1
    mov dword ptr [rip + path_prompt_x], edx

    mov eax, dword ptr [rip + window_height]
    sub eax, 32
    cmp eax, 176
    jbe .window_layout_prompt_height_ready
    mov eax, 176
.window_layout_prompt_height_ready:
    mov dword ptr [rip + path_prompt_height], eax

    # The path prompt follows the same UI preference and scales down only to fit.
    mov eax, dword ptr [rip + path_prompt_width]
    imul eax, 176
    mov edx, dword ptr [rip + path_prompt_height]
    imul edx, 704
    cmp eax, edx
    ja .window_layout_prompt_font_height
    mov eax, dword ptr [rip + path_prompt_width]
    imul eax, dword ptr [rip + ui_font_size]
    xor edx, edx
    mov ecx, 704
    div ecx
    jmp .window_layout_prompt_font_clamp
.window_layout_prompt_font_height:
    mov eax, dword ptr [rip + path_prompt_height]
    imul eax, dword ptr [rip + ui_font_size]
    xor edx, edx
    mov ecx, 176
    div ecx
.window_layout_prompt_font_clamp:
    cmp eax, 6
    jae .window_layout_prompt_font_min_ready
    mov eax, 6
.window_layout_prompt_font_min_ready:
    cmp eax, dword ptr [rip + ui_font_size]
    jbe .window_layout_prompt_font_store
    mov eax, dword ptr [rip + ui_font_size]
.window_layout_prompt_font_store:
    mov dword ptr [rip + path_prompt_font_size], eax

    # Restore the panel height: EAX held the derived text size above.
    mov eax, dword ptr [rip + path_prompt_height]
    mov edx, dword ptr [rip + window_height]
    sub edx, eax
    shr edx, 1
    sub edx, 4
    mov dword ptr [rip + path_prompt_y], edx
    pop rbx
    ret
.size window_update_layout_geometry, . - window_update_layout_geometry

# Convert surface coordinates to the 256x168 Settings design coordinate space.
.type settings_pointer_to_design, @function
settings_pointer_to_design:
    push rbx
    push r12
    mov r12d, esi
    sub edi, dword ptr [rip + settings_panel_x]
    imul edi, 256
    mov eax, edi
    cdq
    mov ecx, dword ptr [rip + settings_panel_width]
    test ecx, ecx
    jz .Lsettings_pointer_x_zero
    idiv ecx
    jmp .Lsettings_pointer_x_ready
.Lsettings_pointer_x_zero:
    xor eax, eax
.Lsettings_pointer_x_ready:
    add eax, 160
    mov ebx, eax
    mov eax, r12d
    sub eax, dword ptr [rip + settings_panel_y]
    imul eax, 192
    cdq
    mov ecx, dword ptr [rip + settings_panel_height]
    test ecx, ecx
    jz .Lsettings_pointer_y_zero
    idiv ecx
    jmp .Lsettings_pointer_y_ready
.Lsettings_pointer_y_zero:
    xor eax, eax
.Lsettings_pointer_y_ready:
    add eax, 32
    mov edx, eax
    mov eax, ebx
    pop r12
    pop rbx
    ret
.size settings_pointer_to_design, . - settings_pointer_to_design

# Parse xdg_toplevel.configure: width, height, and a uint32 array of states.
.type window_capture_toplevel_configure, @function
window_capture_toplevel_configure:
    mov dword ptr [rip + window_pending_width], 0
    mov dword ptr [rip + window_pending_height], 0
    mov dword ptr [rip + window_startup_size_locked], 0
    cmp dword ptr [rip + last_size], 12
    jb .window_capture_toplevel_done
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    jz .window_capture_width_done
    test eax, eax
    js .window_capture_toplevel_error
    cmp eax, MAX_WINDOW_WIDTH
    ja .window_capture_toplevel_error
    mov dword ptr [rip + window_pending_width], eax
    or dword ptr [rip + window_startup_size_locked], 1
.window_capture_width_done:
    mov eax, dword ptr [rip + event_payload + 4]
    test eax, eax
    jz .window_capture_height_done
    test eax, eax
    js .window_capture_toplevel_error
    cmp eax, MAX_WINDOW_HEIGHT
    ja .window_capture_toplevel_error
    mov dword ptr [rip + window_pending_height], eax
    or dword ptr [rip + window_startup_size_locked], 2
.window_capture_height_done:
    mov eax, dword ptr [rip + event_payload + 8]
    mov edx, dword ptr [rip + last_size]
    sub edx, 12
    cmp eax, edx
    ja .window_capture_toplevel_error
    test eax, 3
    jnz .window_capture_toplevel_error
    mov ecx, eax
    lea rdx, [rip + event_payload + 12]
    xor eax, eax
.window_capture_state_loop:
    test ecx, ecx
    jz .window_capture_state_done
    cmp dword ptr [rdx], 1
    je .window_capture_state_locked
    cmp dword ptr [rdx], 2
    je .window_capture_state_locked
    cmp dword ptr [rdx], 5
    jb .window_capture_state_next
    cmp dword ptr [rdx], 8
    ja .window_capture_state_next
.window_capture_state_locked:
    mov dword ptr [rip + window_startup_size_locked], 3
    cmp dword ptr [rdx], 1
    jne .window_capture_state_next
    mov eax, 1
.window_capture_state_next:
    add rdx, 4
    sub ecx, 4
    jmp .window_capture_state_loop
.window_capture_state_done:
    mov dword ptr [rip + window_is_maximized], eax
.window_capture_toplevel_done:
    xor eax, eax
    ret
.window_capture_toplevel_error:
    mov rax, -71
    ret
.size window_capture_toplevel_configure, . - window_capture_toplevel_configure

.type window_commit_initial_size, @function
window_commit_initial_size:
    mov eax, dword ptr [rip + window_pending_width]
    test eax, eax
    jz .window_initial_width_done
    mov dword ptr [rip + window_surface_width], eax
.window_initial_width_done:
    mov eax, dword ptr [rip + window_pending_height]
    test eax, eax
    jz .window_initial_height_done
    mov dword ptr [rip + window_surface_height], eax
.window_initial_height_done:
    mov dword ptr [rip + window_pending_width], 0
    mov dword ptr [rip + window_pending_height], 0
    call window_update_geometry
    ret
.size window_commit_initial_size, . - window_commit_initial_size

# Match either retained wl_buffer object and clear only its own ownership bit.
# RAX = 1 when a release was consumed, otherwise 0.
.type window_handle_buffer_release, @function
window_handle_buffer_release:
    cmp dword ptr [rip + last_opcode], 0
    jne .window_buffer_release_unmatched
    mov eax, dword ptr [rip + last_object]
    lea rdx, [rip + window_buffer_slot_ids]
    cmp dword ptr [rdx], eax
    je .window_buffer_release_slot0
    cmp dword ptr [rdx + 4], eax
    je .window_buffer_release_slot1
.window_buffer_release_unmatched:
    xor eax, eax
    ret
.window_buffer_release_slot0:
    cmp dword ptr [rip + window_buffer_slot_busy], 0
    je .window_buffer_release_matched
    mov dword ptr [rip + window_buffer_slot_busy], 0
    jmp .window_buffer_release_count
.window_buffer_release_slot1:
    cmp dword ptr [rip + window_buffer_slot_busy + 4], 0
    je .window_buffer_release_matched
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
.window_buffer_release_count:
    cmp dword ptr [rip + buffer_busy], 0
    je .window_buffer_release_matched
    dec dword ptr [rip + buffer_busy]
.window_buffer_release_matched:
    mov eax, 1
    ret
.size window_handle_buffer_release, . - window_handle_buffer_release

.type window_handle_surface_configure, @function
window_handle_surface_configure:
    push r12
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 9
    mov esi, 4
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .window_surface_configure_done
    mov r12d, 0
    mov eax, dword ptr [rip + window_pending_width]
    test eax, eax
    jz .window_surface_keep_width
    cmp eax, dword ptr [rip + window_surface_width]
    je .window_surface_keep_width
    mov r12d, 1
.window_surface_keep_width:
    mov eax, dword ptr [rip + window_pending_height]
    test eax, eax
    jz .window_surface_keep_height
    cmp eax, dword ptr [rip + window_surface_height]
    je .window_surface_keep_height
    mov r12d, 1
.window_surface_keep_height:
    mov dword ptr [rip + window_resize_pending], r12d
    mov dword ptr [rip + redraw_pending], 1
    cmp dword ptr [rip + buffer_busy], 0
    jne .window_surface_configure_done
    call window_apply_pending_resize
.window_surface_configure_done:
    pop r12
    ret
.size window_handle_surface_configure, . - window_handle_surface_configure

.type window_apply_pending_resize, @function
window_apply_pending_resize:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8                  # align nested calls after four callee-saved pushes
    cmp dword ptr [rip + window_resize_pending], 0
    je .window_resize_present
    cmp dword ptr [rip + buffer_busy], 0
    jne .window_resize_done
    mov r12d, dword ptr [rip + window_pending_width]
    test r12d, r12d
    jnz .window_resize_width_ready
    mov r12d, dword ptr [rip + window_surface_width]
.window_resize_width_ready:
    mov r13d, dword ptr [rip + window_pending_height]
    test r13d, r13d
    jnz .window_resize_height_ready
    mov r13d, dword ptr [rip + window_surface_height]
.window_resize_height_ready:
    mov dword ptr [rip + window_pending_width], 0
    mov dword ptr [rip + window_pending_height], 0
    mov dword ptr [rip + window_resize_pending], 0
    cmp r12d, dword ptr [rip + window_surface_width]
    jne .window_resize_dimensions_changed
    cmp r13d, dword ptr [rip + window_surface_height]
    jne .window_resize_dimensions_changed
    mov eax, dword ptr [rip + window_buffer_scale]
    cmp eax, dword ptr [rip + window_buffer_created_scale]
    jne .window_resize_dimensions_changed
    mov eax, dword ptr [rip + window_buffer_raster_scale_120]
    cmp eax, dword ptr [rip + window_buffer_created_raster_scale_120]
    jne .window_resize_dimensions_changed
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, dword ptr [rip + window_buffer_created_transform]
    jne .window_resize_dimensions_changed
    mov eax, dword ptr [rip + window_surface_width]
    cmp eax, dword ptr [rip + window_buffer_created_surface_width]
    jne .window_resize_dimensions_changed
    mov eax, dword ptr [rip + window_surface_height]
    cmp eax, dword ptr [rip + window_buffer_created_surface_height]
    jne .window_resize_dimensions_changed
    jmp .window_resize_present
.window_resize_dimensions_changed:
    mov dword ptr [rip + window_surface_width], r12d
    mov dword ptr [rip + window_surface_height], r13d
    call window_update_geometry
    # Every old-generation buffer is idle here. Destroy each object before
    # reusing either offset for the new geometry.
    xor ebx, ebx
.window_resize_destroy_slot:
    lea rax, [rip + window_buffer_slot_ids]
    mov edi, dword ptr [rax + rbx*4]
    test edi, edi
    jz .window_resize_destroy_next
    xor esi, esi
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .window_resize_done
    lea rax, [rip + window_buffer_slot_ids]
    mov dword ptr [rax + rbx*4], 0
.window_resize_destroy_next:
    lea rax, [rip + window_buffer_slot_busy]
    mov dword ptr [rax + rbx*4], 0
    inc ebx
    cmp ebx, 2
    jb .window_resize_destroy_slot
    mov dword ptr [rip + buffer_busy], 0
    mov r14d, dword ptr [rip + next_client_object_id]
    lea eax, [r14 + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + payload_buffer], r14d
    mov dword ptr [rip + payload_buffer + 4], 0
    mov eax, dword ptr [rip + window_buffer_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_buffer_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov eax, dword ptr [rip + window_stride]
    mov dword ptr [rip + payload_buffer + 16], eax
    mov dword ptr [rip + payload_buffer + 20], 1
    mov edi, 11
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 24
    call wl_send_request
    test rax, rax
    js .window_resize_done
    mov dword ptr [rip + window_buffer_slot_ids], r14d
    mov dword ptr [rip + window_buffer_slot_ids + 4], 0
    mov dword ptr [rip + window_buffer_slot_busy], 0
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
    mov dword ptr [rip + window_buffer_last_slot], 1
    mov dword ptr [rip + buffer_busy], 0
    mov dword ptr [rip + window_buffer_id], r14d
    mov rax, qword ptr [rip + shm_mapping_base]
    mov qword ptr [rip + shm_mapping], rax
    mov eax, dword ptr [rip + window_buffer_scale]
    mov dword ptr [rip + window_buffer_created_scale], eax
    mov eax, dword ptr [rip + window_buffer_raster_scale_120]
    mov dword ptr [rip + window_buffer_created_raster_scale_120], eax
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rip + window_buffer_created_transform], eax
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + window_buffer_created_surface_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + window_buffer_created_surface_height], eax

.window_resize_present:
    cmp dword ptr [rip + buffer_busy], 0
    jne .window_resize_done
    call present_buffer
.window_resize_done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size window_apply_pending_resize, . - window_apply_pending_resize

.type application_exit, @function
application_exit:
    # This leaf exit path is entered through CALL with RSP=8 mod 16.
    # Align the stack before calling the C handoff routine.
    sub rsp, 8
    mov edi, dword ptr [rip + socket_fd]
    mov esi, dword ptr [rip + window_buffer_id]
    call clipboard_service_handoff
    add rsp, 8
    mov edi, dword ptr [rip + socket_fd]
    cmp edi, 0
    jl .application_exit_now
    mov eax, SYS_close
    syscall
.application_exit_now:
    xor edi, edi
    jmp linux_exit
.size application_exit, . - application_exit

# Allocate the lazily used second buffer at the second half of the SHM pool.
.type window_create_second_buffer, @function
window_create_second_buffer:
    sub rsp, 8
    mov eax, dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + buffer_slot_new_id], eax
    lea edx, [rax + 1]
    mov dword ptr [rip + next_client_object_id], edx
    mov dword ptr [rip + payload_buffer], eax
    mov dword ptr [rip + payload_buffer + 4], SHM_BUFFER_CAPACITY
    mov eax, dword ptr [rip + window_buffer_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_buffer_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov eax, dword ptr [rip + window_stride]
    mov dword ptr [rip + payload_buffer + 16], eax
    mov dword ptr [rip + payload_buffer + 20], 1
    mov edi, 11
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 24
    call wl_send_request
    test rax, rax
    js .window_create_second_buffer_done
    mov eax, dword ptr [rip + buffer_slot_new_id]
    mov dword ptr [rip + window_buffer_slot_ids + 4], eax
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
    xor eax, eax
.window_create_second_buffer_done:
    add rsp, 8
    ret
.size window_create_second_buffer, . - window_create_second_buffer

.type present_buffer, @function
present_buffer:
    # r12d retains the selected slot across the renderer and protocol calls.
    mov dword ptr [rip + present_buffer_stage], 0
    push r12
    cmp dword ptr [rip + frame_callback_id], 0
    jne .present_buffer_blocked
    cmp dword ptr [rip + window_resize_pending], 0
    jne .present_buffer_blocked
    # Prefer the opposite slot only when it already exists and is free.
    # Otherwise reuse slot zero unless it is still compositor-owned.
    mov eax, dword ptr [rip + window_buffer_last_slot]
    xor eax, 1
    test eax, eax
    jz .present_buffer_prefer_slot0
    cmp dword ptr [rip + window_buffer_slot_ids + 4], 0
    je .present_buffer_try_slot0
    cmp dword ptr [rip + window_buffer_slot_busy + 4], 0
    je .present_buffer_select_slot1
    jmp .present_buffer_try_slot0
.present_buffer_prefer_slot0:
    cmp dword ptr [rip + window_buffer_slot_busy], 0
    je .present_buffer_select_slot0
    jmp .present_buffer_try_slot1
.present_buffer_try_slot0:
    cmp dword ptr [rip + window_buffer_slot_busy], 0
    jne .present_buffer_try_slot1
.present_buffer_select_slot0:
    xor r12d, r12d
    mov eax, dword ptr [rip + window_buffer_slot_ids]
    test eax, eax
    jz .present_buffer_no_slot
    jmp .present_buffer_slot_ready
.present_buffer_try_slot1:
    cmp dword ptr [rip + window_buffer_slot_busy + 4], 0
    jne .present_buffer_no_slot
    mov r12d, 1
    mov eax, dword ptr [rip + window_buffer_slot_ids + 4]
    test eax, eax
    jnz .present_buffer_slot_ready
    call window_create_second_buffer
    test rax, rax
    js .present_buffer_done
    mov eax, dword ptr [rip + window_buffer_slot_ids + 4]
    jmp .present_buffer_slot_ready
.present_buffer_select_slot1:
    mov r12d, 1
    mov eax, dword ptr [rip + window_buffer_slot_ids + 4]
.present_buffer_slot_ready:
    mov dword ptr [rip + window_buffer_id], eax
    mov rdx, qword ptr [rip + shm_mapping_base]
    test r12d, r12d
    jz .present_buffer_mapping_ready
    add rdx, SHM_BUFFER_CAPACITY
.present_buffer_mapping_ready:
    mov qword ptr [rip + shm_mapping], rdx
    call render_surface
    mov dword ptr [rip + present_buffer_stage], 1
    # A frame callback throttles commits; wl_buffer.release independently
    # controls which backing slot may be mutated.
    mov eax, dword ptr [rip + next_client_object_id]
    lea edx, [rax + 1]
    mov dword ptr [rip + next_client_object_id], edx
    mov dword ptr [rip + frame_callback_id], eax
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 8
    mov esi, 3                  # wl_surface.frame(new wl_callback)
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + present_buffer_stage], 2
    cmp dword ptr [rip + compositor_version], 3
    jb .present_buffer_scale_done
    mov eax, dword ptr [rip + window_buffer_scale]
    cmp dword ptr [rip + viewport_object], 0
    je  .present_buffer_scale_target_ready
    mov eax, 1
.present_buffer_scale_target_ready:
    cmp eax, dword ptr [rip + surface_applied_buffer_scale]
    je .present_buffer_scale_done
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 8
    mov esi, 8                  # wl_surface.set_buffer_scale
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov eax, dword ptr [rip + payload_buffer]
    mov dword ptr [rip + surface_applied_buffer_scale], eax
.present_buffer_scale_done:
    cmp dword ptr [rip + compositor_version], 2
    jb .present_buffer_transform_done
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, dword ptr [rip + surface_applied_buffer_transform]
    je .present_buffer_transform_done
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 8
    mov esi, 7                  # wl_surface.set_buffer_transform
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rip + surface_applied_buffer_transform], eax
.present_buffer_transform_done:
    call window_apply_viewport_destination
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + present_buffer_stage], 3
    mov eax, dword ptr [rip + window_buffer_id]
    mov dword ptr [rip + payload_buffer], eax
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], 0
    mov edi, 8
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 12
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + present_buffer_stage], 4
    mov dword ptr [rip + payload_buffer], 0
    mov dword ptr [rip + payload_buffer + 4], 0
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov edi, 8
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 16
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + present_buffer_stage], 5
    mov edi, 8
    mov esi, 6
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .present_buffer_done
    mov dword ptr [rip + present_buffer_stage], 6
    lea rdx, [rip + window_buffer_slot_busy]
    mov dword ptr [rdx + r12*4], 1
    inc dword ptr [rip + buffer_busy]
    mov dword ptr [rip + window_buffer_last_slot], r12d
    mov dword ptr [rip + redraw_pending], 0
    xor eax, eax
    jmp .present_buffer_done
.present_buffer_blocked:
.present_buffer_no_slot:
    mov dword ptr [rip + redraw_pending], 1
    xor eax, eax
.present_buffer_done:
    pop r12
    ret
.size present_buffer, . - present_buffer

# Return the byte offset after one valid UTF-8 scalar. Invalid bytes are treated
# as single-byte replacement units so the original file bytes remain editable.
# EDI=byte offset; EAX=next byte offset.
.global doc_byte_at
.type doc_byte_at, @function
# Read one logical document byte, translating around the movable gap.
# EDI=logical byte offset; EAX=byte value (zero for an out-of-range offset).
doc_byte_at:
    mov eax, edi
    cmp eax, dword ptr [rip + doc_length]
    jae .doc_byte_at_out_of_range
    cmp eax, dword ptr [rip + doc_gap_start]
    jb .doc_byte_at_physical
    mov edx, dword ptr [rip + doc_gap_end]
    sub edx, dword ptr [rip + doc_gap_start]
    add eax, edx
.doc_byte_at_physical:
    mov rdx, qword ptr [rip + doc_buffer]
    movzx eax, byte ptr [rdx + rax]
    ret
.doc_byte_at_out_of_range:
    xor eax, eax
    ret
.size doc_byte_at, . - doc_byte_at

# Move the gap to a logical byte offset. EDI is clamped to doc_length.
# The gap is [doc_gap_start, doc_gap_end); bytes outside it stay in order.
.type doc_move_gap, @function
doc_move_gap:
    push rbx
    push r12
    push r13
    mov ebx, edi
    mov eax, dword ptr [rip + doc_length]
    cmp ebx, eax
    jbe .doc_move_gap_target_valid
    mov ebx, eax
.doc_move_gap_target_valid:
    mov r12d, dword ptr [rip + doc_gap_start]
    cmp ebx, r12d
    jb .doc_move_gap_left
    ja .doc_move_gap_right
    jmp .doc_move_gap_done

.doc_move_gap_left:
    # Move the prefix tail backwards into the end of the current gap.
    mov r13d, r12d
    sub r13d, ebx
    test r13d, r13d
    jz .doc_move_gap_done
    mov rsi, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_start]
    add rsi, rax
    dec rsi
    mov rdi, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add rdi, rax
    dec rdi
    mov ecx, r13d
    std
    rep movsb
    cld
    mov dword ptr [rip + doc_gap_start], ebx
    sub dword ptr [rip + doc_gap_end], r13d
    jmp .doc_move_gap_done

.doc_move_gap_right:
    # Move the suffix head forwards into the beginning of the current gap.
    mov r13d, ebx
    sub r13d, r12d
    test r13d, r13d
    jz .doc_move_gap_done
    mov rsi, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_end]
    add rsi, rax
    mov rdi, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_start]
    add rdi, rax
    mov ecx, r13d
    cld
    rep movsb
    add dword ptr [rip + doc_gap_start], r13d
    add dword ptr [rip + doc_gap_end], r13d
.doc_move_gap_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_move_gap, . - doc_move_gap

# Return the byte offset after one valid UTF-8 scalar. Invalid bytes are treated
# as single-byte replacement units so the original file bytes remain editable.
# EDI=logical byte offset; EAX=next logical byte offset.
.type doc_utf8_next, @function
doc_utf8_next:
    push rbx
    mov r8d, edi
    mov r9d, dword ptr [rip + doc_length]
    mov eax, r8d
    cmp r8d, r9d
    jae .Lneko_utf8_next_done
    mov edi, r8d
    call doc_byte_at
    mov r11d, eax
    cmp r11d, 0xc2
    jb .Lneko_utf8_next_single
    cmp r11d, 0xdf
    jbe .Lneko_utf8_next_two
    cmp r11d, 0xef
    jbe .Lneko_utf8_next_three
    cmp r11d, 0xf4
    jbe .Lneko_utf8_next_four
    jmp .Lneko_utf8_next_single

.Lneko_utf8_next_two:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 2]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_three:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    cmp r10d, 0x80
    jb .Lneko_utf8_next_single
    cmp r10d, 0xbf
    ja .Lneko_utf8_next_single
    cmp r11d, 0xe0
    jne .Lneko_utf8_next_three_check_ed
    cmp r10d, 0xa0
    jb .Lneko_utf8_next_single
    jmp .Lneko_utf8_next_three_second_ok
.Lneko_utf8_next_three_check_ed:
    cmp r11d, 0xed
    jne .Lneko_utf8_next_three_second_ok
    cmp r10d, 0x9f
    ja .Lneko_utf8_next_single
.Lneko_utf8_next_three_second_ok:
    lea edi, [r8d + 2]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 3]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_four:
    lea edi, [r8d + 1]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    cmp r10d, 0x80
    jb .Lneko_utf8_next_single
    cmp r10d, 0xbf
    ja .Lneko_utf8_next_single
    cmp r11d, 0xf0
    jne .Lneko_utf8_next_four_check_f4
    cmp r10d, 0x90
    jb .Lneko_utf8_next_single
    jmp .Lneko_utf8_next_four_second_ok
.Lneko_utf8_next_four_check_f4:
    cmp r11d, 0xf4
    jne .Lneko_utf8_next_four_second_ok
    cmp r10d, 0x8f
    ja .Lneko_utf8_next_single
.Lneko_utf8_next_four_second_ok:
    lea edi, [r8d + 2]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea edi, [r8d + 3]
    cmp edi, r9d
    jae .Lneko_utf8_next_single
    call doc_byte_at
    mov r10d, eax
    and r10d, 0xc0
    cmp r10d, 0x80
    jne .Lneko_utf8_next_single
    lea eax, [r8d + 4]
    jmp .Lneko_utf8_next_done

.Lneko_utf8_next_single:
    lea eax, [r8d + 1]
.Lneko_utf8_next_done:
    pop rbx
    ret
.size doc_utf8_next, . - doc_utf8_next

# Return the start of the valid UTF-8 scalar ending at EDI. Invalid trailing
# bytes remain individually addressable. EDI=byte offset; EAX=previous offset.
.type doc_utf8_prev, @function
doc_utf8_prev:
    push rbx
    push r12
    mov r12d, edi
    test r12d, r12d
    jz .Lneko_utf8_prev_zero
    cmp r12d, 2
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 2]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
    cmp r12d, 3
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 3]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
    cmp r12d, 4
    jb .Lneko_utf8_prev_fallback
    lea ebx, [r12d - 4]
    mov edi, ebx
    call doc_utf8_next
    cmp eax, r12d
    je .Lneko_utf8_prev_found
.Lneko_utf8_prev_fallback:
    lea eax, [r12d - 1]
    jmp .Lneko_utf8_prev_done
.Lneko_utf8_prev_found:
    mov eax, ebx
    jmp .Lneko_utf8_prev_done
.Lneko_utf8_prev_zero:
    xor eax, eax
.Lneko_utf8_prev_done:
    pop r12
    pop rbx
    ret
.size doc_utf8_prev, . - doc_utf8_prev


# Generic binary search over sorted {first,last,value} Unicode ranges.
# EDI=code point, RSI=table address, EDX=entry count; EAX=property or zero.
.type unicode_range_lookup, @function
unicode_range_lookup:
    mov r8d, edi
    mov r9, rsi
    xor r10d, r10d
    mov r11d, edx
.Lunicode_range_lookup_loop:
    cmp r10d, r11d
    jae .Lunicode_range_lookup_miss
    lea ecx, [r10d + r11d]
    shr ecx, 1
    mov eax, ecx
    lea rax, [rax + rax * 2]
    shl rax, 2
    mov edx, dword ptr [r9 + rax]
    cmp r8d, edx
    jb .Lunicode_range_lookup_lower
    mov edx, dword ptr [r9 + rax + 4]
    cmp r8d, edx
    ja .Lunicode_range_lookup_upper
    mov eax, dword ptr [r9 + rax + 8]
    ret
.Lunicode_range_lookup_lower:
    mov r11d, ecx
    jmp .Lunicode_range_lookup_loop
.Lunicode_range_lookup_upper:
    lea r10d, [ecx + 1]
    jmp .Lunicode_range_lookup_loop
.Lunicode_range_lookup_miss:
    xor eax, eax
    ret
.size unicode_range_lookup, . - unicode_range_lookup

# Return Unicode 18.0 Grapheme_Cluster_Break for EDI.
# CR=1, LF=2, Control=3, Extend=4, ZWJ=5, RI=6, Prepend=7,
# SpacingMark=8, L=9, V=10, T=11, LV=12, LVT=13, Other=0.
.type doc_grapheme_property, @function
doc_grapheme_property:
    cmp edi, 0xac00
    jb .Ldoc_gcb_table_lookup
    cmp edi, 0xd7a3
    ja .Ldoc_gcb_table_lookup
    mov eax, edi
    sub eax, 0xac00
    xor edx, edx
    mov ecx, 28
    div ecx
    test edx, edx
    jz .Ldoc_gcb_hangul_lv
    mov eax, 13
    ret
.Ldoc_gcb_hangul_lv:
    mov eax, 12
    ret
.Ldoc_gcb_table_lookup:
    lea rsi, [rip + unicode_gcb_ranges]
    mov edx, (unicode_gcb_ranges_end - unicode_gcb_ranges) / 12
    jmp unicode_range_lookup
.size doc_grapheme_property, . - doc_grapheme_property

.type doc_indic_conjunct_property, @function
doc_indic_conjunct_property:
    lea rsi, [rip + unicode_incb_ranges]
    mov edx, (unicode_incb_ranges_end - unicode_incb_ranges) / 12
    jmp unicode_range_lookup
.size doc_indic_conjunct_property, . - doc_indic_conjunct_property

.type doc_is_extended_pictographic, @function
doc_is_extended_pictographic:
    lea rsi, [rip + unicode_extended_pictographic_ranges]
    mov edx, (unicode_extended_pictographic_ranges_end - unicode_extended_pictographic_ranges) / 12
    jmp unicode_range_lookup
.size doc_is_extended_pictographic, . - doc_is_extended_pictographic

# Decode the UTF-8 scalar at logical byte offset EDI.
# Returns EAX=code point and EDX=byte offset immediately after it.
# Invalid UTF-8 bytes stay addressable as independent one-byte units.
.type doc_unicode_decode_at, @function
doc_unicode_decode_at:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12d, edi
    call doc_utf8_next
    mov r13d, eax
    mov edi, r12d
    call doc_byte_at
    mov ebx, eax
    mov ecx, r13d
    sub ecx, r12d
    cmp ecx, 2
    je .Ldoc_unicode_decode_two
    cmp ecx, 3
    je .Ldoc_unicode_decode_three
    cmp ecx, 4
    je .Ldoc_unicode_decode_four
    mov r14d, ebx
    jmp .Ldoc_unicode_decode_done
.Ldoc_unicode_decode_two:
    mov r14d, ebx
    and r14d, 0x1f
    shl r14d, 6
    lea edi, [r12d + 1]
    call doc_byte_at
    and eax, 0x3f
    or r14d, eax
    jmp .Ldoc_unicode_decode_done
.Ldoc_unicode_decode_three:
    mov r14d, ebx
    and r14d, 0x0f
    shl r14d, 12
    lea edi, [r12d + 1]
    call doc_byte_at
    and eax, 0x3f
    shl eax, 6
    or r14d, eax
    lea edi, [r12d + 2]
    call doc_byte_at
    and eax, 0x3f
    or r14d, eax
    jmp .Ldoc_unicode_decode_done
.Ldoc_unicode_decode_four:
    mov r14d, ebx
    and r14d, 0x07
    shl r14d, 18
    lea edi, [r12d + 1]
    call doc_byte_at
    and eax, 0x3f
    shl eax, 12
    or r14d, eax
    lea edi, [r12d + 2]
    call doc_byte_at
    and eax, 0x3f
    shl eax, 6
    or r14d, eax
    lea edi, [r12d + 3]
    call doc_byte_at
    and eax, 0x3f
    or r14d, eax
.Ldoc_unicode_decode_done:
    mov eax, r14d
    mov edx, r13d
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_unicode_decode_at, . - doc_unicode_decode_at

# Decide whether there is an extended grapheme boundary between adjacent
# scalar starts: EDI=previous scalar offset, ESI=current scalar offset.
# EAX=1 for a break, EAX=0 for no break.
.type doc_grapheme_is_break, @function
doc_grapheme_is_break:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov r12d, edi
    mov r13d, esi
    mov edi, r12d
    call doc_unicode_decode_at
    mov r14d, eax
    mov edi, r14d
    call doc_grapheme_property
    mov ebx, eax
    mov edi, r13d
    call doc_unicode_decode_at
    mov r15d, eax
    mov edi, r15d
    call doc_grapheme_property
    mov ebp, eax

    # GB3: CR x LF.
    cmp ebx, 1
    jne .Ldoc_grapheme_break_controls
    cmp ebp, 2
    je .Ldoc_grapheme_no_break
.Ldoc_grapheme_break_controls:
    # GB4/GB5: break around Control/CR/LF (except GB3).
    cmp ebx, 1
    je .Ldoc_grapheme_break_yes
    cmp ebx, 2
    je .Ldoc_grapheme_break_yes
    cmp ebx, 3
    je .Ldoc_grapheme_break_yes
    cmp ebp, 1
    je .Ldoc_grapheme_break_yes
    cmp ebp, 2
    je .Ldoc_grapheme_break_yes
    cmp ebp, 3
    je .Ldoc_grapheme_break_yes

    # GB6: L x (L | V | LV | LVT).
    cmp ebx, 9
    jne .Ldoc_grapheme_break_gb7
    cmp ebp, 9
    je .Ldoc_grapheme_no_break
    cmp ebp, 10
    je .Ldoc_grapheme_no_break
    cmp ebp, 12
    je .Ldoc_grapheme_no_break
    cmp ebp, 13
    je .Ldoc_grapheme_no_break
.Ldoc_grapheme_break_gb7:
    # GB7: (LV | V) x (V | T).
    cmp ebx, 12
    je .Ldoc_grapheme_break_gb7_prev_ok
    cmp ebx, 10
    jne .Ldoc_grapheme_break_gb8
.Ldoc_grapheme_break_gb7_prev_ok:
    cmp ebp, 10
    je .Ldoc_grapheme_no_break
    cmp ebp, 11
    je .Ldoc_grapheme_no_break
.Ldoc_grapheme_break_gb8:
    # GB8: (LVT | T) x T.
    cmp ebx, 13
    je .Ldoc_grapheme_break_gb8_prev_ok
    cmp ebx, 11
    jne .Ldoc_grapheme_break_gb9
.Ldoc_grapheme_break_gb8_prev_ok:
    cmp ebp, 11
    je .Ldoc_grapheme_no_break
.Ldoc_grapheme_break_gb9:
    # GB9/GB9a: x Extend/ZWJ/SpacingMark. GB9b: Prepend x.
    cmp ebp, 4
    je .Ldoc_grapheme_no_break
    cmp ebp, 5
    je .Ldoc_grapheme_no_break
    cmp ebp, 8
    je .Ldoc_grapheme_no_break
    cmp ebx, 7
    je .Ldoc_grapheme_no_break

    # GB9c: InCB=Consonant (InCB=Extend|Linker)* InCB=Linker
    # (InCB=Extend|Linker)* x InCB=Consonant.
    mov edi, r15d
    call doc_indic_conjunct_property
    cmp eax, 1
    jne .Ldoc_grapheme_break_gb11
    mov dword ptr [rsp + 4], 0
    mov dword ptr [rsp + 8], r12d
.Ldoc_grapheme_gb9c_scan:
    mov edi, dword ptr [rsp + 8]
    call doc_unicode_decode_at
    mov edi, eax
    call doc_indic_conjunct_property
    cmp eax, 3
    je .Ldoc_grapheme_gb9c_linker
    cmp eax, 2
    je .Ldoc_grapheme_gb9c_step_back
    cmp eax, 1
    jne .Ldoc_grapheme_break_gb11
    cmp dword ptr [rsp + 4], 0
    jne .Ldoc_grapheme_no_break
    jmp .Ldoc_grapheme_break_gb11
.Ldoc_grapheme_gb9c_linker:
    mov dword ptr [rsp + 4], 1
.Ldoc_grapheme_gb9c_step_back:
    mov edi, dword ptr [rsp + 8]
    test edi, edi
    jz .Ldoc_grapheme_break_gb11
    call doc_utf8_prev
    cmp eax, dword ptr [rsp + 8]
    je .Ldoc_grapheme_break_gb11
    mov dword ptr [rsp + 8], eax
    jmp .Ldoc_grapheme_gb9c_scan

    # GB11: Extended_Pictographic Extend* ZWJ x Extended_Pictographic.
.Ldoc_grapheme_break_gb11:
    cmp ebx, 5
    jne .Ldoc_grapheme_break_gb12
    mov edi, r15d
    call doc_is_extended_pictographic
    test eax, eax
    jz .Ldoc_grapheme_break_gb12
    mov edi, r12d
    test edi, edi
    jz .Ldoc_grapheme_break_gb12
    call doc_utf8_prev
    mov dword ptr [rsp + 8], eax
.Ldoc_grapheme_gb11_scan:
    mov edi, dword ptr [rsp + 8]
    call doc_unicode_decode_at
    mov r14d, eax
    mov edi, r14d
    call doc_grapheme_property
    cmp eax, 4
    jne .Ldoc_grapheme_gb11_check_pictographic
    mov edi, dword ptr [rsp + 8]
    test edi, edi
    jz .Ldoc_grapheme_break_gb12
    call doc_utf8_prev
    cmp eax, dword ptr [rsp + 8]
    je .Ldoc_grapheme_break_gb12
    mov dword ptr [rsp + 8], eax
    jmp .Ldoc_grapheme_gb11_scan
.Ldoc_grapheme_gb11_check_pictographic:
    mov edi, r14d
    call doc_is_extended_pictographic
    test eax, eax
    jnz .Ldoc_grapheme_no_break
.Ldoc_grapheme_break_gb12:
    # GB12/GB13: pair regional indicators from the beginning of each RI run.
    cmp ebp, 6
    jne .Ldoc_grapheme_break_yes
    cmp ebx, 6
    jne .Ldoc_grapheme_break_yes
    mov dword ptr [rsp + 8], r12d
    mov dword ptr [rsp + 12], 0
.Ldoc_grapheme_gb12_scan:
    mov edi, dword ptr [rsp + 8]
    call doc_unicode_decode_at
    mov edi, eax
    call doc_grapheme_property
    cmp eax, 6
    jne .Ldoc_grapheme_gb12_counted
    inc dword ptr [rsp + 12]
    mov edi, dword ptr [rsp + 8]
    test edi, edi
    jz .Ldoc_grapheme_gb12_counted
    call doc_utf8_prev
    cmp eax, dword ptr [rsp + 8]
    je .Ldoc_grapheme_gb12_counted
    mov dword ptr [rsp + 8], eax
    jmp .Ldoc_grapheme_gb12_scan
.Ldoc_grapheme_gb12_counted:
    test dword ptr [rsp + 12], 1
    jnz .Ldoc_grapheme_no_break

.Ldoc_grapheme_break_yes:
    mov eax, 1
    jmp .Ldoc_grapheme_break_done
.Ldoc_grapheme_no_break:
    xor eax, eax
.Ldoc_grapheme_break_done:
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_grapheme_is_break, . - doc_grapheme_is_break

# EDI=cluster start; EAX=next extended grapheme boundary, or EOF.
.type doc_grapheme_next, @function
doc_grapheme_next:
    push rbx
    push r12
    push r13
    mov ebx, dword ptr [rip + doc_length]
    mov r12d, edi
    cmp r12d, ebx
    jae .Ldoc_grapheme_next_eof
    call doc_unicode_decode_at
    mov r13d, edx
.Ldoc_grapheme_next_scan:
    cmp r13d, ebx
    jae .Ldoc_grapheme_next_done
    mov edi, r12d
    mov esi, r13d
    call doc_grapheme_is_break
    test eax, eax
    jnz .Ldoc_grapheme_next_done
    mov r12d, r13d
    mov edi, r12d
    call doc_unicode_decode_at
    mov r13d, edx
    jmp .Ldoc_grapheme_next_scan
.Ldoc_grapheme_next_eof:
    mov r13d, ebx
.Ldoc_grapheme_next_done:
    mov eax, r13d
    pop r13
    pop r12
    pop rbx
    ret
.size doc_grapheme_next, . - doc_grapheme_next

# EDI=cursor insertion offset; EAX=previous extended grapheme boundary.
.type doc_grapheme_prev, @function
doc_grapheme_prev:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12d, edi
    test r12d, r12d
    jz .Ldoc_grapheme_prev_zero
    mov edi, r12d
    call doc_utf8_prev
    mov r13d, eax
.Ldoc_grapheme_prev_scan:
    test r13d, r13d
    jz .Ldoc_grapheme_prev_zero
    mov edi, r13d
    call doc_utf8_prev
    mov r14d, eax
    mov edi, r14d
    mov esi, r13d
    call doc_grapheme_is_break
    test eax, eax
    jnz .Ldoc_grapheme_prev_done
    mov r13d, r14d
    jmp .Ldoc_grapheme_prev_scan
.Ldoc_grapheme_prev_done:
    mov eax, r13d
    jmp .Ldoc_grapheme_prev_return
.Ldoc_grapheme_prev_zero:
    xor eax, eax
.Ldoc_grapheme_prev_return:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_grapheme_prev, . - doc_grapheme_prev


# Each 16-byte logical-line record stores byte span, wrapped visual rows, and
# one node from each Fenwick prefix tree. Byte spans include a terminating LF.
# The index mapping is bounded and independent of the document gap buffer.
.type doc_line_index_reserve, @function
doc_line_index_reserve:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    mov ebx, edi
    cmp ebx, DOC_INDEX_MAX_LINES
    ja .Ldoc_index_reserve_failed
    mov eax, dword ptr [rip + doc_line_index_capacity]
    cmp eax, ebx
    jae .Ldoc_index_reserve_success
    mov r12d, eax
    test r12d, r12d
    jnz .Ldoc_index_reserve_grow
    mov r12d, DOC_INDEX_INITIAL_LINES
.Ldoc_index_reserve_grow:
    cmp r12d, ebx
    jae .Ldoc_index_reserve_size_ready
    shl r12d, 1
    cmp r12d, DOC_INDEX_MAX_LINES
    jbe .Ldoc_index_reserve_grow
    mov r12d, DOC_INDEX_MAX_LINES
    cmp r12d, ebx
    jb .Ldoc_index_reserve_failed
.Ldoc_index_reserve_size_ready:
    mov r13d, r12d
    shl r13, 4
    mov r14, qword ptr [rip + doc_line_index_base]
    test r14, r14
    jz .Ldoc_index_reserve_mmap
    mov rdi, r14
    mov esi, dword ptr [rip + doc_line_index_capacity]
    shl rsi, 4
    mov rdx, r13
    mov r10d, MREMAP_MAYMOVE
    mov eax, SYS_mremap
    syscall
    test rax, rax
    js .Ldoc_index_reserve_failed
    mov qword ptr [rip + doc_line_index_base], rax
    mov dword ptr [rip + doc_line_index_capacity], r12d
    mov qword ptr [rip + doc_line_index_bytes], r13
    jmp .Ldoc_index_reserve_success
.Ldoc_index_reserve_mmap:
    xor edi, edi
    mov rsi, r13
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9d, r9d
    mov eax, SYS_mmap
    syscall
    test rax, rax
    js .Ldoc_index_reserve_failed
    mov qword ptr [rip + doc_line_index_base], rax
    mov dword ptr [rip + doc_line_index_capacity], r12d
    mov qword ptr [rip + doc_line_index_bytes], r13
.Ldoc_index_reserve_success:
    xor eax, eax
    jmp .Ldoc_index_reserve_done
.Ldoc_index_reserve_failed:
    mov rax, -12
.Ldoc_index_reserve_done:
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_line_index_reserve, . - doc_line_index_reserve

# EDI=logical line byte start, ESI=byte span; returns EAX=visual rows >= 1.
.type doc_line_index_measure_rows, @function
.type doc_line_index_measure_rows, @function
doc_line_index_measure_rows:
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldoc_index_measure_wrapped
    push rbx
    push r12
    push r13
    mov r12d, edi
    lea r13d, [rdi + rsi]
    test esi, esi
    jz .Ldoc_index_unwrapped_end_ready
    lea edi, [r13d - 1]
    call doc_byte_at
    cmp eax, 10
    jne .Ldoc_index_unwrapped_end_ready
    dec r13d
.Ldoc_index_unwrapped_end_ready:
    xor ebx, ebx
.Ldoc_index_unwrapped_loop:
    cmp r12d, r13d
    jae .Ldoc_index_unwrapped_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 9
    je .Ldoc_index_unwrapped_tab
    cmp eax, 32
    jb .Ldoc_index_unwrapped_control
    cmp eax, 128
    jb .Ldoc_index_unwrapped_glyph
    mov edi, r12d
    call doc_utf8_decode_at
.Ldoc_index_unwrapped_glyph:
    mov edi, eax
    call font_codepoint_advance_pixels
    add ebx, eax
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Ldoc_index_unwrapped_loop
.Ldoc_index_unwrapped_tab:
    lea ebx, [rbx + 32]
    and ebx, -32
    inc r12d
    jmp .Ldoc_index_unwrapped_loop
.Ldoc_index_unwrapped_control:
    inc r12d
    jmp .Ldoc_index_unwrapped_loop
.Ldoc_index_unwrapped_done:
    cmp ebx, dword ptr [rip + doc_max_line_width]
    jbe .Ldoc_index_unwrapped_return
    mov dword ptr [rip + doc_max_line_width], ebx
.Ldoc_index_unwrapped_return:
    mov eax, 1
    pop r13
    pop r12
    pop rbx
    ret
.Ldoc_index_measure_wrapped:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    lea r13d, [rdi + rsi]
    test esi, esi
    jz .Ldoc_index_measure_end_ready
    lea edi, [r13d - 1]
    call doc_byte_at
    cmp eax, 10
    jne .Ldoc_index_measure_end_ready
    dec r13d
.Ldoc_index_measure_end_ready:
    mov r15d, dword ptr [rip + window_doc_pixel_width]
    test r15d, r15d
    jnz .Ldoc_index_measure_width_ready
    mov r15d, 1
.Ldoc_index_measure_width_ready:
    mov r14d, 1
    xor ebx, ebx
.Ldoc_index_measure_loop:
    cmp r12d, r13d
    jae .Ldoc_index_measure_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_index_measure_done
    cmp eax, 9
    je .Ldoc_index_measure_tab
    cmp eax, 32
    jb .Ldoc_index_measure_control
    cmp eax, 128
    jb .Ldoc_index_measure_ascii
    mov edi, r12d
    call doc_utf8_decode_at
.Ldoc_index_measure_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [ebx + eax]
    cmp edx, r15d
    jbe .Ldoc_index_measure_glyph_fit
    inc r14d
    xor ebx, ebx
.Ldoc_index_measure_glyph_fit:
    add ebx, eax
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Ldoc_index_measure_loop
.Ldoc_index_measure_tab:
    lea eax, [rbx + 32]
    and eax, -32
    cmp eax, r15d
    jbe .Ldoc_index_measure_tab_fit
    inc r14d
    mov ebx, 32
    jmp .Ldoc_index_measure_tab_next
.Ldoc_index_measure_tab_fit:
    mov ebx, eax
.Ldoc_index_measure_tab_next:
    inc r12d
    jmp .Ldoc_index_measure_loop
.Ldoc_index_measure_control:
    inc r12d
    jmp .Ldoc_index_measure_loop
.Ldoc_index_measure_done:
    mov eax, r14d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_measure_rows, . - doc_line_index_measure_rows

# Linear Fenwick construction. Nodes are reset first so rebuilds after line
# insertion/merging cannot retain stale parent aggregates.
.type doc_line_index_build_trees, @function
doc_line_index_build_trees:
    push rbx
    push r12
    push r13
    mov r12d, dword ptr [rip + doc_line_count]
    mov rbx, qword ptr [rip + doc_line_index_base]
    xor r13d, r13d
.Ldoc_index_tree_zero_loop:
    cmp r13d, r12d
    jae .Ldoc_index_tree_build_begin
    mov eax, r13d
    shl rax, 4
    lea rdi, [rbx + rax]
    mov dword ptr [rdi + DOC_INDEX_BYTE_TREE_OFFSET], 0
    mov dword ptr [rdi + DOC_INDEX_ROW_TREE_OFFSET], 0
    inc r13d
    jmp .Ldoc_index_tree_zero_loop
.Ldoc_index_tree_build_begin:
    mov r13d, 1
.Ldoc_index_tree_build_loop:
    cmp r13d, r12d
    ja .Ldoc_index_tree_build_done
    mov eax, r13d
    dec eax
    shl rax, 4
    lea rdi, [rbx + rax]
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    add dword ptr [rdi + DOC_INDEX_BYTE_TREE_OFFSET], eax
    mov eax, dword ptr [rdi + DOC_INDEX_ROWS_OFFSET]
    add dword ptr [rdi + DOC_INDEX_ROW_TREE_OFFSET], eax
    mov ecx, r13d
    mov edx, ecx
    neg edx
    and edx, ecx
    add edx, ecx
    cmp edx, r12d
    ja .Ldoc_index_tree_build_next
    mov eax, dword ptr [rdi + DOC_INDEX_BYTE_TREE_OFFSET]
    mov r8d, dword ptr [rdi + DOC_INDEX_ROW_TREE_OFFSET]
    mov ecx, edx
    dec ecx
    mov r9, rcx
    shl r9, 4
    lea r10, [rbx + r9]
    add dword ptr [r10 + DOC_INDEX_BYTE_TREE_OFFSET], eax
    add dword ptr [r10 + DOC_INDEX_ROW_TREE_OFFSET], r8d
.Ldoc_index_tree_build_next:
    inc r13d
    jmp .Ldoc_index_tree_build_loop
.Ldoc_index_tree_build_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_build_trees, . - doc_line_index_build_trees

# Sum the first EDI line values from the Fenwick tree at record offset ESI.
.type doc_line_index_prefix_sum, @function
doc_line_index_prefix_sum:
    push rbx
    push r12
    push r13
    mov ebx, edi
    mov r12d, esi
    xor r13d, r13d
.Ldoc_index_prefix_loop:
    test ebx, ebx
    jz .Ldoc_index_prefix_done
    mov eax, ebx
    dec eax
    shl rax, 4
    mov rdx, qword ptr [rip + doc_line_index_base]
    add rdx, rax
    mov eax, dword ptr [rdx + r12]
    add r13d, eax
    mov eax, ebx
    neg eax
    and eax, ebx
    sub ebx, eax
    jmp .Ldoc_index_prefix_loop
.Ldoc_index_prefix_done:
    mov eax, r13d
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_prefix_sum, . - doc_line_index_prefix_sum

# EDI=coordinate, ESI=Fenwick field offset; return line index in EAX and
# its starting byte/visual-row prefix in EDX. EOF clamps to the final record.
.type doc_line_index_find_prefix, @function
doc_line_index_find_prefix:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    mov r14d, dword ptr [rip + doc_line_count]
    test r14d, r14d
    jz .Ldoc_index_find_empty
    mov ebx, 1
.Ldoc_index_find_high_bit:
    mov eax, ebx
    shl eax, 1
    cmp eax, r14d
    ja .Ldoc_index_find_search
    mov ebx, eax
    jmp .Ldoc_index_find_high_bit
.Ldoc_index_find_search:
    xor ebp, ebp
    xor r10d, r10d
.Ldoc_index_find_bit_loop:
    test ebx, ebx
    jz .Ldoc_index_find_clamp
    lea ecx, [rbp + rbx]
    cmp ecx, r14d
    ja .Ldoc_index_find_next_bit
    mov rdx, qword ptr [rip + doc_line_index_base]
    lea eax, [rcx - 1]
    shl rax, 4
    add rdx, rax
    mov edx, dword ptr [rdx + r13]
    mov eax, r10d
    add eax, edx
    cmp eax, r12d
    ja .Ldoc_index_find_next_bit
    mov ebp, ecx
    mov r10d, eax
.Ldoc_index_find_next_bit:
    shr ebx, 1
    jmp .Ldoc_index_find_bit_loop
.Ldoc_index_find_clamp:
    cmp ebp, r14d
    jb .Ldoc_index_find_done
    mov ebp, r14d
    dec ebp
    # The Fenwick node at count may aggregate several lines. Recompute the
    # exact prefix before the final line rather than subtracting that node.
    mov edi, ebp
    mov esi, r13d
    call doc_line_index_prefix_sum
    mov r10d, eax
.Ldoc_index_find_done:
    mov eax, ebp
    mov edx, r10d
    jmp .Ldoc_index_find_return
.Ldoc_index_find_empty:
    xor eax, eax
    xor edx, edx
.Ldoc_index_find_return:
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_line_index_find_prefix, . - doc_line_index_find_prefix

# Reflow only row counts after the window text width changes.
.type doc_line_index_reflow, @function
doc_line_index_reflow:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, dword ptr [rip + doc_line_count]
    xor r13d, r13d
    xor r14d, r14d
.Ldoc_index_reflow_loop:
    cmp r14d, r12d
    jae .Ldoc_index_reflow_done
    mov rax, r14
    shl rax, 4
    mov rdi, qword ptr [rip + doc_line_index_base]
    add rdi, rax
    mov r15d, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    mov edi, r13d
    mov esi, r15d
    call doc_line_index_measure_rows
    mov ebx, eax
    mov rax, r14
    shl rax, 4
    mov rdi, qword ptr [rip + doc_line_index_base]
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], ebx
    add r13d, r15d
    inc r14d
    jmp .Ldoc_index_reflow_loop
.Ldoc_index_reflow_done:
    call doc_line_index_build_trees
    mov eax, dword ptr [rip + window_doc_pixel_width]
    mov dword ptr [rip + doc_line_index_columns], eax
    mov eax, 1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_reflow, . - doc_line_index_reflow

# Rebuild records from the logical byte stream, retaining an empty final line
# when the document ends in LF. Failure disables indexing until the next edit.
.type doc_line_index_rebuild, @function
doc_line_index_rebuild:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov dword ptr [rip + doc_line_index_valid], 0
    mov dword ptr [rip + doc_line_count], 0
    mov ebx, 1
    xor r12d, r12d
    mov r15d, dword ptr [rip + doc_length]

    # A newly opened document has its gap at EOF, so the logical bytes form
    # one contiguous range. SCASB finds newlines without one doc_byte_at call
    # per byte. Keep the original gap-aware path for edited documents.
    mov eax, dword ptr [rip + doc_gap_start]
    cmp eax, r15d
    jne .Ldoc_index_count_generic
    mov rdi, qword ptr [rip + doc_buffer]
    mov ecx, r15d
    mov al, 10
.Ldoc_index_count_contiguous:
    test ecx, ecx
    jz .Ldoc_index_count_done
    repne scasb
    jnz .Ldoc_index_count_done
    inc ebx
    cmp ebx, DOC_INDEX_MAX_LINES
    ja .Ldoc_index_rebuild_failed
    jmp .Ldoc_index_count_contiguous

.Ldoc_index_count_generic:
    xor r12d, r12d
.Ldoc_index_count_lines:
    cmp r12d, r15d
    jae .Ldoc_index_count_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    jne .Ldoc_index_count_next
    inc ebx
    cmp ebx, DOC_INDEX_MAX_LINES
    ja .Ldoc_index_rebuild_failed
.Ldoc_index_count_next:
    inc r12d
    jmp .Ldoc_index_count_lines

.Ldoc_index_count_done:
    mov edi, ebx
    call doc_line_index_reserve
    test rax, rax
    js .Ldoc_index_rebuild_failed
    mov dword ptr [rip + doc_line_count], ebx
    mov dword ptr [rip + doc_max_line_width], 0

    mov eax, dword ptr [rip + doc_gap_start]
    cmp eax, r15d
    jne .Ldoc_index_fill_generic
    xor r12d, r12d              # logical line start
    xor r14d, r14d              # zero-based line index
.Ldoc_index_fill_contiguous:
    mov rdi, qword ptr [rip + doc_buffer]
    mov eax, r12d
    add rdi, rax
    mov ecx, r15d
    sub ecx, r12d
    mov al, 10
    test ecx, ecx
    jz .Ldoc_index_fill_contiguous_last
    repne scasb
    jnz .Ldoc_index_fill_contiguous_last

    # RDI points immediately after the newline found by SCASB.
    mov r13, qword ptr [rip + doc_buffer]
    sub rdi, r13
    mov r13d, edi               # exclusive logical line end
    mov esi, r13d
    sub esi, r12d
    mov edi, r12d
    call doc_line_index_measure_rows
    mov ebx, eax
    mov rdx, qword ptr [rip + doc_line_index_base]
    mov eax, r14d
    shl rax, 4
    add rdx, rax
    mov eax, r13d
    sub eax, r12d
    mov dword ptr [rdx + DOC_INDEX_BYTES_OFFSET], eax
    mov dword ptr [rdx + DOC_INDEX_ROWS_OFFSET], ebx
    mov r12d, r13d
    inc r14d
    jmp .Ldoc_index_fill_contiguous

.Ldoc_index_fill_contiguous_last:
    mov esi, r15d
    sub esi, r12d
    mov ebp, esi
    mov edi, r12d
    mov esi, ebp
    call doc_line_index_measure_rows
    mov ebx, eax
    mov rdx, qword ptr [rip + doc_line_index_base]
    mov ecx, r14d
    shl rcx, 4
    add rdx, rcx
    mov dword ptr [rdx + DOC_INDEX_BYTES_OFFSET], ebp
    mov dword ptr [rdx + DOC_INDEX_ROWS_OFFSET], ebx
    call doc_line_index_build_trees
    mov eax, dword ptr [rip + window_doc_pixel_width]
    mov dword ptr [rip + doc_line_index_columns], eax
    mov dword ptr [rip + doc_line_index_valid], 1
    mov eax, 1
    jmp .Ldoc_index_rebuild_return

.Ldoc_index_fill_generic:
    xor r12d, r12d              # logical line start
    xor r13d, r13d              # byte scan offset
    xor r14d, r14d              # zero-based line index
.Ldoc_index_fill_lines:
    cmp r13d, r15d
    jae .Ldoc_index_fill_last_line
    mov edi, r13d
    call doc_byte_at
    cmp eax, 10
    jne .Ldoc_index_fill_next_byte
    lea esi, [r13d + 1]
    sub esi, r12d
    mov edi, r12d
    call doc_line_index_measure_rows
    mov ebx, eax
    mov rdx, qword ptr [rip + doc_line_index_base]
    mov eax, r14d
    shl rax, 4
    add rdx, rax
    lea ecx, [r13d + 1]
    sub ecx, r12d
    mov dword ptr [rdx + DOC_INDEX_BYTES_OFFSET], ecx
    mov dword ptr [rdx + DOC_INDEX_ROWS_OFFSET], ebx
    lea r12d, [r13d + 1]
    inc r14d
.Ldoc_index_fill_next_byte:
    inc r13d
    jmp .Ldoc_index_fill_lines
.Ldoc_index_fill_last_line:
    mov esi, r15d
    sub esi, r12d
    mov ebp, esi
    mov edi, r12d
    mov esi, ebp
    call doc_line_index_measure_rows
    mov ebx, eax
    mov rdx, qword ptr [rip + doc_line_index_base]
    mov ecx, r14d
    shl rcx, 4
    add rdx, rcx
    mov dword ptr [rdx + DOC_INDEX_BYTES_OFFSET], ebp
    mov dword ptr [rdx + DOC_INDEX_ROWS_OFFSET], ebx
    call doc_line_index_build_trees
    mov eax, dword ptr [rip + window_doc_pixel_width]
    mov dword ptr [rip + doc_line_index_columns], eax
    mov dword ptr [rip + doc_line_index_valid], 1
    mov eax, 1
    jmp .Ldoc_index_rebuild_return
.Ldoc_index_rebuild_failed:
    mov dword ptr [rip + doc_line_count], 0
    mov dword ptr [rip + doc_line_index_valid], 2
    xor eax, eax
.Ldoc_index_rebuild_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_line_index_rebuild, . - doc_line_index_rebuild

.type doc_line_index_ensure, @function
doc_line_index_ensure:
    push rbx
    push r12
    push r13
    cmp dword ptr [rip + doc_line_index_valid], 2
    je .Ldoc_index_ensure_unavailable
    cmp dword ptr [rip + doc_line_index_valid], 0
    je .Ldoc_index_ensure_rebuild
    mov eax, dword ptr [rip + window_doc_pixel_width]
    cmp eax, dword ptr [rip + doc_line_index_columns]
    jne .Ldoc_index_ensure_reflow
    mov eax, 1
    jmp .Ldoc_index_ensure_done
.Ldoc_index_ensure_rebuild:
    call doc_line_index_rebuild
    jmp .Ldoc_index_ensure_done
.Ldoc_index_ensure_reflow:
    call doc_line_index_reflow
    jmp .Ldoc_index_ensure_done
.Ldoc_index_ensure_unavailable:
    xor eax, eax
.Ldoc_index_ensure_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_ensure, . - doc_line_index_ensure

# Point-update a Fenwick tree by signed delta. EDI=line index, ESI=delta,
# EDX=record field offset (8 for bytes or 12 for visual rows).
.type doc_line_index_fenwick_add, @function
doc_line_index_fenwick_add:
    push rbx
    push r12
    push r13
    mov ebx, edi
    inc ebx
    mov r12d, esi
    mov r13d, edx
.Ldoc_index_fenwick_add_loop:
    cmp ebx, dword ptr [rip + doc_line_count]
    ja .Ldoc_index_fenwick_add_done
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    dec eax
    shl rax, 4
    add rdi, rax
    add rdi, r13
    add dword ptr [rdi], r12d
    mov eax, ebx
    neg eax
    and eax, ebx
    add ebx, eax
    jmp .Ldoc_index_fenwick_add_loop
.Ldoc_index_fenwick_add_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_line_index_fenwick_add, . - doc_line_index_fenwick_add

# Update a line after a single insertion. A newline splits its current record;
# ordinary bytes change one line value and point-update both Fenwick trees.
.type doc_line_index_apply_insert, @function
doc_line_index_apply_insert:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    cmp dword ptr [rip + doc_line_index_valid], 1
    jne .Ldoc_index_insert_done
    mov r12d, edi
    mov r13d, esi
    mov edi, r12d
    mov esi, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_find_prefix
    mov ebx, eax
    mov r14d, edx
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov r15d, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    cmp r13d, 10
    je .Ldoc_index_insert_newline
    mov ebp, dword ptr [rdi + DOC_INDEX_ROWS_OFFSET]
    lea eax, [r15d + 1]
    mov dword ptr [rdi + DOC_INDEX_BYTES_OFFSET], eax
    mov edi, r14d
    mov esi, eax
    call doc_line_index_measure_rows
    mov r12d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], r12d
    mov eax, r12d
    sub eax, ebp
    mov edi, ebx
    mov esi, eax
    mov edx, DOC_INDEX_ROW_TREE_OFFSET
    call doc_line_index_fenwick_add
    mov edi, ebx
    mov esi, 1
    mov edx, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_fenwick_add
    jmp .Ldoc_index_insert_done
.Ldoc_index_insert_newline:
    mov eax, dword ptr [rip + doc_line_count]
    inc eax
    mov edi, eax
    call doc_line_index_reserve
    test rax, rax
    js .Ldoc_index_insert_invalidate
    mov r12d, dword ptr [rip + doc_line_count]
    mov ebp, dword ptr [rip + doc_cursor]
    sub ebp, r14d               # new left line includes the inserted LF
    mov ecx, r12d
    sub ecx, ebx
    dec ecx
    jz .Ldoc_index_insert_shift_done
    shl ecx, 2
    mov rsi, qword ptr [rip + doc_line_index_base]
    mov eax, r12d
    shl rax, 4
    add rsi, rax
    sub rsi, 4
    mov rdi, qword ptr [rip + doc_line_index_base]
    lea eax, [r12d + 1]
    shl rax, 4
    add rdi, rax
    sub rdi, 4
    std
    rep movsd
    cld
.Ldoc_index_insert_shift_done:
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_BYTES_OFFSET], ebp
    mov eax, r15d
    sub eax, ebp
    inc eax
    mov dword ptr [rdi + DOC_INDEX_BYTES_OFFSET + DOC_INDEX_RECORD_SIZE], eax
    inc r12d
    mov dword ptr [rip + doc_line_count], r12d
    mov edi, r14d
    mov esi, ebp
    call doc_line_index_measure_rows
    mov r13d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], r13d
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    add eax, r14d
    mov r12d, eax
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET + DOC_INDEX_RECORD_SIZE]
    mov edi, r12d
    mov esi, eax
    call doc_line_index_measure_rows
    mov r13d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    inc eax
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], r13d
    call doc_line_index_build_trees
    jmp .Ldoc_index_insert_done
.Ldoc_index_insert_invalidate:
    mov dword ptr [rip + doc_line_index_valid], 2
    mov dword ptr [rip + doc_line_count], 0
.Ldoc_index_insert_done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_line_index_apply_insert, . - doc_line_index_apply_insert

# Update a line after deletion. Removing LF merges adjacent records; deleting
# ordinary UTF-8 bytes updates only the affected line and its prefix-tree paths.
.type doc_line_index_apply_delete, @function
doc_line_index_apply_delete:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    cmp dword ptr [rip + doc_line_index_valid], 1
    jne .Ldoc_index_delete_done
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    mov edi, r12d
    mov esi, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_find_prefix
    mov ebx, eax
    mov r15d, edx
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov ebp, dword ptr [rdi + DOC_INDEX_ROWS_OFFSET]
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    test r14d, r14d
    jnz .Ldoc_index_delete_newline
    sub eax, r13d
    mov r12d, eax
    mov dword ptr [rdi + DOC_INDEX_BYTES_OFFSET], r12d
    mov edi, r15d
    mov esi, r12d
    call doc_line_index_measure_rows
    mov r12d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], r12d
    mov eax, r12d
    sub eax, ebp
    mov edi, ebx
    mov esi, eax
    mov edx, DOC_INDEX_ROW_TREE_OFFSET
    call doc_line_index_fenwick_add
    mov edi, ebx
    mov esi, r13d
    neg esi
    mov edx, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_fenwick_add
    jmp .Ldoc_index_delete_done
.Ldoc_index_delete_newline:
    mov r12d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov rdx, qword ptr [rip + doc_line_index_base]
    lea eax, [ebx + 1]
    shl rax, 4
    add rdx, rax
    add r12d, dword ptr [rdx + DOC_INDEX_BYTES_OFFSET]
    sub r12d, r13d
    mov ecx, dword ptr [rip + doc_line_count]
    sub ecx, ebx
    sub ecx, 2
    jle .Ldoc_index_delete_shift_done
    shl ecx, 2
    mov rsi, qword ptr [rip + doc_line_index_base]
    lea eax, [ebx + 2]
    shl rax, 4
    add rsi, rax
    mov rdi, qword ptr [rip + doc_line_index_base]
    lea eax, [ebx + 1]
    shl rax, 4
    add rdi, rax
    cld
    rep movsd
.Ldoc_index_delete_shift_done:
    mov eax, dword ptr [rip + doc_line_count]
    dec eax
    mov dword ptr [rip + doc_line_count], eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_BYTES_OFFSET], r12d
    mov edi, r15d
    mov esi, r12d
    call doc_line_index_measure_rows
    mov r12d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov dword ptr [rdi + DOC_INDEX_ROWS_OFFSET], r12d
    call doc_line_index_build_trees
.Ldoc_index_delete_done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_line_index_apply_delete, . - doc_line_index_apply_delete


# Insert one byte at the logical cursor. Grow the mapping when its gap is empty.
.global doc_insert_byte
.type doc_insert_byte, @function
# Insert a byte at the logical cursor by consuming one byte from the gap.
doc_insert_byte:
    push rbx
    push r12
    push r13
    mov r13d, edi
    mov edi, dword ptr [rip + doc_cursor]
    mov esi, r13d
    call history_note_insert
    mov edi, r13d
    call doc_line_index_ensure
    mov edi, dword ptr [rip + doc_cursor]
    call doc_move_gap
    mov eax, dword ptr [rip + doc_gap_start]
    cmp eax, dword ptr [rip + doc_gap_end]
    jb .doc_insert_has_space
    call doc_buffer_grow
    test rax, rax
    js .doc_insert_allocation_failed
    mov eax, dword ptr [rip + doc_gap_start]
.doc_insert_has_space:
    mov r12, qword ptr [rip + doc_buffer]
    mov byte ptr [r12 + rax], r13b
    inc dword ptr [rip + doc_gap_start]
    inc dword ptr [rip + doc_length]
    inc dword ptr [rip + doc_cursor]
    inc dword ptr [rip + doc_revision]
    mov dword ptr [rip + doc_storage_error], 0
    mov edi, dword ptr [rip + doc_cursor]
    dec edi
    mov esi, r13d
    call doc_line_index_apply_insert
    jmp .doc_insert_done
.doc_insert_allocation_failed:
    mov dword ptr [rip + doc_storage_error], 1
.doc_insert_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_insert_byte, . - doc_insert_byte

# Insert a byte range at the document cursor. This is the large-paste path:
# reserve/move once, record one history operation, copy once, then rebuild the
# derived line index lazily on the next render instead of point-updating it
# once per byte.
.global doc_insert_bytes
.type doc_insert_bytes, @function
doc_insert_bytes:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13d, esi
    test r13d, r13d
    jz .Ldoc_insert_bytes_success

    # Reject uint32 overflow before asking the gap buffer to reserve capacity.
    mov eax, dword ptr [rip + doc_length]
    add eax, r13d
    jc .Ldoc_insert_bytes_failed
    mov edi, eax
    call doc_buffer_reserve
    test rax, rax
    js .Ldoc_insert_bytes_failed

    # A single gap move gives the bulk range one contiguous destination.
    mov edi, dword ptr [rip + doc_cursor]
    call doc_move_gap
    mov eax, dword ptr [rip + doc_gap_end]
    sub eax, dword ptr [rip + doc_gap_start]
    cmp eax, r13d
    jb .Ldoc_insert_bytes_failed

    # History stores the inserted bytes as one operation. During Undo/Redo,
    # history replay suppresses this notification as it does for single bytes.
    mov edi, dword ptr [rip + doc_cursor]
    mov rsi, r12
    mov edx, r13d
    call history_note_insert_bytes

    mov rdi, qword ptr [rip + doc_buffer]
    mov eax, dword ptr [rip + doc_gap_start]
    add rdi, rax
    mov rsi, r12
    mov ecx, r13d
    cld
    rep movsb

    mov eax, r13d
    add dword ptr [rip + doc_gap_start], eax
    add dword ptr [rip + doc_length], eax
    add dword ptr [rip + doc_cursor], eax
    inc dword ptr [rip + doc_revision]
    mov dword ptr [rip + doc_storage_error], 0

    # The line index is derived from document bytes. Rebuild it once when the
    # next frame needs it; preserve the sticky "unavailable" state.
    cmp dword ptr [rip + doc_line_index_valid], 2
    je .Ldoc_insert_bytes_success
    mov dword ptr [rip + doc_line_index_valid], 0
.Ldoc_insert_bytes_success:
    xor eax, eax
    jmp .Ldoc_insert_bytes_return
.Ldoc_insert_bytes_failed:
    mov dword ptr [rip + doc_storage_error], 1
    mov rax, -12
.Ldoc_insert_bytes_return:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_insert_bytes, . - doc_insert_bytes

# Insert one Unicode scalar as one to four UTF-8 bytes at the document cursor.
# The caller has already removed an active selection, so all bytes belong to
# the same key input action and the existing grapheme/index machinery applies.
.global doc_insert_codepoint_utf8
.type doc_insert_codepoint_utf8, @function
doc_insert_codepoint_utf8:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16
    mov r12d, edi
    cmp r12d, 0x10ffff
    ja .Ldoc_insert_codepoint_done
    cmp r12d, 0x20
    jb .Ldoc_insert_codepoint_done
    cmp r12d, 0x7f
    jb .Ldoc_insert_codepoint_one
    cmp r12d, 0x9f
    jbe .Ldoc_insert_codepoint_done
    cmp r12d, 0xd800
    jb .Ldoc_insert_codepoint_scalar
    cmp r12d, 0xdfff
    jbe .Ldoc_insert_codepoint_done
.Ldoc_insert_codepoint_scalar:
    cmp r12d, 0x7ff
    jbe .Ldoc_insert_codepoint_two
    cmp r12d, 0xffff
    jbe .Ldoc_insert_codepoint_three
    # Four-byte UTF-8: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx.
    mov eax, r12d
    shr eax, 18
    or eax, 0xf0
    mov byte ptr [rsp], al
    mov eax, r12d
    shr eax, 12
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 1], al
    mov eax, r12d
    shr eax, 6
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 2], al
    mov eax, r12d
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 3], al
    mov r13d, 4
    jmp .Ldoc_insert_codepoint_emit
.Ldoc_insert_codepoint_three:
    # Three-byte UTF-8: 1110xxxx 10xxxxxx 10xxxxxx.
    mov eax, r12d
    shr eax, 12
    or eax, 0xe0
    mov byte ptr [rsp], al
    mov eax, r12d
    shr eax, 6
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 1], al
    mov eax, r12d
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 2], al
    mov r13d, 3
    jmp .Ldoc_insert_codepoint_emit
.Ldoc_insert_codepoint_two:
    # Two-byte UTF-8: 110xxxxx 10xxxxxx.
    mov eax, r12d
    shr eax, 6
    or eax, 0xc0
    mov byte ptr [rsp], al
    mov eax, r12d
    and eax, 0x3f
    or eax, 0x80
    mov byte ptr [rsp + 1], al
    mov r13d, 2
    jmp .Ldoc_insert_codepoint_emit
.Ldoc_insert_codepoint_one:
    mov byte ptr [rsp], r12b
    mov r13d, 1
.Ldoc_insert_codepoint_emit:
    xor r14d, r14d
.Ldoc_insert_codepoint_loop:
    cmp r14d, r13d
    jae .Ldoc_insert_codepoint_done
    movzx edi, byte ptr [rsp + r14]
    call doc_insert_byte
    inc r14d
    jmp .Ldoc_insert_codepoint_loop
.Ldoc_insert_codepoint_done:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_insert_codepoint_utf8, . - doc_insert_codepoint_utf8

.type doc_delete_at_cursor, @function
doc_delete_at_cursor:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    mov r12d, dword ptr [rip + doc_cursor]
    cmp r12d, dword ptr [rip + doc_length]
    jae .doc_delete_done
    call doc_line_index_ensure
    mov edi, r12d
    call doc_byte_at
    xor ebp, ebp
    cmp eax, 10
    sete bpl
    mov edi, r12d
    call doc_grapheme_next
    mov r13d, eax
    mov dword ptr [rip + doc_grapheme_newline_flag], 0
    mov r14d, r12d
.Ldoc_delete_cluster_check_newline:
    cmp r14d, r13d
    jae .Ldoc_delete_cluster_newline_checked
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    jne .Ldoc_delete_cluster_advance
    mov dword ptr [rip + doc_grapheme_newline_flag], 1
.Ldoc_delete_cluster_advance:
    inc r14d
    jmp .Ldoc_delete_cluster_check_newline
.Ldoc_delete_cluster_newline_checked:
    mov edi, r12d
    call doc_move_gap
    mov r14d, r13d
    sub r14d, r12d
    mov edi, r12d
    mov esi, r14d
    call history_note_delete
    add dword ptr [rip + doc_gap_end], r14d
    sub dword ptr [rip + doc_length], r14d
    inc dword ptr [rip + doc_revision]
    mov edi, r12d
    mov esi, r14d
    mov edx, dword ptr [rip + doc_grapheme_newline_flag]
    call doc_line_index_apply_delete
.doc_delete_done:
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_delete_at_cursor, . - doc_delete_at_cursor

.global doc_delete_selection
.type doc_delete_selection, @function
# Remove a logical selection by extending the gap over its selected bytes.
doc_delete_selection:
    push rbx
    push r12
    push r13
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_delete_selection_done
    mov dword ptr [rip + doc_line_index_valid], 0
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_delete_selection_bounds
    xchg eax, edx
.Lneko_delete_selection_bounds:
    mov ebx, eax
    mov r12d, edx
    mov edi, ebx
    mov esi, r12d
    sub esi, ebx
    call history_note_delete
    mov edi, ebx
    call doc_move_gap
    mov r13d, r12d
    sub r13d, ebx
    add dword ptr [rip + doc_gap_end], r13d
    sub dword ptr [rip + doc_length], r13d
    test r13d, r13d
    jz .Lneko_delete_selection_no_revision
    inc dword ptr [rip + doc_revision]
.Lneko_delete_selection_no_revision:
    mov dword ptr [rip + doc_cursor], ebx
    mov dword ptr [rip + doc_selection_anchor], ebx
    mov dword ptr [rip + doc_selection_active], 0
.Lneko_delete_selection_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_delete_selection, . - doc_delete_selection

# Clear selection state while retaining the current insertion point.
.global doc_clear_selection
.type doc_clear_selection, @function
doc_clear_selection:
    mov dword ptr [rip + doc_selection_active], 0
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
    ret
.size doc_clear_selection, . - doc_clear_selection

# Start compositor-configured repeat for ordinary keys. Modifier and lock
# keys are intentionally excluded. EAX=Linux evdev keycode.
.type repeat_start_if_supported, @function
repeat_start_if_supported:
    # Shift, Ctrl, Alt, Meta/Super, Caps/Num/Scroll Lock and Compose do not repeat.
    cmp eax, 42
    je .Lneko_repeat_start_done
    cmp eax, 54
    je .Lneko_repeat_start_done
    cmp eax, 29
    je .Lneko_repeat_start_done
    cmp eax, 97
    je .Lneko_repeat_start_done
    cmp eax, 56
    je .Lneko_repeat_start_done
    cmp eax, 100
    je .Lneko_repeat_start_done
    cmp eax, 125
    je .Lneko_repeat_start_done
    cmp eax, 126
    je .Lneko_repeat_start_done
    cmp eax, 58
    je .Lneko_repeat_start_done
    cmp eax, 69
    je .Lneko_repeat_start_done
    cmp eax, 70
    je .Lneko_repeat_start_done
    cmp eax, 127
    je .Lneko_repeat_start_done
    cmp dword ptr [rip + repeat_rate], 0
    je .Lneko_repeat_start_done
    mov dword ptr [rip + repeat_keycode], eax
    # itimerspec.it_interval = 1 second / repeat_rate.
    mov qword ptr [rip + repeat_timer_spec], 0
    mov qword ptr [rip + repeat_timer_spec + 8], 0
    mov rax, REPEAT_NS_PER_SECOND
    xor edx, edx
    mov ecx, dword ptr [rip + repeat_rate]
    div rcx
    mov rcx, REPEAT_NS_PER_SECOND
    xor edx, edx
    div rcx
    mov qword ptr [rip + repeat_timer_spec], rax
    mov qword ptr [rip + repeat_timer_spec + 8], rdx
    # itimerspec.it_value = configured initial delay in milliseconds.
    mov eax, dword ptr [rip + repeat_delay_ms]
    imul rax, rax, 1000000
    mov rcx, REPEAT_NS_PER_SECOND
    xor edx, edx
    div rcx
    mov qword ptr [rip + repeat_timer_spec + 16], rax
    mov qword ptr [rip + repeat_timer_spec + 24], rdx
    # timerfd interprets a zero it_value as disarmed; represent a zero-delay
    # repeat with the smallest non-zero expiration.
    cmp dword ptr [rip + repeat_delay_ms], 0
    jne .Lneko_repeat_timer_arm
    mov qword ptr [rip + repeat_timer_spec + 24], 1
.Lneko_repeat_timer_arm:
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + repeat_timer_fd]
    xor esi, esi
    lea rdx, [rip + repeat_timer_spec]
    xor r10d, r10d
    syscall
.Lneko_repeat_start_done:
    ret
.size repeat_start_if_supported, . - repeat_start_if_supported

# A separate periodic timer drives edge auto-scroll during mouse selection.
# The initial 120ms delay avoids scrolling during an ordinary short drag.
.type doc_drag_timer_start, @function
doc_drag_timer_start:
    cmp dword ptr [rip + doc_drag_timer_fd], 0
    je .Ldoc_drag_timer_start_done
    mov qword ptr [rip + doc_drag_timer_spec], 0
    mov qword ptr [rip + doc_drag_timer_spec + 8], DOC_DRAG_SCROLL_TICK_NS
    mov qword ptr [rip + doc_drag_timer_spec + 16], 0
    mov qword ptr [rip + doc_drag_timer_spec + 24], DOC_DRAG_SCROLL_INITIAL_NS
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + doc_drag_timer_fd]
    xor esi, esi
    lea rdx, [rip + doc_drag_timer_spec]
    xor r10d, r10d
    syscall
    ret
.Ldoc_drag_timer_start_done:
    xor eax, eax
    ret
.size doc_drag_timer_start, . - doc_drag_timer_start

.type doc_drag_timer_stop, @function
doc_drag_timer_stop:
    cmp dword ptr [rip + doc_drag_timer_fd], 0
    je .Ldoc_drag_timer_stop_done
    mov qword ptr [rip + doc_drag_timer_spec], 0
    mov qword ptr [rip + doc_drag_timer_spec + 8], 0
    mov qword ptr [rip + doc_drag_timer_spec + 16], 0
    mov qword ptr [rip + doc_drag_timer_spec + 24], 0
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + doc_drag_timer_fd]
    xor esi, esi
    lea rdx, [rip + doc_drag_timer_spec]
    xor r10d, r10d
    syscall
    ret
.Ldoc_drag_timer_stop_done:
    xor eax, eax
    ret
.size doc_drag_timer_stop, . - doc_drag_timer_stop

.type repeat_cancel, @function
repeat_cancel:
    mov dword ptr [rip + repeat_keycode], 0
    cmp dword ptr [rip + repeat_timer_fd], 0
    je .Lneko_repeat_cancel_done
    mov qword ptr [rip + repeat_timer_spec], 0
    mov qword ptr [rip + repeat_timer_spec + 8], 0
    mov qword ptr [rip + repeat_timer_spec + 16], 0
    mov qword ptr [rip + repeat_timer_spec + 24], 0
    mov eax, SYS_timerfd_settime
    mov edi, dword ptr [rip + repeat_timer_fd]
    xor esi, esi
    lea rdx, [rip + repeat_timer_spec]
    xor r10d, r10d
    syscall
.Lneko_repeat_cancel_done:
    ret
.size repeat_cancel, . - repeat_cancel

# Begin or update a selection driven by Shift+navigation.
.type doc_begin_keyboard_selection, @function
doc_begin_keyboard_selection:
    cmp dword ptr [rip + doc_selection_active], 0
    jne .Lneko_begin_keyboard_selection_done
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
.Lneko_begin_keyboard_selection_done:
    ret
.size doc_begin_keyboard_selection, . - doc_begin_keyboard_selection

.type doc_finish_keyboard_selection, @function
doc_finish_keyboard_selection:
    mov eax, dword ptr [rip + doc_cursor]
    cmp eax, dword ptr [rip + doc_selection_anchor]
    je .Lneko_finish_keyboard_selection_clear
    mov dword ptr [rip + doc_selection_active], 1
    ret
.Lneko_finish_keyboard_selection_clear:
    mov dword ptr [rip + doc_selection_active], 0
    ret
.size doc_finish_keyboard_selection, . - doc_finish_keyboard_selection

# EDI=0 Home, EDI=1 End.
.type doc_move_line_edge, @function
doc_move_line_edge:
    push rbx
    push r12
    mov r12d, edi
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov ebx, eax
    mov edi, ebx
    xor esi, esi
    test r12d, r12d
    jz .Lneko_visual_edge_lookup
    inc edi
.Lneko_visual_edge_lookup:
    call doc_visual_to_offset
    test r12d, r12d
    jz .Lneko_visual_edge_store
    test eax, eax
    jz .Lneko_visual_edge_store
    mov ebx, eax
    lea edi, [rbx - 1]
    call doc_byte_at
    cmp eax, 10
    jne .Lneko_visual_edge_store_ebx
    dec ebx
    test ebx, ebx
    jz .Lneko_visual_edge_store_ebx
    lea edi, [rbx - 1]
    call doc_byte_at
    cmp eax, 13
    jne .Lneko_visual_edge_store_ebx
    dec ebx
.Lneko_visual_edge_store_ebx:
    mov eax, ebx
.Lneko_visual_edge_store:
    mov dword ptr [rip + doc_cursor], eax
    pop r12
    pop rbx
    ret
.size doc_move_line_edge, . - doc_move_line_edge

# Place the document cursor from surface-local pixel coordinates.
# EDI=x, ESI=y. Clicks snap to the nearest character insertion boundary;
# tabs occupy four cells and UTF-8 continuation bytes are never cursor stops.
# Map a document byte offset to its soft-wrapped visual row and column.
# EDI=byte offset; returns EAX=row and EDX=column.
.type doc_offset_to_visual, @function
doc_offset_to_visual:
    push r12
    mov r12d, edi
    call doc_line_index_ensure
    test eax, eax
    jz .Ldoc_offset_wrapper_legacy
    mov edi, r12d
    call doc_offset_to_visual_indexed
    jmp .Ldoc_offset_wrapper_done
.Ldoc_offset_wrapper_legacy:
    mov edi, r12d
    call doc_offset_to_visual_legacy
.Ldoc_offset_wrapper_done:
    pop r12
    ret
.size doc_offset_to_visual, . - doc_offset_to_visual

.type doc_offset_to_visual_legacy, @function
.type doc_offset_to_visual_legacy, @function
doc_offset_to_visual_legacy:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, dword ptr [rip + doc_length]
    cmp r12d, r13d
    cmova r12d, r13d
    xor r14d, r14d
    xor ebx, ebx
    xor r15d, r15d
.Lneko_offset_visual_scan:
    cmp r15d, r12d
    jae .Lneko_offset_visual_boundary
    mov edi, r15d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_offset_visual_newline
    cmp eax, 9
    je .Lneko_offset_visual_tab
    cmp eax, 32
    jb .Lneko_offset_visual_skip
    cmp eax, 128
    jb .Lneko_offset_visual_ascii
    mov edi, r15d
    call doc_utf8_decode_at
.Lneko_offset_visual_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [ebx + eax]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_offset_visual_glyph_fit
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_offset_visual_glyph_fit
    inc r14d
    xor ebx, ebx
.Lneko_offset_visual_glyph_fit:
    add ebx, eax
    mov edi, r15d
    call doc_grapheme_next
    mov r15d, eax
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_newline:
    inc r14d
    xor ebx, ebx
    inc r15d
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_tab:
    lea eax, [rbx + 32]
    and eax, -32
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_offset_visual_tab_fit
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_offset_visual_tab_fit
    inc r14d
    mov ebx, 32
    inc r15d
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_tab_fit:
    mov ebx, eax
    inc r15d
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_skip:
    inc r15d
    jmp .Lneko_offset_visual_scan
.Lneko_offset_visual_boundary:
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_offset_visual_done
    cmp r12d, r13d
    jae .Lneko_offset_visual_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_offset_visual_done
    cmp eax, 9
    je .Lneko_offset_visual_boundary_tab
    cmp eax, 32
    jb .Lneko_offset_visual_done
    cmp eax, 128
    jb .Lneko_offset_visual_boundary_ascii
    mov edi, r12d
    call doc_utf8_decode_at
.Lneko_offset_visual_boundary_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [ebx + eax]
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_offset_visual_done
    inc r14d
    xor ebx, ebx
    jmp .Lneko_offset_visual_done
.Lneko_offset_visual_boundary_tab:
    lea edx, [rbx + 32]
    and edx, -32
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_offset_visual_done
    inc r14d
    xor ebx, ebx
.Lneko_offset_visual_done:
    mov eax, r14d
    mov edx, ebx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_offset_to_visual_legacy, . - doc_offset_to_visual_legacy


# Fenwick lookup narrows visual mapping to one logical line; local scanning
# preserves the editor's existing tab, control-byte, and UTF-8 semantics.
.type doc_offset_to_visual_indexed, @function
.type doc_offset_to_visual_indexed, @function
doc_offset_to_visual_indexed:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12d, edi
    mov edi, r12d
    mov esi, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_find_prefix
    mov ebx, eax
    mov r13d, edx
    mov edi, ebx
    mov esi, DOC_INDEX_ROW_TREE_OFFSET
    call doc_line_index_prefix_sum
    mov ebp, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    add eax, r13d
    mov r15d, eax
    cmp r12d, r15d
    cmova r12d, r15d
    xor ebx, ebx
    xor r14d, r14d
.Ldoc_offset_indexed_scan:
    cmp r13d, r12d
    jae .Ldoc_offset_indexed_boundary
    mov edi, r13d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_offset_indexed_done
    cmp eax, 9
    je .Ldoc_offset_indexed_tab
    cmp eax, 32
    jb .Ldoc_offset_indexed_control
    cmp eax, 128
    jb .Ldoc_offset_indexed_ascii
    mov edi, r13d
    call doc_utf8_decode_at
.Ldoc_offset_indexed_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [r14d + eax]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Ldoc_offset_indexed_glyph_fit
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_offset_indexed_glyph_fit
    inc ebx
    xor r14d, r14d
.Ldoc_offset_indexed_glyph_fit:
    add r14d, eax
    mov edi, r13d
    call doc_grapheme_next
    mov r13d, eax
    jmp .Ldoc_offset_indexed_scan
.Ldoc_offset_indexed_tab:
    lea eax, [r14d + 32]
    and eax, -32
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Ldoc_offset_indexed_tab_fit
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_offset_indexed_tab_fit
    inc ebx
    mov r14d, 32
    inc r13d
    jmp .Ldoc_offset_indexed_scan
.Ldoc_offset_indexed_tab_fit:
    mov r14d, eax
    inc r13d
    jmp .Ldoc_offset_indexed_scan
.Ldoc_offset_indexed_control:
    inc r13d
    jmp .Ldoc_offset_indexed_scan
.Ldoc_offset_indexed_boundary:
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Ldoc_offset_indexed_done
    cmp r12d, dword ptr [rip + doc_length]
    jae .Ldoc_offset_indexed_done
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_offset_indexed_done
    cmp eax, 9
    je .Ldoc_offset_indexed_boundary_tab
    cmp eax, 32
    jb .Ldoc_offset_indexed_done
    cmp eax, 128
    jb .Ldoc_offset_indexed_boundary_ascii
    mov edi, r12d
    call doc_utf8_decode_at
.Ldoc_offset_indexed_boundary_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [r14d + eax]
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_offset_indexed_done
    inc ebx
    xor r14d, r14d
    jmp .Ldoc_offset_indexed_done
.Ldoc_offset_indexed_boundary_tab:
    lea edx, [r14d + 32]
    and edx, -32
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_offset_indexed_done
    inc ebx
    xor r14d, r14d
.Ldoc_offset_indexed_done:
    add ebp, ebx
    mov eax, ebp
    mov edx, r14d
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_offset_to_visual_indexed, . - doc_offset_to_visual_indexed

.type doc_visual_to_offset_indexed, @function
.type doc_visual_to_offset_indexed, @function
doc_visual_to_offset_indexed:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12d, edi
    mov ebp, esi
    mov edi, r12d
    mov esi, DOC_INDEX_ROW_TREE_OFFSET
    call doc_line_index_find_prefix
    mov ebx, eax
    sub r12d, edx
    mov edi, ebx
    mov esi, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_prefix_sum
    mov r13d, eax
    mov rdi, qword ptr [rip + doc_line_index_base]
    mov eax, ebx
    shl rax, 4
    add rdi, rax
    mov eax, dword ptr [rdi + DOC_INDEX_BYTES_OFFSET]
    add eax, r13d
    mov r15d, eax
    xor ebx, ebx
    xor r14d, r14d
.Ldoc_visual_indexed_scan:
    cmp r13d, r15d
    jae .Ldoc_visual_indexed_done
    mov edi, r13d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_visual_indexed_newline
    cmp eax, 9
    je .Ldoc_visual_indexed_tab
    cmp eax, 32
    jb .Ldoc_visual_indexed_control
    cmp eax, 128
    jb .Ldoc_visual_indexed_ascii
    mov edi, r13d
    call doc_utf8_decode_at
.Ldoc_visual_indexed_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    mov dword ptr [rsp], eax
    lea edx, [r14d + eax]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Ldoc_visual_indexed_glyph_row_ready
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_visual_indexed_glyph_row_ready
    inc ebx
    xor r14d, r14d
.Ldoc_visual_indexed_glyph_row_ready:
    cmp ebx, r12d
    ja .Ldoc_visual_indexed_done
    jne .Ldoc_visual_indexed_consume_glyph
    mov edx, eax
    shr edx, 1
    add edx, r14d
    cmp ebp, edx
    jb .Ldoc_visual_indexed_done
.Ldoc_visual_indexed_consume_glyph:
    add r14d, dword ptr [rsp]
    mov edi, r13d
    call doc_grapheme_next
    mov r13d, eax
    jmp .Ldoc_visual_indexed_scan
.Ldoc_visual_indexed_newline:
    cmp ebx, r12d
    je .Ldoc_visual_indexed_done
    inc ebx
    xor r14d, r14d
    inc r13d
    jmp .Ldoc_visual_indexed_scan
.Ldoc_visual_indexed_tab:
    lea eax, [r14d + 32]
    and eax, -32
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Ldoc_visual_indexed_tab_fit
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Ldoc_visual_indexed_tab_fit
    inc ebx
    xor r14d, r14d
    mov eax, 32
    jmp .Ldoc_visual_indexed_tab_row_ready
.Ldoc_visual_indexed_tab_fit:
    # EAX is the next four-cell tab stop.
    nop
.Ldoc_visual_indexed_tab_row_ready:
    cmp ebx, r12d
    ja .Ldoc_visual_indexed_done
    jne .Ldoc_visual_indexed_consume_tab
    mov edx, eax
    sub edx, r14d
    shr edx, 1
    add edx, r14d
    cmp ebp, edx
    jb .Ldoc_visual_indexed_done
.Ldoc_visual_indexed_consume_tab:
    mov r14d, eax
    inc r13d
    jmp .Ldoc_visual_indexed_scan
.Ldoc_visual_indexed_control:
    # CRLF is one grapheme and cannot expose the byte boundary between CR/LF.
    cmp eax, 13
    jne .Ldoc_visual_indexed_control_byte
    lea edi, [r13d + 1]
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_visual_indexed_done
.Ldoc_visual_indexed_control_byte:
    inc r13d
    jmp .Ldoc_visual_indexed_scan
.Ldoc_visual_indexed_done:
    mov eax, r13d
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_visual_to_offset_indexed, . - doc_visual_to_offset_indexed


# Map a visual row/column to the nearest byte insertion boundary.
# EDI=visual row, ESI=visual column; returns EAX=byte offset.
.type doc_visual_to_offset, @function
doc_visual_to_offset:
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    call doc_line_index_ensure
    test eax, eax
    jz .Ldoc_visual_wrapper_legacy
    mov edi, r12d
    mov esi, r13d
    call doc_visual_to_offset_indexed
    jmp .Ldoc_visual_wrapper_done
.Ldoc_visual_wrapper_legacy:
    mov edi, r12d
    mov esi, r13d
    call doc_visual_to_offset_legacy
.Ldoc_visual_wrapper_done:
    pop r14
    pop r13
    pop r12
    ret
.size doc_visual_to_offset, . - doc_visual_to_offset

.type doc_visual_to_offset_legacy, @function
.type doc_visual_to_offset_legacy, @function
doc_visual_to_offset_legacy:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r15d, dword ptr [rip + doc_length]
    xor r14d, r14d
    xor ebx, ebx
    xor ebp, ebp
.Lneko_visual_offset_scan:
    cmp r14d, r15d
    jae .Lneko_visual_offset_end
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_visual_offset_newline
    cmp eax, 9
    je .Lneko_visual_offset_tab
    cmp eax, 32
    jb .Lneko_visual_offset_skip
    cmp eax, 128
    jb .Lneko_visual_offset_ascii
    mov edi, r14d
    call doc_utf8_decode_at
.Lneko_visual_offset_ascii:
    mov edi, eax
    call font_codepoint_advance_pixels
    lea edx, [ebp + eax]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_visual_offset_glyph_row_ready
    cmp edx, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_visual_offset_glyph_row_ready
    inc ebx
    xor ebp, ebp
.Lneko_visual_offset_glyph_row_ready:
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    jne .Lneko_visual_offset_consume_glyph
    mov edx, eax
    shr edx, 1
    add edx, ebp
    cmp r13d, edx
    jb .Lneko_visual_offset_end
.Lneko_visual_offset_consume_glyph:
    add ebp, eax
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_newline:
    cmp ebx, r12d
    je .Lneko_visual_offset_end
    inc ebx
    xor ebp, ebp
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_tab:
    lea eax, [rbp + 32]
    and eax, -32
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_visual_offset_tab_fit
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_visual_offset_tab_fit
    inc ebx
    xor ebp, ebp
    mov eax, 32
    jmp .Lneko_visual_offset_tab_row_ready
.Lneko_visual_offset_tab_fit:
    nop
.Lneko_visual_offset_tab_row_ready:
    cmp ebx, r12d
    ja .Lneko_visual_offset_end
    jne .Lneko_visual_offset_consume_tab
    mov edx, eax
    sub edx, ebp
    shr edx, 1
    add edx, ebp
    cmp r13d, edx
    jb .Lneko_visual_offset_end
.Lneko_visual_offset_consume_tab:
    mov ebp, eax
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_skip:
    # Keep CRLF as one insertion boundary.
    cmp eax, 13
    jne .Lneko_visual_offset_skip_byte
    lea edi, [r14d + 1]
    call doc_byte_at
    cmp eax, 10
    jne .Lneko_visual_offset_skip_byte
    cmp ebx, r12d
    je .Lneko_visual_offset_end
    inc ebx
    xor ebp, ebp
    add r14d, 2
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_skip_byte:
    inc r14d
    jmp .Lneko_visual_offset_scan
.Lneko_visual_offset_end:
    mov eax, r14d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_visual_to_offset_legacy, . - doc_visual_to_offset_legacy

# Derive total visual rows and thumb geometry from the wrapped document.
# The roadmap's line-start index will later avoid scanning the complete file here.
.type doc_scrollbar_geometry, @function
doc_scrollbar_geometry:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov edi, dword ptr [rip + doc_length]
    call doc_offset_to_visual
    lea r12d, [eax + 1]
    mov dword ptr [rip + doc_total_visual_rows], r12d
    mov r13d, dword ptr [rip + window_doc_visible_rows]
    cmp r12d, r13d
    ja .Ldoc_scrollbar_overflow
    mov dword ptr [rip + doc_view_top_row], 0
    mov dword ptr [rip + doc_scroll_thumb_height], 0
    mov dword ptr [rip + doc_scroll_thumb_top], DOC_TOP
    jmp .Ldoc_scrollbar_geometry_done
.Ldoc_scrollbar_overflow:
    mov r14d, dword ptr [rip + window_doc_bottom]
    sub r14d, DOC_TOP
    mov eax, r14d
    imul eax, r13d
    xor edx, edx
    div r12d
    cmp eax, DOC_SCROLL_MIN_THUMB
    jae .Ldoc_scrollbar_thumb_minimum_ready
    mov eax, DOC_SCROLL_MIN_THUMB
.Ldoc_scrollbar_thumb_minimum_ready:
    cmp eax, r14d
    jbe .Ldoc_scrollbar_thumb_height_ready
    mov eax, r14d
.Ldoc_scrollbar_thumb_height_ready:
    mov dword ptr [rip + doc_scroll_thumb_height], eax
    mov ebx, r14d
    sub ebx, eax
    mov ecx, r12d
    sub ecx, r13d
    mov eax, dword ptr [rip + doc_view_top_row]
    cmp eax, ecx
    jbe .Ldoc_scrollbar_offset_clamped
    mov eax, ecx
    mov dword ptr [rip + doc_view_top_row], eax
.Ldoc_scrollbar_offset_clamped:
    imul rax, rbx
    xor edx, edx
    div rcx
    add eax, DOC_TOP
    mov dword ptr [rip + doc_scroll_thumb_top], eax
.Ldoc_scrollbar_geometry_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_scrollbar_geometry, . - doc_scrollbar_geometry

# EDI=signed visual-row delta; EAX reports whether the viewport moved.
.type doc_scroll_by, @function
doc_scroll_by:
    push rbx
    push r12
    push r13
    mov ebx, edi
    call doc_scrollbar_geometry
    mov eax, dword ptr [rip + doc_total_visual_rows]
    sub eax, dword ptr [rip + window_doc_visible_rows]
    jg .Ldoc_scroll_by_range_ready
    mov dword ptr [rip + doc_view_top_row], 0
    xor eax, eax
    jmp .Ldoc_scroll_by_done
.Ldoc_scroll_by_range_ready:
    mov r12d, eax
    mov r13d, dword ptr [rip + doc_view_top_row]
    test ebx, ebx
    js .Ldoc_scroll_by_up
    add r13d, ebx
    cmp r13d, r12d
    jbe .Ldoc_scroll_by_clamp
    mov r13d, r12d
    jmp .Ldoc_scroll_by_clamp
.Ldoc_scroll_by_up:
    neg ebx
    cmp r13d, ebx
    jae .Ldoc_scroll_by_subtract
    xor r13d, r13d
    jmp .Ldoc_scroll_by_clamp
.Ldoc_scroll_by_subtract:
    sub r13d, ebx
.Ldoc_scroll_by_clamp:
    cmp r13d, dword ptr [rip + doc_view_top_row]
    je .Ldoc_scroll_by_unchanged
    mov dword ptr [rip + doc_view_top_row], r13d
    mov eax, 1
    jmp .Ldoc_scroll_by_done
.Ldoc_scroll_by_unchanged:
    xor eax, eax
.Ldoc_scroll_by_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_scroll_by, . - doc_scroll_by

# EDI=signed pixel delta; horizontal movement is bounded by the active caret.
.type doc_scroll_horizontal_by, @function
doc_scroll_horizontal_by:
    push rbx
    push r12
    mov ebx, edi
    test ebx, ebx
    jz .Ldoc_scroll_horizontal_unchanged
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldoc_scroll_horizontal_unchanged
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov r12d, edx
    movsxd rax, dword ptr [rip + doc_view_left_px]
    movsxd rdx, ebx
    add rax, rdx
    test rax, rax
    jns .Ldoc_scroll_horizontal_nonnegative
    xor eax, eax
.Ldoc_scroll_horizontal_nonnegative:
    mov r12d, dword ptr [rip + doc_max_line_width]
    sub r12d, dword ptr [rip + window_doc_pixel_width]
    test r12d, r12d
    jg .Ldoc_scroll_horizontal_max_ready
    xor r12d, r12d
.Ldoc_scroll_horizontal_max_ready:
    cmp eax, r12d
    jbe .Ldoc_scroll_horizontal_clamped
    mov eax, r12d
.Ldoc_scroll_horizontal_clamped:
    cmp eax, dword ptr [rip + doc_view_left_px]
    je .Ldoc_scroll_horizontal_unchanged
    mov dword ptr [rip + doc_view_left_px], eax
    mov eax, 1
    jmp .Ldoc_scroll_horizontal_done
.Ldoc_scroll_horizontal_unchanged:
    xor eax, eax
.Ldoc_scroll_horizontal_done:
    pop r12
    pop rbx
    ret
.size doc_scroll_horizontal_by, . - doc_scroll_horizontal_by

# ESI=surface-local pointer y; map the captured thumb position to a visual row.
# Horizontal scrollbar maps the widest logical line into the document viewport.
.type doc_hscrollbar_geometry, @function
doc_hscrollbar_geometry:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldoc_hscroll_hidden
    mov r12d, dword ptr [rip + window_doc_pixel_width]
    mov r13d, dword ptr [rip + doc_max_line_width]
    cmp r13d, r12d
    ja .Ldoc_hscroll_overflow
.Ldoc_hscroll_hidden:
    mov dword ptr [rip + doc_hscroll_thumb_width], 0
    mov dword ptr [rip + doc_hscroll_thumb_left], DOC_LEFT
    mov dword ptr [rip + doc_view_left_px], 0
    jmp .Ldoc_hscroll_geometry_done
.Ldoc_hscroll_overflow:
    mov eax, r12d
    imul rax, r12
    xor edx, edx
    mov ecx, r13d
    div rcx
    cmp eax, DOC_HSCROLL_MIN_THUMB
    jae .Ldoc_hscroll_thumb_minimum_ready
    mov eax, DOC_HSCROLL_MIN_THUMB
.Ldoc_hscroll_thumb_minimum_ready:
    cmp eax, r12d
    jbe .Ldoc_hscroll_thumb_width_ready
    mov eax, r12d
.Ldoc_hscroll_thumb_width_ready:
    mov dword ptr [rip + doc_hscroll_thumb_width], eax
    mov r14d, r12d
    sub r14d, eax
    mov r15d, r13d
    sub r15d, r12d
    mov eax, dword ptr [rip + doc_view_left_px]
    cmp eax, r15d
    jbe .Ldoc_hscroll_offset_ready
    mov eax, r15d
    mov dword ptr [rip + doc_view_left_px], eax
.Ldoc_hscroll_offset_ready:
    test r14d, r14d
    jz .Ldoc_hscroll_thumb_at_origin
    imul rax, r14
    xor edx, edx
    mov ecx, r15d
    div rcx
    add eax, DOC_LEFT
    jmp .Ldoc_hscroll_thumb_store
.Ldoc_hscroll_thumb_at_origin:
    mov eax, DOC_LEFT
.Ldoc_hscroll_thumb_store:
    mov dword ptr [rip + doc_hscroll_thumb_left], eax
.Ldoc_hscroll_geometry_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_hscrollbar_geometry, . - doc_hscrollbar_geometry

# ESI=x; update horizontal pixel offset while preserving the thumb grab point.
.type doc_hscrollbar_drag_to_x, @function
doc_hscrollbar_drag_to_x:
    push rbx
    push r12
    push r13
    push r14
    mov r12d, esi
    call doc_hscrollbar_geometry
    mov eax, r12d
    sub eax, DOC_LEFT
    sub eax, dword ptr [rip + doc_hscroll_drag_offset]
    test eax, eax
    jns .Ldoc_hscroll_drag_nonnegative
    xor eax, eax
.Ldoc_hscroll_drag_nonnegative:
    mov r13d, dword ptr [rip + window_doc_pixel_width]
    sub r13d, dword ptr [rip + doc_hscroll_thumb_width]
    cmp eax, r13d
    jbe .Ldoc_hscroll_drag_track_ready
    mov eax, r13d
.Ldoc_hscroll_drag_track_ready:
    mov r14d, dword ptr [rip + doc_max_line_width]
    sub r14d, dword ptr [rip + window_doc_pixel_width]
    test r14d, r14d
    jg .Ldoc_hscroll_drag_range_ready
    xor r14d, r14d
.Ldoc_hscroll_drag_range_ready:
    test r13d, r13d
    jz .Ldoc_hscroll_drag_zero
    imul rax, r14
    xor edx, edx
    mov ecx, r13d
    div rcx
    jmp .Ldoc_hscroll_drag_store
.Ldoc_hscroll_drag_zero:
    xor eax, eax
.Ldoc_hscroll_drag_store:
    mov dword ptr [rip + doc_view_left_px], eax
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_hscrollbar_drag_to_x, . - doc_hscrollbar_drag_to_x

# ESI=x; clicking the track centers the thumb at the pointer.
.type doc_hscrollbar_begin_drag, @function
doc_hscrollbar_begin_drag:
    push rbx
    push r12
    mov r12d, esi
    call doc_hscrollbar_geometry
    cmp dword ptr [rip + doc_hscroll_thumb_width], 0
    je .Ldoc_hscroll_begin_done
    mov eax, r12d
    cmp eax, dword ptr [rip + doc_hscroll_thumb_left]
    jl .Ldoc_hscroll_begin_center
    mov edx, dword ptr [rip + doc_hscroll_thumb_left]
    add edx, dword ptr [rip + doc_hscroll_thumb_width]
    cmp eax, edx
    jae .Ldoc_hscroll_begin_center
    sub eax, dword ptr [rip + doc_hscroll_thumb_left]
    jmp .Ldoc_hscroll_begin_offset_ready
.Ldoc_hscroll_begin_center:
    mov eax, dword ptr [rip + doc_hscroll_thumb_width]
    shr eax, 1
.Ldoc_hscroll_begin_offset_ready:
    mov dword ptr [rip + doc_hscroll_drag_offset], eax
    mov dword ptr [rip + doc_hscroll_drag], 1
    mov esi, r12d
    call doc_hscrollbar_drag_to_x
.Ldoc_hscroll_begin_done:
    pop r12
    pop rbx
    ret
.size doc_hscrollbar_begin_drag, . - doc_hscrollbar_begin_drag

.type render_document_hscrollbar, @function
render_document_hscrollbar:
    cmp dword ptr [rip + doc_hscroll_thumb_width], 0
    jle .Lrender_document_hscrollbar_done
    sub rsp, 8
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, DOC_LEFT
    mov eax, dword ptr [rip + window_doc_bottom]
    add eax, 4
    mov edx, eax
    mov ecx, dword ptr [rip + window_doc_pixel_width]
    mov r8d, DOC_HSCROLL_TRACK_HEIGHT
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, dword ptr [rip + doc_hscroll_thumb_left]
    mov eax, dword ptr [rip + window_doc_bottom]
    add eax, 5
    mov edx, eax
    mov ecx, dword ptr [rip + doc_hscroll_thumb_width]
    mov r8d, DOC_HSCROLL_TRACK_HEIGHT - 2
    cmp dword ptr [rip + doc_hscroll_drag], 0
    je .Lrender_document_hscroll_thumb_normal
    mov r9d, 0xff9bb9d8
    jmp .Lrender_document_hscroll_thumb_draw
.Lrender_document_hscroll_thumb_normal:
    mov r9d, 0xff78a9d4
.Lrender_document_hscroll_thumb_draw:
    call draw_rect
    add rsp, 8
.Lrender_document_hscrollbar_done:
    ret
.size render_document_hscrollbar, . - render_document_hscrollbar

.type doc_scrollbar_drag_to_y, @function
doc_scrollbar_drag_to_y:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, esi
    call doc_scrollbar_geometry
    mov eax, r12d
    sub eax, dword ptr [rip + doc_scroll_drag_offset]
    sub eax, DOC_TOP
    mov r13d, eax
    mov r14d, dword ptr [rip + window_doc_bottom]
    sub r14d, DOC_TOP
    sub r14d, dword ptr [rip + doc_scroll_thumb_height]
    test r13d, r13d
    jns .Ldoc_scroll_drag_lower_bound
    xor r13d, r13d
.Ldoc_scroll_drag_lower_bound:
    cmp r13d, r14d
    jle .Ldoc_scroll_drag_position_ready
    mov r13d, r14d
.Ldoc_scroll_drag_position_ready:
    mov ecx, dword ptr [rip + doc_total_visual_rows]
    sub ecx, dword ptr [rip + window_doc_visible_rows]
    jg .Ldoc_scroll_drag_scale
    mov dword ptr [rip + doc_view_top_row], 0
    jmp .Ldoc_scroll_drag_done
.Ldoc_scroll_drag_scale:
    test r14d, r14d
    jz .Ldoc_scroll_drag_done
    mov eax, r13d
    imul rax, rcx
    xor edx, edx
    div r14
    mov dword ptr [rip + doc_view_top_row], eax
.Ldoc_scroll_drag_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_scrollbar_drag_to_y, . - doc_scrollbar_drag_to_y

# Begin thumb dragging; clicking elsewhere on the track centers the thumb.
# ESI=surface-local pointer y.
.type doc_scrollbar_begin_drag, @function
doc_scrollbar_begin_drag:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, esi
    call doc_scrollbar_geometry
    cmp dword ptr [rip + doc_scroll_thumb_height], 0
    je .Ldoc_scrollbar_begin_done
    mov eax, r12d
    cmp eax, dword ptr [rip + doc_scroll_thumb_top]
    jl .Ldoc_scrollbar_begin_center
    mov edx, dword ptr [rip + doc_scroll_thumb_top]
    add edx, dword ptr [rip + doc_scroll_thumb_height]
    cmp eax, edx
    jae .Ldoc_scrollbar_begin_center
    sub eax, dword ptr [rip + doc_scroll_thumb_top]
    jmp .Ldoc_scrollbar_begin_offset_ready
.Ldoc_scrollbar_begin_center:
    mov eax, dword ptr [rip + doc_scroll_thumb_height]
    shr eax, 1
.Ldoc_scrollbar_begin_offset_ready:
    mov dword ptr [rip + doc_scroll_drag_offset], eax
    mov dword ptr [rip + doc_scroll_drag], 1
    mov esi, r12d
    call doc_scrollbar_drag_to_y
.Ldoc_scrollbar_begin_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_scrollbar_begin_drag, . - doc_scrollbar_begin_drag

# Draw the vertical track and thumb only when content exceeds the viewport.
.type render_document_scrollbar, @function
render_document_scrollbar:
    cmp dword ptr [rip + doc_scroll_thumb_height], 0
    jle .Lrender_document_scrollbar_done
    sub rsp, 8
    mov rdi, qword ptr [rip + shm_mapping]
    mov eax, dword ptr [rip + window_width]
    sub eax, DOC_SCROLL_TRACK_X_OFFSET
    mov esi, eax
    mov edx, DOC_TOP
    mov ecx, DOC_SCROLL_TRACK_WIDTH
    mov r8d, dword ptr [rip + window_doc_bottom]
    sub r8d, DOC_TOP
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov eax, dword ptr [rip + window_width]
    sub eax, DOC_SCROLL_TRACK_X_OFFSET - 1
    mov esi, eax
    mov edx, dword ptr [rip + doc_scroll_thumb_top]
    mov ecx, DOC_SCROLL_TRACK_WIDTH - 2
    mov r8d, dword ptr [rip + doc_scroll_thumb_height]
    mov r9d, 0xff78a9d4
    call draw_rect
    add rsp, 8
.Lrender_document_scrollbar_done:
    ret
.size render_document_scrollbar, . - render_document_scrollbar

# Keep the active insertion point within both visible document axes.
.global doc_ensure_cursor_visible
.type doc_ensure_cursor_visible, @function
doc_ensure_cursor_visible:
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov r8d, eax
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_ensure_horizontal
    mov dword ptr [rip + doc_view_left_px], 0
    jmp .Lneko_ensure_vertical
.Lneko_ensure_horizontal:
    mov eax, edx
    cmp eax, dword ptr [rip + doc_view_left_px]
    jae .Lneko_ensure_horizontal_right
    mov dword ptr [rip + doc_view_left_px], eax
    jmp .Lneko_ensure_vertical
.Lneko_ensure_horizontal_right:
    mov ecx, dword ptr [rip + doc_view_left_px]
    add ecx, dword ptr [rip + window_doc_pixel_width]
    cmp eax, ecx
    jb .Lneko_ensure_vertical
    sub eax, dword ptr [rip + window_doc_pixel_width]
    inc eax
    mov dword ptr [rip + doc_view_left_px], eax
.Lneko_ensure_vertical:
    mov eax, r8d
    mov edx, dword ptr [rip + doc_view_top_row]
    cmp eax, edx
    jae .Lneko_ensure_cursor_lower
    mov dword ptr [rip + doc_view_top_row], eax
    ret
.Lneko_ensure_cursor_lower:
    mov ecx, dword ptr [rip + window_doc_visible_rows]
    add ecx, edx
    cmp eax, ecx
    jb .Lneko_ensure_cursor_done
    sub eax, dword ptr [rip + window_doc_visible_rows]
    inc eax
    mov dword ptr [rip + doc_view_top_row], eax
.Lneko_ensure_cursor_done:
    ret
.size doc_ensure_cursor_visible, . - doc_ensure_cursor_visible

# Place cursor from surface-local coordinates; rows include the current scroll.
# EDI=1 for a timer tick, 0 for a pointer-motion update. Surface-local
# coordinates are retained separately from the clamped hit-test coordinates.
# Motion beyond the document viewport scrolls vertically in either wrap mode;
# horizontal auto-scroll is enabled only while soft wrapping is disabled.
.type doc_drag_pointer_update, @function
doc_drag_pointer_update:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r15d, edi
    mov r12d, dword ptr [rip + pointer_x]
    mov r13d, dword ptr [rip + pointer_y]
    xor r14d, r14d

    # Distance outside the vertical viewport controls the scroll rate.
    mov eax, r13d
    cmp eax, DOC_TOP
    jl .Ldoc_drag_scroll_above
    mov ecx, dword ptr [rip + window_doc_bottom]
    cmp eax, ecx
    jge .Ldoc_drag_scroll_below
    jmp .Ldoc_drag_scroll_horizontal
.Ldoc_drag_scroll_above:
    mov eax, DOC_TOP
    sub eax, r13d
    add eax, DOC_DRAG_SCROLL_ROW_PIXELS - 1
    xor edx, edx
    mov ecx, DOC_DRAG_SCROLL_ROW_PIXELS
    div ecx
    cmp eax, DOC_DRAG_SCROLL_MAX_STEPS
    jbe .Ldoc_drag_scroll_above_clamped
    mov eax, DOC_DRAG_SCROLL_MAX_STEPS
.Ldoc_drag_scroll_above_clamped:
    neg eax
    mov edi, eax
    call doc_scroll_by
    or r14d, eax
    jmp .Ldoc_drag_scroll_horizontal
.Ldoc_drag_scroll_below:
    mov eax, r13d
    sub eax, ecx
    inc eax
    add eax, DOC_DRAG_SCROLL_ROW_PIXELS - 1
    xor edx, edx
    mov ecx, DOC_DRAG_SCROLL_ROW_PIXELS
    div ecx
    cmp eax, DOC_DRAG_SCROLL_MAX_STEPS
    jbe .Ldoc_drag_scroll_below_clamped
    mov eax, DOC_DRAG_SCROLL_MAX_STEPS
.Ldoc_drag_scroll_below_clamped:
    mov edi, eax
    call doc_scroll_by
    or r14d, eax

.Ldoc_drag_scroll_horizontal:
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldoc_drag_scroll_position
    mov eax, r12d
    cmp eax, DOC_LEFT
    jl .Ldoc_drag_scroll_left
    mov ecx, dword ptr [rip + window_doc_pixel_width]
    add ecx, DOC_LEFT
    cmp eax, ecx
    jge .Ldoc_drag_scroll_right
    jmp .Ldoc_drag_scroll_position
.Ldoc_drag_scroll_left:
    mov eax, DOC_LEFT
    sub eax, r12d
    add eax, DOC_DRAG_SCROLL_COLUMN_PIXELS - 1
    xor edx, edx
    mov ecx, DOC_DRAG_SCROLL_COLUMN_PIXELS
    div ecx
    cmp eax, DOC_DRAG_SCROLL_MAX_STEPS
    jbe .Ldoc_drag_scroll_left_clamped
    mov eax, DOC_DRAG_SCROLL_MAX_STEPS
.Ldoc_drag_scroll_left_clamped:
    imul eax, 14
    neg eax
    mov edi, eax
    call doc_scroll_horizontal_by
    or r14d, eax
    jmp .Ldoc_drag_scroll_position
.Ldoc_drag_scroll_right:
    mov eax, r12d
    sub eax, ecx
    inc eax
    add eax, DOC_DRAG_SCROLL_COLUMN_PIXELS - 1
    xor edx, edx
    mov ecx, DOC_DRAG_SCROLL_COLUMN_PIXELS
    div ecx
    cmp eax, DOC_DRAG_SCROLL_MAX_STEPS
    jbe .Ldoc_drag_scroll_right_clamped
    mov eax, DOC_DRAG_SCROLL_MAX_STEPS
.Ldoc_drag_scroll_right_clamped:
    imul eax, 14
    mov edi, eax
    call doc_scroll_horizontal_by
    or r14d, eax

.Ldoc_drag_scroll_position:
    # A timer tick only needs a frame when it actually advanced the viewport.
    cmp r15d, 1
    jne .Ldoc_drag_map_pointer
    test r14d, r14d
    jz .Ldoc_drag_no_change

.Ldoc_drag_map_pointer:
    mov eax, r12d
    cmp eax, DOC_LEFT
    jge .Ldoc_drag_x_left_ready
    mov eax, DOC_LEFT
.Ldoc_drag_x_left_ready:
    mov ecx, dword ptr [rip + window_doc_pixel_width]
    add ecx, DOC_LEFT
    dec ecx
    cmp eax, ecx
    jle .Ldoc_drag_x_clamped
    mov eax, ecx
.Ldoc_drag_x_clamped:
    mov dword ptr [rip + pointer_x], eax

    mov eax, r13d
    cmp eax, DOC_TOP
    jge .Ldoc_drag_y_top_ready
    mov eax, DOC_TOP
.Ldoc_drag_y_top_ready:
    mov ecx, dword ptr [rip + window_doc_bottom]
    dec ecx
    cmp eax, ecx
    jle .Ldoc_drag_y_clamped
    mov eax, ecx
.Ldoc_drag_y_clamped:
    mov dword ptr [rip + pointer_y], eax
    mov edi, dword ptr [rip + pointer_x]
    call doc_place_cursor_from_pointer
    mov dword ptr [rip + pointer_x], r12d
    mov dword ptr [rip + pointer_y], r13d

    cmp dword ptr [rip + doc_word_drag_active], 1
    jne .Ldoc_drag_character_selection
    call doc_select_word_at_cursor
    jmp .Ldoc_drag_updated
.Ldoc_drag_character_selection:
    mov eax, dword ptr [rip + doc_selection_anchor]
    cmp eax, dword ptr [rip + doc_cursor]
    jne .Ldoc_drag_selection_active
    mov dword ptr [rip + doc_selection_active], 0
    jmp .Ldoc_drag_updated
.Ldoc_drag_selection_active:
    mov dword ptr [rip + doc_selection_active], 1
.Ldoc_drag_updated:
    mov eax, 1
    jmp .Ldoc_drag_pointer_done
.Ldoc_drag_no_change:
    xor eax, eax
.Ldoc_drag_pointer_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_drag_pointer_update, . - doc_drag_pointer_update

.type doc_place_cursor_from_pointer, @function
doc_place_cursor_from_pointer:
    mov eax, edi
    sub eax, DOC_LEFT
    test eax, eax
    jns .Lneko_pointer_x_nonnegative
    xor eax, eax
.Lneko_pointer_x_nonnegative:
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Lneko_pointer_x_ready
    add eax, dword ptr [rip + doc_view_left_px]
.Lneko_pointer_x_ready:
    mov esi, eax
    mov eax, dword ptr [rip + pointer_y]
    sub eax, DOC_TOP
    test eax, eax
    jns .Lneko_pointer_y_nonnegative
    xor eax, eax
.Lneko_pointer_y_nonnegative:
    xor edx, edx
    mov ecx, dword ptr [rip + window_doc_line_height]
    div ecx
    add eax, dword ptr [rip + doc_view_top_row]
    mov edi, eax
    call doc_visual_to_offset
    mov dword ptr [rip + doc_cursor], eax
    ret
.size doc_place_cursor_from_pointer, . - doc_place_cursor_from_pointer

# EDI=0 moves up; EDI=1 moves down by one visual row.
.type doc_move_vertical, @function
doc_move_vertical:
    push rbx
    push r12
    mov r12d, edi
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    mov ebx, eax
    test r12d, r12d
    jnz .Lneko_vertical_move_down
    test ebx, ebx
    jz .Lneko_vertical_move_done
    dec ebx
    jmp .Lneko_vertical_move_lookup
.Lneko_vertical_move_down:
    inc ebx
.Lneko_vertical_move_lookup:
    mov edi, ebx
    mov esi, edx
    call doc_visual_to_offset
    mov dword ptr [rip + doc_cursor], eax
.Lneko_vertical_move_done:
    pop r12
    pop rbx
    ret
.size doc_move_vertical, . - doc_move_vertical

# Open the Find/Replace modal. EDI=1 for Find, EDI=2 for Find/Replace.
.type find_replace_open, @function
find_replace_open:
    mov dword ptr [rip + find_replace_mode], edi
    mov dword ptr [rip + find_replace_focus], 0
    mov dword ptr [rip + find_field_select_all], 0
    mov dword ptr [rip + find_status], 0
    mov eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + find_query_cursor], eax
    mov eax, dword ptr [rip + find_replacement_length]
    mov dword ptr [rip + find_replacement_cursor], eax
    mov dword ptr [rip + file_menu_open], 0
    mov dword ptr [rip + settings_menu_open], 0
    ret
.size find_replace_open, . - find_replace_open

.type find_replace_close, @function
find_replace_close:
    mov dword ptr [rip + find_replace_mode], 0
    mov dword ptr [rip + find_field_select_all], 0
    ret
.size find_replace_close, . - find_replace_close

# Insert EDI (an ASCII byte) at the active Find/Replace field cursor.
.type find_input_insert_byte, @function
find_input_insert_byte:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r10d, edi
    cmp dword ptr [rip + find_replace_focus], 0
    jne .Lfind_insert_replacement
    lea rbx, [rip + find_query_buffer]
    lea r14, [rip + find_query_cursor]
    lea r15, [rip + find_query_length]
    jmp .Lfind_insert_field_ready
.Lfind_insert_replacement:
    lea rbx, [rip + find_replacement_buffer]
    lea r14, [rip + find_replacement_cursor]
    lea r15, [rip + find_replacement_length]
.Lfind_insert_field_ready:
    mov r12d, dword ptr [r15]
    mov r13d, dword ptr [r14]
    cmp dword ptr [rip + find_field_select_all], 0
    je .Lfind_insert_no_selection
    xor r12d, r12d
    xor r13d, r13d
    mov byte ptr [rbx], 0
    mov dword ptr [rip + find_field_select_all], 0
.Lfind_insert_no_selection:
    cmp r12d, 127
    jae .Lfind_insert_done
    mov ecx, r12d
.Lfind_insert_shift:
    cmp ecx, r13d
    jbe .Lfind_insert_store
    mov al, byte ptr [rbx + rcx - 1]
    mov byte ptr [rbx + rcx], al
    dec ecx
    jmp .Lfind_insert_shift
.Lfind_insert_store:
    mov byte ptr [rbx + r13], r10b
    inc r12d
    inc r13d
    mov byte ptr [rbx + r12], 0
    mov dword ptr [r15], r12d
    mov dword ptr [r14], r13d
.Lfind_insert_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size find_input_insert_byte, . - find_input_insert_byte

# EDI=1 backspace, EDI=0 delete-forward in the active field.
.type find_input_delete, @function
find_input_delete:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r10d, edi
    cmp dword ptr [rip + find_replace_focus], 0
    jne .Lfind_delete_replacement
    lea rbx, [rip + find_query_buffer]
    lea r14, [rip + find_query_cursor]
    lea r15, [rip + find_query_length]
    jmp .Lfind_delete_field_ready
.Lfind_delete_replacement:
    lea rbx, [rip + find_replacement_buffer]
    lea r14, [rip + find_replacement_cursor]
    lea r15, [rip + find_replacement_length]
.Lfind_delete_field_ready:
    mov r12d, dword ptr [r15]
    mov r13d, dword ptr [r14]
    cmp dword ptr [rip + find_field_select_all], 0
    je .Lfind_delete_no_selection
    xor r12d, r12d
    xor r13d, r13d
    mov byte ptr [rbx], 0
    mov dword ptr [rip + find_field_select_all], 0
    jmp .Lfind_delete_store
.Lfind_delete_no_selection:
    test r10d, r10d
    jz .Lfind_delete_forward
    test r13d, r13d
    jz .Lfind_delete_done
    dec r13d
    mov ecx, r13d
    jmp .Lfind_delete_shift
.Lfind_delete_forward:
    cmp r13d, r12d
    jae .Lfind_delete_done
    mov ecx, r13d
.Lfind_delete_shift:
    lea edx, [r12 - 1]
.Lfind_delete_shift_loop:
    cmp ecx, edx
    jae .Lfind_delete_reduced
    mov al, byte ptr [rbx + rcx + 1]
    mov byte ptr [rbx + rcx], al
    inc ecx
    jmp .Lfind_delete_shift_loop
.Lfind_delete_reduced:
    dec r12d
.Lfind_delete_store:
    mov byte ptr [rbx + r12], 0
    mov dword ptr [r15], r12d
    mov dword ptr [r14], r13d
.Lfind_delete_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size find_input_delete, . - find_input_delete

# EDI=start byte offset; ESI=1 searches forward, ESI=0 backward.
# Search wraps once and returns EAX=match offset or -1.
.type doc_find_match, @function
doc_find_match:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12d, esi
    mov r13d, edi
    mov eax, dword ptr [rip + find_query_length]
    test eax, eax
    jz .Ldoc_find_match_none
    mov ebx, dword ptr [rip + doc_length]
    cmp ebx, eax
    jb .Ldoc_find_match_none
    sub ebx, eax
    cmp r13d, ebx
    jbe .Ldoc_find_start_ready
    mov r13d, ebx
.Ldoc_find_start_ready:
    xor ebp, ebp
    mov r14d, r13d
    test r12d, r12d
    jz .Ldoc_find_backward
    mov r15d, ebx
.Ldoc_find_forward_candidate:
    xor r10d, r10d
.Ldoc_find_forward_compare:
    mov edi, r14d
    add edi, r10d
    call doc_byte_at
    lea rcx, [rip + find_query_buffer]
    cmp al, byte ptr [rcx + r10]
    jne .Ldoc_find_forward_miss
    inc r10d
    cmp r10d, dword ptr [rip + find_query_length]
    jb .Ldoc_find_forward_compare
    mov eax, r14d
    jmp .Ldoc_find_match_done
.Ldoc_find_forward_miss:
    inc r14d
    cmp r14d, r15d
    jbe .Ldoc_find_forward_candidate
    test ebp, ebp
    jnz .Ldoc_find_match_none
    mov ebp, 1
    xor r14d, r14d
    mov r15d, r13d
    test r15d, r15d
    jz .Ldoc_find_match_none
    dec r15d
    jmp .Ldoc_find_forward_candidate
.Ldoc_find_backward:
    xor r15d, r15d
.Ldoc_find_backward_candidate:
    xor r10d, r10d
.Ldoc_find_backward_compare:
    mov edi, r14d
    add edi, r10d
    call doc_byte_at
    lea rcx, [rip + find_query_buffer]
    cmp al, byte ptr [rcx + r10]
    jne .Ldoc_find_backward_miss
    inc r10d
    cmp r10d, dword ptr [rip + find_query_length]
    jb .Ldoc_find_backward_compare
    mov eax, r14d
    jmp .Ldoc_find_match_done
.Ldoc_find_backward_miss:
    test r14d, r14d
    jz .Ldoc_find_backward_pass_end
    dec r14d
    cmp r14d, r15d
    jae .Ldoc_find_backward_candidate
.Ldoc_find_backward_pass_end:
    test ebp, ebp
    jnz .Ldoc_find_match_none
    mov ebp, 1
    mov r14d, ebx
    lea r15d, [r13 + 1]
    cmp r14d, r15d
    jb .Ldoc_find_match_none
    jmp .Ldoc_find_backward_candidate
.Ldoc_find_match_none:
    mov eax, -1
.Ldoc_find_match_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size doc_find_match, . - doc_find_match

.type doc_find_next, @function
doc_find_next:
    cmp dword ptr [rip + find_query_length], 0
    je .Ldoc_find_next_empty
    cmp dword ptr [rip + doc_selection_active], 0
    je .Ldoc_find_next_from_cursor
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jae .Ldoc_find_next_start
    mov eax, edx
.Ldoc_find_next_start:
    mov edi, eax
    jmp .Ldoc_find_next_search
.Ldoc_find_next_from_cursor:
    mov edi, dword ptr [rip + doc_cursor]
.Ldoc_find_next_search:
    mov esi, 1
    call doc_find_match
    test eax, eax
    js .Ldoc_find_next_not_found
    mov dword ptr [rip + doc_selection_anchor], eax
    add eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + doc_cursor], eax
    mov dword ptr [rip + doc_selection_active], 1
    mov dword ptr [rip + find_status], 1
    call doc_ensure_cursor_visible
    mov eax, 1
    ret
.Ldoc_find_next_empty:
    mov dword ptr [rip + find_status], 0
    xor eax, eax
    ret
.Ldoc_find_next_not_found:
    mov dword ptr [rip + find_status], 2
    xor eax, eax
    ret
.size doc_find_next, . - doc_find_next

.type doc_find_previous, @function
doc_find_previous:
    cmp dword ptr [rip + find_query_length], 0
    je .Ldoc_find_previous_empty
    cmp dword ptr [rip + doc_selection_active], 0
    je .Ldoc_find_previous_from_cursor
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Ldoc_find_previous_start
    mov eax, edx
.Ldoc_find_previous_start:
    test eax, eax
    jz .Ldoc_find_previous_search
    dec eax
    mov edi, eax
    jmp .Ldoc_find_previous_search
.Ldoc_find_previous_from_cursor:
    mov edi, dword ptr [rip + doc_cursor]
    test edi, edi
    jz .Ldoc_find_previous_search
    dec edi
.Ldoc_find_previous_search:
    xor esi, esi
    call doc_find_match
    test eax, eax
    js .Ldoc_find_previous_not_found
    mov dword ptr [rip + doc_selection_anchor], eax
    add eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + doc_cursor], eax
    mov dword ptr [rip + doc_selection_active], 1
    mov dword ptr [rip + find_status], 1
    call doc_ensure_cursor_visible
    mov eax, 1
    ret
.Ldoc_find_previous_empty:
    mov dword ptr [rip + find_status], 0
    xor eax, eax
    ret
.Ldoc_find_previous_not_found:
    mov dword ptr [rip + find_status], 2
    xor eax, eax
    ret
.size doc_find_previous, . - doc_find_previous

# Replace the currently selected query; caller guarantees the selection matches.
.type doc_replace_selection_with_buffer, @function
doc_replace_selection_with_buffer:
    push rbx
    call doc_delete_selection
    xor ebx, ebx
.Ldoc_replace_insert_loop:
    cmp ebx, dword ptr [rip + find_replacement_length]
    jae .Ldoc_replace_insert_done
    lea rdx, [rip + find_replacement_buffer]
    movzx edi, byte ptr [rdx + rbx]
    call doc_insert_byte
    inc ebx
    jmp .Ldoc_replace_insert_loop
.Ldoc_replace_insert_done:
    mov eax, dword ptr [rip + doc_cursor]
    mov dword ptr [rip + doc_selection_anchor], eax
    mov dword ptr [rip + doc_selection_active], 0
    pop rbx
    ret
.size doc_replace_selection_with_buffer, . - doc_replace_selection_with_buffer

.type doc_find_selection_matches, @function
doc_find_selection_matches:
    cmp dword ptr [rip + doc_selection_active], 0
    je .Ldoc_find_selection_no
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Ldoc_find_selection_bounds
    xchg eax, edx
.Ldoc_find_selection_bounds:
    sub edx, eax
    cmp edx, dword ptr [rip + find_query_length]
    jne .Ldoc_find_selection_no
    push rbx
    push r12
    mov ebx, eax
    xor r12d, r12d
.Ldoc_find_selection_compare:
    cmp r12d, dword ptr [rip + find_query_length]
    jae .Ldoc_find_selection_yes
    mov edi, ebx
    add edi, r12d
    call doc_byte_at
    lea rdx, [rip + find_query_buffer]
    cmp al, byte ptr [rdx + r12]
    jne .Ldoc_find_selection_no_pop
    inc r12d
    jmp .Ldoc_find_selection_compare
.Ldoc_find_selection_yes:
    mov eax, 1
    jmp .Ldoc_find_selection_pop
.Ldoc_find_selection_no_pop:
    xor eax, eax
.Ldoc_find_selection_pop:
    pop r12
    pop rbx
    ret
.Ldoc_find_selection_no:
    xor eax, eax
    ret
.size doc_find_selection_matches, . - doc_find_selection_matches

.type doc_find_replace_current, @function
doc_find_replace_current:
    call doc_find_selection_matches
    test eax, eax
    jz .Ldoc_find_replace_find_next
    call doc_replace_selection_with_buffer
    mov dword ptr [rip + find_status], 3
    mov eax, 1
    ret
.Ldoc_find_replace_find_next:
    call doc_find_next
    xor eax, eax
    ret
.size doc_find_replace_current, . - doc_find_replace_current

.type doc_find_replace_all, @function
doc_find_replace_all:
    push rbx
    mov dword ptr [rip + find_replace_count], 0
    mov dword ptr [rip + doc_cursor], 0
    mov dword ptr [rip + doc_selection_anchor], 0
    mov dword ptr [rip + doc_selection_active], 0
    cmp dword ptr [rip + find_query_length], 0
    je .Ldoc_find_replace_all_done
.Ldoc_find_replace_all_loop:
    mov edi, dword ptr [rip + doc_cursor]
    mov esi, 1
    call doc_find_match
    test eax, eax
    js .Ldoc_find_replace_all_done
    cmp eax, dword ptr [rip + doc_cursor]
    jb .Ldoc_find_replace_all_done
    mov dword ptr [rip + doc_selection_anchor], eax
    add eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + doc_cursor], eax
    mov dword ptr [rip + doc_selection_active], 1
    call doc_replace_selection_with_buffer
    inc dword ptr [rip + find_replace_count]
    jmp .Ldoc_find_replace_all_loop
.Ldoc_find_replace_all_done:
    mov dword ptr [rip + doc_selection_active], 0
    cmp dword ptr [rip + find_replace_count], 0
    je .Ldoc_find_replace_all_none
    mov dword ptr [rip + find_status], 4
    mov eax, dword ptr [rip + find_replace_count]
    jmp .Ldoc_find_replace_all_return
.Ldoc_find_replace_all_none:
    mov dword ptr [rip + find_status], 2
    xor eax, eax
.Ldoc_find_replace_all_return:
    pop rbx
    ret
.size doc_find_replace_all, . - doc_find_replace_all

# Convert pointer pixels to the Find/Replace modal's 448x192 design grid.
.type find_pointer_to_design, @function
find_pointer_to_design:
    push rbx
    push r12
    mov r12d, esi
    sub edi, dword ptr [rip + find_panel_x]
    imul edi, 448
    mov eax, edi
    cdq
    mov ecx, dword ptr [rip + find_panel_width]
    test ecx, ecx
    jz .Lfind_pointer_x_zero
    idiv ecx
    jmp .Lfind_pointer_x_ready
.Lfind_pointer_x_zero:
    xor eax, eax
.Lfind_pointer_x_ready:
    mov ebx, eax
    mov eax, r12d
    sub eax, dword ptr [rip + find_panel_y]
    imul eax, 192
    cdq
    mov ecx, dword ptr [rip + find_panel_height]
    test ecx, ecx
    jz .Lfind_pointer_y_zero
    idiv ecx
    jmp .Lfind_pointer_y_ready
.Lfind_pointer_y_zero:
    xor eax, eax
.Lfind_pointer_y_ready:
    mov edx, eax
    mov eax, ebx
    pop r12
    pop rbx
    ret
.size find_pointer_to_design, . - find_pointer_to_design

.type find_replace_handle_pointer, @function
find_replace_handle_pointer:
    push rbx
    mov ebx, dword ptr [rip + pointer_y]
    mov edi, dword ptr [rip + pointer_x]
    mov esi, ebx
    call find_pointer_to_design
    cmp edx, 42
    jb .Lfind_pointer_buttons
    cmp edx, 78
    jb .Lfind_pointer_focus_query
    cmp dword ptr [rip + find_replace_mode], 2
    jne .Lfind_pointer_buttons
    cmp edx, 88
    jb .Lfind_pointer_buttons
    cmp edx, 124
    jae .Lfind_pointer_buttons
.Lfind_pointer_focus_replacement:
    mov dword ptr [rip + find_replace_focus], 1
    mov dword ptr [rip + find_field_select_all], 0
    mov eax, dword ptr [rip + find_replacement_length]
    mov dword ptr [rip + find_replacement_cursor], eax
    jmp .Lfind_pointer_done
.Lfind_pointer_focus_query:
    mov dword ptr [rip + find_replace_focus], 0
    mov dword ptr [rip + find_field_select_all], 0
    mov eax, dword ptr [rip + find_query_length]
    mov dword ptr [rip + find_query_cursor], eax
    jmp .Lfind_pointer_done
.Lfind_pointer_buttons:
    cmp edx, 144
    jb .Lfind_pointer_outside
    cmp edx, 184
    jae .Lfind_pointer_outside
    cmp eax, 88
    jb .Lfind_pointer_prev
    cmp eax, 176
    jb .Lfind_pointer_next
    cmp dword ptr [rip + find_replace_mode], 2
    jne .Lfind_pointer_close_check
    cmp eax, 280
    jb .Lfind_pointer_replace
    cmp eax, 368
    jb .Lfind_pointer_replace_all
.Lfind_pointer_close_check:
    cmp eax, 368
    jae .Lfind_pointer_close
    jmp .Lfind_pointer_done
.Lfind_pointer_prev:
    call doc_find_previous
    jmp .Lfind_pointer_done
.Lfind_pointer_next:
    call doc_find_next
    jmp .Lfind_pointer_done
.Lfind_pointer_replace:
    call doc_find_replace_current
    jmp .Lfind_pointer_done
.Lfind_pointer_replace_all:
    call doc_find_replace_all
    jmp .Lfind_pointer_done
.Lfind_pointer_close:
    call find_replace_close
    jmp .Lfind_pointer_done
.Lfind_pointer_outside:
    mov dword ptr [rip + find_replace_mode], 0
.Lfind_pointer_done:
    mov eax, 1
    pop rbx
    ret
.size find_replace_handle_pointer, . - find_replace_handle_pointer

# Translate printable input from the active XKB keymap when the supported
# text-v1 subset was parsed. A parsed map's non-ASCII keys are deliberately
# ignored rather than silently producing an unrelated US-QWERTY character.
# Find/Replace field measurements share the same active overlay font transform.
.type find_measure_ascii_prefix, @function
find_measure_ascii_prefix:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12d, esi
    xor r13d, r13d
.Lfind_measure_prefix_loop:
    test r12d, r12d
    jz .Lfind_measure_prefix_done
    movzx edi, byte ptr [rbx]
    call ui_font_advance_pixels
    add r13d, eax
    inc rbx
    dec r12d
    jmp .Lfind_measure_prefix_loop
.Lfind_measure_prefix_done:
    mov eax, r13d
    pop r13
    pop r12
    pop rbx
    ret
.size find_measure_ascii_prefix, . - find_measure_ascii_prefix

# RDI=field buffer, ESI=cursor, EDX=visible width; keep the caret in the viewport.
.type find_field_view_start, @function
find_field_view_start:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r13d, esi
    mov r14d, edx
    xor ebp, ebp
.Lfind_field_view_start_loop:
    test r13d, r13d
    jz .Lfind_field_view_start_done
    movzx edi, byte ptr [rbx + r13 - 1]
    call ui_font_advance_pixels
    lea ecx, [rbp + rax]
    cmp ecx, r14d
    ja .Lfind_field_view_start_done
    mov ebp, ecx
    dec r13d
    jmp .Lfind_field_view_start_loop
.Lfind_field_view_start_done:
    mov eax, r13d
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size find_field_view_start, . - find_field_view_start

.type keycode_to_ascii, @function
keycode_to_ascii:
    push rbx
    mov ebx, edi
    cmp dword ptr [rip + keymap_format], 1
    jne .Lneko_keymap_fallback
    mov edi, ebx
    mov esi, dword ptr [rip + xkb_modifiers]
    mov edx, dword ptr [rip + keyboard_group]
    call xkb_lookup_ascii
    pop rbx
    ret
.Lneko_keymap_fallback:
    mov edi, ebx
    cmp edi, 128
    jae .keymap_unknown
    mov ecx, edi
    lea r8, [rip + keymap_base]
    movzx eax, byte ptr [r8 + rcx]
    test eax, eax
    jz .keymap_unknown
    cmp eax, 'a'
    jb .keymap_shift_punctuation
    cmp eax, 'z'
    ja .keymap_shift_punctuation
    mov edx, dword ptr [rip + shift_down]
    xor edx, dword ptr [rip + caps_lock]
    test edx, edx
    jz .keymap_done
    sub eax, 32
    pop rbx
    ret
.keymap_shift_punctuation:
    cmp dword ptr [rip + shift_down], 0
    je .keymap_done
    lea r8, [rip + keymap_shift]
    movzx edx, byte ptr [r8 + rcx]
    test edx, edx
    jz .keymap_done
    mov eax, edx
.keymap_done:
    pop rbx
    ret
.keymap_unknown:
    xor eax, eax
    pop rbx
    ret
.size keycode_to_ascii, . - keycode_to_ascii

# Document entry path: preserve ASCII fallback while accepting Unicode XKB
# keysyms from a parsed text-v1 keymap. Prompt/search widgets remain ASCII.
.type keycode_to_unicode, @function
keycode_to_unicode:
    push rbx
    mov ebx, edi
    cmp dword ptr [rip + keymap_format], 1
    jne .Lkeycode_unicode_fallback
    mov edi, ebx
    mov esi, dword ptr [rip + xkb_modifiers]
    mov edx, dword ptr [rip + keyboard_group]
    call xkb_lookup_unicode
    pop rbx
    ret
.Lkeycode_unicode_fallback:
    mov edi, ebx
    call keycode_to_ascii
    pop rbx
    ret
.size keycode_to_unicode, . - keycode_to_unicode

# Return a precomposed Unicode scalar for (EDI=base, ESI=combining mark).
# Zero means no precomposed mapping exists; callers preserve base+mark.
.type doc_compose_precomposed, @function
doc_compose_precomposed:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    lea rbx, [rip + .Ldoc_dead_compose_table]
.Ldoc_compose_precomposed_loop:
    cmp dword ptr [rbx], 0
    je .Ldoc_compose_precomposed_none
    cmp dword ptr [rbx], r12d
    jne .Ldoc_compose_precomposed_next
    cmp dword ptr [rbx + 4], r13d
    je .Ldoc_compose_precomposed_found
.Ldoc_compose_precomposed_next:
    add rbx, 12
    jmp .Ldoc_compose_precomposed_loop
.Ldoc_compose_precomposed_found:
    mov eax, dword ptr [rbx + 8]
    jmp .Ldoc_compose_precomposed_done
.Ldoc_compose_precomposed_none:
    xor eax, eax
.Ldoc_compose_precomposed_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_compose_precomposed, . - doc_compose_precomposed

# Flush pending dead-key marks literally. first..seventh hold up to seven marks.
.type doc_flush_pending_dead_literal, @function
doc_flush_pending_dead_literal:
    push rbx
    push r12
    sub rsp, 8
    cmp dword ptr [rip + doc_pending_dead_mark], 0
    je .Ldoc_flush_pending_dead_done
    call doc_delete_selection
    lea rbx, [rip + doc_compose_first]
    xor r12d, r12d
.Ldoc_flush_pending_dead_loop:
    cmp r12d, 7
    jae .Ldoc_flush_pending_dead_clear
    mov edi, dword ptr [rbx + r12*4]
    test edi, edi
    jz .Ldoc_flush_pending_dead_clear
    call doc_insert_codepoint_utf8
    inc r12d
    jmp .Ldoc_flush_pending_dead_loop
.Ldoc_flush_pending_dead_clear:
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
.Ldoc_flush_pending_dead_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
.size doc_flush_pending_dead_literal, . - doc_flush_pending_dead_literal

# Insert a Unicode scalar, arm a dead key, or process a bounded Multi_key pair.
# Dead-key actions use 0x110001..0x110024; 0x110007 remains reserved for
# Multi_key and is handled before the dead-key range. None are Unicode scalars.
# Multi_key buffers two following symbols and resolves the
# curated pair table below; unknown pairs are preserved as their two scalars.
# Resolve one two-symbol Multi_key sequence (EDI=first, ESI=second).
# EAX is the composed Unicode scalar, or zero for an unsupported pair.
.type doc_compose_pair, @function
doc_compose_pair:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    lea rbx, [rip + .Ldoc_compose_sequence_table]
.Ldoc_compose_pair_loop:
    cmp dword ptr [rbx], 0
    je .Ldoc_compose_pair_none
    cmp dword ptr [rbx], r12d
    jne .Ldoc_compose_pair_next
    cmp dword ptr [rbx + 4], r13d
    je .Ldoc_compose_pair_found
.Ldoc_compose_pair_next:
    add rbx, 12
    jmp .Ldoc_compose_pair_loop
.Ldoc_compose_pair_found:
    mov eax, dword ptr [rbx + 8]
    jmp .Ldoc_compose_pair_done
.Ldoc_compose_pair_none:
    xor eax, eax
.Ldoc_compose_pair_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_compose_pair, . - doc_compose_pair

.type doc_compose_triplet_prefix, @function
doc_compose_triplet_prefix:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    lea rbx, [rip + .Ldoc_compose_triple_sequence_table]
.Ldoc_compose_prefix_loop:
    cmp dword ptr [rbx], 0
    je .Ldoc_compose_prefix_none
    cmp dword ptr [rbx], r12d
    jne .Ldoc_compose_prefix_next
    cmp dword ptr [rbx + 4], r13d
    je .Ldoc_compose_prefix_found
.Ldoc_compose_prefix_next:
    add rbx, 16
    jmp .Ldoc_compose_prefix_loop
.Ldoc_compose_prefix_found:
    mov eax, 1
    jmp .Ldoc_compose_prefix_done
.Ldoc_compose_prefix_none:
    xor eax, eax
.Ldoc_compose_prefix_done:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_compose_triplet_prefix, . - doc_compose_triplet_prefix

.type doc_compose_triplet, @function
doc_compose_triplet:
    push rbx
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    lea rbx, [rip + .Ldoc_compose_triple_sequence_table]
.Ldoc_compose_triplet_loop:
    cmp dword ptr [rbx], 0
    je .Ldoc_compose_triplet_none
    cmp dword ptr [rbx], r12d
    jne .Ldoc_compose_triplet_next
    cmp dword ptr [rbx + 4], r13d
    jne .Ldoc_compose_triplet_next
    cmp dword ptr [rbx + 8], r14d
    je .Ldoc_compose_triplet_found
.Ldoc_compose_triplet_next:
    add rbx, 16
    jmp .Ldoc_compose_triplet_loop
.Ldoc_compose_triplet_found:
    mov eax, dword ptr [rbx + 12]
    jmp .Ldoc_compose_triplet_done
.Ldoc_compose_triplet_none:
    xor eax, eax
.Ldoc_compose_triplet_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_compose_triplet, . - doc_compose_triplet

.type doc_insert_keyboard_codepoint, @function
doc_insert_keyboard_codepoint:
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rbp
    sub rsp, 8
    mov r12d, edi
    cmp r12d, 0x110007
    je .Ldoc_keyboard_compose_start
    cmp r12d, 0x110001
    jb .Ldoc_keyboard_insert_scalar
    cmp r12d, 0x110024
    ja .Ldoc_keyboard_insert_scalar
    lea rax, [rip + .Ldoc_dead_marks]
    sub r12d, 0x110001
    mov r13d, dword ptr [rax + r12*4]
    # A dead key interrupts Compose; preserve every scalar already buffered.
    cmp dword ptr [rip + doc_compose_active], 0
    je .Ldoc_keyboard_dead_after_compose
    mov r14d, dword ptr [rip + doc_compose_first]
    mov r15d, dword ptr [rip + doc_compose_second]
    mov ebx, dword ptr [rip + doc_compose_third]
    mov ebp, dword ptr [rip + doc_compose_fourth]
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    test r14d, r14d
    jz .Ldoc_keyboard_dead_after_compose
    call doc_delete_selection
    mov edi, r14d
    call doc_insert_codepoint_utf8
    test r15d, r15d
    jz .Ldoc_keyboard_dead_flush_third
    mov edi, r15d
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_dead_flush_third:
    test ebx, ebx
    jz .Ldoc_keyboard_dead_flush_fourth
    mov edi, ebx
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_dead_flush_fourth:
    test ebp, ebp
    jz .Ldoc_keyboard_dead_after_compose
    mov edi, ebp
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_dead_after_compose:
    # A dead-key chain stores up to seven combining marks in contiguous slots.
    cmp dword ptr [rip + doc_pending_dead_mark], 0
    je .Ldoc_keyboard_store_first_dead
    # The first slot is already occupied. Find the next empty mark slot;
    # an eighth consecutive dead action flushes the old chain and starts anew.
    lea rax, [rip + doc_compose_first]
    mov ecx, 1
.Ldoc_keyboard_dead_find_empty:
    cmp ecx, 7
    jae .Ldoc_keyboard_dead_chain_full
    cmp dword ptr [rax + rcx*4], 0
    je .Ldoc_keyboard_dead_slot_found
    inc ecx
    jmp .Ldoc_keyboard_dead_find_empty
.Ldoc_keyboard_dead_slot_found:
    mov dword ptr [rax + rcx*4], r13d
    jmp .Ldoc_keyboard_dead_mark_saved
.Ldoc_keyboard_dead_chain_full:
    call doc_flush_pending_dead_literal
.Ldoc_keyboard_store_first_dead:
    mov dword ptr [rip + doc_compose_first], r13d
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
.Ldoc_keyboard_dead_mark_saved:
    mov dword ptr [rip + doc_pending_dead_mark], r13d
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_start:
    # Flush every pending dead mark before arming Multi_key.
    cmp dword ptr [rip + doc_pending_dead_mark], 0
    je .Ldoc_keyboard_compose_start_ready
    call doc_flush_pending_dead_literal
.Ldoc_keyboard_compose_start_ready:
    # Restarting Multi_key preserves any buffered symbols literally.
    cmp dword ptr [rip + doc_compose_active], 0
    je .Ldoc_keyboard_compose_arm
    mov r14d, dword ptr [rip + doc_compose_first]
    mov r15d, dword ptr [rip + doc_compose_second]
    mov ebx, dword ptr [rip + doc_compose_third]
    mov ebp, dword ptr [rip + doc_compose_fourth]
    test r14d, r14d
    jz .Ldoc_keyboard_compose_arm
    call doc_delete_selection
    mov edi, r14d
    call doc_insert_codepoint_utf8
    test r15d, r15d
    jz .Ldoc_keyboard_compose_restart_third
    mov edi, r15d
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_compose_restart_third:
    test ebx, ebx
    jz .Ldoc_keyboard_compose_restart_fourth
    mov edi, ebx
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_compose_restart_fourth:
    test ebp, ebp
    jz .Ldoc_keyboard_compose_arm
    mov edi, ebp
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_compose_arm:
    mov dword ptr [rip + doc_compose_active], 1
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_insert_scalar:
    cmp r12d, 0x10ffff
    ja .Ldoc_keyboard_insert_done
    cmp dword ptr [rip + doc_compose_active], 0
    je .Ldoc_keyboard_insert_pending_dead
    cmp dword ptr [rip + compose_locale_active], 0
    jne .Ldoc_keyboard_locale_compose
    mov r13d, dword ptr [rip + doc_compose_first]
    test r13d, r13d
    jnz .Ldoc_keyboard_compose_second
    mov dword ptr [rip + doc_compose_first], r12d
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_second:
    cmp dword ptr [rip + doc_compose_second], 0
    jne .Ldoc_keyboard_compose_third
    mov edi, r13d
    mov esi, r12d
    call doc_compose_pair
    test eax, eax
    jnz .Ldoc_keyboard_compose_pair_success
    # Delay literal fallback only for a recognized three-symbol prefix.
    mov edi, r13d
    mov esi, r12d
    call doc_compose_triplet_prefix
    test eax, eax
    jz .Ldoc_keyboard_compose_pair_fallback
    mov dword ptr [rip + doc_compose_second], r12d
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_pair_success:
    mov r14d, eax
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call doc_delete_selection
    mov edi, r14d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_third:
    mov edi, r13d
    mov esi, dword ptr [rip + doc_compose_second]
    mov edx, r12d
    call doc_compose_triplet
    test eax, eax
    jz .Ldoc_keyboard_compose_triplet_fallback
    mov r14d, eax
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call doc_delete_selection
    mov edi, r14d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_triplet_fallback:
    # Preserve all three symbols when a recognized prefix receives no matching third key.
    mov r15d, dword ptr [rip + doc_compose_second]
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call doc_delete_selection
    mov edi, r13d
    call doc_insert_codepoint_utf8
    mov edi, r15d
    call doc_insert_codepoint_utf8
    mov edi, r12d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_compose_pair_fallback:
    # Unknown pair: preserve both symbols literally, then leave Compose mode.
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    call doc_delete_selection
    mov edi, r13d
    call doc_insert_codepoint_utf8
    mov edi, r12d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_locale_compose:
    # Optional-pack Multi_key rules remain limited to 2-4 inputs; dead-key rules use the separate chain path.
    # Ambiguous-prefix records are rejected by the loader.
    mov eax, dword ptr [rip + doc_compose_first]
    test eax, eax
    jz .Ldoc_keyboard_locale_first
    mov eax, dword ptr [rip + doc_compose_second]
    test eax, eax
    jz .Ldoc_keyboard_locale_second
    mov eax, dword ptr [rip + doc_compose_third]
    test eax, eax
    jz .Ldoc_keyboard_locale_third
    jmp .Ldoc_keyboard_locale_fourth
.Ldoc_keyboard_locale_first:
    mov dword ptr [rip + doc_compose_first], r12d
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_locale_second:
    mov dword ptr [rip + doc_compose_second], r12d
    xor edi, edi
    mov esi, 2
    lea rdx, [rip + doc_compose_first]
    lea rcx, [rip + compose_locale_output]
    call compose_locale_lookup
    test eax, eax
    jnz .Ldoc_keyboard_locale_result
    xor edi, edi
    mov esi, 2
    lea rdx, [rip + doc_compose_first]
    call compose_locale_prefix
    test eax, eax
    jnz .Ldoc_keyboard_locale_buffered
    mov r14d, 2
    jmp .Ldoc_keyboard_locale_literal
.Ldoc_keyboard_locale_third:
    mov dword ptr [rip + doc_compose_third], r12d
    xor edi, edi
    mov esi, 3
    lea rdx, [rip + doc_compose_first]
    lea rcx, [rip + compose_locale_output]
    call compose_locale_lookup
    test eax, eax
    jnz .Ldoc_keyboard_locale_result
    xor edi, edi
    mov esi, 3
    lea rdx, [rip + doc_compose_first]
    call compose_locale_prefix
    test eax, eax
    jnz .Ldoc_keyboard_locale_buffered
    mov r14d, 3
    jmp .Ldoc_keyboard_locale_literal
.Ldoc_keyboard_locale_fourth:
    mov dword ptr [rip + doc_compose_fourth], r12d
    xor edi, edi
    mov esi, 4
    lea rdx, [rip + doc_compose_first]
    lea rcx, [rip + compose_locale_output]
    call compose_locale_lookup
    test eax, eax
    jnz .Ldoc_keyboard_locale_result
    mov r14d, 4
    jmp .Ldoc_keyboard_locale_literal
.Ldoc_keyboard_locale_result:
    mov r14d, eax
    lea r15, [rip + compose_locale_output]
    jmp .Ldoc_keyboard_locale_commit
.Ldoc_keyboard_locale_literal:
    lea r15, [rip + doc_compose_first]
.Ldoc_keyboard_locale_commit:
    # Preserve buffered input slots until literal fallback has consumed them.
    mov dword ptr [rip + doc_compose_active], 0
    call doc_delete_selection
    xor ebx, ebx
.Ldoc_keyboard_locale_insert_loop:
    cmp ebx, r14d
    jae .Ldoc_keyboard_locale_insert_done
    mov edi, dword ptr [r15 + rbx*4]
    call doc_insert_codepoint_utf8
    inc ebx
    jmp .Ldoc_keyboard_locale_insert_loop
.Ldoc_keyboard_locale_insert_done:
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_locale_buffered:
    mov eax, 1
    jmp .Ldoc_keyboard_insert_done

.Ldoc_keyboard_insert_pending_dead:
    mov r13d, dword ptr [rip + doc_pending_dead_mark]
    test r13d, r13d
    jz .Ldoc_keyboard_plain_scalar
    mov dword ptr [rip + doc_pending_dead_mark], 0
    # Count contiguous pending marks, then append the final base scalar.
    # Kind-1 records hold one to seven marks followed by the base.
    lea rax, [rip + doc_compose_first]
    xor r14d, r14d
.Ldoc_keyboard_dead_count_marks:
    cmp r14d, 7
    jae .Ldoc_keyboard_dead_append_base
    cmp dword ptr [rax + r14*4], 0
    je .Ldoc_keyboard_dead_append_base
    inc r14d
    jmp .Ldoc_keyboard_dead_count_marks
.Ldoc_keyboard_dead_append_base:
    mov dword ptr [rax + r14*4], r12d
    mov r13d, dword ptr [rip + doc_compose_first]
    cmp dword ptr [rip + compose_locale_active], 0
    je .Ldoc_keyboard_dead_fallback
    mov edi, 1
    mov esi, r14d
    inc esi
    lea rdx, [rip + doc_compose_first]
    lea rcx, [rip + compose_locale_output]
    call compose_locale_lookup
    test eax, eax
    jnz .Ldoc_keyboard_locale_result
.Ldoc_keyboard_dead_fallback:
    cmp r14d, 1
    jne .Ldoc_keyboard_dead_chain_fallback
    # Preserve the original built-in precomposed path for a single mark.
    mov edi, r12d
    mov esi, r13d
    call doc_compose_precomposed
    test eax, eax
    jz .Ldoc_keyboard_dead_single_fallback
    mov r14d, eax
    call doc_delete_selection
    mov edi, r14d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_dead_clear
.Ldoc_keyboard_dead_single_fallback:
    call doc_delete_selection
    mov edi, r12d
    call doc_insert_codepoint_utf8
    mov edi, r13d
    call doc_insert_codepoint_utf8
    jmp .Ldoc_keyboard_dead_clear
.Ldoc_keyboard_dead_chain_fallback:
    # No locale rule: preserve the base followed by each mark in input order.
    call doc_delete_selection
    mov edi, r12d
    call doc_insert_codepoint_utf8
    lea r15, [rip + doc_compose_first]
    xor ebx, ebx
.Ldoc_keyboard_dead_chain_fallback_loop:
    cmp ebx, r14d
    jae .Ldoc_keyboard_dead_clear
    mov edi, dword ptr [r15 + rbx*4]
    call doc_insert_codepoint_utf8
    inc ebx
    jmp .Ldoc_keyboard_dead_chain_fallback_loop
.Ldoc_keyboard_dead_clear:
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    jmp .Ldoc_keyboard_insert_done
.Ldoc_keyboard_plain_scalar:
    call doc_delete_selection
    mov edi, r12d
    call doc_insert_codepoint_utf8
.Ldoc_keyboard_insert_done:
    add rsp, 8
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_insert_keyboard_codepoint, . - doc_insert_keyboard_codepoint

.type draw_glyph, @function
draw_glyph:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r15d, edx
    mov r14d, ecx
    test r14d, r14d
    jnz .glyph_size_ready
    mov r14d, 12
.glyph_size_ready:
    cmp dword ptr [rip + ui_transform_active], 0
    je .glyph_transform_done
    mov eax, r12d
    sub eax, dword ptr [rip + ui_transform_base_x]
    imul eax, dword ptr [rip + ui_transform_x_num]
    cdq
    idiv dword ptr [rip + ui_transform_x_den]
    add eax, dword ptr [rip + ui_transform_origin_x]
    mov r12d, eax
    mov eax, r13d
    sub eax, dword ptr [rip + ui_transform_base_y]
    imul eax, dword ptr [rip + ui_transform_y_num]
    cdq
    idiv dword ptr [rip + ui_transform_y_den]
    add eax, dword ptr [rip + ui_transform_origin_y]
    mov r13d, eax
.glyph_transform_done:
    mov eax, dword ptr [rip + window_ui_scale_120]
    cmp eax, 120
    je .glyph_density_done
    imul r12d, eax
    mov eax, r12d
    cdq
    mov ecx, 120
    idiv ecx
    mov r12d, eax
    mov eax, r13d
    imul eax, dword ptr [rip + window_ui_scale_120]
    cdq
    mov ecx, 120
    idiv ecx
    mov r13d, eax
    mov eax, r14d
    imul eax, dword ptr [rip + window_ui_scale_120]
    add eax, 60
    xor edx, edx
    mov ecx, 120
    div ecx
    mov r14d, eax
.glyph_density_done:
    mov r8d, dword ptr [rip + window_buffer_raster_scale_120]
    cmp r8d, 120
    je .glyph_scale_done
    mov eax, r12d
    imul eax, r8d
    cdq
    mov ecx, 120
    idiv ecx
    mov r12d, eax
    mov eax, r13d
    imul eax, r8d
    cdq
    mov ecx, 120
    idiv ecx
    mov r13d, eax
    mov eax, r14d
    imul eax, r8d
    add eax, 60
    xor edx, edx
    mov ecx, 120
    div ecx
    mov r14d, eax
.glyph_scale_done:
    test r12d, r12d
    js .glyph_done
    test r13d, r13d
    js .glyph_done
    mov eax, dword ptr [rip + window_raster_surface_width]
    cmp r12d, eax
    jae .glyph_done
    mov eax, dword ptr [rip + window_raster_surface_height]
    cmp r13d, eax
    jae .glyph_done
    # Render parsed TrueType glyphs when a font is active; retain the compact
    # 5x7 bitmap only for missing/unsupported fonts or individual glyphs.
    cmp dword ptr [rip + font_loaded], 0
    je .glyph_bitmap_fallback
    mov edi, r15d
    mov esi, r12d
    mov edx, r13d
    mov rcx, qword ptr [rip + shm_mapping]
    mov r8d, dword ptr [rip + window_buffer_width]
    mov r9d, dword ptr [rip + window_buffer_height]
    sub rsp, 48
    mov eax, dword ptr [rip + window_stride]
    mov dword ptr [rsp], eax
    mov dword ptr [rsp + 8], r14d
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rsp + 16], eax
    mov eax, dword ptr [rip + window_raster_surface_width]
    mov dword ptr [rsp + 24], eax
    mov eax, dword ptr [rip + window_raster_surface_height]
    mov dword ptr [rsp + 32], eax
    call font_draw_codepoint_size
    add rsp, 48
    test eax, eax
    jnz .glyph_done
.glyph_bitmap_fallback:
    mov eax, r15d
    cmp eax, ' '
    je .glyph_done
    cmp eax, 'a'
    jb .glyph_upper
    cmp eax, 'z'
    ja .glyph_upper
    sub eax, 32
.glyph_upper:
    cmp eax, 'A'
    jb .glyph_digit
    cmp eax, 'Z'
    ja .glyph_digit
    sub eax, 'A'
    jmp .glyph_index_ready
.glyph_digit:
    cmp eax, '0'
    jb .glyph_punctuation
    cmp eax, '9'
    ja .glyph_punctuation
    sub eax, '0'
    add eax, 26
    jmp .glyph_index_ready
.glyph_punctuation:
    cmp eax, '?'
    je .glyph_question
    cmp eax, '.'
    je .glyph_period
    cmp eax, ','
    je .glyph_comma
    cmp eax, ':'
    je .glyph_colon
    cmp eax, '-'
    je .glyph_dash
    cmp eax, '_'
    je .glyph_underscore
    cmp eax, '!'
    je .glyph_exclamation
    cmp eax, '"'
    je .glyph_quote
    cmp eax, 39
    je .glyph_apostrophe
    cmp eax, '('
    je .glyph_open_paren
    cmp eax, ')'
    je .glyph_close_paren
    cmp eax, '+'
    je .glyph_plus
    cmp eax, '='
    je .glyph_equals
    cmp eax, '/'
    je .glyph_slash
    cmp eax, 35
    je .glyph_numbersign
    cmp eax, 36
    je .glyph_dollar
    cmp eax, 37
    je .glyph_percent
    cmp eax, 38
    je .glyph_ampersand
    cmp eax, 42
    je .glyph_asterisk
    cmp eax, 59
    je .glyph_semicolon
    cmp eax, 60
    je .glyph_less
    cmp eax, 62
    je .glyph_greater
    cmp eax, 64
    je .glyph_at
    cmp eax, 91
    je .glyph_open_bracket
    cmp eax, 92
    je .glyph_backslash
    cmp eax, 93
    je .glyph_close_bracket
    cmp eax, 94
    je .glyph_caret
    cmp eax, 96
    je .glyph_grave
    cmp eax, 123
    je .glyph_open_brace
    cmp eax, 124
    je .glyph_bar
    cmp eax, 125
    je .glyph_close_brace
    cmp eax, 126
    je .glyph_tilde
    mov eax, 36
    jmp .glyph_index_ready
.glyph_question:
    mov eax, 36
    jmp .glyph_index_ready
.glyph_period:
    mov eax, 37
    jmp .glyph_index_ready
.glyph_comma:
    mov eax, 38
    jmp .glyph_index_ready
.glyph_colon:
    mov eax, 39
    jmp .glyph_index_ready
.glyph_dash:
    mov eax, 40
    jmp .glyph_index_ready
.glyph_underscore:
    mov eax, 41
    jmp .glyph_index_ready
.glyph_exclamation:
    mov eax, 42
    jmp .glyph_index_ready
.glyph_quote:
    mov eax, 43
    jmp .glyph_index_ready
.glyph_apostrophe:
    mov eax, 44
    jmp .glyph_index_ready
.glyph_open_paren:
    mov eax, 45
    jmp .glyph_index_ready
.glyph_close_paren:
    mov eax, 46
    jmp .glyph_index_ready
.glyph_plus:
    mov eax, 47
    jmp .glyph_index_ready
.glyph_equals:
    mov eax, 48
    jmp .glyph_index_ready
.glyph_slash:
    mov eax, 49
    jmp .glyph_index_ready
.glyph_numbersign:
    mov eax, 50
    jmp .glyph_index_ready
.glyph_dollar:
    mov eax, 51
    jmp .glyph_index_ready
.glyph_percent:
    mov eax, 52
    jmp .glyph_index_ready
.glyph_ampersand:
    mov eax, 53
    jmp .glyph_index_ready
.glyph_asterisk:
    mov eax, 54
    jmp .glyph_index_ready
.glyph_semicolon:
    mov eax, 55
    jmp .glyph_index_ready
.glyph_less:
    mov eax, 56
    jmp .glyph_index_ready
.glyph_greater:
    mov eax, 57
    jmp .glyph_index_ready
.glyph_at:
    mov eax, 58
    jmp .glyph_index_ready
.glyph_open_bracket:
    mov eax, 59
    jmp .glyph_index_ready
.glyph_backslash:
    mov eax, 60
    jmp .glyph_index_ready
.glyph_close_bracket:
    mov eax, 61
    jmp .glyph_index_ready
.glyph_caret:
    mov eax, 62
    jmp .glyph_index_ready
.glyph_grave:
    mov eax, 63
    jmp .glyph_index_ready
.glyph_open_brace:
    mov eax, 64
    jmp .glyph_index_ready
.glyph_bar:
    mov eax, 65
    jmp .glyph_index_ready
.glyph_close_brace:
    mov eax, 66
    jmp .glyph_index_ready
.glyph_tilde:
    mov eax, 67
.glyph_index_ready:
    imul eax, 7
    lea rbx, [rip + font_5x7]
    add rbx, rax
    mov eax, dword ptr [rip + window_ui_scale_120]
    imul eax, dword ptr [rip + window_buffer_raster_scale_120]
    add eax, 14399
    xor edx, edx
    mov ecx, 14400
    div ecx
    mov r10d, eax
    cmp r10d, 1
    jae .glyph_fallback_scale_ready
    mov r10d, 1
.glyph_fallback_scale_ready:
    xor r14d, r14d
.glyph_row:
    cmp r14d, 7
    jae .glyph_done
    movzx r8d, byte ptr [rbx + r14]
    xor r15d, r15d
.glyph_column:
    cmp r15d, 5
    jae .glyph_next_row
    mov eax, 4
    sub eax, r15d
    bt r8d, eax
    jnc .glyph_next_column
    xor r11d, r11d
.glyph_fallback_subrow:
    cmp r11d, r10d
    jae .glyph_next_column
    mov eax, r14d
    imul eax, r10d
    add eax, r13d
    add eax, r11d
    mov ecx, dword ptr [rip + window_raster_surface_height]
    cmp eax, ecx
    jae .glyph_fallback_next_subrow
    # Keep the physical row coordinate intact across every horizontal subpixel.
    # The address calculation below repurposes EAX for the byte offset.
    mov esi, eax
    xor r9d, r9d
.glyph_fallback_subcolumn:
    cmp r9d, r10d
    jae .glyph_fallback_next_subrow
    mov edx, r15d
    imul edx, r10d
    add edx, r12d
    add edx, r9d
    mov ecx, dword ptr [rip + window_raster_surface_width]
    cmp edx, ecx
    jae .glyph_fallback_next_subcolumn
    # Map this physical surface pixel into the transformed SHM buffer.
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, 1
    je .glyph_fallback_map_90
    cmp eax, 2
    je .glyph_fallback_map_180
    cmp eax, 3
    je .glyph_fallback_map_270
    cmp eax, 4
    je .glyph_fallback_map_flipped
    cmp eax, 5
    je .glyph_fallback_map_flipped_90
    cmp eax, 6
    je .glyph_fallback_map_flipped_180
    cmp eax, 7
    je .glyph_fallback_map_flipped_270
    mov eax, esi
    jmp .glyph_fallback_map_done
.glyph_fallback_map_90:
    mov ecx, esi
    mov eax, dword ptr [rip + window_raster_surface_width]
    dec eax
    sub eax, edx
    mov edx, ecx
    jmp .glyph_fallback_map_done
.glyph_fallback_map_180:
    mov edi, dword ptr [rip + window_raster_surface_width]
    dec edi
    sub edi, edx
    mov eax, dword ptr [rip + window_raster_surface_height]
    dec eax
    sub eax, esi
    mov edx, edi
    jmp .glyph_fallback_map_done
.glyph_fallback_map_270:
    mov ecx, dword ptr [rip + window_raster_surface_height]
    dec ecx
    sub ecx, esi
    mov eax, edx
    mov edx, ecx
    jmp .glyph_fallback_map_done
.glyph_fallback_map_flipped:
    mov eax, dword ptr [rip + window_raster_surface_width]
    dec eax
    sub eax, edx
    mov edx, eax
    mov eax, esi
    jmp .glyph_fallback_map_done
.glyph_fallback_map_flipped_90:
    mov eax, esi
    mov ecx, edx
    mov edx, eax
    mov eax, ecx
    jmp .glyph_fallback_map_done
.glyph_fallback_map_flipped_180:
    mov eax, dword ptr [rip + window_raster_surface_height]
    dec eax
    sub eax, esi
    jmp .glyph_fallback_map_done
.glyph_fallback_map_flipped_270:
    mov ecx, dword ptr [rip + window_raster_surface_height]
    dec ecx
    sub ecx, esi
    mov eax, dword ptr [rip + window_raster_surface_width]
    dec eax
    sub eax, edx
    mov edx, ecx
.glyph_fallback_map_done:
    cmp edx, dword ptr [rip + window_buffer_width]
    jae .glyph_fallback_next_subcolumn
    cmp eax, dword ptr [rip + window_buffer_height]
    jae .glyph_fallback_next_subcolumn
    mov ecx, dword ptr [rip + window_stride]
    imul eax, ecx
    shl edx, 2
    add eax, edx
    mov rdi, qword ptr [rip + shm_mapping]
    add rdi, rax
    mov dword ptr [rdi], 0xffd8dee9
.glyph_fallback_next_subcolumn:
    inc r9d
    jmp .glyph_fallback_subcolumn
.glyph_fallback_next_subrow:
    inc r11d
    jmp .glyph_fallback_subrow
.glyph_next_column:
    inc r15d
    jmp .glyph_column
.glyph_next_row:
    inc r14d
    jmp .glyph_row
.glyph_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_glyph, . - draw_glyph

# Return a design-space advance for the active overlay transform.
# The glyph is rasterized at ui_transform_font_size, but its origin is transformed
# by ui_transform_x_num/ui_transform_x_den. Convert the same screen-pixel hmtx
# advance back to design coordinates so the next origin lands on the next glyph.
.type ui_font_advance_pixels, @function
ui_font_advance_pixels:
    push rbx
    mov ebx, edi
    cmp dword ptr [rip + ui_transform_active], 0
    je .ui_font_advance_legacy
    cmp dword ptr [rip + font_loaded], 0
    je .ui_font_advance_legacy
    mov esi, dword ptr [rip + ui_transform_font_size]
    test esi, esi
    jnz .ui_font_advance_size_ready
    mov esi, 10
.ui_font_advance_size_ready:
    mov edi, ebx
    call font_codepoint_advance_pixels_size
    mov ecx, dword ptr [rip + ui_transform_x_num]
    test ecx, ecx
    jz .ui_font_advance_done
    imul eax, dword ptr [rip + ui_transform_x_den]
    add eax, ecx
    dec eax
    xor edx, edx
    div ecx
    jmp .ui_font_advance_done
.ui_font_advance_legacy:
    mov edi, ebx
    mov esi, dword ptr [rip + ui_font_size]
    test esi, esi
    jnz .ui_font_advance_size_ready_default
    mov esi, 10
.ui_font_advance_size_ready_default:
    call font_codepoint_advance_pixels_size
.ui_font_advance_done:
    pop rbx
    ret
.size ui_font_advance_pixels, . - ui_font_advance_pixels

# Draw a NUL-terminated ASCII label. EDI=x, ESI=y, RDX=string; EAX=next x.
.type draw_text, @function
.type draw_text, @function
draw_text:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    mov rbx, rdx
.Lneko_draw_text_loop:
    movzx edx, byte ptr [rbx]
    test edx, edx
    jz .Lneko_draw_text_done
    mov edi, r12d
    mov esi, r13d
    mov ecx, dword ptr [rip + ui_font_size]
    test ecx, ecx
    jnz .Lneko_draw_text_default_size_ready
    mov ecx, 10
.Lneko_draw_text_default_size_ready:
    cmp dword ptr [rip + ui_transform_active], 0
    je .Lneko_draw_text_size_ready
    mov ecx, dword ptr [rip + ui_transform_font_size]
.Lneko_draw_text_size_ready:
    call draw_glyph
    movzx edi, byte ptr [rbx]
    call ui_font_advance_pixels
    add r12d, eax
    inc rbx
    jmp .Lneko_draw_text_loop
.Lneko_draw_text_done:
    mov eax, r12d
    pop r13
    pop r12
    pop rbx
    ret
.size draw_text, . - draw_text

# Draw an unsigned decimal value. EAX=value, EDI=x, ESI=y; returns next x.
.type draw_decimal, @function
.type draw_decimal, @function
draw_decimal:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40
    mov r13d, edi
    mov r14d, esi
    mov ebx, eax
    mov r15d, dword ptr [rip + ui_font_size]
    test r15d, r15d
    jnz .Lneko_draw_decimal_size_ready
    mov r15d, 10
.Lneko_draw_decimal_size_ready:
    cmp dword ptr [rip + ui_transform_active], 0
    je .Lneko_draw_decimal_measure_digits
    mov r15d, dword ptr [rip + ui_transform_font_size]
.Lneko_draw_decimal_measure_digits:
    # Use the widest digit advance as a fixed cell. This keeps numerical
    # columns aligned when a proportional UI font is selected.
    xor ebp, ebp
    mov dword ptr [rsp + 12], 0
.Lneko_draw_decimal_measure_loop:
    mov eax, dword ptr [rsp + 12]
    lea edi, [eax + '0']
    call ui_font_advance_pixels
    cmp eax, ebp
    jbe .Lneko_draw_decimal_measure_next
    mov ebp, eax
.Lneko_draw_decimal_measure_next:
    mov eax, dword ptr [rsp + 12]
    inc eax
    mov dword ptr [rsp + 12], eax
    cmp eax, 10
    jb .Lneko_draw_decimal_measure_loop
    mov dword ptr [rsp], ebp
    lea r12, [rsp + 31]
    mov byte ptr [r12], 0
.Lneko_draw_decimal_convert:
    mov eax, ebx
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    dec r12
    mov byte ptr [r12], dl
    mov ebx, eax
    test ebx, ebx
    jnz .Lneko_draw_decimal_convert
.Lneko_draw_decimal_paint:
    movzx eax, byte ptr [r12]
    test eax, eax
    jz .Lneko_draw_decimal_done
    mov dword ptr [rsp + 32], eax
    mov edi, eax
    call ui_font_advance_pixels
    mov dword ptr [rsp + 36], eax
    mov ecx, dword ptr [rsp]
    sub ecx, eax
    shr ecx, 1
    lea edi, [r13d + ecx]
    mov esi, r14d
    mov edx, dword ptr [rsp + 32]
    mov ecx, r15d
    call draw_glyph
    add r13d, dword ptr [rsp]
    inc r12
    jmp .Lneko_draw_decimal_paint
.Lneko_draw_decimal_done:
    mov eax, r13d
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size draw_decimal, . - draw_decimal

# Render the live logical line/column and current byte count in the footer.
# Columns are one-based; tabs advance to the next four-column stop.
.type render_status_bar, @function
render_status_bar:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    mov edx, dword ptr [rip + window_status_top]
    mov ecx, dword ptr [rip + window_width]
    mov eax, dword ptr [rip + window_height]
    sub eax, dword ptr [rip + window_status_top]
    mov r8d, eax
    mov r9d, 0xff343d4b
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    mov edx, dword ptr [rip + window_status_top]
    mov ecx, dword ptr [rip + window_width]
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect

    # Derive the logical line with the byte-length Fenwick tree, then scan
    # only the bytes from that line's start to the insertion point for column.
    # If the bounded index is unavailable, preserve the original full scan.
    mov ebx, dword ptr [rip + doc_cursor]
    cmp ebx, dword ptr [rip + doc_length]
    jbe .Lneko_status_cursor_bounded
    mov ebx, dword ptr [rip + doc_length]
.Lneko_status_cursor_bounded:
    call doc_line_index_ensure
    test eax, eax
    jz .Lneko_status_scan_legacy
    mov edi, ebx
    mov esi, DOC_INDEX_BYTE_TREE_OFFSET
    call doc_line_index_find_prefix
    lea r13d, [eax + 1]
    mov r14d, edx
    mov ebp, 1
    jmp .Lneko_status_scan
.Lneko_status_scan_legacy:
    xor r14d, r14d
    mov r13d, 1
    mov ebp, 1
.Lneko_status_scan:
    cmp r14d, ebx
    jae .Lneko_status_scan_done
    mov edi, r14d
    call doc_byte_at
    cmp eax, 10
    je .Lneko_status_newline
    cmp eax, 9
    je .Lneko_status_tab
    cmp eax, 32
    jb .Lneko_status_control
    inc ebp
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Lneko_status_scan
.Lneko_status_control:
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_newline:
    inc r13d
    mov ebp, 1
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_tab:
    dec ebp
    add ebp, 4
    and ebp, -4
    inc ebp
    inc r14d
    jmp .Lneko_status_scan
.Lneko_status_scan_done:
    mov r12d, dword ptr [rip + window_status_top]
    mov eax, dword ptr [rip + ui_font_size]
    test eax, eax
    jnz .Lneko_status_font_ready
    mov eax, 10
.Lneko_status_font_ready:
    mov ecx, 22
    sub ecx, eax
    sar ecx, 1
    add r12d, ecx
    mov edi, 16
    mov esi, r12d
    lea rdx, [rip + ui_label_line]
    call draw_text
    mov edi, eax
    mov esi, r12d
    mov eax, r13d
    call draw_decimal
    add eax, 4
    mov edi, eax
    mov esi, r12d
    lea rdx, [rip + ui_label_column]
    call draw_text
    mov edi, eax
    mov esi, r12d
    mov eax, ebp
    call draw_decimal

    mov edi, dword ptr [rip + window_status_bytes_x]
    mov esi, r12d
    lea rdx, [rip + ui_label_bytes]
    call draw_text
    # Keep a distinct visual gap between the "Bytes" label and its value.
    add eax, 8
    mov edi, eax
    mov esi, r12d
    mov eax, dword ptr [rip + doc_length]
    call draw_decimal
    mov edi, dword ptr [rip + window_status_mode_x]
    mov esi, r12d
    lea rdx, [rip + ui_mode_name]
    call draw_text
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size render_status_bar, . - render_status_bar


.type draw_bounded_ascii, @function
# RDI=x, ESI=y, RDX=NUL-terminated byte string, ECX=maximum bytes.
# Non-printable and non-ASCII bytes are rendered as '?' while path operations
# continue to use the untouched original name/path bytes.
draw_bounded_ascii:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdx
    mov r12d, edi
    mov r13d, esi
    mov r14d, ecx
.draw_bounded_ascii_loop:
    test r14d, r14d
    jz .draw_bounded_ascii_done
    movzx edx, byte ptr [rbx]
    test dl, dl
    jz .draw_bounded_ascii_done
    cmp dl, 32
    jb .draw_bounded_ascii_replacement
    cmp dl, 126
    ja .draw_bounded_ascii_replacement
    jmp .draw_bounded_ascii_glyph
.draw_bounded_ascii_replacement:
    mov edx, '?'
.draw_bounded_ascii_glyph:
    mov r15d, edx
    mov edi, r12d
    mov esi, r13d
    mov ecx, 10
    cmp dword ptr [rip + ui_transform_active], 0
    je .draw_bounded_ascii_size_ready
    mov ecx, dword ptr [rip + ui_transform_font_size]
.draw_bounded_ascii_size_ready:
    call draw_glyph
    mov edi, r15d
    call ui_font_advance_pixels
    add r12d, eax
    inc rbx
    dec r14d
    jmp .draw_bounded_ascii_loop
.draw_bounded_ascii_done:
    mov eax, r12d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size draw_bounded_ascii, . - draw_bounded_ascii


# Return a picker design-space advance using the rendered UI font size.
# This is shared by text clipping, caret placement, and pointer hit-testing.
.type picker_font_advance_pixels, @function
picker_font_advance_pixels:
    push rbx
    mov ebx, edi
    mov esi, dword ptr [rip + picker_ui_font_size]
    test esi, esi
    jnz .picker_font_advance_size_ready
    mov esi, 10
.picker_font_advance_size_ready:
    mov edi, ebx
    call font_codepoint_advance_pixels_size
    cmp dword ptr [rip + font_loaded], 0
    je .picker_font_advance_done
    mov ecx, dword ptr [rip + picker_panel_width]
    test ecx, ecx
    jz .picker_font_advance_done
    imul eax, 720
    add eax, ecx
    dec eax
    xor edx, edx
    div ecx
.picker_font_advance_done:
    pop rbx
    ret
.size picker_font_advance_pixels, . - picker_font_advance_pixels

# RDI=ASCII text pointer, ESI=character count. EAX=prefix width in logical UI pixels.
.type picker_measure_ascii_prefix, @function
picker_measure_ascii_prefix:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12d, esi
    xor r13d, r13d
.picker_measure_ascii_prefix_loop:
    test r12d, r12d
    jz .picker_measure_ascii_prefix_done
    movzx edi, byte ptr [rbx]
    call picker_font_advance_pixels
    add r13d, eax
    inc rbx
    dec r12d
    jmp .picker_measure_ascii_prefix_loop
.picker_measure_ascii_prefix_done:
    mov eax, r13d
    pop r13
    pop r12
    pop rbx
    ret
.size picker_measure_ascii_prefix, . - picker_measure_ascii_prefix

# RDI=ASCII text pointer, ESI=length, EDX=target X in logical UI pixels.
# Return the nearest insertion boundary using the same glyph-advance midpoint as drawing.
.type picker_hit_test_ascii, @function
picker_hit_test_ascii:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx
    xor r14d, r14d
    xor r15d, r15d
.picker_hit_test_ascii_loop:
    cmp r14d, r12d
    jae .picker_hit_test_ascii_done
    movzx edi, byte ptr [rbx + r14]
    call picker_font_advance_pixels
    mov ecx, eax
    shr eax, 1
    add eax, r15d
    cmp r13d, eax
    jb .picker_hit_test_ascii_done
    add r15d, ecx
    inc r14d
    jmp .picker_hit_test_ascii_loop
.picker_hit_test_ascii_done:
    mov eax, r14d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size picker_hit_test_ascii, . - picker_hit_test_ascii

# RDI=ASCII text pointer, ESI=cursor offset, EDX=max visible width.
# Walk backward from the cursor so it remains visible in a proportional text field.
.type picker_field_view_start, @function
picker_field_view_start:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r13d, esi
    mov r14d, edx
    xor ebp, ebp
.picker_field_view_start_loop:
    test r13d, r13d
    jz .picker_field_view_start_done
    movzx edi, byte ptr [rbx + r13 - 1]
    call picker_font_advance_pixels
    lea ecx, [rbp + rax]
    cmp ecx, r14d
    ja .picker_field_view_start_done
    mov ebp, ecx
    dec r13d
    jmp .picker_field_view_start_loop
.picker_field_view_start_done:
    mov eax, r13d
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size picker_field_view_start, . - picker_field_view_start

# RDI=x, ESI=y, RDX=NUL-terminated ASCII, ECX=max logical pixel width.
# Truncate at glyph boundaries so a long proportional name cannot enter adjacent controls.
.type draw_bounded_ascii_width, @function
draw_bounded_ascii_width:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rdx
    mov r12d, edi
    mov r13d, esi
    mov r14d, ecx
.draw_bounded_ascii_width_loop:
    movzx edx, byte ptr [rbx]
    test dl, dl
    jz .draw_bounded_ascii_width_done
    cmp dl, 32
    jb .draw_bounded_ascii_width_replacement
    cmp dl, 126
    ja .draw_bounded_ascii_width_replacement
    jmp .draw_bounded_ascii_width_advance
.draw_bounded_ascii_width_replacement:
    mov edx, '?'
.draw_bounded_ascii_width_advance:
    mov r15d, edx
    mov edi, r15d
    call ui_font_advance_pixels
    cmp eax, r14d
    ja .draw_bounded_ascii_width_done
    mov ebp, eax
    mov edi, r12d
    mov esi, r13d
    mov ecx, 10
    cmp dword ptr [rip + ui_transform_active], 0
    je .draw_bounded_ascii_width_size_ready
    mov ecx, dword ptr [rip + ui_transform_font_size]
.draw_bounded_ascii_width_size_ready:
    mov edx, r15d
    call draw_glyph
    add r12d, ebp
    sub r14d, ebp
    inc rbx
    jmp .draw_bounded_ascii_width_loop
.draw_bounded_ascii_width_done:
    mov eax, r12d
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size draw_bounded_ascii_width, . - draw_bounded_ascii_width

.type render_picker, @function
render_picker:
    cmp dword ptr [rip + picker_mode], 0
    je .render_picker_done
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    # Center the picker and scale its 720x408 design box to the available
    # surface. draw_rect/draw_glyph share this transform for visual alignment.
    mov dword ptr [rip + ui_transform_active], 1
    mov eax, dword ptr [rip + picker_ui_font_size]
    mov dword ptr [rip + ui_transform_font_size], eax
    mov dword ptr [rip + ui_transform_base_x], 40
    mov dword ptr [rip + ui_transform_base_y], 36
    mov eax, dword ptr [rip + picker_panel_x]
    mov dword ptr [rip + ui_transform_origin_x], eax
    mov eax, dword ptr [rip + picker_panel_y]
    mov dword ptr [rip + ui_transform_origin_y], eax
    mov eax, dword ptr [rip + picker_panel_width]
    mov dword ptr [rip + ui_transform_x_num], eax
    mov dword ptr [rip + ui_transform_x_den], 720
    mov eax, dword ptr [rip + picker_panel_height]
    mov dword ptr [rip + ui_transform_y_num], eax
    mov dword ptr [rip + ui_transform_y_den], 408

    # Modal panel and title strip.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 40
    mov edx, 36
    mov ecx, 720
    mov r8d, 408
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 40
    mov edx, 36
    mov ecx, 720
    mov r8d, 28
    mov r9d, 0xff343d4b
    call draw_rect
    cmp dword ptr [rip + picker_mode], 1
    je .render_picker_title_open
    cmp dword ptr [rip + picker_mode], 6
    je .render_picker_title_import_xcompose
    cmp dword ptr [rip + picker_mode], 4
    je .render_picker_title_install
    cmp dword ptr [rip + picker_mode], 3
    jne .render_picker_title_save
    mov edi, 56
    mov esi, 40
    lea rdx, [rip + ui_picker_font_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_import_xcompose:
    mov edi, 56
    mov esi, 40
    lea rdx, [rip + ui_picker_import_xcompose_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_install:
    mov edi, 56
    mov esi, 40
    cmp dword ptr [rip + picker_mode], 5
    je .render_picker_title_select_locale
    lea rdx, [rip + ui_picker_install_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_select_locale:
    mov edi, 56
    mov esi, 40
    lea rdx, [rip + ui_picker_select_locale_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_open:
    mov edi, 56
    mov esi, 40
    lea rdx, [rip + ui_picker_open_title]
    call draw_text
    jmp .render_picker_path
.render_picker_title_save:
    mov edi, 56
    mov esi, 40
    lea rdx, [rip + ui_picker_save_title]
    call draw_text

.render_picker_path:
    mov edi, 56
    mov esi, 62
    cmp dword ptr [rip + picker_mode], 4
    je .render_picker_path_source_label
    cmp dword ptr [rip + picker_mode], 6
    jne .render_picker_path_location_label
.render_picker_path_source_label:
    lea rdx, [rip + ui_picker_source_label]
    jmp .render_picker_path_label_draw
.render_picker_path_location_label:
    lea rdx, [rip + ui_picker_path_label]
.render_picker_path_label_draw:
    call draw_text
    cmp dword ptr [rip + picker_mode], 4
    je .render_picker_target_label
    cmp dword ptr [rip + picker_mode], 6
    jne .render_picker_target_done
.render_picker_target_label:
    mov edi, 128
    mov esi, 62
    lea rdx, [rip + ui_picker_install_target_label]
    call draw_text
.render_picker_target_done:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 80
    mov ecx, 688
    mov r8d, 28
    mov r9d, 0xff252a33
    call draw_rect
    cmp dword ptr [rip + picker_focus], 1
    jne .render_picker_path_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 107
    mov ecx, 688
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect
.render_picker_path_text:
    cmp dword ptr [rip + picker_focus], 1
    jne .render_picker_path_window
    cmp dword ptr [rip + picker_edit_select_all], 0
    je .render_picker_path_window
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 64
    mov edx, 84
    mov ecx, 672
    mov r8d, 16
    mov r9d, 0xff414b5a
    call draw_rect
.render_picker_path_window:
    lea rdi, [rip + picker_path_buffer]
    mov esi, dword ptr [rip + picker_path_cursor]
    mov edx, 672
    call picker_field_view_start
    mov dword ptr [rip + picker_path_view_start], eax
    lea rdi, [rip + picker_path_buffer]
    add rdi, rax
    mov esi, dword ptr [rip + picker_path_cursor]
    sub esi, dword ptr [rip + picker_path_view_start]
    call picker_measure_ascii_prefix
    mov r12d, eax
    lea rdx, [rip + picker_path_buffer]
    mov eax, dword ptr [rip + picker_path_view_start]
    add rdx, rax
    mov edi, 64
    mov esi, 88
    mov ecx, 672
    call draw_bounded_ascii_width
    cmp dword ptr [rip + picker_focus], 1
    jne .render_picker_path_done
    cmp dword ptr [rip + picker_edit_select_all], 0
    jne .render_picker_path_done
    lea eax, [r12d + 64]
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, eax
    mov edx, 84
    mov ecx, 1
    mov r8d, 18
    mov r9d, 0xfff0f3f7
    call draw_rect
.render_picker_path_done:

    # Up, Home, and hidden-file visibility controls.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 112
    mov ecx, 44
    mov r8d, 26
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 68
    mov esi, 119
    lea rdx, [rip + ui_picker_up_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 112
    mov ecx, 56
    mov r8d, 26
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 116
    mov esi, 119
    lea rdx, [rip + ui_picker_home_label]
    call draw_text
    mov edi, 600
    mov esi, 119
    lea rdx, [rip + ui_picker_hidden_label]
    call draw_text
    # Bordered 16x16 checkbox, with a filled interior and visible check mark.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 714
    mov edx, 116
    mov ecx, 16
    mov r8d, 16
    mov r9d, 0xff9aa7b8
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 716
    mov edx, 118
    mov ecx, 12
    mov r8d, 12
    mov r9d, 0xff252a33
    call draw_rect
    cmp dword ptr [rip + picker_show_hidden], 0
    je .render_picker_list
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 716
    mov edx, 118
    mov ecx, 12
    mov r8d, 12
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 718
    mov esi, 118
    lea rdx, [rip + ui_picker_check_mark]
    call draw_text

.render_picker_list:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 56
    mov edx, 142
    mov ecx, 688
    mov r8d, 210
    mov r9d, 0xff252a33
    call draw_rect
    # A scrollbar exists only when entries overflow the visible list.
    call picker_scrollbar_geometry
    mov r12d, dword ptr [rip + picker_scroll]
    xor r13d, r13d
    cmp dword ptr [rip + picker_scroll_thumb_height], 0
    je .render_picker_rows
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, PICKER_TRACK_X
    mov edx, PICKER_TRACK_TOP
    mov ecx, PICKER_TRACK_WIDTH
    mov r8d, PICKER_TRACK_HEIGHT
    mov r9d, 0xff171c24
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, PICKER_TRACK_X + 2
    mov edx, dword ptr [rip + picker_scroll_thumb_top]
    mov ecx, PICKER_TRACK_WIDTH - 4
    mov r8d, dword ptr [rip + picker_scroll_thumb_height]
    cmp dword ptr [rip + picker_scroll_drag], 0
    je .render_picker_scroll_thumb_normal
    mov r9d, 0xff9bb9d8
    jmp .render_picker_scroll_thumb_draw
.render_picker_scroll_thumb_normal:
    mov r9d, 0xff687789
.render_picker_scroll_thumb_draw:
    call draw_rect
.render_picker_rows:
    cmp r13d, PICKER_VISIBLE_ROWS
    jae .render_picker_empty_or_name
    mov r14d, r12d
    add r14d, r13d
    cmp r14d, dword ptr [rip + picker_entry_count]
    jae .render_picker_empty_or_name
    cmp r14d, dword ptr [rip + picker_selected]
    jne .render_picker_row_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 58
    mov eax, r13d
    imul eax, PICKER_ROW_HEIGHT
    lea edx, [rax + PICKER_TRACK_TOP]
    mov ecx, 660
    mov r8d, PICKER_ROW_HEIGHT
    mov r9d, 0xff414b5a
    call draw_rect
.render_picker_row_text:
    mov eax, r14d
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    mov edi, 64
    mov eax, r13d
    imul eax, PICKER_ROW_HEIGHT
    lea esi, [rax + PICKER_TRACK_TOP + 2]
    cmp byte ptr [rbx], 1
    jne .render_picker_file_marker
    lea rdx, [rip + ui_picker_dir_marker]
    call draw_text
    jmp .render_picker_draw_name
.render_picker_file_marker:
    lea rdx, [rip + ui_picker_file_marker]
    call draw_text
.render_picker_draw_name:
    lea rdx, [rbx + 4]
    mov edi, 96
    mov eax, r13d
    imul eax, PICKER_ROW_HEIGHT
    lea esi, [rax + PICKER_TRACK_TOP + 2]
    mov ecx, 612
    call draw_bounded_ascii_width
    inc r13d
    jmp .render_picker_rows

.render_picker_empty_or_name:
    cmp dword ptr [rip + picker_entry_count], 0
    jne .render_picker_suggestions
    mov edi, 72
    mov esi, 158
    lea rdx, [rip + ui_picker_empty]
    call draw_text

.render_picker_suggestions:
    cmp dword ptr [rip + picker_mode], 1
    je .render_picker_suggestions_open
    cmp dword ptr [rip + picker_mode], 3
    jne .render_picker_name
.render_picker_suggestions_open:
    cmp dword ptr [rip + picker_focus], 2
    jne .render_picker_name
    mov r12d, dword ptr [rip + picker_suggestion_count]
    test r12d, r12d
    jz .render_picker_name
    # A compact dropdown is drawn over the lower list rows, directly above
    # the Search field. It shows up to five selectable regular-file matches.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 168
    mov edx, PICKER_SUGGESTION_TOP
    mov ecx, 440
    mov eax, r12d
    imul eax, PICKER_SUGGESTION_ROW_HEIGHT
    add eax, 4
    mov r8d, eax
    mov r9d, 0xff171c24
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 170
    mov edx, PICKER_SUGGESTION_TOP + 2
    mov ecx, 436
    mov eax, r12d
    imul eax, PICKER_SUGGESTION_ROW_HEIGHT
    mov r8d, eax
    mov r9d, 0xff1f242d
    call draw_rect
    xor r13d, r13d
.render_picker_suggestion_rows:
    cmp r13d, r12d
    jae .render_picker_name
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 172
    mov eax, r13d
    imul eax, PICKER_SUGGESTION_ROW_HEIGHT
    lea edx, [rax + PICKER_SUGGESTION_TOP + 2]
    mov ecx, 432
    mov r8d, PICKER_SUGGESTION_ROW_HEIGHT
    cmp r13d, dword ptr [rip + picker_suggestion_selected]
    jne .render_picker_suggestion_normal
    mov r9d, 0xff414b5a
    jmp .render_picker_suggestion_fill
.render_picker_suggestion_normal:
    mov r9d, 0xff252a33
.render_picker_suggestion_fill:
    call draw_rect
    mov eax, r13d
    imul eax, 4
    lea rdx, [rip + picker_suggestion_indices]
    mov eax, dword ptr [rdx + rax]
    imul eax, PICKER_ENTRY_SIZE
    lea rbx, [rip + picker_entries]
    add rbx, rax
    mov edi, 184
    mov eax, r13d
    imul eax, PICKER_SUGGESTION_ROW_HEIGHT
    lea esi, [rax + PICKER_SUGGESTION_TOP + 4]
    lea rdx, [rbx + 4]
    mov ecx, 416
    call draw_bounded_ascii_width
    inc r13d
    jmp .render_picker_suggestion_rows

.render_picker_name:
    mov edi, 56
    mov esi, 368
    cmp dword ptr [rip + picker_mode], 1
    je .render_picker_name_label_search
    cmp dword ptr [rip + picker_mode], 3
    jne .render_picker_name_label_file
.render_picker_name_label_search:
    lea rdx, [rip + ui_picker_search_label]
    jmp .render_picker_name_label_draw
.render_picker_name_label_file:
    lea rdx, [rip + ui_picker_name_label]
.render_picker_name_label_draw:
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 168
    mov edx, 360
    mov ecx, 440
    mov r8d, 28
    mov r9d, 0xff252a33
    call draw_rect
    cmp dword ptr [rip + picker_focus], 2
    jne .render_picker_name_window
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 168
    mov edx, 387
    mov ecx, 440
    mov r8d, 1
    mov r9d, 0xff78a9d4
    call draw_rect
    cmp dword ptr [rip + picker_edit_select_all], 0
    je .render_picker_name_window
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 176
    mov edx, 366
    mov ecx, 424
    mov r8d, 16
    mov r9d, 0xff414b5a
    call draw_rect
.render_picker_name_window:
    lea rdi, [rip + picker_name_buffer]
    mov esi, dword ptr [rip + picker_name_cursor]
    mov edx, 424
    call picker_field_view_start
    mov dword ptr [rip + picker_name_view_start], eax
    lea rdi, [rip + picker_name_buffer]
    add rdi, rax
    mov esi, dword ptr [rip + picker_name_cursor]
    sub esi, dword ptr [rip + picker_name_view_start]
    call picker_measure_ascii_prefix
    mov r12d, eax
    lea rdx, [rip + picker_name_buffer]
    mov eax, dword ptr [rip + picker_name_view_start]
    add rdx, rax
    mov edi, 176
    mov esi, 368
    mov ecx, 424
    call draw_bounded_ascii_width
    cmp dword ptr [rip + picker_focus], 2
    jne .render_picker_name_text_done
    cmp dword ptr [rip + picker_edit_select_all], 0
    jne .render_picker_name_text_done
    lea eax, [r12d + 176]
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, eax
    mov edx, 365
    mov ecx, 1
    mov r8d, 18
    mov r9d, 0xfff0f3f7
    call draw_rect
.render_picker_name_text_done:

    # Cancel and Open/Save action buttons.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 600
    mov edx, 396
    mov ecx, 72
    mov r8d, 32
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 612
    mov esi, 407
    lea rdx, [rip + ui_picker_cancel_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 680
    mov edx, 396
    mov ecx, 72
    mov r8d, 32
    mov r9d, 0xff78a9d4
    call draw_rect
    mov edi, 692
    mov esi, 407
    cmp dword ptr [rip + picker_mode], 1
    je .render_picker_open_label
    cmp dword ptr [rip + picker_mode], 5
    je .render_picker_select_locale_label
    cmp dword ptr [rip + picker_mode], 4
    je .render_picker_install_label
    cmp dword ptr [rip + picker_mode], 6
    je .render_picker_import_label
    cmp dword ptr [rip + picker_mode], 3
    jne .render_picker_save_label
    lea rdx, [rip + ui_picker_load_label]
    jmp .render_picker_action_label
.render_picker_select_locale_label:
    lea rdx, [rip + ui_picker_select_locale_label]
    jmp .render_picker_action_label
.render_picker_install_label:
    lea rdx, [rip + ui_picker_install_label]
    jmp .render_picker_action_label
.render_picker_import_label:
    lea rdx, [rip + ui_picker_import_label]
    jmp .render_picker_action_label
.render_picker_open_label:
    lea rdx, [rip + ui_picker_open_label]
    jmp .render_picker_action_label
.render_picker_save_label:
    lea rdx, [rip + ui_picker_save_label]
.render_picker_action_label:
    call draw_text

    cmp dword ptr [rip + picker_truncated], 0
    je .render_picker_messages
    mov edi, 56
    mov esi, 434
    lea rdx, [rip + ui_picker_truncated]
    call draw_text
.render_picker_messages:
    cmp dword ptr [rip + picker_error], 0
    je .render_picker_overwrite
    mov edi, 352
    mov esi, 434
    cmp dword ptr [rip + picker_error], 1
    jne .render_picker_error_file
    lea rdx, [rip + ui_picker_error_path]
    jmp .render_picker_error_draw
.render_picker_error_file:
    cmp dword ptr [rip + picker_error], 6
    je .render_picker_error_xcompose
    cmp dword ptr [rip + picker_error], 5
    je .render_picker_error_locale
    cmp dword ptr [rip + picker_error], 4
    je .render_picker_error_font
    cmp dword ptr [rip + picker_error], 2
    jne .render_picker_error_save
    lea rdx, [rip + ui_picker_error_file]
    jmp .render_picker_error_draw
.render_picker_error_xcompose:
    lea rdx, [rip + ui_picker_error_xcompose]
    jmp .render_picker_error_draw
.render_picker_error_locale:
    lea rdx, [rip + ui_picker_error_locale]
    jmp .render_picker_error_draw
.render_picker_error_font:
    lea rdx, [rip + ui_picker_error_font]
    jmp .render_picker_error_draw
.render_picker_error_save:
    lea rdx, [rip + ui_picker_error_save]
.render_picker_error_draw:
    call draw_text

.render_picker_overwrite:
    cmp dword ptr [rip + picker_overwrite_pending], 0
    je .render_picker_done_pop
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 184
    mov edx, 176
    mov ecx, 432
    mov r8d, 80
    mov r9d, 0xff343d4b
    call draw_rect
    mov edi, 208
    mov esi, 190
    lea rdx, [rip + ui_picker_overwrite]
    call draw_text

.render_picker_done_pop:
    mov dword ptr [rip + ui_transform_active], 0
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
.render_picker_done:
    ret
.size render_picker, . - render_picker

.type render_window_controls, @function
render_window_controls:
    push rbx
    push r12
    mov ebx, dword ptr [rip + window_width]
    sub ebx, 104
    # Minimize.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, ebx
    mov edx, 4
    mov ecx, 24
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    lea esi, [rbx + 8]
    mov rdi, qword ptr [rip + shm_mapping]
    mov edx, 15
    mov ecx, 8
    mov r8d, 2
    mov r9d, 0xffd8dee9
    call draw_rect
    # Maximize/restore.
    add ebx, 32
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, ebx
    mov edx, 4
    mov ecx, 24
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    lea r12d, [rbx + 7]
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, 9
    mov ecx, 10
    mov r8d, 2
    mov r9d, 0xffd8dee9
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, 19
    mov ecx, 10
    mov r8d, 2
    mov r9d, 0xffd8dee9
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, 9
    mov ecx, 2
    mov r8d, 12
    mov r9d, 0xffd8dee9
    call draw_rect
    lea esi, [r12 + 8]
    mov rdi, qword ptr [rip + shm_mapping]
    mov edx, 9
    mov ecx, 2
    mov r8d, 12
    mov r9d, 0xffd8dee9
    call draw_rect
    # Close.
    add ebx, 32
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, ebx
    mov edx, 4
    mov ecx, 24
    mov r8d, 24
    mov r9d, 0xff754b52
    call draw_rect
    lea edi, [rbx + 8]
    mov esi, 12
    mov edx, 'X'
    mov ecx, 10
    call draw_glyph
    pop r12
    pop rbx
    ret
.size render_window_controls, . - render_window_controls

.type render_file_menu, @function
render_file_menu:
    cmp dword ptr [rip + file_menu_open], 1
    je .render_file_menu_draw_file
    cmp dword ptr [rip + settings_menu_open], 1
    je .render_file_menu_draw_settings
    ret
.render_file_menu_draw_file:
    push rbp
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 104
    mov edx, 32
    mov ecx, 128
    mov r8d, 80
    mov r9d, 0xff1f242d
    call draw_rect
    mov edi, 116
    mov esi, 42
    lea rdx, [rip + ui_menu_open_label]
    call draw_text
    mov edi, 116
    mov esi, 66
    lea rdx, [rip + ui_menu_save_label]
    call draw_text
    mov edi, 116
    mov esi, 90
    lea rdx, [rip + ui_menu_save_as_label]
    call draw_text
    pop rbp
    ret
.render_file_menu_draw_settings:
    push rbp
    # Settings is modal: clear the document/History workspace while leaving
    # the title bar and tab strip visible. The panel is then painted above it.
    mov dword ptr [rip + ui_transform_active], 0
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    mov edx, 76
    mov ecx, dword ptr [rip + window_width]
    mov r8d, dword ptr [rip + window_height]
    sub r8d, 76
    mov r9d, 0xff252a33
    call draw_rect
    mov dword ptr [rip + ui_transform_active], 1
    mov eax, dword ptr [rip + settings_ui_font_size]
    mov dword ptr [rip + ui_transform_font_size], eax
    mov dword ptr [rip + ui_transform_base_x], 160
    mov dword ptr [rip + ui_transform_base_y], 32
    mov eax, dword ptr [rip + settings_panel_x]
    mov dword ptr [rip + ui_transform_origin_x], eax
    mov eax, dword ptr [rip + settings_panel_y]
    mov dword ptr [rip + ui_transform_origin_y], eax
    mov eax, dword ptr [rip + settings_panel_width]
    mov dword ptr [rip + ui_transform_x_num], eax
    mov dword ptr [rip + ui_transform_x_den], 256
    mov eax, dword ptr [rip + settings_panel_height]
    mov dword ptr [rip + ui_transform_y_num], eax
    mov dword ptr [rip + ui_transform_y_den], 192
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 160
    mov edx, 32
    mov ecx, 256
    mov r8d, 192
    mov r9d, 0xff1f242d
    call draw_rect
    mov edi, 172
    mov esi, 44
    lea rdx, [rip + ui_menu_confirm_save_label]
    call draw_text
    mov edi, 372
    mov esi, 44
    cmp dword ptr [rip + save_confirm_enabled], 0
    je .render_settings_state_off
    lea rdx, [rip + ui_menu_state_on]
    jmp .render_settings_state_draw
.render_settings_state_off:
    lea rdx, [rip + ui_menu_state_off]
 .render_settings_state_draw:
    call draw_text
    mov edi, 172
    mov esi, 68
    lea rdx, [rip + ui_menu_font_size_label]
    call draw_text
    mov edi, 260
    mov esi, 68
    mov eax, dword ptr [rip + doc_font_size]
    call draw_decimal
    mov edi, 282
    mov esi, 68
    lea rdx, [rip + ui_menu_px_label]
    call draw_text
    mov edi, 172
    mov esi, 92
    lea rdx, [rip + ui_menu_ui_font_size_label]
    call draw_text
    mov edi, 260
    mov esi, 92
    mov eax, dword ptr [rip + ui_font_size]
    call draw_decimal
    mov edi, 282
    mov esi, 92
    lea rdx, [rip + ui_menu_px_label]
    call draw_text
    mov edi, 172
    mov esi, 120
    lea rdx, [rip + ui_menu_wrap_lines_label]
    call draw_text
    mov edi, 372
    mov esi, 120
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .render_settings_wrap_off
    lea rdx, [rip + ui_menu_state_on]
    jmp .render_settings_wrap_draw
.render_settings_wrap_off:
    lea rdx, [rip + ui_menu_state_off]
.render_settings_wrap_draw:
    call draw_text
    cmp dword ptr [rip + font_loaded], 0
    je .render_settings_size_controls_done
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 344
    mov edx, 66
    mov ecx, 28
    mov r8d, 22
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 384
    mov edx, 66
    mov ecx, 28
    mov r8d, 22
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 354
    mov esi, 72
    lea rdx, [rip + ui_menu_minus_label]
    call draw_text
    mov edi, 394
    mov esi, 72
    lea rdx, [rip + ui_menu_plus_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 344
    mov edx, 90
    mov ecx, 28
    mov r8d, 22
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 384
    mov edx, 90
    mov ecx, 28
    mov r8d, 22
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 354
    mov esi, 96
    lea rdx, [rip + ui_menu_minus_label]
    call draw_text
    mov edi, 394
    mov esi, 96
    lea rdx, [rip + ui_menu_plus_label]
    call draw_text
.render_settings_size_controls_done:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 344
    mov edx, 140
    mov ecx, 72
    mov r8d, 18
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 172
    mov esi, 148
    lea rdx, [rip + ui_menu_font_file_label]
    call draw_text
    mov edi, 172
    mov esi, 176
    lea rdx, [rip + ui_menu_clipboard_label]
    call draw_text
    mov edi, 372
    mov esi, 176
    cmp dword ptr [rip + clipboard_persistence_enabled], 0
    je .render_settings_clipboard_off
    lea rdx, [rip + ui_menu_state_on]
    jmp .render_settings_clipboard_draw
.render_settings_clipboard_off:
    lea rdx, [rip + ui_menu_state_off]
.render_settings_clipboard_draw:
    call draw_text

    # Compose locale selector: the selected tag is the dropdown button.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 160
    mov edx, 188
    mov ecx, 96
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdx, qword ptr [rip + preferences_locale_ptr]
    test rdx, rdx
    jnz .render_settings_locale_tag_ready
    lea rdx, [rip + compose_locale_current_tag]
    cmp byte ptr [rdx], 0
    jne .render_settings_locale_tag_ready
    lea rdx, [rip + ui_menu_locale_en]
.render_settings_locale_tag_ready:
    mov edi, 168
    mov esi, 204
    mov ecx, 78
    call draw_bounded_ascii_width
    mov edi, 244
    mov esi, 204
    mov edx, 'v'
    mov ecx, 7
    call draw_glyph

    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 260
    mov edx, 188
    mov ecx, 44
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 308
    mov edx, 188
    mov ecx, 56
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 368
    mov edx, 188
    mov ecx, 48
    mov r8d, 24
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 271
    mov esi, 204
    lea rdx, [rip + ui_menu_locale_add]
    call draw_text
    mov edi, 317
    mov esi, 204
    lea rdx, [rip + ui_menu_locale_remove]
    call draw_text
    mov edi, 372
    mov esi, 204
    lea rdx, [rip + ui_menu_locale_import]
    call draw_text
    call preferences_locale_is_builtin
    test eax, eax
    jnz .render_settings_locale_en
    cmp qword ptr [rip + preferences_locale_ptr], 0
    je .render_settings_locale_effective
    cmp dword ptr [rip + compose_locale_active], 0
    je .render_settings_locale_missing
.render_settings_locale_effective:
    cmp dword ptr [rip + compose_locale_active], 0
    jne .render_settings_locale_active
.render_settings_locale_en:
    lea rdx, [rip + ui_menu_locale_en]
    jmp .render_settings_locale_value
.render_settings_locale_missing:
    lea rdx, [rip + ui_menu_locale_missing]
    jmp .render_settings_locale_value
.render_settings_locale_active:
    lea rdx, [rip + ui_menu_locale_active]
.render_settings_locale_value:
    cmp dword ptr [rip + locale_manager_error], 0
    je .render_settings_locale_status
    lea rdx, [rip + ui_menu_locale_error]
.render_settings_locale_status:
    mov edi, 168
    mov esi, 216
    call draw_text
    call render_settings_locale_dropdown
.render_file_menu_settings_finish:
    mov edi, 360
    mov esi, 146
    lea rdx, [rip + ui_menu_select_label]
    call draw_text
    mov dword ptr [rip + ui_transform_active], 0
    pop rbp
    ret
.size render_file_menu, . - render_file_menu

# Minimal three-command document context menu, painted after all other UI.
.type render_context_menu, @function
render_context_menu:
    cmp dword ptr [rip + context_menu_open], 1
    jne .Lrender_context_menu_done
    push rbx
    push r12
    mov dword ptr [rip + ui_transform_active], 0
    mov ebx, dword ptr [rip + context_menu_x]
    mov r12d, dword ptr [rip + context_menu_y]
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, ebx
    mov edx, r12d
    mov ecx, CONTEXT_MENU_WIDTH
    mov r8d, CONTEXT_MENU_HEIGHT
    mov r9d, 0xff78a9d4
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    lea esi, [rbx + 1]
    lea edx, [r12 + 1]
    mov ecx, CONTEXT_MENU_WIDTH - 2
    mov r8d, CONTEXT_MENU_HEIGHT - 2
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    lea esi, [rbx + 1]
    lea edx, [r12 + CONTEXT_MENU_ROW_HEIGHT]
    mov ecx, CONTEXT_MENU_WIDTH - 2
    mov r8d, 1
    mov r9d, 0xff414b5a
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    lea esi, [rbx + 1]
    lea edx, [r12 + CONTEXT_MENU_ROW_HEIGHT * 2]
    mov ecx, CONTEXT_MENU_WIDTH - 2
    mov r8d, 1
    mov r9d, 0xff414b5a
    call draw_rect
    lea edi, [rbx + 12]
    lea esi, [r12 + 7]
    lea rdx, [rip + ui_context_menu_copy_label]
    call draw_text
    lea edi, [rbx + 12]
    lea esi, [r12 + CONTEXT_MENU_ROW_HEIGHT + 7]
    lea rdx, [rip + ui_context_menu_paste_label]
    call draw_text
    lea edi, [rbx + 12]
    lea esi, [r12 + CONTEXT_MENU_ROW_HEIGHT * 2 + 7]
    lea rdx, [rip + ui_context_menu_cut_label]
    call draw_text
    pop r12
    pop rbx
.Lrender_context_menu_done:
    ret
.size render_context_menu, . - render_context_menu

# Build a horizontally scrolled view of the History path query.
# The full query remains in history_search_query_buffer; this display slice
# keeps the insertion caret visible even when the query exceeds the field.
.type history_search_prepare_display, @function
history_search_prepare_display:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16
    mov ebx, dword ptr [rip + history_search_length]
    cmp ebx, 127
    jbe .history_search_display_length_ready
    mov ebx, 127
.history_search_display_length_ready:
    mov dword ptr [rsp], ebx
    lea rbx, [rip + history_search_query_buffer]
    mov r12d, dword ptr [rip + history_search_cursor]
    cmp r12d, dword ptr [rsp]
    jbe .history_search_display_cursor_ready
    mov r12d, dword ptr [rsp]
.history_search_display_cursor_ready:
    # Ten-pixel left/right inset inside the search field; the right edge
    # remains clear of the separate Browse button.
    mov r15d, dword ptr [rip + window_width]
    sub r15d, 232
    cmp r15d, 1
    ja .history_search_display_width_ready
    mov r15d, 1
.history_search_display_width_ready:
    xor r13d, r13d
    xor r14d, r14d
.history_search_measure_cursor:
    cmp r13d, r12d
    jae .history_search_scroll_start
    movzx edi, byte ptr [rbx + r13]
    call ui_font_advance_pixels
    add r14d, eax
    inc r13d
    jmp .history_search_measure_cursor

.history_search_scroll_start:
    # Drop leading glyphs only until the caret's prefix fits the visible width.
    xor r13d, r13d
.history_search_scroll_start_loop:
    cmp r14d, r15d
    jbe .history_search_scroll_start_ready
    cmp r13d, r12d
    jae .history_search_scroll_start_ready
    movzx edi, byte ptr [rbx + r13]
    call ui_font_advance_pixels
    sub r14d, eax
    inc r13d
    jmp .history_search_scroll_start_loop

.history_search_scroll_start_ready:
    mov dword ptr [rip + history_search_display_start], r13d
    mov dword ptr [rip + history_search_caret_x], 60
    mov byte ptr [rip + history_search_query_display_buffer], 0
    xor r14d, r14d
.history_search_display_loop:
    cmp r13d, dword ptr [rsp]
    jae .history_search_display_done
    cmp r13d, r12d
    jne .history_search_display_measure
    lea eax, [r14d + 60]
    mov dword ptr [rip + history_search_caret_x], eax
.history_search_display_measure:
    movzx edi, byte ptr [rbx + r13]
    call ui_font_advance_pixels
    lea ecx, [r14d + eax]
    cmp ecx, r15d
    ja .history_search_display_done
    mov r14d, ecx
    mov eax, r13d
    sub eax, dword ptr [rip + history_search_display_start]
    mov dl, byte ptr [rbx + r13]
    lea rcx, [rip + history_search_query_display_buffer]
    mov byte ptr [rcx + rax], dl
    inc r13d
    cmp r13d, r12d
    jne .history_search_display_loop
    lea eax, [r14d + 60]
    mov dword ptr [rip + history_search_caret_x], eax
    jmp .history_search_display_loop

.history_search_display_done:
    mov eax, r13d
    sub eax, dword ptr [rip + history_search_display_start]
    lea rdx, [rip + history_search_query_display_buffer]
    mov byte ptr [rdx + rax], 0
    cmp r13d, r12d
    jne .history_search_display_return
    lea eax, [r14d + 60]
    mov dword ptr [rip + history_search_caret_x], eax
.history_search_display_return:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.type render_history_manager, @function
render_history_manager:
    push rbx
    push r12
    push r13
    push r14
    # Main History surface.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 32
    mov edx, 104
    mov eax, dword ptr [rip + window_width]
    sub eax, 64
    mov ecx, eax
    mov r8d, 356
    mov r9d, 0xff1f242d
    call draw_rect

    mov edi, 48
    mov esi, 120
    lea rdx, [rip + ui_history_title]
    call draw_text
    cmp dword ptr [rip + history_open_error], 0
    jne .render_history_header_error
    call history_has_error
    test eax, eax
    jnz .render_history_header_storage_error
    mov edi, 48
    mov esi, 156
    lea rdx, [rip + active_document_name]
    call draw_text
    jmp .render_history_search_box
.render_history_header_error:
    mov edi, 48
    mov esi, 156
    lea rdx, [rip + ui_history_open_error_label]
    call draw_text
    jmp .render_history_search_box
.render_history_header_storage_error:
    mov edi, 48
    mov esi, 156
    lea rdx, [rip + ui_history_storage_error]
    call draw_text

.render_history_search_box:
    # A bordered, wide filter field with a separate Browse action.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 170
    mov eax, dword ptr [rip + window_width]
    sub eax, 208
    mov ecx, eax
    mov r8d, 32
    mov r9d, 0xff526b80
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 50
    mov edx, 172
    mov eax, dword ptr [rip + window_width]
    sub eax, 212
    mov ecx, eax
    mov r8d, 28
    mov r9d, 0xff343d4b
    call draw_rect
    call history_search_prepare_display
    mov edi, 60
    mov esi, 192
    cmp dword ptr [rip + history_search_length], 0
    jne .render_history_search_text
    lea rdx, [rip + ui_history_search_label]
    jmp .render_history_search_draw_text
.render_history_search_text:
    lea rdx, [rip + history_search_query_display_buffer]
.render_history_search_draw_text:
    call draw_text
    cmp dword ptr [rip + history_search_focus], 0
    je .render_history_search_caret_done
    # Visible insertion caret; its x coordinate tracks Left/Right/Home/End.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, dword ptr [rip + history_search_caret_x]
    mov edx, 180
    mov ecx, 1
    mov r8d, 15
    mov r9d, 0xffffffff
    call draw_rect
.render_history_search_caret_done:

    mov rdi, qword ptr [rip + shm_mapping]
    mov eax, dword ptr [rip + window_width]
    sub eax, 144
    mov esi, eax
    mov edx, 170
    mov ecx, 96
    mov r8d, 32
    mov r9d, 0xff414b5a
    call draw_rect
    mov eax, dword ptr [rip + window_width]
    sub eax, 132
    mov edi, eax
    mov esi, 192
    lea rdx, [rip + ui_history_browse_label]
    call draw_text

    mov edi, 48
    mov esi, 216
    lea rdx, [rip + ui_history_results_label]
    call draw_text
    lea rdi, [rip + history_search_query_buffer]
    call history_search_refresh
    call history_search_result_count
    mov dword ptr [rip + history_search_match_count], eax
    test eax, eax
    jnz .render_history_has_matches
    mov dword ptr [rip + history_search_selected], 0
    mov dword ptr [rip + history_search_scroll], 0
    jmp .render_history_rows
.render_history_has_matches:
    mov edx, dword ptr [rip + history_search_selected]
    cmp edx, eax
    jb .render_history_selected_valid
    mov dword ptr [rip + history_search_selected], 0
    xor edx, edx
.render_history_selected_valid:
    mov ecx, dword ptr [rip + history_search_scroll]
    cmp edx, ecx
    jae .render_history_selected_after_top
    mov dword ptr [rip + history_search_scroll], edx
    mov ecx, edx
.render_history_selected_after_top:
    lea ecx, [ecx + 4]
    cmp edx, ecx
    jb .render_history_rows
    lea ecx, [edx - 3]
    mov dword ptr [rip + history_search_scroll], ecx
.render_history_rows:
    xor ebx, ebx
    mov r12d, 224
.render_history_row_loop:
    cmp ebx, 4
    jae .render_history_rows_done
    mov eax, dword ptr [rip + history_search_scroll]
    add eax, ebx
    cmp eax, dword ptr [rip + history_search_match_count]
    jae .render_history_next_row
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, r12d
    mov ecx, dword ptr [rip + window_width]
    sub ecx, 96
    mov r8d, 22
    mov r13d, 0xff303844
    cmp eax, dword ptr [rip + history_search_selected]
    jne .render_history_row_color_ready
    mov r13d, 0xff4b6077
.render_history_row_color_ready:
    mov r9d, r13d
    call draw_rect
    mov eax, dword ptr [rip + history_search_scroll]
    add eax, ebx
    mov edi, eax
    call history_search_display
    test rax, rax
    jz .render_history_next_row
    mov edi, 64
    lea esi, [r12 + 17]
    mov rdx, rax
    call draw_text
.render_history_next_row:
    add r12d, 25
    inc ebx
    jmp .render_history_row_loop
.render_history_rows_done:
    cmp dword ptr [rip + history_search_match_count], 0
    jne .render_history_draw_open
    mov edi, 64
    mov esi, 254
    lea rdx, [rip + ui_history_no_results_label]
    call draw_text

.render_history_draw_open:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 330
    mov ecx, 160
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 62
    mov esi, 349
    lea rdx, [rip + ui_history_open_label]
    call draw_text

    # Keep Undo/Redo counters in their own visible panel, above the action row.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 368
    mov eax, dword ptr [rip + window_width]
    sub eax, 96
    mov ecx, eax
    mov r8d, 30
    mov r9d, 0xff343d4b
    call draw_rect
    mov edi, 60
    mov esi, 390
    lea rdx, [rip + ui_history_undo_count_label]
    call draw_text
    add eax, 8
    mov edi, eax
    mov esi, 390
    call history_undo_count
    call draw_decimal

    mov edi, dword ptr [rip + window_width]
    shr edi, 1
    add edi, 12
    mov esi, 390
    lea rdx, [rip + ui_history_redo_count_label]
    call draw_text
    add eax, 8
    mov edi, eax
    mov esi, 390
    call history_redo_count
    call draw_decimal

    # Four equal-width controls scale with the window instead of using
    # undersized 80-pixel boxes that stopped fitting larger UI fonts.
    mov eax, dword ptr [rip + window_width]
    sub eax, 120
    shr eax, 2
    mov r14d, eax
    mov r12d, 48
    xor ebx, ebx
.render_history_button_loop:
    cmp ebx, 4
    jae .render_history_manager_done
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, 414
    mov ecx, r14d
    mov r8d, 30
    mov r13d, 0xff414b5a
    cmp ebx, 0
    jne .render_history_button_not_undo
    call history_undo_count
    test eax, eax
    jnz .render_history_button_draw
    mov r13d, 0xff343d4b
    jmp .render_history_button_draw
.render_history_button_not_undo:
    cmp ebx, 1
    jne .render_history_button_not_redo
    call history_redo_count
    test eax, eax
    jnz .render_history_button_draw
    mov r13d, 0xff343d4b
    jmp .render_history_button_draw
.render_history_button_not_redo:
    cmp ebx, 3
    jne .render_history_button_draw
    cmp dword ptr [rip + history_search_match_count], 0
    jne .render_history_button_draw
    mov r13d, 0xff343d4b
.render_history_button_draw:
    mov r9d, r13d
    call draw_rect
    lea edi, [r12 + 12]
    mov esi, 434
    cmp ebx, 0
    jne .render_history_label_redo
    lea rdx, [rip + ui_history_undo_label]
    jmp .render_history_label_draw
.render_history_label_redo:
    cmp ebx, 1
    jne .render_history_label_export
    lea rdx, [rip + ui_history_redo_label]
    jmp .render_history_label_draw
.render_history_label_export:
    cmp ebx, 2
    jne .render_history_label_delete
    lea rdx, [rip + ui_history_export_label]
    jmp .render_history_label_draw
.render_history_label_delete:
    lea rdx, [rip + ui_history_delete_label]
.render_history_label_draw:
    call draw_text
    add r12d, r14d
    add r12d, 8
    inc ebx
    jmp .render_history_button_loop
.render_history_manager_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size render_history_manager, . - render_history_manager

.type render_save_confirmation, @function
render_save_confirmation:
    cmp dword ptr [rip + save_confirm_open], 0
    je .render_save_confirmation_done
    push rbx
    push r12
    push r13
    mov eax, dword ptr [rip + window_width]
    sub eax, 432
    shr eax, 1
    mov r12d, eax
    mov eax, dword ptr [rip + window_height]
    sub eax, 120
    shr eax, 1
    mov r13d, eax

    # Centered dialog, retained above either the editor or Save As picker.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, 432
    mov r8d, 120
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, 432
    mov r8d, 28
    mov r9d, 0xff343d4b
    call draw_rect
    lea edi, [r12 + 16]
    lea esi, [r13 + 10]
    cmp dword ptr [rip + save_confirm_action], 3
    jne .render_save_confirm_default_title
    lea rdx, [rip + ui_locale_remove_title]
    jmp .render_save_confirm_title_draw
.render_save_confirm_default_title:
    lea rdx, [rip + ui_save_confirm_title]
.render_save_confirm_title_draw:
    call draw_text
    lea edi, [r12 + 24]
    lea esi, [r13 + 44]
    cmp dword ptr [rip + save_confirm_action], 3
    jne .render_save_confirm_default_message
    lea rdx, [rip + ui_locale_remove_message]
    jmp .render_save_confirm_message_draw
.render_save_confirm_default_message:
    lea rdx, [rip + ui_save_confirm_message]
.render_save_confirm_message_draw:
    call draw_text

    lea esi, [r12 + 64]
    lea edx, [r13 + 78]
    mov rdi, qword ptr [rip + shm_mapping]
    mov ecx, 136
    mov r8d, 28
    mov r9d, 0xff526b55
    call draw_rect
    lea esi, [r12 + 232]
    lea edx, [r13 + 78]
    mov rdi, qword ptr [rip + shm_mapping]
    mov ecx, 136
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    lea edi, [r12 + 112]
    lea esi, [r13 + 88]
    cmp dword ptr [rip + save_confirm_action], 3
    jne .render_save_confirm_default_action
    lea rdx, [rip + ui_locale_remove_label]
    jmp .render_save_confirm_action_draw
.render_save_confirm_default_action:
    lea rdx, [rip + ui_save_confirm_save_label]
.render_save_confirm_action_draw:
    call draw_text
    lea edi, [r12 + 276]
    lea esi, [r13 + 88]
    lea rdx, [rip + ui_save_confirm_cancel_label]
    call draw_text

    pop r13
    pop r12
    pop rbx
.render_save_confirmation_done:
    ret
.size render_save_confirmation, . - render_save_confirmation

.type render_find_replace, @function
render_find_replace:
    cmp dword ptr [rip + find_replace_mode], 0
    je .render_find_replace_done
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov dword ptr [rip + ui_transform_active], 1
    mov eax, dword ptr [rip + find_ui_font_size]
    mov dword ptr [rip + ui_transform_font_size], eax
    mov dword ptr [rip + ui_transform_base_x], 0
    mov dword ptr [rip + ui_transform_base_y], 0
    mov eax, dword ptr [rip + find_panel_x]
    mov dword ptr [rip + ui_transform_origin_x], eax
    mov eax, dword ptr [rip + find_panel_y]
    mov dword ptr [rip + ui_transform_origin_y], eax
    mov eax, dword ptr [rip + find_panel_width]
    mov dword ptr [rip + ui_transform_x_num], eax
    mov dword ptr [rip + ui_transform_x_den], 448
    mov eax, dword ptr [rip + find_panel_height]
    mov dword ptr [rip + ui_transform_y_num], eax
    mov dword ptr [rip + ui_transform_y_den], 192
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, 448
    mov r8d, 192
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    xor esi, esi
    xor edx, edx
    mov ecx, 448
    mov r8d, 32
    mov r9d, 0xff343d4b
    call draw_rect
    cmp dword ptr [rip + find_replace_mode], 2
    jne .render_find_title
    mov edi, 16
    mov esi, 10
    lea rdx, [rip + ui_replace_title]
    call draw_text
    jmp .render_find_field
.render_find_title:
    mov edi, 16
    mov esi, 10
    lea rdx, [rip + ui_find_title]
    call draw_text
.render_find_field:
    mov edi, 20
    mov esi, 55
    lea rdx, [rip + ui_find_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 84
    mov edx, 44
    mov ecx, 340
    mov r8d, 32
    mov r9d, 0xff252a33
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 84
    mov edx, 74
    mov ecx, 340
    mov r8d, 2
    cmp dword ptr [rip + find_replace_focus], 0
    jne .render_find_field_border
    mov r9d, 0xff78a9d4
    jmp .render_find_field_border_draw
.render_find_field_border:
    mov r9d, 0xff596273
.render_find_field_border_draw:
    call draw_rect
    cmp dword ptr [rip + find_field_select_all], 0
    je .render_find_text
    cmp dword ptr [rip + find_replace_focus], 0
    jne .render_find_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 88
    mov edx, 48
    mov ecx, 332
    mov r8d, 24
    mov r9d, 0xff5e81ac
    call draw_rect
.render_find_text:
    lea rdi, [rip + find_query_buffer]
    mov esi, dword ptr [rip + find_query_cursor]
    mov edx, 332
    call find_field_view_start
    mov r12d, eax
    lea rdi, [rip + find_query_buffer]
    add rdi, r12
    mov esi, dword ptr [rip + find_query_cursor]
    sub esi, r12d
    call find_measure_ascii_prefix
    mov r13d, eax
    lea rdx, [rip + find_query_buffer]
    add rdx, r12
    mov edi, 92
    mov esi, 52
    mov ecx, 332
    call draw_bounded_ascii_width
    cmp dword ptr [rip + find_field_select_all], 0
    jne .render_find_query_caret_done
    cmp dword ptr [rip + find_replace_focus], 0
    jne .render_find_query_caret_done
    mov rdi, qword ptr [rip + shm_mapping]
    lea esi, [r13 + 92]
    mov edx, 48
    mov ecx, 1
    mov r8d, 20
    mov r9d, 0xffd8dee9
    call draw_rect
.render_find_query_caret_done:
    cmp dword ptr [rip + find_replace_mode], 2
    jne .render_find_status
    mov edi, 20
    mov esi, 99
    lea rdx, [rip + ui_replace_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 84
    mov edx, 88
    mov ecx, 340
    mov r8d, 32
    mov r9d, 0xff252a33
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 84
    mov edx, 118
    mov ecx, 340
    mov r8d, 2
    cmp dword ptr [rip + find_replace_focus], 1
    jne .render_replace_field_border
    mov r9d, 0xff78a9d4
    jmp .render_replace_field_border_draw
.render_replace_field_border:
    mov r9d, 0xff596273
.render_replace_field_border_draw:
    call draw_rect
    cmp dword ptr [rip + find_field_select_all], 0
    je .render_replace_text
    cmp dword ptr [rip + find_replace_focus], 1
    jne .render_replace_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 88
    mov edx, 92
    mov ecx, 332
    mov r8d, 24
    mov r9d, 0xff5e81ac
    call draw_rect
.render_replace_text:
    lea rdi, [rip + find_replacement_buffer]
    mov esi, dword ptr [rip + find_replacement_cursor]
    mov edx, 332
    call find_field_view_start
    mov r12d, eax
    lea rdi, [rip + find_replacement_buffer]
    add rdi, r12
    mov esi, dword ptr [rip + find_replacement_cursor]
    sub esi, r12d
    call find_measure_ascii_prefix
    mov r13d, eax
    lea rdx, [rip + find_replacement_buffer]
    add rdx, r12
    mov edi, 92
    mov esi, 96
    mov ecx, 332
    call draw_bounded_ascii_width
    cmp dword ptr [rip + find_field_select_all], 0
    jne .render_find_replace_caret_done
    cmp dword ptr [rip + find_replace_focus], 1
    jne .render_find_replace_caret_done
    mov rdi, qword ptr [rip + shm_mapping]
    lea esi, [r13 + 92]
    mov edx, 92
    mov ecx, 1
    mov r8d, 20
    mov r9d, 0xffd8dee9
    call draw_rect
.render_find_replace_caret_done:
.render_find_status:
    mov eax, dword ptr [rip + find_status]
    test eax, eax
    jz .render_find_status_empty
    cmp eax, 1
    je .render_find_status_match
    cmp eax, 2
    je .render_find_status_none
    cmp eax, 3
    je .render_find_status_replaced
    lea rdx, [rip + ui_find_all_label]
    jmp .render_find_status_draw
.render_find_status_match:
    lea rdx, [rip + ui_find_match_label]
    jmp .render_find_status_draw
.render_find_status_none:
    lea rdx, [rip + ui_find_none_label]
    jmp .render_find_status_draw
.render_find_status_replaced:
    lea rdx, [rip + ui_find_replaced_label]
    jmp .render_find_status_draw
.render_find_status_empty:
    lea rdx, [rip + ui_find_empty_label]
.render_find_status_draw:
    mov edi, 20
    mov esi, 137
    call draw_text
    # Buttons share a single row and the same transform as the text fields.
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 16
    mov edx, 150
    mov ecx, 72
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 34
    mov esi, 158
    lea rdx, [rip + ui_find_prev_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 96
    mov edx, 150
    mov ecx, 72
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 118
    mov esi, 158
    lea rdx, [rip + ui_find_next_label]
    call draw_text
    cmp dword ptr [rip + find_replace_mode], 2
    jne .render_find_close_button
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 184
    mov edx, 150
    mov ecx, 88
    mov r8d, 28
    mov r9d, 0xff526b55
    call draw_rect
    mov edi, 194
    mov esi, 158
    lea rdx, [rip + ui_replace_one_label]
    call draw_text
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 280
    mov edx, 150
    mov ecx, 72
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 304
    mov esi, 158
    lea rdx, [rip + ui_replace_all_label]
    call draw_text
.render_find_close_button:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 368
    mov edx, 150
    mov ecx, 64
    mov r8d, 28
    mov r9d, 0xff414b5a
    call draw_rect
    mov edi, 376
    mov esi, 158
    lea rdx, [rip + ui_find_close_label]
    call draw_text
    mov dword ptr [rip + ui_transform_active], 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
.render_find_replace_done:
    ret
.size render_find_replace, . - render_find_replace

.type render_path_prompt, @function
render_path_prompt:
    cmp dword ptr [rip + path_prompt_mode], 0
    je .render_path_prompt_done
    push rbp
    push rbx
    push r12
    push r13
    push r14
    # Configure a centered, width/height-fitted drawing transform for the
    # original 704x176 prompt design (48,148)-(752,324).
    mov dword ptr [rip + ui_transform_active], 1
    mov eax, dword ptr [rip + path_prompt_font_size]
    mov dword ptr [rip + ui_transform_font_size], eax
    mov dword ptr [rip + ui_transform_base_x], 48
    mov dword ptr [rip + ui_transform_base_y], 148
    mov eax, dword ptr [rip + path_prompt_x]
    mov dword ptr [rip + ui_transform_origin_x], eax
    mov eax, dword ptr [rip + path_prompt_y]
    mov dword ptr [rip + ui_transform_origin_y], eax
    mov eax, dword ptr [rip + path_prompt_width]
    mov dword ptr [rip + ui_transform_x_num], eax
    mov dword ptr [rip + ui_transform_x_den], 704
    mov eax, dword ptr [rip + path_prompt_height]
    mov dword ptr [rip + ui_transform_y_num], eax
    mov dword ptr [rip + ui_transform_y_den], 176
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 148
    mov ecx, 704
    mov r8d, 176
    mov r9d, 0xff1f242d
    call draw_rect
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 48
    mov edx, 148
    mov ecx, 704
    mov r8d, 32
    mov r9d, 0xff343d4b
    call draw_rect
    cmp dword ptr [rip + path_prompt_mode], 1
    jne .render_path_prompt_save_title
    mov edi, 72
    mov esi, 160
    lea rdx, [rip + ui_prompt_open_title]
    call draw_text
    jmp .render_path_prompt_entry
.render_path_prompt_save_title:
    mov edi, 72
    mov esi, 160
    lea rdx, [rip + ui_prompt_save_title]
    call draw_text
.render_path_prompt_entry:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, 72
    mov edx, 204
    mov ecx, 656
    mov r8d, 36
    mov r9d, 0xff252a33
    call draw_rect

    # Retain the widest suffix that fits the prompt's 608-pixel text viewport.
    # Walking backward by hmtx advances keeps the caret visible for long paths.
    lea rbx, [rip + path_prompt_buffer]
    mov r14d, dword ptr [rip + path_prompt_length]
    xor r13d, r13d
.render_path_prompt_find_start:
    test r14d, r14d
    jz .render_path_prompt_start_ready
    mov eax, r14d
    dec eax
    movzx edi, byte ptr [rbx + rax]
    cmp edi, 32
    jb .render_path_prompt_find_replacement
    cmp edi, 126
    jbe .render_path_prompt_find_advance
.render_path_prompt_find_replacement:
    mov edi, '?'
.render_path_prompt_find_advance:
    call ui_font_advance_pixels
    lea edx, [r13d + eax]
    cmp edx, 608
    ja .render_path_prompt_start_ready
    mov r13d, edx
    dec r14d
    jmp .render_path_prompt_find_start
.render_path_prompt_start_ready:
    lea rbx, [rip + path_prompt_buffer]
    add rbx, r14
    mov r12d, r14d
    mov r13d, 96
.render_path_prompt_chars:
    cmp r12d, dword ptr [rip + path_prompt_length]
    jae .render_path_prompt_caret
    movzx ebp, byte ptr [rbx]
    test ebp, ebp
    jz .render_path_prompt_caret
    cmp ebp, 32
    jb .render_path_prompt_char_replacement
    cmp ebp, 126
    jbe .render_path_prompt_char_ready
.render_path_prompt_char_replacement:
    mov ebp, '?'
.render_path_prompt_char_ready:
    mov edi, r13d
    mov esi, 218
    mov edx, ebp
    mov ecx, dword ptr [rip + ui_transform_font_size]
    call draw_glyph
    mov edi, ebp
    call ui_font_advance_pixels
    add r13d, eax
    inc rbx
    inc r12d
    jmp .render_path_prompt_chars
.render_path_prompt_caret:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r13d
    mov edx, 216
    mov ecx, 1
    mov r8d, 12
    mov r9d, 0xffffffff
    call draw_rect
    mov edi, 72
    mov esi, 264
    lea rdx, [rip + ui_prompt_help]
    call draw_text
    mov dword ptr [rip + ui_transform_active], 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
.render_path_prompt_done:
    ret
.size render_path_prompt, . - render_path_prompt


# Clip selection rectangles to the text viewport. Arguments follow draw_rect.
.type draw_document_selection_rect, @function
draw_document_selection_rect:
    push rbx
    movsxd rbx, esi
    movsxd r10, ecx
    add r10, rbx
    cmp r10, DOC_LEFT
    jle .Ldoc_selection_rect_done
    cmp rbx, DOC_LEFT
    jge .Ldoc_selection_rect_left_ready
    mov eax, DOC_LEFT
    sub rax, rbx
    sub ecx, eax
    mov esi, DOC_LEFT
    mov rbx, DOC_LEFT
.Ldoc_selection_rect_left_ready:
    mov eax, DOC_LEFT
    add eax, dword ptr [rip + window_doc_pixel_width]
    movsxd r11, eax
    cmp rbx, r11
    jae .Ldoc_selection_rect_done
    cmp r10, r11
    jbe .Ldoc_selection_rect_draw
    mov eax, r11d
    sub eax, esi
    mov ecx, eax
.Ldoc_selection_rect_draw:
    test ecx, ecx
    jle .Ldoc_selection_rect_done
    call draw_rect
.Ldoc_selection_rect_done:
    pop rbx
    ret
.size draw_document_selection_rect, . - draw_document_selection_rect

# Paint every literal query occurrence in the document. The active match is
# subsequently overpainted by render_selection, so the current result remains
# visually distinct while all other occurrences stay highlighted.
.type render_find_highlights, @function
render_find_highlights:
    cmp dword ptr [rip + find_replace_mode], 0
    je .Lrender_find_highlights_done
    cmp dword ptr [rip + find_query_length], 0
    je .Lrender_find_highlights_done
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32
    mov r14d, dword ptr [rip + find_query_length]
    xor r12d, r12d
.Lrender_find_highlights_next_match:
    # Start one byte after the previous result so overlapping occurrences
    # are highlighted too. A wrapped result below the scan point ends the pass.
    mov edi, r12d
    mov esi, 1
    call doc_find_match
    test eax, eax
    js .Lrender_find_highlights_finish
    cmp eax, r12d
    jb .Lrender_find_highlights_finish
    mov r13d, eax
    lea r12d, [rax + 1]
    xor r15d, r15d
.Lrender_find_highlights_match_bytes:
    cmp r15d, r14d
    jae .Lrender_find_highlights_next_match
    mov eax, r13d
    add eax, r15d
    mov dword ptr [rsp], eax
    mov edi, eax
    call doc_offset_to_visual
    mov dword ptr [rsp + 4], eax
    mov dword ptr [rsp + 8], edx
    # Find currently accepts ASCII keymap text, so each query byte is one
    # document glyph; use the active font's real proportional advance.
    mov edi, dword ptr [rsp]
    call doc_byte_at
    mov edi, eax
    call font_codepoint_advance_pixels
    mov dword ptr [rsp + 12], eax

    mov eax, dword ptr [rsp + 4]
    sub eax, dword ptr [rip + doc_view_top_row]
    test eax, eax
    js .Lrender_find_highlights_advance
    cmp eax, dword ptr [rip + window_doc_visible_rows]
    jae .Lrender_find_highlights_advance
    imul eax, dword ptr [rip + window_doc_line_height]
    add eax, DOC_TOP
    mov dword ptr [rsp + 16], eax

    mov eax, dword ptr [rsp + 8]
    add eax, DOC_LEFT
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Lrender_find_highlights_x_ready
    sub eax, dword ptr [rip + doc_view_left_px]
.Lrender_find_highlights_x_ready:
    mov dword ptr [rsp + 20], eax

    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, dword ptr [rsp + 20]
    mov edx, dword ptr [rsp + 16]
    mov ecx, dword ptr [rsp + 12]
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff8f7834
    call draw_document_selection_rect
.Lrender_find_highlights_advance:
    inc r15d
    jmp .Lrender_find_highlights_match_bytes

.Lrender_find_highlights_finish:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
.Lrender_find_highlights_done:
    ret
.size render_find_highlights, . - render_find_highlights

# Paint selected document cells before glyphs and the caret are rendered.
.type render_selection, @function
render_selection:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + doc_selection_active], 0
    je .Lneko_render_selection_done
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .Lneko_render_selection_unwrapped

    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lneko_render_selection_bounds
    xchg eax, edx
.Lneko_render_selection_bounds:
    mov dword ptr [rip + doc_selection_start], eax
    mov dword ptr [rip + doc_selection_end], edx

    # Render in the same pixel coordinate space used by hmtx layout and hit-testing.
    mov r12d, DOC_LEFT
    mov r13d, DOC_TOP
    mov eax, dword ptr [rip + doc_view_top_row]
    imul eax, dword ptr [rip + window_doc_line_height]
    sub r13d, eax
    xor r14d, r14d
.Lneko_render_selection_scan:
    cmp r14d, dword ptr [rip + doc_length]
    jae .Lneko_render_selection_done
    mov eax, dword ptr [rip + doc_selection_end]
    cmp r14d, eax
    jae .Lneko_render_selection_done

    mov edi, r14d
    call doc_byte_at
    mov ebx, eax
    cmp ebx, 10
    je .Lneko_render_selection_newline
    cmp ebx, 13
    jne .Lneko_render_selection_not_cr
    lea edi, [r14d + 1]
    call doc_byte_at
    cmp eax, 10
    je .Lneko_render_selection_newline
.Lneko_render_selection_not_cr:
    cmp ebx, 9
    je .Lneko_render_selection_tab
    cmp ebx, 32
    jb .Lneko_render_selection_control
    cmp ebx, 128
    jb .Lneko_render_selection_character
    mov edi, r14d
    call doc_utf8_decode_at
    mov ebx, eax
.Lneko_render_selection_character:
    mov edi, ebx
    call font_codepoint_advance_pixels
    mov r15d, eax
    mov eax, r12d
    sub eax, DOC_LEFT
    add eax, r15d
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_render_selection_character_fit
    mov r12d, DOC_LEFT
    add r13d, dword ptr [rip + window_doc_line_height]
.Lneko_render_selection_character_fit:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_character_advance
    cmp r13d, DOC_TOP
    jl .Lneko_render_selection_character_advance
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r13d, eax
    jae .Lneko_render_selection_character_advance
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r15d
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_character_advance:
    add r12d, r15d
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_tab:
    # Tabs advance to the next 32-pixel stop, wrapping as one visual token.
    mov eax, r12d
    sub eax, DOC_LEFT
    lea edx, [eax + 32]
    and edx, -32
    sub edx, eax
    mov r15d, edx
    add eax, r15d
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .Lneko_render_selection_tab_fit
    mov r12d, DOC_LEFT
    add r13d, dword ptr [rip + window_doc_line_height]
    mov r15d, 32
.Lneko_render_selection_tab_fit:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_tab_advance
    cmp r13d, DOC_TOP
    jl .Lneko_render_selection_tab_advance
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r13d, eax
    jae .Lneko_render_selection_tab_advance
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r15d
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_tab_advance:
    add r12d, r15d
    inc r14d
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_newline:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r14d, eax
    jb .Lneko_render_selection_newline_advance
    cmp r13d, DOC_TOP
    jl .Lneko_render_selection_newline_advance
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r13d, eax
    jae .Lneko_render_selection_newline_advance
    mov eax, r12d
    sub eax, DOC_LEFT
    mov edx, dword ptr [rip + window_doc_pixel_width]
    sub edx, eax
    test edx, edx
    jle .Lneko_render_selection_newline_advance
    cmp edx, 8
    jbe .Lneko_render_selection_newline_width_ready
    mov edx, 8
.Lneko_render_selection_newline_width_ready:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov ecx, edx
    mov edx, r13d
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_rect
.Lneko_render_selection_newline_advance:
    mov r12d, DOC_LEFT
    add r13d, dword ptr [rip + window_doc_line_height]
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_control:
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Lneko_render_selection_scan

.Lneko_render_selection_unwrapped:
    call render_selection_unwrapped
    jmp .Lneko_render_selection_done

.Lneko_render_selection_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret


# Paint selected bytes in no-wrap mode using absolute line-pixel columns.
.type render_selection_unwrapped, @function
render_selection_unwrapped:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov eax, dword ptr [rip + doc_selection_anchor]
    mov edx, dword ptr [rip + doc_cursor]
    cmp eax, edx
    jbe .Lselection_unwrapped_bounds
    xchg eax, edx
.Lselection_unwrapped_bounds:
    mov dword ptr [rip + doc_selection_start], eax
    mov dword ptr [rip + doc_selection_end], edx
    xor r12d, r12d
    mov r13d, DOC_LEFT
    sub r13d, dword ptr [rip + doc_view_left_px]
    mov r14d, DOC_TOP
    mov eax, dword ptr [rip + doc_view_top_row]
    imul eax, dword ptr [rip + window_doc_line_height]
    sub r14d, eax
.Lselection_unwrapped_scan:
    cmp r12d, dword ptr [rip + doc_length]
    jae .Lselection_unwrapped_done
    mov eax, dword ptr [rip + doc_selection_end]
    cmp r12d, eax
    jae .Lselection_unwrapped_done
    mov edi, r12d
    call doc_byte_at
    mov ebx, eax
    cmp ebx, 10
    je .Lselection_unwrapped_newline
    cmp ebx, 13
    jne .Lselection_unwrapped_not_cr
    lea edi, [r12d + 1]
    call doc_byte_at
    cmp eax, 10
    je .Lselection_unwrapped_newline
.Lselection_unwrapped_not_cr:
    cmp ebx, 9
    je .Lselection_unwrapped_tab
    cmp ebx, 32
    jb .Lselection_unwrapped_control
    cmp ebx, 128
    jb .Lselection_unwrapped_character
    mov edi, r12d
    call doc_utf8_decode_at
    mov ebx, eax
.Lselection_unwrapped_character:
    mov edi, ebx
    call font_codepoint_advance_pixels
    mov r15d, eax
    jmp .Lselection_unwrapped_paint
.Lselection_unwrapped_tab:
    mov eax, r13d
    sub eax, DOC_LEFT
    add eax, dword ptr [rip + doc_view_left_px]
    lea edx, [eax + 32]
    and edx, -32
    sub edx, eax
    mov r15d, edx
.Lselection_unwrapped_paint:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r12d, eax
    jb .Lselection_unwrapped_advance
    cmp r14d, DOC_TOP
    jl .Lselection_unwrapped_advance
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r14d, eax
    jae .Lselection_unwrapped_advance
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r13d
    mov edx, r14d
    mov ecx, r15d
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_document_selection_rect
.Lselection_unwrapped_advance:
    add r13d, r15d
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Lselection_unwrapped_scan
.Lselection_unwrapped_newline:
    mov eax, dword ptr [rip + doc_selection_start]
    cmp r12d, eax
    jb .Lselection_unwrapped_newline_next
    cmp r14d, DOC_TOP
    jl .Lselection_unwrapped_newline_next
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r14d, eax
    jae .Lselection_unwrapped_newline_next
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r13d
    mov edx, r14d
    mov ecx, 8
    mov r8d, dword ptr [rip + window_doc_line_height]
    mov r9d, 0xff5e81ac
    call draw_document_selection_rect
.Lselection_unwrapped_newline_next:
    mov r13d, DOC_LEFT
    sub r13d, dword ptr [rip + doc_view_left_px]
    add r14d, dword ptr [rip + window_doc_line_height]
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Lselection_unwrapped_scan
.Lselection_unwrapped_control:
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Lselection_unwrapped_scan
.Lselection_unwrapped_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size render_selection_unwrapped, . - render_selection_unwrapped

# ASCII alphanumerics/underscore and non-ASCII scalars form word runs.
# Keeping Unicode scripts together is preferable to splitting multibyte words.
.type doc_codepoint_is_word, @function
doc_codepoint_is_word:
    cmp edi, '0'
    jb .Ldoc_word_non_ascii
    cmp edi, '9'
    jbe .Ldoc_word_yes
    cmp edi, 'A'
    jb .Ldoc_word_ascii_other
    cmp edi, 'Z'
    jbe .Ldoc_word_yes
    cmp edi, 'a'
    jb .Ldoc_word_ascii_other
    cmp edi, 'z'
    jbe .Ldoc_word_yes
.Ldoc_word_ascii_other:
    cmp edi, '_'
    je .Ldoc_word_yes
    cmp edi, 128
    jb .Ldoc_word_no
.Ldoc_word_non_ascii:
    cmp edi, 128
    jb .Ldoc_word_no
    cmp edi, 0x10ffff
    ja .Ldoc_word_no
.Ldoc_word_yes:
    mov eax, 1
    ret
.Ldoc_word_no:
    xor eax, eax
    ret
.size doc_codepoint_is_word, . - doc_codepoint_is_word

# EDI=0: previous word start. EDI=1: next word start.
.type doc_move_word, @function
doc_move_word:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, dword ptr [rip + doc_cursor]
    mov r13d, edi
    test r13d, r13d
    jnz .Ldoc_move_word_right
    xor r14d, r14d
.Ldoc_move_word_left_loop:
    test r12d, r12d
    jz .Ldoc_move_word_store
    mov edi, r12d
    call doc_grapheme_prev
    mov r15d, eax
    mov edi, r15d
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test r14d, r14d
    jnz .Ldoc_move_word_left_in_word
    mov r12d, r15d
    test eax, eax
    jnz .Ldoc_move_word_left_found_word
    jmp .Ldoc_move_word_left_loop
.Ldoc_move_word_left_found_word:
    mov r14d, 1
    jmp .Ldoc_move_word_left_loop
.Ldoc_move_word_left_in_word:
    test eax, eax
    jz .Ldoc_move_word_store
    mov r12d, r15d
    jmp .Ldoc_move_word_left_loop
.Ldoc_move_word_right:
    xor r14d, r14d
.Ldoc_move_word_right_loop:
    cmp r12d, dword ptr [rip + doc_length]
    jae .Ldoc_move_word_store
    mov edi, r12d
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test r14d, r14d
    jnz .Ldoc_move_word_right_in_word
    test eax, eax
    jz .Ldoc_move_word_right_separator
    mov r14d, 1
    jmp .Ldoc_move_word_right_advance
.Ldoc_move_word_right_separator:
    mov r14d, 2
    jmp .Ldoc_move_word_right_advance
.Ldoc_move_word_right_in_word:
    cmp r14d, 1
    jne .Ldoc_move_word_right_after_word
    test eax, eax
    jnz .Ldoc_move_word_right_advance
    mov r14d, 2
    jmp .Ldoc_move_word_right_advance
.Ldoc_move_word_right_after_word:
    test eax, eax
    jnz .Ldoc_move_word_store
.Ldoc_move_word_right_advance:
    mov edi, r12d
    call doc_grapheme_next
    mov r12d, eax
    jmp .Ldoc_move_word_right_loop
.Ldoc_move_word_store:
    mov dword ptr [rip + doc_cursor], r12d
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_move_word, . - doc_move_word

# EDI=0 previous logical line start; EDI=1 next logical line start.
# This is a paragraph-style move: wrapped visual rows are not treated as lines.
.type doc_move_line, @function
doc_move_line:
    push rbx
    push r12
    push r13
    mov r12d, dword ptr [rip + doc_cursor]
    mov r13d, edi
    test r13d, r13d
    jz .Ldoc_move_line_previous
.Ldoc_move_line_next:
    cmp r12d, dword ptr [rip + doc_length]
    jae .Ldoc_move_line_store
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_move_line_next_found
    inc r12d
    jmp .Ldoc_move_line_next
.Ldoc_move_line_next_found:
    inc r12d
    jmp .Ldoc_move_line_store
.Ldoc_move_line_previous:
    test r12d, r12d
    jz .Ldoc_move_line_store
    dec r12d
.Ldoc_move_line_find_current_start:
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_move_line_current_start_found
    test r12d, r12d
    jz .Ldoc_move_line_at_document_start
    dec r12d
    jmp .Ldoc_move_line_find_current_start
.Ldoc_move_line_current_start_found:
    test r12d, r12d
    jz .Ldoc_move_line_at_document_start
    dec r12d
.Ldoc_move_line_find_previous_start:
    mov edi, r12d
    call doc_byte_at
    cmp eax, 10
    je .Ldoc_move_line_previous_start_found
    test r12d, r12d
    jz .Ldoc_move_line_at_document_start
    dec r12d
    jmp .Ldoc_move_line_find_previous_start
.Ldoc_move_line_previous_start_found:
    inc r12d
    jmp .Ldoc_move_line_store
.Ldoc_move_line_at_document_start:
    xor r12d, r12d
.Ldoc_move_line_store:
    mov dword ptr [rip + doc_cursor], r12d
    pop r13
    pop r12
    pop rbx
    ret
.size doc_move_line, . - doc_move_line

# Double-click word selection. A click landing just after a word is associated
# with the preceding word, matching the pointer's nearest-boundary hit test.
.type doc_select_word_at_cursor, @function
doc_select_word_at_cursor:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, dword ptr [rip + doc_cursor]
    mov r13d, r12d                 # Preserve raw pointer offset for drag direction.
    cmp r12d, dword ptr [rip + doc_length]
    jb .Ldoc_select_word_probe
    test r12d, r12d
    jz .Ldoc_select_word_empty
    mov edi, r12d
    call doc_grapheme_prev
    mov r12d, eax
    jmp .Ldoc_select_word_probe
.Ldoc_select_word_empty:
    mov dword ptr [rip + doc_selection_active], 0
    jmp .Ldoc_select_word_done
.Ldoc_select_word_probe:
    mov edi, r12d
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test eax, eax
    jnz .Ldoc_select_word_is_word
    test r12d, r12d
    jz .Ldoc_select_word_single
    mov edi, r12d
    call doc_grapheme_prev
    mov ebx, eax
    mov edi, ebx
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test eax, eax
    jz .Ldoc_select_word_single
    mov r12d, ebx
.Ldoc_select_word_is_word:
    mov r14d, r12d
    mov edi, r12d
    call doc_grapheme_next
    mov r15d, eax
.Ldoc_select_word_left:
    test r14d, r14d
    jz .Ldoc_select_word_right
    mov edi, r14d
    call doc_grapheme_prev
    mov ebx, eax
    mov edi, ebx
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test eax, eax
    jz .Ldoc_select_word_right
    mov r14d, ebx
    jmp .Ldoc_select_word_left
.Ldoc_select_word_right:
    cmp r15d, dword ptr [rip + doc_length]
    jae .Ldoc_select_word_store
    mov edi, r15d
    call doc_utf8_decode_at
    mov edi, eax
    call doc_codepoint_is_word
    test eax, eax
    jz .Ldoc_select_word_store
    mov edi, r15d
    call doc_grapheme_next
    mov r15d, eax
    jmp .Ldoc_select_word_right
.Ldoc_select_word_single:
    mov r14d, r12d
    mov edi, r12d
    call doc_grapheme_next
    mov r15d, eax
.Ldoc_select_word_store:
    cmp dword ptr [rip + doc_word_drag_active], 1
    jne .Ldoc_select_word_store_initial
    mov eax, dword ptr [rip + doc_word_drag_start]
    cmp r13d, eax
    jb .Ldoc_select_word_store_reverse
    # Forward drag: preserve the original word's left edge and extend to the
    # end of the word currently under the pointer.
    mov dword ptr [rip + doc_selection_anchor], eax
    mov dword ptr [rip + doc_cursor], r15d
    jmp .Ldoc_select_word_store_active
.Ldoc_select_word_store_reverse:
    # Reverse drag: preserve the original word's right edge and move the
    # active cursor to the start of the word under the pointer.
    mov eax, dword ptr [rip + doc_word_drag_end]
    mov dword ptr [rip + doc_selection_anchor], eax
    mov dword ptr [rip + doc_cursor], r14d
    jmp .Ldoc_select_word_store_active
.Ldoc_select_word_store_initial:
    mov dword ptr [rip + doc_selection_anchor], r14d
    mov dword ptr [rip + doc_cursor], r15d
.Ldoc_select_word_store_active:
    mov dword ptr [rip + doc_selection_active], 1
.Ldoc_select_word_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size doc_select_word_at_cursor, . - doc_select_word_at_cursor

# Decode one validated UTF-8 scalar at a logical document byte offset.
# EDI=offset; EAX=Unicode scalar, or '?' for malformed/truncated input.
.type doc_utf8_decode_at, @function
doc_utf8_decode_at:
    push rbx
    push r12
    push r13
    mov r12d, edi
    call doc_byte_at
    mov r13d, eax
    cmp eax, 0x80
    jb .Lutf8_decode_return
    cmp eax, 0xc2
    jb .Lutf8_decode_invalid
    cmp eax, 0xe0
    jb .Lutf8_decode_two
    cmp eax, 0xf0
    jb .Lutf8_decode_three
    cmp eax, 0xf4
    ja .Lutf8_decode_invalid

    # Four-byte sequence, with the Unicode scalar upper/lower bounds.
    mov edi, r12d
    inc edi
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    cmp r13d, 0xf0
    jne .Lutf8_decode_four_f4
    cmp eax, 0x90
    jb .Lutf8_decode_invalid
    jmp .Lutf8_decode_four_more
.Lutf8_decode_four_f4:
    cmp r13d, 0xf4
    jne .Lutf8_decode_four_more
    cmp eax, 0x8f
    ja .Lutf8_decode_invalid
.Lutf8_decode_four_more:
    and eax, 0x3f
    mov ebx, r13d
    and ebx, 7
    shl ebx, 6
    or ebx, eax
    mov edi, r12d
    add edi, 2
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    and eax, 0x3f
    shl ebx, 6
    or ebx, eax
    mov edi, r12d
    add edi, 3
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    and eax, 0x3f
    shl ebx, 6
    or ebx, eax
    mov eax, ebx
    jmp .Lutf8_decode_return

.Lutf8_decode_three:
    mov edi, r12d
    inc edi
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    cmp r13d, 0xe0
    jne .Lutf8_decode_three_ed
    cmp eax, 0xa0
    jb .Lutf8_decode_invalid
    jmp .Lutf8_decode_three_more
.Lutf8_decode_three_ed:
    cmp r13d, 0xed
    jne .Lutf8_decode_three_more
    cmp eax, 0x9f
    ja .Lutf8_decode_invalid
.Lutf8_decode_three_more:
    and eax, 0x3f
    mov ebx, r13d
    and ebx, 0x0f
    shl ebx, 6
    or ebx, eax
    mov edi, r12d
    add edi, 2
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    and eax, 0x3f
    shl ebx, 6
    or ebx, eax
    mov eax, ebx
    jmp .Lutf8_decode_return

.Lutf8_decode_two:
    mov edi, r12d
    inc edi
    call doc_byte_at
    cmp eax, 0x80
    jb .Lutf8_decode_invalid
    cmp eax, 0xbf
    ja .Lutf8_decode_invalid
    and eax, 0x3f
    mov ebx, r13d
    and ebx, 0x1f
    shl ebx, 6
    or ebx, eax
    mov eax, ebx
    jmp .Lutf8_decode_return
.Lutf8_decode_invalid:
    mov eax, '?'
.Lutf8_decode_return:
    pop r13
    pop r12
    pop rbx
    ret
.size doc_utf8_decode_at, . - doc_utf8_decode_at

.type render_document, @function
.type render_document, @function
render_document:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, DOC_LEFT
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldocument_render_origin_ready
    sub r12d, dword ptr [rip + doc_view_left_px]
.Ldocument_render_origin_ready:
    mov edi, dword ptr [rip + doc_view_top_row]
    xor esi, esi
    call doc_visual_to_offset
    mov r14d, eax
    mov r13d, DOC_TOP
.Ldocument_render_loop:
    cmp r14d, dword ptr [rip + doc_length]
    jae .document_draw_cursor
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r13d, eax
    jge .document_draw_cursor
    mov edi, r14d
    call doc_byte_at
    mov edx, eax
    cmp edx, 10
    je .document_newline
    cmp edx, 9
    je .document_tab
    cmp edx, 32
    jb .document_control
    cmp edx, 127
    jb .document_printable
.document_control:
    cmp edx, 128
    jb .document_next_byte
    mov edi, r14d
    call doc_utf8_decode_at
    mov edx, eax
.document_printable:
    mov ebx, edx
    mov edi, ebx
    call font_codepoint_advance_pixels
    mov r15d, eax
    lea eax, [r12d + r15d]
    mov edx, DOC_LEFT
    add edx, dword ptr [rip + window_doc_pixel_width]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    je .document_printable_fit
    cmp eax, edx
    jbe .document_printable_fit
    mov r12d, DOC_LEFT
    add r13d, dword ptr [rip + window_doc_line_height]
    mov eax, dword ptr [rip + window_doc_bottom]
    sub eax, dword ptr [rip + window_doc_line_height]
    cmp r13d, eax
    jge .document_draw_cursor
.document_printable_fit:
    cmp r13d, DOC_TOP
    jl .document_printable_skip_draw
    cmp r12d, DOC_LEFT
    jl .document_printable_skip_draw
    mov eax, DOC_LEFT
    add eax, dword ptr [rip + window_doc_pixel_width]
    cmp r12d, eax
    jae .document_printable_skip_draw
    mov edi, r12d
    mov esi, r13d
    mov edx, ebx
    mov ecx, dword ptr [rip + doc_font_size]
    call draw_glyph
.document_printable_skip_draw:
    add r12d, r15d
    mov edi, r14d
    call doc_grapheme_next
    mov r14d, eax
    jmp .Ldocument_render_loop

.document_tab:
    mov eax, r12d
    sub eax, DOC_LEFT
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldocument_tab_wrapped
    add eax, dword ptr [rip + doc_view_left_px]
    add eax, 32
    and eax, -32
    sub eax, dword ptr [rip + doc_view_left_px]
    jmp .document_tab_fit
.Ldocument_tab_wrapped:
    add eax, 32
    and eax, -32
    cmp eax, dword ptr [rip + window_doc_pixel_width]
    jbe .document_tab_fit
    mov r12d, DOC_LEFT + 32
    add r13d, dword ptr [rip + window_doc_line_height]
    mov edx, dword ptr [rip + window_doc_bottom]
    sub edx, dword ptr [rip + window_doc_line_height]
    cmp r13d, edx
    jge .document_draw_cursor
    jmp .document_next_byte
.document_tab_fit:
    lea r12d, [eax + DOC_LEFT]
    jmp .document_next_byte

.document_newline:
    mov r12d, DOC_LEFT
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldocument_newline_origin_ready
    sub r12d, dword ptr [rip + doc_view_left_px]
.Ldocument_newline_origin_ready:
    add r13d, dword ptr [rip + window_doc_line_height]
.document_next_byte:
    inc r14d
    jmp .Ldocument_render_loop

.document_draw_cursor:
    mov edi, dword ptr [rip + doc_cursor]
    call doc_offset_to_visual
    lea r12d, [rdx + DOC_LEFT]
    cmp dword ptr [rip + doc_wrap_enabled], 0
    jne .Ldocument_cursor_x_ready
    sub r12d, dword ptr [rip + doc_view_left_px]
.Ldocument_cursor_x_ready:
    mov r13d, eax
    sub r13d, dword ptr [rip + doc_view_top_row]
    test r13d, r13d
    js .document_render_done
    cmp r13d, dword ptr [rip + window_doc_visible_rows]
    jae .document_render_done
    imul r13d, dword ptr [rip + window_doc_line_height]
    add r13d, DOC_TOP
    cmp r12d, DOC_LEFT
    jl .document_render_done
    mov eax, DOC_LEFT
    add eax, dword ptr [rip + window_doc_pixel_width]
    cmp r12d, eax
    jae .document_render_done
    mov eax, dword ptr [rip + window_width]
    sub eax, DOC_SCROLL_TRACK_X_OFFSET + 1
    cmp r12d, eax
    ja .document_render_done
    cmp dword ptr [rip + text_input_enabled], 1
    jne .Ldocument_draw_normal_caret
    mov edi, r12d
    mov esi, r13d
    call render_text_input_preedit
    test ecx, ecx
    jz .document_render_done
    mov r12d, eax
    mov r13d, edx
.Ldocument_draw_normal_caret:
    mov rdi, qword ptr [rip + shm_mapping]
    mov esi, r12d
    mov edx, r13d
    mov ecx, 1
    mov r8d, dword ptr [rip + window_doc_line_height]
    sub r8d, 3
    mov r9d, 0xffffffff
    call draw_rect
.document_render_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size render_document, . - render_document

# Create the optional fractional-scale/viewport objects after the fixed
# surface, shm, seat and input proxies have consumed their lower object IDs.
# A display sync ensures the initial preferred_scale event is received before
# the first buffer dimensions and viewport destination are finalized.
.type fractional_scale_startup, @function
fractional_scale_startup:
    push r12
    push r13
    sub rsp, 8                  # align nested System V calls
    cmp dword ptr [rip + fractional_scale_manager_global], 0
    je .fractional_startup_done
    cmp dword ptr [rip + viewporter_global], 0
    je .fractional_startup_done
    call fractional_scale_bind_managers
    test rax, rax
    js .fractional_startup_return
    call fractional_scale_create_surface_objects
    test rax, rax
    js .fractional_startup_return
    cmp dword ptr [rip + fractional_scale_enabled], 1
    jne .fractional_startup_done
    mov r12d, dword ptr [rip + next_client_object_id]
    inc dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + payload_buffer], r12d
    mov edi, 1
    xor esi, esi                # wl_display.sync(new callback)
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .fractional_startup_return
.fractional_startup_read:
    call wl_read_event
    test rax, rax
    js .fractional_startup_return
    mov eax, dword ptr [rip + fractional_scale_object]
    cmp dword ptr [rip + last_object], eax
    jne .fractional_startup_check_ping
    call handle_fractional_scale_event
    test rax, rax
    js .fractional_startup_return
    jmp .fractional_startup_check_sync
.fractional_startup_check_ping:
    cmp dword ptr [rip + last_object], 6
    jne .fractional_startup_registry
    cmp dword ptr [rip + last_opcode], 0
    jne .fractional_startup_check_sync
    call handle_xdg_ping
    test rax, rax
    js .fractional_startup_return
    jmp .fractional_startup_check_sync
.fractional_startup_registry:
    cmp dword ptr [rip + last_object], 2
    jne .fractional_startup_keyboard
    cmp dword ptr [rip + last_opcode], 0
    je .fractional_startup_global
    cmp dword ptr [rip + last_opcode], 1
    je .fractional_startup_global_remove
    jmp .fractional_startup_check_sync
.fractional_startup_global:
    call registry_capture_global
    jmp .fractional_startup_check_sync
.fractional_startup_global_remove:
    call handle_output_global_remove
    test eax, eax
    js .fractional_startup_return
.fractional_startup_keyboard:
    # This sync runs after wl_seat.get_keyboard. The compositor may deliver
    # the keyboard's initial keymap here, after the earlier seat roundtrip has
    # already completed. Never let a blocking extension roundtrip discard it.
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .fractional_startup_check_sync
    cmp dword ptr [rip + last_object], eax
    jne .fractional_startup_check_sync
    cmp dword ptr [rip + last_opcode], 0
    jne .fractional_startup_check_sync
    call keyboard_keymap_dispatch
    test rax, rax
    js .fractional_startup_return
.fractional_startup_check_sync:
    cmp dword ptr [rip + last_object], 1
    jne .fractional_startup_check_sync_callback
    cmp dword ptr [rip + last_opcode], 0
    jne .fractional_startup_check_sync_callback
    mov rax, -71
    jmp .fractional_startup_return
.fractional_startup_check_sync_callback:
    cmp dword ptr [rip + last_object], r12d
    jne .fractional_startup_read
    cmp dword ptr [rip + last_opcode], 0
    jne .fractional_startup_read
    xor eax, eax
    jmp .fractional_startup_return
.fractional_startup_done:
    xor eax, eax
.fractional_startup_return:
    add rsp, 8
    pop r13
    pop r12
    ret
.size fractional_scale_startup, . - fractional_scale_startup

# Bind the optional fractional-scale manager and viewporter as a pair.
.type fractional_scale_bind_managers, @function
fractional_scale_bind_managers:
    push r12
    push r13
    sub rsp, 8                  # align nested calls to the System V ABI
    cmp dword ptr [rip + fractional_scale_manager_global], 0
    je .fractional_bind_done
    cmp dword ptr [rip + viewporter_global], 0
    je .fractional_bind_done
    mov r12d, dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + fractional_scale_manager_object], r12d
    mov edi, dword ptr [rip + fractional_scale_manager_global]
    lea rsi, [rip + iface_fractional_scale_manager]
    mov edx, 31
    mov ecx, 1
    mov r8d, r12d
    call wl_registry_bind
    test rax, rax
    js .fractional_bind_return
    lea r13d, [r12 + 1]
    mov dword ptr [rip + viewporter_object], r13d
    mov edi, dword ptr [rip + viewporter_global]
    lea rsi, [rip + iface_viewporter]
    mov edx, 14
    mov ecx, 1
    mov r8d, r13d
    call wl_registry_bind
    test rax, rax
    js .fractional_bind_return
    lea eax, [r13 + 1]
    mov dword ptr [rip + next_client_object_id], eax
.fractional_bind_done:
    xor eax, eax
.fractional_bind_return:
    add rsp, 8
    pop r13
    pop r12
    ret
.size fractional_scale_bind_managers, . - fractional_scale_bind_managers

# Create one wp_viewport and one wp_fractional_scale_v1 for wl_surface 8.
.type fractional_scale_create_surface_objects, @function
fractional_scale_create_surface_objects:
    push r12
    push r13
    sub rsp, 8                  # align nested calls to the System V ABI
    cmp dword ptr [rip + fractional_scale_manager_object], 0
    je .fractional_surface_done
    cmp dword ptr [rip + viewporter_object], 0
    je .fractional_surface_done
    mov r12d, dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + viewport_object], r12d
    mov dword ptr [rip + payload_buffer], r12d
    mov dword ptr [rip + payload_buffer + 4], 8
    mov edi, dword ptr [rip + viewporter_object]
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .fractional_surface_return
    lea r13d, [r12 + 1]
    mov dword ptr [rip + fractional_scale_object], r13d
    mov dword ptr [rip + payload_buffer], r13d
    mov dword ptr [rip + payload_buffer + 4], 8
    mov edi, dword ptr [rip + fractional_scale_manager_object]
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .fractional_surface_return
    lea eax, [r13 + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + fractional_scale_enabled], 1
.fractional_surface_done:
    xor eax, eax
.fractional_surface_return:
    add rsp, 8
    pop r13
    pop r12
    ret
.size fractional_scale_create_surface_objects, . - fractional_scale_create_surface_objects

# wp_fractional_scale_v1.preferred_scale (event opcode 0), in 120ths.
# RAX=1 when consumed, 0 for another object, negative on malformed input.
.type handle_fractional_scale_event, @function
handle_fractional_scale_event:
    sub rsp, 8                  # align output_recompute_surface_scale call
    mov eax, dword ptr [rip + fractional_scale_object]
    test eax, eax
    jz .fractional_event_not_found
    cmp dword ptr [rip + last_object], eax
    jne .fractional_event_not_found
    cmp dword ptr [rip + last_opcode], 0
    jne .fractional_event_protocol_error
    cmp dword ptr [rip + last_size], 4
    jb .fractional_event_protocol_error
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    jz .fractional_event_protocol_error
    cmp eax, dword ptr [rip + surface_preferred_fractional_scale]
    je .fractional_event_handled
    mov dword ptr [rip + surface_preferred_fractional_scale], eax
    call output_recompute_surface_scale
.fractional_event_handled:
    mov eax, 1
    add rsp, 8
    ret
.fractional_event_protocol_error:
    mov rax, -71
    add rsp, 8
    ret
.fractional_event_not_found:
    xor eax, eax
    add rsp, 8
    ret
.size handle_fractional_scale_event, . - handle_fractional_scale_event

# Apply a logical viewport destination only when the toplevel size changes.
.type window_apply_viewport_destination, @function
window_apply_viewport_destination:
    sub rsp, 8                  # align wl_send_request call
    mov edi, dword ptr [rip + viewport_object]
    test edi, edi
    jz .viewport_destination_done
    mov eax, dword ptr [rip + window_surface_width]
    cmp eax, dword ptr [rip + viewport_destination_width]
    jne .viewport_destination_send
    mov eax, dword ptr [rip + window_surface_height]
    cmp eax, dword ptr [rip + viewport_destination_height]
    je .viewport_destination_done
.viewport_destination_send:
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + payload_buffer], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + payload_buffer + 4], eax
    mov edi, dword ptr [rip + viewport_object]
    mov esi, 2
    lea rdx, [rip + payload_buffer]
    mov ecx, 8
    call wl_send_request
    test rax, rax
    js .viewport_destination_return
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + viewport_destination_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + viewport_destination_height], eax
.viewport_destination_done:
    xor eax, eax
.viewport_destination_return:
    add rsp, 8
    ret
.size window_apply_viewport_destination, . - window_apply_viewport_destination

# Attach the first wl_buffer and map the surface after bootstrap IDs and
# optional input/output proxies have been allocated in monotonic ID order.
.type window_attach_initial_buffer, @function
window_attach_initial_buffer:
    push rbp
    cmp dword ptr [rip + compositor_version], 3
    jb .initial_buffer_scale_done
    mov eax, dword ptr [rip + window_buffer_scale]
    cmp dword ptr [rip + viewport_object], 0
    je  .initial_buffer_scale_target_ready
    mov eax, 1
.initial_buffer_scale_target_ready:
    cmp eax, dword ptr [rip + surface_applied_buffer_scale]
    je .initial_buffer_scale_done
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 8
    mov esi, 8                  # wl_surface.set_buffer_scale
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .initial_buffer_done
    mov eax, dword ptr [rip + payload_buffer]
    mov dword ptr [rip + surface_applied_buffer_scale], eax
.initial_buffer_scale_done:
    cmp dword ptr [rip + compositor_version], 2
    jb .initial_buffer_transform_done
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, dword ptr [rip + surface_applied_buffer_transform]
    je .initial_buffer_transform_done
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 8
    mov esi, 7                  # wl_surface.set_buffer_transform
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .initial_buffer_done
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rip + surface_applied_buffer_transform], eax
.initial_buffer_transform_done:
    call window_apply_viewport_destination
    test rax, rax
    js .initial_buffer_done
    lea rax, [rip + stage_attach]
    mov qword ptr [rip + failure_stage], rax
    mov eax, dword ptr [rip + window_buffer_id]
    mov dword ptr [rip + payload_buffer], eax
    mov dword ptr [rip + payload_buffer + 4], 0
    mov dword ptr [rip + payload_buffer + 8], 0
    mov edi, 8
    mov esi, 1                  # wl_surface.attach
    lea rdx, [rip + payload_buffer]
    mov ecx, 12
    call wl_send_request
    test rax, rax
    js .initial_buffer_done

    mov dword ptr [rip + payload_buffer], 0
    mov dword ptr [rip + payload_buffer + 4], 0
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov edi, 8
    mov esi, 2                  # wl_surface.damage
    lea rdx, [rip + payload_buffer]
    mov ecx, 16
    call wl_send_request
    test rax, rax
    js .initial_buffer_done

    mov edi, 8
    mov esi, 6                  # wl_surface.commit
    xor edx, edx
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .initial_buffer_done
    mov dword ptr [rip + window_buffer_slot_busy], 1
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
    mov dword ptr [rip + window_buffer_last_slot], 0
    mov dword ptr [rip + buffer_busy], 1
    mov dword ptr [rip + window_surface_mapped], 1
    xor eax, eax
.initial_buffer_done:
    pop rbp
    ret
.size window_attach_initial_buffer, . - window_attach_initial_buffer

# Bind pending wl_output globals at at most protocol version 3.
# The registry name and bound client object ID occupy separate namespaces.
.type output_bind_pending, @function
output_bind_pending:
    push rbp
    push r12
    push r13
    xor r12d, r12d
.output_bind_loop:
    cmp r12d, 8
    jae .output_bind_done
    lea rax, [rip + output_global_names]
    mov eax, dword ptr [rax + r12*4]
    test eax, eax
    jz .output_bind_next
    lea rax, [rip + output_object_ids]
    cmp dword ptr [rax + r12*4], 0
    jne .output_bind_next
    mov r13d, dword ptr [rip + next_client_object_id]
    lea eax, [r13d + 1]
    mov dword ptr [rip + next_client_object_id], eax
    lea rax, [rip + output_global_names]
    mov edi, dword ptr [rax + r12*4]
    lea rsi, [rip + iface_output]
    mov edx, 10                 # strlen("wl_output") + NUL
    lea rax, [rip + output_versions]
    mov ecx, dword ptr [rax + r12*4]
    mov r8d, r13d
    call wl_registry_bind
    test rax, rax
    js .output_bind_return
    lea rax, [rip + output_object_ids]
    mov dword ptr [rax + r12*4], r13d
.output_bind_next:
    inc r12d
    jmp .output_bind_loop
.output_bind_done:
    xor eax, eax
.output_bind_return:
    pop r13
    pop r12
    pop rbp
    ret
.size output_bind_pending, . - output_bind_pending

.type output_recompute_display_size, @function
output_recompute_display_size:
    push rbx
    push r12
    push r13
    push r14
    xor r12d, r12d
    xor r13d, r13d
    xor r14d, r14d
    xor ebx, ebx
.output_display_scan:
    cmp r12d, 8
    jae .output_display_store
    lea rax, [rip + output_mode_width]
    mov eax, dword ptr [rax + r12*4]
    test eax, eax
    jz .output_display_next
    lea rdx, [rip + output_scales]
    mov esi, dword ptr [rdx + r12*4]
    test esi, esi
    jnz .output_display_scale_ready
    mov esi, 1
.output_display_scale_ready:
    xor edx, edx
    div esi
    mov r8d, eax
    lea rax, [rip + output_mode_height]
    mov eax, dword ptr [rax + r12*4]
    test eax, eax
    jz .output_display_next
    xor edx, edx
    div esi
    mov r9d, eax
    test r8d, r8d
    jz .output_display_next
    test r9d, r9d
    jz .output_display_next
    mov eax, r8d
    imul eax, r9d
    cmp eax, ebx
    jbe .output_display_next
    mov ebx, eax
    mov r13d, r8d
    mov r14d, r9d
.output_display_next:
    inc r12d
    jmp .output_display_scan
.output_display_store:
    mov dword ptr [rip + output_display_width], r13d
    mov dword ptr [rip + output_display_height], r14d
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size output_recompute_display_size, . - output_recompute_display_size

.type output_initial_roundtrip, @function
output_initial_roundtrip:
    push rbp
    push r12
    push r13
    xor r13d, r13d
.output_initial_has_output:
    cmp r13d, 8
    jae .output_initial_no_outputs
    lea rax, [rip + output_object_ids]
    cmp dword ptr [rax + r13*4], 0
    jne .output_initial_sync
    inc r13d
    jmp .output_initial_has_output
.output_initial_no_outputs:
    xor eax, eax
    jmp .output_initial_return
.output_initial_sync:
    mov r12d, dword ptr [rip + next_client_object_id]
    lea eax, [r12 + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + payload_buffer], r12d
    mov edi, 1
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .output_initial_return
.output_initial_read:
    call wl_read_event
    test rax, rax
    js .output_initial_return
    cmp dword ptr [rip + last_object], r12d
    jne .output_initial_ping
    cmp dword ptr [rip + last_opcode], 0
    jne .output_initial_read
    xor eax, eax
    jmp .output_initial_return
.output_initial_ping:
    cmp dword ptr [rip + last_object], 6
    jne .output_initial_registry
    cmp dword ptr [rip + last_opcode], 0
    jne .output_initial_registry
    call handle_xdg_ping
    test rax, rax
    js .output_initial_return
    jmp .output_initial_read
.output_initial_registry:
    cmp dword ptr [rip + last_object], 2
    jne .output_initial_output
    cmp dword ptr [rip + last_opcode], 0
    je .output_initial_global
    cmp dword ptr [rip + last_opcode], 1
    je .output_initial_global_remove
    jmp .output_initial_read
.output_initial_global:
    call registry_capture_global
    jmp .output_initial_read
.output_initial_global_remove:
    call handle_output_global_remove
    test eax, eax
    js .output_initial_return
    jmp .output_initial_read
.output_initial_output:
    call handle_output_event
    test eax, eax
    jnz .output_initial_read
    mov eax, dword ptr [rip + keyboard_object]
    test eax, eax
    jz .output_initial_surface_event
    cmp dword ptr [rip + last_object], eax
    jne .output_initial_surface_event
    cmp dword ptr [rip + last_opcode], 0
    jne .output_initial_surface_event
    call keyboard_keymap_dispatch
    test rax, rax
    js .output_initial_return
    jmp .output_initial_read
.output_initial_surface_event:
    call handle_surface_output_event
    test eax, eax
    jnz .output_initial_read
    call handle_fractional_scale_event
    test eax, eax
    jnz .output_initial_read
    jmp .output_initial_read
.output_initial_return:
    pop r13
    pop r12
    pop rbp
    ret
.size output_initial_roundtrip, . - output_initial_roundtrip

# Recompute entered-output count, max integer scale, and the selected scale hint.
# wl_compositor v6+ uses the per-surface preference; older versions fall back
# to the maximum committed scale among entered outputs. Rendering is unchanged.
# Apply the compositor's current integer-scale preference to the software buffer.
# During startup, defer descriptor replacement until the initial buffer is attached.
.type window_scale_schedule, @function
window_scale_schedule:
    push r12
    mov r12d, dword ptr [rip + window_buffer_scale]
    sub rsp, 16
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rsp], eax
    mov eax, dword ptr [rip + window_buffer_raster_scale_120]
    mov dword ptr [rsp + 4], eax
    call window_update_geometry
    mov eax, dword ptr [rsp]
    mov edx, dword ptr [rsp + 4]
    add rsp, 16
    cmp r12d, dword ptr [rip + window_buffer_scale]
    jne .window_scale_schedule_changed
    cmp eax, dword ptr [rip + window_buffer_transform]
    jne .window_scale_schedule_changed
    cmp edx, dword ptr [rip + window_buffer_raster_scale_120]
    je .window_scale_schedule_done
.window_scale_schedule_changed:
    mov dword ptr [rip + window_resize_pending], 1
    mov dword ptr [rip + redraw_pending], 1
    cmp dword ptr [rip + window_surface_mapped], 0
    je .window_scale_schedule_done
    cmp dword ptr [rip + buffer_busy], 0
    jne .window_scale_schedule_done
    call window_apply_pending_resize
    test rax, rax
    js .window_scale_schedule_done
.window_scale_schedule_done:
    pop r12
    ret
.size window_scale_schedule, . - window_scale_schedule

# Rebuild the first buffer if a preferred scale arrived after its original
# create_buffer request but before the first surface attachment.
.type window_apply_initial_output_size, @function
window_apply_initial_output_size:
    cmp dword ptr [rip + window_initial_size_applied], 0
    jne .window_initial_output_size_done
    mov dword ptr [rip + window_initial_size_applied], 1
    mov eax, dword ptr [rip + output_display_width]
    test eax, eax
    jz .window_initial_output_size_done

    # Bit 0 means explicit width; bit 1 means explicit height. A WM-managed
    # maximized/fullscreen/tiled state locks both dimensions.
    test dword ptr [rip + window_startup_size_locked], 1
    jnz .window_output_width_done
    imul eax, 2
    xor edx, edx
    mov ecx, 3
    div ecx
    cmp eax, WINDOW_MIN_WIDTH
    jae .window_initial_width_min_ready
    mov eax, WINDOW_MIN_WIDTH
.window_initial_width_min_ready:
    cmp eax, MAX_WINDOW_WIDTH
    jbe .window_initial_width_max_ready
    mov eax, MAX_WINDOW_WIDTH
.window_initial_width_max_ready:
    mov dword ptr [rip + window_surface_width], eax
.window_output_width_done:
    test dword ptr [rip + window_startup_size_locked], 2
    jnz .window_output_height_done
    mov eax, dword ptr [rip + output_display_height]
    test eax, eax
    jz .window_initial_output_size_done
    imul eax, 2
    xor edx, edx
    mov ecx, 3
    div ecx
    cmp eax, WINDOW_MIN_HEIGHT
    jae .window_initial_height_min_ready
    mov eax, WINDOW_MIN_HEIGHT
.window_initial_height_min_ready:
    cmp eax, MAX_WINDOW_HEIGHT
    jbe .window_initial_height_max_ready
    mov eax, MAX_WINDOW_HEIGHT
.window_initial_height_max_ready:
    mov dword ptr [rip + window_surface_height], eax
.window_output_height_done:
    call window_update_geometry
.window_initial_output_size_done:
    xor eax, eax
    ret
.size window_apply_initial_output_size, . - window_apply_initial_output_size

.type window_prepare_initial_buffer_scale, @function
window_prepare_initial_buffer_scale:
    push r12
    call window_apply_initial_output_size
    mov eax, dword ptr [rip + window_buffer_created_surface_width]
    cmp eax, dword ptr [rip + window_surface_width]
    jne .window_prepare_initial_scale_rebuild
    mov eax, dword ptr [rip + window_buffer_created_surface_height]
    cmp eax, dword ptr [rip + window_surface_height]
    jne .window_prepare_initial_scale_rebuild
    mov eax, dword ptr [rip + window_buffer_created_scale]
    cmp eax, dword ptr [rip + window_buffer_scale]
    jne .window_prepare_initial_scale_rebuild
    mov eax, dword ptr [rip + window_buffer_created_raster_scale_120]
    cmp eax, dword ptr [rip + window_buffer_raster_scale_120]
    jne .window_prepare_initial_scale_rebuild
    mov eax, dword ptr [rip + window_buffer_transform]
    cmp eax, dword ptr [rip + window_buffer_created_transform]
    je .window_prepare_initial_scale_done
.window_prepare_initial_scale_rebuild:
    call render_surface
    # The original descriptor has never been attached, so it is safe to destroy.
    mov edi, dword ptr [rip + window_buffer_id]
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .window_prepare_initial_scale_done
    mov r12d, dword ptr [rip + next_client_object_id]
    lea eax, [r12d + 1]
    mov dword ptr [rip + next_client_object_id], eax
    mov dword ptr [rip + payload_buffer], r12d
    mov dword ptr [rip + payload_buffer + 4], 0
    mov eax, dword ptr [rip + window_buffer_width]
    mov dword ptr [rip + payload_buffer + 8], eax
    mov eax, dword ptr [rip + window_buffer_height]
    mov dword ptr [rip + payload_buffer + 12], eax
    mov eax, dword ptr [rip + window_stride]
    mov dword ptr [rip + payload_buffer + 16], eax
    mov dword ptr [rip + payload_buffer + 20], 1
    mov edi, 11
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    mov ecx, 24
    call wl_send_request
    test rax, rax
    js .window_prepare_initial_scale_done
    mov dword ptr [rip + window_buffer_id], r12d
    mov dword ptr [rip + window_buffer_slot_ids], r12d
    mov dword ptr [rip + window_buffer_slot_ids + 4], 0
    mov dword ptr [rip + window_buffer_slot_busy], 0
    mov dword ptr [rip + window_buffer_slot_busy + 4], 0
    mov dword ptr [rip + window_buffer_last_slot], 1
    mov dword ptr [rip + buffer_busy], 0
    mov rax, qword ptr [rip + shm_mapping_base]
    mov qword ptr [rip + shm_mapping], rax
    mov eax, dword ptr [rip + window_buffer_scale]
    mov dword ptr [rip + window_buffer_created_scale], eax
    mov eax, dword ptr [rip + window_buffer_raster_scale_120]
    mov dword ptr [rip + window_buffer_created_raster_scale_120], eax
    mov eax, dword ptr [rip + window_buffer_transform]
    mov dword ptr [rip + window_buffer_created_transform], eax
    mov eax, dword ptr [rip + window_surface_width]
    mov dword ptr [rip + window_buffer_created_surface_width], eax
    mov eax, dword ptr [rip + window_surface_height]
    mov dword ptr [rip + window_buffer_created_surface_height], eax
    mov dword ptr [rip + window_resize_pending], 0
    mov dword ptr [rip + redraw_pending], 0
.window_prepare_initial_scale_done:
    pop r12
    ret
.size window_prepare_initial_buffer_scale, . - window_prepare_initial_buffer_scale

.type output_recompute_surface_scale, @function
output_recompute_surface_scale:
    push rbp
    push r12
    push r13
    xor r12d, r12d
    xor r13d, r13d             # entered-output count
    mov r11d, 1                # no-output/default scale
    lea rdi, [rip + output_surface_entered]
    lea rsi, [rip + output_scales]
.output_recompute_loop:
    cmp r12d, 8
    jae .output_recompute_done
    cmp dword ptr [rdi + r12*4], 1
    jne .output_recompute_next
    inc r13d
    mov edx, dword ptr [rsi + r12*4]
    cmp edx, r11d
    jbe .output_recompute_next
    mov r11d, edx
.output_recompute_next:
    inc r12d
    jmp .output_recompute_loop
.output_recompute_done:
    mov dword ptr [rip + surface_output_count], r13d
    mov dword ptr [rip + surface_output_max_scale], r11d

    # wp_viewporter keeps wl_surface buffer_scale at 1. The exact preferred
    # 120ths raster numerator is consumed by window_update_geometry.
    cmp dword ptr [rip + fractional_scale_enabled], 1
    jne .output_recompute_integer_scale
    mov eax, 1
    jmp .output_recompute_store_scale
.output_recompute_integer_scale:
    # Version 6 exposes authoritative per-surface scale and transform hints.
    # Their protocol defaults are scale 1 and the normal transform.
    cmp dword ptr [rip + compositor_version], 6
    jb .output_recompute_legacy_scale
    mov eax, dword ptr [rip + surface_preferred_buffer_scale]
    jmp .output_recompute_store_scale
.output_recompute_legacy_scale:
    mov eax, r11d
.output_recompute_store_scale:
    mov dword ptr [rip + surface_effective_buffer_scale], eax
    # Before the first xdg_surface.configure there is no backing geometry or
    # wl_buffer to replace. Let window_commit_initial_size consume the stored
    # preference; after the first pool buffer exists, scale changes are scheduled.
    cmp dword ptr [rip + window_buffer_created_scale], 0
    je .output_recompute_schedule_done
    call window_scale_schedule
.output_recompute_schedule_done:
    pop r13
    pop r12
    pop rbp
    ret
.size output_recompute_surface_scale, . - output_recompute_surface_scale

# Handle wl_registry.global_remove. wl_output.release exists since v3 only.
.type handle_output_global_remove, @function
handle_output_global_remove:
    push rbp
    push r12
    push r13
    cmp dword ptr [rip + last_size], 4
    jb .output_remove_not_found
    mov r12d, dword ptr [rip + event_payload]
    # A global can disappear between registry discovery and the initial
    # binding pass. Clear either optional extension name before attempting
    # wp_fractional_scale_manager_v1/wp_viewporter as a pair.
    cmp r12d, dword ptr [rip + fractional_scale_manager_global]
    je .output_remove_fractional_manager
    cmp r12d, dword ptr [rip + viewporter_global]
    je .output_remove_viewporter
    xor r13d, r13d
.output_remove_find:
    cmp r13d, 8
    jae .output_remove_not_found
    lea rax, [rip + output_global_names]
    cmp dword ptr [rax + r13*4], r12d
    je .output_remove_found
    inc r13d
    jmp .output_remove_find
.output_remove_fractional_manager:
    mov dword ptr [rip + fractional_scale_manager_global], 0
    mov eax, 1
    jmp .output_remove_return
.output_remove_viewporter:
    mov dword ptr [rip + viewporter_global], 0
    mov eax, 1
    jmp .output_remove_return
.output_remove_found:
    lea rax, [rip + output_object_ids]
    mov edi, dword ptr [rax + r13*4]
    test edi, edi
    jz .output_remove_clear
    lea rax, [rip + output_versions]
    cmp dword ptr [rax + r13*4], 3
    jb .output_remove_clear
    xor esi, esi                 # wl_output.release
    lea rdx, [rip + payload_buffer]
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .output_remove_return
.output_remove_clear:
    lea rax, [rip + output_global_names]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_object_ids]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_versions]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_scales]
    mov dword ptr [rax + r13*4], 1
    lea rax, [rip + output_pending_scales]
    mov dword ptr [rax + r13*4], 1
    lea rax, [rip + output_pending_valid]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_mode_width]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_mode_height]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_pending_mode_width]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_pending_mode_height]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_pending_mode_valid]
    mov dword ptr [rax + r13*4], 0
    lea rax, [rip + output_surface_entered]
    mov dword ptr [rax + r13*4], 0
    call output_recompute_surface_scale
    call output_recompute_display_size
    mov eax, 1
    jmp .output_remove_return
.output_remove_not_found:
    xor eax, eax
.output_remove_return:
    pop r13
    pop r12
    pop rbp
    ret
.size handle_output_global_remove, . - handle_output_global_remove

# wl_output.scale (opcode 3, introduced in version 2).
.type handle_output_event, @function
handle_output_event:
    push rbp
    push r12
    push r13
    xor r12d, r12d
    mov r13d, dword ptr [rip + last_object]
.output_event_find:
    cmp r12d, 8
    jae .output_event_not_found
    lea rax, [rip + output_object_ids]
    cmp dword ptr [rax + r12*4], r13d
    je .output_event_found
    inc r12d
    jmp .output_event_find
.output_event_found:
    mov eax, dword ptr [rip + last_opcode]
    cmp eax, 1
    je .output_event_mode
    cmp eax, 3
    je .output_event_scale
    cmp eax, 2
    je .output_event_done
    jmp .output_event_handled
.output_event_mode:
    cmp dword ptr [rip + last_size], 16
    jb .output_event_protocol_error
    mov eax, dword ptr [rip + event_payload]
    test eax, 1
    jz .output_event_handled
    mov eax, dword ptr [rip + event_payload + 4]
    test eax, eax
    jle .output_event_protocol_error
    cmp eax, 32768
    ja .output_event_protocol_error
    mov edx, dword ptr [rip + event_payload + 8]
    test edx, edx
    jle .output_event_protocol_error
    cmp edx, 32768
    ja .output_event_protocol_error
    lea rax, [rip + output_versions]
    cmp dword ptr [rax + r12*4], 2
    jb .output_event_mode_immediate
    lea rax, [rip + output_pending_mode_width]
    mov edx, dword ptr [rip + event_payload + 4]
    mov dword ptr [rax + r12*4], edx
    lea rax, [rip + output_pending_mode_height]
    mov edx, dword ptr [rip + event_payload + 8]
    mov dword ptr [rax + r12*4], edx
    lea rax, [rip + output_pending_mode_valid]
    mov dword ptr [rax + r12*4], 1
    jmp .output_event_handled
.output_event_mode_immediate:
    lea rax, [rip + output_mode_width]
    mov edx, dword ptr [rip + event_payload + 4]
    mov dword ptr [rax + r12*4], edx
    lea rax, [rip + output_mode_height]
    mov edx, dword ptr [rip + event_payload + 8]
    mov dword ptr [rax + r12*4], edx
    call output_recompute_display_size
    jmp .output_event_handled
.output_event_scale:
    cmp dword ptr [rip + last_size], 4
    jb .output_event_protocol_error
    lea rdx, [rip + output_versions]
    cmp dword ptr [rdx + r12*4], 2
    jb .output_event_protocol_error
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    jle .output_event_protocol_error
    lea rdx, [rip + output_pending_scales]
    mov dword ptr [rdx + r12*4], eax
    lea rdx, [rip + output_pending_valid]
    mov dword ptr [rdx + r12*4], 1
    jmp .output_event_handled
.output_event_done:
    lea rdx, [rip + output_versions]
    cmp dword ptr [rdx + r12*4], 2
    jb .output_event_protocol_error
    xor r13d, r13d
    lea rdx, [rip + output_pending_valid]
    cmp dword ptr [rdx + r12*4], 0
    je .output_event_commit_mode
    mov dword ptr [rdx + r12*4], 0
    lea rdx, [rip + output_pending_scales]
    mov eax, dword ptr [rdx + r12*4]
    lea rdx, [rip + output_scales]
    mov dword ptr [rdx + r12*4], eax
    mov r13d, 1
.output_event_commit_mode:
    lea rdx, [rip + output_pending_mode_valid]
    cmp dword ptr [rdx + r12*4], 0
    je .output_event_commit_done
    mov dword ptr [rdx + r12*4], 0
    lea rdx, [rip + output_pending_mode_width]
    mov eax, dword ptr [rdx + r12*4]
    lea rdx, [rip + output_mode_width]
    mov dword ptr [rdx + r12*4], eax
    lea rdx, [rip + output_pending_mode_height]
    mov eax, dword ptr [rdx + r12*4]
    lea rdx, [rip + output_mode_height]
    mov dword ptr [rdx + r12*4], eax
    mov r13d, 1
.output_event_commit_done:
    test r13d, r13d
    jz .output_event_handled
    call output_recompute_surface_scale
    call output_recompute_display_size
.output_event_handled:
    mov eax, 1
    jmp .output_event_return
.output_event_protocol_error:
    mov rax, -71
    jmp .output_event_return
.output_event_not_found:
    xor eax, eax
.output_event_return:
    pop r13
    pop r12
    pop rbp
    ret
.size handle_output_event, . - handle_output_event

# wl_surface.enter/leave (opcodes 0/1) maintain output membership.
.type handle_surface_output_event, @function
handle_surface_output_event:
    push rbp
    push r12
    push r13
    cmp dword ptr [rip + last_object], 8
    jne .surface_output_not_found
    mov eax, dword ptr [rip + last_opcode]
    cmp eax, 0
    je .surface_output_enter
    cmp eax, 1
    je .surface_output_leave
    cmp eax, 2
    je .surface_output_preferred_scale
    cmp eax, 3
    je .surface_output_preferred_transform
    jmp .surface_output_not_found
.surface_output_preferred_scale:
    cmp dword ptr [rip + compositor_version], 6
    jb .surface_output_protocol_error
    cmp dword ptr [rip + last_size], 4
    jb .surface_output_protocol_error
    mov eax, dword ptr [rip + event_payload]
    test eax, eax
    jle .surface_output_protocol_error
    mov dword ptr [rip + surface_preferred_buffer_scale], eax
    mov dword ptr [rip + surface_preferred_scale_seen], 1
    call output_recompute_surface_scale
    jmp .surface_output_handled
.surface_output_preferred_transform:
    cmp dword ptr [rip + compositor_version], 6
    jb .surface_output_protocol_error
    cmp dword ptr [rip + last_size], 4
    jb .surface_output_protocol_error
    mov eax, dword ptr [rip + event_payload]
    cmp eax, 7
    ja .surface_output_protocol_error
    mov dword ptr [rip + surface_preferred_buffer_transform], eax
    mov dword ptr [rip + surface_preferred_transform_seen], 1
    call output_recompute_surface_scale
    jmp .surface_output_handled
.surface_output_enter:
    mov r13d, 1
    jmp .surface_output_find
.surface_output_leave:
    xor r13d, r13d
.surface_output_find:
    cmp dword ptr [rip + last_size], 4
    jb .surface_output_handled
    mov eax, dword ptr [rip + event_payload]
    xor r12d, r12d
.surface_output_loop:
    cmp r12d, 8
    jae .surface_output_handled
    lea rdx, [rip + output_object_ids]
    cmp dword ptr [rdx + r12*4], eax
    je .surface_output_match
    inc r12d
    jmp .surface_output_loop
.surface_output_match:
    lea rdx, [rip + output_surface_entered]
    mov dword ptr [rdx + r12*4], r13d
    call output_recompute_surface_scale
.surface_output_handled:
    mov eax, 1
    jmp .surface_output_return
.surface_output_protocol_error:
    mov rax, -71
    jmp .surface_output_return
.surface_output_not_found:
    xor eax, eax
.surface_output_return:
    pop r13
    pop r12
    pop rbp
    ret
.size handle_surface_output_event, . - handle_surface_output_event

# Create input objects after wl_seat advertises their capabilities.
# Pointer is allocated before keyboard when both appear in the same event.
.type handle_seat_capabilities, @function
handle_seat_capabilities:
    # Keep the prior and new complete capability masks separately while
    # release requests and object constructors call the wire helpers.
    push rbp
    push r12
    push r13
    cmp dword ptr [rip + last_size], 4
    jb .seat_caps_success
    mov r12d, dword ptr [rip + seat_capabilities]
    mov r13d, dword ptr [rip + event_payload]
    mov dword ptr [rip + seat_capabilities], r13d

    # A removed pointer invalidates pointer focus, implicit-button state,
    # resize/scroll drags, its cursor-shape device, and the wl_pointer proxy.
    test r12d, 1
    jz .seat_caps_remove_keyboard
    test r13d, 1
    jnz .seat_caps_remove_keyboard
    mov dword ptr [rip + pointer_inside], 0
    mov dword ptr [rip + pointer_button_down], 0
    mov dword ptr [rip + pointer_enter_serial], 0
    mov dword ptr [rip + pointer_serial], 0
    mov dword ptr [rip + cursor_shape_current], 0
    mov dword ptr [rip + doc_scroll_drag], 0
    mov dword ptr [rip + doc_hscroll_drag], 0
    mov dword ptr [rip + picker_scroll_drag], 0
    mov dword ptr [rip + doc_word_drag_active], 0
    call doc_drag_timer_stop

    mov edi, dword ptr [rip + cursor_shape_device]
    test edi, edi
    jz .seat_caps_pointer_device_destroyed
    # wp_cursor_shape_device_v1.destroy
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .seat_caps_done
    mov dword ptr [rip + cursor_shape_device], 0

.seat_caps_pointer_device_destroyed:
    mov edi, dword ptr [rip + pointer_object]
    test edi, edi
    jz .seat_caps_pointer_proxy_cleared
    cmp dword ptr [rip + seat_version], 3
    jb .seat_caps_pointer_proxy_cleared
    # wl_pointer.release was added in wl_seat version 3.
    mov esi, 1
    lea rdx, [rip + payload_buffer]
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .seat_caps_done

.seat_caps_pointer_proxy_cleared:
    # For seat versions 1-2 there is no protocol release request. Forget the
    # local proxy and use a fresh object ID if the capability returns.
    mov dword ptr [rip + pointer_object], 0
    mov dword ptr [rip + pointer_created], 0

.seat_caps_remove_keyboard:
    # Do not leave a held key, dead-key/Compose prefix, or stale modifier
    # state active across a physical keyboard unplug/replacement.
    test r12d, 2
    jz .seat_caps_add_pointer
    test r13d, 2
    jnz .seat_caps_add_pointer
    mov dword ptr [rip + keyboard_focused], 0
    mov dword ptr [rip + doc_pending_dead_mark], 0
    mov dword ptr [rip + doc_compose_active], 0
    mov dword ptr [rip + doc_compose_first], 0
    mov dword ptr [rip + doc_compose_second], 0
    mov dword ptr [rip + doc_compose_third], 0
    mov dword ptr [rip + doc_compose_fourth], 0
    mov dword ptr [rip + doc_compose_fifth], 0
    mov dword ptr [rip + doc_compose_sixth], 0
    mov dword ptr [rip + doc_compose_seventh], 0
    mov dword ptr [rip + doc_compose_eighth], 0
    mov dword ptr [rip + ctrl_down], 0
    mov dword ptr [rip + ctrl_physical_down], 0
    mov dword ptr [rip + shift_down], 0
    mov dword ptr [rip + shift_physical_down], 0
    mov dword ptr [rip + level3_down], 0
    mov dword ptr [rip + level3_physical_down], 0
    mov dword ptr [rip + level3_mod5_down], 0
    mov dword ptr [rip + xkb_modifiers], 0
    mov dword ptr [rip + keyboard_group], 0
    mov dword ptr [rip + caps_lock], 0
    mov dword ptr [rip + num_lock], 0
    call repeat_cancel

    mov edi, dword ptr [rip + keyboard_object]
    test edi, edi
    jz .seat_caps_keyboard_proxy_cleared
    cmp dword ptr [rip + seat_version], 3
    jb .seat_caps_keyboard_proxy_cleared
    # wl_keyboard.release was added in wl_seat version 3.
    xor esi, esi
    lea rdx, [rip + payload_buffer]
    xor ecx, ecx
    call wl_send_request
    test rax, rax
    js .seat_caps_done

.seat_caps_keyboard_proxy_cleared:
    mov dword ptr [rip + keyboard_object], 0
    mov dword ptr [rip + keyboard_created], 0
    # Disabling text-input-v3 clears transient preedit and hands subsequent
    # printable input back to XKB until a replacement keyboard enters.
    cmp dword ptr [rip + text_input_object], 0
    je .seat_caps_keyboard_redraw
    call text_input_update_state
    test rax, rax
    js .seat_caps_done
.seat_caps_keyboard_redraw:
    mov dword ptr [rip + redraw_pending], 1

.seat_caps_add_pointer:
    test r13d, 1
    jz .seat_caps_add_keyboard
    cmp dword ptr [rip + pointer_created], 0
    jne .seat_caps_add_keyboard
    mov eax, dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + pointer_object], eax
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 13
    xor esi, esi                  # wl_seat.get_pointer
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .seat_caps_done
    mov dword ptr [rip + pointer_created], 1
    inc dword ptr [rip + next_client_object_id]

.seat_caps_add_keyboard:
    test r13d, 2
    jz .seat_caps_success
    cmp dword ptr [rip + keyboard_created], 0
    jne .seat_caps_success
    mov eax, dword ptr [rip + next_client_object_id]
    mov dword ptr [rip + keyboard_object], eax
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 13
    mov esi, 1                    # wl_seat.get_keyboard
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    call wl_send_request
    test rax, rax
    js .seat_caps_done
    mov dword ptr [rip + keyboard_created], 1
    inc dword ptr [rip + next_client_object_id]

.seat_caps_success:
    xor eax, eax
.seat_caps_done:
    pop r13
    pop r12
    pop rbp
    ret
.size handle_seat_capabilities, . - handle_seat_capabilities

# Answer xdg_wm_base.ping (object 6, opcode 0, serial payload).
.type handle_xdg_ping, @function
handle_xdg_ping:
    mov eax, dword ptr [rip + event_payload]
    mov dword ptr [rip + payload_buffer], eax
    mov edi, 6
    mov esi, 3
    lea rdx, [rip + payload_buffer]
    mov ecx, 4
    jmp wl_send_request
.size handle_xdg_ping, . - handle_xdg_ping

.section .note.GNU-stack,"",@progbits
