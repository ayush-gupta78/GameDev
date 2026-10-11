# Vesperdeep — Characters, Enemies and Bosses

**Phase 2 final design specification · INTERNAL / FULL SPOILERS.** Design only: proposed move durations, health and stage logic are **original targets for playtesting**, not Hollow Knight measurements. Phase 1 reference evidence is linked at the end and traced in [`reference-traceability.md`](reference-traceability.md). The two supplied Hollow Knight encounter analyses inform anticipation, attack/collider separation, stuns, camera locks and phase handoffs; **no art, code, scripted dialogue or attack sequence is copied**.

## 1. Cast direction (five key non-player figures)

| Character | Model/camera needs | Acting/dialogue direction | Gameplay role |
|---|---|---|---|
| **Edda** | One small seated collector silhouette; writing-hand loop | Practical and ashamed; short halting lines when confessing complicity | M2 quest anchor, optional reaction after Shore relay |
| **Pip** | Tiny bell tender; bell-hand loop | Curious and gentle, not comic exposition | Humanizes memory loss; ending recognition payoff |
| **Thren** | Blind archivist, hands on vibrating ledger | Precise, dry, observant; refuses to be pitied | Mandatory explanation of Bell Engine and sigil |
| **Asha / Veyra** | Gardener silhouette in G2; single transformation/revelation presentation in G4 | Caring but unsentimental; knows the cost of love without choice | Mandatory late witness; reveals identity only at phase break; sacrifice |
| **Listener / Pale King / Last Wyrm** | Filtered voice initially; masked compact humanoid phase one; larger single connected Wyrm silhouette phase two | Comforting language that becomes a command, then bitterness | Central antagonist; identity hidden until G4 phase break |

**Cast boundary:** these **five major NPCs** are narrative characters. The **Toll Warden** and **Bell Cantor** remain both required miniboss encounters, but have **no spoken or subtitled words**: audible ritual beats, interrupted gestures and defeat animation carry their stories. They are combatant roles, not a sixth/seventh major NPC. The player is the silent discarded Vessel; **Rell** survives only as an optional signed note, without a model, dialogue encounter or quest.

**Personality rule:** nobody explains the entire ancient history in one conversation. Edda explains a local harm; Thren the machine; Asha its moral cost. Only the final scene reveals the culprit's name and relationship.

## 2. Ordinary enemy roster — exactly three archetypes

Each enemy shares the same conceptual health/damage interface as bosses: one incoming-hit response, single brief damage immunity, recoil/flash feedback, death disables contact harm. Attack windup/active/recovery are explicit and mutually exclusive. Those are source-backed **structural principles**, while the roster and numbers below are original.

| Enemy | Where/how many on required route | HP proposal | Threat and telegraph | Counterplay / purpose |
|---|---|---:|---|---|
| **Paper Drudge** | M3×2, C1×1, C2×1 | 2 standard strikes | Slow floor patrol; stops, folds its front edge upward **0.55 s** before one short melee poke | Jump, slash from above, or attack after miss; teaches basic punish |
| **Choir Needle** | C2×1, C4×1 | 2 | Fixed turret; draws a thin floor-level red thread at target **0.8 s** before one horizontally traveling note | Jump/dash out of lane; projectile never fires outside camera. Teaches facing/ranged lane management |
| **Glass Moth** | G1×1, G2×2 | 2 | Drifts over fixed horizontal zone, pauses/glitters **0.7 s** then dives in an obvious diagonal; no homing after commitment | Side-step or up-slash, landing punish; teaches vertical tracking before boss |

**Damage:** 1 health mark from any of the three, no simultaneous body/projectile double charge. **Placement cap:** no more than two active ordinary enemies visible in a mandatory combat pocket. Optional scenery creatures are nonhostile and noninteractive.

## 3. Encounter rules shared by minibosses and final boss

