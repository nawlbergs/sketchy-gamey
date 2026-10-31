class_name StatusBars
extends VBoxContainer
## Status icons above an HP bar. Shared by the overworld HUD and combat.
## The status icons are empty placeholders until the game has status effects.

@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hp_label: Label = %HpLabel


func show_hp(hp: int, max_hp: int) -> void:
	_hp_bar.max_value = max_hp  # Before value, which is clamped to the current maximum.
	_hp_bar.value = hp
	_hp_label.text = "%d / %d" % [hp, max_hp]
