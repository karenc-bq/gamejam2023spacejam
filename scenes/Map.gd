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

const ROOM_BUILDER_ID = 1
const INTERIOR_ID = 3

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
	"EMPTY" : Vector2i(-1 ,-1)
}

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []
var shoeLocation = Vector2(0, 0)

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

func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(0, Vector2i(x, y), 1, Tiles.EMPTY)

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
	var shoeRoom = randi_range(0, rooms.size())
	# draw the rooms on the tilemap
	for i in range(rooms.size()):
		var r = rooms[i]
		var shoeX = randi_range(r.x, r.x + r.w)
		var shoeY = randi_range(r.y, r.y + r.h)
		if i == shoeRoom:
<<<<<<< HEAD
			var shoesArea = Area2D.new()
			var shoes = Sprite2D.new()
			shoeLocation = r.center
=======
			var shoes = $shoesArea.get_node("shoes")
>>>>>>> main
			shoes.position = Vector2(r.center * 32)

		for x in range(r.x, r.x + r.w):
			for y in range(r.y, r.y + r.h):
				set_cell(0, Vector2i(x, y), ROOM_BUILDER_ID, Tiles.GROUND)
				
func draw_edges():
	# draw edges for the rooms
	for i in range(rooms.size()):
		var r = rooms[i]
		
		# draw top and bottom edges
		for x in range(r.x, r.x + r.w):
			set_cell(0, Vector2i(x, r.y + r.h), ROOM_BUILDER_ID, Tiles.EDGE)
			
			if (get_cell_atlas_coords(0, Vector2i(x, r.y - 1)) == Tiles.CORRIDOR):
				set_cell(0, Vector2i(x, r.y), INTERIOR_ID, Tiles.TOP_DOOR)
				set_cell(0, Vector2i(x, r.y + 1), INTERIOR_ID, Tiles.BOTTOM_DOOR)
			else:
				set_cell(0, Vector2i(x, r.y), ROOM_BUILDER_ID, Tiles.ROOF)
				set_cell(0, Vector2i(x, r.y + 1), ROOM_BUILDER_ID, Tiles.WALL)

			if (get_cell_atlas_coords(0, Vector2i(x, r.y + r.h + 1)) == Tiles.CORRIDOR):
				set_cell(0, Vector2i(x, r.y + r.h), ROOM_BUILDER_ID, Tiles.CORRIDOR)
		
		# draw side edges
		for y in range(r.y, r.y + r.h):
			set_cell(0, Vector2i(r.x, y), ROOM_BUILDER_ID, Tiles.LEFT_WALL)
			set_cell(0, Vector2i(r.x + r.w, y), ROOM_BUILDER_ID, Tiles.RIGHT_WALL)
				
			if (get_cell_atlas_coords(0, Vector2i(r.x - 1, y)) == Tiles.CORRIDOR):
				set_cell(0, Vector2i(r.x, y), 1, Tiles.CORRIDOR)
			
			if (get_cell_atlas_coords(0, Vector2i(r.x + r.w + 1, y)) == Tiles.CORRIDOR):
				set_cell(0, Vector2i(r.x + r.w, y), ROOM_BUILDER_ID, Tiles.CORRIDOR)
				

		## draw corners
		set_cell(0, Vector2i(r.x, r.y), ROOM_BUILDER_ID, Tiles.TOP_LEFT)
		set_cell(0, Vector2i(r.x + r.w, r.y), ROOM_BUILDER_ID, Tiles.TOP_RIGHT)
		set_cell(0, Vector2i(r.x, r.y + r.h), ROOM_BUILDER_ID, Tiles.BOTTOM_LEFT)
		set_cell(0, Vector2i(r.x + r.w, r.y + r.h), ROOM_BUILDER_ID, Tiles.BOTTOM_RIGHT)
		
		# clean up side edges
		var corridor_found = 0
		for y in range(r.y, r.y + r.h):
			if (get_cell_atlas_coords(0, Vector2i(r.x + r.w, y)) == Tiles.CORRIDOR):
				if (corridor_found == 0):
					corridor_found = 1
				else:
					set_cell(0, Vector2i(r.x + r.w, y), 1, Tiles.RIGHT_WALL)
			
	for i in range(rooms.size()):
		var r = rooms[i]
		decorate_room(r)

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
			if (get_cell_atlas_coords(0, Vector2i(i, j)) == Tiles.EMPTY):
				set_cell(0, Vector2i(i, j), ROOM_BUILDER_ID, Tiles.CORRIDOR)
			
func clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in get_used_cells(0):
			if get_cell_atlas_coords(0, cell) != Tiles.CORRIDOR: continue

			var nearby = check_nearby(cell.x, cell.y)
			if nearby[0] == 3 || next_to_corner(nearby):
				set_cell(0, cell, 1, Tiles.ROOF)
				deadends.append(cell)
				done = false
	
	if (deadends.size() > 1 && exit != null):
		exit = deadends[Util.randi_range(0, deadends.size() - 1)]
		set_cell(0, exit, 1, Tiles.EXIT)
	
# check in 4 dirs to see how many tiles are empty
func check_nearby(x, y):
	var count: int = 0
	var non_empty: Vector2i = Tiles.CORRIDOR
	var sides = [Vector2i(x, y - 1), Vector2i(x, y + 1), Vector2i(x - 1, y), Vector2i(x + 1, y)]
	for side in sides:
		if (get_cell_atlas_coords(0, side) == Tiles.EMPTY):
			count += 1
		else:
			non_empty = get_cell_atlas_coords(0, side)

	return [count, non_empty]

