# Phase 3 verification report

Baseline: Godot `4.7.2.stable.official.ed1daf0bf` on Fedora Linux. Approved Phase 2 GDD is unchanged; the owner expressly approved a new Double Jump after C3 and relocating the M4 dash gap outside the boss deck. This is a core-systems prototype, not the finished campaign. Scripted checks and OpenGL frames are not owner-operated gameplay verification; the corrected M4, G1/G2 and Double Jump need owner replay. Physical-controller and Windows-runtime execution have not been independently verified.

## Reproduce

From this directory:

```sh
godot --headless --path . --editor --import
godot --headless --path . --scene res://tests/run_checks.tscn
godot --headless --path . --scene res://tests/physics_checks.tscn
godot --headless --path . --scene res://tests/review_checks.tscn
godot --headless --path . --scene res://tests/boss_arena_checks.tscn
godot --headless --path . --scene res://tests/new_issues_checks.tscn
godot --headless --path . --scene res://tests/double_jump_checks.tscn
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- write
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- read
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- damage_write
godot --headless --path . --scene res://tests/relaunch_probe.tscn -- damage_read
godot --path . --scene res://tests/visual_checks.tscn --windowed --resolution 960x540
./builds/vesperdeep-linux.x86_64 --headless --quit-after 120
./builds/vesperdeep-linux.x86_64 --quit-after 120
```

Latest full suite: core **63**, physics/gameplay **17**, independent-review **35**, M4/C3 arena **20**, G1/G2/C1 **12**, Double Jump **19**, independent-process save checks **4**, graphical **7**; all passed, **177 passed / 0 failed**. The graphical checks saved nine frames in `/home/chaos/.hermes/cache/scratch/vesperdeep-phase3-visual/`. The save suite deliberately emits warnings for invalid/corrupt JSON and confirms rejection. Linux and Windows exports were regenerated after the corrections; the Linux executable started headlessly. Windows runtime and physical-controller play were not verified.

## Test evidence (expected → observed; status; correction)

| Test | How tested | Expected → observed | Status / correction |
|---|---|---|---|
| Project import and Linux startup | Editor import; exported Linux executable headless | Scenes/scripts import and main scene prints readiness → succeeded; graphical scripted project checks pass | PASS; previous graphical native startup was before latest correction |
| Windows export | Official matching template, `godot --export-release Windows` and `file` | PE x86-64 executable → produced `builds/vesperdeep-windows.exe` | PASS generation; runtime BLOCKED (no Windows/Wine) |
| Drawing order | Graphical screenshot and `run_checks.gd` ordering assertion | Player visible above opaque room → previously hidden, now visibly rendered | PASS; moved room behind player in `main.gd` |
| Ground speed/deceleration | Physics frames with pressed/released movement | Increases up to tune cap, slows on release → observed | PASS |
| Jump buffering/coyote/variable height | Physics-frame setups at landing, platform edge, early release | Buffered and late ledge jumps rise, release shortens arc → observed | PASS; owner reports Linux movement feel PASS |
| Wall contact/jump | Right-wall collision and jump in `run_checks.gd` | Jump moves and faces away → originally faced into wall, now both left | PASS; `player.gd` normal-facing correction |
| Echo Step | Two attempted airborne uses after unlock | First succeeds, second blocked until reset → observed | PASS; physical-controller input untested |
| Slash target deduplication/partial charge | Overlap queries, repeat hits and three-hit counter in `run_checks.gd` | One hit/target/swing, rejected hit adds no charge; cap three discards excess → observed | PASS |
| Down slash/pogo | C1 enemy overlap and downward `_scan_hits` in `physics_checks.gd` | One HP lost by enemy; upward pogo velocity → observed | PASS; up/forward static queries in core suite |
| Damage/death/hazard | Core suite calls damage and hazard in game context | One damage per immunity window, nonfatal hazard local ledge, fatal shrine respawn → observed | PASS |
| Focus exact duration | Held `heal` 60 then 10 physics frames at 60 Hz | At 1.0 s no heal/charge use, after 1.1 s +1 HP/−1 charge → observed | PASS; owner reports Linux healing PASS, not a separately measured stopwatch result |
| Focus interruption | Real held input then movement; core suite direct interruption | No HP/charge change, focus stops → observed | PASS |
| Drudge | M3 110 physics frames with player nearby | Detection → warning → attack → observed attack serial increased | PASS; owner reports Linux encounter PASS |
| Needle | C2 telegraph/active and rendered OpenGL frames | Red lane and visible moving shot → both visible; earlier projectile was invisible | PASS; added orange projectile polygon |
| Moth and concurrent AI | G2 two Moths over 125 physics frames; overrun committed target | Both attack, neither gets stuck; committed dive does not reverse → observed | PASS; fixed vector commitment |
| Dialogue safety | Locked player and attacking enemy test | No enemy harm while mandatory dialogue active → observed; AI timers freeze | PASS; added damage guard and AI lock |
| Enemy HP between rooms/rest | Partially wound C1 enemy, exit/re-enter, then rest/death core suite | HP remains until rest/death; dead enemy stays gone until rest/death → observed | PASS; run-local enemy HP ledger, never saved to disk |
| Boss integration fixtures | Defeat Warden/Cantor via core suite; live Warden receives ten directional slashes after M4 retry, then actual jump+dash exits | Warden dies, Echo Step/relay/exit flags commit; physical dash gap crossed to C1; C3 Cantor remains grounded and cannot award victory from displacement | PASS scripted; owner replay pending |
| C4 seal | Enter G1 after Sigil without optional interact | Gate opened flag persists → previously unset, now recorded | PASS |
| World/camera/shrines | Room links, spawn, camera limits, rest and hazard tests | Rooms load/unload; limits [0,1100]×[0,540], latest shrine activation and G4 reset → observed | PASS automated; owner reports Linux camera/route PASS |
| Save validation and relaunch | Core malformed/inconsistent cases; separate writer/reader Godot processes | Bad saves rejected; valid room/HP/charges/partial counter/ability/checkpoint survive relaunch → observed | PASS |
| Remapping | InputMap assertions, conflict rejection and menu fallback source review | Keyboard/controller actions mapped, conflicts rejected → observed in simulated actions | PARTIAL; no hardware controller. Remap persistence is **not required** by Phase 2 §10, but is a usability limitation. |
| Graphical dialogue and environment | Five OpenGL screenshots (`m1-player`, `c2-warning`, `c2-projectile`, `g2-warning`, `g2-dialogue`) | Player, warning, projectile and readable dialogue on screen → visually inspected and color assertions passed | PASS scripted; not a human playthrough |

