class_name EquipmentService
extends BaseService

## Service for managing equipment and item business logic
## Handles item creation, equipment management, and item effects

var _character_service: CharacterService
var _guild_service: GuildService

# Service statistics
var _items_created: int = 0
var _items_equipped: int = 0
var _items_unequipped: int = 0
var _equipment_durability_lost: int = 0

func _init():
	super._init("EquipmentService")

## Initialize with dependencies
func initialize_with_dependencies(character_service: CharacterService, guild_service: GuildService) -> void:
	_character_service = character_service
	_guild_service = guild_service

## Create a new item
func create_item(item_data: Dictionary) -> GameResource:
	if not _validate_dependencies():
		return null
	
	var item = GameResource.new()
	
	# Set basic properties
	item.name = item_data.get("name", "Unknown Item")
	item.description = item_data.get("description", "A mysterious item.")
	item.resource_type = item_data.get("resource_type", GameResource.ResourceType.WOOD) # Use Wood as a placeholder
	item.category = item_data.get("category", GameResource.ItemCategory.RESOURCE)
	item.rarity = item_data.get("rarity", GameResource.Rarity.COMMON)
	
	# Set item properties
	item.base_value = item_data.get("base_value", 0)
	item.stack_size = item_data.get("stack_size", 1)
	item.max_stack_size = item_data.get("max_stack_size", 999)
	item.is_tradeable = item_data.get("is_tradeable", true)
	item.is_consumable = item_data.get("is_consumable", false)
	item.is_equipment = item_data.get("is_equipment", false)
	
	# Set equipment properties if applicable
	if item.is_equipment:
		item.equipment_slot = item_data.get("equipment_slot", "")
		item.stat_bonuses = item_data.get("stat_bonuses", {})
		item.equipment_requirements = item_data.get("equipment_requirements", {})
	
	# Set consumable properties if applicable
	if item.is_consumable:
		item.charges = item_data.get("charges", 1)
		item.max_charges = item_data.get("max_charges", 1)
		item.effect_description = item_data.get("effect_description", "")
		item.effect_data = item_data.get("effect_data", {})
	
	# Set quest properties if applicable
	item.quest_id = item_data.get("quest_id", "")
	item.is_quest_reward = item_data.get("is_quest_reward", false)
	item.is_quest_requirement = item_data.get("is_quest_requirement", false)
	
	# Set metadata
	item.source = item_data.get("source", "EquipmentService")
	item.tags.append(item_data.get("tags"))
	
	# Validate item
	if not item.validate():
		push_error("Invalid item data: " + str(item_data))
		return null
	
	_items_created += 1
	log_activity("Created item: " + item.name + " (" + GameResource.Rarity.keys()[item.rarity] + ")")
	return item

## Create equipment item
func create_equipment(equipment_data: Dictionary) -> GameResource:
	var item_data = equipment_data.duplicate()
	item_data["is_equipment"] = true
	item_data["category"] = GameResource.ItemCategory.EQUIPMENT
	
	# Generate stat bonuses based on rarity
	if not item_data.has("stat_bonuses"):
		item_data["stat_bonuses"] = _generate_equipment_stat_bonuses(item_data.get("rarity", GameResource.Rarity.COMMON))
	
	# Set durability based on rarity
	if not item_data.has("durability"):
		item_data["durability"] = _balance_config.equipment_durability.get(
			GameResource.Rarity.keys()[item_data.get("rarity", GameResource.Rarity.COMMON)], 100
		)
	if not item_data.has("tags") :
		item_data.set_data("tags",[""])
		
	return create_item(item_data)

