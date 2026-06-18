# The Forgum Cow Animation Manifesto

Instead of applying a blanket visual filter over the terminal, this manifesto outlines a character-driven animation approach. Each of the 106 cow files in Forgum has unique physical traits (wings, fins, faces, machinery). 

To ensure every cow feels alive and unique, we will build **10 Base Dynamic Animation Engines**, and then assign specific, parameterized combinations of these engines to each individual cow.

---

## Part 1: The 10 Base Dynamic Animation Types

1. **Breathe (Morphology):** Expands and contracts specific whitespace gaps in the ASCII art to simulate breathing chests or expanding bellies.
2. **Float / Bob (Kinematics):** Gently shifts the entire ASCII art block up and down or left and right over time. 
3. **Walk / Trot (Kinematics):** Identifies the bottom-most characters (legs/feet) and swaps them (e.g., `|` to `/` to `\`) to simulate walking.
4. **Environment Particles (Particle System):** Spawns contextual particles around the art (e.g., bubbles for fish, smoke for fire, Zzz for sleeping).
5. **Pulse / Glow (Color/Shader):** Cycles colors dynamically. Can be a full rainbow sweep, or localized glowing (e.g., pulsing red eyes).
6. **Glitch / Cyber (Shader):** Rapidly swaps random ASCII characters with binary or hex symbols, creating a "hacked" or unstable entity effect.
7. **Fly / Hover (Kinematics):** A faster, more erratic version of Float, often combined with "Flap" (swapping wing characters like `>` and `<`).
8. **Talk / Chew (Morphology):** Specifically targets the mouth and eye regions (`$eyes`, `$tongue`) to animate them randomly or in sync with the message text.
9. **Sway / Pendulum (Kinematics):** Skews the top half of the ASCII art left and right while the bottom remains anchored (like trees or tall animals).
10. **Dissolve (Transition):** Slowly breaks the ASCII art apart into falling characters, or reassembles them from dust.

---

## Part 2: Unique Assignments for Every Cow (106 Files)

*If cows share identical physical structures (e.g., `cat` and `cat2`), they share the base animation but have unique parameter tweaks (e.g., different particle types or speeds).*

### Bovines & Farm Animals (The Chewers & Walkers)
**Core Animation:** Breathe + Walk + Talk/Chew
*   `default.cow`, `cower.cow`, `fat-cow.cow`: *Classic Chew* (Breathe + Talk/Chew).
*   `supermilker.cow`: *Fast Chew* (Same as default, but 2x speed + Pulse Glow on udders).
*   `moose.cow`, `mule.cow`: *Trot* (Walk animation + Swaying antlers/ears).
*   `sheep.cow`, `flaming-sheep.cow`: *Breathe*. Flaming sheep gets *Environment Particles (Fire/Smoke)*.
*   `lamb.cow`, `lamb2.cow`: *Fast Trot* (Jumpy Walk animation).
*   `goat.cow`, `goat2.cow`: *Sway* (Headbutting motion).
*   `pig.cow` (if added): *Fast Breathe* (Snorting).

### Aquatic Creatures (The Floaters & Bubblers)
**Core Animation:** Float + Environment Particles (Bubbles)
*   `dolphin.cow`, `whale.cow`, `happy-whale.cow`: *Deep Float* (Slow up/down bobbing + heavy Bubbles).
*   `octopus.cow`, `smiling-octopus.cow`: *Tentacle Sway* (Sway + Float).
*   `jellyfish.cow`: *Pulse Float* (Float + Glowing cyan/magenta colors).
*   `seahorse.cow`, `seahorse-big.cow`: *Fast Bob* (Quick vertical movements + Bubbles).
*   `lobster.cow`: *Claw Snap* (Mouth/Claw Morphing + Walk).

### Birds & Avians (The Flyers)
**Core Animation:** Fly/Hover + Flap
*   `duck.cow`, `turkey.cow`: *Wobble Walk* (Side-to-side Sway + Walk).
*   `owl.cow`: *Stare* (Static body + Jiggle/Glitch on the eyes + Talk).
*   `golden-eagle.cow`: *Hover* (Slow Fly + Flap wings).
*   `tweety-bird.cow`: *Hyper Fly* (Fast Fly + Fly path moves across terminal).
*   `pterodactyl.cow`: *Prehistoric Swoop* (Large diagonal Fly movements).

### Felines, Canines & Forest Critters (The Pouncers)
**Core Animation:** Walk + Breathe
*   `cat.cow`, `cat2.cow`, `kitty.cow`, `kitten.cow`, `meow.cow`: *Tail Flick* (Walk + Swaying tail characters).
*   `catfence.cow`: *Sway* (Only the tail and head sway while the fence is static).
*   `doge.cow`: *Much Glitch* (Glitch animation + Pulse colors "wow").
*   `fox.cow`: *Sneak* (Slow Walk + Breathe).
*   `bunny.cow`: *Hop* (Fast vertical Float + Walk).
*   `squirrel.cow`: *Jiggle* (Twitchy, fast movements).
*   `hedgehog.cow`: *Roll* (Dissolve/Reassemble rapidly to simulate rolling).
*   `koala.cow`, `luke-koala.cow`: *Sleep* (Breathe + Environment Particles: "Zzz").

### Sci-Fi, Fantasy & Monsters (The Mystical)
**Core Animation:** Glitch + Pulse + Fly
*   `dragon.cow`, `dragon-and-cow.cow`, `charizardvice.cow`: *Firebreather* (Breathe + Environment Particles: Fire/Smoke + Hover).
*   `ghost.cow`, `ghostbusters.cow`: *Spooky Float* (Float + Semi-transparent/Glitch effect).
*   `weeping-angel.cow`: *Statue* (Completely static until terminal resize, then it Glitches closer).
*   `alien.cow` / `cthulhu-mini.cow`: *Eldritch Pulse* (Pulse green/purple + Tentacle Sway).
*   `daemon.cow`, `satanic.cow`: *Hellfire* (Float + Environment Particles: Fire).
*   `minotaur.cow`: *Rage Breathe* (Heavy Breathe + Fast Walk).
*   `glados.cow`, `personality-sphere.cow`: *Cyber Glitch* (Glitch + Pulse single red/blue eye).
*   `kosh.cow`: *Enigmatic Glow* (Slow Pulse + Float).

### Pop Culture & Characters
*   `batman.cow`: *Swoop* (Fly diagonally).
*   `snoopy.cow`, `snoopyhouse.cow`: *Tail Flick* + *Breathe*.
*   `snoopysleep.cow`: *Breathe* + *Zzz Particles*.
*   `ren.cow`, `stimpy.cow`, `beavis.zen.cow`: *Jiggle* (Nervous/hyperactive twitching).
*   `nyan.cow`: *Rainbow Fly* (Fly + trailing Environment Particles: Stars/Rainbows).
*   `hellokitty.cow`: *Gentle Sway*.

### Objects, Insects & Misc
*   `bees.cow`: *Swarm* (Hyper Fly + Jiggle for all bee components).
*   `spidercow.cow`: *Creep* (Walk + Float downwards like hanging on a web).
*   `stegosaurus.cow`, `tortoise.cow`, `turtle.cow`: *Slow Walk* (Very low speed Walk).
*   `mona-lisa.cow`: *Haunted Stare* (Static, but Eyes Talk/Jiggle slightly).
*   `periodic-table.cow`, `world.cow`: *Pulse* (Colors shift across the grid).
*   `chess pieces` (`king`, `queen`, `knight`, `rook`, `pawn`): *Slide* (Move smoothly left to right without Walk animations).
*   `surgery.cow`, `mutilated.cow`: *Glitch* (Disturbing flicker/glitch effect).
*   `tux.cow`, `tux-big.cow`: *Wobble* (Penguin waddle via Sway).
*   `docker-whale.cow`: *Container Float* (Float + Bubbles).

---

## Implementation Strategy

To execute this without manually hardcoding 106 separate `if/else` scripts:
1. **Cow Metadata YAML/JSON:** Create a `animations.json` mapping file. Each cow gets a profile:
   `"dragon.cow": { "base": "Hover", "particles": "Fire", "breathe_speed": 1.5 }`
2. **The Physics Engine (`Invoke-PhysicsCow`):** A single PowerShell script reads the mapping, loads the requested modules (Hover, Fire, Breathe), and applies their mathematical transformations to the cow's character grid every frame.
