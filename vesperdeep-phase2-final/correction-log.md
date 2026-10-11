# Vesperdeep — Phase 2 Correction Pass Log

**Status:** Prior correction pass preserved; D1–D3 owner finalization appended · 11 October 2026 · **No implementation, gameplay runtime, or playtesting**. This log accompanies the eight revised Markdown deliverables but is not a ninth game-design specification. The original `docs.zip` and `analysis.zip` and their reference findings were not edited.

## Exact revised sections

| File | Sections revised | Targeted changes |
|---|---|---|
| `story-bible.md` | §5 Characters and relationships; §6 Story beats; §7 Information layering; §10 Established decisions | Five **major narrative NPCs** distinguished from two nonverbal miniboss combatants; required first meetings and G3 latch; S11/S12 reveal timing; personal use and antagonist-as-Wyrm recorded as **settled**, not approval questions. |
| `complete-script.md` | Script conventions; **S02**, **S03** heading, **S04**, **S06**, **S07**, **S09**, **S10**, **S11**; Narrative QA | S11 identity concealment until S12; mandatory, non-bypassable first encounters for Edda/Thren/Asha; no Pip fetch request; Warden/Cantor communicate nonverbally; G3 latch required but shortcut use optional; S03 timestamp specified; removed redundant saved `g4_entry_ready` flag. S12 scene itself and its canon remain unchanged. |
| `world-design.md` | §2 Topology overview; §3 Mourning Shore (M2); §4 Choirwater (C2); §5 Glass Conservatory (G2/G3); §6 Backtracking; §9 Routing invariants | Forced first-encounter passage geometry, persistent story flags and no early bypass; explicit G3 latch/barrier dependency; optional traversal through cross-link; 12-room graph unchanged. |
| `characters-and-bosses.md` | §1 Cast; §4 Toll Warden; §5 Bell Cantor; §6 Listener phase one | Five-NPC counting rule; Warden/Cantor nonverbal start/defeat beats, preserving their fights; masked identity at S11 zero health. Attack patterns/HP not redesigned. |
| `gameplay-progression.md` | §2 Mandatory route and triggers; §3 Progression condition table; §7 Feasibility proof | Mandatory first scenes recorded atomically and retried after interruption; `mirror_latch_open` mandatory to approach G4; no redundant G4-ready state; separate S13 victory flags from S14 `story_complete`. |
| `pacing-and-scope.md` | §1 First-playthrough budget; §2 Assumptions; §4 Content budget; §5 Risk register | Replaced combined rows with individual S01–S14 rows; S05 17:00–21:00 (**4 min**) and S06 21:00–28:00 (**7 min**); total still **60 min**; unified 9 required ordinary enemies; optional shortcut-use distinction and personal-use premise. |
| `reference-traceability.md` | New §6 Correction-pass design trace; renumbered §7 Provenance summary | Appended provenance boundaries for changed design choices, archive checksum/duplication recheck. Original reference interpretations R01–R16 and raw archives unchanged. |
| `implementation-handoff.md` | §2 Manifest; §3 Persistent state; §4 Navigation; §6 Dialogue/secrecy; §8 Acceptance tests; §9 Owner decisions | Aligns mandatory triggers, Gate dependencies, no Pip quest, nonverbal minibosses, nine enemies, explicit S12 reveal boundary, S13/S14 completion flags. Revised T01/T03/T04/T08/T10/T11; added T13/T14; removed settled-canon approval questions. |

## State and trigger invariants (documentation contract)

