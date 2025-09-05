extends Node

## Centralized save/load system for game data
## Handles serialization, compression, and file management

signal save_started(save_name: String)
signal save_completed(save_name: String, duration: float)
signal save_failed(save_name: String, error: String)
signal load_started(save_name: String)
signal load_completed(save_name: String, duration: float)
signal load_failed(save_name: String, error: String)

var _save_directory: String = "user://saves/"
var _current_save_name: String = ""
var _auto_save_enabled: bool = true
var _auto_save_interval: float = 600.0  # 10 minutes
var _auto_save_timer: float = 0.0

# Save statistics
var _save_count: int = 0
var _load_count: int = 0
var _total_save_time: float = 0.0
var _total_load_time: float = 0.0

func _ready():
	# Ensure save directory exists
	_ensure_save_directory_exists()
	
	# Set as autoload singleton
	name = "SaveSystem"

func _process(delta):
	if _auto_save_enabled and _current_save_name != "":
		_auto_save_timer += delta
		if _auto_save_timer >= _auto_save_interval:
			auto_save()
			_auto_save_timer = 0.0

## Ensure save directory exists
func _ensure_save_directory_exists() -> void:
	if not DirAccess.dir_exists_absolute(_save_directory):
		DirAccess.open("user://").make_dir_recursive(_save_directory)

## Set current save name
func set_current_save(save_name: String) -> void:
	_current_save_name = save_name
	_auto_save_timer = 0.0

## Get current save name
func get_current_save() -> String:
	return _current_save_name

## Save data to a specific save slot
func save_to_slot(slot: int, save_name: String = "") -> bool:
	var slot_name = "save_slot_" + str(slot)
	var display_name = save_name if save_name != "" else "Save " + str(slot)
	
	var start_time = Time.get_ticks_msec()
	save_started.emit(slot_name)
	
	var save_data = _collect_save_data()
	save_data["save_info"] = {
		"save_name": display_name,
		"save_timestamp": Time.get_unix_time_from_system(),
		"game_version": "1.0.0",
		"slot": slot
	}
	
	var file_path = _save_directory + slot_name + ".json"
	var result = _write_save_file(file_path, save_data)
	
	var duration = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if result:
		_save_count += 1
		_total_save_time += duration
		save_completed.emit(slot_name, duration)
		return true
	else:
		save_failed.emit(slot_name, "Failed to write save file")
		return false

## Load data from a specific save slot
func load_from_slot(slot: int) -> bool:
	var slot_name = "save_slot_" + str(slot)
	var file_path = _save_directory + slot_name + ".json"
	
	var start_time = Time.get_ticks_msec()
	load_started.emit(slot_name)
	
	var save_data = _read_save_file(file_path)
	if save_data == null:
		load_failed.emit(slot_name, "Save file not found or corrupted")
		return false
	
	var result = _restore_save_data(save_data)
	var duration = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if result:
		_load_count += 1
		_total_load_time += duration
		_current_save_name = slot_name
		load_completed.emit(slot_name, duration)
		return true
	else:
		load_failed.emit(slot_name, "Failed to restore save data")
		return false

## Auto-save current game
func auto_save() -> bool:
	if _current_save_name == "":
		return false
	
	var start_time = Time.get_ticks_msec()
	save_started.emit("auto_save")
	
	var save_data = _collect_save_data()
	save_data["save_info"] = {
		"save_name": "Auto Save",
		"save_timestamp": Time.get_unix_time_from_system(),
		"game_version": "1.0.0",
		"is_auto_save": true
	}
	
	var file_path = _save_directory + "auto_save.json"
	var result = _write_save_file(file_path, save_data)
	
	var duration = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if result:
		_save_count += 1
		_total_save_time += duration
		save_completed.emit("auto_save", duration)
		return true
	else:
		save_failed.emit("auto_save", "Failed to write auto save file")
		return false

## Get list of available save files
func get_available_saves() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	
	# Check for numbered save slots
	for i in range(1, 11):  # 10 save slots
		var slot_name = "save_slot_" + str(i)
		var file_path = _save_directory + slot_name + ".json"
		
		if FileAccess.file_exists(file_path):
			var save_info = _get_save_info(file_path)
			if save_info:
				save_info["slot"] = i
				save_info["file_path"] = file_path
				saves.append(save_info)
	
	# Check for auto save
	var auto_save_path = _save_directory + "auto_save.json"
	if FileAccess.file_exists(auto_save_path):
		var save_info = _get_save_info(auto_save_path)
		if save_info:
			save_info["slot"] = 0  # Auto save is slot 0
			save_info["file_path"] = auto_save_path
			save_info["is_auto_save"] = true
			saves.append(save_info)
	
	# Sort by timestamp (newest first)
	saves.sort_custom(func(a, b): return a.get("save_timestamp", 0) > b.get("save_timestamp", 0))
	
	return saves