- **Telegraph:** strong pose + effect line + distinctive sound, with every hazardous attack having at least one visual cue. Windup must complete before harmful collider/hit effect activates.
- **Fairness:** no two concurrent attacks form an unavoidable full-width lane; if the boss corners the player, it offers a jump-over or cross-through path. No instant-kill pits.
- **Recovery:** a consistently visible vulnerability interval follows each major move. No forced damage when trying a sensible basic defense.
- **Reactions:** consistent slash hit flash, small recoil or stagger reaction, independent boss health UI. Enemy attack colliders end at the active state's completion, not at arbitrary animation presentation time.
- **Deaths:** minboss death state immediately disables offensive collisions, triggers one story beat, and grants the item/flag in the **same atomic outcome**. Bosses never become farmable on reentry.
- **D2 restarts:** miniboss attempts reset from their nearby shrine routes; **a death in either final-boss phase returns to G3 and the next encounter always begins at Listener / Phase 1** with both boss pools reset. **No post-sacrifice or Phase 2 checkpoint exists.** The first S12 reveal/sacrifice is singular canon; after a later Phase 1 win, only a brief non-diegetic form-change is shown.
- **Reference boundary:** phase-source 'Pure Vessel' uses 2 damage in its serialized scene, but **all Vesperdeep bosses deal 1 health mark** for the one-hour accessibility target. Exact timings here are not borrowed values.

## 4. Miniboss I — Toll Warden (M4 Tollhouse)

**Identity:** an old ferry-bound collector trapped in a duty after forgetting its purpose. A heavy bell rod is its only weapon; it has no visible face beneath its folding collar. In life, it helped charge an emotional toll for passage.

**Arena:** flat deck with two end walls, no pit or moving platform, roughly three to four dash lengths wide (size to be calibrated with gameplay physics). M4 door closes on entry. The Warden strikes three harmless bell taps as a readable introduction; health bar **TOLL WARDEN** appears only as the fight begins.

**Proposed health:** 10 standard strikes. **Damage:** 1. **Pattern:** alternate among three moves, no random back-to-back repetition of the same move. At half HP, shorten *recovery* slightly but do not introduce a new phase.

| Move | Telegraph (proposal) | Active threat | Reliable avoidance | Punish window (proposal) |
|---|---|---|---|---|
| **Toll Sweep** | Raises horizontal rod with audible scrape **0.7 s** | Low floor-wide sweep directly in front, **0.3 s**, damage 1 | Jump over; downward slash on rod surface if hit target is appropriate | **0.9 s** recovery behind its back |
| **Anchor Drop** | Bell shadow/impact ring marks one position **0.85 s** | Rod impact and one short ground pulse, **0.35 s** | Move/dash out of marker, jump pulse | **1.1 s** recovery with rod planted |
| **Ferry Shove** | Hunches and drags rod backward **0.6 s** | Committed straight lunge **0.45 s**, stops at wall | Jump or cross above; cannot instantly reverse facing | **0.8 s** endlag at wall |

**Stagger:** once per attempt after approximately five successful hits without a long pause, a brief **1.0 s** droop signals vulnerability. Not required for victory; full stun-system recreation out of scope. **On death (nonverbal):** rod stops at silent bell → the Warden hesitates and relaxes its hand in a newly unscripted gesture (S04) → shoreline relay stops → **Echo Step** acquired → M4 exit open. The Warden has **no dialogue** before or after defeat.

**Fail-safe:** M3 approach latch is mandatory to pass en route, so the prior M2 shrine has a short, cleared approach. Defeated flag and Echo Step are saved together. Warden never locks an unequipped player into the far side of the C1 dash gap.

## 5. Miniboss II — Bell Cantor (C3 Bell Engine)

**Identity:** a former musician made into a regulatory tuning instrument. It believes discord injures people; its body is a bell-shaped shell with visible tuning apertures. Its death demonstrates the return of imperfect harmony.

**Arena:** circular visual setting but a straightforward ground/platform fight. Small central shelf, floor on left/right, three telegraphable note lanes. No true simulated water, flowing physics, projectile pooling system requirement or procedural hazard geometry. Door C3→C4 opens only on victory.

**Proposed health:** 12 standard strikes. **Damage:** 1. **Pattern:** one attack at a time, 0.4–0.7 s idle breathing between moves, no new formal phase. If player stays at arena extreme, prefer a lane-mark attack rather than punishing automatic corner dwell.

| Move | Telegraph (proposal) | Active threat | Reliable avoidance | Punish window (proposal) |
|---|---|---|---|---|
| **Bell Pulse** | Draws breath; concentric ring on floor **0.8 s** | One expanding low shockwave, about **0.4 s** to cross arena | Jump over; dash can reposition but isn't mandatory | **1.0 s** after pulse |
| **Needle Chorus** | Three thin horizontal lanes appear with one conspicuous opening **0.8 s** | Three short successive projectiles, **0.2 s** stagger each; no unavoidable wall | Occupy the opening; jump/dash between lanes | **0.85 s** after last note |
| **Falling Measure** | Two of three floor sections light up **0.7 s** | Two descending rod markers, simultaneous single strike | Stand in unmarked section; safe refuge remains visible | **1.1 s** while Cantor retrieves rod |

