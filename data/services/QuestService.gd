class_name QuestService
extends BaseService

## Service for managing quest business logic
## Handles quest generation, validation, completion, and rewards

var _quest_repository: QuestRepository
var _character_service: CharacterService
var _guild_service: GuildService

# Service statistics
var _quests_generated: int = 0
var _quests_started: int = 0
var _quests_completed: int = 0
var _quests_failed: int = 0
var _total_rewards_given: Dictionary = {}
var _last_error: String = ""

func _init():
	super._init("QuestService")

## Initialize with quest repository
func initialize_with_repository(quest_repository: QuestRepository, character_service: CharacterService = null, guild_service: GuildService = null) -> void:
	_quest_repository = quest_repository
	_character_service = character_service
	_guild_service = guild_service

## Validate that all dependencies are available
func _validate_dependencies() -> bool:
	if not _quest_repository:
		_last_error = "Quest repository not available"
		push_error(_service_name + ": " + _last_error)
		return false
	_last_error = ""
	return true

## Generate a new quest
func generate_quest(quest_type: Quest.QuestType = Quest.QuestType.GATHERING,quest_dif = Quest.QuestDifficulty.TRIVIAL, quest_rank: Quest.QuestRank = Quest.QuestRank.F) -> Quest:
	if not _validate_dependencies():
		return null
	
	var quest = _create_quest_from_template(quest_type,quest_dif, quest_rank)
	if not quest:
		return null
	
	# Add to repository
	if _quest_repository.add(quest):
		_quests_generated += 1
		
		# Emit quest generated event
		var event = QuestEvents.QuestGeneratedEvent.new(quest)
		emit_event(event)
		
		log_activity("Generated quest: " + quest.quest_name)
		return quest
	
	return null

## Create quest from template
func _create_quest_from_template(quest_type: Quest.QuestType,quest_dif: Quest.QuestDifficulty, quest_rank: Quest.QuestRank) -> Quest:
	var quest = Quest.new()
	
	# Set basic properties
	quest.quest_type = quest_type
	quest.quest_rank = quest_rank
	
	if quest_dif == null :
		quest.difficulty = _get_random_difficulty()
	else : 
		quest.difficulty = quest_dif
	
	# Generate quest details
	_generate_quest_details(quest)
	_generate_quest_requirements(quest)
	_generate_quest_rewards(quest)
	_generate_quest_risks(quest)
	
	# Set timing
	quest.duration = _calculate_quest_duration(quest)
	
	return quest

## Generate quest details (name, description, etc.)
func _generate_quest_details(quest: Quest) -> void:
	var quest_templates = _get_quest_templates()
	var template = quest_templates.get(Quest.QuestType.keys()[quest.quest_type], {})
	
	quest.quest_name = template.get("name", "Unknown Quest")
	quest.description = template.get("description", "A mysterious quest awaits.")
	quest.quest_giver = template.get("giver", "Local Merchant")
	quest.location = template.get("location", "Unknown Location")

## Get quest templates
func _get_quest_templates() -> Dictionary:
	return {
		"GATHERING": {
			"name": "Gather Resources",
			"description": "Collect valuable materials from the wilderness",
			"giver": "Local Merchant",
			"location": "Forest"
		},
		"HUNTING": {
			"name": "Hunt Dangerous Beasts",
			"description": "Track and eliminate threatening creatures",
			"giver": "Village Elder",
			"location": "Wilderness"
		},
		"DIPLOMACY": {
			"name": "Diplomatic Mission",
			"description": "Negotiate with neighboring settlements",
			"giver": "Town Mayor",
			"location": "Neighboring Town"
		},
		"CARAVAN_GUARDING": {
			"name": "Caravan Escort",
			"description": "Protect merchant caravans from bandits",
			"giver": "Merchant Guild",
			"location": "Trade Route"
		},
		"ESCORT": {
			"name": "Noble Escort",
			"description": "Safely escort important personages",
			"giver": "Noble House",
			"location": "Various"
		},
		"STEALTH": {
			"name": "Stealth Operation",
			"description": "Infiltrate and gather intelligence",
			"giver": "Spymaster",
			"location": "Enemy Territory"
		},
		"ODD_JOB": {
			"name": "Odd Jobs",
			"description": "Various miscellaneous tasks",
			"giver": "Local Residents",
			"location": "Town"
		},
		"EMERGENCY": {
			"name": "Emergency Response",
			"description": "Urgent mission requiring immediate action",
			"giver": "Town Council",
			"location": "Various"
		}
	}

