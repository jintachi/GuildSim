class_name NavigationState
extends Resource

## Data model for navigation state
## Tracks current navigation position, history, and context

#region Current Navigation
@export var current_node_id: String = ""
@export var current_screen: String = ""
@export var navigation_depth: int = 0
@export var is_modal_open: bool = false
@export var modal_node_id: String = ""
#endregion

#region Navigation History
@export var navigation_stack: Array[String] = []
@export var breadcrumb_path: Array[String] = []
@export var max_history_size: int = 50
@export var can_go_back: bool = false
@export var can_go_forward: bool = false
#endregion

#region Navigation Context
@export var previous_screen: String = ""
@export var navigation_source: String = ""  # "user", "system", "auto"
@export var navigation_timestamp: float = 0.0
@export var navigation_count: int = 0
#endregion

#region UI State
@export var is_animating: bool = false
@export var animation_type: String = "slide"
@export var animation_duration: float = 0.3
@export var ui_scale: float = 1.0
@export var is_fullscreen: bool = false
#endregion

#region Metadata
@export var session_id: String = ""
@export var created_timestamp: float = 0.0
@export var last_updated: float = 0.0
#endregion

func _init():
	session_id = generate_session_id()
	created_timestamp = Time.get_unix_time_from_system()
	last_updated = created_timestamp

## Generate a unique session identifier
func generate_session_id() -> String:
	return "nav_session_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Navigate to a new node
func navigate_to(node_id: String, source: String = "user") -> void:
	# Add current node to history if it exists
	if not current_node_id.is_empty():
		_add_to_history(current_node_id)
	
	# Update current navigation
	previous_screen = current_screen
	current_node_id = node_id
	navigation_source = source
	navigation_timestamp = Time.get_unix_time_from_system()
	navigation_count += 1
	last_updated = navigation_timestamp
	
	# Update navigation state
	_update_navigation_state()

## Go back in navigation history
func go_back() -> bool:
	if not can_go_back or navigation_stack.is_empty():
		return false
	
	# Get the previous node
	var previous_node_id = navigation_stack.pop_back()
	
	# Update current navigation
	previous_screen = current_screen
	current_node_id = previous_node_id
	navigation_source = "back"
	navigation_timestamp = Time.get_unix_time_from_system()
	last_updated = navigation_timestamp
	
	# Update navigation state
	_update_navigation_state()
	
	return true

## Go forward in navigation history (if available)
func go_forward() -> bool:
	# Forward navigation would require a separate forward stack
	# For now, we'll implement a simple version
	return false

## Open a modal navigation node
func open_modal(node_id: String) -> void:
	modal_node_id = node_id
	is_modal_open = true
	navigation_timestamp = Time.get_unix_time_from_system()
	last_updated = navigation_timestamp

## Close modal navigation
func close_modal() -> void:
	modal_node_id = ""
	is_modal_open = false
	navigation_timestamp = Time.get_unix_time_from_system()
	last_updated = navigation_timestamp

## Clear navigation history
func clear_history() -> void:
	navigation_stack.clear()
	breadcrumb_path.clear()
	can_go_back = false
	can_go_forward = false

## Add node to navigation history
func _add_to_history(node_id: String) -> void:
	# Add to stack
	navigation_stack.append(node_id)
	
	# Limit history size
	if navigation_stack.size() > max_history_size:
		navigation_stack.pop_front()
	
	# Update breadcrumb path
	_update_breadcrumb_path()

## Update breadcrumb path
func _update_breadcrumb_path() -> void:
	# This would be populated by the navigation service
	# based on the actual navigation hierarchy
	breadcrumb_path = navigation_stack.duplicate()

## Update navigation state flags
func _update_navigation_state() -> void:
	can_go_back = not navigation_stack.is_empty()
	can_go_forward = false  # Not implemented yet
	navigation_depth = navigation_stack.size()

## Get current navigation context
func get_navigation_context() -> Dictionary:
	return {
		"current_node_id": current_node_id,
		"current_screen": current_screen,
		"previous_screen": previous_screen,
		"navigation_depth": navigation_depth,
		"can_go_back": can_go_back,
		"can_go_forward": can_go_forward,
		"is_modal_open": is_modal_open,
		"modal_node_id": modal_node_id,
		"navigation_source": navigation_source,
		"navigation_count": navigation_count,
		"breadcrumb_path": breadcrumb_path.duplicate()
	}

## Get navigation statistics
func get_navigation_statistics() -> Dictionary:
	return {
		"session_id": session_id,
		"navigation_count": navigation_count,
		"history_size": navigation_stack.size(),
		"max_history_size": max_history_size,
		"current_depth": navigation_depth,
		"session_duration": Time.get_unix_time_from_system() - created_timestamp,
		"last_updated": last_updated
	}

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"current_node_id": return current_node_id
		"current_screen": return current_screen
		"navigation_depth": return navigation_depth
		"is_modal_open": return is_modal_open
		"modal_node_id": return modal_node_id
		"navigation_stack": return navigation_stack
		"breadcrumb_path": return breadcrumb_path
		"max_history_size": return max_history_size
		"can_go_back": return can_go_back
		"can_go_forward": return can_go_forward
		"previous_screen": return previous_screen
		"navigation_source": return navigation_source
		"navigation_timestamp": return navigation_timestamp
		"navigation_count": return navigation_count
		"is_animating": return is_animating
		"animation_type": return animation_type
		"animation_duration": return animation_duration
		"ui_scale": return ui_scale
		"is_fullscreen": return is_fullscreen
		"session_id": return session_id
		"created_timestamp": return created_timestamp
		"last_updated": return last_updated
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"current_node_id": current_node_id = value
		"current_screen": current_screen = value
		"navigation_depth": navigation_depth = value
		"is_modal_open": is_modal_open = value
		"modal_node_id": modal_node_id = value
		"navigation_stack": navigation_stack = value
		"breadcrumb_path": breadcrumb_path = value
		"max_history_size": max_history_size = value
		"can_go_back": can_go_back = value
		"can_go_forward": can_go_forward = value
		"previous_screen": previous_screen = value
		"navigation_source": navigation_source = value
		"navigation_timestamp": navigation_timestamp = value
		"navigation_count": navigation_count = value
		"is_animating": is_animating = value
		"animation_type": animation_type = value
		"animation_duration": animation_duration = value
		"ui_scale": ui_scale = value
		"is_fullscreen": is_fullscreen = value
		"session_id": session_id = value
		"created_timestamp": created_timestamp = value
		"last_updated": last_updated = value

## Validate navigation state data integrity
func validate() -> bool:
	if session_id.is_empty():
		return false
	
	if navigation_depth < 0:
		return false
	
	if max_history_size <= 0:
		return false
	
	if animation_duration < 0.0:
		return false
	
	if ui_scale <= 0.0:
		return false
	
	return true
