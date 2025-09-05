extends Node

## Centralized service manager for coordinating all business logic services
## Handles service initialization, dependency injection, and service coordination

signal services_initialized
signal service_error(service_name: String, error: String)

# Core services
var _character_service: CharacterService
var _quest_service: QuestService
var _guild_service: GuildService
var _equipment_service: EquipmentService
var _training_service: TrainingService

# Repositories
var _character_repository: CharacterRepository
var _quest_repository: QuestRepository
var _guild_repository: GuildRepository

# Service state
var _is_initialized: bool = false
var _initialization_errors: Array[String] = []

func _ready():
	# Set as autoload singleton
	name = "ServiceManager"

## Initialize all services
func initialize_services() -> bool:
	if _is_initialized:
		return true
	
	log_info("Initializing services...")
	
	# Ensure GameConfig is ready
	if not GameConfig:
		log_error("GameConfig not available, cannot initialize services")
		return false
	
	# Ensure BalanceConfig is properly initialized
	GameConfig.ensure_balance_config()
	
	if not GameConfig.is_ready():
		log_error("GameConfig not ready after ensuring BalanceConfig, cannot initialize services")
		return false
	
	# Initialize repositories first
	if not _initialize_repositories():
		return false
	
	# Initialize services
	if not _initialize_services():
		return false
	
	# Set up service dependencies
	if not _setup_service_dependencies():
		return false
	
	# Validate all services
	if not _validate_services():
		return false
	
	_is_initialized = true
	services_initialized.emit()
	log_info("All services initialized successfully")
	return true

## Initialize repositories
func _initialize_repositories() -> bool:
	log_info("Initializing repositories...")
	
	# Create repositories
	_character_repository = CharacterRepository.new(SaveSystem, EventBus)
	_quest_repository = QuestRepository.new(SaveSystem, EventBus)
	_guild_repository = GuildRepository.new(SaveSystem, EventBus)
	
	# Load repository data
	if not _character_repository.load():
		log_warning("Failed to load character repository data")
	
	if not _quest_repository.load():
		log_warning("Failed to load quest repository data")
	
	if not _guild_repository.load():
		log_warning("Failed to load guild repository data")
	
	log_info("Repositories initialized")
	return true

## Initialize services
func _initialize_services() -> bool:
	log_info("Initializing business logic services...")
	
	# Create services
	_character_service = CharacterService.new()
	_quest_service = QuestService.new()
	_guild_service = GuildService.new()
	_equipment_service = EquipmentService.new()
	_training_service = TrainingService.new()
	
	# Initialize services with core dependencies
	_character_service.initialize(EventBus, SaveSystem, GameConfig)
	_quest_service.initialize(EventBus, SaveSystem, GameConfig)
	_guild_service.initialize(EventBus, SaveSystem, GameConfig)
	_equipment_service.initialize(EventBus, SaveSystem, GameConfig)
	_training_service.initialize(EventBus, SaveSystem, GameConfig)
	
	log_info("Services created and initialized")
	return true

## Set up service dependencies
func _setup_service_dependencies() -> bool:
	log_info("Setting up service dependencies...")
	
	# Set up repository dependencies
	_character_service.initialize_with_repository(_character_repository, _guild_service)
	_quest_service.initialize_with_repository(_quest_repository, _character_service, _guild_service)
	_guild_service.initialize_with_repository(_guild_repository)
	_equipment_service.initialize_with_dependencies(_character_service, _guild_service)
	_training_service.initialize_with_dependencies(_character_service, _guild_service)
	
	log_info("Service dependencies configured")
	return true

## Validate all services
func _validate_services() -> bool:
	log_info("Validating services...")
	
	var all_valid = true
	
	# Validate each service
	if not _character_service.is_initialized():
		log_error("CharacterService failed validation")
		all_valid = false
	
	if not _quest_service.is_initialized():
		log_error("QuestService failed validation")
		all_valid = false
	
	if not _guild_service.is_initialized():
		log_error("GuildService failed validation")
		all_valid = false
	
	if not _equipment_service.is_initialized():
		log_error("EquipmentService failed validation")
		all_valid = false
	
	if not _training_service.is_initialized():
		log_error("TrainingService failed validation")
		all_valid = false
	
	if all_valid:
		log_info("All services validated successfully")
	else:
		log_error("Some services failed validation")
	
	return all_valid

## Get character service
func get_character_service() -> CharacterService:
	return _character_service

## Get quest service
func get_quest_service() -> QuestService:
	return _quest_service

## Get guild service
func get_guild_service() -> GuildService:
	return _guild_service

## Get equipment service
func get_equipment_service() -> EquipmentService:
	return _equipment_service

## Get training service
func get_training_service() -> TrainingService:
	return _training_service

## Get character repository
func get_character_repository() -> CharacterRepository:
	return _character_repository

## Get quest repository
func get_quest_repository() -> QuestRepository:
	return _quest_repository

## Get guild repository
func get_guild_repository() -> BaseRepository:
	return _guild_repository

## Check if services are initialized
func is_initialized() -> bool:
	return _is_initialized

## Get service manager statistics
func get_service_statistics() -> Dictionary:
	var stats = {
		"is_initialized": _is_initialized,
		"initialization_errors": _initialization_errors,
		"services": {}
	}
	
	if _character_service:
		stats.services["character_service"] = _character_service.get_statistics()
	
	if _quest_service:
		stats.services["quest_service"] = _quest_service.get_statistics()
	
	if _guild_service:
		stats.services["guild_service"] = _guild_service.get_statistics()
	
	if _equipment_service:
		stats.services["equipment_service"] = _equipment_service.get_statistics()
	
	if _training_service:
		stats.services["training_service"] = _training_service.get_statistics()
	
	return stats

## Save all service data
func save_all_data() -> bool:
	if not _is_initialized:
		return false
	
	var success = true
	
	# Save repository data
	if _character_repository:
		success = success and _character_repository.save()
	
	if _quest_repository:
		success = success and _quest_repository.save()
	
	if _guild_repository:
		success = success and _guild_repository.save()
	
	if success:
		log_info("All service data saved successfully")
	else:
		log_error("Failed to save some service data")
	
	return success

## Load all service data
func load_all_data() -> bool:
	if not _is_initialized:
		return false
	
	var success = true
	
	# Load repository data
	if _character_repository:
		success = success and _character_repository.load()
	
	if _quest_repository:
		success = success and _quest_repository.load()
	
	if _guild_repository:
		success = success and _guild_repository.load()
	
	if success:
		log_info("All service data loaded successfully")
	else:
		log_error("Failed to load some service data")
	
	return success

## Reset all services (for testing)
func reset_all_services() -> void:
	log_info("Resetting all services...")
	
	# Clear repositories
	if _character_repository:
		_character_repository.clear()
	
	if _quest_repository:
		_quest_repository.clear()
	
	if _guild_repository:
		_guild_repository.clear()
	
	# Reset service statistics
	_initialization_errors.clear()
	_is_initialized = false
	
	log_info("All services reset")

## Logging functions
func log_info(message: String) -> void:
	print("[ServiceManager] " + message)

func log_warning(message: String) -> void:
	push_warning("[ServiceManager] " + message)

func log_error(message: String) -> void:
	push_error("[ServiceManager] " + message)
	_initialization_errors.append(message)
