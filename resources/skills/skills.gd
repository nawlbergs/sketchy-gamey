class_name Skills
extends RefCounted
## Every skill in the game, keyed by GameEnums.SkillId. Classes, weapons and enemies reference
## these ids, so look one up with Skills.ALL[id]. All numbers are placeholders.
##
## Every skill has this shape:
##   name, description: display text
##   effect: GameEnums.SkillEffect
##   amount: how much damage or healing
##   target_side: GameEnums.TargetSide
##   target_slots: GameEnums.Slot values it can target. Empty when target_side is SELF.
## Skills hit one target.

const ALL: Dictionary = {
	# Fighter
	GameEnums.SkillId.SECOND_WIND: {
		"name": "Second Wind",
		"description": "Recover some of your own health.",
		"effect": GameEnums.SkillEffect.HEAL,
		"amount": 4,
		"target_side": GameEnums.TargetSide.SELF,
		"target_slots": [],
	},
	GameEnums.SkillId.RALLYING_SHOUT: {
		"name": "Rallying Shout",
		"description": "Call out to steady one ally.",
		"effect": GameEnums.SkillEffect.HEAL,
		"amount": 2,
		"target_side": GameEnums.TargetSide.HERO,
		"target_slots": [GameEnums.Slot.SLOT_1, GameEnums.Slot.SLOT_2, GameEnums.Slot.SLOT_3],
	},
	GameEnums.SkillId.SHOVE: {
		"name": "Shove",
		"description": "Push past an ally to hit the front enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4],
	},
	GameEnums.SkillId.SWEEP: {
		"name": "Sweep",
		"description": "A wide swing at either of the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 4,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	# Mage
	GameEnums.SkillId.SPARK: {
		"name": "Spark",
		"description": "A weak bolt that can reach any enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6, GameEnums.Slot.SLOT_7],
	},
	GameEnums.SkillId.FROST_LANCE: {
		"name": "Frost Lance",
		"description": "A long-range shot at the enemy back row.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 6,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_6, GameEnums.Slot.SLOT_7],
	},
	GameEnums.SkillId.FIRE_BOLT: {
		"name": "Fire Bolt",
		"description": "A strong bolt at the front three enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 5,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6],
	},
	GameEnums.SkillId.FLAME_BURST: {
		"name": "Flame Burst",
		"description": "A close-range blast at the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 4,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	# Priest
	GameEnums.SkillId.MEND: {
		"name": "Mend",
		"description": "Heal one ally.",
		"effect": GameEnums.SkillEffect.HEAL,
		"amount": 6,
		"target_side": GameEnums.TargetSide.HERO,
		"target_slots": [GameEnums.Slot.SLOT_1, GameEnums.Slot.SLOT_2, GameEnums.Slot.SLOT_3],
	},
	GameEnums.SkillId.PRAYER: {
		"name": "Prayer",
		"description": "A strong heal on one ally.",
		"effect": GameEnums.SkillEffect.HEAL,
		"amount": 8,
		"target_side": GameEnums.TargetSide.HERO,
		"target_slots": [GameEnums.Slot.SLOT_1, GameEnums.Slot.SLOT_2, GameEnums.Slot.SLOT_3],
	},
	GameEnums.SkillId.SMITE: {
		"name": "Smite",
		"description": "Holy light strikes one of the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	GameEnums.SkillId.JUDGEMENT: {
		"name": "Judgement",
		"description": "A heavy holy blow on the front enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 5,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4],
	},
	# Sword
	GameEnums.SkillId.SLASH: {
		"name": "Slash",
		"description": "A solid cut at either of the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 5,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	GameEnums.SkillId.THROWN_BLADE: {
		"name": "Thrown Blade",
		"description": "Throw a knife from the back at a front-three enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6],
	},
	GameEnums.SkillId.THRUST: {
		"name": "Thrust",
		"description": "Reach past the front line with a quick stab.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 5,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	GameEnums.SkillId.CLEAVE: {
		"name": "Cleave",
		"description": "A heavy chop at the front enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 7,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4],
	},
	# Staff
	GameEnums.SkillId.BOLT: {
		"name": "Bolt",
		"description": "A small bolt that can reach any enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6, GameEnums.Slot.SLOT_7],
	},
	GameEnums.SkillId.ARCANE_SHOT: {
		"name": "Arcane Shot",
		"description": "A focused shot past the front enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 5,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6, GameEnums.Slot.SLOT_7],
	},
	GameEnums.SkillId.ARC: {
		"name": "Arc",
		"description": "Lightning jumps to one of the front three enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 4,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5, GameEnums.Slot.SLOT_6],
	},
	GameEnums.SkillId.STAFF_STRIKE: {
		"name": "Staff Strike",
		"description": "Hit the front enemy with the staff itself.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4],
	},
	# Mace
	GameEnums.SkillId.BASH: {
		"name": "Bash",
		"description": "A plain blow at either of the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 4,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	GameEnums.SkillId.BLESSING: {
		"name": "Blessing",
		"description": "Raise the mace and heal one ally.",
		"effect": GameEnums.SkillEffect.HEAL,
		"amount": 4,
		"target_side": GameEnums.TargetSide.HERO,
		"target_slots": [GameEnums.Slot.SLOT_1, GameEnums.Slot.SLOT_2, GameEnums.Slot.SLOT_3],
	},
	GameEnums.SkillId.HOLY_STRIKE: {
		"name": "Holy Strike",
		"description": "A blessed blow at either of the front two enemies.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 4,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4, GameEnums.Slot.SLOT_5],
	},
	GameEnums.SkillId.CRUSH: {
		"name": "Crush",
		"description": "A heavy overhead blow on the front enemy.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 6,
		"target_side": GameEnums.TargetSide.ENEMY,
		"target_slots": [GameEnums.Slot.SLOT_4],
	},
	# Enemies
	GameEnums.SkillId.MUCK_SPLAT: {
		"name": "Muck Splat",
		"description": "Flings a glob of muck at one hero.",
		"effect": GameEnums.SkillEffect.DAMAGE,
		"amount": 3,
		"target_side": GameEnums.TargetSide.HERO,
		"target_slots": [GameEnums.Slot.SLOT_1, GameEnums.Slot.SLOT_2, GameEnums.Slot.SLOT_3],
	},
}
