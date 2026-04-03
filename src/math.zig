pub const Rect = struct {
    w: i32,
    h: i32,
    x: i32,
    y: i32,
    pub fn init(w: i32, h: i32, x: i32, y: i32) Rect {
        return .{ .w = w, .h = h, .x = x, .y = y };
    }
};
