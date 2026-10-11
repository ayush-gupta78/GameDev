# Vesperdeep — Reference Traceability and Evidence Audit

**Phase 2 final design specification · INTERNAL.** Audit completed against the supplied `docs.zip` and `analysis.zip` **only**. No Silksong reference, online guides, unsupplied game files or memory-based mechanical values used. All Vesperdeep rooms, characters, telegraph times, health values and visuals are **original designs**; **D1 health/healing, D2 retry and D3 platform/input choices are now owner-approved**, while other combat timing remains provisional. None is a claim of extracted Hollow Knight content.

## 1. What was actually supplied

### `docs.zip` — evidence structure

- `docs/reference-analysis/00-source-manifest.csv`: source-inventory manifest.
- `01-file-inventory.md` through `11-gaps-and-implementation-priorities.md`: ten numbered narrative/mechanics/reference chapters and the final gaps chapter; `05-boss-mechanics.md` includes the extended boss FSM appendix.
- `docs/reference-analysis/evidence/`: 18 artifacts including selected managed-assembly IL/JSON/type indexes, build scene list, global settings, two boss-scene inventories, decoded boss FSM JSON, readme, index and SHA-256 records.
- **Coverage boundary reported by Phase 1:** first-party original Hollow Knight archives `hk-gameplay.zip`, `hk-scene-map.zip`, `hk-boss-scenes.zip` were analyzed during Phase 1, but **those original three source archives are not separately included in this Phase 2 submission**. Their extracted evidence and analyst conclusions are what Phase 2 can inspect and cross-check. The extraction source may be revisited only if the owner later supplies it; no first-hand byte-level re-extraction was performed in Phase 2.

### `analysis.zip` — independent supplement or duplicate?

- `analysis/hollow-knight-boss-scenes-report.md`: longer original-path variant of the comprehensive boss report in `docs.zip`; substantial textual overlap, the docs version includes portability changes, clarified transition counting and two empty-destination transition caveats.
- `analysis/hollow-knight-boss-scenes-fsm-decoded.json`: **byte-for-byte identical SHA-256** to `docs.zip/docs/reference-analysis/evidence/boss-scenes-fsm-decoded.json`. It is **not** independent verification. It is the same decoded evidence redistributed.

**Important limitation:** Two copies of an analyst report / decoded JSON increase access, not evidentiary independence. Both still derive from the same source scene extraction and selected IL; reported runtime timings, pose outcomes and exact engine behavior cannot be concluded solely from them.

### Cross-checked quantitative facts

| Finding | Evidence anchor | Status |
|---|---|---|
| Source build metadata lists **501** scenes | `evidence/build-scenes.json`, `06-world-and-progression.md` | **CONFIRMED from extracted metadata**; not a known full connectivity graph |
| The supplied boss scenes are level **409** (`Room_Final_Boss_Core`) and **447** (`GG_Hollow_Knight`) | `evidence/build-scenes.json`, `level409-inventory.json`, `level447-inventory.json` | **CONFIRMED** mapping |
| Level 409: **103 FSMs, 741 states, 854 state-local transitions, 33 global transitions, 2699 actions** | `05-boss-mechanics.md` coverage table, decoded JSON | **CONFIRMED serialized analysis** |
| Level 447: **43 FSMs, 390 states, 495 state-local transitions, 13 global transitions, 1312 actions** | same | **CONFIRMED serialized analysis** |
| Two level409 transitions point to an empty destination name (2329/`Move test`; 2551/`Land`) | `05-boss-mechanics.md` empty-destination subsection, decoded JSON | **CONFIRMED string values; runtime meaning UNKNOWN** |
| Phase 1 itself labels the full world graph, player tuning, ordinary enemy prefabs and runtime camera feel incomplete | `11-gaps-and-implementation-priorities.md` | **CONFIRMED limitation** |

## 2. Method and confidence definitions

- **VERIFIED STATIC:** explicit selected managed IL assignment/conditional or actually decoded serialized scene field, state, transition or bound value. This does **not** certify the player's observed runtime feel, all reachable state paths, or the full installed game.
- **SUPPORTED INTERPRETATION:** a design principle drawn from multiple static observations, such as anticipating attacks then recovering. This is a reasoned translation, not proof of exact original timing or global coverage.
- **ORIGINAL DESIGN:** new Vesperdeep ability scheduling, room topology, stats, narrative, difficulty and attack patterns; requires later prototyping/playtesting to confirm performance.
- **UNVERIFIED / UNKNOWN:** not in the supplied extraction or requires runtime prefabs, external assets or actual play.

