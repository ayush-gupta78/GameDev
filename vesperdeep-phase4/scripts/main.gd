extends Node2D

var room: TestRoom
var player: Vessel
var camera: Camera2D
var ui: CanvasLayer
var status_label: Label
var hint_label: Label
var objective_label: Label
var boss_label: Label
var panel: PanelContainer
var dialogue_label: Label
var dialogue_lines: Array[String] = []
var dialogue_index: int = 0
var dialogue_key: String = ""
var paused_menu: bool = false
var rebind_index: int = 0
var capturing_bind: bool = false
const REBIND_ACTIONS := ["move_left", "move_right", "aim_up", "aim_down", "jump", "attack", "heal", "dash", "interact", "pause"]
const DIALOGUE := {
    "m1_intro": [
        "LISTENER (distant): There is nothing here that you must carry. Be still.",
        "ARCH: A NAME LEFT UNCLAIMED."
    ],
    "shore_voice": [
        "The rod pauses beneath the mute bell. Its hand opens; one unscripted note rings out.",
        "LISTENER (distant): You have returned noise to a wound.",
        "ECHO STEP ACQUIRED — Shift / B to dash. Cross the culvert to Choirwater."
    ],
    "rell_note": [
        "RELL: Tried trading a true memory for passage. Collector said it had no weight. Funny. It crushed my hands. — Rell"
    ],
    "gravestone": ["Here was someone worth mourning. The space intended for a name has been scraped smooth."],
    "edda": [
        "EDDA: If you came for a name, it isn't here. Not whole.",
        "EDDA: They collect a name, then what it means. Soon a mother can see her child and feel no need to reach for him.",
        "PIP: I remember this one's sound. I don't remember who taught me.",
        "EDDA: The Tollhouse sends every stolen memory inland. Stop its Warden. Then the way to Choirwater can be crossed.",
        "PIP: Three notes, then nothing. I keep waiting for a fourth."
    ],
    "thren": [
        "THREN: I am blind. Before you pity me, listen.",
        "THREN: The pages are full of names. The lines between them are gone. The Choir can write down what you were, but not why you would ever be it.",
        "THREN: Three places keep the Quiet breathing: the Tollhouse, this Bell Engine and the Cradle. You've silenced one.",
        "THREN: There is a sigil beneath the Cantor's bell. It opens the Hollow Basilica, and the garden beyond. The glass does not admit an unregistered will."
    ],
    "asha": [
        "ASHA: You brought the shore's sound into a place that forbids wind.",
        "ASHA: A garden can be kept perfect by never letting anything grow. I tried telling its keeper that once.",
        "ASHA: At the Cradle there is a voice that says it can carry everyone's pain. Ask what it takes from them in exchange.",
        "ASHA: When you arrive, do not mistake recognition for permission."
    ]
}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    player = Vessel.new()
    player.process_mode = Node.PROCESS_MODE_PAUSABLE
    add_child(player)
    player.died.connect(_on_death)
    camera = Camera2D.new()
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 6.0
    camera.limit_left = 0
    camera.limit_right = 1100
    camera.limit_top = 0
    camera.limit_bottom = 540
    player.add_child(camera)
    camera.position = Vector2.ZERO
    camera.enabled = true
    _create_ui()
    RunState.changed.connect(_refresh_ui)
    RunState.run_reset.connect(_load_room)
    _load_room(RunState.room_id)
    print("VESPERDEEP_PHASE4_READY")

func _create_ui() -> void:
    ui = CanvasLayer.new()
    add_child(ui)
    status_label = Label.new()
    status_label.position = Vector2(20, 12)
    status_label.add_theme_font_size_override("font_size", 20)
    ui.add_child(status_label)
    hint_label = Label.new()
    hint_label.position = Vector2(20, 46)
    hint_label.add_theme_font_size_override("font_size", 16)
    ui.add_child(hint_label)
    objective_label = Label.new()
    objective_label.position = Vector2(20, 82)
    objective_label.add_theme_font_size_override("font_size", 16)
    ui.add_child(objective_label)
    boss_label = Label.new()
    boss_label.position = Vector2(330, 104)
    boss_label.add_theme_font_size_override("font_size", 19)
    boss_label.visible = false
    ui.add_child(boss_label)
    panel = PanelContainer.new()
    panel.position = Vector2(100, 355)
    panel.custom_minimum_size = Vector2(760, 140)
    panel.visible = false
    ui.add_child(panel)
    dialogue_label = Label.new()
    dialogue_label.custom_minimum_size = Vector2(730, 100)
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    panel.add_child(dialogue_label)

func _process(_delta: float) -> void:
    if not is_instance_valid(room) or not is_instance_valid(boss_label):
        return
    boss_label.visible = room.boss_active and is_instance_valid(room.miniboss) and not room.miniboss.is_queued_for_deletion()
    if boss_label.visible:
        boss_label.text = ("TOLL WARDEN" if room.miniboss.kind == "warden" else "BELL CANTOR") + "  %d/%d" % [room.miniboss.hp, 10 if room.miniboss.kind == "warden" else 12]

func _load_room(id: String) -> void:
    if is_instance_valid(room):
        room.set_physics_process(false)
        room.queue_free()
    room = TestRoom.new()
    room.process_mode = Node.PROCESS_MODE_PAUSABLE
    add_child(room)
    move_child(room, 0)
    room.setup(id, player)
    room.exit_requested.connect(_on_exit)
    room.interaction_requested.connect(_on_interaction)
    player.global_position = Vector2(115, 450)
    player.safe_position = player.global_position
    player.velocity = Vector2.ZERO
    if id == "M2" and not RunState.SHRINES.has(RunState.checkpoint):
        RunState.activate_shrine("M2")
    if id == "M4" and RunState.has_flag("warden_defeated") and not RunState.has_flag("shore_voice_heard"):
        call_deferred("_on_interaction", "shore_voice")
    _refresh_ui()

