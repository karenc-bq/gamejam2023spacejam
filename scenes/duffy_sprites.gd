extends Area2D

# Code is borrowed from:
# https://docs.godotengine.org/en/stable/getting_started/first_2d_game/03.coding_the_player.html

const Map = preload("res://scenes/Map.gd")

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var tile_map

func _ready():
	screen_size = get_viewport_rect().size
	tile_map = get_parent().get_node("TileMap")
	var start_room = tile_map.rooms[0]
	position = tile_map.map_to_local(start_room.center)
#	position.x  = screen_size.x/2
#	position.y  = screen_size.y/2
	

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
	print("-AL- player: x:", future_pos.x)
	print("-AL- player: y:", future_pos.y)
#	var map_x = future_pos.x/16
#	var map_y = future_pos.y/16
#	print("-AL- player: x/16:", map_x)
#	print("-AL- player: y/16:", map_y)
	print("-AL- player: to_map:", tile_map.local_to_map(Vector2i(future_pos.x, future_pos.y)))
	print("-AL- get_cell_atlas_coords player orig X, Y: ", tile_map.get_cell_atlas_coords(0, Vector2i(future_pos.x, future_pos.y)))
#	if (tile_map.get_cell_atlas_coords(0, Vector2i(future_pos.x, future_pos.y)) != Map.Tiles.WALL):
#	print("-AL- get_cell_atlas_coords player updated X, Y: ", tile_map.get_cell_atlas_coords(0, Vector2i(map_x, map_y)))
#	if (tile_map.get_cell_atlas_coords(0, Vector2i(map_x, map_y)) != Map.Tiles.WALL):
	print("-AL- get_cell_atlas_coords player updated X, Y: ", tile_map.get_cell_atlas_coords(0, tile_map.local_to_map(Vector2i(future_pos.x, future_pos.y))))
	var tile = tile_map.get_cell_atlas_coords(0, tile_map.local_to_map(Vector2i(future_pos.x, future_pos.y)))
	if (tile == Map.Tiles.BOTTOM_DOOR || tile == Map.Tiles.CORRIDOR || tile == Map.Tiles.GROUND):
		print("-AL- wall not detected")
		position = future_pos
	else:
		print("-AL- wall detected")
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
