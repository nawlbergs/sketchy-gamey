extends Control
## Combat screen layout, following _production_files/mockups/combat-drawing.png. Turns and the
## action buttons come in combat-loop-01.

const UNIT_SCENE: PackedScene = preload("res://ui/combat/combat_unit.tscn")
const CELL_WIDTH := 220.0
const CELL_SEPARATION := 16.0
const CURRENT_PORTRAIT_SIZE := Vector2(96, 96)
const QUEUE_PORTRAIT_SIZE := Vector2(72, 72)
## Used when this scene is run directly with no encounter waiting.
const FALLBACK_ENEMIES: Array = [GameEnums.EnemyId.MUCK_BALL]
const ACTION_INFO: Dictionary = {
	"Move": "Move\nNot working yet.",
	"Rest": "Rest\nNot working yet.",
	"Trinket": "Trinket\nNone equipped.",
	"Item": "Combat item\nNone equipped.",
}

var _units: Array[CombatUnit] = []
var _turn_order: Array[CombatUnit] = []
var _selected: CombatUnit = null

@onready var _turn_queue: HBoxContainer = %TurnQueue
@onready var _heroes: HBoxContainer = %Heroes
@onready var _enemies: HBoxContainer = %Enemies
@onready var _selected_portrait: MarginContainer = %SelectedPortrait
@onready var _selected_name: Label = %SelectedName
@onready var _selected_class: Label = %SelectedClass
@onready var _info_label: Label = %InfoLabel
@onready var _skill_buttons: Dictionary = {
	GameEnums.SkillKind.WEAPON: %Skill1,
	GameEnums.SkillKind.WEAPON_SLOT: %Skill2,
	GameEnums.SkillKind.CLASS: %Skill3,
	GameEnums.SkillKind.CLASS_SLOT: %Skill4,
}


func _ready() -> void:
	%EndFightButton.pressed.connect(_on_end_fight_pressed)
	_connect_action_buttons()
	_build_heroes()
	_build_enemies()
	_build_turn_queue()
	_select_first_hero()
	_show_default_info()


func _build_heroes() -> void:
	for hero_slot: int in GameEnums.HeroSlot.values():
		var cell := _add_cell(_heroes, 1, "Slot %d" % hero_slot)
		for hero: Dictionary in GameState.party:
			if hero["current_slot"] == hero_slot:
				_add_unit(cell).setup_hero(hero)
				break


## Fills enemy slots from the front (slot 4), with larger enemies taking several slots.
func _build_enemies() -> void:
	var group: Array = GameState.pending_encounter if not GameState.pending_encounter.is_empty() else FALLBACK_ENEMIES
	var slots: Array = GameEnums.EnemySlot.values()
	var index := 0  # 0-based position in slots.
	for enemy_id: GameEnums.EnemyId in group:
		var span: int = Enemies.ALL[enemy_id]["slot_span"]
		if index + span > slots.size():
			push_error("Combat: enemy group does not fit in the enemy slots: %s" % [group])
			break
		var label := "Slot %d" % slots[index]
		if span > 1:
			label = "Slots %d-%d" % [slots[index], slots[index + span - 1]]
		_add_unit(_add_cell(_enemies, span, label)).setup_enemy(enemy_id, slots[index])
		index += span
	while index < slots.size():
		_add_cell(_enemies, 1, "Slot %d" % slots[index])
		index += 1


func _add_cell(row: HBoxContainer, span: int, label_text: String) -> VBoxContainer:
	var cell := VBoxContainer.new()
	cell.custom_minimum_size.x = CELL_WIDTH * span + CELL_SEPARATION * (span - 1)
	cell.alignment = BoxContainer.ALIGNMENT_END
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(cell)
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	cell.add_child(label)
	return cell


## Adds a unit to a cell, above the cell's slot label.
func _add_unit(cell: VBoxContainer) -> CombatUnit:
	var unit: CombatUnit = UNIT_SCENE.instantiate()
	cell.add_child(unit)
	cell.move_child(unit, 0)
	unit.hovered.connect(_on_unit_hovered.bind(unit))
	unit.unhovered.connect(_show_default_info)
	unit.clicked.connect(_on_unit_clicked.bind(unit))
	_units.append(unit)
	return unit


## Placeholder order: fastest first. combat-loop-01 adds the initiative roll.
func _build_turn_queue() -> void:
	_turn_order = _units.duplicate()
	_turn_order.sort_custom(func(a: CombatUnit, b: CombatUnit) -> bool: return a.stats.speed > b.stats.speed)
	for i in _turn_order.size():
		_add_queue_portrait(_turn_order[i], CURRENT_PORTRAIT_SIZE if i == 0 else QUEUE_PORTRAIT_SIZE)
		if i == 0:
			var divider := VSeparator.new()
			divider.custom_minimum_size.x = 16
			_turn_queue.add_child(divider)


func _add_queue_portrait(unit: CombatUnit, portrait_size: Vector2) -> void:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = portrait_size
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	frame.mouse_entered.connect(_on_unit_hovered.bind(unit))
	frame.mouse_exited.connect(_show_default_info)
	_turn_queue.add_child(frame)
	unit.add_portrait_to(frame)


func _connect_action_buttons() -> void:
	for kind: GameEnums.SkillKind in _skill_buttons:
		var button: Button = _skill_buttons[kind]
		button.mouse_entered.connect(_on_skill_hovered.bind(kind))
		button.mouse_exited.connect(_show_default_info)
	var action_buttons: Dictionary = {
		%MoveButton: "Move", %RestButton: "Rest",
		%Trinket1: "Trinket", %Trinket2: "Trinket", %Item1: "Item", %Item2: "Item",
	}
	for button: Button in action_buttons:
		button.mouse_entered.connect(_show_info.bind(ACTION_INFO[action_buttons[button]]))
		button.mouse_exited.connect(_show_default_info)


## Starts on the unit whose turn it is if that is a hero, otherwise the next hero in the queue.
func _select_first_hero() -> void:
	for unit: CombatUnit in _turn_order:
		if unit.is_hero:
			_select(unit)
			return


func _select(unit: CombatUnit) -> void:
	if _selected:
		_selected.set_selected(false)
	_selected = unit
	unit.set_selected(true)
	_selected_name.text = unit.display_name
	_selected_class.text = unit.subtitle
	for child: Node in _selected_portrait.get_children():
		child.free()
	unit.add_portrait_to(_selected_portrait)
	for kind: GameEnums.SkillKind in _skill_buttons:
		_skill_buttons[kind].disabled = not unit.skill_set.skills.has(kind)


func _on_unit_clicked(unit: CombatUnit) -> void:
	if unit.is_hero:
		_select(unit)


func _on_unit_hovered(unit: CombatUnit) -> void:
	_show_info(unit.get_info_text())


func _on_skill_hovered(kind: GameEnums.SkillKind) -> void:
	if _selected and _selected.skill_set.skills.has(kind):
		_show_info(Skills.summary(_selected.skill_set.skills[kind]))
	else:
		_show_info("No skill here.")


## Shows the unit whose turn it is, when nothing is hovered.
func _show_default_info() -> void:
	_show_info(_turn_order[0].get_info_text() if not _turn_order.is_empty() else "")


func _show_info(text: String) -> void:
	_info_label.text = text


## Temporary way out until combat-loop-01 can end a fight.
func _on_end_fight_pressed() -> void:
	GameState.pending_encounter = []
	SceneRouter.go_to(GameEnums.SceneId.OVERWORLD)
