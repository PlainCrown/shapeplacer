extends Node2D

"""Spawns new shapes."""

onready var game = $".."
onready var spawn_pos = $"../UI/MarginContainer/VBoxContainer/NextShape/Panel/PanelPosition".global_position

const SHAPE = preload("res://Scenes/Shape.tscn")

var first_shape := true
var last_shape: KinematicBody2D = null


func _ready() -> void:
	randomize()
	spawn()


func spawn() -> void:
	if not first_shape:
		last_shape.activate()
	var shape := SHAPE.instance()
	var next_shape := randi() % 7
	add_child(shape)
	shape.shape = next_shape
	shape.position = spawn_pos
	last_shape = shape
	if first_shape:
		first_shape = false
		spawn()
