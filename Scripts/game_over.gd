extends CanvasLayer

func _ready() -> void:
	# Hide post-jumpscare UI until video finishes
	$GameOverLabel.visible = false
	$RestartButton.visible = false
	$MainMenuButton.visible = false

	var monster_type: String = get_meta("monster_type", "unknown")
	var stream = load("res://Scenes/jumpscare_" + monster_type + ".ogv")
	if stream:
		$JumpScareVideo.stream = stream
		$JumpScareVideo.connect("finished", Callable(self, "_on_video_finished"))
		$JumpScareVideo.play()
	else:
		# No video yet — skip straight to game over
		$JumpScareVideo.visible = false
		_on_video_finished()

func _on_video_finished() -> void:
	$JumpScareVideo.visible = false
	$GameOverLabel.visible = true
	$RestartButton.visible = true
	$MainMenuButton.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

