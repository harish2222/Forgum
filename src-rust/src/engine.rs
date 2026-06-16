use std::cmp::max;

#[derive(Debug, PartialEq, Eq)]
pub struct Diff {
    pub x: u16,
    pub y: u16,
    pub ch: char,
}

#[derive(Clone)]
pub struct FrameBuffer {
    pub width: u16,
    pub height: u16,
    pub buffer: Vec<Vec<char>>,
}

impl FrameBuffer {
    pub fn new(width: u16, height: u16) -> Self {
        let width = width.min(900);
        let height = height.min(900);
        Self {
            width,
            height,
            buffer: vec![vec![' '; width as usize]; height as usize],
        }
    }

    pub fn set_char(&mut self, x: u16, y: u16, ch: char) {
        if x < self.width && y < self.height {
            self.buffer[y as usize][x as usize] = ch;
        }
    }

    pub fn get_char(&self, x: u16, y: u16) -> char {
        if x < self.width && y < self.height {
            self.buffer[y as usize][x as usize]
        } else {
            ' '
        }
    }

    pub fn write_str(&mut self, x: u16, y: u16, s: &str) {
        let mut cx = x;
        let mut cy = y;
        for ch in s.chars() {
            if ch == '\n' {
                cx = x;
                cy += 1;
            } else {
                self.set_char(cx, cy, ch);
                cx += 1;
            }
        }
    }

    pub fn diff(&self, previous: &FrameBuffer) -> Vec<Diff> {
        let mut diffs = Vec::new();
        let max_y = max(self.height, previous.height);
        let max_x = max(self.width, previous.width);

        for y in 0..max_y {
            for x in 0..max_x {
                let curr_ch = self.get_char(x, y);
                let prev_ch = previous.get_char(x, y);
                if curr_ch != prev_ch {
                    diffs.push(Diff { x, y, ch: curr_ch });
                }
            }
        }
        diffs
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_diff_identical_frames() {
        let mut f1 = FrameBuffer::new(10, 10);
        f1.write_str(2, 2, "hello");
        let mut f2 = FrameBuffer::new(10, 10);
        f2.write_str(2, 2, "hello");
        
        let diffs = f2.diff(&f1);
        assert!(diffs.is_empty());
    }

    #[test]
    fn test_diff_empty_against_text() {
        let empty = FrameBuffer::new(10, 10);
        let mut text = FrameBuffer::new(10, 10);
        text.write_str(0, 0, "hi");

        let diffs = text.diff(&empty);
        assert_eq!(diffs.len(), 2);
        assert_eq!(diffs[0], Diff { x: 0, y: 0, ch: 'h' });
        assert_eq!(diffs[1], Diff { x: 1, y: 0, ch: 'i' });
    }

    #[test]
    fn test_diff_overlapping_different_text() {
        let mut f1 = FrameBuffer::new(10, 10);
        f1.write_str(0, 0, "hello");
        let mut f2 = FrameBuffer::new(10, 10);
        f2.write_str(0, 0, "hallo");

        let diffs = f2.diff(&f1);
        assert_eq!(diffs.len(), 1);
        assert_eq!(diffs[0], Diff { x: 1, y: 0, ch: 'a' });
    }

    #[test]
    fn test_bounds_checking() {
        let mut fb = FrameBuffer::new(10, 10);
        // Write outside bounds
        fb.set_char(20, 20, 'x');
        // No panic means success. The internal buffer should remain untouched.
        assert_eq!(fb.get_char(20, 20), ' ');

        let max_fb = FrameBuffer::new(1000, 1000);
        assert_eq!(max_fb.width, 900);
        assert_eq!(max_fb.height, 900);
    }
}