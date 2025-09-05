extends Control

## Test scene for verifying foundation architecture
## Tests all core systems to ensure they're working correctly

@onready var output_label: RichTextLabel = $VBoxContainer/Output
@onready var test_character_btn: Button = $VBoxContainer/TestButtons/TestCharacter
@onready var test_quest_btn: Button = $VBoxContainer/TestButtons/TestQuest
@onready var test_event_btn: Button = $VBoxContainer/TestButtons/TestEvent
@onready var test_config_btn: Button = $VBoxContainer/TestButtons/TestConfig
@onready var test_save_btn: Button = $VBoxContainer/TestButtons/TestSave
@onready var test_services_btn: Button = $VBoxContainer/TestButtons/TestServices

var test_character: Character
var test_quest: Quest
var test_guild: Guild

func _ready():
	# Connect button signals
	test_character_btn.pressed.connect(_on_test_character_pressed)
	test_quest_btn.pressed.connect(_on_test_quest_pressed)
	test_event_btn.pressed.connect(_on_test_event_pressed)
	test_config_btn.pressed.connect(_on_test_config_pressed)
	test_save_btn.pressed.connect(_on_test_save_pressed)
	test_services_btn.pressed.connect(_on_test_services_pressed)
	
	# Connect to EventBus for testing
	EventBus.event_emitted.connect(_on_event_emitted)
	
	log_output("GuildSim Foundation Test Scene Loaded")
	log_output("Testing core architecture components...")

func _on_test_character_pressed():
	log_output("\n=== Testing Character System ===")
	
	# Create test character
	test_character = Character.new()
	test_character.character_name = "Test Hero"
	test_character.character_class = Character.CharacterClass.TANK
	test_character.quality = Character.Quality.TWO_STAR
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
	
	# Validate character
	if test_character.validate():
		log_output("✓ Character created successfully: " + test_character.character_name)
		log_output("  ID: " + test_character.id)
		log_output("  Class: " + Character.CharacterClass.keys()[test_character.character_class])
		log_output("  Quality: " + Character.Quality.keys()[test_character.quality])
		log_output("  Rank: " + Character.Rank.keys()[test_character.rank])
		log_output("  Level: " + str(test_character.level))
		log_output("  Health: " + str(test_character.health))
		log_output("  Available: " + str(test_character.is_available()))
		log_output("  Experience to next level: " + str(test_character.get_experience_to_next_level()))
	else:
		log_output("✗ Character validation failed")

func _on_test_quest_pressed():
	log_output("\n=== Testing Quest System ===")
	
	# Create test quest
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
	
	# Test service statistics
	log_output("\n--- Service Statistics ---")
	var service_stats = ServiceManager.get_service_statistics()
	log_output("Service Manager Statistics:")
	log_output("  Initialized: " + str(service_stats.is_initialized))
	log_output("  Services Count: " + str(service_stats.services.size()))
	
	for service_name in service_stats.services:
		var stats = service_stats.services[service_name]
		log_output("  " + service_name + ": " + str(stats.get("service_name", "Unknown")))

func _on_event_emitted(event: BaseEvent):
	log_output("Event Received: " + event.event_type + " from " + event.source)

func log_output(message: String):
	output_label.append_text(message + "\n")
	print(message)  # Also print to console for debugging
