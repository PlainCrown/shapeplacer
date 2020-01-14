extends Node2D

"""Spawns new shapes."""

onready var spawn_pos: Vector2 = $"../UI/MarginContainer/VBoxContainer/NextShape/Panel/SpawnPos".global_position

const SHAPE = preload("res://Scenes/Shape.tscn")

var first_shape := true
var second_shape := true
var next_shape: KinematicBody2D = null
var last_shape: KinematicBody2D = null


func _ready() -> void:
	# makes new shapes truly random and asks the first shape to be spawned
	randomize()
	spawn()


func spawn() -> void:
	# spawns new shapes
	if last_shape:
		last_shape.position -= Vector2(0, 100)
	# if the current shape is not the first shape, asks to activate the shape in the "next" box
	if not second_shape:
		next_shape.activate()
	# creates a random shape and places it in the "next" box
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
	# if the current shape is the first shape of the game, asks to spawn another shape
	if first_shape:
		first_shape = false
		spawn()
	elif second_shape:
		second_shape = false
		spawn()
