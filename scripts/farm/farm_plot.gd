extends Node2D
class_name FarmPlot

# Plot states
enum PlotState {EMPTY, GROWING, HARVESTABLE}
var current_state = PlotState.EMPTY

# References
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var click_area = $ClickArea

# Textures for different states
@export var empty_texture: Texture2D
@export var growing_texture: Texture2D
@export var harvestable_texture: Texture2D

# Signals
signal plot_clicked(plot)

func _ready():
    # Connect click detection
    click_area.input_event.connect(_on_input_event)
    
    # Set initial state
    set_state("empty")

func _on_input_event(_viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        emit_signal("plot_clicked", self)

func set_state(state_name: String):
    match state_name:
        "empty":
            current_state = PlotState.EMPTY
            sprite.texture = empty_texture
            if animation_player.has_animation("idle"):
                animation_player.play("idle")
        
        "growing":
            current_state = PlotState.GROWING
            sprite.texture = growing_texture
            if animation_player.has_animation("growing"):
                animation_player.play("growing")
        
        "harvestable":
            current_state = PlotState.HARVESTABLE
            sprite.texture = harvestable_texture
            if animation_player.has_animation("harvestable"):
                animation_player.play("harvestable")