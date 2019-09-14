tool
extends KinematicBody2D

#Script que controla al personaje del jugador

signal change_life
signal fix_camera

export (int, 0, 3) var  type = 0 setget _set_type
export (Array, NodePath) var body_parts
export var health = 5
export var opposite = false

const GRAVITY = 900
const SPEED = 200
const JUMP_SPEED = 600

var animation = "Idle"
var velocity = Vector2()
var currentDirection = 0
var maxLife = 0
var snap = Vector2(0, 32)
var hurting = false

func _set_type(_type):
	type = _type
	if Engine.is_editor_hint():
		_change_color()

func _change_color():
	$Body/Head/Element.texture = load("res://Game/Player/Elements/Element-" + str(type) + ".png")
	$Body/Head/Element.modulate = Global._color(type)
	for part in body_parts:
		get_node(part).type = type

func _ready():
	$AnimationPlayer.play("Idle")
	maxLife = health
	_change_color()

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

#Animación
func _animate():
	if velocity.x != 0:
		animation = "Walk"
	else: animation = "Idle"
	
	if !is_on_floor(): 
		animation = "Jump"
		if velocity.y > 0:
			animation = "Fall"
	
	if hurting:
		animation = "Hurt"
		if check_life():
			animation = "Die"
	
	animation = "Idle"
	#Comprueba si la animación a reproducir es diferente a la actual
	if animation != $AnimationPlayer.current_animation:
		$Sprite/AnimationPlayer.play(animation)

#Comprueba la vida restante
func check_life():
	health = clamp(health, 0, maxLife)
	if health == 0:
		return true