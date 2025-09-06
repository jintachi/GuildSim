class_name NavigationService
extends BaseService

## Service for navigation management
## Handles navigation logic, state management, and business rules

# Dependencies
var _navigation_repository: NavigationRepository
var _current_state: NavigationState
var _navigation_start_time: float = 0.0

# Navigation configuration
var _default_animation_duration: float = 0.3
var _max_navigation_depth: int = 10
var _enable_navigation_logging: bool = true

func _init(navigation_repository: NavigationRepository, event_bus: EventBus = null):
	super._init("NavigationService")
	_navigation_repository = navigation_repository
	_current_state = NavigationState.new()
	_event_bus = event_bus

## Initialize navigation service
func initialize(event_bus: EventBus, save_system: SaveSystem, game_config: GameConfig) -> void:
	if not _navigation_repository:
		push_error("Navigation repository not provided")
		return
	
	# Call parent initialization first to set up core dependencies
	super.initialize(event_bus, save_system, game_config)
	
	_log_navigation("Starting navigation service initialization...")
	
	# Load default navigation nodes
	_load_default_navigation_nodes()
	
	# Set initial navigation state
	_set_initial_navigation_state()
	
	_log_navigation("Navigation service initialized successfully")

## Navigate to a specific node
func navigate_to(node_id: String, source: String = "user") -> bool:
	if not _is_initialized:
		push_error("Navigation service not initialized")
		return false
	
	var target_node = _navigation_repository.get_node_by_id(node_id)
	if not target_node:
		push_error("Navigation node not found: " + node_id)
		_emit_navigation_failed(node_id, "", "Node not found")
		return false
	
	# Check if navigation is accessible
	if not target_node.is_user_accessible():
		push_error("Navigation node not accessible: " + node_id)
		_emit_navigation_failed(node_id, target_node.screen_name, "Node not accessible")
		return false
	
	# Check navigation depth
	if _current_state.navigation_depth >= _max_navigation_depth:
		push_error("Maximum navigation depth reached")
		_emit_navigation_failed(node_id, target_node.screen_name, "Maximum depth reached")
		return false
	
	# Start navigation
	_navigation_start_time = Time.get_unix_time_from_system()
	_emit_navigation_started(node_id, target_node.screen_name, source)
	
	# Update navigation state
	_current_state.navigate_to(node_id, source)
	_current_state.current_screen = target_node.screen_name
	
	# Record node access
	target_node.record_access()
	_navigation_repository.update(target_node)
	
	# Update breadcrumb path
	_update_breadcrumb_path()
	
	# Complete navigation
	var duration = Time.get_unix_time_from_system() - _navigation_start_time
	_emit_navigation_completed(node_id, target_node.screen_name, _current_state.previous_screen, duration)
	
	_log_navigation("Navigated to: " + node_id + " (" + target_node.screen_name + ")")
	return true

## Navigate to a screen by name
func navigate_to_screen(screen_name: String, source: String = "user") -> bool:
	var nodes = _navigation_repository.get_nodes_by_screen(screen_name)
	if nodes.is_empty():
		push_error("No navigation node found for screen: " + screen_name)
		return false
	
	# Use the first accessible node for this screen
	for node in nodes:
		if node.is_user_accessible():
			return navigate_to(node.id, source)
	
	push_error("No accessible navigation node found for screen: " + screen_name)
	return false

## Go back in navigation history
func go_back() -> bool:
	if not _is_initialized:
		push_error("Navigation service not initialized")
		return false
	
	if not _current_state.can_go_back:
		push_error("Cannot go back - no navigation history")
		return false
	
	var previous_node_id = _current_state.navigation_stack[-1] if not _current_state.navigation_stack.is_empty() else ""
	var previous_node = _navigation_repository.get_node_by_id(previous_node_id)
	
	if not previous_node:
		push_error("Previous navigation node not found")
		return false
	
	# Emit back navigation event
	_emit_navigation_back(_current_state.current_node_id, previous_node_id, 
		_current_state.current_screen, previous_node.screen_name)
	
	# Update navigation state
	_current_state.go_back()
	_current_state.current_screen = previous_node.screen_name
	
	# Update breadcrumb path
	_update_breadcrumb_path()
	
	_log_navigation("Navigated back to: " + previous_node_id + " (" + previous_node.screen_name + ")")
	return true

