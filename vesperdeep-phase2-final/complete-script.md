# Vesperdeep — Complete Playable Script

**Phase 2 final design specification · INTERNAL / FULL SPOILERS.** Scene IDs and triggers refer to [`world-design.md`](world-design.md). **All dialogue below is original writing** for this concept, not Hollow Knight dialogue. Player = silent Vessel; interactions may be skipped only when marked **optional**. All cinematics except the first reveal are skippable after first viewing; skipping never changes flags. Exact animation and VO lengths are Phase 2 proposals.

## Script conventions

- `VO` = offscreen voice, `ENV` = readable inscription, `STAGE` = camera/action direction. `...` is a deliberately unfinished sentence, not missing script.
- Text is displayed as short sequential panels, with no voice acting required. The 60-minute budget assumes the player reads mandatory dialogue once.
- The Listener's early voice is filtered and gender-indeterminate, with no use of his actual name, recognizable throne design or royal insignia. The true identity, unmasked face, recognizable crown and identity-specific title must remain entirely undisclosed throughout **S11**; first player-visible reveal occurs only after `final_p1_cleared` at the start of **S12**. No pre-S12 HUD, subtitles, previews, pause/loading text or other player-facing surfaces may expose them.
- Every scene lists state and outcome. All player interactivity is specified conceptually; **no runtime code is requested**.

## S01 — Wreckfall: the shell that listens (M1; mandatory, 0:00–0:03)

**STAGE:** Black screen, an uncompleted four-note lullaby. Dark water laps against an abandoned stone. The Vessel lies amid shells without inscriptions. A red thread is tied inside its cracked collar. No exposition card.

**SOUND:** Three notes of a four-note bell phrase. The fourth is cut into absolute quiet.

**VO — Listener (distant, indistinct):** "There is nothing here that you must carry. Be still."

**STAGE:** Player gains movement control; moving toward the glow is the only exit. Three harmless planks teach jump; a hanging husk can be struck horizontally. On approaching the arch, the little thread moves as if catching a note.

**ENV — arch, mandatory one-line interaction:** "A NAME LEFT UNCLAIMED."

**STAGE:** The Vessel's first voluntary movement is framed as choosing to cross the arch. No flashback revealing family lineage.

**Flags:** enter M1; none required for basic exit.

## S02 — House of Kept Names (M2; mandatory, 0:03–0:08)

**STAGE:** Handwritten names are folded into jars. The names on many labels end mid-letter. A shrine allows rest. Edda writes against a tide-mark; Pip tests bells that should have different notes but do not.

**EDDA:** "If you came for a name, it isn't here. Not whole."

**EDDA:** "They collect a name, then what it means. Soon a mother can see her child and feel no need to reach for him."

**PIP:** "I remember this one's sound." *(He strikes a silent bell.)* "I don't remember who taught me."

**EDDA:** "The Tollhouse sends every stolen memory inland. Stop its Warden. Then the way to Choirwater can be crossed."

**PIP:** "Three notes, then nothing. I keep waiting for a fourth."

**STAGE / FIRST-ENCOUNTER TRIGGER:** Edda and Pip occupy the single safe passage between M2 entry and the M3 exit. Approaching their shared scene area automatically starts the short S02 exchange once; interacting sooner also starts it. The M2→M3 exit refuses passage until the whole first exchange finishes and `edda_met` is recorded, including after a room exit, death or return. The player cannot jump/dash around this story threshold. Edda gives no item, and Pip assigns **no** note-retrieval task or quest UI. Bench shrine checkpoint M2 activates on first approach to prevent a missed save.

**Optional return dialogue, before M4:**

**EDDA:** "I used to label those jars. I wrote the endings of people's names myself."

**PIP:** "She looks as though she knows me. I wish I knew how to ask."

**Flags:** `edda_met=true` **only on first-exchange completion**; `checkpoint=M2` on shrine approach. The M3 exit opens with `edda_met`. Incomplete/interrupted first conversations re-trigger at the passage; optional return dialogue is never a gate.

## S03 — Ossuary Steps: evidence of failure (M3; optional text, mandatory traversal, 0:08–0:10)