## Independent-review corrections: red → green

| Issue | Reproduction before change | Expected / observed after change | Status / action |
|---|---|---|---|
| 1. Spawn origin | `tests/review_checks.tscn`: all M3/C2/G2 enemies rendered at intended spawn but **6 origin assertions failed**; first Moth at x100 moved away from intended x390 elevated home. | Six world origins now match their spawn (Moths now have a −15 y hover offset for attack accessibility); Moth displaced left closes distance toward `(390,385)`. **14/14 origin/recovery assertions pass.** | PASS; assign enemy position before `add_child` invokes `_ready` in `test_room.gd`. |
| 2. Pause/dialogue | Same frame-driven scene originally failed **6 assertions**: no `SceneTree` freeze, midair gravity, active dash, combat timer, projectile tween and dialogue freeze. | With `SceneTree.paused`, midair position/velocity, dash timer, combat timer, projectile position/damage, Focus and hazard exposure hold for 20–65 physics frames. On resume, movement, dash/combat timers, projectile and remaining Focus advance; hazard damage then occurs. Routed Interact advances mandatory dialogue, Esc cannot displace it; routed Pause and fallback Back both function while paused. **21/21 lock/resume assertions pass.** | PASS; main stays `PROCESS_MODE_ALWAYS` to receive UI input; player/room stay `PAUSABLE`; gameplay lock remains as input/damage guard. Godot automatically pauses the bound projectile tween. |
| 3. Nonfatal damage persistence | Two-process `damage_write` / `damage_read`: first process saved 4 HP, accepted a 1-damage hit, exited without further save; second loaded **4 instead of expected 3**, failing. | Second process loads **3 HP**; no room change, heal, or checkpoint intervened. Existing fatal-death test still confirms shrine respawn at 5 HP with approved resets. | PASS; nonfatal `Vessel.receive_damage()` saves after changing HP; fatal branch still delegates to `RunState.death()` and its single respawn save. |

Every new assertion ran red for the reported defect before production changes. The review suite finishes **35/35**, and the four independent-process writer/reader steps finish **4/4**. The screenshots are scripted evidence distinct from the subsequently owner-reported Linux gameplay QA below.

## M4 Toll Warden softlock: reproduction and correction

The owner's later Linux screenshot shows M4's open floor notch while the red exit barrier remains locked and the Warden is absent from view. `tests/boss_arena_checks.tscn` recreated a rightward Warden charge near the notch with the encounter active: before the correction the boss reached `(868.9, 1121.8)`, was not on the floor, and remained in `idle` rather than triggering victory or recovery (**one failing arena assertion**). Warden's body and floor collision layers matched; its spawn `(660,450)` was valid. The cause was M4's unconditional floor gap at x800–895 during the locked encounter, combined with gravity and no boss out-of-bounds recovery. The approved Phase 2 M4 description calls for no lethal pit during the boss fight and a protected gap only after victory.

