extends Node

"""Adds and controls the background music player, and holds some variables used in other scripts."""

onready var music_file: Resource = preload("res://Assets/Sounds/music_track.ogg")

const CELL_SIZE = 40
const DEFAULT_COLOR_DIC = {
	0: Color(0.1, 0.91, 0.91, 1),
	1: Color(0.1, 0.38, 0.91, 1),
	2: Color(0.65, 0.1, 0.91, 1),
	3: Color(0.1, 0.91, 0.24, 1),
	4: Color(0.91, 0.88, 0.1, 1),
	5: Color(0.91, 0.45, 0.1, 1),
	6: Color(0.91, 0.1, 0.24, 1)}

var music_player := AudioStreamPlayer.new()
var shape_drop_speed := 1.04
var highscore := 0
var last_shape_pos := []

var music_volume := -10 setget music_volume_change
var sfx_volume := -20 setget sfx_volume_change
var fullscreen := false
var show_grid := true
var fast_mode := false
var invisible_mode := false

var color_dic := {
	0: Color(0.1, 0.91, 0.91, 1),
	1: Color(0.1, 0.38, 0.91, 1),
	2: Color(0.65, 0.1, 0.91, 1),
	3: Color(0.1, 0.91, 0.24, 1),
	4: Color(0.91, 0.88, 0.1, 1),
	5: Color(0.91, 0.45, 0.1, 1),
	6: Color(0.91, 0.1, 0.24, 1)}


func _ready() -> void:
	# adds and starts a music player that persists through scene changes
	if fullscreen:
		OS.window_fullscreen = true
	get_viewport().get_node("/root").call_deferred("add_child", music_player)
	music_player.stream = music_file
	music_player.volume_db = music_volume
#	music_player.play()


func music_volume_change(value: int) -> void:
	"""Stores and adjusts the music volume setting."""
	music_volume = value
	if music_volume == -40:
		music_volume = -1000
	music_player.volume_db = music_volume


func sfx_volume_change(value: int) -> void:
	"""Stores and adjusts the sound effect volume setting."""
	sfx_volume = value
	if sfx_volume == -50:
		sfx_volume = -1000
