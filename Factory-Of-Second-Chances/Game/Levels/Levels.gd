tool
extends Node2D

var newLevel = null

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
	
	#Actualiza los límites del fondo según los límites del nivel
	#$ParallaxBackground.scroll_limit_end = get_limits()
	
	#Actualiza los límites de la cámara según los límites del nivel
	#$Levels/Player/Camera2D.limit_right = get_limits().x
	#$Levels/Player/Camera2D.limit_bottom = get_limits().y

func _ready():
	if Engine.is_editor_hint():
		load_level(1)
	else:
		#Cargado de nivel
		load_level(Global.current_level)
		
		#Conexión de señales
		#$Levels/Player.connect("change_life", $MenuLayer/UI/Gui, "change_LifeBar")
		#Global.connect("transition", self, "_transition")
		
		#Reproducción de música
		#if Global.music: $MusicGame.play()

func get_limits():
	var used = newLevel.get_used_rect()
	var sizeTile = newLevel.cell_size.x
	return Vector2 (used.end.x * sizeTile, used.end.y * sizeTile)