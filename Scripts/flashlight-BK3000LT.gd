extends Node3D

class_name Flashlight

@onready var light = get_node("SpotLight3D")

@export var FLASHLIGHT_MAX_BEAM_ANGLE = 35
@export var FLASHLIGHT_MIN_BEAM_ANGLE = 20
@export var FLASHLIGHT_MAX_INTENSITY = 15
@export var FLASHLIGHT_MIN_INTENSITY = 3

var beam_angle = 25.0
var light_intensity = 3.0
var debug_enabled = true  # Toggle this to show/hide debug visualization
var use_mesh_debug = true  # Use mesh-based cone debug visualization
var light_battery = 100.0  # Percentage of battery remaining
var reloading = false
var _reload_timer: Timer = null

@onready var debug_cone: MeshInstance3D
var light_area: Area3D
var light_cone_shape: ConvexPolygonShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Flashlight ready")
	create_light_area()
	if use_mesh_debug:
		create_debug_cone()
		print("Debug cone created: ", debug_cone != null)
	_reload_timer = Timer.new()
	_reload_timer.one_shot = true
	_reload_timer.wait_time = 2.0
	_reload_timer.connect("timeout", Callable(self, "_on_reload_finished"))
	add_child(_reload_timer)


# Debug visual to see the flashlight's area
func create_debug_cone():
	debug_cone = MeshInstance3D.new()
	var cone_mesh = CylinderMesh.new()
	cone_mesh.top_radius = 0.0
	
	# Use a default range if light.spot_range is 0
	var range = max(light.spot_range, 10.0)  # Default to 10 if not set
	cone_mesh.bottom_radius = tan(deg_to_rad(beam_angle / 2)) * range
	cone_mesh.height = range
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1, 1, 0, 0.3)  # Yellow semi-transparent
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Make sure both sides are visible
	debug_cone.material_override = material
	debug_cone.mesh = cone_mesh
	
	# Position the cone so the tip is at the flashlight's position
	# In Godot, forward is -Z, so we position it forward and rotate to point that way
	debug_cone.position.z = -range / 2  # Center the cone on the flashlight
	debug_cone.rotation.x = PI / 2  # Rotate to point forward (-Z direction)
	
	add_child(debug_cone)
	debug_cone.visible = false

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
	
	if debug_enabled and use_mesh_debug and debug_cone:
		var was_visible = debug_cone.visible
		debug_cone.visible = mouse_button_held
		if was_visible != debug_cone.visible:
			print("Debug cone visibility changed to: ", debug_cone.visible)

	if light_area:
		light_area.monitoring = mouse_button_held

	if mouse_button_held and light_battery > 0 and not reloading:
		check_monsters()
		update_light_visuals()
		calculate_battery_drain(delta)

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

	if debug_cone and debug_cone.mesh is CylinderMesh:
		debug_cone.mesh.height = range
		debug_cone.position.z = -range / 2
		debug_cone.mesh.bottom_radius = tan(deg_to_rad(beam_angle / 2)) * range

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

