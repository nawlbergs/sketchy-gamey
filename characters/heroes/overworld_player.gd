class_name OverworldPlayer
extends CharacterBody2D
## The party on the overworld. Moves at any angle, and analog input controls the speed.

@export var speed: float = 300.0

## Direction of the last movement input. Stays put when the player stops.
var facing: Vector2 = Vector2.DOWN

@onready var _camera: Camera2D = %Camera


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		facing = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	# Only while moving, so a player standing still cannot overwrite a position just loaded or reset.
	if direction != Vector2.ZERO:
		GameState.overworld_position = global_position


## Stops the camera showing anything outside bounds.
func set_camera_limits(bounds: Rect2) -> void:
	_camera.limit_left = int(bounds.position.x)
	_camera.limit_top = int(bounds.position.y)
	_camera.limit_right = int(bounds.end.x)
	_camera.limit_bottom = int(bounds.end.y)
