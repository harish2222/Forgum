# Forgum Architecture & Animation Engine

## Overview
Forgum is a cross-platform, zero-dependency PowerShell module that fuses **cowsay**, **fortune**, and **lolcat** into a single, cohesive terminal experience. Its standout feature is a completely native, real-time 2D mathematical physics animation engine that manipulates ASCII art frame-by-frame.

The project is designed to be extremely lightweight, utilizing PowerShell's `[System.Text.StringBuilder]` for highly efficient memory usage and flicker-free ANSI terminal rendering.

---

## Core Pipeline

When `forgum` is executed, the following pipeline occurs:

1. **Fortune Generation (`Get-Fortune`)**: A random fortune is retrieved from the `fortunes.txt` database.
2. **Cow Assembly (`forgum`)**: The text is wrapped in a dynamically generated speech or thought bubble. A randomly selected ASCII cow (or a user-specified one) is appended beneath the bubble.
3. **Animation (`Show-CFAnimation` -> `Invoke-PhysicsCow`)**: 
   - The combined text (speech bubble + cow) is parsed. 
   - The speech bubble is **isolated** to remain perfectly static at the top of the terminal.
   - The cow itself is fed into the `PhysicsCow` 2D manipulation engine.
4. **Colorization (`Format-Lolcat`)**: Once the layout is finalized, Lolcat applies truecolor RGB gradients over the final frame.

---

## The 2D Physics Engine (`PhysicsCow.ps1`)

The animation system operates without any external dependencies (no Rust, C++, or Node.js). It runs an infinite continuous loop in interactive sessions, exiting gracefully upon any keystroke.

### Engine Mechanisms
- **Frame Buffer**: The ASCII cow is read into a 2D character array `[char][][]`.
- **Math Time Progression**: Each frame advances a global time variable `$fSpeed = $frame * $speedMultiplier * 0.3`.
- **Targeted Transforms**: The engine loops through the X and Y coordinates of the 2D array, applying sine waves, gravity, or cellular automata logic to shift characters, swap symbols, or spawn particles.
- **Rendering**: The static speech bubble is prepended to a `StringBuilder`, the transformed 2D cow array is appended, and ANSI cursor-up sequences (`Write-TerminalFrame`) rewrite the terminal buffer seamlessly at 20 FPS.

### Current Mathematical Behaviors
Cows are assigned specific mathematical behaviors via `Data/Cows/animations.json`. Current engines include:

- **`Liquid`**: Sine wave ripple effect (`offsetX = Sin(y + time)`) across the Y axis simulating water.
- **`Squish`**: The cow drops with simulated gravity, compresses horizontally/vertically upon hitting the terminal floor, and springs back up.
- **`Matrix`**: Cyberpunk digital rain where random characters inside the cow dynamically decrypt and swap.
- **`Abduction`**: A UFO tractor beam that slowly pulls the cow vertically while mathematically vaporizing the outer boundary characters.
- **`Fire`**: A bottom-up cellular automata burn effect that turns the bottom rows of the cow into floating `*`, `^`, `.` characters.
- **`Dissolve`**: Completely scatters the cow by assigning individual X/Y velocities to every non-space character.
- **`Fly`**: A Lissajous figure-8 curve (`offsetX = Sin(t)`, `offsetY = Cos(t)`) simulating organic hovering.

---

## Directory Structure

```text
Forgum/
├── Forgum.psd1 / .psm1       # Module manifest and initialization
├── Public/
│   ├── forgum.ps1     # Main entry point pipeline
│   ├── forgum.ps1     # Core cowsay string assembler
│   └── Show-CFAnimation.ps1  # Animation routing dispatcher
├── Private/
│   ├── Animation/
│   │   └── PhysicsCow.ps1    # The core 2D mathematical physics engine
│   ├── Format-CowMessage.ps1 # Speech/thought bubble generator
│   ├── Format-Lolcat.ps1     # Truecolor rainbow text generator
│   └── Write-TerminalFrame.ps1 # ANSI buffer overwriter
├── Data/
│   ├── Cows/                 # 106 .cow template files
│   │   └── animations.json   # Maps cow files to specific physics engines
│   └── Fortunes/             # fortune.txt database
└── Tests/                    # Pester 5 test suite
```

---

## Areas for Developer Improvement & Feedback

If you are looking to contribute or provide feedback on how to implement this better, here are the current technical hurdles and areas for optimization:

1. **Performance at High Resolutions**: While `StringBuilder` is fast, iterating over a 2D `[char][][]` array in native PowerShell for very large multi-line ASCII art can hit performance limits. Are there better .NET Native interops or matrix manipulation strategies within PowerShell?
2. **True Particle System Physics**: Currently, particles (like fire smoke or speech bubbles floating up) are handled by a simple custom object list `$particleList`. Is there a more performant way to manage particle life cycles and collisions natively in PS?
3. **ANSI Color Shifting**: Lolcat is currently applied *statically* over the frame or animate mode shifts the rainbow. Can we apply independent RGB values to individual particles natively within the 2D array before the final StringBuilder render?
4. **Collision Detection**: The `Dissolve` and `Squish` engines currently assume the bottom of the ASCII array is the floor. How can we implement true terminal-boundary collision detection without drastically slowing down the frame rate?
