extends Node

"""Also adds and controls the music player and contains the CELL_SIZE constant that is used across
multiple different scripts."""

onready var music_file: Resource = preload("res://Assets/Sounds/music_track.ogg")

const CELL_SIZE = 40

var sound := true setget music_switch
var music_player := AudioStreamPlayer.new()


func _ready() -> void:
	# adds and starts a music player that persists through scene changes
	get_viewport().get_node("/root").call_deferred("add_child", music_player)
	music_player.stream = music_file
	music_player.volume_db = -14
#	music_player.play()


func music_switch(boolean_value: bool) -> void:
	# turns the music player on and off when the sound variable is changed
	sound = boolean_value
	if sound:
		music_player.play()
	else:
		music_player.stop()
