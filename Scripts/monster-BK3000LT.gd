extends CharacterBody3D
class_name Monster


var health = 1000
var dying := false
var _caught_player := false

const CATCH_DISTANCE = 2.0

# Reference to the visual node (Sprite3D)
var sprite_node: Node = null

# Timer for glow effect
var _glow_timer: Timer = null

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	add_to_group("monsters")
	# Find the Sprite3D child (if any)
	sprite_node = get_node_or_null("Sprite3D")
	# Add a timer for glow effect
	_glow_timer = Timer.new()
	_glow_timer.one_shot = true
	_glow_timer.wait_time = 0.15
	_glow_timer.connect("timeout", Callable(self, "_on_glow_timeout"))
	add_child(_glow_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dying or _caught_player:
		return
	var player = get_player()
	if player and global_position.distance_to(player.global_position) < CATCH_DISTANCE:
		catch_player()

# Trigger game over when the monster reaches the player
func catch_player() -> void:
	_caught_player = true
	var main = get_tree().get_root().get_node_or_null("Main")
	if main and main.has_method("trigger_game_over"):
		main.trigger_game_over(get_monster_type())

# Override in subclasses to return the monster's type string
func get_monster_type() -> String:
	return "unknown"

# Returns the player node
func get_player() -> Node3D:
	return get_tree().get_first_node_in_group("player") as Node3D

# Override this in subclasses to change how much damage a given intensity deals
func calculate_damage(intensity: float) -> float:
	return intensity

# How the monster reacts to taking light damage
func react_to_light(intensity):
	var damage = calculate_damage(intensity)
	health -= damage

	# Glow red when taking damage
	if sprite_node:
		sprite_node.modulate = Color(1, 0.7, 0.7)
		if _glow_timer.is_stopped():
			_glow_timer.start()

	if health <= 0:
		die()

# Revert the glow effect
func _on_glow_timeout():
	if sprite_node:
		sprite_node.modulate = Color(1, 1, 1)

# Handle monster death
func die():
	print("Monster died")
	dying = true
	velocity = Vector3.ZERO
	remove_from_group("monsters")
	if sprite_node:
		var tween = create_tween()
		tween.tween_property(sprite_node, "modulate:a", 0.0, 0.7)
		tween.connect("finished", Callable(self, "_on_fade_out_finished"))
	else:
		queue_free()

# Called when fade-out is done
func _on_fade_out_finished():
	queue_free()

