extends Node

## Centralized game configuration system
## Manages all game settings, balance values, and feature flags

signal config_changed(setting_name: String, old_value: Variant, new_value: Variant)

# Game Settings
@export var game_version: String = "1.0.0"
@export var debug_mode: bool = false
@export var auto_save_enabled: bool = true
@export var auto_save_interval: float = 600.0  # 10 minutes
@export var notification_enabled: bool = true
@export var sound_enabled: bool = true
@export var music_enabled: bool = true
@export var ui_scale: float = 1.0

# Character Settings
@export var max_roster_size: int = 5
@export var max_character_level: int = 100
@export var experience_curve_multiplier: float = 1.0
@export var injury_recovery_time_multiplier: float = 1.0

# Quest Settings
@export var max_active_quests: int = 3
@export var quest_duration_multiplier: float = 1.0
@export var quest_reward_multiplier: float = 1.0
@export var quest_failure_penalty_multiplier: float = 1.0

# Guild Settings
@export var starting_gold: int = 50
@export var starting_influence: int = 100
@export var starting_food: int = 20
@export var reputation_per_level: int = 100

# UI Settings
@export var ui_animation_speed: float = 1.0
@export var tooltip_delay: float = 0.5
@export var notification_duration: float = 5.0
@export var auto_close_dialogs: bool = true

# Performance Settings
@export var max_event_history: int = 1000
@export var auto_cleanup_interval: float = 300.0  # 5 minutes
@export var enable_performance_logging: bool = false

# Feature Flags
@export var features: Dictionary = {
	"training_room": true,
	"library": true,
	"workshop": true,
	"armory": true,
	"healers_guild": true,
	"merchants_guild": true,
	"blacksmiths_guild": true,
	"equipment_system": true,
	"inventory_system": true,
	"crafting_system": false,
	"trading_system": false,
	"achievement_system": false,
	"tutorial_system": true
}

# Balance Configuration
@export var balance_config: BalanceConfig = BalanceConfig.new()

func _ready():
	# Set as autoload singleton
	name = "GameConfig"
	
	# Ensure balance config is always initialized
	if not balance_config:
		balance_config = BalanceConfig.new()
	
	# Load settings from file
	load_settings()
	
	# Ensure balance config is still valid after loading settings
	if not balance_config:
		balance_config = BalanceConfig.new()

## Get a setting value
func get_setting(setting_name: String, default_value: Variant = null) -> Variant:
	if has_method("get_data"):
		return get_data(setting_name)
	return default_value

## Set a setting value
func set_setting(setting_name: String, value: Variant) -> bool:
	if has_method("set_data"):
		var old_value = get_data(setting_name)
		set_data(setting_name, value)
		config_changed.emit(setting_name, old_value, value)
		save_settings()
		return true
	return false

## Get all settings as dictionary
func get_all_settings() -> Dictionary:
	var settings = {}
	var properties = get_property_list()
	
	for prop in properties:
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			# Skip balance_config as it's a complex object
			if prop.name == "balance_config":
				continue
			settings[prop.name] = get_data(prop.name)
	
	return settings

## Restore settings from dictionary
func restore_settings(settings: Dictionary) -> void:
	for setting_name in settings:
		# Skip balance_config as it's handled separately
		if setting_name == "balance_config":
			continue
		if has_method("set_data"):
			set_data(setting_name, settings[setting_name])

## Check if a feature is enabled
func is_feature_enabled(feature_name: String) -> bool:
	return features.get(feature_name, false)

## Enable or disable a feature
func set_feature(feature_name: String, enabled: bool) -> void:
	var old_value = features.get(feature_name, false)
	features[feature_name] = enabled
	config_changed.emit("features." + feature_name, old_value, enabled)
	save_settings()

## Get balance configuration
func get_balance_config() -> BalanceConfig:
	return balance_config

## Check if GameConfig is ready
func is_ready() -> bool:
	return balance_config != null and balance_config is BalanceConfig

## Ensure BalanceConfig is properly initialized
func ensure_balance_config() -> void:
	if not balance_config or not balance_config is BalanceConfig:
		balance_config = BalanceConfig.new()
		print("[GameConfig] BalanceConfig reinitialized")

## Load settings from file
func load_settings() -> void:
	var file_path = "user://game_config.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var settings = json.data
				restore_settings(settings)
			else:
				push_error("Failed to parse game config JSON")

## Save settings to file
func save_settings() -> void:
	var file_path = "user://game_config.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var settings = get_all_settings()
		var json_string = JSON.stringify(settings, "\t")
		file.store_string(json_string)
		file.close()

