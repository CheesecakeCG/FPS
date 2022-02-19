extends Camera3D


@onready var body : CharacterBody3D = get_parent()
@export var sensitivity : float = 130

#var is_ads : bool = true
#
#var _vel : Vector2
#
#func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	pass
#
#func _physics_process(delta):
#	body.rotate_y(_vel.x * delta * sensitivity)
#	rotation.x += _vel.y * delta * sensitivity
#	rotation.x = clamp(rotation.x, deg2rad(-80), deg2rad(80))
#	rotation.y = clamp(lerp(rotation.y, deg2rad(-180), delta), deg2rad(-185), deg2rad(-175))
#
#	_vel = Vector2()
#
##	is_ads = Input.is_action_pressed("player_ads")
##
##	if is_ads:
##		fov = lerp(fov, 20, delta * 10)
##	else:
##		fov = lerp(fov, 50, delta * 4)
#
#func _input(event):
#	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
#		if (event is InputEventMouseMotion or event is InputEventScreenDrag):
#			_vel.x -= event.relative.x / get_viewport().size.y
#			_vel.y -= event.relative.y / get_viewport().size.x
#	else:
#		_vel = Vector2()
