extends Node2D
class_name TestRoom

signal exit_requested(destination: String)
signal interaction_requested(kind: String)
const ROOMS := ["M1", "M2", "M3", "M4", "C1", "C2", "C3", "C4", "G1", "G2", "G3", "G4"]
const SPINE := {"M1":"M2", "M2":"M3", "M3":"M4", "M4":"C1", "C1":"C2", "C2":"C3", "C3":"C4", "C4":"G1", "G1":"G2", "G2":"G3", "G3":"G4"}
const NAMES := {"M1":"Wreckfall", "M2":"House of Kept Names", "M3":"Ossuary Steps", "M4":"Tollhouse", "C1":"Sluice Landing", "C2":"Silence Archive", "C3":"Bell Engine", "C4":"Hollow Basilica", "G1":"Glass Gate", "G2":"Pale Orchard", "G3":"Mirror Gallery", "G4":"Cradle"}
var room_id: String = "M1"
var player: Vessel
var spawned_enemies: Array[OrdinaryEnemy] = []
var miniboss: MinibossPrototype
var boss_active: bool = false
var arena_walls: Array[StaticBody2D] = []
var latch_barrier: StaticBody2D
var room_color := Color(0.12, 0.16, 0.21)
var can_trigger_exit: bool = true
var active_dialogue: bool = false

func setup(id: String, vessel: Vessel) -> void:
    room_id = id
    player = vessel
    name = "Room_" + id
    if id.begins_with("C"):
        room_color = Color(0.07, 0.2, 0.18)
    elif id.begins_with("G"):
        room_color = Color(0.22, 0.24, 0.27)
    if id == "M4":
        _solid(Rect2(0, 490, 825, 50))
        _solid(Rect2(1020, 490, 80, 50))
        if not RunState.has_flag("warden_defeated"):
            arena_walls.append(_solid(Rect2(65, 0, 20, 490)))
            arena_walls.append(_solid(Rect2(810, 0, 20, 490)))
    elif id == "G3":
        _solid(Rect2(0, 490, 800, 50))
        _solid(Rect2(895, 490, 205, 50))
    else:
        _solid(Rect2(0, 490, 1100, 50))
    _solid(Rect2(-20, 0, 20, 540))
    _solid(Rect2(1100, 0, 20, 540))
    if id == "M3":
        _solid(Rect2(330, 420, 170, 16))
        _solid(Rect2(500, 335, 160, 16))
        _solid(Rect2(665, 250, 160, 16))
    if id == "C2":
        _solid(Rect2(320, 420, 180, 16))
        _solid(Rect2(620, 380, 200, 16))
    if id == "G3":
        _solid(Rect2(560, 395, 220, 16))
        if not RunState.has_flag("mirror_latch_open"):
            latch_barrier = _solid(Rect2(590, 0, 20, 490))
    if id in RunState.SHRINES:
        var shrine_hint := Label.new()
        shrine_hint.name = "ShrineHint"
        shrine_hint.text = "SHRINE  E/RB TO REST"
        shrine_hint.position = Vector2(605 if id == "G3" else 170, 410)
        shrine_hint.add_theme_font_size_override("font_size", 14)
        add_child(shrine_hint)
    reset_ordinary_enemies()
    if (id == "M4" and not RunState.has_flag("warden_defeated")) or (id == "C3" and not RunState.has_flag("cantor_defeated")):
        miniboss = MinibossPrototype.new()
        miniboss.kind = "warden" if id == "M4" else "cantor"
        add_child(miniboss)
        miniboss.global_position = Vector2(480 if id == "M4" else 660, 450)
        miniboss.set_player(player)
        miniboss.set_physics_process(false)
        miniboss.defeated.connect(_on_miniboss_defeated)
    queue_redraw()

func _solid(rect: Rect2) -> StaticBody2D:
    var ground := StaticBody2D.new()
    ground.collision_layer = 1
    ground.collision_mask = 0
    var shape := CollisionShape2D.new()
    var box := RectangleShape2D.new()
    box.size = rect.size
    shape.shape = box
    shape.position = rect.position + rect.size / 2.0
    ground.add_child(shape)
    add_child(ground)
    return ground

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(player) or Controls.gameplay_locked:
        return
    var x := player.global_position.x
    if is_instance_valid(miniboss) and not boss_active and x > 310:
        boss_active = true
        miniboss.set_physics_process(true)
    if boss_active and is_instance_valid(miniboss) and x < 65:
        player.global_position.x = 85.0
    if x > 1030 and can_trigger_exit and SPINE.has(room_id):
        var next: String = SPINE[room_id]
        if not RunState.gate_open(room_id, next):
            if _mandatory_scene():
                interaction_requested.emit(_mandatory_scene())
            player.global_position.x = 1000.0
        else:
            can_trigger_exit = false
            exit_requested.emit(next)
    elif x < 55 and can_trigger_exit and not boss_active:
        var index := ROOMS.find(room_id)
        if index > 0:
            var previous: String = ROOMS[index - 1]
            if RunState.gate_open(room_id, previous):
                can_trigger_exit = false
                exit_requested.emit(previous)
            else:
                player.global_position.x = 75.0
    elif x > 90 and x < 990:
        can_trigger_exit = true
    if room_id in ["M2", "C2", "G2"] and x > 740 and not RunState.has_flag(_first_flag()) and not active_dialogue:
        active_dialogue = true
        interaction_requested.emit(_mandatory_scene())
    if room_id == "M3" and x > 840 and not RunState.has_flag("m3_toll_latch_open"):
        RunState.commit(["m3_toll_latch_open"])
    if room_id == "G3" and x > 520 and not RunState.has_flag("mirror_latch_open"):
        interaction_requested.emit("mirror_latch")
    if Input.is_action_just_pressed("interact"):
        if room_id in RunState.SHRINES and absf(x - (670.0 if room_id == "G3" else 235.0)) < 65 and (room_id != "G3" or RunState.has_flag("mirror_latch_open")):
            RunState.reach_shrine(room_id)
            reset_ordinary_enemies()
        elif room_id == "C2" and x < 330:
            RunState.commit(["c2_hatch_open"])
        elif room_id == "M2" and x > 490 and x < 610 and RunState.has_flag("c2_hatch_open"):
            can_trigger_exit = false
            exit_requested.emit("C2")
        elif room_id == "C2" and x > 490 and x < 610 and RunState.has_flag("c2_hatch_open"):
            can_trigger_exit = false
            exit_requested.emit("M2")
        elif room_id == "G3" and x > 450 and x < 650:
            RunState.commit(["mirror_latch_open"])
            if is_instance_valid(latch_barrier):
                latch_barrier.queue_free()
        elif room_id == "G3" and x > 240 and x < 350 and RunState.has_flag("mirror_latch_open"):
            can_trigger_exit = false
            exit_requested.emit("M3")
        elif room_id == "M3" and x > 240 and x < 350 and RunState.has_flag("mirror_latch_open"):
            can_trigger_exit = false
            exit_requested.emit("G3")
        elif room_id == "C4" and x > 880 and RunState.has_flag("resonance_sigil_owned"):
            RunState.commit(["glass_gate_open"])
    if player.global_position.y > 570:
        player.recover_hazard()

