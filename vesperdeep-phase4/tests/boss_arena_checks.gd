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

func frames(n: int) -> void:
    for i in range(n):
        await get_tree().physics_frame

func floor_at(x: float) -> bool:
    var query := PhysicsRayQueryParameters2D.create(Vector2(x, 430), Vector2(x, 530), 1)
    return not game.get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase3_boss_arena_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    RunState.enter_room("M4")
    game._load_room("M4")
    await frames(4)
    var boss: MinibossPrototype = game.room.miniboss
    var player: Vessel = game.player
    check(boss.kind == "warden" and boss.global_position == Vector2(480, 450) and boss.collision_mask & 1 == 1, "M4 Warden spawns centrally over solid floor")
    check(game.room.boss_active == false and not boss.is_physics_processing(), "Warden waits for player arena trigger")
    player.global_position = Vector2(950, 473)
    player.invulnerable = 100.0
    await frames(2)
    check(game.room.boss_active and boss.is_physics_processing(), "M4 approach activates Warden AI")
    boss.global_position = Vector2(280, 458)
    boss.velocity = Vector2.ZERO
    boss.phase = "idle"
    boss.timer = 0.6
    player.global_position = Vector2(680, 473)
    await frames(25)
    check(boss.global_position.x > 300 and boss.phase == "idle", "distant Warden closes space before telegraph rather than standing still")
    boss.move_index = 2
    boss.timer = 0.01
    await frames(2)
    check(boss.phase == "antic" and boss.move_index == 1 and absf(boss.warning_x - 680) < 30, "far target gets marked drop instead of out-of-range sweep")
    var marked_x := boss.warning_x
    player.global_position = Vector2(550, 473)
    await frames(10)
    check(boss.phase == "antic" and boss.warning_x == marked_x, "drop marker commits before impact and allows a dodge")
    player.invulnerable = 0.0
    var health_before := RunState.hp
    await frames(65)
    check(RunState.hp == health_before, "walking clear of the marked drop avoids damage through its active window")
    player.invulnerable = 100.0
    boss.hp = 5
    boss.phase = "recovery"
    boss.move_index = 1
    boss.timer = 0.01
    await frames(2)
    check(boss.phase == "idle" and boss.timer <= 0.3, "half-health Warden reduces idle reset without skipping recovery")
    boss.phase = "idle"
    boss.timer = 0.01
    boss.move_index = 0
    boss.attack_serial = 2
    boss.global_position = Vector2(350, 458)
    player.global_position = Vector2(395, 473)
    await frames(2)
    check(boss.phase == "antic" and boss.move_index == 2 and boss.timer > 0.55, "later Warden breaks a repeated close-range punish with a warned shove")
    boss.hp = 10
    boss.global_position = Vector2(350, 458)
    boss.velocity = Vector2.ZERO
    boss.phase = "active"
    boss.move_index = 2
    boss.facing = 1
    boss.timer = boss._times()[2][1]
    await frames(48)
    check(boss.global_position.x > 495 and boss.phase != "active", "committed shove reaches most of its advertised 170-pixel tell")
    boss.global_position = Vector2(770, 458)
    boss.velocity = Vector2.ZERO
    boss.phase = "active"
    boss.move_index = 2
    boss.facing = 1
    boss.timer = 0.45
    await frames(100)
    check(boss.global_position.y <= 458 and boss.is_on_floor(), "Warden charge cannot fall through M4 combat floor")
    check(boss.global_position.x > 700 and boss.global_position.x < 810 and boss.global_position.y < 490 and boss.phase != "dead", "Warden remains in reachable arena and AI continues")
    check(floor_at(790) and not floor_at(940) and not RunState.gate_open("M4", "C1"), "M4 arena is flat; dash gap lies beyond the locked exit")
    boss.global_position = Vector2(770, 458)
    boss.phase = "active"
    boss.move_index = 2
    boss.facing = 1
    boss.timer = 0.45
    await frames(40)
    check(boss.global_position.x <= 785 and boss.is_on_floor(), "right arena wall stops Warden shove before dash gap")
    boss.global_position = Vector2(120, 458)
    boss.phase = "active"
    boss.move_index = 2
    boss.facing = -1
    boss.timer = 0.45
    await frames(40)
    check(boss.global_position.x >= 110 and boss.is_on_floor(), "left arena wall stops Warden shove")
    boss.global_position = Vector2(480, 458)
    player.global_position = Vector2(500, 473)
    boss.phase = "idle"
    boss.timer = 99.0
    boss.receive_hit(12345, player)
    await frames(50)
    check(absf(boss.global_position.x - 480) < 30, "Warden knockback settles instead of drifting to a rear wall")
    boss.global_position = Vector2(670, 650)
    await frames(2)
    check(boss.hp == 9 and not RunState.has_flag("warden_defeated") and not RunState.has_flag("echo_step_owned"), "offscreen boss position cannot trigger victory or rewards")
    RunState.death()
    await frames(2)
    check(game.room.room_id == "M2" and RunState.checkpoint == "M2" and not RunState.has_flag("warden_defeated"), "failed M4 encounter respawns at M2 without awarding victory")
    RunState.enter_room("M4")
    game._load_room("M4")
    boss = game.room.miniboss
    player = game.player
    check(is_instance_valid(boss) and boss.hp == 10 and floor_at(790), "retry recreates full-health Warden and safe combat floor")
    player.global_position = Vector2(620, 473)
    player.invulnerable = 100.0
    await frames(3)
    var successful_slashes := 0
    for attempt in range(30):
        if not is_instance_valid(boss) or boss.is_queued_for_deletion():
            break
        var from_right := boss.global_position.x > 830.0 and boss.global_position.x < 990.0
        player.global_position = boss.global_position + Vector2(42 if from_right else -42, 0)
        player.facing = -1 if from_right else 1
        player.velocity = Vector2.ZERO
        var previous_hp := boss.hp
        if player.attack.begin_attack():
            await frames(30)
            if is_instance_valid(boss) and boss.hp < previous_hp:
                successful_slashes += 1
            elif not is_instance_valid(boss):
                successful_slashes += 1
    check(successful_slashes >= 10 and RunState.has_flag("warden_defeated"), "ten actual directional slashes defeat Warden")
    check(RunState.has_flag("echo_step_owned") and RunState.has_flag("shore_relay_off") and RunState.has_flag("m4_exit_open") and RunState.gate_open("M4", "C1"), "Warden victory atomically grants Echo Step and opens approved route")
    check(floor_at(790) and not floor_at(940), "Warden defeat preserves arena floor and pre-existing exit gap")
    check(game.dialogue_key == "shore_voice", "post-Warden narrative pauses play until read")
    game._finish_dialogue()
    player.global_position = Vector2(790, 473)
    player.velocity = Vector2.ZERO
    player.facing = 1
    Input.action_press("move_right")
    Input.action_press("jump")
    await frames(28)
    Input.action_release("jump")
    Input.action_press("dash")
    await frames(2)
    Input.action_release("dash")
    await frames(70)
    Input.action_release("move_right")
    check(game.room.room_id == "C1" and RunState.checkpoint == "C1", "actual jump and Echo Step cross exit gap to C1 shrine")
    game._load_room("M4")
    await frames(2)
    check(not is_instance_valid(game.room.miniboss) and floor_at(790) and not floor_at(940), "victory remains durable and floor intact across M4 reload")
    # C3 uses the same boss class but has a continuous floor. Ensure no analogous fall.
    game._load_room("C3")
    player.global_position = Vector2(950, 473)
    player.invulnerable = 100.0
    await frames(2)
    var cantor: MinibossPrototype = game.room.miniboss
    await frames(150)
    check(cantor.kind == "cantor" and cantor.global_position.y <= 458 and cantor.is_on_floor() and cantor.attack_serial > 0, "C3 Cantor remains grounded and progresses through attacks")
    cantor.global_position = Vector2(660, 458)
    cantor.phase = "idle"
    cantor.timer = 99.0
    cantor.receive_hit(54321, player)
    await frames(50)
    check(absf(cantor.global_position.x - 660) < 30 and cantor.is_on_floor(), "C3 Cantor knockback settles on its continuous floor")
    cantor.global_position = Vector2(660, 650)
    await frames(2)
    check(cantor.hp == 11 and not RunState.has_flag("cantor_defeated") and not RunState.has_flag("double_jump_owned"), "C3 environmental displacement cannot grant Sigil or double jump")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("BOSS_ARENA_RESULT ", passed, " passed, ", failures.size(), " failed")
    get_tree().quit(0 if failures.is_empty() else 1)
