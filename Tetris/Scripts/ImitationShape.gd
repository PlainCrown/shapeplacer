extends KinematicBody2D

"""Takes up the same space as Shape and is used to test if rotating Shape is safe.
Please replace this abomination with a better solution if you can think of one."""

onready var real_shape = $".."
onready var imitated_blocks = [$Block0, $Block1, $Block2, $Block3]
onready var real_blocks = [$"../Block0", $"../Block1", $"../Block2", $"../Block3"]

const CELL_SIZE = 40


func valid_imitation(new_rotation: int) -> bool:
	imitated_blocks[0].global_position = real_blocks[0].global_position
	imitated_blocks[1].global_position = real_blocks[1].global_position
	imitated_blocks[2].global_position = real_blocks[2].global_position
	imitated_blocks[3].global_position = real_blocks[3].global_position
	rotation_degrees = 90 * new_rotation
	var valid: bool = real_shape.valid_position(Vector2(0,0), imitated_blocks)
	if not valid:
		rotation_degrees -= 90
	return valid
