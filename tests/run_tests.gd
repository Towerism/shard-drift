extends SceneTree
## Headless test runner (ADR 0003). Loads every res://tests/test_*.gd, calls each
## test_* method with this runner as `t`, and quits with 1 if any check failed.

const TEST_DIR := "res://tests/"

var failures: int = 0
var _current: String = ""


func _initialize() -> void:
	var files: PackedStringArray = DirAccess.get_files_at(TEST_DIR)
	files.sort()
	for file: String in files:
		if file.begins_with("test_") and file.ends_with(".gd"):
			_run_file(file)
	print("failures: %d" % failures)
	quit(1 if failures > 0 else 0)


func _run_file(file: String) -> void:
	var script: GDScript = load(TEST_DIR + file) as GDScript
	# A test file with a parse error loads but can't be instantiated; calling new()
	# on it would stop _initialize() before quit() and hang the run.
	if script == null or not script.can_instantiate():
		failures += 1
		printerr("FAIL %s: could not load or instantiate" % file)
		return
	var suite: Object = script.new()
	for method: Dictionary in script.get_script_method_list():
		var name: String = method["name"]
		if name.begins_with("test_"):
			_current = "%s::%s" % [file, name]
			suite.call(name, self)


## Checks equality. Floats and float vectors compare with is_equal_approx.
func eq(actual: Variant, expected: Variant, label: String) -> void:
	var same: bool
	if _is_approx_type(actual) and _is_approx_type(expected):
		same = _approx(actual, expected)
	else:
		same = typeof(actual) == typeof(expected) and actual == expected
	if not same:
		_fail(label, expected, actual)


func ok(condition: bool, label: String) -> void:
	if not condition:
		_fail(label, true, false)


func _fail(label: String, expected: Variant, actual: Variant) -> void:
	failures += 1
	printerr("FAIL %s %s: expected %s, got %s" % [_current, label, expected, actual])


func _is_approx_type(value: Variant) -> bool:
	return typeof(value) in [TYPE_FLOAT, TYPE_VECTOR2]


func _approx(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	if typeof(a) == TYPE_FLOAT:
		return is_equal_approx(a, b)
	return (a as Vector2).is_equal_approx(b)
