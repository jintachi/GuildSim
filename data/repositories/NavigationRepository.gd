class_name NavigationRepository
extends BaseRepository

## Repository for Navigation entities
## Handles navigation data persistence and retrieval

func _init(save_system: SaveSystem = null, event_bus: EventBus = null):
	super._init(save_system, event_bus)

## Get repository name for save/load
func get_repository_name() -> String:
	return "navigation"

## Initialize default data
func _initialize_default_data() -> void:
	# Create default navigation nodes
	var default_nodes = [
		_create_default_node("characters", "Characters", "Manage your guild members"),
		_create_default_node("quests", "Quests", "Browse and manage available quests"),
		_create_default_node("guild", "Guild", "Manage your guild facilities and resources"),
		_create_default_node("settings", "Settings", "Game configuration and options")
	]
	
	for node in default_nodes:
		if node.validate():
			add(node)

## Create a default navigation node
func _create_default_node(id: String, title: String, description: String) -> NavigationNode:
	var node = NavigationNode.new()
	node.id = id
	node.title = title
	node.description = description
	node.screen_name = id
	node.is_accessible = true
	node.parent_id = ""
	
	return node

## Get all navigation nodes
func get_all_nodes() -> Array[NavigationNode]:
	var nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode:
			nodes.append(node as NavigationNode)
	return nodes

## Get navigation node by ID
func get_node_by_id(node_id: String) -> NavigationNode:
	for node in _data:
		if node is NavigationNode and node.id == node_id:
			return node as NavigationNode
	return null

## Get navigation nodes by screen name
func get_nodes_by_screen(screen_name: String) -> Array[NavigationNode]:
	var nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.screen_name == screen_name:
			nodes.append(node as NavigationNode)
	return nodes

## Get root navigation nodes (no parent)
func get_root_nodes() -> Array[NavigationNode]:
	var root_nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.is_root():
			root_nodes.append(node as NavigationNode)
	return root_nodes

## Get child nodes of a parent
func get_child_nodes(parent_id: String) -> Array[NavigationNode]:
	var child_nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.parent_id == parent_id:
			child_nodes.append(node as NavigationNode)
	return child_nodes

## Get accessible navigation nodes
func get_accessible_nodes() -> Array[NavigationNode]:
	var accessible_nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.is_user_accessible():
			accessible_nodes.append(node as NavigationNode)
	return accessible_nodes

## Get navigation nodes by tag
func get_nodes_by_tag(tag: String) -> Array[NavigationNode]:
	var tagged_nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and tag in node.tags:
			tagged_nodes.append(node as NavigationNode)
	return tagged_nodes

## Get navigation hierarchy as tree structure
func get_navigation_tree() -> Dictionary:
	var tree: Dictionary = {}
	var root_nodes = get_root_nodes()
	
	for root_node in root_nodes:
		tree[root_node.id] = _build_node_tree(root_node)
	
	return tree

## Build tree structure for a node and its children
func _build_node_tree(node: NavigationNode) -> Dictionary:
	var node_data = {
		"node": node,
		"children": {}
	}
	
	var children = get_child_nodes(node.id)
	for child in children:
		node_data.children[child.id] = _build_node_tree(child)
	
	return node_data

## Get navigation path from root to target node
func get_navigation_path(target_node_id: String) -> Array[NavigationNode]:
	var path: Array[NavigationNode] = []
	var current_node = get_node_by_id(target_node_id)
	
	while current_node:
		path.push_front(current_node)
		if current_node.is_root():
			break
		current_node = get_node_by_id(current_node.parent_id)
	
	return path

## Get navigation statistics
func get_navigation_statistics() -> Dictionary:
	var stats = {
		"total_nodes": 0,
		"root_nodes": 0,
		"accessible_nodes": 0,
		"modal_nodes": 0,
		"by_depth": {},
		"by_screen": {},
		"by_tag": {},
		"most_accessed": [],
		"recently_accessed": []
	}
	
	var all_nodes = get_all_nodes()
	stats.total_nodes = all_nodes.size()
	
	var access_counts: Array = []
	var recent_access: Array = []
	
	for node in all_nodes:
		# Count by type
		if node.is_root():
			stats.root_nodes += 1
		if node.is_user_accessible():
			stats.accessible_nodes += 1
		if node.is_modal:
			stats.modal_nodes += 1
		
		# Count by depth
		var depth = str(node.depth)
		stats.by_depth[depth] = stats.by_depth.get(depth, 0) + 1
		
		# Count by screen
		stats.by_screen[node.screen_name] = stats.by_screen.get(node.screen_name, 0) + 1
		
		# Count by tags
		for tag in node.tags:
			stats.by_tag[tag] = stats.by_tag.get(tag, 0) + 1
		
		# Track access statistics
		access_counts.append({"node": node, "count": node.access_count})
		recent_access.append({"node": node, "timestamp": node.last_accessed})
	
	# Sort by access count
	access_counts.sort_custom(func(a, b): return a.count > b.count)
	stats.most_accessed = access_counts.slice(0, 5)
	
	# Sort by recent access
	recent_access.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	stats.recently_accessed = recent_access.slice(0, 5)
	
	return stats

## Search navigation nodes
func search_nodes(query: String) -> Array[NavigationNode]:
	var results: Array[NavigationNode] = []
	var search_terms = query.to_lower().split(" ")
	
	for node in _data:
		if node is NavigationNode:
			var node_text = (node.title + " " + node.description + " " + node.screen_name).to_lower()
			var matches = true
			
			for term in search_terms:
				if not term in node_text:
					matches = false
					break
			
			if matches:
				results.append(node as NavigationNode)
	
	return results

## Get navigation nodes by permission requirement
func get_nodes_by_permission(permission: String) -> Array[NavigationNode]:
	var nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.requires_permission == permission:
			nodes.append(node as NavigationNode)
	return nodes

## Get navigation nodes by animation type
func get_nodes_by_animation_type(animation_type: String) -> Array[NavigationNode]:
	var nodes: Array[NavigationNode] = []
	for node in _data:
		if node is NavigationNode and node.animation_type == animation_type:
			nodes.append(node as NavigationNode)
	return nodes

## Override entity added to emit events
func _on_entity_added(entity: Variant) -> void:
	if entity is NavigationNode:
		var event = NavigationEvents.NavigationStartedEvent.new(entity.id, entity.screen_name, "system")
		_event_bus.emit_event(event)

## Override entity updated to emit events
func _on_entity_updated(entity: Variant) -> void:
	if entity is NavigationNode:
		# Record access if this is a navigation update
		entity.record_access()
		
		var event = NavigationEvents.NavigationStateChangedEvent.new(null, null, "node_updated")
		_event_bus.emit_event(event)
