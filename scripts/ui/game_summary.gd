extends CanvasLayer

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var result_label = $Panel/VBoxContainer/ResultLabel
@onready var seeds_planted_label = $Panel/VBoxContainer/StatsContainer/SeedsPlantedLabel
@onready var resources_label = $Panel/VBoxContainer/StatsContainer/ResourcesLabel
@onready var enemies_label = $Panel/VBoxContainer/StatsContainer/EnemiesLabel
@onready var bosses_label = $Panel/VBoxContainer/StatsContainer/BossesLabel
@onready var damage_label = $Panel/VBoxContainer/StatsContainer/DamageLabel

func _ready():
    # Make sure we're visible
    visible = true

func set_stats(victory: bool, stats: Dictionary):
    # Set result text
    if victory:
        result_label.text = "Victory! You've restored the Harmony Crystal!"
        result_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
    else:
        result_label.text = "Defeat... The Goblins have won."
        result_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
    
    # Set stats
    seeds_planted_label.text = "Seeds Planted: " + str(stats.get("seeds_planted", 0))
    resources_label.text = "Resources Gathered: " + str(stats.get("resources_gathered", 0))
    enemies_label.text = "Enemies Defeated: " + str(stats.get("enemies_defeated", 0))
    bosses_label.text = "Bosses Defeated: " + str(stats.get("bosses_defeated", 0))
    damage_label.text = "Damage Taken: " + str(stats.get("damage_taken", 0))

func _on_main_menu_button_pressed():
    # Return to main menu
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
    # Remove this summary scene
    queue_free()