**STAGE:** Steps climb through shelves of blank memorial stones. A broken bell mechanism overhead repeats an unfinished rhythm. Two Paper Drudges patrol; a vertical wall-jump shaft provides safe training and a visual exit sightline toward M4.

**ENV optional, gravestone:** "Here was someone worth mourning." *(Below it, the space intended for a name has been scraped smooth.)*

**ENV optional, note signed Rell:** "Tried trading a true memory for passage. Collector said it had no weight. Funny. It crushed my hands. — Rell"

**STAGE:** A gate latch at M3 creates a short runback to the Tollhouse. The higher doorway to G3 is barred from this side until the late shortcut is opened from above; it is not required now.

**Flags:** `m3_toll_latch_open=true` when player uses the latch (mandatory placement across route); Rell note has no progression flag.

## S04 — Tollhouse: the first interrupted command (M4; mandatory, 0:10–0:17)

**STAGE:** The Toll Warden stands between a broken ferry rail and an enormous mute bell. Intro lock frames its toll rod. Three hollow taps preview strike timing.

**SOUND / WARDEN (nonverbal):** Three hollow, uneven strikes; the final strike stops midway. No spoken words or subtitles.

**STAGE:** Mini-boss battle (see [`characters-and-bosses.md`](characters-and-bosses.md)). On defeat it places its weapon under the bell instead of striking again. The relay stalls; the bell rings one unscripted note.

**STAGE / WARDEN (nonverbal):** Its rod hangs above the bell as if awaiting a command; its hand opens instead, allowing the bell to sound on its own.

**STAGE:** The Warden collapses and no longer harms anyone. A small echo traces the cracked bell; the Vessel absorbs **Echo Step**, a short horizontal dash. A preview recess teaches the input with no lethal failure. The exit into C1 has a traversable dash-gap, telegraphed in the preceding room.

**VO — Listener:** "You have returned noise to a wound."

**STAGE:** No silhouette or crown image accompanies the line.

**Flags:** `warden_defeated=true`; `echo_step_owned=true`; `shore_relay_off=true`; `m4_exit_open=true`. Ability acquisition persists after death.

## S05 — Choirwater arrival: a change in sound (C1; mandatory, 0:17–0:21)

**STAGE:** The sea pours through pipes without splashing. A rest shrine sits in a dry alcove; discarded jars bob upstream. Dash can cross a short broken aqueduct. The camera reveals a sealed entrance to the Glass Conservatory in the far background, not reachable directly from C1.

**ENV mandatory, at entrance:** "THE BELL ENGINE KEEPS THE GARDEN CLOSED."

**STAGE:** This is an explicit objective clue, not a lore dump. First arrival sets checkpoint C1.

**Flags:** `checkpoint=C1`.

## S06 — Silence Archive: the ledger (C2; mandatory, 0:21–0:28)

**STAGE / FIRST-ENCOUNTER TRIGGER:** Thren waits in the mandatory single passage between the C2 entrance and C3 exit, hands on a vibrating table. His eyes are covered but he turns accurately toward footsteps. Approaching that passage automatically begins his first conversation once; interacting earlier also starts it. The C2→C3 threshold stays shut until `thren_met` and `engine_objective_known` are committed at the end of that exchange. Leaving, dying or backing away cannot allow bypass; an interrupted conversation re-triggers. A Choir Needle demonstrates projected danger with a floor warning. The separate C2→M2 hatch opens only from C2 and is optional; it cannot bypass Thren on the first arrival.

**THREN:** "I am blind. Before you pity me, listen."

**THREN:** "The pages are full of names. The lines between them are gone. The Choir can write down what you were, but not why you would ever be it."

**THREN:** "Three places keep the Quiet breathing: the Tollhouse, this Bell Engine and the Cradle. You've silenced one."

**THREN:** "There is a sigil beneath the Cantor's bell. It opens the Hollow Basilica, and the garden beyond. The glass does not admit an unregistered will."

**Player interaction:** Listen to a three-beat drum to receive an audio/visual preview: one long strike then a short burst of projectiles. This mechanically foreshadows C3 without a separate ability or puzzle.

**Optional follow-up:**

**THREN:** "They told me silence would spare me grief. They forgot grief is one way I know someone lived."

