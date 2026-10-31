extends Node
## Saves, loads and lists games as JSON files in user://saves/.
##
## Each file holds GameState.to_dict() plus save_name and timestamp (Unix seconds).
## Named saves go in save_<sanitized name>.json. The "save_" prefix keeps them clear of the autosave
## file and of names Windows reserves, like "con". Names that sanitize the same share one file.

const SAVE_DIR := "user://saves"
const AUTOSAVE_FILE := "autosave.json"
const AUTOSAVE_NAME := "Autosave"
const MAX_FILE_NAME_LENGTH := 64


## Returns false if the name is blank or the file could not be written.
func save_game(save_name: String) -> bool:
	var clean_name := save_name.strip_edges()
	if clean_name.is_empty():
		push_error("SaveManager: save name is empty")
		return false
	return _write_save("save_%s.json" % _sanitize(clean_name), clean_name)


func autosave() -> bool:
	return _write_save(AUTOSAVE_FILE, AUTOSAVE_NAME)


## Returns [{save_name, timestamp, path}], newest first. Unreadable files are skipped with a warning.
func list_saves() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	if not DirAccess.dir_exists_absolute(SAVE_DIR):  # Normal on first launch.
		return saves
	for file_name in DirAccess.get_files_at(SAVE_DIR):
		if file_name.get_extension() != "json":
			continue
		var path := SAVE_DIR.path_join(file_name)
		var data := _read_save(path)
		if data.is_empty():
			push_warning("SaveManager: skipping unreadable save %s" % path)
			continue
		saves.append({
			"save_name": str(data.get("save_name", file_name.get_basename())),
			"timestamp": int(data.get("timestamp", 0)),
			"path": path,
		})
	saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["timestamp"] > b["timestamp"])
	return saves


func has_saves() -> bool:
	return not list_saves().is_empty()


## Returns false and leaves GameState untouched if the file is missing or unreadable.
func load_game(path: String) -> bool:
	var data := _read_save(path)
	if data.is_empty():
		push_error("SaveManager: could not load %s" % path)
		return false
	GameState.from_dict(data)
	return true


## Writes to a temporary file first, so a crash mid-save cannot destroy the existing save.
func _write_save(file_name: String, save_name: String) -> bool:
	var error := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if error != OK:
		push_error("SaveManager: could not create %s (error %d)" % [SAVE_DIR, error])
		return false
	var data := GameState.to_dict()
	data["save_name"] = save_name
	data["timestamp"] = int(Time.get_unix_time_from_system())

	var path := SAVE_DIR.path_join(file_name)
	var temp_path := path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not write %s (error %d)" % [temp_path, FileAccess.get_open_error()])
		return false
	var written := file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if not written:
		push_error("SaveManager: could not write %s" % temp_path)
		DirAccess.remove_absolute(temp_path)
		return false
	error = DirAccess.rename_absolute(temp_path, path)
	if error != OK:
		push_error("SaveManager: could not replace %s (error %d)" % [path, error])
		DirAccess.remove_absolute(temp_path)
		return false
	return true


## Returns the save's data, or an empty dictionary if it is missing or not a valid save.
func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	var data: Variant = json.data
	if not data is Dictionary or not data.get("party") is Array:
		return {}
	for hero: Variant in data["party"]:
		if not hero is Dictionary:
			return {}
	return data


func _sanitize(save_name: String) -> String:
	var regex := RegEx.create_from_string("[^a-z0-9_-]")
	return regex.sub(save_name.to_lower(), "_", true).left(MAX_FILE_NAME_LENGTH)
