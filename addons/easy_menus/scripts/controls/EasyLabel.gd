@tool
extends Label
class_name EasyLabel

# Properties
@export var responsive_text: bool = true
@export var max_font_size: int = 48
@export var min_font_size: int = 8
@export var reference_width: float = 400.0
@export var reference_font_size: int = 16

# Original font size
var _original_font_size: int = 16

func _ready():
	# Store the original font size
	if has_theme_font_size_override("font_size"):
		_original_font_size = get_theme_font_size("font_size")
	elif theme:
		_original_font_size = theme.get_font_size("font_size", "Label")
	else:
		_original_font_size = reference_font_size
	
	# Connect to resize signals
	resized.connect(_on_resized)
	
	# Initial scaling
	if responsive_text and not Engine.is_editor_hint():
		_scale_font_size()

# Scale the font size based on the current size
func _scale_font_size():
	if not responsive_text or not is_inside_tree():
		return
	
	# Get the parent size
	var parent = get_parent()
	if not parent:
		return
	
	# Load the TextScaler utility
	var text_scaler = load("res://addons/easy_menus/scripts/utils/TextScaler.gd")
	
	# Calculate the scale factor
	var scale_factor = size.x / reference_width
	
	# Calculate the new font size
	var new_font_size = int(_original_font_size * scale_factor)
	
	# Apply min/max constraints
	new_font_size = max(new_font_size, min_font_size)
	new_font_size = min(new_font_size, max_font_size)
	
	# Apply the new font size
	add_theme_font_size_override("font_size", new_font_size)

# Handle resize events
func _on_resized():
	if responsive_text and not Engine.is_editor_hint():
		_scale_font_size()

# Reset to original font size
func reset_font_size():
	if has_theme_font_size_override("font_size"):
		remove_theme_font_size_override("font_size")
