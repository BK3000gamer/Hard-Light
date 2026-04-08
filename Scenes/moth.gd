extends Monster

const MONSTER_TYPE = "moth"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func react_to_light(intensity):
	super.react_to_light(intensity)
