extends Node

var game: Node2D
var passed := 0
var failed: Array[String] = []

func check(condition: bool, label: String) -> void:
    if condition:
        passed += 1
        print("PASS ", label)
    else:
        failed.append(label)
        push_error("FAIL " + label)

func frames(n: int) -> void:
    for tick in range(n):
        await get_tree().physics_frame

func walk_until(next_room: String, limit: int = 480) -> bool:
    Input.action_press("move_right")
    for tick in range(limit):
        if game.room.room_id == next_room or game.panel.visible:
            break
        if game.room.room_id == "M1" and game.player.global_position.x > 130 and game.player.global_position.x < 195 and game.player.is_on_floor():
            Input.action_press("jump")
        elif Input.is_action_pressed("jump") and game.player.global_position.x > 220:
            Input.action_release("jump")
        await get_tree().physics_frame
    Input.action_release("move_right")
    Input.action_release("jump")
    return game.room.room_id == next_room

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_route_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await frames(3)
    check(game.room.room_id == "M1" and RunState.checkpoint == "M1", "fresh run enters M1")
    await walk_until("M2")
    check(game.dialogue_key == "m1_intro" and not RunState.has_flag("m1_intro_seen"), "M1 exit presents first narrative beat")
    game._finish_dialogue()
    check(await walk_until("M2"), "starting movement and jump cross M1 to M2")
    check(RunState.checkpoint == "M2", "M2 shrine activates before first boss")
    await walk_until("M3")
    check(game.dialogue_key == "edda" and not RunState.gate_open("M2", "M3"), "Edda/Pip cannot be bypassed")
    game._finish_dialogue()
    check(await walk_until("M3"), "completed dialogue opens the M3 route")
    check(game.room.spawned_enemies.size() == 3 and game.room.spawned_enemies[2].profile.kind == EnemyProfile.Kind.GLASS_MOTH, "M3 combines two Drudges with one Moth")
    game.player.invulnerable = 100.0 # Route geometry test; enemy combat is covered separately.
    Input.action_press("move_right")
    for tick in range(300):
        if game.player.global_position.x > 845:
            break
        await get_tree().physics_frame
    Input.action_release("move_right")
    check(not RunState.gate_open("M3", "M4"), "M3 remains gated until the visible Toll latch is used")
    Input.action_press("interact")
    await frames(2)
    Input.action_release("interact")
    check(RunState.has_flag("m3_toll_latch_open"), "player operates M3 Toll latch")
    check(await walk_until("M4"), "M3 platforms and enemies do not block the mandatory route")
    check(RunState.has_flag("m3_toll_latch_open") and RunState.checkpoint == "M2", "approach latch and retry shrine persist")
    var warden: MinibossPrototype = game.room.miniboss
    game.player.global_position = Vector2(520, 473)
    await frames(3)
    check(game.room.boss_active and is_instance_valid(warden), "boss encounter locks after approach")
    var hits := 0
    for attempt in range(34):
        if not is_instance_valid(warden) or warden.is_queued_for_deletion():
            break
        game.player.global_position = warden.global_position + Vector2(-42, 0)
        game.player.facing = 1
        game.player.velocity = Vector2.ZERO
        var before := warden.hp
        if game.player.attack.begin_attack():
            await frames(30)
            if not is_instance_valid(warden) or warden.hp < before:
                hits += 1
    check(hits >= 10 and RunState.has_flag("echo_step_owned"), "ten accepted strikes defeat Warden and award dash")
    check(game.dialogue_key == "shore_voice", "victory triggers story and freezes traversal until read")
    game._finish_dialogue()
    game.player.global_position = Vector2(790, 473)
    game.player.velocity = Vector2.ZERO
    game.player.facing = 1
    Input.action_press("move_right")
    Input.action_press("jump")
    await frames(28)
    Input.action_release("jump")
    Input.action_press("dash")
    await frames(2)
    Input.action_release("dash")
    await frames(70)
    Input.action_release("move_right")
    check(game.room.room_id == "C1" and RunState.checkpoint == "C1", "physical jump plus Echo Step reaches C1 exit shrine")
    check(game.room.get_node_or_null("BellEngineClue") != null, "C1 arrival reveals Bell Engine objective")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("SHORE_ROUTE_RESULT ", passed, " passed, ", failed.size(), " failed")
    get_tree().quit(0 if failed.is_empty() else 1)
