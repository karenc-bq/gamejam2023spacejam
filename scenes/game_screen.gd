extends Node2D

var timer
var seconds = 60
var minutes = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.connect("timeout", _on_timer_timeout) 
	timer.set_wait_time(1) # value is in seconds
	add_child(timer)
	timer.start()
	$TimerLabel.set_text(str(minutes, " : 00"))
	minutes = minutes - 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	seconds = seconds - 1
	if seconds == -1:
		minutes = minutes - 1
		seconds = 59

	var secondsString = str(seconds)
	if seconds < 10:
		secondsString = str("0", seconds)
	
	$TimerLabel.set_text(str(minutes, " : ", secondsString))
	
	if minutes == 0 && seconds == 58:
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
