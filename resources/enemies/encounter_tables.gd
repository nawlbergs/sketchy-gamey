class_name EncounterTables
extends RefCounted
## The enemy groups each kind of zone can spawn. All placeholders.
##
## Each table lists groups of GameEnums.EnemyId, and one group is picked at random per encounter.
## A group's enemies must fit the 4 enemy slots, counting each enemy's slot_span.

const ALL: Dictionary = {
	GameEnums.EncounterTableId.GRASS: [
		[GameEnums.EnemyId.MUCK_BALL],
		[GameEnums.EnemyId.MUCK_BALL, GameEnums.EnemyId.MUCK_BALL],
	],
	GameEnums.EncounterTableId.FOREST: [
		[GameEnums.EnemyId.MUCK_BALL, GameEnums.EnemyId.MUCK_BALL],
		[GameEnums.EnemyId.MUCK_BALL, GameEnums.EnemyId.MUCK_BALL, GameEnums.EnemyId.MUCK_BALL],
	],
}
