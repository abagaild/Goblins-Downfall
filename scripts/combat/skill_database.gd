extends Node
class_name SkillDatabase

static var skills = {
    "Basic Attack": {
        "name": "Basic Attack",
        "description": "A simple attack that deals basic damage.",
        "resilience_cost": 0,
        "type": "attack",
        "power": 1.0,
        "unlocked_by_default": true
    },
    "Grounding": {
        "name": "Grounding",
        "description": "A technique to reconnect with the present moment. Restores mental energy.",
        "resilience_cost": 0,
        "type": "recovery",
        "power": 15.0,
        "unlocked_by_default": false,
        "crafting_requirement": "Lavender Seeds"
    },
    "Refocus": {
        "name": "Refocus",
        "description": "Redirect attention to positive thoughts. Restores fortitude.",
        "resilience_cost": 5,
        "type": "healing",
        "power": 10.0,
        "unlocked_by_default": false,
        "crafting_requirement": "Chamomile Seeds"
    },
    "Cognitive Reframing": {
        "name": "Cognitive Reframing",
        "description": "Challenge negative thoughts with positive alternatives. Deals increased damage.",
        "resilience_cost": 15,
        "type": "attack",
        "power": 1.5,
        "unlocked_by_default": false,
        "crafting_requirement": "Sage Seeds"
    },
    "Mindfulness": {
        "name": "Mindfulness",
        "description": "Present-moment awareness without judgment. Creates a protective shield.",
        "resilience_cost": 10,
        "type": "defense",
        "power": 20.0,
        "unlocked_by_default": false,
        "crafting_requirement": "Mint Seeds"
    },
    "Deep Breathing": {
        "name": "Deep Breathing",
        "description": "Slow, deep breaths to calm the nervous system. Reduces damage taken.",
        "resilience_cost": 8,
        "type": "defense",
        "power": 0.7, # Damage multiplier
        "unlocked_by_default": false,
        "crafting_requirement": "Lemon Balm Seeds"
    },
    "Positive Affirmation": {
        "name": "Positive Affirmation",
        "description": "Repeat positive statements to build confidence. Increases attack power.",
        "resilience_cost": 12,
        "type": "buff",
        "power": 1.3, # Attack multiplier
        "unlocked_by_default": false,
        "crafting_requirement": "Rosemary Seeds"
    },
    "Emotional Regulation": {
        "name": "Emotional Regulation",
        "description": "Identify and manage emotional responses. Balances fortitude and resilience.",
        "resilience_cost": 20,
        "type": "balance",
        "power": 15.0,
        "unlocked_by_default": false,
        "crafting_requirement": "Valerian Seeds"
    }
}

static func get_skill(skill_name):
    if skills.has(skill_name):
        return skills[skill_name]
    return null
