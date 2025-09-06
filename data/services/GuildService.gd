class_name GuildService
extends BaseService

## Service for managing guild business logic
## Handles resources, progression, unlocks, and guild operations

var _guild_repository: GuildRepository
var _guild: Guild

# Service statistics
var _resources_gained: Dictionary = {}
var _resources_spent: Dictionary = {}
var _rooms_unlocked: int = 0
var _features_unlocked: int = 0
var _upgrades_purchased: int = 0
var _last_error: String = ""

func _init():
	super._init("GuildService")

## Initialize with guild repository
func initialize_with_repository(guild_repository: GuildRepository) -> void:
	_guild_repository = guild_repository
	
	# Get or create guild
	var guilds = _guild_repository.get_all()
	if guilds.size() > 0:
		_guild = guilds[0]
	else:
		_create_new_guild()

## Validate that all dependencies are available
func _validate_dependencies() -> bool:
	if not _guild_repository:
		_last_error = "Guild repository not available"
		push_error(_service_name + ": " + _last_error)
		return false
	if not _guild:
		_last_error = "Guild not available"
		push_error(_service_name + ": " + _last_error)
		return false
	_last_error = ""
	return true

## Create a new guild
func _create_new_guild() -> void:
	_guild = Guild.new()
	_guild.guild_name = "New Guild"
	
	# Set starting resources from configuration
	if _balance_config and _balance_config is BalanceConfig:
		_guild.gold = _balance_config.starting_gold
		_guild.influence = _balance_config.starting_influence
		_guild.food = _balance_config.starting_food
	else:
		# Fallback values if balance config is not available
		_guild.gold = 50
		_guild.influence = 100
		_guild.food = 20
		push_error("[GuildService] BalanceConfig not available, using fallback values")
	
	# Add to repository
	_guild_repository.add(_guild)
	
	# Emit guild created event
	var event = GuildEvents.GuildCreatedEvent.new(_guild)
	emit_event(event)
	
	log_activity("Created new guild: " + _guild.guild_name)

## Get current guild
func get_guild() -> Guild:
	return _guild

## Add resources to guild
func add_resources(resources: Dictionary) -> bool:
	if not _validate_dependencies() or not _guild:
		return false
	
	var resources_added: Dictionary = {}
	
	for resource_type in resources:
		var amount = resources[resource_type]
		if amount > 0:
			var current_amount = _guild.get_all_resources().get(resource_type, 0)
			var new_amount = current_amount + amount
			
			# Update guild resource
			_guild.set(resource_type, new_amount)
			
			# Track for statistics
			resources_added[resource_type] = amount
			_resources_gained[resource_type] = _resources_gained.get(resource_type, 0) + amount
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Emit resource changed events
	for resource_type in resources_added:
		var event = GuildEvents.ResourceChangedEvent.new(
			resource_type,
			_guild.get_all_resources().get(resource_type, 0) - resources_added[resource_type],
			_guild.get_all_resources().get(resource_type, 0),
			"resource_gained"
		)
		emit_event(event)
	
	# Check for level up
	_check_guild_level_up()
	
	log_activity("Added resources: " + str(resources_added))
	return true

## Spend resources from guild
func spend_resources(resources: Dictionary) -> bool:
	if not _validate_dependencies() or not _guild:
		return false
	
	# Check if guild can afford the cost
	if not can_afford_cost(resources):
		emit_simple_event("insufficient_resources", {
			"required": resources,
			"available": _guild.get_all_resources()
		})
		return false
	
	var resources_spent: Dictionary = {}
	
	for resource_type in resources:
		var amount = resources[resource_type]
		if amount > 0:
			var current_amount = _guild.get_all_resources().get(resource_type, 0)
			var new_amount = current_amount - amount
			
			# Update guild resource
			_guild.set(resource_type, new_amount)
			
			# Track for statistics
			resources_spent[resource_type] = amount
			_resources_spent[resource_type] = _resources_spent.get(resource_type, 0) + amount
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Emit resource changed events
	for resource_type in resources_spent:
		var event = GuildEvents.ResourceChangedEvent.new(
			resource_type,
			_guild.get_all_resources().get(resource_type, 0) + resources_spent[resource_type],
			_guild.get_all_resources().get(resource_type, 0),
			"resource_spent"
		)
		emit_event(event)
	
	log_activity("Spent resources: " + str(resources_spent))
	return true

## Check if guild can afford a cost
func can_afford_cost(cost: Dictionary) -> bool:
	if not _guild:
		return false
	
	return _guild.can_afford(cost)

