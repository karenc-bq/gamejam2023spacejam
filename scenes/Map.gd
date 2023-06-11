extends TileMap

const Util = preload("res://scenes/Util.gd")
const Furniture = preload("res://scenes/furniture.gd")

@export var map_w: int = 64
@export var map_h: int = 40
@export var min_room_size: int = 9
@export_range(0.2, 0.5) var min_room_factor: float = 0.45

const FLOOR_TILE = Vector2i(12, 14)
const CORRIDOR_TILE = Vector2i(12, 6)
const ROOF_TILE = Vector2i(1, 13)
const WALL_TILE = Vector2i(1, 14)
const WALL_LEFT_TILE = Vector2i(11, 2)
const WALL_RIGHT_TILE = Vector2i(13, 2)
const WALL_EDGE_TILE = Vector2i(12, 3)
const TOP_LEFT_TILE = Vector2i(11, 1)
const TOP_RIGHT_TILE = Vector2i(13, 1)
const BOTTOM_LEFT_TILE = Vector2i(11, 3)
const BOTTOM_RIGHT_TILE = Vector2i(13, 3)
const TOP_DOOR_TILE = Vector2i(12, 24)
const BOTTOM_DOOR_TILE = Vector2i(12, 25)
const EXIT_TILE = Vector2i(12, 0)
const DARK_TILE = Vector2i(0, 0)

const ROOM_BUILDER_ID = 1
const COLOR_ID = 2
const INTERIOR_ID = 3

const BACKGROUND_COLOR_LAYER = 0
const BACKGROUND_LAYER = 1
const FOREGROUND_LAYER = 2
const SPAWN_LAYER = 3

var exit: Vector2i
var deadends = []

const Tiles = { 
	"GROUND": FLOOR_TILE,
	"CORRIDOR": CORRIDOR_TILE,
	"ROOF": ROOF_TILE,
	"WALL": WALL_TILE,
	"LEFT_WALL": WALL_LEFT_TILE,
	"RIGHT_WALL": WALL_RIGHT_TILE,
	"EDGE": WALL_EDGE_TILE,
	"TOP_LEFT": TOP_LEFT_TILE,
	"TOP_RIGHT": TOP_RIGHT_TILE,
	"BOTTOM_LEFT": BOTTOM_LEFT_TILE,
	"BOTTOM_RIGHT": BOTTOM_RIGHT_TILE,
	"TOP_DOOR": TOP_DOOR_TILE,
	"BOTTOM_DOOR": BOTTOM_DOOR_TILE,
	"EXIT": EXIT_TILE,
	"EMPTY" : DARK_TILE
}

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []
var shoeLocation = Vector2(0, 0)
var spawnRoom = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()

func generate():
	clear()
	fill_roof()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()
	draw_edges()
	decorate_rooms()

func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(BACKGROUND_COLOR_LAYER, Vector2i(x, y), COLOR_ID, Tiles.EMPTY)
			set_cell(BACKGROUND_LAYER, Vector2i(x, y), COLOR_ID, Tiles.EMPTY)

func start_tree():
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0

	tree[leaf_id] = { "x": 1, "y": 1, "w": map_w-2, "h": map_h-2 }
	leaf_id += 1

func create_leaf(parent_id):
	var x = tree[parent_id].x
	var y = tree[parent_id].y
	var w = tree[parent_id].w
	var h = tree[parent_id].h

	# used to connect the leaves later
	tree[parent_id].center = { x = floor(x + w/2), y = floor(y + h/2) }

	# whether the tree has space for a split
	var can_split = false

	# randomly split horizontal or vertical
	# if not enough width, split horizontal
	# if not enough height, split vertical
	var split_type = Util.choose(["h", "v"])
	if   (min_room_factor * w < min_room_size):  split_type = "h"
	elif (min_room_factor * h < min_room_size):  split_type = "v"

	var leaf1 = {}
	var leaf2 = {}

	# try and split the current leaf,
	# if the room will fit
	if (split_type == "v"):
		var room_size = min_room_factor * w
		if (room_size >= min_room_size):
			var w1 = Util.randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = { x = x, y = y, w = w1, h = h, split = 'v' }
			leaf2 = { x = x+w1, y = y, w = w2, h = h, split = 'v' }
			can_split = true
	else:
		var room_size = min_room_factor * h
		if (room_size >= min_room_size):
			var h1 = Util.randi_range(room_size, (h - room_size))
			var h2 = h - h1
			leaf1 = { x = x, y = y, w = w, h = h1, split = 'h' }
			leaf2 = { x = x, y = y+h1, w = w, h = h2, split = 'h' }
			can_split = true

	# rooms fit, lets split
	if (can_split):
		leaf1.parent_id    = parent_id
		tree[leaf_id]      = leaf1
		tree[parent_id].l  = leaf_id
		leaf_id += 1

		leaf2.parent_id    = parent_id
		tree[leaf_id]      = leaf2
		tree[parent_id].r  = leaf_id
		leaf_id += 1

		# append these leaves as branches from the parent
		leaves.append([tree[parent_id].l, tree[parent_id].r])

		# try and create more leaves
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)

