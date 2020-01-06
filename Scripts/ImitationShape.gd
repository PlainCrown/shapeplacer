extends KinematicBody2D

"""Takes up the same space as Shape and is used to test if rotating Shape is safe."""

onready var real_shape: KinematicBody2D = $".."
onready var imitated_blocks := [$Block0, $Block1, $Block2, $Block3]
onready var real_blocks := [$"../Block0", $"../Block1", $"../Block2", $"../Block3"]


func valid_imitation(new_rotation: int) -> bool:
	# rotates a copy of the shape to check if the real shape can be rotated without causing errors 
	imitated_blocks[0].global_position = real_blocks[0].global_position
	imitated_blocks[1].global_position = real_blocks[1].global_position
	imitated_blocks[2].global_position = real_blocks[2].global_position
	imitated_blocks[3].global_position = real_blocks[3].global_position
	rotation_degrees = 90 * new_rotation
	# asks if the rotation is valid
	var valid: bool = real_shape.valid_position(Vector2(0,0), imitated_blocks)
	if not valid:
		rotation_degrees -= 90
	return valid