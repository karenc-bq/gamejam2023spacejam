extends CharacterBody2D


var speed = 300

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed

func _physics_process(delta):
	get_input()
	move_and_collide(velocity * delta)

#@onready var _animation_player = $AnimationPlayer


#
#func _process(_delta):
#	if Input.is_action_pressed("ui_right"):
#		_animation_player.play("walk")
#	else:
#		_animation_player.stop()
#
#
#var window_width = DisplayServer.window_get_size().x
#
#var speed : int = 300
#var screen_size
#
#const dash_double_tap_within : float = 0.85
#const dash_duration : float = 0.3
#const dash_speed_mult : int = 3
#var norm_speed : int = 300
#var last_tap_right: bool = false
#var animation_time = 0
#
#var is_game_started : bool = false
#
#func new_game():
#	is_game_started = true
#	_animation_player.animation = "walk"
#
#func _physics_process(delta):
#	if not is_game_started:
#		_animation_player.stop()
#		return
#
#	velocity.x = 0
#
#	if Input.is_action_pressed("move_right"):
#		velocity.x += speed
#	if Input.is_action_pressed("move_left"):
#		velocity.x -= speed
#
#	if velocity.length() > 0:
#		_animation_player.play()
#	else:
#		_animation_player.set_frame(0)
#		_animation_player.stop()
#
#	# flips the character when it is walking
#	# the rabbit character is symmetric, so the flipping cannot be 
#	# detected by eye, but if we decide to have another character
#	# that is not symmetric, the flipping should be more obvious. 
#	if velocity.x != 0:
#		_animation_player.flip_v = false
#		_animation_player.flip_h = velocity.x < 0
#	else:
#		_animation_player.set_frame(0)
#		_animation_player.stop()
#
#	move_and_slide()
#
#	# Gravity
#	var player_width = get_node("Hitbox").get_shape().get_extents().x * self.scale.x
#	var max_right = window_width - player_width
#
#	if position.x > max_right:
#		position.x = max_right
#	elif position.x < player_width:
#		position.x = player_width


