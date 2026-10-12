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
    for tick in range(n):
        await get_tree().physics_frame

func stagger_of(body: Node) -> float:
    var value = body.get("contact_stagger")
    return value if value is float else 0.0

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_contact_test.json"
    RunState.new_game()
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    game._load_room("M2")
    game.room.set_physics_process(false)
    await frames(3)
    var player: Vessel = game.player
    var drudge: OrdinaryEnemy = game.room.spawned_enemies[0]
    var partner: OrdinaryEnemy = game.room.spawned_enemies[1]
    player.set_physics_process(false)
    drudge.set_physics_process(false)
    partner.set_physics_process(false)
    player.global_position = Vector2(414, 473)
    player.velocity = Vector2.ZERO
    player.facing = 1 # Old fixed-facing recoil moved INTO this enemy to the left.
    drudge.global_position = Vector2(390, 473)
    drudge.velocity = Vector2.ZERO
    drudge.facing = 1
    drudge._enter("active", drudge.profile.active_seconds)
    var before := RunState.hp
    drudge._active_attack()
    check(RunState.hp == before - 1, "active ground body contact deals one existing one-HP hit")
    check(player.velocity.x > 80.0 and drudge.velocity.x < -30.0, "contact origin sends player and ground enemy in opposite directions")
    check(stagger_of(player) > 0.0 and stagger_of(drudge) > stagger_of(player), "brief enemy stagger exceeds player recoil time")
    var recoil := player.velocity
    partner.global_position = Vector2(420, 473)
    partner.facing = -1
    partner._enter("active", partner.profile.active_seconds)
    partner._active_attack()
    check(RunState.hp == before - 1 and player.velocity == recoil, "second simultaneous enemy cannot restagger an invulnerable player")
    check(drudge.collision_mask & 2 == 0, "ground bodies cannot physically drag player")
    partner.global_position = Vector2(650, 473)
    player.set_physics_process(true)
    drudge.set_physics_process(true)
    var starting_gap := player.global_position.distance_to(drudge.global_position)
    await frames(12)
    check(player.global_position.distance_to(drudge.global_position) > starting_gap + 12.0, "ground contact resolves through terrain-aware physics separation")
    await frames(55)
    check(stagger_of(player) <= 0.0 and stagger_of(drudge) <= 0.0, "contact recovery ends without a stun loop")
    game._load_room("M2")
    game.room.set_physics_process(false)
    player.set_physics_process(false)
    player.global_position = Vector2(414, 473)
    player.velocity = Vector2.ZERO
    player.facing = -1 # Old facing recoil pointed toward an attacker on the right.
    player.invulnerable = 0.0
    player.contact_stagger = 0.0
    var right_enemy: OrdinaryEnemy = game.room.spawned_enemies[1]
    right_enemy.set_physics_process(false)
    right_enemy.global_position = Vector2(440, 473)
    right_enemy.facing = -1
    right_enemy._enter("active", right_enemy.profile.active_seconds)
    right_enemy._active_attack()
    check(player.velocity.x < -80.0 and right_enemy.velocity.x > 30.0, "right-side attacker recoils both bodies outward regardless of player facing")
    game._load_room("M2")
    game.room.set_physics_process(false)
    player.set_physics_process(false)
    player.global_position = Vector2(414, 473)
    player.invulnerable = 0.0
    player.contact_stagger = 0.0
    var neutral: OrdinaryEnemy = game.room.spawned_enemies[0]
    var neutral_hp := RunState.hp
    await frames(2)
    check(RunState.hp == neutral_hp and stagger_of(player) > 0.0 and stagger_of(neutral) > 0.0, "nonattacking body overlap separates without inventing contact damage")
    player.contact_stagger = 0.0
    neutral.receive_hit(9001, player)
    check(stagger_of(player) == 0.0, "player weapon hit remains distinct from body-contact recoil")
    game._load_room("G2")
    game.room.set_physics_process(false)
    player.set_physics_process(false)
    player.global_position = Vector2(415, 390)
    player.velocity = Vector2.ZERO
    player.invulnerable = 0.0
    player.facing = 1
    var moth: OrdinaryEnemy = game.room.spawned_enemies[0]
    var second: OrdinaryEnemy = game.room.spawned_enemies[1]
    moth.set_physics_process(false)
    second.set_physics_process(false)
    moth.global_position = Vector2(390, 390)
    moth.facing = 1
    moth._enter("active", moth.profile.active_seconds)
    moth._active_attack()
    check(player.velocity.x > 80.0 and moth.velocity.x < -30.0 and moth.collision_mask & 2 == 0, "airborne Moth hit separates without physical attachment")
    var flying_health := RunState.hp
    second.global_position = Vector2(440, 390)
    second.facing = -1
    second._enter("active", second.profile.active_seconds)
    second._active_attack()
    check(RunState.hp == flying_health, "two nearly simultaneous flyers cannot inflict repeated damage")
    game._load_room("M4")
    game.room.set_physics_process(false)
    player.set_physics_process(false)
    player.global_position = Vector2(515, 473)
    player.velocity = Vector2.ZERO
    player.invulnerable = 0.0
    player.contact_stagger = 0.0
    player.facing = 1
    var boss: MinibossPrototype = game.room.miniboss
    boss.set_physics_process(false)
    boss.global_position = Vector2(480, 458)
    boss.velocity = Vector2.ZERO
    boss.phase = "active"
    boss.move_index = 2
    boss.facing = 1
    boss.timer = boss._times()[2][1]
    var boss_health := boss.hp
    boss._physics_process(1.0 / 60.0)
    check(player.velocity.x > 80.0 and boss.velocity.x < 0.0 and stagger_of(boss) > 0.0, "Warden contact recoils apart with bounded boss resistance")
    check(boss.hp == boss_health and not RunState.has_flag("warden_defeated"), "boss contact cannot award defeat or progression")
    boss.set_physics_process(true)
    player.set_physics_process(true)
    player.invulnerable = 100.0
    await frames(70)
    check(boss.global_position.x >= 100 and boss.global_position.x <= 790 and boss.is_on_floor(), "contact does not displace Warden beyond arena")
    game.queue_free()
    RunState.new_game()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("CONTACT_RECOIL_RESULT ", passed, " passed, ", failed, " failed")
    get_tree().quit(0 if failed == 0 else 1)
