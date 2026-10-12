extends CharacterBody2D
class_name OrdinaryEnemy

signal defeated(enemy: OrdinaryEnemy)
@export var profile: EnemyProfile = EnemyProfile.new()
var hp: int = 2
var state: String = "idle"
var state_timer: float = 0.0
var facing: int = 1
var origin: Vector2
var player: Vessel
var attack_serial: int = 0
var has_hit: bool = false
var last_player_swing: int = -1
var pending_velocity: Vector2 = Vector2.ZERO
var wound_time: float = 0.0
var contact_stagger: float = 0.0
var committed_target: Vector2
var lane: Line2D
var projectile: Area2D

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1 # Terrain collision only; body contact is resolved explicitly, never by dragging the player.
    hp = profile.maximum_hp
    origin = global_position
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(28, 28)
    shape.shape = rect
    add_child(shape)
    lane = Line2D.new()
    lane.width = 4.0
    lane.default_color = Color(1.0, 0.12, 0.22)
    add_child(lane)
    if profile.kind == EnemyProfile.Kind.GLASS_MOTH:
        origin.y -= 15.0
    queue_redraw()

func set_player(value: Vessel) -> void:
    player = value

func receive_hit(swing_id: int, attacker: Vessel) -> bool:
    if state == "dead" or swing_id == last_player_swing or wound_time > 0.0:
        return false
    last_player_swing = swing_id
    hp -= 1
    wound_time = 0.15
    velocity = Vector2(signf(global_position.x - attacker.global_position.x) * 120.0, -80.0)
    if hp <= 0:
        state = "dead"
        collision_layer = 0
        lane.clear_points()
        if is_instance_valid(projectile):
            projectile.queue_free()
        defeated.emit(self)
        queue_free()
    else:
        if has_meta("spawn_room") and has_meta("spawn_index"):
            RunState.remember_enemy(String(get_meta("spawn_room")), int(get_meta("spawn_index")), hp)
        _enter("recover", 0.4)
    return true

func _enter(next: String, duration: float) -> void:
    state = next
    state_timer = duration
    if next == "telegraph":
        committed_target = player.global_position if is_instance_valid(player) else global_position
        facing = 1 if committed_target.x >= global_position.x else -1
        lane.clear_points()
        if profile.kind == EnemyProfile.Kind.CHOIR_NEEDLE:
            lane.add_point(Vector2(0, 3))
            lane.add_point(Vector2(facing * 260, 3))
        elif profile.kind == EnemyProfile.Kind.GLASS_MOTH:
            lane.add_point(Vector2.ZERO)
            lane.add_point(committed_target - global_position)
    else:
        lane.clear_points()
    if next == "active":
        attack_serial += 1
        has_hit = false
        if profile.kind == EnemyProfile.Kind.CHOIR_NEEDLE:
            _fire_note()
        elif profile.kind == EnemyProfile.Kind.GLASS_MOTH:
            pending_velocity = (committed_target - global_position).normalized() * profile.speed * 2.7
            state_timer = maxf(duration, global_position.distance_to(committed_target) / maxf(pending_velocity.length(), 1.0))

