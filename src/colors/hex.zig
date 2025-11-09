const std = @import("std");
const root = @import("../main.zig");

pub fn convert(window: *@import("quark").Window) void {
    const hex_field = &window.textfields.items[0];
    const hex_text = hex_field.getText();

    if (hex_text.len > 0) {
        const hex_to_parse = if (hex_text[0] == '#') hex_text[1..] else hex_text;
        if (hex_to_parse.len > 0) {
            if (formula(hex_to_parse)) |rgb| {
                root.formatResult(rgb);
                window.setLayout(.{ .column = root.mainLayout(window.allocator) catch return }) catch return;
                return;
            }
        }
    }
}

fn formula(hex: []const u8) ?[3]u8 {
    if (hex.len != 6) return null;

    const r = std.fmt.parseInt(u8, hex[0..2], 16) catch return null;
    const g = std.fmt.parseInt(u8, hex[2..4], 16) catch return null;
    const b = std.fmt.parseInt(u8, hex[4..6], 16) catch return null;

    return .{ r, g, b };
}
