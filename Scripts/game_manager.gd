# GameManager.gd (автозагрузка)
extends Node

# Сигналы для событий игры
signal game_over(victory: bool)
signal mana_changed(current_mana: int, max_mana: int)
signal castle_damaged(current_hp: int, max_hp: int)

# Балансные параметры (будем менять здесь для тюнинга)
@export var max_mana: int = 600
@export var mana_regen_rate: float = 5.0  # единиц в секунду
@export var starting_mana: int = 300

var current_mana: int:
	set(value):
		current_mana = clampi(value, 0, max_mana)
		mana_changed.emit(current_mana, max_mana)

var is_game_active: bool = true

func _ready():
	current_mana = starting_mana
	# Запускаем регенерацию маны
	var regen_timer = Timer.new()
	regen_timer.wait_time = 1.0
	regen_timer.timeout.connect(_on_mana_regen_tick)
	regen_timer.autostart = true
	add_child(regen_timer)

func _on_mana_regen_tick():
	if is_game_active and current_mana < max_mana:
		current_mana += mana_regen_rate
		# Округляем для красоты, но храним как float для точности
		current_mana = mini(current_mana, max_mana)

# Метод для траты маны (будем вызывать из способностей)
func spend_mana(amount: int) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		print("Used ", amount, "mana, left: ", current_mana)
		return true
	return false
