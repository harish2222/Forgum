use crossterm::terminal;

pub struct Size {
    pub width: u16,
    pub height: u16,
}

pub struct Engine {
    width: u16,
    height: u16,
}

impl Engine {
    pub fn new() -> Self {
        let (w, h) = terminal::size().unwrap_or((80, 24));
        Engine { width: w, height: h }
    }

    pub fn calculate_bounds(&self, terminal_width_px: u16, terminal_height_px: u16) -> Size {
        Size {
            width: terminal_width_px.min(900),
            height: terminal_height_px.min(900),
        }
    }

    pub fn scale_asset(&self, original: &str) -> String {
        // Placeholder for the 900x900px math restriction logic
        // For now, return original
        original.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_scaling_hard_limits() {
        let engine = Engine::new();
        // Simulate a massive 4K terminal window
        let scaled = engine.calculate_bounds(3840, 2160);
        assert!(scaled.width <= 900, "Width exceeded 900px limit");
        assert!(scaled.height <= 900, "Height exceeded 900px limit");
    }

    #[test]
    fn test_scaling_small_terminals() {
        let engine = Engine::new();
        // Simulate a tiny 80x24 char terminal (~640x384px)
        let scaled = engine.calculate_bounds(640, 384);
        assert!(scaled.width <= 640, "Width should scale down to terminal size");
        assert!(scaled.height <= 384, "Height should scale down to terminal size");
    }
}
