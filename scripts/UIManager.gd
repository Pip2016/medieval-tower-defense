extends CanvasLayer
class_name UIManager

## UI-Manager - Verwaltet alle Benutzeroberflächen-Elemente.
## Zeigt Gold, Gesundheit, Welle und Turm-Auswahl an.

# UI-Referenzen
var gold_label: Label
var health_label: Label
var wave_label: Label
var start_wave_button: Button
var tower_panel: HBoxContainer
var game_end_panel: Panel
var game_end_label: Label
var restart_button: Button

# Referenz zum GameManager
var game_manager: GameManager

# Signale
signal tower_selected(type: Tower.TowerType)
signal start_wave_pressed()
signal restart_pressed()


func _ready() -> void:
	_create_ui()


## Verbindet den UI-Manager mit dem GameManager
func connect_to_game_manager(gm: GameManager) -> void:
	game_manager = gm
	game_manager.gold_changed.connect(_on_gold_changed)
	game_manager.health_changed.connect(_on_health_changed)
	game_manager.wave_changed.connect(_on_wave_changed)
	game_manager.game_over.connect(_on_game_over)
	game_manager.game_won.connect(_on_game_won)
	game_manager.wave_completed.connect(_on_wave_completed)


## Erstellt die gesamte UI
func _create_ui() -> void:
	# Obere Leiste
	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(10, 10)
	top_bar.size = Vector2(1060, 50)
	top_bar.add_theme_constant_override("separation", 20)
	add_child(top_bar)

	# Gold-Anzeige
	gold_label = Label.new()
	gold_label.text = "Gold: 200"
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	top_bar.add_child(gold_label)

	# Gesundheits-Anzeige
	health_label = Label.new()
	health_label.text = "Leben: 20"
	health_label.add_theme_font_size_override("font_size", 28)
	health_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	top_bar.add_child(health_label)

	# Wellen-Anzeige
	wave_label = Label.new()
	wave_label.text = "Welle: 0/10"
	wave_label.add_theme_font_size_override("font_size", 28)
	wave_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	top_bar.add_child(wave_label)

	# Turm-Auswahl Panel
	tower_panel = HBoxContainer.new()
	tower_panel.position = Vector2(10, 1800)
	tower_panel.size = Vector2(1060, 100)
	tower_panel.add_theme_constant_override("separation", 10)
	add_child(tower_panel)

	# Turm-Buttons erstellen
	_create_tower_button("Bogen\n100g", Tower.TowerType.ARCHER, Color(0.2, 0.6, 0.2))
	_create_tower_button("Magier\n150g", Tower.TowerType.MAGE, Color(0.3, 0.2, 0.7))
	_create_tower_button("Kanone\n200g", Tower.TowerType.CANNON, Color(0.5, 0.5, 0.5))
	_create_tower_button("Kaserne\n120g", Tower.TowerType.BARRACKS, Color(0.6, 0.5, 0.2))

	# Welle starten Button
	start_wave_button = Button.new()
	start_wave_button.text = "Welle starten!"
	start_wave_button.position = Vector2(350, 1730)
	start_wave_button.size = Vector2(380, 60)
	start_wave_button.add_theme_font_size_override("font_size", 24)
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	add_child(start_wave_button)

	# Spielende Panel (versteckt)
	game_end_panel = Panel.new()
	game_end_panel.position = Vector2(190, 700)
	game_end_panel.size = Vector2(700, 400)
	game_end_panel.visible = false
	add_child(game_end_panel)

	game_end_label = Label.new()
	game_end_label.text = ""
	game_end_label.position = Vector2(100, 50)
	game_end_label.size = Vector2(500, 150)
	game_end_label.add_theme_font_size_override("font_size", 48)
	game_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_end_panel.add_child(game_end_label)

	restart_button = Button.new()
	restart_button.text = "Neues Spiel"
	restart_button.position = Vector2(200, 250)
	restart_button.size = Vector2(300, 80)
	restart_button.add_theme_font_size_override("font_size", 28)
	restart_button.pressed.connect(_on_restart_pressed)
	game_end_panel.add_child(restart_button)


## Erstellt einen Turm-Auswahl-Button
func _create_tower_button(text: String, type: Tower.TowerType, color: Color) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(250, 90)
	button.add_theme_font_size_override("font_size", 20)

	# Farbigen Hintergrund hinzufügen
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("hover", hover_style)

	button.pressed.connect(func(): tower_selected.emit(type))
	tower_panel.add_child(button)


# Signal-Callbacks
func _on_gold_changed(new_gold: int) -> void:
	gold_label.text = "Gold: %d" % new_gold


func _on_health_changed(new_health: int) -> void:
	health_label.text = "Leben: %d" % new_health


func _on_wave_changed(wave: int, max_waves: int) -> void:
	wave_label.text = "Welle: %d/%d" % [wave, max_waves]


func _on_wave_completed(_wave: int) -> void:
	start_wave_button.visible = true
	start_wave_button.text = "Nächste Welle!"


func _on_game_over() -> void:
	game_end_panel.visible = true
	game_end_label.text = "NIEDERLAGE!"
	game_end_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	start_wave_button.visible = false


func _on_game_won() -> void:
	game_end_panel.visible = true
	game_end_label.text = "SIEG!"
	game_end_label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.2))
	start_wave_button.visible = false


func _on_start_wave_pressed() -> void:
	start_wave_button.visible = false
	start_wave_pressed.emit()


func _on_restart_pressed() -> void:
	restart_pressed.emit()
