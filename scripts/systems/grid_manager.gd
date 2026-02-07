class_name GridManager
extends Node3D

## Manages the tower placement grid. Tracks occupied cells and validates placement.

signal cell_state_changed(pos: Vector2i, occupied: bool)

@export var grid_size: Vector2i = Vector2i(20, 15)
@export var cell_size: float = 2.0
@export var grid_color_buildable: Color = Color(0.2, 0.6, 0.2, 0.3)
@export var grid_color_path: Color = Color(0.6, 0.4, 0.2, 0.8)
@export var grid_color_blocked: Color = Color(0.6, 0.2, 0.2, 0.3)

enum CellState { EMPTY, BUILDABLE, PATH, OCCUPIED, BLOCKED }

var grid: Array = []  # 2D array of CellState
var occupied_objects: Dictionary = {}  # Vector2i -> Node3D
var grid_visuals: Node3D
var hover_indicator: MeshInstance3D


func _ready() -> void:
	_initialize_grid()
	_create_visuals()
	_create_hover_indicator()


func _initialize_grid() -> void:
	grid.clear()
	for x in range(grid_size.x):
		var column: Array = []
		for z in range(grid_size.y):
			column.append(CellState.EMPTY)
		grid.append(column)


func setup_path(waypoints: Array[Vector3]) -> void:
	for wp in waypoints:
		var grid_pos: Vector2i = world_to_grid(wp)
		if _is_valid_pos(grid_pos):
			grid[grid_pos.x][grid_pos.y] = CellState.PATH
			# Block adjacent cells to path
			for dx in range(-1, 2):
				for dz in range(-1, 2):
					var adj := Vector2i(grid_pos.x + dx, grid_pos.y + dz)
					if _is_valid_pos(adj) and grid[adj.x][adj.y] == CellState.EMPTY:
						grid[adj.x][adj.y] = CellState.BLOCKED

	# Mark remaining empty cells as buildable
	for x in range(grid_size.x):
		for z in range(grid_size.y):
			if grid[x][z] == CellState.EMPTY:
				grid[x][z] = CellState.BUILDABLE

	_update_visuals()


func can_place_at(pos: Vector2i, size: int = 1) -> bool:
	for dx in range(size):
		for dz in range(size):
			var check := Vector2i(pos.x + dx, pos.y + dz)
			if not _is_valid_pos(check):
				return false
			if grid[check.x][check.y] != CellState.BUILDABLE:
				return false
	return true


func occupy_cells(pos: Vector2i, object: Node3D, size: int = 1) -> void:
	for dx in range(size):
		for dz in range(size):
			var cell := Vector2i(pos.x + dx, pos.y + dz)
			if _is_valid_pos(cell):
				grid[cell.x][cell.y] = CellState.OCCUPIED
				occupied_objects[cell] = object
				cell_state_changed.emit(cell, true)
	_update_visuals()


func free_cells(pos: Vector2i, size: int = 1) -> void:
	for dx in range(size):
		for dz in range(size):
			var cell := Vector2i(pos.x + dx, pos.y + dz)
			if _is_valid_pos(cell):
				grid[cell.x][cell.y] = CellState.BUILDABLE
				occupied_objects.erase(cell)
				cell_state_changed.emit(cell, false)
	_update_visuals()


func get_object_at(pos: Vector2i) -> Node3D:
	return occupied_objects.get(pos)


func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(
		grid_pos.x * cell_size + cell_size * 0.5,
		0.0,
		grid_pos.y * cell_size + cell_size * 0.5
	)


func world_to_grid(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		int(world_pos.x / cell_size),
		int(world_pos.z / cell_size)
	)


func show_hover(grid_pos: Vector2i) -> void:
	if hover_indicator:
		hover_indicator.visible = true
		hover_indicator.position = grid_to_world(grid_pos)
		hover_indicator.position.y = 0.05
		var can_build: bool = can_place_at(grid_pos)
		var mat: StandardMaterial3D = hover_indicator.get_surface_override_material(0)
		if mat:
			mat.albedo_color = Color(0, 1, 0, 0.5) if can_build else Color(1, 0, 0, 0.5)


func hide_hover() -> void:
	if hover_indicator:
		hover_indicator.visible = false


func _is_valid_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y


func _create_visuals() -> void:
	if grid_visuals:
		grid_visuals.queue_free()
	grid_visuals = Node3D.new()
	grid_visuals.name = "GridVisuals"
	add_child(grid_visuals)


func _update_visuals() -> void:
	for child in grid_visuals.get_children():
		child.queue_free()

	for x in range(grid_size.x):
		for z in range(grid_size.y):
			var state: CellState = grid[x][z]
			var color: Color
			match state:
				CellState.BUILDABLE:
					color = grid_color_buildable
				CellState.PATH:
					color = grid_color_path
				CellState.BLOCKED:
					color = grid_color_blocked
				CellState.OCCUPIED:
					continue
				_:
					continue

			var mesh_instance := MeshInstance3D.new()
			var plane := PlaneMesh.new()
			plane.size = Vector2(cell_size * 0.95, cell_size * 0.95)
			mesh_instance.mesh = plane

			var mat := StandardMaterial3D.new()
			mat.albedo_color = color
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mesh_instance.set_surface_override_material(0, mat)

			mesh_instance.position = grid_to_world(Vector2i(x, z))
			mesh_instance.position.y = 0.01
			grid_visuals.add_child(mesh_instance)


func _create_hover_indicator() -> void:
	hover_indicator = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(cell_size * 0.9, cell_size * 0.9)
	hover_indicator.mesh = plane

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hover_indicator.set_surface_override_material(0, mat)
	hover_indicator.visible = false
	add_child(hover_indicator)
