extends Node

# This script handles input configuration and setup

func _ready():
	# Set up default input actions if they don't exist
	_setup_default_inputs()

func _setup_default_inputs():
	# Movement inputs
	_add_input_action_if_not_exists("move_up", KEY_W, KEY_UP)
	_add_input_action_if_not_exists("move_down", KEY_S, KEY_DOWN)
	_add_input_action_if_not_exists("move_left", KEY_A, KEY_LEFT)
	_add_input_action_if_not_exists("move_right", KEY_D, KEY_RIGHT)
	
	# Action inputs
	_add_input_action_if_not_exists("attack", KEY_SPACE, MOUSE_BUTTON_LEFT)
	_add_input_action_if_not_exists("interact", KEY_E, KEY_ENTER)
	_add_input_action_if_not_exists("dodge", KEY_SHIFT, MOUSE_BUTTON_RIGHT)
	
	# UI inputs
	_add_input_action_if_not_exists("pause", KEY_ESCAPE, KEY_P)
	_add_input_action_if_not_exists("inventory", KEY_I, KEY_TAB)

func _add_input_action_if_not_exists(action_name, primary_key, secondary_key = -1):
	if not InputMap.has_action(action_name):
		# Create new action
		InputMap.add_action(action_name)
		
		# Add primary key event
		var primary_event = InputEventKey.new()
		primary_event.keycode = primary_key
		InputMap.action_add_event(action_name, primary_event)
		
		# Add secondary key event if provided
		if secondary_key != -1:
			var secondary_event = InputEventKey.new()
			secondary_event.keycode = secondary_key
			InputMap.action_add_event(action_name, secondary_event)

# Function to save input configuration (can be expanded later)
func save_input_config():
	# This would save the current input configuration to a file
	pass

# Function to load input configuration (can be expanded later)
func load_input_config():
	# This would load a saved input configuration from a file
	pass
