# Controls — keyboard and controller

| Action | Keyboard | Controller (Xbox-style) |
|---|---|---|
| Move / face | A/D or ←/→ | Left stick X or D-pad ←/→ |
| Aim slash | W/S or ↑/↓ | Left stick Y or D-pad ↑/↓ |
| Jump / short hop on release; press again in air for Double Jump after C3 | Space | A |
| One directional slash | J | X |
| Hold Gather/Focus | K | Y |
| Echo Step (after M4) | Left Shift | B |
| Interact / advance dialogue | E | RB |
| Pause / resume | Escape | Menu/Start |
| Menu navigation | Arrows or WASD | D-pad or left stick |
| Menu confirm / back | Enter or Space / Escape or Backspace | A / B |

The pause menu locks gameplay. Up/down selects a gameplay action; confirm then press a new key or controller button to rebind that device's action. R restores defaults. Conflicting bindings are rejected. Menu navigation/confirm/back are intentionally not remappable so there is always an escape route. Runtime remaps are not currently persisted across relaunches; use restore defaults if a binding becomes inconvenient. Both input schemes can be used together. Controller detection and button prompts are not yet fully device-adaptive.

The test scaffold uses E/RB on blue shrines (labeled in-room) and latches. M2/C2/G2 required first exchanges auto-start when approaching their onward exits. Defeating M4 Warden unlocks Echo Step; hold Jump and use Echo Step to cross the gap beyond its otherwise continuous boss arena. Defeating C3 Bell Cantor now also unlocks the owner-requested Double Jump alongside the Resonance Sigil: press Jump again while airborne. One extra jump is available until landing or wall-jumping; pogo does not reset it. A brief original wing flash marks the extra impulse. The G4 arena is only a transition/save-state test room, not a final boss fight.

## Run / verify

- Godot editor/project: `godot --path .` from the project directory. Godot 4.7.2 is the tested version.
- Linux native export: `./builds/vesperdeep-linux.x86_64` (on Linux, executable permission may need to be restored after extraction with `chmod +x builds/vesperdeep-linux.x86_64`).
- Windows native export: `builds/vesperdeep-windows.exe` on a Windows x86-64 computer. The Windows runtime has **not** been tested here.
- Automated checks: run `godot --headless --path . --scene res://tests/run_checks.tscn` and `godot --headless --path . --scene res://tests/physics_checks.tscn`. The independent-process save checks and graphical test commands are in `PHASE3_TEST_REPORT.md`.
- Game autosaves to Godot `user://vesperdeep_run.json`. For a fresh owner playthrough, back up this file using Godot's **Project → Open User Data Folder**, then remove that save before launching; do not remove other saves. There is no new-game button in the Phase 3 test scaffold.
- Follow `MANUAL_GAMEPLAY_QA.md` for the owner-operated checklist, including controller and Windows runtime tests.
