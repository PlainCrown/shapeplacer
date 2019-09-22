 extends Node2D

"""Creates a board, adds shapes to it, finds and deletes full lines."""

onready var spawner: Node2D = $Spawner
onready var user_interface: Control = $UI

"""Even though the board is 22 cells high, the two extra spaces allow the shapes
to be rotated outside the top border of the board."""
const BOARD_HEIGHT = 24
const BOARD_WIDTH = 10

var board := []
var game_over := false


func _ready() -> void:
	# creates the game board
	for row in range(BOARD_HEIGHT):
		board.append([])
		for col in range(BOARD_WIDTH):
			board[row].append("[ ]")


func shape_to_board(block_positions: Array) -> void:
	# turns filled Vector2 positions into filled board positions
	for pos in block_positions:
		board[pos.y / Autoload.CELL_SIZE - 1][pos.x / Autoload.CELL_SIZE - 1] = "[X]"
	# asks to spawn a new shape and asks to check if any rows are full 
	if not game_over:
		spawner.spawn()
		row_check()


func row_check() -> void:
	# finds and deletes full rows, then lowers unfilled rows
	
	# finds full rows, empties them from the board
	var full_rows := []
	for row in BOARD_HEIGHT:
		if not "[ ]" in board[row]:
			full_rows.append(row + 1)
			for col in BOARD_WIDTH:
				board[row][col] = "[ ]"
	# if full rows are found
	if not full_rows.empty():
		# asks dropped shapes to delete blocks from full rows
		get_tree().call_group("dropped_shapes", "delete_rows", full_rows)
		# lowers unfilled rows that are above the deleted rows
		for row in range(21, 0, -1):
			if row < full_rows.max() - 1 and not row + 1 in full_rows:
				for col in BOARD_WIDTH:
					if board[row][col] == "[X]":
						board[row][col] = "[ ]"
						# catches exceptions where the lowest unfilled row is lower than the highest filled row
						if row == full_rows.max() - 2 or row == full_rows.max() - 3 and not row + 2 in full_rows:
							board[row + 1][col] = "[X]"
						elif row == full_rows.max() - 3 and full_rows.size() > 1:
							board[row + 2][col] = "[X]"
						else:
							board[row + full_rows.size()][col] = "[X]"
		# asks for the line count to be updated
		user_interface.set_score(full_rows.size())


func _unhandled_key_input(event: InputEventKey) -> void:
	# asks to check if a new highscore is reached and returns to the main menu when escape is pressed
	if event.scancode == KEY_ESCAPE:
		user_interface.set_highscore()
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
