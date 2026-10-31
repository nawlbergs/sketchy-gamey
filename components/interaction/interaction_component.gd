class_name InteractionComponent
extends ShapeCast2D
## Finds interactable things in front of its parent. Sweeps a shape rather than a thin ray, because
## with free movement a ray would keep missing things the player is plainly facing.

## How far the shape sweeps from the parent's center.
@export var reach: float = 40.0


func _ready() -> void:
	enabled = false  # Only sweeps when asked, not every physics tick.


## Interacts with the nearest interactable thing in direction. Returns whether there was one.
func try_interact(direction: Vector2) -> bool:
	target_position = direction * reach
	force_shapecast_update()
	var nearest: InteractableComponent = null
	var nearest_distance := INF
	for i in get_collision_count():
		var body := get_collider(i) as Node2D
		if body == null:
			continue
		var interactable := InteractableComponent.find_on(body)
		var distance := global_position.distance_squared_to(body.global_position)
		if interactable and distance < nearest_distance:
			nearest = interactable
			nearest_distance = distance
	if nearest == null:
		return false
	nearest.interact()
	return true
