class_name HealthComponent
extends Node
## Tracks a unit's hit points. Attach as a child of anything that can be hurt or healed.

signal hp_changed(hp: int, max_hp: int)
signal died

@export var max_hp: int = 10
@export var hp: int = 10


## Sets both values without emitting signals. Use it to configure a unit from saved or game data.
func setup(new_max_hp: int, new_hp: int) -> void:
	max_hp = maxi(new_max_hp, 1)
	hp = clampi(new_hp, 0, max_hp)


func damage(amount: int) -> void:
	if is_dead():
		return
	_set_hp(hp - maxi(amount, 0))
	if is_dead():
		died.emit()


func heal(amount: int) -> void:
	_set_hp(hp + maxi(amount, 0))


func is_dead() -> bool:
	return hp <= 0


func _set_hp(value: int) -> void:
	var clamped := clampi(value, 0, max_hp)
	if clamped == hp:
		return
	hp = clamped
	hp_changed.emit(hp, max_hp)
