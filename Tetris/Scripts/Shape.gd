extends KinematicBody2D

"""Responsible for all moving and changing shapes."""

onready var drop_timer = $DropTimer
onready var game = $"../.."

const SHAPES = [
	[Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)],  # I
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


func _ready() -> void:
	blocks = [$Block0, $Block1, $Block2, $Block3]
	active = true
	drop()


func _physics_process(delta) -> void:
	if active:
		if Input.is_action_pressed("ui_down"):
			drop_timer.wait_time = 0.1
		else:
			drop_timer.wait_time = 0.8
		if Input.is_action_just_pressed("ui_left"):
			if valid_position(Vector2.LEFT):
				position.x -= CELL_SIZE
		if Input.is_action_just_pressed("ui_right"):
			if valid_position(Vector2.RIGHT):
				position.x += CELL_SIZE
		if Input.is_action_just_pressed("ui_up"):
			rotations += 1
			if rotations == 4:
				rotations = 0
			change_rotation(rotations)


func drop() -> void:
	while active:
		var block_positions := []
		yield(drop_timer, "timeout")
		position.y += CELL_SIZE
		if not valid_position(Vector2.DOWN):
			active = false
			drop_timer.stop()
			for block in blocks:
				block_positions.append(block.global_position)
			game.shape_to_board(block_positions)


func valid_position(direction: Vector2) -> bool:
	for block in blocks:
		if block.global_position.x + direction.x < 40 or block.global_position.x + direction.x > 400 or block.global_position.y + direction.y > 880:
			return false
	return true


func change_rotation(new_rotation: int) -> void:
	if active:
		for block in blocks:
			block.rotation_degrees = -90 * new_rotation
		rotation_degrees = 90 * new_rotation


func change_shape(new_shape: int) -> void:
	shape = new_shape
	for i in blocks.size():
		print(i)
		blocks[i].color = shape
		blocks[i].position = SHAPES[shape][i] * CELL_SIZE
