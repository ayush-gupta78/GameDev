# Vesperdeep — Gameplay Progression and Story Integration

**Phase 2 final design specification · INTERNAL.** Single intended 60-minute first playthrough, supported by two optional loopbacks. This is a behavioral design contract, **not** implementation instructions or code. Rooms: [`world-design.md`](world-design.md). Text: [`complete-script.md`](complete-script.md).

## 1. Playable ability set and exclusions

| Ability | Acquisition | Use in mandatory route | Evidentiary status |
|---|---|---|---|
| Walk/run, variable-height jump, falling, facing | Starts M1 | Basic navigation, all arenas | Phase 1 confirms controller structures but exact speeds/gravity remain unknown (`02-player-controller.md`) |
| Wall contact/slide/jump | Starts M1; introduced safely in M3 | M3 shaft, recovery from C2 shelving and G3 ledges | Source-backed state concept, numeric calibration original |
| Three-direction slash (forward/up/down) | Starts M1 | Combat, downward pogo off safe hostile surfaces | Phase 1 confirms selection/hitbox and bounce paths (`03-combat-system.md`) |
| **Echo Step** (one horizontal dash; one air use reset on landing/wall jump) | **M4** after Toll Warden | M4→C1 and G3→G4 gaps; optional combat dodges | Adaptation of source-backed dash state rules; speed/duration original |
| **Gather/Focus** (hit-earned heal only; no spells) | Starts M1, taught with damage-safe prompt | Survivability in boss fights, never traversal gating | **Owner-approved D1 discrete healing charges; source's exact healing loop is partial** |
| Resonance Sigil | **C3** after Bell Cantor | Opens C4→G1 gate | **Item/flag**, not an ability or new combat action |

**Explicitly cut:** double jump; shadow/down/super dash; acid swimming; spells; dream attack; charms; nail arts; currency/shop/map-pins; multiple weapons; elevation-changing elevators; skill tree; alternate endings; optional bosses. Avoid implementing mechanics just because the source contains them.

### Playability targets (original tuning, not verified source numbers)

- **D1 approved:** player starts with **5 HP**. Standard enemy contact and all miniboss/final-boss damaging hits inflict **1 HP per hit**. Avoid unavoidable stun-lock; post-hit invulnerability must exceed the contact-overlap's danger window.
- Attack: short single-strike sequence, no high-complexity combos. One enemy can only receive one damage event per swing. Directional down-strike grants a responsive pogo; wall-jump resets one air dash as in the reference evidence.
- **D1 approved Gather/Focus:** every **3 successful attacks** against valid enemies or bosses earns **1 discrete healing charge**, maximum **3 stored charges**. Holding Focus **stationary for 1.1 seconds** completes one heal, restores **1 HP**, and consumes **1 charge**. If interrupted before completion (including by damage or movement), **no HP is restored and the charge is preserved**; an incomplete attempt cannot consume a charge. Healing is unavailable at 5/5 HP. Charges persist across room transitions, but reset to **0 upon true death**; shrine rest restores HP only, not charges. Boss transitions offer no extra targets for farming. These are **owner-approved original design values**, not recovered Hollow Knight values; there is **no Soul meter or extra healing mechanic**.
- Important combat assists: obvious anticipation silhouettes; audible AND visible tells; one active hit cannot double-damage through overlapping contact/projectile colliders. The **S12 phase break restores health to 5/5 on each successful Phase 1 clear**, but is **not a retry checkpoint**; D2 always restarts a fatal attempt from Phase 1.

## 2. Mandatory route (exact dependency order)

| Order | From → to / flag set | Required competence / information | Outcome |
|---:|---|---|---|
| 1 | M1→M2; M2 exit requires `edda_met` | Jump, horizontal slash; **forced first Edda/Pip exchange** | Edda/Pip teach immediate goal; checkpoint M2; no bypass/quest |
| 2 | M2→M3→M4 | Vertical wall jumps, basic enemy encounters; toll latch | Reach miniboss 1 with safe runback |
| 3 | M4 win; `warden_defeated`, `echo_step_owned`, `shore_relay_off` | Read sweeping/stomp tell | Dash pickup and C1 exit open; partial Shore recovery |
| 4 | M4→C1 | Mandatory short dash gap | Reach Choirwater; checkpoint C1 |
| 5 | C1→C2; C3 exit requires `thren_met` and `engine_objective_known` | Read ranged attack; **forced first Thren exchange** | Learn sigil condition before encounter |
| 6 | C2→C3 win; `cantor_defeated`, `choir_relay_off`, `resonance_sigil_owned` | Dash+slash during three readable patterns | C4 opens; partial return of unscripted notes |
| 7 | C3→C4→G1; `glass_gate_open` | Sigil auto-opens seal | Conservatory reached; checkpoint G1 |
| 8 | G1→G2; G3 exit requires `asha_met` | Handle modest aerial pressure; **forced first Asha exchange** | Asha conveys theme without lineage |
| 9 | G2→G3; **pull mandatory Mirror Latch**; `mirror_latch_open` | Read late hints; latch opens G4 approach, shrine and two-way G3↔M3 route | Opening latch mandatory; **travel through shortcut optional** |
| 10 | G3→G4; `final_p1_started` | Dash over safe final gap | Listener boss; title concealed |
| 11 | P1 victory → S12; `final_p1_cleared` and `final_p2_unlocked` are **attempt-local**; canonical `identity_revealed` and `veyra_sacrificed` persist once | Survive first moveset | First clear reveals Pale King and Veyra's one-time sacrifice; later retries use a short non-diegetic transformation transition |
| 12 | P2 victory; `final_boss_defeated`, `hush_engine_off`, `ending_available` | Apply all learned dodge/attack skills | Boss gone, Engine off; S14 epilogue begins |
| 13 | S14 epilogue; `story_complete` | No new input or key | All memory and agency return; canonical ending completes |

