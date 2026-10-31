class_name Weapons
extends RefCounted
## Weapon data. All numbers are placeholders.
##
## default_ability and abilities hold GameEnums.SkillId values; see Skills.ALL for the details.
## default_ability works from any slot. Keys in abilities are the hero's current GameEnums.HeroSlot.
## classes lists the hero classes allowed to equip the weapon.

const ALL: Dictionary = {
	GameEnums.WeaponId.SWORD: {
		"name": "Sword",
		"classes": [GameEnums.ClassId.FIGHTER],
		"default_ability": GameEnums.SkillId.SLASH,
		"abilities": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.THROWN_BLADE,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.THRUST,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.CLEAVE,
		},
	},
	GameEnums.WeaponId.STAFF: {
		"name": "Staff",
		"classes": [GameEnums.ClassId.MAGE],
		"default_ability": GameEnums.SkillId.BOLT,
		"abilities": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.ARCANE_SHOT,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.ARC,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.STAFF_STRIKE,
		},
	},
	GameEnums.WeaponId.MACE: {
		"name": "Mace",
		"classes": [GameEnums.ClassId.PRIEST],
		"default_ability": GameEnums.SkillId.BASH,
		"abilities": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.BLESSING,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.HOLY_STRIKE,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.CRUSH,
		},
	},
}