**Stagger:** single optional brief wobble after 6–7 hits. **On death (nonverbal):** instruments lose synchronization → the Cantor strikes two mismatched, newly expressive notes (S07) → Bell Engine relay off → **Resonance Sigil** gained → C4 route rises. The Cantor has **no dialogue**. Item and door change commit together. No reward farming, additional quest or second life bar.

**Difficulty step:** the Warden asks 'when do I jump?' while the Cantor asks 'where is the safe lane?' Each still leaves a clear opportunity to heal after at least one move.

## 6. Final boss — phase one: The Listener (G4 Cradle)

**Identity and spoiler control:** at introduction the player sees an unrecognizable **masked** figure, known only by the title **THE LISTENER**. Its crown/profile/true name are not displayed in any pre-battle image, sound, help tip or dialogue. The internal story bible identifies it as the Pale King but the game cannot until the S12 interlude.

**Arena:** single rectangular floor with two walls; dim engine core above, no platform hazards added mid-fight. Locking door and boss HUD use neutral titles. Camera framing must show the forward assault's full tell. Intro dialogue takes 20–30 s depending on reading speed; boss itself should take 2–4 minutes including a normal retry budget.

**Proposed health:** 18 standard strikes; one pool only. **Damage:** 1. **Selection:** 3 core moves, no repeated same move three times, minimum 0.45 s reaction reset. At around half HP crack the mask's surface **without showing recognizable facial features**; slightly increase willingness to use the step move without adding a phase.

| Move | Telegraph | Attack and active threat | Counterplay | Punish |
|---|---|---|---|---|
| **Mute Arc** | Raises hand; white arc blooms in front **0.75 s** | Forward sweeping close-range arc **0.35 s** | Jump over or step behind its facing | **0.9 s** after cast |
| **Severing Step** | One foot drawn back; ground line from current to committed end **0.65 s** | Fast straight lunge **0.35 s**, no midflight retarget | Jump/wall-assisted evade; dash through space if no invulnerability assumed | **0.8 s** at stop |
| **Threadfall** | Two marked floor bands and one obvious safe zone **0.9 s** | Two falling thread bundles **0.4 s** | Stand in clear strip, then approach | **1.1 s** after impact |

**Stagger:** one major stagger at ~9 hits allows safe heal and sets the visible mask fracture, but does not reveal the face. Do not imitate the reference boss's four HP phases or 164-state FSM; there is exactly one Phase 1 HP pool.

**At zero health:** boss does not die, does not trigger ending, and cannot attack; ends **S11 still masked and unidentified** and locks the cutscene. **Only S12** reveals the **Pale King** for the first time. This is the start of the dramatic phase transition, **not a second final boss**.

## 7. Interlude — sacrifice and irreversible transformation (S12)

**Scene beat sequence:** veil splits → explicit Pale King name appears → Asha steps into frame → he recognizes her as mother → she names herself Veyra, First Wyrm → his Hush Engine attempts final extraction → she expends herself to sever the command lattice → released primordial essence awakens and enlarges the son → he rejects her invitation to stop → opponent becomes **THE LAST WYRM**.

**Causal nuance:** Veyra intends to end his ability to command everyone else's will; infusion is the dangerous consequence of unbinding a Wyrm-born antagonist, **not her endorsement of his actions**. She dies permanently. The player's role is to defeat what he chooses to become, not to inherit Wyrm powers. The Engine remains dangerous until his final defeat.

**D2 phase-break safety (approved):** interlude disables player and enemy harm; all attack hitboxes deactivate. After **every successful Phase 1 clear**, refill the player to **5/5 HP**, retain up to **3 earned healing charges** and grant a safe 1.0–1.5 s action delay. This refill is **not** a checkpoint: **a death in either phase restarts from G3 and requires Phase 1 again**. Only the *first* S12 completion permanently records Pale King revelation and Veyra's sacrifice. If Phase 2 later kills the player, a subsequent P1 win uses a short non-diegetic form-change instead of repeating her death; the full Wyrm fight starts only after that P1 win, never directly.

## 8. Final boss — phase two: The Last Wyrm (G4 Cradle)

