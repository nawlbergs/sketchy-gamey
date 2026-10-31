extends CanvasLayer
## Switches scenes by name with a short fade. All navigation goes through go_to().

const SCENES: Dictionary = {
	"main_menu": "res://ui/menus/main_menu/main_menu.tscn",
	"load_game": "res://ui/menus/load_game/load_game.tscn",
	"party_create": "res://ui/menus/new_game/party_create.tscn",
	"overworld": "res://world/overworld.tscn",
	"combat": "res://systems/combat/combat.tscn",
}
const FADE_SECONDS := 0.2

var _fade: ColorRect
var _switching: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Calls made while a switch is already running are ignored, so double clicks are safe.
func go_to(scene_name: String) -> void:
	if _switching:
		return
	if not SCENES.has(scene_name):
		push_error("SceneRouter: unknown scene name '%s'" % scene_name)
		return
	var path: String = SCENES[scene_name]
	if not ResourceLoader.exists(path):
		push_error("SceneRouter: scene file not found: %s" % path)
		return
	await _switch_to(path)


func _switch_to(path: String) -> void:
	_switching = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneRouter: could not load %s (error %d)" % [path, error])
	await _fade_to(0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_switching = false


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_SECONDS)
	await tween.finished