func _on_miniboss_defeated(kind: String) -> void:
    boss_active = false
    if kind == "warden":
        RunState.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"])
        for wall in arena_walls:
            wall.queue_free()
        arena_walls.clear()
    else:
        RunState.commit(["cantor_defeated", "choir_relay_off", "resonance_sigil_owned", "c4_door_open"])
    queue_redraw()

func reset_ordinary_enemies() -> void:
    if not is_instance_valid(player):
        return
    var id := room_id
    var vessel := player
    for child in get_children():
        if child is OrdinaryEnemy:
            child.queue_free()
    spawned_enemies.clear()
    var kinds: Array[int] = []
    match id:
        "M3": kinds = [EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.PAPER_DRUDGE]
        "C1": kinds = [EnemyProfile.Kind.PAPER_DRUDGE]
        "C2": kinds = [EnemyProfile.Kind.CHOIR_NEEDLE, EnemyProfile.Kind.PAPER_DRUDGE]
        "C4": kinds = [EnemyProfile.Kind.CHOIR_NEEDLE]
        "G1": kinds = [EnemyProfile.Kind.GLASS_MOTH]
        "G2": kinds = [EnemyProfile.Kind.GLASS_MOTH, EnemyProfile.Kind.GLASS_MOTH]
    for i in range(kinds.size()):
        if RunState.defeated_enemies.has(id + ":" + str(i)):
            continue
        var enemy := OrdinaryEnemy.new()
        enemy.profile = EnemyProfile.for_kind(kinds[i])
        enemy.set_meta("spawn_room", id)
        enemy.set_meta("spawn_index", i)
        enemy.position = Vector2(390 + i * 270, 400 if kinds[i] == EnemyProfile.Kind.GLASS_MOTH else 465)
        add_child(enemy)
        enemy.hp = int(RunState.enemy_health.get(id + ":" + str(i), enemy.hp))
        enemy.set_player(vessel)
        enemy.defeated.connect(func(_fallen: OrdinaryEnemy) -> void: RunState.mark_enemy(id, i))
        spawned_enemies.append(enemy)

func _first_flag() -> String:
    match room_id:
        "M2": return "edda_met"
        "C2": return "thren_met"
        "G2": return "asha_met"
        _: return ""

func _mandatory_scene() -> String:
    match room_id:
        "M2": return "edda"
        "C2": return "thren"
        "G2": return "asha"
        _: return ""

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1100, 540), room_color)
    if room_id == "M4":
        draw_rect(Rect2(0, 490, 825, 50), Color(0.35, 0.39, 0.39))
        draw_rect(Rect2(1020, 490, 80, 50), Color(0.35, 0.39, 0.39))
        if not arena_walls.is_empty():
            draw_rect(Rect2(65, 0, 20, 490), Color(0.45, 0.54, 0.56))
            draw_rect(Rect2(810, 0, 20, 490), Color(0.45, 0.54, 0.56))
    elif room_id == "G3":
        draw_rect(Rect2(0, 490, 800, 50), Color(0.35, 0.39, 0.39))
        draw_rect(Rect2(895, 490, 205, 50), Color(0.35, 0.39, 0.39))
    else:
        draw_rect(Rect2(0, 490, 1100, 50), Color(0.35, 0.39, 0.39))
    draw_rect(Rect2(30, 360, 35, 130), Color(0.65, 0.8, 0.82))
    draw_rect(Rect2(1030, 360, 35, 130), Color(0.65, 0.8, 0.82) if not SPINE.has(room_id) or RunState.gate_open(room_id, SPINE[room_id]) else Color(0.8, 0.26, 0.2))
    if room_id in RunState.SHRINES:
        draw_rect(Rect2(645 if room_id == "G3" else 210, 440, 40, 50), Color(0.55, 0.78, 0.95))
    if room_id == "G3":
        draw_rect(Rect2(530, 420, 25, 70), Color(0.91, 0.68, 0.2))
    if room_id in ["M4", "G3"]:
        draw_rect(Rect2(915, 490, 65, 8), Color(1.0, 0.35, 0.23))
