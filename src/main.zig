// *************************************
// BOROWIK ENGINE
// by Krzysztof Krystian Jankowski
// github.com/w84death/borowik-engine
// *************************************

const std = @import("std");
const c = @cImport({
    @cInclude("fenster.h");
    @cInclude("fenster_audio.h");
});
const CONF = @import("engine/config.zig").CONF;
const IO = @import("engine/io.zig");
const Render = @import("engine/render.zig").Render;
const THEME = @import("themes/mil.zig").Theme;
//const THEME = @import("themes/smol.zig").Theme;
//const THEME = @import("themes/shroom.zig").Theme;
//const THEME = @import("themes/gray.zig").Theme;
const Fui = @import("engine/fui.zig").Fui(THEME);
const MouseButtons = @import("engine/mouse.zig").MouseButtons;
const State = enum {
    main_menu,
    example,
    about,
    quit,
};
const StateMachine = @import("engine/state.zig").StateMachine(State);
const Menu = @import("engine/menu.zig").Menu(State, StateMachine, THEME);

// Scenes
const MenuScene = @import("scenes/menu.zig").MenuScene(Menu, THEME);
const AboutScene = @import("scenes/about.zig").AboutScene(THEME);
const ExampleScene = @import("scenes/example.zig").ExampleScene(THEME);

pub fn main() void {
    const settings = IO.load_or_create_settings() catch IO.Settings{
        .width = CONF.SCREEN_W,
        .height = CONF.SCREEN_H,
        .fullscreen = false,
    };

    const render_pixels = CONF.SCREEN_W * CONF.SCREEN_H;
    const window_pixels_i64: i64 = @as(i64, settings.width) * @as(i64, settings.height);
    const window_pixels: usize = if (window_pixels_i64 > 0)
        @intCast(window_pixels_i64)
    else
        render_pixels;
    const total_pixels: usize = @max(render_pixels, window_pixels);

    const allocator = std.heap.c_allocator;
    const raw_buf = allocator.alloc(u32, total_pixels) catch @panic("failed to allocate window buffer");
    defer allocator.free(raw_buf);
    @memset(raw_buf, 0);
    const fullscreen_flag: i32 = if (settings.fullscreen) 1 else 0;

    var f = std.mem.zeroInit(c.fenster, .{
        .width = settings.width,
        .height = settings.height,
        .title = CONF.THE_NAME,
        .buf = raw_buf.ptr,
        .fullscreen = fullscreen_flag,
    });
    _ = c.fenster_open(&f);
    defer c.fenster_close(&f);
    var mouse_buttons = MouseButtons.init();
    var renderer = Render.init(raw_buf, settings.width, settings.height);
    defer renderer.deinit();
    var fui = Fui.init();
    var sm = StateMachine.init(State.main_menu);
    var esc_lock = false;

    const menu_groups = [_]Menu.MenuGroup{
        .{
            .title = "Main Menu",
            .items = &[_]Menu.MenuItem{
                .{ .text = "Example", .normal_color = THEME.MENU_NORMAL_COLOR, .hover_color = THEME.MENU_HIGHLIGHT_COLOR, .target_state = State.example },
            },
        },
        .{
            .title = "System",
            .items = &[_]Menu.MenuItem{
                .{ .text = "About", .normal_color = THEME.MENU_SECONDARY_COLOR, .hover_color = THEME.MENU_HIGHLIGHT_COLOR, .target_state = State.about },
                .{ .text = "Quit", .normal_color = THEME.MENU_SECONDARY_COLOR, .hover_color = THEME.MENU_DANGER_COLOR, .target_state = State.quit },
            },
        },
    };

    const core_menu = Menu.init(&fui, &menu_groups);
    var menu = MenuScene.init(&fui, &sm, core_menu);
    var about = AboutScene.init(&fui);
    var example = ExampleScene.init(std.heap.c_allocator, &fui, &renderer);
    defer example.deinit();

    while (c.fenster_loop(&f) == 0) {
        renderer.perf_begin_sim();
        sm.update();
        renderer.begin_frame();
        if (!sm.is(.example)) renderer.clear_background(THEME.BG_COLOR);

        const mapped_mouse_x = @divFloor(f.x * CONF.SCREEN_W, settings.width);
        const mapped_mouse_y = @divFloor(f.y * CONF.SCREEN_H, settings.height);
        const mouse_x = std.math.clamp(mapped_mouse_x, 0, CONF.SCREEN_W - 1);
        const mouse_y = std.math.clamp(mapped_mouse_y, 0, CONF.SCREEN_H - 1);
        const mouse = mouse_buttons.update(mouse_x, mouse_y, @intCast(f.mouse));

        // ESC handler
        if (esc_lock and f.keys[27] == 0) {
            esc_lock = false;
        } else if (!esc_lock and f.keys[27] != 0) {
            esc_lock = true;
            if (!sm.is(State.main_menu)) sm.go_to(State.main_menu) else break;
        }

        // State update
        switch (sm.current) {
            State.example => {
                example.update(mouse, renderer.dt, &renderer);
            },
            else => {},
        }

        // State draw
        switch (sm.current) {
            State.main_menu => {
                menu.draw(&renderer, mouse);
            },
            State.example => {
                example.draw(mouse, renderer.dt, &renderer);
            },
            State.about => {
                about.draw(&renderer);
            },
            State.quit => {
                break;
            },
        }

        renderer.perf_begin_draw();

        // Top global navigation
        if (!sm.is(State.main_menu) and fui.button(&renderer, fui.pivotX(.top_left), fui.pivotY(.top_left), 120, 32, "< Menu", THEME.MENU_SECONDARY_COLOR, THEME.MENU_HIGHLIGHT_COLOR, mouse)) {
            sm.go_to(State.main_menu);
        }

        // Bottom global info
        fui.draw_version(&renderer);
        renderer.draw_perf_overlay(&fui, THEME);

        fui.draw_cursor_lines(&renderer, .{ mouse_x, mouse_y });

        renderer.perf_begin_present();
        renderer.present();
        renderer.perf_end_present();

        renderer.cap_frame(CONF.TARGET_FPS);
    }
}
