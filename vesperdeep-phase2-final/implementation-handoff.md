# Vesperdeep — Phase 2 Design-to-Implementation Handoff

**DESIGN SPECIFICATION ONLY · NOT AUTHORIZATION TO START PHASE 3**  
**Status:** Phase 2 **owner-approved D1/D2/D3 design specification**, 11 October 2026; numerical encounter tuning other than fixed D1 values remains subject to future playtesting, not current implementation authorization. **No gameplay code, engine project, executable, agent assignment or implementation has been produced in Phase 2.** This file is a future contract for an implementation agent *only after explicit approval*.

## 1. Authority and source order

1. **Owner's fixed brief** has priority: Vesperdeep, discarded Vessel, hidden Listener=Pale King, mother's sacrifice, transformation into Last Wyrm, one hour, three regions, two minibosses and one final two-phase boss.
2. **Phase 2 story bible** defines narrative canon and spoilers. [`complete-script.md`](complete-script.md) is authoritative for spoken lines, ordering and trigger placement.
3. **World and progression specs** define room IDs, connectivity, flags, gating and checkpoint lifecycle. In a conflict, flag the conflict for owner resolution—do not silently reinterpret.
4. **Boss/character spec** defines encounter intent and provisional moveset. Playtest tuning may change numerical targets without introducing new moves/characters/regions, but such changes still need owner-approved design authority.
5. **Phase 1 docs and underlying evidence** are reference support with confidence boundaries. The same evidence is traced in [`reference-traceability.md`](reference-traceability.md). Nothing authorizes direct copying of third-party assets, source code or dialogue.

## 2. Content manifest for a future team

| Content category | Required output content (functional, not file/engine structure) |
|---|---|
| Rooms | **M1–M4, C1–C4, G1–G4** (12 total, detailed in world spec) |
| Player | Walking, variable jump, start-enabled wall slide/jump, directional slash/up/down and pogo, basic Gather/Focus heal, unlockable Echo Step horizontal dash |
| Collectible / gate object | Single **Resonance Sigil** (passive gate credential), acquired C3; Echo Step acquired M4 |
| Ordinary enemies | Paper Drudge, Choir Needle, Glass Moth; **9 required placed instances** (4 Drudges + 2 Needles + 3 Moths) |
| Bosses | M4 Toll Warden; C3 Bell Cantor; G4 Listener first pool + Veyra interlude + Last Wyrm second pool |
| Major narrative NPCs | **Five:** Edda, Pip, Thren, Asha/Veyra, Listener/Pale King/Last Wyrm. Warden and Cantor are nonverbal miniboss combatants; unnamed Vessel playable; Rell signature only |
| Durable rest shrines | M2, C1, G1, G3; local hazard respawn markers where required; **G3 is the sole final encounter restart shrine, including Phase 2 death** |
| Interfaces | HUD shows 5-HP capacity and **0–3 discrete healing charges** (no Soul meter); interaction prompt; one current objective; masked boss and miniboss HP/title when fighting; room fade; cinematic subtitle panels; keyboard/controller prompts |
| Narrative | S01–S14 mandatory scenes and 7 optional environmental note triggers; one ending |
| Audio/visual families | Tide/ink, pipe/bell, white-glass/seeds; original assets only; all threat audio paired with visual cue |
| **D3 platform and controls (final)** | **Godot 4**, primary development on **Linux**, standalone exports for **Linux and Windows**, **keyboard and controller** for all required gameplay/menu actions, gameplay rebinding where practical; design action map in §10 |

**No requirements for:** map completion percent, currency, inventory grid, charms, dash variants, spells, difficulty modes, coop, voice acting, monetization, live service, game editor, multiplayer or proprietary game asset extraction.

## 3. Required persistent narrative and progression state

The following are *semantic flag names used in the Phase 2 documents*, not mandated engine identifiers or source code.

