extends Control
## First screen of the game. Load Game only shows when there is a save to load.

@onready var _load_game_button: Button = %LoadGameButton
@onready var _new_game_button: Button = %NewGameButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_load_game_button.pressed.connect(SceneRouter.go_to.bind(GameEnums.SceneId.LOAD_GAME))
	_new_game_button.pressed.connect(SceneRouter.go_to.bind(GameEnums.SceneId.PARTY_CREATE))
	_quit_button.pressed.connect(get_tree().quit)

	var has_saves := SaveManager.has_saves()
	_load_game_button.visible = has_saves
	# Keyboard and gamepad players need a button focused to start from.
	(_load_game_button if has_saves else _new_game_button).grab_focus()

	AudioManager.play_music("main_menu")