## Generate equipment stat bonuses based on rarity
func _generate_equipment_stat_bonuses(rarity: GameResource.Rarity) -> Dictionary:
	var rarity_config = _balance_config.equipment_stat_bonuses.get(
		GameResource.Rarity.keys()[rarity], {"multiplier": 1.0, "base_bonus": 5}
	)
	
	var bonuses = {}
	var stats = ["health", "defense", "attack", "speed", "intelligence", "charisma"]
	
	# Randomly select 2-3 stats to boost
	var num_stats = randi_range(2, 3)
	var selected_stats = []
	
	for i in range(num_stats):
		var stat = stats[randi() % stats.size()]
		if stat not in selected_stats:
			selected_stats.append(stat)
	
	# Apply bonuses
	for stat in selected_stats:
		var base_bonus = rarity_config.base_bonus
		var multiplier = rarity_config.multiplier
		var bonus = int(base_bonus * multiplier * randf_range(0.8, 1.2))
		bonuses[stat] = bonus
	
	return bonuses

## Create consumable item
func create_consumable(consumable_data: Dictionary) -> GameResource:
	var item_data = consumable_data.duplicate()
	item_data["is_consumable"] = true
	item_data["category"] = GameResource.ItemCategory.CONSUMABLE
	
	return create_item(item_data)

## Create material item
func create_material(material_data: Dictionary) -> GameResource:
	var item_data = material_data.duplicate()
	item_data["category"] = GameResource.ItemCategory.MATERIAL
	item_data["is_tradeable"] = true
	
	return create_item(item_data)

## Equip item to character
func equip_item(character: Character, item: GameResource, equipment_slot: String) -> bool:
	if not _validate_dependencies():
		return false
	
	# Check if item is equipment
	if not item.is_equipment_item():
		emit_simple_event("item_not_equipment", {
			"item_id": item.id,
			"item_name": item.name,
			"character_id": character.id
		})
		return false
	
	# Check if character meets requirements
	if not item.can_equip(character):
		emit_simple_event("equipment_requirements_not_met", {
			"item_id": item.id,
			"item_name": item.name,
			"character_id": character.id,
			"requirements": item.get_equipment_requirements()
		})
		return false
	
	# Check if slot is valid
	if item.equipment_slot != equipment_slot:
		emit_simple_event("invalid_equipment_slot", {
			"item_id": item.id,
			"item_name": item.name,
			"character_id": character.id,
			"required_slot": item.equipment_slot,
			"provided_slot": equipment_slot
		})
		return false
	
	# Unequip current item in slot if any
	var current_item_id = character.get_data(equipment_slot)
	if current_item_id != "":
		unequip_item(character, equipment_slot)
	
	# Equip new item
	character.set(equipment_slot, item.id)
	
	# Update character in repository
	if _character_service and _character_service._character_repository:
		_character_service._character_repository.update(character)
	
	# Update statistics
	_items_equipped += 1
	
	# Emit equipment event
	var event = CharacterEvents.CharacterEquippedItemEvent.new(character, item, equipment_slot)
	emit_event(event)
	
	log_activity("Equipped " + item.name + " to " + character.character_name + " in " + equipment_slot)
	return true

## Unequip item from character
func unequip_item(character: Character, equipment_slot: String) -> bool:
	if not _validate_dependencies():
		return false
	
	var item_id = character.get_data(equipment_slot)
	if item_id == "":
		return false  # No item equipped in this slot
	
	# Get item (would need item repository in real implementation)
	# For now, we'll just clear the slot
	character.set(equipment_slot, "")
	
	# Update character in repository
	if _character_service and _character_service._character_repository:
		_character_service._character_repository.update(character)
	
	# Update statistics
	_items_unequipped += 1
	
	# Emit unequipment event (would need item reference)
	emit_simple_event("character_unequipped_item", {
		"character_id": character.id,
		"character_name": character.character_name,
		"equipment_slot": equipment_slot,
		"item_id": item_id
	})
	
	log_activity("Unequipped item from " + character.character_name + " in " + equipment_slot)
	return true

