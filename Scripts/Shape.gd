extends KinematicBody2D

"""Responsible for moving, changing, and deleting shapes. Also handles all of the sound effects."""

onready var audio_player: AudioStreamPlayer2D = $"../../AudioPlayer"
onready var user_interface: Control = $"../../UI"
onready var game: Node2D = $"../.."
onready var invisible_tween := $InvisibleTween
onready var imitation := $ImitationShape
onready var drop_timer := $DropTimer

const SHAPE_DROP_SOUND = preload("res://Assets/Sounds/ShapeDrop.wav")
const LINE_BREAK_SOUND = preload("res://Assets/Sounds/LineBreak.wav")
const GAME_OVER_SOUND = preload("res://Assets/Sounds/GameOver.wav")
const SHAPES = [
	[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],  # I
	[Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)], # L
	[Vector2(0, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0)],  # T
	[Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)],  # S
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)],   # O
	[Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0)],  # J
	[Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(-1, 0)]]  # Z

export(int, "I", "L", "T", "S", "O", "J", "Z") var shape setget change_shape

var active := false
var rotations := 0
var blocks := []
var block_positions := []


func _ready() -> void:
	"""Sets the shape's drop speed and creates an array containing its blocks."""
	drop_timer.wait_time = Autoload.shape_drop_speed
	blocks = [$Block0, $Block1, $Block2, $Block3]


func _physics_process(delta: float) -> void:
	"""Allows the player to move and rotate the shape while it's active."""
	if active:
		if Input.is_action_just_pressed("ui_down"):
			drop_timer.wait_time = 0.04
			drop_timer.start()
		elif Input.is_action_just_released("ui_down"):
			drop_timer.wait_time = Autoload.shape_drop_speed
		if Input.is_action_just_pressed("ui_left"):
			if valid_position(Vector2.LEFT):
				position.x -= Autoload.CELL_SIZE
		if Input.is_action_just_pressed("ui_right"):
			if valid_position(Vector2.RIGHT):
				position.x += Autoload.CELL_SIZE
		if Input.is_action_just_pressed("ui_up"):
			change_rotation()


func activate() -> void:
	"""Moves the shape from the next shape list to the spawn position, then runs a quick delay that 
	gives the game board time to be created at the start of the game, preventing a fatal error 
	caused by calling the valid_position function too early."""
	position = Vector2(200, 40)
	yield(get_tree().create_timer(0.001), "timeout")
	
	"""Checks if the spawn position is already occupied by another shape, sets game_over as true if 
	it is and moves the shape upwards until it no longer overlaps any other shapes."""
	if not valid_position(Vector2.ZERO):
		position = Vector2(200, 0)
		game.game_over = true
		if not valid_position(Vector2.ZERO):
			position = Vector2(200, -40)
	
	"""Tells the user interface to run the game over function and plays the game over sound effect."""
	if game.game_over:
		user_interface.game_over()
		audio_player.stream = GAME_OVER_SOUND
		audio_player.play()
		
		"""Displays all of the invisible shapes if the invisible mode is on."""
		if Autoload.invisible_mode:
			for shape in get_tree().get_nodes_in_group("dropped_shapes"):
				shape.invisible_tween.stop_all()
				shape.modulate = Color(1, 1, 1, 1)
				
		"""Sets self as the active shape and starts the shape drop timer if the game_over wasn't triggered."""
	else:
		active = true
		user_interface.active_shape = self
		drop_timer.start()


func _on_DropTimer_timeout() -> void:
	"""Drops the shape by one row if it's safe to do so."""
	if active:
		if valid_position(Vector2.DOWN):
			position.y += Autoload.CELL_SIZE
		
			"""Stops the drop timer and adds the shape to the dropped shape group if it can't drop further."""
		else:
			active = false
			drop_timer.stop()
			add_to_group("dropped_shapes")
			
			"""Fades out the shape if the invisible mode is on."""
			if Autoload.invisible_mode:
				invisible_tween.interpolate_property(self, "modulate:a", 1, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				invisible_tween.start()
			
			"""Tells game.gd to add the shape to the game board."""
			for block in blocks:
				block_positions.append(block.global_position)
			game.shape_to_board(block_positions)
			
			"""Plays the shape drop sound effect."""
			if audio_player.stream != GAME_OVER_SOUND:
				audio_player.stream = SHAPE_DROP_SOUND
				audio_player.play()


func valid_position(direction: Vector2, block_array: Array = blocks) -> bool:
	"""Chekcs if the shape can move or rotate in the player's chosen direction."""
	for block in block_array:
		var next_pos: Vector2 = block.global_position + direction * Autoload.CELL_SIZE
		if round(next_pos.x) < 40 or round(next_pos.x) > 400 or round(next_pos.y) > 880 or \
		game.board[round(next_pos.y) / Autoload.CELL_SIZE - 1][round(next_pos.x) / Autoload.CELL_SIZE - 1] != "[ ]":
			return false
	return true


func change_rotation() -> void:
	"""Rotates the shape."""
	if active and shape != 4:
		rotations += 1
		if rotations == 4:
			rotations = 0
		if imitation.valid_imitation(rotations):
			for block in blocks:
				block.rotation_degrees = -90 * rotations
			rotation_degrees = 90 * rotations
		else:
			if rotations == 0:
				rotations = 3
			else:
				rotations -= 1


func change_shape(new_shape: int) -> void:
	"""Changes the shape and color of the shape's blocks."""
	shape = new_shape
	for i in blocks.size():
		blocks[i].color = shape
		blocks[i].position = SHAPES[shape][i] * Autoload.CELL_SIZE


func delete_rows(rows: Array) -> void:
	"""Deletes blocks from full rows."""
	for row in rows:
		var row_y_pos: int = row * Autoload.CELL_SIZE
		for block in range(blocks.size() - 1, -1, -1):
			if round(blocks[block].global_position.y) == row_y_pos:
				blocks[block].free()
				blocks.remove(block)
				
	"""Plays the line break sound effect."""
	audio_player.stream = LINE_BREAK_SOUND
	audio_player.play()
	
	"""Deletes shapes that don't contain any blocks."""
	if blocks.empty():
		queue_free()
		return
	
	"""Lowers the remaining dropped shapes that are above the removed rows."""
	for block in blocks:
		var block_y: int = block.global_position.y / Autoload.CELL_SIZE
		if block_y < rows.max():
			
			"""Lowers the remaning dropped shapes that are lower than the highest removed row."""
			if block_y == rows.max() - 1 or block_y == rows.max() - 2 and not rows.max() - 1 in rows:
				block.global_position.y += Autoload.CELL_SIZE
			elif block_y == rows.max() - 2 and rows.size() > 1:
				block.global_position.y += Autoload.CELL_SIZE * 2
			else:
				block.global_position.y += Autoload.CELL_SIZE * rows.size()


func appear() -> void:
	"""Makes dropped invisible shapes shortly appear and fade out again."""
	modulate.a = 1
	invisible_tween.interpolate_property(self, "modulate:a", 1, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	invisible_tween.start()
