extends Node2D

"""Creates a board, adds shapes to it, finds and deletes full lines."""

onready var spawner = $Spawner

const BOARD_HEIGHT = 22
const BOARD_WIDTH = 10
const CELL_SIZE = 40

var board := []


func _ready() -> void:
	for row in range(BOARD_HEIGHT):
		board.append([])
		for col in range(BOARD_WIDTH):
			board[row].append("[ ]")


func shape_to_board(block_positions: Array) -> void:
	for pos in block_positions:
		board[pos.y / CELL_SIZE - 1][pos.x / CELL_SIZE - 1] = "[X]"
	spawner.spawn()
	print_board()
	line_check()


func line_check() -> void:
	for row in board:
		if not "[ ]" in row:
			print("Full line")


func print_board() -> void:
	for row in range(BOARD_HEIGHT):
		print(board[row])
