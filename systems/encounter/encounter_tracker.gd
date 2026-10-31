class_name EncounterTracker
extends Node
## Child of the overworld player. Rolls for a random encounter as the player walks, using the
## rate of the zone they are in. Only real movement counts, so pushing against a wall rolls nothing.

## Pixels walked between rolls.
@export var distance_per_roll: float = 200.0
## Pixels walked with no rolls each time the overworld opens, so a fight can't follow straight after one.
@export var grace_distance: float = 600.0

var _distance_left: float = 0.0
var _encounter_started: bool = false

@onready var _body: CharacterBody2D = get_parent()


func _ready() -> void:
	_distance_left = grace_distance


func _physics_process(_delta: float) -> void:
	if _encounter_started:
		return
	_distance_left -= _body.get_position_delta().length()
	if _distance_left > 0.0:
		return
	_distance_left = distance_per_roll
	var zone := _current_zone()
	if zone and randf() < zone.encounter_rate:
		_start_encounter(zone)


func _current_zone() -> EncounterZone:
	for zone: EncounterZone in get_tree().get_nodes_in_group("encounter_zones"):
		if zone.overlaps_body(_body):
			return zone
	return null


func _start_encounter(zone: EncounterZone) -> void:
	_encounter_started = true
	GameState.overworld_position = _body.global_position
	GameState.pending_encounter = zone.pick_enemy_group()
	SceneRouter.go_to(GameEnums.SceneId.COMBAT)
