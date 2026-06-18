# Forgum TUI Animation Plan

This document outlines a strategic plan for integrating advanced TUI (Text User Interface) animations into the Forgum project. It draws inspiration from Rust-based pixel rendering engines (`termflix`), shell-based template animations (`xmas.ysap.sh`), and broader terminal ASCII art techniques.

## 1. Insights from `termflix` (Rust Animation Engine)

The `termflix` repository demonstrates a highly structured approach to terminal animations using Rust:

*   **Canvas Abstraction:** Instead of printing characters directly, the engine writes to a `Canvas` object. The canvas holds a 1D/2D array of pixels (brightness values) and colors.
*   **Sub-cell Resolution:** The canvas operates at a higher resolution than the terminal grid. It supports different `RenderMode`s:
    *   **Braille:** 2x4 pixels per terminal cell (highest resolution).
    *   **HalfBlock (`▀▄█`):** 1x2 pixels per terminal cell.
    *   **Ascii:** 1x1 pixels mapped to density characters (e.g., ` .:-=+*#%@`).
*   **Animation Trait:** Every effect (fire, matrix, fluid dynamics) implements an `Animation` trait with an `update(canvas, dt, time)` method. This abstracts the math from the rendering.
*   **Post-processing:** Because the canvas holds raw math values (0.0-1.0), it can easily apply post-processing like bloom, scanlines, and vignette before quantizing down to terminal colors/characters.

## 2. Insights from `xmas.ysap.sh` (Bash Template Animation)

The `xmas.ysap.sh` repository provides a practical, lightweight approach to animating static ASCII art (similar to cow files) in a shell script:

*   **Template String Replacement:** The script defines a static ASCII tree but uses numeric placeholders (`0`, `1`, `2`, `3`) instead of characters for the lights.
*   **Frame Calculation:** In a loop, it takes a base frame index, rotates through a color array (`lightidx % len`), and uses native string replacement (`${t// 0 / <colored_char>}`) to generate the frame.
*   **Delta Rendering:** Instead of clearing the entire screen (which causes flickering), it uses ANSI escape codes (or `tput cup`) to move the cursor to specific coordinates (`$x`, `$y`) and overwrites only the necessary text.
*   **Independent Entity Tracking:** For things like snowflakes, it maintains an array of objects (`"x y color char"`). Each frame, it moves the cursor to the old position, prints a space to erase it, calculates the new position, and draws the snowflake.

## 3. Other TUI Animation Approaches

Research into other TUI animation projects reveals a few common patterns:

*   **Video to ASCII (`viu`, `mpv` with `libcaca`):** These tools read standard video/GIF formats, resize the frames to match the terminal rows/cols, map pixel luma/chroma to ANSI colors and block characters, and flush them at 30+ FPS. 
*   **State Machines (`cmatrix`, `asciiquarium`):** These maintain an internal grid of state objects (e.g., a "droplet" with speed, length, and character pool). They iterate over the grid, update the logic, and render the entire grid to an in-memory string buffer before doing a single fast `Write` to the console.

---

## 4. Inducing into Forgum

Given Forgum's constraints (PowerShell, zero external dependencies, fast execution), we can induce these concepts into a phased implementation plan.

### Phase 1: Dynamic Cow Templates (The `ysap` approach)
*   **Concept:** Extend `.cow` files or the `Show-CFAnimation.ps1` router to support template animation.
*   **Implementation:**
    *   Identify specific characters in a cow file that can be animated (e.g., the eyes `$eyes`, the tongue `$tongue`, or new custom variables like `$prop1`).
    *   Implement an animation loop that repeatedly uses `[System.Text.StringBuilder]` to perform string replacements on these placeholders.
    *   Use `[Console]::SetCursorPosition($x, $y)` to jump to the top-left of the cow drawing and overwrite it without clearing the console (`Clear-Host` flickers).
*   **Use Cases:** Blinking eyes, talking animations (mouth moving), or a rainbow color cycle that shifts across the cow's body line-by-line.

### Phase 2: The Forgum Canvas (The `termflix` approach)
*   **Concept:** Introduce an intermediate rendering layer in PowerShell for advanced particle effects.
*   **Implementation:**
    *   Create a PowerShell `class Canvas` containing a 2D array of a custom `struct Cell { char Char; string FgColor; string BgColor; }`.
    *   Write a method to "stamp" a cow template onto this canvas.
    *   Implement animation generators (e.g., `Invoke-CFParticleSystem`) that modify the canvas (like adding falling snow, matrix rain behind the cow, or fire at the bottom).
    *   Implement a `Render()` method that converts the 2D array into a single massive ANSI-escaped string using `StringBuilder` and outputs it in one go to prevent tearing.
*   **Use Cases:** "Weather" modes for the cow (snowing, raining), or background effects (Matrix code falling behind the cow).

### Phase 3: GIF/Video Playback Support
*   **Concept:** Allow Forgum to play animated GIFs as cows or in speech bubbles.
*   **Implementation:**
    *   Since we have zero external dependencies, we can use built-in .NET classes like `[System.Drawing.Image]` or `[System.Windows.Media.Imaging.GifBitmapDecoder]` (depending on PS edition compatibility) to extract frames from a `.gif`.
    *   Downsample each frame into a "HalfBlock" (`▀▄█`) string grid using ANSI TrueColor (`\e[38;2;R;G;Bm`).
    *   Loop and render the frames using a strict `[System.Diagnostics.Stopwatch]` to maintain accurate FPS timings.
*   **Use Cases:** `Invoke-Forgum -GifPath ./nyancat.gif` which renders Nyan Cat inside the terminal using truecolor half-blocks.

## Next Steps for Development
1.  **Cursor Control Utility:** Add a robust internal helper in `Private/` for ANSI cursor positioning (`\e[<r>;<c>H`).
2.  **String Buffer Renderer:** Refactor `Show-CFAnimation.ps1` to use a double-buffering concept where the entire next frame is built in a `StringBuilder` before being written, ensuring smooth >30 FPS playback.
3.  **Prototype Phase 1:** Create a new switch `Invoke-Forgum -AnimateCow` that uses template replacement to make a cow's eyes blink.
