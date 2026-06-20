use std::io::Write;
use crossterm::{cursor, style, queue};
use crate::region::Rect;

#[derive(Clone, Copy, PartialEq)]
pub struct Cell {
    pub ch: char,
    pub fg: (u8, u8, u8),
    pub bg: (u8, u8, u8),
    pub alpha: f32,
    pub dirty: bool,
}

impl Cell {
    pub fn empty() -> Self {
        Cell {
            ch: ' ',
            fg: (0, 0, 0),
            bg: (0, 0, 0),
            alpha: 0.0,
            dirty: false,
        }
    }

    pub fn new(ch: char, fg: (u8, u8, u8), bg: (u8, u8, u8)) -> Self {
        Cell { ch, fg, bg, alpha: 1.0, dirty: true }
    }
}

pub struct FrameBuffer {
    pub width: usize,
    pub height: usize,
    pub back: Vec<Cell>,
    front: Vec<Cell>,
    damage_count: usize,
}

impl FrameBuffer {
    pub fn new(width: usize, height: usize) -> Self {
        let size = width * height;
        FrameBuffer {
            width,
            height,
            back: vec![Cell::empty(); size],
            front: vec![Cell::empty(); size],
            damage_count: 0,
        }
    }

    pub fn resize(&mut self, new_width: usize, new_height: usize) {
        let new_size = new_width * new_height;
        self.width = new_width;
        self.height = new_height;
        self.back = vec![Cell::empty(); new_size];
        self.front = vec![Cell::empty(); new_size];
        self.damage_count = 0;
    }

    pub fn clear(&mut self) {
        for cell in self.back.iter_mut() {
            *cell = Cell::empty();
        }
        self.damage_count = 0;
    }

    pub fn set_cell(&mut self, x: usize, y: usize, cell: Cell) {
        if x < self.width && y < self.height {
            let idx = y * self.width + x;
            self.back[idx] = cell;
        }
    }

    pub fn get_cell(&self, x: usize, y: usize) -> Cell {
        if x < self.width && y < self.height {
            self.back[y * self.width + x]
        } else {
            Cell::empty()
        }
    }

    pub fn set_cell_in_region(&mut self, x: usize, y: usize, cell: Cell, clip: Rect) {
        let cx = x as u16;
        let cy = y as u16;
        if clip.contains(cx, cy) {
            self.set_cell(x, y, cell);
        }
    }

    pub fn mark_all_dirty(&mut self) {
        for cell in self.back.iter_mut() {
            cell.dirty = true;
        }
    }

    pub fn is_dirty(&self) -> bool {
        self.damage_count > 0
    }

    pub fn compute_damage(&mut self) {
        self.damage_count = 0;
        for i in 0..self.back.len().min(self.front.len()) {
            if self.back[i] != self.front[i] {
                self.back[i].dirty = true;
                self.damage_count += 1;
            } else {
                self.back[i].dirty = false;
            }
        }
    }

    pub fn damage_count(&self) -> usize {
        self.damage_count
    }

    pub fn render_region<W: Write>(
        &mut self,
        out: &mut W,
        clip: Rect,
    ) -> std::io::Result<usize> {
        let mut written = 0;
        let mut last_fg: Option<(u8, u8, u8)> = None;
        let mut last_bg: Option<(u8, u8, u8)> = None;

        let x0 = clip.x0 as usize;
        let y0 = clip.y0 as usize;
        let x1 = (clip.x1 as usize).min(self.width);
        let y1 = (clip.y1 as usize).min(self.height);

        for y in y0..y1 {
            for x in x0..x1 {
                let idx = y * self.width + x;
                let back_cell = self.back[idx];

                if back_cell != self.front[idx] {
                    queue!(out, cursor::MoveTo(x as u16, y as u16))?;

                    let fg = back_cell.fg;
                    if last_fg != Some(fg) {
                        queue!(
                            out,
                            style::SetForegroundColor(style::Color::Rgb { r: fg.0, g: fg.1, b: fg.2 })
                        )?;
                        last_fg = Some(fg);
                    }

                    let bg = back_cell.bg;
                    if last_bg != Some(bg) {
                        queue!(
                            out,
                            style::SetBackgroundColor(style::Color::Rgb { r: bg.0, g: bg.1, b: bg.2 })
                        )?;
                        last_bg = Some(bg);
                    }

                    queue!(out, style::Print(back_cell.ch))?;
                    self.front[idx] = back_cell;
                    self.front[idx].dirty = false;
                    self.back[idx].dirty = false;
                    written += 1;
                }
            }
        }
        Ok(written)
    }

    pub fn render_full<W: Write>(&mut self, out: &mut W) -> std::io::Result<usize> {
        let clip = Rect::new(0, 0, self.width as u16, self.height as u16);
        self.render_region(out, clip)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cell_new_is_dirty() {
        let c = Cell::new('x', (255, 255, 255), (0, 0, 0));
        assert!(c.dirty);
    }

    #[test]
    fn test_set_and_get_cell() {
        let mut fb = FrameBuffer::new(10, 10);
        fb.set_cell(3, 5, Cell::new('A', (255, 0, 0), (0, 0, 0)));
        assert_eq!(fb.get_cell(3, 5).ch, 'A');
        assert_eq!(fb.get_cell(3, 5).fg, (255, 0, 0));
    }

    #[test]
    fn test_bounds_check() {
        let mut fb = FrameBuffer::new(5, 5);
        fb.set_cell(4, 4, Cell::new('Z', (0, 0, 0), (0, 0, 0)));
        assert_eq!(fb.get_cell(4, 4).ch, 'Z');

        fb.set_cell(5, 5, Cell::new('!', (0, 0, 0), (0, 0, 0)));
        assert_eq!(fb.get_cell(5, 5).ch, ' ');
    }

    #[test]
    fn test_compute_damage() {
        let mut fb = FrameBuffer::new(5, 1);
        fb.set_cell(0, 0, Cell::new('H', (255, 255, 255), (0, 0, 0)));
        fb.set_cell(1, 0, Cell::new('i', (255, 255, 255), (0, 0, 0)));
        fb.compute_damage();
        assert!(fb.is_dirty());

        let clip = Rect::new(0, 0, 5, 1);
        let mut out = Vec::new();
        let written = fb.render_region(&mut out, clip).unwrap();
        assert_eq!(written, 2);

        fb.compute_damage();
        assert!(!fb.is_dirty());
    }

    #[test]
    fn test_resize_clears() {
        let mut fb = FrameBuffer::new(10, 10);
        fb.set_cell(5, 5, Cell::new('X', (1, 1, 1), (0, 0, 0)));
        fb.resize(5, 5);
        assert_eq!(fb.width, 5);
        assert_eq!(fb.height, 5);
        assert_eq!(fb.get_cell(5, 5).ch, ' ');
    }

    #[test]
    fn test_region_clip() {
        let mut fb = FrameBuffer::new(10, 10);
        let clip = Rect::new(0, 0, 5, 5);
        fb.set_cell_in_region(3, 3, Cell::new('A', (1, 1, 1), (0, 0, 0)), clip);
        assert_eq!(fb.get_cell(3, 3).ch, 'A');

        fb.set_cell_in_region(7, 7, Cell::new('B', (1, 1, 1), (0, 0, 0)), clip);
        assert_eq!(fb.get_cell(7, 7).ch, ' ');
    }
}
