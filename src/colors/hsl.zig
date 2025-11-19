const std = @import("std");
const root = @import("../main.zig");

pub fn convert(window: *@import("quark").Window) void {
    const hsl_h_field = &window.textfields.items[4];
    const hsl_s_field = &window.textfields.items[5];
    const hsl_l_field = &window.textfields.items[6];

    const hsl_h_text = hsl_h_field.getText();
    const hsl_s_text = hsl_s_field.getText();
    const hsl_l_text = hsl_l_field.getText();

    if (hsl_h_text.len > 0 or hsl_s_text.len > 0 or hsl_l_text.len > 0) {
        const h = std.fmt.parseFloat(f32, hsl_h_text) catch {
            root.setError("Invalid HSL H value (0-360°)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const s = std.fmt.parseFloat(f32, hsl_s_text) catch {
            root.setError("Invalid HSL S value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const l = std.fmt.parseFloat(f32, hsl_l_text) catch {
            root.setError("Invalid HSL L value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };

        if (h < 0 or h > 360 or s < 0 or s > 100 or l < 0 or l > 100) {
            root.setError("HSL values out of range (H: 0-360, S/L: 0-100)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        }

        const rgb = formula(h, s, l);
        root.formatResult(rgb);
        window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
        return;
    }
}

fn formula(h: f32, s: f32, l: f32) [3]u8 {
    const s_norm = s / 100.0;
    const l_norm = l / 100.0;

    const c = (1.0 - @abs(2.0 * l_norm - 1.0)) * s_norm;
    const x = c * (1.0 - @abs(@mod(h / 60.0, 2.0) - 1.0));
    const m = l_norm - c / 2.0;

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
