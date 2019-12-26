tool
extends Area2D

export (Global.Type) var type = Global.Type.FIRE setget _set_type
var current_name = ""

func _set_type(_type):
	type = _type
	
	var children = $Nodes.get_children()
	for node in children:
		node.visible = false
	
	$Particles2D.modulate = Global._color(type, false, false)
	if type == Global.Type.FIRE: $Particles2D.modulate = Global._color(type, false)
	$Particles2D.modulate.a = 0.5
	$Particles2D.texture = load("res://Game/Elements/Particle-0" + str(type + 1) + ".png")
	
	current_name = Global.Type.keys()[type]
	
	$Nodes.get_node(current_name).visible = true
	$Animation.play(current_name)

func _ready():
	_set_type(type)

func _disable():
	$CollisionShape2D.disabled = Global.special_disable
	$Particles2D.emitting = !Global.special_disable
	if Global.special_disable:
		$Animation.play(current_name + "_disable")
	else:
		$Animation.play_backwards(current_name + "_disable")

func _on_SpecialTerrain_body_entered(body):
	if body.is_in_group("Player"):
		body._live_or_die(type)

func _on_SpecialTerrain_body_exited(body):
	if body.is_in_group("Player"):
		body._live_or_die(-1)

func _on_Animation_animation_finished(anim_name):
	if anim_name == current_name + "_disable":
		if !Global.special_disable:
			$Animation.play(current_name)
