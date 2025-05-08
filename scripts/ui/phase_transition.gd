extends CanvasLayer

@onready var label = $Label
@onready var timer = $Timer

func _ready():
    # Hide by default
    visible = false

func show_transition(phase_name: String):
    # Set the phase name
    label.text = phase_name
    
    # Show the transition
    visible = true
    
    # Start the timer
    timer.start()

func _on_timer_timeout():
    # Hide the transition
    visible = false