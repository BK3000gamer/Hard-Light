extends CanvasLayer

@onready var flashlight : Flashlight = $"../Head/Camera3D/Flashlight"
@onready var battery_level : ProgressBar = $Control/BatteryLevel

func _process(delta: float) -> void:
	battery_level.value = flashlight.light_battery
