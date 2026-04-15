extends Monster

const MONSTER_TYPE = "vampire"
const GRAVITY = 9.8

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var speed = 2.0
@export var initial_health = 1500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = initial_health
	super()

func _physics_process(delta: float) -> void:
	if dying:
		return
	var player = get_player()
	if not player or not _nav_agent:
		return

	_nav_agent.target_position = player.global_position

	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	# Follow nav path toward player
	if not _nav_agent.is_navigation_finished():
		var next_pos = _nav_agent.get_next_path_position()
		var dir = (next_pos - global_position)
		dir.y = 0.0
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func react_to_light(intensity):
	super.react_to_light(intensity)

func get_monster_type() -> String:
	return MONSTER_TYPE

# Quadratic curve: deals heavy damage at high intensity, little at low
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): ~0.6 damage, at bright(15): 15 damage
func calculate_damage(intensity: float) -> float:
	return (intensity * intensity) / 15.0