func create_rooms():
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("l"): continue # if node has children, don't build rooms

		if Util.chance(75):
			var room = {}
			var roomType = randi_range(0, 2)
			room.type = roomType
			
			room.id = leaf_id;
			room.w  = Util.randi_range(min_room_size, leaf.w) - 1
			room.h  = Util.randi_range(min_room_size, leaf.h) - 1
			room.x  = leaf.x + floor((leaf.w - room.w) / 2) + 1
			room.y  = leaf.y + floor((leaf.h - room.h) / 2) + 1
			room.split = leaf.split

			room.center = Vector2()
			room.center.x = floor(room.x + room.w / 2)
			room.center.y = floor(room.y + room.h / 2)
			rooms.append(room);
		
	draw_rooms()
				
func draw_rooms():
	var shoeRoom = randi_range(0, rooms.size() - 1)
	spawnRoom = randi_range(0, rooms.size() - 1)
	while spawnRoom == shoeRoom:
		spawnRoom = randi_range(0, rooms.size() - 1)
		
	# draw the rooms on the tilemap
	for i in range(rooms.size()):
		var r = rooms[i]
		
		for x in range(r.x, r.x + r.w):
			for y in range(r.y, r.y + r.h):
				set_cell(BACKGROUND_LAYER, Vector2i(x, y), ROOM_BUILDER_ID, Tiles.GROUND)
		
		if i == spawnRoom:
			set_cell(SPAWN_LAYER, r.center, ROOM_BUILDER_ID, Tiles.GROUND)
		else:
			var dogInRoom = randi_range(1, 100)
			if dogInRoom >= 40 && i != shoeRoom:
				var dogX = randi_range(r.x + 2, r.x + r.w - 2)
				var dogY = randi_range(r.y + 3, r.y + r.h - 2)
				var dog = load("res://scenes/dog.tscn")
				var newDog = dog.instantiate()
				newDog.position = Vector2(dogX * 32, dogY * 32)
				add_child(newDog)
				newDog.add_to_group("dogs")
				set_cell(FOREGROUND_LAYER, Vector2i(dogX, dogY), ROOM_BUILDER_ID, Vector2i(-2, -2))
			
			var shoeX = randi_range(r.x, r.x + r.w)
			var shoeY = randi_range(r.y, r.y + r.h)
			if i == shoeRoom:
				var shoes = $shoesArea.get_node("shoes")
				shoes.position = Vector2(r.center * 32)

func draw_edges():
	# draw edges for the rooms
	for i in range(rooms.size()):
		var r = rooms[i]
		
		# draw top and bottom edges
		for x in range(r.x, r.x + r.w):
#			set_cell(BACKGROUND_LAYER, Vector2i(x, r.y + r.h), ROOM_BUILDER_ID, Tiles.EDGE)
			
			if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, r.y - 1)) == Tiles.CORRIDOR):
				set_cell(BACKGROUND_LAYER, Vector2i(x, r.y), INTERIOR_ID, Tiles.TOP_DOOR)
				set_cell(BACKGROUND_LAYER, Vector2i(x, r.y + 1), INTERIOR_ID, Tiles.BOTTOM_DOOR)
			else:
				set_cell(BACKGROUND_LAYER, Vector2i(x, r.y), ROOM_BUILDER_ID, Tiles.ROOF)
				set_cell(BACKGROUND_LAYER, Vector2i(x, r.y + 1), ROOM_BUILDER_ID, Tiles.WALL)
