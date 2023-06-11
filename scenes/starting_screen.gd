extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("blurb").hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_btn_mouse_entered():
	$blurb.show()

func _on_btn_mouse_exited():
	$"blurb".hide()
