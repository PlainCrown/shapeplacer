 extends Node2D

"""Creates a board, adds shapes to it, finds and deletes full lines."""

onready var spawner: Node2D = $Spawner
onready var shape_script: GDScript = load("res://Scripts/Shape.gd")

"""Even though the board is 22 cells high, the two extra spaces allow the shapes
to be rotated above the top border of the board."""
const BOARD_HEIGHT = 24
const BOARD_WIDTH = 10

var board := []


func _ready() -> void:
	for row in range(BOARD_HEIGHT):
		board.append([])
		for col in range(BOARD_WIDTH):
			board[row].append("[ ]")


func shape_to_board(block_positions: Array) -> void:
	for pos in block_positions:
		board[pos.y / Autoload.CELL_SIZE - 1][pos.x / Autoload.CELL_SIZE - 1] = "[X]"
	spawner.spawn()
	line_check()


func line_check() -> void:
	var full_rows := []
	for row in BOARD_HEIGHT:
		if not "[ ]" in board[row]:
			full_rows.append(row + 1)
			for col in BOARD_WIDTH:
				board[row][col] = "[ ]"
	if not full_rows.empty():
		get_tree().call_group("dropped_shapes", "delete_rows", full_rows)
		for row in range(21, 0, -1):
			if row < full_rows.max() - 1 and not row + 1 in full_rows:
				for col in BOARD_WIDTH:
					if board[row][col] == "[X]":
						board[row][col] = "[ ]"
						if row == full_rows.max() - 2 or row == full_rows.max() - 3 and not row + 2 in full_rows:
							board[row + 1][col] = "[X]"
						elif row == full_rows.max() - 3 and full_rows.size() > 1:
							board[row + 2][col] = "[X]"
						else:
							board[row + full_rows.size()][col] = "[X]"
		print_board()


func print_board() -> void:
	for row in range(BOARD_HEIGHT - 2):
		print(board[row])
	print(" ")
