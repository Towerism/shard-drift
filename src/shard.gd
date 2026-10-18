class_name Shard
extends Area2D
## The pickup. Reports when the player touches it; main.gd decides where it goes next.

signal collected

const PULSE_SCALE := 1.25
const PULSE_SECONDS := 0.4

@onready var visual: Polygon2D = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var pulse := create_tween().set_loops()
	pulse.tween_property(visual, "scale", Vector2.ONE * PULSE_SCALE, PULSE_SECONDS)
	pulse.tween_property(visual, "scale", Vector2.ONE, PULSE_SECONDS)


func move_to(pos: Vector2) -> void:
	position = pos


# The shard's mask only includes the player layer, so any body here is the ship.
func _on_body_entered(_body: Node2D) -> void:
	collected.emit()
