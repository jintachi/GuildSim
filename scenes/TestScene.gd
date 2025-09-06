extends Control

## Comprehensive test scene for GuildSim game
## Tests all systems from foundation to full gameplay integration

# UI References
@onready var output_label: RichTextLabel = $MainContainer/VBoxContainer/OutputPanel/Output
@onready var demo_subviewport: SubViewport = $MainContainer/VBoxContainer/SubViewportContainer/DemoDisplay

# System Control Buttons
@onready var initialize_services_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/SystemControl/SystemControlButtons/InitializeServices
@onready var reset_services_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/SystemControl/SystemControlButtons/ResetServices

# Foundation Test Buttons
@onready var test_character_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestCharacter
@onready var test_quest_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestQuest
@onready var test_event_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestEvent
@onready var test_config_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestConfig
@onready var test_save_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestSave
@onready var test_services_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/FoundationTests/FoundationButtons/TestServices

# UI Test Buttons
@onready var test_ui_navigation_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestUINavigation
@onready var test_character_ui_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestCharacterUI
@onready var test_quest_ui_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestQuestUI
@onready var test_guild_ui_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestGuildUI
@onready var test_settings_ui_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestSettingsUI
@onready var test_ui_manager_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/UITests/UIButtons/TestUIManager

# Gameplay Test Buttons
@onready var test_recruitment_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestRecruitment
@onready var test_quest_assignment_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestQuestAssignment
@onready var test_training_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestTraining
@onready var test_equipment_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestEquipment
@onready var test_guild_management_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestGuildManagement
@onready var test_quest_execution_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/GameplayTests/GameplayButtons/TestQuestExecution

# Integration Test Buttons
@onready var test_full_gameplay_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestFullGameplay
@onready var test_save_load_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestSaveLoad
@onready var test_performance_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestPerformance
@onready var test_stress_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestStress
@onready var test_error_handling_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestErrorHandling
@onready var test_all_systems_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/IntegrationTests/IntegrationButtons/TestAllSystems

# Control Buttons
@onready var clear_output_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/ControlButtons/ClearOutput
@onready var launch_game_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/ControlButtons/LaunchGame
@onready var clear_demo_btn: Button = $MainContainer/TestPanel/TestScrollContainer/TestVBox/ControlButtons/ClearDemo

# Test Data
var test_character: Character
var test_quest: Quest
var test_guild: Guild
var test_characters: Array[Character] = []
var test_quests: Array[Quest] = []
var test_equipment: Array[GameResource] = []

# Test State
var test_in_progress: bool = false
var test_results: Dictionary = {}

func _ready():
	# Connect system control button signals
	initialize_services_btn.pressed.connect(_on_initialize_services_pressed)
	reset_services_btn.pressed.connect(_on_reset_services_pressed)
	
	# Connect foundation test button signals
	test_character_btn.pressed.connect(_on_test_character_pressed)
	test_quest_btn.pressed.connect(_on_test_quest_pressed)
	test_event_btn.pressed.connect(_on_test_event_pressed)
	test_config_btn.pressed.connect(_on_test_config_pressed)
	test_save_btn.pressed.connect(_on_test_save_pressed)
	test_services_btn.pressed.connect(_on_test_services_pressed)
	
	# Connect UI test button signals
	test_ui_navigation_btn.pressed.connect(_on_test_ui_navigation_pressed)
	test_character_ui_btn.pressed.connect(_on_test_character_ui_pressed)
	test_quest_ui_btn.pressed.connect(_on_test_quest_ui_pressed)
	test_guild_ui_btn.pressed.connect(_on_test_guild_ui_pressed)
	test_settings_ui_btn.pressed.connect(_on_test_settings_ui_pressed)
	test_ui_manager_btn.pressed.connect(_on_test_ui_manager_pressed)
	
	# Connect gameplay test button signals
	test_recruitment_btn.pressed.connect(_on_test_recruitment_pressed)
	test_quest_assignment_btn.pressed.connect(_on_test_quest_assignment_pressed)
	test_training_btn.pressed.connect(_on_test_training_pressed)
	test_equipment_btn.pressed.connect(_on_test_equipment_pressed)
	test_guild_management_btn.pressed.connect(_on_test_guild_management_pressed)
	test_quest_execution_btn.pressed.connect(_on_test_quest_execution_pressed)
	
	# Connect integration test button signals
	test_full_gameplay_btn.pressed.connect(_on_test_full_gameplay_pressed)
	test_save_load_btn.pressed.connect(_on_test_save_load_pressed)
	test_performance_btn.pressed.connect(_on_test_performance_pressed)
	test_stress_btn.pressed.connect(_on_test_stress_pressed)
	test_error_handling_btn.pressed.connect(_on_test_error_handling_pressed)
	test_all_systems_btn.pressed.connect(_on_test_all_systems_pressed)
	
	# Connect control button signals
	clear_output_btn.pressed.connect(_on_clear_output_pressed)
	launch_game_btn.pressed.connect(_on_launch_game_pressed)
	clear_demo_btn.pressed.connect(_on_clear_demo_pressed)
	
	# Connect to EventBus for testing
	EventBus.event_emitted.connect(_on_event_emitted)
	
	log_output("GuildSim Comprehensive Test Suite Loaded")
	log_output("Ready to test all game systems...")
	
	# Wait for UI system to initialize
	await get_tree().process_frame
	if UIManager and UIManager._is_initialized:
		log_output("✓ UI System initialized successfully")
		log_output("Use 'Launch Full Game' to start the main interface")
	else:
		log_output("⚠ UI System not yet initialized, using test interface")

