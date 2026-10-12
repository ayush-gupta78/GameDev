# Phase 4 corrected build — test report

Godot `4.7.2.stable.official.ed1daf0bf` on Linux. Owner manually tested the preceding Phase 4 build and requested targeted corrections; **the corrected build remains pending owner gameplay verification**. Windows runtime and physical-controller operation are UNVERIFIED. Prior Phase 3's **177 passed / 0 failed** remain historical acceptance evidence in `PHASE3_TEST_REPORT.md`. The original Phase 4 review's **226 passed / 0 failed** evidence is preserved byte-for-byte in the untouched `vesperdeep-phase4-review.zip` and copied to `tests/evidence/phase4-original-226/`. These are historical runs and must not be added to the new run's count.

The final corrected-suite run actually executed **282 passed / 0 failed** (including rerun baseline assertions) across the rows below; `tests/evidence/execution-summary.json` and individual stdout logs capture the results. The fresh aggregate is not a measured balance score or independent human playthrough.

| Test scene | Passed / failed | Evidence |
|---|---:|---|
| Core gameplay/save (`run_checks`) | 64 / 0 | `tests/evidence/run_checks.log` |
| Physics/combat (`physics_checks`) | 17 / 0 | `tests/evidence/physics_checks.log` |
| Independent-review regression (`review_checks`) | 37 / 0 | `tests/evidence/review_checks.log` |
| Warden/Cantor arena (`boss_arena_checks`) | 28 / 0 | `tests/evidence/boss_arena_checks.log` |
| G1/G2 Moths/C1 (`new_issues_checks`) | 12 / 0 | `tests/evidence/new_issues_checks.log` |
| Double Jump/save migration (`double_jump_checks`) | 19 / 0 | `tests/evidence/double_jump_checks.log` |
| M1–M4 story/layout, M3 and C1 wall behavior (`shore_slice_checks`) | 32 / 0 | `tests/evidence/shore_slice_checks.log` |
| Input-driven M1→C1 route (`shore_route_checks`) | 16 / 0 | `tests/evidence/shore_route_checks.log` |
| M1–M4 curated encounter placements (`shore_encounters_checks`) | 14 / 0 | `tests/evidence/shore_encounters_checks.log` |
| Ordinary and climbable wall collision (`wall_contact_checks`) | 4 / 0 | `tests/evidence/wall_contact_checks.log` |
| Ground enemy pursuit and staggered combat (`ground_ai_checks`) | 5 / 0 | `tests/evidence/ground_ai_checks.log` |
| Moth disengagement, full warning, paired timing (`moth_checks`) | 7 / 0 | `tests/evidence/moth_checks.log` |
| Player/enemy/Warden contact recoil, stagger, separation (`contact_recoil_checks`) | 15 / 0 | `tests/evidence/contact_recoil_checks.log` |
| Four independent-process save/relaunch probes | 4 / 0 | `tests/evidence/relaunch_*.log` |
| Real OpenGL rendering assertions | 8 / 0 | `tests/evidence/visual_checks.log`; ten PNG frames under `tests/evidence/frames/` |

Specific checks exercise actual C1 ordinary boundary gravity, synthetic ordinary-wall refusal to wall jump and actual M3 marked chimney slide/synthetic marked wall jump; Glass Moth physical separation, committed dive damage, full-length visual warning, hover recovery, G2 pair warning staggering and actual upward slash defeat; directional ground/airborne player-enemy recoil, brief stagger and recovery, passive overlap without extra HP damage, simultaneous-hit immunity, boss resistant recoil and arena containment, and weapon/body separation; Drudge pursuit, melee-range decisions, group staggering and home bounds; M1–M4 encounter placement; Warden pursuit, premarked avoidable drop, late-fight pressure, shove reach, continuous arena, death retry and HP-depleting combat victory; reward flags, save migration, shrine health/reset, interruption/relaunch and genuine jump-plus-dash to C1. The M1→C1 route uses long invulnerability and repositioned boss strikes to isolate traversal and progression; it does **not** prove a fair human playthrough or boss difficulty.

`godot --headless --path . --editor --import`, Linux/Windows x86-64 release exports and the native Linux headless/graphical startup all returned exit 0. Logs are `tests/evidence/import.log`, `export-linux.log`, `export-windows.log`, `project_boot.log`, `linux_export_boot.log`, `linux_export_graphical.log`. ELF and PE executable formats and paired PCKs were confirmed. The graphical checks captured actual OpenGL frames for M1, M3, M4 and Phase 3 regression scenes. Windows was **not** run on Windows; no physical controller was attached. No 17-minute playtime claim is made; the approved GDD target is unchanged, and no route expansion or artificial delay was added.

Intermediate red tests and one modified old Focus/pause fixture are not final failures: the latter's original M1 position is now in combat range, so it uses invulnerability to isolate paused Focus timing. A new encounter test first failed before the encounter placement change, ordinary wall/moth/ground/boss tests were red before their fixes, and the final unified run is green. See `PHASE4_MANUAL_QA.md` for the owner's next acceptance pass and `PHASE4_KNOWN_ISSUES.md` for limits. The original `vesperdeep-phase4-review.zip`, `vesperdeep-phase3-final.zip`, Phase 3 source and approved Phase 2 GDD were not modified.
