extends KinematicBody2D

"""Responsible for all moving and changing shapes.
ROTATIONS NEED TO BE FIXED."""


onready var drop_timer = $DropTimer
onready var game = $"../.."
onready var imitation = $ImitationShape

const SHAPES = [
	[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)], # I
	[Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],  # L
	[Vector2(0, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0)],  # T
	[Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)],  # S
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)],  # O
	[Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0)],  # J
	[Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(-1, 0)]]  # Z

export(int, "I", "L", "T", "S", "O", "J", "Z") var shape setget change_shape

const CELL_SIZE = 40

var active := false
var rotations := 0
var blocks := []
var time := 0.8


func _ready() -> void:
	drop_timer.wait_time = time
	blocks = [$Block0, $Block1, $Block2, $Block3]
#	active = true
#	drop()


func _physics_process(delta) -> void:
	if active:
		if Input.is_action_pressed("ui_down"):
			drop_timer.wait_time = 0.08
		else:
			drop_timer.wait_time = time
		if Input.is_action_just_pressed("ui_left"):
			if valid_position(Vector2.LEFT):
				position.x -= CELL_SIZE
		if Input.is_action_just_pressed("ui_right"):
			if valid_position(Vector2.RIGHT):
				position.x += CELL_SIZE
		if Input.is_action_just_pressed("ui_up"):
			change_rotation()


func activate() -> void:
	position = Vector2(200, 40)
	active = true
	drop()


func drop() -> void:
	var block_positions := []
	while active:
		yield(drop_timer, "timeout")
		if valid_position(Vector2.DOWN):
			position.y += CELL_SIZE
		else:
			active = false
			drop_timer.stop()
			for block in blocks:
				block_positions.append(block.global_position)
			game.shape_to_board(block_positions)


func valid_position(direction: Vector2, block_array: Array = blocks) -> bool:
	for block in block_array:
		var next_pos: Vector2 = block.global_position + direction * CELL_SIZE
		if round(next_pos.x) < 40 or round(next_pos.x) > 400 or round(next_pos.y) > 880 \
		or game.board[round(next_pos.y) / CELL_SIZE - 1][round(next_pos.x) / CELL_SIZE - 1] != "[ ]":
			return false
	return true


func change_rotation() -> void:
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
	shape = new_shape
	for i in blocks.size():
		blocks[i].color = shape
		blocks[i].position = SHAPES[shape][i] * CELL_SIZE
