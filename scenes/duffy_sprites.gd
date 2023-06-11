extends Area2D

# Code is borrowed from:
# https://docs.godotengine.org/en/stable/getting_started/first_2d_game/03.coding_the_player.html

const Map = preload("res://scenes/Map.gd")

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var tile_map
var alerted = false

func _ready():
	screen_size = get_viewport_rect().size
	tile_map = get_parent().get_node("TileMap")
	var start_room = tile_map.rooms[0]
<<<<<<< HEAD
	position = tile_map.map_to_local(start_room.center)
=======
	position = tile_map.map_to_local(Vector2(start_room.center.x - 1, start_room.center.y - 1))
	
>>>>>>> a6b714d (some furniture)

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
	var tile = tile_map.get_cell_atlas_coords(0, tile_map.local_to_map(Vector2i(future_pos.x, future_pos.y)))
<<<<<<< HEAD
	if (tile == Map.Tiles.BOTTOM_DOOR || tile == Map.Tiles.TOP_DOOR || tile == Map.Tiles.CORRIDOR || tile == Map.Tiles.GROUND || tile == Map.Tiles.EXIT):
=======
	var furnitureTile = tile_map.get_cell_atlas_coords(1, tile_map.local_to_map(Vector2i(future_pos.x, future_pos.y)))
	if (tile == Map.Tiles.BOTTOM_DOOR || tile == Map.Tiles.TOP_DOOR || tile == Map.Tiles.CORRIDOR || tile == Map.Tiles.GROUND):
		var isFurniture = false
		for i in range(Map.Furniture.FURNITURE_TILES.size()):
			if furnitureTile == Map.Furniture.FURNITURE_TILES[i]:
				isFurniture = true
				break
				
>>>>>>> a6b714d (some furniture)
		# able to walk on the tile
		if !isFurniture:
			position = future_pos
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if (!alerted && tile_map.get_cell_atlas_coords(0, tile_map.local_to_map(Vector2i(position.x, position.y))) == Map.Tiles.EXIT):
		OS.alert('You have found the exit', 'Exit')
		alerted = true
