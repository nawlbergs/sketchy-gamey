class_name HeroSlotPanel
extends PanelContainer
## One hero column on the Create Party screen: choose a class, enter a name, see what that
## class can do from this slot.

signal name_changed
## The class changed and the player has not edited this name, so it should be re-rolled.
signal default_name_needed

const MIN_NAME_LENGTH := 3
const MAX_NAME_LENGTH := 9

@export var slot: GameEnums.HeroSlot = GameEnums.HeroSlot.SLOT_1
@export var class_id: GameEnums.ClassId = GameEnums.ClassId.FIGHTER

var _name_was_edited := false

@onready var _class_label: Label = %ClassLabel
@onready var _name_edit: LineEdit = %NameEdit
@onready var _info_label: Label = %InfoLabel
@onready var _previous_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton


func _ready() -> void:
	_name_edit.max_length = MAX_NAME_LENGTH
	_name_edit.placeholder_text = "Name (%d-%d characters)" % [MIN_NAME_LENGTH, MAX_NAME_LENGTH]
	_name_edit.text_changed.connect(_on_name_text_changed)
	_name_edit.focus_entered.connect(_name_edit.edit)  # Tabbing in should allow typing straight away.
	_previous_button.pressed.connect(_cycle_class.bind(-1))
	_next_button.pressed.connect(_cycle_class.bind(1))
	_refresh()


func get_hero_name() -> String:
	return _name_edit.text.strip_edges()


func has_valid_name() -> bool:
	return get_hero_name().length() >= MIN_NAME_LENGTH and get_hero_name().length() <= MAX_NAME_LENGTH


func set_hero_name(hero_name: String) -> void:
	_name_edit.text = hero_name
	name_changed.emit()


## Puts the cursor in the name box, ready for typing.
func start_name_entry() -> void:
	_name_edit.grab_focus()


## Sets where Tab goes from this panel's name box.
func set_next_focus(target: Control) -> void:
	_name_edit.focus_next = _name_edit.get_path_to(target)


func get_name_edit() -> LineEdit:
	return _name_edit


## Only fires for the player's edits: setting text from code does not emit text_changed.
func _on_name_text_changed(_new_text: String) -> void:
	_name_was_edited = true
	name_changed.emit()


func _cycle_class(step: int) -> void:
	var ids := GameEnums.ClassId.values()
	class_id = ids[posmod(ids.find(class_id) + step, ids.size())]
	_refresh()
	if not _name_was_edited:
		default_name_needed.emit()


func _refresh() -> void:
	var class_data: Dictionary = Classes.ALL[class_id]
	var weapon: Dictionary = Weapons.ALL[class_data["starting_weapon"]]
	_class_label.text = class_data["name"]
	_info_label.text = "\n".join([
		_skill_text("Class skill", class_data["class_skill"]),
		_skill_text("Class slot skill", class_data["class_slot_skills"][slot]),
		_skill_text(weapon["name"] + " skill", weapon["default_ability"]),
		_skill_text(weapon["name"] + " slot skill", weapon["abilities"][slot]),
		"",
		class_data["best_slot"],
		"Slot %d becomes this hero's primary weapon slot." % slot,
	])


func _skill_text(heading: String, skill_id: GameEnums.SkillId) -> String:
	var skill: Dictionary = Skills.ALL[skill_id]
	var effect := "%d damage" if skill["effect"] == GameEnums.SkillEffect.DAMAGE else "heals %d"
	return "%s: %s (%s)\n%s" % [heading, skill["name"], effect % skill["amount"], skill["description"]]
