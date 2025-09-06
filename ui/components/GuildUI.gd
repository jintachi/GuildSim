extends BaseUIComponent
class_name GuildUI

## Guild management UI component
## Handles guild resources, upgrades, and room management

# UI elements

# Guild overview UI
var _guild_name_label: Label = null
var _guild_level_label: Label = null
var _guild_reputation_label: Label = null
var _guild_efficiency_label: Label = null

# Resource UI
var _gold_label: Label = null
var _influence_label: Label = null
var _food_label: Label = null
var _building_materials_label: Label = null

# Room management UI
var _unlocked_rooms_list: ItemList = null
var _available_rooms_list: ItemList = null
var _unlock_room_button: Button = null
var _room_cost_label: Label = null

# Upgrade UI
var _available_upgrades_list: ItemList = null
var _purchase_upgrade_button: Button = null
var _upgrade_cost_label: Label = null

# ViewModel reference
var _guild_view_model: GuildViewModel = null

func _init():
	_component_id = "GuildUI"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()
	
	# UI updates will happen in _on_initialized() after view model is available
	_update_button_states()

## Create UI layout
func _create_ui_layout() -> void:
	# Find UI elements from the already loaded scene
	_find_ui_elements()

## Find UI elements from the loaded scene
func _find_ui_elements() -> void:
	# Find UI elements by their node paths
	_guild_name_label = find_child("GuildNameLabel", true, false)
	_guild_level_label = find_child("GuildLevelLabel", true, false)
	_guild_reputation_label = find_child("GuildReputationLabel", true, false)
	_guild_efficiency_label = find_child("GuildEfficiencyLabel", true, false)
	_gold_label = find_child("GoldLabel", true, false)
	_influence_label = find_child("InfluenceLabel", true, false)
	_food_label = find_child("FoodLabel", true, false)
	_building_materials_label = find_child("BuildingMaterialsLabel", true, false)
	_unlocked_rooms_list = find_child("UnlockedRoomsList", true, false)
	_available_rooms_list = find_child("AvailableRoomsList", true, false)
	_unlock_room_button = find_child("UnlockRoomButton", true, false)
	_room_cost_label = find_child("RoomCostLabel", true, false)
	_available_upgrades_list = find_child("AvailableUpgradesList", true, false)
	_purchase_upgrade_button = find_child("PurchaseUpgradeButton", true, false)
	_upgrade_cost_label = find_child("UpgradeCostLabel", true, false)
	
	# Connect signals
	if _unlocked_rooms_list:
		_unlocked_rooms_list.item_selected.connect(_on_unlocked_room_selected)
	if _available_rooms_list:
		_available_rooms_list.item_selected.connect(_on_available_room_selected)
	if _unlock_room_button:
		_unlock_room_button.pressed.connect(_on_unlock_room_button_pressed)
	if _available_upgrades_list:
		_available_upgrades_list.item_selected.connect(_on_upgrade_selected)
	if _purchase_upgrade_button:
		_purchase_upgrade_button.pressed.connect(_on_purchase_upgrade_button_pressed)

## Signal handlers for UI interactions
func _on_unlocked_room_selected(index: int) -> void:
	if _guild_view_model:
		_guild_view_model.set_selected_unlocked_room(index)

func _on_available_room_selected(index: int) -> void:
	if _guild_view_model:
		_guild_view_model.set_selected_available_room(index)
		_update_room_cost()

func _on_unlock_room_button_pressed() -> void:
	if _guild_view_model:
		# Get selected room and unlock it
		var selected_items: Array = []
		if _available_rooms_list:
			selected_items = _available_rooms_list.get_selected_items()
		if not selected_items.is_empty():
			var selected_index = selected_items[0]
			var room_costs = _guild_view_model.get_data("room_costs")
			var available_rooms = room_costs.keys() if room_costs else []
			if selected_index < available_rooms.size():
				var room_name = available_rooms[selected_index]
				_guild_view_model.unlock_room(room_name)

func _on_upgrade_selected(index: int) -> void:
	if _guild_view_model:
		_guild_view_model.set_selected_upgrade(index)
		_update_upgrade_cost()

