tool
extends Node2D

export (Global.Type) var type = Global.Type.FIRE setget _set_type
export (bool) var flip = false setget _set_flip
export (int, 0, 5) var time_action = 5

var dissolve = false
var progress = 1
var current_node = ""
var enabled = true

func _set_type(_type):
	type = _type
	
	var children = get_children()
	children.pop_back()
	for node in children:
		node.visible = false
	
	get_node(Global.Type.keys()[type]).visible = true
	
	$Nodes/Particles01.texture = load("res://Game/Elements/Particle-0" + str(type + 1) + ".png")
	$Nodes/Particles01.modulate = Global._color(type)
	$Nodes/Particles01.visible = false
	
	$Nodes/Particles02.texture = load("res://Game/Elements/Particle-0" + str(type + 1) + ".png")
	$Nodes/Particles02.modulate = Global._color(type)
	$Nodes/Particles02.visible = false

func _set_flip(_flip):
	flip = _flip
	
	scale.x = -1 if flip else 1 
	
	$FIRE/RigidBody2D/Fire02.scale.x = scale.x
	$ACID/Acid01.scale.x = scale.x
	$ELECTRICITY/Electricity01.scale.x = scale.x
	$POISON/Poison01.scale.x = scale.x

func _ready():
	if !Engine.is_editor_hint():
		$FIRE/RigidBody2D/Fire02.scale = Vector2(0.5, 0.5)
		
		var children = get_children()
		children.pop_back()
		for node in children:
			if !node.visible:
				node.queue_free()

func _collision(_type):
	if _type == type:
		$Nodes/Animation.play(Global.Type.keys()[type])
		if type < 2:
			dissolve = true
			_shader_param()
		
		if type == Global.Type.ELECTRICITY:
			$Nodes/Particles2D.emitting = true
			$Nodes/Timer.start(time_action)
		
		if type == Global.Type.POISON:
			$Nodes/Timer.start(time_action + 1)

func _process(delta):
	if dissolve:
		if progress > 0:
			progress = clamp(progress - delta, 0, 1)
		else:
			dissolve = false
		get_node(current_node).material.set_shader_param("dissolve", progress)

func _shader_param():
	var shader_rotation = 0.0
	var pivot = Vector2(0.0, 0.0)
	
	if type == Global.Type.FIRE:
		current_node = "FIRE/Fire01"
		shader_rotation = 0.75
		pivot = Vector2(0.5, 0.65)
	
	if type == Global.Type.ACID:
		current_node = "ACID/Acid01"
		shader_rotation = 1.0
		pivot = Vector2(0.75, 0.5)
	
	get_node(current_node).material.set_shader_param("rotation", shader_rotation)
	get_node(current_node).material.set_shader_param("pivot", pivot)

func _on_Timer_timeout():
	if type > 1:
		$Nodes/Animation.play_backwards(Global.Type.keys()[type])

func _on_Animation_animation_finished(anim_name):
	if type == Global.Type.FIRE:
		$FIRE/RigidBody2D.gravity_scale = 5
		$FIRE/RigidBody2D.apply_central_impulse(Vector2(0,500))
	
	if type == Global.Type.POISON && !$Nodes/Timer.is_stopped():
		$Nodes/Animation.play("PoisonLoop")

func _on_Poison_body_entered(body):
	if body.has_method("_immunity"):
		body._immunity(time_action)
