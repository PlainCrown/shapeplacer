extends Control

"""Controls the in-game user interface in the right sidebar."""

onready var pause: Label = $MarginContainer/VBoxContainer/Buttons/Pause
onready var pause_timer: Timer = $MarginContainer/VBoxContainer/Buttons/Pause/PauseTimer
onready var line_count: Label = $MarginContainer/VBoxContainer/LineTracker/Score
onready var most_lines: Label = $MarginContainer/VBoxContainer/LineTracker/Highscore
onready var over: Label = $"../MarginContainer/GameOver"

const PAUSE_IMG = preload("res://Assets/UI/tetris_pause.png")
const PAUSE_RED_IMG = preload("res://Assets/UI/tetris_pause_red.png")
const UNPAUSE_IMG = preload("res://Assets/UI/tetris_unpause.png")
const UNPAUSE_RED_IMG = preload("res://Assets/UI/tetris_unpause_red.png")

var active_shape: KinematicBody2D = null
var pressed := 0
var score := 0
var ten_lines := 0
var previous_ten_lines := 0
var remainingDropTime := 0


func _ready():
	# displays the highscore when the game starts and hides the game over label
	set_highscore()
	over.hide()


func _on_Pause_pressed() -> void:
	# pauses the game when pressed for the first time, continues it when pressed for the second time
	pause.disabled = true
	remainingDropTime = active_shape.drop_timer.wait_time
	active_shape.active = false
	pressed += 1
	pause.texture_normal = UNPAUSE_RED_IMG
	if pressed == 2:
		pause.texture_normal = PAUSE_RED_IMG
		active_shape.active = true
		active_shape.drop_timer.wait_time = remainingDropTime
		active_shape.drop()
		pressed = 0
	# starts a two second timer between pause button clicks to prevent errors and spam clicking
	pause_timer.start()


func _on_PauseTimer_timeout() -> void:
	# allows the pause button to be clicked again and changes its texture
	pause.disabled = false
	if pause.texture_normal == UNPAUSE_RED_IMG:
		pause.texture_normal = UNPAUSE_IMG
	else:
		pause.texture_normal = PAUSE_IMG


func _on_MainMenu_pressed() -> void:
	# asks to check if a new highscore is reached and switches to the main menu scene
	set_highscore()
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func set_score(lines) -> void:
	# updates the line counter and increases the shape drop speed by 0.01 sec per 10 lines
	score += lines
	for ten in range(floor(score / 10)):
		ten_lines += 1
	if ten_lines > 0 and ten_lines > previous_ten_lines:
		Autoload.shape_drop_speed = 1.04 - ten_lines * 0.01
		previous_ten_lines = ten_lines
	ten_lines = 0
	line_count.text = "%04d" % score


func set_highscore() -> void:
	# updates the most lines label if the current line count is higher than the previous best
	if Autoload.highscore < score:
		Autoload.highscore = score
	most_lines.text = "%04d" % Autoload.highscore


func game_over() -> void:
	# asks to check if a new highscore is reached, to show the game over label, and restarts the game after 5 sec
	set_highscore()
	over.show()
	yield(get_tree().create_timer(5), "timeout")
	get_tree().change_scene("res://Scenes/Game.tscn")
