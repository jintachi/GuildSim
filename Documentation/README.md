# GuildSim Rebuild Project Documentation

## Overview

This is the documentation for the **GuildSim Rebuild Project** - a complete architectural overhaul of the original ClaudeGuildIdlePrototype. The rebuild focuses on modern software architecture principles, maintainability, and scalability.

## Project Structure

```
Rebuild/guildsim/
├── Documentation/           # This documentation folder
├── data/                   # Core data layer
│   ├── models/            # Pure data models
│   ├── events/            # Event system
│   ├── repositories/      # Data access layer
│   └── services/          # Business logic layer
├── config/                # Configuration system
├── scenes/                # Godot scenes
└── project.godot         # Godot project file
```

## Documentation Files

- **[ARCHITECTURE_PLAN.md](ARCHITECTURE_PLAN.md)** - Original rebuild strategy and architectural decisions
- **[CURRENT_PROGRESS.md](CURRENT_PROGRESS.md)** - Current implementation status and completed phases
- **[NEXT_STEPS.md](NEXT_STEPS.md)** - Upcoming development phases and priorities
- **[TECHNICAL_SPECIFICATIONS.md](TECHNICAL_SPECIFICATIONS.md)** - Detailed technical implementation details
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - How to test and validate the system

## Quick Start

1. **Current Status**: Phase 2 (Service Layer) - ✅ **COMPLETED**
2. **Next Phase**: Phase 3 (UI Layer) - 🚧 **READY TO START**
3. **Testing**: Use `TestScene.tscn` to validate all systems

## Key Achievements

- ✅ **Domain-Driven Design** implementation
- ✅ **Event-Driven Architecture** with typed events
- ✅ **Repository Pattern** for data access
- ✅ **Service Layer** for business logic
- ✅ **Configuration System** with balance values
- ✅ **Save/Load System** with multi-slot support

## Architecture Principles

- **Separation of Concerns**: Clear boundaries between data, business logic, and UI
- **Dependency Injection**: Services receive their dependencies through constructor injection
- **Event-Driven Communication**: Loose coupling through typed events
- **Configuration-Driven**: Game balance and settings externalized to configuration files
- **Testable Design**: Each component can be tested independently

## Getting Started

1. Open the project in Godot 4.x
2. Run the `TestScene.tscn` to see the current system in action
3. Review the documentation files for detailed implementation information
4. Follow the next steps outlined in `NEXT_STEPS.md`

---

*Last Updated: Phase 2 Completion - Service Layer Implementation*
