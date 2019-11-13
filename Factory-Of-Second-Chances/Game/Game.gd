tool
extends Node2D

var newLevel = null

#Establece el nivel (útil para la edición)
export (int, 1, 2) var level = 1 setget load_level

onready var camera = $Camera

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
		$CanvasLayer/AnimationPlayer.play("Transition")
		
		camera.limit_right = get_limits().x
		camera.limit_bottom = get_limits().y
		
		$Player.connect("die_retry", self, "_retry")
		$Player2.connect("die_retry", self, "_retry")

func _input(event):
	if $CanvasLayer/CenterContainer/Button.visible:
		if event.is_action_pressed("ui_accept"):
			_on_Button_pressed()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _retry():
	if $Player.dead && $Player2.dead:
		$CanvasLayer/CenterContainer/Button.visible = true

func _on_Button_pressed():
	Global.try_again()
