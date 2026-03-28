extends Node

# Словарь всех доступных способностей
var abilities: Dictionary = {}
var ability_slots: Array = []  # Порядок способностей на UI

# Сигналы
signal ability_used(ability_name: String)
signal ability_unlocked(ability_name: String)

func _ready():
	# Регистрируем все способности
	_register_abilities()

func _register_abilities():
	# Создаем экземпляры способностей
	var holy_water = preload("res://scripts/abilities/abilities/holy_water.gd").new()
	
	# Регистрируем
	abilities["holy_water"] = holy_water
	
	# Настраиваем порядок на UI
	ability_slots = ["holy_water", "lightning", "heal", "slow"]
	
	print("Registered ", abilities.size(), " abilities")

func use_ability(ability_id: String, cast_position: Vector3, target: Node = null) -> bool:
	if not abilities.has(ability_id):
		print("Ability not found: ", ability_id)
		return false
	
	var ability = abilities[ability_id]
	var success = ability.activate(cast_position, target)
	
	if success:
		ability_used.emit(ability_id)
	
	return success

func get_ability(ability_id: String) -> BaseAbility:
	return abilities.get(ability_id, null)

func get_cooldown(ability_id: String) -> float:
	var ability = get_ability(ability_id)
	if ability:
		return ability.current_cooldown
	return 0.0

func get_cooldown_progress(ability_id: String) -> float:
	var ability = get_ability(ability_id)
	if ability:
		return ability.get_cooldown_progress()
	return 0.0

func unlock_ability(ability_id: String):
	if abilities.has(ability_id):
		abilities[ability_id].is_unlocked = true
		ability_unlocked.emit(ability_id)
		print("Ability unlocked: ", ability_id)

func upgrade_ability(ability_id: String, upgrade_type: String, value: float):
	var ability = get_ability(ability_id)
	if not ability:
		return
	
	match upgrade_type:
		"damage":
			if ability.has_method("set_damage"):
				ability.set_damage(value)
		"mana_cost":
			ability.mana_cost = max(5, ability.mana_cost - value)
		"cooldown":
			ability.cooldown = max(0.5, ability.cooldown - value)
