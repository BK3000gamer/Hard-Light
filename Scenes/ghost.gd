extends Monster

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

const MONSTER_TYPE = "ghost"

@export var speed = 2.4
@export var initial_health = 1000

var catched := false

var surface_mode = "floor"
var _surface_normal = Vector3.UP
var path: Path3D = null
var progress: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = initial_health
	super()
	monster_type = MONSTER_TYPE

func _physics_process(delta: float) -> void:
	if dying or not path:
		return
	var player = get_player()
	if not player:
		return

	progress += speed * delta

	var curve = path.curve
	var path_length = curve.get_baked_length()

	# Loop or clamp
	var distance = progress
	if distance > path_length:
		if catched == false:
			catch_player()
			catched = true
		return

	var position_on_path = curve.sample_baked(distance)
	global_position = position_on_path

	var to_player = (player.global_position - global_position).normalized()

	# Rotate smoothly: forward toward player along surface, up = surface normal
	var target_basis = Basis.looking_at(to_player, -_surface_normal)
	transform.basis = transform.basis.slerp(target_basis, 0.1)

func set_surface(mode: String) -> void:
	surface_mode = mode

	match surface_mode:
		"left_wall":
			_surface_normal = Vector3.RIGHT
		"right_wall":
			_surface_normal = Vector3.LEFT

func set_path(new_path: Path3D) -> void:
	path = new_path
	progress = 0.0

func react_to_light(intensity):
	super.react_to_light(intensity)

func get_monster_type() -> String:
	return MONSTER_TYPE

# Gaussian bell curve peaking at mid-intensity (9)
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): ~2 damage, at mid(9): 15 damage, at bright(15): ~2 damage
func calculate_damage(intensity: float) -> float:
	return 15.0 * exp(-pow(intensity - 9.0, 2.0) / 18.0)
