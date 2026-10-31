@tool
class_name PlaceholderBox
extends Panel
## White box with a gray border that stands in for art not drawn yet.
## Size and position it where the real art will go, and set label_text to name that art.

@export var label_text: String = "ART":
	set(value):
		label_text = value
		if is_node_ready():
			_label.text = label_text

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = label_text
