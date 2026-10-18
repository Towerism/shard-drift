class_name Difficulty
extends RefCounted
## Steps the game up every STEP_SECONDS: rocks spawn more often and fly faster.

const STEP_SECONDS := 15.0
const BASE_INTERVAL := 1.2
const INTERVAL_STEP := 0.1
const MIN_INTERVAL := 0.4
const BASE_ROCK_SPEED := 180.0
const SPEED_GROWTH := 1.1

var elapsed: float = 0.0
var level: int = 0


## Returns true when this call changed the level, even if it jumped several steps.
func advance(delta: float) -> bool:
	elapsed += delta
	var new_level := int(elapsed / STEP_SECONDS)
	var changed := new_level != level
	level = new_level
	return changed


func spawn_interval() -> float:
	return maxf(MIN_INTERVAL, BASE_INTERVAL - INTERVAL_STEP * level)


## Pixels per second for rocks spawned now.
func rock_speed() -> float:
	return BASE_ROCK_SPEED * pow(SPEED_GROWTH, level)
