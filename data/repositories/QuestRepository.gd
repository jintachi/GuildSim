class_name QuestRepository
extends BaseRepository

## Repository for Quest entities
## Handles quest data persistence and retrieval

func _init(save_system: SaveSystem = null, event_bus: EventBus = null):
	super._init(save_system, event_bus)

## Get repository name for save/load
func get_repository_name() -> String:
	return "quests"

## Get all available quests (not started)
func get_available_quests() -> Array[Quest]:
	var available: Array[Quest] = []
	for quest in _data:
		if quest.status == Quest.QuestStatus.NOT_STARTED:
			available.append(quest)
	return available

## Get active quests (in progress or awaiting completion)
func get_active_quests() -> Array[Quest]:
	var active: Array[Quest] = []
	for quest in _data:
		if quest.is_active():
			active.append(quest)
	return active

## Get completed quests
func get_completed_quests() -> Array[Quest]:
	var completed: Array[Quest] = []
	for quest in _data:
		if quest.is_completed():
			completed.append(quest)
	return completed

## Get failed quests
func get_failed_quests() -> Array[Quest]:
	var failed: Array[Quest] = []
	for quest in _data:
		if quest.is_failed():
			failed.append(quest)
	return failed

## Get quests by type
func get_quests_by_type(quest_type: Quest.QuestType) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		if quest.quest_type == quest_type:
			quests.append(quest)
	return quests

## Get quests by rank
func get_quests_by_rank(quest_rank: Quest.QuestRank) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		if quest.quest_rank == quest_rank:
			quests.append(quest)
	return quests

## Get quests by difficulty
func get_quests_by_difficulty(difficulty: Quest.QuestDifficulty) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		if quest.difficulty == difficulty:
			quests.append(quest)
	return quests

## Get emergency quests
func get_emergency_quests() -> Array[Quest]:
	var emergency: Array[Quest] = []
	for quest in _data:
		if quest.is_emergency:
			emergency.append(quest)
	return emergency

## Get repeatable quests
func get_repeatable_quests() -> Array[Quest]:
	var repeatable: Array[Quest] = []
	for quest in _data:
		if quest.is_repeatable:
			repeatable.append(quest)
	return repeatable

## Get quests by quest giver
func get_quests_by_giver(quest_giver: String) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		if quest.quest_giver == quest_giver:
			quests.append(quest)
	return quests

## Get quests by location
func get_quests_by_location(location: String) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		if quest.location == location:
			quests.append(quest)
	return quests

## Get quests within level range
func get_quests_by_level_range(min_level: int, max_level: int) -> Array[Quest]:
	var quests: Array[Quest] = []
	for quest in _data:
		var quest_level = _get_quest_level(quest)
		if quest_level >= min_level and quest_level <= max_level:
			quests.append(quest)
	return quests

## Get quest level based on rank and difficulty
func _get_quest_level(quest: Quest) -> int:
	var base_level = Quest.QuestRank.keys().find(Quest.QuestRank.keys()[quest.quest_rank]) + 1
	var difficulty_multiplier = quest.get_difficulty_multiplier()
	return int(base_level * difficulty_multiplier)

## Get quests that can be completed by party
func get_quests_for_party(party: Array[Character]) -> Array[Quest]:
	var suitable_quests: Array[Quest] = []
	
	for quest in get_available_quests():
		if _can_party_complete_quest(quest, party):
			suitable_quests.append(quest)
	
	return suitable_quests

