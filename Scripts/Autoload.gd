extends Node

"""Autoload script containing variables that are used across multiple different scripts.
Responsible for saving and loading save files and user preferences.
Also adds and controls the music audio player."""

onready var music_file: Resource = preload("res://Assets/Sounds/music_track.ogg")
onready var config_path = "user://config.ini"
onready var save_path = "user://save.dat"

const CELL_SIZE = 40
const DEFAULT_SHAPE_DROP_SPEED = 1.04
const DEFAULT_COLOR_DIC = {
	0: Color(0.1, 0.91, 0.91, 1),
	1: Color(0.1, 0.38, 0.91, 1),
	2: Color(0.65, 0.1, 0.91, 1),
	3: Color(0.1, 0.91, 0.24, 1),
	4: Color(0.91, 0.88, 0.1, 1),
	5: Color(0.91, 0.45, 0.1, 1),
	6: Color(0.91, 0.1, 0.24, 1)}

var music_player := AudioStreamPlayer.new()
var shape_drop_speed := DEFAULT_SHAPE_DROP_SPEED

"""Variables saved to config.ini"""
var music_volume: int setget music_volume_change
var sfx_volume: int setget sfx_volume_change
var fullscreen: bool
var show_grid: bool
var fast_mode: bool
var invisible_mode: bool
var color_dic := {
	0: Color(0.1, 0.91, 0.91, 1),
	1: Color(0.1, 0.38, 0.91, 1),
	2: Color(0.65, 0.1, 0.91, 1),
	3: Color(0.1, 0.91, 0.24, 1),
	4: Color(0.91, 0.88, 0.1, 1),
	5: Color(0.91, 0.45, 0.1, 1),
	6: Color(0.91, 0.1, 0.24, 1)}

"""Dictionary saved to save.dat"""
var highscore_dictionary := {} setget save_data


func _ready() -> void:
	"""Loads the config.ini and save.dat files.
	Switches to fullscreen if it has been turned on in the options menu."""
	load_config()
	if fullscreen:
		OS.window_fullscreen = true
	load_data()
	
	"""Creates and plays the music audio player which continues to play even when scenes are changed."""
	get_viewport().get_node("/root").call_deferred("add_child", music_player)
	music_player.stream = music_file
	music_player.volume_db = music_volume
	music_player.play()


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


func save_config() -> void:
	"""Creates a config file and saves all user preferences in the options menu."""
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "show_grid", show_grid)
	config.set_value("game_mode", "fast_mode", fast_mode)
	config.set_value("game_mode", "invisible_mode", invisible_mode)
	config.set_value("shape_colors", "color_dic", color_dic)
	var err := config.save(config_path)
	
	"""Checks if the config file was saved successfully."""
	if err != OK:
		print("Error while saving config")


func load_config() -> void:
	"""Loads the config file."""
	var config := ConfigFile.new()
	var err := config.load(config_path)
	
	"""Sets options menu values to default if the config file fails to load or does not exist."""
	if err != OK:
		music_volume = -10
		sfx_volume = -20
		fullscreen = false
		show_grid = true
		fast_mode = false
		invisible_mode = false
		color_dic = DEFAULT_COLOR_DIC
		print("Error while loading config. Default settings loaded.")
		return
	
	"""Sets option menu values to the values stored in the config file."""
	music_volume = config.get_value("audio", "music_volume")
	sfx_volume = config.get_value("audio", "sfx_volume")
	fullscreen = config.get_value("display", "fullscreen")
	show_grid = config.get_value("display", "show_grid")
	fast_mode = config.get_value("game_mode", "fast_mode")
	invisible_mode = config.get_value("game_mode", "invisible_mode")
	color_dic = config.get_value("shape_colors", "color_dic")


func save_data(new_scores: Dictionary) -> void:
	"""Creates a save file."""
	highscore_dictionary = new_scores
	var save_file := File.new()
	var err := save_file.open(save_path, File.WRITE)
	
	"""Checks if the save file was opened successfully."""
	if err != OK:
		print("Error while opening save file")
		return
	
	"""Saves the dictionary and closes the save file."""
	save_file.store_var(highscore_dictionary)
	save_file.close()


func load_data() -> void:
	"""Loads the save file."""
	var save_file := File.new()
	var err := save_file.open(save_path, File.READ)
	
	"""Sets high score values to default if the save file fails to load or does not exist."""
	if err != OK:
		highscore_dictionary = {
			1: 0,  # NORMAL
			2: 0,  # FAST
			3: 0,  # INVISIBLE
			4: 0}  # FAST + INVISIBLE
		print("Error while loading save file. Default settings loaded.")
		return
	
	"""Sets high score values to the values stored in the save file."""
	highscore_dictionary = save_file.get_var()
	save_file.close()
