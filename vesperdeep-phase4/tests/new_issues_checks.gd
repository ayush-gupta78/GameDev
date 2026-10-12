extends Node

var passed := 0
var failed: Array[String] = []
var game: Node2D

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

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase3_new_issues_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    await frames(3)
    game._load_room("C1")
    var shrine_hint := game.room.get_node_or_null("ShrineHint") as Label
    check(shrine_hint != null and "E/RB" in shrine_hint.text and "SHRINE" in shrine_hint.text, "C1 blue shrine is visibly labeled with interaction")
    for id in ["G1", "G2"]:
        game._load_room(id)
        await frames(2)
        var enemies: Array[OrdinaryEnemy] = game.room.spawned_enemies
        check(enemies.size() == (1 if id == "G1" else 2), id + " retains approved Moth placement")
        for moth in enemies:
            moth.set_physics_process(false)
        for moth in enemies:
            moth.global_position = moth.origin
            var player: Vessel = game.player
            player.global_position = Vector2(moth.global_position.x, 473)
            player.velocity = Vector2.ZERO
            player.invulnerable = 10.0
            check(moth.origin.y >= 380, id + " Moth hover height allows ground up-slash during dive")
            moth._enter("telegraph", moth.profile.telegraph_seconds)
            moth._enter("active", moth.profile.active_seconds)
            moth.set_physics_process(true)
            await frames(12)
            moth.set_physics_process(false)
            var hp_before := moth.hp
            player.attack.direction = "up"
            player.attack.swing_id += 1
            player.attack.struck_ids.clear()
            player.attack._scan_hits(player)
            check(moth.hp == hp_before - 1, id + " Moth dive enters actual upward-slash hitbox")
            moth.set_physics_process(true)
            var spawn_index := int(moth.get_meta("spawn_index"))
            for tick in range(210):
                await frames(1)
                if not is_instance_valid(moth) or moth.is_queued_for_deletion():
                    break
                if moth.state == "active" and moth.global_position.y >= 422 and moth.wound_time <= 0.0:
                    player.attack.swing_id += 1
                    player.attack.struck_ids.clear()
                    player.attack._scan_hits(player)
                    if moth.state == "dead":
                        break
            check(RunState.defeated_enemies.has(id + ":" + str(spawn_index)), id + " Moth can be defeated on a second natural dive")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("NEW_ISSUES_RESULT ", passed, " passed, ", failed.size(), " failed")
    get_tree().quit(0 if failed.is_empty() else 1)
