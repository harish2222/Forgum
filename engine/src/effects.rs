use crate::framebuffer::{FrameBuffer, Cell};
use crate::particles::ParticlePool;
use crate::color::hsv_to_rgb;
use crate::region::Rect;
use rand::Rng;
use rand::seq::SliceRandom;

pub trait Effect {
    fn update(&mut self, dt: f32);
    fn render(&self, fb: &mut FrameBuffer, clip: Rect);
    fn on_resize(&mut self, _new_width: usize, _new_height: usize) {}
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

// ============================================================
// FLAGSHIP VISUAL EFFECTS (existing)
// ============================================================

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
pub struct ShatterEffect {
    particles: ParticlePool,
    time: f32,
    active: bool,
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
        ShatterEffect { particles: pool, time: 0.0, active: true }
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

// 9. Physics — breathing bounce with gravity particles
pub struct PhysicsEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    base_offset_y: usize,
    text_w: usize,
    text_h: usize,
    particles: ParticlePool,
}

impl PhysicsEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        PhysicsEffect {
            cow_text, time: 0.0, offset_x: ox, offset_y: oy, base_offset_y: oy,
            text_w: tw, text_h: th, particles: ParticlePool::new(200),
        }
    }
}

impl Effect for PhysicsEffect {
    fn update(&mut self, dt: f32) {
        self.time += dt;
        let bounce = (self.time * 2.0).sin() * 3.0;
        self.offset_y = (self.base_offset_y as f32 + bounce) as usize;

        let mut rng = rand::thread_rng();
        if rng.gen_ratio(1, 3) {
            let px = self.offset_x as f32 + rng.gen_range(0.0..self.text_w as f32);
            let py = (self.offset_y + self.text_h) as f32;
            let vx = rng.gen_range(-0.5..0.5);
            let vy = rng.gen_range(-2.0..-0.5);
            let life = rng.gen_range(1.0..2.5);
            self.particles.spawn(px, py, vx, vy, life, '.', 180, 220, 255);
        }

        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                self.particles.life[i] -= dt;
                if self.particles.life[i] <= 0.0 {
                    self.particles.active[i] = false;
                } else {
                    self.particles.vy[i] += 0.5 * dt;
                    self.particles.x[i] += self.particles.vx[i] * dt;
                    self.particles.y[i] += self.particles.vy[i] * dt;
                    let fade = (self.particles.life[i] / self.particles.max_life[i]).max(0.0);
                    let val = (200.0 * fade) as u8;
                    self.particles.r[i] = val;
                    self.particles.g[i] = (val as f32 * 1.2).min(255.0) as u8;
                    self.particles.b[i] = 255;
                }
            }
        }
    }

    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.base_offset_y = oy;
    }

    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let pulse = (self.time * 2.0).sin();
        let r = (80.0 + pulse * 30.0) as u8;
        let g = (120.0 + pulse * 40.0) as u8;
        let b = (200.0 + pulse * 55.0) as u8;

        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = self.offset_x;
            } else {
                if ch != ' ' {
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }

        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                let px = self.particles.x[i] as usize;
                let py = self.particles.y[i] as usize;
                let cell = Cell::new(
                    self.particles.ch[i],
                    (self.particles.r[i], self.particles.g[i], self.particles.b[i]),
                    (0, 0, 0),
                );
                fb.set_cell_in_region(px, py, cell, clip);
            }
        }
    }
}

// ============================================================
// BASE ANIMATION STYLES (new — mapped from animations.json)
// ============================================================

