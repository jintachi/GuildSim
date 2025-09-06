class_name BaseRepository
extends RefCounted

## Base class for all repositories
## Provides common functionality for data access patterns

var _data: Array = []
var _index_by_id: Dictionary = {}
var _save_system: SaveSystem
var _event_bus: EventBus

func _init(save_system: SaveSystem = null, event_bus: EventBus = null):
	_save_system = save_system
	_event_bus = event_bus

## Get all entities
func get_all() -> Array:
	return _data.duplicate()

## Get entity by ID
func get_by_id(id: String) -> Variant:
	if _index_by_id.has(id):
		var index = _index_by_id[id]
		if index < _data.size():
			return _data[index]
	return null

## Check if entity exists by ID
func exists(id: String) -> bool:
	return _index_by_id.has(id) and _index_by_id[id] < _data.size()

## Get count of entities
func count() -> int:
	return _data.size()

## Add entity to repository
func add(entity: Variant) -> bool:
	if not entity.has_method("validate") or not entity.validate():
		push_error("Invalid entity data")
		return false
	
	if entity.has_method("get") and entity.get("id") in _index_by_id:
		push_error("Entity with ID already exists: " + str(entity.get("id")))
		return false
	
	_data.append(entity)
	_update_index()
	_on_entity_added(entity)
	return true

## Update existing entity
func update(entity: Variant) -> bool:
	if not entity.has_method("validate") or not entity.validate():
		push_error("Invalid entity data")
		return false
	
	var id = entity.get("id") if entity.has_method("get") else entity.id
	if not exists(id):
		push_error("Entity not found for update: " + str(id))
		return false
	
	var index = _index_by_id[id]
	_data[index] = entity
	_on_entity_updated(entity)
	return true

## Remove entity by ID
func remove(id: String) -> bool:
	if not exists(id):
		return false
	
	var index = _index_by_id[id]
	var entity = _data[index]
	_data.remove_at(index)
	_update_index()
	_on_entity_removed(entity)
	return true

## Remove entity by reference
func remove_entity(entity: Variant) -> bool:
	var id = entity.get("id") if entity.has_method("get") else entity.id
	return remove(id)

## Clear all entities
func clear() -> void:
	_data.clear()
	_index_by_id.clear()
	_on_repository_cleared()

## Find entities matching criteria
func find(criteria: Dictionary) -> Array:
	var results: Array = []
	
	for entity in _data:
		if _matches_criteria(entity, criteria):
			results.append(entity)
	
	return results

## Find first entity matching criteria
func find_first(criteria: Dictionary) -> Variant:
	for entity in _data:
		if _matches_criteria(entity, criteria):
			return entity
	return null

## Check if entity matches criteria
func _matches_criteria(entity: Variant, criteria: Dictionary) -> bool:
	for key in criteria:
		var entity_value = _get_entity_value(entity, key)
		var criteria_value = criteria[key]
		
		if entity_value != criteria_value:
			return false
	
	return true

## Get value from entity by key
func _get_entity_value(entity: Variant, key: String) -> Variant:
	if entity.has_method("get_data"):
		return entity.get_data(key)
	else:
		# Try to get property directly using Godot's property system
		return entity.get(key)

## Update the ID index
func _update_index() -> void:
	_index_by_id.clear()
	for i in range(_data.size()):
		var entity = _data[i]
		var id = entity.get("id") if entity.has_method("get") else entity.id
		_index_by_id[id] = i

## Save repository data
func save() -> bool:
	if _save_system:
		return _save_system.save_data(get_repository_name(), _data)
	return false

## Load repository data
func load() -> bool:
	if _save_system:
		var loaded_data = _save_system.load_data(get_repository_name())
		if loaded_data != null:
			_data = loaded_data
			_update_index()
			_on_repository_loaded()
			return true
	
	# If no saved data, initialize with default data
	_initialize_default_data()
	return true

## Initialize default data (override in subclasses)
func _initialize_default_data() -> void:
	# Default implementation does nothing
	# Subclasses should override this to provide default data
	pass

## Get repository name for save/load
func get_repository_name() -> String:
	push_error("get_repository_name() must be implemented by subclass")
	return ""

## Event handlers (override in subclasses)
func _on_entity_added(_entity: Variant) -> void:
	pass

func _on_entity_updated(_entity: Variant) -> void:
	pass

func _on_entity_removed(_entity: Variant) -> void:
	pass

func _on_repository_cleared() -> void:
	pass

func _on_repository_loaded() -> void:
	pass
