extends Node3D

class_name PlayerTool

@export var foregrip_path : NodePath
@onready var foregrip : Node3D = get_node(foregrip_path)
@export var maingrip_path : NodePath
@onready var maingrip : Node3D = get_node(maingrip_path)

var actions : Array[Callable]

signal used(action_index : int)
