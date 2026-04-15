extends Monster

const MONSTER_TYPE = "vampire"
const GRAVITY = 9.8

@export var speed = 2.0
@export var initial_health = 1500

var path: Path3D = null
var progress: float = 0.0
var catched := false

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

func react_to_light(intensity):
	super.react_to_light(intensity)

func set_path(new_path: Path3D) -> void:
	path = new_path
	progress = 0.0

func get_monster_type() -> String:
	return MONSTER_TYPE

# Quadratic curve: deals heavy damage at high intensity, little at low
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): ~0.6 damage, at bright(15): 15 damage
func calculate_damage(intensity: float) -> float:
	return (intensity * intensity) / 15.0