## Unlock a room
func unlock_room(room_name: String) -> bool:
	if not _validate_dependencies() or not _guild:
		return false
	
	# Check if room is already unlocked
	if _guild.is_room_unlocked(room_name):
		return false
	
	# Get unlock cost
	var unlock_cost = _balance_config.get_room_unlock_cost(room_name)
	
	# Check if guild can afford the cost
	if not can_afford_cost(unlock_cost):
		emit_simple_event("insufficient_resources", {
			"required": unlock_cost,
			"operation": "room_unlock",
			"room_name": room_name
		})
		return false
	
	# Spend resources
	if not spend_resources(unlock_cost):
		return false
	
	# Unlock room
	_guild.unlocked_rooms.append(room_name)
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Update statistics
	_rooms_unlocked += 1
	
	# Emit room unlocked event
	var event = GuildEvents.RoomUnlockedEvent.new(room_name, unlock_cost, {})
	emit_event(event)
	
	log_activity("Unlocked room: " + room_name)
	return true

## Unlock a feature
func unlock_feature(feature_name: String, unlock_cost: Dictionary = {}) -> bool:
	if not _validate_dependencies() or not _guild:
		return false
	
	# Check if feature is already unlocked
	if _guild.is_feature_unlocked(feature_name):
		return false
	
	# Check if guild can afford the cost
	if not can_afford_cost(unlock_cost):
		emit_simple_event("insufficient_resources", {
			"required": unlock_cost,
			"operation": "feature_unlock",
			"feature_name": feature_name
		})
		return false
	
	# Spend resources
	if not spend_resources(unlock_cost):
		return false
	
	# Unlock feature
	_guild.unlocked_features[feature_name] = true
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Update statistics
	_features_unlocked += 1
	
	# Emit feature unlocked event
	var event = GuildEvents.FeatureUnlockedEvent.new(feature_name, unlock_cost, {})
	emit_event(event)
	
	log_activity("Unlocked feature: " + feature_name)
	return true

## Purchase guild upgrade
func purchase_upgrade(upgrade_type: String) -> bool:
	if not _validate_dependencies() or not _guild:
		return false
	
	# Get upgrade cost
	var upgrade_cost = _balance_config.get_guild_upgrade_cost(upgrade_type)
	
	# Check if guild can afford the cost
	if not can_afford_cost(upgrade_cost):
		emit_simple_event("insufficient_resources", {
			"required": upgrade_cost,
			"operation": "guild_upgrade",
			"upgrade_type": upgrade_type
		})
		return false
	
	# Spend resources
	if not spend_resources(upgrade_cost):
		return false
	
	# Apply upgrade
	var current_level = _guild.guild_upgrades.get(upgrade_type, 0)
	_guild.guild_upgrades[upgrade_type] = current_level + 1
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Update statistics
	_upgrades_purchased += 1
	
	# Emit upgrade purchased event
	var benefits = _calculate_upgrade_benefits(upgrade_type, current_level + 1)
	var event = GuildEvents.GuildUpgradePurchasedEvent.new(upgrade_type, current_level + 1, upgrade_cost, benefits)
	emit_event(event)
	
	log_activity("Purchased upgrade: " + upgrade_type + " (Level " + str(current_level + 1) + ")")
	return true

## Calculate upgrade benefits
func _calculate_upgrade_benefits(upgrade_type: String, level: int) -> Dictionary:
	var benefits: Dictionary = {}
	
	match upgrade_type:
		"roster_size":
			benefits["additional_roster_slots"] = level
		"quest_slots":
			benefits["additional_quest_slots"] = level
		"storage_capacity":
			benefits["additional_storage"] = level * 50
		"recruitment_quality":
			benefits["recruitment_quality_bonus"] = level * 5
	
	return benefits

## Check for guild level up
func _check_guild_level_up() -> void:
	if not _guild:
		return
	
	var old_level = _guild.level
	var new_level = _guild.calculate_guild_level()
	
	if new_level > old_level:
		_guild.level = new_level
		
		# Calculate reputation gained
		var reputation_gained = (new_level - old_level) * _balance_config.reputation_per_level
		_guild.reputation += reputation_gained
		
		# Check for new unlocks
		var new_unlocks = _get_unlocks_for_level(new_level)
		
		# Update repository
		_guild_repository.update(_guild)
		
		# Emit level up event
		var event = GuildEvents.GuildLevelUpEvent.new(old_level, new_level, reputation_gained, new_unlocks)
		emit_event(event)
		
		log_activity("Guild leveled up to level " + str(new_level) + " (Reputation: +" + str(reputation_gained) + ")")

## Get unlocks available at level
func _get_unlocks_for_level(level: int) -> Array[String]:
	var unlocks = []
	
	# Define level-based unlocks
	var level_unlocks = {
		2: ["training_room"],
		3: ["library"],
		4: ["workshop"],
		5: ["armory"],
		6: ["healers_guild"],
		7: ["merchants_guild"],
		8: ["blacksmiths_guild"]
	}
	
	if level_unlocks.has(level):
		unlocks = level_unlocks[level]
	
	return unlocks

## Update guild statistics
func update_guild_statistics(statistic_name: String, value: int) -> void:
	if not _guild:
		return
	
	var old_value = _guild.get_data(statistic_name)
	_guild.set(statistic_name, old_value + value)
	
	# Update repository
	_guild_repository.update(_guild)
	
	# Emit statistic updated event
	var event = GuildEvents.GuildStatisticUpdatedEvent.new(statistic_name, old_value, old_value + value)
	emit_event(event)
	
	log_activity("Updated statistic " + statistic_name + ": +" + str(value))

