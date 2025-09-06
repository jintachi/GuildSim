extends BaseUIComponent
class_name NavigationBar

## Simple Navigation bar component
## Just provides quick travel buttons to main screens

# UI elements
var _characters_button: Button = null
var _quests_button: Button = null
var _guild_button: Button = null
var _map_button: Button = null
var _settings_button: Button = null

func _init():
	_component_id = "NavigationBar"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()

## Create UI layout
func _create_ui_layout() -> void:
	# Find UI elements from the already loaded scene
	_find_ui_elements()

## Find UI elements from the loaded scene
func _find_ui_elements() -> void:
	# Find UI elements by their node paths
	_characters_button = find_child("CharactersButton", true, false)
	_quests_button = find_child("QuestsButton", true, false)
	_guild_button = find_child("GuildButton", true, false)
	_map_button = find_child("MapButton", true, false)
	_settings_button = find_child("SettingsButton", true, false)
	
	# Connect signals
	if _characters_button:
		_characters_button.pressed.connect(_on_characters_button_pressed)
	if _quests_button:
		_quests_button.pressed.connect(_on_quests_button_pressed)
	if _guild_button:
		_guild_button.pressed.connect(_on_guild_button_pressed)
	if _map_button:
		_map_button.pressed.connect(_on_map_button_pressed)
	if _settings_button:
		_settings_button.pressed.connect(_on_settings_button_pressed)


## Update button states (highlight current screen)
func _update_button_states(current_screen: String) -> void:
	# Reset all buttons
	if _characters_button:
		_characters_button.modulate = Color.WHITE
	if _quests_button:
		_quests_button.modulate = Color.WHITE
	if _guild_button:
		_guild_button.modulate = Color.WHITE
	if _map_button:
		_map_button.modulate = Color.WHITE
	if _settings_button:
		_settings_button.modulate = Color.WHITE
	
	# Highlight current screen
	match current_screen:
		"characters":
			if _characters_button:
				_characters_button.modulate = Color.YELLOW
		"quests":
			if _quests_button:
				_quests_button.modulate = Color.YELLOW
		"guild":
			if _guild_button:
				_guild_button.modulate = Color.YELLOW
		"map":
			if _map_button:
				_map_button.modulate = Color.YELLOW
		"settings":
			if _settings_button:
				_settings_button.modulate = Color.YELLOW

## Handle initialization
func _on_initialized() -> void:
	# Simple initialization - no complex ViewModel needed
	super._on_initialized()

## Event handlers - simple navigation
func _on_characters_button_pressed() -> void:
	print("[NavigationBar] Characters button pressed")
	_navigate_to_screen("characters")

func _on_quests_button_pressed() -> void:
	print("[NavigationBar] Quests button pressed")
	_navigate_to_screen("quests")

func _on_guild_button_pressed() -> void:
	print("[NavigationBar] Guild button pressed")
	_navigate_to_screen("guild")

func _on_map_button_pressed() -> void:
	print("[NavigationBar] Map button pressed")
	_navigate_to_screen("map")

func _on_settings_button_pressed() -> void:
	print("[NavigationBar] Settings button pressed")
	_navigate_to_screen("settings")

## Navigate to a screen
func _navigate_to_screen(screen_name: String) -> void:
	print("[NavigationBar] Navigating to: " + screen_name)
	
	# Emit simple navigation event
	if _event_bus:
		_event_bus.emit_simple_event("ui_navigate_to", {"screen_name": screen_name}, _component_id)
	
	# Update button states
	_update_button_states(screen_name)
	
	print("[NavigationBar] Navigation complete, button states updated")

## Update component
func update_component() -> void:
	super.update_component()
	# Simple navigation doesn't need complex updates

## Refresh component data
func refresh() -> void:
	super.refresh()
	# Simple navigation doesn't need complex refresh logic
