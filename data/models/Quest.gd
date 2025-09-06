class_name Quest
extends Resource

## Pure data model for Quest entities
## Contains no business logic - only data and basic validation

#region Enums
enum QuestType {
	GATHERING,
	HUNTING,
	TRAPPING,
	DIPLOMACY,
	CARAVAN_GUARDING,
	DEFENSE,
	STEALTH,
	ODD_JOB,
	EMERGENCY,
	EXPLORATION,
	ESCORT,
	ASSASSINATION,
	RECONNAISSANCE,
	INVESTIGATION,
	RESCUE,
	DELIVERY,
	UNIQUE_MONSTER_HUNT,
	RAID,
	APEX_PREDATOR_HUNT
}

enum QuestStatus {
	NOT_STARTED,
	IN_PROGRESS,
	AWAITING_COMPLETION,
	COMPLETED,
	FAILED
}

enum QuestRank {
	F, E, D, C, B, A, S, SS, SSS
}

enum QuestDifficulty {
	TRIVIAL,
	EASY,
	NORMAL,
	HARD,
	EXTREME,
	LEGENDARY
}
#endregion

#region Core Properties
@export var id: String
@export var quest_name: String
@export var quest_type: QuestType
@export var quest_rank: QuestRank
@export var difficulty: QuestDifficulty = QuestDifficulty.NORMAL
@export var description: String
@export var status: QuestStatus = QuestStatus.NOT_STARTED
#endregion

#region Timing
@export var duration: float  # in seconds
@export var start_time: float = 0.0
@export var completion_time: float = 0.0
@export var allow_partial_failure: bool = true
#endregion

#region Party Requirements
@export var min_party_size: int = 1
@export var max_party_size: int = 5
@export var required_tank: bool = false
@export var required_healer: bool = false
@export var required_support: bool = false
@export var required_attacker: bool = false
@export var required_jobs: Array[String] = []
#endregion

#region Stat Requirements
@export var min_total_health: int = 0
@export var min_total_defense: int = 0
@export var min_total_attack: int = 0
@export var min_total_speed: int = 0
@export var min_total_intelligence: int = 0
@export var min_total_charisma: int = 0
#endregion

#region Sub-stat Requirements
@export var min_gathering: int = 0
@export var min_hunting: int = 0
@export var min_diplomacy: int = 0
@export var min_stealth: int = 0
@export var min_leadership: int = 0
@export var min_survival: int = 0
#endregion

#region Rewards
@export var gold_reward: int = 0
@export var influence_reward: int = 0
@export var experience_reward: int = 0
@export var item_rewards: Array[String] = []
@export var material_rewards: Dictionary = {}  # {"material_name": quantity}
#endregion

#region Risk & Consequences
@export var injury_chance: float = 0.0  # 0.0 to 1.0
@export var failure_penalty_gold: int = 0
@export var failure_penalty_influence: int = 0
@export var critical_failure_chance: float = 0.0  # 0.0 to 1.0
#endregion

#region Metadata
@export var created_timestamp: float = 0.0
@export var quest_giver: String = ""
@export var location: String = ""
@export var is_emergency: bool = false
@export var is_repeatable: bool = false
#endregion

func _init():
	id = generate_unique_id()
	created_timestamp = Time.get_unix_time_from_system()

## Generate a unique identifier for this quest
func generate_unique_id() -> String:
	return "quest_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Get all stat requirements as a dictionary
func get_stat_requirements() -> Dictionary:
	return {
		"health": min_total_health,
		"defense": min_total_defense,
		"attack": min_total_attack,
		"speed": min_total_speed,
		"intelligence": min_total_intelligence,
		"charisma": min_total_charisma
	}

## Get all sub-stat requirements as a dictionary
func get_substat_requirements() -> Dictionary:
	return {
		"gathering": min_gathering,
		"hunting": min_hunting,
		"diplomacy": min_diplomacy,
		"stealth": min_stealth,
		"leadership": min_leadership,
		"survival": min_survival
	}

## Get class requirements as a dictionary
func get_class_requirements() -> Dictionary:
	return {
		"tank": required_tank,
		"healer": required_healer,
		"support": required_support,
		"attacker": required_attacker
	}

## Get all rewards as a dictionary
func get_all_rewards() -> Dictionary:
	return {
		"gold": gold_reward,
		"influence": influence_reward,
		"experience": experience_reward,
		"items": item_rewards,
		"materials": material_rewards
	}

## Get failure penalties as a dictionary
func get_failure_penalties() -> Dictionary:
	return {
		"gold": failure_penalty_gold,
		"influence": failure_penalty_influence
	}

## Check if quest is currently active
func is_active() -> bool:
	return status == QuestStatus.IN_PROGRESS or status == QuestStatus.AWAITING_COMPLETION

## Check if quest is completed
func is_completed() -> bool:
	return status == QuestStatus.COMPLETED

## Check if quest has failed
func is_failed() -> bool:
	return status == QuestStatus.FAILED

