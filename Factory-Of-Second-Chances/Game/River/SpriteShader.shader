shader_type canvas_item;

uniform float speed = 0.0;

void fragment()
{
	vec2 waves;
	waves.x = -TIME * (0.1 + speed);
	waves.y = 0.0;
	
	COLOR = texture(TEXTURE, UV + waves);
}