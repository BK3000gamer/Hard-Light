extends Monster

const MONSTER_TYPE = "moth"

@export var speed = 3.5
@export var initial_health = 900

var _wander_offset := Vector3.ZERO
var _wander_timer: Timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = initial_health
	_wander_timer = Timer.new()
	_wander_timer.wait_time = 0.6
	_wander_timer.one_shot = false
	_wander_timer.connect("timeout", Callable(self, "_on_wander_tick"))
	add_child(_wander_timer)
	super()
	_wander_timer.start()
	monster_type = MONSTER_TYPE

func _on_wander_tick() -> void:
	_wander_offset = Vector3(
		randf_range(-4.0, 4.0),
		randf_range(-1.2, 1.2),
		randf_range(-4.0, 4.0)
	)

func _physics_process(delta: float) -> void:
	if dying:
		return
	var player = get_player()
	if not player:
		return

	var target = player.global_position + _wander_offset
	var dir = (target - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

func react_to_light(intensity):
	super.react_to_light(intensity)

func get_monster_type() -> String:
	return MONSTER_TYPE

# Linear inverse curve: deals heavy damage at low intensity, little at high
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): 15 damage, at bright(15): 3 damage
func calculate_damage(intensity: float) -> float:
	return 18.0 - intensity