## Use consumable item
func use_consumable(character: Character, item: GameResource) -> bool:
	if not _validate_dependencies():
		return false
	
	# Check if item is consumable
	if not item.is_consumable_item():
		emit_simple_event("item_not_consumable", {
			"item_id": item.id,
			"item_name": item.name,
			"character_id": character.id
		})
		return false
	
	# Check if item has charges
	if item.charges <= 0:
		emit_simple_event("item_no_charges", {
			"item_id": item.id,
			"item_name": item.name,
			"character_id": character.id
		})
		return false
	
	# Apply consumable effects
	var effects = item.get_consumable_effects()
	var success = _apply_consumable_effects(character, effects)
	
	if success:
		# Consume charge
		item.charges -= 1
		
		# Update character in repository
		if _character_service and _character_service._character_repository:
			_character_service._character_repository.update(character)
		
		log_activity("Used consumable " + item.name + " on " + character.character_name)
		return true
	
	return false

## Apply consumable effects to character
func _apply_consumable_effects(character: Character, effects: Dictionary) -> bool:
	var success = true
	
	for effect_type in effects:
		var effect_value = effects[effect_type]
		
		match effect_type:
			"heal":
				character.health = min(character.health + effect_value, character.health)
			"heal_injury":
				if character.current_injury != Character.InjuryType.NONE:
					character.current_injury = Character.InjuryType.NONE
					character.injury_severity = 0
					character.injury_duration = 0.0
			"stat_boost":
				# Apply temporary stat boost (would need temporary effect system)
				pass
			"experience":
				if _character_service:
					_character_service.add_experience(character, effect_value)
			_:
				push_warning("Unknown consumable effect: " + effect_type)
				success = false
	
	return success

## Calculate equipment bonuses for character
func calculate_equipment_bonuses(character: Character) -> Dictionary:
	var total_bonuses = {
		"health": 0,
		"defense": 0,
		"attack": 0,
		"speed": 0,
		"intelligence": 0,
		"charisma": 0
	}
	
	# Check each equipment slot
	var equipment_slots = ["equipped_weapon", "equipped_armor", "equipped_accessory"]
	
	for slot in equipment_slots:
		var item_id = character.get_data(slot)
		if item_id != "":
			# In a real implementation, we'd look up the item by ID
			# For now, we'll simulate equipment bonuses
			var slot_bonuses = _get_simulated_equipment_bonuses(slot)
			for stat in slot_bonuses:
				total_bonuses[stat] += slot_bonuses[stat]
	
	return total_bonuses

## Get simulated equipment bonuses (placeholder)
func _get_simulated_equipment_bonuses(equipment_slot: String) -> Dictionary:
	var bonuses = {}
	
	match equipment_slot:
		"equipped_weapon":
			bonuses = {"attack": 10, "speed": 5}
		"equipped_armor":
			bonuses = {"health": 20, "defense": 15}
		"equipped_accessory":
			bonuses = {"intelligence": 8, "charisma": 8}
	
	return bonuses

## Repair equipment
func repair_equipment(character: Character, equipment_slot: String, repair_cost: Dictionary) -> bool:
	if not _validate_dependencies():
		return false
	
	# Check if guild can afford repair
	if _guild_service and not _guild_service.can_afford_cost(repair_cost):
		emit_simple_event("insufficient_resources", {
			"required": repair_cost,
			"operation": "equipment_repair"
		})
		return false
	
	# Spend repair cost
	if _guild_service:
		_guild_service.spend_resources(repair_cost)
	
	# Repair equipment (would need durability system)
	# For now, we'll just log the repair
	log_activity("Repaired equipment in " + equipment_slot + " for " + character.character_name)
	return true

## Get equipment service statistics
func get_equipment_statistics() -> Dictionary:
	return {
		"service_name": _service_name,
		"items_created": _items_created,
		"items_equipped": _items_equipped,
		"items_unequipped": _items_unequipped,
		"equipment_durability_lost": _equipment_durability_lost
	}

## Get service statistics
func get_statistics() -> Dictionary:
	var base_stats = super.get_statistics()
	var equipment_stats = get_equipment_statistics()
	base_stats.merge(equipment_stats)
	return base_stats
