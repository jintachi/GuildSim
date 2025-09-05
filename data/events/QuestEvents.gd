class_name QuestEvents

## Static class containing all quest-related event definitions
## Provides type-safe event creation and handling

#region Quest Lifecycle Events
class QuestGeneratedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(quest: Quest, source: String = "QuestService"):
		self.quest = quest
		super._init("quest_generated", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"quest_type": Quest.QuestType.keys()[quest.quest_type],
			"quest_rank": Quest.QuestRank.keys()[quest.quest_rank]
		})

class QuestStartedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	
	func _init(quest: Quest, party: Array[Character], source: String = "QuestService"):
		self.quest = quest
		self.party = party
		var party_data = []
		for character in party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_started", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"party": party_data
		})

class QuestCompletedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var rewards: Dictionary
	var success_rate: float
	
	func _init(quest: Quest, party: Array[Character], rewards: Dictionary, success_rate: float, source: String = "QuestService"):
		self.quest = quest
		self.party = party
		self.rewards = rewards
		self.success_rate = success_rate
		var party_data = []
		for character in party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_completed", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"party": party_data,
			"rewards": rewards,
			"success_rate": success_rate
		})

class QuestFailedEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var failure_reason: String
	var penalties: Dictionary
	
	func _init(quest: Quest, party: Array[Character], failure_reason: String, penalties: Dictionary, source: String = "QuestService"):
		self.quest = quest
		self.party = party
		self.failure_reason = failure_reason
		self.penalties = penalties
		var party_data = []
		for character in party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("quest_failed", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"party": party_data,
			"failure_reason": failure_reason,
			"penalties": penalties
		})

class QuestAbandonedEvent extends BaseEvent:
	var quest: Quest
	var reason: String
	
	func _init(quest: Quest, reason: String, source: String = "QuestService"):
		self.quest = quest
		self.reason = reason
		super._init("quest_abandoned", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"reason": reason
		})
#endregion

#region Quest Selection Events
class QuestSelectedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(quest: Quest, source: String = "QuestUI"):
		self.quest = quest
		super._init("quest_selected", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"quest_type": Quest.QuestType.keys()[quest.quest_type]
		})

class QuestDeselectedEvent extends BaseEvent:
	var quest: Quest
	
	func _init(quest: Quest, source: String = "QuestUI"):
		self.quest = quest
		super._init("quest_deselected", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name
		})

class PartyAssembledEvent extends BaseEvent:
	var quest: Quest
	var party: Array[Character]
	var success_chance: float
	
	func _init(quest: Quest, party: Array[Character], success_chance: float, source: String = "QuestUI"):
		self.quest = quest
		self.party = party
		self.success_chance = success_chance
		var party_data = []
		for character in party:
			party_data.append({
				"character_id": character.id,
				"character_name": character.character_name
			})
		super._init("party_assembled", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"party": party_data,
			"success_chance": success_chance
		})

class PartyMemberAddedEvent extends BaseEvent:
	var quest: Quest
	var character: Character
	var new_success_chance: float
	
	func _init(quest: Quest, character: Character, success_chance: float, source: String = "QuestUI"):
		self.quest = quest
		self.character = character
		self.new_success_chance = success_chance
		super._init("party_member_added", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"character_id": character.id,
			"character_name": character.character_name,
			"new_success_chance": success_chance
		})

class PartyMemberRemovedEvent extends BaseEvent:
	var quest: Quest
	var character: Character
	var new_success_chance: float
	
	func _init(quest: Quest, character: Character, success_chance: float, source: String = "QuestUI"):
		self.quest = quest
		self.character = character
		self.new_success_chance = success_chance
		super._init("party_member_removed", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"character_id": character.id,
			"character_name": character.character_name,
			"new_success_chance": success_chance
		})
#endregion

#region Quest Progress Events
class QuestProgressUpdatedEvent extends BaseEvent:
	var quest: Quest
	var progress_percentage: float
	var time_remaining: float
	
	func _init(quest: Quest, progress: float, time_remaining: float, source: String = "QuestService"):
		self.quest = quest
		self.progress_percentage = progress
		self.time_remaining = time_remaining
		super._init("quest_progress_updated", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"progress_percentage": progress,
			"time_remaining": time_remaining
		})

class QuestRewardClaimedEvent extends BaseEvent:
	var quest: Quest
	var rewards: Dictionary
	
	func _init(quest: Quest, rewards: Dictionary, source: String = "QuestService"):
		self.quest = quest
		self.rewards = rewards
		super._init("quest_reward_claimed", source, {
			"quest_id": quest.id,
			"quest_name": quest.quest_name,
			"rewards": rewards
		})
#endregion
