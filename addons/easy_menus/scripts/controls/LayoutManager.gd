extends Node

# Signal emitted when the layout changes
signal layout_changed(breakpoint_name)

# Default breakpoints
var default_breakpoints = [
	{ "name": "mobile", "max_width": 640, "container_type": "VBox", "layout_size": "small" },
	{ "name": "tablet", "max_width": 1280, "container_type": "Grid", "layout_size": "default" },
	{ "name": "desktop", "max_width": 9999, "container_type": "HBox", "layout_size": "large" }
]

# Current breakpoints (can be overridden)
var breakpoints = []

# Current active breakpoint
var current_breakpoint = {}

# Parent control that this layout manager is managing
var parent_control = null

# Container nodes for each breakpoint type
var containers = {}

# Whether to automatically update on window resize
var auto_update = true

func _init(p_parent_control: Control, p_breakpoints = null):
	parent_control = p_parent_control

	# Use provided breakpoints or default ones
	breakpoints = p_breakpoints if p_breakpoints != null else default_breakpoints.duplicate(true)

func _ready():
	# Set up window resize connection
	_connect_to_viewport()

	# Create containers for each breakpoint
	_create_containers()

	# Initial update
	update_layout()

# Connect to the viewport's size_changed signal
func _connect_to_viewport():
	if is_inside_tree() and get_viewport():
		get_viewport().size_changed.connect(_on_window_resize)
	else:
		# If we can't connect now, try again after a short delay
		call_deferred("_connect_to_viewport")

# Create container nodes for each breakpoint type
func _create_containers():
	# Clear existing containers
	for container in containers.values():
		if is_instance_valid(container):
			container.queue_free()

	containers.clear()

	# Create new containers
	var container_types = _get_unique_container_types()

	for container_type in container_types:
		var container = _create_container_for_type(container_type)
		containers[container_type] = container
		parent_control.add_child(container)
		container.visible = false

# Get a list of unique container types from breakpoints
func _get_unique_container_types() -> Array:
	var types = []

	for i in range(breakpoints.size()):
		var breakpointer = breakpoints[i]
		if breakpointer.has("container_type"):
			if not types.has(breakpointer.container_type):
				types.append(breakpointer.container_type)

	return types

# Create a container node based on the container type
func _create_container_for_type(container_type: String) -> Container:
	match container_type:
		"VBox":
			var vbox = VBoxContainer.new()
			vbox.name = "VBoxContainer"
			vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			return vbox

		"HBox":
			var hbox = HBoxContainer.new()
			hbox.name = "HBoxContainer"
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			return hbox

		"Grid":
			var grid = GridContainer.new()
			grid.name = "GridContainer"
			grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
			grid.columns = 2
			return grid

		_:
			# Default to VBox if unknown type
			var vbox = VBoxContainer.new()
			vbox.name = "DefaultContainer"
			vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			return vbox

# Update the layout based on the current viewport size
func update_layout():
	# Check if we're in a valid state to update
	if not is_inside_tree() or not parent_control or not is_instance_valid(parent_control):
		return

	# Get the appropriate breakpoint for the current viewport size
	var new_breakpoint = preload("res://addons/easy_menus/scripts/utils/Responsive.gd").get_current_breakpoint(breakpoints)

	# If the breakpoint hasn't changed, do nothing
	if current_breakpoint.has("name") and new_breakpoint.name == current_breakpoint.name:
		return

	# Update current breakpoint
	current_breakpoint = new_breakpoint

	# Hide all containers
	for container in containers.values():
		if is_instance_valid(container):
			container.visible = false

	# Show the appropriate container
	var container_type = current_breakpoint.container_type
	if containers.has(container_type) and is_instance_valid(containers[container_type]):
		containers[container_type].visible = true

	# Apply layout size if specified in the breakpoint
	if current_breakpoint.has("layout_size") and parent_control.has_method("set_layout_size"):
		parent_control.set_layout_size(current_breakpoint.layout_size)

	# Emit signal
	emit_signal("layout_changed", current_breakpoint.name)

# Add a child to all containers
func add_child_to_containers(child: Control):
	# Store the original parent
	var original_parent = child.get_parent()

	# Remove from original parent if needed
	if original_parent:
		original_parent.remove_child(child)

	# Add to each container
	for container in containers.values():
		container.add_child(child.duplicate())

# Window resize handler
func _on_window_resize():
	if auto_update and is_inside_tree():
		update_layout()

# Set custom breakpoints
func set_breakpoints(new_breakpoints: Array):
	breakpoints = new_breakpoints

	# Recreate containers if needed
	var new_types = []
	for breakpoints in new_breakpoints:
		if "container_type" in breakpoints:
			new_types.append(breakpoints.container_type)

	var recreate_needed = false
	for type in new_types:
		if not containers.has(type):
			recreate_needed = true
			break

	if recreate_needed:
		_create_containers()

	# Update layout
	update_layout()

# Get the current breakpoint
func get_current_breakpoint() -> Dictionary:
	return current_breakpoint

# Get the container for the current breakpoint
func get_current_container() -> Container:
	var container_type = current_breakpoint.container_type
	if containers.has(container_type):
		return containers[container_type]
	return null

# Clean up when node exits the tree
func _exit_tree():
	# Disconnect from viewport if connected
	if is_inside_tree() and get_viewport() and get_viewport().is_connected("size_changed", _on_window_resize):
		get_viewport().size_changed.disconnect(_on_window_resize)
