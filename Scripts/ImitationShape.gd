extends KinematicBody2D

"""Invisible copy of the shape, used to test if it's safe to rotate the shape."""

onready var real_shape: KinematicBody2D = $".."
onready var imitated_blocks := [$Block0, $Block1, $Block2, $Block3]
onready var real_blocks := [$"../Block0", $"../Block1", $"../Block2", $"../Block3"]


func valid_imitation(new_rotation: int) -> bool:
	"""Sets the invisible block positions to be equal to the visible shape, and rotates them."""
	imitated_blocks[0].global_position = real_blocks[0].global_position
	imitated_blocks[1].global_position = real_blocks[1].global_position
	imitated_blocks[2].global_position = real_blocks[2].global_position
	imitated_blocks[3].global_position = real_blocks[3].global_position
	rotation_degrees = 90 * new_rotation
	
	"""Checks if the shape can maintain the rotated position without entering walls or other shapes."""
	var valid: bool = real_shape.valid_position(Vector2(0, 0), imitated_blocks)
	
	"""Tells the visible shape if it can rotate and resets the invisible blocks if it can't."""
	if not valid:
		rotation_degrees -= 90
	return valid
