class_name CharacterService
extends BaseService

## Service for managing character business logic
## Handles recruitment, training, progression, and character operations

var _character_repository: CharacterRepository
var _guild_service: GuildService

# Service statistics
var _characters_recruited: int = 0
var _characters_trained: int = 0
var _characters_promoted: int = 0
var _total_recruitment_cost: int = 0
var _total_training_cost: int = 0

func _init():
	super._init("CharacterService")

## Initialize with character repository
func initialize_with_repository(character_repository: CharacterRepository, guild_service: GuildService = null) -> void:
	_character_repository = character_repository
	_guild_service = guild_service

## Recruit a new character
func recruit_character(character_data: Dictionary) -> Character:
	if not _validate_dependencies():
		return null
	
	# Create character from data
	var character = _create_character_from_data(character_data)
	if not character:
		return null
	
	# Calculate recruitment cost
	var recruitment_cost = _calculate_recruitment_cost(character)
	
	# Check if guild can afford recruitment
	if _guild_service and not _guild_service.can_afford_cost({"gold": recruitment_cost}):
		emit_simple_event("insufficient_resources", {
			"required": {"gold": recruitment_cost},
			"operation": "character_recruitment"
		})
		return null
	
	# Add character to repository
	if _character_repository.add(character):
		# Deduct cost from guild
		if _guild_service:
			_guild_service.spend_resources({"gold": recruitment_cost})
		
		# Update statistics
		_characters_recruited += 1
		_total_recruitment_cost += recruitment_cost
		
		# Emit recruitment event
		var event = CharacterEvents.CharacterRecruitedEvent.new(character, recruitment_cost)
		emit_event(event)
		
		log_activity("Recruited character: " + character.character_name + " for " + str(recruitment_cost) + " gold")
		return character
	
	return null

## Create character from data dictionary
func _create_character_from_data(data: Dictionary) -> Character:
	var character = Character.new()
	
	# Set basic properties
	character.character_name = data.get("name", "Unknown")
	character.character_class = data.get("class", Character.CharacterClass.TANK)
	character.quality = data.get("quality", Character.Quality.ONE_STAR)
	character.rank = data.get("rank", Character.Rank.F)
	character.level = data.get("level", 1)
	
	# Set base stats
	character.health = data.get("health", 100)
	character.defense = data.get("defense", 10)
	character.attack = data.get("attack", 10)
	character.speed = data.get("speed", 10)
	character.intelligence = data.get("intelligence", 10)
	character.charisma = data.get("charisma", 10)
	
	# Set substats
	character.gathering = data.get("gathering", 0)
	character.hunting = data.get("hunting", 0)
	character.diplomacy = data.get("diplomacy", 0)
	character.stealth = data.get("stealth", 0)
	character.leadership = data.get("leadership", 0)
	character.survival = data.get("survival", 0)
	
	# Apply quality bonuses
	_apply_quality_bonuses(character)
	
	# Set recruitment cost
	character.recruitment_cost = _calculate_recruitment_cost(character)
	
	return character

## Apply quality-based bonuses to character
func _apply_quality_bonuses(character: Character) -> void:
	var bonus = _balance_config.character_recruitment_quality_bonuses.get(
		Character.Quality.keys()[character.quality], 0
	)
	
	# Apply bonus to all stats
	character.health += bonus
	character.defense += bonus
	character.attack += bonus
	character.speed += bonus
	character.intelligence += bonus
	character.charisma += bonus

## Calculate recruitment cost for character
func _calculate_recruitment_cost(character: Character) -> int:
	var base_cost = _balance_config.get_recruitment_cost(character.quality)
	var rank_multiplier = 1.0 + (Character.Rank.keys().find(Character.Rank.keys()[character.rank]) * 0.1)
	var level_multiplier = 1.0 + (character.level - 1) * 0.05
	
	return int(base_cost * rank_multiplier * level_multiplier)

## Train character in a specific stat
func train_character(character: Character, stat_name: String) -> bool:
	if not _validate_dependencies():
		return false
	
	# Check if character is available for training
	if not character.is_available():
		emit_simple_event("character_not_available", {
			"character_id": character.id,
			"character_name": character.character_name,
			"operation": "training"
		})
		return false
	
	# Get training cost
	var training_cost = _balance_config.get_training_cost(stat_name)
	
	# Check if guild can afford training
	if _guild_service and not _guild_service.can_afford_cost(training_cost):
		emit_simple_event("insufficient_resources", {
			"required": training_cost,
			"operation": "character_training"
		})
		return false
	
	# Calculate training success
	var success_rate = _balance_config.get_training_success_rate(character.quality)
	var success = randf() < success_rate
	
	if success:
		# Calculate stat improvement
		var improvement_range = _balance_config.training_stat_gains.get(
			Character.Quality.keys()[character.quality], {"min": 1, "max": 2}
		)
		var improvement = randi_range(improvement_range.min, improvement_range.max)
		
		# Apply improvement
		var old_value = character.get(stat_name)
		character.set(stat_name, old_value + improvement)
		
		# Deduct cost from guild
		if _guild_service:
			_guild_service.spend_resources(training_cost)
		
		# Update repository
		_character_repository.update(character)
		
		# Update statistics
		_characters_trained += 1
		_total_training_cost += training_cost.get("gold", 0)
		
		# Emit training completed event
		var improvements = {stat_name: improvement}
		var event = CharacterEvents.CharacterTrainingCompletedEvent.new(character, stat_name, improvements)
		emit_event(event)
		
		log_activity("Trained " + character.character_name + " in " + stat_name + " (+" + str(improvement) + ")")
		return true
	else:
		# Training failed - still deduct cost
		if _guild_service:
			_guild_service.spend_resources(training_cost)
		
		log_activity("Training failed for " + character.character_name + " in " + stat_name)
		return false

