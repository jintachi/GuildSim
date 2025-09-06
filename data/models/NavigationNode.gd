class_name NavigationNode
extends Resource

## Data model for navigation nodes
## Represents a single navigation point in the UI hierarchy

#region Core Properties
@export var id: String
@export var title: String
@export var description: String = ""
@export var icon_name: String = ""
@export var screen_name: String = ""
@export var parent_id: String = ""
@export var depth: int = 0
#endregion

#region Navigation Properties
@export var is_accessible: bool = true
@export var requires_permission: String = ""
@export var is_modal: bool = false
@export var can_go_back: bool = true
@export var breadcrumb_title: String = ""
#endregion

#region UI Properties
@export var ui_scale: float = 1.0
@export var background_color: Color = Color.TRANSPARENT
@export var custom_theme: String = ""
@export var animation_type: String = "slide"
@export var animation_duration: float = 0.3
#endregion

#region Metadata
@export var created_timestamp: float = 0.0
@export var last_accessed: float = 0.0
@export var access_count: int = 0
@export var tags: Array[String] = []
#endregion

func _init():
	id = generate_unique_id()
	created_timestamp = Time.get_unix_time_from_system()
	breadcrumb_title = title

## Generate a unique identifier for this navigation node
func generate_unique_id() -> String:
	return "nav_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

## Get display title (breadcrumb title if available, otherwise title)
func get_display_title() -> String:
	return breadcrumb_title if not breadcrumb_title.is_empty() else title

## Check if this node is a root node
func is_root() -> bool:
	return parent_id.is_empty()

## Check if this node is accessible to the user
func is_user_accessible() -> bool:
	if not is_accessible:
		return false
	
	# Check permission requirements
	if not requires_permission.is_empty():
		# This would integrate with a permission system
		# For now, assume all permissions are granted
		pass
	
	return true

## Get navigation path as array of node IDs
func get_navigation_path() -> Array[String]:
	var path: Array[String] = []
	var current_id = id
	
	while not current_id.is_empty():
		path.push_front(current_id)
		# This would need to be resolved by the navigation service
		# For now, return just this node
		break
	
	return path

## Update access statistics
func record_access() -> void:
	last_accessed = Time.get_unix_time_from_system()
	access_count += 1

## Get property value by name
func get_data(property_name: String) -> Variant:
	match property_name:
		"id": return id
		"title": return title
		"description": return description
		"icon_name": return icon_name
		"screen_name": return screen_name
		"parent_id": return parent_id
		"depth": return depth
		"is_accessible": return is_accessible
		"requires_permission": return requires_permission
		"is_modal": return is_modal
		"can_go_back": return can_go_back
		"breadcrumb_title": return breadcrumb_title
		"ui_scale": return ui_scale
		"background_color": return background_color
		"custom_theme": return custom_theme
		"animation_type": return animation_type
		"animation_duration": return animation_duration
		"created_timestamp": return created_timestamp
		"last_accessed": return last_accessed
		"access_count": return access_count
		"tags": return tags
		_: return null

## Set property value by name
func set_data(property_name: String, value: Variant) -> void:
	match property_name:
		"id": id = value
		"title": title = value
		"description": description = value
		"icon_name": icon_name = value
		"screen_name": screen_name = value
		"parent_id": parent_id = value
		"depth": depth = value
		"is_accessible": is_accessible = value
		"requires_permission": requires_permission = value
		"is_modal": is_modal = value
		"can_go_back": can_go_back = value
		"breadcrumb_title": breadcrumb_title = value
		"ui_scale": ui_scale = value
		"background_color": background_color = value
		"custom_theme": custom_theme = value
		"animation_type": animation_type = value
		"animation_duration": animation_duration = value
		"created_timestamp": created_timestamp = value
		"last_accessed": last_accessed = value
		"access_count": access_count = value
		"tags": tags = value

## Validate navigation node data integrity
func validate() -> bool:
	if id.is_empty() or title.is_empty() or screen_name.is_empty():
		return false
	
	if depth < 0:
		return false
	
	if ui_scale <= 0.0:
		return false
	
	if animation_duration < 0.0:
		return false
	
	return true
