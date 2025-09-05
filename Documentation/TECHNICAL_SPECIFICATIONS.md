# Technical Specifications - GuildSim Rebuild

## System Architecture Overview

### **Architecture Pattern**: Layered Architecture with Event-Driven Communication

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (Phase 3)                      │
├─────────────────────────────────────────────────────────────┤
│                 Service Layer (Phase 2) ✅                 │
├─────────────────────────────────────────────────────────────┤
│                Repository Layer (Phase 1) ✅               │
├─────────────────────────────────────────────────────────────┤
│                  Event Layer (Phase 1) ✅                  │
├─────────────────────────────────────────────────────────────┤
│                   Data Layer (Phase 1) ✅                  │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Data Layer Specifications

### **Data Models**

#### **Character Model**
```gdscript
class_name Character extends Resource
```

**Properties**:
- `id: String` - Unique identifier
- `name: String` - Character name
- `character_class: CharacterClass` - Class enum (TANK, DPS, HEALER, SUPPORT)
- `quality: CharacterQuality` - Quality enum (ONE_STAR, TWO_STAR, THREE_STAR)
- `rank: CharacterRank` - Rank enum (D, C, B, A, S)
- `level: int` - Current level (1-100)
- `health: int` - Current health
- `max_health: int` - Maximum health
- `experience: int` - Current experience
- `experience_to_next: int` - Experience needed for next level
- `stats: Dictionary` - Character statistics
- `equipment: Dictionary` - Equipped items
- `is_available: bool` - Availability for quests
- `recruitment_cost: Dictionary` - Cost to recruit
- `training_progress: Dictionary` - Training progress

**Methods**:
- `get_data(property_name: String) -> Variant`
- `set_data(property_name: String, value: Variant) -> void`
- `validate() -> bool`
- `get_statistics_summary() -> Dictionary`
- `can_afford(cost: Dictionary) -> bool`

#### **Quest Model**
```gdscript
class_name Quest extends Resource
```

**Properties**:
- `id: String` - Unique identifier
- `quest_name: String` - Quest name
- `quest_type: QuestType` - Type enum (GATHERING, HUNTING, ESCORT, DEFENSE)
- `rank: CharacterRank` - Required rank
- `difficulty: QuestDifficulty` - Difficulty enum (EASY, NORMAL, HARD, EXPERT)
- `duration: float` - Duration in seconds
- `required_stats: Dictionary` - Required character stats
- `rewards: Dictionary` - Quest rewards
- `requirements: Dictionary` - Quest requirements
- `description: String` - Quest description
- `is_completed: bool` - Completion status
- `assigned_characters: Array[String]` - Assigned character IDs

**Methods**:
- `get_data(property_name: String) -> Variant`
- `set_data(property_name: String, value: Variant) -> void`
- `validate() -> bool`
- `get_statistics_summary() -> Dictionary`
- `calculate_reward_value() -> int`

#### **Guild Model**
```gdscript
class_name Guild extends Resource
```

**Properties**:
- `id: String` - Unique identifier
- `guild_name: String` - Guild name
- `level: int` - Guild level
- `reputation: int` - Guild reputation
- `gold: int` - Gold resources
- `influence: int` - Influence resources
- `food: int` - Food resources
- `building_materials: int` - Building materials
- `unlocked_rooms: Array[String]` - Unlocked rooms
- `unlocked_features: Dictionary` - Unlocked features
- `guild_upgrades: Dictionary` - Guild upgrades
- `statistics: Dictionary` - Guild statistics

**Methods**:
- `get_data(property_name: String) -> Variant`
- `set_data(property_name: String, value: Variant) -> void`
- `validate() -> bool`
- `get_statistics_summary() -> Dictionary`
- `get_all_resources() -> Dictionary`
- `can_afford(cost: Dictionary) -> bool`
- `is_room_unlocked(room_name: String) -> bool`
- `is_feature_unlocked(feature_name: String) -> bool`

#### **Resource Model**
```gdscript
class_name Resource extends Resource
```