#
			if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, r.y + r.h + 1)) == Tiles.CORRIDOR):
				set_cell(BACKGROUND_LAYER, Vector2i(x, r.y + r.h), ROOM_BUILDER_ID, Tiles.CORRIDOR)
		
		# draw side edges
		# for y in range(r.y, r.y + r.h):
		# 	set_cell(BACKGROUND_LAYER, Vector2i(r.x, y), ROOM_BUILDER_ID, Tiles.LEFT_WALL)
		# 	set_cell(BACKGROUND_LAYER, Vector2i(r.x + r.w, y), ROOM_BUILDER_ID, Tiles.RIGHT_WALL)

		# 	if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(r.x - 1, y)) == Tiles.CORRIDOR):
		# 		set_cell(BACKGROUND_LAYER, Vector2i(r.x, y), 1, Tiles.CORRIDOR)

		# 	if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(r.x + r.w + 1, y)) == Tiles.CORRIDOR):
		# 		set_cell(BACKGROUND_LAYER, Vector2i(r.x + r.w, y), ROOM_BUILDER_ID, Tiles.CORRIDOR)


		## draw corners
		# set_cell(BACKGROUND_LAYER, Vector2i(r.x, r.y), ROOM_BUILDER_ID, Tiles.TOP_LEFT)
		# set_cell(BACKGROUND_LAYER, Vector2i(r.x + r.w, r.y), ROOM_BUILDER_ID, Tiles.TOP_RIGHT)
		# set_cell(BACKGROUND_LAYER, Vector2i(r.x, r.y + r.h), ROOM_BUILDER_ID, Tiles.BOTTOM_LEFT)
		# set_cell(BACKGROUND_LAYER, Vector2i(r.x + r.w, r.y + r.h), ROOM_BUILDER_ID, Tiles.BOTTOM_RIGHT)
		
		# clean up side edges
		# var corridor_found = 0
		# for y in range(r.y, r.y + r.h):
		# 	if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(r.x + r.w, y)) == Tiles.CORRIDOR):
		# 		if (corridor_found == 0):
		# 			corridor_found = 1
		# 		else:
		# 			set_cell(BACKGROUND_LAYER, Vector2i(r.x + r.w, y), 1, Tiles.RIGHT_WALL)
	
func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])

func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1

	# Vertical corridor
	if (leaf1.split == 'h'):
		x -= floor(w / 2) + 1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:
		# Horizontal corridor
		y -= floor(h / 2) + 1
		w = abs(leaf1.center.x - leaf2.center.x)

	# Ensure within map
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y

	for i in range(x, x + w):
		for j in range(y, y + h):
			if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(i, j)) == Tiles.EMPTY):
				set_cell(BACKGROUND_LAYER, Vector2i(i, j), ROOM_BUILDER_ID, Tiles.CORRIDOR)
			
func clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in get_used_cells(0):
			if get_cell_atlas_coords(BACKGROUND_LAYER, cell) != Tiles.CORRIDOR: continue

			var nearby = check_nearby(cell.x, cell.y)
			if nearby[0] == 3 || next_to_corner(nearby):
				set_cell(BACKGROUND_LAYER, cell, 1, Tiles.ROOF)
				deadends.append(cell)
				done = false
	
	if (deadends.size() > 1 && exit != null):
		exit = deadends[Util.randi_range(0, deadends.size() - 1)]
		set_cell(BACKGROUND_LAYER, exit, 1, Tiles.EXIT)
	
# check in 4 dirs to see how many tiles are empty
func check_nearby(x, y):
	var count: int = 0
	var non_empty: Vector2i = Tiles.CORRIDOR
	var sides = [Vector2i(x, y - 1), Vector2i(x, y + 1), Vector2i(x - 1, y), Vector2i(x + 1, y)]
	for side in sides:
		if (get_cell_atlas_coords(BACKGROUND_LAYER, side) == Tiles.EMPTY):
			count += 1
		else:
			non_empty = get_cell_atlas_coords(BACKGROUND_LAYER, side)

	return [count, non_empty]

func next_to_corner(nearby):
	var edges = [Tiles.TOP_LEFT, Tiles.TOP_RIGHT, Tiles.BOTTOM_LEFT, Tiles.BOTTOM_RIGHT]
	return edges.has(nearby[1])

func along_wall(x, y):
	if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, y - 1)) == Tiles.GROUND || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, y + 1)) == Tiles.GROUND:
		if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x - 1, y)) == Tiles.CORRIDOR || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x + 1, y)) == Tiles.CORRIDOR:
			return true
			
	if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x - 1, y)) == Tiles.GROUND || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x + 1, y)) == Tiles.GROUND:
		if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, y + 1)) == Tiles.CORRIDOR || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(x, y - 1)) == Tiles.CORRIDOR:
			return true

func decorate_rooms():
	for i in range(rooms.size()):
		var r = rooms[i]
		if i != spawnRoom:
			decorate_room(r)
		
