extends BaseViewModel
class_name GuildViewModel

## ViewModel for guild management UI
## Handles guild data binding and state management

# Guild data
var _guild: Guild = null
var _guild_resources: Dictionary = {}
var _guild_level: int = 1
var _guild_reputation: int = 0

# Resource management
var _gold: int = 0
var _influence: int = 0
var _food: int = 0
var _building_materials: int = 0

# Guild progression
var _unlocked_rooms: Array[String] = []
var _unlocked_features: Dictionary = {}
var _guild_upgrades: Dictionary = {}
var _available_upgrades: Array[Dictionary] = []

# Room management
var _room_costs: Dictionary = {}
var _can_unlock_room: bool = false
var _unlock_error: String = ""

# Upgrade management
var _upgrade_costs: Dictionary = {}
var _can_upgrade: bool = false
var _upgrade_error: String = ""

# Guild statistics
var _total_quests_completed: int = 0
var _total_characters_recruited: int = 0
var _total_resources_earned: Dictionary = {}
var _guild_efficiency: float = 0.0

func _init():
	super._init()

## Setup event subscriptions
func _setup_event_subscriptions() -> void:
	_subscribe_to_event("guild_created", _on_guild_created)
	_subscribe_to_event("guild_leveled_up", _on_guild_leveled_up)
	_subscribe_to_event("guild_resource_changed", _on_guild_resource_changed)
	_subscribe_to_event("guild_room_unlocked", _on_guild_room_unlocked)
	_subscribe_to_event("guild_feature_unlocked", _on_guild_feature_unlocked)
	_subscribe_to_event("guild_upgrade_purchased", _on_guild_upgrade_purchased)

## Handle initialization
func _on_initialized() -> void:
	_load_guild_data()
	_update_statistics()

## Load guild data from service
func _load_guild_data() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var guild_service = ServiceManager.get_guild_service()
	var guild_repository = ServiceManager.get_guild_repository()
	
	if guild_service and guild_repository:
		_guild = guild_repository.get_current_guild()
		if _guild:
			_update_guild_properties()

## Update guild properties from loaded data
func _update_guild_properties() -> void:
	if not _guild:
		return
	
	_guild_resources = _guild.get_all_resources()
	_gold = _guild_resources.get("gold", 0)
	_influence = _guild_resources.get("influence", 0)
	_food = _guild_resources.get("food", 0)
	_building_materials = _guild_resources.get("building_materials", 0)
	
	_guild_level = _guild.level
	_guild_reputation = _guild.reputation
	
	_unlocked_rooms = _guild.unlocked_rooms
	_unlocked_features = _guild.unlocked_features
	_guild_upgrades = _guild.guild_upgrades
	
	# Notify property changes
	_notify_property_changed("guild", null, _guild)
	_notify_property_changed("guild_resources", {}, _guild_resources)
	_notify_property_changed("gold", 0, _gold)
	_notify_property_changed("influence", 0, _influence)
	_notify_property_changed("food", 0, _food)
	_notify_property_changed("building_materials", 0, _building_materials)
	_notify_property_changed("guild_level", 1, _guild_level)
	_notify_property_changed("guild_reputation", 0, _guild_reputation)
	_notify_property_changed("unlocked_rooms", [], _unlocked_rooms)
	_notify_property_changed("unlocked_features", {}, _unlocked_features)
	_notify_property_changed("guild_upgrades", {}, _guild_upgrades)

## Update guild statistics
func _update_statistics() -> void:
	if not _guild:
		return
	
	# Calculate guild efficiency based on completed quests and resources
	var total_quests = _guild.get_data("total_quests_completed")
	var total_resources = _gold + _influence + _food + _building_materials
	
	if total_quests > 0:
		_guild_efficiency = float(total_resources) / float(total_quests)
	else:
		_guild_efficiency = 0.0
	
	# Notify property changes
	_notify_property_changed("guild_efficiency", 0.0, _guild_efficiency)

## Get data for a property
func get_data(property_name: String) -> Variant:
	match property_name:
		"guild": return _guild
		"guild_resources": return _guild_resources
		"gold": return _gold
		"influence": return _influence
		"food": return _food
		"building_materials": return _building_materials
		"guild_level": return _guild_level
		"guild_reputation": return _guild_reputation
		"unlocked_rooms": return _unlocked_rooms
		"unlocked_features": return _unlocked_features
		"guild_upgrades": return _guild_upgrades
		"available_upgrades": return _available_upgrades
		"room_costs": return _room_costs
		"can_unlock_room": return _can_unlock_room
		"unlock_error": return _unlock_error
		"upgrade_costs": return _upgrade_costs
		"can_upgrade": return _can_upgrade
		"upgrade_error": return _upgrade_error
		"total_quests_completed": return _total_quests_completed
		"total_characters_recruited": return _total_characters_recruited
		"total_resources_earned": return _total_resources_earned
		"guild_efficiency": return _guild_efficiency
		_: return null