1. **M2:** Edda/Pip's single mandatory first exchange starts automatically at the sole route to M3 (or on earlier voluntary interaction). `edda_met` persists only when that exchange completes; no bypass and no Pip fetch flag.
2. **C2:** Thren's mandatory first exchange starts automatically at the sole route to C3 (or on earlier voluntary interaction). `thren_met` and `engine_objective_known` commit together. The C2↔M2 hatch is optional.
3. **G2:** Asha's mandatory first exchange starts automatically at the sole route to G3 (or on earlier voluntary interaction). G3 exit requires `asha_met`.
4. **G3:** pulling the Mirror Latch sets `mirror_latch_open` and opens both the G4 approach barrier and G3↔M3 shortcut. Opening is mandatory; using the shortcut is optional. G4 requires `asha_met`, `mirror_latch_open` and `echo_step_owned`. No saved `g4_entry_ready` state.
5. **G4 (updated by final D2):** S11 ends unidentified; first S12 reveals identity and permanently records `identity_revealed` and `veyra_sacrificed`, while `final_p1_started`, `final_p1_cleared`, `final_p2_unlocked` and phase health are attempt-local. S13 victory sets `final_boss_defeated`, `hush_engine_off`, `ending_available`; S14 ending sets `story_complete`. **Either-phase death respawns at G3 and restarts Listener Phase 1.**
6. **Recovery (updated by final D2):** incomplete mandatory first conversations re-trigger; completed first encounters, boss rewards, latch states and the one-time revelation/sacrifice persist. **No Phase 2 checkpoint persists.** Death or reload of unfinished finale resets the whole encounter to G3→Listener Phase 1; no repeated maternal sacrifice.

## Revised verification checklist

### A. Documentation checks completed

- [x] Eight required revised Markdown files are present and cross-linked; additional log is separate.
- [x] S01–S14 scene windows match one-for-one with pacing rows; uninterrupted **00:00–60:00** budget, sum **60 minutes**.
- [x] Spoiler disclosure begins **only in S12** after S11 ends; masked S11 has no unmasked title/portrait/lineage.
- [x] Edda/Thren/Asha first encounters are mandatory in the route spec, with fail-closed exit and interrupted-scene recovery.
- [x] **Five major narrative NPCs**; Warden and Cantor remain as **two nonverbal minibosses**; no sixth speaking NPC role.
- [x] Mirror Latch **opening** mandatory, shortcut **use** optional; no route requires optional hatch or lore note.
- [x] No Pip retrieval mission, new inventory key, quest flag, optional boss, room, region or ability.
- [x] Nine ordinary-enemy instances (**4 Drudges + 2 Needles + 3 Moths**) consistent across documents.
- [x] G4 entry and S12/S13/S14 state dependencies reconciled in route and future acceptance tests.
- [x] Established personal-use premise and antagonist transformation are not presented as unsettled approvals.

### B. Reference findings independently confirmed (from supplied archives)

- [x] **15/15** bundled evidence artifacts match the supplied SHA-256 checksums in `docs.zip`.
- [x] Decoded boss FSM JSON supplied in `analysis.zip` is byte-identical to the copy in `docs.zip`.
- [x] Traceability preserves original Phase 1 findings R01–R16, with changed narrative/gate/timing choices clearly labeled **original design**.
- [ ] Independent reproduction of source extraction from raw original game archives **not performed**; they were not in this correction-pass input.
- [ ] Runtime Hollow Knight movement, enemy probabilities, camera tuning, or 2D behavior **not independently confirmed**.

### C. Design estimates requiring later playtesting

- [ ] Whether typical first playthroughs actually finish near **60 minutes** (current breakdown is an estimate).
- [ ] Actual movement/jump/dash envelopes, collision bounds and shortcut navigation with a game build.
- [ ] Boss readability, damage fairness, retry costs, healing rates, checkpoint experience and phase-two accessibility.
- [ ] NPC autotrigger and save/reload resilience validated against actual runtime behavior, not only documentation.

### D. Owner decisions finalized; separate implementation authorization pending

- [x] **D1 FINAL:** 5 HP; 1 damage/hit; 3 successful attacks/charge; **3 stored charges**; stationary **1.1 s** Focus restores 1 HP at completed cast; interruption preserves charge and grants no HP.
- [x] **D2 FINAL:** all fatal final-boss attempts restart **G3→Listener Phase 1**; no Phase 2 retry checkpoint; first S12 canon persists without repeating Veyra's death.
- [x] **D3 FINAL:** **Godot 4**, Linux development, Linux and Windows exports, keyboard/controller support and remappable gameplay actions where practical.
- [x] **No owner design choice remains open among D1–D3.** Phase 3 implementation still requires **separate explicit authorization**, not a gameplay design decision.

