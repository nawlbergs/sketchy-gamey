extends StaticBody2D
## A character who says their lines when the player interacts with them.

@export var speaker_name: String = ""
@export var lines: Array[String] = []

@onready var _interactable: InteractableComponent = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	DialogueBox.show_lines(lines, speaker_name)
