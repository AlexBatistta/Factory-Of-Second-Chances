tool
extends Node2D

var newLevel = null
var player01 = null
var player02 = null

#Establece el nivel (útil para la edición)
export (int, 1, 2) var level = 1 setget load_level

#Carga el nivel y actualiza el nivel en el nodo Global
func load_level(_level):
	level = _level
	Global.change_level(level)
	change_level()

#Cambia el nivel
func change_level():
	#Elimina el nivel cargado si existe
	if newLevel != null:
		newLevel.queue_free()
	
	#Instancia el nodo del nivel
	var levelScene = load("res://Game/Levels/Level" + str(level) + ".tscn")
	newLevel = levelScene.instance()
	newLevel.visible = true
	add_child(newLevel)
	
	player01 = newLevel.get_node("Players/Player01")
	player02 = newLevel.get_node("Players/Player02")
	
	player01.connect("die_retry", self, "_retry")
	player02.connect("die_retry", self, "_retry")
	
	#Actualiza los límites del fondo según los límites del nivel
	#$ParallaxBackground.scroll_limit_end = get_limits()

func get_limits():
	var used = newLevel.get_used_rect()
	var sizeTile = newLevel.cell_size.x
	return Vector2 (used.end.x * sizeTile, used.end.y * sizeTile)

func _ready():
	if Engine.is_editor_hint():
		load_level(1)
	else:
		#Cargado de nivel
		load_level(Global.current_level)
		$Layer01/AnimationPlayer.play("Transition")
		
		$Camera.limit_right = get_limits().x
		$Camera.limit_bottom = get_limits().y

func _input(event):
	if $Layer01/CenterContainer/Button.visible:
		if event.is_action_pressed("ui_accept"):
			_on_Button_pressed()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _retry():
	if player01.dead && player02.dead:
		$Layer01/CenterContainer/Button.visible = true

func _on_Button_pressed():
	Global.try_again()

func _on_Area2D_body_entered(body):
	$Layer02/Area2D.z_index = 1
