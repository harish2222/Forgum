use crate::framebuffer::{FrameBuffer, Cell};

pub struct Compositor;

impl Compositor {
    pub fn draw_text_layer(fb: &mut FrameBuffer, x: usize, y: usize, text: &str, r: u8, g: u8, b: u8) {
        let mut cur_x = x;
        let mut cur_y = y;
        
        for ch in text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = x;
            } else {
                if ch != ' ' {
                    fb.set_cell(cur_x, cur_y, Cell { ch, r, g, b, alpha: 1.0 });
                }
                cur_x += 1;
            }
        }
    }
}
