# HealthComponent.gd
extends Node
class_name HealthComponent
signal health_changed(current: int, max: int)
signal died()

@export var max_health: int = 100
var current_health: int:
	set(value):
		current_health = clampi(value, 0, max_health)
		health_changed.emit(current_health, max_health)
		if current_health <= 0:
			died.emit()

func _ready():
	current_health = max_health

func take_damage(amount: int):
	if current_health <= 0:
		return
	current_health -= amount

func heal(amount: int):
	if current_health <= 0:
		return
	current_health += amount
