extends Resource
class_name BaseAbility

# Основные параметры способности
@export var ability_name: String = "Ability"
@export var description: String = "Description"
@export var icon: Texture2D
@export var mana_cost: int = 20
@export var cooldown: float = 3.0
@export var is_unlocked: bool = true

# Визуальные эффекты
@export var cast_effect_scene: PackedScene
@export var impact_effect_scene: PackedScene
@export var cast_sound: AudioStream

# Текущее состояние (не сохраняется в ресурсе)
var current_cooldown: float = 0.0

# Сигналы для UI
signal cooldown_started(ability: BaseAbility)
signal cooldown_finished(ability: BaseAbility)

# Виртуальный метод активации способности
func activate(cast_position: Vector3, target: Node = null) -> bool:
	# Проверяем, можно ли использовать способность
	if not _can_use():
		return false
	
	# Тратим манну
	if not GameManager.spend_mana(mana_cost):
		print("Not enough mana for ", ability_name)
		return false
	
	# Запускаем кулдаун
	_start_cooldown()
	
	# Вызываем эффект способности
	_apply_effect(cast_position, target)
	
	print("Ability used: ", ability_name, " (Mana: ", mana_cost, ")")
	return true

func _can_use() -> bool:
	return is_unlocked and current_cooldown <= 0.0 and GameManager.is_game_active

func _start_cooldown():
	current_cooldown = cooldown
	cooldown_started.emit(self)
	
	# Запускаем таймер кулдауна
	var timer = Timer.new()
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.timeout.connect(_on_cooldown_finished)
	AbilityManager.add_child(timer)
	timer.start()

func _on_cooldown_finished():
	current_cooldown = 0.0
	cooldown_finished.emit(self)

# Переопределяется в дочерних классах
func _apply_effect(cast_position: Vector3, target: Node):
	pass

# Визуальный эффект каста
func _spawn_cast_effect(position: Vector3):
	if cast_effect_scene:
		var effect = cast_effect_scene.instantiate()
		effect.global_position = position
		#get_tree().current_scene.add_child(effect)
		
		# Автоудаление эффекта
		#await get_tree().create_timer(2.0).timeout
		effect.queue_free()
	
	if cast_sound:
		pass
		#AudioManager.play_sound(cast_sound, position)  # Если есть AudioManager

# Получение прогресса кулдауна (0-1)
func get_cooldown_progress() -> float:
	if current_cooldown <= 0:
		return 0.0
	return current_cooldown / cooldown
