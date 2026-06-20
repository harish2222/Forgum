use crate::framebuffer::{FrameBuffer, Cell};
use crate::region::Rect;

#[allow(dead_code)]
pub struct Compositor;

impl Compositor {
    #[allow(dead_code)]
    pub fn draw_text_layer(fb: &mut FrameBuffer, x: usize, y: usize, text: &str, fg: (u8, u8, u8)) {
        let mut cur_x = x;
        let mut cur_y = y;

        for ch in text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = x;
            } else {
                if ch != ' ' {
                    fb.set_cell(cur_x, cur_y, Cell::new(ch, fg, (0, 0, 0)));
                }
                cur_x += 1;
            }
        }
    }

    #[allow(dead_code)]
    pub fn draw_text_clipped(fb: &mut FrameBuffer, x: usize, y: usize, text: &str, fg: (u8, u8, u8), clip: Rect) {
        let mut cur_x = x;
        let mut cur_y = y;

        for ch in text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = x;
            } else {
                if ch != ' ' {
                    fb.set_cell_in_region(cur_x, cur_y, Cell::new(ch, fg, (0, 0, 0)), clip);
                }
                cur_x += 1;
            }
        }
    }
}
