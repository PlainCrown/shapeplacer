 extends Node2D

"""Creates a board, adds shapes to it, finds and deletes full lines."""

onready var spawner: Node2D = $Spawner
onready var user_interface: Control = $UI

"""Even though the board is only 22 cells high, the additional board height allows the shapes
to be rotated outside the top border of the board."""
const BOARD_HEIGHT = 24
const BOARD_WIDTH = 10

var board := []
var game_over := false


func _ready() -> void:
	"""Resets the shape drop speed to the default speed."""
	Autoload.shape_drop_speed = Autoload.DEFAULT_SHAPE_DROP_SPEED
	
	"""Creates the game board."""
	for row in range(BOARD_HEIGHT):
		board.append([])
		for col in range(BOARD_WIDTH):
			board[row].append("[ ]")


func shape_to_board(block_positions: Array) -> void:
	"""Turns Vector2 positions that contain blocks into X on the game board."""
	for pos in block_positions:
		board[pos.y / Autoload.CELL_SIZE - 1][pos.x / Autoload.CELL_SIZE - 1] = "[X]"
	
	"""Requests to spawn a new shape and to check if any of the rows are full."""
	if not game_over:
		spawner.spawn()
		row_check()


func row_check() -> void:
	"""Searches for full rows and removes them from the game board."""
	var full_rows := []
	for row in BOARD_HEIGHT:
		if not "[ ]" in board[row]:
			full_rows.append(row + 1)
			for col in BOARD_WIDTH:
				board[row][col] = "[ ]"
	
	"""Tells the shapes that have dropped to delete any blocks within the full rows."""
	if not full_rows.empty():
		get_tree().call_group("dropped_shapes", "delete_rows", full_rows)
		
		"""If the invisible mode is on, this makes the dropped shapes visible when lines are filled."""
		if Autoload.invisible_mode:
			get_tree().call_group("dropped_shapes", "appear")
		
		"""Lowers unfilled rows that are higher than the deleted rows."""
		for row in range(21, 0, -1):
			if row < full_rows.max() - 1 and not row + 1 in full_rows:
				for col in BOARD_WIDTH:
					if board[row][col] == "[X]":
						board[row][col] = "[ ]"
						
						"""Lowers unfilled rows that are between the highest filled and lowest filled row."""
						if row == full_rows.max() - 2 or row == full_rows.max() - 3 and not row + 2 in full_rows:
							board[row + 1][col] = "[X]"
						elif row == full_rows.max() - 3 and full_rows.size() > 1:
							board[row + 2][col] = "[X]"
						else:
							board[row + full_rows.size()][col] = "[X]"
							
		"""Tells the user interface to update the number of filled lines."""
		user_interface.set_score(full_rows.size())
