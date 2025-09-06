extends Node

## Centralized theme management system
## Handles theme loading, application, and customization

signal theme_changed(theme_name: String)

# Theme storage
var _themes: Dictionary = {}
var _current_theme: String = "default"
var _default_theme: Theme

# Theme customization
var _custom_colors: Dictionary = {}
var _custom_fonts: Dictionary = {}
var _custom_styles: Dictionary = {}

# Theme settings
var _ui_scale: float = 1.0
var _color_scheme: String = "light"  # "light", "dark", "auto"
var _font_size_multiplier: float = 1.0

func _ready():
	# Set as autoload singleton
	name = "UIThemeManager"
	
	# Load default theme
	_load_default_theme()
	
	# Load custom themes
	_load_custom_themes()
	
	# Apply initial theme
	_apply_theme(_current_theme)

## Load default theme
func _load_default_theme() -> void:
	_default_theme = Theme.new()
	_setup_default_theme()

## Setup default theme
func _setup_default_theme() -> void:
	# Default colors
	var default_colors = {
		"primary": Color(0.2, 0.4, 0.8, 1.0),
		"secondary": Color(0.6, 0.6, 0.6, 1.0),
		"success": Color(0.2, 0.8, 0.2, 1.0),
		"warning": Color(0.8, 0.6, 0.2, 1.0),
		"error": Color(0.8, 0.2, 0.2, 1.0),
		"background": Color(0.95, 0.95, 0.95, 1.0),
		"surface": Color(1.0, 1.0, 1.0, 1.0),
		"text": Color(0.1, 0.1, 0.1, 1.0),
		"text_secondary": Color(0.4, 0.4, 0.4, 1.0),
		"border": Color(0.8, 0.8, 0.8, 1.0)
	}
	
	# Default fonts
	var default_font = ThemeDB.fallback_font
	var default_font_size = 14
	
	# Apply default colors
	for color_name in default_colors:
		_default_theme.set_color(color_name, "Label", default_colors[color_name])
		_default_theme.set_color(color_name, "Button", default_colors[color_name])
		_default_theme.set_color(color_name, "LineEdit", default_colors[color_name])
	
	# Apply default fonts
	_default_theme.set_font("font", "Label", default_font)
	_default_theme.set_font("font", "Button", default_font)
	_default_theme.set_font("font", "LineEdit", default_font)
	_default_theme.set_font_size("font_size", "Label", default_font_size)
	_default_theme.set_font_size("font_size", "Button", default_font_size)
	_default_theme.set_font_size("font_size", "LineEdit", default_font_size)
	
	# Create default styles
	_create_default_styles()
	
	_themes["default"] = _default_theme

## Create default styles
func _create_default_styles() -> void:
	# Button styles
	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = _default_theme.get_color("primary", "Button")
	button_normal.corner_radius_top_left = 4
	button_normal.corner_radius_top_right = 4
	button_normal.corner_radius_bottom_left = 4
	button_normal.corner_radius_bottom_right = 4
	button_normal.border_width_left = 1
	button_normal.border_width_right = 1
	button_normal.border_width_top = 1
	button_normal.border_width_bottom = 1
	button_normal.border_color = _default_theme.get_color("border", "Button")
	_default_theme.set_stylebox("normal", "Button", button_normal)
	
	var button_hover = StyleBoxFlat.new()
	button_hover.bg_color = _default_theme.get_color("primary", "Button").lightened(0.1)
	button_hover.corner_radius_top_left = 4
	button_hover.corner_radius_top_right = 4
	button_hover.corner_radius_bottom_left = 4
	button_hover.corner_radius_bottom_right = 4
	button_hover.border_width_left = 1
	button_hover.border_width_right = 1
	button_hover.border_width_top = 1
	button_hover.border_width_bottom = 1
	button_hover.border_color = _default_theme.get_color("border", "Button")
	_default_theme.set_stylebox("hover", "Button", button_hover)
	
	var button_pressed = StyleBoxFlat.new()
	button_pressed.bg_color = _default_theme.get_color("primary", "Button").darkened(0.1)
	button_pressed.corner_radius_top_left = 4
	button_pressed.corner_radius_top_right = 4
	button_pressed.corner_radius_bottom_left = 4
	button_pressed.corner_radius_bottom_right = 4
	button_pressed.border_width_left = 1
	button_pressed.border_width_right = 1
	button_pressed.border_width_top = 1
	button_pressed.border_width_bottom = 1
	button_pressed.border_color = _default_theme.get_color("border", "Button")
	_default_theme.set_stylebox("pressed", "Button", button_pressed)
	
	# Panel styles
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = _default_theme.get_color("surface", "Panel")
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = _default_theme.get_color("border", "Panel")
	_default_theme.set_stylebox("panel", "Panel", panel_style)

