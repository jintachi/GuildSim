class_name CharacterEvents

## Static class containing all character-related event definitions
## Provides type-safe event creation and handling

#region Character Lifecycle Events
class CharacterRecruitedEvent extends BaseEvent:
	var character: Character
	var recruitment_cost: int
	
	func _init(p_character: Character, p_cost: int, p_source: String = "CharacterService"):
		character = p_character
		recruitment_cost = p_cost
		super._init("character_recruited", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"recruitment_cost": p_cost
		})

class CharacterLeveledUpEvent extends BaseEvent:
	var character: Character
	var old_level: int
	var new_level: int
	var experience_gained: int
	
	func _init(p_character: Character, p_old_level: int, p_new_level: int, p_exp_gained: int, p_source: String = "CharacterService"):
		character = p_character
		old_level = p_old_level
		new_level = p_new_level
		experience_gained = p_exp_gained
		super._init("character_leveled_up", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"old_level": p_old_level,
			"new_level": p_new_level,
			"experience_gained": p_exp_gained
		})

class CharacterPromotedEvent extends BaseEvent:
	var character: Character
	var old_rank: Character.Rank
	var new_rank: Character.Rank
	
	func _init(p_character: Character, p_old_rank: Character.Rank, p_new_rank: Character.Rank, p_source: String = "CharacterService"):
		character = p_character
		old_rank = p_old_rank
		new_rank = p_new_rank
		super._init("character_promoted", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"old_rank": Character.Rank.keys()[p_old_rank],
			"new_rank": Character.Rank.keys()[p_new_rank]
		})

class CharacterInjuredEvent extends BaseEvent:
	var character: Character
	var injury_type: Character.InjuryType
	var severity: int
	var duration: float
	
	func _init(p_character: Character, p_injury_type: Character.InjuryType, p_severity: int, p_duration: float, p_source: String = "QuestService"):
		character = p_character
		injury_type = p_injury_type
		severity = p_severity
		duration = p_duration
		super._init("character_injured", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"injury_type": Character.InjuryType.keys()[p_injury_type],
			"severity": p_severity,
			"duration": p_duration
		})

class CharacterHealedEvent extends BaseEvent:
	var character: Character
	var injury_type: Character.InjuryType
	
	func _init(p_character: Character, p_injury_type: Character.InjuryType, p_source: String = "HealerService"):
		character = p_character
		injury_type = p_injury_type
		super._init("character_healed", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"injury_type": Character.InjuryType.keys()[p_injury_type]
		})

class CharacterStatusChangedEvent extends BaseEvent:
	var character: Character
	var old_status: Character.CharacterStatus
	var new_status: Character.CharacterStatus
	
	func _init(p_character: Character, p_old_status: Character.CharacterStatus, p_new_status: Character.CharacterStatus, p_source: String = "CharacterService"):
		character = p_character
		old_status = p_old_status
		new_status = p_new_status
		super._init("character_status_changed", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"old_status": Character.CharacterStatus.keys()[p_old_status],
			"new_status": Character.CharacterStatus.keys()[p_new_status]
		})
#endregion

#region Character Training Events
class CharacterTrainingStartedEvent extends BaseEvent:
	var character: Character
	var training_type: String
	var training_cost: int
	
	func _init(p_character: Character, p_training_type: String, p_cost: int, p_source: String = "TrainingService"):
		character = p_character
		training_type = p_training_type
		training_cost = p_cost
		super._init("character_training_started", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"training_type": p_training_type,
			"training_cost": p_cost
		})

class CharacterTrainingCompletedEvent extends BaseEvent:
	var character: Character
	var training_type: String
	var stat_improvements: Dictionary
	
	func _init(p_character: Character, p_training_type: String, p_improvements: Dictionary, p_source: String = "TrainingService"):
		character = p_character
		training_type = p_training_type
		stat_improvements = p_improvements
		super._init("character_training_completed", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"training_type": p_training_type,
			"stat_improvements": p_improvements
		})
#endregion

#region Character Equipment Events
class CharacterEquippedItemEvent extends BaseEvent:
	var character: Character
	var item: GameResource
	var equipment_slot: String
	
	func _init(p_character: Character, p_item: GameResource, p_slot: String, p_source: String = "EquipmentService"):
		character = p_character
		item = p_item
		equipment_slot = p_slot
		super._init("character_equipped_item", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"item_id": p_item.id,
			"item_name": p_item.name,
			"equipment_slot": p_slot
		})

class CharacterUnequippedItemEvent extends BaseEvent:
	var character: Character
	var item: GameResource
	var equipment_slot: String
	
	func _init(p_character: Character, p_item: GameResource, p_slot: String, p_source: String = "EquipmentService"):
		character = p_character
		item = p_item
		equipment_slot = p_slot
		super._init("character_unequipped_item", p_source, {
			"character_id": p_character.id,
			"character_name": p_character.character_name,
			"item_id": p_item.id,
			"item_name": p_item.name,
			"equipment_slot": p_slot
		})
#endregion
