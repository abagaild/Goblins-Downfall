extends Control

@export var display_time: float = 3.0
@export var main_menu_scene: String = "res://scenes/main_menu.tscn"

# Track if we've already started transitioning to avoid multiple calls
var _transitioning: bool = false

func _ready():
	# Create a timer to automatically transition to main menu
	var timer = Timer.new()
	timer.wait_time = display_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	
	# Connect input events to skip splash screen
	set_process_input(true)

func _input(event):
	if not _transitioning and (event is InputEventKey or event is InputEventMouseButton):
		if event.pressed:
			_change_to_main_menu()

func _on_timer_timeout():
	_change_to_main_menu()

func _change_to_main_menu():
	# Prevent multiple transitions
	if _transitioning:
		return
	
	_transitioning = true
	
	# Check if the main menu scene exists
	if ResourceLoader.exists(main_menu_scene):
		# Use change_scene_to_file for Godot 4.x
		get_tree().change_scene_to_file(main_menu_scene)
	else:
		push_error("Main menu scene not found: " + main_menu_scene)
		# Fallback to quitting if scene doesn't exist
		get_tree().quit()