Do not use the phrase “Hollow Knight has a 0.7 s Toll Sweep” or similar; **Toll Sweep and its durations are our original proposals**.

## 3. Evidence-to-decision matrix

| ID | Phase 1 evidence (primary locator) | What the evidence supports | Phase 2 decision and doc | Evidence boundary |
|---|---|---|---|---|
| **R01** | `02-player-controller.md` → `HeroController.FilterInput`, RVA `0x2BDF8`, axes strict 0.3/0.5 thresholds; `HeroController.Move` RVA `0x2527C` | Directionally filtered input and direct horizontal velocity selection | Crisp left/right motion; forward and up/down attacks in [`gameplay-progression.md`](gameplay-progression.md) | **VERIFIED STATIC** architecture. New movement speed/axis configuration **ORIGINAL DESIGN** |
| **R02** | `02-player-controller.md` → `.ctor` RVA `0x2BFF8` jump queue 2 fixed steps, ledge buffer 2, head bump 3; `Jump` RVA `0x253DC`; `CancelHeroJump` RVA `0x26128` | Buffered jump and variable-height release behavior | Beginner-friendly jumps, wall shaft and safe landing areas M1/M3 | **VERIFIED STATIC** structure and listed counts; exact gravity/jump steps unknown |
| **R03** | `02-player-controller.md` → `DoWallJump` RVA `0x28984`, wall-slide contact; `HeroDash` RVA `0x28C14`, `Dash` RVA `0x25E2C`, `FinishedDashing` RVA `0x29EA0` | Wall-jump resets some air uses; dash consumes a single air use until landing, suspends gravity during dash | Base wall jump; one unlock, **Echo Step**, in M4; two mandatory dash gaps | **VERIFIED STATIC** state rules; acquisition position and gap sizes **ORIGINAL DESIGN** |
| **R04** | `03-combat-system.md` → `HeroController.DoAttack` RVA `0x28B48`; `NailSlash.FixedUpdate` RVA `0x2CBEC`, active from step 1 through step condition ≥5; `NailSlash.OnTriggerEnter2D` RVA `0x2CC94` | Three-direction slash selection, hitboxes and downward bounce | Three-direction slash/pogo and stagger windows for all encounters | **VERIFIED STATIC** behavior; swing lengths / bounce distances unknown |
| **R05** | `03-combat-system.md` → `DamageEnemies.DoDamage` RVA `0x34B98`, `HitTaker.Hit` RVA `0x10E98`, `HealthManager.TakeDamage` RVA `0x3892C` | One damage packet/responder path, recoil, immunity and death | Shared hit-response and clean hazard lifecycle across three enemies/three encounters | **VERIFIED STATIC** structure. Proposed 5 health and 1-hit damage **ORIGINAL DESIGN** |
| **R06** | `03-combat-system.md` §Health/SOUL; `11-gaps-and-implementation-priorities.md` explicitly marks healing/spells incomplete | Resource gain hooks exist; precise healing cost/cast time not established | **Owner-approved D1 Gather/Focus** (3 landed attacks→1 charge, **max3**, stationary 1.1 s Focus, 1 HP/charge, interruptions preserve charge) | **ORIGINAL DESIGN**. Never mislabel as confirmed Hollow Knight healing |
| **R07** | `04-enemy-ai.md` → `Walker.UpdateWalking` RVA `0x3D298`; reusable detectors, hit effects, recoil components | Patrol with wall/floor checks; modular target detection and action boundaries | Paper Drudge walker, Choir Needle ranged stationary, Glass Moth dive | **SUPPORTED INTERPRETATION**; actual source ordinary enemy prefabs absent; all three designs original |
| **R08** | `05-boss-mechanics.md` / `analysis/hollow-knight-boss-scenes-report.md`; level409 Control FSM **2329**, Phase FSM **2320** | Attack antic→active→recover; phase controller; narrative death path (phase 4 250 HP reset) | Listener with 3 clean attacks, cinematic threshold and one proper phase-two conversion | **VERIFIED STATIC** source FSM structure. No transplant of exact boss phases/stats |
| **R09** | `05-boss-mechanics.md` level447 Control **1959**, Stun Control **1954**, HP **2053**; focus and tendril antic sequences | Introduced late-move vocabulary, readable windows, short staggers, optional dynamic HP phases | Last Wyrm uses 3 attack silhouettes, 1 mid-fight breath/stagger, **no third phase** | **SUPPORTED INTERPRETATION** of design practice, not copied moves |
| **R10** | `05-boss-mechanics.md` level409 `HealthManager` **2613** HP1000+reset250, 24 hit objects all 1 damage; level447 `HealthManager` **2053** base1600 with potential scale1850 and 27 hit objects 2 | Serialized source stats are encounter- and difficulty-specific | All our enemies/bosses separately tuned for 60 min / 5 health, 1-hit damage | Source values **VERIFIED STATIC**; new numbers **ORIGINAL DESIGN** |
| **R11** | `06-world-and-progression.md` → `TransitionPoint.TryDoTransition` with source gate `left1` → `Room_Final_Boss_atrium/right1`; `SceneLoadInfo`, `GameManager.BeginScene` | Named destination + entry marker, room-local persistence | Twelve named rooms and declared two-way exits; persist gates and boss clears | **VERIFIED STATIC** transition architecture, **UNKNOWN** full source world graph; 12-room graph original |
| **R12** | `06-world-and-progression.md` → `PlayerData.SetBenchRespawn`, `SetHazardRespawn`, `SceneData.SaveMyState` | Distinguishes durable checkpoints, room-local hazard recovery, persistent objects | Four shrines, safe ledge respawn, cleared minibosses and shortcuts | **VERIFIED STATIC** data pathways; recovery damage/bench UI **ORIGINAL DESIGN** |
| **R13** | `07-camera-system.md` → `CameraTarget.Update`, `CameraController.LateUpdate`, `CameraLockArea::OnTriggerEnter2D`; level409 locks **2680–2684**, level447 **2138–2141** | Separate follow target, damping and arena lock bounds; boss intro lock | Bounded room camera, fixed boss intro, widened Last Wyrm framing | **VERIFIED STATIC** structure/selected scene lock bounds; smoothing and projections **UNKNOWN** |
| **R14** | `08-animation-and-visuals.md` → gameplay/animation/collider synchronization, attack and impact effects; `05-boss-mechanics.md` §Audio | Communicative audio/visual phase changes, tell/active/recovery | Unique original bell, paper, glass telegraphs; no copied sounds, sprites, animation | **SUPPORTED INTERPRETATION**; exact animation frame events/resource payloads partial |
| **R15** | `09-game-architecture.md` → global state, scene FSMs, transitions, save flows; `10-master-mechanics-reference.md` P0/P1 | Composable responsibilities without recreating original architecture | Small finite required flag set, one encounter interface, one save state | **SUPPORTED INTERPRETATION**; not an engine choice or implementation instruction |
| **R16** | `11-gaps-and-implementation-priorities.md` Phase 2 readiness and limits | Exact tune cannot be claimed; scope reductions suggested | Single dash unlock, no double jump/charm/spell economy; every tuning value tagged provisional | **VERIFIED STATIC** documentation gap; scope selection **ORIGINAL DESIGN** |

