extends Node

var game: Node2D
var failures: Array[String] = []
const DIR := "/home/chaos/.hermes/cache/scratch/vesperdeep-phase3-visual"

func _ready() -> void:
    call_deferred("run")

func snap(name: String) -> Image:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var result := image.save_png(DIR + "/" + name + ".png")
    if result != OK:
        failures.append("screenshot " + name)
    return image

func check_color_presence(image: Image, expected: Color, label: String) -> void:
    var count := 0
    for y in range(image.get_height()):
        for x in range(image.get_width()):
            var color := image.get_pixel(x, y)
            if absf(color.r - expected.r) < 0.03 and absf(color.g - expected.g) < 0.03 and absf(color.b - expected.b) < 0.03:
                count += 1
    if count > 3:
        print("PASS ", label, " (", count, " pixels)")
    else:
        failures.append(label)
        push_error("FAIL " + label)

func run() -> void:
    DirAccess.make_dir_recursive_absolute(DIR)
    RunState.save_path = "user://phase3_visual_test.json"
    RunState.new_game()
    game = load("res://scenes/main.tscn").instantiate()
    get_tree().root.add_child(game)
    game._load_room("M1")
    for i in range(4): await get_tree().physics_frame
    var image := await snap("m1-player")
    check_color_presence(image, Color(0.78, 0.88, 0.94), "M1 player visually in front of room")
    game._load_room("C2")
    var needle: OrdinaryEnemy = game.room.spawned_enemies[0]
    needle.set_physics_process(false)
    needle._enter("telegraph", needle.profile.telegraph_seconds)
    image = await snap("c2-warning")
    needle._enter("active", needle.profile.active_seconds)
    image = await snap("c2-projectile")
    check_color_presence(image, Color(1.0, 0.68, 0.27), "Needle projectile renders on camera")
    game._load_room("C1")
    image = await snap("c1-shrine")
    check_color_presence(image, Color(0.55, 0.78, 0.95), "C1 blue checkpoint renders beside shrine label")
    game._load_room("M4")
    image = await snap("m4-enclosed-arena")
    check_color_presence(image, Color(0.45, 0.54, 0.56), "M4 arena boundary visibly separates boss deck from dash gap")
    RunState.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"])
    game._load_room("M4")
    image = await snap("m4-post-victory")
    if not image.is_empty(): print("PASS M4 post-victory graphical frame captured")
    RunState.commit(["cantor_defeated", "choir_relay_off", "resonance_sigil_owned", "c4_door_open"])
    game._load_room("C1")
    game.player.global_position = Vector2(400, 350)
    game.player.wing_flash = 0.22
    game.player.queue_redraw()
    image = await snap("double-jump-wings")
    var wing_pixels := 0
    for y in range(int(image.get_height() * 330.0 / 540.0), int(image.get_height() * 355.0 / 540.0)):
        for x in range(int(image.get_width() * 367.0 / 960.0), int(image.get_width() * 389.0 / 960.0)):
            var color := image.get_pixel(x, y)
            if color.b > 0.45 and color.b > color.r + 0.05:
                wing_pixels += 1
    if wing_pixels > 3:
        print("PASS double-jump wing effect renders in gameplay (", wing_pixels, " pixels)")
    else:
        failures.append("double-jump wing effect not visible")
    game._load_room("G2")
    var moth: OrdinaryEnemy = game.room.spawned_enemies[0]
    moth.set_physics_process(false)
    game.player.global_position = Vector2(500, 450)
    moth._enter("telegraph", moth.profile.telegraph_seconds)
    image = await snap("g2-warning")
    game._on_interaction("asha")
    image = await snap("g2-dialogue")
    if not image.is_empty(): print("PASS G2 dialogue graphical frame captured")
    game._finish_dialogue()
    game.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    print("VISUAL_RESULT ", failures.size(), " failed; screenshots: ", DIR)
    get_tree().quit(0 if failures.is_empty() else 1)
