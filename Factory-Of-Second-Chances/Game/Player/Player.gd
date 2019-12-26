tool
extends KinematicBody2D

#Script que controla al personaje del jugador

signal die_retry
signal drag_box

export (Global.Type) var type = Global.Type.FIRE setget _set_type
export (int, "PLAYER_1", "PLAYER_2") var player_type = 0 setget _set_player
export (bool) var flip setget _set_flip
export (PackedScene) var Bullet
export (Array, NodePath) var body_parts
export (float, 0, 5) var timeSpecial = 1.5

const GRAVITY = 3000
const SPEED = 300
const JUMP_SPEED = 800
const TIME_TWEEN = 0.4
const INERTIA = 100

var velocity = Vector2()
var direction = Vector2()
var maxLife = 0
var snap = Vector2(0, 32)
var drag : bool = false
var dead : bool = false

var topRiver = 0
var swimming = false

var playback
var state = "Idle"
var face_blink = load("res://Game/Player/Body-Parts/Face-Blink.png")
var face_normal = load("res://Game/Player/Body-Parts/Face-Normal.png")
var face_hurt = load("res://Game/Player/Body-Parts/Face-Hurt.png")

onready var size = $CollisionShape2D.shape.extents + Vector2(20,0)
onready var bullet_spawn = $Body/Head/Element

func _set_type(_type):
	type = _type
	
	if Engine.is_editor_hint():
		_change_color()

func _set_player(_player):
	player_type = _player
	z_index = player_type
	set_collision_layer_bit(0, bool(!player_type))
	set_collision_layer_bit(1, bool(player_type))

func _set_flip(_flip):
	flip = _flip
	
	$Body.scale.x = -1 if flip else 1
	#if sign(float(size.x)) != _direction:
	#	size.x *= -1

func _change_color():
	$Body/Head/Element.texture = load("res://Game/Elements/Element-0" + str(type + 1) + ".png")
	$Body/Head/Element.modulate = Global._color(type, dead)
	for part in body_parts:
		get_node(part).type = type

func _ready():
	$Body/Tween.interpolate_property($Body/Head/Element, "scale", Vector2(1.15, 1.15), Vector2(0.85, 0.85), TIME_TWEEN, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Body/Tween.interpolate_callback(self, TIME_TWEEN / 2, "_blink", false)
	$Body/Tween.start()
	
	$AnimationTree.active = true
	playback = $AnimationTree.get("parameters/playback")
	#playback.travel(state)
	
	_change_color()
	
	randomize()

func _physics_process(delta):
	if !Engine.is_editor_hint():
		#Movimiento
		if !dead:
			direction.x = int(Input.is_action_pressed("right_" + str(player_type))) - int(Input.is_action_pressed("left_" + str(player_type)))
			direction.y = int(Input.is_action_pressed("down_" + str(player_type))) - int(Input.is_action_pressed("up_" + str(player_type)))
		
		if !swimming:
			_move(delta)
		else:
			_swimming(delta)
		
		_attack()
		
		#Animación
		if $AnimationTree.active: 
			_animate()
		
		#Aplica la velocidad
		if dead || _stop(): velocity.x = 0
		velocity = move_and_slide_with_snap(velocity, snap, Vector2(0, -1), false, 4, PI / 4, false)

#Movimiento
func _move(delta):
	#Se "pega" al suelo
	snap = Vector2(0, 32)
	
	velocity.y += delta * GRAVITY
	
	velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 10)
	if abs(velocity.x) < 40: velocity.x = 0
	
	#Si está en el suelo se habilita el salto
	if is_on_floor() && !dead:
		velocity.y = 0
		if Input.is_action_pressed("jump_" + str(player_type)):
			#Impulso hacia arriba
			velocity.y = -JUMP_SPEED
			
			#Se "despega" del suelo
			snap = Vector2.ZERO
			
			state = "Jump"
		
		if Input.is_action_just_pressed("action_" + str(player_type)):
			state = "Action"

func _attack():
	if Input.is_action_just_pressed("attack_" + str(player_type)):
		if $SpecialKey.is_stopped():
			$SpecialKey.start(timeSpecial)
	
	if Input.is_action_pressed("attack_" + str(player_type)):
		if $SpecialKey.time_left < timeSpecial - 0.5: state = "ChargeAttack"
	
	if Input.is_action_just_released("attack_" + str(player_type)):
		state = "Attack"
		if $SpecialKey.time_left < 0.5: state = "SpecialAttack"
		else: $SpecialKey.stop()

func _river(_active, _top = 0):
	swimming = _active
	topRiver = _top
	velocity = Vector2()
	$Body/Shadow.visible = !_active

func _swimming(delta):
	#Se "despega" del suelo
	snap = Vector2.ZERO
	
	#Por defecto hunde al personaje
	if direction.y == 0:
		direction.y = 1
	
	#Impulsa hacia abajo si esta cerca de la superficie
	if direction.y == -1 && position.y < topRiver:
		direction.y = 1
	
	velocity = lerp(velocity, direction * (SPEED / 2), delta * 2)
	
	if direction.x == 0:
		velocity.x = 0
	
	#Salida del río, si choca contra una pared y esta cerca de la 
	#superficie, se lo impulsa a salir
	if is_on_wall() && position.y < topRiver + 15:
		velocity.x = SPEED * direction.x
		velocity.y = -JUMP_SPEED

func _shoot(_direction, _explosive = false):
	var bullet = Bullet.instance()
	var bullet_dir = Vector2($Body.scale.x * sign(_direction), abs(_direction))
	
	bullet._shoot(type, bullet_dir, bullet_spawn.global_position * 2, _explosive)
	get_parent().add_child(bullet)

#Animación
func _animate():
	if state == "":
		if is_on_floor():
			if velocity.x != 0:
				state = "Walk"
			else:
				state = "Idle"
		else:
			if playback.get_current_node() != "Jump Loop":
				state =  "Fall"
	
	playback.travel(state)
	state = ""
	
	#Cambio de dirección
	if direction.x != 0: 
		$Body.scale.x = direction.x

func _push():
	state = "Jump"
	
	velocity.x = SPEED * $Body.scale.x * 3
	velocity.y = -JUMP_SPEED
	
	velocity = move_and_slide(velocity)

func _immunity(_time):
	$Immunity.start(_time)
	$Particles2D.visible = true
	$Particles2D.emitting = true

func _live_or_die(_type):
	dead = true if _type != type else false
	if !$Immunity.is_stopped() || _type == -1: dead = false
	
	for part in body_parts:
		get_node(part).dead = dead
		
	$Body/Head/Element.modulate = Global._color(type, dead)
	
	$Body/Tween.set_active(!dead)
	$AnimationTree.active = !dead
	
	if dead: 
		$Body/Head/Face.texture = face_hurt
		emit_signal("die_retry")
	else: 
		$Body/Head/Face.texture = face_normal

func _blink(blink):
	var _time = TIME_TWEEN / 3
	
	if blink:
		$Body/Head/Face.texture = face_blink
	else:
		$Body/Head/Face.texture = face_normal
		_time = ceil(rand_range(2, 8))
	
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

func _stop():
	match playback.get_current_node():
		"Action", "Attack", "ChargeAttack", "SpecialAttack":
			return true
		_:
			return false

func _on_Immunity_timeout():
	$Particles2D.visible = false
	$Particles2D.emitting = false
