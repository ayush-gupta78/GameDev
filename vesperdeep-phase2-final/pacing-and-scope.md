# Vesperdeep — One-Hour Pacing, Scope and Feasibility

**Phase 2 final design specification · INTERNAL.** The intended experience is **about 60 minutes for a first-time, normally skilled player**, not a 60-minute speedrun or an asserted result of real testing. Room names and boss IDs are defined in [`world-design.md`](world-design.md) and [`characters-and-bosses.md`](characters-and-bosses.md).

## 1. Baseline first-playthrough budget

| Segment | Clock | Minutes | What consumes time (inclusive) |
|---|---|---:|---|
| S01 M1: introduction | 00:00–03:00 | **3** | Opening visual, jump practice, first clue |
| S02 M2: Edda/Pip | 03:00–08:00 | **5** | Forced first encounter, checkpoint, objective; no fetch quest |
| S03 M3: Ossuary | 08:00–10:00 | **2** | Two Drudges, wall-jump shaft, required approach latch |
| S04 M4: Toll Warden / dash | 10:00–17:00 | **7** | Nonverbal miniboss, plausible retry/runback, dash practice |
| S05 C1: Choirwater arrival | 17:00–21:00 | **4** | Dash gap, arrival and shrine |
| S06 C2: Thren / Archive | 21:00–28:00 | **7** | Forced Thren scene, Archive hazards, optional hatch glimpse |
| S07 C3: Bell Cantor / sigil | 28:00–35:00 | **7** | Nonverbal miniboss, plausible retry, sigil |
| S08 C4→G1: Basilica and gate | 35:00–40:00 | **5** | Chapel, sigil seal, Needle, shrine |
| S09 G2: Asha / Orchard | 40:00–45:00 | **5** | Forced Asha scene, two Moths, no quest |
| S10 G3: Mirror Gallery | 45:00–47:00 | **2** | Required latch opening, optional shortcut use, shrine |
| S11 G4: masked Listener phase one | 47:00–52:00 | **5** | No identity reveal; masked fight and possible retry |
| S12 G4: unmask / maternal sacrifice | 52:00–54:00 | **2** | First identity reveal, Veyra's one canonical sacrifice, HP refill (**no checkpoint**) |
| S13 G4: Last Wyrm phase two | 54:00–58:00 | **4** | Transformed antagonist, **clean Phase 2 in baseline**, final strike; a death repeats Phase 1 and adds variable time |
| S14 ending | 58:00–60:00 | **2** | Memory/choice restoration vignettes |
| **Total** | **00:00–60:00** | **60** | **Includes ordinary traversal, core dialogue, some retry/backtracking overhead** |

**Subtotal:** Shore 17 min; Choirwater 18 min (17–35); Basilica/Conservatory/finale 25 min (35–60). No hidden fourth region or mandatory lore chase.

## 2. What the 60 minutes assume

- Mandatory conversations read once at typical game-text speed; a player can skip repeated dialogue after death.
- The **60-minute planning baseline** allows a short failed Phase 1 attempt and some miniboss failure overhead, but **assumes no Phase 2 death**. Under **D2**, Phase 2 death sends the player back through all of Phase 1 from G3. Such retries add variable time beyond this 60-minute baseline; it is **not** reasonable to promise a 60-minute completion to a player who dies repeatedly in the Wyrm phase. These are scope estimates, not tested averages.
- There are **9 required ordinary-enemy placements** across 12 rooms (4 Drudges, 2 Needles, 3 Moths), not a full gauntlet. The C2 hatch is optional to open; the G3 latch is **required to open**, but traveling via its newly opened shortcut is optional and not budgeted. Mandatory first NPC scenes are included in their respective rows.
- A player unfamiliar with 2D action combat can take longer. **Illustrative design ranges only (not samples or quantiles):** a clean familiar run may approach ~45–55 min; a normal low-retry route is budgeted near ~60 min; one or more Phase 2 deaths can take the run beyond 60 minutes because each requires re-winning Phase 1. Exact overrun and the player distribution are **unknown until actual playtesting**.
- If timed cinematics overrun the assigned budget, shorten ambient holds and nonessential travel first, not the late boss reveal or Veyra's sacrifice.

## 3. Encounter feasibility and expected retries

| Encounter | Arena re-entry cost target | Suggested assistance from first playtest | Scope containment |
|---|---|---|---|
| Toll Warden | 20–35 s from M2 with M3 latch | Strong sweep silhouette; optional softened first attack | 3 attacks, 1 HP pool |
| Bell Cantor | 20–35 s from C1 via C2 | Never cover all lanes simultaneously | 3 attacks, 1 HP pool |
| Listener phase 1 | 10–20 s from G3 | Distinct arc/step/thread cues | 3 attacks, 1 HP pool |
| Last Wyrm phase 2 | **10–20 s G3→G4 entry + full Phase 1 replay + shortened form-change** after a Phase 2 death | **D2:** no direct retry; phase break refills HP but never saves progress; readable >~0.9 s tells and 3-charge D1 cap mitigate challenge | 3 attacks, 1 HP pool |