## Generate quest requirements
func _generate_quest_requirements(quest: Quest) -> void:
	var rank_multiplier = quest.get_rank_multiplier()
	var difficulty_multiplier = quest.get_difficulty_multiplier()
	var base_requirements = _get_base_requirements_for_type(quest.quest_type)
	
	# Set party size requirements
	quest.min_party_size = max(1, int(base_requirements.min_party_size * difficulty_multiplier))
	quest.max_party_size = min(5, int(base_requirements.max_party_size * difficulty_multiplier))
	
	# Set class requirements
	quest.required_tank = base_requirements.required_tank
	quest.required_healer = base_requirements.required_healer
	quest.required_support = base_requirements.required_support
	quest.required_attacker = base_requirements.required_attacker
	
	# Set job requirements
	if base_requirements.has("required_jobs"):
		quest.required_jobs.assign(base_requirements.required_jobs)
	else:
		quest.required_jobs = []
	
	# Set stat requirements
	var stat_req_multiplier = rank_multiplier * difficulty_multiplier
	quest.min_total_health = int(base_requirements.min_total_health * stat_req_multiplier)
	quest.min_total_defense = int(base_requirements.min_total_defense * stat_req_multiplier)
	quest.min_total_attack = int(base_requirements.min_total_attack * stat_req_multiplier)
	quest.min_total_speed = int(base_requirements.min_total_speed * stat_req_multiplier)
	quest.min_total_intelligence = int(base_requirements.min_total_intelligence * stat_req_multiplier)
	quest.min_total_charisma = int(base_requirements.min_total_charisma * stat_req_multiplier)
	
	# Set substat requirements
	quest.min_gathering = int(base_requirements.min_gathering * stat_req_multiplier)
	quest.min_hunting = int(base_requirements.min_hunting * stat_req_multiplier)
	quest.min_diplomacy = int(base_requirements.min_diplomacy * stat_req_multiplier)
	quest.min_stealth = int(base_requirements.min_stealth * stat_req_multiplier)
	quest.min_leadership = int(base_requirements.min_leadership * stat_req_multiplier)
	quest.min_survival = int(base_requirements.min_survival * stat_req_multiplier)

