tool
extends Area2D

export (Global.Type) var type = Global.Type.FIRE setget _set_type

func _set_type(_type):
	if Engine.is_editor_hint():
		type = _type
		
		var color = Global._color(type, false, false)
		if type == Global.Type.FIRE: color = Global._color(type, false)
		
		$Puddle.modulate = color
		
		$Element.texture = load("res://Game/Elements/Element-" + str(type) + ".png")

func _ready():
	$Puddle/AnimationPlayer.play("Waves")
	_set_type(type)
	pass

