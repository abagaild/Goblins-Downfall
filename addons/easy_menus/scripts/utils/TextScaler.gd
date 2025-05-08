extends Node

# Utility class for scaling text in UI elements

# Scale a label's font size to maintain its percentage fill of the parent container
static func scale_label_font_size(label: Label, reference_size: Vector2, max_font_size: int = -1) -> void:
	if not is_instance_valid(label) or not label.is_inside_tree():
		return

	var parent = label.get_parent()
	if not is_instance_valid(parent):
		return

	var parent_size = parent.size
	if parent_size.x <= 0 or parent_size.y <= 0:
		return

	# Store the original font size if not already stored
	if not label.has_meta("original_font_size"):
		var original_size = 16  # Default fallback
		if label.has_theme_font_size_override("font_size"):
			original_size = label.get_theme_font_size("font_size")
		elif label.theme:
			original_size = label.theme.get_font_size("font_size", "Label")
		label.set_meta("original_font_size", original_size)

	# Get the original font size
	var original_font_size = label.get_meta("original_font_size")

	# Calculate the scale factor based on the smaller dimension
	var scale_x = parent_size.x / reference_size.x
	var scale_y = parent_size.y / reference_size.y
	var scale_factor = max(scale_x, scale_y)  # Use MAX instead of MIN to make text larger

	# Calculate the new font size based on the original size
	var new_font_size = int(original_font_size * scale_factor)

	# Apply max font size limit if specified
	if max_font_size > 0 and new_font_size > max_font_size:
		new_font_size = max_font_size

	# Apply the new font size
	label.add_theme_font_size_override("font_size", new_font_size)

# Scale a button's font size to maintain its percentage fill
static func scale_button_font_size(button: Button, reference_size: Vector2, max_font_size: int = -1) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return

	var parent = button.get_parent()
	if not is_instance_valid(parent):
		return

	var parent_size = parent.size
	if parent_size.x <= 0 or parent_size.y <= 0:
		return

	# Store the original font size if not already stored
	if not button.has_meta("original_font_size"):
		var original_size = 16  # Default fallback
		if button.has_theme_font_size_override("font_size"):
			original_size = button.get_theme_font_size("font_size")
		elif button.theme:
			original_size = button.theme.get_font_size("font_size", "Button")
		button.set_meta("original_font_size", original_size)

	# Get the original font size
	var original_font_size = button.get_meta("original_font_size")

	# Calculate the scale factor based on the smaller dimension
	var scale_x = parent_size.x / reference_size.x
	var scale_y = parent_size.y / reference_size.y
	var scale_factor = max(scale_x, scale_y)  # Use MAX instead of MIN to make text larger

	# Calculate the new font size based on the original size
	var new_font_size = int(original_font_size * scale_factor)

	# Apply max font size limit if specified
	if max_font_size > 0 and new_font_size > max_font_size:
		new_font_size = max_font_size

	# Apply the new font size
	button.add_theme_font_size_override("font_size", new_font_size)

# Scale all text elements in a container recursively
static func scale_container_text(container: Control, reference_size: Vector2, max_font_size: int = -1) -> void:
	if not is_instance_valid(container) or not container.is_inside_tree():
		return

	# Process all children
	for child in container.get_children():
		if child is Label:
			scale_label_font_size(child, reference_size, max_font_size)
		elif child is Button:
			scale_button_font_size(child, reference_size, max_font_size)
		elif child is Container or child is Control:
			# Recursively process containers
			scale_container_text(child, reference_size, max_font_size)

# Get the optimal font size for a text to fit within a given width
static func get_optimal_font_size(text: String, font: Font, max_width: float, min_size: int = 8, max_size: int = 72) -> int:
	var size = max_size

	while size > min_size:
		var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if text_width <= max_width:
			break
		size -= 1

	return size

# Calculate a font size that maintains the same text-to-container ratio
static func maintain_text_ratio(control: Control, original_size: Vector2, original_font_size: int, max_font_size: int = -1) -> int:
	if not is_instance_valid(control) or not control.is_inside_tree():
		return original_font_size

	var current_size = control.size
	if current_size.x <= 0 or current_size.y <= 0:
		return original_font_size

	# Calculate the scale factor based on the smaller dimension
	var scale_x = current_size.x / original_size.x
	var scale_y = current_size.y / original_size.y
	var scale_factor = min(scale_x, scale_y)

	# Calculate the new font size
	var new_font_size = int(original_font_size * scale_factor)

	# Apply max font size limit if specified
	if max_font_size > 0 and new_font_size > max_font_size:
		new_font_size = max_font_size

	return new_font_size
