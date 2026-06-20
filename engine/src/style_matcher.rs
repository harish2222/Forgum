#[allow(dead_code)]
pub struct CowStyle {
    pub base: &'static str,
    pub particles: Option<&'static str>,
    pub speed: f32,
}

pub fn get_cow_style(filename: &str) -> CowStyle {
    match filename {
        "default.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "cower.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "fat-cow.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "supermilker.cow" => CowStyle { base: "Talk", particles: None, speed: 2.0 },
        "moose.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "mule.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "sheep.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "flaming-sheep.cow" => CowStyle { base: "Breathe", particles: Some("Fire"), speed: 1.0 },
        "lamb.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.5 },
        "lamb2.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.5 },
        "goat.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "goat2.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "dolphin.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 0.5 },
        "whale.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 0.5 },
        "happy-whale.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 0.5 },
        "docker-whale.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 0.5 },
        "octopus.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "smiling-octopus.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "jellyfish.cow" => CowStyle { base: "Squish", particles: Some("Pulse"), speed: 1.0 },
        "seahorse.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 1.5 },
        "seahorse-big.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 1.5 },
        "lobster.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "turkey.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "owl.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.0 },
        "golden-eagle.cow" => CowStyle { base: "Fly", particles: None, speed: 0.8 },
        "tweety-bird.cow" => CowStyle { base: "Fly", particles: None, speed: 2.0 },
        "pterodactyl.cow" => CowStyle { base: "Fly", particles: None, speed: 1.5 },
        "cat.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "cat2.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "kitty.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "kitten.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "meow.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "catfence.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "doge.cow" => CowStyle { base: "Matrix", particles: Some("Pulse"), speed: 1.0 },
        "fox.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "bunny.cow" => CowStyle { base: "Squish", particles: None, speed: 2.0 },
        "squirrel.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.5 },
        "hedgehog.cow" => CowStyle { base: "Dissolve", particles: None, speed: 1.0 },
        "koala.cow" => CowStyle { base: "Breathe", particles: Some("Zzz"), speed: 1.0 },
        "luke-koala.cow" => CowStyle { base: "Breathe", particles: Some("Zzz"), speed: 1.0 },
        "dragon.cow" => CowStyle { base: "Fire", particles: Some("Fire"), speed: 1.0 },
        "dragon-and-cow.cow" => CowStyle { base: "Fly", particles: Some("Fire"), speed: 1.0 },
        "charizardvice.cow" => CowStyle { base: "Fly", particles: Some("Fire"), speed: 1.0 },
        "ghost.cow" => CowStyle { base: "Dissolve", particles: Some("Glitch"), speed: 1.0 },
        "ghostbusters.cow" => CowStyle { base: "Squish", particles: Some("Glitch"), speed: 1.0 },
        "weeping-angel.cow" => CowStyle { base: "Abduction", particles: None, speed: 1.0 },
        "alien.cow" => CowStyle { base: "Pulse", particles: None, speed: 1.0 },
        "cthulhu-mini.cow" => CowStyle { base: "Pulse", particles: None, speed: 1.0 },
        "daemon.cow" => CowStyle { base: "Squish", particles: Some("Fire"), speed: 1.0 },
        "satanic.cow" => CowStyle { base: "Squish", particles: Some("Fire"), speed: 1.0 },
        "minotaur.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.5 },
        "glados.cow" => CowStyle { base: "Matrix", particles: Some("Pulse"), speed: 1.0 },
        "personality-sphere.cow" => CowStyle { base: "Matrix", particles: Some("Pulse"), speed: 1.0 },
        "kosh.cow" => CowStyle { base: "Squish", particles: Some("Pulse"), speed: 0.5 },
        "batman.cow" => CowStyle { base: "Fly", particles: None, speed: 1.5 },
        "snoopy.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "snoopyhouse.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "snoopysleep.cow" => CowStyle { base: "Breathe", particles: Some("Zzz"), speed: 1.0 },
        "ren.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.5 },
        "stimpy.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.5 },
        "beavis.zen.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.5 },
        "nyan.cow" => CowStyle { base: "Fly", particles: Some("Stars"), speed: 2.0 },
        "hellokitty.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "bees.cow" => CowStyle { base: "Fly", particles: None, speed: 2.0 },
        "spidercow.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "stegosaurus.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.3 },
        "tortoise.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.3 },
        "turtle.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.3 },
        "mona-lisa.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "periodic-table.cow" => CowStyle { base: "Pulse", particles: None, speed: 1.0 },
        "world.cow" => CowStyle { base: "Pulse", particles: None, speed: 1.0 },
        "king.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "queen.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "knight.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "rook.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "pawn.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "surgery.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.0 },
        "mutilated.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.0 },
        "tux.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "tux-big.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "armadillo.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "atat.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "bearface.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "bill-the-cat.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.5 },
        "bud-frogs.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "charlie.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "claw-arm.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "cowfee.cow" => CowStyle { base: "Breathe", particles: Some("Fire"), speed: 1.0 },
        "ebi_furai.cow" => CowStyle { base: "Squish", particles: Some("Bubbles"), speed: 1.0 },
        "elephant-in-snake.cow" => CowStyle { base: "Breathe", particles: None, speed: 0.5 },
        "elephant.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "elephant2.cow" => CowStyle { base: "Liquid", particles: None, speed: 0.5 },
        "eyes.cow" => CowStyle { base: "Talk", particles: None, speed: 1.0 },
        "fat-banana.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "fence.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "hippie.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "hiya.cow" => CowStyle { base: "Sway", particles: None, speed: 1.0 },
        "hypno.cow" => CowStyle { base: "Pulse", particles: None, speed: 1.0 },
        "kiss.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "lollerskates.cow" => CowStyle { base: "Liquid", particles: None, speed: 2.0 },
        "moofasa.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "mooghidjirah.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "moojira.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "shikato.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "shrug.cow" => CowStyle { base: "Breathe", particles: None, speed: 1.0 },
        "skeleton.cow" => CowStyle { base: "Matrix", particles: None, speed: 1.0 },
        "small.cow" => CowStyle { base: "Liquid", particles: None, speed: 1.0 },
        "wizard.cow" => CowStyle { base: "Pulse", particles: Some("Stars"), speed: 1.0 },
        _ => CowStyle { base: "Talk", particles: None, speed: 1.0 },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_known_cow_default() {
        let style = get_cow_style("default.cow");
        assert_eq!(style.base, "Talk");
        assert!(style.particles.is_none());
        assert!((style.speed - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_known_cow_dragon() {
        let style = get_cow_style("dragon.cow");
        assert_eq!(style.base, "Fire");
        assert_eq!(style.particles, Some("Fire"));
    }

    #[test]
    fn test_known_cow_tux() {
        let style = get_cow_style("tux.cow");
        assert_eq!(style.base, "Sway");
        assert!(style.particles.is_none());
    }

    #[test]
    fn test_known_cow_dolphin() {
        let style = get_cow_style("dolphin.cow");
        assert_eq!(style.base, "Squish");
        assert_eq!(style.particles, Some("Bubbles"));
        assert!((style.speed - 0.5).abs() < 0.001);
    }

    #[test]
    fn test_known_cow_nyan() {
        let style = get_cow_style("nyan.cow");
        assert_eq!(style.base, "Fly");
        assert_eq!(style.particles, Some("Stars"));
        assert!((style.speed - 2.0).abs() < 0.001);
    }

    #[test]
    fn test_unknown_cow_defaults_to_talk() {
        let style = get_cow_style("nonexistent-xyz.cow");
        assert_eq!(style.base, "Talk");
        assert!(style.particles.is_none());
        assert!((style.speed - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_empty_string_defaults_to_talk() {
        let style = get_cow_style("");
        assert_eq!(style.base, "Talk");
    }

    #[test]
    fn test_speed_varies_by_cow() {
        let slow = get_cow_style("dolphin.cow");
        let fast = get_cow_style("nyan.cow");
        assert!(slow.speed < fast.speed);
    }

    #[test]
    fn test_all_styles_are_valid() {
        let valid_bases = ["Talk", "Liquid", "Breathe", "Sway", "Squish",
                          "Fly", "Fire", "Matrix", "Dissolve", "Pulse", "Abduction"];
        let cows = ["default.cow", "cat.cow", "sheep.cow", "goat.cow", "dolphin.cow",
                    "golden-eagle.cow", "dragon.cow", "owl.cow", "hedgehog.cow",
                    "alien.cow", "weeping-angel.cow"];
        for cow in cows {
            let style = get_cow_style(cow);
            assert!(valid_bases.contains(&style.base),
                "Cow '{}' has invalid base '{}'", cow, style.base);
        }
    }
}
