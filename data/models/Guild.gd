class_name Guild
extends Resource

## Pure data model for Guild entities
## Contains no business logic - only data and basic validation

#region Core Properties
@export var id: String
@export var guild_name: String
@export var level: int = 1
@export var reputation: int = 0
@export var max_reputation: int = 1000
#endregion

#region Resources
@export var gold: int = 50
@export var influence: int = 100
@export var building_materials: int = 0
@export var food: int = 20
@export var armor_pieces: int = 0
@export var weapons: int = 0
#endregion

#region Character Management
@export var max_roster_size: int = 5
@export var current_roster_size: int = 0
@export var available_recruits: int = 3
@export var recruit_refresh_timer: float = 0.0
@export var recruit_refresh_interval: float = 300.0  # 5 minutes
#endregion

#region Quest Management
@export var max_active_quests: int = 3
@export var current_active_quests: int = 0
@export var total_quests_completed: int = 0
@export var quests_completed_by_rank: Dictionary = {}
#endregion

#region Progression & Unlocks
@export var unlocked_rooms: Array[String] = ["main_hall"]
@export var unlocked_features: Dictionary = {
	"training_room": false,
	"library": false,
	"workshop": false,
	"armory": false,
	"healers_guild": false,
	"merchants_guild": false,
	"blacksmiths_guild": false
}
@export var guild_upgrades: Dictionary = {
	"roster_size": 0,
	"quest_slots": 0,
	"storage_capacity": 0,
	"recruitment_quality": 0
}
#endregion

#region Statistics
@export var total_gold_earned: int = 0
@export var total_influence_earned: int = 0
@export var total_characters_recruited: int = 0
@export var total_characters_promoted: int = 0
@export var total_injuries_treated: int = 0
@export var days_active: int = 0
#endregion

#region Settings & Preferences
@export var auto_save_enabled: bool = true
@export var auto_save_interval: float = 600.0  # 10 minutes
@export var notification_enabled: bool = true
@export var sound_enabled: bool = true
@export var music_enabled: bool = true
#endregion

#region Metadata
@export var created_timestamp: float = 0.0
@export var last_save_timestamp: float = 0.0
@export var last_activity_timestamp: float = 0.0
@export var game_version: String = "1.0.0"
#endregion

func _init():
	id = generate_unique_id()
	created_timestamp = Time.get_unix_time_from_system()
	last_activity_timestamp = created_timestamp

## Generate a unique identifier for this guild
func generate_unique_id() -> String:
	return "guild_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Get all resources as a dictionary
func get_all_resources() -> Dictionary:
	return {
		"gold": gold,
		"influence": influence,
		"building_materials": building_materials,
		"food": food,
		"armor_pieces": armor_pieces,
		"weapons": weapons
	}

## Get all unlocked features as a dictionary
func get_unlocked_features() -> Dictionary:
	return unlocked_features.duplicate()

## Get all guild upgrades as a dictionary
func get_guild_upgrades() -> Dictionary:
	return guild_upgrades.duplicate()

## Check if a specific room is unlocked
func is_room_unlocked(room_name: String) -> bool:
	return room_name in unlocked_rooms

## Check if a specific feature is unlocked
func is_feature_unlocked(feature_name: String) -> bool:
	return unlocked_features.get(feature_name, false)

## Get effective roster size (base + upgrades)
func get_effective_roster_size() -> int:
	return max_roster_size + guild_upgrades.get("roster_size", 0)

## Get effective quest slots (base + upgrades)
func get_effective_quest_slots() -> int:
	return max_active_quests + guild_upgrades.get("quest_slots", 0)

## Get effective storage capacity (base + upgrades)
func get_effective_storage_capacity() -> int:
	return 100 + guild_upgrades.get("storage_capacity", 0) * 50

## Get recruitment quality bonus (affects recruit stats)
func get_recruitment_quality_bonus() -> int:
	return guild_upgrades.get("recruitment_quality", 0)

## Check if guild has enough resources for a cost
func can_afford(cost: Dictionary) -> bool:
	for resource in cost:
		if get_all_resources().get(resource, 0) < cost[resource]:
			return false
	return true

## Get guild level based on reputation
func calculate_guild_level() -> int:
	return int(reputation / 100) + 1