**Flags:** `thren_met=true` and `engine_objective_known=true` together on completion of the mandatory first exchange. C3 exit unlocks on these flags, not on an extra key. Optional hatch lever sets persistent `c2_hatch_open=true` only if used; neither optional text nor hatch use is needed.

## S07 — Bell Engine: the false harmony (C3; mandatory, 0:28–0:35)

**STAGE:** The Bell Cantor vibrates behind an open ribbed mechanism. It folds its hands around a brass tuning rod. The first attack demonstrates visible floor lines without dealing damage until the antic completes.

**SOUND / CANTOR (nonverbal):** The tuning rod produces three perfectly identical notes while the other bells remain unnaturally quiet.

**STAGE:** Mini-boss battle. On defeat the Cantor releases its rod, and differently pitched drops of water strike the basin. A sigil falls from its casing; the player obtains **Resonance Sigil**, a passive passage credential. No additional combat weapon is awarded.

**STAGE / CANTOR (nonverbal):** Its rod slips, striking two differently pitched notes for the first time. It folds inward without another gesture.

**VO — Listener:** "Some who remember will wish they had not."

**STAGE:** A submerged bell rises, opening the C4 path. Nothing identifies the speaker.

**Flags:** `cantor_defeated=true`, `choir_relay_off=true`, `resonance_sigil_owned=true`, `c4_door_open=true`.

## S08 — Hollow Basilica and Glass Gate (C4 → G1; mandatory, 0:35–0:40)

**STAGE:** A nave full of benches faces an empty speaking stand. The sigil on the player glows; the gate reacts and opens with no menu. Eerie white panes behind it show a single missing figure; none is recognizable. New checkpoint G1 is exposed just inside the garden threshold, but not required for the late boss runback if G3 has been reached.

**ENV mandatory, above gate:** "NO VOICE SHALL ENTER WITHOUT A MEASURE."

**ENV optional, prayer scratched into a bench:** "I asked that it stop hurting. I did not ask to stop loving."

**Flags:** `glass_gate_open=true`, `checkpoint=G1` on first entry; then access G2.

## S09 — Pale Orchard: Asha (G2; mandatory, 0:40–0:45)

**STAGE / FIRST-ENCOUNTER TRIGGER:** Glass branches bear flawless, scentless fruit. Asha kneels at a safe patch beside the **sole traversable G2→G3 threshold**, before the next region exit, with a bowl of unplanted soil and one living seed. She is an elderly gardener of indeterminate kind, not visually coded as a monarch or Wyrm. Reaching this threshold automatically begins her complete first exchange once; interacting with her earlier begins the same exchange. The exit cannot be crossed by jump, dash, hazard reset or a shortcut until `asha_met` is committed at its end. Most dialogue keeps camera/control presentation simple; no item, additional puzzle or fetch requirement is added.

**ASHA:** "You brought the shore's sound into a place that forbids wind."

**ASHA:** "A garden can be kept perfect by never letting anything grow. I tried telling its keeper that once."

**ASHA:** "At the Cradle there is a voice that says it can carry everyone's pain. Ask what it takes from them in exchange."

**ASHA:** "When you arrive, do not mistake recognition for permission."

**STAGE:** She touches the empty bowl but never reveals her lineage. The player sees a faint reflection of coiled shapes only in optional fractured glass, not an identifiable creature or direct spoiler.

**Optional on returning after shortcut:**

**ASHA:** "If love made every deed right, no one would ever have to apologize."

**Flags:** `asha_met=true` only after the mandatory first exchange. G2→G3 opens on that flag; if the exchange is interrupted, the threshold repeats it. Optional return dialogue does not gate progression.

## S10 — Mirror Gallery: the last question (G3; mandatory traversal, 0:45–0:47)

**STAGE:** Unnamed faceless reflections copy the Vessel's posture half a beat late. A cracked image suggests a throne with no occupant. One panel shows discarded shells; the central face is destroyed. **No identifiable Pale King crown, named title or familial dialogue.**

**ENV optional:** "We asked for a keeper. We built a door that could not open from our side."

**ENV optional:** "Whatever is not chosen is not peace."

