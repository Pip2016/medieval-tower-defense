extends Node
class_name GameManager

## Spielmanager - Verwaltet Spielzustand, Wellen, Wirtschaft und Turm-Platzierung.
## Zentrales Steuerungsskript für die gesamte Spiellogik.

# Spielkonfiguration
const MAX_WAVES: int = 10
const STARTING_GOLD: int = 200
const STARTING_HEALTH: int = 20

# Spielzustand
var current_gold: int = STARTING_GOLD
var current_health: int = STARTING_HEALTH
var current_wave: int = 0
var is_wave_active: bool = false
var game_active: bool = true

# Wellen-Verwaltung
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var enemies_alive: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5

# Referenzen
var level_generator: LevelGenerator
var enemy_container: Node2D
var tower_container: Node2D

# Ausgewählter Turmtyp zum Platzieren
var selected_tower_type: Tower.TowerType = Tower.TowerType.ARCHER
var is_placing_tower: bool = false

# Platzierte Türme (Grid-Position -> Tower)
var placed_towers: Dictionary = {}

# Signale
signal gold_changed(new_gold: int)
signal health_changed(new_health: int)
signal wave_changed(wave: int, max_waves: int)
signal wave_completed(wave: int)
signal game_over()
signal game_won()
signal enemy_spawned(enemy: CharacterBody2D)


func _ready() -> void:
	pass


## Initialisiert den GameManager mit Referenzen
func initialize(level_gen: LevelGenerator, enemy_cont: Node2D, tower_cont: Node2D) -> void:
	level_generator = level_gen
	enemy_container = enemy_cont
	tower_container = tower_cont
	_reset_game()


## Setzt das Spiel zurück
func _reset_game() -> void:
	current_gold = STARTING_GOLD
	current_health = STARTING_HEALTH
	current_wave = 0
	is_wave_active = false
	game_active = true
	placed_towers.clear()

	gold_changed.emit(current_gold)
	health_changed.emit(current_health)
	wave_changed.emit(current_wave, MAX_WAVES)


## Startet die nächste Welle
func start_next_wave() -> void:
	if is_wave_active or not game_active:
		return

	if current_wave >= MAX_WAVES:
		return

	current_wave += 1
	is_wave_active = true

	# Feindanzahl berechnen: 5 + (Welle * 3)
	enemies_to_spawn = 5 + (current_wave * 3)
	enemies_spawned = 0
	enemies_alive = 0
	spawn_timer = 0.0

	# Spawn-Intervall: wird mit höheren Wellen kürzer
	spawn_interval = max(0.3, 1.5 - current_wave * 0.1)

	wave_changed.emit(current_wave, MAX_WAVES)


func _process(delta: float) -> void:
	if not game_active or not is_wave_active:
		return

	# Feinde spawnen
	if enemies_spawned < enemies_to_spawn:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			_spawn_enemy()

	# Prüfen ob die Welle beendet ist
	elif enemies_alive <= 0:
		_complete_wave()


## Spawnt einen Feind
func _spawn_enemy() -> void:
	if level_generator == null or level_generator.path_points.size() == 0:
		return

	var enemy_scene := Enemy.new()
	enemy_container.add_child(enemy_scene)

	# Feindtyp basierend auf Welle bestimmen
	var enemy_type: Enemy.EnemyType = _get_enemy_type_for_wave()
	enemy_scene.setup(enemy_type, level_generator.path_points, level_generator.TILE_SIZE)

	# Signale verbinden
	enemy_scene.enemy_killed.connect(_on_enemy_killed)
	enemy_scene.enemy_reached_end.connect(_on_enemy_reached_end)

	enemies_spawned += 1
	enemies_alive += 1
	enemy_spawned.emit(enemy_scene)


## Bestimmt den Feindtyp basierend auf der aktuellen Welle
func _get_enemy_type_for_wave() -> Enemy.EnemyType:
	var roll: float = randf()

	if current_wave <= 2:
		return Enemy.EnemyType.GOBLIN
	elif current_wave <= 5:
		if roll < 0.7:
			return Enemy.EnemyType.GOBLIN
		else:
			return Enemy.EnemyType.ORC
	elif current_wave <= 8:
		if roll < 0.4:
			return Enemy.EnemyType.GOBLIN
		elif roll < 0.8:
			return Enemy.EnemyType.ORC
		else:
			return Enemy.EnemyType.TROLL
	else:
		if roll < 0.2:
			return Enemy.EnemyType.GOBLIN
		elif roll < 0.6:
			return Enemy.EnemyType.ORC
		else:
			return Enemy.EnemyType.TROLL


## Welle abschließen
func _complete_wave() -> void:
	is_wave_active = false

	# Wellenbonus: 50 + (Welle * 10)
	var bonus: int = 50 + (current_wave * 10)
	_add_gold(bonus)

	wave_completed.emit(current_wave)

	# Prüfen ob das Spiel gewonnen wurde
	if current_wave >= MAX_WAVES:
		game_active = false
		game_won.emit()


## Versucht einen Turm an der gegebenen Position zu platzieren
func try_place_tower(grid_pos: Vector2i) -> bool:
	if not game_active:
		return false

	if not level_generator.can_build_at(grid_pos):
		return false

	# Prüfen ob bereits ein Turm dort steht
	if placed_towers.has(grid_pos):
		return false

	# Kosten prüfen
	var cost: int = _get_tower_cost(selected_tower_type)
	if current_gold < cost:
		return false

	# Turm erstellen und platzieren
	var tower := Tower.new()
	tower_container.add_child(tower)
	tower.setup(selected_tower_type)
	tower.position = level_generator.grid_to_world(grid_pos)

	placed_towers[grid_pos] = tower
	_spend_gold(cost)

	# Feld als besetzt markieren
	level_generator.grid[grid_pos.x][grid_pos.y] = LevelGenerator.CellType.BLOCKED

	return true


## Versucht einen Turm aufzuwerten
func try_upgrade_tower(grid_pos: Vector2i) -> bool:
	if not placed_towers.has(grid_pos):
		return false

	var tower: Tower = placed_towers[grid_pos]
	var cost: int = tower.get_upgrade_cost()

	if current_gold < cost:
		return false

	if tower.upgrade():
		_spend_gold(cost)
		return true

	return false


## Gibt die Kosten für einen Turmtyp zurück
func _get_tower_cost(type: Tower.TowerType) -> int:
	match type:
		Tower.TowerType.ARCHER:
			return 100
		Tower.TowerType.MAGE:
			return 150
		Tower.TowerType.CANNON:
			return 200
		Tower.TowerType.BARRACKS:
			return 120
	return 100


## Gold hinzufügen
func _add_gold(amount: int) -> void:
	current_gold += amount
	gold_changed.emit(current_gold)


## Gold ausgeben
func _spend_gold(amount: int) -> void:
	current_gold -= amount
	gold_changed.emit(current_gold)


# Signal-Callbacks
func _on_enemy_killed(gold: int) -> void:
	enemies_alive -= 1
	_add_gold(gold)


func _on_enemy_reached_end(damage: int) -> void:
	enemies_alive -= 1
	current_health -= damage
	current_health = max(0, current_health)
	health_changed.emit(current_health)

	if current_health <= 0:
		game_active = false
		is_wave_active = false
		game_over.emit()


## Setzt den ausgewählten Turmtyp
func select_tower_type(type: Tower.TowerType) -> void:
	selected_tower_type = type
	is_placing_tower = true
