#[cfg(test)]
use std::env;

#[cfg(test)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Multiplexer {
    None,
    Tmux,
    Zellij,
    Screen,
    Wezterm,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TermSize {
    pub cols: u16,
    pub rows: u16,
}

#[derive(Debug, Clone, Copy)]
pub struct PromptRegion {
    pub y_start: u16,
}

pub struct Terminal {
    pub size: TermSize,
    raw_mode_enabled: bool,
}

impl Terminal {
    pub fn detect() -> Self {
        let size = crossterm::terminal::size()
            .map(|(c, r)| TermSize { cols: c, rows: r })
            .unwrap_or(TermSize { cols: 80, rows: 24 });

        Terminal {
            size,
            raw_mode_enabled: false,
        }
    }

    #[allow(dead_code)]
    pub fn refresh_size(&mut self) {
        if let Ok((c, r)) = crossterm::terminal::size() {
            self.size = TermSize { cols: c, rows: r };
        }
    }

    pub fn prompt_region(&self) -> PromptRegion {
        let prompt_y = self.size.rows.saturating_sub(3).max(1);
        PromptRegion {
            y_start: prompt_y,
        }
    }

    pub fn overlay_bounds(&self) -> (u16, u16, u16, u16) {
        let prompt = self.prompt_region();
        let y0 = 0u16;
        let y1 = prompt.y_start;
        (0, y0, self.size.cols, y1)
    }
}

impl Drop for Terminal {
    fn drop(&mut self) {
        if self.raw_mode_enabled {
            let _ = crossterm::terminal::disable_raw_mode();
        }
    }
}

#[cfg(test)]
fn detect_multiplexer() -> Multiplexer {
    if env::var("TMUX").is_ok() {
        return Multiplexer::Tmux;
    }
    if env::var("ZELLIJ").is_ok() {
        return Multiplexer::Zellij;
    }
    if env::var("STY").is_ok() {
        return Multiplexer::Screen;
    }
    if env::var("WEZTERM_PANE").is_ok() {
        return Multiplexer::Wezterm;
    }
    Multiplexer::None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_multiplexer_none_by_default() {
        let mux = detect_multiplexer();
        if env::var("TMUX").is_err()
            && env::var("ZELLIJ").is_err()
            && env::var("STY").is_err()
            && env::var("WEZTERM_PANE").is_err()
        {
            assert_eq!(mux, Multiplexer::None);
        }
    }

    #[test]
    fn test_overlay_bounds_respects_prompt() {
        let term = Terminal {
            size: TermSize { cols: 80, rows: 40 },
            raw_mode_enabled: false,
        };
        let (x0, y0, x1, y1) = term.overlay_bounds();
        assert_eq!(x0, 0);
        assert_eq!(y0, 0);
        assert_eq!(x1, 80);
        assert!(y1 <= term.size.rows);
        assert!(y1 > 0);
    }
}
