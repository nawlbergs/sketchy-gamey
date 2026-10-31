extends CanvasLayer
## Autoload DialogueBox: reads lines of text one at a time at the bottom of the screen.
## Confirm or interact advances, and the box closes after the last line. For example:
##     DialogueBox.show_lines(["Hello.", "Goodbye."], "Villager")
##     await DialogueBox.finished

signal finished

var _lines: Array[String] = []
var _index: int = 0

@onready var _speaker_label: Label = %SpeakerLabel
@onready var _text_label: Label = %TextLabel


func _ready() -> void:
	visible = false


## Opens the box, replacing anything already showing. Empty lines do nothing, and finished is not
## emitted, so check for that before awaiting finished.
func show_lines(lines: Array[String], speaker: String = "") -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_speaker_label.text = speaker
	_speaker_label.visible = not speaker.is_empty()
	_text_label.text = _lines[_index]
	visible = true


func is_open() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return
	if event.is_action_pressed("confirm") or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	_index += 1
	if _index < _lines.size():
		_text_label.text = _lines[_index]
		return
	visible = false
	finished.emit()
