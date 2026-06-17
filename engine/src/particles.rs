pub struct ParticlePool {
    pub active: Vec<bool>,
    pub x: Vec<f32>,
    pub y: Vec<f32>,
    pub vx: Vec<f32>,
    pub vy: Vec<f32>,
    pub life: Vec<f32>,
    pub max_life: Vec<f32>,
    pub ch: Vec<char>,
    pub r: Vec<u8>,
    pub g: Vec<u8>,
    pub b: Vec<u8>,
}

impl ParticlePool {
    pub fn new(capacity: usize) -> Self {
        ParticlePool {
            active: vec![false; capacity],
            x: vec![0.0; capacity],
            y: vec![0.0; capacity],
            vx: vec![0.0; capacity],
            vy: vec![0.0; capacity],
            life: vec![0.0; capacity],
            max_life: vec![1.0; capacity],
            ch: vec![' '; capacity],
            r: vec![0; capacity],
            g: vec![0; capacity],
            b: vec![0; capacity],
        }
    }

    pub fn spawn(&mut self, x: f32, y: f32, vx: f32, vy: f32, life: f32, ch: char, r: u8, g: u8, b: u8) {
        if let Some(idx) = self.active.iter().position(|&a| !a) {
            self.active[idx] = true;
            self.x[idx] = x;
            self.y[idx] = y;
            self.vx[idx] = vx;
            self.vy[idx] = vy;
            self.life[idx] = life;
            self.max_life[idx] = life;
            self.ch[idx] = ch;
            self.r[idx] = r;
            self.g[idx] = g;
            self.b[idx] = b;
        }
    }
}
