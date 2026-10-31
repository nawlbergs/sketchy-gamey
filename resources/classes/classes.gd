class_name Classes
extends RefCounted
## Hero class data. All numbers are placeholders.
##
## class_skill and class_slot_skills hold GameEnums.SkillId values; see Skills.ALL for the details.
## Keys in class_slot_skills are the hero's current GameEnums.HeroSlot.

const ALL: Dictionary = {
	GameEnums.ClassId.FIGHTER: {
		"name": "Fighter",
		"max_hp": 30,
		"speed": 4,
		"starting_weapon": GameEnums.WeaponId.SWORD,
		"best_slot": "Best in slot 3: tough enough to hold the front.",
		"class_skill": GameEnums.SkillId.SECOND_WIND,
		"class_slot_skills": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.RALLYING_SHOUT,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.SHOVE,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.SWEEP,
		},
	},
	GameEnums.ClassId.MAGE: {
		"name": "Mage",
		"max_hp": 16,
		"speed": 6,
		"starting_weapon": GameEnums.WeaponId.STAFF,
		"best_slot": "Best in slot 1: fragile, but reaches the enemy back row.",
		"class_skill": GameEnums.SkillId.SPARK,
		"class_slot_skills": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.FROST_LANCE,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.FIRE_BOLT,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.FLAME_BURST,
		},
	},
	GameEnums.ClassId.PRIEST: {
		"name": "Priest",
		"max_hp": 22,
		"speed": 5,
		"starting_weapon": GameEnums.WeaponId.MACE,
		"best_slot": "Best in slot 1 or 2: strongest healing comes from the back.",
		"class_skill": GameEnums.SkillId.MEND,
		"class_slot_skills": {
			GameEnums.HeroSlot.SLOT_1: GameEnums.SkillId.PRAYER,
			GameEnums.HeroSlot.SLOT_2: GameEnums.SkillId.SMITE,
			GameEnums.HeroSlot.SLOT_3: GameEnums.SkillId.JUDGEMENT,
		},
	},
}
