class_name GameEnums
extends RefCounted
## Ids and fixed choices used across the game. Use these instead of strings.
##
## Enum values are plain numbers that change if entries are reordered, so save files must store
## the entry's name ("FIGHTER"), never its number. See GameState.to_dict().
## Slot enums are the exception: their values are pinned to the slot numbers, so saves store those.

## Starting names on the Create Party screen. Each must be 3-9 characters, with no repeats and at
## least 4 in total: a re-roll skips the 3 names showing and still needs one left to pick.
const DEFAULT_HERO_NAMES: Array[String] = [
	"Chad", "Snubs", "Donker", "Jarnathan", "Snips", "Rancho", "Flaunti", "Knob",
	"Strank",
]

## Hero slots: 3 = front/tank, 1 = back.
enum HeroSlot { SLOT_1 = 1, SLOT_2 = 2, SLOT_3 = 3 }

## Enemy slots: 4 = front, 7 = back.
enum EnemySlot { SLOT_4 = 4, SLOT_5 = 5, SLOT_6 = 6, SLOT_7 = 7 }

## Every slot on the battlefield, built from HeroSlot and EnemySlot.
enum Slot {
	SLOT_1 = HeroSlot.SLOT_1,
	SLOT_2 = HeroSlot.SLOT_2,
	SLOT_3 = HeroSlot.SLOT_3,
	SLOT_4 = EnemySlot.SLOT_4,
	SLOT_5 = EnemySlot.SLOT_5,
	SLOT_6 = EnemySlot.SLOT_6,
	SLOT_7 = EnemySlot.SLOT_7,
}

enum SceneId { MAIN_MENU, LOAD_GAME, PARTY_CREATE, OVERWORLD, COMBAT }
enum ClassId { FIGHTER, MAGE, PRIEST }
enum WeaponId { SWORD, STAFF, MACE }
## Gear slots that show on the hero doll. Necklace, rings, boots and the rest get added with their items.
enum GearSlot { HEAD, BODY }
enum GearId { LEATHER_CAP, LEATHER_ARMOR }
enum EnemyId { MUCK_BALL }
## Scenes store exported enums as numbers, so add new tables at the end to keep placed zones correct.
enum EncounterTableId { GRASS, FOREST }
enum EnemySize { SM, MD, LG, XL }
enum SkillId {
	# Fighter
	SECOND_WIND,
	RALLYING_SHOUT,
	SHOVE,
	SWEEP,
	# Mage
	SPARK,
	FROST_LANCE,
	FIRE_BOLT,
	FLAME_BURST,
	# Priest
	MEND,
	PRAYER,
	SMITE,
	JUDGEMENT,
	# Sword
	SLASH,
	THROWN_BLADE,
	THRUST,
	CLEAVE,
	# Staff
	BOLT,
	ARCANE_SHOT,
	ARC,
	STAFF_STRIKE,
	# Mace
	BASH,
	BLESSING,
	HOLY_STRIKE,
	CRUSH,
	# Enemies
	MUCK_SPLAT,
}
## The four skills a unit's skill set can hold, matching combat buttons 1 to 4.
enum SkillKind { WEAPON, WEAPON_SLOT, CLASS, CLASS_SLOT }
enum SkillEffect{ DAMAGE, HEAL }
enum TargetSide { ENEMY, HERO, SELF }
