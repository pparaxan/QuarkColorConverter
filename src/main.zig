const std = @import("std");
const quark = @import("quark");

const HEX_INPUT_ID = 1;
const R_INPUT_ID = 2;
const G_INPUT_ID = 3;
const B_INPUT_ID = 4;
const CONVERT_BUTTON_ID = 5;
const CLEAR_BUTTON_ID = 6;

var result_text: [256]u8 = undefined;
var result_len: usize = 0;

pub fn main() !void {
    var window = try quark.Window.init("QuarkColorConverter", 450, 500);
    defer window.deinit();

    var root = quark.Widget.Column.init(window.allocator);
    root.alignment = .start;

    _ = try root.add(.{ .label = quark.Widget.Label.init("QuarkColorConverter") });
    _ = try root.add(.{ .label = quark.Widget.Label.init("Effortlessly convert color codes to Quark's float values") });
    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(10) });

    _ = try root.add(.{ .label = quark.Widget.Label.init("Hex Color:") });
    var hex_field = quark.Widget.TextField.init(HEX_INPUT_ID, "#");
    hex_field.width = 300;
    hex_field.height = 35;
    _ = try root.add(.{ .textfield = hex_field });
    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(10) });

    _ = try root.add(.{ .label = quark.Widget.Label.init("RGB Values:") });
    var rgb_row = quark.Widget.Row.init(window.allocator);
    rgb_row.spacing = 5;

    _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("R:") });
    var r_field = quark.Widget.TextField.init(R_INPUT_ID, "0");
    r_field.width = 80;
    r_field.height = 35;
    _ = try rgb_row.add(.{ .textfield = r_field });

    _ = try rgb_row.add(.{ .spacer = quark.Widget.Spacer.fixedWidth(20) });
    _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("G:") });
    var g_field = quark.Widget.TextField.init(G_INPUT_ID, "0");
    g_field.width = 80;
    g_field.height = 35;
    _ = try rgb_row.add(.{ .textfield = g_field });

    _ = try rgb_row.add(.{ .spacer = quark.Widget.Spacer.fixedWidth(20) });
    _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("B:") });
    var b_field = quark.Widget.TextField.init(B_INPUT_ID, "0");
    b_field.width = 80;
    b_field.height = 35;
    _ = try rgb_row.add(.{ .textfield = b_field });

    _ = try root.add(.{ .row = rgb_row });
    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(10) });

    var button_row = quark.Widget.Row.init(window.allocator);
    button_row.spacing = 10;
    _ = try button_row.add(.{ .button = quark.Widget.Button.init("Convert", CONVERT_BUTTON_ID) });
    _ = try button_row.add(.{ .button = quark.Widget.Button.init("Clear", CLEAR_BUTTON_ID) });
    _ = try root.add(.{ .row = button_row });
    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(20) });

    _ = try root.add(.{ .label = quark.Widget.Label.init("Quark Float Values:") });
    const initial = "Enter either your HEX or RGB values and click \"Convert\""; // There's a bug w/ this, you can tell; fix this later.
    @memcpy(result_text[0..initial.len], initial);
    result_len = initial.len;
    _ = try root.add(.{ .label = quark.Widget.Label.init(result_text[0..result_len]) });

    try window.setLayout(.{ .column = root });

    while (window.update()) |event| {
        if (event) |e| {
            switch (e) {
                .button_clicked => |id| {
                    if (id == CONVERT_BUTTON_ID) {
                        handleConvert(&window);
                    } else if (id == CLEAR_BUTTON_ID) {
                        handleClear(&window);
                    }
                },
                .textfield_submitted => |data| {
                    if (data.id == HEX_INPUT_ID or
                        data.id == R_INPUT_ID or
                        data.id == G_INPUT_ID or
                        data.id == B_INPUT_ID)
                    {
                        handleConvert(&window);
                    }
                },
                else => continue,
            }
        }
    }
}

fn handleConvert(window: *quark.Window) void {
    const hex_field = &window.textfields.items[0];
    const hex_text = hex_field.getText();

    if (hex_text.len > 0 and hex_text[0] != '#') {
        if (parseHexColor(hex_text)) |rgb| {
            formatResult(rgb);
            return;
        }
    } else if (hex_text.len > 1) {
        if (parseHexColor(hex_text[1..])) |rgb| {
            formatResult(rgb);
            return;
        }
    }

    const r_field = &window.textfields.items[1];
    const g_field = &window.textfields.items[2];
    const b_field = &window.textfields.items[3];

    const r = std.fmt.parseInt(u8, r_field.getText(), 10) catch {
        const err = "Invalid R value, it must be between 0-255";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    const g = std.fmt.parseInt(u8, g_field.getText(), 10) catch {
        const err = "Invalid G value, it must be between 0-255";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    const b = std.fmt.parseInt(u8, b_field.getText(), 10) catch {
        const err = "Invalid B value, it must be between 0-255";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };

    formatResult(.{ r, g, b });
}

fn handleClear(window: *quark.Window) void {
    for (window.textfields.items) |*tf| {
        tf.clear();
    }

    const cleared = "Cleared! Enter your new values";
    @memcpy(result_text[0..cleared.len], cleared);
    result_len = cleared.len;
}

fn parseHexColor(hex: []const u8) ?[3]u8 {
    if (hex.len != 6) return null;

    const r = std.fmt.parseInt(u8, hex[0..2], 16) catch return null;
    const g = std.fmt.parseInt(u8, hex[2..4], 16) catch return null;
    const b = std.fmt.parseInt(u8, hex[4..6], 16) catch return null;

    return .{ r, g, b };
}

fn formatResult(rgb: [3]u8) void {
    const r_float = @as(f32, @floatFromInt(rgb[0])) / 255.0;
    const g_float = @as(f32, @floatFromInt(rgb[1])) / 255.0;
    const b_float = @as(f32, @floatFromInt(rgb[2])) / 255.0;

    const formatted = std.fmt.bufPrint(&result_text, ".{{ .r = {d:.3}, .g = {d:.3}, .b = {d:.3}, .a = 1.0 }}", .{ r_float, g_float, b_float }) catch {
        const err = "Error formatting result";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    result_len = formatted.len;
}