## Add experience to character
func add_experience(character: Character, experience_amount: int) -> bool:
	if not _validate_dependencies():
		return false
	
	var old_level = character.level
	var old_experience = character.experience
	
	# Add experience
	character.experience += experience_amount
	character.total_experience_gained += experience_amount
	
	# Check for level up
	var leveled_up = _check_and_process_level_up(character)
	
	# Check for promotion
	var promoted = _check_and_process_promotion(character)
	
	# Update repository
	_character_repository.update(character)
	
	# Emit experience gained event
	emit_simple_event("character_experience_gained", {
		"character_id": character.id,
		"character_name": character.character_name,
		"experience_gained": experience_amount,
		"new_total": character.total_experience_gained,
		"leveled_up": leveled_up,
		"promoted": promoted
	})
	
	log_activity("Added " + str(experience_amount) + " experience to " + character.character_name)
	return true

## Check and process level up
func _check_and_process_level_up(character: Character) -> bool:
	var experience_needed = character.get_experience_to_next_level()
	
	if character.experience >= experience_needed:
		# Level up
		character.level += 1
		character.experience -= experience_needed
		
		# Apply stat gains
		_apply_level_up_stat_gains(character)
		
		# Emit level up event
		var event = CharacterEvents.CharacterLeveledUpEvent.new(
			character, character.level - 1, character.level, experience_needed
		)
		emit_event(event)
		
		log_activity(character.character_name + " leveled up to level " + str(character.level))
		return true
	
	return false

## Apply stat gains on level up
func _apply_level_up_stat_gains(character: Character) -> void:
	var char_class_name = Character.CharacterClass.keys()[character.character_class]
	var stat_gains = _balance_config.level_up_stat_gains.get(char_class_name, {})
	
	for stat in stat_gains:
		var current_value = character.get(stat)
		var gain = stat_gains[stat]
		character.set(stat, current_value + gain)

## Check and process promotion
func _check_and_process_promotion(character: Character) -> bool:
	var current_rank_exp = _get_rank_experience_requirement(character.rank)
	var next_rank = _get_next_rank(character.rank)
	var next_rank_exp = _get_rank_experience_requirement(next_rank)
	
	if character.total_experience_gained >= next_rank_exp and next_rank != character.rank:
		var old_rank = character.rank
		character.rank = next_rank
		character.promotion_count += 1
		
		# Emit promotion event
		var event = CharacterEvents.CharacterPromotedEvent.new(character, old_rank, next_rank)
		emit_event(event)
		
		# Update statistics
		_characters_promoted += 1
		
		log_activity(character.character_name + " promoted to rank " + Character.Rank.keys()[next_rank])
		return true
	
	return false

## Get experience requirement for rank
func _get_rank_experience_requirement(rank: Character.Rank) -> int:
	return _balance_config.get_experience_requirement(rank)

## Get next rank
func _get_next_rank(current_rank: Character.Rank) -> Character.Rank:
	var ranks = Character.Rank.values()
	var current_index = ranks.find(current_rank)
	if current_index < ranks.size() - 1:
		return ranks[current_index + 1]
	return current_rank

## Heal character injury
func heal_character(character: Character, healing_cost: Dictionary = {}) -> bool:
	if not _validate_dependencies():
		return false
	
	if character.current_injury == Character.InjuryType.NONE:
		return false  # No injury to heal
	
	# Check if guild can afford healing
	if _guild_service and not _guild_service.can_afford_cost(healing_cost):
		emit_simple_event("insufficient_resources", {
			"required": healing_cost,
			"operation": "character_healing"
		})
		return false
	
	# Heal the character
	var injury_type = character.current_injury
	character.current_injury = Character.InjuryType.NONE
	character.injury_severity = 0
	character.injury_duration = 0.0
	
	# Deduct healing cost
	if _guild_service:
		_guild_service.spend_resources(healing_cost)
	
	# Update repository
	_character_repository.update(character)
	
	# Emit healing event
	var event = CharacterEvents.CharacterHealedEvent.new(character, injury_type)
	emit_event(event)
	
	log_activity("Healed " + character.character_name + " from " + Character.InjuryType.keys()[injury_type])
	return true

## Get character statistics
func get_character_statistics() -> Dictionary:
	var repo_stats = _character_repository.get_character_statistics() if _character_repository else {}
	
	return {
		"service_name": _service_name,
		"characters_recruited": _characters_recruited,
		"characters_trained": _characters_trained,
		"characters_promoted": _characters_promoted,
		"total_recruitment_cost": _total_recruitment_cost,
		"total_training_cost": _total_training_cost,
		"repository_stats": repo_stats
	}

## Get service statistics
func get_statistics() -> Dictionary:
	var base_stats = super.get_statistics()
	var char_stats = get_character_statistics()
	base_stats.merge(char_stats)
	return base_stats
