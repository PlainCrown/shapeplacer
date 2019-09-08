extends Node2D

"""Spawns new shapes."""

onready var spawn_pos = $"../UI/MarginContainer/VBoxContainer/NextShape/Panel/PanelPosition".global_position
onready var game = $".."

const SHAPE = preload("res://Scenes/Shape.tscn")


func spawn():
	var shape := SHAPE.instance()
	var next_shape := randi() % 7
	add_child(shape)
	shape.shape = next_shape
	shape.position = Vector2(200, 40)
