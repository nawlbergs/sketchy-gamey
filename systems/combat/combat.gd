extends Control
## A fight: rolls a turn order each round, then takes turns until one side is dead.
## Layout follows _production_files/mockups/combat-drawing.png. Only skill 1 works for now.

const UNIT_SCENE: PackedScene = preload("res://ui/combat/combat_unit.tscn")
const CELL_WIDTH := 220.0
const CELL_SEPARATION := 16.0
const CURRENT_PORTRAIT_SIZE := Vector2(96, 96)
const QUEUE_PORTRAIT_SIZE := Vector2(72, 72)
## Each unit's initiative is its speed plus a roll from 0 to this.
const INITIATIVE_ROLL_MAX := 4
const ENEMY_TURN_SECONDS := 0.8
const RESULT_SECONDS := 2.0
## Used when this scene is run directly with no encounter waiting.
const FALLBACK_ENEMIES: Array = [GameEnums.EnemyId.MUCK_BALL]
const ACTION_INFO: Dictionary = {
	"Move": "Move\nNot working yet.",
	"Rest": "Rest\nEnd this hero's turn.",
	"Trinket": "Trinket\nNone equipped.",
	"Item": "Combat item\nNone equipped.",
}

var _hero_units: Array[CombatUnit] = []
var _enemy_units: Array[CombatUnit] = []  # Living enemies, front first.
var _turn_queue_units: Array[CombatUnit] = []  # Units still to act this round.
var _current: CombatUnit = null  # The unit whose turn it is.
var _selected: CombatUnit = null
var _armed_skill: Variant = null  # The GameEnums.SkillId waiting for a target, or null.
var _reward_xp: int = 0
var _reward_gold: int = 0
var _fight_over: bool = false

@onready var _turn_queue: HBoxContainer = %TurnQueue
@onready var _heroes: HBoxContainer = %Heroes
@onready var _enemies: HBoxContainer = %Enemies
@onready var _selected_portrait: MarginContainer = %SelectedPortrait
@onready var _selected_name: Label = %SelectedName
@onready var _selected_class: Label = %SelectedClass
@onready var _info_label: Label = %InfoLabel
@onready var _result_label: Label = %ResultLabel
@onready var _weapon_skill_button: Button = %Skill1
@onready var _rest_button: Button = %RestButton
@onready var _skill_buttons: Dictionary = {
	GameEnums.SkillKind.WEAPON: %Skill1,
	GameEnums.SkillKind.WEAPON_SLOT: %Skill2,
	GameEnums.SkillKind.CLASS: %Skill3,
	GameEnums.SkillKind.CLASS_SLOT: %Skill4,
}


func _ready() -> void:
	_connect_action_buttons()
	_build_heroes()
	_build_enemies()
	_show_default_info()
	if _hero_units.is_empty():
		push_warning("Combat: no party, so the fight cannot start. Enter through a game to play.")
		_update_buttons()
		return
	_start_round()


func _unhandled_input(event: InputEvent) -> void:
	if _armed_skill != null and event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		_disarm()


# --- Building the battlefield ---

func _build_heroes() -> void:
	for hero_slot: int in GameEnums.HeroSlot.values():
		var cell := _add_cell(_heroes, 1, "Slot %d" % hero_slot)
		for hero: Dictionary in GameState.party:
			if hero["current_slot"] == hero_slot:
				var unit := _new_unit(cell)
				cell.move_child(unit, 0)
				unit.setup_hero(hero)
				_hero_units.append(unit)
				break


func _build_enemies() -> void:
	var group: Array = GameState.pending_encounter if not GameState.pending_encounter.is_empty() else FALLBACK_ENEMIES
	var slots_left: int = GameEnums.EnemySlot.size()
	for enemy_id: GameEnums.EnemyId in group:
		var enemy: Dictionary = Enemies.ALL[enemy_id]
		if enemy["slot_span"] > slots_left:
			push_error("Combat: enemy group does not fit in the enemy slots: %s" % [group])
			break
		slots_left -= enemy["slot_span"]
		var unit := _new_unit(_enemies)
		unit.setup_enemy(enemy_id)
		_enemy_units.append(unit)
		_reward_xp += enemy["xp"]
		_reward_gold += enemy["gold"]
	_layout_enemies()


