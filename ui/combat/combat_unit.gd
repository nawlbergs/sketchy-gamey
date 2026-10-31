class_name CombatUnit
extends VBoxContainer
## One hero or enemy in a fight, set up from data. Behaviour comes from its component children,
## so there are no hero or enemy subclasses. Add it to the tree before calling a setup function.

signal hovered
signal unhovered
signal clicked

const DOLL_SCENE: PackedScene = preload("res://characters/heroes/hero_doll.tscn")
const BOX_SCENE: PackedScene = preload("res://ui/common/placeholder_box.tscn")
const HERO_FIGURE_HEIGHT := 280.0
const DEAD_COLOR := Color(1, 1, 1, 0.35)
const ENEMY_FIGURE_HEIGHTS: Dictionary = {
	GameEnums.EnemySize.SM: 200.0,
	GameEnums.EnemySize.MD: 240.0,
	GameEnums.EnemySize.LG: 280.0,
	GameEnums.EnemySize.XL: 320.0,
}

var display_name: String = ""
var subtitle: String = ""
var slot: int = 0
var slot_span: int = 1
var is_hero: bool = false

var _equipment: Dictionary = {}
var _hero: Dictionary = {}  # The hero in GameState.party, which is kept up to date with damage.

@onready var health: HealthComponent = $Health
@onready var stats: StatsComponent = $Stats
@onready var skill_set: SkillSetComponent = $SkillSet
@onready var _target_marker: Label = %TargetMarker
@onready var _figure: MarginContainer = %Figure
@onready var _status_bars: StatusBars = %StatusBars
@onready var _charge_bar: ProgressBar = %ChargeBar
@onready var _selection_bar: ColorRect = %SelectionBar


func _ready() -> void:
	mouse_entered.connect(hovered.emit)
	mouse_exited.connect(unhovered.emit)
	health.hp_changed.connect(_on_hp_changed)
	set_selected(false)
	set_targetable(false)


func setup_hero(hero: Dictionary) -> void:
	is_hero = true
	_hero = hero
	display_name = hero["name"]
	subtitle = Classes.ALL[hero["class_id"]]["name"]
	slot = hero["current_slot"]
	_equipment = hero["equipment"]
	stats.speed = hero["speed"]
	skill_set.setup_for_hero(hero)
	_finish_setup(hero["max_hp"], hero["hp"], HERO_FIGURE_HEIGHT)


func setup_enemy(enemy_id: GameEnums.EnemyId) -> void:
	var enemy: Dictionary = Enemies.ALL[enemy_id]
	display_name = enemy["name"]
	subtitle = "Size: %s" % GameEnums.EnemySize.find_key(enemy["size"])
	slot_span = enemy["slot_span"]
	stats.speed = enemy["speed"]
	skill_set.setup_for_enemy(enemy)
	_charge_bar.visible = false
	_finish_setup(enemy["max_hp"], enemy["max_hp"], ENEMY_FIGURE_HEIGHTS[enemy["size"]])


## Adds a picture of this unit to parent, which must be a container that sizes its children.
func add_portrait_to(parent: Control) -> void:
	if is_hero:
		var doll: HeroDoll = DOLL_SCENE.instantiate()
		parent.add_child(doll)
		doll.show_equipment(_equipment)
	else:
		var box: PlaceholderBox = BOX_SCENE.instantiate()
		box.label_text = display_name.to_upper()
		parent.add_child(box)


## Marks this unit as the hero whose actions are showing.
func set_selected(selected: bool) -> void:
	_selection_bar.self_modulate.a = 1.0 if selected else 0.0


## Shows or hides the marker for a unit the armed skill can hit.
func set_targetable(targetable: bool) -> void:
	_target_marker.self_modulate.a = 1.0 if targetable else 0.0


func occupies_any(slots: Array) -> bool:
	for i in slot_span:
		if (slot + i) in slots:
			return true
	return false


func get_info_text() -> String:
	return "%s\n%s\nHealth: %d / %d\nSpeed: %d\nSlot: %d" % [
		display_name, subtitle, health.hp, health.max_hp, stats.speed, slot,
	]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()


func _finish_setup(max_hp: int, hp: int, figure_height: float) -> void:
	health.setup(max_hp, hp)
	_status_bars.show_hp(health.hp, health.max_hp)
	_figure.custom_minimum_size.y = figure_height
	add_portrait_to(_figure)
	_update_dead_look()


func _on_hp_changed(hp: int, max_hp: int) -> void:
	_status_bars.show_hp(hp, max_hp)
	if is_hero:
		_hero["hp"] = hp
	_update_dead_look()


func _update_dead_look() -> void:
	modulate = DEAD_COLOR if health.is_dead() else Color.WHITE
