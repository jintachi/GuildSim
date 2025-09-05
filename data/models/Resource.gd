class_name GameResource
extends Resource

## Pure data model for in-game resources
## Represents any collectible or tradeable item in the game

#region Enums
enum ResourceType {
	# Basic Resources
	GOLD,
	INFLUENCE,
	FOOD,
	BUILDING_MATERIALS,
	
	# Equipment
	WEAPONS,
	ARMOR_PIECES,
	ACCESSORIES,
	
	# Materials
	ORE,
	WOOD,
	FIBERS,
	MONSTER_PARTS,
	HERBS,
	GEMS,
	
	# Consumables
	POTIONS,
	SCROLLS,
	TOOLS,
	
	# Special
	QUEST_ITEMS,
	KEY_ITEMS,
	ARTIFACTS
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	ARTIFACT
}

enum ItemCategory {
	RESOURCE,
	EQUIPMENT,
	CONSUMABLE,
	MATERIAL,
	QUEST_ITEM,
	KEY_ITEM
}
#endregion

#region Core Properties
@export var id: String
@export var name: String
@export var description: String
@export var resource_type: ResourceType
@export var category: ItemCategory
@export var rarity: Rarity = Rarity.COMMON
#endregion

#region Properties
@export var base_value: int = 0
@export var stack_size: int = 1
@export var max_stack_size: int = 999
@export var is_tradeable: bool = true
@export var is_consumable: bool = false
@export var is_equipment: bool = false
#endregion

#region Equipment Properties (if applicable)
@export var equipment_slot: String = ""  # "weapon", "armor", "accessory"
@export var stat_bonuses: Dictionary = {}  # {"health": 10, "attack": 5}
@export var equipment_requirements: Dictionary = {}  # {"level": 5, "class": "tank"}
#endregion

#region Consumable Properties (if applicable)
@export var charges: int = 1
@export var max_charges: int = 1
@export var effect_description: String = ""
@export var effect_data: Dictionary = {}  # Effect parameters
#endregion

#region Quest Properties (if applicable)
@export var quest_id: String = ""
@export var is_quest_reward: bool = false
@export var is_quest_requirement: bool = false
#endregion

#region Metadata
@export var created_timestamp: float = 0.0
@export var source: String = ""  # Where this item came from
@export var tags: Array[String] = []  # Searchable tags
#endregion

func _init():
	id = generate_unique_id()
	created_timestamp = Time.get_unix_time_from_system()

## Generate a unique identifier for this resource
func generate_unique_id() -> String:
	return "resource_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Get the current value of this resource (base value * rarity multiplier)
func get_current_value() -> int:
	var rarity_multiplier = get_rarity_multiplier()
	return int(base_value * rarity_multiplier)

## Get rarity-based value multiplier
func get_rarity_multiplier() -> float:
	match rarity:
		Rarity.COMMON: return 1.0
		Rarity.UNCOMMON: return 1.5
		Rarity.RARE: return 2.5
		Rarity.EPIC: return 5.0
		Rarity.LEGENDARY: return 10.0
		Rarity.ARTIFACT: return 25.0
		_: return 1.0

## Check if this resource can be stacked with another
func can_stack_with(other: GameResource) -> bool:
	if id == other.id:
		return true
	
	# Same type, name, and properties
	if (resource_type == other.resource_type and 
		name == other.name and 
		rarity == other.rarity and
		base_value == other.base_value):
		return true
	
	return false

## Get effective stack size (current vs max)
func get_stack_info() -> Dictionary:
	return {
		"current": stack_size,
		"max": max_stack_size,
		"can_add": max_stack_size - stack_size,
		"is_full": stack_size >= max_stack_size
	}

## Check if this is a quest-related item
func is_quest_item() -> bool:
	return category == ItemCategory.QUEST_ITEM or category == ItemCategory.KEY_ITEM

## Check if this is equipment
func is_equipment_item() -> bool:
	return is_equipment or category == ItemCategory.EQUIPMENT