## Get reputation progress to next level
func get_reputation_progress() -> Dictionary:
	var current_level_reputation = (level - 1) * 100
	var next_level_reputation = level * 100
	var progress = reputation - current_level_reputation
	var required = next_level_reputation - current_level_reputation
	
	return {
		"current": progress,
		"required": required,
		"percentage": float(progress) / float(required) if required > 0 else 1.0
	}

## Get guild statistics summary
func get_statistics_summary() -> Dictionary:
	return {
		"level": level,
		"reputation": reputation,
		"days_active": days_active,
		"total_quests_completed": total_quests_completed,
		"total_characters_recruited": total_characters_recruited,
		"total_gold_earned": total_gold_earned,
		"total_influence_earned": total_influence_earned,
		"unlocked_rooms": unlocked_rooms.size(),
		"unlocked_features": unlocked_features.values().filter(func(v): return v).size()
	}

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"id": return id
		"guild_name": return guild_name
		"level": return level
		"reputation": return reputation
		"max_reputation": return max_reputation
		"gold": return gold
		"influence": return influence
		"building_materials": return building_materials
		"food": return food
		"armor_pieces": return armor_pieces
		"weapons": return weapons
		"max_roster_size": return max_roster_size
		"current_roster_size": return current_roster_size
		"available_recruits": return available_recruits
		"recruit_refresh_timer": return recruit_refresh_timer
		"recruit_refresh_interval": return recruit_refresh_interval
		"max_active_quests": return max_active_quests
		"current_active_quests": return current_active_quests
		"total_quests_completed": return total_quests_completed
		"quests_completed_by_rank": return quests_completed_by_rank
		"unlocked_rooms": return unlocked_rooms
		"unlocked_features": return unlocked_features
		"guild_upgrades": return guild_upgrades
		"total_gold_earned": return total_gold_earned
		"total_influence_earned": return total_influence_earned
		"total_characters_recruited": return total_characters_recruited
		"total_characters_promoted": return total_characters_promoted
		"total_injuries_treated": return total_injuries_treated
		"days_active": return days_active
		"auto_save_enabled": return auto_save_enabled
		"auto_save_interval": return auto_save_interval
		"notification_enabled": return notification_enabled
		"sound_enabled": return sound_enabled
		"music_enabled": return music_enabled
		"created_timestamp": return created_timestamp
		"last_save_timestamp": return last_save_timestamp
		"last_activity_timestamp": return last_activity_timestamp
		"game_version": return game_version
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"id": id = value
		"guild_name": guild_name = value
		"level": level = value
		"reputation": reputation = value
		"max_reputation": max_reputation = value
		"gold": gold = value
		"influence": influence = value
		"building_materials": building_materials = value
		"food": food = value
		"armor_pieces": armor_pieces = value
		"weapons": weapons = value
		"max_roster_size": max_roster_size = value
		"current_roster_size": current_roster_size = value
		"available_recruits": available_recruits = value
		"recruit_refresh_timer": recruit_refresh_timer = value
		"recruit_refresh_interval": recruit_refresh_interval = value
		"max_active_quests": max_active_quests = value
		"current_active_quests": current_active_quests = value
		"total_quests_completed": total_quests_completed = value
		"quests_completed_by_rank": quests_completed_by_rank = value
		"unlocked_rooms": unlocked_rooms = value
		"unlocked_features": unlocked_features = value
		"guild_upgrades": guild_upgrades = value
		"total_gold_earned": total_gold_earned = value
		"total_influence_earned": total_influence_earned = value
		"total_characters_recruited": total_characters_recruited = value
		"total_characters_promoted": total_characters_promoted = value
		"total_injuries_treated": total_injuries_treated = value
		"days_active": days_active = value
		"auto_save_enabled": auto_save_enabled = value
		"auto_save_interval": auto_save_interval = value
		"notification_enabled": notification_enabled = value
		"sound_enabled": sound_enabled = value
		"music_enabled": music_enabled = value
		"created_timestamp": created_timestamp = value
		"last_save_timestamp": last_save_timestamp = value
		"last_activity_timestamp": last_activity_timestamp = value
		"game_version": game_version = value

## Validate guild data integrity
func validate() -> bool:
	if id.is_empty() or guild_name.is_empty():
		return false
	
	if level < 1 or reputation < 0:
		return false
	
	if max_roster_size < 1 or max_active_quests < 1:
		return false
	
	if gold < 0 or influence < 0 or building_materials < 0 or food < 0:
		return false
	
	if armor_pieces < 0 or weapons < 0:
		return false
	
	return true
