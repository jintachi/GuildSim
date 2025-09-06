extends BaseViewModel
class_name CharacterViewModel

## ViewModel for character management UI
## Handles character data binding and state management

# Character data
var _characters: Array[Character] = []
var _selected_character: Character = null
var _available_characters: Array[Character] = []
var _character_classes: Array[String] = []
var _character_qualities: Array[String] = []

# Character statistics
var _total_characters: int = 0
var _available_count: int = 0
var _busy_count: int = 0
var _average_level: float = 0.0

# Recruitment data
var _recruitment_costs: Dictionary = {}
var _can_recruit: bool = false
var _recruitment_error: String = ""

# Training data
var _training_options: Array[Dictionary] = []
var _selected_training: Dictionary = {}
var _training_cost: Dictionary = {}
var _can_train: bool = false

func _init():
	super._init()

## Setup event subscriptions
func _setup_event_subscriptions() -> void:
	_subscribe_to_event("character_recruited", _on_character_recruited)
	_subscribe_to_event("character_leveled_up", _on_character_leveled_up)
	_subscribe_to_event("character_trained", _on_character_trained)
	_subscribe_to_event("character_equipped", _on_character_equipped)
	_subscribe_to_event("guild_resource_changed", _on_guild_resource_changed)

## Handle initialization
func _on_initialized() -> void:
	_load_character_data()
	_load_character_enums()
	_update_statistics()

## Load character data from service
func _load_character_data() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var character_service = ServiceManager.get_character_service()
	var character_repository = ServiceManager.get_character_repository()
	
	if character_service and character_repository:
		var temp_characters = character_repository.get_all()
		for c in temp_characters:
			_characters.append(c as Character)
			
		var temp_available_characters = character_repository.get_available_characters()
		for c in temp_available_characters:
			_available_characters.append(c as Character)
		
		_update_statistics()

## Load character enums
func _load_character_enums() -> void:
	_character_classes = ["TANK", "HEALER", "SUPPORT", "ATTACKER"]
	_character_qualities = ["ONE_STAR", "TWO_STAR", "THREE_STAR"]

## Update character statistics
func _update_statistics() -> void:
	_total_characters = _characters.size()
	_available_count = _available_characters.size()
	_busy_count = _total_characters - _available_count
	
	# Calculate average level
	if _total_characters > 0:
		var total_level = 0
		for character in _characters:
			total_level += character.level
		_average_level = float(total_level) / float(_total_characters)
	else:
		_average_level = 0.0
	
	# Notify property changes
	_notify_property_changed("total_characters", 0, _total_characters)
	_notify_property_changed("available_count", 0, _available_count)
	_notify_property_changed("busy_count", 0, _busy_count)
	_notify_property_changed("average_level", 0.0, _average_level)

## Get data for a property
func get_data(property_name: String) -> Variant:
	match property_name:
		"characters": return _characters
		"selected_character": return _selected_character
		"available_characters": return _available_characters
		"character_classes": return _character_classes
		"character_qualities": return _character_qualities
		"total_characters": return _total_characters
		"available_count": return _available_count
		"busy_count": return _busy_count
		"average_level": return _average_level
		"recruitment_costs": return _recruitment_costs
		"can_recruit": return _can_recruit
		"recruitment_error": return _recruitment_error
		"training_options": return _training_options
		"selected_training": return _selected_training
		"training_cost": return _training_cost
		"can_train": return _can_train
		_: return null

## Set data for a property
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"selected_character": 
			_selected_character = value
			_update_training_options()
		"selected_training":
			_selected_training = value
			_update_training_cost()
		_: 
			super.set_data(property_name, value)

## Update a property
func _update_property(property_name: String, value: Variant) -> void:
	match property_name:
		"selected_character": _selected_character = value
		"selected_training": _selected_training = value
		_: pass

## Select a character
func select_character(character: Character) -> void:
	_selected_character = character
	_update_training_options()
	_notify_property_changed("selected_character", null, character)

## Get character by ID
func get_character_by_id(character_id: String) -> Character:
	for character in _characters:
		if character.id == character_id:
			return character
	return null

