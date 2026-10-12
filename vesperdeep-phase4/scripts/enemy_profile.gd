extends Resource
class_name EnemyProfile

enum Kind { PAPER_DRUDGE, CHOIR_NEEDLE, GLASS_MOTH }
@export var kind: Kind = Kind.PAPER_DRUDGE
@export var maximum_hp: int = 2
@export var damage: int = 1
@export var telegraph_seconds: float = 0.55
@export var active_seconds: float = 0.2
@export var recovery_seconds: float = 0.6
@export var speed: float = 65.0
@export var detection_range: float = 190.0
@export var contact_knockback: float = 155.0
@export var contact_stagger_seconds: float = 0.24

static func for_kind(value: Kind) -> EnemyProfile:
    var p := EnemyProfile.new()
    p.kind = value
    match value:
        Kind.PAPER_DRUDGE:
            p.telegraph_seconds = 0.48
            p.recovery_seconds = 0.52
            p.speed = 78.0
            p.detection_range = 220.0
        Kind.CHOIR_NEEDLE:
            p.telegraph_seconds = 0.8
            p.speed = 0.0
            p.detection_range = 310.0
        Kind.GLASS_MOTH:
            p.telegraph_seconds = 0.7
            p.speed = 95.0
    return p
