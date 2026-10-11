# Vesperdeep — Phase 3 core systems

Godot 4.7.2 GDScript prototype. Phase 2 source of truth: `../vesperdeep-phase2-final/` (unchanged). The project is separate and contains original placeholder geometry only.

## Run

```sh
cd vesperdeep-phase3
godot --path .
```

Linux and Windows are the configured desktop targets. An installed Godot 4.7.2 editor is required. The project launches from `scenes/main.tscn`. The test-room scaffold represents the approved room IDs; it is not the finished 60-minute campaign. Controls: `CONTROLS.md`.

## Verify

```sh
godot --headless --path . --editor --import
godot --headless --path . --scene res://tests/run_checks.tscn
godot --headless --path . --scene res://tests/physics_checks.tscn
godot --headless --path . --scene res://tests/review_checks.tscn
godot --headless --path . --scene res://tests/boss_arena_checks.tscn
godot --headless --path . --scene res://tests/new_issues_checks.tscn
godot --headless --path . --scene res://tests/double_jump_checks.tscn
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- damage_write
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- damage_read
godot --headless --path . --quit-after 60
```

The test scene uses `user://phase3_test_run.json` and deletes it at completion. Normal play uses `user://vesperdeep_run.json`. Missing or invalid saves start a new game; remove that normal save file to start a new game manually. The first-time checkpoint begins at M1, then activates at M2/C1/G1/G3. Death is a shrine respawn with durable progress, not a full-run reset. G4 death/reload returns to G3; no Phase 2 retry checkpoint exists.

## Export

Presets `Linux` and `Windows` are configured in `export_presets.cfg`. The package includes Linux and Windows x86-64 binaries with matching `.pck` sidecars under `builds/`. The matching Godot 4.7.2 release templates are installed on the build machine. To reproduce an export on another machine, install the official matching templates and then:

```sh
mkdir -p builds
godot --headless --path . --export-release Linux builds/vesperdeep-linux.x86_64
godot --headless --path . --export-release Windows builds/vesperdeep-windows.exe
```

Linux native startup was tested both headless and graphically. Windows export generated a valid PE but was not executed (no Windows host or Wine). Keep each `.pck` beside its executable. See `PHASE3_TEST_REPORT.md` and `MANUAL_GAMEPLAY_QA.md`.

## Scope

Core movement, combat, enemy, gate, room, shrine and save prototypes are implemented. M4/C3 minibosses are limited behavior prototypes to exercise reward/gate integration. The G4 final encounter, complete presentation/audio, final authored level geometry and full narrative sequence are not implemented; do not treat this as the finished campaign. See `PHASE3_IMPLEMENTATION_REPORT.md` for traceability and limitations. No Phase 4 work was started.
