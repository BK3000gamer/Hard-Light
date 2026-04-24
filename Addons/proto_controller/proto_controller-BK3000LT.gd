extends CharacterBody3D

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002

@export_group("Input Actions")
## Name of Input Action to Increase flashlight beam angle.
@export var input_flashlight_beam_up : String = "flashlight_beam_up"
## Name of Input Action to Decrease flashlight beam angle.
@export var input_flashlight_beam_down : String = "flashlight_beam_down"
## Name of Input Action to Increase flashlight intensity.
@export var input_flashlight_intensity_up : String = "flashlight_intensity_up"
## Name of Input Action to Decrease flashlight intensity.
@export var input_flashlight_intensity_down : String = "flashlight_intensity_down"


var mouse_captured : bool = false
var look_rotation : Vector2

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var flashlight : Flashlight = get_node("Head/Camera3D/Flashlight") as Flashlight

func _ready() -> void:
	add_to_group("player")
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _input(event: InputEvent) -> void:
	# Mouse capturing - use _input so HUD clicks don't block capture
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		capture_mouse()
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		release_mouse()

	# Look around - use _input so HUD doesn't block mouse motion
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func _unhandled_input(event: InputEvent) -> void:
	pass


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(input_flashlight_intensity_up) and flashlight.light_intensity < flashlight.FLASHLIGHT_MAX_INTENSITY:
		flashlight.light_intensity += delta * 20

	if Input.is_action_pressed(input_flashlight_intensity_down) and flashlight.light_intensity > flashlight.FLASHLIGHT_MIN_INTENSITY:
		flashlight.light_intensity -= delta * 20

	if Input.is_action_pressed(input_flashlight_beam_up) and flashlight.beam_angle < flashlight.FLASHLIGHT_MAX_BEAM_ANGLE:
		flashlight.beam_angle += 2

	if Input.is_action_pressed(input_flashlight_beam_down) and flashlight.beam_angle > flashlight.FLASHLIGHT_MIN_BEAM_ANGLE:
		flashlight.beam_angle -= 2


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if not InputMap.has_action(input_flashlight_beam_up):
		print("Warning: No input mapping for increasing flashlight beam angle. Action name: " + input_flashlight_beam_up)
	if not InputMap.has_action(input_flashlight_beam_down):
		print("Warning: No input mapping for decreasing flashlight beam angle. Action name: " + input_flashlight_beam_down)
	if not InputMap.has_action(input_flashlight_intensity_up):
		print("Warning: No input mapping for increasing flashlight intensity. Action name: " + input_flashlight_intensity_up)
	if not InputMap.has_action(input_flashlight_intensity_down):
		print("Warning: No input mapping for decreasing flashlight intensity. Action name: " + input_flashlight_intensity_down)
