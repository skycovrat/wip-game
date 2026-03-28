extends Node

# Параметры способности (меняй здесь для баланса)
var mana_cost: int = 25
var cooldown_seconds: float = 1.0
var puddle_scene: PackedScene = null

# Внутреннее состояние
var current_cooldown: float = 0.0
var is_on_cooldown: bool = false

func _ready():
	puddle_scene = preload("res://Scenes/holy_water.tscn")
	print("Poison Flask Ability loaded")

func _process(delta):
	if is_on_cooldown:
		current_cooldown -= delta
		if current_cooldown <= 0:
			is_on_cooldown = false
			print("Poison Flask ready again")

func use(target_position: Vector3) -> bool:
	# Проверка кулдауна
	if is_on_cooldown:
		print("Poison Flask on cooldown: ", round(current_cooldown), "s left")
		return false
	
	# Проверка маны
	if not GameManager.spend_mana(mana_cost):
		print("Not enough mana! Need ", mana_cost)
		return false
	
	# Создаем лужу
	_create_puddle(target_position)
	
	# Запускаем кулдаун
	is_on_cooldown = true
	current_cooldown = cooldown_seconds
	
	print("Poison Flask used at: ", target_position)
	return true

func _create_puddle(position: Vector3):
	if not puddle_scene:
		print("ERROR: Puddle scene not loaded!")
		return
	
	var puddle = puddle_scene.instantiate()
	puddle.global_position = position
	get_tree().current_scene.add_child(puddle)
	print("Poison puddle created at: ", position)
