class_name CharacterRepository
extends BaseRepository

## Repository for Character entities
## Handles character data persistence and retrieval

var _is_initializing: bool = false

func _init(save_system: SaveSystem = null, event_bus: EventBus = null):
	super._init(save_system, event_bus)

## Get repository name for save/load
func get_repository_name() -> String:
	return "characters"

## Initialize default data
func _initialize_default_data() -> void:
	_is_initializing = true
	
	# Create some default characters for testing
	var default_characters = [
		_create_default_character("Hero", Character.CharacterClass.TANK, Character.CharacterJob.HERO, Character.Quality.THREE_STAR),
		_create_default_character("Bard", Character.CharacterClass.SUPPORT, Character.CharacterJob.BARD, Character.Quality.TWO_STAR),
		_create_default_character("Rogue", Character.CharacterClass.ATTACKER, Character.CharacterJob.ROGUE, Character.Quality.TWO_STAR),
		_create_default_character("Healer", Character.CharacterClass.HEALER, Character.CharacterJob.PRIEST, Character.Quality.ONE_STAR)
	]
	
	for character in default_characters:
		if character.validate():
			add(character)
	
	_is_initializing = false

## Override load to prevent events during data loading
func load() -> bool:
	if _save_system:
		var loaded_data = _save_system.load_data(get_repository_name())
		if loaded_data != null:
			_is_initializing = true
			_data = loaded_data
			_update_index()
			_is_initializing = false
			_on_repository_loaded()
			return true
	
	# If no saved data, initialize with default data
	_initialize_default_data()
	return true

## Create a default character
func _create_default_character(name: String, char_class: Character.CharacterClass,char_job: Character.CharacterJob, quality: Character.Quality) -> Character:
	var character = Character.new()
	character.character_name = name
	character.character_class = char_class
	character.quality = quality
	character.rank = Character.Rank.D
	
	# Set some basic stats based on class
	match char_class:
		Character.CharacterClass.TANK:
			
			character.health = 200
			character.defense = 30
			character.attack = 15
			character.speed = 10
		Character.CharacterClass.SUPPORT:
			character.health = 120
			character.defense = 15
			character.attack = 12
			character.speed = 15
			character.intelligence = 15
		Character.CharacterClass.ATTACKER:
			character.health = 140
			character.defense = 20
			character.attack = 22
			character.speed = 18
		Character.CharacterClass.HEALER:
			character.health = 150
			character.defense = 18
			character.attack = 12
			character.speed = 14
			character.intelligence = 17
	
	# Set some basic substats
	character.gathering = 5
	character.hunting = 5
	character.diplomacy = 5
	
	character.character_job = char_job

	return character

## Get all available characters (not on quest)
func get_available_characters() -> Array[Character]:
	var available: Array[Character] = []
	for character in _data:
		if character.is_available():
			available.append(character)
	return available

## Get characters by class
func get_characters_by_class(character_class: Character.CharacterClass) -> Array[Character]:
	var characters: Array[Character] = []
	for character in _data:
		if character.character_class == character_class:
			characters.append(character)
	return characters

## Get characters by rank
func get_characters_by_rank(rank: Character.Rank) -> Array[Character]:
	var characters: Array[Character] = []
	for character in _data:
		if character.rank == rank:
			characters.append(character)
	return characters

## Get characters by quality
func get_characters_by_quality(quality: Character.Quality) -> Array[Character]:
	var characters: Array[Character] = []
	for character in _data:
		if character.quality == quality:
			characters.append(character)
	return characters

## Get injured characters
func get_injured_characters() -> Array[Character]:
	var injured: Array[Character] = []
	for character in _data:
		if character.current_injury != Character.InjuryType.NONE:
			injured.append(character)
	return injured

## Get characters on quest
func get_characters_on_quest() -> Array[Character]:
	var on_quest: Array[Character] = []
	for character in _data:
		if character.status == Character.CharacterStatus.ON_QUEST:
			on_quest.append(character)
	return on_quest

## Get characters waiting for results
func get_characters_waiting_for_results() -> Array[Character]:
	var waiting: Array[Character] = []
	for character in _data:
		if character.status == Character.CharacterStatus.WAITING_FOR_RESULTS:
			waiting.append(character)
	return waiting

## Get characters by level range
func get_characters_by_level_range(min_level: int, max_level: int) -> Array[Character]:
	var characters: Array[Character] = []
	for character in _data:
		if character.level >= min_level and character.level <= max_level:
			characters.append(character)
	return characters

## Get characters needing promotion
func get_characters_needing_promotion() -> Array[Character]:
	var needing_promotion: Array[Character] = []
	for character in _data:
		if _character_needs_promotion(character):
			needing_promotion.append(character)
	return needing_promotion

