extends BaseUIComponent
class_name QuestUI

## Quest management UI component
## Handles quest board, assignment, and tracking

# UI elements
var _quest_list: ItemList = null

# Quest details UI
var _quest_name_label: Label = null
var _quest_type_label: Label = null
var _quest_difficulty_label: Label = null
var _quest_rewards_container: VBoxContainer = null
var _quest_requirements_container: VBoxContainer = null

# Quest generation UI
var _quest_type_selection: OptionButton = null
var _quest_difficulty_selection: OptionButton = null
var _quest_rank_selection: OptionButton = null
var _generate_quest_button: Button = null
var _generation_cost_label: Label = null

# Quest assignment UI
var _character_selection_list: ItemList = null
var _assign_quest_button: Button = null
var _assignment_error_label: Label = null

# Statistics UI
var _stats_label: Label = null

# ViewModel reference
var _quest_view_model: QuestViewModel = null

func _init():
	_component_id = "QuestUI"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()
	
	# UI updates will happen in _on_initialized() after view model is available
	_update_generation_cost()
	_update_button_states()

## Create UI layout
func _create_ui_layout() -> void:
	# Find UI elements from the already loaded scene
	_find_ui_elements()

## Find UI elements from the loaded scene
func _find_ui_elements() -> void:
	# Find UI elements by their node paths
	_quest_list = find_child("QuestList", true, false)
	_quest_name_label = find_child("QuestNameLabel", true, false)
	_quest_type_label = find_child("QuestTypeLabel", true, false)
	_quest_difficulty_label = find_child("QuestDifficultyLabel", true, false)
	_quest_rewards_container = find_child("QuestRewardsContainer", true, false)
	_quest_requirements_container = find_child("QuestRequirementsContainer", true, false)
	_quest_type_selection = find_child("QuestTypeSelection", true, false)
	_quest_difficulty_selection = find_child("QuestDifficultySelection", true, false)
	_quest_rank_selection = find_child("QuestRankSelection", true, false)
	_generate_quest_button = find_child("GenerateQuestButton", true, false)
	_generation_cost_label = find_child("GenerationCostLabel", true, false)
	_character_selection_list = find_child("CharacterSelectionList", true, false)
	_assign_quest_button = find_child("AssignQuestButton", true, false)
	_assignment_error_label = find_child("AssignmentErrorLabel", true, false)
	_stats_label = find_child("StatsLabel", true, false)
	
	# Connect signals
	if _quest_list:
		_quest_list.item_selected.connect(_on_quest_selected)
	if _quest_type_selection:
		_quest_type_selection.item_selected.connect(_on_quest_type_selection_changed)
	if _quest_difficulty_selection:
		_quest_difficulty_selection.item_selected.connect(_on_quest_difficulty_selection_changed)
	if _quest_rank_selection:
		_quest_rank_selection.item_selected.connect(_on_quest_rank_selection_changed)
	if _generate_quest_button:
		_generate_quest_button.pressed.connect(_on_generate_quest_button_pressed)
	if _character_selection_list:
		_character_selection_list.item_selected.connect(_on_character_selection_changed)
	if _assign_quest_button:
		_assign_quest_button.pressed.connect(_on_assign_quest_button_pressed)

## Signal handlers for UI interactions
func _on_quest_type_selection_changed(index: int) -> void:
	if _quest_view_model:
		_quest_view_model.set_selected_quest_type(index)
		_update_generation_cost()

func _on_quest_difficulty_selection_changed(index: int) -> void:
	if _quest_view_model:
		_quest_view_model.set_selected_difficulty(index)
		_update_generation_cost()

func _on_quest_rank_selection_changed(index: int) -> void:
	if _quest_view_model:
		_quest_view_model.set_selected_rank(index)
		_update_generation_cost()

func _on_character_selection_changed(index: int) -> void:
	if _quest_view_model:
		_quest_view_model.toggle_character_selection(index)


## Setup data bindings
func _setup_data_bindings() -> void:
	if not _quest_view_model:
		return
	
	# Bind quest data
	_quest_view_model.watch_property("quests", _on_quests_changed)
	_quest_view_model.watch_property("available_quests", _on_available_quests_changed)
	_quest_view_model.watch_property("selected_quest", _on_selected_quest_changed)
	_quest_view_model.watch_property("generation_costs", _on_generation_costs_changed)
	_quest_view_model.watch_property("can_generate_quest", _on_can_generate_quest_changed)
	_quest_view_model.watch_property("can_assign_quest", _on_can_assign_quest_changed)

## Handle initialization
func _on_initialized() -> void:
	_quest_view_model = _view_model as QuestViewModel
	#intentionally not calling super._on_initialized() as the super class has the "_is_initialized = true" line for all elements
	super._on_initialized()

