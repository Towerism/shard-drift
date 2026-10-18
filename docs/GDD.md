# Shard Drift

A top-down arcade dodger for Godot 4. You fly a small ship around one screen, grab glowing shards for points, and avoid rocks that drift in from the edges. Rocks get faster and more frequent the longer you survive. One hit ends the run. A run lasts one to three minutes, so "one more try" is cheap.

I picked this because every part is a few lines of GDScript on stock nodes, with no tilemaps, pathfinding, animation trees or save system to eat the time budget.

## Core loop

1. Move with WASD or arrow keys. The ship has a little inertia, so it feels like drifting instead of snapping.
2. A shard sits somewhere on screen. Touch it for +10 points and it respawns at a random spot.
3. Rocks spawn just off screen every 1.2 s, aimed loosely at the center, and travel in a straight line.
4. Every 15 s the difficulty steps up: spawn interval drops by 0.1 s (floor 0.4 s) and rock speed rises 10%.
5. Press Space to dash: a short burst of speed with 0.3 s of invulnerability, then a 2 s cooldown. This is the one skill move, and it's what makes near misses fun.
6. Touch a rock and the run ends. Show score and best score, and press Space to restart.

## Scenes and scripts

| Scene | Root node | Job |
|---|---|---|
| `main.tscn` | Node2D | Spawns rocks on a Timer, moves the shard, tracks score and difficulty, handles game over |
| `player.tscn` | CharacterBody2D | Movement with acceleration and friction, dash, emits `died` signal |
| `rock.tscn` | Area2D | Moves in a straight line, random size and spin, frees itself on `VisibleOnScreenNotifier2D.screen_exited` |
| `shard.tscn` | Area2D | Pulses in scale with a Tween, emits `collected` when the player enters |
| `hud.tscn` | CanvasLayer | Score label, best score, dash cooldown bar, game-over panel |

That's five scenes and about 200 lines of GDScript in total. Best score goes in `user://best.txt` with `FileAccess`, which is four lines.

## Art and sound

The game should run with zero downloads, so the default look uses shapes Godot already has:

- Ship: a `Polygon2D` triangle in cyan.
- Rocks: a `Polygon2D` with 7 to 9 points at random radii, which looks like a lumpy asteroid, in grey.
- Shard: a small diamond `Polygon2D` in yellow, with a `CPUParticles2D` sparkle.
- Background: a dark `ColorRect` plus a `CPUParticles2D` star field drifting slowly.
- Hit effect: a one-shot `CPUParticles2D` burst and a short camera shake.

If you want real sprites, use the Kenney "Space Shooter Redux" pack (CC0, free from kenney.nl). Kenney packs also show up in Godot's Asset Library (the AssetLib tab in the editor), but what's listed there changes, so check before relying on a specific one. The swap is one texture per scene: replace each `Polygon2D` with a `Sprite2D` and keep the collision shapes. Kenney also has free CC0 sound packs ("Sci-fi Sounds", "Interface Sounds") for pickup, dash and explosion sounds, played through `AudioStreamPlayer`.

## Building it

[architecture.md](architecture.md) has the file layout, every tuning number, the build order and the test command. Where it differs from this document, it wins.

## Out of scope

Menus beyond the game-over panel, multiple levels, power-ups, enemies that shoot, mobile controls and online leaderboards. Each one is a good next step after the first build, and each would break the 30-minute budget.