## Get quest difficulty multiplier for calculations
func get_difficulty_multiplier() -> float:
	match difficulty:
		QuestDifficulty.TRIVIAL: return 0.5
		QuestDifficulty.EASY: return 0.75
		QuestDifficulty.NORMAL: return 1.0
		QuestDifficulty.HARD: return 1.5
		QuestDifficulty.EXTREME: return 2.0
		QuestDifficulty.LEGENDARY: return 3.0
		_: return 1.0

## Get rank-based multiplier for calculations
func get_rank_multiplier() -> float:
	match quest_rank:
		QuestRank.F: return 1.0
		QuestRank.E: return 1.2
		QuestRank.D: return 1.5
		QuestRank.C: return 2.0
		QuestRank.B: return 2.5
		QuestRank.A: return 3.0
		QuestRank.S: return 4.0
		QuestRank.SS: return 5.0
		QuestRank.SSS: return 6.0
		_: return 1.0

## Calculate total reward value (for sorting/display)
func get_total_reward_value() -> int:
	var total = gold_reward + influence_reward + experience_reward
	# Add estimated value of items and materials
	total += item_rewards.size() * 50  # Rough estimate
	for material in material_rewards:
		total += material_rewards[material] * 25  # Rough estimate
	return total

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"id": return id
		"quest_name": return quest_name
		"quest_type": return quest_type
		"quest_rank": return quest_rank
		"difficulty": return difficulty
		"description": return description
		"status": return status
		"duration": return duration
		"start_time": return start_time
		"completion_time": return completion_time
		"allow_partial_failure": return allow_partial_failure
		"min_party_size": return min_party_size
		"max_party_size": return max_party_size
		"required_tank": return required_tank
		"required_healer": return required_healer
		"required_support": return required_support
		"required_attacker": return required_attacker
		"required_jobs": return required_jobs
		"min_total_health": return min_total_health
		"min_total_defense": return min_total_defense
		"min_total_attack": return min_total_attack
		"min_total_speed": return min_total_speed
		"min_total_intelligence": return min_total_intelligence
		"min_total_charisma": return min_total_charisma
		"min_gathering": return min_gathering
		"min_hunting": return min_hunting
		"min_diplomacy": return min_diplomacy
		"min_stealth": return min_stealth
		"min_leadership": return min_leadership
		"min_survival": return min_survival
		"gold_reward": return gold_reward
		"influence_reward": return influence_reward
		"experience_reward": return experience_reward
		"item_rewards": return item_rewards
		"material_rewards": return material_rewards
		"injury_chance": return injury_chance
		"failure_penalty_gold": return failure_penalty_gold
		"failure_penalty_influence": return failure_penalty_influence
		"critical_failure_chance": return critical_failure_chance
		"created_timestamp": return created_timestamp
		"quest_giver": return quest_giver
		"location": return location
		"is_emergency": return is_emergency
		"is_repeatable": return is_repeatable
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"id": id = value
		"quest_name": quest_name = value
		"quest_type": quest_type = value
		"quest_rank": quest_rank = value
		"difficulty": difficulty = value
		"description": description = value
		"status": status = value
		"duration": duration = value
		"start_time": start_time = value
		"completion_time": completion_time = value
		"allow_partial_failure": allow_partial_failure = value
		"min_party_size": min_party_size = value
		"max_party_size": max_party_size = value
		"required_tank": required_tank = value
		"required_healer": required_healer = value
		"required_support": required_support = value
		"required_attacker": required_attacker = value
		"required_jobs": required_jobs = value
		"min_total_health": min_total_health = value
		"min_total_defense": min_total_defense = value
		"min_total_attack": min_total_attack = value
		"min_total_speed": min_total_speed = value
		"min_total_intelligence": min_total_intelligence = value
		"min_total_charisma": min_total_charisma = value
		"min_gathering": min_gathering = value
		"min_hunting": min_hunting = value
		"min_diplomacy": min_diplomacy = value
		"min_stealth": min_stealth = value
		"min_leadership": min_leadership = value
		"min_survival": min_survival = value
		"gold_reward": gold_reward = value
		"influence_reward": influence_reward = value
		"experience_reward": experience_reward = value
		"item_rewards": item_rewards = value
		"material_rewards": material_rewards = value
		"injury_chance": injury_chance = value
		"failure_penalty_gold": failure_penalty_gold = value
		"failure_penalty_influence": failure_penalty_influence = value
		"critical_failure_chance": critical_failure_chance = value
		"created_timestamp": created_timestamp = value
		"quest_giver": quest_giver = value
		"location": location = value
		"is_emergency": is_emergency = value
		"is_repeatable": is_repeatable = value

## Validate quest data integrity
func validate() -> bool:
	if id.is_empty() or quest_name.is_empty() or description.is_empty():
		return false
	
	if duration <= 0:
		return false
	
	if min_party_size < 1 or max_party_size < min_party_size:
		return false
	
	if gold_reward < 0 or influence_reward < 0 or experience_reward < 0:
		return false
	
	if injury_chance < 0.0 or injury_chance > 1.0:
		return false
	
	if critical_failure_chance < 0.0 or critical_failure_chance > 1.0:
		return false
	
	return true
