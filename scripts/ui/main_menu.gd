extends Control

## Main menu scene with title, start, and quit buttons.


func _ready() -> void:
	_create_ui()


func _create_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.15, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative elements
	for i in range(30):
		var decor := ColorRect.new()
		decor.size = Vector2(randi_range(30, 100), randi_range(30, 100))
		decor.position = Vector2(randi_range(0, 1920), randi_range(0, 1080))
		decor.color = Color(
			randf_range(0.08, 0.2),
			randf_range(0.15, 0.3),
			randf_range(0.05, 0.15),
			0.25
		)
		add_child(decor)

	# Title
	var title := Label.new()
	title.text = "Tower Defense\nEnterprise Edition"
	title.position = Vector2(460, 150)
	title.size = Vector2(1000, 250)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Resource-Based Data-Driven Architecture | Godot 4.2+"
	subtitle.position = Vector2(460, 400)
	subtitle.size = Vector2(1000, 50)
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)

	# Start button
	var start_btn := Button.new()
	start_btn.text = "Start Game"
	start_btn.position = Vector2(760, 550)
	start_btn.size = Vector2(400, 90)
	start_btn.add_theme_font_size_override("font_size", 32)
	var start_style := StyleBoxFlat.new()
	start_style.bg_color = Color(0.15, 0.45, 0.15)
	start_style.set_corner_radius_all(12)
	start_btn.add_theme_stylebox_override("normal", start_style)
	var start_hover := StyleBoxFlat.new()
	start_hover.bg_color = Color(0.25, 0.55, 0.25)
	start_hover.set_corner_radius_all(12)
	start_btn.add_theme_stylebox_override("hover", start_hover)
	start_btn.pressed.connect(_on_start_pressed)
	add_child(start_btn)

	# Quit button
	var quit_btn := Button.new()
	quit_btn.text = "Quit"
	quit_btn.position = Vector2(810, 670)
	quit_btn.size = Vector2(300, 70)
	quit_btn.add_theme_font_size_override("font_size", 24)
	var quit_style := StyleBoxFlat.new()
	quit_style.bg_color = Color(0.45, 0.12, 0.12)
	quit_style.set_corner_radius_all(12)
	quit_btn.add_theme_stylebox_override("normal", quit_style)
	quit_btn.pressed.connect(func(): get_tree().quit())
	add_child(quit_btn)

	# Feature list
	var features := Label.new()
	features.text = "Features:\n• 3D Procedural Visuals\n• 4 Tower Types with Upgrades\n• Hero Abilities System\n• 15 Progressive Waves\n• Multi-Platform (PC, Mobile, Console)"
	features.position = Vector2(660, 790)
	features.size = Vector2(600, 250)
	features.add_theme_font_size_override("font_size", 18)
	features.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	features.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(features)

	# Version
	var version := Label.new()
	version.text = "v1.0 | Godot 4.2+ | Enterprise Edition"
	version.position = Vector2(660, 1040)
	version.size = Vector2(600, 30)
	version.add_theme_font_size_override("font_size", 14)
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(version)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameLevel.tscn")
