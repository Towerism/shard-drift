class_name DashState
extends RefCounted
## Dash timing. One press starts three timers together: the burst of speed, the
## invulnerable window and the cooldown.

const DASH_TIME := 0.15
const INVULNERABLE_TIME := 0.3
const COOLDOWN := 2.0

var _dash_left: float = 0.0
var _invulnerable_left: float = 0.0
var _cooldown_left: float = 0.0


## Fails while the cooldown runs. The cooldown counts from the press, so the next
## dash is possible COOLDOWN seconds after this one started.
func try_dash() -> bool:
	if _cooldown_left > 0.0:
		return false
	_dash_left = DASH_TIME
	_invulnerable_left = INVULNERABLE_TIME
	_cooldown_left = COOLDOWN
	return true


func tick(delta: float) -> void:
	_dash_left = maxf(0.0, _dash_left - delta)
	_invulnerable_left = maxf(0.0, _invulnerable_left - delta)
	_cooldown_left = maxf(0.0, _cooldown_left - delta)


func is_dashing() -> bool:
	return _dash_left > 0.0


func is_invulnerable() -> bool:
	return _invulnerable_left > 0.0


## 0.0 right after a dash, rising to 1.0 when the next dash is ready.
func cooldown_ratio() -> float:
	return 1.0 - _cooldown_left / COOLDOWN
