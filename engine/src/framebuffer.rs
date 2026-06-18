use std::io::Write;
use crossterm::{cursor, style, queue};

#[derive(Clone, Copy, PartialEq)]
pub struct Cell {
    pub ch: char,
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub alpha: f32,
}

impl Cell {
    pub fn empty() -> Self {
        Cell { ch: ' ', r: 0, g: 0, b: 0, alpha: 0.0 }
    }
}

pub struct FrameBuffer {
    pub width: usize,
    pub height: usize,
    pub front: Vec<Cell>,
    pub back: Vec<Cell>,
}

impl FrameBuffer {
    pub fn new(width: usize, height: usize) -> Self {
        let size = width * height;
        FrameBuffer {
            width,
            height,
            front: vec![Cell::empty(); size],
            back: vec![Cell::empty(); size],
        }
    }

    pub fn clear(&mut self) {
        for cell in self.back.iter_mut() {
            *cell = Cell::empty();
        }
    }

    pub fn set_cell(&mut self, x: usize, y: usize, cell: Cell) {
        if x < self.width && y < self.height {
            self.back[y * self.width + x] = cell;
        }
    }
    
    #[allow(dead_code)]
    pub fn get_cell_mut(&mut self, x: usize, y: usize) -> Option<&mut Cell> {
        if x < self.width && y < self.height {
            Some(&mut self.back[y * self.width + x])
        } else {
            None
        }
    }

    pub fn render<W: Write>(&mut self, out: &mut W) -> std::io::Result<()> {
        let mut last_fg = None;
        for y in 0..self.height {
            for x in 0..self.width {
                let idx = y * self.width + x;
                let back_cell = self.back[idx];
                
                if back_cell != self.front[idx] {
                    queue!(out, cursor::MoveTo(x as u16, y as u16))?;
                    
                    let fg = (back_cell.r, back_cell.g, back_cell.b);
                    if last_fg != Some(fg) {
                        queue!(out, style::SetForegroundColor(style::Color::Rgb { r: fg.0, g: fg.1, b: fg.2 }))?;
                        last_fg = Some(fg);
                    }
                    
                    queue!(out, style::Print(back_cell.ch))?;
                    self.front[idx] = back_cell;
                }
            }
        }
        out.flush()
    }
}