**Mandatory first-encounter contract:** approaching the sole onward threshold in **M2/C2/G2** automatically starts respectively **Edda+Pip / Thren / Asha** unless already completed; a voluntary earlier interaction is equivalent. Exit to **M3/C3/G3** is impassable until respectively `edda_met` / (`thren_met && engine_objective_known`) / `asha_met` is saved upon completing the first exchange. Interrupted scenes re-trigger on the same side of their thresholds; jumping, dashing, hazard recovery, deaths and later optional shortcuts cannot bypass the first-time requirement. Only first encounters are mandatory, not optional follow-up text. **Pip's line is not a note-retrieval quest** and has no objective/item/flag.

## 3. Progression condition table

| Path / event | Gate expression in plain language | Opens with | What prevents a softlock |
|---|---|---|---|
| M2→M3 passage | Edda/Pip first exchange completed (`edda_met`) | Mandatory M2 proximity conversation | Auto-trigger at exit even if manual interaction skipped; replay if interrupted |
| M3→M4 boss start | First reach M4, no key | Basic moveset | M3 approach latch creates short repeat path |
| M4→C1 | Warden defeated **and** Echo Step owned | M4 single encounter/automatic pickup | Pickup flag is committed at defeat; room cannot unlock early without dash |
| C2→C3 combat | Thren first exchange completed (`thren_met && engine_objective_known`) | Automatic C2 passage trigger or early manual interaction | Cannot exit C2 without both flags; return route stays open |
| C3→C4 | Bell Cantor defeated | C3 victory | Victory simultaneously awards sigil and toggles passage |
| C4→G1 | Resonance Sigil owned | C3 victory | Sigil never consumable or missable |
| G2→G3 passage | Asha first exchange completed (`asha_met`) | Automatic G2 passage trigger or early manual interaction | Sole first-visit path blocks progress until completion; no collectible or quest |
| M3↔G3 shortcut **and** G4 approach barrier | **Mirror Latch must be pulled at G3** | G3 mandatory main-path action | Link opens two-way persistently; **traversing it remains optional** |
| M2↔C2 hatch | Lever pulled from C2 | C2 optional | Never the only exit; no first-route gate bypass |
| G3→G4 | `asha_met`, `mirror_latch_open` and Echo Step owned | Asha first scene, mandatory G3 latch, M4 guaranteed dash | No independent `g4_entry_ready` save flag; G3 shrine lies beyond latch before dash gap |
| G4 phase 2 | Current attempt has cleared Phase 1 and completed S12/its abbreviated retry transition | After Listener first pool depleted **in that attempt** | **No Phase 2 retry entry**; a death in either phase resets both combat pools and returns to G3 for a new Phase 1 attempt |
| Story ending | Last Wyrm defeated | G4 phase 2 | No dialogue choice, item collection or hidden boss needed |

**No irreversible lost state:** On death, completed pre-final bosses, NPC conversations, acquired abilities, mandatory latch and reached shrines persist. **D2 final encounter exception:** dying in **either** G4 phase returns to **G3 shrine**, with 5/5 HP and 0 healing charges; the next G4 entry restarts **the Listener / Phase 1 at full HP**, not the Last Wyrm. Reset attempt-local phase/arena flags and both boss health pools. The first S12 reveal and Veyra sacrifice are permanent story facts once witnessed, but they never authorize a Phase 2 shortcut or checkpoint. After a replayed Phase 1 clear, the phase-change visual is abbreviated without a second in-world sacrifice or repeated identity revelation.

## 4. Shortcuts, recovery and persistence