func next_to_corner(nearby):
	var edges = [Tiles.TOP_LEFT, Tiles.TOP_RIGHT, Tiles.BOTTOM_LEFT, Tiles.BOTTOM_RIGHT]
	return edges.has(nearby[1])

func along_wall(x, y):
	if get_cell_atlas_coords(0, Vector2i(x, y - 1)) == Tiles.GROUND || get_cell_atlas_coords(0, Vector2i(x, y + 1)) == Tiles.GROUND:
		if get_cell_atlas_coords(0, Vector2i(x - 1, y)) == Tiles.CORRIDOR || get_cell_atlas_coords(0, Vector2i(x + 1, y)) == Tiles.CORRIDOR:
			return true
			
	if get_cell_atlas_coords(0, Vector2i(x - 1, y)) == Tiles.GROUND || get_cell_atlas_coords(0, Vector2i(x + 1, y)) == Tiles.GROUND:
		if get_cell_atlas_coords(0, Vector2i(x, y + 1)) == Tiles.CORRIDOR || get_cell_atlas_coords(0, Vector2i(x, y - 1)) == Tiles.CORRIDOR:
			return true

<<<<<<< HEAD
func _on_shoes_found():
	print("found shoes")
	pass

func decorate_room(room):
	if room.type == 0:
		set_cell(1, Vector2i(room.center.x, room.center.y), 3, Furniture.TABLE_TOP_LEFT)
		set_cell(1, Vector2i(room.center.x + 1, room.center.y), 3, Furniture.TABLE_TOP_MIDDLE)
		set_cell(1, Vector2i(room.center.x + 2, room.center.y), 3, Furniture.TABLE_TOP_RIGHT)
		set_cell(1, Vector2i(room.center.x, room.center.y + 1), 3, Furniture.TABLE_BOTTOM_LEFT)
		set_cell(1, Vector2i(room.center.x + 1, room.center.y + 1), 3, Furniture.TABLE_BOTTOM_MIDDLE)
		set_cell(1, Vector2i(room.center.x + 2, room.center.y + 1), 3, Furniture.TABLE_BOTTOM_RIGHT)
	elif room.type == 1:
		var coordinates = checkFurnitureCorner(room, 3, 2)
		if coordinates != Vector2i(-1, -1):
			set_cell(1, Vector2i(coordinates.x, coordinates.y + 1), 3, Furniture.W_COUCH_TOP_LEFT)
			set_cell(1, Vector2i(coordinates.x + 1, coordinates.y + 1), 3, Furniture.W_COUCH_TOP_MIDDLE)
			set_cell(1, Vector2i(coordinates.x + 2, coordinates.y + 1), 3, Furniture.W_COUCH_TOP_RIGHT)
			set_cell(1, Vector2i(coordinates.x, coordinates.y + 2), 3, Furniture.W_COUCH_BOTTOM_LEFT)
			set_cell(1, Vector2i(coordinates.x + 1, coordinates.y + 2), 3, Furniture.W_COUCH_BOTTOM_MIDDLE)
			set_cell(1, Vector2i(coordinates.x + 2, coordinates.y + 2), 3, Furniture.W_COUCH_BOTTOM_RIGHT)
			
		var carpet = Vector2i(room.center.x - 2, room.center.y - 2)
		set_cell(1, Vector2i(carpet.x, carpet.y + 1), 3, Furniture.CARPET_1_TOP_LEFT)
		set_cell(1, Vector2i(carpet.x + 1, carpet.y + 1), 3, Furniture.CARPET_1_TOP_MIDDLE)
		set_cell(1, Vector2i(carpet.x + 2, carpet.y + 1), 3, Furniture.CARPET_1_TOP_RIGHT)
		set_cell(1, Vector2i(carpet.x, carpet.y + 2), 3, Furniture.CARPET_1_BOTTOM_LEFT)
		set_cell(1, Vector2i(carpet.x + 1, carpet.y + 2), 3, Furniture.CARPET_1_BOTTOM_MIDDLE)
		set_cell(1, Vector2i(carpet.x + 2, carpet.y + 2), 3, Furniture.CARPET_1_BOTTOM_RIGHT)

func checkFurnitureCorner(room, width, length):
	var startX = room.x + 2
	var startY = room.y
	while startX < (room.x + room.w - width):
		var areaClear = true
		# check above
		for i in range(width):
			if get_cell_atlas_coords(0, Vector2i(startX + i, startY - 1)) == Tiles.CORRIDOR || get_cell_atlas_coords(0, Vector2i(startX + i, startY - 1)) == Tiles.BOTTOM_DOOR:
				areaClear = false
				break

		# check right
		for i in range(length):
			if get_cell_atlas_coords(0, Vector2i(startX + width, startY + i)) == Tiles.CORRIDOR || get_cell_atlas_coords(0, Vector2i(startX + width, startY + i)) == Tiles.BOTTOM_DOOR:
				areaClear = false
				break
		
		if areaClear:
			return Vector2i(startX, startY)
		else:
			startX = startX + width
			
	return Vector2i(-1, -1)
=======

>>>>>>> main
