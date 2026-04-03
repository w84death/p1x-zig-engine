const CONF = @import("../engine/config.zig").CONF;
const THEME = @import("../themes/mil.zig").Theme;
const Fui = @import("../engine/fui.zig").Fui;
const Mouse = @import("../engine/mouse.zig").Mouse;
pub fn MenuScene(comptime State: type, comptime StateMachine: type) type {
    return struct {
        const Self = @This();

        pub const MenuItem = struct {
            text: [:0]const u8,
            color: u32,
            target_state: State,
        };

        pub const MenuGroup = struct {
            title: [:0]const u8,
            items: []const MenuItem,
        };

        fui: *Fui,
        sm: *StateMachine,
        groups: []const MenuGroup,

        pub fn init(fui: *Fui, sm: *StateMachine, groups: []const MenuGroup) Self {
            return Self{
                .fui = fui,
                .sm = sm,
                .groups = groups,
            };
        }

        pub fn draw(self: *Self, mouse: Mouse) void {
            const cx: i32 = self.fui.pivotX(.center);
            const cy: i32 = self.fui.pivotY(.center) - 192;

            const tx: i32 = cx - self.fui.text_center(CONF.THE_NAME, CONF.FONT_BIG)[0];
            self.fui.draw_text(CONF.THE_NAME, tx + 4, cy + 4, CONF.FONT_BIG, THEME.SECONDARY);
            self.fui.draw_text(CONF.THE_NAME, tx, cy, CONF.FONT_BIG, THEME.PRIMARY);

            self.fui.draw_text(CONF.TAG_LINE, cx - self.fui.text_center(CONF.TAG_LINE, CONF.FONT_DEFAULT_SIZE)[0], cy + 64, CONF.FONT_DEFAULT_SIZE, THEME.PRIMARY);

            var y: i32 = cy + 128;
            for (self.groups) |group| {
                const title_x = cx - self.fui.text_center(group.title, CONF.FONT_DEFAULT_SIZE)[0];
                self.fui.draw_text(group.title, title_x, y, CONF.FONT_DEFAULT_SIZE, THEME.PRIMARY);
                y += 24;

                const rect_y_start = y - 8;
                var rect_height: i32 = 8;
                for (group.items) |item| {
                    if (self.fui.button(cx - 100, y, 200, 32, item.text, item.color, mouse)) {
                        self.sm.go_to(item.target_state);
                    }
                    y += 38;
                    rect_height += 38;
                }
                self.fui.renderer.draw_rect_lines(cx - 110, rect_y_start, 220, rect_height, THEME.SECONDARY);
                y += 16;
            }
        }
    };
}