## Places living enemies from the front (slot 4), with larger enemies taking several slots. Called
## again after a death so the rest step forward; otherwise weapons that only reach the front slots
## could never finish a fight.
func _layout_enemies() -> void:
	for unit: CombatUnit in _enemy_units:
		unit.get_parent().remove_child(unit)
	for cell: Node in _enemies.get_children():
		cell.free()
	var slots: Array = GameEnums.EnemySlot.values()
	var index := 0  # 0-based position in slots.
	for unit: CombatUnit in _enemy_units:
		var label := "Slot %d" % slots[index]
		if unit.slot_span > 1:
			label = "Slots %d-%d" % [slots[index], slots[index + unit.slot_span - 1]]
		var cell := _add_cell(_enemies, unit.slot_span, label)
		cell.add_child(unit)
		cell.move_child(unit, 0)
		unit.slot = slots[index]
		index += unit.slot_span
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


func _new_unit(parent: Node) -> CombatUnit:
	var unit: CombatUnit = UNIT_SCENE.instantiate()
	parent.add_child(unit)
	unit.hovered.connect(_on_unit_hovered.bind(unit))
	unit.unhovered.connect(_show_default_info)
	unit.clicked.connect(_on_unit_clicked.bind(unit))
	return unit


# --- Turns ---

func _start_round() -> void:
	var rolls := {}
	_turn_queue_units = []
	for unit: CombatUnit in _hero_units + _enemy_units:
		if not unit.health.is_dead():
			rolls[unit] = unit.stats.speed + randi_range(0, INITIATIVE_ROLL_MAX)
			_turn_queue_units.append(unit)
	_turn_queue_units.sort_custom(func(a: CombatUnit, b: CombatUnit) -> bool: return rolls[a] > rolls[b])
	_next_turn()


func _next_turn() -> void:
	if _check_fight_over():
		return
	_turn_queue_units = _turn_queue_units.filter(func(unit: CombatUnit) -> bool: return not unit.health.is_dead())
	if _turn_queue_units.is_empty():
		_start_round()
		return
	_current = _turn_queue_units.pop_front()
	_refresh_turn_queue()
	_show_default_info()
	if _current.is_hero:
		_select(_current)
		_update_buttons()
	else:
		if _selected == null or _selected.health.is_dead():
			_select(_first_living_hero())
		_update_buttons()
		_take_enemy_turn(_current)


func _first_living_hero() -> CombatUnit:
	for hero: CombatUnit in _hero_units:
		if not hero.health.is_dead():
			return hero
	return null


func _take_enemy_turn(enemy: CombatUnit) -> void:
	await get_tree().create_timer(ENEMY_TURN_SECONDS).timeout
	var target := _pick_enemy_target()
	var skill: Dictionary = Skills.ALL[enemy.skill_set.skills[GameEnums.SkillKind.WEAPON]]
	target.health.damage(skill["amount"])
	_next_turn()


## A random living hero, more likely the closer to the front: slot 3 is three times as likely as slot 1.
func _pick_enemy_target() -> CombatUnit:
	var choices: Array[CombatUnit] = []
	for hero: CombatUnit in _hero_units:
		if not hero.health.is_dead():
			for i in hero.slot:
				choices.append(hero)
	return choices.pick_random()


func _check_fight_over() -> bool:
	if _enemy_units.is_empty():
		GameState.xp += _reward_xp
		GameState.gold += _reward_gold
		_finish_fight("Victory!\n+%d XP   +%d gold" % [_reward_xp, _reward_gold], GameEnums.SceneId.OVERWORLD)
		return true
	if _hero_units.all(func(hero: CombatUnit) -> bool: return hero.health.is_dead()):
		_finish_fight("Defeated", GameEnums.SceneId.MAIN_MENU)
		return true
	return false


func _finish_fight(message: String, next_scene: GameEnums.SceneId) -> void:
	_fight_over = true
	_current = null
	GameState.pending_encounter = []
	_update_buttons()
	_show_default_info()
	for child: Node in _turn_queue.get_children():
		child.free()
	_result_label.text = message
	_result_label.visible = true
	await get_tree().create_timer(RESULT_SECONDS).timeout
	SceneRouter.go_to(next_scene)


# --- The player's choices ---

func _connect_action_buttons() -> void:
	_weapon_skill_button.pressed.connect(_on_weapon_skill_pressed)
	_rest_button.pressed.connect(_on_rest_pressed)
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


