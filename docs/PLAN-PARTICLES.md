# Particle Type Specifications

**Date:** 2026-06-20
**Particle Pool:** `ParticlePool` in `engine/src/particles.rs`

---

## ParticlePool Architecture

SoA (Struct of Arrays) layout for cache-friendly iteration:

```rust
pub struct ParticlePool {
    pub active: Vec<bool>,     // Is this slot alive?
    pub x: Vec<f32>,           // World X position
    pub y: Vec<f32>,           // World Y position
    pub vx: Vec<f32>,          // X velocity (chars/sec)
    pub vy: Vec<f32>,          // Y velocity (chars/sec)
    pub life: Vec<f32>,        // Remaining life (seconds)
    pub max_life: Vec<f32>,    // Initial life (for fade calc)
    pub ch: Vec<char>,         // Rendered character
    pub r: Vec<u8>,            // Red channel
    pub g: Vec<u8>,            // Green channel
    pub b: Vec<u8>,            // Blue channel
}
```

### Spawn Mechanics

- `spawn()` finds first inactive slot (`active[i] == false`)
- If pool is full, spawn is silently dropped
- `life` is initialized to the full value, decremented each frame
- `max_life` stores the original value for percentage-based fade

### Death Mechanics

- When `life <= 0.0`, `active[i]` set to `false`
- Slot becomes available for reuse on next `spawn()`
- No explicit removal — lifecycle is automatic

---

## Particle Type 1: Fire

**Used by:** Ember effect, Fire effect, Dragon/Cowfee/Daemon/Satanic cows

### Visual Description
Rising embers that transition from bright yellow → orange → dark red → gray ash. Characters: `*` → `^` → `.` → extinct.

### Spawn Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Rate | 3-5 per frame | Continuous stream |
| Position X | `random(offset_x .. offset_x + cow_width)` | Spread across cow bottom |
| Position Y | `offset_y + cow_height` | Just below cow body |
| Initial char | `*` | Bright ember |

### Movement Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Direction | Upward (negative Y) | Anti-gravity feel |
| Speed X | `random(-2.0 .. 2.0)` | Horizontal drift |
| Speed Y | `random(-15.0 .. -5.0)` | Fast upward rise |
| Gravity | None | Constant velocity |

### Death Behavior
| Life % | Char | Color | Notes |
|--------|------|-------|-------|
| 100%→60% | `*` | `(255, life_pct→255, 0)` bright yellow-orange | Hot ember |
| 60%→30% | `^` | `(life_pct→255, 0, 0)` orange-red | Cooling |
| 30%→0% | `.` | `(life_pct→100, 0, 0)` dark red-gray | Ash, fading |
| ≤0% | — | — | Slot freed |

### Rendering
- Cow body chars lit by `apply_radial_glow()` from nearby particles
- Base cow color: dim gray `(60, 60, 60)`
- Glow radius: 6.0 chars
- Particles rendered as independent chars at their world position

---

## Particle Type 2: Bubbles

**Used by:** Dolphin, Whale, Docker-Whale, Seahorse, Happy-Whale, Ebi-Furai cows

### Visual Description
Transparent bubbles that float upward from the cow, wobbling slightly side-to-side. Characters: `o` `O` `0` `.`

### Spawn Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Rate | 2-4 per frame | Steady stream |
| Position X | `random(offset_x .. offset_x + cow_width)` | Across cow width |
| Position Y | `offset_y + cow_height` | Below cow body |
| Initial char | `random choice of ['o', 'O', '0']` | Bubble variety |

### Movement Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Direction | Upward (negative Y) | Floating up |
| Speed X | `sin(time + particle_id) * 0.5` | Gentle wobble |
| Speed Y | `random(-3.0 .. -1.0)` | Slow float |
| Gravity | None | Constant velocity |
| Wobble | `x += sin(life * 3.0) * 0.3` | Horizontal oscillation |

### Death Behavior
| Life % | Char | Color | Notes |
|--------|------|-------|-------|
| 100%→50% | `o`/`O`/`0` | `(150, 200, 255)` light blue | Full bubble |
| 50%→20% | `o` | `(100, 150, 255)` medium blue | Shrinking |
| 20%→0% | `.` | `(80, 120, 255)` dim blue | Tiny bubble |
| ≤0% | — | — | Popped |

### Rendering
- Cow body: blue-tinted liquid effect (hue ~210)
- Bubbles rendered at world position, overlapping cow if applicable
- No glow effect — bubbles are independent visual elements

---

## Particle Type 3: Zzz

**Used by:** Koala, Luke-Koala, SnoopySleep cows

### Visual Description
Sleepy "Z" characters that drift upward and grow larger before fading. Characters: `z` → `Z` → `Zzz`

### Spawn Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Rate | 1 per 15 frames (~0.5/sec) | Slow, sleepy pace |
| Position X | `offset_x + cow_width * 0.7` | Near cow's mouth area |
| Position Y | `offset_y + cow_height * 0.3` | Head level |
| Initial char | `z` | Small z |

