extends Area2D
## A rock drifting in a straight line. It holds no rules about the player; the
## player's hurtbox detects it.

## A rock aimed with spread can miss the screen entirely and never leave it, so it
## also frees itself after this many seconds.
const LIFETIME := 12.0
const COLLISION_SCALE := 0.85

var _velocity: Vector2 = Vector2.ZERO
var _radius: float = 0.0
var _spin: float = 0.0
var _polygon: PackedVector2Array = PackedVector2Array()
var _age: float = 0.0
var _has_entered: bool = false

@onready var visual: Polygon2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


## Called before add_child, when the @onready nodes are still null, so it only
## stores values; _ready() applies them.
func setup(pos: Vector2, velocity: Vector2, radius: float, spin: float, polygon: PackedVector2Array) -> void:
	position = pos
	_velocity = velocity
	_radius = radius
	_spin = spin
	_polygon = polygon


func _ready() -> void:
	# Each rock needs its own shape: a shared one would resize every rock at once.
	var shape := CircleShape2D.new()
	shape.radius = _radius * COLLISION_SCALE
	collision.shape = shape
	visual.polygon = _polygon
	notifier.rect = Rect2(-_radius, -_radius, _radius * 2.0, _radius * 2.0)
	notifier.screen_entered.connect(_on_screen_entered)
	notifier.screen_exited.connect(_on_screen_exited)


func _process(delta: float) -> void:
	position += _velocity * delta
	rotation += _spin * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()


func _on_screen_entered() -> void:
	_has_entered = true


# Rocks spawn off screen, so only an exit after entering means the rock is done.
func _on_screen_exited() -> void:
	if _has_entered:
		queue_free()
