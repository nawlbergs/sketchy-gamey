extends Node2D
## The overworld map. Puts the player where the game state says, or at the start of a new game.

const MAP_SIZE := Vector2(3000, 3000)
## Keeps a position from an old or edited save clear of the map edge walls.
const EDGE_MARGIN := Vector2(64, 64)

@onready var _player: OverworldPlayer = %Player
@onready var _player_start: Marker2D = %PlayerStart


func _ready() -> void:
	_player.set_camera_limits(Rect2(Vector2.ZERO, MAP_SIZE))
	# (0, 0) is the map corner, which the player can never stand on, so it means "no position yet".
	var position_to_use := GameState.overworld_position
	if position_to_use == Vector2.ZERO:
		position_to_use = _player_start.global_position
	_player.global_position = position_to_use.clamp(EDGE_MARGIN, MAP_SIZE - EDGE_MARGIN)
	GameState.overworld_position = _player.global_position
