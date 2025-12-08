const std = @import("std");
const root = @import("../main.zig");

pub fn convert(window: *@import("quark").Window) void {
    const h_field = &window.textfields.items[1];
    const s_field = &window.textfields.items[2];
    const v_field = &window.textfields.items[3];

    const h_text = h_field.getText();
    const s_text = s_field.getText();
    const v_text = v_field.getText();

    if (h_text.len > 0 or s_text.len > 0 or v_text.len > 0) {
        const h = std.fmt.parseFloat(f32, h_text) catch {
            root.setError("Invalid H value (0-360°)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const s = std.fmt.parseFloat(f32, s_text) catch {
            root.setError("Invalid S value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const v = std.fmt.parseFloat(f32, v_text) catch {
            root.setError("Invalid V value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };

        if (h < 0 or h > 360 or s < 0 or s > 100 or v < 0 or v > 100) {
            root.setError("HSV values out of range (H: 0-360, S/V: 0-100)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        }

        const rgb = formula(h, s, v);
        root.formatResult(rgb);
        window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
        return;
    }
}

fn formula(h: f32, s: f32, v: f32) [3]u8 {
    const s_norm = s / 100.0;
    const v_norm = v / 100.0;

    const c = v_norm * s_norm;
    const x = c * (1.0 - @abs(@mod(h / 60.0, 2.0) - 1.0));
    const m = v_norm - c;

    var r_prime: f32 = 0;
    var g_prime: f32 = 0;
    var b_prime: f32 = 0;

    if (h >= 0 and h < 60) {
        r_prime = c;
        g_prime = x;
        b_prime = 0;
    } else if (h >= 60 and h < 120) {
        r_prime = x;
        g_prime = c;
        b_prime = 0;
    } else if (h >= 120 and h < 180) {
        r_prime = 0;
        g_prime = c;
        b_prime = x;
    } else if (h >= 180 and h < 240) {
        r_prime = 0;
        g_prime = x;
        b_prime = c;
    } else if (h >= 240 and h < 300) {
        r_prime = x;
        g_prime = 0;
        b_prime = c;
    } else {
        r_prime = c;
        g_prime = 0;
        b_prime = x;
    }

    const r = @as(u8, @intFromFloat(@round((r_prime + m) * 255.0)));
    const g = @as(u8, @intFromFloat(@round((g_prime + m) * 255.0)));
    const b = @as(u8, @intFromFloat(@round((b_prime + m) * 255.0)));

    return .{ r, g, b };
}