## 4. Boss reference cross-check (what is and is not safe to transfer)

**Confirmed by decoded fields and report:** level409's boss has phase thresholds 750 and 400, later decline/music beats 275 and 150, special zero-to-250 fourth pool; level447 defines one-third/two-thirds thresholds in its control logic, base HP 1600 with potential 1850 scale; both have stagger metadata and antic/recovery states. These show **how** to structure an encounter, not **what** health or exact animation speeds are good for this short game.

**Not confirmed from Phase 1 for Vesperdeep or ordinary Hollow Knight play:** the best fight duration, exact responsive animation frames, what one would feel while holding a controller, actual route lengths, miniboss analogues, controller's serialized runtime speed/gravity, whether source static FSM edges execute in every difficulty, or exact source camera smoothing. All telegraphs and timing values in [`characters-and-bosses.md`](characters-and-bosses.md) are provisional game-design targets.

**Important corrected extraction caveat:** `docs.zip` clarifies 46 **global transitions** in addition to 1,349 **state-local transitions** across both boss scenes. Its two level409 empty-destination transitions have **unknown live consequences**. Nothing in this design relies on those exceptional edges.

## 5. Missing, incomplete or unverified evidence register

| Topic | What is missing / why | Effect on Phase 2 | Approval or future verification |
|---|---|---|---|
| Full player prefab/controller serialized values | Selected IL exposes field usage, not final speed, collider and gravity configuration | All route gap widths and numerical movement envelopes provisional | Prototype/owner-authorized measurement in Phase 3 |
| Player/ordinary-enemy visual rigs | No complete player sprite/collider prefabs and enemy scenes in supplied evidence | Cannot guarantee precise pogo, recoil or enemy frame timings | Original assets + later in-game validation |
| Healing | Only partial source resource/cast analysis | Discrete Focus system **D1 owner-approved original design**, not extracted mechanic | **Decision final; runtime verify only after Phase 3 authorization** |
| Full 501-room topology | Build list contains names but only two encounter scene graphs supplied | World route is original logical design, not fidelity claim | Design approved route and test in engine later |
| Doors, lifts and ability-gated source rooms | Architecture yes, representative exploration gate configurations no | Proposed physical gate interactions are new | Test each required gate in Phase 3 |
| Boss runtime probabilities and phases | Complex omitted backing arrays; fixed scene values do not prove actual runtime bindings for all modes | Do not copy random weights or timings | Use simple authored moves, tune later |
| Camera rig, lookahead tuning, display constraints | Core controller architecture visible, exact saved rig / runtime pixels not observed | Room camera design descriptive only | Prototype across aspect ratios |
| Animation/tk2d frame tables/audio samples | Names and a few native clip details, not full authoritative frame tables/resources | Attack hit timing must be authored from original animations | Build original audiovisual feedback |
| Source archive independence | `analysis.zip` duplicates a JSON included in `docs.zip`; original `hk-*.zip` are not in the uploaded Phase 2 set | No independent recomputation of extraction possible here | Owner can supply raw archives if more reference work authorized |
| Player skill and the one-hour runtime | No completed Vesperdeep game exists | 60-min breakdown is a hypothesis | Run timed novice/normal tests after Phase 2 approval |

