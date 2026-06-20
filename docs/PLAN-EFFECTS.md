# Animation Effects — Complete Specification

**Date:** 2026-06-20
**Total Effects:** 18 (9 existing + 9 new)

---

## EXISTING EFFECTS (already implemented in `effects.rs`)

---

### 1. Aurora

**Description:** Rainbow HSV hue cycling across the cow's body, hue shifts vertically.

**Algorithm:**
```
for each non-space character at (x, y):
    hue = (time + y * 10.0) % 360.0
    color = hsv_to_rgb(hue, 0.8, 1.0)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 50.0 | Time multiplier per frame |
| `saturation` | f32 | 0.8 | HSV saturation |
| `brightness` | f32 | 1.0 | HSV value |

**Visual:** Smooth vertical rainbow gradient that scrolls over time. Each row has a different hue creating a northern-lights effect.

---

### 2. Ember

**Description:** Cow glows with fire particles rising from below, color shifts from bright yellow → orange → dark red → gray.

**Algorithm:**
```
spawn 3 particles/frame below cow:
    px = random(offset_x .. offset_x + width)
    py = offset_y + height
    vx = random(-2.0 .. 2.0)
    vy = random(-15.0 .. -5.0)
    life = random(1.0 .. 3.0)

for each active particle:
    life -= dt
    x += vx * dt; y += vy * dt
    if life% > 0.6: color = yellow(*, 255, life, 0)
    elif life% > 0.3: color = orange(^, life, 0, 0)
    else: color = gray(., life, 0, 0)

for each cow character:
    base_color = dim gray (60, 60, 60)
    for each nearby particle:
        base_color = apply_radial_glow(base_color, particle)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `spawn_rate` | u32 | 3 | Particles spawned per frame |
| `glow_radius` | f32 | 6.0 | Radial glow influence radius |
| `max_particles` | u32 | 1000 | Particle pool capacity |

**Visual:** Cow body is dim gray, lit by nearby fire particles. Particles rise, shrink, and fade from bright to dark.

---

### 3. Shatter

**Description:** Cow explodes into individual characters that fly outward with gravity, then fade.

**Algorithm:**
```
on init:
    for each non-space character at (x, y):
        vx = random(-20.0 .. 20.0)
        vy = random(-15.0 .. 10.0)
        life = random(2.0 .. 5.0)
        spawn particle at (x, y) with velocity

for each frame:
    gravity = 30.0
    for each active particle:
        life -= dt
        vy += gravity * dt
        x += vx * dt; y += vy * dt
        brightness = 255 * (life / max_life)
        color = (brightness, brightness, brightness)
    if no particles active: effect stops
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `gravity` | f32 | 30.0 | Downward acceleration |
| `max_particles` | u32 | 5000 | Particle pool capacity |

**Visual:** Cow's characters explode outward in all directions, arc downward under gravity, fade to black. One-shot effect.

---

### 4. Plasma

**Description:** Classic plasma effect using overlapping sine/cosine waves mapped to hue.

**Algorithm:**
```
for each non-space character at (x, y):
    v = (sin(x * 0.2 + time) + cos(y * 0.2 + time) + 2.0) / 4.0
    plasma_color = hsv_to_rgb(v * 360, 1.0, 1.0)
    final = blend_color_dodge(base_gray, plasma_color)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 3.0 | Time multiplier |
| `frequency` | f32 | 0.2 | Wave frequency |
| `base_brightness` | u8 | 80 | Base gray level |

**Visual:** Swirling, pulsating color waves across the cow body. Organic, lava-lamp-like motion.

---

### 5. LiquidChrome

**Description:** Metallic liquid effect with vertical sine-wave intensity modulation.

**Algorithm:**
```
for each non-space character at (x, y):
    intensity = (sin(y * 0.5 + time) * 0.5 + 0.5) * 200 + 55
    color = (intensity, intensity, 255)  ← blue-tinted chrome
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 2.0 | Time multiplier |
| `frequency` | f32 | 0.5 | Vertical wave frequency |
| `blue_tint` | u8 | 255 | Blue channel constant |

**Visual:** Cow appears to be made of liquid metal, with shimmering waves flowing vertically. Cool blue-white palette.

---

### 6. Portal

**Description:** Spiral rainbow effect radiating from the center of the cow.

**Algorithm:**
```
cx = x - 15.0    (center offset)
cy = y - 10.0
dist = sqrt(cx² + cy²)
angle = atan2(cy, cx)
hue = (dist * 10 - time * 50 + angle * 180/π) % 360
color = hsv_to_rgb(hue, 1.0, 1.0)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 5.0 | Spiral rotation speed |
| `spiral_density` | f32 | 10.0 | Distance-to-hue multiplier |
| `center_x` | f32 | 15.0 | Spiral center X offset |
| `center_y` | f32 | 10.0 | Spiral center Y offset |

