AS       ?= as
LD       ?= ld
READELF  ?= readelf
PYTHON   ?= python3
CC       ?= cc
CFLAGS   ?= -m64 -O2 -std=c11 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-asynchronous-unwind-tables -fno-unwind-tables -mno-red-zone -fno-tree-loop-distribute-patterns
BUILD_DIR ?= build
APP_BINARY := $(BUILD_DIR)/nekoedit

ASFLAGS  ?= --64 --fatal-warnings
LDFLAGS  ?= -static -no-pie -z noexecstack -e _start

SOURCES  := src/entry.S src/linux/syscall.S src/font/sfnt.S src/backend/wayland.S src/backend/xkb.S
C_SOURCES := src/font/rasterizer.c src/backend/clipboard.c src/editor/history.c
OBJECTS  := $(patsubst src/%.S,$(BUILD_DIR)/%.o,$(SOURCES)) $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

.PHONY: all clean test test-wayland check inspect

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

test: $(APP_BINARY)
	sh tests/smoke.sh ./$(APP_BINARY)

test-wayland: $(APP_BINARY)
	$(PYTHON) tests/wayland_mock.py ./$(APP_BINARY)

clean:
	rm -rf $(BUILD_DIR)
