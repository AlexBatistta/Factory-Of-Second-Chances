tool
extends TileMap

func _process(delta):
	if Engine.is_editor_hint():
		update()

func _draw():
	if Engine.is_editor_hint():
		get_limits()
		var partition_limits = Vector2(get_limits().x / Global.cam_size.x, get_limits().y / Global.cam_size.y).floor()
		for i in range(partition_limits.x + 1):
			draw_line(Vector2(i* Global.cam_size.x * 2, 0), Vector2(i* Global.cam_size.x * 2, get_limits().y), Color.red)

func get_limits():
	var used = get_used_rect()
	var sizeTile = cell_size.x
	return Vector2 (used.end.x * sizeTile, used.end.y * sizeTile)