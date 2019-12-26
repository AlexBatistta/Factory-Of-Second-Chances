tool
extends Area2D

export var speed = 7
export (float, 0, 5) var liveTime = 1.5
export (Global.Type) var type = Global.Type.FIRE setget _change_type

var explosive = false
var direction = Vector2()
var velocity = Vector2()

func _ready():
	if Engine.is_editor_hint():
		$AnimationPlayer.play(Global.Type.keys()[type])
		return
	
	$LiveTimer.start(liveTime)

func _change_type(_type):
	type = _type
	
	$Particles2D.texture = load("res://Game/Elements/Particle-0" + str(type + 1) + ".png")
	$Particles2D.modulate = Global._color(type)
	
	$Explosive.texture = load("res://Game/Elements/Particle-0" + str(type + 1) + ".png")
	$Explosive.modulate = Global._color(type)
	
	$AnimationPlayer.play(Global.Type.keys()[type])

func _shoot(_type, _direction, _position, _explosive = false):	
	direction = _direction
	explosive = _explosive
	
	position = Vector2(_position.x + 25 * direction.x, _position.y - 25)
	
	if explosive: scale = Vector2(1.25, 1.25)
	scale.x *= direction.x
	
	rotation_degrees = 15 * direction.y * direction.x
	direction.y *= 0.5
	
	velocity = Vector2(direction.x * speed, direction.y * speed)
	
	_change_type(_type)

func _physics_process(delta):
	position += velocity

func _collide(node):
	if node.is_in_group("Gate") && explosive:
		node._collision(type)
	elif !node.is_in_group("Level") && !explosive:
		node.get_parent()._collision(type)
	
	_on_LiveTimer_timeout()

func _on_LiveTimer_timeout():
	if !explosive:
		queue_free()
	else:
		$AnimationPlayer.play("Exploit")
