extends BaseUIComponent
class_name SettingsUI

## Settings UI component
## Handles game settings and configuration

# UI elements
var _settings_container: VBoxContainer = null
var _ui_scale_slider: HSlider = null
var _ui_scale_label: Label = null
var _animation_speed_slider: HSlider = null
var _animation_speed_label: Label = null
var _sound_enabled_checkbox: CheckBox = null
var _music_enabled_checkbox: CheckBox = null
var _auto_save_checkbox: CheckBox = null
var _debug_mode_checkbox: CheckBox = null

func _init():
	_component_id = "SettingsUI"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()

## Create UI layout
func _create_ui_layout() -> void:
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.offset_top = 60  # Account for navigation bar
	main_container.offset_left = 50
	main_container.offset_right = -50
	main_container.offset_bottom = -50
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "Game Settings"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title)
	
	# Settings container
	_settings_container = VBoxContainer.new()
	_settings_container.custom_minimum_size = Vector2(0, 400)
	main_container.add_child(_settings_container)
	
	# Create settings sections
	_create_ui_settings_section()
	_create_audio_settings_section()
	_create_game_settings_section()

## Create UI settings section
func _create_ui_settings_section() -> void:
	var section = _create_settings_section("UI Settings")
	_settings_container.add_child(section)
	
	# UI Scale
	var ui_scale_container = HBoxContainer.new()
	section.add_child(ui_scale_container)
	
	var ui_scale_label = Label.new()
	ui_scale_label.text = "UI Scale:"
	ui_scale_label.custom_minimum_size = Vector2(150, 0)
	ui_scale_container.add_child(ui_scale_label)
	
	_ui_scale_slider = HSlider.new()
	_ui_scale_slider.min_value = 0.5
	_ui_scale_slider.max_value = 2.0
	_ui_scale_slider.step = 0.1
	_ui_scale_slider.value = 1.0
	_ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	ui_scale_container.add_child(_ui_scale_slider)
	
	_ui_scale_label = Label.new()
	_ui_scale_label.text = "1.0"
	_ui_scale_label.custom_minimum_size = Vector2(50, 0)
	ui_scale_container.add_child(_ui_scale_label)
	
	# Animation Speed
	var animation_speed_container = HBoxContainer.new()
	section.add_child(animation_speed_container)
	
	var animation_speed_label = Label.new()
	animation_speed_label.text = "Animation Speed:"
	animation_speed_label.custom_minimum_size = Vector2(150, 0)
	animation_speed_container.add_child(animation_speed_label)
	
	_animation_speed_slider = HSlider.new()
	_animation_speed_slider.min_value = 0.1
	_animation_speed_slider.max_value = 3.0
	_animation_speed_slider.step = 0.1
	_animation_speed_slider.value = 1.0
	_animation_speed_slider.value_changed.connect(_on_animation_speed_changed)
	animation_speed_container.add_child(_animation_speed_slider)
	
	_animation_speed_label = Label.new()
	_animation_speed_label.text = "1.0"
	_animation_speed_label.custom_minimum_size = Vector2(50, 0)
	animation_speed_container.add_child(_animation_speed_label)

## Create audio settings section
func _create_audio_settings_section() -> void:
	var section = _create_settings_section("Audio Settings")
	_settings_container.add_child(section)
	
	# Sound enabled
	var sound_container = HBoxContainer.new()
	section.add_child(sound_container)
	
	var sound_label = Label.new()
	sound_label.text = "Sound Effects:"
	sound_label.custom_minimum_size = Vector2(150, 0)
	sound_container.add_child(sound_label)
	
	_sound_enabled_checkbox = CheckBox.new()
	_sound_enabled_checkbox.text = "Enabled"
	_sound_enabled_checkbox.button_pressed = true
	_sound_enabled_checkbox.toggled.connect(_on_sound_enabled_toggled)
	sound_container.add_child(_sound_enabled_checkbox)
	
	# Music enabled
	var music_container = HBoxContainer.new()
	section.add_child(music_container)
	
	var music_label = Label.new()
	music_label.text = "Background Music:"
	music_label.custom_minimum_size = Vector2(150, 0)
	music_container.add_child(music_label)
	
	_music_enabled_checkbox = CheckBox.new()
	_music_enabled_checkbox.text = "Enabled"
	_music_enabled_checkbox.button_pressed = true
	_music_enabled_checkbox.toggled.connect(_on_music_enabled_toggled)
	music_container.add_child(_music_enabled_checkbox)

