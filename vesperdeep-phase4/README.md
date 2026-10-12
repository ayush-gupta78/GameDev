# Vesperdeep — corrected Phase 4 owner review build

Godot 4.7.2 project. The complete Phase 4 vertical slice is the Mourning Shore (M1–M4) and its dash-gated C1 landing. Other room IDs and verified Phase 3 core mechanics remain available as integration scaffolds, not as finished Phase 4 regions. This is not the full approximately 60-minute game. The unchanged approved design lives at `../vesperdeep-phase2-final/` outside this package; the supplied Phase 3 documentation is included for provenance.

## Open and play

Extract the review ZIP with a permission-preserving unzip tool. Open `project.godot` in Godot 4.7.2, press F5, or run `godot --path .`. Linux: launch `builds/vesperdeep-linux.x86_64` beside `builds/vesperdeep-linux.pck`. Some extraction tools do not restore executable permissions; if necessary run `chmod +x builds/vesperdeep-linux.x86_64` once after extraction. Windows: launch `builds/vesperdeep-windows.exe` beside `builds/vesperdeep-windows.pck` on a Windows x86-64 host. The Windows binary was exported, not runtime-tested. See `CONTROLS.md` and `PHASE4_MANUAL_QA.md`.

A new Phase 4 playthrough saves to Godot's user-data directory for `Vesperdeep — Phase 4`, not the accepted Phase 3 application. To continue a backed-up Phase 3 run, copy its `vesperdeep_run.json` into the Phase 4 user-data directory while the game is closed. Valid version-1/2 files migrate to version 3 on launch; keep the original backup, because the Phase 3 executable cannot read version 3. Godot's Project → Open User Data Folder gives the correct platform-specific path. To restart, close Phase 4 and back up/remove only its `vesperdeep_run.json`.

## Shore route

1. M1 Wreckfall: walk, jump across a shallow reversible dip and three platforms; learn basic combat against one Drudge, strike the harmless hanging target, and read the distant voice at the exit.
2. M2 House of Kept Names: approach the shrine, fight two central Drudges while keeping the NPC passage clear, then finish Edda and Pip's mandatory first exchange to open M3. Use E/RB at the shrine to rest.
3. M3 Ossuary Steps: encounter two Paper Drudges and a Glass Moth; climb only the marked vertical chimney stones to reach the optional gravestone and ascend platforms to Rell's note. Use E/RB at the gold latch near the exit to open the short M4 approach. The higher G3 shortcut stays barred until opened later from G3.
4. M4 Tollhouse: deal with the pre-arena Drudge, approach to start the nonverbal Toll Warden, read its three visible tells and defeat it by combat. Its win grants Echo Step and opens the arena. Read the Listener's post-victory line, then jump + dash over the separate marked culvert to C1.
5. C1 Sluice Landing: activate the shrine and read the Bell Engine objective. This is the Phase 4 handoff boundary, not a claim that Choirwater is complete.

The three-charge Focus cap, true-death shrine retry, C3 Double Jump acquisition and other accepted Phase 3 systems remain unchanged. The accepted Phase 2 GDD is not embedded in this ZIP.

## Checks

From the project root: `godot --headless --path . --editor --import`, then `godot --headless --path . --scene res://tests/shore_route_checks.tscn`; replace the scene path with `shore_slice_checks.tscn`, `wall_contact_checks.tscn`, `moth_checks.tscn`, `contact_recoil_checks.tscn`, `ground_ai_checks.tscn`, or `boss_arena_checks.tscn` for targeted checks. Root causes and tuning are in `PHASE4_CORRECTION_REPORT.md`; the regression matrix is in `PHASE4_TEST_REPORT.md`. New evidence is under `tests/evidence/`, and the original 226-check Phase 4 run is copied under `tests/evidence/phase4-original-226/`. Graphical checks need a real display; headless checks do not prove owner-operated play or physical-controller behavior.

The owner tested the preceding Linux build, but these corrections are submitted for independent review and are not owner-verified. The approved ~17-minute region target remains; no playtime has been measured for this build. Do not proceed to Phase 5 without explicit approval.
