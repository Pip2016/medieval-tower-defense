extends Node2D
class_name Tower

## Turm-Klasse mit Angriffs-, Reichweiten- und Upgrade-System.
## Unterstützt verschiedene Turmtypen mit einzigartigen Eigenschaften.

# Turmtypen
enum TowerType { ARCHER, MAGE, CANNON, BARRACKS }

# Turm-Konfiguration
var tower_type: TowerType = TowerType.ARCHER
var tower_level: int = 1
var base_damage: float = 15.0
var attack_range: float = 200.0
var attack_speed: float = 2.0  # Angriffe pro Sekunde
var tower_cost: int = 100

# Kampf-Variablen
var attack_timer: float = 0.0
var current_target: CharacterBody2D = null
var enemies_in_range: Array = []

# Visuelle Elemente
var body_visual: ColorRect
var range_indicator: Node2D
var attack_area: Area2D

# Signale
signal tower_upgraded(new_level: int)


func _ready() -> void:
	_create_visuals()
	_create_attack_area()


## Initialisiert den Turm mit einem Typ
func setup(type: TowerType) -> void:
	tower_type = type
	tower_level = 1

	match tower_type:
		TowerType.ARCHER:
			base_damage = 15.0
			attack_range = 200.0
			attack_speed = 2.0
			tower_cost = 100
		TowerType.MAGE:
			base_damage = 35.0
			attack_range = 180.0
			attack_speed = 0.8
			tower_cost = 150
		TowerType.CANNON:
			base_damage = 80.0
			attack_range = 220.0
			attack_speed = 0.5
			tower_cost = 200
		TowerType.BARRACKS:
			base_damage = 0.0
			attack_range = 100.0
			attack_speed = 0.0
			tower_cost = 120

	_update_visuals()
	_update_attack_area()


## Erstellt die visuellen Elemente des Turms
func _create_visuals() -> void:
	body_visual = ColorRect.new()
	body_visual.size = Vector2(50, 50)
	body_visual.position = Vector2(-25, -25)
	add_child(body_visual)


## Aktualisiert die Optik basierend auf Turmtyp und Level
func _update_visuals() -> void:
	if body_visual == null:
		return

	match tower_type:
		TowerType.ARCHER:
			body_visual.color = Color(0.2, 0.6, 0.2, 1.0)  # Grün
			# Turm-Dekoration
			var top := ColorRect.new()
			top.size = Vector2(20, 20)
			top.position = Vector2(-10, -35)
			top.color = Color(0.1, 0.5, 0.1, 1.0)
			add_child(top)
		TowerType.MAGE:
			body_visual.color = Color(0.3, 0.2, 0.7, 1.0)  # Violett
			var top := ColorRect.new()
			top.size = Vector2(15, 25)
			top.position = Vector2(-7, -38)
			top.color = Color(0.5, 0.3, 0.9, 1.0)
			add_child(top)
		TowerType.CANNON:
			body_visual.color = Color(0.5, 0.5, 0.5, 1.0)  # Grau
			body_visual.size = Vector2(55, 45)
			body_visual.position = Vector2(-27, -22)
			var barrel := ColorRect.new()
			barrel.size = Vector2(30, 12)
			barrel.position = Vector2(5, -6)
			barrel.color = Color(0.3, 0.3, 0.3, 1.0)
			add_child(barrel)
		TowerType.BARRACKS:
			body_visual.color = Color(0.6, 0.5, 0.2, 1.0)  # Gold
			body_visual.size = Vector2(55, 55)
			body_visual.position = Vector2(-27, -27)

	# Level-Indikator
	for i in range(tower_level - 1):
		var star := ColorRect.new()
		star.size = Vector2(8, 8)
		star.position = Vector2(-20 + i * 12, 28)
		star.color = Color(1.0, 0.9, 0.0, 1.0)
		add_child(star)


