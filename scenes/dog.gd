extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	OS.alert("Oh no! You've run into a guard dog!!", 'Exit')
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
