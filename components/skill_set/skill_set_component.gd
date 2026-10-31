class_name SkillSetComponent
extends Node
## The skills a combat unit can use right now, by GameEnums.SkillKind. A hero's depend on the slot
## they stand in, so call setup_for_hero again after the hero moves.

## GameEnums.SkillKind to GameEnums.SkillId. A kind the unit lacks is simply missing.
var skills: Dictionary = {}


func setup_for_hero(hero: Dictionary) -> void:
	skills = {}
	var slot: int = hero["current_slot"]
	var class_data: Dictionary = Classes.ALL[hero["class_id"]]
	skills[GameEnums.SkillKind.CLASS] = class_data["class_skill"]
	skills[GameEnums.SkillKind.CLASS_SLOT] = class_data["class_slot_skills"][slot]
	# Use the weapon in the weapon slot matching this position, otherwise the primary weapon.
	var weapon_id: Variant = hero["weapons"].get(slot, hero["weapons"].get(hero["primary_weapon_slot"]))
	if weapon_id != null:
		var weapon: Dictionary = Weapons.ALL[weapon_id]
		skills[GameEnums.SkillKind.WEAPON] = weapon["default_ability"]
		skills[GameEnums.SkillKind.WEAPON_SLOT] = weapon["abilities"][slot]


func setup_for_enemy(enemy: Dictionary) -> void:
	skills = {GameEnums.SkillKind.WEAPON: enemy["attack"]}