## Erstellt den Angriffsbereich (Area2D)
func _create_attack_area() -> void:
	attack_area = Area2D.new()
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = attack_range
	collision.shape = shape
	attack_area.add_child(collision)
	add_child(attack_area)

	attack_area.body_entered.connect(_on_enemy_entered)
	attack_area.body_exited.connect(_on_enemy_exited)


## Aktualisiert den Angriffsbereich
func _update_attack_area() -> void:
	if attack_area == null:
		return
	var collision: CollisionShape2D = attack_area.get_child(0)
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = attack_range


func _process(delta: float) -> void:
	if tower_type == TowerType.BARRACKS:
		return  # Kaserne hat keinen direkten Angriff

	attack_timer += delta

	# Ziel aktualisieren
	_update_target()

	# Angreifen wenn möglich
	if current_target and attack_timer >= (1.0 / attack_speed):
		_attack(current_target)
		attack_timer = 0.0


## Aktualisiert das aktuelle Ziel (priorisiert am weitesten fortgeschrittene Feinde)
func _update_target() -> void:
	# Ungültige Feinde entfernen
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.is_empty():
		current_target = null
		return

	# Feind mit höchstem Pfad-Index wählen (am weitesten fortgeschritten)
	var best_target: CharacterBody2D = null
	var best_progress: int = -1

	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			if enemy.current_path_index > best_progress:
				best_progress = enemy.current_path_index
				best_target = enemy

	current_target = best_target


## Führt einen Angriff auf das Ziel aus
func _attack(target: CharacterBody2D) -> void:
	if not is_instance_valid(target):
		return

	var damage: float = _get_current_damage()

	# Projektil-Animation
	_create_projectile(target.position)

	if target.has_method("take_damage"):
		target.take_damage(damage)


## Berechnet den aktuellen Schaden basierend auf Level
func _get_current_damage() -> float:
	return base_damage * pow(1.5, tower_level - 1)


## Erstellt eine Projektil-Animation
func _create_projectile(target_pos: Vector2) -> void:
	var projectile := ColorRect.new()
	projectile.size = Vector2(8, 8)
	projectile.position = Vector2(-4, -4)

	match tower_type:
		TowerType.ARCHER:
			projectile.color = Color(0.8, 0.6, 0.2, 1.0)  # Pfeil
			projectile.size = Vector2(6, 6)
		TowerType.MAGE:
			projectile.color = Color(0.5, 0.2, 1.0, 1.0)  # Magiekugel
			projectile.size = Vector2(10, 10)
		TowerType.CANNON:
			projectile.color = Color(0.2, 0.2, 0.2, 1.0)  # Kanonenkugel
			projectile.size = Vector2(12, 12)

	add_child(projectile)

	# Einfache Projektil-Animation mit Tween
	var tween: Tween = create_tween()
	var local_target: Vector2 = target_pos - global_position
	tween.tween_property(projectile, "position", local_target, 0.2)
	tween.tween_callback(projectile.queue_free)


## Upgrade des Turms
func upgrade() -> bool:
	if tower_level >= 3:
		return false

	tower_level += 1
	attack_range *= 1.1  # +10% Reichweite
	_update_attack_area()

	# Visuelle Elemente neu erstellen
	for child in get_children():
		if child != attack_area:
			child.queue_free()
	_create_visuals()
	_update_visuals()

	tower_upgraded.emit(tower_level)
	return true


## Gibt die Upgrade-Kosten zurück
func get_upgrade_cost() -> int:
	return tower_cost * tower_level


## Gibt den Turmtyp als String zurück
func get_type_name() -> String:
	match tower_type:
		TowerType.ARCHER:
			return "Bogenschütze"
		TowerType.MAGE:
			return "Magier"
		TowerType.CANNON:
			return "Kanone"
		TowerType.BARRACKS:
			return "Kaserne"
	return "Unbekannt"


# Signal-Callbacks für Area2D
func _on_enemy_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("take_damage"):
		enemies_in_range.append(body)


func _on_enemy_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
