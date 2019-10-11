extends Node

#Script para el guardado de datos

const PATH = "user://data.dat"

var is_loaded = false

#Datos para guardar (cantidad de niveles desbloqueados)
var data = {
	"LevelsUnlock" : 1
}

func _ready():
	var file = File.new()
	
	#Si el archivo existe carga los datos, si no lo crea antes de cargarlo
	if file.file_exists(PATH):
		load_data()
	else:
		save_data()
		load_data()

#Actualiza la información
func update_data():
	data = {
		"LevelsUnlock" : Global.levelsUnlock
	}

#Guarda los datos (abre el archivo, actualiza los datos y lo vuelve a cerrar)
func save_data():
	var file = File.new()
	
	file.open(PATH, File.WRITE)
	update_data()
	file.store_line(to_json(data))
	file.close()
	
	is_loaded = false

#Carga los datos (abre el archivo, almacena los datos en el nodo Global y lo vuelve a cerrar)
func load_data():
	if is_loaded:
		return
	
	var file = File.new()
	
	file.open(PATH, File.READ)
	data = parse_json(file.get_line())
	Global.levelsUnlock = Global.MAX_LEVELS#data["LevelsUnlock"]
	file.close()
	
	is_loaded = true