## Set data for a property
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"guild": _guild = value
		"guild_resources": _guild_resources = value
		"gold": _gold = value
		"influence": _influence = value
		"food": _food = value
		"building_materials": _building_materials = value
		"guild_level": _guild_level = value
		"guild_reputation": _guild_reputation = value
		"unlocked_rooms": _unlocked_rooms = value
		"unlocked_features": _unlocked_features = value
		"guild_upgrades": _guild_upgrades = value
		"available_upgrades": _available_upgrades = value
		"room_costs": _room_costs = value
		"can_unlock_room": _can_unlock_room = value
		"unlock_error": _unlock_error = value
		"upgrade_costs": _upgrade_costs = value
		"can_upgrade": _can_upgrade = value
		"upgrade_error": _upgrade_error = value
		"total_quests_completed": _total_quests_completed = value
		"total_characters_recruited": _total_characters_recruited = value
		"total_resources_earned": _total_resources_earned = value
		"guild_efficiency": _guild_efficiency = value
		_: 
			super.set_data(property_name, value)

## Update a property
func _update_property(property_name: String, value: Variant) -> void:
	match property_name:
		"guild": _guild = value
		"guild_resources": _guild_resources = value
		"gold": _gold = value
		"influence": _influence = value
		"food": _food = value
		"building_materials": _building_materials = value
		"guild_level": _guild_level = value
		"guild_reputation": _guild_reputation = value
		"unlocked_rooms": _unlocked_rooms = value
		"unlocked_features": _unlocked_features = value
		"guild_upgrades": _guild_upgrades = value
		"available_upgrades": _available_upgrades = value
		"room_costs": _room_costs = value
		"can_unlock_room": _can_unlock_room = value
		"unlock_error": _unlock_error = value
		"upgrade_costs": _upgrade_costs = value
		"can_upgrade": _can_upgrade = value
		"upgrade_error": _upgrade_error = value
		"total_quests_completed": _total_quests_completed = value
		"total_characters_recruited": _total_characters_recruited = value
		"total_resources_earned": _total_resources_earned = value
		"guild_efficiency": _guild_efficiency = value
		_: pass

## Check if room is unlocked
func is_room_unlocked(room_name: String) -> bool:
	return _unlocked_rooms.has(room_name)

## Check if feature is unlocked
func is_feature_unlocked(feature_name: String) -> bool:
	return _unlocked_features.get(feature_name, false)

## Get room cost
func get_room_cost(room_name: String) -> Dictionary:
	return _room_costs.get(room_name, {})

## Get upgrade cost
func get_upgrade_cost(upgrade_name: String) -> Dictionary:
	return _upgrade_costs.get(upgrade_name, {})

## Update room costs
func update_room_costs() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		_room_costs = guild_service.get_room_costs()
		_can_unlock_room = guild_service.can_unlock_room()
		_unlock_error = guild_service.get_last_error()

## Update upgrade costs
func update_upgrade_costs() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		_upgrade_costs = guild_service.get_upgrade_costs()
		_available_upgrades = guild_service.get_available_upgrades()
		_can_upgrade = guild_service.can_upgrade()
		_upgrade_error = guild_service.get_last_error()

## Unlock a room
func unlock_room(room_name: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		var success = guild_service.unlock_room(room_name)
		if success:
			_load_guild_data()
		return success
	return false

## Purchase an upgrade
func purchase_upgrade(upgrade_name: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		var success = guild_service.purchase_upgrade(upgrade_name)
		if success:
			_load_guild_data()
		return success
	return false

## Spend resources
func spend_resources(cost: Dictionary) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		var success = guild_service.spend_resources(cost)
		if success:
			_load_guild_data()
		return success
	return false

## Add resources
func add_resources(resources: Dictionary) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		var success = guild_service.add_resources(resources)
		if success:
			_load_guild_data()
		return success
	return false

## Get guild statistics summary
func get_guild_statistics_summary() -> Dictionary:
	return {
		"guild_level": _guild_level,
		"guild_reputation": _guild_reputation,
		"gold": _gold,
		"influence": _influence,
		"food": _food,
		"building_materials": _building_materials,
		"unlocked_rooms": _unlocked_rooms.size(),
		"unlocked_features": _unlocked_features.size(),
		"guild_upgrades": _guild_upgrades.size(),
		"available_upgrades": _available_upgrades.size(),
		"guild_efficiency": _guild_efficiency,
		"can_unlock_room": _can_unlock_room,
		"can_upgrade": _can_upgrade
	}

## Refresh all data
func refresh() -> void:
	_load_guild_data()
	update_room_costs()
	update_upgrade_costs()
	_update_statistics()

## Event handlers
func _on_guild_created(_event: BaseEvent) -> void:
	_load_guild_data()

func _on_guild_leveled_up(_event: BaseEvent) -> void:
	_load_guild_data()

func _on_guild_resource_changed(_event: BaseEvent) -> void:
	_load_guild_data()

func _on_guild_room_unlocked(_event: BaseEvent) -> void:
	_load_guild_data()

func _on_guild_feature_unlocked(_event: BaseEvent) -> void:
	_load_guild_data()

func _on_guild_upgrade_purchased(_event: BaseEvent) -> void:
	_load_guild_data()

## Validate ViewModel state
func validate() -> bool:
	return super.validate() and ServiceManager != null and ServiceManager.is_initialized() and _guild != null