## Get base requirements for quest type
func _get_base_requirements_for_type(quest_type: Quest.QuestType) -> Dictionary:
	var requirements = {
		"GATHERING": {
			"min_party_size": 1, "max_party_size": 3,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": ["HERBALIST", "SCOUT"],
			"min_total_health": 40, "min_total_defense": 15, "min_total_attack": 10, "min_total_speed": 20, "min_total_intelligence": 15, "min_total_charisma": 5,
			"min_gathering": 20, "min_hunting": 5, "min_diplomacy": 0, "min_stealth": 8, "min_leadership": 0, "min_survival": 15
		},
		"HUNTING": {
			"min_party_size": 2, "max_party_size": 4,
			"required_tank": true, "required_healer": false, "required_support": false, "required_attacker": true,
			"required_jobs": ["HUNTER", "RANGER"],
			"min_total_health": 120, "min_total_defense": 35, "min_total_attack": 45, "min_total_speed": 25, "min_total_intelligence": 20, "min_total_charisma": 10,
			"min_gathering": 0, "min_hunting": 25, "min_diplomacy": 0, "min_stealth": 15, "min_leadership": 8, "min_survival": 20
		},
		"DIPLOMACY": {
			"min_party_size": 1, "max_party_size": 3,
			"required_tank": false, "required_healer": false, "required_support": true, "required_attacker": false,
			"required_jobs": ["DIPLOMAT", "BARD", "MERCHANT"],
			"min_total_health": 50, "min_total_defense": 10, "min_total_attack": 5, "min_total_speed": 15, "min_total_intelligence": 30, "min_total_charisma": 35,
			"min_gathering": 0, "min_hunting": 0, "min_diplomacy": 25, "min_stealth": 5, "min_leadership": 20, "min_survival": 5
		},
		"CARAVAN_GUARDING": {
			"min_party_size": 3, "max_party_size": 5,
			"required_tank": true, "required_healer": true, "required_support": true, "required_attacker": true,
			"required_jobs": ["GUARD", "KNIGHT"],
			"min_total_health": 130, "min_total_defense": 45, "min_total_attack": 40, "min_total_speed": 20, "min_total_intelligence": 15, "min_total_charisma": 20,
			"min_gathering": 0, "min_hunting": 8, "min_diplomacy": 10, "min_stealth": 0, "min_leadership": 15, "min_survival": 18
		},
		"ESCORT": {
			"min_party_size": 2, "max_party_size": 2,
			"required_tank": true, "required_healer": true, "required_support": false, "required_attacker": false,
			"required_jobs": ["GUARD", "PRIEST"],
			"min_total_health": 110, "min_total_defense": 40, "min_total_attack": 20, "min_total_speed": 25, "min_total_intelligence": 15, "min_total_charisma": 30,
			"min_gathering": 0, "min_hunting": 5, "min_diplomacy": 20, "min_stealth": 8, "min_leadership": 25, "min_survival": 12
		},
		"STEALTH": {
			"min_party_size": 1, "max_party_size": 2,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": ["ROGUE", "ASSASSIN", "SCOUT"],
			"min_total_health": 60, "min_total_defense": 15, "min_total_attack": 35, "min_total_speed": 45, "min_total_intelligence": 40, "min_total_charisma": 15,
			"min_gathering": 0, "min_hunting": 8, "min_diplomacy": 5, "min_stealth": 30, "min_leadership": 5, "min_survival": 20
		},
		"ODD_JOB": {
			"min_party_size": 1, "max_party_size": 2,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": [],
			"min_total_health": 35, "min_total_defense": 12, "min_total_attack": 12, "min_total_speed": 18, "min_total_intelligence": 18, "min_total_charisma": 18,
			"min_gathering": 8, "min_hunting": 8, "min_diplomacy": 8, "min_stealth": 8, "min_leadership": 8, "min_survival": 8
		},
		"EMERGENCY": {
			"min_party_size": 4, "max_party_size": 5,
			"required_tank": true, "required_healer": true, "required_support": true, "required_attacker": true,
			"required_jobs": ["KNIGHT", "PRIEST"],
			"min_total_health": 160, "min_total_defense": 55, "min_total_attack": 55, "min_total_speed": 30, "min_total_intelligence": 25, "min_total_charisma": 30,
			"min_gathering": 0, "min_hunting": 12, "min_diplomacy": 15, "min_stealth": 5, "min_leadership": 25, "min_survival": 25
		},
		"EXPLORATION": {
			"min_party_size": 1, "max_party_size": 3,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": ["SCOUT", "RANGER", "SCHOLAR"],
			"min_total_health": 60, "min_total_defense": 20, "min_total_attack": 15, "min_total_speed": 30, "min_total_intelligence": 25, "min_total_charisma": 10,
			"min_gathering": 12, "min_hunting": 10, "min_diplomacy": 5, "min_stealth": 15, "min_leadership": 8, "min_survival": 20
		},
		"ASSASSINATION": {
			"min_party_size": 1, "max_party_size": 1,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": true,
			"required_jobs": ["ASSASSIN", "ROGUE"],
			"min_total_health": 45, "min_total_defense": 15, "min_total_attack": 40, "min_total_speed": 50, "min_total_intelligence": 35, "min_total_charisma": 20,
			"min_gathering": 0, "min_hunting": 5, "min_diplomacy": 0, "min_stealth": 35, "min_leadership": 0, "min_survival": 15
		},
		"RECONNAISSANCE": {
			"min_party_size": 1, "max_party_size": 2,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": ["SCOUT", "RANGER"],
			"min_total_health": 50, "min_total_defense": 15, "min_total_attack": 10, "min_total_speed": 35, "min_total_intelligence": 30, "min_total_charisma": 8,
			"min_gathering": 5, "min_hunting": 12, "min_diplomacy": 0, "min_stealth": 25, "min_leadership": 5, "min_survival": 20
		},
		"INVESTIGATION": {
			"min_party_size": 1, "max_party_size": 1,
			"required_tank": false, "required_healer": false, "required_support": true, "required_attacker": false,
			"required_jobs": ["SCHOLAR", "DETECTIVE"],
			"min_total_health": 40, "min_total_defense": 10, "min_total_attack": 8, "min_total_speed": 20, "min_total_intelligence": 40, "min_total_charisma": 25,
			"min_gathering": 0, "min_hunting": 0, "min_diplomacy": 20, "min_stealth": 15, "min_leadership": 10, "min_survival": 8
		},
		"RESCUE": {
			"min_party_size": 2, "max_party_size": 3,
			"required_tank": false, "required_healer": true, "required_support": true, "required_attacker": false,
			"required_jobs": ["PRIEST", "KNIGHT"],
			"min_total_health": 100, "min_total_defense": 30, "min_total_attack": 20, "min_total_speed": 25, "min_total_intelligence": 20, "min_total_charisma": 25,
			"min_gathering": 0, "min_hunting": 8, "min_diplomacy": 15, "min_stealth": 10, "min_leadership": 20, "min_survival": 18
		},
		"DELIVERY": {
			"min_party_size": 1, "max_party_size": 4,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": false,
			"required_jobs": ["MERCHANT", "COURIER"],
			"min_total_health": 45, "min_total_defense": 18, "min_total_attack": 12, "min_total_speed": 25, "min_total_intelligence": 15, "min_total_charisma": 20,
			"min_gathering": 0, "min_hunting": 0, "min_diplomacy": 15, "min_stealth": 5, "min_leadership": 10, "min_survival": 12
		},
		"UNIQUE_MONSTER_HUNT": {
			"min_party_size": 2, "max_party_size": 2,
			"required_tank": false, "required_healer": false, "required_support": false, "required_attacker": true,
			"required_jobs": ["HUNTER", "RANGER"],
			"min_total_health": 100, "min_total_defense": 30, "min_total_attack": 50, "min_total_speed": 30, "min_total_intelligence": 20, "min_total_charisma": 15,
			"min_gathering": 0, "min_hunting": 30, "min_diplomacy": 0, "min_stealth": 12, "min_leadership": 10, "min_survival": 25
		},
		"RAID": {
			"min_party_size": 4, "max_party_size": 5,
			"required_tank": true, "required_healer": true, "required_support": true, "required_attacker": true,
			"required_jobs": ["KNIGHT", "PRIEST"],
			"min_total_health": 160, "min_total_defense": 55, "min_total_attack": 55, "min_total_speed": 30, "min_total_intelligence": 25, "min_total_charisma": 30,
			"min_gathering": 0, "min_hunting": 12, "min_diplomacy": 15, "min_stealth": 5, "min_leadership": 25, "min_survival": 25
		},
		"APEX_PREDATOR_HUNT": {
			"min_party_size": 4, "max_party_size": 4,
			"required_tank": true, "required_healer": true, "required_support": true, "required_attacker": true,
			"required_jobs": ["HUNTER", "RANGER", "KNIGHT"],
			"min_total_health": 170, "min_total_defense": 60, "min_total_attack": 60, "min_total_speed": 25, "min_total_intelligence": 30, "min_total_charisma": 25,
			"min_gathering": 0, "min_hunting": 35, "min_diplomacy": 10, "min_stealth": 8, "min_leadership": 30, "min_survival": 30
		}
	}
	
	return requirements.get(Quest.QuestType.keys()[quest_type], requirements["ODD_JOB"])

