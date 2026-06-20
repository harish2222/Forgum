# Background Animation Engine — Architecture Plan

**Date:** 2026-06-20
**Status:** Implementation Plan
**Engine Binary:** `forgum-engine` (Rust)

---

## 1. Background Overlay Model

The background animation engine renders ASCII cow art as a transparent overlay **above** the shell prompt, leaving the prompt fully interactive. The engine never enters raw mode or hides the cursor.

### Terminal Screen Layout

```
┌──────────────────────────────────────────────────┐  Row 0
│                 OVERLAY REGION                    │
│  ┌────────────────────────────────────────────┐  │
│  │         Animation Effect Renders Here      │  │
│  │         (aurora, ember, glitch, etc.)      │  │
│  │                                            │  │
│  │         Cow text + Particles               │  │
│  │                                            │  │
│  └────────────────────────────────────────────┘  │
│                                                  │  Row (overlay_height - 1)
├──────────────────────────────────────────────────┤  ← ob_y1 (overlay boundary)
│                                                  │
│              PROMPT REGION (READ ONLY)            │
│  user@host:~/project$ _                          │
│                                                  │
└──────────────────────────────────────────────────┘  Row (rows - 1)
```

- **Overlay Region**: Rows `0..ob_y1` — where animation renders.
- **Prompt Region**: Rows `ob_y1..rows` — never written by the engine.
- `ob_y1 = min(overlay_height, rows - 3)` — always leaves 3 rows minimum for prompt.

---

## 2. Requirements

| Requirement | Description |
|-------------|-------------|
| **Fixed frame size** | FrameBuffer allocated at `(cols × rows)`, resized on `Event::Resize` |
| **Window-responsive** | Overlay region adapts to terminal resize events |
| **Infinite looping** | `duration=0` → loop forever until `q`/`Esc`/`Enter`/`Ctrl+C` |
| **Finite looping** | `duration=N` → run exactly N frames then exit |
| **Prompt safety** | Never hide cursor, never enter raw mode, never write below `ob_y1` |
| **No flicker** | Damage/diff rendering — only changed cells are written |
| **No cursor jump** | Save/restore cursor around every render cycle |
| **Multiplexer compat** | Works under tmux, zellij, screen, wezterm |
| **Clean exit** | Clear overlay region on exit, reset colors, restore cursor visibility |

---

## 3. Cursor Save/Restore Mechanism

Every render cycle follows this sequence:

```
1. cursor::SavePosition          ← Save shell cursor position
2. fb.render_region(stdout, clip) ← Write only dirty cells in overlay region
3. cursor::RestorePosition        ← Restore shell cursor to exact position
4. stdout.flush()                 ← Flush to terminal
```

This ensures the user's typing cursor and prompt text are never corrupted.

### Implementation (main.rs:102-107)

```rust
queue!(stdout, cursor::SavePosition)?;
let written = fb.render_region(&mut stdout, clip)?;
queue!(stdout, cursor::RestorePosition)?;
stdout.flush()?;
```

---

## 4. Region Allocation and Clipping

### RegionAllocator (`region.rs`)

- Manages a list of named `Region` objects, each with a `Rect` bounds.
- New regions are clamped to the canvas on allocation.
- On canvas resize, all regions are re-clamped; regions fully outside become `visible: false`.

### Clipping Flow

```
Terminal::overlay_bounds()  →  (x0, y0, x1, y1)
       ↓
RegionAllocator::allocate(Rect(x0, y0, x1, y1), priority=100)  →  overlay_id
       ↓
RegionAllocator::get(overlay_id)  →  Region { bounds: Rect }
       ↓
fb.render_region(stdout, clip)  ← Only cells within `clip` are written
       ↓
Effect::render(fb, clip)  ← Effect calls fb.set_cell_in_region(x, y, cell, clip)
```

### Clipping Enforcement

```rust
// framebuffer.rs:82-88
pub fn set_cell_in_region(&mut self, x: usize, y: usize, cell: Cell, clip: Rect) {
    let cx = x as u16;
    let cy = y as u16;
    if clip.contains(cx, cy) {
        self.set_cell(x, y, cell);
    }
}
```

---

## 5. Resize Handling

On `Event::Resize(new_cols, new_rows)`:

```
1. term.refresh_size()
2. fb.resize(new_cols, new_rows)           ← Reallocate front/back buffers
3. region_alloc.resize_canvas(...)         ← Re-clamp all regions to new canvas
4. region_alloc.resize_region(overlay_id, nob)  ← Update overlay bounds
5. effect.on_resize(new_cols, new_rows)    ← Effect recalculates center offset
```

### Effect Resize Behavior

Each effect stores `offset_x`, `offset_y`, `text_w`, `text_h`. On resize, it calls `center_offset()` to recalculate position:

```rust
fn center_offset(text_lines: usize, text_width: usize, fb_w: usize, fb_h: usize) -> (usize, usize) {
    let ox = if fb_w > text_width { (fb_w - text_width) / 2 } else { 2 };
    let oy = if fb_h > text_lines { (fb_h - text_lines) / 2 } else { 2 };
    (ox.max(2), oy.max(2))
}
```

---

## 6. Loop Behavior