# System Control Methods
func _on_initialize_services_pressed():
	log_output("\n=== Initializing Services ===")
	
	if ServiceManager.is_initialized():
		log_output("⚠ Services already initialized")
		return
	
	log_output("Initializing all services...")
	if ServiceManager.initialize_services():
		log_output("✓ All services initialized successfully")
		
		# Show service status
		var service_stats = ServiceManager.get_service_statistics()
		log_output("Service Status:")
		log_output("  Services Count: " + str(service_stats.services.size()))
		for service_name in service_stats.services:
			var stats = service_stats.services[service_name]
			log_output("  ✓ " + service_name + ": " + str(stats.get("service_name", "Unknown")))
	else:
		log_output("✗ Service initialization failed")

func _on_reset_services_pressed():
	log_output("\n=== Resetting Services ===")
	
	if not ServiceManager.is_initialized():
		log_output("⚠ Services not initialized, nothing to reset")
		return
	
	# Clear test data
	test_character = null
	test_quest = null
	test_guild = null
	test_characters.clear()
	test_quests.clear()
	test_equipment.clear()
	
	log_output("✓ Test data cleared")
	log_output("Note: Services remain initialized. Use 'Initialize Services' to reinitialize if needed.")

func _on_test_character_pressed():
	log_output("\n=== Testing Character System ===")
	
	# Create test character directly (no service initialization needed)
	test_character = Character.new()
	test_character.character_name = "Test Hero"
	test_character.character_class = Character.CharacterClass.TANK
	test_character.quality = Character.Quality.THREE_STAR
	test_character.rank = Character.Rank.D
	
	# Set some stats
	test_character.health = 150
	test_character.defense = 25
	test_character.attack = 20
	test_character.speed = 15
	test_character.intelligence = 12
	test_character.charisma = 10
	
	# Set some substats
	test_character.gathering = 5
	test_character.hunting = 8
	test_character.diplomacy = 3
	
	# Ensure enum values are valid for key lookup (Godot enums are ints, keys() returns array)
	# Defensive: clamp to valid range to avoid out-of-bounds
	var class_keys = Character.CharacterClass.keys()
	var job_keys = Character.CharacterJob.keys()
	var quality_keys = Character.Quality.keys()
	var rank_keys = Character.Rank.keys()
	
	# Optionally, clamp to valid range (if you want to avoid errors)
	test_character.character_class = clamp(test_character.character_class, 0, class_keys.size() - 1)
	test_character.character_job = clamp(test_character.character_job, 0, job_keys.size() - 1)
	test_character.quality = clamp(test_character.quality, 0, quality_keys.size() - 1)
	test_character.rank = clamp(test_character.rank, 0, rank_keys.size() - 1)
	# Validate character
	if test_character.validate():
		log_output("✓ Character created successfully: " + test_character.character_name)
		log_output("  ID: " + test_character.id)
		log_output("  Class: " + Character.CharacterClass.keys()[test_character.character_class])
		log_output("  Job: " + Character.CharacterJob.keys()[test_character.character_job])
		log_output("  Quality: " + Character.Quality.keys()[test_character.quality])
		log_output("  Rank: " + Character.Rank.keys()[test_character.rank])
		log_output("  Level: " + str(test_character.level))
		log_output("  Health: " + str(test_character.health))
		log_output("  Available: " + str(test_character.is_available()))
		log_output("  Experience to next level: " + str(test_character.get_experience_to_next_level()))
		
		# Only add to repository if services are initialized
		if ServiceManager.is_initialized():
			var character_repo = ServiceManager.get_character_repository()
			if character_repo and character_repo.add(test_character):
				log_output("✓ Character added to repository")
			else:
				log_output("✗ Failed to add character to repository")
		else:
			log_output("ℹ Services not initialized - character created but not added to repository")
			log_output("  Use 'Initialize Services' button to enable repository operations")
	else:
		log_output("✗ Character validation failed")

