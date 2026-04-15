extends Node3D

var _game_over_triggered := false

func trigger_game_over(monster_type: String) -> void:
	if _game_over_triggered:
		return
	_game_over_triggered = true

	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var game_over = load("res://Scenes/game_over.tscn").instantiate()
	game_over.set_meta("monster_type", monster_type)
	add_child(game_over)

func _process(delta: float) -> void:
	pass
