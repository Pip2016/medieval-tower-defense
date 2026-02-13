class_name GameHUD
extends CanvasLayer

## Main game HUD. Displays resources, wave info, tower selection, and ability bar.

var gold_label: Label
var lives_label: Label
var wave_label: Label
var enemies_label: Label
var start_wave_button: Button
var tower_panel: HBoxContainer
var ability_panel: HBoxContainer
var game_end_panel: Panel
var game_end_label: Label
var restart_button: Button
var tower_info_panel: Panel
var tower_info_label: Label
var sell_button: Button
var upgrade_button: Button

# Tower data references for building
var tower_datas: Array[TowerData] = []
var selected_tower_data: TowerData

signal tower_build_selected(data: TowerData)
signal tower_build_cancelled()
signal start_wave_pressed()
signal restart_pressed()
signal upgrade_pressed()
signal sell_pressed()


func _ready() -> void:
	_create_ui()
	_connect_signals()


func set_tower_datas(datas: Array[TowerData]) -> void:
	tower_datas = datas
	_rebuild_tower_buttons()


func _connect_signals() -> void:
	GameEvents.gold_changed.connect(_on_gold_changed)
	GameEvents.lives_changed.connect(_on_lives_changed)
	GameEvents.wave_started.connect(_on_wave_started)
	GameEvents.wave_completed.connect(_on_wave_completed)
	GameEvents.wave_enemies_remaining.connect(_on_enemies_remaining)
	GameEvents.game_over.connect(_on_game_over)
	GameEvents.game_won.connect(_on_game_won)
	GameEvents.tower_selected.connect(_on_tower_selected)
	GameEvents.tower_deselected.connect(_on_tower_deselected)
	GameEvents.ability_cooldown_updated.connect(_on_ability_cooldown_updated)


func _create_ui() -> void:
	# Top bar background
	var top_bg := ColorRect.new()
	top_bg.color = Color(0.1, 0.1, 0.1, 0.7)
	top_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bg.size.y = 50
	add_child(top_bg)

	# Top bar container
	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(20, 8)
	top_bar.size = Vector2(1880, 40)
	top_bar.add_theme_constant_override("separation", 40)
	add_child(top_bar)

	gold_label = _create_label("Gold: 300", Color(1.0, 0.85, 0.0))
	top_bar.add_child(gold_label)

	lives_label = _create_label("Lives: 20", Color(0.9, 0.2, 0.2))
	top_bar.add_child(lives_label)

	wave_label = _create_label("Wave: 0/15", Color(0.9, 0.9, 0.9))
	top_bar.add_child(wave_label)

	enemies_label = _create_label("Enemies: 0", Color(0.7, 0.7, 0.7))
	top_bar.add_child(enemies_label)

	# Bottom panel background
	var bottom_bg := ColorRect.new()
	bottom_bg.color = Color(0.1, 0.1, 0.1, 0.7)
	bottom_bg.position = Vector2(0, 980)
	bottom_bg.size = Vector2(1920, 100)
	add_child(bottom_bg)

	# Tower selection panel
	tower_panel = HBoxContainer.new()
	tower_panel.position = Vector2(20, 990)
	tower_panel.size = Vector2(800, 80)
	tower_panel.add_theme_constant_override("separation", 8)
	add_child(tower_panel)

	# Start wave button
	start_wave_button = Button.new()
	start_wave_button.text = "Start Wave"
	start_wave_button.position = Vector2(1650, 990)
	start_wave_button.size = Vector2(250, 70)
	start_wave_button.add_theme_font_size_override("font_size", 22)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.5, 0.15)
	btn_style.set_corner_radius_all(8)
	start_wave_button.add_theme_stylebox_override("normal", btn_style)
	start_wave_button.pressed.connect(func(): start_wave_pressed.emit())
	add_child(start_wave_button)

	# Ability panel
	ability_panel = HBoxContainer.new()
	ability_panel.position = Vector2(900, 990)
	ability_panel.size = Vector2(600, 80)
	ability_panel.add_theme_constant_override("separation", 8)
	add_child(ability_panel)

	# Tower info panel (hidden)
	_create_tower_info_panel()

	# Game end panel (hidden)
	_create_game_end_panel()


func _create_tower_info_panel() -> void:
	tower_info_panel = Panel.new()
	tower_info_panel.position = Vector2(1450, 600)
	tower_info_panel.size = Vector2(450, 350)
	tower_info_panel.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.12, 0.9)
	style.set_corner_radius_all(10)
	tower_info_panel.add_theme_stylebox_override("panel", style)
	add_child(tower_info_panel)

	tower_info_label = Label.new()
	tower_info_label.position = Vector2(20, 20)
	tower_info_label.size = Vector2(410, 200)
	tower_info_label.add_theme_font_size_override("font_size", 18)
	tower_info_panel.add_child(tower_info_label)

	upgrade_button = Button.new()
	upgrade_button.text = "Upgrade"
	upgrade_button.position = Vector2(20, 260)
	upgrade_button.size = Vector2(190, 50)
	upgrade_button.add_theme_font_size_override("font_size", 18)
	upgrade_button.pressed.connect(func(): upgrade_pressed.emit())
	tower_info_panel.add_child(upgrade_button)

	sell_button = Button.new()
	sell_button.text = "Sell"
	sell_button.position = Vector2(240, 260)
	sell_button.size = Vector2(190, 50)
	sell_button.add_theme_font_size_override("font_size", 18)
	var sell_style := StyleBoxFlat.new()
	sell_style.bg_color = Color(0.6, 0.15, 0.15)
	sell_style.set_corner_radius_all(6)
	sell_button.add_theme_stylebox_override("normal", sell_style)
	sell_button.pressed.connect(func(): sell_pressed.emit())
	tower_info_panel.add_child(sell_button)