- **Shrines:** M2, C1, G1, G3. The latest visited shrine is the usual durable checkpoint; **there is no additional final-boss or phase-two retry shrine**. **Entering M4, C3 or G4 reselects the already-reached nearby shrine M2, C1 or G3 respectively** as the encounter retry checkpoint, even if optional backtracking changed the most recent shrine. This adds no new shrine. Rest fully heals, respawns ordinary enemies, never revives bosses or resets gates. G3 shrine is directly before Cradle.
- **Local hazard recovery:** a short fall or shallow environmental hazard places the Vessel at the latest safe room-local ledge, costs one health mark and has a brief invulnerable recovery. This is separate from death respawn. Do not abuse to skip gates; a safe ledge always lies on the current side of an unopened gate.
- **True death:** restore all health at last durable checkpoint; reset Focus charges; retain unlocked abilities, defeated bosses, discovered NPCs and persistent gates. No shade/currency recovery mechanic because the project does not have economy.
- **Tollhouse and Cantor retries:** defeat flags set only on boss death; resetting a live attempt restores that miniboss's full health and arena elements but not global story progress prior to it. Enemy runbacks should take roughly **20–35 seconds** at intended movement tuning.
- **D2 final retries (approved):** death in **either phase** respawns at **G3**, refills to **5 HP**, resets healing charges to **0**, restores initial Phase 1 boss/arena state and both combat pools (Listener **18 strikes** / Wyrm **20 strikes**, design targets), and requires another full Phase 1 win. On each successful Phase 1 clear, S12 or its abbreviated replay refills HP to 5/5 for Phase 2. `final_p1_started`, `final_p1_cleared`, `final_p2_unlocked` and current boss HP are **attempt-local**, always reset on death/re-entry/reload of an unfinished finale; they never grant direct Phase 2 entry. `identity_revealed` and `veyra_sacrificed` are permanent once S12 first completes; replay shows **only** a short, non-diegetic metamorphosis visual (no second mother, death or new disclosure). Saving/reloading during either unfinished phase returns to the same G3 Phase 1 starting contract, never a half-complete cinematic.

## 5. Story-reactive systems with minimal overhead

| Trigger | Visual/audio/story change | Required? |
|---|---|---|
| Warden defeat | A single audible Shore bell; Edda's jars respond | Mandatory core event; revisiting Edda is optional |
| Cantor defeat | Water produces differing pitches; Basilica seal glows | Mandatory world feedback |
| First Conservatory arrival | Reflections visibly misalign before responding | Mandatory region mood |
| Asha conversation | Gardener touches bowl; hints at doctrine's emotional cost | Mandatory conversation |
| Phase break | Unmask, Veyra identity, sacrifice; boss transformation | Mandatory, first-time unskippable |
| Final victory | People recognize each other; no second collection loop | Mandatory epilogue |

No quest journal, dialogue-branch editor or complex reputation system is necessary. A short context prompt and one current objective line are sufficient for navigation.

## 6. Difficulty and tutorial ramp

1. **M1–M3:** teach jump, wall jump and basic slash with no lethal first mistakes. Introduce 2-hit walking enemies before M4.
2. **M4:** train two telegraphed boss moves and a short counterattack window; defeat directly provides the dash used at the exit.
3. **C1–C2:** allow optional dash revisits; introduce 1 ranged enemy with clear floor marker and fair line-of-sight breaks.
4. **C3:** layer projectile lanes and a pulse to make dash timing relevant. Prevent random unavoidable multi-hit overlaps.
5. **G1–G3:** introduce controlled aerial approaches and final dash over safe gaps; do not introduce a new movement upgrade.
6. **G4:** first phase recombines jump, dash and healing decisions; second phase recombines them with wider but slower attack silhouettes. No mandatory button introduced in the finale.

## 7. Proof of progression feasibility

**Initial set:** walk, jump, wall jump, up/forward/down slash, Focus.  
**M4 win** adds Echo Step before the first mandatory dash gate M4→C1.  
**C3 win** adds Resonance Sigil before C4→G1.  
**G3** is reachable by crossing the sigil gate from C4 **after finishing Asha's mandatory G2 scene**, and must open the Mirror Latch to approach G4. This action also opens the M3 shortcut, but **using** it is optional and cannot create a first-arrival bypass.  
**G4** requires `asha_met`, `mirror_latch_open` and Echo Step already acquired at M4; Thren and Edda are guaranteed by upstream chokepoints.  
**P2** requires only combat moves available since M4 and does not require a new finisher input.  
**Conclusion:** every mandatory skill/item precedes its first gated use, every initial gate is reachable, and every final-stage mandatory event has a clear trigger. This is **logical design validation**, not a completed engine playtest.

## 8. Parameter owners and unknowns

Godot 4 (Linux development; Linux and Windows targets), keyboard/controller support and remappable gameplay inputs are **D3 approved design requirements** (action definitions in [`implementation-handoff.md`](implementation-handoff.md)); no project/input code exists. Physics speeds, jump/dash envelope, attack range, interrupt timing implementation, enemy HP, encounter windups and camera follow timings still need prototype calibration. Phase 1 confirms much of the **shape** of these systems (`02-player-controller.md`, `03-combat-system.md`) but does not supply complete player prefab tuning or ordinary-enemy scene configurations. No exact Hollow Knight speeds or input latencies are asserted by this file.
