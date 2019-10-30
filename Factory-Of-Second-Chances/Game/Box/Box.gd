tool
extends RigidBody2D

var connect = false
var _body_player = null

func _ready():
	randomize()
	$Box.frame = randi() % 2

func _drag():
	connect = !connect
	if connect:
		$PinJoint2D.node_a = self.get_path()
		$PinJoint2D.node_b = _body_player.get_path()
		gravity_scale = 2
	else:
		$PinJoint2D.node_a = NodePath()
		$PinJoint2D.node_b = NodePath()
		gravity_scale = 5

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		print(body.name)
		body.drag = true
		body.connect("drag_box", self, "_drag")
		_body_player = body

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		body.drag = false
		body.disconnect("drag_box", self, "_drag")
		_body_player = null

