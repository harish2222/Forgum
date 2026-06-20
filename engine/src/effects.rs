use crate::framebuffer::{FrameBuffer, Cell};
use crate::particles::ParticlePool;
use crate::color::hsv_to_rgb;
use crate::region::Rect;
use rand::Rng;

pub trait Effect {
    fn update(&mut self, dt: f32);
    fn render(&self, fb: &mut FrameBuffer, clip: Rect);
    #[allow(dead_code)]
    fn bounds(&self, fb_width: usize, fb_height: usize) -> Rect;
    fn on_resize(&mut self, _new_width: usize, _new_height: usize) {}
    #[allow(dead_code)]
    fn cleanup(&mut self) {}
}

fn center_offset(text_lines: usize, text_width: usize, fb_w: usize, fb_h: usize) -> (usize, usize) {
    let ox = if fb_w > text_width { (fb_w - text_width) / 2 } else { 2 };
    let oy = if fb_h > text_lines { (fb_h - text_lines) / 2 } else { 2 };
    (ox.max(2), oy.max(2))
}

fn text_dims(text: &str) -> (usize, usize) {
    let lines: Vec<&str> = text.lines().collect();
    let height = lines.len();
    let width = lines.iter().map(|l| l.chars().count()).max().unwrap_or(0);
    (width, height)
}

// 1. Aurora
pub struct AuroraEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl AuroraEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        AuroraEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for AuroraEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 50.0; }
    fn bounds(&self, _fb_width: usize, _fb_height: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 1) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let h = (self.time + (cur_y as f32 * 10.0)) % 360.0;
                    let rgb = hsv_to_rgb(h, 0.8, 1.0);
                    let cell = Cell::new(ch, (rgb.r, rgb.g, rgb.b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 2. Ember
pub struct EmberEffect {
    cow_text: String,
    particles: ParticlePool,
    offset_x: usize,
    offset_y: usize,
    width: usize,
    height: usize,
}

impl EmberEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        EmberEffect { cow_text, particles: ParticlePool::new(1000), offset_x: ox, offset_y: oy, width: tw, height: th }
    }
}

impl Effect for EmberEffect {
    fn update(&mut self, dt: f32) {
        let mut rng = rand::thread_rng();
        for _ in 0..3 {
            let px = self.offset_x as f32 + rng.gen_range(0.0..self.width as f32);
            let py = self.offset_y as f32 + self.height as f32;
            let vx = rng.gen_range(-2.0..2.0);
            let vy = rng.gen_range(-15.0..-5.0);
            let life = rng.gen_range(1.0..3.0);
            self.particles.spawn(px, py, vx, vy, life, '^', 255, 100, 0);
        }
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                self.particles.life[i] -= dt;
                if self.particles.life[i] <= 0.0 { self.particles.active[i] = false; } else {
                    self.particles.x[i] += self.particles.vx[i] * dt;
                    self.particles.y[i] += self.particles.vy[i] * dt;
                    let life_pct = self.particles.life[i] / self.particles.max_life[i];
                    if life_pct > 0.6 {
                        self.particles.r[i] = 255; self.particles.g[i] = (255.0 * (life_pct - 0.6) / 0.4) as u8; self.particles.b[i] = 0; self.particles.ch[i] = '*';
                    } else if life_pct > 0.3 {
                        self.particles.r[i] = (255.0 * (life_pct - 0.3) / 0.3) as u8; self.particles.g[i] = 0; self.particles.b[i] = 0; self.particles.ch[i] = '^';
                    } else {
                        self.particles.r[i] = (100.0 * life_pct / 0.3) as u8; self.particles.g[i] = 0; self.particles.b[i] = 0; self.particles.ch[i] = '.';
                    }
                }
            }
        }
    }
    fn bounds(&self, fb_w: usize, fb_h: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.width + 1) as u16,
            (self.offset_y + self.height + 20) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.height, self.width, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let mut base_r: u8 = 60;
                    let mut base_g: u8 = 60;
                    let mut base_b: u8 = 60;

                    for i in 0..self.particles.active.len() {
                        if self.particles.active[i] {
                            let p_color = crate::color::Rgb::new(self.particles.r[i], self.particles.g[i], self.particles.b[i]);
                            let base_color = crate::color::Rgb::new(base_r, base_g, base_b);
                            let lit = crate::color::apply_radial_glow(
                                cur_x, cur_y,
                                self.particles.x[i], self.particles.y[i],
                                6.0, p_color, base_color
                            );
                            base_r = lit.r;
                            base_g = lit.g;
                            base_b = lit.b;
                        }
                    }

                    let cell = Cell::new(ch, (base_r, base_g, base_b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }

        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                let px = self.particles.x[i] as usize;
                let py = self.particles.y[i] as usize;
                let cell = Cell::new(self.particles.ch[i], (self.particles.r[i], self.particles.g[i], self.particles.b[i]), (0, 0, 0));
                fb.set_cell_in_region(px, py, cell, clip);
            }
        }
    }
}

// 3. Shatter
#[allow(dead_code)]
pub struct ShatterEffect {
    particles: ParticlePool,
    time: f32,
    active: bool,
    origin_x: usize,
    origin_y: usize,
}

impl ShatterEffect {
    pub fn new(cow_text: String) -> Self {
        let mut pool = ParticlePool::new(5000);
        let mut rng = rand::thread_rng();
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        let (mut cur_x, mut cur_y) = (ox, oy);
        for ch in cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = ox; } else {
                if ch != ' ' {
                    let vx = rng.gen_range(-20.0..20.0);
                    let vy = rng.gen_range(-15.0..10.0);
                    pool.spawn(cur_x as f32, cur_y as f32, vx, vy, rng.gen_range(2.0..5.0), ch, 255, 255, 255);
                }
                cur_x += 1;
            }
        }
        ShatterEffect { particles: pool, time: 0.0, active: true, origin_x: ox, origin_y: oy }
    }
}

