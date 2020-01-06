extends CollisionShape2D

"""Changes the color of the blocks for each shape."""

onready var block_sprite: Sprite = $BlockSprite

enum block_colors {I_color, L_color, T_color, S_color, O_color, J_color, Z_color}
export (block_colors) var color setget change_color


func change_color(new_color: int) -> void:
	# sets a new block color depending on the shape
	color = new_color
	block_sprite.modulate = Autoload.color_dic[color]
