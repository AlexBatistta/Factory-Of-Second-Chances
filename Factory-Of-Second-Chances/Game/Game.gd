tool
extends Node

onready var camera_main = $ViewportMain/ViewportMain/Camera
onready var camera_01 = $Viewport/ViewportContainer/ViewportPlayer1/Camera
onready var camera_02 = $Viewport/ViewportContainer2/ViewportPlayer2/Camera
onready var player_01 = $ViewportMain/ViewportMain/Levels/Player
onready var player_02 = $ViewportMain/ViewportMain/Levels/Player2

var cam_size = Vector2()

func _ready():
	if !Engine.is_editor_hint():
		$CanvasLayer/AnimationPlayer.play("Transition")
		
		camera_01.get_parent().world_2d = camera_main.get_parent().world_2d
		camera_02.get_parent().world_2d = camera_main.get_parent().world_2d
		
		camera_01.target = player_01
		camera_02.target = player_02
		
		camera_limitis([camera_main, camera_01, camera_02])
		
		camera_main.get_parent().connect("size_changed", self, "_on_ViewportMain_resized")
		_on_ViewportMain_resized()

func _process(delta):
	if !Engine.is_editor_hint():
		var change = false if new_frame(player_01) == new_frame(player_02) else true
		
		if change != Global.dual_camera:
			Global.dual_camera = change
			change_viewport()

func change_viewport():
	$CanvasLayer/AnimationPlayer.play("Transition")
	
	$ViewportMain.visible = !Global.dual_camera
	$Viewport.visible = Global.dual_camera
	
	if Global.dual_camera:
		camera_01.position = Vector2(new_frame(player_01).x * cam_size.x, new_frame(player_01).y * cam_size.y)
		camera_02.position = Vector2(new_frame(player_02).x * cam_size.x, new_frame(player_02).y * cam_size.y)
	else:
		camera_main.position = Vector2(new_frame(player_01).x * cam_size.x, new_frame(player_01).y * cam_size.y)
	
	camera_main.current = !Global.dual_camera
	camera_01.current = Global.dual_camera
	camera_02.current = Global.dual_camera

func new_frame(player):
	var level_limits = $ViewportMain/ViewportMain/Levels.get_limits()
	var partition_limits = Vector2(level_limits.x / cam_size.x, level_limits.y / cam_size.y).floor()
	
	var current = Vector2()
	
	var pos = player.global_position# - player.size
	for i in range(partition_limits.x - 1):
		if pos.x > i * cam_size.x:
			current.x = i
	
	for j in range(partition_limits.y - 1):
		if pos.y > j * cam_size.y:
			current.y = j
	
	return current

func _on_ViewportMain_resized():
	cam_size = camera_main.get_parent().size * camera_main.zoom

func camera_limitis(cameras):
	var _limits = $ViewportMain/ViewportMain/Levels.get_limits()
	for cam in cameras:
		cam.limit_right = _limits.x
		cam.limit_bottom = _limits.y