## Handle view model ready
func _on_view_model_ready() -> void:
	super._on_view_model_ready()
	
	# Now that view model is available, update the UI
	_populate_quest_types()
	_populate_quest_difficulties()
	_populate_quest_ranks()
	_update_quest_list()
	_update_statistics()
	_update_character_selection()

## Populate quest types
func _populate_quest_types() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _quest_type_selection:
		return
	
	_quest_type_selection.clear()
	var quest_types = _quest_view_model.get_data("quest_types")
	for quest_type in quest_types:
		_quest_type_selection.add_item(quest_type)

## Populate quest difficulties
func _populate_quest_difficulties() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _quest_difficulty_selection:
		return
	
	_quest_difficulty_selection.clear()
	var quest_difficulties = _quest_view_model.get_data("quest_difficulties")
	for difficulty in quest_difficulties:
		_quest_difficulty_selection.add_item(difficulty)

## Populate quest ranks
func _populate_quest_ranks() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _quest_rank_selection:
		return
	
	_quest_rank_selection.clear()
	var quest_ranks = _quest_view_model.get_data("quest_ranks")
	for rank in quest_ranks:
		_quest_rank_selection.add_item(rank)

## Update quest list
func _update_quest_list() -> void:
	# Check if UI elements are ready
	if not _quest_list:
		return
	
	# Check if ViewModel is ready
	if not _quest_view_model:
		return
	
	_quest_list.clear()

	# Get available quests
	var quests = _quest_view_model.get_data("available_quests")
	
	if quests:
		for quest in quests:
			var status = "Available"
			if quest.is_active():
				status = "Active"
			var quest_type_name = Quest.QuestType.keys()[quest.quest_type]
			var difficulty_name = Quest.QuestDifficulty.keys()[quest.difficulty]
			var item_text = "%s (%s %s) - %s" % [quest.quest_name, quest_type_name, difficulty_name, status]
			_quest_list.add_item(item_text)

## Update statistics
func _update_statistics() -> void:
	if not _stats_label or not _quest_view_model:
		return
	
	var available = _quest_view_model.get_data("available_count")
	var active = _quest_view_model.get_data("active_count")
	var completed = _quest_view_model.get_data("completed_count")
	
	_stats_label.text = "Available: %d | Active: %d | Completed: %d" % [available, active, completed]

## Update character selection
func _update_character_selection() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _character_selection_list:
		return
	
	_character_selection_list.clear()
	var available_characters = _quest_view_model.get_data("available_characters")
	
	if available_characters:
		for character in available_characters:
			var item_text = "%s (Lv.%d %s)" % [character.character_name, character.level, Character.CharacterClass.keys()[character.character_class]]
			_character_selection_list.add_item(item_text)

## Update quest details
func _update_quest_details() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _quest_name_label:
		return
	
	var selected_quest = _quest_view_model.get_data("selected_quest")
	
	if not selected_quest:
		_quest_name_label.text = "Name: -"
		_quest_type_label.text = "Type: -"
		_quest_difficulty_label.text = "Difficulty: -"
		_clear_quest_rewards()
		_clear_quest_requirements()
		return
	
	_quest_name_label.text = "Name: %s" % selected_quest.quest_name
	var quest_type_name = Quest.QuestType.keys()[selected_quest.quest_type]
	var difficulty_name = Quest.QuestDifficulty.keys()[selected_quest.difficulty]
	_quest_type_label.text = "Type: %s" % quest_type_name
	_quest_difficulty_label.text = "Difficulty: %s" % difficulty_name
	
	_update_quest_rewards(selected_quest)
	_update_quest_requirements(selected_quest)

## Update quest rewards
func _update_quest_rewards(quest: Quest) -> void:
	_clear_quest_rewards()
	
	if not quest:
		return
	
	var quest_rewards = quest.get_all_rewards()
	for reward_type in quest_rewards:
		var reward_value = quest_rewards[reward_type]
		if typeof(reward_value) == TYPE_INT and reward_value > 0:
			var reward_label = Label.new()
			reward_label.text = "%s: %d" % [reward_type, reward_value]
			_quest_rewards_container.add_child(reward_label)

