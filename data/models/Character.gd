class_name Character
extends Resource

## Pure data model for Character entities
## Contains no business logic - only data and basic validation

#region Enums
enum CharacterClass {
	TANK,
	HEALER, 
	SUPPORT,
	ATTACKER
}

enum CharacterJob {
	HERO,
	MAGE,
	ROGUE,
	WARRIOR,
	ARCHER,
	KNIGHT,
	PRIEST,
	DRUID,
	SHAMAN,
	WARLOCK,
	MONK,
	BARBARIAN,
	ASSASSIN,
	ALCHEMIST,
	ARTISAN,
	BLACKSMITH,
	BARD,
	BEAST_TAMER,
	BERSERKER,
	CRUSADER,
	DOMINATOR,
	ELEMENTALIST,
	ENCHANTER,
	EXPLORER,
	FIREBRAND,
	FORGEMASTER,
	GREEN_THUMB
}

enum Quality {
	ONE_STAR = 1,
	TWO_STAR = 2,
	THREE_STAR = 3
}

enum Rank {
	F, E, D, C, B, A, S, SS, SSS
}

enum InjuryType {
	NONE,
	PHYSICAL_WOUND,
	MENTAL_TRAUMA,
	CURSED_AFFLICTION,
	EXHAUSTION,
	POISON
}

enum CharacterStatus {
	AVAILABLE,
	ON_QUEST,
	WAITING_FOR_RESULTS,
	WAITING_TO_PROGRESS
}
#endregion

#region Core Properties
@export var id: String
@export var character_name: String
@export var character_class: CharacterClass
@export var character_job: CharacterJob
@export var quality: Quality = Quality.ONE_STAR
@export var rank: Rank = Rank.F
@export var level: int = 1
@export var experience: int = 0
@export var status: CharacterStatus = CharacterStatus.AVAILABLE
#endregion

#region Base Stats
@export var health: int = 100
@export var defense: int = 10
@export var attack: int = 10
@export var speed: int = 10
@export var intelligence: int = 10
@export var charisma: int = 10
#endregion

#region Sub-stats
@export var gathering: int = 0
@export var hunting: int = 0
@export var diplomacy: int = 0
@export var stealth: int = 0
@export var leadership: int = 0
@export var survival: int = 0
#endregion

#region Progression
@export var total_experience_gained: int = 0
@export var quests_completed: int = 0
@export var quests_failed: int = 0
@export var injury_count: int = 0
@export var promotion_count: int = 0
#endregion

#region Injury System
@export var current_injury: InjuryType = InjuryType.NONE
@export var injury_severity: int = 0  # 0-100, affects stat penalties
@export var injury_duration: float = 0.0  # Time until healed
#endregion

#region Equipment (Future)
@export var equipped_weapon: String = ""
@export var equipped_armor: String = ""
@export var equipped_accessory: String = ""
#endregion

#region Metadata
@export var created_timestamp: float = 0.0
@export var last_activity_timestamp: float = 0.0
@export var recruitment_cost: int = 0
#endregion

func _init():
	id = generate_unique_id()
	created_timestamp = Time.get_unix_time_from_system()
	last_activity_timestamp = created_timestamp

## Generate a unique identifier for this character
func generate_unique_id() -> String:
	return "char_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Get total stats for quest calculations
func get_total_stats() -> Dictionary:
	return {
		"health": health,
		"defense": defense,
		"attack": attack,
		"speed": speed,
		"intelligence": intelligence,
		"charisma": charisma
	}

## Get sub-stats for quest calculations
func get_substats() -> Dictionary:
	return {
		"gathering": gathering,
		"hunting": hunting,
		"diplomacy": diplomacy,
		"stealth": stealth,
		"leadership": leadership,
		"survival": survival
	}

## Check if character is available for quests
func is_available() -> bool:
	return status == CharacterStatus.AVAILABLE and current_injury == InjuryType.NONE

## Get experience required for next level
func get_experience_to_next_level() -> int:
	var base_exp = 100
	var rank_multiplier = get_rank_multiplier()
	var level_multiplier = 1.0 + (level - 1) * 0.1
	return int(base_exp * rank_multiplier * level_multiplier)

