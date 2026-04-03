extends Node3D

class_name Flashlight

@onready var light = get_node("SpotLight3D")

var beam_angle = 25.0
var light_intensity = 3.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_button_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	light.visible = mouse_button_held
	
	if mouse_button_held:
		check_monsters()
		update_light_visuals()


func check_monsters():
	for monster in get_tree().get_nodes_in_group("monsters"):
		if is_in_flashlight_cone(monster):
			monster.react_to_light(light_intensity)

func update_light_visuals():
	light.spot_angle = beam_angle * 1.1
	light.light_energy = light_intensity

# Check if the monster is in the flashlight cone
func is_in_flashlight_cone(monster) -> bool:
	# Get the forward direction of the flashlight and the direction to the monster
	var forward = -global_transform.basis.z.normalized()
	var dir_to_monster = (monster.global_transform.origin - global_transform.origin).normalized()

	# Convert direction to monster from forward direction to angle
	var angle = acos(forward.dot(dir_to_monster))

	return angle < deg_to_rad(beam_angle/ 2)