## Create game settings section
func _create_game_settings_section() -> void:
	var section = _create_settings_section("Game Settings")
	_settings_container.add_child(section)
	
	# Auto save
	var auto_save_container = HBoxContainer.new()
	section.add_child(auto_save_container)
	
	var auto_save_label = Label.new()
	auto_save_label.text = "Auto Save:"
	auto_save_label.custom_minimum_size = Vector2(150, 0)
	auto_save_container.add_child(auto_save_label)
	
	_auto_save_checkbox = CheckBox.new()
	_auto_save_checkbox.text = "Enabled"
	_auto_save_checkbox.button_pressed = true
	_auto_save_checkbox.toggled.connect(_on_auto_save_toggled)
	auto_save_container.add_child(_auto_save_checkbox)
	
	# Debug mode
	var debug_container = HBoxContainer.new()
	section.add_child(debug_container)
	
	var debug_label = Label.new()
	debug_label.text = "Debug Mode:"
	debug_label.custom_minimum_size = Vector2(150, 0)
	debug_container.add_child(debug_label)
	
	_debug_mode_checkbox = CheckBox.new()
	_debug_mode_checkbox.text = "Enabled"
	_debug_mode_checkbox.button_pressed = false
	_debug_mode_checkbox.toggled.connect(_on_debug_mode_toggled)
	debug_container.add_child(_debug_mode_checkbox)

## Create settings section
func _create_settings_section(title: String) -> Control:
	var section = Panel.new()
	section.custom_minimum_size = Vector2(0, 120)
	
	# Style section
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.8, 0.8, 0.8)
	section.add_theme_stylebox_override("panel", style)
	
	# Create container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.offset_left = 15
	container.offset_top = 15
	container.offset_right = -15
	container.offset_bottom = -15
	section.add_child(container)
	
	# Section title
	var section_title = Label.new()
	section_title.text = title
	section_title.add_theme_font_size_override("font_size", 18)
	section_title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	container.add_child(section_title)
	
	return section

## Handle initialization
func _on_initialized() -> void:
	super._on_initialized()
	_load_settings()

## Load settings from GameConfig
func _load_settings() -> void:
	if not GameConfig:
		return
	
	# Load UI settings
	var ui_scale = GameConfig.get_data("ui_scale")
	if ui_scale != null:
		_ui_scale_slider.value = ui_scale
		_ui_scale_label.text = "%.1f" % ui_scale
	
	var animation_speed = GameConfig.get_data("ui_animation_speed")
	if animation_speed != null:
		_animation_speed_slider.value = animation_speed
		_animation_speed_label.text = "%.1f" % animation_speed
	
	# Load audio settings
	var sound_enabled = GameConfig.get_data("sound_enabled")
	if sound_enabled != null:
		_sound_enabled_checkbox.button_pressed = sound_enabled
	
	var music_enabled = GameConfig.get_data("music_enabled")
	if music_enabled != null:
		_music_enabled_checkbox.button_pressed = music_enabled
	
	# Load game settings
	var auto_save_enabled = GameConfig.get_data("auto_save_enabled")
	if auto_save_enabled != null:
		_auto_save_checkbox.button_pressed = auto_save_enabled
	
	var debug_mode = GameConfig.get_data("debug_mode")
	if debug_mode != null:
		_debug_mode_checkbox.button_pressed = debug_mode

## Save settings to GameConfig
func _save_settings() -> void:
	if not GameConfig:
		return
	
	# Save UI settings
	GameConfig.set_data("ui_scale", _ui_scale_slider.value)
	GameConfig.set_data("ui_animation_speed", _animation_speed_slider.value)
	
	# Save audio settings
	GameConfig.set_data("sound_enabled", _sound_enabled_checkbox.button_pressed)
	GameConfig.set_data("music_enabled", _music_enabled_checkbox.button_pressed)
	
	# Save game settings
	GameConfig.set_data("auto_save_enabled", _auto_save_checkbox.button_pressed)
	GameConfig.set_data("debug_mode", _debug_mode_checkbox.button_pressed)

## Event handlers
func _on_ui_scale_changed(value: float) -> void:
	_ui_scale_label.text = "%.1f" % value
	_save_settings()
	
	# Apply UI scale immediately
	if UIManager:
		UIManager.set_ui_scale(value)

func _on_animation_speed_changed(value: float) -> void:
	_animation_speed_label.text = "%.1f" % value
	_save_settings()
	
	# Apply animation speed immediately
	if UIManager:
		UIManager.set_animation_speed(value)

func _on_sound_enabled_toggled(_enabled: bool) -> void:
	_save_settings()

func _on_music_enabled_toggled(_enabled: bool) -> void:
	_save_settings()

func _on_auto_save_toggled(_enabled: bool) -> void:
	_save_settings()

func _on_debug_mode_toggled(_enabled: bool) -> void:
	_save_settings()

## Update component
func update_component() -> void:
	super.update_component()
	_load_settings()

## Refresh component data
func refresh() -> void:
	super.refresh()
	_load_settings()
