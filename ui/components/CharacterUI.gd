extends BaseUIComponent
class_name CharacterUI

## Character management UI component
## Handles character roster, recruitment, and training

# UI elements
var _character_list: ItemList = null

# Character details UI
var _character_name_label: Label = null
var _character_class_label: Label = null
var _character_level_label: Label = null
var _character_stats_container: VBoxContainer = null

# Recruitment UI
var _class_selection: OptionButton = null
var _quality_selection: OptionButton = null
var _recruit_button: Button = null
var _recruitment_cost_label: Label = null

# Training UI
var _training_options_list: ItemList = null
var _training_cost_label: Label = null
var _train_button: Button = null

# Statistics UI
var _stats_label: Label = null

# ViewModel reference
var _character_view_model: CharacterViewModel = null

func _init():
	_component_id = "CharacterUI"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()
	
	# UI updates will happen in _on_initialized() after view model is available
	_update_training_cost()
	_update_recruitment_cost()
	_update_button_states()

## Create UI layout
func _create_ui_layout() -> void:
	# Find UI elements from the already loaded scene
	_find_ui_elements()

## Find UI elements from the loaded scene
func _find_ui_elements() -> void:
	# Find UI elements by their node paths
	_character_list = find_child("CharacterList", true, false)
	_character_name_label = find_child("CharacterNameLabel", true, false)
	_character_class_label = find_child("CharacterClassLabel", true, false)
	_character_level_label = find_child("CharacterLevelLabel", true, false)
	_character_stats_container = find_child("CharacterStatsContainer", true, false)
	_class_selection = find_child("ClassSelection", true, false)
	_quality_selection = find_child("QualitySelection", true, false)
	_recruit_button = find_child("RecruitButton", true, false)
	_recruitment_cost_label = find_child("RecruitmentCostLabel", true, false)
	_training_options_list = find_child("TrainingOptionsList", true, false)
	_training_cost_label = find_child("TrainingCostLabel", true, false)
	_train_button = find_child("TrainButton", true, false)
	_stats_label = find_child("StatsLabel", true, false)
	
	# Connect signals
	if _character_list:
		_character_list.item_selected.connect(_on_character_selected)
	if _class_selection:
		_class_selection.item_selected.connect(_on_class_selection_changed)
	if _quality_selection:
		_quality_selection.item_selected.connect(_on_quality_selection_changed)
	if _recruit_button:
		_recruit_button.pressed.connect(_on_recruit_button_pressed)
	if _training_options_list:
		_training_options_list.item_selected.connect(_on_training_option_selected)
	if _train_button:
		_train_button.pressed.connect(_on_train_button_pressed)

## Signal handlers for UI interactions
func _on_class_selection_changed(index: int) -> void:
	if _character_view_model:
		_character_view_model.set_selected_class(index)
		_update_recruitment_cost()

func _on_quality_selection_changed(index: int) -> void:
	if _character_view_model:
		_character_view_model.set_selected_quality(index)
		_update_recruitment_cost()

## Setup data bindings
func _setup_data_bindings() -> void:
	if not _character_view_model:
		return
	
	# Bind character list
	_character_view_model.watch_property("characters", _on_characters_changed)
	_character_view_model.watch_property("available_characters", _on_available_characters_changed)
	_character_view_model.watch_property("selected_character", _on_selected_character_changed)
	_character_view_model.watch_property("recruitment_costs", _on_recruitment_costs_changed)
	_character_view_model.watch_property("training_options", _on_training_options_changed)
	_character_view_model.watch_property("training_cost", _on_training_cost_changed)
	_character_view_model.watch_property("can_recruit", _on_can_recruit_changed)
	_character_view_model.watch_property("can_train", _on_can_train_changed)

## Handle initialization
func _on_initialized() -> void:
	_character_view_model = _view_model as CharacterViewModel
	#intentionally not calling super._on_initialized() as the super class has the "_is_initialized = true" line for all elements
	super._on_initialized()

