class_name EncounterZone
extends Area2D
## An area of the map with random encounters. Add CollisionShape2D children to set where it covers.
## Anywhere without a zone is safe.

@export var zone_name: String = ""
## Chance of an encounter each time the tracker rolls, from 0 to 1.
@export_range(0.0, 1.0, 0.01) var encounter_rate: float = 0.1
@export var table: GameEnums.EncounterTableId = GameEnums.EncounterTableId.GRASS


## Returns a random group of GameEnums.EnemyId from this zone's table.
func pick_enemy_group() -> Array:
	var groups: Array = EncounterTables.ALL[table]
	return groups.pick_random().duplicate()
