extends Control

var main := preload("res://Scenes/main.tscn")
var test := preload("res://Scenes/test_level.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(main)

func _on_test_pressed() -> void:
	get_tree().change_scene_to_packed(test)

func _on_quit_pressed() -> void:
	get_tree().quit()
