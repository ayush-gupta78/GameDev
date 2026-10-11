extends Node

var passed: int = 0
var failed: Array[String] = []
var game: Node2D
var player: Vessel

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failed.append(label)
        push_error("FAIL " + label)

func frames(count: int) -> void:
    for i in range(count):
        await get_tree().physics_frame

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    await get_tree().process_frame
    RunState.save_path = "user://phase3_physics_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    player = game.player
    await frames(6)
    var start_x := player.global_position.x
    Input.action_press("move_right")
    await frames(3)
    var early_speed := player.velocity.x
    await frames(18)
    var late_speed := player.velocity.x
    Input.action_release("move_right")
    await frames(10)
    check(player.global_position.x > start_x and early_speed > 0 and late_speed > early_speed and late_speed <= player.tuning.run_speed, "ground acceleration and max speed")
    check(absf(player.velocity.x) < absf(late_speed), "ground deceleration")
    player.global_position = Vector2(260, 473)
    player.velocity = Vector2.ZERO
    await frames(3)
    Input.action_press("jump")
    await frames(2)
    var held_speed := player.velocity.y
    Input.action_release("jump")
    await frames(2)
    check(held_speed < -100.0 and player.velocity.y > held_speed * 0.7, "early jump release shortens arc")
    # Airborne input shortly before landing must be buffered to a second jump.
    player.global_position = Vector2(270, 446)
    player.velocity = Vector2(0, 260)
    await frames(2)
    Input.action_press("jump")
    await frames(8)
    Input.action_release("jump")
    check(player.velocity.y < -100.0, "jump buffer fires on imminent landing")
    # Coyote: G3's open gap is separate from the enclosed M4 boss deck.
    game._load_room("G3")
    game.room.set_physics_process(false)
    if is_instance_valid(game.room.miniboss):
        game.room.miniboss.set_physics_process(false)
    player.global_position = Vector2(780, 473)
    player.velocity = Vector2.ZERO
    await frames(3)
    player.global_position = Vector2(850, 473)
    await frames(2)
    var off_floor := not player.is_on_floor()
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    check(off_floor and player.velocity.y < -100.0, "coyote jump after recent ledge departure")
    game.room.set_physics_process(true)
    # Actual grounded Focus: threshold must not award early.
    player.global_position = Vector2(280, 473)
    player.velocity = Vector2.ZERO
    player.invulnerable = 0.0
    await frames(4)
    RunState.hp = 4
    RunState.charges = 1
    Input.action_press("heal")
    await frames(60)
    check(RunState.hp == 4 and RunState.charges == 1, "Focus not complete before 1.1 s")
    await frames(10)
    Input.action_release("heal")
    check(RunState.hp == 5 and RunState.charges == 0, "Focus completes after 1.1 s at 60 Hz")
    RunState.hp = 4
    RunState.charges = 1
    Input.action_press("heal")
    await frames(25)
    Input.action_press("move_right")
    await frames(2)
    Input.action_release("move_right")
    Input.action_release("heal")
    check(RunState.hp == 4 and RunState.charges == 1 and not player.attack.is_focusing(), "movement interrupts real-time Focus without spending charge")
    # Room camera bounds and two enemy placements stay available in the scaffold.
    check(game.camera.limit_left == 0 and game.camera.limit_right == 1100 and game.camera.limit_bottom == 540, "camera bounded to test room")
    game._load_room("C2")
    check(game.room.spawned_enemies.size() == 2, "C2 two approved archetypes coexist")
    var needle: OrdinaryEnemy = game.room.spawned_enemies[0]
    needle.set_physics_process(false)
    needle._enter("active", needle.profile.active_seconds)
    check(is_instance_valid(needle.projectile) and needle.projectile.get_node_or_null("VisibleBody") is Polygon2D, "Needle projectile has a visible body")
    game._load_room("G2")
    check(game.room.spawned_enemies.size() == 2, "G2 two Glass Moths coexist")
    var moth: OrdinaryEnemy = game.room.spawned_enemies[0]
    moth.set_physics_process(false)
    player.global_position = moth.global_position + Vector2(100, 20)
    moth._enter("telegraph", moth.profile.telegraph_seconds)
    moth._enter("active", moth.profile.active_seconds)
    moth.global_position.x = moth.committed_target.x + 5
    moth._physics_process(1.0 / 60.0)
    check(moth.velocity.x > 0, "Moth committed dive does not reverse after passing target")
    moth.global_position = Vector2(390, 400)
    moth._enter("idle", 0.0)
    moth.set_physics_process(true)
    player.invulnerable = 4.0
    player.global_position = Vector2(520, 450)
    await frames(125)
    check(game.room.spawned_enemies[0].attack_serial > 0 and game.room.spawned_enemies[1].attack_serial > 0, "two Moths concurrently detect, warn and attack")
    game._load_room("C1")
    player.global_position = Vector2(390, 430)
    player.velocity = Vector2.ZERO
    await frames(2)
    var drudge: OrdinaryEnemy = game.room.spawned_enemies[0]
    drudge.set_physics_process(false)
    player.attack.direction = "down"
    player.attack.swing_id += 1
    player.attack.struck_ids.clear()
    player.attack._scan_hits(player)
    check(drudge.hp == 1 and player.velocity.y == -player.tuning.pogo_speed, "downward slash inflicts one hit and pogo impulse")
    var overhead := OrdinaryEnemy.new()
    game.room.add_child(overhead)
    overhead.global_position = Vector2(610, 415)
    overhead.set_physics_process(false)
    player.global_position = Vector2(610, 455)
    await frames(2)
    player.attack.direction = "up"
    player.attack.swing_id += 1
    player.attack.struck_ids.clear()
    player.attack._scan_hits(player)
    check(overhead.hp == 1, "upward slash reaches overhead enemy")
    game._load_room("M3")
    player.global_position = Vector2(390, 473)
    await frames(110)
    check(game.room.spawned_enemies[0].attack_serial > 0, "Drudge engages and completes a warned attack")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("PHYSICS_RESULT ", passed, " passed, ", failed.size(), " failed")
    get_tree().quit(0 if failed.is_empty() else 1)
