extends Monster

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

const MONSTER_TYPE = "crawling_ghost"
const SPEED = 3.5

var surface_mode = "floor"
var _surface_normal = Vector3.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 1500
	super()

func _physics_process(delta: float) -> void:
	if dying:
		return
	var player = get_player()
	if not player:
		return

	# Direction to player projected onto the current surface plane
	_nav_agent.target_position = player.global_position
	var next_pos = _nav_agent.get_next_path_position()
	var move_dir = (next_pos - global_position)

	# Project onto surface
	# move_dir = move_dir - move_dir.dot(_surface_normal) * _surface_normal

	if move_dir.length() > 0.1:
		move_dir = move_dir.normalized()

	# Rotate smoothly: forward toward player along surface, up = surface normal
	var target_basis = Basis.looking_at(move_dir, _surface_normal)
	transform.basis = transform.basis.slerp(target_basis, delta * 8.0)

	# Move along surface and press slightly into it to maintain contact
	velocity = move_dir * SPEED + (-_surface_normal * 3.0)
	up_direction = _surface_normal
	move_and_slide()

func set_surface(mode: String) -> void:
	surface_mode = mode

	match surface_mode:
		"floor":
			_surface_normal = Vector3.UP
		"left_wall":
			_surface_normal = Vector3.RIGHT
		"right_wall":
			_surface_normal = Vector3.LEFT

func react_to_light(intensity):
	super.react_to_light(intensity)

func get_monster_type() -> String:
	return MONSTER_TYPE

# Gaussian bell curve peaking at mid-intensity (9)
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): ~2 damage, at mid(9): 15 damage, at bright(15): ~2 damage
func calculate_damage(intensity: float) -> float:
	return 15.0 * exp(-pow(intensity - 9.0, 2.0) / 18.0)
