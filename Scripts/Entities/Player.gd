extends KinematicBody2D
const controller_type = 0


#public and editor settings
export (float, 0.01, 100) var speed_tiles_per_sec = 4
export (float, 0, 1) var horizontal_lerp_weight = 0.5
export (float, 0.01, 100) var max_jump_height = 2.15
export (float, 0.01, 100) var min_jump_height = 0.3
export (float, 0.01, 60) var sec_jump_duration = 0.35
export (float, 0, 60) var sec_jump_buffer = 0.12
export (float, 0, 60) var sec_coyote_time = 0.15


#private variables basen on public settings
var _gravity
var _max_jump_velocity
var _min_jump_velocity
var _lerp_weight
var _speed


#script global woking variables
var _velocity = Vector2(0,0)
#var is_grounded = false
var was_grounded = false

enum{IDLE, WALK, RUN, AIR, JUMP, LAND}
var state = IDLE
var direction = 0
var jumping = false

#subnode cache
onready var GFX = $GFX
onready var coyoteTimer = Timer.new()
onready var jumpBufferTimer = Timer.new()


func _ready():
	add_child(coyoteTimer)
	add_child(jumpBufferTimer)
	
	recalculate_movement_settings()



func recalculate_movement_settings():
	_gravity = 2 * GameState.tile_unit_size.y * max_jump_height / pow(sec_jump_duration, 2)
	_max_jump_velocity = -sqrt(2 * _gravity * max_jump_height * GameState.tile_unit_size.y)
	_min_jump_velocity = -sqrt(2 * _gravity * min_jump_height * GameState.tile_unit_size.y)
	_lerp_weight = 1 - horizontal_lerp_weight
	_speed =  speed_tiles_per_sec * GameState.tile_unit_size.x
	coyoteTimer.wait_time = sec_coyote_time
	jumpBufferTimer.wait_time = sec_jump_buffer
	coyoteTimer.one_shot = true
	jumpBufferTimer.one_shot = true


func set_camera_limits(left_top: Vector2 = Vector2(0, 0), right_bottom: Vector2 = Vector2(1280, 720)):
	$Camera2D.limit_left = left_top.x
	$Camera2D.limit_top = left_top.y
	$Camera2D.limit_right = right_bottom.x
	$Camera2D.limit_bottom = right_bottom.y


func _physics_process(delta):
	#Test move 1 unit down to determine if the player is grounded
#	is_grounded = true if move_and_collide(Vector2.DOWN, false, true, true) else false
	direction = int(GameState.player_can_move) * (-Input.get_action_strength("move_left") + Input.get_action_strength("move_right"))
	
	_velocity.x = lerp(_velocity.x, _speed * direction, _lerp_weight)
	#flip sprite
	if direction == 1:
		GFX.flip_h = false
	elif direction == -1:
		GFX.flip_h = true
	
	#activate jumpBuffer
	if Input.is_action_just_pressed("move_jump") and GameState.player_can_move:
		jumpBufferTimer.start()
		jumping = true
	#jump if jumpBuffer is active
	if is_grounded():
		if not jumpBufferTimer.is_stopped():
			jumpBufferTimer.stop()
			_velocity.y = _max_jump_velocity
#			state = JUMP
	elif not coyoteTimer.is_stopped() and not jumpBufferTimer.is_stopped():
		coyoteTimer.stop()
		jumpBufferTimer.stop()
		_velocity.y = _max_jump_velocity
	else:
		#gravity
		_velocity.y += _gravity * delta
	
	#variable jump cutoff
	if (not Input.is_action_pressed("move_jump") and _velocity.y < _min_jump_velocity):
		_velocity.y = _min_jump_velocity
	

	match state:
		IDLE:
			GFX.play("player_idle")
			if direction:
				state = WALK
			if not is_grounded():
				state = AIR
		
		WALK:
			GFX.play("player_run")
			if not direction:
				state = IDLE
			if not is_grounded():
				state = AIR
		
		AIR:
			GFX.play("player_air")
			if is_grounded():
				state = LAND
				GFX.play("player_land")
		
		LAND:
			GFX.play("player_land")
		
		JUMP:
			GFX.play("player_jump")
		
	#moving
	_velocity = move_and_slide_with_snap(_velocity, Vector2.DOWN, Vector2.UP)
	if was_grounded and not is_grounded() and not jumping:
		jumping = false
		coyoteTimer.start()
	was_grounded = is_grounded()
	jumping = not is_grounded()


func _on_GFX_animation_finished():
	#dirty fix for animation stutter
	if state == JUMP:
		state = AIR
	elif state == LAND:
		state = IDLE


func is_grounded():
	return is_on_floor() #or move_and_collide(Vector2.DOWN * 2, false, true, true)
