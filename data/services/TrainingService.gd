class_name TrainingService
extends BaseService

## Service for managing character training business logic
## Handles stat improvement, training courses, and training progression

var _character_service: CharacterService
var _guild_service: GuildService

# Service statistics
var _training_sessions_completed: int = 0
var _training_sessions_failed: int = 0
var _total_training_cost: int = 0
var _total_stat_improvements: Dictionary = {}

func _init():
	super._init("TrainingService")

## Initialize with dependencies
func initialize_with_dependencies(character_service: CharacterService, guild_service: GuildService) -> void:
	_character_service = character_service
	_guild_service = guild_service

## Train character in a specific stat
func train_character_stat(character: Character, stat_name: String) -> bool:
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
	var success_rate = _calculate_training_success_rate(character, stat_name)
	var success = randf() < success_rate
	
	# Deduct cost regardless of success
	if _guild_service:
		_guild_service.spend_resources(training_cost)
	
	_total_training_cost += training_cost.get("gold", 0)
	
	if success:
		# Calculate stat improvement
		var improvement = _calculate_stat_improvement(character, stat_name)
		
		# Apply improvement
		var old_value = character.get(stat_name)
		character.set(stat_name, old_value + improvement)
		
		# Update character in repository
		if _character_service and _character_service._character_repository:
			_character_service._character_repository.update(character)
		
		# Update statistics
		_training_sessions_completed += 1
		_total_stat_improvements[stat_name] = _total_stat_improvements.get(stat_name, 0) + improvement
		
		# Emit training completed event
		var improvements = {stat_name: improvement}
		var event = CharacterEvents.CharacterTrainingCompletedEvent.new(character, stat_name, improvements)
		emit_event(event)
		
		log_activity("Training successful: " + character.character_name + " gained +" + str(improvement) + " " + stat_name)
		return true
	else:
		_training_sessions_failed += 1
		log_activity("Training failed: " + character.character_name + " in " + stat_name)
		return false

## Calculate training success rate
func _calculate_training_success_rate(character: Character, stat_name: String) -> float:
	var base_success_rate = _balance_config.get_training_success_rate(character.quality)
	
	# Apply character-specific modifiers
	var character_modifier = _get_character_training_modifier(character, stat_name)
	var level_modifier = _get_level_training_modifier(character.level)
	var rank_modifier = _get_rank_training_modifier(character.rank)
	
	var final_success_rate = base_success_rate * character_modifier * level_modifier * rank_modifier
	
	return clamp(final_success_rate, 0.1, 0.95)  # Between 10% and 95%

## Get character-specific training modifier
func _get_character_training_modifier(character: Character, stat_name: String) -> float:
	# Characters with higher base stats in a stat are better at training that stat
	var base_stat = character.get(stat_name)
	var modifier = 1.0 + (base_stat - 10) * 0.01  # 1% bonus per point over 10
	
	# Quality bonus
	var quality_bonus = {
		Character.Quality.ONE_STAR: 1.0,
		Character.Quality.TWO_STAR: 1.1,
		Character.Quality.THREE_STAR: 1.2
	}
	modifier *= quality_bonus.get(character.quality, 1.0)
	
	return modifier

## Get level-based training modifier
func _get_level_training_modifier(level: int) -> float:
	# Higher level characters are slightly better at training
	return 1.0 + (level - 1) * 0.005  # 0.5% bonus per level

## Get rank-based training modifier
func _get_rank_training_modifier(rank: Character.Rank) -> float:
	var rank_bonuses = {
		Character.Rank.F: 1.0,
		Character.Rank.E: 1.05,
		Character.Rank.D: 1.1,
		Character.Rank.C: 1.15,
		Character.Rank.B: 1.2,
		Character.Rank.A: 1.25,
		Character.Rank.S: 1.3,
		Character.Rank.SS: 1.35,
		Character.Rank.SSS: 1.4
	}
	
	return rank_bonuses.get(rank, 1.0)

## Calculate stat improvement amount
func _calculate_stat_improvement(character: Character, stat_name: String) -> int:
	var improvement_range = _balance_config.training_stat_gains.get(
		Character.Quality.keys()[character.quality], {"min": 1, "max": 2}
	)
	
	var base_improvement = randi_range(improvement_range.min, improvement_range.max)
	
	# Apply character-specific bonuses
	var character_bonus = _get_character_improvement_bonus(character, stat_name)
	var level_bonus = _get_level_improvement_bonus(character.level)
	var rank_bonus = _get_rank_improvement_bonus(character.rank)
	
	var total_improvement = int(base_improvement * character_bonus * level_bonus * rank_bonus)
	
	return max(1, total_improvement)  # Minimum 1 point improvement