### Movement Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Direction | Upward-right | Drifting away |
| Speed X | `random(0.5 .. 2.0)` | Gentle rightward drift |
| Speed Y | `random(-2.0 .. -0.8)` | Very slow rise |
| Gravity | None | Constant velocity |
| Scale | Grows from `z` → `Z` as life decreases | Visual size increase |

### Death Behavior
| Life % | Char | Color | Notes |
|--------|------|-------|-------|
| 100%→60% | `z` | `(180, 180, 255)` light lavender | Small, forming |
| 60%→30% | `Z` | `(150, 150, 255)` medium lavender | Large, full |
| 30%→0% | `Z` | `(100, 100, 200)` dim lavender | Fading |
| ≤0% | — | — | Dissipated |

### Rendering
- Cow body: warm breathing effect (subtle vertical scale)
- Zzz particles float above and right of the cow
- No glow — particles are self-luminous

---

## Particle Type 4: Stars

**Used by:** Nyan, Wizard cows

### Visual Description
Sparkling star characters that drift leftward and twinkle. Characters: `*` `+` `.` `✦`

### Spawn Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Rate | 4-6 per frame | Dense trail |
| Position X | `offset_x + cow_width` | Right edge of cow (trailing) |
| Position Y | `random(offset_y .. offset_y + cow_height)` | Full height spread |
| Initial char | `random choice of ['*', '+', '✦']` | Star variety |

### Movement Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Direction | Leftward (negative X) | Trailing behind |
| Speed X | `random(-4.0 .. -1.0)` | Leftward drift |
| Speed Y | `random(-1.0 .. 1.0)` | Slight vertical wander |
| Gravity | None | Constant velocity |
| Twinkle | Color brightness oscillates `sin(life * 5)` | Sparkle effect |

### Death Behavior
| Life % | Char | Color | Notes |
|--------|------|-------|-------|
| 100%→50% | `*`/`+`/`✦` | `(255, 255, random(200-255))` bright white-gold | Sparkling |
| 50%→20% | `.` | `(200, 200, random(150-255))` fading gold | Dimming |
| 20%→0% | `.` | `(100, 100, 150)` dim gray-blue | Nearly invisible |
| ≤0% | — | — | Extinguished |

### Rendering
- Cow body: bright saturated colors (flying motion)
- Star trail rendered behind/below cow movement direction
- Each star's brightness oscillates independently for twinkle

---

## Particle Type 5: Glitch

**Used by:** Ghost, Ghostbusters cows

### Visual Description
Corrupted digital fragments — random characters with harsh RGB colors that flicker in and out.

### Spawn Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Rate | 8-12 per frame | Rapid burst |
| Position X | `random(offset_x - 3 .. offset_x + cow_width + 3)` | Around cow edges |
| Position Y | `random(offset_y .. offset_y + cow_height)` | Full height |
| Initial char | `random ASCII 33..126` | Any printable char |

### Movement Behavior
| Param | Value | Notes |
|-------|-------|-------|
| Direction | Random | Chaotic scatter |
| Speed X | `random(-8.0 .. 8.0)` | High horizontal velocity |
| Speed Y | `random(-6.0 .. 6.0)` | High vertical velocity |
| Gravity | None | Constant velocity |
| Jitter | Color changes every 2 frames | Flicker effect |

### Death Behavior
| Life % | Char | Color | Notes |
|--------|------|-------|-------|
| 100%→70% | random | `(random(0-255), 0, 0)` or `(0, 255, 0)` or `(0, 0, 255)` | Harsh primary |
| 70%→30% | random | `(random(0-100), 0, 0)` or similar | Dimming |
| 30%→0% | `░`/`▒`/`▓` | `(30, 30, 30)` near-black | Digital noise |
| ≤0% | — | — | Signal lost |

### Rendering
- Cow body: dissolving/fading (ghost effect)
- Glitch particles create a "digital disintegration" border
- Harsh color transitions (no blending) — intentionally jarring
- Particles overlap cow characters for corruption effect

---

## Particle Pool Sizes by Effect

| Effect | Pool Size | Rationale |
|--------|-----------|-----------|
| Ember | 1,000 | Continuous stream, moderate density |
| Shatter | 5,000 | One-shot explosion, needs all chars |
| Physics | 200 | Sparse sparkles |
| Fire | 3,000 | Dense fire simulation |
| Dissolve | 5,000 | One-shot, all chars become particles |
| Bubbles | 500 | Moderate density |
| Zzz | 50 | Very sparse, slow spawn |
| Stars | 800 | Dense trail |
| Glitch | 600 | Dense burst |

---

## Common Update Pattern

```rust
for i in 0..pool.active.len() {
    if pool.active[i] {
        pool.life[i] -= dt;
        if pool.life[i] <= 0.0 {
            pool.active[i] = false;  // Death: free slot
        } else {
            // Movement
            pool.x[i] += pool.vx[i] * dt;
            pool.y[i] += pool.vy[i] * dt;

            // Optional: gravity
            // pool.vy[i] += gravity * dt;

            // Color fade based on remaining life
            let fade = pool.life[i] / pool.max_life[i];
            pool.r[i] = (base_r as f32 * fade) as u8;
            pool.g[i] = (base_g as f32 * fade) as u8;
            pool.b[i] = (base_b as f32 * fade) as u8;
        }
    }
}
```
