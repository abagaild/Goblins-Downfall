@tool
extends Control
class_name EasyMenu

# Signals
signal opened
signal closed
signal menu_resized

# Properties
@export var menu_name: String = ""
@export var register_with_manager: bool = true
@export var use_theme_manager: bool = true
@export var auto_center: bool = true
@export var default_visibility: bool = false
@export var default_open: bool = false

# Size constraints
@export_group("Size Constraints")
@export var use_size_constraints: bool = false
@export var min_size: Vector2 = Vector2(300, 200)
@export var max_size: Vector2 = Vector2(800, 600)
@export var default_size: Vector2 = Vector2(400, 300)
@export var scale_with_screen: bool = true
@export_range(0.0, 1.0, 0.01) var screen_size_percentage: float = 0.7
@export var floating_responsiveness: bool = false

# Text scaling
@export_group("Text Scaling")
@export var responsive_text: bool = true
@export var max_font_size: int = 48

# Layout sizes
@export_group("Layout Sizes")
@export var small_layout_size: Vector2 = Vector2(300, 200)
@export var default_layout_size: Vector2 = Vector2(400, 300)
@export var large_layout_size: Vector2 = Vector2(600, 500)

# Custom breakpoints for this menu
@export_group("Breakpoints")
@export var custom_breakpoints: Array = []

# Whether the menu is currently open
var is_open: bool = false

# Layout manager reference
var layout_manager = null

# Original reference sizes for text scaling
var _original_panel_size: Vector2 = Vector2.ZERO
var _original_font_sizes: Dictionary = {}

# Edge distances for floating responsiveness
var _edge_distances: Dictionary = {
	"left": 0.0,
	"right": 0.0,
	"top": 0.0,
	"bottom": 0.0,
	"width_percent": 0.0,
	"height_percent": 0.0
}

func _ready():
	# Set up layout manager
	layout_manager = load("res://addons/easy_menus/scripts/controls/LayoutManager.gd").new(self, custom_breakpoints if custom_breakpoints.size() > 0 else null)
	add_child(layout_manager)

	# Connect to layout manager signals
	layout_manager.layout_changed.connect(_on_layout_changed)

	# Apply theme if using theme manager
	if use_theme_manager and Engine.is_editor_hint() == false:
		var theme_manager = load("res://addons/easy_menus/scripts/controls/ThemeManager.gd").new()
		theme = theme_manager.get_current_theme()
		theme_manager.theme_changed.connect(_on_theme_changed)

	# Register with menu manager if needed
	if register_with_manager and menu_name != "" and Engine.is_editor_hint() == false:
		if Engine.has_singleton("MenuManager"):
			var menu_manager = Engine.get_singleton("MenuManager")
			menu_manager.register_menu(menu_name, self)

	# Initial visibility
	if not Engine.is_editor_hint():
		visible = default_visibility
		is_open = default_open

	# Store original panel size for text scaling reference
	var panel = find_child("Panel", false, false)
	if panel:
		_original_panel_size = panel.size

	# Store original font sizes for all text elements
	_store_original_font_sizes()

	# Connect to window resize signal and resized signal
	if not Engine.is_editor_hint():
		get_viewport().size_changed.connect(_on_viewport_size_changed)
		resized.connect(_on_resized)

	# Apply size constraints if enabled
	if use_size_constraints and not Engine.is_editor_hint():
		# Set initial size to default size
		custom_minimum_size = min_size

		# Apply size constraints - this will handle auto-centering and screen scaling
		_apply_size_constraints()
	else:
		# Center the menu if needed but not using size constraints
		if auto_center:
			anchor_left = 0.5
			anchor_top = 0.5
			anchor_right = 0.5
			anchor_bottom = 0.5
			offset_left = -size.x / 2
			offset_top = -size.y / 2
			offset_right = size.x / 2
			offset_bottom = size.y / 2

	# Calculate initial edge distances for floating responsiveness
	if floating_responsiveness and not Engine.is_editor_hint():
		# Wait two frames to ensure the menu is properly positioned and sized
		await get_tree().process_frame
		await get_tree().process_frame
		_calculate_edge_distances()
		print("Initial edge distances calculated in _ready")

	# Initial text scaling - do this AFTER positioning
	if responsive_text and not Engine.is_editor_hint():
		_scale_text_elements()

	# Initial visibility
	if not Engine.is_editor_hint():
		visible = default_visibility
		is_open = default_open

