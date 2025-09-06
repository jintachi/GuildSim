class_name NavigationEvents

## Navigation-related events for the event system
## Provides typed events for navigation state changes

## Base navigation event
class NavigationEvent extends BaseEvent:
	var navigation_data: Dictionary = {}
	
	func _init(nav_event_type: String, nav_data: Dictionary = {}):
		super._init(nav_event_type)
		navigation_data = nav_data

## Navigation started event
class NavigationStartedEvent extends NavigationEvent:
	var node_id: String
	var screen_name: String
	var nav_source: String
	
	func _init(target_node_id: String, target_screen: String, nav_source_param: String = "user"):
		var event_data = {
			"node_id": target_node_id,
			"screen_name": target_screen,
			"source": nav_source_param,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_started", event_data)
		node_id = target_node_id
		screen_name = target_screen
		nav_source = nav_source_param

## Navigation completed event
class NavigationCompletedEvent extends NavigationEvent:
	var node_id: String
	var screen_name: String
	var previous_screen: String
	var duration: float
	
	func _init(target_node_id: String, target_screen: String, prev_screen: String, nav_duration: float):
		var event_data = {
			"node_id": target_node_id,
			"screen_name": target_screen,
			"previous_screen": prev_screen,
			"duration": nav_duration,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_completed", event_data)
		node_id = target_node_id
		screen_name = target_screen
		previous_screen = prev_screen
		duration = nav_duration

## Navigation back event
class NavigationBackEvent extends NavigationEvent:
	var from_node_id: String
	var to_node_id: String
	var from_screen: String
	var to_screen: String
	
	func _init(from_node: String, to_node: String, from_screen_name: String, to_screen_name: String):
		var event_data = {
			"from_node_id": from_node,
			"to_node_id": to_node,
			"from_screen": from_screen_name,
			"to_screen": to_screen_name,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_back", event_data)
		from_node_id = from_node
		to_node_id = to_node
		from_screen = from_screen_name
		to_screen = to_screen_name

## Navigation failed event
class NavigationFailedEvent extends NavigationEvent:
	var attempted_node_id: String
	var attempted_screen: String
	var reason: String
	var error_code: String
	
	func _init(node_id: String, screen_name: String, failure_reason: String, code: String = ""):
		var event_data = {
			"attempted_node_id": node_id,
			"attempted_screen": screen_name,
			"reason": failure_reason,
			"error_code": code,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_failed", event_data)
		attempted_node_id = node_id
		attempted_screen = screen_name
		reason = failure_reason
		error_code = code

## Modal navigation opened event
class ModalNavigationOpenedEvent extends NavigationEvent:
	var modal_node_id: String
	var modal_screen: String
	var parent_node_id: String
	
	func _init(modal_node: String, modal_screen_name: String, parent_node: String):
		var event_data = {
			"modal_node_id": modal_node,
			"modal_screen": modal_screen_name,
			"parent_node_id": parent_node,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("modal_navigation_opened", event_data)
		modal_node_id = modal_node
		modal_screen = modal_screen_name
		parent_node_id = parent_node

## Modal navigation closed event
class ModalNavigationClosedEvent extends NavigationEvent:
	var modal_node_id: String
	var modal_screen: String
	var return_node_id: String
	
	func _init(modal_node: String, modal_screen_name: String, return_node: String):
		var event_data = {
			"modal_node_id": modal_node,
			"modal_screen": modal_screen_name,
			"return_node_id": return_node,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("modal_navigation_closed", event_data)
		modal_node_id = modal_node
		modal_screen = modal_screen_name
		return_node_id = return_node

## Navigation state changed event
class NavigationStateChangedEvent extends NavigationEvent:
	var old_state: NavigationState
	var new_state: NavigationState
	var change_type: String
	
	func _init(old_nav_state: NavigationState, new_nav_state: NavigationState, change: String):
		var event_data = {
			"old_state": old_nav_state,
			"new_state": new_nav_state,
			"change_type": change,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_state_changed", event_data)
		old_state = old_nav_state
		new_state = new_nav_state
		change_type = change

## Breadcrumb updated event
class BreadcrumbUpdatedEvent extends NavigationEvent:
	var breadcrumb_path: Array[String]
	var current_node_id: String
	var depth: int
	
	func _init(path: Array[String], current_node: String, nav_depth: int):
		var event_data = {
			"breadcrumb_path": path,
			"current_node_id": current_node,
			"depth": nav_depth,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("breadcrumb_updated", event_data)
		breadcrumb_path = path
		current_node_id = current_node
		depth = nav_depth

## Navigation history cleared event
class NavigationHistoryClearedEvent extends NavigationEvent:
	var cleared_count: int
	var reason: String
	
	func _init(count: int, clear_reason: String = "user_request"):
		var event_data = {
			"cleared_count": count,
			"reason": clear_reason,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_history_cleared", event_data)
		cleared_count = count
		reason = clear_reason

## Navigation permission denied event
class NavigationPermissionDeniedEvent extends NavigationEvent:
	var attempted_node_id: String
	var attempted_screen: String
	var required_permission: String
	var user_permissions: Array[String]
	
	func _init(node_id: String, screen_name: String, permission: String, user_perms: Array[String]):
		var event_data = {
			"attempted_node_id": node_id,
			"attempted_screen": screen_name,
			"required_permission": permission,
			"user_permissions": user_perms,
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_permission_denied", event_data)
		attempted_node_id = node_id
		attempted_screen = screen_name
		required_permission = permission
		user_permissions = user_perms

## Navigation tree toggle event
class NavigationTreeToggleEvent extends NavigationEvent:
	func _init():
		var event_data = {
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_tree_toggle", event_data)

## Navigation close event
class NavigationCloseEvent extends NavigationEvent:
	func _init():
		var event_data = {
			"timestamp": Time.get_unix_time_from_system()
		}
		super._init("navigation_close", event_data)
