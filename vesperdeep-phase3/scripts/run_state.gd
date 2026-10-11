extends Node

signal changed
signal run_reset(room_id: String)
var save_path: String = "user://vesperdeep_run.json"
const SAVE_VERSION := 2
const FLAGS := ["edda_met", "thren_met", "engine_objective_known", "asha_met", "m3_toll_latch_open", "warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open", "cantor_defeated", "choir_relay_off", "resonance_sigil_owned", "c4_door_open", "glass_gate_open", "c2_hatch_open", "mirror_latch_open", "identity_revealed", "veyra_sacrificed", "final_boss_defeated", "hush_engine_off", "ending_available", "story_complete", "double_jump_owned"]
const SHRINES := ["M2", "C1", "G1", "G3"]
var flags: Dictionary = {}
var checkpoint: String = "M1"
var room_id: String = "M1"
var hp: int = 5
var charges: int = 0
var hit_progress: int = 0
var defeated_enemies: Dictionary = {}
var enemy_health: Dictionary = {}

func _ready() -> void:
    if not load_game():
        new_game()

func new_game() -> void:
    flags.clear()
    for key in FLAGS:
        flags[key] = false
    checkpoint = "M1"
    room_id = "M1"
    hp = 5
    charges = 0
    hit_progress = 0
    defeated_enemies.clear()
    enemy_health.clear()
    changed.emit()
    save_game()

func commit(keys: Array) -> bool:
    for key in keys:
        if not key is String or not FLAGS.has(key):
            push_error("Unknown progression flag: " + key)
            return false
    for key in keys:
        flags[key] = true
    if keys.has("cantor_defeated"):
        flags["double_jump_owned"] = true
    changed.emit()
    return save_game()

func has_flag(key: String) -> bool:
    return flags.get(key, false) == true

func gate_open(from_room: String, to_room: String) -> bool:
    var pair := from_room + ">" + to_room
    match pair:
        "M2>M3", "M3>M2": return has_flag("edda_met")
        "M3>M4", "M4>M3": return has_flag("m3_toll_latch_open")
        "M4>C1", "C1>M4": return has_flag("warden_defeated") and has_flag("echo_step_owned")
        "C2>C3", "C3>C2": return has_flag("thren_met") and has_flag("engine_objective_known")
        "C3>C4", "C4>C3": return has_flag("cantor_defeated") and has_flag("choir_relay_off")
        "C4>G1", "G1>C4": return has_flag("resonance_sigil_owned")
        "G2>G3", "G3>G2": return has_flag("asha_met")
        "G3>G4", "G4>G3": return has_flag("asha_met") and has_flag("mirror_latch_open") and has_flag("echo_step_owned")
        "C2>M2", "M2>C2": return has_flag("c2_hatch_open")
        "G3>M3", "M3>G3": return has_flag("mirror_latch_open")
        _:
            var spine := ["M1", "M2", "M3", "M4", "C1", "C2", "C3", "C4", "G1", "G2", "G3", "G4"]
            return abs(spine.find(from_room) - spine.find(to_room)) == 1 and spine.has(from_room) and spine.has(to_room)

func reach_shrine(id: String) -> void:
    if not SHRINES.has(id):
        return
    activate_shrine(id)
    hp = 5
    defeated_enemies.clear()
    enemy_health.clear()
    changed.emit()
    save_game()

func activate_shrine(id: String) -> void:
    if not SHRINES.has(id):
        push_error("Invalid shrine: " + id)
        return
    checkpoint = id
    changed.emit()
    save_game()

func mark_enemy(room: String, index: int) -> void:
    defeated_enemies[room + ":" + str(index)] = true
    enemy_health.erase(room + ":" + str(index))

func remember_enemy(room: String, index: int, remaining_hp: int) -> void:
    enemy_health[room + ":" + str(index)] = remaining_hp

func enter_room(id: String) -> void:
    room_id = id
    match id:
        "M4": checkpoint = "M2"
        "C3": checkpoint = "C1"
        "G4": checkpoint = "G3"
    changed.emit()
    save_game()