**Visual:** hypnotic spiral rainbow radiating outward from center. Colors rotate and pulse.

---

### 7. Glitch

**Description:** Random horizontal shifts and RGB color bursts simulating digital corruption.

**Algorithm:**
```
is_glitch = random(10% chance)
x_shift = is_glitch ? random(-2..2) : 0

for each non-space character:
    render_x = x + x_shift
    if is_glitch:
        color = random choice of (255,0,0) / (0,255,0) / (0,0,255)
    else:
        color = (200, 200, 200)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `glitch_probability` | f32 | 0.1 | Chance of glitch frame |
| `max_shift` | i32 | 2 | Max horizontal displacement |
| `normal_color` | (u8,u8,u8) | (200,200,200) | Non-glitch frame color |

**Visual:** Mostly static gray cow with occasional violent red/green/blue shifts and horizontal displacement. Digital corruption aesthetic.

---

### 8. NeonPulse

**Description:** Moving neon light source that illuminates the cow with radial glow.

**Algorithm:**
```
pulse = (sin(time) * 0.5 + 0.5) * 200 + 55
light_x = offset_x + (cos(time) * 0.5 + 0.5) * 60
light_y = offset_y + (sin(time) * 0.5 + 0.5) * 20
neon_color = (pulse, 0, 255)

for each non-space character:
    base_color = (40, 40, 40)  ← very dark
    final = apply_radial_glow(x, y, light_x, light_y, 30.0, neon_color, base_color)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 3.0 | Light movement speed |
| `glow_radius` | f32 | 30.0 | Neon light radius |
| `base_darkness` | u8 | 40 | Background darkness level |

**Visual:** Dark cow with a moving purple-pink neon spotlight that sweeps across the surface. Dramatic lighting.

---

### 9. Physics

**Description:** Gentle bounce with rising particle sparkles.

**Algorithm:**
```
bounce = sin(time * 2) * 3
offset_y = base_offset_y + bounce

spawn 1/3 chance particles from bottom:
    vx = random(-0.5 .. 0.5)
    vy = random(-2.0 .. -0.5)
    life = random(1.0 .. 2.5)
    char = '.', color = light blue

for each particle:
    vy += 0.5 * dt  (gravity)
    fade = life / max_life
    color = (200*fade, 240*fade, 255)

cow color = pulse between (80,120,200) and (110,160,255)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `bounce_amplitude` | f32 | 3.0 | Vertical bounce height |
| `bounce_speed` | f32 | 2.0 | Bounce oscillation speed |
| `gravity` | f32 | 0.5 | Particle downward acceleration |
| `max_particles` | u32 | 200 | Particle pool capacity |

**Visual:** Cow gently bobs up and down while soft blue sparkles float upward and fade.

---

## NEW EFFECTS (to be implemented)

---

### 10. Static

**Description:** CRT television static noise — random characters rapidly flicker across the cow's shape.

**Algorithm:**
```
for each non-space character at (x, y):
    if random(30% chance):
        ch = random printable ASCII char
        brightness = random(100..255)
        color = (brightness, brightness, brightness)
    else:
        ch = original character
        color = (180, 180, 180)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `noise_ratio` | f32 | 0.3 | Probability of character replacement |
| `scanline` | bool | false | Add horizontal scanline darkening |

**Visual:** Cow shape filled with rapidly changing random characters, like an old TV between channels. occasional static bursts.

---

### 11. Breathing

**Description:** Gentle vertical scale pulsation — the cow appears to breathe in and out.