func _on_purchase_upgrade_button_pressed() -> void:
	if _guild_view_model:
		# Get selected upgrade and purchase it
		var selected_items: Array = []
		if _available_upgrades_list:
			selected_items = _available_upgrades_list.get_selected_items()
		if not selected_items.is_empty():
			var selected_index = selected_items[0]
			var available_upgrades = _guild_view_model.get_data("available_upgrades")
			if selected_index < available_upgrades.size():
				var upgrade = available_upgrades[selected_index]
				var upgrade_name = upgrade.get("name", "") if upgrade else ""
				_guild_view_model.purchase_upgrade(upgrade_name)


## Setup data bindings
func _setup_data_bindings() -> void:
	if not _guild_view_model:
		return
	
	# Bind guild data
	_guild_view_model.watch_property("guild", _on_guild_changed)
	_guild_view_model.watch_property("guild_level", _on_guild_level_changed)
	_guild_view_model.watch_property("guild_reputation", _on_guild_reputation_changed)
	_guild_view_model.watch_property("guild_efficiency", _on_guild_efficiency_changed)
	_guild_view_model.watch_property("gold", _on_gold_changed)
	_guild_view_model.watch_property("influence", _on_influence_changed)
	_guild_view_model.watch_property("food", _on_food_changed)
	_guild_view_model.watch_property("building_materials", _on_building_materials_changed)
	_guild_view_model.watch_property("unlocked_rooms", _on_unlocked_rooms_changed)
	_guild_view_model.watch_property("available_upgrades", _on_available_upgrades_changed)
	_guild_view_model.watch_property("room_costs", _on_room_costs_changed)
	_guild_view_model.watch_property("upgrade_costs", _on_upgrade_costs_changed)
	_guild_view_model.watch_property("can_unlock_room", _on_can_unlock_room_changed)
	_guild_view_model.watch_property("can_upgrade", _on_can_upgrade_changed)

## Handle initialization
func _on_initialized() -> void:
	super._on_initialized()
	_guild_view_model = _view_model as GuildViewModel

## Handle view model ready
func _on_view_model_ready() -> void:
	super._on_view_model_ready()
	
	# Now that view model is available, update the UI
	_update_guild_overview()
	_update_resources()
	_update_room_lists()
	_update_upgrade_list()
	_update_room_cost()
	_update_upgrade_cost()

## Update guild overview
func _update_guild_overview() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _guild_name_label:
		return
	
	var guild = _guild_view_model.get_data("guild")
	
	if not guild:
		_guild_name_label.text = "Name: -"
		_guild_level_label.text = "Level: -"
		_guild_reputation_label.text = "Reputation: -"
		_guild_efficiency_label.text = "Efficiency: -"
		return
	
	_guild_name_label.text = "Name: %s" % guild.guild_name
	_guild_level_label.text = "Level: %d" % guild.level
	_guild_reputation_label.text = "Reputation: %d" % guild.reputation
	# Note: Efficiency calculation could be added here based on guild performance metrics
	_guild_efficiency_label.text = "Efficiency: N/A"

## Update resources
func _update_resources() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _gold_label:
		return
	
	var gold = _guild_view_model.get_data("gold")
	var influence = _guild_view_model.get_data("influence")
	var food = _guild_view_model.get_data("food")
	var building_materials = _guild_view_model.get_data("building_materials")
	
	_gold_label.text = "Gold: %d" % gold
	_influence_label.text = "Influence: %d" % influence
	_food_label.text = "Food: %d" % food
	_building_materials_label.text = "Building Materials: %d" % building_materials

## Update room lists
func _update_room_lists() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _unlocked_rooms_list or not _available_rooms_list:
		return
	
	# Clear lists
	_unlocked_rooms_list.clear()
	_available_rooms_list.clear()
	
	# Get room data
	var unlocked_rooms = _guild_view_model.get_data("unlocked_rooms")
	var room_costs = _guild_view_model.get_data("room_costs")
	
	# Add unlocked rooms
	for room in unlocked_rooms:
		_unlocked_rooms_list.add_item(room)
	
	# Add available rooms
	for room_name in room_costs:
		if not unlocked_rooms.has(room_name):
			_available_rooms_list.add_item(room_name)

