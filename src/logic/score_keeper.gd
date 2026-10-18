class_name ScoreKeeper
extends RefCounted
## Score for one run, and the best score including this run.

const SHARD_POINTS := 10

var score: int = 0
var best: int = 0
var _starting_best: int = 0


func _init(starting_best: int) -> void:
	best = starting_best
	_starting_best = starting_best


func add_shard() -> void:
	score += SHARD_POINTS
	if score > best:
		best = score


## A tie with the previous best doesn't count.
func is_new_best() -> bool:
	return score > _starting_best
