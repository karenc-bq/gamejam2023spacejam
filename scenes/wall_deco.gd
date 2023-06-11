class_name WallDeco

var TOP_LEFT: Vector2i
var TOP_MIDDLE: Vector2i
var TOP_RIGHT: Vector2i
var MIDDLE_LEFT: Vector2i
var MIDDLE_MIDDLE: Vector2i
var MIDDLE_RIGHT: Vector2i
var BOTTOM_LEFT: Vector2i
var BOTTOM_MIDDLE: Vector2i
var BOTTOM_RIGHT: Vector2i

func _init(top_left=null, top_middle=null, top_right=null, middle_left=null, middle_middle=null, middle_right=null, bottom_left=null, bottom_middle=null, bottom_right=null):
	if top_left != null:
		TOP_LEFT = top_left
	
	if top_right != null:
		TOP_RIGHT = top_right
	
	if top_middle != null:
		TOP_MIDDLE = top_middle
	
	if middle_left != null:
		MIDDLE_LEFT = middle_left
	
	if middle_right != null:
		MIDDLE_RIGHT = middle_right
	
	if middle_middle != null:
		MIDDLE_MIDDLE = middle_middle
		
	if bottom_left != null:
		BOTTOM_LEFT = bottom_left
	
	if bottom_right != null:
		BOTTOM_RIGHT = bottom_right
	
	if bottom_middle != null:
		BOTTOM_MIDDLE = bottom_middle

func get_top_left():
	return TOP_LEFT

func get_top_middle():
	return TOP_MIDDLE

func get_top_right():
	return TOP_RIGHT

func get_middle_left():
	return MIDDLE_LEFT

func get_middle_middle():
	return MIDDLE_MIDDLE

func get_middle_right():
	return MIDDLE_RIGHT

func get_bottom_left():
	return BOTTOM_LEFT

func get_bottom_middle():
	return BOTTOM_MIDDLE
	
func get_bottom_right():
	return BOTTOM_RIGHT
