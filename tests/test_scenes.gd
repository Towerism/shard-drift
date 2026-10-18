extends RefCounted

const SCENE_DIR := "res://scenes/"
const EXPECTED: Array[String] = ["hud.tscn", "main.tscn", "player.tscn", "rock.tscn", "shard.tscn"]
# Bitmask values: layer 1 is 1, layer 2 is 2, layer 3 is 4.
const PLAYER_LAYER := 1
const ROCKS_LAYER := 2
const SHARD_LAYER := 4


func test_every_expected_scene_exists(t) -> void:
	for file: String in EXPECTED:
		t.ok(ResourceLoader.exists(SCENE_DIR + file), "exists " + file)


func test_every_scene_loads_and_instantiates(t) -> void:
	for file: String in DirAccess.get_files_at(SCENE_DIR):
		if not file.ends_with(".tscn"):
			continue
		var node := _instance(file)
		t.ok(node != null, "instantiate " + file)
		if node != null:
			node.free()


func test_collision_layers_connect_ship_rocks_and_shard(t) -> void:
	var player := _instance("player.tscn") as CharacterBody2D
	var rock := _instance("rock.tscn") as Area2D
	var shard := _instance("shard.tscn") as Area2D
	if player == null or rock == null or shard == null:
		t.ok(false, "scenes instantiate")
		return
	var hurtbox := player.get_node("Hurtbox") as Area2D
	t.eq(player.collision_layer, PLAYER_LAYER, "player body layer")
	t.eq(player.collision_mask, 0, "player body mask")
	t.eq(hurtbox.collision_layer, 0, "hurtbox layer")
	t.eq(hurtbox.collision_mask, ROCKS_LAYER, "hurtbox watches rocks")
	t.eq(rock.collision_layer, ROCKS_LAYER, "rock layer")
	t.eq(rock.collision_mask, 0, "rock mask")
	t.eq(shard.collision_layer, SHARD_LAYER, "shard layer")
	t.eq(shard.collision_mask, PLAYER_LAYER, "shard watches player")
	player.free()
	rock.free()
	shard.free()


func _instance(file: String) -> Node:
	var packed := load(SCENE_DIR + file) as PackedScene
	return packed.instantiate() if packed != null else null


func test_main_has_children_in_draw_order(t) -> void:
	var main := _instance("main.tscn")
	if main == null:
		t.ok(false, "main instantiates")
		return
	var names: Array[String] = []
	for child: Node in main.get_children():
		names.append(child.name)
	var expected: Array[String] = ["Background", "Stars", "Rocks", "Shard", "Player",
		"HitBurst", "Camera2D", "SpawnTimer", "HUD"]
	t.eq(names, expected, "children")
	main.free()