## Reset settings to defaults
func reset_to_defaults() -> void:
	# Reset all settings to their default values
	game_version = "1.0.0"
	debug_mode = false
	auto_save_enabled = true
	auto_save_interval = 600.0
	notification_enabled = true
	sound_enabled = true
	music_enabled = true
	ui_scale = 1.0
	
	max_roster_size = 5
	max_character_level = 100
	experience_curve_multiplier = 1.0
	injury_recovery_time_multiplier = 1.0
	
	max_active_quests = 3
	quest_duration_multiplier = 1.0
	quest_reward_multiplier = 1.0
	quest_failure_penalty_multiplier = 1.0
	
	starting_gold = 50
	starting_influence = 100
	starting_food = 20
	reputation_per_level = 100
	
	ui_animation_speed = 1.0
	tooltip_delay = 0.5
	notification_duration = 5.0
	auto_close_dialogs = true
	
	max_event_history = 1000
	auto_cleanup_interval = 300.0
	enable_performance_logging = false
	
	# Reset features
	features = {
		"training_room": true,
		"library": true,
		"workshop": true,
		"armory": true,
		"healers_guild": true,
		"merchants_guild": true,
		"blacksmiths_guild": true,
		"equipment_system": true,
		"inventory_system": true,
		"crafting_system": false,
		"trading_system": false,
		"achievement_system": false,
		"tutorial_system": true
	}
	
	save_settings()

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"game_version": return game_version
		"debug_mode": return debug_mode
		"auto_save_enabled": return auto_save_enabled
		"auto_save_interval": return auto_save_interval
		"notification_enabled": return notification_enabled
		"sound_enabled": return sound_enabled
		"music_enabled": return music_enabled
		"ui_scale": return ui_scale
		"max_roster_size": return max_roster_size
		"max_character_level": return max_character_level
		"experience_curve_multiplier": return experience_curve_multiplier
		"injury_recovery_time_multiplier": return injury_recovery_time_multiplier
		"max_active_quests": return max_active_quests
		"quest_duration_multiplier": return quest_duration_multiplier
		"quest_reward_multiplier": return quest_reward_multiplier
		"quest_failure_penalty_multiplier": return quest_failure_penalty_multiplier
		"starting_gold": return starting_gold
		"starting_influence": return starting_influence
		"starting_food": return starting_food
		"reputation_per_level": return reputation_per_level
		"ui_animation_speed": return ui_animation_speed
		"tooltip_delay": return tooltip_delay
		"notification_duration": return notification_duration
		"auto_close_dialogs": return auto_close_dialogs
		"max_event_history": return max_event_history
		"auto_cleanup_interval": return auto_cleanup_interval
		"enable_performance_logging": return enable_performance_logging
		"features": return features
		"balance_config": return balance_config
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"game_version": game_version = value
		"debug_mode": debug_mode = value
		"auto_save_enabled": auto_save_enabled = value
		"auto_save_interval": auto_save_interval = value
		"notification_enabled": notification_enabled = value
		"sound_enabled": sound_enabled = value
		"music_enabled": music_enabled = value
		"ui_scale": ui_scale = value
		"max_roster_size": max_roster_size = value
		"max_character_level": max_character_level = value
		"experience_curve_multiplier": experience_curve_multiplier = value
		"injury_recovery_time_multiplier": injury_recovery_time_multiplier = value
		"max_active_quests": max_active_quests = value
		"quest_duration_multiplier": quest_duration_multiplier = value
		"quest_reward_multiplier": quest_reward_multiplier = value
		"quest_failure_penalty_multiplier": quest_failure_penalty_multiplier = value
		"starting_gold": starting_gold = value
		"starting_influence": starting_influence = value
		"starting_food": starting_food = value
		"reputation_per_level": reputation_per_level = value
		"ui_animation_speed": ui_animation_speed = value
		"tooltip_delay": tooltip_delay = value
		"notification_duration": notification_duration = value
		"auto_close_dialogs": auto_close_dialogs = value
		"max_event_history": max_event_history = value
		"auto_cleanup_interval": auto_cleanup_interval = value
		"enable_performance_logging": enable_performance_logging = value
		"features": features = value
		"balance_config": balance_config = value

## Get configuration summary
func get_config_summary() -> Dictionary:
	return {
		"game_version": game_version,
		"debug_mode": debug_mode,
		"features_enabled": features.values().filter(func(v): return v).size(),
		"total_features": features.size(),
		"auto_save_enabled": auto_save_enabled,
		"ui_scale": ui_scale,
		"max_roster_size": max_roster_size,
		"max_active_quests": max_active_quests
	}
