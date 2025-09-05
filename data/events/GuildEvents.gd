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
	
	func _init(resource_type: String, old_amount: int, new_amount: int, reason: String, source: String = "GuildService"):
		self.resource_type = resource_type
		self.old_amount = old_amount
		self.new_amount = new_amount
		self.change_amount = new_amount - old_amount
		self.reason = reason
		super._init("resource_changed", source, {
			"resource_type": resource_type,
			"old_amount": old_amount,
			"new_amount": new_amount,
			"change_amount": self.change_amount,
			"reason": reason
		})

class InsufficientResourcesEvent extends BaseEvent:
	var required_resources: Dictionary
	var available_resources: Dictionary
	var missing_resources: Dictionary
	
	func _init(required: Dictionary, available: Dictionary, source: String = "GuildService"):
		self.required_resources = required
		self.available_resources = available
		self.missing_resources = {}
		
		for resource in required:
			var available_amount = available.get(resource, 0)
			var required_amount = required[resource]
			if available_amount < required_amount:
				self.missing_resources[resource] = required_amount - available_amount
		
		super._init("insufficient_resources", source, {
			"required_resources": required,
			"available_resources": available,
			"missing_resources": self.missing_resources
		})
#endregion

#region Guild Progression Events
class GuildLevelUpEvent extends BaseEvent:
	var old_level: int
	var new_level: int
	var reputation_gained: int
	var new_unlocks: Array[String]
	
	func _init(old_level: int, new_level: int, reputation_gained: int, unlocks: Array[String], source: String = "GuildService"):
		self.old_level = old_level
		self.new_level = new_level
		self.reputation_gained = reputation_gained
		self.new_unlocks = unlocks
		super._init("guild_level_up", source, {
			"old_level": old_level,
			"new_level": new_level,
			"reputation_gained": reputation_gained,
			"new_unlocks": unlocks
		})

class RoomUnlockedEvent extends BaseEvent:
	var room_name: String
	var unlock_cost: Dictionary
	var unlock_requirements: Dictionary
	
	func _init(room_name: String, cost: Dictionary, requirements: Dictionary, source: String = "GuildService"):
		self.room_name = room_name
		self.unlock_cost = cost
		self.unlock_requirements = requirements
		super._init("room_unlocked", source, {
			"room_name": room_name,
			"unlock_cost": cost,
			"unlock_requirements": requirements
		})

class FeatureUnlockedEvent extends BaseEvent:
	var feature_name: String
	var unlock_cost: Dictionary
	var unlock_requirements: Dictionary
	
	func _init(feature_name: String, cost: Dictionary, requirements: Dictionary, source: String = "GuildService"):
		self.feature_name = feature_name
		self.unlock_cost = cost
		self.unlock_requirements = requirements
		super._init("feature_unlocked", source, {
			"feature_name": feature_name,
			"unlock_cost": cost,
			"unlock_requirements": requirements
		})

class GuildUpgradePurchasedEvent extends BaseEvent:
	var upgrade_type: String
	var upgrade_level: int
	var upgrade_cost: Dictionary
	var upgrade_benefits: Dictionary
	
	func _init(upgrade_type: String, level: int, cost: Dictionary, benefits: Dictionary, source: String = "GuildService"):
		self.upgrade_type = upgrade_type
		self.upgrade_level = level
		self.upgrade_cost = cost
		self.upgrade_benefits = benefits
		super._init("guild_upgrade_purchased", source, {
			"upgrade_type": upgrade_type,
			"upgrade_level": level,
			"upgrade_cost": cost,
			"upgrade_benefits": benefits
		})
#endregion

#region Guild Management Events
class GuildCreatedEvent extends BaseEvent:
	var guild: Guild
	
	func _init(guild: Guild, source: String = "GuildService"):
		self.guild = guild
		super._init("guild_created", source, {
			"guild_id": guild.id,
			"guild_name": guild.guild_name
		})

class GuildSavedEvent extends BaseEvent:
	var guild: Guild
	var save_duration: float
	
	func _init(guild: Guild, save_duration: float, source: String = "SaveService"):
		self.guild = guild
		self.save_duration = save_duration
		super._init("guild_saved", source, {
			"guild_id": guild.id,
			"guild_name": guild.guild_name,
			"save_duration": save_duration
		})

class GuildLoadedEvent extends BaseEvent:
	var guild: Guild
	var load_duration: float
	
	func _init(guild: Guild, load_duration: float, source: String = "SaveService"):
		self.guild = guild
		self.load_duration = load_duration
		super._init("guild_loaded", source, {
			"guild_id": guild.id,
			"guild_name": guild.guild_name,
			"load_duration": load_duration
		})

class GuildSettingsChangedEvent extends BaseEvent:
	var setting_name: String
	var old_value: Variant
	var new_value: Variant
	
	func _init(setting_name: String, old_value: Variant, new_value: Variant, source: String = "SettingsService"):
		self.setting_name = setting_name
		self.old_value = old_value
		self.new_value = new_value
		super._init("guild_settings_changed", source, {
			"setting_name": setting_name,
			"old_value": old_value,
			"new_value": new_value
		})
#endregion

#region Guild Statistics Events
class GuildStatisticUpdatedEvent extends BaseEvent:
	var statistic_name: String
	var old_value: int
	var new_value: int
	var change_amount: int
	
	func _init(statistic_name: String, old_value: int, new_value: int, source: String = "GuildService"):
		self.statistic_name = statistic_name
		self.old_value = old_value
		self.new_value = new_value
		self.change_amount = new_value - old_value
		super._init("guild_statistic_updated", source, {
			"statistic_name": statistic_name,
			"old_value": old_value,
			"new_value": new_value,
			"change_amount": self.change_amount
		})

class GuildMilestoneReachedEvent extends BaseEvent:
	var milestone_name: String
	var milestone_value: int
	var milestone_reward: Dictionary
	
	func _init(milestone_name: String, value: int, reward: Dictionary, source: String = "GuildService"):
		self.milestone_name = milestone_name
		self.milestone_value = value
		self.milestone_reward = reward
		super._init("guild_milestone_reached", source, {
			"milestone_name": milestone_name,
			"milestone_value": value,
			"milestone_reward": reward
		})
#endregion