## Get characters by class
func get_characters_by_class(character_class: Character.CharacterClass) -> Array[Character]:
	var filtered_characters: Array[Character] = []
	for character in _characters:
		if character.character_class == character_class:
			filtered_characters.append(character)
	return filtered_characters

## Get characters by quality
func get_characters_by_quality(quality: Character.Quality) -> Array[Character]:
	var filtered_characters: Array[Character] = []
	for character in _characters:
		if character.quality == quality:
			filtered_characters.append(character)
	return filtered_characters

## Update recruitment costs
func update_recruitment_costs() -> void:
	if not ServiceManager or not ServiceManager.is_initialized():
		return
	
	var character_service = ServiceManager.get_character_service()
	if character_service:
		_recruitment_costs = character_service.get_recruitment_costs()
		_can_recruit = character_service.can_recruit_character()
		_recruitment_error = character_service.get_last_error()

## Update training options
func _update_training_options() -> void:
	if not _selected_character or not ServiceManager or not ServiceManager.is_initialized():
		_training_options.clear()
		return
	
	var training_service = ServiceManager.get_training_service()
	if training_service:
		_training_options = training_service.get_training_options(_selected_character.id)

## Update training cost
func _update_training_cost() -> void:
	if not _selected_character or not _selected_training or not ServiceManager or not ServiceManager.is_initialized():
		_training_cost.clear()
		_can_train = false
		return
	
	var training_service = ServiceManager.get_training_service()
	if training_service:
		_training_cost = training_service.calculate_training_cost(_selected_character.id, _selected_training)
		_can_train = training_service.can_train_character(_selected_character.id, _selected_training)

## Recruit a character
func recruit_character(character_class: String, quality: String) -> bool:
	if not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var character_service = ServiceManager.get_character_service()
	if character_service:
		# Convert string names to enum values
		var class_enum = Character.CharacterClass.get(character_class)
		var quality_enum = Character.Quality.get(quality)
		
		# Create character data dictionary
		var character_data = {
			"class": class_enum,
			"quality": quality_enum,
			"name": "Recruited " + character_class
		}
		
		var character = character_service.recruit_character(character_data)
		if character:
			_load_character_data()
			return true
	return false

## Train a character
func train_character() -> bool:
	if not _selected_character or not _selected_training or not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var training_service = ServiceManager.get_training_service()
	if training_service:
		var success = training_service.train_character(_selected_character.id, _selected_training)
		if success:
			_load_character_data()
		return success
	return false

## Equip a character
func equip_character(equipment_slot: String, equipment_id: String) -> bool:
	if not _selected_character or not ServiceManager or not ServiceManager.is_initialized():
		return false
	
	var equipment_service = ServiceManager.get_equipment_service()
	if equipment_service:
		var success = equipment_service.equip_character(_selected_character.id, equipment_slot, equipment_id)
		if success:
			_load_character_data()
		return success
	return false

## Get character statistics summary
func get_character_statistics_summary() -> Dictionary:
	return {
		"total_characters": _total_characters,
		"available_count": _available_count,
		"busy_count": _busy_count,
		"average_level": _average_level,
		"selected_character": _selected_character.id if _selected_character else "",
		"can_recruit": _can_recruit,
		"can_train": _can_train
	}

## Refresh all data
func refresh() -> void:
	_load_character_data()
	update_recruitment_costs()
	_update_training_options()
	_update_training_cost()

## Event handlers
func _on_character_recruited(_event: BaseEvent) -> void:
	_load_character_data()

func _on_character_leveled_up(_event: BaseEvent) -> void:
	_load_character_data()

func _on_character_trained(_event: BaseEvent) -> void:
	_load_character_data()

func _on_character_equipped(_event: BaseEvent) -> void:
	_load_character_data()

func _on_guild_resource_changed(_event: BaseEvent) -> void:
	update_recruitment_costs()
	_update_training_cost()

## Validate ViewModel state
func validate() -> bool:
	return super.validate() and ServiceManager != null and ServiceManager.is_initialized()