## Update upgrade list
func _update_upgrade_list() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _available_upgrades_list:
		return
	
	_available_upgrades_list.clear()
	var available_upgrades = _guild_view_model.get_data("available_upgrades")
	
	for upgrade in available_upgrades:
		var upgrade_name = upgrade.get("name", "")
		var upgrade_description = upgrade.get("description", "")
		var item_text = "%s: %s" % [upgrade_name, upgrade_description]
		_available_upgrades_list.add_item(item_text)

## Update room cost
func _update_room_cost() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _room_cost_label or not _available_rooms_list:
		return
	
	var selected_items = _available_rooms_list.get_selected_items()
	if selected_items.is_empty():
		_room_cost_label.text = "Cost: -"
		return
	
	var selected_index = selected_items[0]
	var room_costs = _guild_view_model.get_data("room_costs")
	var available_rooms = room_costs.keys()
	
	if selected_index < available_rooms.size():
		var room_name = available_rooms[selected_index]
		var cost = room_costs.get(room_name, {})
		
		if cost and not cost.is_empty():
			var cost_text = "Cost: "
			var cost_parts = []
			for resource in cost:
				var cost_value = cost[resource]
				if cost_value is int or cost_value is float:
					cost_parts.append("%d %s" % [int(cost_value), resource])
				else:
					cost_parts.append("%s %s" % [str(cost_value), resource])
			cost_text += ", ".join(cost_parts)
			_room_cost_label.text = cost_text
		else:
			_room_cost_label.text = "Cost: -"

## Update upgrade cost
func _update_upgrade_cost() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model or not _upgrade_cost_label or not _available_upgrades_list:
		return
	
	var selected_items = _available_upgrades_list.get_selected_items()
	if selected_items.is_empty():
		_upgrade_cost_label.text = "Cost: -"
		return
	
	var selected_index = selected_items[0]
	var available_upgrades = _guild_view_model.get_data("available_upgrades")
	
	if selected_index < available_upgrades.size():
		var upgrade = available_upgrades[selected_index]
		var upgrade_name = upgrade.get("name", "")
		var upgrade_costs = _guild_view_model.get_data("upgrade_costs")
		var cost = upgrade_costs.get(upgrade_name, {})
		
		if cost and not cost.is_empty():
			var cost_text = "Cost: "
			var cost_parts = []
			for resource in cost:
				var cost_value = cost[resource]
				if cost_value is int or cost_value is float:
					cost_parts.append("%d %s" % [int(cost_value), resource])
				else:
					cost_parts.append("%s %s" % [str(cost_value), resource])
			cost_text += ", ".join(cost_parts)
			_upgrade_cost_label.text = cost_text
		else:
			_upgrade_cost_label.text = "Cost: -"

## Update button states
func _update_button_states() -> void:
	# Check if ViewModel and UI elements are ready
	if not _guild_view_model:
		return
	
	var can_unlock_room = _guild_view_model.get_data("can_unlock_room")
	var can_upgrade = _guild_view_model.get_data("can_upgrade")
	
	if _unlock_room_button:
		_unlock_room_button.disabled = not can_unlock_room
	
	if _purchase_upgrade_button:
		_purchase_upgrade_button.disabled = not can_upgrade


## Property change handlers
func _on_guild_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_guild_overview()

func _on_guild_level_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_guild_overview()

func _on_guild_reputation_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_guild_overview()

func _on_guild_efficiency_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_guild_overview()

func _on_gold_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_resources()

func _on_influence_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_resources()

func _on_food_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_resources()

func _on_building_materials_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_resources()

func _on_unlocked_rooms_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_room_lists()

func _on_available_upgrades_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_upgrade_list()

func _on_room_costs_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_room_lists()
	_update_room_cost()

func _on_upgrade_costs_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_upgrade_cost()

func _on_can_unlock_room_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

func _on_can_upgrade_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_button_states()

## Update component
func update_component() -> void:
	super.update_component()
	_update_guild_overview()
	_update_resources()
	_update_room_lists()
	_update_upgrade_list()
	_update_room_cost()
	_update_upgrade_cost()
	_update_button_states()

## Refresh component data
func refresh() -> void:
	super.refresh()
	if _guild_view_model:
		_guild_view_model.refresh()
