tool
extends Position2D

#Script que controla a las plataformas, en base a coordenadas obtiene
#los puntos hacia donde tiene que desplazarse

export (Array, Vector2) var coordinates setget add_point
export (bool) var active = false setget activate
export var tileSize = 128
export var speed = 2

var points = []
var current_point = 1
var next_point = Vector2()
var back = false

onready var platform = $Platform

func activate(_active):
	active = _active
	
	if !active:
		platform.position = Vector2.ZERO
	else:
		update()

#Agrega un punto
func add_point(_point):
	coordinates = _point
	
	if !points.empty():
		points.clear()
	
	#Multiplica las coordenadas por la mitad del tamaño de un tile
	for i in range(0, coordinates.size()):
		points.push_back(Vector2(coordinates[i].x * tileSize, coordinates[i].y * tileSize))

func _ready():
	#Siguiente punto a desplazarse
	next_point = points[current_point]

#Dibuja una línea que muestra el recorrido en el editor
func _draw():
	if Engine.is_editor_hint() && !active:
		for point in range(0, points.size()):
			point = wrapi(point, 0, points.size()-1)
			draw_line(points[point], points[point + 1], Color.yellow, 5.0)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		active = true
	
	if active:
		#Comprueba que no haya llegado al punto
		if platform.position.distance_to(next_point) < 1:
			#Ciclo
			if current_point + 1 > points.size() - 1:
				back = true
			elif current_point == 0:
				back = false 
			
			#Siguiente punto
			if !back: current_point += 1
			else: current_point -= 1
		
		#Selecciona el punto a desplazarse
		next_point = points[current_point]
		#Movimiento
		platform.position += (next_point - platform.position).normalized() * speed
	else:
		#Actualización para dibujo en editor
		update()

