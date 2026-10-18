extends CharacterBody2D
## The ship. Flies with ShipMotion, dashes with DashState, and detects its own hits.

signal died

const DASH_ALPHA := 0.5

var dash := DashState.new()
var _dead: bool = false

@onready var visual: Polygon2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("dash") and dash.try_dash():
		velocity = ShipMotion.dash_velocity(velocity, input_dir, Vector2.RIGHT.rotated(rotation))
	elif not dash.is_dashing():
		velocity = ShipMotion.step(velocity, input_dir, delta)
	move_and_slide()
	position = ShipMotion.clamp_to(get_viewport_rect(), position)
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
	dash.tick(delta)
	visual.modulate.a = DASH_ALPHA if dash.is_dashing() else 1.0
	_check_hit()


func dash_ratio() -> float:
	return dash.cooldown_ratio()


## Stops the ship for game over: hidden, no movement, no more hits.
func freeze() -> void:
	_dead = true
	hide()
	set_physics_process(false)
	hurtbox.set_deferred("monitoring", false)


# Polled every frame instead of using area_entered, so a rock still touching the
# ship when invulnerability ends still counts.
func _check_hit() -> void:
	if not _dead and not dash.is_invulnerable() and hurtbox.has_overlapping_areas():
		_dead = true
		died.emit()
