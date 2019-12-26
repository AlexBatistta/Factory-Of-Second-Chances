tool
extends TileMap

func _draw():
	if !Engine.is_editor_hint(): return
	
	var vp = get_viewport_rect().size * 2
	draw_line(Vector2(vp.x, 0),Vector2(vp.x, vp.y), Color.red, 5.0)
	draw_line(Vector2(0, vp.y),Vector2(vp.x, vp.y), Color.red, 5.0)

func _process(delta):
	update()
