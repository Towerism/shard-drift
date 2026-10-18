# ADR 0002: Game rules in node-free classes

- Status: Accepted (2026-10-18)
- Date: 2026-10-17

## Decision

Every rule with a number in it lives in a class under `src/logic/`. That covers difficulty steps, scoring, ship movement, dash timing, spawn positions, rock shapes and best-score storage. These classes extend `RefCounted` and never touch nodes, input or the scene tree. Scene scripts call these classes and handle only nodes, signals and drawing.

## Context

The build follows test-driven development: a failing test before each piece of code. Tests for node scripts need a running scene tree, physics frames and input, which are slow and awkward to drive headless. Plain classes can be tested with direct calls. Randomness is the other obstacle, so every random function takes a `RandomNumberGenerator`, and tests pass one with a fixed seed.

## Options considered

- **Node-free logic classes (chosen).** Fast, exact tests. Costs a few extra files.
- **Rules inside scene scripts, tested by running scenes.** Fewer files, but tests depend on frame timing and are much harder to write in a 30-minute build.
- **No unit tests, playtest only.** Fastest to write, but a broken difficulty curve or dash timer only shows up when a person notices it.

## Consequences

- Six small classes: `Difficulty`, `ScoreKeeper`, `BestScoreStore`, `SpawnMath`, `ShipMotion`, `DashState`. Their interfaces are listed in `docs/architecture.md`.
- Tuning numbers are `const` values at the top of each class. Tests read the constants, so retuning doesn't break tests that only check behavior.
- Scene scripts stay thin enough that the scene-load test, the 300-frame run and playtesting cover them.
