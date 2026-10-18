class_name ShipMotion
extends RefCounted
## Ship movement with a little inertia: it speeds up and slows down instead of snapping.

const MAX_SPEED := 420.0 ## pixels per second
const ACCELERATION := 2400.0 ## pixels per second squared
const FRICTION := 1800.0 ## pixels per second squared
const DASH_SPEED := 900.0 ## pixels per second
const SCREEN_PADDING := 16.0 ## pixels


## One frame of normal flight. Not used while dashing; afterwards it brings the dash
## speed back down to MAX_SPEED.
static func step(velocity: Vector2, input_dir: Vector2, delta: float) -> Vector2:
	if input_dir == Vector2.ZERO:
		return velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	return velocity.move_toward(input_dir.normalized() * MAX_SPEED, ACCELERATION * delta)


static func dash_velocity(_velocity: Vector2, input_dir: Vector2, facing: Vector2) -> Vector2:
	var direction := input_dir if input_dir != Vector2.ZERO else facing
	return direction.normalized() * DASH_SPEED


static func clamp_to(rect: Rect2, pos: Vector2) -> Vector2:
	var inner := rect.grow(-SCREEN_PADDING)
	return pos.clamp(inner.position, inner.end)
