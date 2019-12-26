tool
extends StaticBody2D

const SIZE = Vector2(128, 78)

export var vertical : bool = false setget change_orientation
export (int, 1, 5) var dimension = 1 setget change_dimension
export var offset = 34 setget change_offset

var enabled = true
var offset_cs = 6
var impact_type = -1
var original_dimension

func change_orientation(_vertical):
	vertical = _vertical
	if vertical:
		$AnimationPlayer.play("Vertical")
	else:
		$AnimationPlayer.play("Horizontal")
	change_offset(offset)

func change_dimension(_dimension):
	dimension = _dimension
	$Gate.region_rect = Rect2(Vector2.ZERO, Vector2(SIZE.x * dimension, SIZE.y))
	$CollisionShape2D.shape.extents = Vector2($Gate.region_rect.size.x / 2, $Gate.region_rect.size.y / 2 - (offset_cs * 2))
	
	change_offset(offset)

func change_offset(_offset):
	offset = _offset
	
	$Gate.offset = Vector2($Gate.region_rect.size.x / 2, SIZE.y / 2 + offset)
	if vertical: $Gate.offset.y = 0
	$CollisionShape2D.position = Vector2($Gate.offset.x, ($Gate.offset.y + offset_cs - 6))
	if vertical: $CollisionShape2D.position.y = 0

func _ready():
	original_dimension = dimension

func _collision(_type):
	if impact_type < 0:
		enabled = true
		impact_type = _type
		$Timer.start(1)
	else:
		if _type != impact_type:
			enabled = false
			$AnimationPlayer.play("Active")
			$Timer.start(5)

func _change_size():
	if !enabled:
		dimension -= 1
	else:
		dimension += 1
	
	if dimension < 0 || dimension > original_dimension:
		$AnimationPlayer.stop()
	else:
		Global.emit_signal("shake")
		change_dimension(dimension)

func _on_Timer_timeout():
	impact_type = -1
	if !enabled:
		enabled = true
		$AnimationPlayer.play_backwards("Active")

