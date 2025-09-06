class_name QuestEvents

## Static class containing all quest-related event definitions
## Provides type-safe event creation and handling

#region Quest Lifecycle Events
class QuestGeneratedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(p_quest: Quest, p_source: String = "QuestService"):
		quest = p_quest
		super._init("quest_generated", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"quest_type": Quest.QuestType.keys()[p_quest.quest_type],
			"quest_rank": Quest.QuestRank.keys()[p_quest.quest_rank]
		})

class QuestStartedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	
	func _init(p_quest: Quest, p_party: Array[Character], p_source: String = "QuestService"):
		quest = p_quest
		party = p_party
		var party_data = []
		for character in p_party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_started", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"party": party_data
		})

class QuestCompletedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var rewards: Dictionary
	var success_rate: float
	
	func _init(p_quest: Quest, p_party: Array[Character], p_rewards: Dictionary, p_success_rate: float, p_source: String = "QuestService"):
		quest = p_quest
		party = p_party
		rewards = p_rewards
		success_rate = p_success_rate
		var party_data = []
		for character in p_party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_completed", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"party": party_data,
			"rewards": p_rewards,
			"success_rate": p_success_rate
		})

class QuestFailedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var failure_reason: String
	var penalties: Dictionary
	
	func _init(p_quest: Quest, p_party: Array[Character], p_failure_reason: String, p_penalties: Dictionary, p_source: String = "QuestService"):
		quest = p_quest
		party = p_party
		failure_reason = p_failure_reason
		penalties = p_penalties
		var party_data = []
		for character in p_party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_failed", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"party": party_data,
			"failure_reason": p_failure_reason,
			"penalties": p_penalties
		})

class QuestAbandonedEvent extends BaseEvent:
	var quest: Quest
	var reason: String
	
	func _init(p_quest: Quest, p_reason: String, p_source: String = "QuestService"):
		quest = p_quest
		reason = p_reason
		super._init("quest_abandoned", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"reason": p_reason
		})
#endregion

#region Quest Selection Events
class QuestSelectedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(p_quest: Quest, p_source: String = "QuestUI"):
		quest = p_quest
		super._init("quest_selected", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"quest_type": Quest.QuestType.keys()[p_quest.quest_type]
		})

class QuestDeselectedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(p_quest: Quest, p_source: String = "QuestUI"):
		quest = p_quest
		super._init("quest_deselected", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name
		})

class PartyAssembledEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var success_chance: float
	
	func _init(p_quest: Quest, p_party: Array[Character], p_success_chance: float, p_source: String = "QuestUI"):
		quest = p_quest
		party = p_party
		success_chance = p_success_chance
		var party_data = []
		for character in p_party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("party_assembled", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"party": party_data,
			"success_chance": p_success_chance
		})

class PartyMemberAddedEvent extends BaseEvent:
	var quest: Quest
	var character: Character
	var new_success_chance: float
	
	func _init(p_quest: Quest, p_character: Character, p_success_chance: float, p_source: String = "QuestUI"):
		quest = p_quest
		character = p_character
		new_success_chance = p_success_chance
		super._init("party_member_added", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"new_success_chance": p_success_chance
		})

class PartyMemberRemovedEvent extends BaseEvent:
	var quest: Quest
	var character: Character
	var new_success_chance: float
	
	func _init(p_quest: Quest, p_character: Character, p_success_chance: float, p_source: String = "QuestUI"):
		quest = p_quest
		character = p_character
		new_success_chance = p_success_chance
		super._init("party_member_removed", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"new_success_chance": p_success_chance
		})
#endregion

#region Quest Progress Events
class QuestProgressUpdatedEvent extends BaseEvent:
	var quest: Quest
	var progress_percentage: float
	var time_remaining: float
	
	func _init(p_quest: Quest, p_progress: float, p_time_remaining: float, p_source: String = "QuestService"):
		quest = p_quest
		progress_percentage = p_progress
		time_remaining = p_time_remaining
		super._init("quest_progress_updated", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"progress_percentage": p_progress,
			"time_remaining": p_time_remaining
		})

class QuestRewardClaimedEvent extends BaseEvent:
	var quest: Quest
	var rewards: Dictionary
	
	func _init(p_quest: Quest, p_rewards: Dictionary, p_source: String = "QuestService"):
		quest = p_quest
		rewards = p_rewards
		super._init("quest_reward_claimed", p_source, {
			"quest_id": p_quest.id,
			"quest_name": p_quest.quest_name,
			"rewards": p_rewards
		})
#endregion