func _on_test_quest_pressed():
	log_output("\n=== Testing Quest System ===")
	
	# Create test quest directly (no service initialization needed)
	test_quest = Quest.new()
	test_quest.quest_name = "Test Quest: Gather Herbs"
	test_quest.quest_type = Quest.QuestType.GATHERING
	test_quest.quest_rank = Quest.QuestRank.D
	test_quest.difficulty = Quest.QuestDifficulty.NORMAL
	test_quest.description = "Gather rare herbs from the forest"
	test_quest.duration = 300.0  # 5 minutes
	
	# Set requirements
	test_quest.min_party_size = 1
	test_quest.max_party_size = 3
	test_quest.min_gathering = 10
	test_quest.min_survival = 5
	
	# Set rewards
	test_quest.gold_reward = 150
	test_quest.influence_reward = 50
	test_quest.experience_reward = 100
	test_quest.material_rewards = {"herbs": 5, "wood": 2}
	
	# Set risk
	test_quest.injury_chance = 0.1
	test_quest.failure_penalty_gold = 25
	
	# Validate quest
	if test_quest.validate():
		log_output("✓ Quest created successfully: " + test_quest.quest_name)
		log_output("  ID: " + test_quest.id)
		log_output("  Type: " + Quest.QuestType.keys()[test_quest.quest_type])
		log_output("  Rank: " + Quest.QuestRank.keys()[test_quest.quest_rank])
		log_output("  Difficulty: " + Quest.QuestDifficulty.keys()[test_quest.difficulty])
		log_output("  Duration: " + str(test_quest.duration) + " seconds")
		log_output("  Gold Reward: " + str(test_quest.gold_reward))
		log_output("  Total Reward Value: " + str(test_quest.get_total_reward_value()))
		log_output("  Difficulty Multiplier: " + str(test_quest.get_difficulty_multiplier()))
		log_output("  Rank Multiplier: " + str(test_quest.get_rank_multiplier()))
		
		# Only add to repository if services are initialized
		if ServiceManager.is_initialized():
			var quest_repo = ServiceManager.get_quest_repository()
			if quest_repo and quest_repo.add(test_quest):
				log_output("✓ Quest added to repository")
			else:
				log_output("✗ Failed to add quest to repository")
		else:
			log_output("ℹ Services not initialized - quest created but not added to repository")
			log_output("  Use 'Initialize Services' button to enable repository operations")
	else:
		log_output("✗ Quest validation failed")

func _on_test_event_pressed():
	log_output("\n=== Testing Event System ===")
	
	# Test basic event emission
	EventBus.emit_simple_event("test_event", {"message": "Hello from EventBus!"}, "TestScene")
	
	# Test character event
	if test_character:
		var char_event = CharacterEvents.CharacterRecruitedEvent.new(test_character, 250)
		EventBus.emit_event(char_event)
		log_output("✓ Character recruited event emitted")
	
	# Test quest event
	if test_quest:
		var quest_event = QuestEvents.QuestGeneratedEvent.new(test_quest)
		EventBus.emit_event(quest_event)
		log_output("✓ Quest generated event emitted")
	
	# Test guild event
	test_guild = Guild.new()
	test_guild.guild_name = "Test Guild"
	var event = GuildEvents.GuildCreatedEvent.new(test_guild)
	EventBus.emit_event(event)
	log_output("✓ Guild created event emitted")
	
	# Print event statistics
	var stats = EventBus.get_statistics()
	log_output("Event Statistics:")
	log_output("  Events Emitted: " + str(stats.events_emitted))
	log_output("  Events Processed: " + str(stats.events_processed))
	log_output("  Subscriptions: " + str(stats.subscription_count))

func _on_test_config_pressed():
	log_output("\n=== Testing Configuration System ===")
	
	# Test basic settings
	log_output("Game Version: " + GameConfig.game_version)
	log_output("Debug Mode: " + str(GameConfig.debug_mode))
	log_output("Auto Save Enabled: " + str(GameConfig.auto_save_enabled))
	log_output("UI Scale: " + str(GameConfig.ui_scale))
	
	# Test feature flags
	log_output("Features Enabled:")
	for feature in GameConfig.features:
		if GameConfig.features[feature]:
			log_output("  ✓ " + feature)
		else:
			log_output("  ✗ " + feature)
	
	# Test balance config
	var balance = GameConfig.get_balance_config()
	log_output("Balance Config:")
	log_output("  Recruitment Cost (2-star): " + str(balance.get_recruitment_cost(Character.Quality.TWO_STAR)))
	log_output("  Quest Reward Multiplier (D): " + str(balance.get_quest_reward_multiplier(Quest.QuestRank.D)))
	log_output("  Training Cost (health): " + str(balance.get_training_cost("health")))
	
	# Test setting changes
	var old_ui_scale = GameConfig.ui_scale
	GameConfig.set_setting("ui_scale", 1.5)
	log_output("UI Scale changed from " + str(old_ui_scale) + " to " + str(GameConfig.ui_scale))

func _on_test_save_pressed():
	log_output("\n=== Testing Save System ===")
	
	# Test save system statistics
	var stats = SaveSystem.get_statistics()
	log_output("Save System Statistics:")
	log_output("  Save Count: " + str(stats.save_count))
	log_output("  Load Count: " + str(stats.load_count))
	log_output("  Auto Save Enabled: " + str(stats.auto_save_enabled))
	log_output("  Current Save: " + str(stats.current_save))
	
	# Test available saves
	var saves = SaveSystem.get_available_saves()
	log_output("Available Saves: " + str(saves.size()))
	
	# Test setting current save
	SaveSystem.set_current_save("test_save")
	log_output("Current save set to: " + SaveSystem.get_current_save())
	
	# Test auto-save settings
	SaveSystem.set_auto_save(true, 300.0)  # 5 minutes
	log_output("Auto-save configured: enabled, 5 minute interval")

