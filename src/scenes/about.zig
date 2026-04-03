const CONF = @import("../engine/config.zig").CONF;
const THEME = @import("../themes/mil.zig").Theme;
const Fui = @import("../engine/fui.zig").Fui;
const Mouse = @import("../engine/mouse.zig").Mouse;

pub fn AboutScene(comptime State: type, comptime StateMachine: type) type {
    return struct {
        const Self = @This();

        fui: *Fui,
        sm: *StateMachine,
        back_target_state: State,

        pub fn init(fui: *Fui, sm: *StateMachine, back_target_state: State) Self {
            return Self{ .fui = fui, .sm = sm, .back_target_state = back_target_state };
        }

        pub fn draw(self: *Self, mouse: Mouse) void {
            const px = self.fui.pivotX(.top_left);
            const py = self.fui.pivotY(.top_left);
            if (self.fui.button(px, py, 120, 32, "< Menu", THEME.MENU_SECONDARY, mouse)) {
                self.sm.go_to(self.back_target_state);
            }

            var ay: i32 = py + 64;
            const lines = [_][:0]const u8{
                "P1X ZE is an Zig Engine for creating small",
                "applications for Linux and Windows.",
                "",
                "",
                "Uses customized fenster software renderer.",
                "Source code available at:",
                "https://github.com/w84death/p1x-zig-engine",
                "",
                "MIT Licence.",
            };

            const line_height = 24;
            for (lines) |line| {
                self.fui.draw_text(line, px, ay, CONF.FONT_DEFAULT_SIZE, THEME.PRIMARY);
                ay += line_height;
            }
        }
    };
}
