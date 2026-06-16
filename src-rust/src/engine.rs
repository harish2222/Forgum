use crossterm::terminal;

pub struct Engine {
    width: u16,
    height: u16,
}

impl Engine {
    pub fn new() -> Self {
        let (w, h) = terminal::size().unwrap_or((80, 24));
        Engine { width: w, height: h }
    }

    pub fn scale_asset(&self, original: &str) -> String {
        // Placeholder for the 900x900px math restriction logic
        // For now, return original
        original.to_string()
    }
}
