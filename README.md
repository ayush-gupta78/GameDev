# Vesperdeep — An AI Game Development Experiment

### Testing the Limits of ChatGPT Sol 6

This project was an experiment to test the **creativity, coding capabilities, self-refactoring ability, and overall limitations of ChatGPT Sol 6** in building a complete 2D Metroidvania game.

**The experiment failed. Spectacularly.**

The goal was to see how far an AI model could go in developing a playable game with minimal human intervention.

### What Actually Worked

- **Physics Engine:** Surprisingly good. Player movement, jumping, collisions, and core combat mechanics were functional.
- **Core Gameplay:** A playable foundation with enemies, platforming, and combat systems.
- **Technical Implementation:** The model demonstrated reasonable capabilities when implementing individual gameplay mechanics.

### Where It Failed

- **UI Design:** Poor visual quality and inconsistent design.
- **Backgrounds & Environments:** Generic, uninspiring, and lacking artistic cohesion.
- **Animations:** Rudimentary and visually disappointing.
- **Creative Direction:** The model struggled to turn functional systems into a compelling game experience.
- **Self-Refactoring:** Iterative improvements frequently introduced additional complexity instead of meaningfully improving the project.

The AI could generate UI elements, backgrounds, and animations, but the results were far below the quality expected from a polished game.

For a **solo developer**, manually redesigning and refactoring everything would have required more effort than the experiment justified.

### Run the Game

The playable Phase 4 build is available for Linux.

Navigate to the `vesperdeep-phase4` directory and execute:

```bash
chmod +x builds/vesperdeep-linux.x86_64
./builds/vesperdeep-linux.x86_64
```

### Final Verdict

**Good physics. Functional gameplay. Terrible presentation.**

The experiment demonstrated that AI can establish a reasonably functional gameplay foundation, but generating code is not the same as building a cohesive, polished game.

The biggest limitation wasn't getting things to work. It was achieving consistent artistic quality, maintaining architectural coherence, and improving the project without creating more work.

For a solo developer, the cost of refactoring, redesigning, and polishing the AI-generated output ultimately outweighed the benefits.

**Result: A technically interesting experiment, but an unsuccessful game development project.**

*An experiment in how far AI-assisted game development can go before human intervention becomes the bottleneck.*
