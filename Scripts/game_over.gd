extends CanvasLayer

func _ready() -> void:
	# Hide post-jumpscare UI until video finishes
	$RestartButton.visible = false
	$MainMenuButton.visible = false

	var monster_type: String = get_meta("monster_type", "unknown")

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