An ordinary player should be able to learn *which movement avoids which move* from one observation. If an encounter consumes more than twice its row's baseline for most testers, adjust telegraph clarity, health, recovery or checkpoint position before adding power-ups.

## 4. Content budget and exclusions

| Category | Firm content cap | Production implication |
|---|---:|---|
| Explorable regions | **3** | Three palette/environment families; named sublandmarks are not separate regions |
| Authored rooms | **12** (4 per region) | Reuse tile motifs, transition effects and cameras |
| Major narrative NPCs | **5** including Listener; plus silent player | Edda, Pip, Thren, Asha/Veyra, Listener/Pale King/Last Wyrm; minibosses are nonverbal combatants outside this count |
| Minor environmental person | **Rell as signature only** | No model, schedule or dialogue branch |
| Ordinary enemies | **3 archetypes**, **9 required placements** (4+2+3) | A walker, a stationary ranged hazard, a telegraphed diver |
| Minibosses | **2**, one health pool each | Toll Warden, Bell Cantor |
| Final bosses | **1**, **2 phases** | Listener→Last Wyrm in one room, not two independent fights |
| Acquired movement abilities | **1** | Echo Step dash; wall jump is starting capability |
| Story items | **1** | Resonance Sigil (passive gate credential) |
| Shrines | **4**, **no Phase 2 restart point** | M2, C1, G1, G3; **G3 restarts both phases**; no bench economy |
| Cross-region shortcut links | **2** | C2↔M2 hatch: optional to open/use. G3↔M3 link: **required latch to open**, optional to use. No optional side level |
| Endings | **1** | Fixed restoration epilogue |

**Deliberately cut:** multi-hour questlines, seven separately explorable locales from the earlier outline, 501 rooms, hidden alternate finales, complex spell system, deep upgrade economy, player transformations, additional minibosses, combat minions in final fight, and full serpent-body physics. The original extended locale names survive as sublandmarks where appropriate.

## 5. Production-risk register (design-stage estimates)

| Risk | Impact | Mitigation in Phase 2 design | Status |
|---|---|---|---|
| Movement/camera values absent from supplied prefabs | High | Define relative route envelopes, distinguish provisional tuning from confirmed controller behavior | **Unverified** |
| Complex boss state graph and cinematic identity reveal | High | Three moves per combat phase; single arena; separate cinematic invulnerability and restart contract | **Specified, not prototyped** |
| 2D Wyrm animation demands | High | 1 coherent silhouette + simple layered arcs instead of deformable/physics serpent | **Specified, art feasibility unproven** |
| Too many distinct art biomes | Medium | 3 palettes, 12 modular rooms, reuse motifs and enemy feedback | **Contained on paper** |
| Healing loop unclear in source | Medium | **D1 owner-approved** 5 HP / 1 damage / 3 attacks per charge / **3 charge cap** / stationary **1.1 s** heal / preserved charge on interruption; no Soul economy | **Decision final; runtime calibration pending** |
| First-playthrough retry variance | High | Nearby G3 shrine, **full P1 replay after any P2 death**, D1 healing cap 3, visible tells and full HP at S12 transition; document variable overrun rather than force 60 min | **Playtesting required** |
| Spoiler leak via assets/UI/tutorial | High | No unmasked figure/name before S12; separate reveal asset visibility contract | **Reviewable in design; must test runtime later** |
| Original-game IP relationship | Relevant only if distribution plans change | Personal-use narrative canon retained; original/licensed art/music/code; future distribution would require separate rights review | **Not a current Phase 2 approval question** |

## 6. How to keep the target if the build runs long

**Trim order (without changing canon):**

1. Shorten repeatable C2/ G2 ordinary combat and empty transit spaces.
2. Reduce enemy HP or avoid stacking contacts in travel rooms; retain the **same three archetypes**.
3. Auto-open the optional C2 hatch more visibly without requiring a detour; do not make it mandatory.
4. Shorten cinematic camera holds outside S12 and the final epilogue.
5. Decrease boss HP slightly before deleting a signature move; preserve two minibosses and both final phases.

**Do not trim:** identity reveal from inside final battle; Asha→Veyra and maternal connection; her death; antagonist's Last Wyrm transformation; **D2 full Phase 1 restart on death in either final phase**; agency/memory-restoration ending.

If the build is too short, invest in readable exploration and optional lore **within existing rooms**, not a fourth region, extra quest chain, miniboss or movement ability.

## 7. Phase 2 acceptance metrics for later playtest

**Design-only provisional thresholds:** median-like target run near **60 min**, at least 90% of first-time testers logically find all required gates without external hints, median boss runback under 35 s, no lethal unavoidable attack pairing, and every tester can state after the reveal who the Listener was and why Veyra died. Statistical thresholds must be measured later; **Phase 2 cannot validate runtime duration or accessibility empirically**.

**Owner decisions D1–D3 are final:** three-charge stationary Gather/Focus healing, full Phase 1 final retries from G3, and Godot 4/Linux+Windows/keyboard+controller direction. **Status:** logically time-budgeted; not experimentally timed. Formal approval and Phase 3 are separate decisions.
