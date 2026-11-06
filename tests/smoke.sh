#!/bin/sh
set -eu

binary=${1:-build/nekoedit}

help_output=$("$binary" --help)
printf '%s\n' "$help_output" | grep -q 'NekoEdit'
printf '%s\n' "$help_output" | grep -q -- '--help'

version_output=$("$binary" --version)
printf '%s\n' "$version_output" | grep -q '0.0.1-dev'

set +e
unknown_output=$("$binary" --definitely-unknown 2>&1)
unknown_status=$?
set -e
[ "$unknown_status" -eq 64 ]
printf '%s\n' "$unknown_output" | grep -q 'unknown argument'

set +e
startup_output=$("$binary" 2>&1)
startup_status=$?
set -e
[ "$startup_status" -eq 2 ]
printf '%s\n' "$startup_output" | grep -q 'no graphical backend yet'

echo 'Smoke tests passed.'
