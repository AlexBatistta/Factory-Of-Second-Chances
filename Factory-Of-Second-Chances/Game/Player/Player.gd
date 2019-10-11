tool
extends KinematicBody2D

#Script que controla al personaje del jugador

signal change_life
signal change_viewport

export (Global.Type) var type = Global.Type.FIRE setget _set_type
export (Array, NodePath) var body_parts
export var health = 5
export (int, "PLAYER_1", "PLAYER_2") var player_type = 0 setget _set_player

const GRAVITY = 2000
const SPEED = 250
const JUMP_SPEED = 800
const TIME_TWEEN = 0.4

var velocity = Vector2()
var maxLife = 0
var snap = Vector2(0, 32)
var dead : bool = false

var state
var face_blink = load("res://Game/Player/Body-Parts/Face-Blink.png")
var face_normal = load("res://Game/Player/Body-Parts/Face-Normal.png")
var face_hurt = load("res://Game/Player/Body-Parts/Face-Hurt.png")

onready var size = $CollisionShape2D.shape.extents + Vector2(20,0)

func _set_type(_type):
	type = _type
	if Engine.is_editor_hint():
		_change_color()

func _set_player(_player):
	player_type = _player
	z_index = player_type * 5
	set_collision_layer_bit(0, bool(!player_type))
	set_collision_layer_bit(1, bool(player_type))

func _change_color():
	$Body/Head/Element.texture = load("res://Game/Elements/Element-" + str(type) + ".png")
	$Body/Head/Element.modulate = Global._color(type, dead)
	for part in body_parts:
		get_node(part).type = type

func _ready():
	if !Engine.is_editor_hint():
		$AnimationTree.active = true
	else:
		$AnimationPlayer.play("Idle")
	
	$Body/Tween.interpolate_property($Body/Head/Element, "scale", Vector2(1.15, 1.15), Vector2(0.85, 0.85), TIME_TWEEN, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Body/Tween.interpolate_callback(self, TIME_TWEEN / 2, "_blink", false)
	$Body/Tween.start()
	
	state = $AnimationTree.get("parameters/playback")
	
	maxLife = health
	_change_color()
	
	randomize()

func _process(delta):
	if !Engine.is_editor_hint():
		#Movimiento
		_move(delta)
		
		#Animación
		if $AnimationTree.active: 
			_animate()

#Movimiento
func _move(delta):
	#Se "pega" al suelo
	snap = Vector2(0, 32)
	
	velocity.y += delta * GRAVITY
	
	var direction = int(Input.is_action_pressed("right_" + str(player_type))) - int(Input.is_action_pressed("left_" + str(player_type)))
	
	#Cambio de dirección
	if direction != 0: 
		$Body.scale.x = direction
		if sign(float(size.x)) != direction:
			size.x *= -1
	
	if Input.is_action_just_pressed("ui_accept"): _live_or_die()
	
	velocity.x = direction * SPEED
	
	#Si está en el suelo se habilita el salto
	if is_on_floor():
		velocity.y = 0
		if Input.is_action_pressed("jump_" + str(player_type)):
			#Impulso hacia arriba
			velocity.y = -JUMP_SPEED
			
			#Se "despega" del suelo
			snap = Vector2.ZERO
			
			state.travel("Jump")
			
			#Sonido de salto
			#$PlayerSounds.stream = load("res://Sound/Jump.ogg")
			#$PlayerSounds.play()
	
	
	#Aplica la velocidad
	velocity = move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
	

func _action():
		return true if Input.is_action_pressed("action_" + str(player_type)) else false

#Animación
func _animate():
	if is_on_floor():
		if velocity.x != 0:
			state.travel("Walk")
		else:
			state.travel("Idle")
	else:
		if state.get_current_node() != "Jump Loop":
			state.travel("Fall")

#Comprueba la vida restante
func check_life():
	health = clamp(health, 0, maxLife)
	if health == 0:
		return true

func _live_or_die():
	dead = !dead
	
	for part in body_parts:
		get_node(part).dead = dead
		
	$Body/Head/Element.modulate = Global._color(type, dead)
	
	$Body/Tween.set_active(!dead)
	$AnimationTree.active = !dead
	
	if dead: $Body/Head/Face.texture = face_hurt
	else: $Body/Head/Face.texture = face_normal

func _blink(blink):
	var _time = TIME_TWEEN / 3
	
	if blink:
		$Body/Head/Face.texture = face_blink
	else:
		$Body/Head/Face.texture = face_normal
		_time = ceil(rand_range(5, 10))
	
	$Body/Tween.interpolate_callback(self, _time, "_blink", !blink)
	$Body/Tween.start()

func _on_Tween_tween_completed(object, key):
	var _new_scale = Vector2(0.85,0.85)
	
	if object.name == "Element":
		if object.scale == _new_scale:
			$Body/Tween.interpolate_property(object, "scale", _new_scale, Vector2(1.15,1.15), TIME_TWEEN, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			$Body/Tween.interpolate_property(object, "scale", Vector2(1.15,1.15), _new_scale, TIME_TWEEN, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Body/Tween.start()