**STAGE / REQUIRED LATCH, OPTIONAL SHORTCUT USE:** The **Mirror Latch** lies on G3's only route to the Cradle approach. Pulling it is **mandatory**: it permanently opens the two-way G3↔M3 shortcut *and* releases the nearby barrier to the G4 approach. The player never needs to travel through the newly opened shortcut; using it for return travel is **optional**. The latch is reachable only after S09/`asha_met`, and G4 cannot be reached while it is closed. The final shrine is beyond the latch and directly before the Cradle entrance. The G4 gap requires already-owned Echo Step. A trace of the four-note lullaby ends with the missing fourth note.

**Flags:** `mirror_latch_open=true` when the latch is pulled; `checkpoint=G3` when the shrine is reached. **No separate saved `g4_entry_ready` flag**: G4 approach eligibility derives from `asha_met && mirror_latch_open && echo_step_owned`, with the sigil-gated first-arrival route already completed. The shrine is reachable without engaging the boss.

## S11 — Cradle: the Listener (G4, final phase one; mandatory, 0:47–0:52)

**STAGE:** Dark suspended vessels oscillate around the Hush Engine; the Listener wears a faceless white veil and a distorted, unidentifiable mantle. First camera lock establishes arena edges. There is **no boss-name spoiler** in the UI; the boss bar reads **THE LISTENER**.

**LISTENER:** "You have carried their noise all the way to me."

**LISTENER:** "I heard every grief this place ever held. I built a mercy large enough to keep it."

**LISTENER:** "Give me the last thing you cannot bear. You need not choose again."

**STAGE:** Vessel steps forward rather than surrendering. Phase-one fight begins. Hit reactions crack only anonymous veil material: **no recognizable crown, facial profile, familial emblem, true name or identification appears anywhere in S11**, even on the final hit. The attack names and punish beats are specified in the boss document.

**Attempt-local flags:** `final_p1_started=true`. On zero health in the **current attempt**, `final_p1_cleared=true`; the still-masked boss freezes and **S12 begins before any identity exposure**. On a death in either phase, these flags reset; the player respawns at G3 with full health/zero healing charges and must beat this Phase 1 again. The unmask/name occur inside S12, never during S11 or its HUD transition. No generic death transition or ending is allowed yet.

## S12 — The face, the mother and the sacrifice (G4, 0:52–0:54; mandatory unskippable first time)

**STAGE:** The veil cracks and falls. For the first time the figure's recognizable features, broken crown and true title are shown. **Boss subtitle: THE PALE KING.** No earlier content uses this subtitle or identifiable appearance.

**VESSEL:** *(silent; steps back, hand on the red thread)*

**PALE KING:** "Even cast away, one of mine reaches the end of the world."

**ASHA (entering from glass-lit threshold):** "Do not call him yours when you could not bear what he might become."

**PALE KING:** "Mother? You stayed to watch me fail."

**ASHA:** "I stayed to give you a choice. I am Veyra, the First Wyrm. I carried you before you bore a crown."

**PALE KING:** "A choice would let them suffer."

**VEYRA:** "And take away a song? A memory? Each other? You called a prison mercy."

**STAGE:** The Cradle tries to draw the remaining memories from all three regions. Asha/Veyra places both hands into the command lattice; she unbinds its grip at the cost of her embodied existence. Her Wyrm essence travels along the chain to her son, exposing the form the Engine contained. The broken bowl in G2 splits in a synchronized cutaway. The Wyrm body is an original design, not a reproduction of existing Hollow Knight creature art.

**VEYRA (fading):** "I cannot choose for you. Not even now."

**PALE KING:** "Then I choose an end to every cry."

**STAGE:** He deliberately rejects her last invitation. White glass darkens, ancient coils form, and the antagonist becomes **THE LAST WYRM**. The transformation is **one cinematic phase break of the same final boss**, not a new encounter. Veyra dies here and does not return in the epilogue. Her sacrifice temporarily breaks the Engine's suppression and grants the Vessel a health refill before phase two.

