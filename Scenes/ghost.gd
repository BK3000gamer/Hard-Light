extends Monster

const MONSTER_TYPE = "crawling_ghost"
const SPEED = 3.5

var _surface_normal := Vector3.UP

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

	_detect_surface()

	# Direction to player projected onto the current surface plane
	var to_player = player.global_position - global_position
	var move_dir = to_player - to_player.dot(_surface_normal) * _surface_normal
	if move_dir.length() > 0.1:
		move_dir = move_dir.normalized()

	# Rotate smoothly: forward toward player along surface, up = surface normal
	if move_dir.length() > 0.01 and abs(move_dir.dot(_surface_normal)) < 0.99:
		var target_basis = Basis.looking_at(move_dir, _surface_normal)
		transform.basis = transform.basis.slerp(target_basis, delta * 8.0)

	# Move along surface and press slightly into it to maintain contact
	velocity = move_dir * SPEED + (-_surface_normal * 3.0)
	up_direction = _surface_normal
	move_and_slide()

func _detect_surface() -> void:
	var space_state = get_world_3d().direct_space_state

	# First try directly "below" relative to current surface orientation
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + (-_surface_normal) * 1.5
	)
	query.exclude = [get_rid()]
	var result = space_state.intersect_ray(query)
	if result:
		_surface_normal = result.normal
		return

	# No surface found — scan all 6 axes to find a nearby surface
	for dir in [Vector3.DOWN, Vector3.UP, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]:
		var q = PhysicsRayQueryParameters3D.create(global_position, global_position + dir * 1.5)
		q.exclude = [get_rid()]
		var r = space_state.intersect_ray(q)
		if r:
			_surface_normal = r.normal
			return

func react_to_light(intensity):
	super.react_to_light(intensity)

func get_monster_type() -> String:
	return MONSTER_TYPE

# Gaussian bell curve peaking at mid-intensity (9)
# intensity range: 3 (dim) to 15 (bright)
# at dim(3): ~2 damage, at mid(9): 15 damage, at bright(15): ~2 damage
func calculate_damage(intensity: float) -> float:
	return 15.0 * exp(-pow(intensity - 9.0, 2.0) / 18.0)

