class_name Enemies
extends RefCounted
## Enemy data. All numbers are placeholders.
##
## attack holds a GameEnums.SkillId value; see Skills.ALL for the details.
## slot_span is how many enemy slots the enemy fills: SM 1, MD 2, LG 3, XL 4.
## xp and gold are what the party gets for beating it.

const ALL: Dictionary = {
	GameEnums.EnemyId.MUCK_BALL: {
		"name": "Muck Ball",
		"size": GameEnums.EnemySize.SM,
		"slot_span": 1,
		"max_hp": 12,
		"speed": 3,
		"attack": GameEnums.SkillId.MUCK_SPLAT,
		"xp": 10,
		"gold": 3,
	},
}