## Load custom themes
func _load_custom_themes() -> void:
	# Load themes from themes directory
	var themes_dir = "res://ui/themes/"
	if DirAccess.dir_exists_absolute(themes_dir):
		var dir = DirAccess.open(themes_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var theme_path = themes_dir + file_name
					var theme_name = file_name.get_basename()
					
					var theme = load(theme_path)
					if theme and theme is Theme:
						_themes[theme_name] = theme
						print("[UIThemeManager] Loaded theme: %s" % theme_name)
				
				file_name = dir.get_next()

## Apply a theme
func _apply_theme(theme_name: String) -> void:
	if not _themes.has(theme_name):
		push_warning("[UIThemeManager] Theme not found: %s" % theme_name)
		return
	
	var theme = _themes[theme_name]
	
	# Apply theme to all UI components
	_apply_theme_to_scene_tree(get_tree().root, theme)
	
	_current_theme = theme_name
	theme_changed.emit(theme_name)

## Apply theme to scene tree
func _apply_theme_to_scene_tree(node: Node, theme: Theme) -> void:
	if node is Control:
		var control = node as Control
		control.theme = theme
		
		# Apply UI scale
		if _ui_scale != 1.0:
			control.scale = Vector2(_ui_scale, _ui_scale)
	
	# Recursively apply to children
	for child in node.get_children():
		_apply_theme_to_scene_tree(child, theme)

## Get current theme
func get_current_theme() -> String:
	return _current_theme

## Get theme by name
func get_theme(theme_name: String) -> Theme:
	return _themes.get(theme_name, _default_theme)

## Set current theme
func set_theme(theme_name: String) -> void:
	if _themes.has(theme_name):
		_apply_theme(theme_name)
	else:
		push_warning("[UIThemeManager] Theme not found: %s" % theme_name)

## Add custom theme
func add_theme(theme_name: String, theme: Theme) -> void:
	_themes[theme_name] = theme

## Remove theme
func remove_theme(theme_name: String) -> void:
	if theme_name != "default":
		_themes.erase(theme_name)

## Get available themes
func get_available_themes() -> Array[String]:
	return _themes.keys()

## Set UI scale
func set_ui_scale(scale: float) -> void:
	_ui_scale = max(0.5, min(2.0, scale))
	_apply_theme(_current_theme)

## Get UI scale
func get_ui_scale() -> float:
	return _ui_scale

## Set color scheme
func set_color_scheme(scheme: String) -> void:
	_color_scheme = scheme
	_apply_color_scheme()

## Apply color scheme
func _apply_color_scheme() -> void:
	# Override in derived classes for specific color scheme handling
	pass

## Set font size multiplier
func set_font_size_multiplier(multiplier: float) -> void:
	_font_size_multiplier = max(0.5, min(2.0, multiplier))
	_apply_font_size_multiplier()

## Apply font size multiplier
func _apply_font_size_multiplier() -> void:
	# Override in derived classes for specific font size handling
	pass

## Get theme statistics
func get_theme_statistics() -> Dictionary:
	return {
		"current_theme": _current_theme,
		"available_themes": _themes.size(),
		"ui_scale": _ui_scale,
		"color_scheme": _color_scheme,
		"font_size_multiplier": _font_size_multiplier,
		"custom_colors": _custom_colors.size(),
		"custom_fonts": _custom_fonts.size(),
		"custom_styles": _custom_styles.size()
	}

## Create custom color
func create_custom_color(color_name: String, color: Color) -> void:
	_custom_colors[color_name] = color

## Get custom color
func get_custom_color(color_name: String) -> Color:
	return _custom_colors.get(color_name, Color.WHITE)

## Create custom font
func create_custom_font(font_name: String, font: Font) -> void:
	_custom_fonts[font_name] = font

## Get custom font
func get_custom_font(font_name: String) -> Font:
	return _custom_fonts.get(font_name, ThemeDB.fallback_font)

## Create custom style
func create_custom_style(style_name: String, style: StyleBox) -> void:
	_custom_styles[style_name] = style

## Get custom style
func get_custom_style(style_name: String) -> StyleBox:
	return _custom_styles.get(style_name, null)

## Save theme settings
func save_theme_settings() -> void:
	var settings = {
		"current_theme": _current_theme,
		"ui_scale": _ui_scale,
		"color_scheme": _color_scheme,
		"font_size_multiplier": _font_size_multiplier
	}
	
	var file = FileAccess.open("user://ui_theme_settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

## Load theme settings
func load_theme_settings() -> void:
	var file = FileAccess.open("user://ui_theme_settings.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var settings = json.data
			_current_theme = settings.get("current_theme", "default")
			_ui_scale = settings.get("ui_scale", 1.0)
			_color_scheme = settings.get("color_scheme", "light")
			_font_size_multiplier = settings.get("font_size_multiplier", 1.0)
			
			_apply_theme(_current_theme)
