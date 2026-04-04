const CONF = @import("../engine/config.zig").CONF;
const THEME = @import("../themes/mil.zig").Theme;
const Fui = @import("../engine/fui.zig").Fui;
const Mouse = @import("../engine/mouse.zig").Mouse;
const Vfx = @import("../logic/vfx.zig").Vfx;

pub fn ExampleScene(comptime State: type, comptime StateMachine: type) type {
    return struct {
        const Self = @This();

        fui: *Fui,
        sm: *StateMachine,
        back_target_state: State,
        vfx: Vfx,

        pub fn init(fui: *Fui, sm: *StateMachine, back_target_state: State) Self {
            return Self{
                .fui = fui,
                .sm = sm,
                .back_target_state = back_target_state,
                .vfx = Vfx.init(fui),
            };
        }

        pub fn draw(self: *Self, mouse: Mouse, dt: f32) void {
            self.vfx.draw(THEME.SECONDARY, dt);

            const px = self.fui.pivotX(.top_left);
            const py = self.fui.pivotY(.top_left);
            if (self.fui.button(px, py, 120, 32, "< Menu", THEME.MENU_SECONDARY, mouse)) {
                self.sm.go_to(self.back_target_state);
            }

            const title = "Example Scene";
            const tx = self.fui.pivotX(.center) - self.fui.text_center(title, CONF.FONT_BIG)[0];
            const ty = self.fui.pivotY(.center) - 96;
            self.fui.draw_text(title, tx, ty, CONF.FONT_BIG, THEME.PRIMARY);
        }
    };
}
