class_name OverworldHud
extends CanvasLayer
## Overworld display of the party, gold and XP. Call refresh() after changing GameState while
## this scene is open; it reads GameState once when the scene starts.

signal menu_pressed

@onready var _menu_button: Button = %MenuButton
@onready var _hero_widgets: Array[Node] = %Heroes.get_children()
@onready var _gold_label: Label = %GoldLabel
@onready var _xp_bar: ProgressBar = %XpBar
@onready var _xp_label: Label = %XpLabel


func _ready() -> void:
	_menu_button.pressed.connect(menu_pressed.emit)
	refresh()


func refresh() -> void:
	for i in _hero_widgets.size():
		var widget := _hero_widgets[i] as HeroStatusWidget
		widget.visible = i < GameState.party.size()
		if widget.visible:
			widget.show_hero(GameState.party[i])
	_gold_label.text = "Gold: %d" % GameState.gold
	_xp_bar.max_value = maxi(GameState.xp_to_next, 1)  # Before value, which is clamped to the maximum.
	_xp_bar.value = GameState.xp
	_xp_label.text = "XP %d / %d" % [GameState.xp, GameState.xp_to_next]
