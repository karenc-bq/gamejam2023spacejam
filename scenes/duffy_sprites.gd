extends Area2D

# Code is borrowed from:
# https://docs.godotengine.org/en/stable/getting_started/first_2d_game/03.coding_the_player.html

const Map = preload("res://scenes/Map.gd")

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var tile_map

func _ready():
	screen_size = get_viewport_rect().size
	position.x  = screen_size.x/2
	position.y  = screen_size.y/2
	tile_map = get_parent().get_node("TileMap")

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$CharacterBody2D.play()
	else:
		$CharacterBody2D.stop()
	
	var future_pos = position + velocity * delta
	#print("-AL- player: x, y:", future_pos.x, future_pos.y)
	#print("-AL- get_cell_atlas_coords player: ", tile_map.get_cell_atlas_coords(0, Vector2i(future_pos.x, future_pos.y)))
	if (tile_map.get_cell_atlas_coords(0, Vector2i(future_pos.x, future_pos.y)) != Map.Tiles.WALL):
		#print("-AL- wall not detected")
		position = future_pos
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	#print("-AL- wall detected")
