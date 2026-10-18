class_name ShakeCamera
extends Camera2D
## Screen shake: a random offset that shrinks linearly to zero.

var _strength: float = 0.0
var _duration: float = 0.0
var _time_left: float = 0.0


func shake(strength: float = 8.0, duration: float = 0.25) -> void:
	_strength = strength
	_duration = duration
	_time_left = duration


func _process(delta: float) -> void:
	if _time_left <= 0.0:
		return
	_time_left = maxf(0.0, _time_left - delta)
	if _time_left == 0.0:
		offset = Vector2.ZERO
		return
	var reach := _strength * _time_left / _duration
	offset = Vector2.from_angle(randf() * TAU) * randf() * reach
