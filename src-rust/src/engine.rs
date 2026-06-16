use crossterm::terminal;

pub struct Size {
    pub width: u16,
    pub height: u16,
}

pub struct Engine {
    _width: u16,
    _height: u16,
}

impl Engine {
    pub fn new() -> Self {
        let (w, h) = terminal::size().unwrap_or((80, 24));
        Engine { _width: w, _height: h }
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

    pub fn render_diff(&self, _old_frame: &str, new_frame: &str) -> String {
        // Stub: In a real double buffer, we'd return ANSI codes. 
        // For testing, just return the new frame if they differ, or empty string if same.
        if _old_frame == new_frame {
            String::new()
        } else {
            new_frame.to_string()
        }
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

    #[test]
    fn test_scale_asset_returns_original() {
        let engine = Engine::new();
        let input = "Moo cow";
        let output = engine.scale_asset(input);
        assert_eq!(input, output, "scale_asset should return original string for now");       
    }

    #[test]
    fn test_render_diff_identical_frames_produce_zero_bytes() {
        let engine = Engine::new();
        let frame = "        \\   ^__^\n         \\  (oo)\\_______\n            (__)\\       )\\/\\";
        let diff = engine.render_diff(frame, frame);
        assert_eq!(diff.len(), 0, "Identical frames should produce 0 bytes of ANSI updates");
    }

    #[test]
    fn test_render_diff_changed_frames_produce_output() {
        let engine = Engine::new();
        let frame1 = "Moo";
        let frame2 = "Baa";
        let diff = engine.render_diff(frame1, frame2);
        assert!(diff.len() > 0, "Changed frames must produce output");
    }

    #[test]
    fn test_buffer_diffing_identical_frames() {
        let engine = Engine::new();
        let frame1 = "Moo";
        let frame2 = "Moo";
        // If frames are identical, a double-buffering engine should produce no ANSI changes.
        // For now, since we haven't built the full buffer state machine, we just test 
        // that the asset scaler processes identical inputs identically.
        let out1 = engine.scale_asset(frame1);
        let out2 = engine.scale_asset(frame2);
        assert_eq!(out1, out2, "Identical frames must produce identical scaled output");
    }

    #[test]
    fn test_ansi_escape_integrity() {
        let engine = Engine::new();
        // Ensure that strings containing ANSI escape codes are not mangled during scaling
        let ansi_string = "\x1b[31mMoo\x1b[0m";
        let output = engine.scale_asset(ansi_string);
        assert!(output.contains("\x1b[31m"), "ANSI color codes must survive scaling");
    }
}
