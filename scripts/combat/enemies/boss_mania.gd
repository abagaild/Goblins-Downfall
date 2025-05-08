extends EnemyBase
class_name ManiaBoss

# Boss-specific properties
var energy_level = 1.0
var attack_multiplier = 1.0

func _ready():
    super._ready()
    
    # Set up boss stats
    enemy_name = "Mania"  # Changed from name to enemy_name
    max_health = 250.0
    current_health = max_health
    attack_power = 12.0
    defense = 5.0
    is_boss = true
    
    # Boss-specific attacks
    attacks = ["energy_surge", "racing_thoughts", "impulsive_burst"]
    
    emit_signal("health_changed", current_health, max_health)

func _process(delta):
    # Mania's energy increases over time
    if energy_level < 3.0:
        energy_level += delta * 0.05
        attack_multiplier = 1.0 + (energy_level - 1.0) * 0.5

func choose_attack():
    # Attacks based on energy level
    if energy_level > 2.5:
        current_attack = "manic_episode"
        energy_level = 1.0
    elif energy_level > 1.8:
        var options = ["racing_thoughts", "impulsive_burst"]
        current_attack = options[randi() % options.size()]
    else:
        var options = ["energy_surge", "racing_thoughts"]
        current_attack = options[randi() % options.size()]
    
    emit_signal("attack_chosen", current_attack)
    
    if animation_player:
        animation_player.play("attack_" + current_attack)
    
    return current_attack

func get_bullet_pattern(attack_name):
    match attack_name:
        "energy_surge":
            energy_level += 0.5
            return "mania"
        "racing_thoughts":
            return "rapid"
        "impulsive_burst":
            return "erratic"
        "manic_episode":
            return "mania"
    return "mania"

# Override take_damage to implement boss mechanics
func take_damage(amount):
    var actual_damage = amount
    
    # Higher energy means more vulnerable
    if energy_level > 2.0:
        actual_damage *= 1.5
    
    # Taking damage increases energy
    energy_level += 0.1
    
    return super.take_damage(actual_damage)