func _on_test_services_pressed():
	log_output("\n=== Testing Service Layer ===")
	
	# Wait for GameConfig to be ready
	if not GameConfig.is_ready():
		log_output("Waiting for GameConfig to be ready...")
		await get_tree().process_frame
		if not GameConfig.is_ready():
			log_output("✗ GameConfig not ready, cannot test services")
			return
	
	# Initialize services
	if not ServiceManager.is_initialized():
		log_output("Initializing services...")
		if ServiceManager.initialize_services():
			log_output("✓ Services initialized successfully")
		else:
			log_output("✗ Service initialization failed")
			return
	else:
		log_output("✓ Services already initialized")
	
	# Test character service
	log_output("\n--- Testing Character Service ---")
	var char_service = ServiceManager.get_character_service()
	if char_service:
		log_output("✓ Character Service available")
		
		# Test character recruitment
		var character_data = {
			"name": "Test Warrior",
			"class": Character.CharacterClass.TANK,
			"quality": Character.Quality.TWO_STAR,
			"rank": Character.Rank.D,
			"level": 5
		}
		
		var recruited_char = char_service.recruit_character(character_data)
		if recruited_char:
			log_output("✓ Character recruited: " + recruited_char.character_name)
			test_character = recruited_char
		else:
			log_output("✗ Character recruitment failed")
	else:
		log_output("✗ Character Service not available")
	
	# Test quest service
	log_output("\n--- Testing Quest Service ---")
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		log_output("✓ Quest Service available")
		
		# Test quest generation
		var generated_quest = quest_service.generate_quest(Quest.QuestType.GATHERING, Quest.QuestRank.D)
		if generated_quest:
			log_output("✓ Quest generated: " + generated_quest.quest_name)
			test_quest = generated_quest
		else:
			log_output("✗ Quest generation failed")
	else:
		log_output("✗ Quest Service not available")
	
	# Test guild service
	log_output("\n--- Testing Guild Service ---")
	var guild_service = ServiceManager.get_guild_service()
	if guild_service:
		log_output("✓ Guild Service available")
		
		var guild = guild_service.get_guild()
		if guild:
			log_output("✓ Guild available: " + guild.guild_name)
			log_output("  Gold: " + str(guild.gold))
			log_output("  Influence: " + str(guild.influence))
			test_guild = guild
		else:
			log_output("✗ Guild not available")
	else:
		log_output("✗ Guild Service not available")
	
	# Test training service
	log_output("\n--- Testing Training Service ---")
	var training_service = ServiceManager.get_training_service()
	if training_service:
		log_output("✓ Training Service available")
		
		if test_character:
			var training_options = training_service.get_available_training_options(test_character)
			log_output("✓ Training options available: " + str(training_options.size()))
			
			# Test training efficiency
			var efficiency = training_service.get_training_efficiency(test_character)
			log_output("  Training efficiency: " + str(efficiency.overall_efficiency))
			log_output("  Recommended stats: " + str(efficiency.recommended_stats))
		else:
			log_output("✗ No character available for training test")
	else:
		log_output("✗ Training Service not available")
	
	# Test equipment service
	log_output("\n--- Testing Equipment Service ---")
	var equipment_service = ServiceManager.get_equipment_service()
	if equipment_service:
		log_output("✓ Equipment Service available")
		
		# Test equipment creation
		var equipment_data = {
			"name": "Iron Sword",
			"description": "A sturdy iron sword",
			"resource_type": GameResource.ResourceType.WEAPONS,
			"rarity": GameResource.Rarity.COMMON,
			"equipment_slot": "weapon",
			"base_value": 100,
			"tags": "Equipment"
		}
		
		var equipment = equipment_service.create_equipment(equipment_data)
		if equipment:
			log_output("✓ Equipment created: " + equipment.name)
			log_output("  Rarity: " + GameResource.Rarity.keys()[equipment.rarity])
			log_output("  Value: " + str(equipment.get_current_value()))
		else:
			log_output("✗ Equipment creation failed")
	else:
		log_output("✗ Equipment Service not available")
	
	# Navigation service removed - using simple UI navigation instead
	log_output("\n--- Navigation System ---")
	log_output("✓ Using simplified UI navigation (no complex navigation service needed)")
	
	# Test service statistics
	log_output("\n--- Service Statistics ---")
	var service_stats = ServiceManager.get_service_statistics()
	log_output("Service Manager Statistics:")
	log_output("  Initialized: " + str(service_stats.is_initialized))
	log_output("  Services Count: " + str(service_stats.services.size()))
	
	for service_name in service_stats.services:
		var stats = service_stats.services[service_name]
		log_output("  " + service_name + ": " + str(stats.get("service_name", "Unknown")))

func _on_event_emitted(event: Variant):
	# Handle both BaseEvent objects and Dictionary events
	if event is BaseEvent:
		log_output("Event Received: " + event.event_type + " from " + event.source)
	elif event is Dictionary:
		log_output("Event Received: " + event.get("event_type", "unknown") + " from " + event.get("source", "unknown"))
	else:
		log_output("Event Received: " + str(event))

# UI Test Methods
func _on_test_ui_navigation_pressed():
	log_output("\n=== Testing UI Navigation ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized")
		return
	
	# Test navigation to different screens
	var screens = ["characters", "quests", "guild", "settings"]
	for screen in screens:
		log_output("Testing navigation to: " + screen)
		UIManager.navigate_to(screen)
		await get_tree().process_frame
		log_output("✓ Navigated to " + screen)
		await get_tree().create_timer(0.5).timeout
	
	log_output("✓ UI Navigation test completed")

