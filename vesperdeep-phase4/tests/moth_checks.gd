extends Node

var failed := 0

func frames(n: int) -> void:
    for i in range(n):
        await get_tree().physics_frame

func check(condition: bool, label: String) -> void:
    if condition:
        print("PASS ", label)
    else:
        failed += 1
        push_error("FAIL " + label)

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://moth_checks.json"
    RunState.new_game()
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    game._load_room("G2")
    game.room.set_physics_process(false)
    var player: Vessel = game.player
    player.set_physics_process(false)
    player.global_position = Vector2(390, 430)
    var moth: OrdinaryEnemy = game.room.spawned_enemies[0]
    game.room.spawned_enemies[1].set_physics_process(false)
    moth.global_position = Vector2(390, 465)
    moth._enter("recover", 2.0)
    await frames(60)
    check(moth.global_position.y < 420, "Moth recovery passes contact rather than sticking beneath player")
    moth.set_physics_process(false)
    moth.global_position = moth.origin
    player.global_position = moth.origin + Vector2(180, 20)
    player.contact_stagger = 0.0 # Player physics is disabled in this flight probe.
    moth._enter("telegraph", moth.profile.telegraph_seconds)
    check(moth.lane.get_point_position(1).distance_to(moth.committed_target - moth.global_position) < 2.0, "full committed dive path is visible during warning")
    player.global_position = moth.origin + Vector2(110, 88)
    moth._enter("telegraph", moth.profile.telegraph_seconds)
    moth._enter("active", moth.profile.active_seconds)
    player.global_position = Vector2(950, 473) # Dodge: test committed travel without an impact interrupting it.
    moth.set_physics_process(true)
    await frames(35)
    check(moth.global_position.distance_to(moth.committed_target) < 35, "Committed dive actually reaches a warned target")
    moth.set_physics_process(false)
    moth.global_position = moth.origin
    moth.contact_stagger = 0.0
    player.global_position = moth.origin + Vector2(110, 88)
    player.contact_stagger = 0.0
    moth._enter("telegraph", moth.profile.telegraph_seconds)
    moth._enter("active", moth.profile.active_seconds)
    moth.set_physics_process(true)
    var hp_before := RunState.hp
    await frames(35)
    check(RunState.hp == hp_before - 1, "Committed dive deals one contact hit without physical sticking")
    player.global_position = Vector2(950, 473)
    await frames(70)
    check(moth.global_position.distance_to(moth.origin) < 4, "Moth finishes recovery at its hover point before re-engaging")
    game._load_room("G2")
    var pair: Array[OrdinaryEnemy] = game.room.spawned_enemies
    player.global_position = Vector2(520, 473)
    player.invulnerable = 100.0
    var overlap := false
    for tick in range(220):
        await frames(1)
        if pair[0].state in ["telegraph", "active"] and pair[1].state in ["telegraph", "active"]:
            overlap = true
    check(pair[0].attack_serial > 0 and pair[1].attack_serial > 0, "Both Moths get attack turns")
    check(not overlap, "Moths stagger warning and dive windows")
    game.queue_free()
    RunState.new_game()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("MOTH_RESULT ", failed, " failed")
    get_tree().quit(0 if failed == 0 else 1)
