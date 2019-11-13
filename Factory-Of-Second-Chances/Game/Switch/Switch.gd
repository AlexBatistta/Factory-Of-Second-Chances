tool
extends Area2D

signal exit

export (int, "Switch", "Button") var type = 0 setget _set_type
export (int, 1, 5) var time_active = 5
export (bool) var switch_exit = false

var switch_active = false

func _set_type(_type):
	type = _type
	$Switch.visible = !bool(type)
	$Button.visible = bool(type)

func _activate_switch():
	if !switch_exit:
		Global.special_disable = true
		get_tree().call_group("Special", "_disable")
	else:
		emit_signal("exit", true)
	
	$AnimationPlayer.play("Switch-" + str(type))
	if type == 0:
		$Timer.start(time_active)
	
	switch_active = true

func _on_Timer_timeout():
	if switch_active:
		if !switch_exit:
			Global.special_disable = false
			get_tree().call_group("Special", "_disable")
		else:
			emit_signal("exit", false)
		$AnimationPlayer.play_backwards("Switch-" + str(type))
	
	switch_active = false

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	if !switch_active && !bodies.empty():
		for body in bodies:
			if Input.is_action_pressed("action_" + str(body.player_type)):
				_activate_switch()
			if type == 1:
				_activate_switch()

func _on_Switch_body_exited(body):
	if get_overlapping_bodies().size() == type:
		 _on_Timer_timeout()
