extends RefCounted

const PATH := "user://test_best.txt"


func test_saved_value_loads_back(t) -> void:
	_remove()
	BestScoreStore.save_best(PATH, 120)
	t.eq(BestScoreStore.load_best(PATH), 120, "round trip")
	_remove()


func test_missing_file_loads_zero(t) -> void:
	_remove()
	t.eq(BestScoreStore.load_best(PATH), 0, "missing")


func test_surrounding_whitespace_is_ignored(t) -> void:
	_write(" 7\n")
	t.eq(BestScoreStore.load_best(PATH), 7, "padded number")
	_remove()


func test_bad_contents_load_zero(t) -> void:
	for text: String in ["", "abc", "12abc", "-5", "99999999999999999999"]:
		_write(text)
		t.eq(BestScoreStore.load_best(PATH), 0, "contents '%s'" % text)
	_remove()


func _write(text: String) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _remove() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
