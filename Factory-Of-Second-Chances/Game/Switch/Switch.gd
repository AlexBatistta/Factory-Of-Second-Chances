extends Area2D

signal exit

export(int, 1, 5) var time_active = 5
export (bool) var switch_exit = false 

var _player = null

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
	
	$AnimationPlayer.play("Switch")
	$Timer.start(time_active)

func _on_Timer_timeout():
	if !switch_exit:
		Global.special_disable = false
		get_tree().call_group("Special", "_disable")
	else:
		emit_signal("exit", false)
	
	$AnimationPlayer.play_backwards("Switch")

func _on_Switch_body_entered(body):
	if body.is_in_group("Player"):
		_player = body

func _on_Switch_body_exited(body):
	if body.is_in_group("Player"):
		_player = null