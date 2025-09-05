# Testing Guide - GuildSim Rebuild

## Overview

This guide provides comprehensive testing procedures for the GuildSim rebuild project. The testing system is designed to validate all architectural components and ensure system stability.

## 🧪 Testing Architecture

### **Test Scene**: `TestScene.tscn`
**Location**: `scenes/TestScene.tscn`  
**Purpose**: Comprehensive testing interface for all system components

### **Test Categories**
1. **Unit Testing**: Individual component testing
2. **Integration Testing**: Component interaction testing
3. **System Testing**: End-to-end system testing
4. **Performance Testing**: Performance validation
5. **Error Testing**: Error condition testing

## 🚀 Running Tests

### **Quick Start**
1. Open the project in Godot 4.x
2. Load `scenes/TestScene.tscn`
3. Run the scene (F6)
4. Click "Test All Systems" button
5. Review test results in the console

### **Test Execution**
```gdscript
# Test execution order
1. Character System Test
2. Quest System Test
3. Event System Test
4. Configuration System Test
5. Save System Test
6. Service Layer Test
```

## 📊 Test Results Interpretation

### **Success Indicators** ✅
- **Green Checkmarks**: All tests passed
- **No Error Messages**: Clean console output
- **Proper Event Flow**: Events emitted and received correctly
- **Data Persistence**: Save/load operations successful
- **Service Initialization**: All services initialized without errors

### **Failure Indicators** ❌
- **Red X Marks**: Test failures
- **Error Messages**: Runtime errors in console
- **Missing Events**: Events not emitted or received
- **Data Corruption**: Save/load failures
- **Service Failures**: Service initialization errors

## 🔍 Detailed Test Procedures

### **1. Character System Testing**

#### **Test: Character Creation**
```gdscript
# Expected Results
✓ Character created successfully: Test Hero
ID: char_[timestamp]_[random]
Class: TANK
Quality: THREE_STAR
Rank: D
Level: 1
Health: 150
Available: true
Experience to next level: 150
```

#### **Test: Character Data Validation**
- **ID Generation**: Unique ID format validation
- **Property Access**: `get_data()` and `set_data()` methods
- **Data Validation**: `validate()` method returns true
- **Statistics**: `get_statistics_summary()` returns proper data

#### **Test: Character Repository**
- **CRUD Operations**: Create, Read, Update, Delete
- **Search Functions**: Find by ID, class, availability
- **Event Integration**: Repository events emitted correctly

### **2. Quest System Testing**

#### **Test: Quest Generation**
```gdscript
# Expected Results
✓ Quest created successfully: Gather Herbs
ID: quest_[timestamp]_[random]
Type: GATHERING
Rank: D
Difficulty: NORMAL
Duration: 300.0 seconds
Gold Reward: 150
Total Reward Value: 475
Difficulty Multiplier: 1.0
Rank Multiplier: 1.5
```

#### **Test: Quest Data Validation**
- **ID Generation**: Unique ID format validation
- **Property Access**: `get_data()` and `set_data()` methods
- **Data Validation**: `validate()` method returns true
- **Reward Calculation**: `calculate_reward_value()` returns correct value

#### **Test: Quest Repository**
- **CRUD Operations**: Create, Read, Update, Delete
- **Search Functions**: Find by type, rank, difficulty
- **Event Integration**: Repository events emitted correctly

### **3. Event System Testing**

#### **Test: Event Emission**
```gdscript
# Expected Results
Event Received: test_event from TestScene
Event Received: character_recruited from CharacterService
✓ Character recruited event emitted
Event Received: quest_generated from QuestService
✓ Quest generated event emitted
Event Received: guild_created from GuildService
✓ Guild created event emitted
```

#### **Test: Event Statistics**
```gdscript
# Expected Results
Event Statistics:
Events Emitted: 4
Events Processed: 0
Subscriptions: 0
```

#### **Test: Event Types**
- **Character Events**: Recruitment, training, equipment
- **Quest Events**: Generation, assignment, completion
- **Guild Events**: Creation, resource changes, progression

### **4. Configuration System Testing**

#### **Test: Game Configuration**
```gdscript
# Expected Results
Game Version: 1.0.0
Debug Mode: false
Auto Save Enabled: true
UI Scale: 1.5
Features Enabled:
✗ achievement_system
✓ armory
✓ blacksmiths_guild
✗ crafting_system
✓ equipment_system
✓ healers_guild
✓ inventory_system
✓ library
✓ merchants_guild
✗ trading_system
✓ training_room
✓ tutorial_system
✓ workshop
```

#### **Test: Balance Configuration**
```gdscript
# Expected Results
Balance Config:
Recruitment Cost (2-star): 500
Quest Reward Multiplier (D): 1.5
Training Cost (health): { "gold": 50, "time": 60 }
```

#### **Test: Configuration Persistence**
- **Settings Save**: Configuration saved correctly
- **Settings Load**: Configuration loaded correctly
- **Default Values**: Fallback values when config missing

### **5. Save System Testing**

#### **Test: Save System Statistics**
```gdscript
# Expected Results
Save System Statistics:
Save Count: 0
Load Count: 0
Auto Save Enabled: true
Current Save: 
Available Saves: 0
Current save set to: test_save
Auto-save configured: enabled, 5 minute interval
```

