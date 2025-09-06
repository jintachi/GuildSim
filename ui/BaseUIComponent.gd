extends Control
class_name BaseUIComponent

## Base UI Component class for reusable UI elements
## Provides common functionality, theming, and event handling

signal component_ready
signal component_updated
signal component_error(error_message: String)

# Component state
var _is_initialized: bool = false
var _is_visible: bool = true
var _is_enabled: bool = true
var _component_id: String = ""

# Theme integration
var _theme_override: Theme
var _custom_styles: Dictionary = {}

# Animation settings
var _animation_duration: float = 0.2
var _animation_easing: Tween.EaseType = Tween.EASE_OUT
var _animation_transition: Tween.TransitionType = Tween.TRANS_CUBIC

# Event integration
var _event_bus: EventBus
var _subscribed_events: Array[String] = []

# ViewModel integration
var _view_model: BaseViewModel
var _data_bindings: Dictionary = {}

func _init():
	# Initialize base component properties
	_component_id = ""
	_is_initialized = false
	_is_visible = true
	_is_enabled = true
	_theme_override = null
	_animation_duration = 0.2
	_animation_easing = Tween.EASE_OUT
	_animation_transition = Tween.TRANS_CUBIC
	_event_bus = null
	_subscribed_events = []
	_view_model = null
	_data_bindings = {}
	_custom_styles = {}

func _ready():
	if not _is_initialized:
		_setup_component()


## Setup component (override in derived classes)
func _setup_component() -> void:
	# Apply theme
	_apply_theme()
	
	# Setup animations
	_setup_animations()
	
	# Setup event handling
	_setup_event_handling()

## Initialize component with dependencies
func initialize(event_bus: EventBus, view_model: BaseViewModel = null) -> void:
	_event_bus = event_bus
	_view_model = view_model
	
	if _view_model:
		_setup_data_bindings()
		_on_view_model_ready()
	
	_on_initialized()

## Check if component is initialized
func is_initialized() -> bool:
	return _is_initialized

## Set component visibility with animation
func set_visible_animated(should_be_visible: bool, duration: float = -1.0) -> void:
	if duration < 0:
		duration = _animation_duration
	
	_is_visible = should_be_visible
	
	if should_be_visible:
		show()
		_animate_fade_in(duration)
	else:
		_animate_fade_out(duration)

## Set component enabled state
func set_enabled_state(enabled: bool) -> void:
	_is_enabled = enabled
	modulate.a = 1.0 if enabled else 0.5
	
	# Disable input if not enabled
	mouse_filter = Control.MOUSE_FILTER_IGNORE if not enabled else Control.MOUSE_FILTER_PASS

## Apply theme to component
func _apply_theme() -> void:
	if _theme_override:
		theme = _theme_override
	
	# Apply custom styles
	for style_name in _custom_styles:
		_apply_custom_style(style_name, _custom_styles[style_name])

## Apply custom style
func _apply_custom_style(_style_name: String, _style: StyleBox) -> void:
	# Override in derived classes for specific style applications
	pass

## Setup animations
func _setup_animations() -> void:
	# Override in derived classes for specific animations
	pass

## Setup event handling
func _setup_event_handling() -> void:
	# Override in derived classes for specific event handling
	pass

## Setup data bindings with ViewModel
func _setup_data_bindings() -> void:
	if not _view_model:
		return
	
	# Override in derived classes for specific data bindings
	pass

## Handle initialization (override in derived classes)
func _on_initialized() -> void:
	# Override in derived classes
	_is_initialized = true
	component_ready.emit()
	pass

## Handle view model ready (override in derived classes)
## Called after view model is set and data bindings are established
func _on_view_model_ready() -> void:
	# Override in derived classes to perform view model-dependent setup
	pass

## Animate fade in
func _animate_fade_in(duration: float) -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
	tween.set_ease(_animation_easing)
	tween.set_trans(_animation_transition)

## Animate fade out
func _animate_fade_out(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.set_ease(_animation_easing)
	tween.set_trans(_animation_transition)
	tween.tween_callback(hide)

## Subscribe to an event
func _subscribe_to_event(event_type: String, callback: Callable) -> void:
	if _event_bus:
		_event_bus.subscribe(event_type, callback)
		_subscribed_events.append(event_type)

## Unsubscribe from an event
func _unsubscribe_from_event(event_type: String, callback: Callable) -> void:
	if _event_bus:
		_event_bus.unsubscribe(event_type, callback)
		_subscribed_events.erase(event_type)

## Set theme override
func set_theme_override(custom_theme: Theme) -> void:
	_theme_override = custom_theme
	_apply_theme()

## Add custom style
func add_custom_style(style_name: String, style: StyleBox) -> void:
	_custom_styles[style_name] = style
	_apply_custom_style(style_name, style)

## Remove custom style
func remove_custom_style(style_name: String) -> void:
	_custom_styles.erase(style_name)

## Set animation settings
func set_animation_settings(duration: float, easing: Tween.EaseType, transition: Tween.TransitionType) -> void:
	_animation_duration = duration
	_animation_easing = easing
	_animation_transition = transition

## Get component statistics
func get_component_statistics() -> Dictionary:
	return {
		"component_id": _component_id,
		"is_initialized": _is_initialized,
		"is_visible": _is_visible,
		"is_enabled": _is_enabled,
		"subscribed_events": _subscribed_events.size(),
		"data_bindings": _data_bindings.size(),
		"custom_styles": _custom_styles.size()
	}

## Clean up component
func cleanup() -> void:
	# Unsubscribe from all events
	if _event_bus:
		_event_bus.unsubscribe_all_for_object(self)
	
	_subscribed_events.clear()
	_data_bindings.clear()
	_custom_styles.clear()
	_is_initialized = false

## Handle component error
func _handle_error(error_message: String) -> void:
	component_error.emit(error_message)
	push_error("[%s] %s" % [_component_id, error_message])

## Update component (override in derived classes)
func update_component() -> void:
	component_updated.emit()

## Refresh component data
func refresh() -> void:
	if _view_model:
		_view_model.refresh()
	update_component()

## Validate component state
func validate() -> bool:
	return _is_initialized and is_inside_tree()

## Get component ID
func get_component_id() -> String:
	return _component_id

## Set component ID
func set_component_id(id: String) -> void:
	_component_id = id
	name = id
