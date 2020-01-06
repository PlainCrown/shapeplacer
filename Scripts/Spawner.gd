extends Node2D

"""Spawns new shapes."""

onready var spawn_pos: Position2D = $"../UI/MarginContainer/VBoxContainer/NextShape/Panel/PanelPosition".global_position

const SHAPE = preload("res://Scenes/Shape.tscn")

var first_shape := true
var last_shape: KinematicBody2D = null


func _ready() -> void:
	# makes new shapes truly random and asks the first shape to be spawned
	randomize()
	spawn()


func spawn() -> void:
	# spawns new shapes
	
	# if the current shape is not the first shape, asks to activate the shape in the "next" box
	if not first_shape:
		last_shape.activate()
	# creates a random shape and places it in the "next" box
	var shape := SHAPE.instance()
	var next_shape := randi() % 7
	add_child(shape)
	shape.shape = next_shape
	shape.position = spawn_pos
	last_shape = shape
	# if the current shape is the first shape of the game, asks to spawn another shape
	if first_shape:
		first_shape = false
		spawn()
