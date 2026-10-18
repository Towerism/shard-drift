extends Node2D
## Runs the game: spawns rocks, scores shards, ends the run and restarts it. This is
## the only script that knows about more than one game object (ADR 0004).

enum State { PLAYING, GAME_OVER }

## Stops a dash pressed at the moment of the hit from restarting the game instantly.
const RESTART_DELAY := 0.5
const ROCK_SCENE: PackedScene = preload("res://scenes/rock.tscn")

var state: State = State.PLAYING
var difficulty := Difficulty.new()
var score: ScoreKeeper
var rng := RandomNumberGenerator.new()
var _died_at_msec: int = 0

@onready var rocks: Node2D = $Rocks
@onready var shard: Shard = $Shard
@onready var player: Player = $Player
@onready var hit_burst: CPUParticles2D = $HitBurst
@onready var camera: ShakeCamera = $Camera2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var hud: HUD = $HUD


func _ready() -> void:
	score = ScoreKeeper.new(BestScoreStore.load_best(BestScoreStore.PATH))
	rng.randomize()
	player.died.connect(_on_player_died)
	shard.collected.connect(_on_shard_collected)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	shard.move_to(SpawnMath.shard_point(_play_field(), player.position, rng))
	spawn_timer.start()
	hud.set_score(score.score)
	hud.set_best(score.best)
	hud.set_dash_ratio(player.dash_ratio())


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	if difficulty.advance(delta):
		spawn_timer.wait_time = difficulty.spawn_interval()
	hud.set_dash_ratio(player.dash_ratio())


func _unhandled_input(event: InputEvent) -> void:
	if state != State.GAME_OVER or not event.is_action_pressed("dash"):
		return
	if Time.get_ticks_msec() - _died_at_msec >= RESTART_DELAY * 1000.0:
		get_tree().reload_current_scene()


func _play_field() -> Rect2:
	return get_viewport_rect()


func _on_spawn_timer_timeout() -> void:
	var field := _play_field()
	var pos := SpawnMath.edge_point(field, rng)
	var direction := SpawnMath.aim(pos, field.get_center(), rng)
	var radius := SpawnMath.rock_radius(rng)
	var rock := ROCK_SCENE.instantiate() as Rock
	rock.setup(pos, direction * difficulty.rock_speed(), radius, SpawnMath.rock_spin(rng),
		SpawnMath.rock_polygon(radius, rng))
	rocks.add_child(rock)


func _on_shard_collected() -> void:
	if state != State.PLAYING:
		return
	score.add_shard()
	shard.move_to(SpawnMath.shard_point(_play_field(), player.position, rng))
	hud.set_score(score.score)
	hud.set_best(score.best)


func _on_player_died() -> void:
	state = State.GAME_OVER
	_died_at_msec = Time.get_ticks_msec()
	spawn_timer.stop()
	player.freeze()
	hit_burst.position = player.position
	hit_burst.emitting = true
	camera.shake()
	var new_best := score.is_new_best()
	if new_best:
		BestScoreStore.save_best(BestScoreStore.PATH, score.best)
	hud.show_game_over(score.score, score.best, new_best)