**Properties**:
- `id: String` - Unique identifier
- `name: String` - Resource name
- `type: ResourceType` - Type enum (EQUIPMENT, CONSUMABLE, MATERIAL)
- `rarity: ItemRarity` - Rarity enum (COMMON, UNCOMMON, RARE, EPIC, LEGENDARY)
- `value: int` - Base value
- `stats: Dictionary` - Resource statistics
- `requirements: Dictionary` - Usage requirements
- `description: String` - Resource description

**Methods**:
- `get_data(property_name: String) -> Variant`
- `set_data(property_name: String, value: Variant) -> void`
- `validate() -> bool`
- `get_statistics_summary() -> Dictionary`

## 🔄 Event System Specifications

### **Event Architecture**

#### **Base Event**
```gdscript
class_name BaseEvent extends RefCounted
```

**Properties**:
- `event_type: String` - Event type identifier
- `source: String` - Event source
- `timestamp: float` - Event timestamp
- `data: Dictionary` - Event data

**Methods**:
- `_init(event_type: String, source: String, data: Dictionary)`

#### **Event Categories**

**Character Events**:
- `CharacterRecruitedEvent` - Character recruitment
- `CharacterLeveledUpEvent` - Character level up
- `CharacterTrainedEvent` - Character training
- `CharacterEquippedEvent` - Equipment changes

**Quest Events**:
- `QuestGeneratedEvent` - Quest generation
- `QuestAssignedEvent` - Quest assignment
- `QuestCompletedEvent` - Quest completion
- `QuestFailedEvent` - Quest failure

**Guild Events**:
- `GuildCreatedEvent` - Guild creation
- `GuildLeveledUpEvent` - Guild level up
- `GuildResourceChangedEvent` - Resource changes
- `GuildRoomUnlockedEvent` - Room unlocks
- `GuildFeatureUnlockedEvent` - Feature unlocks

### **Event Bus**
```gdscript
class_name EventBus extends Node
```

**Methods**:
- `emit_event(event: BaseEvent) -> void`
- `emit_simple_event(event_type: String, data: Dictionary, source: String) -> void`
- `subscribe(event_type: String, callback: Callable) -> void`
- `unsubscribe(event_type: String, callback: Callable) -> void`
- `get_event_statistics() -> Dictionary`

## 🗄️ Repository Layer Specifications

### **Base Repository**
```gdscript
class_name BaseRepository extends RefCounted
```

**Properties**:
- `_data: Array` - Entity storage
- `_index: Dictionary` - Entity indexing
- `_save_system: SaveSystem` - Save system reference
- `_event_bus: EventBus` - Event bus reference

**Methods**:
- `add(entity: Variant) -> bool`
- `get_by_id(id: String) -> Variant`
- `get_all() -> Array`
- `update(entity: Variant) -> bool`
- `remove(id: String) -> bool`
- `clear() -> void`
- `get_repository_name() -> String` (Abstract)
- `_get_entity_value(entity: Variant, key: String) -> Variant`
- `_update_index() -> void`

### **Concrete Repositories**

#### **Character Repository**
- **Repository Name**: "characters"
- **Special Methods**: `get_available_characters()`, `get_characters_by_class()`

#### **Quest Repository**
- **Repository Name**: "quests"
- **Special Methods**: `get_available_quests()`, `get_quests_by_type()`

#### **Guild Repository**
- **Repository Name**: "guild"
- **Special Methods**: `get_current_guild()`, `spend_resources()`, `add_resources()`

## 🔧 Service Layer Specifications

### **Base Service**
```gdscript
class_name BaseService extends RefCounted
```

**Properties**:
- `_service_name: String` - Service name
- `_is_initialized: bool` - Initialization status
- `_event_bus: EventBus` - Event bus reference
- `_save_system: SaveSystem` - Save system reference
- `_game_config: GameConfig` - Game configuration
- `_balance_config: BalanceConfig` - Balance configuration

**Methods**:
- `initialize(event_bus: EventBus, save_system: SaveSystem, game_config: GameConfig) -> void`
- `is_initialized() -> bool`
- `get_service_name() -> String`
- `_on_initialized() -> void` (Virtual)
- `log_activity(message: String) -> void`

### **Business Logic Services**