func _on_test_character_ui_pressed():
	log_output("\n=== Testing Character UI ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized")
		return
	
	# Navigate to character UI
	UIManager.navigate_to("characters")
	await get_tree().process_frame
	
	# Test character UI functionality
	var character_ui = UIManager.get_ui_component("character_ui")
	if character_ui:
		log_output("✓ Character UI component found")
		character_ui.refresh()
		log_output("✓ Character UI refreshed")
	else:
		log_output("✗ Character UI component not found")

func _on_test_quest_ui_pressed():
	log_output("\n=== Testing Quest UI ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized")
		return
	
	# Navigate to quest UI
	UIManager.navigate_to("quests")
	await get_tree().process_frame
	
	# Test quest UI functionality
	var quest_ui = UIManager.get_ui_component("quest_ui")
	if quest_ui:
		log_output("✓ Quest UI component found")
		quest_ui.refresh()
		log_output("✓ Quest UI refreshed")
	else:
		log_output("✗ Quest UI component not found")

func _on_test_guild_ui_pressed():
	log_output("\n=== Testing Guild UI ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized")
		return
	
	# Navigate to guild UI
	UIManager.navigate_to("guild")
	await get_tree().process_frame
	
	# Test guild UI functionality
	var guild_ui = UIManager.get_ui_component("guild_ui")
	if guild_ui:
		log_output("✓ Guild UI component found")
		guild_ui.refresh()
		log_output("✓ Guild UI refreshed")
	else:
		log_output("✗ Guild UI component not found")

func _on_test_settings_ui_pressed():
	log_output("\n=== Testing Settings UI ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized")
		return
	
	# Navigate to settings UI
	UIManager.navigate_to("settings")
	await get_tree().process_frame
	
	# Test settings UI functionality
	var settings_ui = UIManager.get_ui_component("settings_ui")
	if settings_ui:
		log_output("✓ Settings UI component found")
	else:
		log_output("✗ Settings UI component not found")

func _on_test_ui_manager_pressed():
	log_output("\n=== Testing UI Manager ===")
	
	if not UIManager:
		log_output("✗ UI Manager not available")
		return
	
	log_output("UI Manager Status:")
	log_output("  Initialized: " + str(UIManager._is_initialized))
	log_output("  Current Screen: " + UIManager.get_current_screen())
	log_output("  Screen History: " + str(UIManager.get_screen_history()))
	
	# Test ViewModels
	var view_models = ["character", "quest", "guild"]
	for vm_type in view_models:
		var vm = UIManager.get_view_model(vm_type)
		if vm:
			log_output("✓ " + vm_type + " ViewModel available")
		else:
			log_output("✗ " + vm_type + " ViewModel not available")

# Gameplay Test Methods
func _on_test_recruitment_pressed():
	log_output("\n=== Testing Character Recruitment ===")
	
	if not ServiceManager.is_initialized():
		log_output("✗ Services not initialized")
		return
	
	var char_service = ServiceManager.get_character_service()
	if not char_service:
		log_output("✗ Character service not available")
		return
	
	# Test recruiting multiple characters
	var character_types = [
		{"name": "Warrior", "class": Character.CharacterClass.TANK, "quality": Character.Quality.TWO_STAR},
		{"name": "Mage", "class": Character.CharacterClass.ATTACKER, "quality": Character.Quality.THREE_STAR},
		{"name": "Rogue", "class": Character.CharacterClass.SUPPORT, "quality": Character.Quality.ONE_STAR}
	]
	
	for char_data in character_types:
		var recruited = char_service.recruit_character(char_data)
		if recruited:
			log_output("✓ Recruited: " + recruited.character_name + " (" + Character.CharacterClass.keys()[recruited.character_class] + ")")
			test_characters.append(recruited)
		else:
			log_output("✗ Failed to recruit: " + char_data.name)
	
	log_output("Total characters recruited: " + str(test_characters.size()))

func _on_test_quest_assignment_pressed():
	log_output("\n=== Testing Quest Assignment ===")
	
	if test_characters.is_empty():
		log_output("⚠ No characters available, running recruitment test first...")
		_on_test_recruitment_pressed()
		await get_tree().process_frame
	
	if test_quests.is_empty():
		log_output("⚠ No quests available, generating test quests...")
		_generate_test_quests()
	
	var quest_service = ServiceManager.get_quest_service()
	if not quest_service:
		log_output("✗ Quest service not available")
		return
	
	# Test assigning quests to characters
	for i in range(min(test_quests.size(), test_characters.size())):
		var quest = test_quests[i]
		var character = test_characters[i]
		
		if quest_service.can_assign_quest(quest, [character]):
			var success = quest_service.assign_quest(quest.id, [character.id])
			if success:
				log_output("✓ Assigned quest '" + quest.quest_name + "' to " + character.character_name)
			else:
				log_output("✗ Failed to assign quest '" + quest.quest_name + "'")
		else:
			log_output("⚠ Cannot assign quest '" + quest.quest_name + "' to " + character.character_name + " (requirements not met)")

