class_name InteractableComponent
extends Node
## Marks its parent as something the player can interact with. The parent's physics body is what
## the player's InteractionComponent detects. Connect to interacted to decide what happens.

signal interacted


## Returns the component on node, or null if node is not interactable.
static func find_on(node: Node) -> InteractableComponent:
	for child: Node in node.get_children():
		if child is InteractableComponent:
			return child
	return null


func interact() -> void:
	interacted.emit()