#### **Character Service**
- **Repository**: CharacterRepository
- **Key Methods**: `recruit_character()`, `train_character()`, `equip_character()`
- **Events**: Character recruitment, training, equipment changes

#### **Quest Service**
- **Repository**: QuestRepository
- **Key Methods**: `generate_quest()`, `assign_quest()`, `complete_quest()`
- **Events**: Quest generation, assignment, completion

#### **Guild Service**
- **Repository**: GuildRepository
- **Key Methods**: `create_guild()`, `spend_resources()`, `unlock_room()`
- **Events**: Guild creation, resource changes, progression

#### **Equipment Service**
- **Repository**: ResourceRepository
- **Key Methods**: `create_equipment()`, `calculate_stats()`, `upgrade_equipment()`
- **Events**: Equipment creation, stat changes

#### **Training Service**
- **Repository**: CharacterRepository
- **Key Methods**: `train_character()`, `calculate_training_cost()`, `get_training_options()`
- **Events**: Training progress, stat improvements

## ⚙️ Configuration System Specifications

### **Game Configuration**
```gdscript
class_name GameConfig extends Node
```

**Properties**:
- `game_version: String` - Game version
- `debug_mode: bool` - Debug mode flag
- `auto_save_enabled: bool` - Auto-save setting
- `ui_scale: float` - UI scale factor
- `features_enabled: Dictionary` - Feature flags
- `balance_config: BalanceConfig` - Balance configuration

**Methods**:
- `get_data(setting_name: String) -> Variant`
- `set_data(setting_name: String, value: Variant) -> void`
- `is_ready() -> bool`
- `ensure_balance_config() -> void`
- `get_all_settings() -> Dictionary`
- `restore_settings(settings: Dictionary) -> void`

### **Balance Configuration**
```gdscript
class_name BalanceConfig extends Resource
```

**Properties**:
- `recruitment_costs: Dictionary` - Character recruitment costs
- `quest_reward_multipliers: Dictionary` - Quest reward multipliers
- `training_costs: Dictionary` - Training costs
- `starting_gold: int` - Starting gold
- `starting_influence: int` - Starting influence
- `starting_food: int` - Starting food
- `starting_building_materials: int` - Starting building materials

## 💾 Save System Specifications

### **Save System**
```gdscript
class_name SaveSystem extends Node
```

**Properties**:
- `current_save_slot: String` - Current save slot
- `auto_save_enabled: bool` - Auto-save setting
- `auto_save_interval: float` - Auto-save interval
- `save_statistics: Dictionary` - Save statistics

**Methods**:
- `save_game(slot_name: String) -> bool`
- `load_game(slot_name: String) -> bool`
- `delete_save(slot_name: String) -> bool`
- `get_available_saves() -> Array[String]`
- `auto_save() -> void`
- `get_save_statistics() -> Dictionary`

## 🎯 Performance Specifications

### **Performance Targets**
- **Initialization Time**: < 1 second for all systems
- **Frame Rate**: 60+ FPS during gameplay
- **Memory Usage**: < 100MB for core systems
- **Event Processing**: < 1ms per event
- **Save/Load Time**: < 500ms for save operations

### **Optimization Strategies**
- **Lazy Loading**: Load data only when needed
- **Object Pooling**: Reuse objects to reduce garbage collection
- **Event Batching**: Batch similar events for efficiency
- **Caching**: Cache frequently accessed data
- **Memory Management**: Proper resource cleanup

## 🔒 Error Handling Specifications

### **Error Categories**
- **Initialization Errors**: System startup failures
- **Data Validation Errors**: Invalid data states
- **Resource Errors**: Missing or corrupted resources
- **Event Errors**: Event processing failures
- **Save/Load Errors**: Persistence failures

### **Error Handling Strategy**
- **Graceful Degradation**: System continues with reduced functionality
- **Error Logging**: Comprehensive error logging
- **User Notification**: User-friendly error messages
- **Recovery Mechanisms**: Automatic error recovery where possible
- **Fallback Values**: Default values for missing data

---

*These technical specifications provide the detailed implementation requirements for the GuildSim rebuild project.*
