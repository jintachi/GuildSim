class_name BaseEvent
extends RefCounted

## Base class for all game events
## Provides common functionality and type safety for the event system

@export var event_type: String
@export var timestamp: float
@export var source: String
@export var data: Dictionary

func _init(p_event_type: String, p_source: String = "", p_data: Dictionary = {}):
	event_type = p_event_type
	source = p_source
	data = p_data
	timestamp = Time.get_unix_time_from_system()

## Get event age in seconds
func get_age() -> float:
	return Time.get_unix_time_from_system() - timestamp

## Check if event is older than specified seconds
func is_older_than(seconds: float) -> bool:
	return get_age() > seconds

## Get formatted timestamp string
func get_timestamp_string() -> String:
	var time_dict = Time.get_datetime_dict_from_unix_time(timestamp)
	var hour = int(round(time_dict.hour))
	var minute = int(round(time_dict.minute))
	var second = int(round(time_dict.second))
	return "%02d:%02d:%02d" % [hour, minute, second]

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
