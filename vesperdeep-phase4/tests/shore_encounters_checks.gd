extends Node

var game: Node2D
var passed := 0
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failures.append(label)
        push_error("FAIL " + label)

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_encounters_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await get_tree().physics_frame
    var expected := {
        "M1": [EnemyProfile.Kind.PAPER_DRUDGE],
        "M2": [EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.PAPER_DRUDGE],
        "M3": [EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.PAPER_DRUDGE, EnemyProfile.Kind.GLASS_MOTH],
        "M4": [EnemyProfile.Kind.PAPER_DRUDGE]
    }
    for room_id in expected:
        game._load_room(room_id)
        await get_tree().physics_frame
        var enemies: Array[OrdinaryEnemy] = game.room.spawned_enemies
        check(enemies.size() == expected[room_id].size(), room_id + " authored density")
        var correct: bool = enemies.size() == expected[room_id].size()
        for index in range(enemies.size()):
            correct = correct and enemies[index].profile.kind == expected[room_id][index]
        check(correct, room_id + " existing archetypes and escalating combination")
        if room_id == "M1":
            check(enemies.size() > 0 and enemies[0].global_position.x > 280 and enemies[0].global_position.x < 600, "M1 first enemy after safe movement introduction")
            check(game.room.get_node_or_null("HangingTarget") != null, "M1 harmless target remains")
        elif room_id == "M2":
            var safe := true
            for enemy in enemies:
                safe = safe and enemy.global_position.x > 350 and enemy.global_position.x < 550
            check(safe and game.room.get_node_or_null("EddaPip") != null, "M2 shrine and NPC patch remain clear")
        elif room_id == "M3":
            var safe := true
            for enemy in enemies:
                safe = safe and enemy.global_position.x > 350 and enemy.global_position.x < 790
            check(safe and game.room.get_node_or_null("ChimneyWalls") != null, "M3 side climb and latch have clear approach")
        elif room_id == "M4":
            check(enemies.size() > 0 and enemies[0].global_position.x > 100 and enemies[0].global_position.x < 310 and not game.room.boss_active, "M4 warm-up stays outside inactive boss arena")
            var warm_up: OrdinaryEnemy = enemies[0]
            game.player.global_position = Vector2(450, 473)
            game.player.invulnerable = 100.0
            await get_tree().physics_frame
            await get_tree().physics_frame
            check(game.room.boss_active and not is_instance_valid(warm_up), "engaging Warden clears the pre-arena Drudge without a double threat")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("SHORE_ENCOUNTERS_RESULT ", passed, " passed, ", failures.size(), " failed")
    get_tree().quit(0 if failures.is_empty() else 1)