impl Effect for ShatterEffect {
    fn update(&mut self, dt: f32) {
        if !self.active { return; }
        self.time += dt;
        let gravity = 30.0;
        let mut alive_count = 0;
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                self.particles.life[i] -= dt;
                if self.particles.life[i] <= 0.0 { self.particles.active[i] = false; } else {
                    alive_count += 1;
                    self.particles.vy[i] += gravity * dt;
                    self.particles.x[i] += self.particles.vx[i] * dt;
                    self.particles.y[i] += self.particles.vy[i] * dt;
                    let fade = (self.particles.life[i] / self.particles.max_life[i]).max(0.0);
                    let val = (255.0 * fade) as u8;
                    self.particles.r[i] = val; self.particles.g[i] = val; self.particles.b[i] = val;
                }
            }
        }
        if alive_count == 0 { self.active = false; }
    }
    fn bounds(&self, fb_w: usize, fb_h: usize) -> Rect {
        Rect::new(0, 0, fb_w as u16, fb_h as u16)
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                let px = self.particles.x[i] as usize;
                let py = self.particles.y[i] as usize;
                let cell = Cell::new(self.particles.ch[i], (self.particles.r[i], self.particles.g[i], self.particles.b[i]), (0, 0, 0));
                fb.set_cell_in_region(px, py, cell, clip);
            }
        }
    }
}

// 4. Plasma
pub struct PlasmaEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl PlasmaEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        PlasmaEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for PlasmaEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 3.0; }
    fn bounds(&self, _fb_w: usize, _fb_h: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 1) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let v = ((cur_x as f32 * 0.2 + self.time).sin() + (cur_y as f32 * 0.2 + self.time).cos() + 2.0) / 4.0;
                    let plasma_rgb = hsv_to_rgb(v * 360.0, 1.0, 1.0);
                    let base = crate::color::Rgb::new(80, 80, 80);
                    let final_color = crate::color::blend_color_dodge(base, plasma_rgb);
                    let cell = Cell::new(ch, (final_color.r, final_color.g, final_color.b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 5. LiquidChrome
pub struct LiquidChromeEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl LiquidChromeEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        LiquidChromeEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for LiquidChromeEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 2.0; }
    fn bounds(&self, _fb_w: usize, _fb_h: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 1) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let intensity = ((cur_y as f32 * 0.5 + self.time).sin() * 0.5 + 0.5) * 200.0 + 55.0;
                    let val = intensity as u8;
                    let cell = Cell::new(ch, (val, val, 255), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 6. Portal
pub struct PortalEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl PortalEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        PortalEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for PortalEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 5.0; }
    fn bounds(&self, _fb_w: usize, _fb_h: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 1) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let cx = cur_x as f32 - 15.0;
                    let cy = cur_y as f32 - 10.0;
                    let dist = (cx * cx + cy * cy).sqrt();
                    let angle = cy.atan2(cx);
                    let h = (dist * 10.0 - self.time * 50.0 + angle * 180.0 / std::f32::consts::PI) % 360.0;
                    let rgb = hsv_to_rgb((h + 360.0) % 360.0, 1.0, 1.0);
                    let cell = Cell::new(ch, (rgb.r, rgb.g, rgb.b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 7. Glitch
pub struct GlitchEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl GlitchEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        GlitchEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for GlitchEffect {
    fn update(&mut self, dt: f32) { self.time += dt; }
    fn bounds(&self, _fb_w: usize, _fb_h: usize) -> Rect {
        Rect::new(
            (self.offset_x as i32 - 3).max(0) as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 4) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let mut rng = rand::thread_rng();
        let is_glitch = rng.gen_bool(0.1);
        let x_shift = if is_glitch { rng.gen_range(-2..=2) } else { 0 };

        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let mut render_x = cur_x as i32 + x_shift;
                    let render_y = cur_y as i32;
                    if render_x < 0 { render_x = 0; }

                    let (r, g, b) = if is_glitch {
                        match rng.gen_range(0..3) {
                            0 => (255u8, 0u8, 0u8),
                            1 => (0u8, 255u8, 0u8),
                            _ => (0u8, 0u8, 255u8),
                        }
                    } else {
                        (200u8, 200u8, 200u8)
                    };
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(render_x as usize, render_y as usize, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 8. NeonPulse
pub struct NeonPulseEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl NeonPulseEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        NeonPulseEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for NeonPulseEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 3.0; }
    fn bounds(&self, _fb_w: usize, _fb_h: usize) -> Rect {
        Rect::new(
            self.offset_x as u16,
            self.offset_y as u16,
            (self.offset_x + self.text_w + 1) as u16,
            (self.offset_y + self.text_h + 1) as u16,
        )
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        let pulse = (self.time.sin() * 0.5 + 0.5) * 200.0 + 55.0;

        let light_x = self.offset_x as f32 + (self.time.cos() * 0.5 + 0.5) * 60.0;
        let light_y = self.offset_y as f32 + (self.time.sin() * 0.5 + 0.5) * 20.0;
        let neon_color = crate::color::Rgb::new(pulse as u8, 0, 255);

        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let base_color = crate::color::Rgb::new(40, 40, 40);
                    let final_color = crate::color::apply_radial_glow(
                        cur_x, cur_y, light_x, light_y, 30.0, neon_color, base_color
                    );
                    let cell = Cell::new(ch, (final_color.r, final_color.g, final_color.b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}
