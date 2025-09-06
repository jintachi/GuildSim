extends BaseViewModel
class_name QuestViewModel

## ViewModel for quest management UI
## Handles quest data binding and state management

# Quest data
var _quests: Array[Quest] = []
var _available_quests: Array[Quest] = []
var _active_quests: Array[Quest] = []
var _completed_quests: Array[Quest] = []
var _selected_quest: Quest = null

# Quest types and difficulties
var _quest_types: Array[String] = []
var _quest_difficulties: Array[String] = []
var _quest_ranks: Array[String] = []

# Quest statistics
var _total_quests: int = 0
var _available_count: int = 0
var _active_count: int = 0
var _completed_count: int = 0
var _success_rate: float = 0.0

# Quest generation
var _can_generate_quest: bool = false
var _generation_cost: Dictionary = {}
var _generation_error: String = ""

# Quest assignment
var _selected_characters: Array[String] = []
var _can_assign_quest: bool = false
var _assignment_error: String = ""

# Quest rewards
var _pending_rewards: Array[Dictionary] = []
var _total_rewards: Dictionary = {}

func _init():
	super._init()

## Setup event subscriptions
func _setup_event_subscriptions() -> void:
	_subscribe_to_event("quest_generated", _on_quest_generated)
	_subscribe_to_event("quest_assigned", _on_quest_assigned)
	_subscribe_to_event("quest_completed", _on_quest_completed)
	_subscribe_to_event("quest_failed", _on_quest_failed)
	_subscribe_to_event("character_assigned_to_quest", _on_character_assigned_to_quest)
	_subscribe_to_event("character_removed_from_quest", _on_character_removed_from_quest)

## Handle initialization
func _on_initialized() -> void:
	_load_quest_data()
	_load_quest_enums()
	_update_statistics()

## Load quest data from service
func _load_quest_data() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var quest_service = ServiceManager.get_quest_service()
	var quest_repository = ServiceManager.get_quest_repository()
	
	if quest_service and quest_repository:
		var temp_quests = quest_repository.get_all()
		for q in temp_quests:
			_quests.append(q as Quest)
		var temp_available_quests = quest_repository.get_available_quests()
		for q in temp_available_quests:
			_available_quests.append(q as Quest)
		var temp_active_quests = quest_repository.get_active_quests()
		for q in temp_active_quests:
			_active_quests.append(q as Quest)
		var temp_completed_quests = quest_repository.get_completed_quests()
		for q in temp_completed_quests:
			_completed_quests.append(q as Quest)
		_active_quests = quest_repository.get_active_quests()
		_completed_quests = quest_repository.get_completed_quests()
		_update_statistics()

## Load quest enums
func _load_quest_enums() -> void:
	_quest_types = ["GATHERING", "HUNTING", "DIPLOMACY", "CARAVAN_GUARDING", "ESCORT", "STEALTH", "ODD_JOB", "EMERGENCY"]
	_quest_difficulties = ["TRIVIAL", "EASY", "NORMAL", "HARD", "EXTREME", "LEGENDARY"]
	_quest_ranks = ["F", "E", "D", "C", "B", "A", "S", "SS", "SSS"]

## Update quest statistics
func _update_statistics() -> void:
	_total_quests = _quests.size()
	_available_count = _available_quests.size()
	_active_count = _active_quests.size()
	_completed_count = _completed_quests.size()
	
	# Calculate success rate
	if _completed_count > 0:
		var successful_quests = 0
		for quest in _completed_quests:
			if quest.is_completed:
				successful_quests += 1
		_success_rate = float(successful_quests) / float(_completed_count)
	else:
		_success_rate = 0.0
	
	# Notify property changes
	_notify_property_changed("total_quests", 0, _total_quests)
	_notify_property_changed("available_count", 0, _available_count)
	_notify_property_changed("active_count", 0, _active_count)
	_notify_property_changed("completed_count", 0, _completed_count)
	_notify_property_changed("success_rate", 0.0, _success_rate)