## Check if character needs promotion
func _character_needs_promotion(character: Character) -> bool:
	# Character needs promotion if they have enough experience for next rank
	var _current_rank_exp = _get_rank_experience_requirement(character.rank)
	var next_rank_exp = _get_rank_experience_requirement(_get_next_rank(character.rank))
	
	return character.total_experience_gained >= next_rank_exp

## Get experience requirement for a rank
func _get_rank_experience_requirement(rank: Character.Rank) -> int:
	match rank:
		Character.Rank.F: return 0
		Character.Rank.E: return 100
		Character.Rank.D: return 250
		Character.Rank.C: return 500
		Character.Rank.B: return 1000
		Character.Rank.A: return 2000
		Character.Rank.S: return 4000
		Character.Rank.SS: return 8000
		Character.Rank.SSS: return 16000
		_: return 0

## Get next rank
func _get_next_rank(current_rank: Character.Rank) -> Character.Rank:
	var ranks = Character.Rank.values()
	var current_index = ranks.find(current_rank)
	if current_index < ranks.size() - 1:
		return ranks[current_index + 1]
	return current_rank

## Get character statistics
func get_character_statistics() -> Dictionary:
	var stats = {
		"total_characters": _data.size(),
		"available_characters": 0,
		"on_quest": 0,
		"waiting_for_results": 0,
		"injured": 0,
		"by_class": {},
		"by_rank": {},
		"by_quality": {},
		"average_level": 0.0,
		"total_experience": 0
	}
	
	var total_level = 0
	
	for character in _data:
		# Status counts
		match character.status:
			Character.CharacterStatus.AVAILABLE:
				stats.available_characters += 1
			Character.CharacterStatus.ON_QUEST:
				stats.on_quest += 1
			Character.CharacterStatus.WAITING_FOR_RESULTS:
				stats.waiting_for_results += 1
		
		# Injury count
		if character.current_injury != Character.InjuryType.NONE:
			stats.injured += 1
		
		# Class count
		var char_class_name = Character.CharacterClass.keys()[character.character_class]
		stats.by_class[char_class_name] = stats.by_class.get(char_class_name, 0) + 1
		
		# Rank count
		var rank_name = Character.Rank.keys()[character.rank]
		stats.by_rank[rank_name] = stats.by_rank.get(rank_name, 0) + 1
		
		# Quality count
		var quality_enum = character.quality
		stats.by_quality[quality_enum] = stats.by_quality.get(quality_enum, 0) + 1
		
		# Level and experience totals
		total_level += character.level
		stats.total_experience += character.total_experience_gained
	
	# Calculate averages
	if _data.size() > 0:
		stats.average_level = float(total_level) / float(_data.size())
	
	return stats

## Override entity added to emit events
func _on_entity_added(entity: Variant) -> void:
	# Only emit recruitment events if this is not during initialization
	# (i.e., when loading default data or saved data)
	if _event_bus and entity is Character and not _is_initializing:
		var event = CharacterEvents.CharacterRecruitedEvent.new(entity, entity.recruitment_cost)
		_event_bus.emit_event(event)

## Override entity updated to emit events
func _on_entity_updated(entity: Variant) -> void:
	# Match the type of entity before we proceed
	if entity is Character :
		# Check for level up
		var old_character = get_by_id(entity.id)
		if old_character and old_character.level < entity.level:
			if _event_bus:
				var event = CharacterEvents.CharacterLeveledUpEvent.new(
					entity, 
					old_character.level, 
					entity.level, 
					entity.experience - old_character.experience
				)
				_event_bus.emit_event(event)
		
		# Check for promotion
		if old_character and old_character.rank != entity.rank:
			if _event_bus:
				var event = CharacterEvents.CharacterPromotedEvent.new(entity, old_character.rank, entity.rank)
				_event_bus.emit_event(event)
		
		# Check for status change
		if old_character and old_character.status != entity.status:
			if _event_bus:
				var event = CharacterEvents.CharacterStatusChangedEvent.new(entity, old_character.status, entity.status)
				_event_bus.emit_event(event)
		
		# Check for injury
		if old_character and old_character.current_injury != entity.current_injury:
			if entity.current_injury != Character.InjuryType.NONE:
				if _event_bus:
					var event = CharacterEvents.CharacterInjuredEvent.new(
						entity, 
						entity.current_injury, 
						entity.injury_severity, 
						entity.injury_duration
					)
					_event_bus.emit_event(event)
			elif old_character.current_injury != Character.InjuryType.NONE:
				if _event_bus:
					var event = CharacterEvents.CharacterHealedEvent.new(entity, old_character.current_injury)
					_event_bus.emit_event(event)
