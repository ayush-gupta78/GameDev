extends Node

var passed := 0
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

func frames(n: int) -> void:
    for i in range(n):
        await get_tree().physics_frame

func tap_jump() -> void:
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    await frames(2)

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase3_double_jump_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    player = game.player
    await frames(4)
    check(not RunState.has_flag("double_jump_owned"), "fresh game cannot double jump")
    player.global_position = Vector2(300, 473)
    await frames(3)
    Input.action_press("jump")
    await frames(16)
    Input.action_release("jump")
    await frames(2)
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    check(player.air_jump_available and player.wing_flash <= 0.0, "pre-C3 second press cannot activate locked ability")
    await frames(2)
    game._load_room("C3")
    game.room._on_miniboss_defeated("cantor")
    check(RunState.has_flag("double_jump_owned") and RunState.has_flag("resonance_sigil_owned"), "Cantor grants double jump atomically with Sigil")
    check("jump twice" in game.hint_label.text, "HUD explains unlocked second jump")
    game._load_room("C1")
    player.global_position = Vector2(300, 473)
    player.velocity = Vector2.ZERO
    player.jump_buffer = 0.0
    await frames(4)
    Input.action_press("jump")
    await frames(16)
    check(player.velocity.y < 0.0 and not player.is_on_floor(), "ground jump works and holding does not automatically chain")
    Input.action_release("jump")
    await frames(2)
    Input.action_press("jump")
    await frames(2)
    check(player.velocity.y < -240.0 and not player.is_on_floor(), "second distinct airborne press launches upward")
    Input.action_release("jump")
    await frames(2)
    var airborne_x := player.global_position.x
    Input.action_press("move_right")
    await frames(6)
    Input.action_release("move_right")
    check(player.global_position.x > airborne_x, "horizontal steering remains active after double jump")
    var before_third := player.velocity.y
    Input.action_press("jump")
    await frames(2)
    check(player.velocity.y >= before_third, "third airborne press cannot jump again")
    Input.action_release("jump")
    await frames(70)
    check(player.is_on_floor(), "player lands without clipping through floor")
    await tap_jump()
    await frames(10)
    var before_reset_jump := player.velocity.y
    await tap_jump()
    check(player.velocity.y < before_reset_jump, "landing restores the second jump")
    Input.action_release("jump")
    game._load_room("G3")
    player.global_position = Vector2(780, 473)
    player.velocity = Vector2.ZERO
    await frames(3)
    player.global_position = Vector2(850, 473)
    await frames(9)
    var falling := player.velocity.y > 0.0 and not player.is_on_floor()
    Input.action_press("jump")
    await frames(2)
    var ledge_leap := player.velocity.y
    Input.action_release("jump")
    check(falling and ledge_leap < -200.0, "walking off a ledge permits one airborne jump")
    game._load_room("M3")
    player.global_position = Vector2(400, 460)
    player.velocity = Vector2.ZERO
    player.coyote = 0.0
    player.air_jump_available = true
    await frames(2)
    Input.action_press("jump")
    await frames(12)
    Input.action_release("jump")
    check(player.global_position.y >= 453, "double jump under M3 platform cannot clip through ceiling")
    game._load_room("C1")
    player.global_position = Vector2(1075, 330)
    player.velocity = Vector2.ZERO
    player.air_jump_available = false
    await frames(2)
    Input.action_press("move_right")
    await frames(16)
    for index in player.get_slide_collision_count():
        var contact := player.get_slide_collision(index)
        if absf(contact.get_normal().x) > 0.5:
            contact.get_collider().add_to_group("climbable_wall")
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    Input.action_release("move_right")
    check(player.air_jump_available and player.velocity.y < 0, "wall jump restores double jump availability")
    await frames(2)
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    check(not player.air_jump_available and player.wing_flash > 0.0, "double jump after wall jump plays temporary wing effect")
    RunState.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"])
    Input.action_press("dash")
    await frames(2)
    Input.action_release("dash")
    check(player.dash_timer > 0.0 and not player.air_jump_available, "Echo Step follows double jump without restoring another jump")
    player.pogo()
    check(not player.air_jump_available and player.velocity.y == -player.tuning.pogo_speed, "pogo bounce does not create repeated midair jumps")
    check(InputMap.action_get_events("jump").any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton), "double jump uses the existing controller Jump action")
    RunState.save_game()
    RunState.flags["double_jump_owned"] = false
    check(RunState.load_game() and RunState.has_flag("double_jump_owned"), "double-jump unlock survives save/load")
    var old_save: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RunState.save_path))
    old_save.version = 1
    old_save.flags.erase("double_jump_owned")
    old_save.flags.erase("m1_intro_seen")
    old_save.flags.erase("shore_voice_heard")
    var legacy_file := FileAccess.open(RunState.save_path, FileAccess.WRITE)
    legacy_file.store_string(JSON.stringify(old_save))
    legacy_file.close()
    check(RunState.load_game() and RunState.has_flag("double_jump_owned") and JSON.parse_string(FileAccess.get_file_as_string(RunState.save_path)).version == RunState.SAVE_VERSION, "v1 Cantor saves migrate without losing unlocked ability")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("DOUBLE_JUMP_RESULT ", passed, " passed, ", failed.size(), " failed")
    get_tree().quit(0 if failed.is_empty() else 1)
