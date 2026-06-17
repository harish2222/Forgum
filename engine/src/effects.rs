use crate::framebuffer::{FrameBuffer, Cell};
use crate::particles::ParticlePool;
use crate::color::{hsv_to_rgb, Rgb};
use rand::Rng;

pub trait Effect {
    fn update(&mut self, dt: f32);
    fn render(&self, fb: &mut FrameBuffer);
}

// 1. Aurora
pub struct AuroraEffect {
    cow_text: String,
    time: f32,
    offset_x: usize,
    offset_y: usize,
}
impl AuroraEffect {
    pub fn new(cow_text: String) -> Self {
        AuroraEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 }
    }
}
impl Effect for AuroraEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 50.0; }
    fn render(&self, fb: &mut FrameBuffer) {
        let mut cur_x = self.offset_x;
        let mut cur_y = self.offset_y;
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let h = (self.time + (cur_y as f32 * 10.0)) % 360.0;
                    let rgb = hsv_to_rgb(h, 0.8, 1.0);
                    fb.set_cell(cur_x, cur_y, Cell { ch, r: rgb.r, g: rgb.g, b: rgb.b, alpha: 1.0 });
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
        let lines: Vec<&str> = cow_text.lines().collect();
        let height = lines.len();
        let width = lines.iter().map(|l| l.chars().count()).max().unwrap_or(0);
        EmberEffect { cow_text, particles: ParticlePool::new(1000), offset_x: 2, offset_y: 2, width, height }
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
    fn render(&self, fb: &mut FrameBuffer) {
        crate::compositor::Compositor::draw_text_layer(fb, self.offset_x, self.offset_y, &self.cow_text, 150, 150, 150);
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                let px = self.particles.x[i] as usize;
                let py = self.particles.y[i] as usize;
                fb.set_cell(px, py, Cell { ch: self.particles.ch[i], r: self.particles.r[i], g: self.particles.g[i], b: self.particles.b[i], alpha: 1.0 });
            }
        }
    }
}

// 3. Shatter
pub struct ShatterEffect { particles: ParticlePool, time: f32, active: bool }
impl ShatterEffect {
    pub fn new(cow_text: String) -> Self {
        let mut pool = ParticlePool::new(5000);
        let mut rng = rand::thread_rng();
        let (mut cur_x, mut cur_y) = (2, 2);
        for ch in cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = 2; } else {
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
    fn render(&self, fb: &mut FrameBuffer) {
        for i in 0..self.particles.active.len() {
            if self.particles.active[i] {
                let px = self.particles.x[i] as usize;
                let py = self.particles.y[i] as usize;
                fb.set_cell(px, py, Cell { ch: self.particles.ch[i], r: self.particles.r[i], g: self.particles.g[i], b: self.particles.b[i], alpha: 1.0 });
            }
        }
    }
}

// 4. Plasma
pub struct PlasmaEffect { cow_text: String, time: f32, offset_x: usize, offset_y: usize }
impl PlasmaEffect {
    pub fn new(cow_text: String) -> Self { PlasmaEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 } }
}
impl Effect for PlasmaEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 3.0; }
    fn render(&self, fb: &mut FrameBuffer) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let v = ((cur_x as f32 * 0.2 + self.time).sin() + (cur_y as f32 * 0.2 + self.time).cos() + 2.0) / 4.0;
                    let rgb = hsv_to_rgb(v * 360.0, 1.0, 1.0);
                    fb.set_cell(cur_x, cur_y, Cell { ch, r: rgb.r, g: rgb.g, b: rgb.b, alpha: 1.0 });
                }
                cur_x += 1;
            }
        }
    }
}

// 5. LiquidChrome
pub struct LiquidChromeEffect { cow_text: String, time: f32, offset_x: usize, offset_y: usize }
impl LiquidChromeEffect {
    pub fn new(cow_text: String) -> Self { LiquidChromeEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 } }
}
impl Effect for LiquidChromeEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 2.0; }
    fn render(&self, fb: &mut FrameBuffer) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    let intensity = ((cur_y as f32 * 0.5 + self.time).sin() * 0.5 + 0.5) * 200.0 + 55.0;
                    let val = intensity as u8;
                    fb.set_cell(cur_x, cur_y, Cell { ch, r: val, g: val, b: 255, alpha: 1.0 });
                }
                cur_x += 1;
            }
        }
    }
}

// 6. Portal
pub struct PortalEffect { cow_text: String, time: f32, offset_x: usize, offset_y: usize }
impl PortalEffect {
    pub fn new(cow_text: String) -> Self { PortalEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 } }
}
impl Effect for PortalEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 5.0; }
    fn render(&self, fb: &mut FrameBuffer) {
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
                    fb.set_cell(cur_x, cur_y, Cell { ch, r: rgb.r, g: rgb.g, b: rgb.b, alpha: 1.0 });
                }
                cur_x += 1;
            }
        }
    }
}

// 7. Glitch
pub struct GlitchEffect { cow_text: String, time: f32, offset_x: usize, offset_y: usize }
impl GlitchEffect {
    pub fn new(cow_text: String) -> Self { GlitchEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 } }
}
impl Effect for GlitchEffect {
    fn update(&mut self, dt: f32) { self.time += dt; }
    fn render(&self, fb: &mut FrameBuffer) {
        let mut rng = rand::thread_rng();
        let is_glitch = rng.gen_bool(0.1); // 10% chance to glitch frame
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
                            0 => (255, 0, 0),
                            1 => (0, 255, 0),
                            _ => (0, 0, 255),
                        }
                    } else {
                        (200, 200, 200)
                    };
                    fb.set_cell(render_x as usize, render_y as usize, Cell { ch, r, g, b, alpha: 1.0 });
                }
                cur_x += 1;
            }
        }
    }
}

// 8. NeonPulse
pub struct NeonPulseEffect { cow_text: String, time: f32, offset_x: usize, offset_y: usize }
impl NeonPulseEffect {
    pub fn new(cow_text: String) -> Self { NeonPulseEffect { cow_text, time: 0.0, offset_x: 2, offset_y: 2 } }
}
impl Effect for NeonPulseEffect {
    fn update(&mut self, dt: f32) { self.time += dt * 3.0; }
    fn render(&self, fb: &mut FrameBuffer) {
        let (mut cur_x, mut cur_y) = (self.offset_x, self.offset_y);
        let pulse = (self.time.sin() * 0.5 + 0.5) * 200.0 + 55.0; // 55 to 255
        for ch in self.cow_text.chars() {
            if ch == '\n' { cur_y += 1; cur_x = self.offset_x; } else {
                if ch != ' ' {
                    fb.set_cell(cur_x, cur_y, Cell { ch, r: pulse as u8, g: 0, b: 255, alpha: 1.0 }); // Magenta/Purple neon
                }
                cur_x += 1;
            }
        }
    }
}
