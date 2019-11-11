tool
extends Area2D

export (Global.Type) var type = Global.Type.FIRE setget _set_type

var type_name = ["Fire", "Acid", "Poison", "Electricity"]
var current_name = ""

func _set_type(_type):
	for node in type_name:
		get_node(node).visible = false
	
	type = _type
	current_name = type_name[type]
	
	match type:
		0:	$Particles2D.modulate = Color.darkgray
		1:	$Particles2D.modulate = Color.limegreen
		2:	$Particles2D.modulate = Color.mediumorchid
		3:	$Particles2D.modulate = Color.yellow
	
	$Particles2D.modulate.a = 0.5
	
	get_node(current_name).visible = true
	
	$Animation.play(current_name)

func _ready():
	if !Engine.is_editor_hint():
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
