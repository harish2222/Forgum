#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Rgb {
    pub fn new(r: u8, g: u8, b: u8) -> Self {
        Rgb { r, g, b }
    }
}

pub fn hsv_to_rgb(h: f32, s: f32, v: f32) -> Rgb {
    let c = v * s;
    let x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
    let m = v - c;

    let (r_prime, g_prime, b_prime) = if h < 60.0 {
        (c, x, 0.0)
    } else if h < 120.0 {
        (x, c, 0.0)
    } else if h < 180.0 {
        (0.0, c, x)
    } else if h < 240.0 {
        (0.0, x, c)
    } else if h < 300.0 {
        (x, 0.0, c)
    } else {
        (c, 0.0, x)
    };

    Rgb::new(
        ((r_prime + m) * 255.0) as u8,
        ((g_prime + m) * 255.0) as u8,
        ((b_prime + m) * 255.0) as u8,
    )
}

// Blending functions mirroring CSS mix-blend-mode
#[allow(dead_code)]
pub fn blend_multiply(base: Rgb, blend: Rgb) -> Rgb {
    Rgb::new(
        ((base.r as f32 * blend.r as f32) / 255.0) as u8,
        ((base.g as f32 * blend.g as f32) / 255.0) as u8,
        ((base.b as f32 * blend.b as f32) / 255.0) as u8,
    )
}

pub fn blend_color_dodge(base: Rgb, blend: Rgb) -> Rgb {
    let dodge = |b: u8, l: u8| -> u8 {
        if l == 255 {
            255
        } else {
            let val = (b as f32 * 255.0) / (255.0 - l as f32);
            val.min(255.0) as u8
        }
    };
    Rgb::new(
        dodge(base.r, blend.r),
        dodge(base.g, blend.g),
        dodge(base.b, blend.b),
    )
}

// Apply a localized radial glow simulating a light source
pub fn apply_radial_glow(x: usize, y: usize, light_x: f32, light_y: f32, radius: f32, light_color: Rgb, base_color: Rgb) -> Rgb {
    let dx = x as f32 - light_x;
    let dy = (y as f32 - light_y) * 2.0; // Terminal characters are twice as tall as they are wide
    let distance = (dx * dx + dy * dy).sqrt();

    if distance < radius {
        let intensity = 1.0 - (distance / radius);
        // Linear fade for the intensity
        let glow_color = Rgb::new(
            (light_color.r as f32 * intensity) as u8,
            (light_color.g as f32 * intensity) as u8,
            (light_color.b as f32 * intensity) as u8,
        );
        blend_color_dodge(base_color, glow_color)
    } else {
        base_color
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hsv_to_rgb() {
        let red = hsv_to_rgb(0.0, 1.0, 1.0);
        assert_eq!(red.r, 255);
        assert_eq!(red.g, 0);
        assert_eq!(red.b, 0);

        let green = hsv_to_rgb(120.0, 1.0, 1.0);
        assert_eq!(green.r, 0);
        assert_eq!(green.g, 255);
        assert_eq!(green.b, 0);

        let blue = hsv_to_rgb(240.0, 1.0, 1.0);
        assert_eq!(blue.r, 0);
        assert_eq!(blue.g, 0);
        assert_eq!(blue.b, 255);
    }

    #[test]
    fn test_blend_dodge() {
        let base = Rgb { r: 100, g: 100, b: 100 };
        let blend = Rgb { r: 50, g: 50, b: 50 };
        let dodged = blend_color_dodge(base, blend);
        assert!(dodged.r > 100);
        assert!(dodged.g > 100);
        assert!(dodged.b > 100);
    }

    #[test]
    fn test_blend_multiply() {
        let base = Rgb { r: 255, g: 128, b: 0 };
        let blend = Rgb { r: 128, g: 255, b: 255 };
        let multiplied = blend_multiply(base, blend);
        
        assert_eq!(multiplied.r, 128);
        assert_eq!(multiplied.g, 128);
        assert_eq!(multiplied.b, 0);
    }
}
