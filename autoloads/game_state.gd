extends Node
## The current run: party, gold, xp, overworld position and inventory.
## Heroes are plain dictionaries here. Scenes that show a unit attach components instead.

const INVENTORY_SIZE := 36
const STARTING_XP_TO_NEXT := 100

var party: Array[Dictionary] = []
var gold: int = 0
var xp: int = 0
var xp_to_next: int = STARTING_XP_TO_NEXT
var overworld_position: Vector2 = Vector2.ZERO
var inventory: Array = []  # Always INVENTORY_SIZE long; null marks an empty slot.


func _init() -> void:
	reset()


func reset() -> void:
	party = []
	gold = 0
	xp = 0
	xp_to_next = STARTING_XP_TO_NEXT
	overworld_position = Vector2.ZERO
	inventory = []
	inventory.resize(INVENTORY_SIZE)


## Builds a hero at full health. slot is the party slot, 1-3 (3 = front, 1 = back).
func make_hero(hero_name: String, class_id: String, slot: int, max_hp: int, speed: int) -> Dictionary:
	return {
		"name": hero_name,
		"class_id": class_id,
		"start_slot": slot,
		"current_slot": slot,
		"primary_weapon_slot": slot,
		"unlocked_weapon_slots": [slot],
		"max_hp": max_hp,
		"hp": max_hp,
		"speed": speed,
		"equipment": {},
	}


## Returns JSON-safe data for saving. The result shares nothing with the live state.
func to_dict() -> Dictionary:
	return {
		"party": party.duplicate(true),
		"gold": gold,
		"xp": xp,
		"xp_to_next": xp_to_next,
		"overworld_position": {"x": overworld_position.x, "y": overworld_position.y},
		"inventory": inventory.duplicate(true),
	}


## Replaces the current state. JSON turns every number into a float, so whole numbers are converted back.
func from_dict(data: Dictionary) -> void:
	reset()
	for hero_data: Dictionary in data.get("party", []):
		party.append(_hero_from_dict(hero_data))
	gold = int(data.get("gold", gold))
	xp = int(data.get("xp", xp))
	xp_to_next = int(data.get("xp_to_next", xp_to_next))
	var position_data: Dictionary = data.get("overworld_position", {})
	overworld_position = Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0)))
	var saved_inventory: Array = data.get("inventory", [])
	inventory = saved_inventory.duplicate(true)
	inventory.resize(INVENTORY_SIZE)


func _hero_from_dict(data: Dictionary) -> Dictionary:
	var slot := int(data.get("start_slot", 1))
	var hero := make_hero(
		str(data.get("name", "")),
		str(data.get("class_id", "")),
		slot,
		int(data.get("max_hp", 1)),
		int(data.get("speed", 0))
	)
	hero["current_slot"] = int(data.get("current_slot", slot))
	hero["primary_weapon_slot"] = int(data.get("primary_weapon_slot", slot))
	hero["hp"] = int(data.get("hp", hero["max_hp"]))
	var unlocked: Array = []
	for weapon_slot: Variant in data.get("unlocked_weapon_slots", [slot]):
		unlocked.append(int(weapon_slot))
	hero["unlocked_weapon_slots"] = unlocked
	var equipment: Dictionary = data.get("equipment", {})
	hero["equipment"] = equipment.duplicate(true)
	return hero
