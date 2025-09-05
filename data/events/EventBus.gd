extends Node

## Centralized Event Bus for decoupled communication
## Handles event registration, emission, and subscription

signal event_emitted(event: BaseEvent)

# Event subscriptions: {event_type: [callable1, callable2, ...]}
var _subscriptions: Dictionary = {}
var _event_history: Array[BaseEvent] = []
var _max_history_size: int = 1000

# Performance tracking
var _events_emitted: int = 0
var _events_processed: int = 0
var _subscription_count: int = 0

func _ready():
	# Set as autoload singleton
	name = "EventBus"

## Subscribe to a specific event type
func subscribe(event_type: String, callable: Callable) -> void:
	if not _subscriptions.has(event_type):
		_subscriptions[event_type] = []
	
	_subscriptions[event_type].append(callable)
	_subscription_count += 1

## Unsubscribe from a specific event type
func unsubscribe(event_type: String, callable: Callable) -> void:
	if _subscriptions.has(event_type):
		_subscriptions[event_type].erase(callable)
		_subscription_count -= 1
		
		# Clean up empty event types
		if _subscriptions[event_type].is_empty():
			_subscriptions.erase(event_type)

## Unsubscribe all callables for a specific object
func unsubscribe_all_for_object(obj: Object) -> void:
	for event_type in _subscriptions.keys():
		var callables = _subscriptions[event_type]
		for i in range(callables.size() - 1, -1, -1):
			if callables[i].get_object() == obj:
				callables.remove_at(i)
				_subscription_count -= 1
		
		# Clean up empty event types
		if _subscriptions[event_type].is_empty():
			_subscriptions.erase(event_type)

## Emit an event to all subscribers
func emit_event(event: BaseEvent) -> void:
	_events_emitted += 1
	
	# Add to history
	_event_history.append(event)
	if _event_history.size() > _max_history_size:
		_event_history.pop_front()
	
	# Emit global signal
	event_emitted.emit(event)
	
	# Notify specific subscribers
	var event_type = event.event_type
	if _subscriptions.has(event_type):
		var callables = _subscriptions[event_type]
		for callable in callables:
			if callable.is_valid():
				callable.call(event)
				_events_processed += 1
			else:
				# Remove invalid callables
				callables.erase(callable)
				_subscription_count -= 1

## Emit a simple event with just type and data
func emit_simple_event(event_type: String, data: Dictionary = {}, source: String = "") -> void:
	var event = BaseEvent.new(event_type, source, data)
	emit_event(event)

## Get recent events of a specific type
func get_recent_events(event_type: String, count: int = 10) -> Array[BaseEvent]:
	var filtered_events: Array[BaseEvent] = []
	var start_index = max(0, _event_history.size() - count)
	
	for i in range(_event_history.size() - 1, start_index - 1, -1):
		if _event_history[i].event_type == event_type:
			filtered_events.append(_event_history[i])
			if filtered_events.size() >= count:
				break
	
	return filtered_events

## Get all events from the last N seconds
func get_events_from_last_seconds(seconds: float) -> Array[BaseEvent]:
	var cutoff_time = Time.get_unix_time_from_system() - seconds
	var recent_events: Array[BaseEvent] = []
	
	for event in _event_history:
		if event.timestamp >= cutoff_time:
			recent_events.append(event)
	
	return recent_events

## Get event statistics
func get_statistics() -> Dictionary:
	return {
		"events_emitted": _events_emitted,
		"events_processed": _events_processed,
		"subscription_count": _subscription_count,
		"event_types_subscribed": _subscriptions.size(),
		"history_size": _event_history.size(),
		"max_history_size": _max_history_size
	}

## Clear event history
func clear_history() -> void:
	_event_history.clear()

## Set maximum history size
func set_max_history_size(size: int) -> void:
	_max_history_size = max(1, size)
	
	# Trim history if needed
	while _event_history.size() > _max_history_size:
		_event_history.pop_front()

## Get all subscribed event types
func get_subscribed_event_types() -> Array[String]:
	return _subscriptions.keys()

## Check if there are subscribers for an event type
func has_subscribers(event_type: String) -> bool:
	return _subscriptions.has(event_type) and not _subscriptions[event_type].is_empty()

## Get subscriber count for an event type
func get_subscriber_count(event_type: String) -> int:
	if _subscriptions.has(event_type):
		return _subscriptions[event_type].size()
	return 0

## Debug: Print event statistics
func print_statistics() -> void:
	var stats = get_statistics()
	print("=== EventBus Statistics ===")
	print("Events Emitted: ", stats.events_emitted)
	print("Events Processed: ", stats.events_processed)
	print("Total Subscriptions: ", stats.subscription_count)
	print("Event Types: ", stats.event_types_subscribed)
	print("History Size: ", stats.history_size)
	print("Subscribed Types: ", get_subscribed_event_types())

## Debug: Print recent events
func print_recent_events(count: int = 10) -> void:
	print("=== Recent Events ===")
	var start_index = max(0, _event_history.size() - count)
	for i in range(start_index, _event_history.size()):
		var event = _event_history[i]
		print("[%s] %s from %s: %s" % [
			event.get_timestamp_string(),
			event.event_type,
			event.source,
			event.data
		])