// 10. Static — no animation, just render cow text
pub struct StaticEffect {
    cow_text: String,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl StaticEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        StaticEffect { cow_text, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for StaticEffect {
    fn update(&mut self, _dt: f32) {}
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
                    let cell = Cell::new(ch, (255, 255, 255), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 11. Breathing — slow scale expansion/contraction via space insertion
pub struct BreathingEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl BreathingEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        BreathingEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for BreathingEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 0.5; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let expand = self.time.sin() * 0.15;
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        let mut space_counter = 0;
        for ch in self.cow_text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = self.offset_x;
                space_counter = 0;
            } else {
                if ch == ' ' {
                    space_counter += 1;
                    if expand > 0.05 && space_counter % 3 == 0 {
                        let cell = Cell::new(' ', (255, 255, 255), (0, 0, 0));
                        fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                        cur_x += 1;
                    }
                } else {
                    let r = (200.0 + expand * 200.0) as u8;
                    let g = (200.0 + expand * 200.0) as u8;
                    let b = (200.0 + expand * 200.0) as u8;
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 12. Liquid — per-row sine wave horizontal displacement
pub struct LiquidEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl LiquidEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        LiquidEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for LiquidEffect {
    fn update(&mut self, dt: f32) { self.time += dt; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        let mut row = 0;
        for ch in self.cow_text.chars() {
            if ch == '\n' {
                cur_y += 1;
                cur_x = self.offset_x;
                row += 1;
            } else {
                let shift = (row as f32 * 0.4 + self.time * 0.5).sin() * 2.0;
                let render_x = (cur_x as f32 + shift) as usize;
                if ch != ' ' {
                    let h = (row as f32 * 30.0 + self.time * 20.0) % 360.0;
                    let rgb = hsv_to_rgb(h, 0.6, 0.9);
                    let cell = Cell::new(ch, (rgb.r, rgb.g, rgb.b), (0, 0, 0));
                    fb.set_cell_in_region(render_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 13. Sway — elastic horizontal sway, centered
pub struct SwayEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl SwayEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        SwayEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for SwayEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 1.5; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let sway_amt = self.time.sin() * 3.0;
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                let row_offset = cur_y as f32 - (self.offset_y + self.text_h / 2) as f32;
                let dist_from_center = row_offset.abs() / (self.text_h as f32 / 2.0).max(1.0);
                let shift = sway_amt * (1.0 - dist_from_center);
                let render_x = (cur_x as f32 + shift) as usize;
                if ch != ' ' {
                    let r = (180.0 + dist_from_center * 75.0) as u8;
                    let g = (180.0 + dist_from_center * 75.0) as u8;
                    let b = 200u8;
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(render_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 14. Bounce — gravity + squash on landing
pub struct BounceEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    base_offset_y: usize,
    text_w: usize,
    text_h: usize,
    vy: f32,
    bounces: u32,
}

impl BounceEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        BounceEffect {
            cow_text, time: 0.0, offset_x: ox, offset_y: oy, base_offset_y: oy,
            text_w: tw, text_h: th, vy: -10.0, bounces: 0,
        }
    }
}

impl Effect for BounceEffect {
    fn update(&mut self, dt: f32) {
        self.time += dt;
        let gravity = 15.0;
        self.vy += gravity * dt;
        let new_y = self.base_offset_y as f32 + self.vy * self.time;
        if new_y >= self.base_offset_y as f32 {
            self.offset_y = self.base_offset_y;
            self.vy = -self.vy * 0.6;
            self.bounces += 1;
            self.time = 0.0;
        } else {
            self.offset_y = new_y as usize;
        }
        if self.vy.abs() < 0.5 {
            self.vy = -10.0;
            self.time = 0.0;
        }
    }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.base_offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let squash = if self.offset_y >= self.base_offset_y { 1.2 } else { 1.0 };
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let r = (255.0 * (0.8 + 0.2 * squash)) as u8;
                    let g = (200.0 * (1.0 / squash)) as u8;
                    let b = 100u8;
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 15. Flying — Lissajous figure-8 path with wing char alternation
pub struct FlyingEffect {
    cow_text: String,
    time: f32,
    base_offset_x: usize,
    base_offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl FlyingEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        FlyingEffect {
            cow_text, time: 0.0,
            base_offset_x: ox, base_offset_y: oy, text_w: tw, text_h: th,
        }
    }
}

impl Effect for FlyingEffect {
    fn update(&mut self, dt: f32) { self.time += dt; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.base_offset_x = ox;
        self.base_offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let fly_y = (self.time * 1.5).sin() * 3.0;
        let fly_x = (self.time * 0.7).sin() * 5.0;
        let render_ox = (self.base_offset_x as f32 + fly_x) as usize;
        let render_oy = (self.base_offset_y as f32 + fly_y) as usize;
        let wing = if (self.time * 8.0).sin() > 0.0 { '/' } else { '\\' };
        let mut cur_x = render_ox;
        let mut cur_y = render_oy;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = render_ox; } else {
                let render_ch = match ch {
                    '<' | '>' => wing,
                    _ => ch,
                };
                if render_ch != ' ' {
                    let h = (self.time * 50.0 + cur_x as f32 * 10.0) % 360.0;
                    let rgb = hsv_to_rgb(h, 0.7, 1.0);
                    let cell = Cell::new(render_ch, (rgb.r, rgb.g, rgb.b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 16. Fire — hot base coloring + rising ember particles
pub struct FireEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
    particles: ParticlePool,
}

impl FireEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        FireEffect {
            cow_text, time: 0.0, offset_x: ox, offset_y: oy,
            text_w: tw, text_h: th, particles: ParticlePool::new(500),
        }
    }
}

impl Effect for FireEffect {
    fn update(&mut self, dt: f32) {
        self.time += dt;
        let mut rng = rand::thread_rng();
        for _ in 0..5 {
            let px = self.offset_x as f32 + rng.gen_range(0.0..self.text_w as f32);
            let py = (self.offset_y + self.text_h) as f32;
            let vx = rng.gen_range(-1.0..1.0);
            let vy = rng.gen_range(-8.0..-2.0);
            let life = rng.gen_range(0.5..2.0);
            self.particles.spawn(px, py, vx, vy, life, '*', 255, 150, 0);
        }
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                self.particles.life[i] -= dt;
                if self.particles.life[i] <= 0.0 { self.particles.active[i] = false; } else {
                    self.particles.y[i] += self.particles.vy[i] * dt;
                    self.particles.x[i] += self.particles.vx[i] * dt;
                    let life_pct = self.particles.life[i] / self.particles.max_life[i];
                    self.particles.r[i] = 255;
                    self.particles.g[i] = (200.0 * life_pct) as u8;
                    self.particles.b[i] = (50.0 * life_pct) as u8;
                }
            }
        }
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
                    let flicker = (self.time * 10.0 + cur_x as f32).sin() * 0.3 + 0.7;
                    let r = (255.0 * flicker) as u8;
                    let g = (100.0 * flicker) as u8;
                    let b = 20u8;
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
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

// 17. Matrix — green digital rain + random char replacement
pub struct MatrixEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl MatrixEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        MatrixEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for MatrixEffect {
    fn update(&mut self, dt: f32) { self.time += dt; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let mut rng = rand::thread_rng();
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let replace = rng.gen_ratio(1, 20);
                    let render_ch = if replace {
                        *b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".choose(&mut rng).unwrap_or(&b'0') as char
                    } else { ch };
                    let brightness = if rng.gen_ratio(3, 4) { 255 } else { 100 };
                    let g = if rng.gen_ratio(1, 5) { 255 } else { brightness };
                    let cell = Cell::new(render_ch, (0, g, 0), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
            }
        }
    }
}

// 18. Pulse — per-character RGB sine cycling
pub struct PulseEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
    text_w: usize,
    text_h: usize,
}

impl PulseEffect {
    pub fn new(cow_text: String) -> Self {
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        PulseEffect { cow_text, time: 0.0, offset_x: ox, offset_y: oy, text_w: tw, text_h: th }
    }
}

impl Effect for PulseEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 2.0; }
    fn on_resize(&mut self, new_w: usize, new_h: usize) {
        let (ox, oy) = center_offset(self.text_h, self.text_w, new_w, new_h);
        self.offset_x = ox;
        self.offset_y = oy;
    }
    fn render(&self, fb: &mut FrameBuffer, clip: Rect) {
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        let mut char_idx = 0;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; char_idx = 0; } else {
                if ch != ' ' {
                    let freq = 0.15;
                    let r = ((freq * (char_idx as f32 + self.time * 10.0)).sin() * 127.0 + 128.0) as u8;
                    let g = ((freq * (char_idx as f32 + self.time * 10.0) + 2.094).sin() * 127.0 + 128.0) as u8;
                    let b = ((freq * (char_idx as f32 + self.time * 10.0) + 4.189).sin() * 127.0 + 128.0) as u8;
                    let cell = Cell::new(ch, (r, g, b), (0, 0, 0));
                    fb.set_cell_in_region(cur_x, cur_y, cell, clip);
                }
                cur_x += 1;
                char_idx += 1;
            }
        }
    }
}

// 19. Dissolve — characters scatter with gravity, slow fade
pub struct DissolveEffect {
    particles: ParticlePool,
    time: f32,
    active: bool,
}

impl DissolveEffect {
    pub fn new(cow_text: String) -> Self {
        let mut pool = ParticlePool::new(5000);
        let mut rng = rand::thread_rng();
        let (tw, th) = text_dims(&cow_text);
        let (ox, oy) = center_offset(th, tw, 80, 40);
        let (mut cur_x, mut cur_y) = (ox, oy);
        for ch in cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = ox; } else {
                if ch != ' ' {
                    let vx = rng.gen_range(-10.0..10.0);
                    let vy = rng.gen_range(-5.0..5.0);
                    pool.spawn(cur_x as f32, cur_y as f32, vx, vy, rng.gen_range(3.0..6.0), ch, 255, 255, 255);
                }
                cur_x += 1;
            }
        }
        DissolveEffect { particles: pool, time: 0.0, active: true }
    }
}

impl Effect for DissolveEffect {
    fn update(&mut self, dt: f32) {
        if !self.active { return; }
        self.time += dt;
        let gravity = 5.0;
        let mut alive_count = 0;
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                self.particles.life[i] -= dt;
                if self.particles.life[i] <= 0.0 { self.particles.active[i] = false; } else {
                    alive_count += 1;
                    self.particles.vy[i] += gravity * dt;
                    self.particles.x[i] += self.particles.vx[i] * dt;
                    self.particles.y[i] += self.particles.vy[i] * dt;
                    self.particles.vx[i] *= 0.98;
                    let fade = (self.particles.life[i] / self.particles.max_life[i]).max(0.0);
                    let val = (255.0 * fade) as u8;
                    self.particles.r[i] = val;
                    self.particles.g[i] = (val as f32 * 0.8) as u8;
                    self.particles.b[i] = (val as f32 * 0.6) as u8;
                }
            }
        }
        if alive_count == 0 { self.active = false; }
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
