extends Node

func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    RunState.save_path = "user://phase3_damage_relaunch_probe.json" if args.size() == 1 and args[0].begins_with("damage_") else "user://phase3_relaunch_probe.json"
    if args.size() == 1 and args[0] == "write":
        RunState.new_game()
        RunState.commit(["warden_defeated", "shore_relay_off", "echo_step_owned", "m4_exit_open"])
        RunState.commit(["cantor_defeated", "choir_relay_off", "resonance_sigil_owned", "c4_door_open"])
        RunState.enter_room("C1")
        RunState.activate_shrine("C1")
        RunState.hp = 3
        RunState.charges = 2
        RunState.hit_progress = 1
        if RunState.save_game(): print("PASS persisted save written in first process")
        else: get_tree().quit(1); return
    elif args.size() == 1 and args[0] == "read":
        if RunState.load_game() and RunState.room_id == "C1" and RunState.checkpoint == "C1" and RunState.hp == 3 and RunState.charges == 2 and RunState.hit_progress == 1 and RunState.has_flag("echo_step_owned") and RunState.has_flag("double_jump_owned"):
            print("PASS ability, shrine, health and partial charge restored in second process")
        else:
            push_error("FAIL independent-process save round trip")
            get_tree().quit(1)
            return
        DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    elif args.size() == 1 and args[0] == "damage_write":
        RunState.new_game()
        RunState.hp = 4
        RunState.save_game()
        var vessel := Vessel.new()
        add_child(vessel)
        if vessel.receive_damage(42, 1) and RunState.hp == 3:
            print("PASS nonfatal hit accepted before first process exits")
        else:
            push_error("FAIL damage setup")
            get_tree().quit(1)
            return
    elif args.size() == 1 and args[0] == "damage_read":
        if RunState.load_game() and RunState.hp == 3:
            print("PASS damaged HP restored on independent process relaunch")
        else:
            push_error("FAIL damaged HP reverted after relaunch: " + str(RunState.hp))
            get_tree().quit(1)
            return
        DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.save_path))
    else:
        push_error("Pass -- write or -- read")
        get_tree().quit(1)
        return
    get_tree().quit()
