extends Node

var passed: int = 0
var failed: Array[String] = []
var state: Node
var controls: Node
var game: Node2D

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failed.append(label)
        push_error("FAIL " + label)

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    await get_tree().process_frame
    state = get_tree().root.get_node("RunState")
    controls = get_tree().root.get_node("Controls")
    state.save_path = "user://phase3_test_run.json"
    state.new_game()
    check(state.hp == 5 and state.charges == 0 and state.hit_progress == 0, "new game resources")
    check(not state.gate_open("M2", "M3"), "Edda gate initially closed")
    check(not state.gate_open("G3", "G4"), "G4 gate initially closed")
    check(state.commit(["edda_met"]), "first dialogue durable commit")
    check(state.gate_open("M2", "M3"), "Edda gate opens")
    check(state.commit(["m3_toll_latch_open"]), "mandatory approach latch")
    check(state.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"]), "Warden atomic reward group")
    check(state.gate_open("M4", "C1"), "Echo Step gate after reward")
    check(state.commit(["thren_met", "engine_objective_known"]), "Thren atomic scene")
    check(state.gate_open("C2", "C3"), "C3 reached without sigil")
    check(state.commit(["cantor_defeated", "choir_relay_off", "resonance_sigil_owned", "c4_door_open"]), "Cantor atomic reward")
    check(state.gate_open("C4", "G1"), "passive sigil gate")
    check(state.commit(["asha_met", "mirror_latch_open"]), "Asha and Mirror Latch")
    check(state.gate_open("G3", "G4") and state.gate_open("M3", "G3"), "derived finale and two-way shortcut gates")
    check(not state.gate_open("M1", "G4"), "unlisted teleport rejected")
    check(state.load_game() and state.has_flag("mirror_latch_open"), "save/load round trip keeps gate progress")
    state.mark_enemy("M3", 0)
    state.activate_shrine("M2")
    check(state.defeated_enemies.has("M3:0"), "activation does not respawn ordinary enemies")
    state.reach_shrine("M2")
    check(state.defeated_enemies.is_empty(), "rest respawns ordinary enemies")
    state.reach_shrine("G1")
    state.hit_progress = 2
    state.charges = 2
    state.enter_room("M4")
    check(state.checkpoint == "M2" and state.hit_progress == 2 and state.charges == 2, "boss checkpoint and partial charge survive room")
    state.hp = 2
    state.death()
    check(state.room_id == "M2" and state.hp == 5 and state.charges == 0 and state.hit_progress == 0 and state.has_flag("echo_step_owned"), "normal death shrine and durable abilities")
    state.commit(["identity_revealed", "veyra_sacrificed"])
    state.enter_room("G4")
    state.hp = 1
    state.charges = 3
    state.death()
    check(state.room_id == "G3" and state.hp == 5 and state.charges == 0 and state.has_flag("veyra_sacrificed"), "both-phase death contract and canonical flags")
    state.enter_room("G4")
    check(state.load_game() and state.room_id == "G3" and state.hp == 5, "unfinished G4 reload returns to G3")
    var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(state.save_path))
    data.flags.echo_step_owned = false
    var bad := FileAccess.open(state.save_path, FileAccess.WRITE)
    bad.store_string(JSON.stringify(data))
    bad.close()
    check(not state.load_game(), "inconsistent save rejected")
    state.new_game()
    var junk := FileAccess.open(state.save_path, FileAccess.WRITE)
    junk.store_string("{broken")
    junk.close()
    check(not state.load_game(), "corrupt save rejected")
    state.new_game()
    var keyboard := InputEventKey.new()
    keyboard.physical_keycode = KEY_J
    check(InputMap.event_is_action(keyboard, "attack"), "keyboard slash bound")
    var joy := InputEventJoypadButton.new()
    joy.button_index = JOY_BUTTON_X
    check(InputMap.event_is_action(joy, "attack"), "controller slash bound")
    var stick := InputEventJoypadMotion.new()
    stick.axis = JOY_AXIS_LEFT_X
    stick.axis_value = 1.0
    check(InputMap.event_is_action(stick, "move_right"), "controller analog movement bound")
    check(not controls.rebind(&"attack", keyboard), "conflicting remap rejected")
    var scene: PackedScene = load("res://scenes/main.tscn")
    game = scene.instantiate()
    get_tree().root.add_child(game)
    await get_tree().physics_frame
    await get_tree().physics_frame
    check(game.player is Vessel and game.room.room_id == "M1", "project scene boots with playable player")
    check(game.get_child(0) == game.room, "room background renders behind player")
    var p: Vessel = game.player
    var start := p.global_position.x
    Input.action_press("move_right")
    for i in range(14): await get_tree().physics_frame
    Input.action_release("move_right")
    check(p.global_position.x > start + 8.0, "horizontal movement")
    for i in range(14): await get_tree().physics_frame
    Input.action_press("jump")
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_release("jump")
    check(p.velocity.y < 0.0, "jump action")
    state.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"])
    p.air_dash_available = true
    p.dash_cooldown = 0.0
    Input.action_press("dash")
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_release("dash")
    check(p.dash_timer > 0.0 and not p.air_dash_available, "Echo Step spends one air dash")
    p.dash_timer = 0.0
    p.dash_cooldown = 0.0
    p.air_dash_available = false
    Input.action_press("dash")
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_release("dash")
    check(p.dash_timer <= 0.0, "second airborne dash blocked")
    game.room.set_physics_process(false)
    p.global_position = Vector2(1075, 330)
    p.velocity = Vector2.ZERO
    Input.action_press("move_right")
    for i in range(16): await get_tree().physics_frame
    Input.action_release("move_right")
    check(p.is_on_wall(), "right wall contact acquired")
    for index in p.get_slide_collision_count():
        var contact := p.get_slide_collision(index)
        if absf(contact.get_normal().x) > 0.5:
            contact.get_collider().add_to_group("climbable_wall")
    Input.action_press("jump")
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_release("jump")
    check(p.velocity.x < 0.0 and p.facing == -1, "wall jump moves and faces away from right wall")
    game.room.set_physics_process(true)
    var enemy := OrdinaryEnemy.new()
    enemy.profile = EnemyProfile.for_kind(EnemyProfile.Kind.PAPER_DRUDGE)
    game.room.add_child(enemy)
    enemy.set_physics_process(false)
    enemy.set_player(p)
    p.global_position = Vector2(270, 450)
    p.facing = 1
    enemy.global_position = Vector2(299, 450)
    await get_tree().physics_frame
    var old_hp: int = enemy.hp
    state.hit_progress = 0
    state.charges = 0
    var combat: PlayerCombat = p.attack
    combat.phase = "active"
    combat.direction = "forward"
    combat.swing_id += 1
    combat.struck_ids.clear()
    combat._scan_hits(p)
    combat._scan_hits(p)
    check(enemy.hp == old_hp - 1 and state.hit_progress == 1, "physical slash hits once per target per swing")
    combat.swing_id += 1
    combat.struck_ids.clear()
    combat._scan_hits(p)
    check(enemy.hp == old_hp - 1 and state.hit_progress == 1, "enemy wound immunity denies duplicate charge")
    enemy.wound_time = 0.0
    combat.swing_id += 1
    combat.struck_ids.clear()
    combat._scan_hits(p)
    check(enemy.state == "dead" and state.hit_progress == 2, "enemy death stops harm and credits valid hit")
    combat.phase = "idle"
    var scout := OrdinaryEnemy.new()
    scout.profile = EnemyProfile.for_kind(EnemyProfile.Kind.PAPER_DRUDGE)
    game.room.add_child(scout)
    scout.global_position = p.global_position + Vector2(85, 0)
    scout.set_player(p)
    for i in range(8): await get_tree().physics_frame
    check(scout.state in ["engage", "telegraph", "active", "recover"], "enemy detects nearby player and engages")
    scout._enter("telegraph", 0.01)
    for i in range(4): await get_tree().physics_frame
    check(scout.state == "active" or scout.state == "recover", "enemy telegraph transitions to active threat")
    p.invulnerable = 0.0
    p.global_position = scout.global_position + Vector2(18, 0)
    scout.facing = 1
    scout.has_hit = false
    var dialogue_hp: int = state.hp
    controls.gameplay_locked = true
    scout._active_attack()
    check(state.hp == dialogue_hp, "mandatory dialogue blocks enemy harm")
    controls.gameplay_locked = false
    scout.queue_free()
    state.hp = 3
    state.hit_progress = 0
    for i in range(3): combat.register_successful_attack()
    check(state.charges == 1 and state.hit_progress == 0, "three landed hits earn one charge")
    for i in range(11): combat.register_successful_attack()
    check(state.charges == 3 and state.hit_progress == 0, "three-charge cap discards excess hits")
    combat.focusing = true
    combat.focus_timer = 0.7
    combat.interrupt_focus()
    check(state.hp == 3 and state.charges == 3 and combat.focus_timer == 0.0, "interrupted heal preserves charge and health")
    combat.focusing = true
    combat.focus_timer = 1.1
    combat.finish_focus()
    check(state.hp == 4 and state.charges == 2, "completed heal consumes one charge and restores one HP")
    state.hp = 5
    p.invulnerable = 0.0
    check(p.receive_damage(201), "first damage accepted")
    check(not p.receive_damage(201) and state.hp == 4, "immunity prevents duplicate damage")
    p.invulnerable = 0.0
    state.hp = 1
    state.reach_shrine("M2")
    state.hp = 1
    p.receive_damage(202)
    check(state.hp == 5 and state.room_id == "M2", "player death reloads selected shrine")
    p.invulnerable = 0.0
    state.hp = 3
    p.safe_position = Vector2(140, 450)
    p.global_position = Vector2(500, 600)
    p.recover_hazard()
    check(state.hp == 2 and p.global_position == Vector2(140, 450), "nonfatal hazard costs one HP and returns local safe ledge")
    p.invulnerable = 0.0
    state.hp = 1
    p.recover_hazard()
    check(state.hp == 5 and state.room_id == "M2" and p.global_position != Vector2(140, 450), "fatal hazard uses shrine, not stale local ledge")
    state.new_game()
    game._load_room("M4")
    var warden: MinibossPrototype = game.room.miniboss
    check(is_instance_valid(warden) and warden.hp == 10, "Warden prototype has approved strike target")
    warden.set_physics_process(false)
    for i in range(10):
        warden.wound_time = 0.0
        warden.receive_hit(i + 1, p)
    check(state.has_flag("warden_defeated") and state.has_flag("echo_step_owned") and state.has_flag("m4_exit_open"), "Warden defeat atomically unlocks Echo Step and exit")
    check(game.dialogue_key == "shore_voice", "Warden reward delivers Shore narrative")
    game._finish_dialogue()
    game._load_room("C3")
    var cantor: MinibossPrototype = game.room.miniboss
    check(is_instance_valid(cantor) and cantor.hp == 12, "Cantor prototype has approved strike target")
    cantor.set_physics_process(false)
    for i in range(12):
        cantor.wound_time = 0.0
        cantor.receive_hit(i + 1, p)
    check(state.has_flag("cantor_defeated") and state.has_flag("resonance_sigil_owned") and state.has_flag("c4_door_open"), "Cantor defeat atomically grants sigil and opens C4")
    game._load_room("C4")
    game._on_exit("G1")
    check(state.has_flag("glass_gate_open"), "sigil gate auto-recorded when entering G1")
    game._load_room("C1")
    var hurt_enemy: OrdinaryEnemy = game.room.spawned_enemies[0]
    hurt_enemy.set_physics_process(false)
    hurt_enemy.receive_hit(999, p)
    check(hurt_enemy.hp == 1, "setup partial enemy damage")
    game._load_room("C2")
    game._load_room("C1")
    check(game.room.spawned_enemies[0].hp == 1, "surviving enemy HP persists across room reentry")
    game._load_room("M1")
    game._on_exit("M2")
    check(game.room.room_id == "M2" and state.checkpoint == "M2", "connected room transition and shrine activation")
    game._load_room("M2")
    state.new_game()
    p.global_position = Vector2(780, 450)
    await get_tree().physics_frame
    await get_tree().physics_frame
    check(game.panel.visible and not state.has_flag("edda_met") and controls.gameplay_locked, "mandatory Edda scene auto-starts and locks passage")
    for i in range(game.dialogue_lines.size()):
        game.dialogue_index += 1
        if game.dialogue_index >= game.dialogue_lines.size():
            game._finish_dialogue()
    check(state.has_flag("edda_met") and not controls.gameplay_locked, "Edda flag commits only after complete exchange")
    var pause_event := InputEventKey.new()
    pause_event.physical_keycode = KEY_ESCAPE
    pause_event.pressed = true
    game._unhandled_input(pause_event)
    check(game.paused_menu and controls.gameplay_locked, "keyboard pause locks gameplay")
    game._unhandled_input(pause_event)
    check(not game.paused_menu and not controls.gameplay_locked, "keyboard pause resumes gameplay")
    state.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(state.save_path))
    print("RESULT ", passed, " passed, ", failed.size(), " failed")
    get_tree().quit(0 if failed.is_empty() else 1)