## Handle view model ready
func _on_view_model_ready() -> void:
	super._on_view_model_ready()
	
	# Now that view model is available, update the UI
	_populate_character_classes()
	_populate_character_qualities()
	_update_character_list()
	_update_statistics()
	_update_character_details()
	_update_training_options()

## Populate character classes
func _populate_character_classes() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _class_selection:
		return
	
	_class_selection.clear()
	var classes = _character_view_model.get_data("character_classes")
	for char_class_name in classes:
		_class_selection.add_item(char_class_name)

## Populate character qualities
func _populate_character_qualities() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _quality_selection:
		return
	
	_quality_selection.clear()
	var qualities = _character_view_model.get_data("character_qualities")
	for quality in qualities:
		_quality_selection.add_item(quality)

## Update character list
func _update_character_list() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _character_list:
		return
	
	_character_list.clear()
	var characters = _character_view_model.get_data("characters")
	
	for character in characters:
		var status = "Available" if character.status == Character.CharacterStatus.AVAILABLE else "Busy"
		var char_class_name = Character.CharacterClass.keys()[character.character_class]
		var item_text = "%s (Lv.%d %s) - %s" % [character.character_name, character.level, char_class_name, status]
		_character_list.add_item(item_text)

## Update statistics
func _update_statistics() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _stats_label:
		return
	
	var total = _character_view_model.get_data("total_characters")
	var available = _character_view_model.get_data("available_count")
	var busy = _character_view_model.get_data("busy_count")
	
	_stats_label.text = "Total: %d | Available: %d | Busy: %d" % [total, available, busy]

## Update character details
func _update_character_details() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _character_name_label:
		return
	
	var selected_character = _character_view_model.get_data("selected_character")
	
	if not selected_character:
		_character_name_label.text = "Name: -"
		_character_class_label.text = "Class: -"
		_character_level_label.text = "Level: -"
		_clear_character_stats()
		return
	
	_character_name_label.text = "Name: %s" % selected_character.character_name
	var char_class_name = Character.CharacterClass.keys()[selected_character.character_class]
	_character_class_label.text = "Class: %s" % char_class_name
	_character_level_label.text = "Level: %d" % selected_character.level
	
	_update_character_stats(selected_character)

## Update character stats
func _update_character_stats(character: Character) -> void:
	_clear_character_stats()
	
	if not character:
		return
	
	# Display base stats
	var base_stats = {
		"Health": character.health,
		"Defense": character.defense,
		"Attack": character.attack,
		"Speed": character.speed,
		"Intelligence": character.intelligence,
		"Charisma": character.charisma
	}
	
	for stat_name in base_stats:
		var stat_value = base_stats[stat_name]
		var stat_label = Label.new()
		stat_label.text = "%s: %d" % [stat_name, stat_value]
		_character_stats_container.add_child(stat_label)
	
	# Display sub-stats
	var substats = {
		"Gathering": character.gathering,
		"Hunting": character.hunting,
		"Diplomacy": character.diplomacy,
		"Stealth": character.stealth,
		"Leadership": character.leadership,
		"Survival": character.survival
	}
	
	for substat_name in substats:
		var substat_value = substats[substat_name]
		if substat_value > 0:  # Only show non-zero substats
			var substat_label = Label.new()
			substat_label.text = "%s: %d" % [substat_name, substat_value]
			_character_stats_container.add_child(substat_label)

## Clear character stats
func _clear_character_stats() -> void:
	for child in _character_stats_container.get_children():
		child.queue_free()

## Update training options
func _update_training_options() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _training_options_list:
		return
	
	_training_options_list.clear()
	var training_options = _character_view_model.get_data("training_options")
	
	for option in training_options:
		var option_text = "%s (+%d %s)" % [option.get("name", ""), option.get("value", 0), option.get("stat", "")]
		_training_options_list.add_item(option_text)

