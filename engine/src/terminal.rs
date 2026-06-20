use std::env;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Multiplexer {
    None,
    Tmux,
    Zellij,
    Screen,
    Wezterm,
}

impl Multiplexer {
    #[allow(dead_code)]
    pub fn is_some(self) -> bool {
        self != Multiplexer::None
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TermSize {
    pub cols: u16,
    pub rows: u16,
}

#[derive(Debug, Clone, Copy)]
pub struct PromptRegion {
    pub y_start: u16,
    #[allow(dead_code)]
    pub y_end: u16,
    #[allow(dead_code)]
    pub is_interactive: bool,
}

pub struct Terminal {
    pub size: TermSize,
    #[allow(dead_code)]
    pub mux: Multiplexer,
    raw_mode_enabled: bool,
    #[allow(dead_code)]
    alternate_screen: bool,
}

impl Terminal {
    pub fn detect() -> Self {
        let mux = detect_multiplexer();
        let size = crossterm::terminal::size()
            .map(|(c, r)| TermSize { cols: c, rows: r })
            .unwrap_or(TermSize { cols: 80, rows: 24 });

        Terminal {
            size,
            mux,
            raw_mode_enabled: false,
            alternate_screen: false,
        }
    }

    pub fn refresh_size(&mut self) {
        if let Ok((c, r)) = crossterm::terminal::size() {
            self.size = TermSize { cols: c, rows: r };
        }
    }

    #[allow(dead_code)]
    pub fn enter_raw_mode(&mut self) -> std::io::Result<()> {
        if !self.raw_mode_enabled {
            crossterm::terminal::enable_raw_mode()?;
            self.raw_mode_enabled = true;
        }
        Ok(())
    }

    #[allow(dead_code)]
    pub fn leave_raw_mode(&mut self) -> std::io::Result<()> {
        if self.raw_mode_enabled {
            crossterm::terminal::disable_raw_mode()?;
            self.raw_mode_enabled = false;
        }
        Ok(())
    }

    #[allow(dead_code)]
    pub fn enter_alternate_screen(&mut self, out: &mut impl std::io::Write) -> std::io::Result<()> {
        if !self.alternate_screen && self.mux == Multiplexer::None {
            crossterm::execute!(out, crossterm::terminal::EnterAlternateScreen)?;
            self.alternate_screen = true;
        }
        Ok(())
    }

    #[allow(dead_code)]
    pub fn leave_alternate_screen(&mut self, out: &mut impl std::io::Write) -> std::io::Result<()> {
        if self.alternate_screen {
            crossterm::execute!(out, crossterm::terminal::LeaveAlternateScreen)?;
            self.alternate_screen = false;
        }
        Ok(())
    }

    pub fn prompt_region(&self) -> PromptRegion {
        let is_interactive = atty_is_tty();

        if !is_interactive {
            return PromptRegion {
                y_start: 0,
                y_end: self.size.rows,
                is_interactive: false,
            };
        }

        let prompt_y = self.size.rows.saturating_sub(3).max(1);
        PromptRegion {
            y_start: prompt_y,
            y_end: self.size.rows,
            is_interactive: true,
        }
    }

    pub fn overlay_bounds(&self) -> (u16, u16, u16, u16) {
        let prompt = self.prompt_region();
        let y0 = 0u16;
        let y1 = prompt.y_start;
        (0, y0, self.size.cols, y1)
    }

    #[allow(dead_code)]
    pub fn is_tty() -> bool {
        atty_is_tty()
    }
}

impl Drop for Terminal {
    fn drop(&mut self) {
        if self.raw_mode_enabled {
            let _ = crossterm::terminal::disable_raw_mode();
        }
    }
}

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

fn atty_is_tty() -> bool {
    #[cfg(unix)]
    {
        unsafe { libc::isatty(libc::STDIN_FILENO) != 0 && libc::isatty(libc::STDOUT_FILENO) != 0 }
    }
    #[cfg(not(unix))]
    {
        true
    }
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
            mux: Multiplexer::None,
            raw_mode_enabled: false,
            alternate_screen: false,
        };
        let (x0, y0, x1, y1) = term.overlay_bounds();
        assert_eq!(x0, 0);
        assert_eq!(y0, 0);
        assert_eq!(x1, 80);
        assert!(y1 <= term.size.rows);
        assert!(y1 > 0);
    }
}