The previous temporary grate avoided the fall but disappeared on victory, producing an unnatural new hole inside the fight area. The owner approved a continuous boss deck while preserving the Phase 2 mandatory dash gap beyond it. M4 now has an uninterrupted floor x0–825, temporary enclosing end walls during combat, and a pre-existing x825–1020 transition gap behind the right wall. The Warden spawns centrally at `(480,450)`; wall collision stops both shoves. Shared horizontal drag prevents hit recoil from sliding Warden/Cantor indefinitely toward a rear wall. Warden emits `defeated` **only** at zero HP in `receive_hit`; forced offscreen displacement with remaining HP does not award victory or Echo Step. We could not reproduce the owner's asserted fall-causes-victory sequence directly; the earlier grate disappearing after a legitimate death explains the observed hole but does not prove its timing. Ten live directional slashes, atomic reward, actual jump+Echo Step gap traversal to C1, shrine retry and durable reload pass. C3's continuous floor and non-victory on offscreen displacement pass. **20/20 arena checks pass**; corrected manual play remains pending.

## G1/G2 accessibility, C1 shrine, and owner-approved Double Jump

Glass Moths spawned at y400 but returned to y345; their short committed dive ended too high for a ground upward slash to overlap their 28×28 hurtbox. A red test in G1 and both G2 placements failed the real combat query. Lowering only the hover offset from 55 to 15 places their recover/home at y385; after a telegraphed dive, ground upward slashes now hit and defeat all three placements. The GDD's 0.7 s telegraph, committed target and two-HP threat remain intact. C1's blue x210–250 block is the approved shrine/checkpoint, not a platform or obstacle; it now reads `SHRINE  E/RB TO REST` in the room. **12/12 checks pass.**

The owner authorized Double Jump after C3 alongside the Sigil, overriding only the Phase 2 exclusion of that ability. A distinct tunable 360-unit upward impulse consumes one airborne use after a fresh Jump press; landing and wall jump restore it, while pogo and Echo Step do not. A short wing flash and HUD/controls hint explain it. Tests cover pre-unlock denial, hold versus second press, third-press denial, landing, ledge walk-off, ceiling collision, wall jump, dash, pogo, controller Jump mapping, save/load, and version-1 save migration. The C3 reward commits the unlock with the Sigil; new version-2 saves validate parity, and old saves migrate without resetting progress. **19/19 checks pass**, plus independent-process save tests include the unlock; physical-controller input still needs device testing. Rendered captures show C1 shrine cue, enclosed and post-victory M4, and the temporary wings; **7/7 graphical checks pass**.

## Owner-operated Linux gameplay QA

The owner earlier reported all 21 cases in `MANUAL_GAMEPLAY_QA.md` PASS on Linux. A subsequent owner-operated M4 session discovered the progression-blocking Warden fall described above, superseding the earlier "no blocking defects" statement for M4. The corrected encounter passes scripted checks but needs an owner-operated replay before manual M4 verification is restored. The original 21 results remain a historical attestation, not an agent-run replay; exact input device and launch method were not supplied. P5/S3 physical-controller substeps and E1/S3 conditional Windows substeps do not establish independently verified device or Windows execution.

## Export provenance and limitations

Official Godot 4.7.2 standard template archive from `https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz` was checked against upstream release SHA-256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`. Installed only matching `linux_release.x86_64`, `windows_release_x86_64.exe`, and `version.txt` in the user's Godot template directory. The Windows executable is a validated PE file but has not been launched: no Wine binary or Windows host exists here. `/dev/input/js*` has no attached joystick. `computer_use` delivered background synthetic keys without confirmed effect and foreground X11 focus could not be confirmed; do **not** infer a human keyboard/controller gameplay pass from automated action presses. See `MANUAL_GAMEPLAY_QA.md`.

## Residual risks

- Owner replay of the corrected M4 encounter remains outstanding; the earlier 21-case attestation does not close this newly discovered defect. Physical-controller device/evidence and Windows runtime remain unverified. Task 1 meets applicable export/startup criteria; no Windows runtime success is claimed.
- The test rooms are geometry scaffolds, not the final 60-minute world. Bosses are reward integration fixtures, not approved complete Phase 4 encounters; G4 has no final fight by design.
- Remaps reset on relaunch; no approved requirement says they must persist, but owner should assess accessibility impact. Controller glyphs are generic Xbox-style and may be wrong on another device.
- No final art/audio. Warning lines and projectile shapes remain provisional; controller dead zones and Windows presentation require separate device/platform QA. Linux encounter feel and camera behavior were reported as PASS by the owner.
