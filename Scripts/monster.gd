extends Node
class_name Monster

var health = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("monsters")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func react_to_light(intensity):
	var damage = intensity
	health -= damage
	print("Monster hit by light! Health: ", health)

	if health <= 0:
		die()

func die():
	print("Monster died")
	queue_free()

