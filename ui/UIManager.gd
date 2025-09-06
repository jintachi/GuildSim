extends Node

## Centralized UI management system
## Handles UI initialization, navigation, and state management

signal ui_initialized
signal navigated_to_screen(screen_name: String)
signal ui_error(error_message: String)

# UI state
var _is_initialized: bool = false
var _current_screen: String = "main"
var _screen_history: Array[String] = []

# ViewModels
var _character_view_model: CharacterViewModel
var _quest_view_model: QuestViewModel
var _guild_view_model: GuildViewModel

# UI components
@export var _main_interface: Control
@export var _navigation_bar: Control
@export var _character_ui: CharacterUI
@export var _quest_ui: QuestUI
@export var _guild_ui: GuildUI
@export var _map_ui: Control
@export var _settings_ui: SettingsUI

# UI settings
var _ui_scale: float = 1.0
var _animation_speed: float = 1.0
var _tooltip_delay: float = 0.5

# Navigation
var _max_navigation_depth: int = 10

func _ready():
	# Set as autoload singleton
	name = "UIManager"
	set_process_input(true)
	# Removed set_process_unhandled_input(true) - not needed for simple navigation
	
	# Wait for other systems to initialize
	await get_tree().process_frame
	_initialize_ui()

## Initialize the UI system
func _initialize_ui() -> void:
	if _is_initialized:
		return
	
	log_info("Initializing UI system...")
	
	# Wait for ServiceManager to be ready
	if not ServiceManager or not ServiceManager.is_initialized():
		await ServiceManager.services_initialized
	
	# Initialize ViewModels
	_initialize_view_models()
	
	# Load UI settings
	_load_ui_settings()
	
	# Create main interface
	_create_main_interface()
	
	# Setup event subscriptions
	_setup_event_subscriptions()
	
	_is_initialized = true
	ui_initialized.emit()
	log_info("UI system initialized successfully")

## Initialize ViewModels
func _initialize_view_models() -> void:
	log_info("Initializing ViewModels...")
	
	# Create ViewModels
	_character_view_model = CharacterViewModel.new()
	_quest_view_model = QuestViewModel.new()
	_guild_view_model = GuildViewModel.new()
	
	# Initialize ViewModels
	_character_view_model.initialize(EventBus)
	_quest_view_model.initialize(EventBus)
	_guild_view_model.initialize(EventBus)
	
	# Setup event handling
	_setup_navigation_events()
	
	log_info("ViewModels initialized")

## Setup navigation event handling (simplified)
func _setup_navigation_events() -> void:
	# Simple navigation doesn't need complex event handling
	pass

## Handle navigation tree toggle (removed - using simple navigation)
func _on_navigation_tree_toggle(_event: BaseEvent) -> void:
	# Navigation tree removed - using simple navigation bar instead
	pass

## Handle navigation close
func _on_navigation_close(_event: BaseEvent) -> void:
	# Hide navigation components
	if _navigation_bar:
		_navigation_bar.visible = false
	
	# Show main game UI
	_show_main_game_ui()
	log_info("Navigation closed, showing main game UI")

## Show main game UI
func _show_main_game_ui() -> void:
	# Show the main game interface (character, quest, guild UIs)
	if _character_ui:
		_character_ui.visible = true
	if _quest_ui:
		_quest_ui.visible = true
	if _guild_ui:
		_guild_ui.visible = true
	
	# Set default screen to character management
	# Try navigation first, fallback to direct UI show if navigation fails
	var navigation_success = navigate_to("characters")
	if not navigation_success:
		# Fallback: show character UI directly
		if _character_ui:
			_character_ui.visible = true
			_character_ui.refresh()
		_current_screen = "characters"
		log_info("Fallback: Showing character UI directly")

## Show navigation UI
func show_navigation() -> void:
	# Hide main game UI
	if _character_ui:
		_character_ui.visible = false
	if _quest_ui:
		_quest_ui.visible = false
	if _guild_ui:
		_guild_ui.visible = false
	
	# Show navigation components
	if _navigation_bar:
		_navigation_bar.visible = true
	
	log_info("Navigation shown")

