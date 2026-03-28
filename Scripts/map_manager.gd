# MapManager.gd (автозагрузка)
extends Node
class_name MapManager
# Границы карты (прямоугольник)
@export var map_left: float = -20.0
@export var map_right: float = 20.0
@export var map_top: float = -20.0    # Z координата (вперед-назад)
@export var map_bottom: float = 20.0

# Где находится замок (центр карты)
var castle_position: Vector3 = Vector3.ZERO

func get_random_edge_position() -> Vector3:
	# Выбираем случайную сторону: 0-лево, 1-право, 2-верх, 3-низ
	var side = randi() % 4
	var x: float
	var z: float
	
	match side:
		0: # Левая сторона
			x = map_left
			z = randf_range(map_top, map_bottom)
		1: # Правая сторона
			x = map_right
			z = randf_range(map_top, map_bottom)
		2: # Верхняя сторона
			x = randf_range(map_left, map_right)
			z = map_top
		3: # Нижняя сторона
			x = randf_range(map_left, map_right)
			z = map_bottom
	
	return Vector3(x, 0, z)

func get_distance_from_edge(position: Vector3) -> float:
	# Вычисляем минимальное расстояние до любой границы
	var dist_to_left = abs(position.x - map_left)
	var dist_to_right = abs(position.x - map_right)
	var dist_to_top = abs(position.z - map_top)
	var dist_to_bottom = abs(position.z - map_bottom)
	
	return min(dist_to_left, dist_to_right, dist_to_top, dist_to_bottom)