func decorate_room(room):
	var couches = Furniture.get_couches()
	var couch_variation: RectObject = couches[Util.randi_range(0, couches.size() - 1)]
	
	var carpets = Furniture.get_carpets()
	var carpet_variation: RectObject = carpets[Util.randi_range(0, carpets.size() - 1)]

	var wall_decos = Furniture.get_wall_deco()
	var deco_variation: WallDeco = wall_decos[Util.randi_range(0, wall_decos.size() - 1)]
	
	var wall_art = Furniture.get_wall_art()
	var wall_art_variation: WallDeco = wall_art[Util.randi_range(0, wall_art.size() - 1)]
	
	if room.type == 0:
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x, room.center.y), INTERIOR_ID, Furniture.TABLE_TOP_LEFT)
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x + 1, room.center.y), INTERIOR_ID, Furniture.TABLE_TOP_MIDDLE)
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x + 2, room.center.y), INTERIOR_ID, Furniture.TABLE_TOP_RIGHT)
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x, room.center.y + 1), INTERIOR_ID, Furniture.TABLE_BOTTOM_LEFT)
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x + 1, room.center.y + 1), INTERIOR_ID, Furniture.TABLE_BOTTOM_MIDDLE)
		set_cell(FOREGROUND_LAYER, Vector2i(room.center.x + 2, room.center.y + 1), INTERIOR_ID, Furniture.TABLE_BOTTOM_RIGHT)
		
	elif room.type == 1:
		var coordinates = checkFurnitureCorner(room, INTERIOR_ID, 2)
		if coordinates != Vector2i(-1, -1):
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x, coordinates.y + 1), INTERIOR_ID, couch_variation.get_top_left())
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x + 1, coordinates.y + 1), INTERIOR_ID, couch_variation.get_top_middle())
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x + 2, coordinates.y + 1), INTERIOR_ID, couch_variation.get_top_right())
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x, coordinates.y + 2), INTERIOR_ID, couch_variation.get_bottom_left())
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x + 1, coordinates.y + 2), INTERIOR_ID, couch_variation.get_bottom_middle())
			set_cell(FOREGROUND_LAYER, Vector2i(coordinates.x + 2, coordinates.y + 2), INTERIOR_ID, couch_variation.get_bottom_right())
			
		var carpet = Vector2i(room.center.x - 2, room.center.y - 2)
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x, carpet.y + 1), INTERIOR_ID, carpet_variation.get_top_left())
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x + 1, carpet.y + 1), INTERIOR_ID, carpet_variation.get_top_middle())
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x + 2, carpet.y + 1), INTERIOR_ID, carpet_variation.get_top_right())
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x, carpet.y + 2), INTERIOR_ID, carpet_variation.get_bottom_left())
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x + 1, carpet.y + 2), INTERIOR_ID, carpet_variation.get_bottom_middle())
		set_cell(FOREGROUND_LAYER, Vector2i(carpet.x + 2, carpet.y + 2), INTERIOR_ID, carpet_variation.get_bottom_right())
	
	var random_wall = Util.randi_range(room.x + 1, room.x + room.w - 1)
	if (get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(random_wall, room.y)) == Tiles.ROOF && get_cell_atlas_coords(FOREGROUND_LAYER, Vector2i(random_wall, room.y + 1)) == Vector2i(-1, -1)):
		set_cell(FOREGROUND_LAYER, Vector2i(random_wall, room.y), INTERIOR_ID, wall_art_variation.get_top_middle())
		set_cell(FOREGROUND_LAYER, Vector2i(random_wall, room.y + 1), INTERIOR_ID, wall_art_variation.get_middle_middle())
		
	var lampX = randi_range(room.x + 1, room.x + room.w - 1)
	var lampY = randi_range(room.y + 3, room.y + room.h - 3)
	while get_cell_atlas_coords(FOREGROUND_LAYER, Vector2i(lampX, lampY)) != Vector2i(-1, -1) || get_cell_atlas_coords(FOREGROUND_LAYER, Vector2i(lampX, lampY + 1)) != Vector2i(-1, -1):
		lampX = randi_range(room.x + 1, room.x + room.w - 1)
		lampY = randi_range(room.y + 3, room.y + room.h - 3)
	set_cell(FOREGROUND_LAYER, Vector2i(lampX, lampY), INTERIOR_ID, Furniture.LAMP_UP)
	set_cell(FOREGROUND_LAYER, Vector2i(lampX, lampY + 1), INTERIOR_ID, Furniture.LAMP_DOWN)
	
	
func checkFurnitureCorner(room, width, length):
	var startX = room.x + 2
	var startY = room.y
	while startX < (room.x + room.w - width):
		var areaClear = true
		# check above
		for i in range(width):
			if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(startX + i, startY - 1)) == Tiles.CORRIDOR || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(startX + i, startY - 1)) == Tiles.BOTTOM_DOOR:
				areaClear = false
				break

		# check right
		for i in range(length):
			if get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(startX + width, startY + i)) == Tiles.CORRIDOR || get_cell_atlas_coords(BACKGROUND_LAYER, Vector2i(startX + width, startY + i)) == Tiles.BOTTOM_DOOR:
				areaClear = false
				break
		
		if areaClear:
			return Vector2i(startX, startY)
		else:
			startX = startX + width
			
	return Vector2i(-1, -1)