## Check if navigation is currently visible
func is_navigation_visible() -> bool:
	return _navigation_bar != null and _navigation_bar.visible

## Toggle navigation visibility
func toggle_navigation() -> void:
	if is_navigation_visible():
		_on_navigation_close(null)
	else:
		show_navigation()

## Handle input events
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				# Toggle navigation with F1
				toggle_navigation()
			KEY_ESCAPE:
				# Close navigation with Escape
				if is_navigation_visible():
					_on_navigation_close(null)

## Load UI settings
func _load_ui_settings() -> void:
	if GameConfig:
		_ui_scale = GameConfig.get_data("ui_scale")
		_animation_speed = GameConfig.get_data("ui_animation_speed")
		_tooltip_delay = GameConfig.get_data("tooltip_delay")

## Create main interface
func _create_main_interface() -> void:
	log_info("Creating main interface...")
	
	# Check if we're in a test scene - don't create main interface if so
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "TestScene":
		log_info("Test scene detected - skipping main interface creation")
		return
	
	# Load the MainUI scene
	var main_ui_scene = preload("res://ui/MainUI.tscn")
	_main_interface = main_ui_scene.instantiate()
	_main_interface.name = "MainInterface"
	
	# Add to scene tree
	get_tree().root.add_child(_main_interface)
	
	# Load and instantiate UI component scenes
	_load_ui_components()
	
	# Initialize UI components
	_initialize_ui_components()
		
	log_info("Main interface created")

## Load and instantiate UI component scenes
func _load_ui_components() -> void:
	log_info("Loading UI component scenes...")
	
	# Find placeholder nodes in MainInterface
	var navigation_bar_placeholder = _main_interface.find_child("NavigationBar", true, false)
	var navigation_tree_placeholder = _main_interface.find_child("NavigationTree", true, false)
	var character_ui_placeholder = _main_interface.find_child("CharacterUI", true, false)
	var quest_ui_placeholder = _main_interface.find_child("QuestUI", true, false)
	var guild_ui_placeholder = _main_interface.find_child("GuildUI", true, false)
	var settings_ui_placeholder = _main_interface.find_child("SettingsUI", true, false)
	
	log_info("Found placeholders - NavigationBar: %s, NavigationTree: %s, CharacterUI: %s, QuestUI: %s, GuildUI: %s, SettingsUI: %s" % [
		navigation_bar_placeholder != null,
		navigation_tree_placeholder != null,
		character_ui_placeholder != null,
		quest_ui_placeholder != null,
		guild_ui_placeholder != null,
		settings_ui_placeholder != null
	])
	
	# Load and instantiate NavigationBar
	if navigation_bar_placeholder:
		log_info("Loading NavigationBar...")
		var navigation_bar_scene = preload("res://ui/components/NavigationBar.tscn")
		log_info("NavigationBar scene preloaded")
		_navigation_bar = navigation_bar_scene.instantiate()
		log_info("NavigationBar instantiated")
		_navigation_bar.name = "NavigationBar"
		# Copy transform and visibility from placeholder
		_navigation_bar.position = navigation_bar_placeholder.position
		_navigation_bar.size = navigation_bar_placeholder.size
		_navigation_bar.visible = navigation_bar_placeholder.visible
		# Replace placeholder with actual component
		navigation_bar_placeholder.get_parent().add_child(_navigation_bar)
		log_info("NavigationBar added to scene tree")
		navigation_bar_placeholder.queue_free()
		log_info("NavigationBar placeholder queued for deletion")
	
	# NavigationTree removed - using simple navigation bar instead
	if navigation_tree_placeholder:
		navigation_tree_placeholder.queue_free()
	
	# Load and instantiate CharacterUI
	if character_ui_placeholder:
		var character_ui_scene = preload("res://ui/components/CharacterUI.tscn")
		_character_ui = character_ui_scene.instantiate()
		_character_ui.name = "CharacterUI"
		# Copy transform and visibility from placeholder
		_character_ui.position = character_ui_placeholder.position
		_character_ui.size = character_ui_placeholder.size
		_character_ui.visible = character_ui_placeholder.visible
		# Replace placeholder with actual component
		character_ui_placeholder.get_parent().add_child(_character_ui)
		character_ui_placeholder.queue_free()
	
	# Load and instantiate QuestUI
	if quest_ui_placeholder:
		var quest_ui_scene = preload("res://ui/components/QuestUI.tscn")
		_quest_ui = quest_ui_scene.instantiate()
		_quest_ui.name = "QuestUI"
		# Copy transform and visibility from placeholder
		_quest_ui.position = quest_ui_placeholder.position
		_quest_ui.size = quest_ui_placeholder.size
		_quest_ui.visible = quest_ui_placeholder.visible
		# Replace placeholder with actual component
		quest_ui_placeholder.get_parent().add_child(_quest_ui)
		quest_ui_placeholder.queue_free()
	
	# Load and instantiate GuildUI
	if guild_ui_placeholder:
		var guild_ui_scene = preload("res://ui/components/GuildUI.tscn")
		_guild_ui = guild_ui_scene.instantiate()
		_guild_ui.name = "GuildUI"
		# Copy transform and visibility from placeholder
		_guild_ui.position = guild_ui_placeholder.position
		_guild_ui.size = guild_ui_placeholder.size
		_guild_ui.visible = guild_ui_placeholder.visible
		# Replace placeholder with actual component
		guild_ui_placeholder.get_parent().add_child(_guild_ui)
		guild_ui_placeholder.queue_free()
	
	# Load and instantiate SettingsUI
	if settings_ui_placeholder:
		var settings_ui_scene = preload("res://ui/components/SettingsUI.tscn")
		_settings_ui = settings_ui_scene.instantiate()
		_settings_ui.name = "SettingsUI"
		# Copy transform and visibility from placeholder
		_settings_ui.position = settings_ui_placeholder.position
		_settings_ui.size = settings_ui_placeholder.size
		_settings_ui.visible = settings_ui_placeholder.visible
		# Replace placeholder with actual component
		settings_ui_placeholder.get_parent().add_child(_settings_ui)
		settings_ui_placeholder.queue_free()
	
	log_info("UI component scenes loaded successfully")

