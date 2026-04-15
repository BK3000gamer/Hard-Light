extends Node3D

class_name Flashlight

@onready var light = get_node("SpotLight3D")

@export var FLASHLIGHT_MAX_BEAM_ANGLE = 35
@export var FLASHLIGHT_MIN_BEAM_ANGLE = 20
@export var FLASHLIGHT_MAX_INTENSITY = 15
@export var FLASHLIGHT_MIN_INTENSITY = 3

var beam_angle = FLASHLIGHT_MIN_BEAM_ANGLE
var light_intensity = FLASHLIGHT_MIN_INTENSITY
var light_battery = 100.0  # Percentage of battery remaining
var reloading = false
var _reload_timer: Timer = null

var light_area: Area3D
var light_cone_shape: ConvexPolygonShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Flashlight ready")
	create_light_area()

func create_light_area():
	light_area = Area3D.new()
	light_area.name = "FlashlightArea"
	light_area.monitoring = true
	light_area.monitorable = true
	light_area.collision_layer = 0
	light_area.collision_mask = 1
	
	# Create a cone shape using ConvexPolygonShape3D
	light_cone_shape = ConvexPolygonShape3D.new()
	var range = max(light.spot_range, 10.0)
	var radius = tan(deg_to_rad(beam_angle / 2)) * range
	
	# Create cone points: tip + 8 points around the base
	var points = PackedVector3Array()
	
	# Tip of the cone (at origin, will be positioned later)
	points.append(Vector3(0, 0, 0))
	
	# Base points in a circle
	for i in range(8):
		var angle = (i / 8.0) * TAU
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector3(x, y, -range))
	
	light_cone_shape.points = points
	
	var shape_node = CollisionShape3D.new()
	shape_node.name = "CollisionShape3D"
	shape_node.shape = light_cone_shape
	# No rotation needed since we built the cone pointing down -Z
	shape_node.position.z = 0  # Tip at flashlight position
	light_area.add_child(shape_node)
	
	add_child(light_area)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_button_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if light_battery > 0 and not reloading:
		light.visible = mouse_button_held
	else:
		light.visible = false

	if light_area:
		light_area.monitoring = mouse_button_held

	if mouse_button_held or InputEventMouseMotion.pressure > 0 and light_battery > 0 and not reloading:
		check_monsters()
		update_light_visuals()
		calculate_battery_drain(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_tablet_input(event)

func handle_tablet_input(event: InputEventMouseMotion):
	light_intensity = lerp(FLASHLIGHT_MIN_INTENSITY, FLASHLIGHT_MAX_INTENSITY, event.pressure)
	light_intensity = clamp(light_intensity, FLASHLIGHT_MIN_INTENSITY, FLASHLIGHT_MAX_INTENSITY)

	var tilt_x = (event.tilt.x + 1) / 2  # Normalize tilt_x from [-1, 1] to [0, 1]
	beam_angle = lerp(FLASHLIGHT_MIN_BEAM_ANGLE, FLASHLIGHT_MAX_BEAM_ANGLE, tilt_x)
	beam_angle = clamp(beam_angle, FLASHLIGHT_MIN_BEAM_ANGLE, FLASHLIGHT_MAX_BEAM_ANGLE)


func check_monsters():
	if not light_area:
		return

	for body in light_area.get_overlapping_bodies():
		if body.is_in_group("monsters"):
			body.react_to_light(light_intensity)

func update_light_visuals():
	light.spot_angle = beam_angle * 0.5 # Adjusted to match the cone shape
	light.light_energy = light_intensity

	var range = max(light.spot_range, 10.0)
	if light_cone_shape:
		var radius = tan(deg_to_rad(beam_angle / 2)) * range
		
		# Recreate cone points
		var points = PackedVector3Array()
		points.append(Vector3(0, 0, 0))  # Tip
		
		# Base points in a circle
		for i in range(8):
			var angle = (i / 8.0) * TAU
			var x = cos(angle) * radius
			var y = sin(angle) * radius
			points.append(Vector3(x, y, -range))
		
		light_cone_shape.points = points

func calculate_battery_drain(delta):
	var drain_rate = 5.0  # Percentage drained per second at full intensity and max beam angle
	var intensity_factor = light_intensity / FLASHLIGHT_MAX_INTENSITY
	var beam_factor = beam_angle / FLASHLIGHT_MAX_BEAM_ANGLE

	var drain_amount = drain_rate * intensity_factor * beam_factor * delta

	light_battery = max(light_battery - drain_amount, 0)
	if light_battery <= 0:
		reload_battery()

func reload_battery():
	print("Reloading...")
	reloading = true
	_reload_timer.start()

func _on_reload_finished():
	light_battery = 100.0
	reloading = false
	print("Battery reloaded!")
