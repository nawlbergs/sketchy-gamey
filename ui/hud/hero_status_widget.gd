class_name HeroStatusWidget
extends PanelContainer
## One hero's status bars, portrait and name. Takes a hero dictionary from GameState.party.

@onready var _status_bars: StatusBars = %StatusBars
@onready var _name_label: Label = %NameLabel
@onready var _portrait: HeroDoll = %Portrait


func show_hero(hero: Dictionary) -> void:
	_name_label.text = hero["name"]
	_status_bars.show_hp(hero["hp"], hero["max_hp"])
	_portrait.show_equipment(hero["equipment"])
