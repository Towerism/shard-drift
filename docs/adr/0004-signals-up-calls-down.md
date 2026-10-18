# ADR 0004: main.gd coordinates; signals up, calls down

- Status: Accepted (2026-10-18)
- Date: 2026-10-17

## Decision

`main.gd` is the only script that knows about more than one game object. Child scenes report events with signals (`Player.died`, `Shard.collected`, `SpawnTimer.timeout`), and `main.gd` responds by calling methods on its children (`player.freeze()`, `shard.move_to()`, `hud.set_score()`). Children never call their siblings or their parent. There are no autoload singletons.

## Context

The game has five scenes and one flow: play, die, restart. A central coordinator makes every interaction visible in one file, which matters when one conversation writes everything and has to keep it consistent. Restart is `get_tree().reload_current_scene()`, which resets every node for free and only works cleanly if no state lives in autoloads.

## Options considered

- **One coordinator, signals up, calls down (chosen).** Easy to follow, easy to restart.
- **Global event bus autoload.** Useful when many unrelated systems talk to each other. Here it would hide five connections behind indirection and survive scene reloads, which makes restart bugs more likely.
- **Children find each other through groups.** Short to write, but creates hidden links between scenes.

## Consequences

- The player detects its own hits through a `Hurtbox` area and decides whether it's invulnerable. Rocks contain no code about the player.
- The HUD (heads-up display) only displays what it's told; it emits nothing. Restart input is read by `main.gd` in the `GAME_OVER` state.
- The best score survives a restart because it's saved to `user://best.txt` before the reload and read again in `_ready()`.
