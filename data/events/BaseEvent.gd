class_name BaseEvent
extends RefCounted

## Base class for all game events
## Provides common functionality and type safety for the event system

@export var event_type: String
@export var timestamp: float
@export var source: String
@export var data: Dictionary

func _init(event_type: String, source: String = "", data: Dictionary = {}):
	self.event_type = event_type
	self.source = source
	self.data = data
	self.timestamp = Time.get_unix_time_from_system()

## Get event age in seconds
func get_age() -> float:
	return Time.get_unix_time_from_system() - timestamp

## Check if event is older than specified seconds
func is_older_than(seconds: float) -> bool:
	return get_age() > seconds

## Get formatted timestamp string
func get_timestamp_string() -> String:
	var time_dict = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]

## Convert event to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"event_type": event_type,
		"timestamp": timestamp,
		"source": source,
		"data": data
	}

## Create event from dictionary (for deserialization)
static func from_dict(dict: Dictionary) -> BaseEvent:
	var event = BaseEvent.new(
		dict.get("event_type", ""),
		dict.get("source", ""),
		dict.get("data", {})
	)
	event.timestamp = dict.get("timestamp", Time.get_unix_time_from_system())
	return event
