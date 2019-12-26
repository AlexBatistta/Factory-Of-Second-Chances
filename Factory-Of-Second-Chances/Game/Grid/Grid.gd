tool
extends Area2D

export (Global.Type) var type_01 = Global.Type.FIRE setget _type_one
export (Global.Type) var type_02 = Global.Type.ACID setget _type_two

func _type_one(_type):
	type_01 = _type
	
	$Type1.modulate = Global._color(type_01)
	$Type1/Element.texture = load("res://Game/Elements/Element-0" + str(type_01 + 1) + ".png")
	$Type1/Smoke.texture = load("res://Game/Elements/Particle-0" + str(type_01 + 1) + ".png")

func _type_two(_type):
	type_02 = _type
	
	$Type2.modulate = Global._color(type_02)
	$Type2/Element.texture = load("res://Game/Elements/Element-0" + str(type_02 + 1) + ".png")
	$Type2/Smoke.texture = load("res://Game/Elements/Particle-0" + str(type_02 + 1) + ".png")

func _disable():
	$CollisionShape2D.disabled = Global.special_disable
	$Type1/Element.emitting = !Global.special_disable
	$Type1/Smoke.emitting = !Global.special_disable
	$Type2/Element.emitting = !Global.special_disable
	$Type2/Smoke.emitting = !Global.special_disable

func _on_Grid_body_entered(body):
	if body.is_in_group("Player"):
		body._live_or_die(body.type + 1)

func _on_Grid_body_exited(body):
	if body.is_in_group("Player"):
		body._live_or_die(-1)