## Update training cost
func _update_training_cost() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _training_cost_label:
		return
	
	var training_cost = _character_view_model.get_data("training_cost")
	if training_cost and not training_cost.is_empty():
		var cost_text = "Cost: "
		var cost_parts = []
		for resource in training_cost:
			var cost_value = training_cost[resource]
			if cost_value is int or cost_value is float:
				cost_parts.append("%d %s" % [int(cost_value), resource])
			else:
				cost_parts.append("%s %s" % [str(cost_value), resource])
		cost_text += ", ".join(cost_parts)
		_training_cost_label.text = cost_text
	else:
		_training_cost_label.text = "Cost: -"

## Update recruitment cost
func _update_recruitment_cost() -> void:
	# Check if ViewModel and UI elements are ready
	if not _character_view_model or not _recruitment_cost_label:
		return
	
	var recruitment_costs = _character_view_model.get_data("recruitment_costs")
	if recruitment_costs and not recruitment_costs.is_empty():
		var cost_text = "Cost: "
		var cost_parts = []
		for resource in recruitment_costs:
			var cost_value = recruitment_costs[resource]
			if cost_value is int or cost_value is float:
				cost_parts.append("%d %s" % [int(cost_value), resource])
			else:
				cost_parts.append("%s %s" % [str(cost_value), resource])
		cost_text += ", ".join(cost_parts)
		_recruitment_cost_label.text = cost_text
	else:
		_recruitment_cost_label.text = "Cost: -"

## Update button states
func _update_button_states() -> void:
	# Check if ViewModel is ready
	if not _character_view_model:
		return
	
	var can_recruit = _character_view_model.get_data("can_recruit")
	var can_train = _character_view_model.get_data("can_train")
	
	if _recruit_button:
		_recruit_button.disabled = not can_recruit
	
	if _train_button:
		_train_button.disabled = not can_train

## Event handlers
func _on_character_selected(index: int) -> void:
	if not _character_view_model:
		return
	
	var characters = _character_view_model.get_data("characters")
	if index >= 0 and index < characters.size():
		var character = characters[index]
		_character_view_model.select_character(character)

func _on_training_option_selected(index: int) -> void:
	if not _character_view_model:
		return
	
	var training_options = _character_view_model.get_data("training_options")
	if index >= 0 and index < training_options.size():
		var option = training_options[index]
		_character_view_model.set_data("selected_training", option)

func _on_recruit_button_pressed() -> void:
	if not _character_view_model:
		return
	
	var class_index = _class_selection.selected
	var quality_index = _quality_selection.selected
	
	if class_index >= 0 and quality_index >= 0:
		var character_classes = _character_view_model.get_data("character_classes")
		var character_qualities = _character_view_model.get_data("character_qualities")
		
		var character_class = character_classes[class_index]
		var quality = character_qualities[quality_index]
		
		var success = _character_view_model.recruit_character(character_class, quality)
		if success:
			UIManager.show_notification("Character recruited successfully!")
		else:
			UIManager.show_notification("Failed to recruit character", 3.0)

func _on_train_button_pressed() -> void:
	if not _character_view_model:
		return
	
	var success = _character_view_model.train_character()
	if success:
		UIManager.show_notification("Character trained successfully!")
	else:
		UIManager.show_notification("Failed to train character", 3.0)

## Property change handlers
func _on_characters_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_character_list()
	_update_statistics()

func _on_available_characters_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_statistics()

func _on_selected_character_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_character_details()

func _on_recruitment_costs_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_recruitment_cost()

func _on_training_options_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_training_options()

func _on_training_cost_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_training_cost()

func _on_can_recruit_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

func _on_can_train_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

## Update component
func update_component() -> void:
	super.update_component()
	_update_character_list()
	_update_statistics()
	_update_character_details()
	_update_training_options()
	_update_training_cost()
	_update_recruitment_cost()
	_update_button_states()

## Refresh component data
func refresh() -> void:
	super.refresh()
	if _character_view_model:
		_character_view_model.refresh()
