extends Control

## Simple Navigation Bar with quick travel buttons
## Just a VBox with buttons for each main screen

signal navigation_requested(screen_name: String)

# Main navigation buttons
@onready var characters_btn: Button = $VBox/CharactersBtn
@onready var quests_btn: Button = $VBox/QuestsBtn
@onready var guild_btn: Button = $VBox/GuildBtn
@onready var map_btn: Button = $VBox/MapBtn
@onready var settings_btn: Button = $VBox/SettingsBtn

func _ready():
	# Connect button signals
	characters_btn.pressed.connect(_on_characters_pressed)
	quests_btn.pressed.connect(_on_quests_pressed)
	guild_btn.pressed.connect(_on_guild_pressed)
	map_btn.pressed.connect(_on_map_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)

## Handle navigation button presses
func _on_characters_pressed():
	navigation_requested.emit("characters")

func _on_quests_pressed():
	navigation_requested.emit("quests")

func _on_guild_pressed():
	navigation_requested.emit("guild")

func _on_map_pressed():
	navigation_requested.emit("map")

func _on_settings_pressed():
	navigation_requested.emit("settings")

## Update button states (if needed for visual feedback)
func update_button_states(current_screen: String):
	# Reset all buttons
	characters_btn.modulate = Color.WHITE
	quests_btn.modulate = Color.WHITE
	guild_btn.modulate = Color.WHITE
	map_btn.modulate = Color.WHITE
	settings_btn.modulate = Color.WHITE
	
	# Highlight current screen
	match current_screen:
		"characters":
			characters_btn.modulate = Color.YELLOW
		"quests":
			quests_btn.modulate = Color.YELLOW
		"guild":
			guild_btn.modulate = Color.YELLOW
		"map":
			map_btn.modulate = Color.YELLOW
		"settings":
			settings_btn.modulate = Color.YELLOW