# Open the menu
func open():
	if is_open:
		return

	visible = true
	is_open = true

	# Print debug info
	print("Opening menu")

	# Apply size constraints if enabled - this will handle positioning and text scaling
	if use_size_constraints:
		# If using floating responsiveness, calculate edge distances first
		if floating_responsiveness:
			_calculate_edge_distances()

		# Then apply size constraints
		_apply_size_constraints()
	elif responsive_text:
		# If not using size constraints but still want responsive text
		_scale_text_elements()

	# Update layout
	if layout_manager:
		layout_manager.update_layout()

	emit_signal("opened")

# Close the menu
func close():
	if not is_open:
		return

	visible = false
	is_open = false

	emit_signal("closed")

# Toggle the menu
func toggle():
	if is_open:
		close()
	else:
		open()

# Check if the menu is open
func get_is_open() -> bool:
	return is_open

# Called when the layout changes
func _on_layout_changed(breakpoint_name: String):
	# Override this in subclasses to handle layout changes
	pass

# Called when the theme changes
func _on_theme_changed(theme_name: String):
	if use_theme_manager:
		var theme_manager = load("res://addons/easy_menus/scripts/controls/ThemeManager.gd").new()
		theme = theme_manager.get_theme(theme_name)

# Called when the menu is resized directly
func _on_resized():
	if not use_size_constraints or Engine.is_editor_hint():
		return

	# Print debug info
	print("Menu resized directly")

	# If using floating responsiveness, recalculate edge distances
	if floating_responsiveness:
		_recalculate_edge_distances()
		return

	# Apply size constraints
	_apply_size_constraints()

	# Scale text if responsive text is enabled
	if responsive_text:
		_scale_text_elements()

	# Emit signal
	emit_signal("menu_resized")

# Recalculate edge distances without changing the menu's current position
func _recalculate_edge_distances():
	if not is_inside_tree() or Engine.is_editor_hint():
		return

	var viewport_size = get_viewport_rect().size
	var menu_rect = Rect2(global_position, size)

	# Calculate distances from each edge as percentages of screen size
	_edge_distances["left"] = menu_rect.position.x / viewport_size.x
	_edge_distances["top"] = menu_rect.position.y / viewport_size.y
	_edge_distances["right"] = (viewport_size.x - (menu_rect.position.x + menu_rect.size.x)) / viewport_size.x
	_edge_distances["bottom"] = (viewport_size.y - (menu_rect.position.y + menu_rect.size.y)) / viewport_size.y

	# Also store the size as a percentage of the viewport
	_edge_distances["width_percent"] = menu_rect.size.x / viewport_size.x
	_edge_distances["height_percent"] = menu_rect.size.y / viewport_size.y

	# Print debug info
	print("Edge distances recalculated: ", _edge_distances)

# Store original font sizes for all text elements
func _store_original_font_sizes() -> void:
	_original_font_sizes.clear()

	# Find all Labels and Buttons in the menu
	var text_elements = _find_all_text_elements(self)

	# Store their original font sizes
	for element in text_elements:
		var node_path = get_path_to(element)
		var font_size = 16  # Default fallback

		if element is Label:
			if element.has_theme_font_size_override("font_size"):
				font_size = element.get_theme_font_size("font_size")
			elif element.theme:
				font_size = element.theme.get_font_size("font_size", "Label")

			# Also store it directly on the element for easier access
			if not element.has_meta("original_font_size"):
				element.set_meta("original_font_size", font_size)

		elif element is Button:
			if element.has_theme_font_size_override("font_size"):
				font_size = element.get_theme_font_size("font_size")
			elif element.theme:
				font_size = element.theme.get_font_size("font_size", "Button")

			# Also store it directly on the element for easier access
			if not element.has_meta("original_font_size"):
				element.set_meta("original_font_size", font_size)

		_original_font_sizes[node_path] = font_size

# Find all text elements (Labels and Buttons) in a container
func _find_all_text_elements(container: Control) -> Array:
	var elements = []

	for child in container.get_children():
		if child is Label or child is Button:
			elements.append(child)
		elif child is Container or child is Control:
			# Recursively search in containers
			elements.append_array(_find_all_text_elements(child))

	return elements

