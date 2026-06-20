# Cow File Artistic Classification

**Date:** 2026-06-20
**Source:** `Data/Cows/animations.json` (110 cow files)

---

## Style Categories

Each cow file is classified into one of 9 artistic style categories. Each category maps to a **base animation effect** and optional **particle type**.

---

## Classification Table

### Cute / Fluffy
Soft, friendly animals with rounded features.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `bunny.cow` | Squish | — | 2.0 |
| `kitten.cow` | Liquid | — | 1.0 |
| `kitty.cow` | Liquid | — | 1.0 |
| `cat.cow` | Liquid | — | 1.0 |
| `cat2.cow` | Liquid | — | 1.0 |
| `meow.cow` | Liquid | — | 1.0 |
| `catfence.cow` | Sway | — | 1.0 |
| `lamb.cow` | Liquid | — | 1.5 |
| `lamb2.cow` | Liquid | — | 1.5 |
| `sheep.cow` | Breathe | — | 1.0 |
| `flaming-sheep.cow` | Breathe | Fire | 1.0 |
| `squirrel.cow` | Matrix | — | 1.5 |
| `hedgehog.cow` | Dissolve | — | 1.0 |
| `koala.cow` | Breathe | Zzz | 1.0 |
| `luke-koala.cow` | Breathe | Zzz | 1.0 |
| `snoopy.cow` | Breathe | — | 1.0 |
| `snoopyhouse.cow` | Breathe | — | 1.0 |
| `snoopysleep.cow` | Breathe | Zzz | 1.0 |
| `hellokitty.cow` | Sway | — | 1.0 |
| `doge.cow` | Matrix | Pulse | 1.0 |
| `fox.cow` | Liquid | — | 0.5 |

**Typical mapping:** Breathe/Liquid for soft motion, Zzz for sleeping variants, Sway for standing poses.

---

### Aquatic
Sea creatures and water-themed.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `dolphin.cow` | Squish | Bubbles | 0.5 |
| `whale.cow` | Squish | Bubbles | 0.5 |
| `happy-whale.cow` | Squish | Bubbles | 0.5 |
| `docker-whale.cow` | Squish | Bubbles | 0.5 |
| `seahorse.cow` | Squish | Bubbles | 1.5 |
| `seahorse-big.cow` | Squish | Bubbles | 1.5 |
| `jellyfish.cow` | Squish | Pulse | 1.0 |
| `octopus.cow` | Sway | — | 1.0 |
| `smiling-octopus.cow` | Sway | — | 1.0 |
| `lobster.cow` | Liquid | — | 1.0 |
| `turtle.cow` | Liquid | — | 0.3 |
| `tortoise.cow` | Liquid | — | 0.3 |
| `ebi_furai.cow` | Squish | Bubbles | 1.0 |

**Typical mapping:** Squish for buoyant swimming, Bubbles for underwater atmosphere, Sway for tentacle motion.

---

### Mechanical
Robots, machines, and technology.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `atat.cow` | Liquid | — | 0.5 |
| `glados.cow` | Matrix | Pulse | 1.0 |
| `personality-sphere.cow` | Matrix | Pulse | 1.0 |
| `claw-arm.cow` | Sway | — | 1.0 |
| `surgery.cow` | Matrix | — | 1.0 |
| `mutilated.cow` | Matrix | — | 1.0 |

**Typical mapping:** Matrix for digital/cybernetic, Liquid for mechanical motion, Sway for articulated limbs.

---

### Flying
Birds, bats, and aerial creatures.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `golden-eagle.cow` | Fly | — | 0.8 |
| `tweety-bird.cow` | Fly | — | 2.0 |
| `pterodactyl.cow` | Fly | — | 1.5 |
| `owl.cow` | Matrix | — | 1.0 |
| `batman.cow` | Fly | — | 1.5 |
| `nyan.cow` | Fly | Stars | 2.0 |
| `dragon.cow` | Fire | Fire | 1.0 |
| `dragon-and-cow.cow` | Fly | Fire | 1.0 |
| `charizardvice.cow` | Fly | Fire | 1.0 |
| `bees.cow` | Fly | — | 2.0 |
| `tweety-bird.cow` | Fly | — | 2.0 |

**Typical mapping:** Fly for hovering/figure-8 motion, Fire for fire-breathing variants, Stars for magical flight.

---

### Fire / Heat
Creatures associated with fire, demons, or heat.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `daemon.cow` | Squish | Fire | 1.0 |
| `satanic.cow` | Squish | Fire | 1.0 |
| `cowfee.cow` | Breathe | Fire | 1.0 |
| `ghostbusters.cow` | Squish | Glitch | 1.0 |

**Typical mapping:** Fire particles + Squish/Breathe for demonic breathing motion.

---

