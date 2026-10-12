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
@export var contact_knockback: float = 45.0
@export var contact_stagger_seconds: float = 0.13
var contact_stagger: float = 0.0
var warning_x: float = 0.0
const WARDEN := [[0.7, 0.3, 0.9], [0.85, 0.35, 1.1], [0.6, 0.62, 0.8]]
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

func begin_encounter() -> void:
    if kind == "warden":
        phase = "intro"
        timer = 1.5 # Three harmless taps before the first attack tell.

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
    if contact_stagger > 0.0:
        contact_stagger = maxf(0.0, contact_stagger - delta)
        velocity.x = move_toward(velocity.x, 0.0, 180.0 * delta)
        velocity.y = minf(velocity.y + 1100.0 * delta, 540.0)
        move_and_slide()
        queue_redraw()
        return
    timer -= delta
    if phase == "intro" and timer <= 0.0:
        phase = "idle"
        timer = 0.45
    elif phase == "idle" and timer <= 0.0:
        move_index = (move_index + 1) % 3
        if kind == "warden" and hp <= 5 and move_index == 1 and attack_serial % 2 == 0 and absf(player.global_position.x - global_position.x) < 65.0:
            move_index = 2 # A warned shove contests repeated close-range punishes; other cycles retain the marked drop.
        if kind == "warden" and move_index == 0 and absf(player.global_position.x - global_position.x) > 135.0:
            move_index = 1 # The marked drop pressures distant players; never use an out-of-range sweep.
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
            velocity.x = facing * 260.0
        elif kind == "warden" and move_index == 1:
            velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        if not hit_this_attack and _dangerous_overlap():
            hit_this_attack = player.receive_body_contact(self, 1)
            if hit_this_attack:
                var away := global_position.x - player.global_position.x
                velocity.x = (signf(away) if absf(away) >= 1.0 else float(-facing)) * contact_knockback
                contact_stagger = contact_stagger_seconds
        if timer <= 0.0:
            phase = "recovery"
            timer = _times()[move_index][2]
            velocity.x = 0.0
    elif phase == "recovery" and timer <= 0.0:
        phase = "idle"
        timer = 0.55 if kind == "cantor" else (0.25 if hp <= 5 else 0.45)
    if kind == "warden" and phase == "idle" and absf(player.global_position.x - global_position.x) > 105.0:
        velocity.x = move_toward(velocity.x, signf(player.global_position.x - global_position.x) * 135.0, 650.0 * delta)
    elif not (kind == "warden" and phase == "active" and move_index == 2):
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
    velocity.y = minf(velocity.y + 1100.0 * delta, 540.0)
    move_and_slide()
    queue_redraw()

func _times() -> Array:
    if kind != "warden" or hp > 5:
        return WARDEN if kind == "warden" else CANTOR
    var moves: Array = WARDEN.duplicate(true)
    for move in moves:
        move[2] = maxf(0.65, move[2] - 0.12)
    return moves

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
    if phase == "intro":
        var tap := mini(3, int((1.5 - timer) / 0.5) + 1)
        for i in range(tap):
            draw_circle(Vector2(-14 + i * 14, -47), 4, Color(0.95, 0.78, 0.40))
    if phase == "antic":
        match move_index:
            0: draw_line(Vector2.ZERO, Vector2(facing * 105, 0), Color(1, 0.3, 0.2), 5)
            1: draw_rect(Rect2(warning_x - global_position.x - 38, 20, 76, 8), Color(1, 0.3, 0.2))
            2: draw_line(Vector2.ZERO, Vector2(facing * 170, 0), Color(1, 0.3, 0.2), 4)
