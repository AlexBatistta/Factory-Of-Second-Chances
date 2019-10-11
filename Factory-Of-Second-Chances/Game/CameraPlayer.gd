extends Camera2D

var target = null
const OFFSET = -200

func _process(delta):
	if target && Global.dual_camera: 
		position.y = target.global_position.y + OFFSET