## Open modal navigation
func open_modal(node_id: String) -> bool:
	if not _is_initialized:
		push_error("Navigation service not initialized")
		return false
	
	var modal_node = _navigation_repository.get_node_by_id(node_id)
	if not modal_node:
		push_error("Modal navigation node not found: " + node_id)
		return false
	
	if not modal_node.is_modal:
		push_error("Node is not configured as modal: " + node_id)
		return false
	
	# Emit modal opened event
	_emit_modal_opened(node_id, modal_node.screen_name, _current_state.current_node_id)
	
	# Update navigation state
	_current_state.open_modal(node_id)
	
	_log_navigation("Opened modal: " + node_id + " (" + modal_node.screen_name + ")")
	return true

## Close modal navigation
func close_modal() -> bool:
	if not _is_initialized:
		push_error("Navigation service not initialized")
		return false
	
	if not _current_state.is_modal_open:
		push_error("No modal is currently open")
		return false
	
	var modal_node = _navigation_repository.get_node_by_id(_current_state.modal_node_id)
	var modal_screen = modal_node.screen_name if modal_node else ""
	
	# Emit modal closed event
	_emit_modal_closed(_current_state.modal_node_id, modal_screen, _current_state.current_node_id)
	
	# Update navigation state
	_current_state.close_modal()
	
	_log_navigation("Closed modal: " + _current_state.modal_node_id)
	return true

## Get current navigation state
func get_current_state() -> NavigationState:
	return _current_state

## Get current navigation context
func get_navigation_context() -> Dictionary:
	return _current_state.get_navigation_context()

## Get breadcrumb path
func get_breadcrumb_path() -> Array[NavigationNode]:
	var path: Array[NavigationNode] = []
	for node_id in _current_state.breadcrumb_path:
		var node = _navigation_repository.get_node_by_id(node_id)
		if node:
			path.append(node)
	return path

## Get navigation tree
func get_navigation_tree() -> Dictionary:
	return _navigation_repository.get_navigation_tree()

## Get accessible navigation nodes
func get_accessible_nodes() -> Array[NavigationNode]:
	return _navigation_repository.get_accessible_nodes()

## Search navigation nodes
func search_nodes(query: String) -> Array[NavigationNode]:
	return _navigation_repository.search_nodes(query)

## Clear navigation history
func clear_history() -> void:
	var history_size = _current_state.navigation_stack.size()
	_current_state.clear_history()
	_emit_history_cleared(history_size, "user_request")
	_log_navigation("Navigation history cleared (" + str(history_size) + " entries)")

## Set navigation animation settings
func set_animation_settings(duration: float, animation_type: String = "slide") -> void:
	_default_animation_duration = duration
	_current_state.animation_duration = duration
	_current_state.animation_type = animation_type

## Get navigation statistics
func get_navigation_statistics() -> Dictionary:
	var repo_stats = _navigation_repository.get_navigation_statistics()
	var state_stats = _current_state.get_navigation_statistics()
	
	return {
		"repository": repo_stats,
		"state": state_stats,
		"service": {
			"is_initialized": _is_initialized,
			"default_animation_duration": _default_animation_duration,
			"max_navigation_depth": _max_navigation_depth,
			"enable_logging": _enable_navigation_logging
		}
	}

