extends Node3D

@export var vampire_scene: PackedScene
@export var ghost_scene: PackedScene
@export var moth_scene: PackedScene

@export var spawn_interval: float = 3.0

func _ready() -> void:
	spawn_loop()

func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_monster()

func spawn_monster() -> void:
	if not vampire_scene or not ghost_scene or not moth_scene:
		print("Error: One or more monster scenes not assigned in SpawnManager.")
		return
	var monster_type = randi() % 3

	match monster_type:
		0:
			spawn_vampire()
		1:
			# spawn_ghost()
			spawn_vampire() # Temporary: spawn vampire instead of ghost until ghost is implemented
		2:
			# spawn_moth()
			spawn_vampire() # Temporary: spawn vampire instead of moth until moth is implemented

func spawn_vampire() -> void:
	var path: Path3D = null

	var paths = get_tree().get_nodes_in_group("floor_path")
	path = paths.pick_random()

	var vampire = vampire_scene.instantiate()
	position = path.curve.sample_baked(0)
	vampire.global_position = position + Vector3(0, 2, 0)
	vampire.set_path(path)
	add_child(vampire)

func spawn_moth() -> void:
	var spawn_points = get_tree().get_nodes_in_group("air_spawn")
	var point = spawn_points.pick_random()

	var moth = moth_scene.instantiate()
	moth.global_transform = point.global_transform
	add_child(moth)

func spawn_ghost():
	var spawn_surface

	var roll = randf()

	if roll < 0.5: 
		spawn_surface = "left_wall"
	else:
		spawn_surface = "right_wall"

	var group_name = ""
	var path: Path3D = null
	match spawn_surface:
		"left_wall":
			group_name = "wall_spawn_left"
			var paths = get_tree().get_nodes_in_group("wall_path_left")
			path = paths.pick_random()
		"right_wall":
			group_name = "wall_spawn_right"
			var paths = get_tree().get_nodes_in_group("wall_path_right")
			path = paths.pick_random()

	var ghost = ghost_scene.instantiate()
	ghost.global_position = path.curve.sample_baked(0)
	ghost.set_surface(spawn_surface)
	ghost.set_path(path)

	add_child(ghost)