func _on_exit(destination: String) -> void:
    var previous := room.room_id
    if previous == "C4" and destination == "G1" and RunState.has_flag("resonance_sigil_owned"):
        RunState.commit(["glass_gate_open"])
    RunState.enter_room(destination)
    _load_room(destination)
    if TestRoom.ROOMS.find(previous) > TestRoom.ROOMS.find(destination):
        player.global_position.x = 960.0
    if destination in ["M3", "G3"] and absf(TestRoom.ROOMS.find(previous) - TestRoom.ROOMS.find(destination)) > 1:
        player.global_position.x = 330.0
    player.safe_position = player.global_position
    if destination in ["M2", "C1", "G1"]:
        RunState.activate_shrine(destination)
    player.safe_position = player.global_position

func _on_interaction(kind: String) -> void:
    if kind == "mirror_latch":
        hint_label.text = "Mirror Latch: E / RB to open the G4 approach and M3 link"
        return
    if not DIALOGUE.has(kind) or panel.visible:
        return
    dialogue_key = kind
    dialogue_lines.clear()
    for line in DIALOGUE[kind]:
        dialogue_lines.append(String(line))
    dialogue_index = 0
    panel.visible = true
    Controls.gameplay_locked = true
    dialogue_label.text = dialogue_lines[dialogue_index] + "\n\nE / RB or Enter / A: continue"
    get_tree().paused = true

func _finish_dialogue() -> void:
    panel.visible = false
    Controls.gameplay_locked = false
    get_tree().paused = false
    match dialogue_key:
        "m1_intro": RunState.commit(["m1_intro_seen"])
        "shore_voice": RunState.commit(["shore_voice_heard"])
        "edda": RunState.commit(["edda_met"])
        "thren": RunState.commit(["thren_met", "engine_objective_known"])
        "asha": RunState.commit(["asha_met"])
    dialogue_key = ""
    dialogue_lines.clear()

func _unhandled_input(event: InputEvent) -> void:
    if paused_menu and capturing_bind:
        if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
            var action: StringName = StringName(REBIND_ACTIONS[rebind_index])
            var accepted := Controls.rebind(action, event)
            capturing_bind = false
            _show_pause()
            if not accepted:
                hint_label.text = "Binding conflict; choose another key/button"
            get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("pause") and (not panel.visible or paused_menu):
        paused_menu = not paused_menu
        Controls.gameplay_locked = paused_menu
        panel.visible = paused_menu
        if paused_menu:
            _show_pause()
        get_tree().paused = paused_menu
        get_viewport().set_input_as_handled()
        return
    if paused_menu:
        if event.is_action_pressed("menu_back"):
            paused_menu = false
            Controls.gameplay_locked = false
            panel.visible = false
            get_tree().paused = false
        elif event.is_action_pressed("menu_up"):
            rebind_index = posmod(rebind_index - 1, REBIND_ACTIONS.size())
            _show_pause()
        elif event.is_action_pressed("menu_down"):
            rebind_index = (rebind_index + 1) % REBIND_ACTIONS.size()
            _show_pause()
        elif event.is_action_pressed("menu_confirm"):
            capturing_bind = true
            dialogue_label.text = "Press a new key or controller button for " + REBIND_ACTIONS[rebind_index]
        elif event is InputEventKey and event.is_pressed() and event.physical_keycode == KEY_R:
            Controls.install_defaults()
            _show_pause()
        get_viewport().set_input_as_handled()
        return
    if panel.visible and (event.is_action_pressed("interact") or event.is_action_pressed("menu_confirm")):
        dialogue_index += 1
        if dialogue_index >= dialogue_lines.size():
            _finish_dialogue()
        else:
            dialogue_label.text = dialogue_lines[dialogue_index] + "\n\nE / RB or Enter / A: continue"
        get_viewport().set_input_as_handled()

func _show_pause() -> void:
    dialogue_label.text = "PAUSED — controls\n↑/↓ select: " + REBIND_ACTIONS[rebind_index] + "\nEnter/A: rebind · R: defaults · Esc/Menu: resume"

func _on_death() -> void:
    Controls.gameplay_locked = false
    panel.visible = false
    get_tree().paused = false
    RunState.death()

func _refresh_ui() -> void:
    if not is_instance_valid(status_label) or not is_instance_valid(room):
        return
    status_label.text = "%s — %s | HP %d/5 | Focus %d/3 (%d/3)" % [room.room_id, TestRoom.NAMES[room.room_id], RunState.hp, RunState.charges, RunState.hit_progress]
    if room.room_id == "M1":
        objective_label.text = "Objective: find the House of Kept Names"
    elif room.room_id in ["M2", "M3"]:
        objective_label.text = "Objective: reach the Tollhouse; speak to Edda and Pip" if not RunState.has_flag("edda_met") else "Objective: reach the Toll Warden"
    elif room.room_id == "M4":
        objective_label.text = "Objective: cross to Choirwater with Echo Step" if RunState.has_flag("warden_defeated") else "Objective: defeat the Toll Warden"
    elif room.room_id == "C1":
        objective_label.text = "Mourning Shore complete · The Bell Engine keeps the garden closed"
    else:
        objective_label.text = "Explore the next region"
    if not panel.visible:
        hint_label.text = "A/D or stick move · Space/A %s · J/X slash · K/Y hold heal · Shift/B dash · E/RB interact" % ("jump twice" if RunState.has_flag("double_jump_owned") else "jump")
