class_name BaseService
extends RefCounted

## Base class for all business logic services
## Provides common functionality and dependency injection

var _event_bus: EventBus
var _save_system: SaveSystem
var _game_config: GameConfig
var _balance_config: BalanceConfig

# Service state
var _is_initialized: bool = false
var _service_name: String = ""

func _init(service_name: String):
	_service_name = service_name

## Initialize service with dependencies
func initialize(event_bus: EventBus, save_system: SaveSystem, game_config: GameConfig) -> void:
	_event_bus = event_bus
	_save_system = save_system
	_game_config = game_config
	_balance_config = game_config.get_balance_config()
	
	# Debug and fix balance config
	if not _balance_config:
		push_error("BalanceConfig is null in " + _service_name + ", attempting to reinitialize")
		_balance_config = BalanceConfig.new()
	elif not _balance_config is BalanceConfig:
		push_error("BalanceConfig is not a BalanceConfig object in " + _service_name + ", type: " + str(_balance_config.get_class()) + ", reinitializing")
		_balance_config = BalanceConfig.new()
	else:
		log_activity("BalanceConfig loaded successfully")
	
	_is_initialized = true
	_on_initialized()

## Check if service is properly initialized
func is_initialized() -> bool:
	return _is_initialized

## Get service name
func get_service_name() -> String:
	return _service_name

## Emit event through event bus
func emit_event(event: BaseEvent) -> void:
	if _event_bus:
		_event_bus.emit_event(event)
	else:
		push_error("EventBus not available in " + _service_name)

## Emit simple event
func emit_simple_event(event_type: String, data: Dictionary = {}) -> void:
	if _event_bus:
		_event_bus.emit_simple_event(event_type, data, _service_name)
	else:
		push_error("EventBus not available in " + _service_name)

## Log service activity
func log_activity(message: String) -> void:
	if _game_config and _game_config.debug_mode:
		print("[" + _service_name + "] " + message)

## Get game configuration
func get_game_config() -> GameConfig:
	return _game_config

## Get balance configuration
func get_balance_config() -> BalanceConfig:
	return _balance_config

## Validate service dependencies
func _validate_dependencies() -> bool:
	if not _event_bus:
		push_error(_service_name + ": EventBus not available")
		return false
	if not _save_system:
		push_error(_service_name + ": SaveSystem not available")
		return false
	if not _game_config:
		push_error(_service_name + ": GameConfig not available")
		return false
	return true

## Called after service initialization (override in subclasses)
func _on_initialized() -> void:
	pass

## Get service statistics (override in subclasses)
func get_statistics() -> Dictionary:
	return {
		"service_name": _service_name,
		"is_initialized": _is_initialized,
		"dependencies_valid": _validate_dependencies()
	}