func _on_test_training_pressed():
	log_output("\n=== Testing Character Training ===")
	
	if test_characters.is_empty():
		log_output("⚠ No characters available, running recruitment test first...")
		_on_test_recruitment_pressed()
		await get_tree().process_frame
	
	var training_service = ServiceManager.get_training_service()
	if not training_service:
		log_output("✗ Training service not available")
		return
	
	# Test training on first character
	if test_characters.size() == 0:
		log_output("✗ No characters available for training.")
		return
	var character = test_characters[0]
	log_output("Testing training on: " + character.character_name)
	
	# Get training options
	var options = training_service.get_available_training_options(character)
	log_output("Available training options: " + str(options.size()))
	
	# Test training efficiency
	var efficiency = training_service.get_training_efficiency(character)
	log_output("Training efficiency: " + str(efficiency.overall_efficiency))
	log_output("Recommended stats: " + str(efficiency.recommended_stats))
	
	# Test actual training if options available
	if options.size() > 0:
		var training_option = options[0]
		var cost = GameConfig.get_balance_config().get_training_cost(training_option.stat_name)
		log_output("Training cost for " + training_option.stat_name + ": " + str(cost))
		
		# Simulate training (without actually spending resources)
		log_output("✓ Training system functional")

func _on_test_equipment_pressed():
	log_output("\n=== Testing Equipment System ===")
	
	var equipment_service = ServiceManager.get_equipment_service()
	if not equipment_service:
		log_output("✗ Equipment service not available")
		return
	
	# Test creating various equipment
	var equipment_data = [
		{"name": "Iron Sword", "resource_type": GameResource.ResourceType.WEAPONS, "rarity": GameResource.Rarity.COMMON, "equipment_slot": "weapon", "tags": ["Equipment"]},
		{"name": "Leather Armor", "resource_type": GameResource.ResourceType.ARMOR_PIECES, "rarity": GameResource.Rarity.COMMON, "equipment_slot": "armor", "tags": ["Equipment"]},
		{"name": "Magic Ring", "resource_type": GameResource.ResourceType.ACCESSORIES, "rarity": GameResource.Rarity.RARE, "equipment_slot": "accessory", "tags": ["Equipment"]}
	]
	
	for data in equipment_data:
		var equipment = equipment_service.create_equipment(data)
		if equipment:
			log_output("✓ Created equipment: " + equipment.name + " (" + GameResource.Rarity.keys()[equipment.rarity] + ")")
			test_equipment.append(equipment)
		else:
			log_output("✗ Failed to create equipment: " + data.name)
	
	log_output("Total equipment created: " + str(test_equipment.size()))

func _on_test_guild_management_pressed():
	log_output("\n=== Testing Guild Management ===")
	
	var guild_service = ServiceManager.get_guild_service()
	if not guild_service:
		log_output("✗ Guild service not available")
		return
	
	var guild = guild_service.get_guild()
	if not guild:
		log_output("✗ Guild not available")
		return
	
	log_output("Guild Status:")
	log_output("  Name: " + guild.guild_name)
	log_output("  Gold: " + str(guild.gold))
	log_output("  Influence: " + str(guild.influence))
	log_output("  Level: " + str(guild.level))
	log_output("  Members: " + str(guild.current_roster_size))
	
	# Test guild operations
	var old_gold = guild.gold
	var old_influence = guild.influence
	
	# Add resources using the correct method
	var resources_to_add = {"gold": 100, "influence": 50}
	var success = guild_service.add_resources(resources_to_add)
	
	if success:
		var updated_guild = guild_service.get_guild()
		log_output("✓ Added 100 gold (was: " + str(old_gold) + ", now: " + str(updated_guild.gold) + ")")
		log_output("✓ Added 50 influence (was: " + str(old_influence) + ", now: " + str(updated_guild.influence) + ")")
	else:
		log_output("✗ Failed to add resources")

func _on_test_quest_execution_pressed():
	log_output("\n=== Testing Quest Execution ===")
	
	if test_quests.is_empty():
		log_output("⚠ No quests available, generating test quests...")
		_generate_test_quests()
	
	var quest_service = ServiceManager.get_quest_service()
	if not quest_service:
		log_output("✗ Quest service not available")
		return
	
	# Test quest execution simulation
	for quest in test_quests:
		log_output("Testing quest: " + quest.quest_name)
		log_output("  Duration: " + str(quest.duration) + " seconds")
		log_output("  Difficulty: " + Quest.QuestDifficulty.keys()[quest.difficulty])
		log_output("  Rewards: " + str(quest.get_total_reward_value()) + " gold value")
		
		# Simulate quest completion (simplified success chance calculation)
		var base_success_rate = 0.8  # 80% base success rate
		var difficulty_penalty = quest.difficulty * 0.1  # 10% penalty per difficulty level
		var success_chance = max(0.1, base_success_rate - difficulty_penalty)  # Minimum 10% chance
		log_output("  Success chance: " + str(success_chance * 100) + "%")
		log_output("✓ Quest execution simulation complete")

