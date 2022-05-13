extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var max_speed : float = 10
@export var speed_curve : Curve = preload("res://SpeedFalloff.tres")
@export var thrust : float = 100
@export var run_thrust_mult : float = 2
@export var jump_thrust : float = 7
@export var friction : float = 10

@export_node_path var camera_path
@onready var camera = get_node(camera_path) as Camera3D

var MOUSE_SENSITIVITY = -0.1
var time : float = 0
var land_speed : float = 0

const force_offline_mode : bool = false

var input_frame : PackedByteArray
var local_pif : PlayerInputFrame

class PlayerInputFrame:
	var dir : Vector2 = Vector2()
	var mouse : Vector2 = Vector2()
	var run : bool = false
	var jump : bool = false
	var jump_released : bool = false
	
	func serialize() -> PackedByteArray:
		var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
		buffer.put_var(dir)
		buffer.put_var(mouse)
		buffer.put_var(run)
		buffer.put_var(jump)
		buffer.put_var(jump_released)
		
		return buffer.data_array
		
	static func deserialize(data : PackedByteArray) -> PlayerInputFrame:
		var pif = PlayerInputFrame.new()
		var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
		buffer.data_array = data
		pif.dir = buffer.get_var()
		pif.mouse = buffer.get_var()
		pif.run = buffer.get_var()
		pif.jump = buffer.get_var()
		pif.jump_released = buffer.get_var()
		
#		print(OS.get_process_id(), " ", pif.dir)

		return pif as PlayerInputFrame

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func is_local_authority() -> bool:
	if force_offline_mode:
		return true
#	assert(get_multiplayer_authority() == multiplayer.get_unique_id())
#	assert($MultiplayerSynchronizer.get_multiplayer_authority() == get_multiplayer_authority())
	return is_multiplayer_authority()

func _ready():
	input_frame = PlayerInputFrame.new().serialize()
	if is_local_authority():
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		set_multiplayer_authority(get_multiplayer_authority(), true)
		print(OS.get_process_id(), " Local Player Ready: ", get_multiplayer_authority())
		print(OS.get_process_id(), " -> In groups: ", self.get_groups())
	else:
		set_multiplayer_authority(get_multiplayer_authority(), true)
		print(OS.get_process_id(), " Remote Player Ready: ", get_multiplayer_authority())

func _input(event: InputEvent) -> void:
	if not is_local_authority():
		return
#	var pif : PlayerInputFrame = PlayerInputFrame.deserialize(input_frame)
	var pif : PlayerInputFrame = PlayerInputFrame.new()
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pif.mouse = event.relative * MOUSE_SENSITIVITY
		camera.rotate_x(deg2rad(pif.mouse.y))
		rotate_y(deg2rad(pif.mouse.x))
		camera.rotation.x = clamp(camera.rotation.x, -1.4, 1.4)
		
	pif.dir = Input.get_vector("player_strafe_left", "player_strafe_right", "player_forwards", "player_backwards")
	pif.jump = Input.get_action_strength("player_jump")
	pif.jump_released = Input.is_action_just_released("player_jump")
	pif.run = Input.get_action_strength("player_run")
	
	local_pif = pif
	input_frame = pif.serialize()
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var pif : PlayerInputFrame
	if is_local_authority():
		pif = local_pif
	else:
		pif = PlayerInputFrame.deserialize(input_frame)

		camera.rotate_x(deg2rad(pif.mouse.y))
		rotate_y(deg2rad(pif.mouse.x))
		camera.rotation.x = clamp(camera.rotation.x, -1.4, 1.4)
	
	if pif == null:
		printerr(OS.get_process_id(), " PIF is null!!: ", get_multiplayer_authority())
		move_and_slide()
		return
	var dir2 = pif.dir
	var dir : Vector3 = Vector3(dir2.x, 0, dir2.y)
	

	var global_dir = dir.rotated(global_transform.basis.y, global_transform.basis.get_euler().y)
	var planer_vel = motion_velocity
	planer_vel.y = 0
	land_speed = planer_vel.length()

	var r : float = max(int(pif.run) * run_thrust_mult, 1)
	motion_velocity += speed_curve.interpolate_baked(land_speed / (max_speed * r)) * r * thrust * global_dir * delta
	
	motion_velocity = motion_velocity.lerp(Vector3(0, motion_velocity.y, 0), friction * delta)
	if is_on_floor():
		motion_velocity.y += int(pif.jump) * jump_thrust
	else:
		motion_velocity.y -= (9.81 * delta)
		
		if motion_velocity.y > 0 && pif.jump_released:
			motion_velocity.y *= 0.5
	
	move_and_slide()


#func _physics_process(delta):
#	# Add the gravity.
#	if not is_on_floor():
#		motion_velocity.y -= gravity * delta
#	if is_local_authority():
#		# Handle Jump.
#		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#			motion_velocity.y = JUMP_VELOCITY
#
#		# Get the input direction and handle the movement/deceleration.
#		# As good practice, you should replace UI actions with custom gameplay actions.
#
#		var input_dir : Vector2 = Input.get_vector("player_strafe_right", "player_strafe_left", "player_backwards", "player_forwards")
#		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#		if direction:
#			motion_velocity.x = direction.x * SPEED
#			motion_velocity.z = direction.z * SPEED
#		else:
#			motion_velocity.x = move_toward(motion_velocity.x, 0, SPEED)
#			motion_velocity.z = move_toward(motion_velocity.z, 0, SPEED)
#
#	move_and_slide()
