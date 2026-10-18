extends RefCounted

const DT := 1.0 / 60.0
const FIELD := Rect2(0, 0, 1280, 720)


func test_input_accelerates_up_to_max_speed(t) -> void:
	var v := ShipMotion.step(Vector2.ZERO, Vector2.RIGHT, DT)
	t.eq(v, Vector2(ShipMotion.ACCELERATION * DT, 0.0), "first frame")
	for i: int in 120:
		v = ShipMotion.step(v, Vector2.RIGHT, DT)
	t.eq(v, Vector2(ShipMotion.MAX_SPEED, 0.0), "capped")


func test_diagonal_input_is_capped_at_max_speed(t) -> void:
	var v := Vector2.ZERO
	for i: int in 120:
		v = ShipMotion.step(v, Vector2(1, 1), DT)
	t.eq(v.length(), ShipMotion.MAX_SPEED, "diagonal speed")


func test_friction_slows_to_exactly_zero(t) -> void:
	var start := Vector2(ShipMotion.MAX_SPEED, 0.0)
	var v := ShipMotion.step(start, Vector2.ZERO, DT)
	t.eq(v, Vector2(ShipMotion.MAX_SPEED - ShipMotion.FRICTION * DT, 0.0), "first frame")
	for i: int in 120:
		v = ShipMotion.step(v, Vector2.ZERO, DT)
	t.ok(v == Vector2.ZERO, "stopped exactly, got %s" % v)


func test_dash_goes_along_input_at_dash_speed(t) -> void:
	var v := ShipMotion.dash_velocity(Vector2(100, 0), Vector2(0, 0.5), Vector2.RIGHT)
	t.eq(v, Vector2(0, ShipMotion.DASH_SPEED), "short input normalized")


func test_dash_without_input_goes_along_facing(t) -> void:
	var v := ShipMotion.dash_velocity(Vector2.ZERO, Vector2.ZERO, Vector2(0, -3))
	t.eq(v, Vector2(0, -ShipMotion.DASH_SPEED), "facing normalized")


func test_clamp_keeps_padding_inside_every_side(t) -> void:
	var pad := ShipMotion.SCREEN_PADDING
	t.eq(ShipMotion.clamp_to(FIELD, Vector2(-50, -50)), Vector2(pad, pad), "top left")
	t.eq(ShipMotion.clamp_to(FIELD, Vector2(5000, 5000)), FIELD.end - Vector2(pad, pad), "bottom right")
	t.eq(ShipMotion.clamp_to(FIELD, Vector2(640, 360)), Vector2(640, 360), "inside unchanged")
