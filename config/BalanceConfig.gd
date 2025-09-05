class_name BalanceConfig
extends Resource

## Centralized balance configuration for all game mechanics
## Contains all numerical values used for calculations

# Character Recruitment
@export var character_recruitment_costs: Dictionary = {
	"ONE_STAR": 100,
	"TWO_STAR": 250,
	"THREE_STAR": 500
}

@export var character_recruitment_quality_bonuses: Dictionary = {
	"ONE_STAR": 0,
	"TWO_STAR": 5,
	"THREE_STAR": 10
}

# Character Leveling
@export var experience_requirements: Dictionary = {
	"F": 100,
	"E": 120,
	"D": 150,
	"C": 200,
	"B": 250,
	"A": 300,
	"S": 400,
	"SS": 500,
	"SSS": 600
}

@export var level_up_stat_gains: Dictionary = {
	"TANK": {"health": 15, "defense": 8, "attack": 3, "speed": 2, "intelligence": 2, "charisma": 2},
	"HEALER": {"health": 10, "defense": 4, "attack": 2, "speed": 3, "intelligence": 8, "charisma": 5},
	"SUPPORT": {"health": 8, "defense": 3, "attack": 2, "speed": 4, "intelligence": 6, "charisma": 7},
	"ATTACKER": {"health": 12, "defense": 3, "attack": 8, "speed": 6, "intelligence": 3, "charisma": 2}
}

@export var substat_improvement_chance: float = 0.1  # 10% chance per quest
@export var substat_improvement_amount: int = 1

# Quest Rewards
@export var quest_reward_multipliers: Dictionary = {
	"F": 1.0,
	"E": 1.2,
	"D": 1.5,
	"C": 2.0,
	"B": 2.5,
	"A": 3.0,
	"S": 4.0,
	"SS": 5.0,
	"SSS": 6.0
}

@export var quest_difficulty_multipliers: Dictionary = {
	"TRIVIAL": 0.5,
	"EASY": 0.75,
	"NORMAL": 1.0,
	"HARD": 1.5,
	"EXTREME": 2.0,
	"LEGENDARY": 3.0
}

@export var quest_type_reward_bonuses: Dictionary = {
	"GATHERING": {"gold": 1.0, "influence": 0.8, "experience": 1.2},
	"HUNTING_TRAPPING": {"gold": 1.2, "influence": 1.0, "experience": 1.0},
	"DIPLOMACY": {"gold": 0.8, "influence": 1.5, "experience": 1.1},
	"CARAVAN_GUARDING": {"gold": 1.1, "influence": 1.0, "experience": 0.9},
	"ESCORTING": {"gold": 1.0, "influence": 1.2, "experience": 1.0},
	"STEALTH": {"gold": 1.3, "influence": 0.7, "experience": 1.3},
	"ODD_JOBS": {"gold": 0.9, "influence": 0.9, "experience": 1.0},
	"EMERGENCY": {"gold": 2.0, "influence": 2.0, "experience": 1.5}
}

# Quest Success Calculation
@export var stat_overage_bonus: float = 0.05  # 5% bonus per point over requirement
@export var substat_overage_bonus: float = 0.1  # 10% bonus per point over requirement
@export var class_requirement_bonus: float = 0.2  # 20% bonus for meeting class requirements
@export var party_size_bonus: float = 0.1  # 10% bonus per additional party member

# Injury System
@export var injury_chances: Dictionary = {
	"TRIVIAL": 0.0,
	"EASY": 0.05,
	"NORMAL": 0.1,
	"HARD": 0.2,
	"EXTREME": 0.3,
	"LEGENDARY": 0.4
}

@export var injury_severity_ranges: Dictionary = {
	"PHYSICAL_WOUND": {"min": 20, "max": 60},
	"MENTAL_TRAUMA": {"min": 15, "max": 50},
	"CURSED_AFFLICTION": {"min": 30, "max": 70},
	"EXHAUSTION": {"min": 10, "max": 40},
	"POISON": {"min": 25, "max": 65}
}

@export var injury_duration_multipliers: Dictionary = {
	"PHYSICAL_WOUND": 1.0,
	"MENTAL_TRAUMA": 1.5,
	"CURSED_AFFLICTION": 2.0,
	"EXHAUSTION": 0.5,
	"POISON": 1.2
}

# Guild Progression
@export var guild_level_requirements: Dictionary = {
	1: 0,
	2: 100,
	3: 250,
	4: 500,
	5: 1000,
	6: 2000,
	7: 4000,
	8: 8000,
	9: 16000,
	10: 32000
}

@export var room_unlock_costs: Dictionary = {
	"training_room": {"gold": 500, "influence": 200, "building_materials": 50},
	"library": {"gold": 750, "influence": 300, "building_materials": 75},
	"workshop": {"gold": 1000, "influence": 400, "building_materials": 100},
	"armory": {"gold": 800, "influence": 350, "building_materials": 80},
	"healers_guild": {"gold": 600, "influence": 250, "building_materials": 60},
	"merchants_guild": {"gold": 1200, "influence": 500, "building_materials": 120},
	"blacksmiths_guild": {"gold": 900, "influence": 400, "building_materials": 90}
}

@export var guild_upgrade_costs: Dictionary = {
	"roster_size": {"gold": 200, "influence": 100},
	"quest_slots": {"gold": 300, "influence": 150},
	"storage_capacity": {"gold": 150, "influence": 75},
	"recruitment_quality": {"gold": 400, "influence": 200}
}

