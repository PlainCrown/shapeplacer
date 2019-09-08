extends Node2D

"""Draws a grid in the game."""

onready var cell_size = $"..".cell_size.x

const LINE_COLOR = Color(255, 255, 255)
const LINE_WIDTH = 1

var width := 10
var length := 22


func _draw() -> void:
	# draws the grid in-game
	for x in range(width + 1):
		var col_pos: int = x * cell_size
		var limit: int = length * cell_size
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
	for y in range(length + 1):
		var row_pos: int = y * cell_size
		var limit: int = width * cell_size
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