func death() -> void:
    var respawn := checkpoint
    if room_id == "G4":
        respawn = "G3"
        checkpoint = "G3"
    room_id = respawn
    hp = 5
    charges = 0
    hit_progress = 0
    defeated_enemies.clear()
    enemy_health.clear()
    changed.emit()
    save_game()
    run_reset.emit(respawn)

func save_game() -> bool:
    var data := {"version": SAVE_VERSION, "flags": flags.duplicate(), "checkpoint": checkpoint,
        "room_id": room_id, "hp": hp, "charges": charges, "hit_progress": hit_progress}
    var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
    if file == null:
        push_error("Cannot write save: " + str(FileAccess.get_open_error()))
        return false
    file.store_string(JSON.stringify(data))
    file.flush()
    file.close()
    var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(save_path + ".tmp"), ProjectSettings.globalize_path(save_path))
    if error != OK:
        push_error("Cannot commit save: " + str(error))
        return false
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(save_path):
        return false
    var file := FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        return false
    var parser := JSON.new()
    if parser.parse(file.get_as_text()) != OK:
        push_warning("Corrupt save JSON ignored")
        return false
    var data: Variant = parser.data
    if not _valid(data):
        push_warning("Invalid save ignored; starting new game")
        return false
    flags = data.flags.duplicate()
    if data.version == 1:
        flags["double_jump_owned"] = flags["cantor_defeated"]
    checkpoint = data.checkpoint
    room_id = data.room_id
    hp = int(data.hp)
    charges = int(data.charges)
    hit_progress = int(data.hit_progress)
    defeated_enemies.clear()
    enemy_health.clear()
    if room_id == "G4" and not has_flag("final_boss_defeated"):
        room_id = "G3"
        checkpoint = "G3"
        hp = 5
        charges = 0
        hit_progress = 0
        save_game()
    if data.version == 1:
        save_game()
    changed.emit()
    return true

func _valid(data: Variant) -> bool:
    if not data is Dictionary or (data.get("version") != 1 and data.get("version") != SAVE_VERSION):
        return false
    var legacy: bool = data.version == 1
    if not data.get("flags") is Dictionary or data.flags.size() != FLAGS.size() - (1 if legacy else 0):
        return false
    for key in FLAGS:
        if legacy and key == "double_jump_owned":
            continue
        if not data.flags.has(key) or not data.flags[key] is bool:
            return false
    if not data.get("checkpoint") is String or not (SHRINES + ["M1"]).has(data.checkpoint):
        return false
    if not data.get("room_id") is String or not (["M1", "M2", "M3", "M4", "C1", "C2", "C3", "C4", "G1", "G2", "G3", "G4"]).has(data.room_id):
        return false
    for spec in [["hp", 1, 5], ["charges", 0, 3], ["hit_progress", 0, 2]]:
        var value: Variant = data.get(spec[0])
        if not (value is int or value is float) or value != floorf(value) or value < spec[1] or value > spec[2]:
            return false
    if not (data.flags.warden_defeated == data.flags.echo_step_owned and data.flags.warden_defeated == data.flags.m4_exit_open and data.flags.warden_defeated == data.flags.shore_relay_off):
        return false
    if not (data.flags.cantor_defeated == data.flags.resonance_sigil_owned and data.flags.cantor_defeated == data.flags.c4_door_open and data.flags.cantor_defeated == data.flags.choir_relay_off):
        return false
    if not legacy and data.flags.cantor_defeated != data.flags.double_jump_owned:
        return false
    if data.flags.glass_gate_open and not data.flags.resonance_sigil_owned:
        return false
    if data.flags.thren_met != data.flags.engine_objective_known:
        return false
    if data.flags.identity_revealed != data.flags.veyra_sacrificed:
        return false
    if data.flags.final_boss_defeated and (not data.flags.hush_engine_off or not data.flags.ending_available):
        return false
    return true