# Starting Values
@export var starting_gold: int = 50
@export var starting_influence: int = 100
@export var starting_food: int = 20
@export var starting_building_materials: int = 0

# Training System
@export var training_costs: Dictionary = {
	"health": {"gold": 50, "time": 60},
	"defense": {"gold": 45, "time": 60},
	"attack": {"gold": 55, "time": 60},
	"speed": {"gold": 40, "time": 60},
	"intelligence": {"gold": 60, "time": 60},
	"charisma": {"gold": 50, "time": 60},
	"gathering": {"gold": 30, "time": 45},
	"hunting": {"gold": 35, "time": 45},
	"diplomacy": {"gold": 40, "time": 45},
	"stealth": {"gold": 45, "time": 45},
	"leadership": {"gold": 50, "time": 45},
	"survival": {"gold": 35, "time": 45}
}

@export var training_success_rates: Dictionary = {
	"ONE_STAR": 0.6,
	"TWO_STAR": 0.75,
	"THREE_STAR": 0.9
}

@export var training_stat_gains: Dictionary = {
	"ONE_STAR": {"min": 1, "max": 2},
	"TWO_STAR": {"min": 2, "max": 3},
	"THREE_STAR": {"min": 3, "max": 4}
}

# Equipment System
@export var equipment_stat_bonuses: Dictionary = {
	"COMMON": {"multiplier": 1.0, "base_bonus": 5},
	"UNCOMMON": {"multiplier": 1.2, "base_bonus": 8},
	"RARE": {"multiplier": 1.5, "base_bonus": 12},
	"EPIC": {"multiplier": 2.0, "base_bonus": 18},
	"LEGENDARY": {"multiplier": 2.5, "base_bonus": 25},
	"ARTIFACT": {"multiplier": 3.0, "base_bonus": 35}
}

@export var equipment_durability: Dictionary = {
	"COMMON": 100,
	"UNCOMMON": 150,
	"RARE": 200,
	"EPIC": 300,
	"LEGENDARY": 500,
	"ARTIFACT": 1000
}

# Economy
@export var item_base_values: Dictionary = {
	"gold": 1,
	"influence": 1,
	"food": 2,
	"building_materials": 5,
	"weapons": 50,
	"armor_pieces": 40,
	"ore": 10,
	"wood": 3,
	"fibers": 2,
	"monster_parts": 15,
	"herbs": 8,
	"gems": 100
}

@export var vendor_price_multipliers: Dictionary = {
	"merchants_guild": 0.8,  # Buy at 80% of base value
	"blacksmiths_guild": 0.7,  # Buy at 70% of base value
	"auction_house": 1.5  # Sell at 150% of base value
}

# Time and Duration
@export var quest_duration_base: float = 300.0  # 5 minutes base
@export var quest_duration_variance: float = 0.2  # ±20% variance
@export var training_duration_base: float = 60.0  # 1 minute base
@export var injury_recovery_base: float = 1800.0  # 30 minutes base

# UI and UX
@export var notification_durations: Dictionary = {
	"quest_completed": 5.0,
	"character_leveled": 3.0,
	"character_injured": 4.0,
	"resource_gained": 2.0,
	"room_unlocked": 6.0
}

@export var auto_save_intervals: Dictionary = {
	"normal": 600.0,  # 10 minutes
	"frequent": 300.0,  # 5 minutes
	"rare": 1800.0  # 30 minutes
}

## Get recruitment cost for character quality
func get_recruitment_cost(quality: Character.Quality) -> int:
	var quality_name = Character.Quality.keys()[quality]
	return character_recruitment_costs.get(quality_name, 100)

## Get experience requirement for rank
func get_experience_requirement(rank: Character.Rank) -> int:
	var rank_name = Character.Rank.keys()[rank]
	return experience_requirements.get(rank_name, 100)

## Get quest reward multiplier for rank
func get_quest_reward_multiplier(rank: Quest.QuestRank) -> float:
	var rank_name = Quest.QuestRank.keys()[rank]
	return quest_reward_multipliers.get(rank_name, 1.0)

## Get quest difficulty multiplier
func get_quest_difficulty_multiplier(difficulty: Quest.QuestDifficulty) -> float:
	var difficulty_name = Quest.QuestDifficulty.keys()[difficulty]
	return quest_difficulty_multipliers.get(difficulty_name, 1.0)

## Get training cost for stat
func get_training_cost(stat_name: String) -> Dictionary:
	return training_costs.get(stat_name, {"gold": 50, "time": 60})

## Get training success rate for quality
func get_training_success_rate(quality: Character.Quality) -> float:
	var quality_name = Character.Quality.keys()[quality]
	return training_success_rates.get(quality_name, 0.6)

## Get injury chance for difficulty
func get_injury_chance(difficulty: Quest.QuestDifficulty) -> float:
	var difficulty_name = Quest.QuestDifficulty.keys()[difficulty]
	return injury_chances.get(difficulty_name, 0.1)

## Get room unlock cost
func get_room_unlock_cost(room_name: String) -> Dictionary:
	return room_unlock_costs.get(room_name, {"gold": 500, "influence": 200, "building_materials": 50})

## Get guild upgrade cost
func get_guild_upgrade_cost(upgrade_type: String) -> Dictionary:
	return guild_upgrade_costs.get(upgrade_type, {"gold": 200, "influence": 100})
