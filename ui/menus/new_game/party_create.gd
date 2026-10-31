extends Control
## Create Party screen: one column per hero slot. Begin needs a valid name in every column.

@onready var _panels: Array[Node] = %Panels.get_children()
@onready var _back_button: Button = %BackButton
@onready var _begin_button: Button = %BeginButton


func _ready() -> void:
	_back_button.pressed.connect(SceneRouter.go_to.bind(GameEnums.SceneId.MAIN_MENU))
	_begin_button.pressed.connect(_on_begin_pressed)
	for panel: HeroSlotPanel in _panels:
		panel.name_changed.connect(_update_begin_button)
		panel.default_name_needed.connect(_roll_default_name.bind(panel))
		_roll_default_name(panel)
	_set_up_tab_order()
	_update_begin_button()
	(_panels[0] as HeroSlotPanel).start_name_entry()


## Skips every name currently showing, so a re-roll always changes the name and heroes never match.
func _roll_default_name(panel: HeroSlotPanel) -> void:
	var taken: Array = _panels.map(func(other: HeroSlotPanel) -> String: return other.get_hero_name())
	var options: Array = GameEnums.DEFAULT_HERO_NAMES.filter(func(option: String) -> bool: return option not in taken)
	panel.set_hero_name(options.pick_random())


## Tab goes name to name, then to Begin, since naming the party is the main job here.
func _set_up_tab_order() -> void:
	for i in _panels.size():
		var panel := _panels[i] as HeroSlotPanel
		if i + 1 < _panels.size():
			panel.set_next_focus((_panels[i + 1] as HeroSlotPanel).get_name_edit())
		else:
			panel.set_next_focus(_begin_button)


func _update_begin_button() -> void:
	_begin_button.disabled = not _panels.all(func(panel: HeroSlotPanel) -> bool: return panel.has_valid_name())


func _on_begin_pressed() -> void:
	GameState.reset()
	for panel: HeroSlotPanel in _panels:
		GameState.party.append(GameState.make_hero(panel.get_hero_name(), panel.class_id, panel.slot))
	SceneRouter.go_to(GameEnums.SceneId.OVERWORLD)
