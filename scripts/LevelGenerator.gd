extends Node2D
class_name LevelGenerator

## Prozeduraler Level-Generator für das Tower Defense Spiel.
## Erzeugt ein Raster mit zufälligem Pfad und baubaren Feldern.

# Raster-Konfiguration
const GRID_WIDTH: int = 16
const GRID_HEIGHT: int = 24
const TILE_SIZE: int = 64

# Zelltypen
enum CellType { EMPTY, PATH, BLOCKED, BUILDABLE }

# Generiertes Raster
var grid: Array = []
var path_points: Array = []
var buildable_tiles: Array = []

# Signale
signal level_generated(path: Array, buildable: Array)


func _ready() -> void:
	pass


## Hauptfunktion: Generiert ein neues Level
func generate_level() -> void:
	_initialize_grid()
	_generate_path()
	_smooth_path()
	_mark_blocked_tiles()
	_identify_buildable_tiles()
	_draw_level()
	level_generated.emit(path_points, buildable_tiles)


## Initialisiert das Raster mit leeren Zellen
func _initialize_grid() -> void:
	grid.clear()
	for x in range(GRID_WIDTH):
		var column: Array = []
		for y in range(GRID_HEIGHT):
			column.append(CellType.EMPTY)
		grid.append(column)


## Generiert einen zufälligen Pfad von links nach rechts
func _generate_path() -> void:
	path_points.clear()
	var current_y: int = randi_range(2, GRID_HEIGHT - 3)
	var start_pos: Vector2i = Vector2i(0, current_y)
	path_points.append(start_pos)
	grid[0][current_y] = CellType.PATH

	var current_x: int = 0
	while current_x < GRID_WIDTH - 1:
		var direction: int = randi_range(0, 2)
		var next_x: int = current_x
		var next_y: int = current_y

		match direction:
			0: # Rechts
				next_x += 1
			1: # Rechts-Oben
				next_x += 1
				next_y = max(1, next_y - randi_range(1, 3))
			2: # Rechts-Unten
				next_x += 1
				next_y = min(GRID_HEIGHT - 2, next_y + randi_range(1, 3))

		# Zwischenpunkte auf der Y-Achse hinzufügen
		var step_y: int = 1 if next_y > current_y else -1
		if next_y != current_y:
			var y: int = current_y
			while y != next_y:
				y += step_y
				if grid[current_x][y] != CellType.PATH:
					grid[current_x][y] = CellType.PATH
					path_points.append(Vector2i(current_x, y))

		# Zum nächsten X-Punkt bewegen
		current_x = next_x
		current_y = next_y
		if current_x < GRID_WIDTH:
			grid[current_x][current_y] = CellType.PATH
			path_points.append(Vector2i(current_x, current_y))


## Glättet den Pfad für bessere Optik
func _smooth_path() -> void:
	if path_points.size() < 3:
		return
	var smoothed: Array = [path_points[0]]
	for i in range(1, path_points.size() - 1):
		var prev: Vector2i = path_points[i - 1]
		var curr: Vector2i = path_points[i]
		var next_pt: Vector2i = path_points[i + 1]
		# Entferne Punkte die zu starke Zickzack-Muster erzeugen
		if abs(prev.y - next_pt.y) <= 2:
			smoothed.append(curr)
		else:
			smoothed.append(curr)
	smoothed.append(path_points[path_points.size() - 1])
	path_points = smoothed


## Markiert Felder neben dem Pfad als blockiert
func _mark_blocked_tiles() -> void:
	for point in path_points:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var nx: int = point.x + dx
				var ny: int = point.y + dy
				if nx >= 0 and nx < GRID_WIDTH and ny >= 0 and ny < GRID_HEIGHT:
					if grid[nx][ny] == CellType.EMPTY:
						grid[nx][ny] = CellType.BLOCKED


## Identifiziert Felder auf denen gebaut werden kann
func _identify_buildable_tiles() -> void:
	buildable_tiles.clear()
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid[x][y] == CellType.EMPTY or grid[x][y] == CellType.BLOCKED:
				# Nur Felder die nicht direkt am Pfad sind
				if grid[x][y] == CellType.EMPTY:
					grid[x][y] = CellType.BUILDABLE
					buildable_tiles.append(Vector2i(x, y))


## Zeichnet das Level visuell
func _draw_level() -> void:
	# Vorherige Zeichnungen entfernen
	for child in get_children():
		child.queue_free()

	# Pfad zeichnen
	for point in path_points:
		var rect := ColorRect.new()
		rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
		rect.position = Vector2(point.x * TILE_SIZE + 1, point.y * TILE_SIZE + 1)
		rect.color = Color(0.55, 0.4, 0.25, 1.0) # Erdbraun
		add_child(rect)

	# Baubare Felder zeichnen
	for tile in buildable_tiles:
		var rect := ColorRect.new()
		rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
		rect.position = Vector2(tile.x * TILE_SIZE + 1, tile.y * TILE_SIZE + 1)
		rect.color = Color(0.3, 0.5, 0.2, 0.3) # Halbtransparentes Grün
		add_child(rect)


## Gibt die Weltposition für eine Rasterkoordinate zurück
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE / 2, grid_pos.y * TILE_SIZE + TILE_SIZE / 2)


## Gibt die Rasterkoordinate für eine Weltposition zurück
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))


## Prüft ob an einer Rasterposition gebaut werden kann
func can_build_at(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= GRID_WIDTH:
		return false
	if grid_pos.y < 0 or grid_pos.y >= GRID_HEIGHT:
		return false
	return grid[grid_pos.x][grid_pos.y] == CellType.BUILDABLE
