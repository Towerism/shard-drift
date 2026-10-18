class_name SpawnMath
extends RefCounted
## Where rocks and shards appear, and what rocks look like. Every function takes the
## random number generator so tests can pass a seeded one.

const EDGE_MARGIN := 60.0
const AIM_SPREAD := 0.35 ## radians
const ROCK_RADIUS_MIN := 18.0
const ROCK_RADIUS_MAX := 42.0
const ROCK_SPIN_MAX := 2.0 ## radians per second
const SHARD_INSET := 60.0
const SHARD_MIN_DIST := 200.0
const ROCK_POINTS_MIN := 7
const ROCK_POINTS_MAX := 9
const ROCK_LUMP_MIN := 0.7
const SHARD_TRIES := 20


## A point EDGE_MARGIN outside a random edge of rect, anywhere along that edge.
static func edge_point(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var x := rng.randf_range(rect.position.x, rect.end.x)
	var y := rng.randf_range(rect.position.y, rect.end.y)
	match rng.randi_range(0, 3):
		0:
			return Vector2(x, rect.position.y - EDGE_MARGIN)
		1:
			return Vector2(x, rect.end.y + EDGE_MARGIN)
		2:
			return Vector2(rect.position.x - EDGE_MARGIN, y)
		_:
			return Vector2(rect.end.x + EDGE_MARGIN, y)


static func aim(from: Vector2, target: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var spread := rng.randf_range(-AIM_SPREAD, AIM_SPREAD)
	return from.direction_to(target).rotated(spread)


static func rock_radius(rng: RandomNumberGenerator) -> float:
	return rng.randf_range(ROCK_RADIUS_MIN, ROCK_RADIUS_MAX)


static func rock_spin(rng: RandomNumberGenerator) -> float:
	return rng.randf_range(-ROCK_SPIN_MAX, ROCK_SPIN_MAX)


## Points evenly spaced by angle, each at a random 70-100% of radius, so every rock
## has a different lumpy outline.
static func rock_polygon(radius: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var count := rng.randi_range(ROCK_POINTS_MIN, ROCK_POINTS_MAX)
	var points := PackedVector2Array()
	for i: int in count:
		var distance := radius * rng.randf_range(ROCK_LUMP_MIN, 1.0)
		points.append(Vector2.from_angle(TAU * i / count) * distance)
	return points


## A random point inside rect shrunk by SHARD_INSET, at least SHARD_MIN_DIST from
## avoid. After SHARD_TRIES misses it returns the last try, which may be closer.
static func shard_point(rect: Rect2, avoid: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var inner := rect.grow(-SHARD_INSET)
	var point := inner.get_center()
	for i: int in SHARD_TRIES:
		point = Vector2(
			rng.randf_range(inner.position.x, inner.end.x),
			rng.randf_range(inner.position.y, inner.end.y))
		if point.distance_to(avoid) >= SHARD_MIN_DIST:
			break
	return point
