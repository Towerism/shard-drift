#!/usr/bin/env bash
# Runs every headless check. Exits 1 if any step fails, times out or logs a script error,
# because Godot itself exits 0 after most script errors.
set -u
cd "$(dirname "$0")/.."
log=$(mktemp)
status=0
step() {
	echo "== godot $*"
	timeout 120 godot --headless --path . "$@" >"$log" 2>&1
	local code=$?
	grep -E "SCRIPT ERROR|^ERROR:|FAIL|failures:" "$log"
	if [ "$code" -ne 0 ] || grep -qE "SCRIPT ERROR|^ERROR:" "$log"; then
		echo "-> failed (exit $code)"
		status=1
	fi
}
step --import
step --script res://tests/run_tests.gd
step --quit-after 300
rm -f "$log"
exit $status
