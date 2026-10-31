@tool
class_name HeroDoll
extends Control
## The hero's rag doll: pill body, round head and hands, with worn gear drawn on top.
## Scales to fit whatever size it is given, so every screen showing a hero can use it.
## To add a visible gear slot, add a layer to the scene and to _gear_layers.

## The size the parts are laid out at inside Rig.
const RIG_SIZE := Vector2(200, 240)

@onready var _rig: Control = $Rig
@onready var _gear_layers: Dictionary = {
	GameEnums.GearSlot.HEAD: $Rig/HeadGear,
	GameEnums.GearSlot.BODY: $Rig/BodyGear,
}


func _ready() -> void:
	resized.connect(_fit_rig)
	_fit_rig()


## Shows the gear in equipment (a hero's "equipment": GameEnums.GearSlot to GameEnums.GearId).
## A slot missing from equipment shows nothing, leaving the bare body or head.
func show_equipment(equipment: Dictionary) -> void:
	for slot: GameEnums.GearSlot in _gear_layers:
		var layer: Control = _gear_layers[slot]
		layer.visible = equipment.has(slot)
		if layer.visible:
			_show_gear(layer, Gear.ALL[equipment[slot]])


func _show_gear(layer: Control, gear: Dictionary) -> void:
	var art: TextureRect = layer.get_node("Art")
	var placeholder: PlaceholderBox = layer.get_node("Placeholder")
	var has_art := ResourceLoader.exists(gear["art"])
	art.texture = load(gear["art"]) if has_art else null
	art.visible = has_art
	placeholder.visible = not has_art
	placeholder.label_text = gear["name"]


func _fit_rig() -> void:
	var fit := minf(size.x / RIG_SIZE.x, size.y / RIG_SIZE.y)
	_rig.scale = Vector2(fit, fit)
	_rig.position = (size - RIG_SIZE * fit) / 2.0