## Get data for a property
func get_data(property_name: String) -> Variant:
	match property_name:
		"quests": return _quests
		"available_quests": return _available_quests
		"active_quests": return _active_quests
		"completed_quests": return _completed_quests
		"selected_quest": return _selected_quest
		"quest_types": return _quest_types
		"quest_difficulties": return _quest_difficulties
		"quest_ranks": return _quest_ranks
		"total_quests": return _total_quests
		"available_count": return _available_count
		"active_count": return _active_count
		"completed_count": return _completed_count
		"success_rate": return _success_rate
		"can_generate_quest": return _can_generate_quest
		"generation_cost": return _generation_cost
		"generation_error": return _generation_error
		"selected_characters": return _selected_characters
		"can_assign_quest": return _can_assign_quest
		"assignment_error": return _assignment_error
		"pending_rewards": return _pending_rewards
		"total_rewards": return _total_rewards
		_: return null

## Set data for a property
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"selected_quest": 
			_selected_quest = value
			_update_assignment_options()
		"selected_characters":
			_selected_characters = value
			_update_assignment_options()
		_: 
			super.set_data(property_name, value)

## Update a property
func _update_property(property_name: String, value: Variant) -> void:
	match property_name:
		"selected_quest": _selected_quest = value
		"selected_characters": _selected_characters = value
		_: pass

## Select a quest
func select_quest(quest: Quest) -> void:
	_selected_quest = quest
	_update_assignment_options()
	_notify_property_changed("selected_quest", null, quest)

## Get quest by ID
func get_quest_by_id(quest_id: String) -> Quest:
	for quest in _quests:
		if quest.id == quest_id:
			return quest
	return null

## Get party members assigned to a quest
func _get_quest_party(quest_id: String) -> Array[Character]:
	if not ServiceManager or not ServiceManager.is_initialized():
		return []
	
	var character_service = ServiceManager.get_character_service()
	var character_repository = ServiceManager.get_character_repository()
	
	if not character_service or not character_repository:
		return []
	
	# Get the quest to check its status
	var quest = get_quest_by_id(quest_id)
	if not quest or quest.status != Quest.QuestStatus.IN_PROGRESS:
		return []
	
	# Get all characters that are currently on quest
	# Note: In the current system, we assume all characters on quest are part of the same quest
	# This is a limitation that could be improved by adding quest_id tracking to characters
	var characters_on_quest = character_repository.get_characters_on_quest()
	
	# For now, return all characters on quest since the system appears designed for single active quest
	# In a more complex system, we'd need to add quest_id field to Character model
	return characters_on_quest

## Get quests by type
func get_quests_by_type(quest_type: String) -> Array[Quest]:
	var filtered_quests: Array[Quest] = []
	for quest in _quests:
		var quest_type_name = Quest.QuestType.keys()[quest.quest_type]
		if quest_type_name == quest_type:
			filtered_quests.append(quest)
	return filtered_quests

## Get quests by difficulty
func get_quests_by_difficulty(difficulty: String) -> Array[Quest]:
	var filtered_quests: Array[Quest] = []
	for quest in _quests:
		var difficulty_name = Quest.QuestDifficulty.keys()[quest.difficulty]
		if difficulty_name == difficulty:
			filtered_quests.append(quest)
	return filtered_quests

## Get quests by rank
func get_quests_by_rank(rank: String) -> Array[Quest]:
	var filtered_quests: Array[Quest] = []
	for quest in _quests:
		var rank_name = Quest.QuestRank.keys()[quest.quest_rank]
		if rank_name == rank:
			filtered_quests.append(quest)
	return filtered_quests

## Update generation options
func update_generation_options() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		_can_generate_quest = quest_service.can_generate_quest()
		_generation_cost = quest_service.get_generation_cost()
		_generation_error = quest_service.get_last_error()

## Update assignment options
func _update_assignment_options() -> void:
	if not _selected_quest or not ServiceManager or not ServiceManager.is_initialized():
		_can_assign_quest = false
		_assignment_error = ""
		return
	
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		# Check if quest can be assigned based on party size and requirements
		var can_assign = _selected_characters.size() >= _selected_quest.min_party_size and _selected_characters.size() <= _selected_quest.max_party_size
		_can_assign_quest = can_assign
		_assignment_error = "" if can_assign else "Invalid party size for quest"

