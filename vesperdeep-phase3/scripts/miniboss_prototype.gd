extends CharacterBody2D
class_name MinibossPrototype

signal defeated(kind: String)
@export var kind: String = "warden"
var hp: int = 10
var player: Vessel
var phase: String = "idle"
var timer: float = 0.65
var move_index: int = -1
var facing: int = -1
var attack_serial: int = 0
var hit_this_attack: bool = false
var last_swing: int = -1
var wound_time: float = 0.0
var warning_x: float = 0.0
const WARDEN := [[0.7, 0.3, 0.9], [0.85, 0.35, 1.1], [0.6, 0.45, 0.8]]
const CANTOR := [[0.8, 0.4, 1.0], [0.8, 0.6, 0.85], [0.7, 0.35, 1.1]]

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    hp = 10 if kind == "warden" else 12
    var shape := CollisionShape2D.new()
    var box := RectangleShape2D.new()
    box.size = Vector2(52, 64)
    shape.shape = box
    add_child(shape)
    queue_redraw()

func set_player(value: Vessel) -> void:
    player = value

func receive_hit(swing: int, attacker: Vessel) -> bool:
    if phase == "dead" or last_swing == swing or wound_time > 0.0:
        return false
    last_swing = swing
    wound_time = 0.12
    hp -= 1
    if hp <= 0:
        phase = "dead"
        collision_layer = 0
        defeated.emit(kind)
        queue_free()
    else:
        velocity.x = signf(global_position.x - attacker.global_position.x) * 95.0
    return true

func _physics_process(delta: float) -> void:
    if phase == "dead" or Controls.gameplay_locked or not is_instance_valid(player):
        return
    wound_time = maxf(0.0, wound_time - delta)
    timer -= delta
    if phase == "idle" and timer <= 0.0:
        move_index = (move_index + 1) % 3
        facing = 1 if player.global_position.x > global_position.x else -1
        warning_x = player.global_position.x
        phase = "antic"
        timer = _times()[move_index][0]
    elif phase == "antic" and timer <= 0.0:
        phase = "active"
        timer = _times()[move_index][1]
        attack_serial += 1
        hit_this_attack = false
    elif phase == "active":
        if kind == "warden" and move_index == 2:
            velocity.x = facing * 240.0
        elif kind == "warden" and move_index == 1:
            velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        if not hit_this_attack and _dangerous_overlap():
            hit_this_attack = player.receive_damage(get_instance_id() + attack_serial, 1)
        if timer <= 0.0:
            phase = "recovery"
            timer = _times()[move_index][2]
            velocity.x = 0.0
    elif phase == "recovery" and timer <= 0.0:
        phase = "idle"
        timer = 0.55 if kind == "cantor" else 0.45
    if not (kind == "warden" and phase == "active" and move_index == 2):
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
    velocity.y = minf(velocity.y + 1100.0 * delta, 540.0)
    move_and_slide()
    queue_redraw()

func _times() -> Array:
    return WARDEN if kind == "warden" else CANTOR

func _dangerous_overlap() -> bool:
    var diff := player.global_position - global_position
    if kind == "warden":
        match move_index:
            0: return diff.x * facing > -10 and diff.x * facing < 105 and absf(diff.y) < 34
            1: return absf(player.global_position.x - warning_x) < 38 and absf(diff.y) < 52
            2: return absf(diff.x) < 45 and absf(diff.y) < 50
    else:
        match move_index:
            0: return absf(diff.x) < 160 and diff.y > -30 and diff.y < 35
            1: return absf(diff.x) < 205 and absf(diff.y) < 18
            2: return absf(player.global_position.x - warning_x) < 40 and diff.y > -45
    return false

func _draw() -> void:
    var tint := Color(0.9, 0.76, 0.35) if kind == "warden" else Color(0.52, 0.93, 0.85)
    if phase == "antic": tint = Color(1.0, 0.27, 0.22)
    draw_rect(Rect2(-26, -32, 52, 64), Color.WHITE if wound_time > 0.0 else tint)
    if phase == "antic":
        match move_index:
            0: draw_line(Vector2.ZERO, Vector2(facing * 105, 0), Color(1, 0.3, 0.2), 5)
            1: draw_rect(Rect2(warning_x - global_position.x - 38, 20, 76, 8), Color(1, 0.3, 0.2))
            2: draw_line(Vector2.ZERO, Vector2(facing * 170, 0), Color(1, 0.3, 0.2), 4)