## Load default navigation nodes
func _load_default_navigation_nodes() -> void:
	_log_navigation("Loading default navigation nodes...")
	
	# Create default navigation structure
	var root_node = NavigationNode.new()
	root_node.title = "Main Menu"
	root_node.screen_name = "main_menu"
	root_node.depth = 0
	root_node.breadcrumb_title = "Home"
	
	_log_navigation("Adding root node: " + root_node.title)
	var add_result = _navigation_repository.add(root_node)
	if add_result:
		_log_navigation("Root node added successfully")
	else:
		_log_navigation("Failed to add root node")
	
	# Character management
	var character_node = NavigationNode.new()
	character_node.title = "Characters"
	character_node.screen_name = "characters"
	character_node.parent_id = root_node.id
	character_node.depth = 1
	character_node.icon_name = "character"
	_navigation_repository.add(character_node)
	
	# Quest management
	var quest_node = NavigationNode.new()
	quest_node.title = "Quests"
	quest_node.screen_name = "quests"
	quest_node.parent_id = root_node.id
	quest_node.depth = 1
	quest_node.icon_name = "quest"
	_navigation_repository.add(quest_node)
	
	# Guild management
	var guild_node = NavigationNode.new()
	guild_node.title = "Guild"
	guild_node.screen_name = "guild"
	guild_node.parent_id = root_node.id
	guild_node.depth = 1
	guild_node.icon_name = "guild"
	_navigation_repository.add(guild_node)
	
	# Settings
	var settings_node = NavigationNode.new()
	settings_node.title = "Settings"
	settings_node.screen_name = "settings"
	settings_node.parent_id = root_node.id
	settings_node.depth = 1
	settings_node.icon_name = "settings"
	_navigation_repository.add(settings_node)
	
	_log_navigation("Default navigation nodes loaded")

## Set initial navigation state
func _set_initial_navigation_state() -> void:
	var root_nodes = _navigation_repository.get_root_nodes()
	if not root_nodes.is_empty():
		var root_node = root_nodes[0]
		_current_state.navigate_to(root_node.id, "system")
		_current_state.current_screen = root_node.screen_name
		_update_breadcrumb_path()

## Update breadcrumb path
func _update_breadcrumb_path() -> void:
	var path = _navigation_repository.get_navigation_path(_current_state.current_node_id)
	var path_ids: Array[String] = []
	
	for node in path:
		path_ids.append(node.id)
	
	_current_state.breadcrumb_path = path_ids
	_emit_breadcrumb_updated(path_ids, _current_state.current_node_id, _current_state.navigation_depth)

## Event emission methods
func _emit_navigation_started(node_id: String, screen_name: String, source: String) -> void:
	if _event_bus:
		var event = NavigationEvents.NavigationStartedEvent.new(node_id, screen_name, source)
		_event_bus.emit_event(event)

func _emit_navigation_completed(node_id: String, screen_name: String, previous_screen: String, duration: float) -> void:
	if _event_bus:
		var event = NavigationEvents.NavigationCompletedEvent.new(node_id, screen_name, previous_screen, duration)
		_event_bus.emit_event(event)

func _emit_navigation_back(from_node: String, to_node: String, from_screen: String, to_screen: String) -> void:
	if _event_bus:
		var event = NavigationEvents.NavigationBackEvent.new(from_node, to_node, from_screen, to_screen)
		_event_bus.emit_event(event)

func _emit_navigation_failed(node_id: String, screen_name: String, reason: String) -> void:
	if _event_bus:
		var event = NavigationEvents.NavigationFailedEvent.new(node_id, screen_name, reason)
		_event_bus.emit_event(event)

func _emit_modal_opened(modal_node: String, modal_screen: String, parent_node: String) -> void:
	if _event_bus:
		var event = NavigationEvents.ModalNavigationOpenedEvent.new(modal_node, modal_screen, parent_node)
		_event_bus.emit_event(event)

func _emit_modal_closed(modal_node: String, modal_screen: String, return_node: String) -> void:
	if _event_bus:
		var event = NavigationEvents.ModalNavigationClosedEvent.new(modal_node, modal_screen, return_node)
		_event_bus.emit_event(event)

func _emit_breadcrumb_updated(path: Array[String], current_node: String, depth: int) -> void:
	if _event_bus:
		var event = NavigationEvents.BreadcrumbUpdatedEvent.new(path, current_node, depth)
		_event_bus.emit_event(event)

func _emit_history_cleared(count: int, reason: String) -> void:
	if _event_bus:
		var event = NavigationEvents.NavigationHistoryClearedEvent.new(count, reason)
		_event_bus.emit_event(event)

## Logging
func _log_navigation(message: String) -> void:
	if _enable_navigation_logging:
		print("[NavigationService] " + message)
