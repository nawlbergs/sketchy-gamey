extends Node
## Plays music and sound effects by id. An id with no matching file silently does nothing,
## so game code can call these before the audio exists.

const MUSIC_DIR := "res://assets/audio/music"
const SFX_DIR := "res://assets/audio/sfx"
const EXTENSIONS: Array[String] = ["ogg", "mp3", "wav"]

var _music_player: AudioStreamPlayer
var _music_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.finished.connect(_music_player.play)  # Music always loops, whatever the file's import settings say.


## Starts a track and loops it. Asking for the track already playing does not restart it.
func play_music(id: String) -> void:
	if id == _music_id and _music_player.playing:
		return
	var stream := _find_stream(MUSIC_DIR, id)
	if stream == null:
		return
	_music_id = id
	_music_player.stream = stream
	_music_player.play()


func play_sfx(id: String) -> void:
	var stream := _find_stream(SFX_DIR, id)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _find_stream(directory: String, id: String) -> AudioStream:
	for extension in EXTENSIONS:
		var path := "%s/%s.%s" % [directory, id, extension]
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return null