**D2 first-time/retry rule:** On the **first full S12** only, permanently commit `identity_revealed=true` and `veyra_sacrificed=true`; `final_p2_unlocked=true` is **attempt-local** and becomes true after the completed scene. The transition restores **5/5 HP** without creating a checkpoint. If the player later dies in Phase 2, the next G4 attempt begins **S11 Phase 1 again**. After re-defeating the Listener, show a **short non-diegetic transformation visual** in S12's place and activate Phase 2, **without repeating the revelation, Veyra's appearance, sacrifice, dialogue or a second in-world death**; retain permanent story flags. Never offer a direct Phase 2 retry or skip of Phase 1.

## S13 — Last Wyrm: what chooses to remain (G4, final phase two; mandatory, 0:54–0:58)

**STAGE:** Arena geometry is unchanged, but attack lanes and camera framing widen. Boss bar **THE LAST WYRM** appears only now. A continuous silhouette with simple animated arcs gives the impression of a huge body without requiring a fully simulated segmented creature.

**LAST WYRM:** "I made a quiet world."

**LAST WYRM:** "And still you move."

**STAGE:** Phase-two fight. **Death at any point here returns to G3 (5 HP, 0 healing charges), resets both phase health pools and starts the next boss attempt from S11 Phase 1**; Last Wyrm has no independent retry. Once the Listener is beaten again, use the abbreviated S12 transition specified above. After the final stagger, the player must land one clearly signaled ordinary strike; no new finisher control, special weapon or quick-time event is introduced.

**LAST WYRM (last words):** "Then carry it. All of it."

**STAGE:** The Engine collapses into silence. After one full breath, imperfect voices, water and unsteady bells return. The Vessel keeps the red thread, no longer pulled toward any command.

**Flags:** `final_boss_defeated=true`, `hush_engine_off=true`, `ending_available=true`. Boss cannot respawn in cleared story state.

## S14 — The unsilenced bell: epilogue (mandatory, 0:58–1:00)

**STAGE (short static vignettes, no newly explorable region):** At the House, Pip reads the name on a newly legible jar and reaches for Edda. Edda weeps without hiding it. At the Archive, Thren hears a room full of different footsteps. In the Orchard, the bowl is broken but the single seed has germinated beside it. No living image of Veyra appears.

**PIP:** "Edda. I remember you."

**EDDA:** "So do I. Every mistake. And you."

**THREN (offscreen):** "The pages are too noisy to keep straight. Good."

**STAGE:** The Vessel walks out as a new, imperfect fourth note is played by an ordinary bell. The world is no longer commanded to forget; it has not become painless. A concise credit/title frame ends play. No optional ending or hidden boss.

**Flags:** `story_complete=true`.

## Optional environmental lore: placement and interpretation

| Trigger | Text/visual | What it adds, without breaking the reveal |
|---|---|---|
| M1 broken shell pile | Different shell sizes, none with names | The Vessel is not the only discarded being |
| M3 gravestone and Rell's signed note | S03 text | Weight of memory; Rell retained as offscreen worldbuilding |
| C1 floating receipt | `Paid in full: three summers and a sister's laugh.` | Memories were collected in ordinary units of life |
| C2 margin annotation | `Statement corrected: peace -> compliance.` | Historical resistance to the Quiet |
| C4 chapel prayer | S08 text | Victims consented to relief, not enslavement |
| G2 cracked glass | A coiling pattern, deliberately non-identifying | Ambiguous ancient prehistory; *not* a pre-reveal Wyrm identification |
| G3 mirror panel | Vacant throne and damaged likeness | Late foreshadowing; no direct visual reveal |

**Narrative QA (documentation logic):** M2, C2 and G2 force their first NPC exchanges before onward passage; no player can bypass Edda, Thren or Asha through either optional cross-link. Pip has no retrieval quest. The Warden and Cantor communicate only through nonverbal boss behavior, not as additional speaking NPCs. G3 latch opening is required; using its G3↔M3 shortcut is optional. **S11 remains unidentified through its final frame; S12 first reveals the Pale King.** S12 contains the **one-time canonical maternal sacrifice**; later Phase 1 victories show a non-diegetic form-change only. **D2** restarts the entire final encounter after death in either phase, while **D1** keeps discrete healing at **three charges maximum**. The one ending follows S13. These are design checks, not runtime results.
