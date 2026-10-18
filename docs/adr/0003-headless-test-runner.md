# ADR 0003: Own headless test runner instead of GUT or gdUnit4

- Status: Accepted (2026-10-18)
- Date: 2026-10-17

## Decision

Use a small test runner, `tests/run_tests.gd`, that extends `SceneTree` and runs with `godot --headless --script`. Wrap it, the class import and a 300-frame game run in `tests/check.sh`, which is the one command that decides pass or fail.

## Context

GUT (Godot Unit Test) and gdUnit4 are good Godot test frameworks, but both are add-ons downloaded into `addons/` and enabled as plugins, normally through the editor. This build has no editor and a 30-minute budget. The logic classes from ADR 0002 need only equality checks and a pass/fail exit code.

Trying the runner on 2026-10-17 with Godot 4.7.2 showed three traps:

- Scripts run with `--script` can't see `class_name` classes until `godot --headless --path . --import` has run once.
- A runtime error inside a test, or in the game during `--quit-after`, prints `SCRIPT ERROR` and Godot still exits 0.
- A parse error in a test file makes `new()` fail inside the runner's `_initialize()`, so `quit()` is never reached and the process hangs.

## Options considered

- **Own runner plus `check.sh` (chosen).** No downloads, about 40 lines of GDScript and 20 of shell. It handles all three traps above.
- **GUT or gdUnit4.** Richer assertions and reports, but an install step, plugin setup and more to learn, for tests this simple.

## Consequences

- `check.sh` runs `--import` first, puts every step under `timeout 120`, and fails if the log contains `SCRIPT ERROR` or a line starting with `ERROR:`.
- `run_tests.gd` checks `script.can_instantiate()` before `new()` and counts a failure instead of hanging.
- The first build step adds a deliberately failing test and confirms `check.sh` exits 1, so the build never trusts a runner that can't fail.
- If the project grows past a few dozen tests, moving to GUT is straightforward because tests are already plain methods named `test_*`.
