extends Node

var passed := 0
var failed := 0

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failed += 1
        push_error("FAIL " + label)

func frames(n: int) -> void:
    for i in range(n):
        await get_tree().physics_frame

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_ground_ai_test.json"
    RunState.new_game()
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    game._load_room("M2")
    game.room.set_physics_process(false)
    game.player.set_physics_process(false)
    game.player.invulnerable = 100.0
    game.player.global_position = Vector2(280, 473)
    await frames(4)
    var lead: OrdinaryEnemy = game.room.spawned_enemies[0]
    var other: OrdinaryEnemy = game.room.spawned_enemies[1]
    other.set_physics_process(false)
    var origin_x := lead.origin.x
    await frames(25)
    check(lead.facing == -1 and lead.global_position.x < origin_x - 12, "Drudge turns and pursues a nearby player before attacking")
    check(lead.state != "telegraph" or absf(lead.global_position.x - game.player.global_position.x) < 70, "Drudge does not waste a strike outside melee range")
    game._load_room("M2")
    game.room.set_physics_process(false)
    game.player.global_position = Vector2(445, 473)
    var pair: Array[OrdinaryEnemy] = game.room.spawned_enemies
    var overlap := false
    for tick in range(240):
        await frames(1)
        if pair[0].state in ["telegraph", "active"] and pair[1].state in ["telegraph", "active"]:
            overlap = true
    check(pair[0].attack_serial > 0 and pair[1].attack_serial > 0, "Both Drudges eventually attack instead of idling")
    check(not overlap, "Drudge pair staggers telegraphs and active attacks")
    var within := true
    for enemy in pair:
        within = within and absf(enemy.global_position.x - enemy.origin.x) <= 115
    check(within, "Drudges cannot be kited into shrine or NPC safe patches")
    RunState.new_game()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("GROUND_AI_RESULT ", passed, " passed, ", failed, " failed")
    get_tree().quit(0 if failed == 0 else 1)
