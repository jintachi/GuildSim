extends BaseUIComponent
class_name NavigationTree

## Navigation tree component
## Displays hierarchical navigation structure

# UI elements
var _tree_container: VBoxContainer = null
var _tree_items: Dictionary = {}  # {node_id: TreeItem}
var _tree_buttons: Dictionary = {}  # {node_id: Button}

# Navigation data
var _navigation_tree: Dictionary = {}
var _current_node_id: String = ""

# ViewModel reference
var _navigation_view_model: NavigationViewModel = null

func _init():
	_component_id = "NavigationTree"

## Setup component
func _setup_component() -> void:
	super._setup_component()
	_create_ui_layout()
	

## Create UI layout
func _create_ui_layout() -> void:
	# Find UI elements from the already loaded scene
	_find_ui_elements()

## Find UI elements from the loaded scene
func _find_ui_elements() -> void:
	# Find UI elements by their node paths
	_tree_container = find_child("TreeContent", true, false)

## Update navigation tree
func _update_navigation_tree() -> void:
	# Check if UI layout is ready
	if not _tree_container:
		return
	
	# Check if view model is available
	if not _navigation_view_model:
		return
	
	# Clear existing tree
	_clear_tree()
	
	# Get navigation tree data
	var tree_data = _navigation_view_model.get_data("navigation_tree")
	if not tree_data:
		return
	
	_navigation_tree = tree_data
	
	# Build tree structure
	_build_tree_recursive(tree_data, 0)

## Clear navigation tree
func _clear_tree() -> void:
	for child in _tree_container.get_children():
		child.queue_free()
	_tree_items.clear()
	_tree_buttons.clear()

## Build tree recursively
func _build_tree_recursive(tree_data: Dictionary, depth: int) -> void:
	for node_id in tree_data:
		var node_data = tree_data[node_id]
		var node = node_data.get("node", null)
		
		if node and node is NavigationNode:
			_create_tree_item(node, depth)
			
			# Build children
			var children = node_data.get("children", {})
			if not children.is_empty():
				_build_tree_recursive(children, depth + 1)

## Create tree item
func _create_tree_item(node: NavigationNode, depth: int) -> void:
	# Create container for this tree item
	var item_container = HBoxContainer.new()
	item_container.add_theme_constant_override("separation", 5)
	
	# Add indentation based on depth
	var indent = Control.new()
	indent.custom_minimum_size = Vector2(depth * 20, 0)
	item_container.add_child(indent)
	
	# Create navigation button
	var button = Button.new()
	button.text = node.get_display_title()
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Style based on current selection
	if node.id == _current_node_id:
		button.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		button.add_theme_font_size_override("font_size", 16)
	else:
		button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		button.add_theme_font_size_override("font_size", 14)
	
	# Add icon if available
	if not node.icon_name.is_empty():
		button.text = "📁 " + button.text  # Simple icon placeholder
	
	# Connect button
	button.pressed.connect(_on_navigation_item_clicked.bind(node.id))
	button.tooltip_text = node.description if not node.description.is_empty() else node.title
	
	# Disable if not accessible
	if not node.is_user_accessible():
		button.disabled = true
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	item_container.add_child(button)
	_tree_container.add_child(item_container)
	
	# Store references
	_tree_buttons[node.id] = button

## Update current selection
func _update_current_selection() -> void:
	# Check if UI layout is ready
	if not _tree_buttons or _tree_buttons.is_empty():
		return
	
	# Check if view model is available
	if not _navigation_view_model:
		return
	
	var current_node = _navigation_view_model.get_data("current_node")
	if current_node:
		_current_node_id = current_node.id
	else:
		_current_node_id = ""
	
	# Update button styles
	for node_id in _tree_buttons:
		var button = _tree_buttons[node_id]
		if node_id == _current_node_id:
			button.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
			button.add_theme_font_size_override("font_size", 16)
		else:
			button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
			button.add_theme_font_size_override("font_size", 14)

## Handle initialization
func _on_initialized() -> void:
	_navigation_view_model = _view_model as NavigationViewModel
	#intentionally not calling super._on_initialized() as the super class has the "_is_initialized = true" line for all elements
	super._on_initialized()

## Handle view model ready
func _on_view_model_ready() -> void:
	super._on_view_model_ready()
	
	# Now that view model is available, update the navigation tree
	_update_navigation_tree()
	_update_current_selection()

## Set up data bindings with the view model
func _setup_data_bindings() -> void:
	if not _navigation_view_model:
		return
	
	# Connect to view model property changes
	_navigation_view_model.property_changed.connect(_on_view_model_property_changed)

## Handle view model property changes
func _on_view_model_property_changed(property_name: String, old_value: Variant, new_value: Variant) -> void:
	match property_name:
		"navigation_tree":
			_on_navigation_tree_changed(property_name, old_value, new_value)
		"current_node":
			_on_current_node_changed(property_name, old_value, new_value)
		"accessible_nodes":
			_on_accessible_nodes_changed(property_name, old_value, new_value)

## Event handlers
func _on_navigation_item_clicked(node_id: String) -> void:
	if _navigation_view_model:
		_navigation_view_model.navigate_to(node_id)

## Property change handlers
func _on_navigation_tree_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_navigation_tree()

func _on_current_node_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_current_selection()

func _on_accessible_nodes_changed(_property_name: String, _old_value: Variant, _new_value: Variant) -> void:
	_update_navigation_tree()

## Update component
func update_component() -> void:
	super.update_component()
	_update_navigation_tree()
	_update_current_selection()

## Refresh component data
func refresh() -> void:
	super.refresh()
	if _navigation_view_model:
		_navigation_view_model.refresh()
