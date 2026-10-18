class_name BestScoreStore
extends RefCounted
## Reads and writes the best score as a number in a text file.

const PATH := "user://best.txt"
## Longer digit strings can overflow a 64-bit int, and to_int() logs an error for them.
const MAX_DIGITS := 18


## Returns 0 unless the file holds one non-negative integer. The player can edit the
## file, so anything else is treated as no best score.
static func load_best(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var text := FileAccess.get_file_as_string(path).strip_edges()
	if text.length() > MAX_DIGITS or not text.is_valid_int():
		return 0
	return maxi(0, text.to_int())


## Returns without writing if the file can't be opened, so a read-only user folder
## costs the best score but never the game.
static func save_best(path: String, value: int) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(str(value))
	file.close()
