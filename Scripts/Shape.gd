extends KinematicBody2D

"""Responsible for moving, changing, and deleting shapes. Also, sound effects."""

onready var drop_timer: Timer = $DropTimer
onready var game: Node2D = $"../.."
onready var user_interface: Control = $"../../UI"
onready var imitation: KinematicBody2D = $ImitationShape
onready var audio_player: AudioStreamPlayer2D = $"../../AudioPlayer"

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


func _ready() -> void:
	# sets the drop timer and creates an array consisting of all shape's blocks
	z_index = 1
	drop_timer.wait_time = Autoload.shape_drop_speed
	blocks = [$Block0, $Block1, $Block2, $Block3]


func _physics_process(delta: float) -> void:
	# gives player control over the active shape and asks if the shape can be moved or rotated
	if active:
		if Input.is_action_pressed("ui_down"):
			drop_timer.wait_time = 0.04
		else:
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
	# repositions and activates the shape locked in the "next" box, asks to drop the shape
	z_index = 0
	position = Vector2(200, 40)
	active = true
	drop()


func drop() -> void:
	# drops the current active shape, stops its movement, and checks if the game is over
	user_interface.active_shape = self
	var block_positions := []
	# asks if the shape can be lowered and does so if possible
	while active:
		yield(drop_timer, "timeout")
		if not active:
			return
		if valid_position(Vector2.DOWN):
			position.y += Autoload.CELL_SIZE
		# stops the shape once it can't move any further
		else:
			active = false
			drop_timer.stop()
			add_to_group("dropped_shapes")
			# asks to play the shape drop sound effect
			audio_player.stream = SHAPE_DROP_SOUND
			audio_player.play()
			# checks if the game is over and asks to display the game over label if true
			if self.position == Vector2(200, 40):
				game.game_over = true
				user_interface.game_over()
				# asks to play the game over sound effect
				audio_player.stream = GAME_OVER_SOUND
				audio_player.play()
			# asks the game script to add the shape to the game board
			for block in blocks:
				block_positions.append(block.global_position)
			game.shape_to_board(block_positions)


func valid_position(direction: Vector2, block_array: Array = blocks) -> bool:
	# checks if the shape can move left, right, or down
	for block in block_array:
		var next_pos: Vector2 = block.global_position + direction * Autoload.CELL_SIZE
		if round(next_pos.x) < 40 or round(next_pos.x) > 400 or round(next_pos.y) > 880 or \
		game.board[round(next_pos.y) / Autoload.CELL_SIZE - 1][round(next_pos.x) / Autoload.CELL_SIZE - 1] != "[ ]":
			return false
	return true


func change_rotation() -> void:
	# rotates the shape
	if active and shape != 4:
		rotations += 1
		if rotations == 4:
			rotations = 0
		# asks a copy of the shape if it's safe to rotate and rotates if true
		if imitation.valid_imitation(rotations):
			for block in blocks:
				block.rotation_degrees = -90 * rotations
			rotation_degrees = 90 * rotations
		# otherwise makes sure that the previous rotation attempt is ignored
		else:
			if rotations == 0:
				rotations = 3
			else:
				rotations -= 1


func change_shape(new_shape: int) -> void:
	# asks to change the arrangement and color of the shape's blocks
	shape = new_shape
	for i in blocks.size():
		blocks[i].color = shape
		blocks[i].position = SHAPES[shape][i] * Autoload.CELL_SIZE


func delete_rows(rows: Array) -> void:
	# deletes blocks inside full rows and empty shapes, also lowers the remaining shapes
	
	# deletes blocks from full rows
	for row in rows:
		var row_y_pos: int = row * Autoload.CELL_SIZE
		for block in range(blocks.size() - 1, -1, -1):
			if round(blocks[block].global_position.y) == row_y_pos:
				blocks[block].free()
				blocks.remove(block)
	# asks to play the line break sound effect
	audio_player.stream = LINE_BREAK_SOUND
	audio_player.play()
	# deletes shapes that don't have any blocks left
	if blocks.empty():
		self.queue_free()
		return
	# lowers the shapes that remain above the removed rows
	for block in blocks:
		var block_y: int = block.global_position.y / Autoload.CELL_SIZE
		if block_y < rows.max():
			# catches exceptions where the lowest unfilled row is lower than the highest filled row
			if block_y == rows.max() - 1 or block_y == rows.max() - 2 and not rows.max() - 1 in rows:
				block.global_position.y += Autoload.CELL_SIZE
			elif block_y == rows.max() - 2 and rows.size() > 1:
				block.global_position.y += Autoload.CELL_SIZE * 2
			else:
				block.global_position.y += Autoload.CELL_SIZE * rows.size()