#### **Test: Save Operations**
- **Save Game**: Game state saved successfully
- **Load Game**: Game state loaded successfully
- **Delete Save**: Save file deleted successfully
- **Auto Save**: Auto-save functionality working

### **6. Service Layer Testing**

#### **Test: Service Initialization**
```gdscript
# Expected Results
Initializing services...
[ServiceManager] Initializing services...
[ServiceManager] Initializing repositories...
[ServiceManager] Repositories initialized
[ServiceManager] Initializing business logic services...
[ServiceManager] Services created and initialized
[ServiceManager] Setting up service dependencies...
[ServiceManager] Service dependencies configured
[ServiceManager] Validating services...
[ServiceManager] All services validated successfully
[ServiceManager] All services initialized successfully
✓ Services initialized successfully
```

#### **Test: Character Service**
```gdscript
# Expected Results
--- Testing Character Service ---
✓ Character Service available
Event Received: insufficient_resources from CharacterService
✗ Character recruitment failed
```

#### **Test: Quest Service**
```gdscript
# Expected Results
--- Testing Quest Service ---
✓ Quest Service available
Event Received: quest_generated from QuestService
✓ Quest generated: Gather Resources
```

#### **Test: Guild Service**
```gdscript
# Expected Results
--- Testing Guild Service ---
✓ Guild Service available
✓ Guild available: New Guild
Gold: 1
Influence: 1
```

#### **Test: Training Service**
```gdscript
# Expected Results
--- Testing Training Service ---
✓ Training Service available
✓ Training options available: 12
Training efficiency: 0.08059628397254
Recommended stats: ["health", "gathering", "hunting"]
```

#### **Test: Equipment Service**
```gdscript
# Expected Results
--- Testing Equipment Service ---
✓ Equipment Service available
✓ Equipment created: Iron Sword
Rarity: COMMON
Value: 100
```

## 🐛 Troubleshooting Common Issues

### **Issue: "Character recruitment failed"**
**Cause**: Insufficient guild resources  
**Solution**: Check guild resource initialization in `GuildService`

### **Issue: "BalanceConfig not available"**
**Cause**: Configuration system not properly initialized  
**Solution**: Ensure `GameConfig.ensure_balance_config()` is called

### **Issue: "get_repository_name() must be implemented"**
**Cause**: Missing concrete repository implementation  
**Solution**: Implement `get_repository_name()` in repository classes

### **Issue: "Event not received"**
**Cause**: Event subscription or emission problem  
**Solution**: Check event types and subscription callbacks

### **Issue: "Save/Load failed"**
**Cause**: File system or serialization problem  
**Solution**: Check file permissions and data serialization

## 📈 Performance Testing

### **Performance Metrics**
- **Initialization Time**: < 1 second
- **Frame Rate**: 60+ FPS
- **Memory Usage**: < 100MB
- **Event Processing**: < 1ms per event
- **Save/Load Time**: < 500ms

### **Performance Testing Procedure**
1. **Startup Performance**: Measure system initialization time
2. **Runtime Performance**: Monitor frame rate during operation
3. **Memory Usage**: Track memory consumption over time
4. **Event Performance**: Measure event processing time
5. **Save/Load Performance**: Time save and load operations

## 🔧 Test Environment Setup

### **Required Environment**
- **Godot Version**: 4.x
- **Platform**: Windows, macOS, Linux
- **Memory**: 4GB+ RAM
- **Storage**: 1GB+ free space

### **Test Data**
- **Test Characters**: Predefined test character data
- **Test Quests**: Predefined test quest data
- **Test Guild**: Predefined test guild data
- **Test Resources**: Predefined test resource data

## 📋 Test Checklist

### **Pre-Test Checklist**
- [ ] Project opens without errors
- [ ] All systems initialize successfully
- [ ] No missing dependencies
- [ ] Configuration files present
- [ ] Save directory accessible

### **Test Execution Checklist**
- [ ] Character system tests pass
- [ ] Quest system tests pass
- [ ] Event system tests pass
- [ ] Configuration system tests pass
- [ ] Save system tests pass
- [ ] Service layer tests pass

### **Post-Test Checklist**
- [ ] All tests completed successfully
- [ ] No error messages in console
- [ ] Performance metrics within targets
- [ ] Test results documented
- [ ] Issues identified and logged

## 🎯 Success Criteria

### **System Health**
- ✅ **Zero Runtime Errors**: All systems initialize without errors
- ✅ **Event Flow**: Events properly emitted and received
- ✅ **Data Persistence**: Save/load operations working
- ✅ **Service Integration**: All services working together
- ✅ **Performance**: Meets performance targets

### **Quality Assurance**
- ✅ **Code Quality**: Clean, well-documented code
- ✅ **Architecture**: Proper separation of concerns
- ✅ **Error Handling**: Comprehensive error handling
- ✅ **Testing Coverage**: All components tested
- ✅ **Documentation**: Complete documentation

---

*This testing guide ensures the GuildSim rebuild project meets all quality and performance requirements.*
