extends Control

"""Controls the in-game user interface in the right sidebar."""

onready var pause: Label = $MarginContainer/VBoxContainer/Buttons/Pause
onready var pause_timer: Timer = $MarginContainer/VBoxContainer/Buttons/Pause/PauseTimer
onready var line_count: Label = $MarginContainer/VBoxContainer/LineTracker/Score
onready var most_lines: Label = $MarginContainer/VBoxContainer/LineTracker/Highscore

const PAUSE_IMG = preload("res://Assets/UI/tetris_pause.png")
const UNPAUSE_IMG = preload("res://Assets/UI/tetris_unpause.png")

var active_shape: KinematicBody2D = null
var pressed := 0


func _on_Pause_pressed() -> void:
	# pauses the game when pressed for the first time, continues it when pressed for the second time
	pause.disabled = true
	active_shape.active = false
	pressed += 1
	pause.texture_normal = UNPAUSE_IMG
	if pressed == 2:
		pause.texture_normal = PAUSE_IMG
		active_shape.active = true
		active_shape.drop()
		pressed = 0
	pause_timer.start()


func _on_PauseTimer_timeout() -> void:
	# prevents the pause button from being spam-clicked by forcing a two second break between clicks
	pause.disabled = false


func _on_MainMenu_pressed() -> void:
	# switches to the main menu scene
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