## Update quest requirements
func _update_quest_requirements(quest: Quest) -> void:
	_clear_quest_requirements()
	
	if not quest:
		return
	
	# Add party size requirements
	if quest.min_party_size > 1 or quest.max_party_size < 5:
		var party_label = Label.new()
		party_label.text = "Party Size: %d-%d" % [quest.min_party_size, quest.max_party_size]
		_quest_requirements_container.add_child(party_label)
	
	# Add stat requirements
	var stat_requirements = quest.get_stat_requirements()
	for stat in stat_requirements:
		if stat_requirements[stat] > 0:
			var stat_label = Label.new()
			stat_label.text = "Min %s: %d" % [stat.capitalize(), stat_requirements[stat]]
			_quest_requirements_container.add_child(stat_label)
	
	# Add sub-stat requirements
	var substat_requirements = quest.get_substat_requirements()
	for substat in substat_requirements:
		if substat_requirements[substat] > 0:
			var substat_label = Label.new()
			substat_label.text = "Min %s: %d" % [substat.capitalize(), substat_requirements[substat]]
			_quest_requirements_container.add_child(substat_label)

## Clear quest rewards
func _clear_quest_rewards() -> void:
	for child in _quest_rewards_container.get_children():
		child.queue_free()

## Clear quest requirements
func _clear_quest_requirements() -> void:
	for child in _quest_requirements_container.get_children():
		child.queue_free()

## Update generation cost
func _update_generation_cost() -> void:
	# Check if ViewModel and UI elements are ready
	if not _quest_view_model or not _generation_cost_label:
		return
	
	var generation_cost = _quest_view_model.get_data("generation_cost")
	if generation_cost and not generation_cost.is_empty():
		var cost_text = "Cost: "
		var cost_parts = []
		for resource in generation_cost:
			var cost_value = generation_cost[resource]
			if cost_value is int or cost_value is float:
				cost_parts.append("%d %s" % [int(cost_value), resource])
			else:
				cost_parts.append("%s %s" % [str(cost_value), resource])
		cost_text += ", ".join(cost_parts)
		_generation_cost_label.text = cost_text
	else:
		_generation_cost_label.text = "Cost: -"

## Update button states
func _update_button_states() -> void:
	# Check if ViewModel is ready
	if not _quest_view_model:
		return
	
	var can_generate = _quest_view_model.get_data("can_generate_quest")
	var can_assign = _quest_view_model.get_data("can_assign_quest")
	
	if _generate_quest_button:
		_generate_quest_button.disabled = not can_generate
	
	if _assign_quest_button:
		_assign_quest_button.disabled = not can_assign

## Event handlers
func _on_quest_selected(index: int) -> void:
	if not _quest_view_model:
		return
	
	var available_quests = _quest_view_model.get_data("available_quests")
	if index >= 0 and index < available_quests.size():
		var quest = available_quests[index]
		_quest_view_model.select_quest(quest)

func _on_generate_quest_button_pressed() -> void:
	if not _quest_view_model:
		return
	
	var type_index = _quest_type_selection.selected
	var difficulty_index = _quest_difficulty_selection.selected
	var rank_index = _quest_rank_selection.selected
	
	if type_index >= 0 and difficulty_index >= 0 and rank_index >= 0:
		var quest_types = _quest_view_model.get_data("quest_types")
		var quest_difficulties = _quest_view_model.get_data("quest_difficulties")
		var quest_ranks = _quest_view_model.get_data("quest_ranks")
		
		var quest_type = quest_types[type_index]
		var difficulty = quest_difficulties[difficulty_index]
		var rank = quest_ranks[rank_index]
		
		var success = _quest_view_model.generate_quest(quest_type, difficulty, rank)
		if success:
			UIManager.show_notification("Quest generated successfully!")
		else:
			UIManager.show_notification("Failed to generate quest", 3.0)

func _on_assign_quest_button_pressed() -> void:
	if not _quest_view_model:
		return
	
	var selected_items = _character_selection_list.get_selected_items()
	if selected_items.is_empty():
		_assignment_error_label.text = "Please select at least one character"
		return
	
	var available_characters = _quest_view_model.get_data("available_characters")
	var selected_characters = []
	
	if available_characters:
		for index in selected_items:
			if index < available_characters.size():
				selected_characters.append(available_characters[index].id)
	
	_quest_view_model.set_data("selected_characters", selected_characters)
	
	var success = _quest_view_model.assign_quest()
	if success:
		UIManager.show_notification("Quest assigned successfully!")
		_assignment_error_label.text = ""
	else:
		_assignment_error_label.text = "Failed to assign quest"

## Property change handlers
func _on_quests_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_quest_list()
	_update_statistics()

func _on_available_quests_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_quest_list()
	_update_statistics()

func _on_selected_quest_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_quest_details()

func _on_generation_costs_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_generation_cost()

func _on_can_generate_quest_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

func _on_can_assign_quest_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

## Update component
func update_component() -> void:
	super.update_component()
	_update_quest_list()
	_update_statistics()
	_update_quest_details()
	_update_character_selection()
	_update_generation_cost()
	_update_button_states()

## Refresh component data
func refresh() -> void:
	super.refresh()
	if _quest_view_model:
		_quest_view_model.refresh()
