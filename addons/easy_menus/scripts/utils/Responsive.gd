extends Node

# Get the current viewport size
static func get_viewport_size() -> Vector2:
	return DisplayServer.window_get_size()

# Check if the current viewport width is less than or equal to a given width
static func is_width_less_than(width: int) -> bool:
	return get_viewport_size().x <= width

# Check if the current viewport height is less than or equal to a given height
static func is_height_less_than(height: int) -> bool:
	return get_viewport_size().y <= height

# Check if the current viewport is in portrait orientation
static func is_portrait() -> bool:
	var size = get_viewport_size()
	return size.y > size.x

# Check if the current viewport is in landscape orientation
static func is_landscape() -> bool:
	var size = get_viewport_size()
	return size.x >= size.y

# Get the current aspect ratio (width / height)
static func get_aspect_ratio() -> float:
	var size = get_viewport_size()
	if size.y == 0:
		return 1.0
	return size.x / size.y

# Find the appropriate breakpoint for the current viewport width
static func get_current_breakpoint(breakpoints: Array) -> Dictionary:
	var width = get_viewport_size().x
	
	# Sort breakpoints by max_width
	breakpoints.sort_custom(func(a, b): return a.max_width < b.max_width)
	
	# Find the first breakpoint that fits
	for breakpointer in breakpoints:
		if width <= breakpointer.max_width:
			return breakpointer
	
	# If no breakpoint fits, return the last one
	if breakpoints.size() > 0:
		return breakpoints[breakpoints.size() - 1]
	
	# Default fallback
	return {"name": "default", "max_width": 9999, "container_type": "VBox"}

# Scale a value based on the current viewport size
static func scale_value(base_value: float, base_width: float = 1920.0) -> float:
	var width = get_viewport_size().x
	return base_value * (width / base_width)

# Get a percentage of the viewport width
static func percent_of_width(percent: float) -> float:
	return get_viewport_size().x * (percent / 100.0)

# Get a percentage of the viewport height
static func percent_of_height(percent: float) -> float:
	return get_viewport_size().y * (percent / 100.0)
