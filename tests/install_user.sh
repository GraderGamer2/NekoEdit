#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temporary_home=$(mktemp -d "${TMPDIR:-/tmp}/nekoedit-install-test.XXXXXX")
cleanup() {
    rm -rf "$temporary_home"
}
trap cleanup EXIT HUP INT TERM

prefix="$temporary_home/.local"
binary="$prefix/bin/nekoedit"
desktop="$prefix/share/applications/nekoedit.desktop"
icon="$prefix/share/icons/hicolor/scalable/apps/nekoedit.svg"

make -C "$repo_dir" install-user USER_PREFIX="$prefix" >/dev/null

test -x "$binary"
test -f "$desktop"
test -f "$icon"
"$binary" --version | grep -F "NekoEdit" >/dev/null
grep -F "Exec=\"$binary\" %f" "$desktop" >/dev/null
grep -F "TryExec=\"$binary\"" "$desktop" >/dev/null
grep -Fx "Terminal=false" "$desktop" >/dev/null
grep -Fx "MimeType=text/plain;" "$desktop" >/dev/null
grep -F "<svg" "$icon" >/dev/null

make -C "$repo_dir" uninstall-user USER_PREFIX="$prefix" >/dev/null
test ! -e "$binary"
test ! -e "$desktop"
test ! -e "$icon"

printf '%s\n' "Per-user executable, desktop launcher, plain-text association metadata, icon, and uninstall tests passed."
