tool
extends Area2D

signal exit

export (int, "Switch", "Button") var type = 0 setget _set_type
export (int, 1, 5) var time_active = 5
export (bool) var switch_exit = false 

var _player = null

func _set_type(_type):
	type = _type
	$Switch.visible = !bool(type)
	$Button.visible = bool(type)

func _input(event):
	if _player != null && !Global.special_disable:
		if event.is_action_pressed("action_" + str(_player.player_type)):
			_activate_switch()

func _activate_switch():
	if !switch_exit:
		Global.special_disable = true
		get_tree().call_group("Special", "_disable")
	else:
		emit_signal("exit", true)
	
	$AnimationPlayer.play("Switch-" + str(type))
	if type == 0:
		$Timer.start(time_active)

func _on_Timer_timeout():
	if !switch_exit:
		Global.special_disable = false
		get_tree().call_group("Special", "_disable")
	else:
		emit_signal("exit", false)
	
	$AnimationPlayer.play_backwards("Switch-" + str(type))

func _on_Switch_body_entered(body):
	if body.is_in_group("Player"):
		_player = body
		if type == 1:
			_activate_switch()

func _on_Switch_body_exited(body):
	if body.is_in_group("Player"):
		_player = null
		if type == 1:
			_on_Timer_timeout()