AS       ?= as
LD       ?= ld
READELF  ?= readelf
NM       ?= nm
SIZE     ?= size
STRIP    ?= strip
PYTHON   ?= python3
CC       ?= cc
OPT_FLAGS ?= -O2 -flto
NEKOEDIT_BASE_CFLAGS := -m64 -std=c11 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-asynchronous-unwind-tables -fno-unwind-tables -mno-red-zone -fno-tree-loop-distribute-patterns -ffunction-sections -fdata-sections -fno-ident
CFLAGS   ?= $(NEKOEDIT_BASE_CFLAGS) $(OPT_FLAGS)
# Test globals are read by the external Wayland harness; keep test objects non-LTO.
TEST_CFLAGS ?= $(filter-out -flto,$(CFLAGS))
BUILD_DIR ?= build
APP_BINARY := $(BUILD_DIR)/nekoedit
TEST_BUILD_DIR := $(BUILD_DIR)/test
TEST_APP_BINARY := $(TEST_BUILD_DIR)/nekoedit-test
TEST_OBJECTS = $(patsubst src/%.S,$(TEST_BUILD_DIR)/%.o,$(SOURCES)) $(patsubst src/%.c,$(TEST_BUILD_DIR)/%.o,$(C_SOURCES))
PREFERENCES_TEST := $(BUILD_DIR)/preferences_test
HISTORY_TEST := $(BUILD_DIR)/history_test
CLIPBOARD_RANGE_TEST := $(BUILD_DIR)/clipboard_range_test
COMPOSE_LOCALE_MANAGER_TEST := $(BUILD_DIR)/compose_locale_manager_test
COMPOSE_LOCALE_IMPORT_TEST := $(BUILD_DIR)/compose_locale_import_test
XKB_NATIVE_KEYMAP_TEST := $(BUILD_DIR)/xkb_native_keymap_test
ADVANCE_TEST := $(BUILD_DIR)/advance_test
ADVANCE_BENCH := $(BUILD_DIR)/advance_bench
RASTERIZER_BENCH := $(BUILD_DIR)/rasterizer_bench
RASTERIZER_BENCH_GENERIC := $(BUILD_DIR)/rasterizer_bench_generic
RASTERIZER_BENCH_LINEAR := $(BUILD_DIR)/rasterizer_bench_linear
RASTERIZER_BENCH_IDENTITY_REFERENCE := $(BUILD_DIR)/rasterizer_bench_identity_reference
RASTERIZER_BENCH_STORAGE_REFERENCE := $(BUILD_DIR)/rasterizer_bench_storage_reference
RASTERIZER_BENCH_METADATA_REFERENCE := $(BUILD_DIR)/rasterizer_bench_metadata_reference

PREFIX ?= /usr/local
USER_PREFIX ?= $(HOME)/.local
USER_BIN_DIR ?= $(USER_PREFIX)/bin
USER_APP_DIR ?= $(USER_PREFIX)/share/applications
USER_ICON_DIR ?= $(USER_PREFIX)/share/icons/hicolor/scalable/apps
MAKE_DEFAULT ?= 0

ASFLAGS  ?= --64 --fatal-warnings
LDFLAGS  ?= -static -no-pie -z noexecstack -e _start --gc-sections
# GCC's driver performs LTO while -nostdlib preserves the freestanding syscall-only ELF.
APP_LINKER ?= $(CC)
APP_LDFLAGS ?= -flto -nostdlib -static -no-pie -Wl,-z,noexecstack -Wl,-e,_start -Wl,--gc-sections
TEST_LINKER ?= $(LD)
TEST_LDFLAGS ?= $(LDFLAGS)

SOURCES  := src/entry.S src/linux/syscall.S src/font/advance.S src/font/sfnt.S src/backend/wayland.S src/backend/xkb.S
C_SOURCES := src/font/rasterizer.c src/backend/clipboard.c src/backend/compose_locale.c src/editor/history.c src/editor/preferences.c
OBJECTS  := $(patsubst src/%.S,$(BUILD_DIR)/%.o,$(SOURCES)) $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

.PHONY: all clean test test-wayland test-mutter test-xkb-native test-install-user bench-renderer bench-advance bench-compiler-flags locale-packs check strip-binary inspect install install-user uninstall-user

all: strip-binary

