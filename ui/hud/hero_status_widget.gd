class_name HeroStatusWidget
extends PanelContainer
## One hero's status icons, HP bar, portrait and name. Takes a hero dictionary from GameState.party.
## The status icons are empty placeholders until the game has status effects.

@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hp_label: Label = %HpLabel
@onready var _name_label: Label = %NameLabel
@onready var _portrait: HeroDoll = %Portrait


func show_hero(hero: Dictionary) -> void:
	_name_label.text = hero["name"]
	_hp_bar.max_value = hero["max_hp"]  # Before value, which is clamped to the current maximum.
	_hp_bar.value = hero["hp"]
	_hp_label.text = "%d / %d" % [hero["hp"], hero["max_hp"]]
	_portrait.show_equipment(hero["equipment"])
