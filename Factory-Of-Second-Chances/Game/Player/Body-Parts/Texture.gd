tool
extends Sprite

var type : int = 0

func _draw():
	var t_color = load(texture.resource_path)
	
	var t_size = Vector2(t_color.get_width() / hframes, t_color.get_height())
	if hframes == 2: t_size.y /= 2;
	
	var _rect = Rect2(offset, t_size)
	var _src_rect = Rect2(Vector2(t_size.x, 0), t_size)
	draw_texture_rect_region(t_color, _rect, _src_rect, Global._color(type, false))
	
	_src_rect = Rect2(Vector2(t_size.x * 2, 0), t_size)
	if hframes == 2: _src_rect = Rect2(Vector2(t_size.x, t_size.y), t_size)
	draw_texture_rect_region(t_color, _rect, _src_rect, Global._color(type))

func _process(delta):
	update()

