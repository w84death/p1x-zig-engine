// *************************************
// P1X ZIG ENGINE
// by Krzysztof Krystian Jankowski
// github.com/w84death/p1x-zig-engine
// *************************************

pub const Rect = struct {
    w: i32,
    h: i32,
    x: i32,
    y: i32,
    pub fn init(w: i32, h: i32, x: i32, y: i32) Rect {
        return .{ .w = w, .h = h, .x = x, .y = y };
    }
};