# Calculate and store the distances from each edge of the screen
func _calculate_edge_distances() -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return

	var viewport_size = get_viewport_rect().size
	var menu_rect = Rect2(global_position, size)

	# Calculate distances from each edge as percentages of screen size
	_edge_distances["left"] = menu_rect.position.x / viewport_size.x
	_edge_distances["top"] = menu_rect.position.y / viewport_size.y
	_edge_distances["right"] = (viewport_size.x - (menu_rect.position.x + menu_rect.size.x)) / viewport_size.x
	_edge_distances["bottom"] = (viewport_size.y - (menu_rect.position.y + menu_rect.size.y)) / viewport_size.y

	# Also store the size as a percentage of the viewport
	_edge_distances["width_percent"] = menu_rect.size.x / viewport_size.x
	_edge_distances["height_percent"] = menu_rect.size.y / viewport_size.y

	# Print debug info
	print("Edge distances calculated: ", _edge_distances)

# Scale all text elements based on the current size
func _scale_text_elements() -> void:
	if not responsive_text or Engine.is_editor_hint():
		return

	# Get the panel (main container)
	var panel = find_child("Panel", false, false)
	if not panel:
		return

	# If we don't have the original panel size yet, store it
	if _original_panel_size == Vector2.ZERO and panel.size != Vector2.ZERO:
		_original_panel_size = panel.size
	elif _original_panel_size == Vector2.ZERO:
		# Can't scale without a reference size
		return

	# Load the TextScaler utility
	var text_scaler = load("res://addons/easy_menus/scripts/utils/TextScaler.gd")

	# Scale all text elements in the panel
	text_scaler.scale_container_text(panel, _original_panel_size, max_font_size)

# Handle viewport size changes
func _on_viewport_size_changed() -> void:
	if not use_size_constraints or Engine.is_editor_hint():
		return

	# Print debug info
	print("Viewport size changed")

	# Apply size constraints - this will handle positioning and sizing
	_apply_size_constraints()

	# Scale text if responsive text is enabled
	if responsive_text:
		_scale_text_elements()

	# Emit signal
	emit_signal("menu_resized")

# Apply size constraints based on viewport size
func _apply_size_constraints() -> void:
	if not use_size_constraints or Engine.is_editor_hint():
		return

	# Get the viewport size
	var viewport_size = get_viewport_rect().size

	# Store the original size and position
	var original_size = size
	var original_position = position
	var original_global_position = global_position

	# Handle floating responsiveness
	if floating_responsiveness:
		# If edge distances haven't been calculated yet, do it now
		if _edge_distances["left"] == 0 and _edge_distances["right"] == 0 and _edge_distances["top"] == 0 and _edge_distances["bottom"] == 0:
			_calculate_edge_distances()
			return  # Return after initial calculation to avoid jumps

		# Calculate new size based on viewport and stored percentages
		var new_size = Vector2(
			viewport_size.x * _edge_distances["width_percent"],
			viewport_size.y * _edge_distances["height_percent"]
		)

		# Apply minimum size
		new_size.x = max(new_size.x, min_size.x)
		new_size.y = max(new_size.y, min_size.y)

		# Apply maximum size
		new_size.x = min(new_size.x, max_size.x)
		new_size.y = min(new_size.y, max_size.y)

		# Also ensure the size doesn't exceed the viewport
		new_size.x = min(new_size.x, viewport_size.x * 0.95)
		new_size.y = min(new_size.y, viewport_size.y * 0.95)

		# Calculate new position based on edge distances
		# We need to maintain the left and top edge distances
		var new_left = viewport_size.x * _edge_distances["left"]
		var new_top = viewport_size.y * _edge_distances["top"]

		# Apply the new size and position
		size = new_size
		global_position = Vector2(new_left, new_top)

		# Use anchors to maintain position during further resizing
		anchor_left = 0
		anchor_top = 0
		anchor_right = 0
		anchor_bottom = 0

		# Print debug info
		print("Floating responsive resize: ", {
			"viewport_size": viewport_size,
			"new_size": new_size,
			"new_position": global_position
		})

		return

	# Handle standard scaling (non-floating)
	var target_size = Vector2.ZERO
	if scale_with_screen:
		# Calculate size as a percentage of the screen
		var screen_percentage_size = Vector2(
			viewport_size.x * screen_size_percentage,
			viewport_size.y * screen_size_percentage
		)

		# Maintain aspect ratio based on default_size
		var aspect_ratio = default_size.x / default_size.y
		if screen_percentage_size.x / screen_percentage_size.y > aspect_ratio:
			# Width is the limiting factor
			screen_percentage_size.x = screen_percentage_size.y * aspect_ratio
		else:
			# Height is the limiting factor
			screen_percentage_size.y = screen_percentage_size.x / aspect_ratio

		target_size = screen_percentage_size
	else:
		# Use the current size
		target_size = size

	# Apply minimum size
	target_size.x = max(target_size.x, min_size.x)
	target_size.y = max(target_size.y, min_size.y)

	# Apply maximum size
	target_size.x = min(target_size.x, max_size.x)
	target_size.y = min(target_size.y, max_size.y)

	# Also ensure the size doesn't exceed the viewport
	target_size.x = min(target_size.x, viewport_size.x * 0.95)
	target_size.y = min(target_size.y, viewport_size.y * 0.95)

	# Apply the new size
	size = target_size

	# Update the position based on the selected positioning method
	if auto_center:
		# For centered menus, use anchors for perfect centering
		anchor_left = 0.5
		anchor_top = 0.5
		anchor_right = 0.5
		anchor_bottom = 0.5
		offset_left = -size.x / 2
		offset_top = -size.y / 2
		offset_right = size.x / 2
		offset_bottom = size.y / 2
	else:
		# For standard non-centered menus, maintain the exact same relative position
		# Calculate the menu's relative position in the viewport
		var relative_position = Vector2(
			original_global_position.x / viewport_size.x,
			original_global_position.y / viewport_size.y
		)

		# Calculate the new global position based on the stored relative position
		var new_global_position = Vector2(
			viewport_size.x * relative_position.x,
			viewport_size.y * relative_position.y
		)

		# Apply the new global position
		global_position = new_global_position

		# Use anchors to maintain position during further resizing
		anchor_left = 0
		anchor_top = 0
		anchor_right = 0
		anchor_bottom = 0

