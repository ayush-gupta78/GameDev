extends Node

var failures: Array[String] = []
var passed := 0

func check(ok: bool, label: String) -> void:
    if ok:
        passed += 1
        print("PASS ", label)
    else:
        failures.append(label)
        push_error("FAIL " + label)

func frames(count: int) -> void:
    for i in range(count):
        await get_tree().physics_frame

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    RunState.save_path = "user://phase4_wall_contact_test.json"
    RunState.new_game()
    var wall := StaticBody2D.new()
    wall.position = Vector2(35, 0)
    wall.collision_layer = 1
    var shape := CollisionShape2D.new()
    var box := RectangleShape2D.new()
    box.size = Vector2(20, 1600)
    shape.shape = box
    wall.add_child(shape)
    add_child(wall)
    var player := Vessel.new()
    add_child(player)
    player.global_position = Vector2.ZERO
    Input.action_press("move_right")
    await frames(30)
    check(player.is_on_wall() and player.velocity.y > player.tuning.wall_slide_speed + 50.0 and player.state == "fall", "ordinary wall contact falls with gravity rather than sliding")
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    check(player.velocity.y > 0.0 and player.velocity.x >= 0.0 and player.state != "wall_jump", "ordinary wall denies wall jump")
    await frames(2)
    wall.add_to_group("climbable_wall")
    player.global_position = Vector2.ZERO
    player.velocity = Vector2.ZERO
    player.coyote = 0.0
    player.jump_buffer = 0.0
    await frames(30)
    check(player.is_on_wall() and player.velocity.y <= player.tuning.wall_slide_speed and player.state == "wall_slide", "marked wall permits slow wall slide")
    Input.action_press("jump")
    await frames(2)
    Input.action_release("jump")
    check(player.velocity.y < 0.0 and player.velocity.x < 0.0 and player.air_jump_available, "marked wall permits wall jump and restores air jump")
    Input.action_release("move_right")
    player.queue_free()
    wall.queue_free()
    RunState.new_game()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("WALL_CONTACT_RESULT ", passed, " passed, ", failures.size(), " failed")
    get_tree().quit(0 if failures.is_empty() else 1)
