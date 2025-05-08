extends EnemyBase
class_name DepressionBoss

# Boss-specific properties
var energy_drain = 0.0
var hopelessness_level = 0
var isolation_active = false

func _ready():
    super._ready()
    
    # Set up boss stats
    enemy_name = "Depression"  # Changed from name to enemy_name
    max_health = 400.0
    current_health = max_health
    attack_power = 15.0
    defense = 15.0
    is_boss = true
    
    # Boss-specific attacks
    attacks = ["energy_drain", "negative_thoughts", "isolation"]
    
    emit_signal("health_changed", current_health, max_health)

func _process(delta):
    # Depression slowly heals over time
    if current_health < max_health:
        heal(delta * 2)

func choose_attack():
    # Depression has phase-based attacks
    if hopelessness_level >= 5:
        current_attack = "overwhelming_despair"
        hopelessness_level = 0
    elif isolation_active:
        current_attack = "rumination"
        isolation_active = false
    else:
        var options = ["energy_drain", "negative_thoughts", "isolation"]
        current_attack = options[randi() % options.size()]
        
        if current_attack == "isolation":
            isolation_active = true
    
    emit_signal("attack_chosen", current_attack)
    
    if animation_player:
        animation_player.play("attack_" + current_attack)
    
    return current_attack

func get_bullet_pattern(attack_name):
    match attack_name:
        "energy_drain":
            energy_drain += 0.2
            return "depression"
        "negative_thoughts":
            hopelessness_level += 1
            return "basic"
        "isolation":
            return "depression"
        "rumination":
            return "spiral"
        "overwhelming_despair":
            return "heavy"
    return "depression"

# Override take_damage to implement boss mechanics
func take_damage(amount):
    var actual_damage = amount
    
    # Energy drain reduces damage
    if energy_drain > 0:
        actual_damage *= max(0.3, 1.0 - energy_drain)
        energy_drain = max(0, energy_drain - 0.1)
    
    # Isolation reduces damage
    if isolation_active:
        actual_damage *= 0.5
    
    # Taking damage increases hopelessness
    hopelessness_level += 1
    
    return super.take_damage(actual_damage)