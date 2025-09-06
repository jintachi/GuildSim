extends Control

## Simple Map UI component
## Just a panel where you can manually add room buttons

signal room_selected(room_name: String)

# Room buttons (you'll add these manually in the scene)
var room_buttons: Array[Button] = []

func _ready():
	# Find all buttons in this scene and connect them
	_find_and_connect_room_buttons()

## Find all buttons and connect them to room selection
func _find_and_connect_room_buttons():
	room_buttons.clear()
	_find_buttons_recursive(self)

## Recursively find all buttons in the scene tree
func _find_buttons_recursive(node: Node):
	if node is Button:
		var button = node as Button
		room_buttons.append(button)
		button.pressed.connect(_on_room_button_pressed.bind(button.text))
	
	for child in node.get_children():
		_find_buttons_recursive(child)

## Handle room button press
func _on_room_button_pressed(room_name: String):
	room_selected.emit(room_name)
	print("Room selected: " + room_name)

## Add a room button programmatically (if needed)
func add_room_button(room_name: String, position: Vector2 = Vector2.ZERO) -> Button:
	var button = Button.new()
	button.text = room_name
	button.position = position
	button.size = Vector2(100, 50)
	add_child(button)
	
	button.pressed.connect(_on_room_button_pressed.bind(room_name))
	room_buttons.append(button)
	
	return button

## Get all available rooms
func get_available_rooms() -> Array[String]:
	var rooms: Array[String] = []
	for button in room_buttons:
		rooms.append(button.text)
	return rooms