## Skill 1 and Rest work on the current hero only. Viewing another hero leaves them off.
func _update_buttons() -> void:
	var can_act := not _fight_over and _current != null and _current.is_hero and _selected == _current
	_rest_button.disabled = not can_act
	_weapon_skill_button.disabled = not can_act or _weapon_skill_targets().is_empty()
	_weapon_skill_button.set_pressed_no_signal(_armed_skill != null)


func _weapon_skill_targets() -> Array[CombatUnit]:
	if _current == null or not _current.skill_set.skills.has(GameEnums.SkillKind.WEAPON):
		return []
	return _valid_targets(Skills.ALL[_current.skill_set.skills[GameEnums.SkillKind.WEAPON]])


func _valid_targets(skill: Dictionary) -> Array[CombatUnit]:
	var targets: Array[CombatUnit] = []
	match skill["target_side"]:
		GameEnums.TargetSide.SELF:
			targets.append(_current)
		GameEnums.TargetSide.HERO:
			targets = _hero_units.filter(func(unit: CombatUnit) -> bool: return not unit.health.is_dead() and unit.occupies_any(skill["target_slots"]))
		GameEnums.TargetSide.ENEMY:
			targets = _enemy_units.filter(func(unit: CombatUnit) -> bool: return unit.occupies_any(skill["target_slots"]))
	return targets


func _on_weapon_skill_pressed() -> void:
	if _armed_skill != null:
		_disarm()
		return
	_armed_skill = _current.skill_set.skills[GameEnums.SkillKind.WEAPON]
	for unit: CombatUnit in _valid_targets(Skills.ALL[_armed_skill]):
		unit.set_targetable(true)
	_update_buttons()


func _disarm() -> void:
	_armed_skill = null
	for unit: CombatUnit in _hero_units + _enemy_units:
		unit.set_targetable(false)
	_update_buttons()


func _on_rest_pressed() -> void:
	_disarm()
	_next_turn()


func _on_unit_clicked(unit: CombatUnit) -> void:
	if _fight_over:
		return
	if _armed_skill != null:
		if unit in _valid_targets(Skills.ALL[_armed_skill]):
			_use_armed_skill_on(unit)
	elif unit.is_hero:
		_select(unit)
		_update_buttons()


func _use_armed_skill_on(target: CombatUnit) -> void:
	var skill: Dictionary = Skills.ALL[_armed_skill]
	_disarm()
	if skill["effect"] == GameEnums.SkillEffect.DAMAGE:
		target.health.damage(skill["amount"])
	else:
		target.health.heal(skill["amount"])
	if target.health.is_dead() and not target.is_hero:
		_enemy_units.erase(target)
		_turn_queue_units.erase(target)
		target.queue_free()
		target.get_parent().remove_child(target)
		_layout_enemies()
	_next_turn()


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


# --- Display ---

## Shows the unit taking its turn, larger and split off from those still to act this round.
func _refresh_turn_queue() -> void:
	for child: Node in _turn_queue.get_children():
		child.free()
	_add_queue_portrait(_current, CURRENT_PORTRAIT_SIZE)
	var divider := VSeparator.new()
	divider.custom_minimum_size.x = 16
	_turn_queue.add_child(divider)
	for unit: CombatUnit in _turn_queue_units:
		_add_queue_portrait(unit, QUEUE_PORTRAIT_SIZE)


func _add_queue_portrait(unit: CombatUnit, portrait_size: Vector2) -> void:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = portrait_size
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	frame.mouse_entered.connect(_on_unit_hovered.bind(unit))
	frame.mouse_exited.connect(_show_default_info)
	_turn_queue.add_child(frame)
	unit.add_portrait_to(frame)


func _on_unit_hovered(unit: CombatUnit) -> void:
	_show_info(unit.get_info_text())


func _on_skill_hovered(kind: GameEnums.SkillKind) -> void:
	if _selected and _selected.skill_set.skills.has(kind):
		_show_info(Skills.summary(_selected.skill_set.skills[kind]))
	else:
		_show_info("No skill here.")


## Shows the unit whose turn it is, when nothing is hovered.
func _show_default_info() -> void:
	_show_info(_current.get_info_text() if _current else "")


func _show_info(text: String) -> void:
	_info_label.text = text
