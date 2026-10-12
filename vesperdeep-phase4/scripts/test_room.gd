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
    if id == "M1":
        _solid(Rect2(0, 490, 105, 50))
        _solid(Rect2(105, 515, 85, 25))
        _solid(Rect2(190, 490, 910, 50))
    elif id == "M4":
        _solid(Rect2(0, 490, 825, 50))
        _solid(Rect2(1020, 490, 80, 50))
    elif id == "G3":
        _solid(Rect2(0, 490, 800, 50))
        _solid(Rect2(895, 490, 205, 50))
    else:
        _solid(Rect2(0, 490, 1100, 50))
    _solid(Rect2(-20, 0, 20, 540))
    _solid(Rect2(1100, 0, 20, 540))
    if id == "M1":
        var platforms := Node2D.new()
        platforms.name = "ShorePlatforms"
        add_child(platforms)
        for ledge in [Rect2(180, 430, 90, 12), Rect2(390, 385, 90, 12), Rect2(630, 430, 90, 12)]:
            var body := _solid(ledge)
            body.reparent(platforms, false)
        var target := ShoreTarget.new()
        target.name = "HangingTarget"
        target.position = Vector2(540, 445)
        add_child(target)
    if id == "M2":
        var cast := Label.new()
        cast.name = "EddaPip"
        cast.position = Vector2(695, 395)
        cast.text = "EDDA + PIP\nTheir first exchange opens the Ossuary passage"
        cast.add_theme_font_size_override("font_size", 14)
        add_child(cast)
    if id == "M4":
        var culvert := Label.new()
        culvert.name = "CulvertHint"
        culvert.text = "CULVERT\nJUMP + DASH (SHIFT/B)" if RunState.has_flag("echo_step_owned") else "CULVERT\nECHO STEP REQUIRED"
        culvert.position = Vector2(615, 346)
        culvert.add_theme_font_size_override("font_size", 14)
        add_child(culvert)
    if id == "C1":
        var arrival := Label.new()
        arrival.name = "BellEngineClue"
        arrival.text = "THE BELL ENGINE KEEPS THE GARDEN CLOSED."
        arrival.position = Vector2(465, 375)
        arrival.add_theme_font_size_override("font_size", 16)
        add_child(arrival)
    if id == "M3":
        _solid(Rect2(330, 420, 170, 16))
        _solid(Rect2(500, 355, 160, 16))
        _solid(Rect2(665, 290, 160, 16))
        var chimney := Node2D.new()
        chimney.name = "ChimneyWalls"
        add_child(chimney)
        for stone in [Rect2(190, 315, 16, 130), Rect2(265, 285, 16, 160), Rect2(281, 285, 64, 12)]:
            var body := _solid(stone)
            if stone.size.y > stone.size.x:
                body.add_to_group("climbable_wall")
            body.reparent(chimney, false)
        var grave := Label.new()
        grave.name = "GravestoneHint"
        grave.text = "GRAVESTONE  E/RB"
        grave.position = Vector2(292, 247)
        grave.add_theme_font_size_override("font_size", 14)
        add_child(grave)
        var latch := Label.new()
        latch.name = "TollLatchHint"
        latch.text = "LATCH  E/RB"
        latch.position = Vector2(805, 435)
        latch.add_theme_font_size_override("font_size", 14)
        add_child(latch)
        var note := Label.new()
        note.name = "RellNoteHint"
        note.text = "RELL'S NOTE  E/RB"
        note.position = Vector2(690, 255)
        note.add_theme_font_size_override("font_size", 14)
        add_child(note)
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
        if room_id == "M4":
            for enemy in spawned_enemies:
                if is_instance_valid(enemy):
                    enemy.queue_free() # Warm-up encounter ends before the solo Warden fight.
            spawned_enemies.clear()
            arena_walls.append(_solid(Rect2(65, 0, 20, 490)))
            arena_walls.append(_solid(Rect2(810, 0, 20, 490)))
            queue_redraw()
        miniboss.begin_encounter()
        miniboss.set_physics_process(true)
    if boss_active and is_instance_valid(miniboss) and x < 65:
        player.global_position.x = 85.0
    if room_id == "M1" and x > 850 and not RunState.has_flag("m1_intro_seen") and not active_dialogue:
        active_dialogue = true
        interaction_requested.emit("m1_intro")
        return
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

    if room_id == "G3" and x > 520 and not RunState.has_flag("mirror_latch_open"):
        interaction_requested.emit("mirror_latch")
    if Input.is_action_just_pressed("interact"):
        if room_id == "M3" and x > 800 and x < 930 and not RunState.has_flag("m3_toll_latch_open"):
            RunState.commit(["m3_toll_latch_open"])
            queue_redraw()
        elif room_id == "M3" and x > 285 and x < 355 and player.global_position.y < 330:
            interaction_requested.emit("gravestone")
        elif room_id == "M3" and x > 690 and x < 790 and player.global_position.y < 340:
            interaction_requested.emit("rell_note")
        elif room_id in RunState.SHRINES and absf(x - (670.0 if room_id == "G3" else 235.0)) < 65 and (room_id != "G3" or RunState.has_flag("mirror_latch_open")):
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
        var culvert := get_node_or_null("CulvertHint") as Label
        if culvert != null:
            culvert.text = "CULVERT\nJUMP + DASH (SHIFT/B)"
        for wall in arena_walls:
            wall.queue_free()
        arena_walls.clear()
        if not RunState.has_flag("shore_voice_heard"):
            interaction_requested.emit("shore_voice")
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
        "M1": kinds = [EnemyProfile.Kind.PAPER_DRUDGE]
        "M2": kinds = [EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.PAPER_DRUDGE]
        "M3": kinds = [EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.GLASS_MOTH]
        "M4": kinds = [EnemyProfile.Kind.PAPER_DRUDGE]
        "C1": kinds = [EnemyProfile.Kind.PAPER_DRUDGE]
        "C2": kinds = [EnemyProfile.Kind.CHOIR_NEEDLE, EnemyProfile.Kind.PAPER_DRUDGE]
        "C4": kinds = [EnemyProfile.Kind.CHOIR_NEEDLE]
        "G1": kinds = [EnemyProfile.Kind.GLASS_MOTH]
        "G2": kinds = [EnemyProfile.Kind.GLASS_MOTH, EnemyProfile.Kind.GLASS_MOTH]
    var shore_spawns := {
        "M1": [Vector2(400, 465)],
        "M2": [Vector2(390, 465), Vector2(500, 465)],
        "M3": [Vector2(400, 465), Vector2(570, 465), Vector2(720, 365)],
        "M4": [Vector2(200, 465)]
    }
    for i in range(kinds.size()):
        if RunState.defeated_enemies.has(id + ":" + str(i)):
            continue
        var enemy := OrdinaryEnemy.new()
        enemy.profile = EnemyProfile.for_kind(kinds[i])
        enemy.set_meta("spawn_room", id)
        enemy.set_meta("spawn_index", i)
        enemy.position = shore_spawns[id][i] if shore_spawns.has(id) else Vector2(390 + i * 270, 400 if kinds[i] == EnemyProfile.Kind.GLASS_MOTH else 465)
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
    if room_id.begins_with("M"):
        draw_rect(Rect2(0, 145, 1100, 8), Color(0.26, 0.33, 0.38))
        for x in [90, 290, 520, 760, 970]:
            draw_line(Vector2(x, 153), Vector2(x + 18, 275), Color(0.32, 0.39, 0.42, 0.65), 5)
        if room_id == "M1":
            for ledge in [Rect2(180, 430, 90, 12), Rect2(390, 385, 90, 12), Rect2(630, 430, 90, 12)]:
                draw_rect(ledge, Color(0.65, 0.70, 0.66))
            draw_rect(Rect2(65, 465, 105, 25), Color(0.29, 0.37, 0.40))
        elif room_id == "M2":
            for x in [420, 462, 504, 546]:
                draw_rect(Rect2(x, 405, 23, 50), Color(0.65, 0.70, 0.65))
                draw_rect(Rect2(x + 3, 416, 17, 17), Color(0.30, 0.36, 0.38))
            draw_rect(Rect2(762, 440, 20, 50), Color(0.84, 0.75, 0.60))
            draw_rect(Rect2(795, 462, 15, 28), Color(0.79, 0.81, 0.67))
        elif room_id == "M3":
            for ledge in [Rect2(330, 420, 170, 16), Rect2(500, 355, 160, 16), Rect2(665, 290, 160, 16)]:
                draw_rect(ledge, Color(0.64, 0.69, 0.66))
            draw_rect(Rect2(190, 315, 16, 130), Color(0.63, 0.67, 0.68))
            draw_rect(Rect2(265, 285, 16, 160), Color(0.63, 0.67, 0.68))
            draw_rect(Rect2(281, 285, 64, 12), Color(0.72, 0.76, 0.72))
            draw_rect(Rect2(850, 434, 22, 56), Color(0.85, 0.68, 0.40) if not RunState.has_flag("m3_toll_latch_open") else Color(0.57, 0.78, 0.65))
            draw_rect(Rect2(270, 165, 55, 80), Color(0.72, 0.36, 0.30) if not RunState.has_flag("mirror_latch_open") else Color(0.60, 0.75, 0.68))
    if room_id == "M1":
        draw_rect(Rect2(0, 490, 105, 50), Color(0.35, 0.39, 0.39))
        draw_rect(Rect2(105, 515, 85, 25), Color(0.35, 0.39, 0.39))
        draw_rect(Rect2(190, 490, 910, 50), Color(0.35, 0.39, 0.39))
    elif room_id == "M4":
        draw_circle(Vector2(485, 267), 63, Color(0.33, 0.38, 0.38))
        draw_arc(Vector2(485, 267), 63, 0, TAU, 40, Color(0.59, 0.55, 0.42), 5)
        draw_line(Vector2(485, 211), Vector2(485, 253), Color(0.59, 0.55, 0.42), 5)
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
    if room_id == "M4":
        draw_line(Vector2(815, 477), Vector2(825, 490), Color(1.0, 0.65, 0.24), 5)
        draw_line(Vector2(1020, 490), Vector2(1030, 477), Color(1.0, 0.65, 0.24), 5)
