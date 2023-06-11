class_name RectObject

var TOP_LEFT: Vector2i
var TOP_MIDDLE: Vector2i
var TOP_RIGHT: Vector2i
var BOTTOM_LEFT: Vector2i
var BOTTOM_MIDDLE: Vector2i
var BOTTOM_RIGHT: Vector2i

func _init(top_left=null, top_middle=null, top_right=null, bottom_left=null, bottom_middle=null, bottom_right=null):
	TOP_LEFT = top_left
	TOP_MIDDLE = top_middle
	TOP_RIGHT = top_right
	BOTTOM_LEFT = bottom_left
	BOTTOM_MIDDLE = bottom_middle
	BOTTOM_RIGHT = bottom_right

func get_top_left():
	return TOP_LEFT

func get_top_middle():
	return TOP_MIDDLE

func get_top_right():
	return TOP_RIGHT

func get_bottom_left():
	return BOTTOM_LEFT

func get_bottom_middle():
	return BOTTOM_MIDDLE
	
func get_bottom_right():
	return BOTTOM_RIGHT