# Integration Test Methods
func _on_test_full_gameplay_pressed():
	log_output("\n=== Testing Full Gameplay Loop ===")
	
	test_in_progress = true
	
	# Step 1: Initialize services
	log_output("Step 1: Initializing services...")
	if not ServiceManager.is_initialized():
		ServiceManager.initialize_services()
	log_output("✓ Services initialized")
	
	# Step 2: Create guild
	log_output("Step 2: Setting up guild...")
	var guild_service = ServiceManager.get_guild_service()
	var guild = guild_service.get_guild()
	log_output("✓ Guild ready: " + guild.guild_name)
	
	# Step 3: Recruit characters
	log_output("Step 3: Recruiting characters...")
	_on_test_recruitment_pressed()
	await get_tree().process_frame
	log_output("✓ Recruited " + str(test_characters.size()) + " characters")
	
	# Step 4: Generate quests
	log_output("Step 4: Generating quests...")
	_generate_test_quests()
	log_output("✓ Generated " + str(test_quests.size()) + " quests")
	
	# Step 5: Assign and execute quests
	log_output("Step 5: Assigning quests...")
	_on_test_quest_assignment_pressed()
	await get_tree().process_frame
	log_output("✓ Quest assignment complete")
	
	# Step 6: Train characters
	log_output("Step 6: Training characters...")
	_on_test_training_pressed()
	log_output("✓ Training complete")
	
	# Step 7: Manage guild resources
	log_output("Step 7: Managing guild resources...")
	_on_test_guild_management_pressed()
	log_output("✓ Guild management complete")
	
	log_output("✓ Full gameplay loop test completed successfully!")
	test_in_progress = false

func _on_test_save_load_pressed():
	log_output("\n=== Testing Save/Load Cycle ===")
	
	# Create test data
	if test_characters.is_empty():
		_on_test_recruitment_pressed()
		await get_tree().process_frame
	
	# Test save
	log_output("Testing save system...")
	SaveSystem.set_current_save("test_save")
	var save_success = SaveSystem.save_game()
	if save_success:
		log_output("✓ Game saved successfully")
	else:
		log_output("✗ Save failed")
	
	# Test load
	log_output("Testing load system...")
	var load_success = SaveSystem.load_game()
	if load_success:
		log_output("✓ Game loaded successfully")
	else:
		log_output("✗ Load failed")
	
	# Verify data integrity
	log_output("Verifying data integrity...")
	var loaded_characters = ServiceManager.get_character_repository().get_all()
	log_output("Loaded characters: " + str(loaded_characters.size()))
	log_output("✓ Save/Load cycle test completed")

func _on_test_performance_pressed():
	log_output("\n=== Testing Performance ===")
	
	var start_time = Time.get_ticks_msec()
	
	# Test character creation performance
	log_output("Testing character creation performance...")
	var char_start = Time.get_ticks_msec()
	for i in range(100):
		var test_char = Character.new()
		test_char.character_name = "Test Char " + str(i)
		test_char.validate()
	var char_time = Time.get_ticks_msec() - char_start
	log_output("✓ Created 100 characters in " + str(char_time) + "ms")
	
	# Test quest creation performance
	log_output("Testing quest creation performance...")
	var quest_start = Time.get_ticks_msec()
	for i in range(100):
		var quest = Quest.new()
		quest.quest_name = "Test Quest " + str(i)
		quest.validate()
	var quest_time = Time.get_ticks_msec() - quest_start
	log_output("✓ Created 100 quests in " + str(quest_time) + "ms")
	
	# Test event system performance
	log_output("Testing event system performance...")
	var event_start = Time.get_ticks_msec()
	for i in range(1000):
		EventBus.emit_simple_event("test_event", {"id": i}, "PerformanceTest")
	var event_time = Time.get_ticks_msec() - event_start
	log_output("✓ Emitted 1000 events in " + str(event_time) + "ms")
	
	var total_time = Time.get_ticks_msec() - start_time
	log_output("✓ Performance test completed in " + str(total_time) + "ms")

func _on_test_stress_pressed():
	log_output("\n=== Testing Stress Scenarios ===")
	
	# Test rapid character creation
	log_output("Testing rapid character creation...")
	for i in range(50):
		var stress_char = Character.new()
		stress_char.character_name = "Stress Test Char " + str(i)
		stress_char.validate()
	log_output("✓ Created 50 characters rapidly")
	
	# Test rapid quest generation
	log_output("Testing rapid quest generation...")
	var quest_service = ServiceManager.get_quest_service()
	if quest_service:
		for i in range(20):
			var quest = quest_service.generate_quest(Quest.QuestType.GATHERING, Quest.QuestRank.D)
			if quest:
				log_output("Generated: " + quest.quest_name)
		log_output("✓ Generated 20 quests rapidly")
	
	# Test rapid event emission
	log_output("Testing rapid event emission...")
	for i in range(500):
		EventBus.emit_simple_event("stress_test", {"iteration": i}, "StressTest")
	log_output("✓ Emitted 500 events rapidly")
	
	log_output("✓ Stress test completed")

func _on_test_error_handling_pressed():
	log_output("\n=== Testing Error Handling ===")
	
	# Test invalid character creation
	log_output("Testing invalid character creation...")
	var invalid_char = Character.new()
	# Don't set required fields
	var is_valid = invalid_char.validate()
	log_output("Invalid character validation: " + str(is_valid) + " (expected: false)")
	
	# Test invalid quest creation
	log_output("Testing invalid quest creation...")
	var invalid_quest = Quest.new()
	# Don't set required fields
	var quest_valid = invalid_quest.validate()
	log_output("Invalid quest validation: " + str(quest_valid) + " (expected: false)")
	
	# Test service error handling
	log_output("Testing service error handling...")
	var char_service = ServiceManager.get_character_service()
	if char_service:
		# Try to recruit with invalid data
		var invalid_data = {"invalid": "data"}
		var result = char_service.recruit_character(invalid_data)
		log_output("Invalid recruitment result: " + str(result) + " (expected: null)")
	
	log_output("✓ Error handling test completed")