### duration = 0 (Infinite)

```
loop {
    // ... render cycle ...
    frame_count += 1;
    if max_frames > 0 && frame_count >= max_frames { break; }
    // max_frames=0 → never breaks → loops forever
}
```

### duration = N (Finite)

```
max_frames = N;
loop {
    // ... render cycle ...
    frame_count += 1;
    if frame_count >= max_frames { break; }
}
```

### Exit Conditions

| Trigger | Code |
|---------|------|
| Press `q` | `KeyCode::Char('q')` |
| Press `Esc` | `KeyCode::Esc` |
| Press `Enter` | `KeyCode::Enter` |
| Press `Ctrl+C` | `KeyCode::Char('c') + CTRL` |
| Duration exhausted | `frame_count >= max_frames` |

---

## 7. Cleanup on Exit

### Foreground Mode

```rust
execute!(stdout, style::ResetColor, cursor::Show)?;
```

### Background Mode

```rust
// Clear the entire overlay region
queue!(stdout, cursor::SavePosition)?;
for y in 0..ob_y1 {
    queue!(stdout, cursor::MoveTo(0, y))?;
    queue!(stdout, style::Print(" ".repeat(cols as usize)))?;
}
queue!(stdout, cursor::RestorePosition)?;
execute!(stdout, style::ResetColor)?;
```

This restores the terminal to its pre-animation state — the prompt line remains intact.

---

## 8. Daemon Spawn Flow

When `background=true` and `--daemon` is not set:

```
1. Parse JSON from stdin
2. Spawn detached child process: forgum-engine --daemon
3. Pipe original JSON to child's stdin
4. Parent exits immediately → shell prompt returns
5. Child runs render_loop_background() independently
```

---

## 9. Adaptive Frame Scheduler

`Scheduler` (`scheduler.rs`) dynamically adjusts FPS:

| State | FPS | Condition |
|-------|-----|-----------|
| Active | 60 (or target) | Damage count > 0 |
| Idle | 5 | 15+ consecutive zero-damage frames |
| Initial | Configured FPS | At startup |

```rust
scheduler.adapt(damage_count);    // Adjust FPS based on activity
scheduler.wait_if_needed();       // Sleep until next frame time
scheduler.should_render(count);   // Skip render if idle and no damage
```

---

## 10. Phase-by-Phase Implementation Plan

### Phase 1: Core Engine Shell
- [ ] `SceneConfig` deserialization with all fields
- [ ] stdin JSON parsing with error reporting
- [ ] `--daemon` flag and `--help` flag handling
- [ ] `init <shell>` hook generation

### Phase 2: FrameBuffer & Rendering
- [ ] Double-buffered `FrameBuffer` with `Cell` storage
- [ ] `set_cell_in_region()` clipping enforcement
- [ ] `compute_damage()` diff detection
- [ ] `render_region()` with ANSI color optimization
- [ ] `resize()` reallocation

### Phase 3: Terminal Management
- [ ] `Terminal::detect()` with crossterm
- [ ] `overlay_bounds()` prompt-safe calculation
- [ ] `refresh_size()` on resize events
- [ ] Multiplexer detection (tmux, zellij, screen, wezterm)
- [ ] `Drop` implementation for raw mode cleanup

### Phase 4: Region Allocation
- [ ] `RegionAllocator` with `allocate()`, `resize_region()`, `resize_canvas()`
- [ ] `Rect::intersect()` and `Rect::contains()` for clipping
- [ ] `clamp_to_canvas()` on allocation

### Phase 5: Foreground Render Loop
- [ ] Full-screen animation mode
- [ ] Cursor hide/show lifecycle
- [ ] Keyboard input handling (q/Esc/Enter/Ctrl+C)
- [ ] Resize event handling
- [ ] Duration-based exit

### Phase 6: Background Render Loop
- [ ] Overlay-only rendering (top N rows)
- [ ] No raw mode, no cursor hide
- [ ] Save/restore cursor every frame
- [ ] Cleanup on exit (clear overlay, reset colors)
- [ ] Daemon spawn from parent process

### Phase 7: Scheduler & Adaptive FPS
- [ ] Idle/active FPS switching
- [ ] Damage-based adaptation
- [ ] Frame timing with `wait_if_needed()`
- [ ] `should_render()` skip logic

### Phase 8: Effect System
- [ ] `Effect` trait: `update()`, `render()`, `on_resize()`
- [ ] `create_effect()` factory function
- [ ] Implement all 9 existing effects (Aurora, Ember, Shatter, Plasma, LiquidChrome, Portal, Glitch, NeonPulse, Physics)
- [ ] "random" effect selection

### Phase 9: Particle System
- [ ] `ParticlePool` with SoA layout
- [ ] `spawn()` recycling (find inactive slot)
- [ ] Per-frame update: velocity, life, gravity
- [ ] Color fade based on life percentage

### Phase 10: Polish & Testing
- [ ] Unit tests for FrameBuffer, Region, Scheduler, Color
- [ ] Integration tests for JSON parsing
- [ ] Manual terminal testing (tmux, zellij)
- [ ] Memory profiling for long-running sessions
- [ ] Performance benchmarking at various terminal sizes