func _physics_process(delta: float) -> void:
    if state == "dead" or Controls.gameplay_locked:
        return
    wound_time = maxf(0.0, wound_time - delta)
    if not is_instance_valid(player):
        return
    if contact_stagger > 0.0:
        contact_stagger = maxf(0.0, contact_stagger - delta)
        velocity.x = move_toward(velocity.x, 0.0, 180.0 * delta)
        if profile.kind != EnemyProfile.Kind.GLASS_MOTH:
            velocity.y = minf(velocity.y + 1100.0 * delta, 500.0)
        move_and_slide()
        queue_redraw()
        return
    var distance := player.global_position.distance_to(global_position)
    state_timer -= delta
    match state:
        "idle":
            if distance < profile.detection_range:
                _enter("engage", 0.18)
            else:
                _enter("patrol", 0.7)
        "patrol":
            if distance < profile.detection_range:
                _enter("engage", 0.18)
            elif state_timer <= 0.0:
                facing *= -1
                _enter("idle", 0.4)
        "engage":
            if profile.kind == EnemyProfile.Kind.PAPER_DRUDGE and absf(player.global_position.x - global_position.x) > 15.0:
                facing = 1 if player.global_position.x > global_position.x else -1
            if distance > profile.detection_range * 1.4:
                _enter("patrol", 0.8)
            elif state_timer <= 0.0 and (profile.kind != EnemyProfile.Kind.PAPER_DRUDGE or (absf(player.global_position.x - global_position.x) < 62.0 and absf(player.global_position.y - global_position.y) < 40.0)):
                var turn_available := true
                if profile.kind in [EnemyProfile.Kind.GLASS_MOTH, EnemyProfile.Kind.PAPER_DRUDGE]:
                    for sibling in get_parent().get_children():
                        if sibling is OrdinaryEnemy and sibling != self and sibling.profile.kind == profile.kind and sibling.state in ["telegraph", "active", "recover"]:
                            turn_available = false
                            break
                if turn_available:
                    _enter("telegraph", profile.telegraph_seconds)
        "telegraph":
            if state_timer <= 0.0:
                _enter("active", profile.active_seconds)
        "active":
            _active_attack()
            if state_timer <= 0.0:
                _enter("recover", profile.recovery_seconds)
        "recover":
            if state_timer <= 0.0 and (profile.kind != EnemyProfile.Kind.GLASS_MOTH or global_position.distance_to(origin) < 3.0):
                _enter("idle", 0.3)
    if profile.kind == EnemyProfile.Kind.GLASS_MOTH:
        if state == "active":
            velocity = pending_velocity
        elif state == "telegraph":
            velocity = Vector2.ZERO
        elif state == "recover":
            velocity = (origin - global_position).limit_length(profile.speed * 2.7 * delta) / delta
        else:
            velocity = (origin - global_position).limit_length(profile.speed * delta) / delta
    else:
        velocity.y = minf(velocity.y + 1100.0 * delta, 500.0)
        if profile.kind == EnemyProfile.Kind.PAPER_DRUDGE:
            velocity.x = facing * profile.speed if state in ["patrol", "engage"] else move_toward(velocity.x, 0.0, 450.0 * delta)
            if absf(global_position.x - origin.x) >= 95.0 and signf(global_position.x - origin.x) == facing:
                velocity.x = 0.0
        else:
            velocity.x = 0.0
    move_and_slide()
    if state in ["idle", "patrol", "engage", "recover"] and absf(player.global_position.x - global_position.x) < 26.0 and absf(player.global_position.y - global_position.y) < 28.0:
        if player.receive_body_contact(self, 0):
            _contact_recoil()
    if is_on_wall() and state == "patrol":
        facing *= -1
    queue_redraw()

func _active_attack() -> void:
    if has_hit or profile.kind == EnemyProfile.Kind.CHOIR_NEEDLE:
        return
    var forward := player.global_position.x - global_position.x
    var near := absf(forward) < 37.0 and absf(player.global_position.y - global_position.y) < 34.0
    if near and (profile.kind == EnemyProfile.Kind.GLASS_MOTH or signf(forward) == facing):
        has_hit = player.receive_body_contact(self, profile.damage)
        if has_hit:
            _contact_recoil()

func _contact_recoil() -> void:
    var away := global_position.x - player.global_position.x
    if absf(away) < 1.0:
        away = velocity.x - player.velocity.x
    var direction := signf(away) if absf(away) >= 1.0 else float(-facing)
    velocity = Vector2(direction * profile.contact_knockback, -65.0)
    contact_stagger = profile.contact_stagger_seconds
    if state == "active":
        _enter("recover", profile.recovery_seconds)

func _fire_note() -> void:
    var note := Area2D.new()
    note.collision_layer = 16
    note.collision_mask = 2
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(15, 8)
    shape.shape = rect
    note.add_child(shape)
    var visible_body := Polygon2D.new()
    visible_body.name = "VisibleBody"
    visible_body.polygon = PackedVector2Array([Vector2(-8, -4), Vector2(8, -4), Vector2(8, 4), Vector2(-8, 4)])
    visible_body.color = Color(1.0, 0.68, 0.27)
    note.add_child(visible_body)
    get_parent().add_child(note)
    note.global_position = global_position + Vector2(facing * 18.0, 2.0)
    projectile = note
    var born_serial := attack_serial
    note.body_entered.connect(func(body: Node2D) -> void:
        if body is Vessel and born_serial == attack_serial:
            body.receive_damage(get_instance_id() + born_serial, profile.damage)
            if is_instance_valid(note): note.queue_free()
    )
    var tween := note.create_tween()
    tween.tween_property(note, "position:x", note.position.x + facing * 340.0, 1.1)
    tween.tween_callback(func() -> void: if is_instance_valid(note): note.queue_free())

func _draw() -> void:
    var color := Color(0.8, 0.69, 0.5) if profile.kind == EnemyProfile.Kind.PAPER_DRUDGE else (Color(0.64, 0.86, 0.73) if profile.kind == EnemyProfile.Kind.CHOIR_NEEDLE else Color(0.86, 0.89, 0.99))
    if state == "telegraph":
        color = Color(1.0, 0.32, 0.26)
    draw_rect(Rect2(-14, -14, 28, 28), Color.WHITE if wound_time > 0.0 else color)