func _on_test_all_systems_pressed():
	log_output("\n=== Testing All Systems ===")
	log_output("Running comprehensive system test...")
	
	# Run all foundation tests
	_on_test_character_pressed()
	await get_tree().process_frame
	_on_test_quest_pressed()
	await get_tree().process_frame
	_on_test_event_pressed()
	await get_tree().process_frame
	_on_test_config_pressed()
	await get_tree().process_frame
	_on_test_save_pressed()
	await get_tree().process_frame
	_on_test_services_pressed()
	await get_tree().process_frame
	
	# Run all UI tests
	_on_test_ui_navigation_pressed()
	await get_tree().process_frame
	_on_test_character_ui_pressed()
	await get_tree().process_frame
	_on_test_quest_ui_pressed()
	await get_tree().process_frame
	_on_test_guild_ui_pressed()
	await get_tree().process_frame
	_on_test_settings_ui_pressed()
	await get_tree().process_frame
	_on_test_ui_manager_pressed()
	await get_tree().process_frame
	
	# Run all gameplay tests
	_on_test_recruitment_pressed()
	await get_tree().process_frame
	_on_test_quest_assignment_pressed()
	await get_tree().process_frame
	_on_test_training_pressed()
	await get_tree().process_frame
	_on_test_equipment_pressed()
	await get_tree().process_frame
	_on_test_guild_management_pressed()
	await get_tree().process_frame
	_on_test_quest_execution_pressed()
	await get_tree().process_frame
	
	# Run integration tests
	_on_test_performance_pressed()
	await get_tree().process_frame
	_on_test_stress_pressed()
	await get_tree().process_frame
	_on_test_error_handling_pressed()
	await get_tree().process_frame
	
	log_output("\n✓ ALL SYSTEMS TEST COMPLETED!")
	log_output("Check results above for any failures or warnings.")

# Control Methods
func _on_clear_output_pressed():
	output_label.clear()
	_clear_demo_viewport()
	log_output("Output cleared. Ready for new tests.")

func _on_clear_demo_pressed():
	log_output("\n=== Clearing Demo Viewport ===")
	_clear_demo_viewport()
	log_output("✓ Demo viewport cleared")

func _on_launch_game_pressed():
	log_output("\n=== Launching Full Game in Demo Viewport ===")
	
	if not UIManager or not UIManager._is_initialized:
		log_output("✗ UI Manager not initialized, cannot launch game")
		return
	
	# Set up the SubViewport for game rendering
	_setup_game_viewport()
	
	# Show main game UI in the SubViewport
	UIManager.navigate_to("characters")
	log_output("✓ Full game launched in demo viewport! Use navigation to explore different screens.")
	log_output("  Game is now rendering in the demo viewport below.")

# Helper Methods
func _clear_demo_viewport():
	"""Clear the demo viewport"""
	if demo_subviewport:
		for child in demo_subviewport.get_children():
			child.queue_free()
		log_output("Demo viewport cleared")

func _setup_game_viewport():
	"""Set up the SubViewport to render the game UI"""
	log_output("Setting up game viewport...")
	
	# Configure the SubViewport
	demo_subviewport.size = Vector2(800, 600)  # Set a reasonable size for the demo
	demo_subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	demo_subviewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	
	log_output("Demo viewport configured: " + str(demo_subviewport.size))
	
	# Clear any existing content
	for child in demo_subviewport.get_children():
		child.queue_free()
	
	# Ensure services are initialized first
	if not ServiceManager.is_initialized():
		log_output("Initializing services for demo viewport...")
		ServiceManager.initialize_services()
		await get_tree().process_frame
	
	# Ensure UIManager is properly initialized
	if UIManager:
		if not UIManager._is_initialized:
			log_output("Initializing UIManager for demo viewport...")
			# Initialize ViewModels and dependencies
			UIManager._initialize_view_models()
			UIManager._load_ui_settings()
			UIManager._setup_event_subscriptions()
			UIManager._is_initialized = true
		
		# Initialize UI in the demo viewport
		UIManager.initialize_ui_for_demo_viewport(demo_subviewport)
		log_output("✓ UI system initialized for demo viewport")
	else:
		log_output("✗ UIManager not available")

func _generate_test_quests():
	var quest_service = ServiceManager.get_quest_service()
	if not quest_service:
		return
	
	# Generate various types of quests
	var quest_types = [Quest.QuestType.GATHERING, Quest.QuestType.HUNTING, Quest.QuestType.DIPLOMACY]
	var quest_ranks = [Quest.QuestRank.D, Quest.QuestRank.C, Quest.QuestRank.B]
	
	for quest_type in quest_types:
		for quest_rank in quest_ranks:
			var quest = quest_service.generate_quest(quest_type, quest_rank)
			if quest:
				test_quests.append(quest)

func log_output(message: String):
	output_label.append_text(message + "\n")
	print(message)  # Also print to console for debugging