**Visual plan:** high-impact **single boss silhouette**, coiling spine implied by two or three layered opaque shapes with simple bone-white/tide-black alternation, not a high-cost physics serpent. The Wyrm is **the transformed Pale King**, not Veyra or the Vessel. The arena and engine backdrop persist; camera uses a wider vertical rectangle, ensuring full attack warning visibility.

**Proposed health:** 20 standard strikes, **reset to full for every newly completed Phase 1 attempt**, with **no separate Phase 2 retry**. **Damage:** 1. Three attacks with larger but deliberately slower tells. No summoned enemies, environmental platform breaks, extra life bars, third phase or surprise button.

| Move | Telegraph (proposal) | Hazard | Counterplay | Punish (proposal) |
|---|---|---|---|---|
| **Spine Sweep** | Coil tightens; ground arc glows **0.95 s** | One body-tail sweep traveling from one side to center, **0.5 s** | Jump / wall-jump over crest, never requires dash-invulnerability | Exposed neck **1.0 s** |
| **Crown Dive** | Crown silhouette lifts and marks ground with broad bright oval **1.0 s** | Single committed dive plus short outward dust pulses, **0.5 s** | Move to unmarked side; jump subsequent ground pulse | Grounded head **1.2 s** |
| **Memory Rain** | Engine throws three distinct reflection strips on ground **1.1 s** | Two strips flash harmful for **0.45 s**, third stays safe | Read safe lane, reposition; does not chase player after marking | Exposed heart **1.1 s** |

**Optional mid-fight beat:** at ~half health the creature goes still for **1.25 s** while the missing fourth bell note sounds. This is a recovery window, **not a third phase**, new attack or difficulty reset.

**Defeat:** Wyrm recoils and drops its guard → clearly lit one final ordinary slash is required → body collapses without a corpse-interaction mechanic → Hush Engine stops → S14 epilogue. If the player does not strike during the finisher pause, boss remains harmless and prompt recurs; no softlock or QTE. Its last words are in S13. Boss flags and world restoration commit together.

## 9. Challenge targets and accessibility parameters

| Encounter | New skill tested | First clean-win combat time target | Retry allowance included in pacing model | Common fairness risks to inspect later |
|---|---|---|---|---|
| Toll Warden | Jump-over + punish | 1.4–2.0 min | ~1 plausible failed attempt | Rod sweep cannot corner-trap |
| Bell Cantor | Recognize safe lanes + dash | 1.6–2.5 min | ~1 plausible failed attempt | Mixed shots cannot fill all exits |
| Listener P1 | Combine three previously taught patterns | 1.9–3.0 min | Short failed P1 attempt may fit pooled finale budget | No unseen collision after crack animation |
| Last Wyrm P2 | Read large silhouettes, manage heal/pogo | 2.2–3.5 min | **0 Phase 2 deaths assumed in 60-min baseline; each death repeats Phase 1 and adds unmeasured time** | Body contact doesn't repeatedly tick; all tells fully visible |

Win times are design targets, **not measured playtest outcomes**. **D1 final combat resource:** 5 HP, 1 incoming damage per hit, 1 discrete charge per 3 successful attacks, cap **3**, stationary 1.1-second Focus restores 1 HP on completion; interruption preserves charge. **D2 final retry:** no Phase 2 retry checkpoint; both phases restart at the Listener from G3 on death. This is expected to increase run-time variance, requiring later tests rather than a fabricated 60-minute guarantee. Difficulty should come from anticipation and commitment, not punitive damage, runback length, obscure hitboxes or requiring proprietary Hollow Knight tuning. Reject the design if a normal novice run exceeds the one-hour envelope primarily because of unfair retries.

## 10. Source relationship and constraints

The supplied boss report confirms, in **actual serialized scene evidence**, the concepts of a separate main attack FSM and phase controller, anticipations followed by active hit objects and recoveries, stun windows, room-specific camera locks, death/corpse paths, and complicated transitions. It also confirms two specific reference encounters only: `Room_Final_Boss_Core` (boss Control 2329 / Phase Control 2320) and `GG_Hollow_Knight` (Control 1959 / Stun Control 1954). See `docs.zip/docs/reference-analysis/05-boss-mechanics.md` and the duplicate decoded FSM JSON in `analysis.zip/analysis/hollow-knight-boss-scenes-fsm-decoded.json`. There is **no supplied miniboss scene** for the Warden or Cantor; their gameplay is original design, not a claimed reproduction.
