# Main.gd (скрипт для главной сцены)
extends Node3D

@onready var castle: Node3D = $PlayerCastle
@onready var edge_spawner: EdgeSpawner = $EdgeSpawner

var poison_ability: Node

func _ready():
	# Настраиваем MapManager
	var map_manager = get_node("/root/Map_Manager")
	if map_manager:
		# Настраиваем границы карты в зависимости от визуального окружения
		map_manager.map_left = -25.0
		map_manager.map_right = 25.0
		map_manager.map_top = -25.0
		map_manager.map_bottom = 25.0
		map_manager.castle_position = castle.global_position
	
	# Подключаем сигналы GameManager
	GameManager.game_over.connect(_on_game_over)
	
	# Создаем визуальные границы (опционально)
	_create_visual_boundaries()
	_setup_poison_ability()

func _create_visual_boundaries():
	# Создаем прозрачные стены или маркеры на границах карты
	var map_manager = get_node("/root/Map_Manager")
	if not map_manager:
		return
	
	# Создаем простые маркеры по углам
	var corners = [
		Vector3(map_manager.map_left, 0, map_manager.map_top),
		Vector3(map_manager.map_left, 0, map_manager.map_bottom),
		Vector3(map_manager.map_right, 0, map_manager.map_top),
		Vector3(map_manager.map_right, 0, map_manager.map_bottom)
	]
	
	for corner in corners:
		var marker = MeshInstance3D.new()
		marker.mesh = BoxMesh.new()
		marker.mesh.size = Vector3(0.5, 0.5, 0.5)
		marker.material_override = StandardMaterial3D.new()
		marker.material_override.albedo_color = Color.YELLOW
		marker.position = corner
		add_child(marker)

func _on_game_over(victory: bool):
	if not victory:
		print("Game Over! You lost!")
		# Здесь можно добавить экран поражения


func _setup_poison_ability():
	poison_ability = preload("res://Scripts/Abilities/Abilities/holy_water.gd").new()
	add_child(poison_ability)
	print("Poison ability added to scene")

func _input(event):
	# Использование способности по клавише E
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_try_use_poison_ability()

func _try_use_poison_ability():
	if not GameManager.is_game_active:
		print("Game not active")
		return
	
	# Получаем позицию под курсором мыши
	var target_pos = _get_mouse_ground_position()
	
	if target_pos != Vector3.ZERO:
		poison_ability.use(target_pos)
	else:
		print("No valid ground position found")

func _get_mouse_ground_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Маска для земли/пола
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return Vector3.ZERO
	
	return result.position