## Get character improvement bonus
func _get_character_improvement_bonus(character: Character, stat_name: String) -> float:
	# Characters with higher base stats get slightly better improvements
	var base_stat = character.get(stat_name)
	return 1.0 + (base_stat - 10) * 0.005  # 0.5% bonus per point over 10

## Get level improvement bonus
func _get_level_improvement_bonus(level: int) -> float:
	# Higher level characters get slightly better improvements
	return 1.0 + (level - 1) * 0.002  # 0.2% bonus per level

## Get rank improvement bonus
func _get_rank_improvement_bonus(rank: Character.Rank) -> float:
	var rank_bonuses = {
		Character.Rank.F: 1.0,
		Character.Rank.E: 1.02,
		Character.Rank.D: 1.05,
		Character.Rank.C: 1.08,
		Character.Rank.B: 1.1,
		Character.Rank.A: 1.12,
		Character.Rank.S: 1.15,
		Character.Rank.SS: 1.18,
		Character.Rank.SSS: 1.2
	}
	
	return rank_bonuses.get(rank, 1.0)

## Train character in multiple stats
func train_character_multiple_stats(character: Character, stat_names: Array[String]) -> Dictionary:
	var results = {}
	
	for stat_name in stat_names:
		results[stat_name] = train_character_stat(character, stat_name)
	
	return results

## Get available training options for character
func get_available_training_options(character: Character) -> Array[Dictionary]:
	var options:Array[Dictionary]
	var all_stats = ["health", "defense", "attack", "speed", "intelligence", "charisma", "gathering", "hunting", "diplomacy", "stealth", "leadership", "survival"]
	
	for stat_name in all_stats:
		var training_cost = _balance_config.get_training_cost(stat_name)
		var success_rate = _calculate_training_success_rate(character, stat_name)
		var expected_improvement = _calculate_expected_improvement(character, stat_name)
		
		options.append({
			"stat_name": stat_name,
			"cost": training_cost,
			"success_rate": success_rate,
			"expected_improvement": expected_improvement,
			"current_value": character.get_data(stat_name)
		})
	
	return options

## Calculate expected improvement for training
func _calculate_expected_improvement(character: Character, stat_name: String) -> float:
	var success_rate = _calculate_training_success_rate(character, stat_name)
	var improvement_range = _balance_config.training_stat_gains.get(
		Character.Quality.keys()[character.quality], {"min": 1, "max": 2}
	)
	
	var average_improvement = (improvement_range.min + improvement_range.max) / 2.0
	var character_bonus = _get_character_improvement_bonus(character, stat_name)
	var level_bonus = _get_level_improvement_bonus(character.level)
	var rank_bonus = _get_rank_improvement_bonus(character.rank)
	
	var expected_improvement = average_improvement * character_bonus * level_bonus * rank_bonus * success_rate
	
	return expected_improvement

## Get training efficiency for character
func get_training_efficiency(character: Character) -> Dictionary:
	var efficiency = {
		"overall_efficiency": 0.0,
		"stat_efficiencies": {},
		"recommended_stats": []
	}
	
	var all_stats = ["health", "defense", "attack", "speed", "intelligence", "charisma", "gathering", "hunting", "diplomacy", "stealth", "leadership", "survival"]
	var total_efficiency = 0.0
	
	for stat_name in all_stats:
		var success_rate = _calculate_training_success_rate(character, stat_name)
		var expected_improvement = _calculate_expected_improvement(character, stat_name)
		var cost = _balance_config.get_training_cost(stat_name).get("gold", 50)
		
		var stat_efficiency = (expected_improvement * success_rate) / cost
		efficiency.stat_efficiencies[stat_name] = stat_efficiency
		total_efficiency += stat_efficiency
	
	efficiency.overall_efficiency = total_efficiency / all_stats.size()
	
	# Find recommended stats (top 3 most efficient)
	var sorted_stats = all_stats.duplicate()
	sorted_stats.sort_custom(func(a, b): return efficiency.stat_efficiencies[a] > efficiency.stat_efficiencies[b])
	efficiency.recommended_stats = sorted_stats.slice(0, 3)
	
	return efficiency

## Get training service statistics
func get_training_statistics() -> Dictionary:
	return {
		"service_name": _service_name,
		"training_sessions_completed": _training_sessions_completed,
		"training_sessions_failed": _training_sessions_failed,
		"total_training_cost": _total_training_cost,
		"total_stat_improvements": _total_stat_improvements,
		"success_rate": float(_training_sessions_completed) / max(1, _training_sessions_completed + _training_sessions_failed)
	}

## Get service statistics
func get_statistics() -> Dictionary:
	var base_stats = super.get_statistics()
	var training_stats = get_training_statistics()
	base_stats.merge(training_stats)
	return base_stats
