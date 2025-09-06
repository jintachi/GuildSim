extends RefCounted
class_name BaseViewModel

## Base ViewModel class for MVVM pattern implementation
## Handles data binding, state management, and event integration

signal property_changed(property_name: String, old_value: Variant, new_value: Variant)
signal error_occurred(error_message: String)

# ViewModel state
var _is_initialized: bool = false
var _is_loading: bool = false
var _error_message: String = ""
var _last_updated: float = 0.0

# Event integration
var _event_bus: EventBus
var _subscribed_events: Array[String] = []

# Data binding
var _bound_properties: Dictionary = {}
var _property_watchers: Dictionary = {}

func _init():
	_last_updated = Time.get_unix_time_from_system()

## Initialize the ViewModel
func initialize(event_bus: EventBus) -> void:
	if _is_initialized:
		return
	
	_event_bus = event_bus
	_setup_event_subscriptions()
	_on_initialized()
	_is_initialized = true
	_last_updated = Time.get_unix_time_from_system()

## Check if ViewModel is initialized
func is_initialized() -> bool:
	return _is_initialized

## Check if ViewModel is currently loading data
func is_loading() -> bool:
	return _is_loading

## Get the last update timestamp
func get_last_updated() -> float:
	return _last_updated

## Get current error message
func get_error_message() -> String:
	return _error_message

## Clear error message
func clear_error() -> void:
	_error_message = ""
	error_occurred.emit("")

## Set loading state
func set_loading(loading: bool) -> void:
	_is_loading = loading
	property_changed.emit("is_loading", not loading, loading)

## Set error message
func set_error(error: String) -> void:
	_error_message = error
	error_occurred.emit(error)

## Bind a property to a UI element
func bind_property(property_name: String, ui_element: Control, ui_property: String = "text") -> void:
	if not _bound_properties.has(property_name):
		_bound_properties[property_name] = []
	
	_bound_properties[property_name].append({
		"ui_element": ui_element,
		"ui_property": ui_property
	})
	
	# Set initial value
	_update_ui_element(property_name, get_data(property_name))

## Unbind a property from UI elements
func unbind_property(property_name: String) -> void:
	_bound_properties.erase(property_name)

## Watch a property for changes
func watch_property(property_name: String, callback: Callable) -> void:
	if not _property_watchers.has(property_name):
		_property_watchers[property_name] = []
	
	_property_watchers[property_name].append(callback)

## Unwatch a property
func unwatch_property(property_name: String, callback: Callable) -> void:
	if _property_watchers.has(property_name):
		_property_watchers[property_name].erase(callback)

## Get data for a property
func get_data(_property_name: String) -> Variant:
	# Override in derived classes
	return null

## Set data for a property
func set_data(property_name: String, value: Variant) -> void:
	var old_value = get_data(property_name)
	
	# Update the property (override in derived classes)
	_update_property(property_name, value)
	
	# Notify watchers
	_notify_property_changed(property_name, old_value, value)
	
	# Update bound UI elements
	_update_bound_ui_elements(property_name, value)
	
	_last_updated = Time.get_unix_time_from_system()

## Update a property (override in derived classes)
func _update_property(_property_name: String, _value: Variant) -> void:
	# Override in derived classes
	pass

## Notify property watchers
func _notify_property_changed(property_name: String, old_value: Variant, new_value: Variant) -> void:
	property_changed.emit(property_name, old_value, new_value)
	
	if _property_watchers.has(property_name):
		for callback in _property_watchers[property_name]:
			if callback.is_valid():
				callback.call(property_name, old_value, new_value)

## Update bound UI elements
func _update_bound_ui_elements(property_name: String, value: Variant) -> void:
	if _bound_properties.has(property_name):
		for binding in _bound_properties[property_name]:
			_update_ui_element(property_name, value, binding)

## Update a specific UI element
func _update_ui_element(_property_name: String, value: Variant, binding: Dictionary = {}) -> void:
	var ui_element = binding.get("ui_element")
	var ui_property = binding.get("ui_property", "text")
	
	if ui_element and ui_element.is_inside_tree():
		# Convert value to appropriate type for UI
		var ui_value = _convert_value_for_ui(value, ui_property)
		
		# Set the UI property
		if ui_element.has_method("set_" + ui_property):
			ui_element.call("set_" + ui_property, ui_value)
		elif ui_element.has_method(ui_property):
			ui_element.call(ui_property, ui_value)
		else:
			ui_element.set(ui_property, ui_value)

## Convert value for UI display
func _convert_value_for_ui(value: Variant, ui_property: String) -> Variant:
	match ui_property:
		"text", "placeholder_text":
			return str(value) if value != null else ""
		"value", "min_value", "max_value":
			return float(value) if value != null else 0.0
		"pressed", "disabled", "visible":
			return bool(value) if value != null else false
		_:
			return value

## Setup event subscriptions (override in derived classes)
func _setup_event_subscriptions() -> void:
	# Override in derived classes
	pass

## Handle initialization (override in derived classes)
func _on_initialized() -> void:
	# Override in derived classes
	pass

## Subscribe to an event
func _subscribe_to_event(event_type: String, callback: Callable) -> void:
	if _event_bus:
		_event_bus.subscribe(event_type, callback)
		_subscribed_events.append(event_type)

## Unsubscribe from an event
func _unsubscribe_from_event(event_type: String, callback: Callable) -> void:
	if _event_bus:
		_event_bus.unsubscribe(event_type, callback)
		_subscribed_events.erase(event_type)

## Clean up ViewModel
func cleanup() -> void:
	# Unsubscribe from all events
	if _event_bus:
		_event_bus.unsubscribe_all_for_object(self)
	
	_subscribed_events.clear()
	_bound_properties.clear()
	_property_watchers.clear()
	_is_initialized = false

## Get ViewModel statistics
func get_statistics() -> Dictionary:
	return {
		"is_initialized": _is_initialized,
		"is_loading": _is_loading,
		"error_message": _error_message,
		"last_updated": _last_updated,
		"bound_properties": _bound_properties.size(),
		"watched_properties": _property_watchers.size(),
		"subscribed_events": _subscribed_events.size()
	}

## Refresh all data
func refresh() -> void:
	# Override in derived classes
	pass

## Validate ViewModel state
func validate() -> bool:
	# Override in derived classes
	return _is_initialized and _error_message.is_empty()