## Initialize UI components
func _initialize_ui_components() -> void:
	# Initialize navigation components
	if _navigation_bar:
		_navigation_bar.initialize(EventBus, null)
	
	# Initialize UI components
	if _character_ui:
		_character_ui.initialize(EventBus, _character_view_model)
		_character_ui.visible = false
	if _quest_ui:
		_quest_ui.initialize(EventBus, _quest_view_model)
		_quest_ui.visible = false
	if _guild_ui:
		_guild_ui.initialize(EventBus, _guild_view_model)
		_guild_ui.visible = false
	if _settings_ui:
		_settings_ui.visible = false


## Setup event subscriptions
func _setup_event_subscriptions() -> void:
	_subscribe_to_event("ui_navigate_to", _on_ui_navigate_to)
	_subscribe_to_event("ui_show_notification", _on_ui_show_notification)
	_subscribe_to_event("ui_show_dialog", _on_ui_show_dialog)

## Navigate to a screen
func navigate_to(screen_name: String) -> bool:
	if not _is_initialized:
		log_error("UI not initialized, cannot navigate")
		return false
	
	log_info("Navigating to screen: " + screen_name)
	
	# Simple navigation - no complex navigation service needed
	if _current_screen != screen_name:
		_screen_history.append(_current_screen)
		
		# Limit history depth
		if _screen_history.size() > _max_navigation_depth:
			_screen_history.pop_front()
	
	# Hide current screen
	_hide_current_screen()
	
	# Show new screen
	_show_screen(screen_name)
	
	_current_screen = screen_name
	navigated_to_screen.emit(screen_name)
	log_info("Successfully navigated to screen: " + screen_name)
	return true

