@tool
extends Button
class_name EasyButton

# Action types
enum ActionType {
	NONE,
	CHANGE_SCENE,
	OPEN_URL,
	TOGGLE_MENU,
	OPEN_MENU,
	CLOSE_MENU,
	QUIT_GAME,
	CUSTOM
}

# Properties
@export var action_type: ActionType = ActionType.NONE
@export var target: String = ""
@export var custom_signal: String = ""
@export var transition_effect: bool = true
@export var transition_time: float = 0.3

# Signal for custom actions
signal custom_action_triggered

func _ready():
	# Connect pressed signal
	pressed.connect(_on_button_pressed)
	
	# Apply default styling if in a game (not editor)
	if not Engine.is_editor_hint():
		# Add hover effect
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)

# Handle button press
func _on_button_pressed():
	match action_type:
		ActionType.CHANGE_SCENE:
			_change_scene()
		
		ActionType.OPEN_URL:
			_open_url()
		
		ActionType.TOGGLE_MENU:
			_toggle_menu()
		
		ActionType.OPEN_MENU:
			_open_menu()
		
		ActionType.CLOSE_MENU:
			_close_menu()
		
		ActionType.QUIT_GAME:
			_quit_game()
		
		ActionType.CUSTOM:
			_trigger_custom_action()

# Change scene action
func _change_scene():
	if target.is_empty():
		push_error("EasyButton: Cannot change scene - target is empty")
		return
	
	if transition_effect:
		# Create a simple transition effect
		var transition = ColorRect.new()
		transition.color = Color(0, 0, 0, 0)
		transition.anchors_preset = Control.PRESET_FULL_RECT
		get_tree().root.add_child(transition)
		
		var tween = create_tween()
		tween.tween_property(transition, "color", Color(0, 0, 0, 1), transition_time)
		tween.tween_callback(func(): get_tree().change_scene_to_file(target))
		tween.tween_property(transition, "color", Color(0, 0, 0, 0), transition_time)
		tween.tween_callback(func(): transition.queue_free())
	else:
		get_tree().change_scene_to_file(target)

# Open URL action
func _open_url():
	if target.is_empty():
		push_error("EasyButton: Cannot open URL - target is empty")
		return
	
	OS.shell_open(target)

# Toggle menu action
func _toggle_menu():
	if target.is_empty():
		push_error("EasyButton: Cannot toggle menu - target menu name is empty")
		return
	
	if Engine.has_singleton("MenuManager"):
		var menu_manager = Engine.get_singleton("MenuManager")
		menu_manager.toggle_menu(target)
	else:
		push_error("EasyButton: MenuManager singleton not found")

# Open menu action
func _open_menu():
	if target.is_empty():
		push_error("EasyButton: Cannot open menu - target menu name is empty")
		return
	
	if Engine.has_singleton("MenuManager"):
		var menu_manager = Engine.get_singleton("MenuManager")
		menu_manager.open_menu(target)
	else:
		push_error("EasyButton: MenuManager singleton not found")

# Close menu action
func _close_menu():
	if target.is_empty():
		push_error("EasyButton: Cannot close menu - target menu name is empty")
		return
	
	if Engine.has_singleton("MenuManager"):
		var menu_manager = Engine.get_singleton("MenuManager")
		menu_manager.close_menu(target)
	else:
		push_error("EasyButton: MenuManager singleton not found")

# Quit game action
func _quit_game():
	get_tree().quit()

# Trigger custom action
func _trigger_custom_action():
	emit_signal("custom_action_triggered")
	
	# Also emit the custom signal if specified
	if not custom_signal.is_empty():
		emit_signal(custom_signal)

# Mouse hover effects
func _on_mouse_entered():
	if transition_effect:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	if transition_effect:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
