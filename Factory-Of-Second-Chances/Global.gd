tool
extends Node

#Script principal, administra variables globales y carga las escenas

const MAX_LEVELS = 5

#Variables de control de escena
var current_scene = null
var current_level = 1
var current_menu = "MainMenu"
var current_state = "Menus"
var levelsUnlock = 1

var sound = true
var music = true

signal transition

var dual_camera : bool = false
var special_disable : bool = false

enum Type {FIRE, ACID, POISON, ELECTRICITY} 

var Game = null
var Menu = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	Game = load("res://Game/Game.tscn")
	Menu = preload("res://Menus/Menu.tscn")

#Cambia la escena 
func change_scene(_scene):
	call_deferred("new_scene", _scene)

#Carga la nueva escena
func new_scene(_scene):
	#Elimina la escena actual
	current_scene.free()
	
	#Instancia la escena
	if _scene == "Game":
		current_scene = Game.instance()
		current_state = "Game"
		get_tree().paused = false
	else:
		current_scene = Menu.instance()
		current_state = "Menus"
	
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene(current_scene)
	
	#Guarda los datos
	#Data.save_data()

#Cambia el nivel actual
func change_level(_level):
	if _level <= MAX_LEVELS:
		current_level = _level

#Cambia el menú actual y emite señal para la transición
func change_menu(_menu):
	current_menu = _menu
	emit_signal("transition")

#Recarga la escena
func try_again():
	change_scene("Game")

#Carga el nivel siguiente
func pass_level():
	if current_level < MAX_LEVELS:
		current_level += 1;
		change_scene("Game")

#Retorna el color del nivel
func _color(type : int, dead : bool = false, dark : bool = true):
	if dead:
		return Color.dimgray if dark else Color.gray
	
	if dark:
		match type:
			0:	return Color.red
			1:	return Color.limegreen
			2:	return Color.darkviolet
			3:	return Color.gold
	else:
		match type:
			0:	return Color.darkorange
			1:	return Color.chartreuse
			2:	return Color.mediumorchid
			3:	return Color.yellow

#Cambia el estado del sonido
func set_sound():
	sound = !sound
	if sound:
		AudioServer.set_bus_volume_db(1, 0)
	else:
		AudioServer.set_bus_volume_db(1, -80)

#Cambia el estado de la música
func set_music():
	music = !music
	var current = "Music" + current_state
	var songs = get_tree().get_nodes_in_group("Music")
	for song in songs:
		if !music:
			song.stop()
		else:
			if song.name == current:
				song.play(song.get_playback_position())