## Get rank-based experience multiplier
func get_rank_multiplier() -> float:
	match rank:
		Rank.F: return 1.0
		Rank.E: return 1.2
		Rank.D: return 1.5
		Rank.C: return 2.0
		Rank.B: return 2.5
		Rank.A: return 3.0
		Rank.S: return 4.0
		Rank.SS: return 5.0
		Rank.SSS: return 6.0
		_: return 1.0

## Get stat penalties from injury
func get_injury_penalties() -> Dictionary:
	if current_injury == InjuryType.NONE:
		return {}
	
	var penalty_percent = injury_severity / 100.0
	var penalties = {}
	
	match current_injury:
		InjuryType.PHYSICAL_WOUND:
			penalties = {"health": -int(health * penalty_percent * 0.5), "defense": -int(defense * penalty_percent * 0.3)}
		InjuryType.MENTAL_TRAUMA:
			penalties = {"intelligence": -int(intelligence * penalty_percent * 0.4), "charisma": -int(charisma * penalty_percent * 0.3)}
		InjuryType.CURSED_AFFLICTION:
			penalties = {"attack": -int(attack * penalty_percent * 0.3), "speed": -int(speed * penalty_percent * 0.2)}
		InjuryType.EXHAUSTION:
			penalties = {"health": -int(health * penalty_percent * 0.2), "speed": -int(speed * penalty_percent * 0.4)}
		InjuryType.POISON:
			penalties = {"health": -int(health * penalty_percent * 0.6), "defense": -int(defense * penalty_percent * 0.2)}
	
	return penalties

## Get effective stats (base stats + equipment - injury penalties)
func get_effective_stats() -> Dictionary:
	var base_stats = get_total_stats()
	var injury_penalties = get_injury_penalties()
	var effective_stats = {}
	
	for stat in base_stats:
		effective_stats[stat] = base_stats[stat] + injury_penalties.get(stat, 0)
	
	return effective_stats

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"id": return id
		"character_name": return character_name
		"character_class": return character_class
		"quality": return quality
		"rank": return rank
		"level": return level
		"experience": return experience
		"status": return status
		"health": return health
		"defense": return defense
		"attack": return attack
		"speed": return speed
		"intelligence": return intelligence
		"charisma": return charisma
		"gathering": return gathering
		"hunting": return hunting
		"diplomacy": return diplomacy
		"stealth": return stealth
		"leadership": return leadership
		"survival": return survival
		"total_experience_gained": return total_experience_gained
		"quests_completed": return quests_completed
		"quests_failed": return quests_failed
		"injury_count": return injury_count
		"promotion_count": return promotion_count
		"current_injury": return current_injury
		"injury_severity": return injury_severity
		"injury_duration": return injury_duration
		"equipped_weapon": return equipped_weapon
		"equipped_armor": return equipped_armor
		"equipped_accessory": return equipped_accessory
		"created_timestamp": return created_timestamp
		"last_activity_timestamp": return last_activity_timestamp
		"recruitment_cost": return recruitment_cost
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"id": id = value
		"character_name": character_name = value
		"character_class": character_class = value
		"quality": quality = value
		"rank": rank = value
		"level": level = value
		"experience": experience = value
		"status": status = value
		"health": health = value
		"defense": defense = value
		"attack": attack = value
		"speed": speed = value
		"intelligence": intelligence = value
		"charisma": charisma = value
		"gathering": gathering = value
		"hunting": hunting = value
		"diplomacy": diplomacy = value
		"stealth": stealth = value
		"leadership": leadership = value
		"survival": survival = value
		"total_experience_gained": total_experience_gained = value
		"quests_completed": quests_completed = value
		"quests_failed": quests_failed = value
		"injury_count": injury_count = value
		"promotion_count": promotion_count = value
		"current_injury": current_injury = value
		"injury_severity": injury_severity = value
		"injury_duration": injury_duration = value
		"equipped_weapon": equipped_weapon = value
		"equipped_armor": equipped_armor = value
		"equipped_accessory": equipped_accessory = value
		"created_timestamp": created_timestamp = value
		"last_activity_timestamp": last_activity_timestamp = value
		"recruitment_cost": recruitment_cost = value

## Validate character data integrity
func validate() -> bool:
	if id.is_empty() or character_name.is_empty():
		return false
	
	if level < 1 or experience < 0:
		return false
	
	if health <= 0 or defense < 0 or attack < 0 or speed < 0 or intelligence < 0 or charisma < 0:
		return false
	
	if injury_severity < 0 or injury_severity > 100:
		return false
	
	return true
