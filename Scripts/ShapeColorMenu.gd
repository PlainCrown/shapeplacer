extends Control

"""Controls the functionality of all the buttons in the shape color menu."""

onready var color_shape_array := [$ShapeContainer/Shape0, $ShapeContainer/Shape1, $ShapeContainer/Shape2,
$ShapeContainer/Shape3, $ShapeContainer/Shape4, $ShapeContainer/Shape5, $ShapeContainer/Shape6]

onready var color_picker_array := [$MarginContainer/VBoxContainer/I, $MarginContainer/VBoxContainer/L, 
$MarginContainer/VBoxContainer/T, $MarginContainer/VBoxContainer/S, $MarginContainer/VBoxContainer/O, 
$MarginContainer/VBoxContainer/J, $MarginContainer/VBoxContainer/Z]


func _ready() -> void:
	set_color_pickers()
	change()


func _on_I_color_changed(color: Color) -> void:
	Autoload.color_dic[0] = color
	change()


func _on_L_color_changed(color: Color) -> void:
	Autoload.color_dic[1] = color
	change()


func _on_T_color_changed(color: Color) -> void:
	Autoload.color_dic[2] = color
	change()


func _on_S_color_changed(color: Color) -> void:
	Autoload.color_dic[3] = color
	change()


func _on_O_color_changed(color: Color) -> void:
	Autoload.color_dic[4] = color
	change()


func _on_J_color_changed(color: Color) -> void:
	Autoload.color_dic[5] = color
	change()


func _on_Z_color_changed(color: Color) -> void:
	Autoload.color_dic[6] = color
	change()


func _on_ResetButton_pressed() -> void:
	Autoload.color_dic = Autoload.DEFAULT_COLOR_DIC.duplicate(true)
	set_color_pickers()
	change()


func change() -> void:
	for i in range(7):
		color_shape_array[i].change_shape(i)


func set_color_pickers() -> void:
	for i in color_picker_array.size():
		color_picker_array[i].color = Autoload.color_dic[i]


func _on_BackButton_pressed() -> void:
	"""Exits the options menu when the back button is clicked."""
	get_tree().change_scene("res://Scenes/Options.tscn")


func _unhandled_key_input(event: InputEventKey) -> void:
	"""Exits the options menu when the escape key is pressed."""
	if event.scancode == KEY_ESCAPE and event.pressed:
		get_tree().change_scene("res://Scenes/Options.tscn")