## Check if party can complete quest
func _can_party_complete_quest(quest: Quest, party: Array[Character]) -> bool:
	# Check party size
	if party.size() < quest.min_party_size or party.size() > quest.max_party_size:
		return false
	
	# Check class requirements
	var class_requirements = quest.get_class_requirements()
	var party_classes = {}
	
	for character in party:
		var char_class_name = Character.CharacterClass.keys()[character.character_class].to_lower()
		party_classes[char_class_name] = party_classes.get(char_class_name, 0) + 1
	
	for required_class in class_requirements:
		if class_requirements[required_class] and party_classes.get(required_class, 0) == 0:
			return false
	
	# Check stat requirements
	var stat_requirements = quest.get_stat_requirements()
	var party_stats = _calculate_party_stats(party)
	
	for stat in stat_requirements:
		if party_stats.get(stat, 0) < stat_requirements[stat]:
			return false
	
	# Check sub-stat requirements
	var substat_requirements = quest.get_substat_requirements()
	var party_substats = _calculate_party_substats(party)
	
	for substat in substat_requirements:
		if party_substats.get(substat, 0) < substat_requirements[substat]:
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

## Get quest statistics
func get_quest_statistics() -> Dictionary:
	var stats = {
		"total_quests": _data.size(),
		"available_quests": 0,
		"active_quests": 0,
		"completed_quests": 0,
		"failed_quests": 0,
		"by_type": {},
		"by_rank": {},
		"by_difficulty": {},
		"emergency_quests": 0,
		"repeatable_quests": 0,
		"total_rewards_gold": 0,
		"total_rewards_influence": 0,
		"average_duration": 0.0
	}
	
	var total_duration = 0.0
	
	for quest in _data:
		# Status counts
		match quest.status:
			Quest.QuestStatus.NOT_STARTED:
				stats.available_quests += 1
			Quest.QuestStatus.IN_PROGRESS, Quest.QuestStatus.AWAITING_COMPLETION:
				stats.active_quests += 1
			Quest.QuestStatus.COMPLETED:
				stats.completed_quests += 1
			Quest.QuestStatus.FAILED:
				stats.failed_quests += 1
		
		# Type count
		var type_name = Quest.QuestType.keys()[quest.quest_type]
		stats.by_type[type_name] = stats.by_type.get(type_name, 0) + 1
		
		# Rank count
		var rank_name = Quest.QuestRank.keys()[quest.quest_rank]
		stats.by_rank[rank_name] = stats.by_rank.get(rank_name, 0) + 1
		
		# Difficulty count
		var difficulty_name = Quest.QuestDifficulty.keys()[quest.difficulty]
		stats.by_difficulty[difficulty_name] = stats.by_difficulty.get(difficulty_name, 0) + 1
		
		# Special quest counts
		if quest.is_emergency:
			stats.emergency_quests += 1
		if quest.is_repeatable:
			stats.repeatable_quests += 1
		
		# Reward totals
		stats.total_rewards_gold += quest.gold_reward
		stats.total_rewards_influence += quest.influence_reward
		
		# Duration
		total_duration += quest.duration
	
	# Calculate averages
	if _data.size() > 0:
		stats.average_duration = total_duration / float(_data.size())
	
	return stats

## Override entity added to emit events
func _on_entity_added(entity: Variant) -> void:
	# Confirm our entity is a Quest
	if _event_bus and int(entity.get_class()) == typeof(Character):
		var event = QuestEvents.QuestGeneratedEvent.new(entity)
		_event_bus.emit_event(event)

## Override entity updated to emit events
func _on_entity_updated(entity: Variant) -> void:
	# Confirm our entity is a Quest
	if entity == typeof(Quest) :
		var old_quest = get_by_id(entity.id)
		if old_quest and old_quest.status != entity.status:
			# Status changed - emit appropriate event
			match entity.status:
				Quest.QuestStatus.IN_PROGRESS:
					if _event_bus:
						var event = QuestEvents.QuestStartedEvent.new(entity, [])  # Party would be passed separately
						_event_bus.emit_event(event)
				Quest.QuestStatus.COMPLETED:
					if _event_bus:
						var event = QuestEvents.QuestCompletedEvent.new(entity, [], {}, 1.0)  # Data would be passed separately
						_event_bus.emit_event(event)
				Quest.QuestStatus.FAILED:
					if _event_bus:
						var event = QuestEvents.QuestFailedEvent.new(entity, [], "Unknown", {})
						_event_bus.emit_event(event)
