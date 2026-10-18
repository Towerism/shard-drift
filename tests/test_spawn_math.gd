extends RefCounted

const FIELD := Rect2(0, 0, 1280, 720)
const RUNS := 200
const EPS := 0.001


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	return rng


func test_edge_points_sit_margin_outside_one_edge(t) -> void:
	var rng := _rng()
	var m := SpawnMath.EDGE_MARGIN
	for i: int in RUNS:
		var p := SpawnMath.edge_point(FIELD, rng)
		var in_x := p.x >= FIELD.position.x - EPS and p.x <= FIELD.end.x + EPS
		var in_y := p.y >= FIELD.position.y - EPS and p.y <= FIELD.end.y + EPS
		var top := is_equal_approx(p.y, FIELD.position.y - m) and in_x
		var bottom := is_equal_approx(p.y, FIELD.end.y + m) and in_x
		var left := is_equal_approx(p.x, FIELD.position.x - m) and in_y
		var right := is_equal_approx(p.x, FIELD.end.x + m) and in_y
		t.ok(top or bottom or left or right, "edge point %s" % p)


func test_aim_is_a_unit_vector_within_spread_of_target(t) -> void:
	var rng := _rng()
	var target := FIELD.get_center()
	for i: int in RUNS:
		var from := SpawnMath.edge_point(FIELD, rng)
		var dir := SpawnMath.aim(from, target, rng)
		t.eq(dir.length(), 1.0, "length")
		var off := absf(dir.angle_to(target - from))
		t.ok(off <= SpawnMath.AIM_SPREAD + EPS, "angle off target %f" % off)


func test_radius_and_spin_stay_in_range(t) -> void:
	var rng := _rng()
	for i: int in RUNS:
		var r := SpawnMath.rock_radius(rng)
		t.ok(r >= SpawnMath.ROCK_RADIUS_MIN and r <= SpawnMath.ROCK_RADIUS_MAX, "radius %f" % r)
		var s := SpawnMath.rock_spin(rng)
		t.ok(absf(s) <= SpawnMath.ROCK_SPIN_MAX, "spin %f" % s)


func test_rock_polygon_points_are_evenly_spaced_and_lumpy(t) -> void:
	var rng := _rng()
	var radius := 30.0
	for i: int in RUNS:
		var poly := SpawnMath.rock_polygon(radius, rng)
		var n := poly.size()
		t.ok(n >= SpawnMath.ROCK_POINTS_MIN and n <= SpawnMath.ROCK_POINTS_MAX, "point count %d" % n)
		for k: int in n:
			var d := poly[k].length()
			t.ok(d >= radius * SpawnMath.ROCK_LUMP_MIN - EPS and d <= radius + EPS, "point distance %f" % d)
			var gap := poly[k].angle_to(poly[(k + 1) % n])
			t.eq(gap, TAU / n, "angle gap")


func test_shard_point_stays_inset_and_away_from_avoid(t) -> void:
	var inner := FIELD.grow(-SpawnMath.SHARD_INSET)
	for avoid: Vector2 in [FIELD.get_center(), FIELD.position]:
		var rng := _rng()
		for i: int in RUNS:
			var p := SpawnMath.shard_point(FIELD, avoid, rng)
			t.ok(_inside(inner, p), "inside inset %s" % p)
			t.ok(p.distance_to(avoid) >= SpawnMath.SHARD_MIN_DIST, "distance from %s" % avoid)


func test_shard_point_falls_back_to_last_try_inside_inset(t) -> void:
	var rng := _rng()
	var small := Rect2(0, 0, 200, 200)
	var inner := small.grow(-SpawnMath.SHARD_INSET)
	for i: int in RUNS:
		var p := SpawnMath.shard_point(small, small.get_center(), rng)
		t.ok(_inside(inner, p), "fallback inside inset %s" % p)


func _inside(rect: Rect2, p: Vector2) -> bool:
	return (p.x >= rect.position.x - EPS and p.x <= rect.end.x + EPS
		and p.y >= rect.position.y - EPS and p.y <= rect.end.y + EPS)
