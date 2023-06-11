extends Node2D

# Util.choose(["one", "two"])   returns one or two
static func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]

# the percent chance something happens
static func chance(num):
	randomize()

	if randi() % 100 <= num: return true
	else:                    return false

# returns random int between low and high
static func randi_range(low, high):
	return floor(randf_range(low, high))

func _on_music_button_pressed():
	$"audio".stream_paused = !$"audio".stream_paused