## Check if this is a consumable
func is_consumable_item() -> bool:
	return is_consumable or category == ItemCategory.CONSUMABLE

## Get equipment stat bonuses (if applicable)
func get_equipment_bonuses() -> Dictionary:
	if not is_equipment_item():
		return {}
	return stat_bonuses.duplicate()

## Get equipment requirements (if applicable)
func get_equipment_requirements() -> Dictionary:
	if not is_equipment_item():
		return {}
	return equipment_requirements.duplicate()

## Check if character meets equipment requirements
func can_equip(character: Character) -> bool:
	if not is_equipment_item():
		return false
	
	var requirements = get_equipment_requirements()
	
	# Check level requirement
	if requirements.has("level") and character.level < requirements["level"]:
		return false
	
	# Check class requirement
	if requirements.has("class"):
		var required_class = requirements["class"]
		var character_class_name = Character.CharacterClass.keys()[character.character_class].to_lower()
		if character_class_name != required_class:
			return false
	
	return true

## Get consumable effect data (if applicable)
func get_consumable_effects() -> Dictionary:
	if not is_consumable_item():
		return {}
	return effect_data.duplicate()

## Get rarity color for UI display
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.BLUE
		Rarity.EPIC: return Color.PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
		Rarity.ARTIFACT: return Color.GOLD
		_: return Color.WHITE

## Get display name with rarity prefix
func get_display_name() -> String:
	var rarity_prefix = ""
	match rarity:
		Rarity.UNCOMMON: rarity_prefix = "[Uncommon] "
		Rarity.RARE: rarity_prefix = "[Rare] "
		Rarity.EPIC: rarity_prefix = "[Epic] "
		Rarity.LEGENDARY: rarity_prefix = "[Legendary] "
		Rarity.ARTIFACT: rarity_prefix = "[Artifact] "
	
	return rarity_prefix + name

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"id": return id
		"name": return name
		"description": return description
		"resource_type": return resource_type
		"category": return category
		"rarity": return rarity
		"base_value": return base_value
		"stack_size": return stack_size
		"max_stack_size": return max_stack_size
		"is_tradeable": return is_tradeable
		"is_consumable": return is_consumable
		"is_equipment": return is_equipment
		"equipment_slot": return equipment_slot
		"stat_bonuses": return stat_bonuses
		"equipment_requirements": return equipment_requirements
		"charges": return charges
		"max_charges": return max_charges
		"effect_description": return effect_description
		"effect_data": return effect_data
		"quest_id": return quest_id
		"is_quest_reward": return is_quest_reward
		"is_quest_requirement": return is_quest_requirement
		"created_timestamp": return created_timestamp
		"source": return source
		"tags": return tags
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"id": id = value
		"name": name = value
		"description": description = value
		"resource_type": resource_type = value
		"category": category = value
		"rarity": rarity = value
		"base_value": base_value = value
		"stack_size": stack_size = value
		"max_stack_size": max_stack_size = value
		"is_tradeable": is_tradeable = value
		"is_consumable": is_consumable = value
		"is_equipment": is_equipment = value
		"equipment_slot": equipment_slot = value
		"stat_bonuses": stat_bonuses = value
		"equipment_requirements": equipment_requirements = value
		"charges": charges = value
		"max_charges": max_charges = value
		"effect_description": effect_description = value
		"effect_data": effect_data = value
		"quest_id": quest_id = value
		"is_quest_reward": is_quest_reward = value
		"is_quest_requirement": is_quest_requirement = value
		"created_timestamp": created_timestamp = value
		"source": source = value
		"tags": tags = value

## Validate resource data integrity
func validate() -> bool:
	if id.is_empty() or name.is_empty():
		return false
	
	if base_value < 0 or stack_size < 0 or max_stack_size < 1:
		return false
	
	if stack_size > max_stack_size:
		return false
	
	if is_equipment_item() and equipment_slot.is_empty():
		return false
	
	if is_consumable_item() and (charges < 0 or max_charges < 1):
		return false
	
	return true
