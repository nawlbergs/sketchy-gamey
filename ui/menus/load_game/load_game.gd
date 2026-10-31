extends Control
## Lists saved games, newest first. Choosing one loads it and goes to the overworld.

const ROW_HEIGHT := 64
const ROW_FONT_SIZE := 24

@onready var _save_list: VBoxContainer = %SaveList
@onready var _empty_message: Label = %EmptyMessage
@onready var _error_message: Label = %ErrorMessage
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(SceneRouter.go_to.bind(GameEnums.SceneId.MAIN_MENU))
	for save: Dictionary in SaveManager.list_saves():
		_add_row(save)

	if _save_list.get_child_count() == 0:
		_empty_message.visible = true
		_back_button.grab_focus()
	else:
		(_save_list.get_child(0) as Button).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		SceneRouter.go_to(GameEnums.SceneId.MAIN_MENU)


func _add_row(save: Dictionary) -> void:
	var row := Button.new()
	row.text = "%s     %s" % [_format_date(save["timestamp"]), save["save_name"]]
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.clip_text = true  # Date comes first so a long save name cannot hide it.
	row.custom_minimum_size.y = ROW_HEIGHT
	row.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
	row.pressed.connect(_on_save_pressed.bind(save["path"]))
	_save_list.add_child(row)


func _on_save_pressed(path: String) -> void:
	if SaveManager.load_game(path):
		SceneRouter.go_to(GameEnums.SceneId.OVERWORLD)
	else:
		_error_message.visible = true


## Save timestamps are UTC, so this shifts them to the player's local time.
func _format_date(timestamp: int) -> String:
	var bias_minutes: int = Time.get_time_zone_from_system()["bias"]
	var local := Time.get_datetime_string_from_unix_time(timestamp + bias_minutes * 60, true)
	return local.left(16)  # YYYY-MM-DD HH:MM
