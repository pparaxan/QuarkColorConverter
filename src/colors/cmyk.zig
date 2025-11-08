const std = @import("std");
const root = @import("../main.zig");

pub fn convert(window: *@import("quark").Window) void {
    const c_field = &window.textfields.items[7];
    const m_field = &window.textfields.items[8];
    const y_field = &window.textfields.items[9];
    const k_field = &window.textfields.items[10];

    const c_text = c_field.getText();
    const m_text = m_field.getText();
    const y_text = y_field.getText();
    const k_text = k_field.getText();

    if (c_text.len > 0 or m_text.len > 0 or y_text.len > 0 or k_text.len > 0) {
        const c = std.fmt.parseFloat(f32, c_text) catch {
            root.setError("Invalid C value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const m = std.fmt.parseFloat(f32, m_text) catch {
            root.setError("Invalid M value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const y = std.fmt.parseFloat(f32, y_text) catch {
            root.setError("Invalid Y value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };
        const k = std.fmt.parseFloat(f32, k_text) catch {
            root.setError("Invalid K value (0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        };

        if (c < 0 or c > 100 or m < 0 or m > 100 or y < 0 or y > 100 or k < 0 or k > 100) {
            root.setError("CMYK values out of range (all: 0-100%)");
            window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
            return;
        }

        const rgb = formula(c, m, y, k);
        root.formatResult(rgb);
        window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
        return;
    }

    root.setError("Please enter at least one color format");
    window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
}

fn formula(c: f32, m: f32, y: f32, k: f32) [3]u8 {
    const c_norm = c / 100.0;
    const m_norm = m / 100.0;
    const y_norm = y / 100.0;
    const k_norm = k / 100.0;

    const r = @as(u8, @intFromFloat(@round(255.0 * (1.0 - c_norm) * (1.0 - k_norm))));
    const g = @as(u8, @intFromFloat(@round(255.0 * (1.0 - m_norm) * (1.0 - k_norm))));
    const b = @as(u8, @intFromFloat(@round(255.0 * (1.0 - y_norm) * (1.0 - k_norm))));

    return .{ r, g, b };
}