func _create_game_end_panel() -> void:
	game_end_panel = Panel.new()
	game_end_panel.position = Vector2(610, 340)
	game_end_panel.size = Vector2(700, 400)
	game_end_panel.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 0.95)
	style.set_corner_radius_all(16)
	game_end_panel.add_theme_stylebox_override("panel", style)
	add_child(game_end_panel)

	game_end_label = Label.new()
	game_end_label.position = Vector2(50, 50)
	game_end_label.size = Vector2(600, 150)
	game_end_label.add_theme_font_size_override("font_size", 56)
	game_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_end_panel.add_child(game_end_label)

	restart_button = Button.new()
	restart_button.text = "Play Again"
	restart_button.position = Vector2(200, 280)
	restart_button.size = Vector2(300, 80)
	restart_button.add_theme_font_size_override("font_size", 28)
	restart_button.pressed.connect(func(): restart_pressed.emit())
	game_end_panel.add_child(restart_button)


func _rebuild_tower_buttons() -> void:
	for child in tower_panel.get_children():
		child.queue_free()

	for data in tower_datas:
		var btn := Button.new()
		btn.text = "%s\n%dg" % [data.tower_name, data.base_cost]
		btn.custom_minimum_size = Vector2(150, 70)
		btn.add_theme_font_size_override("font_size", 16)

		var style := StyleBoxFlat.new()
		style.bg_color = data.tower_color.darkened(0.3)
		style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", style)

		var hover := StyleBoxFlat.new()
		hover.bg_color = data.tower_color.darkened(0.1)
		hover.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover)

		btn.pressed.connect(func(): tower_build_selected.emit(data))
		tower_panel.add_child(btn)

	# Cancel button
	var cancel := Button.new()
	cancel.text = "Cancel\n[X]"
	cancel.custom_minimum_size = Vector2(100, 70)
	cancel.add_theme_font_size_override("font_size", 16)
	var cancel_style := StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.5, 0.15, 0.15)
	cancel_style.set_corner_radius_all(6)
	cancel.add_theme_stylebox_override("normal", cancel_style)
	cancel.pressed.connect(func(): tower_build_cancelled.emit())
	tower_panel.add_child(cancel)


func show_tower_info(tower: TowerController) -> void:
	if tower == null or tower.tower_data == null:
		tower_info_panel.visible = false
		return

	var stats: Dictionary = tower.tower_data.get_stats_at_level(tower.current_level)
	var info: String = "%s (Level %d)\n" % [tower.tower_data.tower_name, tower.current_level]
	info += "Damage: %.0f\n" % stats["damage"]
	info += "Range: %.0f\n" % stats["range"]
	info += "Speed: %.1f/s\n" % stats["attack_speed"]
	info += "Sell value: %dg" % tower.get_sell_value()

	if tower.current_level < tower.tower_data.max_level:
		var upgrade_cost: int = tower.tower_data.get_upgrade_cost(tower.current_level)
		info += "\nUpgrade cost: %dg" % upgrade_cost
		upgrade_button.visible = true
		upgrade_button.disabled = not GameState.can_afford(upgrade_cost)
	else:
		info += "\nMAX LEVEL"
		upgrade_button.visible = false

	tower_info_label.text = info
	tower_info_panel.visible = true


func _create_label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	return label


# Signal handlers
func _on_gold_changed(amount: int) -> void:
	gold_label.text = "Gold: %d" % amount

func _on_lives_changed(amount: int) -> void:
	lives_label.text = "Lives: %d" % amount

func _on_wave_started(wave: int) -> void:
	wave_label.text = "Wave: %d/%d" % [wave, GameState.MAX_WAVES]
	start_wave_button.disabled = true
	start_wave_button.text = "In Progress..."

func _on_wave_completed(_wave: int, _bonus: int) -> void:
	start_wave_button.disabled = false
	start_wave_button.text = "Next Wave"

func _on_enemies_remaining(count: int) -> void:
	enemies_label.text = "Enemies: %d" % count

func _on_game_over() -> void:
	game_end_panel.visible = true
	game_end_label.text = "DEFEAT"
	game_end_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

func _on_game_won() -> void:
	game_end_panel.visible = true
	game_end_label.text = "VICTORY!"
	game_end_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))

func _on_tower_selected(tower: Node3D) -> void:
	if tower is TowerController:
		show_tower_info(tower)

func _on_tower_deselected() -> void:
	tower_info_panel.visible = false

func _on_ability_cooldown_updated(index: int, remaining: float, total: float) -> void:
	if index < ability_panel.get_child_count():
		var btn: Button = ability_panel.get_child(index)
		if remaining > 0:
			btn.text = "%.0fs" % remaining
			btn.disabled = true
		else:
			btn.text = "Ready"
			btn.disabled = false
