// *************************************
// P1X ZIG ENGINE
// by Krzysztof Krystian Jankowski
// github.com/w84death/p1x-zig-engine
// *************************************

const std = @import("std");
const c = @cImport({
    @cInclude("fenster.h");
    @cInclude("fenster_audio.h");
});
const CONF = @import("engine/config.zig").CONF;
const StateMachine = @import("engine/state.zig").StateMachine;
const State = @import("engine/state.zig").State;
const Fui = @import("engine/fui.zig").Fui;
const MouseButtons = @import("engine/mouse.zig").MouseButtons;
const MenuScene = @import("scenes/menu.zig").MenuScene;
const AboutScene = @import("scenes/about.zig").AboutScene;

pub fn main() void {
    var buf: [CONF.SCREEN_W * CONF.SCREEN_H]u32 = undefined;
    var f = std.mem.zeroInit(c.fenster, .{
        .width = CONF.SCREEN_W,
        .height = CONF.SCREEN_H,
        .title = CONF.THE_NAME,
        .buf = &buf[0],
    });
    _ = c.fenster_open(&f);
    defer c.fenster_close(&f);
    var mouse_buttons = MouseButtons.init();
    var fui = Fui.init(&buf);
    var renderer = &fui.renderer;
    var sm = StateMachine.init(State.main_menu);

    var menu = MenuScene.init(fui, &sm);
    var about = AboutScene.init(fui, &sm);

    var close_application = false;

    while (!close_application and c.fenster_loop(&f) == 0) {
        sm.update();
        renderer.begin_frame();

        const mouse = mouse_buttons.update(f.x, f.y, @intCast(f.mouse));

        switch (sm.current) {
            State.main_menu => {
                menu.draw(mouse);
            },
            State.about => {
                about.draw(mouse);
            },
            State.quit => {
                close_application = true;
            },
        }

        if (f.keys[27] != 0) {
            break;
        }

        // Quit
        if (!sm.is(State.main_menu) and fui.button(fui.pivotX(.top_right) - 80, fui.pivotY(.top_right), 80, 32, "Quit", CONF.COLOR_MENU_NORMAL, mouse)) {
            sm.goTo(State.quit);
        }

        renderer.end_frame(&fui, f.x, f.y);
    }
}
