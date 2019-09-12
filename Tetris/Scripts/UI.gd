extends Control

"""Controls the in-game user interface in the right sidebar."""

onready var pause = $MarginContainer/VBoxContainer/Buttons/Pause
onready var main_menu = $MarginContainer/VBoxContainer/Buttons/MainMenu
onready var line_count = $MarginContainer/VBoxContainer/LineTracker/Score
onready var most_lines = $MarginContainer/VBoxContainer/LineTracker/Highscore
