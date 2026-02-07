extends CharacterBody2D
class_name Enemy

## Feind-Klasse mit Pfadverfolgung und Gesundheitssystem.
## Bewegt sich entlang des generierten Pfades und verursacht Schaden an der Basis.

# Feindtyp-Konfiguration
enum EnemyType { GOBLIN, ORC, TROLL }

# Eigenschaften
var enemy_type: EnemyType = EnemyType.GOBLIN
var max_health: float = 50.0
var current_health: float = 50.0
var move_speed: float = 150.0
var gold_reward: int = 5
var base_damage: int = 1

# Pfadverfolgung
var path_points: Array = []
var current_path_index: int = 0
var tile_size: int = 64

# Referenzen
var health_bar: ColorRect
var health_bar_bg: ColorRect
var body_visual: ColorRect

# Signale
signal enemy_killed(gold: int)
signal enemy_reached_end(damage: int)


func _ready() -> void:
	_create_visuals()


## Initialisiert den Feind mit Typ und Pfad
func setup(type: EnemyType, path: Array, ts: int) -> void:
	enemy_type = type
	path_points = path
	tile_size = ts
	current_path_index = 0

	match enemy_type:
		EnemyType.GOBLIN:
			max_health = 50.0
			move_speed = 150.0
			gold_reward = 5
			base_damage = 1
		EnemyType.ORC:
			max_health = 150.0
			move_speed = 80.0
			gold_reward = 15
			base_damage = 2
		EnemyType.TROLL:
			max_health = 400.0
			move_speed = 40.0
			gold_reward = 30
			base_damage = 5

	current_health = max_health

	if path_points.size() > 0:
		var start: Vector2i = path_points[0]
		position = Vector2(start.x * tile_size + tile_size / 2, start.y * tile_size + tile_size / 2)

	_update_visuals()


## Erstellt die visuellen Elemente des Feindes
func _create_visuals() -> void:
	# Körper
	body_visual = ColorRect.new()
	body_visual.size = Vector2(40, 40)
	body_visual.position = Vector2(-20, -20)
	add_child(body_visual)

	# Gesundheitsbalken Hintergrund
	health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(40, 6)
	health_bar_bg.position = Vector2(-20, -30)
	health_bar_bg.color = Color(0.3, 0.0, 0.0, 0.8)
	add_child(health_bar_bg)

	# Gesundheitsbalken
	health_bar = ColorRect.new()
	health_bar.size = Vector2(40, 6)
	health_bar.position = Vector2(-20, -30)
	health_bar.color = Color(0.0, 0.8, 0.0, 0.9)
	add_child(health_bar)


## Aktualisiert die visuellen Elemente basierend auf dem Feindtyp
func _update_visuals() -> void:
	if body_visual == null:
		return

	match enemy_type:
		EnemyType.GOBLIN:
			body_visual.color = Color(0.0, 0.7, 0.0, 1.0)  # Grün
			body_visual.size = Vector2(30, 30)
			body_visual.position = Vector2(-15, -15)
		EnemyType.ORC:
			body_visual.color = Color(0.5, 0.3, 0.1, 1.0)  # Braun
			body_visual.size = Vector2(40, 40)
			body_visual.position = Vector2(-20, -20)
		EnemyType.TROLL:
			body_visual.color = Color(0.4, 0.0, 0.4, 1.0)  # Lila
			body_visual.size = Vector2(50, 50)
			body_visual.position = Vector2(-25, -25)


func _physics_process(delta: float) -> void:
	if path_points.size() == 0:
		return

	if current_path_index >= path_points.size():
		_reached_end()
		return

	var target_point: Vector2i = path_points[current_path_index]
	var target_pos: Vector2 = Vector2(
		target_point.x * tile_size + tile_size / 2,
		target_point.y * tile_size + tile_size / 2
	)

	var direction: Vector2 = (target_pos - position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	# Prüfen ob der nächste Wegpunkt erreicht wurde
	if position.distance_to(target_pos) < 10.0:
		current_path_index += 1


## Fügt dem Feind Schaden zu
func take_damage(amount: float) -> void:
	current_health -= amount
	_update_health_bar()

	if current_health <= 0:
		_die()


## Aktualisiert den Gesundheitsbalken
func _update_health_bar() -> void:
	if health_bar == null:
		return
	var health_ratio: float = clamp(current_health / max_health, 0.0, 1.0)
	health_bar.size.x = 40.0 * health_ratio

	# Farbe ändern basierend auf Gesundheit
	if health_ratio > 0.6:
		health_bar.color = Color(0.0, 0.8, 0.0, 0.9)
	elif health_ratio > 0.3:
		health_bar.color = Color(0.8, 0.8, 0.0, 0.9)
	else:
		health_bar.color = Color(0.8, 0.0, 0.0, 0.9)


## Feind wurde besiegt
func _die() -> void:
	enemy_killed.emit(gold_reward)
	queue_free()


## Feind hat das Ende des Pfades erreicht
func _reached_end() -> void:
	enemy_reached_end.emit(base_damage)
	queue_free()