**Verification type:** This pass checked document logic, link targets, internal timeline, evidence-file integrity and source provenance. **No engine tests, playtests, measured playtime or Phase 3 work occurred.**

## Final owner decision update — D1, D2, D3 (11 October 2026)

This addendum **supersedes obsolete D1–D3 candidate values** in the earlier correction history. It does not replace/alter Phase 1 reference documents and does not claim gameplay tests. The earlier correction table remains intact as an audit history; new authoritative values are below.

| Decision | Final exact approved rule | Affected files / exact sections |
|---|---|---|
| **D1 — healing** | 5 HP; 1 HP damage per hit; 1 discrete charge per 3 successful attacks; **3 charge cap**; stationary **1.1 s** heal, **1 HP** recovered per completed charge; interrupted heal heals nothing and consumes nothing; no Soul meter | `gameplay-progression.md` §§1, 8; `implementation-handoff.md` §§2, 5, 8–10; `characters-and-bosses.md` §§7, 9; `story-bible.md` §10; `pacing-and-scope.md` §§3, 5, 7; `complete-script.md` S11–S13, narrative QA; `reference-traceability.md` R06/§§5–6 |
| **D2 — final retry** | On death in P1 **or** P2, respawn **G3**, start next attempt **Listener P1** with 5 HP and 0 healing charges; reset attempt-local phase state and both boss pools; **no P2 checkpoint**. First S12 revelation/sacrifice commits permanent story flags; later P1 replay win uses short non-diegetic form-change cue, not a second sacrifice. Each P1→P2 transition refills HP without creating a save point | `complete-script.md` S11–S13; `story-bible.md` §10; `world-design.md` §§5–6; `characters-and-bosses.md` §§7–9; `gameplay-progression.md` §§1–4; `pacing-and-scope.md` §§1–3, 4–7; `implementation-handoff.md` §§2–9; `reference-traceability.md` §6 |
| **D3 — technology and input** | **Godot 4** engine; primary development **Linux**; target **Linux + Windows**; **keyboard + controller** for gameplay and menus; gameplay remapping and fallbacks where practical; action table for movement/aim, jump, attack, heal, dash, interact, pause, menu navigation/confirm/back | `implementation-handoff.md` §§2, 9–10; `gameplay-progression.md` §8; `world-design.md` §9; `story-bible.md` §10; `pacing-and-scope.md` §7; `reference-traceability.md` §6 |

### Final verification checklist (documentation, not runtime)

- [x] All **eight original Markdown files plus this correction log** preserved in the final package.
- [x] **D1**: cap **3** is uniform, 1.1 s/1 HP, 3 hits per charge, interrupted cast preserves charge; no Soul meter or new healing systems.
- [x] **D2**: deaths in P1 and P2 always require replaying **Listener P1** from **G3**; no direct P2 checkpoint, persisted phase resume or duplicated maternal sacrifice.
- [x] **D3**: Godot 4, Linux+Windows, keyboard/controller, input action defaults and remapping contract documented; no Godot project was produced.
- [x] S11 remains masked; **S12 alone** reveals the Pale King for the first time.
- [x] Mandatory Edda/Thren/Asha first encounters, 5 NPCs, 2 silent minibosses, 3 regions, 12 rooms, G3 latch and Pip-no-quest survive unchanged.
- [x] S01–S14 windows stay contiguous at **60 minutes estimated**; Phase 2 death adds potentially significant unmeasured retry time beyond baseline.
- [x] Cross-document references and Markdown paths checked; no code, executable, engine project or Phase 3 action.
- [ ] Runtime combat, actual input/remapping, boss resets and timing **not tested**.
- [ ] Measured first-playthrough duration and accessibility **not established**; 60 minutes is a plan, not an observed result.
- [ ] Independently re-extracting the original Hollow Knight binaries **not performed**; Phase 1 evidence interpretations unchanged.
- [x] **No D1/D2/D3 owner approvals outstanding. Phase 3 is NOT authorized.**
