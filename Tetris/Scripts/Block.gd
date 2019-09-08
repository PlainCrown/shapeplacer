extends CollisionShape2D

"""Changes the color of the blocks for each shape."""

onready var block_sprite = $BlockSprite

enum block_colors {Cyan, Blue, Purple, Green, Yellow, Orange, Red}
export(block_colors) var color setget change_color

const CELL_SIZE = 40


func change_color(new_color: int) -> void:
	color = new_color
	block_sprite.region_rect = Rect2(color * CELL_SIZE, 0, CELL_SIZE, CELL_SIZE)