## Hide current screen
func _hide_current_screen() -> void:
	match _current_screen:
		"characters":
			if _character_ui:
				_character_ui.visible = false
		"quests":
			if _quest_ui:
				_quest_ui.visible = false
		"guild":
			if _guild_ui:
				_guild_ui.visible = false
		"settings":
			if _settings_ui:
				_settings_ui.visible = false
		"map":
			if _map_ui:
				_map_ui.visible = false

## Show screen
func _show_screen(screen_name: String) -> void:
	match screen_name:
		"characters":
			if _character_ui:
				_character_ui.visible = true
				_character_ui.refresh()
		"quests":
			if _quest_ui:
				_quest_ui.visible = true
				_quest_ui.refresh()
		"guild":
			if _guild_ui:
				_guild_ui.visible = true
				_guild_ui.refresh()
		"settings":
			if _settings_ui:
				_settings_ui.visible = true
		"map":
			if _map_ui:
				_map_ui.visible = true
				if _map_ui.has_method("refresh"):
					_map_ui.refresh()

## Navigate back
func navigate_back() -> void:
	if _screen_history.size() > 0:
		var previous_screen = _screen_history.pop_back()
		navigate_to(previous_screen)

## Get current screen
func get_current_screen() -> String:
	return _current_screen

## Get screen history
func get_screen_history() -> Array[String]:
	return _screen_history.duplicate()

## Get ViewModel
func get_view_model(view_model_type: String) -> BaseViewModel:
	match view_model_type:
		"character": return _character_view_model
		"quest": return _quest_view_model
		"guild": return _guild_view_model
		_: return null

## Get UI component
func get_ui_component(component_name: String) -> Control:
	match component_name:
		"main_interface": return _main_interface
		"character_ui": return _character_ui
		"quest_ui": return _quest_ui
		"guild_ui": return _guild_ui
		"settings_ui": return _settings_ui
		_: return null

## Set UI scale
func set_ui_scale(scale: float) -> void:
	_ui_scale = max(0.5, min(2.0, scale))
	
	# Apply scale to main interface
	if _main_interface:
		_main_interface.scale = Vector2(_ui_scale, _ui_scale)
	
	# Save setting
	if GameConfig:
		GameConfig.set_data("ui_scale", _ui_scale)

## Initialize UI for demo viewport (called from test scene)
func initialize_ui_for_demo_viewport(demo_viewport: SubViewport) -> void:
	log_info("Initializing UI for demo viewport...")
	
	# Ensure ViewModels are initialized
	if not _character_view_model:
		log_info("Initializing ViewModels for demo viewport...")
		_initialize_view_models()
	
	# Load the MainUI scene
	var main_ui_scene = preload("res://ui/MainUI.tscn")
	_main_interface = main_ui_scene.instantiate()
	_main_interface.name = "MainInterface"
	
	# Add to demo viewport instead of root
	demo_viewport.add_child(_main_interface)
	
	# Make sure the main interface is visible and properly sized
	_main_interface.visible = true
	_main_interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Set a specific size that fits within the demo viewport
	_main_interface.size = Vector2(800, 600)
	_main_interface.position = Vector2.ZERO
	
	log_info("Main interface added to demo viewport and made visible")
	log_info("Main interface size: " + str(_main_interface.size))
	log_info("Main interface position: " + str(_main_interface.position))
	
	# Load and instantiate UI component scenes
	_load_ui_components()
	
	# Initialize UI components
	_initialize_ui_components()
	
	# Debug: Check what components were loaded
	log_info("UI Components loaded:")
	log_info("  NavigationBar: " + str(_navigation_bar != null))
	log_info("  CharacterUI: " + str(_character_ui != null))
	log_info("  QuestUI: " + str(_quest_ui != null))
	log_info("  GuildUI: " + str(_guild_ui != null))
	log_info("  SettingsUI: " + str(_settings_ui != null))
	
	# Show the navigation bar and initial screen
	if _navigation_bar:
		_navigation_bar.visible = true
		log_info("Navigation bar made visible")
	else:
		log_error("Navigation bar not found!")
	
	# Navigate to characters screen as default
	navigate_to("characters")
	
	log_info("UI initialized for demo viewport")

## Get UI scale
func get_ui_scale() -> float:
	return _ui_scale

