tool
extends Area2D

#Script encargado de la creación de ríos de diferentes tipos, estableciendo
#el daño que produce al jugador y las dimensiones de los sprites

export (Global.Type) var type = Global.Type.FIRE
export (Vector2) var dimensions = Vector2(1, 1) setget change_dimensions
export var tileSize = 128
export var offset = Vector2(45, 32)

var rectSprite = Vector2()
var color
var backWaves : Sprite
var frontWaves : Sprite
var current_type = type

#Cambia las dimensiones
func change_dimensions(_dimensions):
	#Limita la altura
	if _dimensions.y > 4: _dimensions.y = 4
	dimensions = _dimensions
	
	#Crea el sprite del fondo y lo agrega a escena
	if backWaves != null:
		backWaves.queue_free()
	backWaves = create_sprite(-3)
	backWaves.position += Vector2(offset.x, 0)
	add_child(backWaves)
	
	#Crea el sprite del frente y lo agrega a escena
	if frontWaves != null:
		frontWaves.queue_free()
	frontWaves = create_sprite(5)
	#Sprite mas bajo que el del fondo
	frontWaves.region_rect = Rect2(tileSize / 2, 0, rectSprite.x, rectSprite.y - 20)
	frontWaves.position += Vector2(offset.x, 10)
	#Movimiento de las olas
	frontWaves.material.set_shader_param("speed", 0.2)
	add_child(frontWaves)
	
	#Color según el tipo
	set_color(Global._color(type, false, false))

#Establece los parámetros según las dimensiones
func setup():
	$CollisionShape2D.scale = dimensions
	$CollisionShape2D.position = Vector2(rectSprite.x / 2 - offset.x, rectSprite.y / 2 + offset.y)
	
	$Bubbles.process_material = load("res://Game/River/ParticlesMaterial.tres").duplicate()
	$Bubbles.process_material.emission_box_extents = Vector3((tileSize / 2) * dimensions.x, (tileSize / 2) * dimensions.y - offset.y, 1)
	$Bubbles.position = rectSprite / 2
	$Bubbles.emitting = true

#Crea el sprite y lo retorna
func create_sprite(zIndex):
	#Ancho y largo según la medida del tile y las dimensiones
	rectSprite = Vector2(tileSize * dimensions.x + (offset.x * 2), tileSize * dimensions.y)
	
	#Crea el sprite con la textura
	var sprite = Sprite.new()
	sprite.texture = load("res://Game/River/River.png")
	sprite.z_index = zIndex
	
	#Establece las medidas
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2(0, 0), rectSprite)
	sprite.set_offset(Vector2((tileSize / 2) * dimensions.x - offset.x, (tileSize / 2) * dimensions.y + (offset.y / 2)))
	
	#Agrega el shader
	var shader = ShaderMaterial.new()
	shader.set_shader(load("res://Game/River/SpriteShader.shader"))
	sprite.set_material(shader)
	
	return sprite

#Establece el color
func set_color(color):
	if !Global.special_disable:
		if type == Global.Type.FIRE: color = Global._color(type, false)
	
	if backWaves != null:
		backWaves.modulate = color
	
	if frontWaves != null:
		frontWaves.modulate = color
		#Lo transparenta para que se vea el personaje "en el medio de las olas"
		frontWaves.modulate.a = 0.65
	
	#Color de las burbujas (partículas)
	$Bubbles.modulate = color
	
	$Sign/Element.texture = load("res://Game/Elements/Element" + str(type) + ".png")
	#$Sign/Element.modulate = color

func _ready():
	setup()

#Acción de colision
func _on_River_body_entered(body):
	if body.is_in_group("Player"):
		#Activa el poder de nadar
		body._river(true, position.y - offset.y + 10)
		body._live_or_die(current_type)
		#Sonido del río
		#$LiquidSound.play()
	
	#Si cae desde muy alto reproduce un sonido
	#if body.velocity.y > 45:
	#	$SplashSound.play()

#Acción de salida
func _on_River_body_exited(body):
	if body.is_in_group("Player"):
		#Para el poder de nadar
		body._river(false)
		#Para el sonido
		#$LiquidSound.stop()

func _disable():
	if Global.special_disable:
		set_color(Color.darkturquoise)
		current_type = -1
	else:
		set_color(Global._color(type, false, false))
		current_type = type
	
	for player in get_tree().get_nodes_in_group("Player"):
		if player.swimming: player._live_or_die(current_type)
