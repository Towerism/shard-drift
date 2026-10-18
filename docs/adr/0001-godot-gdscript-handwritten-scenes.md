# ADR 0001: Godot 4.7, typed GDScript, hand-written scene files

- Status: Accepted (2026-10-18)
- Date: 2026-10-17

## Decision

Build Shard Drift with Godot 4.7 and statically typed GDScript. Write `project.godot` and every `.tscn` file as text, without opening the Godot editor.

## Context

One Claude Code conversation builds the whole game from a terminal. It can't click through the editor, so anything that needs the editor is a step it can't do. Godot 4.7.2 is installed at `/usr/bin/godot`. The game is a single screen with five small scenes, so the scene files stay short enough to write and review by hand.

## Options considered

- **GDScript, hand-written scenes (chosen).** No build step, no extra install, and scene files are plain text the conversation can read and diff.
- **C# with Godot .NET.** Needs the .NET build of Godot and Microsoft's .NET software development kit, adds a compile step, and gives nothing this game needs.
- **Build the scenes in code from `_ready()`.** Avoids `.tscn` syntax but hides the node tree from anyone who opens the project in the editor later, and makes the art swap in ADR 0005 harder.

## Consequences

- Scene files use `format=3` and need correct `ext_resource` and `sub_resource` IDs. `tests/test_scenes.gd` loads every scene so a typo fails the check instead of showing up at runtime.
- Typed GDScript turns many mistakes into parse errors, which `tests/check.sh` catches.
- Someone can still open the project in the editor later; nothing depends on it never being opened.
