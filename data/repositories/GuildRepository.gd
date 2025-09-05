class_name GuildRepository
extends BaseRepository

## Repository for Guild entities
## Handles guild data persistence and retrieval

func _init(save_system: SaveSystem = null, event_bus: EventBus = null):
	super._init(save_system, event_bus)

## Get repository name for save/load
func get_repository_name() -> String:
	return "guild"

## Get the current guild (there should only be one)
func get_current_guild() -> Guild:
	if _data.size() > 0:
		return _data[0]
	return null

## Set the current guild (replaces any existing guild)
func set_current_guild(guild: Guild) -> void:
	clear()
	add(guild)

## Check if guild exists
func has_guild() -> bool:
	return _data.size() > 0

## Get guild statistics
func get_guild_statistics() -> Dictionary:
	var guild = get_current_guild()
	if not guild:
		return {}
	
	return guild.get_statistics_summary()

## Get guild resources
func get_guild_resources() -> Dictionary:
	var guild = get_current_guild()
	if not guild:
		return {}
	
	return guild.get_all_resources()

## Check if guild can afford a cost
func can_afford_cost(cost: Dictionary) -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	return guild.can_afford(cost)

## Spend resources from guild
func spend_resources(cost: Dictionary) -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	if not guild.can_afford(cost):
		return false
	
	# Deduct resources
	for resource in cost:
		var current_value = guild.get_data(resource)
		guild.set_data(resource, current_value - cost[resource])
	
	# Emit resource change event
	if _event_bus:
		for resource in cost:
			var old_value = guild.get_data(resource) + cost[resource]  # Calculate old value
			var new_value = guild.get_data(resource)  # Current value after deduction
			var event = GuildEvents.ResourceChangedEvent.new(resource, old_value, new_value, "spent")
			_event_bus.emit_event(event)
	
	return true

## Add resources to guild
func add_resources(resources: Dictionary) -> void:
	var guild = get_current_guild()
	if not guild:
		return
	
	# Add resources
	for resource in resources:
		var current_value = guild.get_data(resource)
		guild.set_data(resource, current_value + resources[resource])
	
	# Emit resource change event
	if _event_bus:
		for resource in resources:
			var old_value = guild.get_data(resource) - resources[resource]  # Calculate old value
			var new_value = guild.get_data(resource)  # Current value after addition
			var event = GuildEvents.ResourceChangedEvent.new(resource, old_value, new_value, "gained")
			_event_bus.emit_event(event)

## Unlock a room for the guild
func unlock_room(room_name: String) -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	var unlocked_rooms = guild.get_data("unlocked_rooms")
	if room_name not in unlocked_rooms:
		unlocked_rooms.append(room_name)
		guild.set_data("unlocked_rooms", unlocked_rooms)
		
		# Emit room unlocked event
		if _event_bus:
			var event = GuildEvents.RoomUnlockedEvent.new(room_name, {}, {})
			_event_bus.emit_event(event)
		
		return true
	
	return false

## Unlock a feature for the guild
func unlock_feature(feature_name: String) -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	var unlocked_features = guild.get_data("unlocked_features")
	if not unlocked_features.get(feature_name, false):
		unlocked_features[feature_name] = true
		guild.set_data("unlocked_features", unlocked_features)
		
		# Emit feature unlocked event
		if _event_bus:
			var event = GuildEvents.FeatureUnlockedEvent.new(feature_name, {}, {})
			_event_bus.emit_event(event)
		
		return true
	
	return false

## Upgrade guild
func upgrade_guild(upgrade_type: String, levels: int = 1) -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	var guild_upgrades = guild.get_data("guild_upgrades")
	var current_level = guild_upgrades.get(upgrade_type, 0)
	guild_upgrades[upgrade_type] = current_level + levels
	guild.set_data("guild_upgrades", guild_upgrades)
	
	# Emit upgrade event
	if _event_bus:
		var event = GuildEvents.GuildUpgradePurchasedEvent.new(upgrade_type, current_level + levels, {}, {})
		_event_bus.emit_event(event)
	
	return true

## Validate guild data
func validate_guild_data() -> bool:
	var guild = get_current_guild()
	if not guild:
		return false
	
	return guild.validate()
