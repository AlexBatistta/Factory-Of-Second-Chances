tool
extends KinematicBody2D

#Script que controla a las plataformas, en base a coordenadas obtiene
#los puntos hacia donde tiene que desplazarse

export (Array, Vector2) var coordinates setget add_point
export var tileSize = 128
export var speed = 2

var points = []
var current_point = 1
var next_point = Vector2()
var global_pos = Vector2()
var back = false

#Agrega un punto
func add_point(_point):
	coordinates = _point
	
	if !points.empty():
		points.clear()
	
	#Multiplica las coordenadas por la mitad del tamaño de un tile
	for i in range(0, coordinates.size()):
		points.push_back(Vector2(coordinates[i].x * tileSize, coordinates[i].y * tileSize))

func _ready():
	#Posición inicial auxiliar
	global_pos = position
	
	#Siguiente punto a desplazarse
	next_point = points[current_point] + global_pos

#Dibuja una línea que muestra el recorrido en el editor
func _draw():
	if Engine.is_editor_hint():
		for point in range(0, points.size()):
			point = wrapi(point, 0, points.size()-1)
			draw_line(points[point], points[point + 1], Color.red, 5.0)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		#Comprueba que no haya llegado al punto
		if position.distance_to(next_point) < 1:
			#Ciclo
			if current_point + 1 > points.size() - 1:
				back = true
			elif current_point == 0:
				back = false 
			
			#Siguiente punto
			if !back: current_point += 1
			else: current_point -= 1
			
			$Sprite.scale.x = 1 if back else -1
		
		#Selecciona el punto a desplazarse
		next_point = points[current_point] + global_pos
		#Movimiento
		position += (next_point - position).normalized() * speed
	else:
		#Actualización para dibujo en editor
		update()