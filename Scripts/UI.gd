extends Control

"""Controls the in-game user interface in the right sidebar."""

onready var pause := $MarginContainer/VBoxContainer/Buttons/Pause
onready var pause_timer = $MarginContainer/VBoxContainer/Buttons/Pause/PauseTimer
onready var line_count := $MarginContainer/VBoxContainer/LineTracker/Score
onready var most_lines := $MarginContainer/VBoxContainer/LineTracker/Highscore
onready var pause_cover := $PauseCover
onready var game_over := $GameOverLabel

const PAUSE_IMG = preload("res://Assets/UI/tetris_pause.png")
const PAUSE_RED_IMG = preload("res://Assets/UI/tetris_pause_red.png")
const UNPAUSE_IMG = preload("res://Assets/UI/tetris_unpause.png")
const UNPAUSE_RED_IMG = preload("res://Assets/UI/tetris_unpause_red.png")

var active_shape: KinematicBody2D
var score := 0


func _ready():
	most_lines.text = "%04d" % Autoload.highscore


func _on_Pause_pressed() -> void:
	if not pause.disabled:
		# pauses the game when pressed for the first time, continues it when pressed for the second time
		pause.disabled = true
		if pause.texture_normal == PAUSE_IMG:
			active_shape.active = false
			pause_cover.show()
			pause.texture_normal = UNPAUSE_RED_IMG
		else:
			pause_cover.hide()
			pause.texture_normal = PAUSE_RED_IMG
			active_shape.active = true
			active_shape.drop_timer.wait_time = Autoload.shape_drop_speed
			active_shape.drop_timer.start()
		# starts a two second timer between pause button clicks to prevent errors and spam clicking
		pause_timer.start()


func _on_PauseTimer_timeout() -> void:
	# allows the pause button to be clicked again and changes its texture
	pause.disabled = false
	if pause.texture_normal == UNPAUSE_RED_IMG:
		pause.texture_normal = UNPAUSE_IMG
	else:
		pause.texture_normal = PAUSE_IMG


func _on_Restart_pressed() -> void:
	get_tree().change_scene("res://Scenes/Game.tscn")


func _unhandled_key_input(event: InputEventKey) -> void:
	"""Calls the restart function when R is pressed and informs the player that the game is restarting."""
	if event.scancode == KEY_SPACE:
		_on_Pause_pressed()
	elif event.scancode == KEY_R and event.pressed:
		get_tree().change_scene("res://Scenes/Game.tscn")
	elif event.scancode == KEY_ESCAPE:
		get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_MainMenu_pressed() -> void:
	# asks to check if a new highscore is reached and switches to the main menu scene
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func set_score(lines: int) -> void:
	# updates the line counter and increases the shape drop speed by 0.01 sec per 10 lines
	score += lines
	if Autoload.shape_drop_speed != 0.04:
		if Autoload.fast_mode:
			Autoload.shape_drop_speed = 1.04 - score * 0.01
		else:
			Autoload.shape_drop_speed = 1.04 - floor(score / 10) * 0.01
	line_count.text = "%04d" % score
	"""Updates the high score if the previous high score is beaten."""
	if Autoload.highscore < score:
		Autoload.highscore = score
		most_lines.text = "%04d" % Autoload.highscore


func game_over() -> void:
	# asks to check if a new highscore is reached, to show the game over label, and restarts the game after 5 sec
	pause.disabled = true
	game_over.show()
