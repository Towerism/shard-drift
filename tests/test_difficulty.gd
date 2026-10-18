extends RefCounted


func test_starts_at_level_zero(t) -> void:
	var d := Difficulty.new()
	t.eq(d.elapsed, 0.0, "elapsed")
	t.eq(d.level, 0, "level")
	t.eq(d.spawn_interval(), Difficulty.BASE_INTERVAL, "interval")
	t.eq(d.rock_speed(), Difficulty.BASE_ROCK_SPEED, "speed")


func test_advance_reports_only_the_call_that_changes_level(t) -> void:
	var d := Difficulty.new()
	var half := Difficulty.STEP_SECONDS / 2.0
	t.eq(d.advance(half), false, "first half step")
	t.eq(d.level, 0, "level after half step")
	t.eq(d.advance(half), true, "reaching the step")
	t.eq(d.level, 1, "level after one step")
	t.eq(d.advance(0.5), false, "small delta after the step")
	t.eq(d.level, 1, "level unchanged")


func test_huge_delta_crossing_two_steps_reports_once(t) -> void:
	var d := Difficulty.new()
	t.eq(d.advance(Difficulty.STEP_SECONDS * 2.5), true, "one report")
	t.eq(d.level, 2, "level")
	t.eq(d.elapsed, Difficulty.STEP_SECONDS * 2.5, "elapsed")


func test_spawn_interval_drops_per_level_down_to_floor(t) -> void:
	var d := Difficulty.new()
	d.advance(Difficulty.STEP_SECONDS * 3.0)
	t.eq(d.spawn_interval(), Difficulty.BASE_INTERVAL - Difficulty.INTERVAL_STEP * 3.0, "level 3")
	d.advance(Difficulty.STEP_SECONDS * 100.0)
	t.eq(d.spawn_interval(), Difficulty.MIN_INTERVAL, "floor")


func test_rock_speed_grows_geometrically(t) -> void:
	var d := Difficulty.new()
	d.advance(Difficulty.STEP_SECONDS * 4.0)
	t.eq(d.rock_speed(), Difficulty.BASE_ROCK_SPEED * pow(Difficulty.SPEED_GROWTH, 4.0), "level 4")
