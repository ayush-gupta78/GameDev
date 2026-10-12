extends Node

var passed := 0
var failures: Array[String] = []
var game: Node2D

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failures.append(label)
        push_error("FAIL " + label)

func frames(count: int) -> void:
    for i in range(count):
        await get_tree().physics_frame

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_shore_test.json"
    RunState.new_game()
    check(ProjectSettings.get_setting("application/config/name") == "Vesperdeep — Phase 4", "Phase 4 user data is isolated from accepted Phase 3")

    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await frames(3)
    check(game.room.room_id == "M1" and game.room.get_node_or_null("ShorePlatforms") != null, "M1 has authored jump platforms")
    check(game.get("objective_label") != null and "House" in game.get("objective_label").text, "M1 HUD shows current region objective")
    var dip := PhysicsRayQueryParameters2D.create(Vector2(145, 485), Vector2(145, 535), 1)
    var dip_hit: Dictionary = game.get_world_2d().direct_space_state.intersect_ray(dip)
    check(not dip_hit.is_empty() and dip_hit.position.y >= 510, "M1 has a shallow nonlethal reversible drop")
    var target: Node = game.room.get_node_or_null("HangingTarget")
    check(target != null, "M1 has a harmless slash target")
    if target != null:
        var before := RunState.hit_progress
        check(not target.receive_hit(1, game.player) and target.get("flash") > 0.0 and RunState.hit_progress == before, "training target reacts but cannot farm healing")
    game.player.global_position = Vector2(870, 473)
    await frames(2)
    check(game.dialogue_key == "m1_intro" and not RunState.has_flag("m1_intro_seen"), "M1 listener and arch scene starts at the exit, not on boot")
    game._finish_dialogue()
    check(RunState.has_flag("m1_intro_seen"), "M1 opening commits only after entire exchange")
    game._load_room("M1")
    game.player.global_position = Vector2(870, 473)
    await frames(2)
    check(not game.panel.visible, "M1 one-time scene stays completed on revisit")
    game._load_room("M2")
    await frames(2)
    check(game.room.get_node_or_null("EddaPip") != null, "M2 introduces Edda and Pip at the passage")
    game._load_room("M3")
    await frames(2)
    check(game.room.get_node_or_null("TollLatchHint") != null, "M3 approach latch is visible")
    check(game.room.get_node_or_null("ChimneyWalls") != null, "M3 has a dedicated wall-jump side shaft")
    game.player.global_position = Vector2(235, 473)
    game.player.velocity = Vector2.ZERO
    await frames(3)
    Input.action_press("move_right")
    Input.action_press("jump")
    await frames(12)
    Input.action_release("jump")
    await frames(2)
    Input.action_release("move_right")
    check(game.player.is_on_wall() and game.player.global_position.y < 445, "actual M3 chimney wall contact supports wall-jump training")
    var climbed := false
    for tick in range(30):
        await frames(1)
        climbed = climbed or game.player.state == "wall_slide"
    check(climbed, "M3's marked shaft supports actual wall sliding")
    game.player.invulnerable = 100.0
    game.player.global_position = Vector2(450, 400)
    game.player.velocity = Vector2.ZERO
    await frames(3)
    Input.action_press("move_right")
    Input.action_press("jump")
    await frames(24)
    Input.action_release("jump")
    await frames(28)
    Input.action_release("move_right")
    check(game.player.is_on_floor() and game.player.global_position.y < 355, "starting jump reaches M3 middle shelf")
    game.player.global_position = Vector2(610, 338)
    game.player.velocity = Vector2.ZERO
    await frames(3)
    Input.action_press("move_right")
    Input.action_press("jump")
    await frames(24)
    Input.action_release("jump")
    await frames(24)
    Input.action_release("move_right")
    check(game.player.global_position.y < 290 and game.player.is_on_floor(), "M3 upper shelf reachable without Double Jump")
    game.player.global_position = Vector2(740, 473)
    await frames(3)
    Input.action_press("interact")
    await frames(2)
    Input.action_release("interact")
    check(not game.panel.visible, "Rell optional note cannot be read through upper shelf")
    game.player.global_position = Vector2(740, 273)
    await frames(3)
    Input.action_press("interact")
    await frames(2)
    Input.action_release("interact")
    check(game.dialogue_key == "rell_note", "upper exploration reveals optional Rell note")
    game._finish_dialogue()
    game.player.global_position = Vector2(850, 473)
    await frames(3)
    check(not RunState.has_flag("m3_toll_latch_open") and not RunState.gate_open("M3", "M4"), "M3 Toll latch requires a deliberate interaction")
    Input.action_press("interact")
    await frames(2)
    Input.action_release("interact")
    check(RunState.has_flag("m3_toll_latch_open"), "interacting with approach latch opens the M4 route")
    RunState.commit(["edda_met"])
    RunState.enter_room("M4")
    game._load_room("M4")
    check(game.room.arena_walls.is_empty(), "M4 entrance remains returnable before boss engagement")
    var boss: MinibossPrototype = game.room.miniboss
    game.player.global_position = Vector2(460, 473)
    await frames(2)
    check(boss.phase == "intro" and game.get("boss_label") != null and game.get("boss_label").visible, "Warden starts with non-damaging intro and visible health bar")
    boss.hp = 5
    check(boss._times()[0][2] < MinibossPrototype.WARDEN[0][2], "Warden half-health shortens recovery, not the warning")
    boss.hp = 10
    game.player.invulnerable = 100.0
    var patterns: Dictionary = {}
    for tick in range(650):
        await frames(1)
        if boss.phase in ["antic", "active"]:
            patterns[boss.move_index] = true
    check(patterns.has(0) and patterns.has(1) and patterns.has(2) and boss.attack_serial >= 3, "live Warden cycles through all three telegraphed moves")
    boss.set_physics_process(false)
    for strike in range(10):
        boss.wound_time = 0.0
        boss.receive_hit(strike + 100, game.player)
    check(game.dialogue_key == "shore_voice" and not RunState.has_flag("shore_voice_heard"), "legitimate Warden defeat triggers one Listener story beat")
    get_tree().paused = false
    Controls.gameplay_locked = false
    game.queue_free()
    await frames(2)
    check(RunState.load_game() and RunState.has_flag("echo_step_owned") and not RunState.has_flag("shore_voice_heard"), "interrupted post-boss scene retains reward but not unspoken story")
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await frames(2)
    check(game.dialogue_key == "shore_voice", "unfinished post-boss story replays after relaunch")
    game._finish_dialogue()
    check(RunState.has_flag("shore_voice_heard") and RunState.has_flag("echo_step_owned"), "narrative completion persists without delaying reward")
    game._load_room("M4")
    check(not game.panel.visible, "completed Shore voice does not replay on return")
    check(RunState.load_game() and RunState.has_flag("m1_intro_seen") and RunState.has_flag("shore_voice_heard"), "one-time Shore events survive independent save reload")
    game._load_room("C1")
    game.room.set_physics_process(false)
    game.player.global_position = Vector2(35, 180)
    game.player.velocity = Vector2.ZERO
    game.player.coyote = 0.0
    Input.action_press("move_left")
    await frames(28)
    Input.action_release("move_left")
    check(game.player.is_on_wall() and game.player.state == "fall" and game.player.velocity.y > game.player.tuning.wall_slide_speed + 30, "actual C1 ordinary boundary falls naturally without wall stick")
    var old_save: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RunState.save_path))
    old_save.version = 2
    old_save.flags.erase("m1_intro_seen")
    old_save.flags.erase("shore_voice_heard")
    var legacy := FileAccess.open(RunState.save_path, FileAccess.WRITE)
    legacy.store_string(JSON.stringify(old_save))
    legacy.close()
    check(RunState.load_game() and RunState.has_flag("m1_intro_seen") and RunState.has_flag("shore_voice_heard") and JSON.parse_string(FileAccess.get_file_as_string(RunState.save_path)).version == RunState.SAVE_VERSION, "accepted Phase 3 v2 saves migrate to Phase 4 without replaying old scenes")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("SHORE_SLICE_RESULT ", passed, " passed, ", failures.size(), " failed")
    get_tree().quit(0 if failures.is_empty() else 1)