$(APP_BINARY): $(OBJECTS)
	@mkdir -p $(@D)
	$(APP_LINKER) $(APP_LDFLAGS) -o $@ $(OBJECTS)

$(TEST_APP_BINARY): $(TEST_OBJECTS)
	@mkdir -p $(@D)
	$(TEST_LINKER) $(TEST_LDFLAGS) -o $@ $(TEST_OBJECTS)

$(BUILD_DIR)/%.o: src/%.S
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

$(TEST_BUILD_DIR)/%.o: src/%.S
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) --defsym NEKOEDIT_TESTING=1 -o $@ $<

$(TEST_BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(TEST_CFLAGS) -DNEKOEDIT_TESTING=1 -c -o $@ $<

$(BUILD_DIR)/backend/clipboard.o $(BUILD_DIR)/editor/history.o: src/editor/gap_buffer.h
$(TEST_BUILD_DIR)/backend/clipboard.o $(TEST_BUILD_DIR)/editor/history.o: src/editor/gap_buffer.h

check: $(APP_BINARY)
	@if $(READELF) -l $(APP_BINARY) | grep -q 'INTERP'; then \
		echo 'error: executable contains a PT_INTERP segment' >&2; exit 1; \
	fi
	@if $(READELF) -d $(APP_BINARY) 2>/dev/null | grep -q 'NEEDED'; then \
		echo 'error: executable has dynamic library dependencies' >&2; exit 1; \
	fi
	@if $(NM) -g --defined-only $(APP_BINARY) | grep -Eq ' (font_probe_|render_(selection|find|document)_scan_|doc_(offset_visual|visual_offset)_scan_|keymap_event_|keyboard_dispatch_|xkb_parse_error_|render_clip_background_row_visits|render_status_scan_steps|render_status_column_value|render_document_byte_visits|render_document_row_visits|render_document_last_row_y|font_ascii_advance_fast_hits)'; then \
		echo 'error: production executable contains test-only instrumentation symbols' >&2; exit 1; \
	fi
	@echo 'ELF check passed: no interpreter, dynamic dependencies, or test instrumentation.'

# Audit first, then remove non-runtime symbol/debug tables from the release ELF.
# --gc-sections already removes unreachable code/data; stripping is a separate step.
strip-binary: check
	$(STRIP) --strip-all $(APP_BINARY)
	@if $(READELF) -S $(APP_BINARY) | grep -q '[.]symtab'; then \
		echo 'error: production executable still contains a full symbol table' >&2; exit 1; \
	fi
	@echo 'Strip check passed: release symbol table removed.'

inspect: strip-binary
	$(READELF) -h $(APP_BINARY)
	$(READELF) -l $(APP_BINARY)
	$(READELF) -d $(APP_BINARY) || true
	$(SIZE) $(APP_BINARY)

test: strip-binary $(ADVANCE_TEST) $(PREFERENCES_TEST) $(HISTORY_TEST) $(CLIPBOARD_RANGE_TEST) $(COMPOSE_LOCALE_MANAGER_TEST) $(COMPOSE_LOCALE_IMPORT_TEST) test-install-user
	sh tests/smoke.sh ./$(APP_BINARY)
	./$(ADVANCE_TEST)
	./$(PREFERENCES_TEST)
	./$(HISTORY_TEST)
	./$(CLIPBOARD_RANGE_TEST)
	$(PYTHON) tests/compose_pack_test.py
	$(PYTHON) tests/compose_import_test.py
	$(PYTHON) tests/user_xcompose_import_test.py
	$(PYTHON) tests/system_xcompose_import_test.py
	$(PYTHON) tests/install_user_xcompose_test.py
	$(PYTHON) tests/compose_locale_data_test.py
	$(PYTHON) tests/compose_locale_manager_test.py ./$(COMPOSE_LOCALE_MANAGER_TEST)
	./$(COMPOSE_LOCALE_IMPORT_TEST)

test-install-user: strip-binary
	sh tests/install_user.sh

$(PREFERENCES_TEST): tests/preferences_test.c src/editor/preferences.c
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o $@ $^

$(HISTORY_TEST): tests/history_test.c src/editor/history.c
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o $@ $^

$(CLIPBOARD_RANGE_TEST): tests/clipboard_range_test.c src/editor/gap_buffer.h
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o $@ $<

test-wayland: $(TEST_APP_BINARY)
	$(PYTHON) tests/wayland_mock.py ./$(TEST_APP_BINARY)

$(RASTERIZER_BENCH): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o "$@" $^

$(RASTERIZER_BENCH_GENERIC): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DFONT_DRAW_GENERIC_REFERENCE -DFONT_DRAW_BLEND_REFERENCE -DFONT_GLYPH_STORAGE_REFERENCE -DFONT_CACHE_AOS_REFERENCE -o "$@" $^

$(RASTERIZER_BENCH_LINEAR): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DFONT_CACHE_LINEAR_REFERENCE -DFONT_DRAW_GENERIC_REFERENCE -DFONT_DRAW_BLEND_REFERENCE -DFONT_GLYPH_STORAGE_REFERENCE -DFONT_CACHE_AOS_REFERENCE -o "$@" $^

$(RASTERIZER_BENCH_IDENTITY_REFERENCE): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DFONT_DRAW_BLEND_REFERENCE -DFONT_GLYPH_STORAGE_REFERENCE -DFONT_CACHE_AOS_REFERENCE -o "$@" $^

$(RASTERIZER_BENCH_STORAGE_REFERENCE): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DFONT_GLYPH_STORAGE_REFERENCE -DFONT_CACHE_AOS_REFERENCE -o "$@" $^

$(RASTERIZER_BENCH_METADATA_REFERENCE): tests/rasterizer_bench.c src/font/rasterizer.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DFONT_CACHE_AOS_REFERENCE -o "$@" $^

$(ADVANCE_TEST): tests/advance_test.c src/font/rasterizer.c src/font/advance.S
	@mkdir -p "$(@D)"
	$(AS) $(ASFLAGS) --defsym NEKOEDIT_TESTING=1 -o "$(BUILD_DIR)/advance_test_advance.o" src/font/advance.S
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DNEKOEDIT_TESTING=1 -o "$@" tests/advance_test.c src/font/rasterizer.c "$(BUILD_DIR)/advance_test_advance.o"

$(ADVANCE_BENCH): tests/advance_bench.c src/font/rasterizer.c src/font/advance.S
	@mkdir -p "$(@D)"
	$(AS) $(ASFLAGS) -o "$(BUILD_DIR)/advance_bench_advance.o" src/font/advance.S
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o "$@" tests/advance_bench.c src/font/rasterizer.c "$(BUILD_DIR)/advance_bench_advance.o"

.PHONY: bench-advance
bench-advance: $(ADVANCE_BENCH)
	./$(ADVANCE_BENCH)

bench-renderer: $(RASTERIZER_BENCH_LINEAR) $(RASTERIZER_BENCH_GENERIC) $(RASTERIZER_BENCH_IDENTITY_REFERENCE) $(RASTERIZER_BENCH_STORAGE_REFERENCE) $(RASTERIZER_BENCH_METADATA_REFERENCE) $(RASTERIZER_BENCH)
	$(PYTHON) tests/compare_rasterizer_bench.py ./$(RASTERIZER_BENCH_LINEAR) ./$(RASTERIZER_BENCH_GENERIC) ./$(RASTERIZER_BENCH_IDENTITY_REFERENCE) ./$(RASTERIZER_BENCH_STORAGE_REFERENCE) ./$(RASTERIZER_BENCH_METADATA_REFERENCE) ./$(RASTERIZER_BENCH)

# Compare compiler optimization levels and safe tuning/LTO candidates on identical workloads.
bench-compiler-flags:
	$(PYTHON) tests/compare_compiler_flags.py "$(CC)" "$(AS)" "$(LD)" "$(STRIP)" "$(NEKOEDIT_BASE_CFLAGS)"

test-xkb-native: $(XKB_NATIVE_KEYMAP_TEST)
	./$(XKB_NATIVE_KEYMAP_TEST)

test-mutter: $(TEST_APP_BINARY) locale-packs
	dbus-run-session -- bash tests/mutter_gnome_smoke.sh "$(TEST_APP_BINARY)" "$(LOCALE_PACK_DIR)/pt_BR.UTF-8.nlp"

install: strip-binary
	install -d "$(DESTDIR)$(PREFIX)/bin" "$(DESTDIR)$(PREFIX)/share/applications" "$(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps"
	install -m 0755 "$(APP_BINARY)" "$(DESTDIR)$(PREFIX)/bin/nekoedit"
	sed 's|@NEKOEDIT_EXEC@|nekoedit|g' data/nekoedit.desktop.in > "$(DESTDIR)$(PREFIX)/share/applications/nekoedit.desktop"
	install -m 0644 data/nekoedit.svg "$(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/nekoedit.svg"

install-user: strip-binary
	install -d "$(USER_BIN_DIR)" "$(USER_APP_DIR)" "$(USER_ICON_DIR)"
	install -m 0755 "$(APP_BINARY)" "$(USER_BIN_DIR)/nekoedit"
	sed 's|@NEKOEDIT_EXEC@|$(USER_BIN_DIR)/nekoedit|g' data/nekoedit.desktop.in > "$(USER_APP_DIR)/nekoedit.desktop"
	chmod 0755 "$(USER_APP_DIR)/nekoedit.desktop"
	install -m 0644 data/nekoedit.svg "$(USER_ICON_DIR)/nekoedit.svg"
	@if command -v gio >/dev/null 2>&1; then gio set "$(USER_APP_DIR)/nekoedit.desktop" metadata::trusted true >/dev/null 2>&1 || true; fi
	@if command -v update-desktop-database >/dev/null 2>&1; then update-desktop-database "$(USER_APP_DIR)" >/dev/null 2>&1 || true; fi
	@if [ "$(MAKE_DEFAULT)" = "1" ] && command -v xdg-mime >/dev/null 2>&1; then xdg-mime default nekoedit.desktop text/plain; fi
	@echo "Installed NekoEdit to $(USER_BIN_DIR)/nekoedit"
	@echo "Desktop launcher: $(USER_APP_DIR)/nekoedit.desktop"
	@if [ "$(MAKE_DEFAULT)" = "1" ]; then echo "NekoEdit is now the default text/plain handler."; else echo "Use Open With > NekoEdit to choose it for text files, or rerun with MAKE_DEFAULT=1 to make it the default."; fi

uninstall-user:
	rm -f "$(USER_BIN_DIR)/nekoedit" "$(USER_APP_DIR)/nekoedit.desktop" "$(USER_ICON_DIR)/nekoedit.svg"
	@if command -v update-desktop-database >/dev/null 2>&1; then update-desktop-database "$(USER_APP_DIR)" >/dev/null 2>&1 || true; fi

clean:
	rm -rf $(BUILD_DIR)

LOCALE_PACK_DIR := $(BUILD_DIR)/locales
LOCALE_TAGS := pt_BR.UTF-8 fi_FI.UTF-8 sr_RS.UTF-8 el_GR.UTF-8 cs_CZ.UTF-8
LOCALE_PACKS := $(addprefix $(LOCALE_PACK_DIR)/,$(addsuffix .nlp,$(LOCALE_TAGS)))

.PHONY: locale-packs
locale-packs: $(LOCALE_PACKS)

$(LOCALE_PACK_DIR)/%.nlp: data/locales/%.json data/locales/%.NOTICE.txt tools/compose_pack.py
	@mkdir -p "$(@D)"
	$(PYTHON) tools/compose_pack.py build --input "$<" --output "$@"
	cp "data/locales/$*.NOTICE.txt" "$(LOCALE_PACK_DIR)/$*.NOTICE.txt"

$(COMPOSE_LOCALE_MANAGER_TEST): tests/compose_locale_manager_test.c src/backend/compose_locale.c src/backend/xkb.S
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o "$@" $^

$(COMPOSE_LOCALE_IMPORT_TEST): tests/compose_locale_import_test.c src/backend/compose_locale.c src/backend/xkb.S
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o "$@" $^

$(XKB_NATIVE_KEYMAP_TEST): tests/xkb_native_keymap_test.c src/backend/xkb.S
	@mkdir -p "$(TEST_BUILD_DIR)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -DNEKOEDIT_TESTING=1 -c -o "$(TEST_BUILD_DIR)/xkb_native_keymap_test.o" "$<"
	$(AS) $(ASFLAGS) --defsym NEKOEDIT_TESTING=1 -o "$(TEST_BUILD_DIR)/xkb_native_keymap.o" "src/backend/xkb.S"
	$(CC) -m64 -O2 -o "$@" "$(TEST_BUILD_DIR)/xkb_native_keymap_test.o" "$(TEST_BUILD_DIR)/xkb_native_keymap.o" -lxkbcommon
