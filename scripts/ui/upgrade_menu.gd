extends Control
class_name UpgradeMenu

# References to farm manager for resource access
var farm_manager

# Upgrade costs and levels
var upgrades = {
    "farm": {
        "plot": {
            "level": 0,
            "max_level": 3,
            "base_cost": 50,
            "cost_multiplier": 1.5
        },
        "yield": {
            "level": 0,
            "max_level": 5,
            "base_cost": 30,
            "cost_multiplier": 1.3
        },
        "growth": {
            "level": 0,
            "max_level": 5,
            "base_cost": 25,
            "cost_multiplier": 1.3
        }
    },
    "plants": {
        "grounding": {
            "unlocked": false,
            "cost": 40
        },
        "mindfulness": {
            "unlocked": false,
            "cost": 45
        },
        "compassion": {
            "unlocked": false,
            "cost": 50
        }
    },
    "combat": {
        "health": {
            "level": 0,
            "max_level": 5,
            "base_cost": 20,
            "cost_multiplier": 1.2
        },
        "dodge": {
            "level": 0,
            "max_level": 3,
            "base_cost": 35,
            "cost_multiplier": 1.4
        },
        "balance": {
            "level": 0,
            "max_level": 3,
            "base_cost": 40,
            "cost_multiplier": 1.5
        }
    }
}

# UI references
@onready var plot_upgrade_button = $Panel/TabContainer/Farm/VBoxContainer/PlotUpgrade/Button
@onready var plot_upgrade_cost = $Panel/TabContainer/Farm/VBoxContainer/PlotUpgrade/Cost
@onready var yield_upgrade_button = $Panel/TabContainer/Farm/VBoxContainer/YieldUpgrade/Button
@onready var yield_upgrade_cost = $Panel/TabContainer/Farm/VBoxContainer/YieldUpgrade/Cost
@onready var growth_upgrade_button = $Panel/TabContainer/Farm/VBoxContainer/GrowthUpgrade/Button
@onready var growth_upgrade_cost = $Panel/TabContainer/Farm/VBoxContainer/GrowthUpgrade/Cost

@onready var grounding_plant_button = $Panel/TabContainer/Plants/VBoxContainer/GroundingPlant/Button
@onready var grounding_plant_cost = $Panel/TabContainer/Plants/VBoxContainer/GroundingPlant/Cost
@onready var mindfulness_plant_button = $Panel/TabContainer/Plants/VBoxContainer/MindfulnessPlant/Button
@onready var mindfulness_plant_cost = $Panel/TabContainer/Plants/VBoxContainer/MindfulnessPlant/Cost
@onready var compassion_plant_button = $Panel/TabContainer/Plants/VBoxContainer/CompassionPlant/Button
@onready var compassion_plant_cost = $Panel/TabContainer/Plants/VBoxContainer/CompassionPlant/Cost

@onready var health_upgrade_button = $Panel/TabContainer/Combat/VBoxContainer/HealthUpgrade/Button
@onready var health_upgrade_cost = $Panel/TabContainer/Combat/VBoxContainer/HealthUpgrade/Cost
@onready var dodge_upgrade_button = $Panel/TabContainer/Combat/VBoxContainer/DodgeUpgrade/Button
@onready var dodge_upgrade_cost = $Panel/TabContainer/Combat/VBoxContainer/DodgeUpgrade/Cost
@onready var balance_upgrade_button = $Panel/TabContainer/Combat/VBoxContainer/BalanceUpgrade/Button
@onready var balance_upgrade_cost = $Panel/TabContainer/Combat/VBoxContainer/BalanceUpgrade/Cost

func _ready():
    # Find farm manager
    farm_manager = get_tree().get_nodes_in_group("farm_manager")[0]
    
    # Connect button signals
    plot_upgrade_button.pressed.connect(_on_plot_upgrade_pressed)
    yield_upgrade_button.pressed.connect(_on_yield_upgrade_pressed)
    growth_upgrade_button.pressed.connect(_on_growth_upgrade_pressed)
    
    grounding_plant_button.pressed.connect(_on_grounding_plant_pressed)
    mindfulness_plant_button.pressed.connect(_on_mindfulness_plant_pressed)
    compassion_plant_button.pressed.connect(_on_compassion_plant_pressed)
    
    health_upgrade_button.pressed.connect(_on_health_upgrade_pressed)
    dodge_upgrade_button.pressed.connect(_on_dodge_upgrade_pressed)
    balance_upgrade_button.pressed.connect(_on_balance_upgrade_pressed)
    
    # Update UI
    update_ui()
    
    # Hide menu initially
    visible = false

func update_ui():
    # Update farm upgrades
    update_upgrade_ui("farm", "plot", plot_upgrade_button, plot_upgrade_cost)
    update_upgrade_ui("farm", "yield", yield_upgrade_button, yield_upgrade_cost)
    update_upgrade_ui("farm", "growth", growth_upgrade_button, growth_upgrade_cost)
    
    # Update plant unlocks
    update_unlock_ui("plants", "grounding", grounding_plant_button, grounding_plant_cost)
    update_unlock_ui("plants", "mindfulness", mindfulness_plant_button, mindfulness_plant_cost)
    update_unlock_ui("plants", "compassion", compassion_plant_button, compassion_plant_cost)
    
    # Update combat upgrades
    update_upgrade_ui("combat", "health", health_upgrade_button, health_upgrade_cost)
    update_upgrade_ui("combat", "dodge", dodge_upgrade_button, dodge_upgrade_cost)
    update_upgrade_ui("combat", "balance", balance_upgrade_button, balance_upgrade_cost)