## Set animation speed
func set_animation_speed(speed: float) -> void:
	_animation_speed = max(0.1, min(3.0, speed))
	
	# Save setting
	if GameConfig:
		GameConfig.set_data("ui_animation_speed", _animation_speed)

## Get animation speed
func get_animation_speed() -> float:
	return _animation_speed

## Show notification
func show_notification(message: String, duration: float = 5.0) -> void:
	# Create notification UI
	var notification_ui = _create_notification(message, duration)
	_main_interface.add_child(notification_ui)
	
	# Animate notification
	_animate_notification(notification_ui)

## Create notification
func _create_notification(message: String, duration: float) -> Control:
	var notification_panel = Panel.new()
	notification_panel.name = "Notification"
	notification_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	notification_panel.offset_left = -300
	notification_panel.offset_top = 10
	notification_panel.offset_right = -10
	notification_panel.offset_bottom = 60
	
	# Style notification
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.8, 0.2, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	notification_panel.add_theme_stylebox_override("panel", style)
	
	# Add message label
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 10
	label.offset_top = 10
	label.offset_right = -10
	label.offset_bottom = -10
	notification_panel.add_child(label)
	
	# Auto-remove after duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_remove_notification.bind(notification_panel))
	notification_panel.add_child(timer)
	timer.start()
	
	return notification_panel

## Animate notification
func _animate_notification(notification_control: Control) -> void:
	notification_control.modulate.a = 0.0
	notification_control.position.x += 300
	
	var tween = create_tween()
	tween.parallel().tween_property(notification_control, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(notification_control, "position:x", notification_control.position.x - 300, 0.3)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

## Remove notification
func _remove_notification(notification_control: Control) -> void:
	var tween = create_tween()
	tween.parallel().tween_property(notification_control, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(notification_control, "position:x", notification_control.position.x + 300, 0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(notification_control.queue_free)

## Subscribe to an event
func _subscribe_to_event(event_type: String, callback: Callable) -> void:
	if EventBus:
		EventBus.subscribe(event_type, callback)

## Unsubscribe from an event
func _unsubscribe_from_event(event_type: String, callback: Callable) -> void:
	if EventBus:
		EventBus.unsubscribe(event_type, callback)

## Event handlers
func _on_navigation_button_pressed(screen_name: String) -> void:
	navigate_to(screen_name)

func _on_ui_navigate_to(event: BaseEvent) -> void:
	var screen_name = event.data.get("screen_name", "")
	if screen_name:
		navigate_to(screen_name)

func _on_ui_show_notification(event: BaseEvent) -> void:
	var message = event.data.get("message", "")
	var duration = event.data.get("duration", 5.0)
	if message:
		show_notification(message, duration)

func _on_ui_show_dialog(_event: BaseEvent) -> void:
	# Handle dialog display
	pass

## Get UI statistics
func get_ui_statistics() -> Dictionary:
	return {
		"is_initialized": _is_initialized,
		"current_screen": _current_screen,
		"screen_history_size": _screen_history.size(),
		"ui_scale": _ui_scale,
		"animation_speed": _animation_speed,
		"tooltip_delay": _tooltip_delay,
		"viewmodels_initialized": {
			"character": _character_view_model != null,
			"quest": _quest_view_model != null,
			"guild": _guild_view_model != null
		}
	}

## Clean up UI
func cleanup() -> void:
	# Clean up ViewModels
	if _character_view_model:
		_character_view_model.cleanup()
	if _quest_view_model:
		_quest_view_model.cleanup()
	if _guild_view_model:
		_guild_view_model.cleanup()
	
	# Clean up UI components
	if _main_interface:
		_main_interface.queue_free()
	
	_is_initialized = false

## Get navigation view model (removed - using simple navigation)
func get_navigation_view_model() -> BaseViewModel:
	return null

## Logging functions
func log_info(message: String) -> void:
	print("[UIManager] " + message)

func log_warning(message: String) -> void:
	push_warning("[UIManager] " + message)

func log_error(message: String) -> void:
	push_error("[UIManager] " + message)
	ui_error.emit(message)
