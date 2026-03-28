# Main.gd (скрипт для главной сцены)
extends Node3D

@onready var castle: Node3D = $PlayerCastle
@onready var edge_spawner: EdgeSpawner = $EdgeSpawner


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
