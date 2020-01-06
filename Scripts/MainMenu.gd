extends Control

"""Controls the functionality of all the buttons on the main menu screen."""

onready var controls_page: TextureRect = $ControlsPage


func _ready() -> void:
	# hides the controls page when the game is started and makes the sound button remain toggled
	controls_page.hide()


func _on_Start_pressed() -> void:
	# changes to the game scene when the start button is pressed
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_Options_pressed() -> void:
	"""Opens the options menu."""
	get_tree().change_scene("res://Scenes/Options.tscn")


func _on_Controls_pressed() -> void:
	# shows the controls page
	controls_page.show()


func _on_Exit_pressed() -> void:
	# closes the game window when the exit button is pressed
	get_tree().quit()


func _unhandled_key_input(event: InputEventKey) -> void:
	# hides the controls page when escape is pressed
	if event.scancode == KEY_ESCAPE:
		controls_page.hide()
