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
	get_tree().get_root().connect("size_changed", self, "_on_Screen_resized")
	
	if Engine.is_editor_hint():
		load_level(1)
	else:
		#Cargado de nivel
		load_level(Global.current_level)
		$CanvasLayer/AnimationPlayer.play("Transition")
		
		camera.limit_right = get_limits().x
		camera.limit_bottom = get_limits().y
	
	_on_Screen_resized()


func _on_Screen_resized():
	Global.cam_size = get_viewport_rect().size * camera.zoom

