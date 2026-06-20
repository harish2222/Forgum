use std::time::{Duration, Instant};

pub struct Scheduler {
    idle_fps: u32,
    active_fps: u32,
    current_fps: u32,
    target_fps: u32,
    frame_duration: Duration,
    last_frame: Instant,
    last_damage_count: usize,
    idle_frames: u32,
    idle_threshold: u32,
}

impl Scheduler {
    pub fn new(target_fps: u32) -> Self {
        let effective_fps = target_fps.max(1).min(120);
        Scheduler {
            idle_fps: 5,
            active_fps: 60.min(effective_fps),
            current_fps: effective_fps,
            target_fps: effective_fps,
            frame_duration: Duration::from_secs_f64(1.0 / effective_fps as f64),
            last_frame: Instant::now(),
            last_damage_count: 0,
            idle_frames: 0,
            idle_threshold: 15,
        }
    }

    pub fn adapt(&mut self, damage_count: usize) {
        if damage_count == 0 {
            self.idle_frames += 1;
        } else {
            self.idle_frames = 0;
        }

        self.last_damage_count = damage_count;

        let desired_fps = if self.idle_frames >= self.idle_threshold {
            self.idle_fps
        } else if damage_count > 0 {
            self.active_fps.min(self.target_fps)
        } else {
            self.current_fps
        };

        if desired_fps != self.current_fps {
            self.current_fps = desired_fps;
            self.frame_duration = Duration::from_secs_f64(1.0 / desired_fps as f64);
        }
    }

    pub fn wait_if_needed(&mut self) {
        let now = Instant::now();
        let elapsed = now.duration_since(self.last_frame);
        if elapsed < self.frame_duration {
            std::thread::sleep(self.frame_duration - elapsed);
        }
        self.last_frame = Instant::now();
    }

    pub fn should_render(&self, damage_count: usize) -> bool {
        damage_count > 0 || self.idle_frames < self.idle_threshold
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_scheduler_creation() {
        let s = Scheduler::new(30);
        assert_eq!(s.current_fps, 30);
    }

    #[test]
    fn test_clamp_fps() {
        let s = Scheduler::new(200);
        assert_eq!(s.current_fps, 120);

        let s2 = Scheduler::new(0);
        assert_eq!(s2.current_fps, 1);
    }

    #[test]
    fn test_idle_adaptation() {
        let mut s = Scheduler::new(30);
        for _ in 0..20 {
            s.adapt(0);
        }
        assert_eq!(s.current_fps, s.idle_fps);
    }

    #[test]
    fn test_active_adaptation() {
        let mut s = Scheduler::new(30);
        for _ in 0..20 {
            s.adapt(0);
        }
        assert_eq!(s.current_fps, s.idle_fps);
        s.adapt(50);
        assert_eq!(s.current_fps, 30);
    }
}
