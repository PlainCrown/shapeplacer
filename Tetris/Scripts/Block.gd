extends CollisionShape2D

"""Changes the color of the blocks for each shape."""

onready var block_sprite: Sprite = $BlockSprite

enum block_colors {Cyan, Blue, Purple, Green, Yellow, Orange, Red}
export(block_colors) var color setget change_color


func change_color(new_color: int) -> void:
	# sets a new block color depending on the shape
	color = new_color
	block_sprite.region_rect = Rect2(color * Autoload.CELL_SIZE, 0, Autoload.CELL_SIZE, Autoload.CELL_SIZE)
