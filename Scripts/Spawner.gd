extends Node2D

"""Spawns new shapes."""

onready var spawn_pos: Vector2 = $"../UI/MarginContainer/VBoxContainer/NextShape/Panel/SpawnPos".global_position

const SHAPE = preload("res://Scenes/Shape.tscn")

var first_shape := true
var second_shape := true
var next_shape: KinematicBody2D = null
var last_shape: KinematicBody2D = null


func _ready() -> void:
	"""Makes RNG truly random and tells the first shape to spawn."""
	randomize()
	spawn()


func spawn() -> void:
	"""Moves the last spawned shape up by 100 pixels in the shape queue."""
	if last_shape:
		last_shape.position -= Vector2(0, 100)
	
	"""Activates the next shape in the shape queue."""
	if not second_shape:
		next_shape.activate()
	
	"""Creates a new random shape and places it at the bottom of the shape queue."""
	var shape := SHAPE.instance()
	var new_shape := randi() % 7
	add_child(shape)
	shape.shape = new_shape
	if new_shape == 0 or new_shape == 4:
		shape.position = spawn_pos - Vector2(20, 0)
	else:
		shape.position = spawn_pos
	next_shape = last_shape
	last_shape = shape
	
	"""Tells the function to spawn another shape if this is the first spawned shape."""
	if first_shape:
		first_shape = false
		spawn()
	
		"""Tells the function to spawn another shape if this is the second spawned shape."""
	elif second_shape:
		second_shape = false
		spawn()