### Sturdy
Large, heavy, grounded animals.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `moose.cow` | Liquid | — | 1.0 |
| `mule.cow` | Liquid | — | 1.0 |
| `elephant.cow` | Liquid | — | 0.5 |
| `elephant2.cow` | Liquid | — | 0.5 |
| `elephant-in-snake.cow` | Breathe | — | 0.5 |
| `bearface.cow` | Breathe | — | 1.0 |
| `moofasa.cow` | Breathe | — | 1.0 |
| `armadillo.cow` | Liquid | — | 1.0 |
| `minotaur.cow` | Liquid | — | 1.5 |
| `king.cow` | Liquid | — | 0.5 |
| `queen.cow` | Liquid | — | 0.5 |
| `knight.cow` | Liquid | — | 0.5 |
| `rook.cow` | Liquid | — | 0.5 |
| `pawn.cow` | Liquid | — | 0.5 |
| `stegosaurus.cow` | Liquid | — | 0.3 |

**Typical mapping:** Liquid for slow, heavy movement. Breathe for resting state. Low speed values.

---

### Comic
Humorous, exaggerated, or pop-culture references.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `mona-lisa.cow` | Talk | — | 1.0 |
| `lollerskates.cow` | Liquid | — | 2.0 |
| `beavis.zen.cow` | Matrix | — | 1.5 |
| `ren.cow` | Matrix | — | 1.5 |
| `stimpy.cow` | Matrix | — | 1.5 |
| `bill-the-cat.cow` | Matrix | — | 1.5 |
| `bud-frogs.cow` | Talk | — | 1.0 |
| `eyes.cow` | Talk | — | 1.0 |
| `shrug.cow` | Breathe | — | 1.0 |
| `hiya.cow` | Sway | — | 1.0 |
| `kiss.cow` | Breathe | — | 1.0 |
| `hippie.cow` | Breathe | — | 1.0 |
| `charlie.cow` | Liquid | — | 1.0 |
| `fat-banana.cow` | Sway | — | 1.0 |
| `fence.cow` | Sway | — | 1.0 |

**Typical mapping:** Talk for speech-related, Matrix for absurd/digital, Sway for silly poses.

---

### Fragile
Thin, delicate, or transparent creatures.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `ghost.cow` | Dissolve | Glitch | 1.0 |
| `skeleton.cow` | Matrix | — | 1.0 |
| `spidercow.cow` | Liquid | — | 1.0 |
| `weeping-angel.cow` | Abduction | — | 1.0 |
| `hypno.cow` | Pulse | — | 1.0 |
| `periodic-table.cow` | Pulse | — | 1.0 |
| `world.cow` | Pulse | — | 1.0 |

**Typical mapping:** Dissolve for fading/ghostly, Pulse for ethereal pulsing, Matrix for skeletal/digital.

---

### Mystical
Magical, fantasy, or otherworldly.

| Cow File | Base Effect | Particles | Speed |
|----------|-------------|-----------|-------|
| `wizard.cow` | Pulse | Stars | 1.0 |
| `cthulhu-mini.cow` | Pulse | — | 1.0 |
| `alien.cow` | Pulse | — | 1.0 |
| `mooghidjirah.cow` | Breathe | — | 1.0 |
| `moojira.cow` | Breathe | — | 1.0 |
| `kosh.cow` | Squish | Pulse | 0.5 |
| `tux.cow` | Sway | — | 1.0 |
| `tux-big.cow` | Sway | — | 1.0 |

**Typical mapping:** Pulse for magical glow, Stars for spell effects, Breathe for mystical breathing.

---

## Summary: Category → Effect Mapping

| Category | Default Effect | Default Particles | Speed Range | Character |
|----------|---------------|-------------------|-------------|-----------|
| Cute/Fluffy | Breathe | Zzz (sleeping) | 1.0–2.0 | Soft, warm |
| Aquatic | Squish | Bubbles | 0.3–1.5 | Buoyant, flowing |
| Mechanical | Matrix | Pulse | 0.5–1.5 | Digital, precise |
| Flying | Fly | Stars/Fire | 0.8–2.0 | Dynamic, airborne |
| Fire/Heat | Squish | Fire | 1.0 | Intense, hot |
| Sturdy | Liquid | — | 0.3–1.5 | Heavy, slow |
| Comic | Talk/Matrix | — | 1.0–2.0 | Expressive, absurd |
| Fragile | Dissolve/Pulse | Glitch | 1.0 | Ethereal, fading |
| Mystical | Pulse | Stars | 0.5–1.0 | Magical, glowing |

---

## Unclassified Cows (default.cow pattern)

These cow files use the generic `Talk` base effect with no particles:

| Cow File | Notes |
|----------|-------|
| `default.cow` | Standard cowsay cow |
| `cower.cow` | Cowering variant |
| `fat-cow.cow` | Fat variant |
| `supermilker.cow` | Milking variant (speed 2.0) |

These are fallback cows that don't fit a specific artistic category.
