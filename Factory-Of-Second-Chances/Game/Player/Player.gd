tool
extends KinematicBody2D

#Script que controla al personaje del jugador

signal change_life
signal fix_camera

export (int, 0, 3) var  type = 0 setget _set_type
export (Array, NodePath) var body_parts
export var health = 5
export var opposite = false setget _set_player

const GRAVITY = 900
const SPEED = 150
const JUMP_SPEED = 400
const TIME_TWEEN = 0.4

var animation = "Idle"
var velocity = Vector2()
var currentDirection = 0
var maxLife = 0
var snap = Vector2(0, 32)
var hurting = false

var state

var face_blink = load("res://Game/Player/Body-Parts/Face-Blink.png")
var face_normal = load("res://Game/Player/Body-Parts/Face-Normal.png")

func _set_type(_type):
	type = _type
	if Engine.is_editor_hint():
		_change_color()

func _set_player(_opposite):
	opposite = _opposite
	z_index = int(opposite) * 5
	set_collision_layer_bit(int(opposite), opposite)
	set_collision_layer_bit(int(!opposite), !opposite)

func _change_color():
	$Body/Head/Element.texture = load("res://Game/Player/Elements/Element-" + str(type) + ".png")
	$Body/Head/Element.modulate = Global._color(type)
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
		_animate()

#Movimiento
func _move(delta):
	#Se "pega" al suelo
	snap = Vector2(0, 32)
	
	velocity.y += delta * GRAVITY
	
	velocity.x = _walking_controls() * SPEED
	
	#Si está en el suelo se habilita el salto
	if is_on_floor():
		velocity.y = 0
		if _jump_controls():
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
	
	#Variable auxiliar para el movimiento de la cámara
	#if direction.x == 0: prev_pos_x = position.x

func _walking_controls():
	var direction
	
	direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	if opposite:
		direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	
	#Cambio de dirección
	if direction != 0: $Body.scale.x = direction
	
	return direction

func _jump_controls():
	if !opposite:
		return true if Input.is_action_pressed("jump") else false
	else:
		return true if Input.is_action_pressed("ui_up") else false

func _action():
	if !opposite:
		return true if Input.is_action_pressed("action") else false
	else:
		return true if Input.is_action_pressed("ui_down") else false

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