**Algorithm:**
```
breath_scale = 1.0 + sin(time * 1.5) * 0.05

for each row y of the cow:
    scaled_y = round((y - center_y) * breath_scale + center_y)
    render character at (x, scaled_y) instead of (x, y)

color = warm white with subtle brightness pulse:
    brightness = 220 + sin(time * 1.5) * 35
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 1.5 | Breathing oscillation speed |
| `amplitude` | f32 | 0.05 | Scale variation (5% = subtle) |
| `color_pulse` | bool | true | Brightness oscillates with breath |

**Visual:** Cow very subtly expands and contracts vertically, like a sleeping animal breathing. Warm, calming effect.

---

### 12. Liquid

**Description:** Horizontal sine wave ripple — the cow's columns shift left/right creating a water surface effect.

**Algorithm:**
```
for each non-space character at (x, y):
    offset_x = round(sin(y * 0.3 + time * 2.0) * 3.0)
    render at (x + offset_x, y)

color = blue-white gradient:
    hue = 200 + sin(y * 0.2 + time) * 20
    saturation = 0.3
    brightness = 0.9 + sin(x * 0.1 + time) * 0.1
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 2.0 | Wave propagation speed |
| `amplitude` | f32 | 3.0 | Max horizontal displacement (chars) |
| `frequency` | f32 | 0.3 | Wave frequency per row |

**Visual:** Cow appears to be underwater, with each row swaying left and right in a smooth sine pattern. Cool blue tones.

---

### 13. Sway

**Description:** The entire cow body gently sways side to side as one unit, like a tree in wind.

**Algorithm:**
```
sway_offset = round(sin(time * 1.2) * 4.0)

for each non-space character at (x, y):
    render at (x + sway_offset, y)

color = warm green-tint:
    hue = 90 + sin(time) * 30
    saturation = 0.2
    brightness = 0.95
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 1.2 | Sway oscillation speed |
| `amplitude` | f32 | 4.0 | Max horizontal displacement |

**Visual:** Cow rocks left and right as a solid unit, like a pendulum or wind-blown tree. Gentle, organic motion.

---

### 14. Bounce

**Description:** Cow drops from above with gravity, squishes on impact, then springs back up.

**Algorithm:**
```
phase = time % 4.0

if phase < 2.0:  (falling)
    t = phase / 2.0
    offset_y = start_y + (floor_height * t²)
else:  (bouncing up)
    t = (phase - 2.0) / 2.0
    offset_y = floor_height - (floor_height * (1-t)²)

if near floor:
    squash_x = 1.0 + 0.3 * (1 - dist_to_floor)
    squash_y = 1.0 - 0.2 * (1 - dist_to_floor)

render with horizontal/vertical scaling around center
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `gravity` | f32 | 9.8 | Downward acceleration |
| `bounce_height` | f32 | 10.0 | Max bounce height in rows |
| `squash_factor` | f32 | 0.3 | Max horizontal squash on impact |

**Visual:** Cow falls with increasing speed, compresses when hitting the bottom, then springs back up. Cartoon physics.

---

### 15. Flying

**Description:** Cow follows a Lissajous figure-8 path, creating an organic hovering/flying motion.

**Algorithm:**
```
offset_x = round(sin(time * 1.0) * 8.0)
offset_y = round(cos(time * 2.0) * 3.0)

for each non-space character at (x, y):
    render at (x + offset_x, y + offset_y)

color = sky blue with brightness variation:
    brightness = 0.9 + sin(time * 3) * 0.1
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 1.0 | Path traversal speed |
| `x_amplitude` | f32 | 8.0 | Horizontal figure-8 width |
| `y_amplitude` | f32 | 3.0 | Vertical figure-8 height |
| `x_frequency` | f32 | 1.0 | Horizontal oscillation rate |
| `y_frequency` | f32 | 2.0 | Vertical oscillation rate (2:1 for figure-8) |

**Visual:** Cow traces a smooth figure-8 pattern in the air. Organic, bird-like hovering motion.

---

### 16. Fire

**Description:** Bottom-up cellular automata burn — cow chars convert to fire particles rising upward.

**Algorithm:**
```
for each row from bottom to top:
    for each column:
        if char is fire particle (*, ^, ., ~):
            if random(20%): spawn new particle above
            if random(10%): this particle dies
            move upward by 1 row
        else if below a fire particle and random(5%):
            convert to fire particle '*'

fire particle color based on height from bottom:
    bottom: bright yellow (255, 255, 100)
    middle: orange (255, 150, 0)
    top: dark red (150, 0, 0)
    very top: smoke gray (80, 80, 80)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `spread_chance` | f32 | 0.05 | Probability of fire spreading upward |
