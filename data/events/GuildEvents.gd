class_name GuildEvents

## Static class containing all guild-related event definitions
## Provides type-safe event creation and handling

#region Guild Resource Events
class ResourceChangedEvent extends BaseEvent:
	var resource_type: String
	var old_amount: int
	var new_amount: int
	var change_amount: int
	var reason: String
	
	func _init(p_resource_type: String, p_old_amount: int, p_new_amount: int, p_reason: String, p_source: String = "GuildService"):
		resource_type = p_resource_type
		old_amount = p_old_amount
		new_amount = p_new_amount
		change_amount = p_new_amount - p_old_amount
		reason = p_reason
		super._init("resource_changed", p_source, {
			"resource_type": p_resource_type,
			"old_amount": p_old_amount,
			"new_amount": p_new_amount,
			"change_amount": change_amount,
			"reason": p_reason
		})

class InsufficientResourcesEvent extends BaseEvent:
	var required_resources: Dictionary
	var available_resources: Dictionary
	var missing_resources: Dictionary
	
	func _init(p_required: Dictionary, p_available: Dictionary, p_source: String = "GuildService"):
		required_resources = p_required
		available_resources = p_available
		missing_resources = {}
		
		for resource in p_required:
			var available_amount = p_available.get(resource, 0)
			var required_amount = p_required[resource]
			if available_amount < required_amount:
				missing_resources[resource] = required_amount - available_amount
		
		super._init("insufficient_resources", p_source, {
			"required_resources": p_required,
			"available_resources": p_available,
			"missing_resources": missing_resources
		})
#endregion

#region Guild Progression Events
class GuildLevelUpEvent extends BaseEvent:
	var old_level: int
	var new_level: int
	var reputation_gained: int
	var new_unlocks: Array[String]
	
	func _init(p_old_level: int, p_new_level: int, p_reputation_gained: int, p_unlocks: Array[String], p_source: String = "GuildService"):
		old_level = p_old_level
		new_level = p_new_level
		reputation_gained = p_reputation_gained
		new_unlocks = p_unlocks
		super._init("guild_level_up", p_source, {
			"old_level": p_old_level,
			"new_level": p_new_level,
			"reputation_gained": p_reputation_gained,
			"new_unlocks": p_unlocks
		})

class RoomUnlockedEvent extends BaseEvent:
	var room_name: String
	var unlock_cost: Dictionary
	var unlock_requirements: Dictionary
	
	func _init(p_room_name: String, p_cost: Dictionary, p_requirements: Dictionary, p_source: String = "GuildService"):
		room_name = p_room_name
		unlock_cost = p_cost
		unlock_requirements = p_requirements
		super._init("room_unlocked", p_source, {
			"room_name": p_room_name,
			"unlock_cost": p_cost,
			"unlock_requirements": p_requirements
		})

class FeatureUnlockedEvent extends BaseEvent:
	var feature_name: String
	var unlock_cost: Dictionary
	var unlock_requirements: Dictionary
	
	func _init(p_feature_name: String, p_cost: Dictionary, p_requirements: Dictionary, p_source: String = "GuildService"):
		feature_name = p_feature_name
		unlock_cost = p_cost
		unlock_requirements = p_requirements
		super._init("feature_unlocked", p_source, {
			"feature_name": p_feature_name,
			"unlock_cost": p_cost,
			"unlock_requirements": p_requirements
		})

class GuildUpgradePurchasedEvent extends BaseEvent:
	var upgrade_type: String
	var upgrade_level: int
	var upgrade_cost: Dictionary
	var upgrade_benefits: Dictionary
	
	func _init(p_upgrade_type: String, p_level: int, p_cost: Dictionary, p_benefits: Dictionary, p_source: String = "GuildService"):
		upgrade_type = p_upgrade_type
		upgrade_level = p_level
		upgrade_cost = p_cost
		upgrade_benefits = p_benefits
		super._init("guild_upgrade_purchased", p_source, {
			"upgrade_type": p_upgrade_type,
			"upgrade_level": p_level,
			"upgrade_cost": p_cost,
			"upgrade_benefits": p_benefits
		})
#endregion

#region Guild Management Events
class GuildCreatedEvent extends BaseEvent:
	var guild: Guild
	
	func _init(p_guild: Guild, p_source: String = "GuildService"):
		guild = p_guild
		super._init("guild_created", p_source, {
			"guild_id": p_guild.id,
			"guild_name": p_guild.guild_name
		})

class GuildSavedEvent extends BaseEvent:
	var guild: Guild
	var save_duration: float
	
	func _init(p_guild: Guild, p_save_duration: float, p_source: String = "SaveService"):
		guild = p_guild
		save_duration = p_save_duration
		super._init("guild_saved", p_source, {
			"guild_id": p_guild.id,
			"guild_name": p_guild.guild_name,
			"save_duration": p_save_duration
		})

class GuildLoadedEvent extends BaseEvent:
	var guild: Guild
	var load_duration: float
	
	func _init(p_guild: Guild, p_load_duration: float, p_source: String = "SaveService"):
		guild = p_guild
		load_duration = p_load_duration
		super._init("guild_loaded", p_source, {
			"guild_id": p_guild.id,
			"guild_name": p_guild.guild_name,
			"load_duration": p_load_duration
		})

class GuildSettingsChangedEvent extends BaseEvent:
	var setting_name: String
	var old_value: Variant
	var new_value: Variant
	
	func _init(p_setting_name: String, p_old_value: Variant, p_new_value: Variant, p_source: String = "SettingsService"):
		setting_name = p_setting_name
		old_value = p_old_value
		new_value = p_new_value
		super._init("guild_settings_changed", p_source, {
			"setting_name": p_setting_name,
			"old_value": p_old_value,
			"new_value": p_new_value
		})
#endregion

#region Guild Statistics Events
class GuildStatisticUpdatedEvent extends BaseEvent:
	var statistic_name: String
	var old_value: int
	var new_value: int
	var change_amount: int
	
	func _init(p_statistic_name: String, p_old_value: int, p_new_value: int, p_source: String = "GuildService"):
		statistic_name = p_statistic_name
		old_value = p_old_value
		new_value = p_new_value
		change_amount = p_new_value - p_old_value
		super._init("guild_statistic_updated", p_source, {
			"statistic_name": p_statistic_name,
			"old_value": p_old_value,
			"new_value": p_new_value,
			"change_amount": change_amount
		})

class GuildMilestoneReachedEvent extends BaseEvent:
	var milestone_name: String
	var milestone_value: int
	var milestone_reward: Dictionary
	
	func _init(p_milestone_name: String, p_value: int, p_reward: Dictionary, p_source: String = "GuildService"):
		milestone_name = p_milestone_name
		milestone_value = p_value
		milestone_reward = p_reward
		super._init("guild_milestone_reached", p_source, {
			"milestone_name": p_milestone_name,
			"milestone_value": p_value,
			"milestone_reward": p_reward
		})
#endregion
