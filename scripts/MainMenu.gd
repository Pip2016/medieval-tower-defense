extends Control
class_name MainMenu

## Hauptmenü des Spiels.
## Bietet Optionen zum Starten des Spiels und zeigt den Titel an.

var title_label: Label
var start_button: Button
var quit_button: Button
var version_label: Label
var background: ColorRect


func _ready() -> void:
	_create_background()
	_create_ui()


## Erstellt den Hintergrund
func _create_background() -> void:
	background = ColorRect.new()
	background.color = Color(0.15, 0.2, 0.1, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Dekorative Elemente
	for i in range(20):
		var decor := ColorRect.new()
		decor.size = Vector2(randi_range(20, 80), randi_range(20, 80))
		decor.position = Vector2(randi_range(0, 1080), randi_range(0, 1920))
		decor.color = Color(
			randf_range(0.1, 0.3),
			randf_range(0.2, 0.4),
			randf_range(0.05, 0.2),
			0.3
		)
		add_child(decor)


## Erstellt die Menü-Elemente
func _create_ui() -> void:
	# Titel
	title_label = Label.new()
	title_label.text = "Medieval\nTower Defense"
	title_label.position = Vector2(140, 300)
	title_label.size = Vector2(800, 300)
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(title_label)

	# Untertitel
	var subtitle := Label.new()
	subtitle.text = "Verteidige dein Königreich!"
	subtitle.position = Vector2(240, 600)
	subtitle.size = Vector2(600, 60)
	subtitle.add_theme_font_size_override("font_size", 28)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)

	# Spiel starten Button
	start_button = Button.new()
	start_button.text = "Spiel starten"
	start_button.position = Vector2(340, 850)
	start_button.size = Vector2(400, 100)
	start_button.add_theme_font_size_override("font_size", 36)

	var start_style := StyleBoxFlat.new()
	start_style.bg_color = Color(0.2, 0.5, 0.15)
	start_style.corner_radius_top_left = 12
	start_style.corner_radius_top_right = 12
	start_style.corner_radius_bottom_left = 12
	start_style.corner_radius_bottom_right = 12
	start_button.add_theme_stylebox_override("normal", start_style)

	var start_hover := StyleBoxFlat.new()
	start_hover.bg_color = Color(0.3, 0.6, 0.25)
	start_hover.corner_radius_top_left = 12
	start_hover.corner_radius_top_right = 12
	start_hover.corner_radius_bottom_left = 12
	start_hover.corner_radius_bottom_right = 12
	start_button.add_theme_stylebox_override("hover", start_hover)

	start_button.pressed.connect(_on_start_pressed)
	add_child(start_button)

	# Beenden Button
	quit_button = Button.new()
	quit_button.text = "Beenden"
	quit_button.position = Vector2(390, 1000)
	quit_button.size = Vector2(300, 80)
	quit_button.add_theme_font_size_override("font_size", 28)

	var quit_style := StyleBoxFlat.new()
	quit_style.bg_color = Color(0.5, 0.15, 0.15)
	quit_style.corner_radius_top_left = 12
	quit_style.corner_radius_top_right = 12
	quit_style.corner_radius_bottom_left = 12
	quit_style.corner_radius_bottom_right = 12
	quit_button.add_theme_stylebox_override("normal", quit_style)

	var quit_hover := StyleBoxFlat.new()
	quit_hover.bg_color = Color(0.6, 0.25, 0.25)
	quit_hover.corner_radius_top_left = 12
	quit_hover.corner_radius_top_right = 12
	quit_hover.corner_radius_bottom_left = 12
	quit_hover.corner_radius_bottom_right = 12
	quit_button.add_theme_stylebox_override("hover", quit_hover)

	quit_button.pressed.connect(_on_quit_pressed)
	add_child(quit_button)

	# Versions-Anzeige
	version_label = Label.new()
	version_label.text = "v1.0 - Medieval Tower Defense"
	version_label.position = Vector2(340, 1800)
	version_label.size = Vector2(400, 40)
	version_label.add_theme_font_size_override("font_size", 18)
	version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(version_label)


## Spiel starten - Wechselt zur Hauptspielszene
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")


## Spiel beenden
func _on_quit_pressed() -> void:
	get_tree().quit()