func update_upgrade_ui(category, upgrade_name, button, cost_label):
    var upgrade = upgrades[category][upgrade_name]
    var current_level = upgrade["level"]
    var max_level = upgrade["max_level"]
    
    if current_level >= max_level:
        button.text = "Maxed"
        button.disabled = true
        cost_label.text = "Max Level"
    else:
        var next_cost = calculate_upgrade_cost(category, upgrade_name)
        button.text = "Upgrade"
        button.disabled = farm_manager.upgrade_points < next_cost
        cost_label.text = "Cost: " + str(next_cost)

func update_unlock_ui(category, upgrade_name, button, cost_label):
    var upgrade = upgrades[category][upgrade_name]
    
    if upgrade["unlocked"]:
        button.text = "Unlocked"
        button.disabled = true
        cost_label.text = "Unlocked"
    else:
        var cost = upgrade["cost"]
        button.text = "Unlock"
        button.disabled = farm_manager.upgrade_points < cost
        cost_label.text = "Cost: " + str(cost)

func calculate_upgrade_cost(category, upgrade_name):
    var upgrade = upgrades[category][upgrade_name]
    var base_cost = upgrade["base_cost"]
    var multiplier = upgrade["cost_multiplier"]
    var level = upgrade["level"]
    
    return floor(base_cost * pow(multiplier, level))

func _on_plot_upgrade_pressed():
    purchase_upgrade("farm", "plot")
    
    # Apply gameplay effect - add a new plot
    if farm_manager.has_method("add_farm_plot"):
        farm_manager.add_farm_plot()

func _on_yield_upgrade_pressed():
    purchase_upgrade("farm", "yield")
    
    # Apply gameplay effect - increase yield
    if farm_manager.has_method("increase_yield"):
        farm_manager.increase_yield(0.25)

func _on_growth_upgrade_pressed():
    purchase_upgrade("farm", "growth")
    
    # Apply gameplay effect - decrease growth time
    if farm_manager.has_method("decrease_growth_time"):
        farm_manager.decrease_growth_time(0.2)

func _on_grounding_plant_pressed():
    purchase_unlock("plants", "grounding")
    
    # Apply gameplay effect - unlock grounding plant
    if farm_manager.has_method("unlock_plant"):
        farm_manager.unlock_plant("grounding")

func _on_mindfulness_plant_pressed():
    purchase_unlock("plants", "mindfulness")
    
    # Apply gameplay effect - unlock mindfulness plant
    if farm_manager.has_method("unlock_plant"):
        farm_manager.unlock_plant("mindfulness")

func _on_compassion_plant_pressed():
    purchase_unlock("plants", "compassion")
    
    # Apply gameplay effect - unlock compassion plant
    if farm_manager.has_method("unlock_plant"):
        farm_manager.unlock_plant("compassion")

func _on_health_upgrade_pressed():
    purchase_upgrade("combat", "health")
    
    # Apply gameplay effect - increase health
    var player = get_tree().get_nodes_in_group("player")
    if player.size() > 0 and player[0].has_method("increase_max_health"):
        player[0].increase_max_health(10)

func _on_dodge_upgrade_pressed():
    purchase_upgrade("combat", "dodge")
    
    # Apply gameplay effect - increase dodge window
    var player = get_tree().get_nodes_in_group("player")
    if player.size() > 0 and player[0].has_method("increase_dodge_window"):
        player[0].increase_dodge_window(0.15)

func _on_balance_upgrade_pressed():
    purchase_upgrade("combat", "balance")
    
    # Apply gameplay effect - increase balance gauge
    var player = get_tree().get_nodes_in_group("player")
    if player.size() > 0 and player[0].has_method("increase_balance_gauge"):
        player[0].increase_balance_gauge(0.2)

func purchase_upgrade(category, upgrade_name):
    var upgrade = upgrades[category][upgrade_name]
    var cost = calculate_upgrade_cost(category, upgrade_name)
    
    if farm_manager.upgrade_points >= cost:
        # Deduct points
        farm_manager.upgrade_points -= cost
        farm_manager.emit_signal("resources_changed", farm_manager.hope_seeds, farm_manager.upgrade_points, farm_manager.sun_resource)
        
        # Increase level
        upgrade["level"] += 1
        
        # Update UI
        update_ui()

func purchase_unlock(category, upgrade_name):
    var upgrade = upgrades[category][upgrade_name]
    var cost = upgrade["cost"]
    
    if farm_manager.upgrade_points >= cost:
        # Deduct points
        farm_manager.upgrade_points -= cost
        farm_manager.emit_signal("resources_changed", farm_manager.hope_seeds, farm_manager.upgrade_points, farm_manager.sun_resource)
        
        # Unlock
        upgrade["unlocked"] = true
        
        # Update UI
        update_ui()

func _on_close_button_pressed():
    visible = false

func open():
    update_ui()
    visible = true

func close():
    visible = false