extends Area2D

var exit = false
var change_level = false

func _ready():
	$Switch.connect("exit", self, "_active")
	$Switch2.connect("exit", self, "_active")

func _active(_active):
	if _active:
		if !exit: exit = true
		else:
			$AnimationPlayer.play("Exit")
	else:
		if !exit: $AnimationPlayer.play_backwards("Exit")
		else: exit = false

func _on_Exit_body_entered(body):
	if exit && body.is_in_group("Player"):
		if !change_level: change_level = true
		else: Global.change_scene("Menus")
