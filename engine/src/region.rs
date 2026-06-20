#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Rect {
    pub x0: u16,
    pub y0: u16,
    pub x1: u16,
    pub y1: u16,
}

impl Rect {
    pub fn new(x0: u16, y0: u16, x1: u16, y1: u16) -> Self {
        Rect { x0, y0, x1, y1 }
    }

    pub fn contains(self, x: u16, y: u16) -> bool {
        x >= self.x0 && x < self.x1 && y >= self.y0 && y < self.y1
    }

    pub fn intersect(self, other: Rect) -> Option<Rect> {
        let x0 = self.x0.max(other.x0);
        let y0 = self.y0.max(other.y0);
        let x1 = self.x1.min(other.x1);
        let y1 = self.y1.min(other.y1);
        if x0 < x1 && y0 < y1 {
            Some(Rect { x0, y0, x1, y1 })
        } else {
            None
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RegionId(pub usize);

#[derive(Debug, Clone)]
pub struct Region {
    pub id: RegionId,
    pub bounds: Rect,
    pub visible: bool,
}

pub struct RegionAllocator {
    regions: Vec<Region>,
    next_id: usize,
    canvas: Rect,
}

impl RegionAllocator {
    pub fn new(canvas: Rect) -> Self {
        RegionAllocator {
            regions: Vec::new(),
            next_id: 0,
            canvas,
        }
    }

    pub fn resize_canvas(&mut self, new_canvas: Rect) {
        self.canvas = new_canvas;
        let canvas = self.canvas;
        for region in &mut self.regions {
            if let Some(clamped) = region.bounds.intersect(canvas) {
                region.bounds = clamped;
            } else {
                region.visible = false;
            }
        }
    }

    pub fn allocate(&mut self, bounds: Rect, _priority: u8) -> RegionId {
        let id = RegionId(self.next_id);
        self.next_id += 1;
        let mut region = Region {
            id,
            bounds,
            visible: true,
        };
        self.clamp_to_canvas(&mut region);
        self.regions.push(region);
        id
    }

    pub fn resize_region(&mut self, id: RegionId, new_bounds: Rect) -> bool {
        if let Some(region) = self.regions.iter_mut().find(|r| r.id == id) {
            region.bounds = new_bounds;
            let canvas = self.canvas;
            if let Some(clamped) = region.bounds.intersect(canvas) {
                region.bounds = clamped;
            } else {
                region.visible = false;
            }
            true
        } else {
            false
        }
    }

    pub fn get(&self, id: RegionId) -> Option<&Region> {
        self.regions.iter().find(|r| r.id == id)
    }

    fn clamp_to_canvas(&self, region: &mut Region) {
        if let Some(clamped) = region.bounds.intersect(self.canvas) {
            region.bounds = clamped;
        } else {
            region.visible = false;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rect_intersect() {
        let a = Rect::new(0, 0, 10, 10);
        let b = Rect::new(5, 5, 15, 15);
        let ix = a.intersect(b).unwrap();
        assert_eq!(ix, Rect::new(5, 5, 10, 10));
    }

    #[test]
    fn test_rect_no_intersect() {
        let a = Rect::new(0, 0, 5, 5);
        let b = Rect::new(10, 10, 15, 15);
        assert!(a.intersect(b).is_none());
    }

    #[test]
    fn test_region_alloc_release() {
        let canvas = Rect::new(0, 0, 80, 40);
        let mut alloc = RegionAllocator::new(canvas);
        let id = alloc.allocate(Rect::new(0, 0, 80, 30), 100);
        assert!(alloc.get(id).is_some());
        alloc.regions.retain(|r| r.id != id);
        assert!(alloc.get(id).is_none());
    }

    #[test]
    fn test_region_resize() {
        let canvas = Rect::new(0, 0, 80, 40);
        let mut alloc = RegionAllocator::new(canvas);
        let id = alloc.allocate(Rect::new(0, 0, 80, 30), 100);
        alloc.resize_region(id, Rect::new(0, 0, 80, 20));
        assert_eq!(alloc.get(id).unwrap().bounds.y1, 20);
    }

    #[test]
    fn test_canvas_resize_clamps_regions() {
        let canvas = Rect::new(0, 0, 80, 40);
        let mut alloc = RegionAllocator::new(canvas);
        let id = alloc.allocate(Rect::new(0, 0, 80, 35), 100);
        alloc.resize_canvas(Rect::new(0, 0, 60, 25));
        assert_eq!(alloc.get(id).unwrap().bounds.x1, 60);
        assert_eq!(alloc.get(id).unwrap().bounds.y1, 25);
    }
}
