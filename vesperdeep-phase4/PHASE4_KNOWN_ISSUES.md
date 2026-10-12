# Corrected Phase 4 known issues and unverified behavior

The owner identified wall sticking, Moth trapping and low enemy/boss difficulty in the previous Linux build. Targeted corrections now pass scripted tests, but the owner has not replayed this corrected build. No currently reproduced progression blocker remains in the automated M1→C1 route. The following limits stay open.

| ID | Status | Scope and next check |
|---|---|---|
| K1 | UNVERIFIED | Windows x86-64 executable and PCK were generated but not executed on Windows. Run the checklist in `PHASE4_MANUAL_QA.md` on a Windows host, including launch/relaunch, input, boss retry, and dash crossing. |
| K2 | UNVERIFIED | A physical controller was not attached; mapped joypad actions and generic Xbox-style prompts are scripted only. Check D-pad/stick, face buttons, RB, Menu, dialogue-only navigation, reconnection and dead zones on actual hardware. |
| K3 | CORRECTED-BUILD OWNER REVIEW PENDING | Wall/ledge feel near C1, M3 optional chimney climb, Drudge/Moth and Warden directional body-contact feel and tuning, multi-enemy stun safety, M1–M4 density, Warden difficulty/fairness, camera and first-pass duration need owner-operated replay. Scripted physics confirms separation, one-hit immunity, ordinary C1 wall falling, M3 wall slide and a traversable main route, not human feel or a 17-minute measurement. |
| K4 | SCOPE LIMITATION | Geometry, characters, boss animations, and bells are original placeholder shapes; no final sound/animation or art pipeline is included. Warning cues are visual, so the slice is readable without audio, but the GDD's distinct *audible* boss tells have not been implemented. Review presentation as a prototype rather than finished audiovisual polish. |
| K5 | SCOPE LIMITATION | Only M1–M4 and the C1 arrival are authored for this milestone. C2–G4 are retained Phase 3 scaffolds; C3 Cantor is a fixture and G4 has no final encounter. Their presence in the project does not imply finished extra regions, the ending, or a 60-minute tested game. |
| K6 | USABILITY LIMITATION | Gameplay rebindings work for the current session but reset on relaunch, as in accepted Phase 3. Controller glyphs are generic and may not match every pad. |
| K7 | MIGRATION NOTE | Phase 4 uses separate user data. Copy a backed-up Phase 3 version-1/2 save manually if continuing that run. Migration writes a version-3 file in the Phase 4 namespace; do not overwrite the Phase 3 original with the migrated file. |
| K8 | EXTRACTION NOTE | Standard `unzip` restores the Linux executable's stored mode 755; Python `zipfile.extractall` does not restore Unix executable permissions. If the Linux binary refuses to launch after extraction, run `chmod +x builds/vesperdeep-linux.x86_64` in the extracted project. |

Report new defects with build, OS, keyboard/controller model, starting save state, room, steps, expected/actual, and screenshot or video. Do not mark any of these UNVERIFIED rows PASS on the basis of export generation or scripted input.
