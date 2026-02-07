extends Node2D
class_name MainGame

## Haupt-Spielszene - Verbindet alle Systeme und verarbeitet Eingaben.
## Koordiniert LevelGenerator, GameManager, UIManager und Touch-Eingaben.

# Referenzen zu Subsystemen
var level_generator: LevelGenerator
var game_manager: GameManager
var ui_manager: UIManager
var enemy_container: Node2D
var tower_container: Node2D
var camera: Camera2D


func _ready() -> void:
	_setup_camera()
	_setup_containers()
	_setup_systems()
	_connect_signals()
	_start_game()


## Kamera einrichten für die Spielansicht
func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(
		LevelGenerator.GRID_WIDTH * LevelGenerator.TILE_SIZE / 2,
		LevelGenerator.GRID_HEIGHT * LevelGenerator.TILE_SIZE / 2
	)
	camera.zoom = Vector2(1.0, 1.0)
	camera.enabled = true
	add_child(camera)


## Container für Spielobjekte erstellen
func _setup_containers() -> void:
	# Level-Container
	level_generator = LevelGenerator.new()
	level_generator.name = "LevelGenerator"
	add_child(level_generator)

	# Feind-Container
	enemy_container = Node2D.new()
	enemy_container.name = "EnemyContainer"
	add_child(enemy_container)

	# Turm-Container
	tower_container = Node2D.new()
	tower_container.name = "TowerContainer"
	add_child(tower_container)


## Spielsysteme einrichten
func _setup_systems() -> void:
	# GameManager
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	add_child(game_manager)

	# UIManager
	ui_manager = UIManager.new()
	ui_manager.name = "UIManager"
	add_child(ui_manager)


## Signale zwischen Systemen verbinden
func _connect_signals() -> void:
	# UIManager mit GameManager verbinden
	ui_manager.connect_to_game_manager(game_manager)

	# UI-Signale
	ui_manager.tower_selected.connect(_on_tower_selected)
	ui_manager.start_wave_pressed.connect(_on_start_wave_pressed)
	ui_manager.restart_pressed.connect(_on_restart_pressed)


## Spiel starten
func _start_game() -> void:
	# Level generieren
	level_generator.generate_level()

	# GameManager initialisieren
	game_manager.initialize(level_generator, enemy_container, tower_container)


## Touch-Eingabe verarbeiten
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_touch(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position)


## Touch-Position verarbeiten
func _handle_touch(screen_pos: Vector2) -> void:
	if not game_manager.game_active:
		return

	# Bildschirmposition in Weltposition umrechnen
	var world_pos: Vector2 = _screen_to_world(screen_pos)
	var grid_pos: Vector2i = level_generator.world_to_grid(world_pos)

	# Prüfen ob bereits ein Turm dort steht (Upgrade)
	if game_manager.placed_towers.has(grid_pos):
		game_manager.try_upgrade_tower(grid_pos)
		return

	# Neuen Turm platzieren
	if game_manager.is_placing_tower:
		game_manager.try_place_tower(grid_pos)


## Konvertiert Bildschirmposition zu Weltposition
func _screen_to_world(screen_pos: Vector2) -> Vector2:
	if camera:
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		var camera_pos: Vector2 = camera.position
		var zoom: Vector2 = camera.zoom
		return camera_pos + (screen_pos - viewport_size / 2) / zoom
	return screen_pos


# Signal-Callbacks
func _on_tower_selected(type: Tower.TowerType) -> void:
	game_manager.select_tower_type(type)


func _on_start_wave_pressed() -> void:
	game_manager.start_next_wave()


func _on_restart_pressed() -> void:
	# Alle Feinde und Türme entfernen
	for child in enemy_container.get_children():
		child.queue_free()
	for child in tower_container.get_children():
		child.queue_free()

	# Level neu generieren
	level_generator.generate_level()

	# Spiel zurücksetzen
	game_manager.initialize(level_generator, enemy_container, tower_container)