| Flag family | Meaning / expected persistence |
|---|---|
| `edda_met`, `thren_met`, `asha_met` | **First mandatory conversations completed** at M2/C2/G2 respective threshold; commit after full exchange, persist over death/exit; fail closed until recorded |
| `engine_objective_known` | Thren explains Bell Engine/sigil gate; commits **together with** `thren_met`; no independently missable state |
| `warden_defeated`, `shore_relay_off`, `echo_step_owned`, `m4_exit_open` | Must become true **together** when Warden defeat completes; permanent |
| `cantor_defeated`, `choir_relay_off`, `resonance_sigil_owned`, `c4_door_open` | Must become true **together** when Cantor defeat completes; permanent |
| `glass_gate_open` | Permanent once sigil-based opening occurs |
| `m3_toll_latch_open`, `mirror_latch_open`, `c2_hatch_open` | Persistent opened states. **M3 approach latch and G3 Mirror Latch are mandatory**; pulling G3 latch also opens G4 approach and G3↔M3 shortcut. **C2 hatch optional**. Traversing either cross-link is optional. No saved `g4_entry_ready` flag. |
| `checkpoint` | Last activated M2/C1/G1/G3 shrine; M4/C3/G4 entry selects nearby M2/C1/**G3** respectively. **Neither S12 nor Phase 2 creates any checkpoint or resume token.** |
| `final_p1_started`, `final_p1_cleared`, `final_p2_unlocked`, `final_p2_active` | **Attempt-local only**, never durable resume flags; on death in either phase or reload/exit of an unfinished G4 encounter, clear them and reset both phase HP pools/arena; next G4 entry is always **Phase 1 / Listener** |
| `identity_revealed`, `veyra_sacrificed` | **Durable canonical story flags** first committed after complete S12. Persist over death and re-entry without allowing Phase 2 skips. On replayed Phase 1 win, show only brief non-diegetic form change; never repeat the maternal death as an additional story event |
| `final_boss_defeated`, `hush_engine_off`, `ending_available`, `story_complete` | First three become true **together on S13 victory**; `story_complete` becomes true after S14 epilogue, not before. One canonical ending. |

**Atomicity and interruption rule:** abilities and their blocking gates must never be separated by a checkpoint/save. **NPC first scenes set completion flags only after full first exchange; an interruption re-triggers from the same side of the exit**. Re-entering completed rooms re-creates opened doors and **previously defeated minibosses remain defeated**; skipping replay-only dialogue never changes core flags. G4 approach is *derived* from `asha_met && mirror_latch_open && echo_step_owned` (prior sigil route is mandatory), never stored independently. **S11 stays masked through its final frame; S12 begins before identity is shown.**

## 4. Navigation and player-state acceptance contract

**Gates and connectivity** (must be proven with navigable tests after approval):

- M1→M2→M3→M4 remains possible with starting moves only; the **M2→M3 exit requires completed automatic first encounter with Edda/Pip** (or equivalent early manual interaction), never an item.
- M4 win grants dash and opens route to C1 in the same transition; the gap cannot be mandatory before the acquisition.
- C1→C2 and Thren are reachable without Resonance Sigil; the **C2→C3 exit requires `thren_met && engine_objective_known`**, with first dialogue automatically triggered on the sole onward route.
- C3 win opens C4 and awards the sigil. C4→G1 accepts that sigil permanently, does not consume it.
- G1→G2→G3 is reachable on starting abilities plus Echo Step, but **G2→G3 cannot be passed without completing Asha's auto-triggered first scene**. G3 requires pulling the **Mirror Latch** to release the G4 approach and two-way G3↔M3 shortcut; **using that shortcut is optional**. The C2→M2 hatch may optionally be opened from C2.
- G3→G4 requires `asha_met && mirror_latch_open && echo_step_owned`; the sigil gate was necessarily traversed first. It relies on no optional note, shortcut traversal, hidden key or double jump.
- No room admits an irreversible trap; before the final fight the player can walk back. While an active boss is underway, arena doors lock and correctly unlock on defeat/restart.

**D2 death and recovery (approved):** room-local environmental setbacks cost 1 HP and respawn at the last safe local ledge. True death refills to **5/5 HP** at the selected shrine, resets healing charges to **0**, and preserves permanent NPC, item, gate and story flags. **In G4, death during Phase 1 OR Phase 2 uses G3, resets all unfinished encounter state and both boss pools, and starts the next attempt from Listener / Phase 1**; there is **no direct Phase 2 retry**. On retry the encounter HUD starts **THE LISTENER** regardless of whether the true name is known; the first completed S12 revelation/sacrifice remains canonical but is not performed again. There must be no saved `resume_phase_2`, transient phase-2 checkpoint, or state allowing phase-two-only reentry.

## 5. Combat functional requirements

- A hit action has an **antic**, **active threat** and **recovery**; damage enabled only during active. Each source swing affects each target at most once.
- Three-direction slash selection and downward bounce are consistent across ordinary enemies and appropriate boss surfaces. Wall-jump resets air dash availability; ordinary landing does too.
- Player starts at **5 health marks**. Ordinary enemies and bosses do **1 damage** per legitimate hit; post-hit invulnerability must avoid multiple contacts from the same active move.
- **D1 approved Gather/Focus (fixed numbers):** **3 successful attacks** against valid enemies/bosses earn **1 discrete healing charge**, cap **3**; start/death-reset charges **0**. Focusing requires **1.1 seconds stationary** to restore **1 HP** and spend **1 charge** *only upon completion*. Any interruption before completion restores **0 HP** and preserves that charge. Can heal only below 5/5 HP with at least one charge; at cap, extra hits do not increase storage. No Soul meter or additional healing economy. Charge progress is earned from successful attacks, not swings into empty air; avoid transition hit farming.
- Enemy behaviors from [`characters-and-bosses.md`](characters-and-bosses.md) are the **only** mandatory roster and attacks. Boss hitboxes match visible silhouette and telegraph direction; no unmarked hit from an offscreen origin.
- During **every successful Phase 1 → Phase 2 transition**, player and boss damage are disabled, overlapping attack hitboxes clear, and player HP refills to **5/5** (the existing transition-heal benefit, **not** a healing charge or checkpoint). First S12 completion plays the full canonical unmask, sacrifice and transformation and durably records the story facts; subsequent attempts abbreviate only the **non-diegetic form-change visual** after Phase 1 is defeated again. Clear attempt-local phase flags on death/reload and never persist a Phase 2 resume position. The Wyrm uses one new HP pool and the same arena, not a separate third phase.

## 6. Dialogue, UI and secrecy requirements

- S01–S14 text from [`complete-script.md`](complete-script.md) is authoritative. **Edda/Pip in M2, Thren in C2 and Asha in G2** have forced one-time first exchanges on the sole onward thresholds; voluntary early interactions use those same scenes. The first time cannot be bypassed by player movement, retries, deaths or cross-links. Pip has **no retrieval quest**. Warden and Cantor use **nonverbal** cues and have no subtitles or spoken lines. Optional inscriptions may be read in any order without gating completion.
- **Throughout S11, including the zero-health moment,** player-visible UI must never contain **Pale King**, **Veyra**, **Last Wyrm**, identifiable faces/crowns or familial titles tied to the Listener. The boss bar remains **THE LISTENER** until **S12 begins after `final_p1_cleared`**. Hidden internal identifiers are acceptable only if never surfaced in player UX, metadata that loads early, logs displayed to the player or preview art.
- First-view S12 plays in order: **unmask → Pale King named → Asha named Veyra/mother → sacrifice → rejection of last choice → Last Wyrm form**. **Only on first completion** are `identity_revealed` and `veyra_sacrificed` committed. After a later Phase 1 replay, show a **short, non-diegetic shape-change transition** into Last Wyrm without repeating Veyra or replaying the revelation as a second event; preserve canonical flags. Do not unlock a Phase 2 shortcut or change first-time S11 reveal boundary.
- S14 reflects restored names, emotions and **capacity for choice** without undoing Veyra's death or promising a pain-free realm.
- Edda, Pip, Thren, Asha and the Listener are exactly five **major narrative NPCs**. Neither miniboss speaks; both combat encounters are preserved. Rell is offscreen optional environmental text, not an NPC or fetch target.

## 7. Presentation and camera contract

- Exploration follows within room bounds, readable look-ahead, no excessive disorientation; boss intros use fixed camera lock and arena lock after control returns. No unseen offscreen attack warnings.
- All environmental hazards have strong visual contrast relative to their region; audio cues cannot be the only accessibility channel.
- Cradle camera widens modestly when the single Wyrm silhouette appears; body art need not obey procedural serpent simulation or multi-part physics.
- One transition/fade treatment reused for all rooms; one simple HUD theme; optional visual polish cannot hide active hitboxes.
- All images/music/sound/fonts and animations for the standalone game must be original or otherwise appropriately licensed. **The Phase 1 extraction is a study reference, not an asset repository.**

## 8. Acceptance test matrix (to execute later, not executed in Phase 2)

| Test ID | Design acceptance condition |
|---|---|
| **T01** | From a fresh save, M2's unavoidable first Edda/Pip scene fires on the only path to M3; `edda_met` completes before the exit opens, including after interruption/reload. M4 reachable with starting abilities and no optional dialogue |
| **T02** | First required dash gap M4→C1 is not open before `echo_step_owned`; after Warden defeat, dash acquisition is automatic |
| **T03** | C2's unavoidable first Thren scene commits `thren_met` and `engine_objective_known` together before C3; C3 needs no sigil; C4/G1 remain blocked until Cantor victory |
| **T04** | G3 Mirror Latch **must be opened** to approach G4; doing so opens G3↔M3 bidirectionally, but **using** shortcut is optional. C2 hatch opening/use are optional. Both persist when opened, with no early bypass |
| **T05** | All shrines can be reached, record correct room, refill health, and preserve defeated miniboss states |
| **T06** | A local fall never places the player beyond an unopened gate or in an unrecoverable position |
| **T07** | All **12** designed boss attacks (**3 each for 2 minibosses and both final-boss phases**) have visible anticipation, bounded active windows, recoveries and at least one reachable safe response |
| **T08** | **S11 ends fully unidentified**, including final hit, title/HUD, transitions and pre-S12 previews. **S12 alone** unmasks/names Pale King, reveals Veyra's motherhood and enacts her irreversible sacrifice |
| **T09** | Death in **either** Phase 1 or Phase 2 restores **G3 shrine + 5 HP + 0 charges**; next entry starts masked **Listener Phase 1** at full pool. Phase 2 Wyrm pool resets, no Phase 2 checkpoint/resume. Once the original S12 was seen, retries re-clear Phase 1 and show brief form-change only (no second diegetic sacrifice). Test also quitting/reloading in P2 |
| **T10** | S13 victory commits `final_boss_defeated`, `hush_engine_off`, `ending_available` together; S14 plays exactly one canonical restoration ending, then commits `story_complete` |
| **T11** | G2→G3 cannot bypass Asha; G4 cannot open before `asha_met && mirror_latch_open && echo_step_owned`; all 12 rooms remain reachable with no fourth region/extra ability/quest |
| **T12** | Several first-time playtests cluster reasonably around ~60 min; if not, tune length and fairness while retaining all immutable story beats |

**T13 — cast/dialogue:** Verify only Edda, Pip, Thren, Asha and Listener are narrative NPC speakers; Warden/Cantor only have nonverbal audio/animation. Pip has no note-retrieval trigger or inventory dependency.

**T14 — forced first encounters:** Verify aborted/retried conversations, hazard respawns, dash/jump attempts and optional later cross-link entry cannot bypass any of the three mandatory first scenes.

**T15 — approved D1 healing:** Verify 5 HP maximum, 1 damage per enemy/boss hit, exactly 1 charge per 3 landed attacks, cap 3, 1 HP recovered per 1 completed 1.1-second stationary Focus, and interruption preserves charge and restores 0 HP; no Soul UI. Confirm zero charges after death and no farm from empty swings.

**T16 — approved D3 input/platform:** Verify all §10 gameplay/menu actions with keyboard **and** controller in Godot 4 on Linux and Windows builds; focus/modal navigation, pause/resume and remapping work; no binding change can remove the mandatory confirmation/back escape route.

**T17 — finale state lifecycle:** Verify first S12 is full and unskippable, canonical story flags commit once, Phase 2 deaths never allow entry directly into Wyrm, attempt-local phase flags reset on death/exit/reload, neither boss pool carries over across attempts, and completed final victory alone persists ending unlock. Health refills on each P1→P2 break, but no checkpoint is created.

**Phase 2 has audited the logical design only; none of T01–T17 represents an executed software or user-playtest pass.**

## 9. Final owner decisions (D1, D2, D3 — locked for Phase 2)

The following are **approved, not open questions**. Earlier provisional values and the Phase 2 direct-retry concession are superseded.

| Decision | Final binding specification | Status |
|---|---|---|
| **D1 — healing** | 5 HP; every enemy/boss damaging hit 1 HP; every 3 successful attacks grants 1 charge, store at most **3**; stationary heal **1.1 s** for +1 HP/−1 charge *only on completion*; interrupted heal: +0 HP/−0 charge; no Soul meter | **Owner approved** |
| **D2 — final retry** | Death in **either** final phase returns to **G3**, resets all current encounter health/phase state, and restarts the **Listener Phase 1**. No Phase 2 checkpoint. S12's sacrifice happens once canonically; a later Phase 1 win can show a shortened **non-diegetic** transformation cue | **Owner approved** |
| **D3 — technology** | **Godot 4**, Linux primary development, Linux + Windows supported targets, keyboard + controller, remappable gameplay controls where practical; action map below | **Owner approved** |

Already-settled story and scope also remain fixed: personal use, Pale King as Listener and transformed Last Wyrm, Veyra's irreversible sacrifice, three regions/twelve rooms/two silent minibosses/one two-phase final boss/one ending. Future measured tuning remains possible through owner review, but is **not** a pending D1/D2/D3 approval.

## 10. D3 action and input contract (specification only)

Both **keyboard** and **controller** must cover the whole game, including conversations, exploration, bosses, pause menus and credits. Action names below are *semantic design labels* (not mandated Godot InputMap identifiers). Controller face-button examples use the standard Xbox layout labels; the in-game prompts must match the connected device when practical.

| Action / context | Intended keyboard default | Intended controller default | Rule |
|---|---|---|---|
| Move left / right | **A / D** or **← / →** | **Left stick X** or **D-pad ←/→** | Both sources work in exploration and combat |
| Aim up / down (directional slash) | **W / S** or **↑ / ↓** | **Left stick Y** or **D-pad ↑/↓** | With Attack selects upward/downward slash; neutral attack slashes forward |
| Jump / release early for lower arc | **Space** | **A (south face)** | Start-enabled movement; allow repeat wall-jump according to movement spec |
| Attack | **J** | **X (west face)** | One press triggers a single strike; direction uses current aim |
| Heal (Gather/Focus) | **Hold K** | **Hold Y (north face)** | Requires stationary hold **1.1 s** and charge; movement/damage cancels without expenditure |
| Echo Step dash | **Left Shift** | **B (east face)** | Action usable only after M4 unlock; no new dash variants |
| Interact / read / advance dialogue | **E** | **RB (right shoulder)** | At a scripted first-scene threshold, scene auto-starts regardless of input |
| Pause / resume | **Esc** | **Menu/Start** | Must be available during controllable sections; paused state blocks combat inputs |
| Menu navigation | **Arrows** or **WASD** | **D-pad** or **left stick** | Up/down/left/right through options and dialogue choices (where shown) |
| Menu confirm | **Enter / Space** | **A (south face)** | Also selects HUD/dialogue confirmation as appropriate |
| Menu back / cancel | **Esc / Backspace** | **B (east face)** | Context-separated from dash; do not consume gameplay charge or move while menus are open |

**Remapping and accessibility:** provide remapping of gameplay movement/aim, jump, attack, heal, dash, interact and pause **where practical**; allow both controller and keyboard simultaneously. Menu navigation/accept/back must retain always-available fallback bindings even if the player remaps a gameplay action to those keys. Detect/report conflicting binds or provide resolution, with a **restore defaults** option. UI must not trap controller-only or keyboard-only users. Input prompts should show the currently used scheme; player controls must not fire while menus, mandatory conversations, or cinematic input locks have focus. Controller deadzones, button prompts, platform packaging and remapping behavior are **future test targets**, not validated facts.

**Stop line:** Owner approval is required before any future implementation agent acts on this handoff. This document does **not** delegate or initiate Phase 3.