## Check for guild milestones
func check_milestones() -> void:
	if not _guild:
		return
	
	var milestones = _get_guild_milestones()
	
	for milestone in milestones:
		var milestone_name = milestone.name
		var milestone_value = milestone.value
		var current_value = _guild.get_data(milestone.statistic)
		
		if current_value >= milestone_value and not _guild.get_data("milestone_" + milestone_name + "_reached"):
			# Milestone reached
			_guild.set_data("milestone_" + milestone_name + "_reached", true)
			
			# Give milestone reward
			var reward = milestone.reward
			if reward.size() > 0:
				add_resources(reward)
			
			# Emit milestone reached event
			var event = GuildEvents.GuildMilestoneReachedEvent.new(milestone_name, milestone_value, reward)
			emit_event(event)
			
			log_activity("Milestone reached: " + milestone_name + " (" + str(milestone_value) + ")")

## Get guild milestones
func _get_guild_milestones() -> Array[Dictionary]:
	return [
		{"name": "first_quest", "statistic": "total_quests_completed", "value": 1, "reward": {"gold": 100, "influence": 50}},
		{"name": "ten_quests", "statistic": "total_quests_completed", "value": 10, "reward": {"gold": 500, "influence": 200}},
		{"name": "fifty_quests", "statistic": "total_quests_completed", "value": 50, "reward": {"gold": 2000, "influence": 1000}},
		{"name": "first_recruit", "statistic": "total_characters_recruited", "value": 1, "reward": {"gold": 50, "influence": 25}},
		{"name": "ten_recruits", "statistic": "total_characters_recruited", "value": 10, "reward": {"gold": 500, "influence": 250}},
		{"name": "first_promotion", "statistic": "total_characters_promoted", "value": 1, "reward": {"gold": 200, "influence": 100}},
		{"name": "thousand_gold", "statistic": "total_gold_earned", "value": 1000, "reward": {"influence": 500}},
		{"name": "five_thousand_gold", "statistic": "total_gold_earned", "value": 5000, "reward": {"gold": 1000, "influence": 1000}}
	]

## Get guild service statistics
func get_guild_statistics() -> Dictionary:
	var guild_stats = _guild.get_statistics_summary() if _guild else {}
	
	return {
		"service_name": _service_name,
		"resources_gained": _resources_gained,
		"resources_spent": _resources_spent,
		"rooms_unlocked": _rooms_unlocked,
		"features_unlocked": _features_unlocked,
		"upgrades_purchased": _upgrades_purchased,
		"guild_stats": guild_stats
	}

## Get service statistics
func get_statistics() -> Dictionary:
	var base_stats = super.get_statistics()
	var guild_stats = get_guild_statistics()
	base_stats.merge(guild_stats)
	return base_stats

## Get room costs for all available rooms
func get_room_costs() -> Dictionary:
	if not _validate_dependencies():
		return {}
	
	var room_costs: Dictionary = {}
	# For now, return costs for common rooms
	# In the future, this could be expanded with a list of available rooms
	var common_rooms = ["training_room", "library", "workshop", "armory", "healers_guild", "merchants_guild", "blacksmiths_guild"]
	for room_name in common_rooms:
		room_costs[room_name] = _balance_config.get_room_unlock_cost(room_name)
	return room_costs

## Check if room unlocking is possible
func can_unlock_room() -> bool:
	return _validate_dependencies() and _guild != null

## Get upgrade costs for all available upgrades
func get_upgrade_costs() -> Dictionary:
	if not _validate_dependencies():
		return {}
	
	var upgrade_costs: Dictionary = {}
	# For now, return costs for common upgrades
	# In the future, this could be expanded with a list of available upgrades
	var common_upgrades = ["roster_size", "quest_slots", "storage_capacity", "recruitment_quality"]
	for upgrade_type in common_upgrades:
		upgrade_costs[upgrade_type] = _balance_config.get_guild_upgrade_cost(upgrade_type)
	return upgrade_costs

## Get available upgrades
func get_available_upgrades() -> Array[Dictionary]:
	if not _validate_dependencies():
		return []
	
	var upgrades: Array[Dictionary] = []
	# For now, return common upgrades
	# In the future, this could be expanded with a list of available upgrades
	var common_upgrades = ["roster_size", "quest_slots", "storage_capacity", "recruitment_quality"]
	for upgrade_type in common_upgrades:
		var upgrade_info: Dictionary = {
			"name": upgrade_type,
			"description": "Upgrade " + upgrade_type.replace("_", " ").capitalize(),
			"cost": _balance_config.get_guild_upgrade_cost(upgrade_type)
		}
		upgrades.append(upgrade_info)
	return upgrades

## Check if upgrading is possible
func can_upgrade() -> bool:
	return _validate_dependencies() and _guild != null

## Get the last error message
func get_last_error() -> String:
	return _last_error if "_last_error" in self else ""
