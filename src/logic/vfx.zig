const std = @import("std");
const Random = std.Random;
const Fui = @import("../engine/fui.zig").Fui;
const CONF = @import("../engine/config.zig").CONF;
pub const VFX_SNOW_MIN = 4;
pub const VFX_SNOW_MAX = 64;
pub const VFX_SNOW_COLOR = 0x022546;
pub const VFX_SNOW_SPEED_MIN = 50.0;
pub const VFX_SNOW_SPEED_MAX = 500.0;
const Particle = struct {
    x: f32,
    y: f32,
    size: f32,
    speed: f32,
};
pub const Vfx = struct {
    vfx: [32]Particle = undefined,
    fui: *Fui,
    prng: Random.DefaultPrng,

    pub fn init(fui: *Fui) Vfx {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch {};
        const prng = Random.DefaultPrng.init(seed);
        const vfx: [32]Particle = undefined;
        var self = Vfx{
            .vfx = vfx,
            .fui = fui,
            .prng = prng,
        };
        for (&self.vfx) |*p| {
            self.fillRandomRectangles(p);
        }
        return self;
    }
    pub fn draw(self: *Vfx, color: u32, dt: f32) void {
        self.drawSnow(color, dt);
    }
    fn drawSnow(self: *Vfx, color: u32, dt: f32) void {
        for (&self.vfx) |*p| {
            const x: i32 = @intFromFloat(p.x - p.size * 0.5);
            const y: i32 = @intFromFloat(p.y - p.size * 0.5);
            const size: i32 = @intFromFloat(p.size);
            self.fui.renderer.draw_rect(x, y, size, size, color);
            p.y += p.speed * dt;
            if (p.y > CONF.SCREEN_H) {
                self.fillRandomRectangles(p);
            }
        }
    }
    fn fillRandomRectangles(self: *Vfx, p: *Particle) void {
        const rand = self.prng.random();
        p.x = rand.float(f32) * CONF.SCREEN_W;
        p.y = -rand.float(f32) * (CONF.SCREEN_H);
        p.size = VFX_SNOW_MIN + rand.float(f32) * (VFX_SNOW_MAX - VFX_SNOW_MIN);
        p.speed = VFX_SNOW_SPEED_MIN + (p.size * 0.001) * VFX_SNOW_SPEED_MAX;
    }
};
