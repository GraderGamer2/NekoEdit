#!/bin/sh
set -eu

binary=\${1:-build/nekoedit}

help_output=$("$binary" --help)
printf '%s\n' "$help_output" | grep -q 'NekoEdit'
printf '%s\n' "$help_output" | grep -q -- '--backend=wayland'

version_output=$("$binary" --version)
printf '%s\n' "$version_output" | grep -q '0.1.0-dev'

set +e
unknown_output=$("$binary" --definitely-unknown 2>&1)
unknown_status=$?
set -e
[ "$unknown_status" -eq 64 ]
printf '%s\n' "$unknown_output" | grep -q 'unknown argument'

set +e
x11_output=$("$binary" --backend=x11 2>&1)
x11_status=$?
set -e
[ "$x11_status" -eq 69 ]
printf '%s\n' "$x11_output" | grep -q 'X11 backend is not implemented yet'

echo 'Smoke tests passed.'