## 6. Correction-pass design trace (source findings unchanged)

The following changes are **original Phase 2 narrative, routing and scope clarifications**; they are **not** claims about recovered Hollow Knight behavior:

| Correction | Phase 2 rule | Source-status boundary |
|---|---|---|
| S11/S12 spoiler line | S11 stays masked/unidentified through final frame; S12 alone unmasks/names Pale King | Script secrecy rule, **ORIGINAL DESIGN**; no reference asset evidence altered |
| Required first NPC encounters | M2 Edda+Pip, C2 Thren, G2 Asha each auto-trigger at an unavoidable onward threshold; first dialogue completion persists | Passage placement and flags **ORIGINAL DESIGN**, not extracted NPC/script data |
| Cast taxonomy and Pip | Five major narrative NPCs; both minibosses nonverbal; Pip has no note quest | Script/scope **ORIGINAL DESIGN**; existing enemy and boss source evidence unchanged |
| G3 latch | Opening required for G4 approach; shortcut traversal optional | Gate/room graph **ORIGINAL DESIGN**; source reference supports general state persistence but not this route |
| Timing and numbers | S05 17–21 min, S06 21–28 min; exactly 9 ordinary enemy placements | **ESTIMATED** pacing, unmeasured; placements are design counts |
| **D1–D3 final owner decisions** | D1 max **3** discrete charges and fixed heal contract; D2 death in either final phase resets to **G3 → Listener Phase 1** with canonical story flags persisted; D3 Godot 4/Linux development/Linux+Windows/keyboard+controller/remapping | **OWNER REQUIREMENTS / ORIGINAL DESIGN**. These are **not** new Phase 1 reference findings; prior references and extracted evidence remain untouched |

This pass does not edit, replace or recalculate Phase 1 source interpretations R01–R16. No new original raw game archives were supplied.

## 7. Provenance integrity summary

Both ZIP files were enumerated, extracted as data, and inspected. All **15 SHA-256-indexed evidence artifacts** match their recorded sizes and hashes; both boss scenes' decoded FSM state, transition, action and disabled-action counts were independently recounted from the supplied JSON. The decoded boss JSON occurs twice and is identical across archives; the report is closely related, with a portability/update difference. The evidence was used **without executing source binaries** and without building game code. The docs version's latest qualifications (including global-transition counts and unknown transitions) supersede any casual shorter summary.

**Correction-pass archive check (11 October 2026):** re-read the supplied ZIP data; independently matched all **15/15 SHA-256-indexed evidence artifacts** in `docs.zip` to the bundled checksums and confirmed that the decoded boss FSM JSON in `analysis.zip` matches the copy in `docs.zip` **byte for byte**. This independently confirms *integrity and duplication of the supplied extracted files*, not the accuracy of the original decompilation against raw game archives or any in-game runtime behavior. Findings R01–R16 and the Phase 1 source files remain unchanged.

**Phase 2 conclusion:** sufficient to author a coherent, evidence-conscious original game design; **not** sufficient to certify exact Hollow Knight mechanical fidelity, runtime behavior or a true 60-minute completion time. No material finding from Silksong was used.
