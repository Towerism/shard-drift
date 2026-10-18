# ADR 0005: Polygon2D art first, sprites optional

- Status: Accepted (2026-10-18)
- Date: 2026-10-17

## Decision

Draw the ship, rocks, shard and effects with `Polygon2D`, `ColorRect` and particle nodes. Ship no image or sound files in the first build. Sprites from a CC0 pack such as Kenney's "Space Shooter Redux" (kenney.nl) can replace each `Polygon2D` later with a `Sprite2D`, keeping the same collision shapes and scripts.

## Context

The build runs from a terminal with no editor, so the Godot Asset Library tab isn't available. Downloading packs from scripts adds a network step and licence checks to a 30-minute budget. Rocks look better with random outlines anyway, and `SpawnMath.rock_polygon()` already generates them.

## Options considered

- **Shapes and particles now, sprites later (chosen).** No downloads, nothing to licence, and every rock looks different.
- **Download Kenney sprites at the start.** Looks more polished but adds a download, an import step and file layout decisions before any gameplay exists.
- **Use only Godot's `icon.svg`.** Works, but one image for everything reads poorly in play.

## Consequences

- Each scene has one visual node (`Polygon2D`) separate from its `CollisionShape2D`, so swapping in a sprite touches one node.
- No sound in the first build. Adding it means an `AudioStreamPlayer` per sound and calls from `main.gd`, which is a separate change.