## Generate quest rewards
func _generate_quest_rewards(quest: Quest) -> void:
	var rank_multiplier = quest.get_rank_multiplier()
	var difficulty_multiplier = quest.get_difficulty_multiplier()
	var type_bonuses = _balance_config.quest_type_reward_bonuses.get(
		Quest.QuestType.keys()[quest.quest_type], {"gold": 1.0, "influence": 1.0, "experience": 1.0}
	)
	
	var base_rewards = _get_base_rewards_for_rank(quest.quest_rank)
	
	# Calculate rewards
	quest.gold_reward = int(base_rewards.gold * rank_multiplier * difficulty_multiplier * type_bonuses.gold)
	quest.influence_reward = int(base_rewards.influence * rank_multiplier * difficulty_multiplier * type_bonuses.influence)
	quest.experience_reward = int(base_rewards.experience * rank_multiplier * difficulty_multiplier * type_bonuses.experience)
	
	# Add material rewards based on quest type
	quest.material_rewards = _generate_material_rewards(quest.quest_type, quest.quest_rank)

## Get base rewards for rank
func _get_base_rewards_for_rank(quest_rank: Quest.QuestRank) -> Dictionary:
	var base_rewards = {
		"F": {"gold": 50, "influence": 20, "experience": 30},
		"E": {"gold": 75, "influence": 30, "experience": 45},
		"D": {"gold": 100, "influence": 40, "experience": 60},
		"C": {"gold": 150, "influence": 60, "experience": 90},
		"B": {"gold": 200, "influence": 80, "experience": 120},
		"A": {"gold": 300, "influence": 120, "experience": 180},
		"S": {"gold": 500, "influence": 200, "experience": 300},
		"SS": {"gold": 750, "influence": 300, "experience": 450},
		"SSS": {"gold": 1000, "influence": 400, "experience": 600}
	}
	
	return base_rewards.get(Quest.QuestRank.keys()[quest_rank], base_rewards["F"])

