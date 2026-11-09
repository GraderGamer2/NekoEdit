AS       ?= as
LD       ?= ld
READELF  ?= readelf
PYTHON   ?= python3
CC       ?= cc
CFLAGS   ?= -m64 -O2 -std=c11 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-asynchronous-unwind-tables -fno-unwind-tables -mno-red-zone -fno-tree-loop-distribute-patterns
BUILD_DIR ?= build
APP_BINARY := $(BUILD_DIR)/nekoedit
PREFERENCES_TEST := $(BUILD_DIR)/preferences_test
HISTORY_TEST := $(BUILD_DIR)/history_test
COMPOSE_LOCALE_MANAGER_TEST := $(BUILD_DIR)/compose_locale_manager_test

PREFIX ?= /usr/local
USER_PREFIX ?= $(HOME)/.local
USER_BIN_DIR ?= $(USER_PREFIX)/bin
USER_APP_DIR ?= $(USER_PREFIX)/share/applications
USER_ICON_DIR ?= $(USER_PREFIX)/share/icons/hicolor/scalable/apps
MAKE_DEFAULT ?= 0

ASFLAGS  ?= --64 --fatal-warnings
LDFLAGS  ?= -static -no-pie -z noexecstack -e _start

SOURCES  := src/entry.S src/linux/syscall.S src/font/sfnt.S src/backend/wayland.S src/backend/xkb.S
C_SOURCES := src/font/rasterizer.c src/backend/clipboard.c src/backend/compose_locale.c src/editor/history.c src/editor/preferences.c
OBJECTS  := $(patsubst src/%.S,$(BUILD_DIR)/%.o,$(SOURCES)) $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

.PHONY: all clean test test-wayland test-install-user locale-packs check inspect install install-user uninstall-user

all: $(APP_BINARY) check

$(APP_BINARY): $(OBJECTS)
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/%.o: src/%.S
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

check: $(APP_BINARY)
	@if $(READELF) -l $(APP_BINARY) | grep -q 'INTERP'; then \
		echo 'error: executable contains a PT_INTERP segment' >&2; exit 1; \
	fi
	@if $(READELF) -d $(APP_BINARY) 2>/dev/null | grep -q 'NEEDED'; then \
		echo 'error: executable has dynamic library dependencies' >&2; exit 1; \
	fi
	@echo 'ELF check passed: no interpreter and no DT_NEEDED entries.'

inspect: $(APP_BINARY)
	$(READELF) -h $(APP_BINARY)
	$(READELF) -l $(APP_BINARY)
	$(READELF) -d $(APP_BINARY) || true

test: $(APP_BINARY) $(PREFERENCES_TEST) $(HISTORY_TEST) $(COMPOSE_LOCALE_MANAGER_TEST) test-install-user
	sh tests/smoke.sh ./$(APP_BINARY)
	./$(PREFERENCES_TEST)
	./$(HISTORY_TEST)
	$(PYTHON) tests/compose_pack_test.py
	$(PYTHON) tests/compose_import_test.py
	$(PYTHON) tests/user_xcompose_import_test.py
	$(PYTHON) tests/install_user_xcompose_test.py
	$(PYTHON) tests/compose_locale_data_test.py
	$(PYTHON) tests/compose_locale_manager_test.py ./$(COMPOSE_LOCALE_MANAGER_TEST)

test-install-user: $(APP_BINARY)
	sh tests/install_user.sh

$(PREFERENCES_TEST): tests/preferences_test.c src/editor/preferences.c
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o $@ $^

$(HISTORY_TEST): tests/history_test.c src/editor/history.c
	@mkdir -p $(@D)
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o $@ $^

test-wayland: $(APP_BINARY)
	$(PYTHON) tests/wayland_mock.py ./$(APP_BINARY)

install: $(APP_BINARY)
	install -d "$(DESTDIR)$(PREFIX)/bin" "$(DESTDIR)$(PREFIX)/share/applications" "$(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps"
	install -m 0755 "$(APP_BINARY)" "$(DESTDIR)$(PREFIX)/bin/nekoedit"
	sed 's|@NEKOEDIT_EXEC@|nekoedit|g' data/nekoedit.desktop.in > "$(DESTDIR)$(PREFIX)/share/applications/nekoedit.desktop"
	install -m 0644 data/nekoedit.svg "$(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/nekoedit.svg"

install-user: $(APP_BINARY)
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
LOCALE_TAGS := pt_BR.UTF-8 fi_FI.UTF-8 sr_RS.UTF-8
LOCALE_PACKS := $(addprefix $(LOCALE_PACK_DIR)/,$(addsuffix .nlp,$(LOCALE_TAGS)))

.PHONY: locale-packs
locale-packs: $(LOCALE_PACKS)

$(LOCALE_PACK_DIR)/%.nlp: data/locales/%.json data/locales/%.NOTICE.txt tools/compose_pack.py
	@mkdir -p "$(@D)"
	$(PYTHON) tools/compose_pack.py build --input "$<" --output "$@"
	cp "data/locales/$*.NOTICE.txt" "$(LOCALE_PACK_DIR)/$*.NOTICE.txt"

$(COMPOSE_LOCALE_MANAGER_TEST): tests/compose_locale_manager_test.c src/backend/compose_locale.c
	@mkdir -p "$(@D)"
	$(CC) -m64 -O2 -std=c11 -Wall -Wextra -Werror -o "$@" $^