## Generate a quest
func generate_quest(quest_type: String, difficulty: String, rank: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		# Convert string names to enum values
		var quest_type_enum = Quest.QuestType.get(quest_type)
		var difficulty_enum = Quest.QuestDifficulty.get(difficulty)
		var rank_enum = Quest.QuestRank.get(rank)
		
		var success = quest_service.generate_quest(quest_type_enum, difficulty_enum, rank_enum)
		if success:
			_load_quest_data()
		return success
	return false

## Assign quest to characters
func assign_quest() -> bool:
	if not _selected_quest or not _selected_characters or not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		var success = quest_service.assign_quest(_selected_quest.id, _selected_characters)
		if success:
			_load_quest_data()
		return success
	return false

## Complete a quest
func complete_quest(quest_id: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var quest_service = ServiceManager.get_quest_service()
	var character_service = ServiceManager.get_character_service()
	
	if quest_service and character_service:
		# Get the quest object
		var quest = get_quest_by_id(quest_id)
		if not quest:
			return false
		
		# Get the party members assigned to this quest
		var party = _get_quest_party(quest_id)
		if party.is_empty():
			return false
		
		# Complete the quest with the party data
		var success = quest_service.complete_quest(quest, party)
		if success:
			_load_quest_data()
			_update_rewards()
		return success
	return false

## Fail a quest
func fail_quest(quest_id: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var quest_service = ServiceManager.get_quest_service()
	var character_service = ServiceManager.get_character_service()
	
	if quest_service and character_service:
		# Get the quest object
		var quest = get_quest_by_id(quest_id)
		if not quest:
			return false
		
		# Get the party members assigned to this quest
		var party = _get_quest_party(quest_id)
		if party.is_empty():
			return false
		
		# Fail the quest with the party data
		var success = quest_service.fail_quest(quest, party)
		if success:
			_load_quest_data()
		return success
	return false

## Update rewards
func _update_rewards() -> void:
	# Calculate pending rewards from completed quests
	_pending_rewards.clear()
	_total_rewards.clear()
	
	for quest in _completed_quests:
		if quest.is_completed():
			var quest_rewards = quest.get_all_rewards()
			_pending_rewards.append(quest_rewards)
			
			# Add to total rewards
			for reward_type in quest_rewards:
				var amount = quest_rewards[reward_type]
				if typeof(amount) == TYPE_INT:
					_total_rewards[reward_type] = _total_rewards.get(reward_type, 0) + amount

## Collect rewards
func collect_rewards() -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		var success = guild_service.add_resources(_total_rewards)
		if success:
			_pending_rewards.clear()
			_total_rewards.clear()
		return success
	return false

## Get quest statistics summary
func get_quest_statistics_summary() -> Dictionary:
	return {
		"total_quests": _total_quests,
		"available_count": _available_count,
		"active_count": _active_count,
		"completed_count": _completed_count,
		"success_rate": _success_rate,
		"selected_quest": _selected_quest.id if _selected_quest else "",
		"can_generate_quest": _can_generate_quest,
		"can_assign_quest": _can_assign_quest,
		"pending_rewards": _pending_rewards.size()
	}

## Refresh all data
func refresh() -> void:
	_load_quest_data()
	update_generation_options()
	_update_assignment_options()
	_update_rewards()

## Event handlers
func _on_quest_generated(_event: BaseEvent) -> void:
	_load_quest_data()

func _on_quest_assigned(_event: BaseEvent) -> void:
	_load_quest_data()

func _on_quest_completed(_event: BaseEvent) -> void:
	_load_quest_data()
	_update_rewards()

func _on_quest_failed(_event: BaseEvent) -> void:
	_load_quest_data()

func _on_character_assigned_to_quest(_event: BaseEvent) -> void:
	_load_quest_data()

func _on_character_removed_from_quest(_event: BaseEvent) -> void:
	_load_quest_data()

## Validate ViewModel state
func validate() -> bool:
	return super.validate() and ServiceManager != null and ServiceManager.is_initialized()