| `die_chance` | f32 | 0.10 | Probability of particle dying |
| `speed` | f32 | 1.0 | Cellular automata step speed |

**Visual:** Cow appears to catch fire from the bottom, with characters converting to rising fire symbols. Realistic fire gradient from yellow to red to smoke.

---

### 17. Matrix

**Description:** Cyberpunk digital rain — random characters inside the cow decrypt and cycle rapidly.

**Algorithm:**
```
for each non-space character at (x, y):
    if random(15%):
        ch = random printable char
        color = bright green (0, 255, 70)
    elif random(10%):
        ch = random digit/symbol
        color = dim green (0, 150, 30)
    else:
        ch = original character
        color = dark green (0, 80, 20)

occasionally: drop a "head" character that's brighter white
    if column has active head:
        head_y += 1
        head color = (200, 255, 200)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `replace_ratio` | f32 | 0.15 | Character replacement probability |
| `head_speed` | f32 | 5.0 | Bright head character fall speed |
| `color_palette` | str | "green" | Color scheme: "green", "blue", "amber" |

**Visual:** Inside the cow's shape, characters rapidly flicker between random symbols, creating a digital decryption effect. Green-tinted cyberpunk aesthetic.

---

### 18. Pulse

**Description:** Rhythmic brightness pulsation — the cow's entire body brightens and dims in a heartbeat pattern.

**Algorithm:**
```
pulse = pow(sin(time * 2.0), 2)  ← sharp heartbeat peaks
brightness = 80 + pulse * 175  ← range 80..255

for each non-space character at (x, y):
    hue = 280 + sin(x * 0.1 + time) * 40  ← purple tint
    saturation = 0.6 + pulse * 0.4
    color = hsv_to_rgb(hue, saturation, brightness / 255.0)
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `speed` | f32 | 2.0 | Pulse oscillation speed |
| `min_brightness` | f32 | 0.31 | Minimum brightness (80/255) |
| `max_brightness` | f32 | 1.0 | Maximum brightness (255/255) |
| `hue_base` | f32 | 280.0 | Base hue (280 = purple) |

**Visual:** Cow pulses with a rhythmic heartbeat pattern, brightening and dimming. Purple-magenta tint with warm highlights at peak brightness.

---

### 19. Dissolve

**Description:** Each character gets individual random velocity and flies off in its own direction.

**Algorithm:**
```
on init:
    for each non-space character at (x, y):
        vx = random(-10.0 .. 10.0)
        vy = random(-8.0 .. 8.0)
        life = random(2.0 .. 4.0)

for each frame:
    for each active particle:
        life -= dt
        x += vx * dt
        y += vy * dt
        vx *= 0.98  (drag)
        vy *= 0.98
        fade = life / max_life
        color = original_color * fade
```

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `max_velocity` | f32 | 10.0 | Max initial velocity per axis |
| `drag` | f32 | 0.98 | Velocity decay per frame |
| `max_particles` | u32 | 5000 | Particle pool capacity |

**Visual:** Cow disintegrates with each character flying off in a random direction, slowing down and fading. Like the cow is being teleported away atom by atom.

---

## Effect Registry

| # | Name | Type | Particles | Loop |
|---|------|------|-----------|------|
| 1 | Aurora | Color | No | Infinite |
| 2 | Ember | Particle | Yes (Fire) | Infinite |
| 3 | Shatter | Particle | Yes (Explosion) | One-shot |
| 4 | Plasma | Color | No | Infinite |
| 5 | LiquidChrome | Color | No | Infinite |
| 6 | Portal | Color | No | Infinite |
| 7 | Glitch | Color | No | Infinite |
| 8 | NeonPulse | Color+Glow | No | Infinite |
| 9 | Physics | Motion+Particle | Yes (Sparkles) | Infinite |
| 10 | Static | Noise | No | Infinite |
| 11 | Breathing | Motion | No | Infinite |
| 12 | Liquid | Motion | No | Infinite |
| 13 | Sway | Motion | No | Infinite |
| 14 | Bounce | Motion | No | Infinite |
| 15 | Flying | Motion | No | Infinite |
| 16 | Fire | Cellular | Yes (Fire) | Infinite |
| 17 | Matrix | Noise+Color | No | Infinite |
| 18 | Pulse | Color | No | Infinite |
| 19 | Dissolve | Particle | Yes (Explosion) | One-shot |