## Get save file information
func _get_save_info(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var save_data = json.data
	return save_data.get("save_info", {})

## Delete a save file
func delete_save(slot: int) -> bool:
	var slot_name = "save_slot_" + str(slot)
	var file_path = _save_directory + slot_name + ".json"
	
	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open("user://")
		return dir.remove(file_path) == OK
	
	return false

## Write save file to disk
func _write_save_file(file_path: String, save_data: Dictionary) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: " + file_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	return true

## Read save file from disk
func _read_save_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file JSON: " + file_path)
		return {}
	
	return json.data

## Collect all save data from repositories and services
func _collect_save_data() -> Dictionary:
	var save_data = {}
	
	# Collect from repositories
	if has_node("/root/CharacterRepository"):
		var char_repo = get_node("/root/CharacterRepository")
		save_data["characters"] = char_repo.get_all()
	
	if has_node("/root/QuestRepository"):
		var quest_repo = get_node("/root/QuestRepository")
		save_data["quests"] = quest_repo.get_all()
	
	if has_node("/root/GuildRepository"):
		var guild_repo = get_node("/root/GuildRepository")
		save_data["guild"] = guild_repo.get_all()
	
	# Collect from services
	if has_node("/root/GameConfig"):
		var config = get_node("/root/GameConfig")
		save_data["config"] = config.get_all_settings()
	
	return save_data

## Restore save data to repositories and services
func _restore_save_data(save_data: Dictionary) -> bool:
	# Restore to repositories
	if save_data.has("characters") and has_node("/root/CharacterRepository"):
		var char_repo = get_node("/root/CharacterRepository")
		char_repo.clear()
		for char_data in save_data["characters"]:
			var character = Character.new()
			_restore_character_data(character, char_data)
			char_repo.add(character)
	
	if save_data.has("quests") and has_node("/root/QuestRepository"):
		var quest_repo = get_node("/root/QuestRepository")
		quest_repo.clear()
		for quest_data in save_data["quests"]:
			var quest = Quest.new()
			_restore_quest_data(quest, quest_data)
			quest_repo.add(quest)
	
	if save_data.has("guild") and has_node("/root/GuildRepository"):
		var guild_repo = get_node("/root/GuildRepository")
		guild_repo.clear()
		for guild_data in save_data["guild"]:
			var guild = Guild.new()
			_restore_guild_data(guild, guild_data)
			guild_repo.add(guild)
	
	# Restore config
	if save_data.has("config") and has_node("/root/GameConfig"):
		var config = get_node("/root/GameConfig")
		config.restore_settings(save_data["config"])
	
	return true

## Restore character data from save
func _restore_character_data(character: Character, data: Dictionary) -> void:
	# Restore all properties
	for property in data:
		if character.has_method("set_data"):
			character.set_data(property, data[property])

## Restore quest data from save
func _restore_quest_data(quest: Quest, data: Dictionary) -> void:
	# Restore all properties
	for property in data:
		if quest.has_method("set_data"):
			quest.set_data(property, data[property])

## Restore guild data from save
func _restore_guild_data(guild: Guild, data: Dictionary) -> void:
	# Restore all properties
	for property in data:
		if guild.has_method("set"):
			guild.set_data(property, data[property])

## Get save system statistics
func get_statistics() -> Dictionary:
	return {
		"save_count": _save_count,
		"load_count": _load_count,
		"total_save_time": _total_save_time,
		"total_load_time": _total_load_time,
		"average_save_time": _total_save_time / max(1, _save_count),
		"average_load_time": _total_load_time / max(1, _load_count),
		"auto_save_enabled": _auto_save_enabled,
		"auto_save_interval": _auto_save_interval,
		"current_save": _current_save_name
	}

## Set auto-save settings
func set_auto_save(enabled: bool, interval: float = 600.0) -> void:
	_auto_save_enabled = enabled
	_auto_save_interval = max(60.0, interval)  # Minimum 1 minute
	_auto_save_timer = 0.0

## Save specific data (for repositories)
func save_data(data_name: String, data: Variant) -> bool:
	var save_data = {data_name: data}
	var file_path = _save_directory + data_name + ".json"
	return _write_save_file(file_path, save_data)

## Load specific data (for repositories)
func load_data(data_name: String) -> Variant:
	var file_path = _save_directory + data_name + ".json"
	var save_data = _read_save_file(file_path)
	if save_data.has(data_name):
		return save_data[data_name]
	return null
