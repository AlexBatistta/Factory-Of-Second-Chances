extends Area2D

var exit = [false, false]
export var open = false

func _ready():
	$Switch.connect("exit", self, "_active")
	$Switch2.connect("exit", self, "_active")

func _active(_active, _name):
	if _name == "Switch":
		exit[0] = _active
	else:
		exit[1] = _active
	
	if exit.count(true) == exit.size():
		$AnimationPlayer.play("Exit")
	elif open:
		$AnimationPlayer.play_backwards("Exit")

func _on_Exit_body_entered(body):
	if get_overlapping_bodies().size() > 1 && open:
		Global.change_scene("Menus")
