extends Control

"""Controls the user interface."""

onready var fast_mode := $MarginContainer/VBoxContainer/LineTracker/FastLabel
onready var invisible_mode := $MarginContainer/VBoxContainer/LineTracker/InvisibleLabel
onready var line_count := $MarginContainer/VBoxContainer/LineTracker/Score
onready var most_lines := $MarginContainer/VBoxContainer/LineTracker/Highscore
onready var pause := $MarginContainer/VBoxContainer/Buttons/Pause
onready var pause_timer = $MarginContainer/VBoxContainer/Buttons/Pause/PauseTimer
onready var pause_cover := $PauseCover
onready var game_over := $GameOverLabel

const PAUSE_IMG = preload("res://Assets/UI/tetris_pause.png")
const PAUSE_RED_IMG = preload("res://Assets/UI/tetris_pause_red.png")
const UNPAUSE_IMG = preload("res://Assets/UI/tetris_unpause.png")
const UNPAUSE_RED_IMG = preload("res://Assets/UI/tetris_unpause_red.png")

var active_shape: KinematicBody2D
var score := 0
var game_type := 1


func _ready():
	"""Finds the game mode and sets the appropriate high score."""
	if Autoload.fast_mode:
		game_type += 1
		fast_mode.show()
	if Autoload.invisible_mode:
		game_type += 2
		invisible_mode.show()
	most_lines.text = "%04d" % Autoload.highscore_dictionary[game_type]


func _on_Pause_pressed() -> void:
	"""Pauses and unpauses the game."""
	if not pause.disabled:
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
			
		"""Starts a timer between pause button clicks to prevent errors, spam clicking, and keeping 
		the shape in the same place for an indefinite amount of time which negates the difficulty 
		created by the icreasing shape drop speed."""
		pause_timer.start()


func _on_PauseTimer_timeout() -> void:
	"""Allows the pause button to be clicked again and changes its texture."""
	pause.disabled = false
	if pause.texture_normal == UNPAUSE_RED_IMG:
		pause.texture_normal = UNPAUSE_IMG
	else:
		pause.texture_normal = PAUSE_IMG


func _on_Restart_pressed() -> void:
	"""Restarts the game."""
	get_tree().change_scene("res://Scenes/Game.tscn")


func _unhandled_key_input(event: InputEventKey) -> void:
	"""Pauses, restarts, and exits the game with keyboard input."""
	if event.scancode == KEY_SPACE:
		_on_Pause_pressed()
	elif event.scancode == KEY_R and event.pressed:
		get_tree().change_scene("res://Scenes/Game.tscn")
	elif event.scancode == KEY_ESCAPE:
		get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_MainMenu_pressed() -> void:
	"""Returns to the main menu."""
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func set_score(lines: int) -> void:
	"""Updates the number of filled lines and changes the shape drop speed depending on the game mode."""
	score += lines
	if Autoload.shape_drop_speed != 0.04:
		if Autoload.fast_mode:
			Autoload.shape_drop_speed = Autoload.DEFAULT_SHAPE_DROP_SPEED - score * 0.01
		else:
			Autoload.shape_drop_speed = Autoload.DEFAULT_SHAPE_DROP_SPEED - floor(score / 10) * 0.01
	line_count.text = "%04d" % score
	
	"""Updates the high score if the previous high score is beaten."""
	if score > Autoload.highscore_dictionary[game_type]:
		Autoload.highscore_dictionary[game_type] = score
		most_lines.text = "%04d" % score


func game_over() -> void:
	"""Disables the pause button and shows the game over label."""
	pause.disabled = true
	game_over.show()