# Set the menu to a specific layout size
func set_layout_size(layout_name: String) -> void:
	if Engine.is_editor_hint():
		return

	# Print debug info
	print("Setting layout size: ", layout_name)

	# Determine the new size based on layout name
	var new_size = default_layout_size
	match layout_name:
		"small":
			new_size = small_layout_size
		"default":
			new_size = default_layout_size
		"large":
			new_size = large_layout_size

	# Store the viewport size
	var viewport_size = get_viewport_rect().size

	if floating_responsiveness:
		# If edge distances haven't been calculated yet, do it now
		if _edge_distances["left"] == 0 and _edge_distances["right"] == 0 and _edge_distances["top"] == 0 and _edge_distances["bottom"] == 0:
			# Apply the new size first
			size = new_size
			# Then calculate edge distances
			_calculate_edge_distances()
		else:
			# Apply the new size
			size = new_size

			# Recalculate the width and height percentages
			_edge_distances["width_percent"] = size.x / viewport_size.x
			_edge_distances["height_percent"] = size.y / viewport_size.y

			# Update position based on edge distances
			global_position = Vector2(
				viewport_size.x * _edge_distances["left"],
				viewport_size.y * _edge_distances["top"]
			)

			# Print debug info
			print("Floating responsive layout change: ", {
				"new_size": size,
				"new_position": global_position,
				"edge_distances": _edge_distances
			})
	else:
		# Apply the new size
		size = new_size

		# Apply constraints - this will handle positioning
		if use_size_constraints:
			_apply_size_constraints()
		else:
			# If not using size constraints, handle positioning manually
			if auto_center:
				# For centered menus, use anchors for perfect centering
				anchor_left = 0.5
				anchor_top = 0.5
				anchor_right = 0.5
				anchor_bottom = 0.5
				offset_left = -size.x / 2
				offset_top = -size.y / 2
				offset_right = size.x / 2
				offset_bottom = size.y / 2

	# Scale text if responsive text is enabled
	if responsive_text:
		_scale_text_elements()

	# Emit signal
	emit_signal("menu_resized")

# Called when the node is about to be removed from the scene
func _exit_tree():
	# Disconnect from window resize signal
	if use_size_constraints and not Engine.is_editor_hint():
		var viewport = get_viewport()
		if viewport and viewport.is_connected("size_changed", _on_viewport_size_changed):
			viewport.size_changed.disconnect(_on_viewport_size_changed)

	# Disconnect from resized signal
	if is_connected("resized", _on_resized):
		disconnect("resized", _on_resized)

	# Unregister from menu manager
	if register_with_manager and menu_name != "" and Engine.is_editor_hint() == false:
		if Engine.has_singleton("MenuManager"):
			var menu_manager = Engine.get_singleton("MenuManager")
			menu_manager.unregister_menu(menu_name)
