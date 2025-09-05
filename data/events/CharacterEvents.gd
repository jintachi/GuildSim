class_name CharacterEvents

## Static class containing all character-related event definitions
## Provides type-safe event creation and handling

#region Character Lifecycle Events
class CharacterRecruitedEvent extends BaseEvent:
	var character: Character
	var recruitment_cost: int
	
	func _init(character: Character, cost: int, source: String = "CharacterService"):
		self.character = character
		self.recruitment_cost = cost
		super._init("character_recruited", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"recruitment_cost": cost
		})

class CharacterLeveledUpEvent extends BaseEvent:
	var character: Character
	var old_level: int
	var new_level: int
	var experience_gained: int
	
	func _init(character: Character, old_level: int, new_level: int, exp_gained: int, source: String = "CharacterService"):
		self.character = character
		self.old_level = old_level
		self.new_level = new_level
		self.experience_gained = exp_gained
		super._init("character_leveled_up", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"old_level": old_level,
			"new_level": new_level,
			"experience_gained": exp_gained
		})

class CharacterPromotedEvent extends BaseEvent:
	var character: Character
	var old_rank: Character.Rank
	var new_rank: Character.Rank
	
	func _init(character: Character, old_rank: Character.Rank, new_rank: Character.Rank, source: String = "CharacterService"):
		self.character = character
		self.old_rank = old_rank
		self.new_rank = new_rank
		super._init("character_promoted", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"old_rank": Character.Rank.keys()[old_rank],
			"new_rank": Character.Rank.keys()[new_rank]
		})

class CharacterInjuredEvent extends BaseEvent:
	var character: Character
	var injury_type: Character.InjuryType
	var severity: int
	var duration: float
	
	func _init(character: Character, injury_type: Character.InjuryType, severity: int, duration: float, source: String = "QuestService"):
		self.character = character
		self.injury_type = injury_type
		self.severity = severity
		self.duration = duration
		super._init("character_injured", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"injury_type": Character.InjuryType.keys()[injury_type],
			"severity": severity,
			"duration": duration
		})

class CharacterHealedEvent extends BaseEvent:
	var character: Character
	var injury_type: Character.InjuryType
	
	func _init(character: Character, injury_type: Character.InjuryType, source: String = "HealerService"):
		self.character = character
		self.injury_type = injury_type
		super._init("character_healed", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"injury_type": Character.InjuryType.keys()[injury_type]
		})

class CharacterStatusChangedEvent extends BaseEvent:
	var character: Character
	var old_status: Character.CharacterStatus
	var new_status: Character.CharacterStatus
	
	func _init(character: Character, old_status: Character.CharacterStatus, new_status: Character.CharacterStatus, source: String = "CharacterService"):
		self.character = character
		self.old_status = old_status
		self.new_status = new_status
		super._init("character_status_changed", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"old_status": Character.CharacterStatus.keys()[old_status],
			"new_status": Character.CharacterStatus.keys()[new_status]
		})
#endregion

#region Character Training Events
class CharacterTrainingStartedEvent extends BaseEvent:
	var character: Character
	var training_type: String
	var training_cost: int
	
	func _init(character: Character, training_type: String, cost: int, source: String = "TrainingService"):
		self.character = character
		self.training_type = training_type
		self.training_cost = cost
		super._init("character_training_started", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"training_type": training_type,
			"training_cost": cost
		})

class CharacterTrainingCompletedEvent extends BaseEvent:
	var character: Character
	var training_type: String
	var stat_improvements: Dictionary
	
	func _init(character: Character, training_type: String, improvements: Dictionary, source: String = "TrainingService"):
		self.character = character
		self.training_type = training_type
		self.stat_improvements = improvements
		super._init("character_training_completed", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"training_type": training_type,
			"stat_improvements": improvements
		})
#endregion

#region Character Equipment Events
class CharacterEquippedItemEvent extends BaseEvent:
	var character: Character
	var item: GameResource
	var equipment_slot: String
	
	func _init(character: Character, item: GameResource, slot: String, source: String = "EquipmentService"):
		self.character = character
		self.item = item
		self.equipment_slot = slot
		super._init("character_equipped_item", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"item_id": item.id,
			"item_name": item.name,
			"equipment_slot": slot
		})

class CharacterUnequippedItemEvent extends BaseEvent:
	var character: Character
	var item: GameResource
	var equipment_slot: String
	
	func _init(character: Character, item: GameResource, slot: String, source: String = "EquipmentService"):
		self.character = character
		self.item = item
		self.equipment_slot = slot
		super._init("character_unequipped_item", source, {
			"character_id": character.id,
			"character_name": character.character_name,
			"item_id": item.id,
			"item_name": item.name,
			"equipment_slot": slot
		})
#endregion