## Generate material rewards
func _generate_material_rewards(quest_type: Quest.QuestType, quest_rank: Quest.QuestRank) -> Dictionary:
	var materials: Dictionary = {}
	var rank_multiplier = Quest.QuestRank.keys().find(Quest.QuestRank.keys()[quest_rank]) + 1
	
	match quest_type:
		Quest.QuestType.GATHERING:
			materials["herbs"] = randi_range(2, 5) * rank_multiplier
			materials["wood"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.HUNTING:
			materials["monster_parts"] = randi_range(1, 3) * rank_multiplier
			materials["leather"] = randi_range(1, 2) * rank_multiplier
		Quest.QuestType.DIPLOMACY:
			materials["trade_documents"] = 1
		Quest.QuestType.CARAVAN_GUARDING:
			materials["gold"] = randi_range(10, 25) * rank_multiplier
		Quest.QuestType.ESCORT:
			materials["noble_favor"] = 1
		Quest.QuestType.STEALTH:
			materials["intelligence"] = 1
		Quest.QuestType.ODD_JOB:
			materials["misc_items"] = randi_range(1, 3)
		Quest.QuestType.EMERGENCY:
			materials["emergency_supplies"] = randi_range(2, 4) * rank_multiplier
		Quest.QuestType.EXPLORATION:
			materials["exploration_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.ASSASSINATION:
			materials["assassination_kit"] = 1
		Quest.QuestType.RECONNAISSANCE:
			materials["reconnaissance_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.INVESTIGATION:
			materials["investigation_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.RESCUE:
			materials["rescue_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.DELIVERY:
			materials["delivery_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.UNIQUE_MONSTER_HUNT:
			materials["unique_monster_parts"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.RAID:
			materials["raid_supplies"] = randi_range(1, 3) * rank_multiplier
		Quest.QuestType.APEX_PREDATOR_HUNT:
			materials["apex_predator_parts"] = randi_range(1, 3) * rank_multiplier
	
	return materials

## Generate quest risks
func _generate_quest_risks(quest: Quest) -> void:
	var difficulty_multiplier = quest.get_difficulty_multiplier()
	var base_injury_chance = _balance_config.get_injury_chance(quest.difficulty)
	
	quest.injury_chance = base_injury_chance * difficulty_multiplier
	quest.critical_failure_chance = quest.injury_chance * 0.1  # 10% of injury chance
	
	# Set failure penalties
	quest.failure_penalty_gold = int(quest.gold_reward * 0.5)
	quest.failure_penalty_influence = int(quest.influence_reward * 0.3)

## Calculate quest duration
func _calculate_quest_duration(quest: Quest) -> float:
	var base_duration = _balance_config.quest_duration_base
	var rank_multiplier = quest.get_rank_multiplier()
	var difficulty_multiplier = quest.get_difficulty_multiplier()
	var variance = _balance_config.quest_duration_variance
	
	var duration = base_duration * rank_multiplier * difficulty_multiplier
	var variance_amount = duration * variance
	var final_duration = duration + randf_range(-variance_amount, variance_amount)
	
	return max(60.0, final_duration)  # Minimum 1 minute

## Get random difficulty
func _get_random_difficulty() -> Quest.QuestDifficulty:
	var difficulties = Quest.QuestDifficulty.values()
	var weights = [0.1, 0.2, 0.4, 0.2, 0.08, 0.02]  # Weighted towards normal difficulty
	
	var random_value = randf()
	var cumulative_weight = 0.0
	
	for i in range(difficulties.size()):
		cumulative_weight += weights[i]
		if random_value <= cumulative_weight:
			return difficulties[i]
	
	return Quest.QuestDifficulty.NORMAL

## Assign quest to characters (alias for start_quest)
## Check if a quest can be assigned to characters
func can_assign_quest(quest: Quest, characters: Array[Character]) -> bool:
	if not _validate_dependencies():
		return false
	
	if not quest or characters.is_empty():
		return false
	
	# Check if quest is available
	if quest.status != Quest.QuestStatus.NOT_STARTED:
		return false
	
	# Check party size requirements
	if characters.size() < quest.min_party_size or characters.size() > quest.max_party_size:
		return false
	
	# Check if all characters are available
	for character in characters:
		if not character.is_available():
			return false
	
	# Validate quest party requirements
	return _validate_quest_party(quest, characters)

func assign_quest(quest_id: String, character_ids: Array[String]) -> bool:
	if not _validate_dependencies():
		return false
	
	# Get the quest
	var quest = _quest_repository.get_by_id(quest_id)
	if not quest:
		return false
	
	# Get the character objects
	var party: Array[Character] = []
	for char_id in character_ids:
		var character = _character_service._character_repository.get_by_id(char_id)
		if character:
			party.append(character)
	
	if party.is_empty():
		return false
	
	# Use start_quest to handle the assignment
	return start_quest(quest, party)

## Start a quest with a party
func start_quest(quest: Quest, party: Array[Character]) -> bool:
	if not _validate_dependencies():
		return false
	
	# Validate quest and party
	if not _validate_quest_party(quest, party):
		return false
	
	# Set quest status
	quest.status = Quest.QuestStatus.IN_PROGRESS
	quest.start_time = Time.get_unix_time_from_system()
	
	# Set character statuses
	for character in party:
		character.status = Character.CharacterStatus.ON_QUEST
		_character_service._character_repository.update(character)
	
	# Update repository
	_quest_repository.update(quest)
	
	# Update statistics
	_quests_started += 1
	
	# Emit quest started event
	var event = QuestEvents.QuestStartedEvent.new(quest, party)
	emit_event(event)
	
	log_activity("Started quest: " + quest.quest_name + " with party of " + str(party.size()))
	return true

## Validate quest and party compatibility
func _validate_quest_party(quest: Quest, party: Array[Character]) -> bool:
	# Check party size
	if party.size() < quest.min_party_size or party.size() > quest.max_party_size:
		emit_simple_event("invalid_party_size", {
			"quest_id": quest.id,
			"party_size": party.size(),
			"required_min": quest.min_party_size,
			"required_max": quest.max_party_size
		})
		return false
	
	# Check class requirements
	var class_requirements = quest.get_class_requirements()
	var party_classes: Dictionary = {}
	
	for character in party:
		var char_class_name = Character.CharacterClass.keys()[character.character_class].to_lower()
		party_classes[char_class_name] = party_classes.get(char_class_name, 0) + 1
	
	for required_class in class_requirements:
		if class_requirements[required_class] and party_classes.get(required_class, 0) == 0:
			emit_simple_event("missing_required_class", {
				"quest_id": quest.id,
				"required_class": required_class
			})
			return false
	
	# Check stat requirements
	var stat_requirements = quest.get_stat_requirements()
	var party_stats = _calculate_party_stats(party)
	
	for stat in stat_requirements:
		if party_stats.get(stat, 0) < stat_requirements[stat]:
			emit_simple_event("insufficient_stats", {
				"quest_id": quest.id,
				"stat": stat,
				"required": stat_requirements[stat],
				"available": party_stats.get(stat, 0)
			})
			return false
	
	# Check sub-stat requirements
	var substat_requirements = quest.get_substat_requirements()
	var party_substats = _calculate_party_substats(party)
	
	for substat in substat_requirements:
		if party_substats.get(substat, 0) < substat_requirements[substat]:
			emit_simple_event("insufficient_substats", {
				"quest_id": quest.id,
				"substat": substat,
				"required": substat_requirements[substat],
				"available": party_substats.get(substat, 0)
			})
			return false
	
	return true

## Calculate total party stats
func _calculate_party_stats(party: Array[Character]) -> Dictionary:
	var total_stats = {
		"health": 0,
		"defense": 0,
		"attack": 0,
		"speed": 0,
		"intelligence": 0,
		"charisma": 0
	}
	
	for character in party:
		var stats = character.get_effective_stats()
		for stat in stats:
			total_stats[stat] += stats[stat]
	
	return total_stats

## Calculate total party sub-stats
func _calculate_party_substats(party: Array[Character]) -> Dictionary:
	var total_substats = {
		"gathering": 0,
		"hunting": 0,
		"diplomacy": 0,
		"stealth": 0,
		"leadership": 0,
		"survival": 0
	}
	
	for character in party:
		var substats = character.get_substats()
		for substat in substats:
			total_substats[substat] += substats[substat]
	
	return total_substats

## Complete a quest
func complete_quest(quest: Quest, party: Array[Character]) -> bool:
	if not _validate_dependencies():
		return false
	
	# Calculate success rate
	var success_rate = _calculate_quest_success_rate(quest, party)
	var success = randf() < success_rate
	
	# Set quest status
	quest.status = Quest.QuestStatus.COMPLETED if success else Quest.QuestStatus.FAILED
	quest.completion_time = Time.get_unix_time_from_system()
	
	# Process results
	if success:
		_process_quest_success(quest, party)
	else:
		_process_quest_failure(quest, party)
	
	# Update character statuses
	for character in party:
		character.status = Character.CharacterStatus.AVAILABLE
		_character_service._character_repository.update(character)
	
	# Update repository
	_quest_repository.update(quest)
	
	# Update statistics
	if success:
		_quests_completed += 1
	else:
		_quests_failed += 1
	
	# Emit completion event
	var event = QuestEvents.QuestCompletedEvent.new(quest, party, quest.get_all_rewards(), success_rate)
	emit_event(event)
	
	log_activity("Completed quest: " + quest.quest_name + " (Success: " + str(success) + ", Rate: " + str(success_rate) + ")")
	return success

## Fail a quest
func fail_quest(quest: Quest, party: Array[Character]) -> bool:
	if not _validate_dependencies():
		return false
	
	# Set quest status to failed
	quest.status = Quest.QuestStatus.FAILED
	quest.completion_time = Time.get_unix_time_from_system()
	
	# Process failure results
	_process_quest_failure(quest, party)
	
	# Update character statuses
	for character in party:
		character.status = Character.CharacterStatus.AVAILABLE
		_character_service._character_repository.update(character)
	
	# Update repository
	_quest_repository.update(quest)
	
	# Update statistics
	_quests_failed += 1
	
	# Emit failure event
	var failure_reason = "Quest failed due to insufficient party capabilities"
	var penalties = quest.get_failure_penalties()
	var event = QuestEvents.QuestFailedEvent.new(quest, party, failure_reason, penalties)
	emit_event(event)
	
	log_activity("Failed quest: " + quest.quest_name)
	return true

## Calculate quest success rate
func _calculate_quest_success_rate(quest: Quest, party: Array[Character]) -> float:
	var base_success_rate = 0.8  # 80% base success rate
	
	# Calculate stat bonuses
	var stat_requirements = quest.get_stat_requirements()
	var party_stats = _calculate_party_stats(party)
	var stat_bonus = 0.0
	
	for stat in stat_requirements:
		var overage = party_stats.get(stat, 0) - stat_requirements[stat]
		if overage > 0:
			stat_bonus += overage * _balance_config.stat_overage_bonus
	
	# Calculate substat bonuses
	var substat_requirements = quest.get_substat_requirements()
	var party_substats = _calculate_party_substats(party)
	var substat_bonus = 0.0
	
	for substat in substat_requirements:
		var overage = party_substats.get(substat, 0) - substat_requirements[substat]
		if overage > 0:
			substat_bonus += overage * _balance_config.substat_overage_bonus
	
	# Calculate class requirement bonus
	var class_requirements = quest.get_class_requirements()
	var party_classes: Dictionary = {}
	
	for character in party:
		var char_class_name = Character.CharacterClass.keys()[character.character_class].to_lower()
		party_classes[char_class_name] = party_classes.get(char_class_name, 0) + 1
	
	var class_bonus = 0.0
	for required_class in class_requirements:
		if class_requirements[required_class] and party_classes.get(required_class, 0) > 0:
			class_bonus += _balance_config.class_requirement_bonus
	
	# Calculate party size bonus
	var party_size_bonus = (party.size() - 1) * _balance_config.party_size_bonus
	
	# Calculate final success rate
	var final_success_rate = base_success_rate + stat_bonus + substat_bonus + class_bonus + party_size_bonus
	
	return clamp(final_success_rate, 0.1, 0.95)  # Between 10% and 95%

## Process successful quest completion
func _process_quest_success(quest: Quest, party: Array[Character]) -> void:
	# Give rewards to guild
	if _guild_service:
		var rewards = quest.get_all_rewards()
		_guild_service.add_resources(rewards)
		
		# Update total rewards given
		for reward_type in rewards:
			_total_rewards_given[reward_type] = _total_rewards_given.get(reward_type, 0) + rewards[reward_type]
	
	# Give experience to characters
	var experience_per_character = int(quest.experience_reward / float(party.size()))
	for character in party:
		_character_service.add_experience(character, experience_per_character)
	
	# Check for injuries
	_check_for_injuries(quest, party)

## Process failed quest
func _process_quest_failure(quest: Quest, party: Array[Character]) -> void:
	# Apply failure penalties
	if _guild_service:
		var penalties = quest.get_failure_penalties()
		_guild_service.spend_resources(penalties)
	
	# Check for injuries (higher chance on failure)
	_check_for_injuries(quest, party, true)

## Check for character injuries
func _check_for_injuries(quest: Quest, party: Array[Character], is_failure: bool = false) -> void:
	var injury_chance = quest.injury_chance
	if is_failure:
		injury_chance *= 1.5  # 50% higher chance on failure
	
	for character in party:
		if randf() < injury_chance:
			_inflict_injury(character, quest.difficulty)

## Inflict injury on character
func _inflict_injury(character: Character, _difficulty: Quest.QuestDifficulty) -> void:
	var injury_types = Character.InjuryType.values()
	var injury_type = injury_types[randi() % injury_types.size()]
	
	var severity_range = _balance_config.injury_severity_ranges.get(
		Character.InjuryType.keys()[injury_type], {"min": 20, "max": 50}
	)
	var severity = randi_range(severity_range.min, severity_range.max)
	
	var duration_multiplier = _balance_config.injury_duration_multipliers.get(
		Character.InjuryType.keys()[injury_type], 1.0
	)
	var duration = _balance_config.injury_recovery_base * duration_multiplier
	
	# Apply injury
	character.current_injury = injury_type
	character.injury_severity = severity
	character.injury_duration = duration
	character.injury_count += 1
	
	# Update character
	_character_service._character_repository.update(character)
	
	log_activity(character.character_name + " was injured: " + Character.InjuryType.keys()[injury_type])

## Get quest service statistics
func get_quest_statistics() -> Dictionary:
	var repo_stats = _quest_repository.get_quest_statistics() if _quest_repository else {}
	
	return {
		"service_name": _service_name,
		"quests_generated": _quests_generated,
		"quests_started": _quests_started,
		"quests_completed": _quests_completed,
		"quests_failed": _quests_failed,
		"total_rewards_given": _total_rewards_given,
		"repository_stats": repo_stats
	}

## Get service statistics
func get_statistics() -> Dictionary:
	var base_stats = super.get_statistics()
	var quest_stats = get_quest_statistics()
	base_stats.merge(quest_stats)
	return base_stats

## Check if quest generation is possible
func can_generate_quest() -> bool:
	return _validate_dependencies()

## Get the cost of generating a quest
func get_generation_cost() -> Dictionary:
	# For now, quest generation is free
	# In the future, this could check guild resources or other costs
	return {}

## Get the last error message
func get_last_error() -> String:
	return _last_error if "_last_error" in self else ""
