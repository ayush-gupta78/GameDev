extends Node

var passed := 0
var failed := 0
var game: Node2D

func check(condition: bool, label: String) -> void:
    if condition:
        passed += 1
        print("PASS ", label)
    else:
        failed += 1
        push_error("FAIL " + label)

func frames(count: int) -> void:
    for i in range(count):
        await get_tree().physics_frame

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase3_review_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await frames(3)
    for id in ["M3", "C2", "G2"]:
        game._load_room(id)
        for i in range(game.room.spawned_enemies.size()):
            var enemy: OrdinaryEnemy = game.room.spawned_enemies[i]
            var spawn: Vector2 = [Vector2(400, 465), Vector2(570, 465), Vector2(720, 365)][i] if id == "M3" else Vector2(390 + i * 270, 400 if enemy.profile.kind == EnemyProfile.Kind.GLASS_MOTH else 465)
            var home: Vector2 = spawn + (Vector2(0, -15) if enemy.profile.kind == EnemyProfile.Kind.GLASS_MOTH else Vector2.ZERO)
            check(enemy.global_position == spawn, id + " enemy " + str(i) + " spawns at designated world point")
            check(enemy.origin == home, id + " enemy " + str(i) + " has designated home point")
    game._load_room("G2")
    var moth: OrdinaryEnemy = game.room.spawned_enemies[0]
    moth.set_physics_process(false)
    moth.global_position = Vector2(100, 380)
    var before := moth.global_position.distance_to(moth.origin)
    moth._enter("recover", 0.5)
    moth._physics_process(1.0 / 60.0)
    check(moth.global_position.distance_to(Vector2(390, 385)) < Vector2(100, 380).distance_to(Vector2(390, 385)), "Moth recovery moves toward intended elevated spawn home")
    check(moth.global_position.distance_to(moth.origin) < before, "Moth recovery closes distance to stored home")
    game._load_room("C2")
    var player: Vessel = game.player
    var needle: OrdinaryEnemy = game.room.spawned_enemies[0]
    needle.set_physics_process(false)
    player.global_position = Vector2(280, 300)
    player.velocity = Vector2(0, -100)
    await frames(2)
    var pause_event := InputEventKey.new()
    pause_event.physical_keycode = KEY_ESCAPE
    pause_event.pressed = true
    game._unhandled_input(pause_event)
    check(get_tree().paused and game.paused_menu, "pause menu freezes SceneTree")
    var air_position := player.global_position
    var air_velocity := player.velocity
    var air_immunity := player.invulnerable
    await frames(20)
    check(player.global_position == air_position and player.velocity == air_velocity, "midair pause freezes gravity and movement")
    check(player.invulnerable == air_immunity, "pause freezes player immunity timer")
    game._unhandled_input(pause_event)
    await frames(3)
    check(not get_tree().paused and player.global_position != air_position, "resuming midair restores player physics")
    player.global_position = Vector2(280, 300)
    player.dash_timer = 0.16
    player.attack.phase = "active"
    player.attack.timer = 0.08
    needle._enter("active", needle.profile.active_seconds)
    await frames(2)
    var note := needle.projectile
    check(is_instance_valid(note), "Needle projectile created before pause")
    game._unhandled_input(pause_event)
    var dash_position := player.global_position
    var dash_time := player.dash_timer
    var attack_time := player.attack.timer
    var note_position := note.global_position
    var health := RunState.hp
    await frames(20)
    check(player.global_position == dash_position and player.dash_timer == dash_time, "pause freezes active Echo Step")
    check(player.attack.timer == attack_time and needle.state_timer == needle.profile.active_seconds, "pause freezes combat and enemy timers")
    check(note.global_position == note_position and RunState.hp == health, "pause freezes in-flight projectile and damage")
    game._unhandled_input(pause_event)
    await frames(3)
    check(not get_tree().paused and player.dash_timer < dash_time and (player.attack.phase != "active" or player.attack.timer < attack_time), "dash and attack states resume")
    check(note.global_position != note_position, "projectile tween resumes after pause")
    game._on_interaction("thren")
    check(game.panel.visible and get_tree().paused and not game.paused_menu, "mandatory dialogue freezes world but is not pause menu")
    var advance := InputEventKey.new()
    advance.physical_keycode = KEY_E
    advance.pressed = true
    game.get_viewport().push_input(advance)
    await get_tree().process_frame
    check(game.dialogue_index == 1 and get_tree().paused, "routed Interact event advances dialogue while world is paused")
    game._unhandled_input(pause_event)
    check(not game.paused_menu and game.panel.visible, "pause key cannot displace mandatory dialogue")
    game._finish_dialogue()
    check(not get_tree().paused and not Controls.gameplay_locked and RunState.has_flag("thren_met"), "finishing dialogue releases world and commits flag")
    game.get_viewport().push_input(pause_event)
    await get_tree().process_frame
    check(get_tree().paused and game.paused_menu, "routed Pause event opens menu")
    var back := InputEventKey.new()
    back.physical_keycode = KEY_BACKSPACE
    back.pressed = true
    game.get_viewport().push_input(back)
    await get_tree().process_frame
    check(not get_tree().paused and not game.paused_menu, "routed fallback Back event exits paused menu")
    game._load_room("M1")
    player.global_position = Vector2(280, 473)
    player.velocity = Vector2.ZERO
    player.attack.phase = "idle"
    player.invulnerable = 100.0 # Isolate pause/Focus timing from the new M1 combat encounter.
    RunState.hp = 4
    RunState.charges = 1
    await frames(4)
    Input.action_press("heal")
    await frames(20)
    check(player.attack.is_focusing(), "held Focus active before pause")
    var focus_before := player.attack.focus_timer
    game._unhandled_input(pause_event)
    await frames(65)
    check(player.attack.is_focusing() and player.attack.focus_timer == focus_before and RunState.hp == 4 and RunState.charges == 1, "pause freezes incomplete Focus without charge loss")
    game._unhandled_input(pause_event)
    await frames(65)
    Input.action_release("heal")
    check(RunState.hp == 5 and RunState.charges == 0, "Focus completes after resuming remaining hold")
    RunState.hp = 4
    player.invulnerable = 0.0
    player.global_position = Vector2(280, 600)
    game._unhandled_input(pause_event)
    await frames(10)
    check(RunState.hp == 4, "paused out-of-bounds player does not take hazard damage")
    game._unhandled_input(pause_event)
    await frames(3)
    check(RunState.hp == 3 and player.global_position.y < 570, "hazard resolves only after unpause")
    game.queue_free()
    RunState.new_game()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("REVIEW_RESULT ", passed, " passed, ", failed, " failed")
    get_tree().quit(0 if failed == 0 else 1)
