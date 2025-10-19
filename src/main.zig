const std = @import("std");
const libquark = @import("quark");

const HEX_INPUT_ID = 1;
const R_INPUT_ID = 2;
const G_INPUT_ID = 3;
const B_INPUT_ID = 4;
const CONVERT_BUTTON_ID = 5;
const CLEAR_BUTTON_ID = 6;

var result_text: [256]u8 = undefined;
var result_len: usize = 0;

pub fn main() !void {
    var window = try libquark.Window.init("QuarkColorConverter", 600, 500);
    defer window.deinit();

    _ = try window.addLabel("QuarkColorConverter", 20, 20);
    _ = try window.addLabel("Converting hex/RGB to Quark's float values made simple", 20, 45);

    _ = try window.addLabel("Hex Color:", 20, 90);
    _ = try window.addTextField(20, 115, 300, 35, "#", HEX_INPUT_ID);

    _ = try window.addLabel("RGB Values:", 20, 170);
    _ = try window.addLabel("R:", 20, 200);
    _ = try window.addTextField(50, 195, 80, 35, "0", R_INPUT_ID);
    _ = try window.addLabel("G:", 150, 200);
    _ = try window.addTextField(180, 195, 80, 35, "0", G_INPUT_ID);
    _ = try window.addLabel("B:", 280, 200);
    _ = try window.addTextField(310, 195, 80, 35, "0", B_INPUT_ID);

    _ = try window.addButton(20, 260, 120, 40, CONVERT_BUTTON_ID, "Convert");
    _ = try window.addButton(150, 260, 120, 40, CLEAR_BUTTON_ID, "Clear");

    _ = try window.addLabel("Quark Float Values:", 20, 320);

    const initial = "Enter hex or RGB values and click Convert";
    @memcpy(result_text[0..initial.len], initial);
    result_len = initial.len;

    const result_label_idx = window.labels.items.len;
    _ = try window.addLabel(result_text[0..result_len], 20, 350);

    while (window.update()) |event| {
        if (event) |e| {
            switch (e) {
                .button_clicked => |id| {
                    if (id == CONVERT_BUTTON_ID) {
                        handleConvert(&window);
                        window.labels.items[result_label_idx].text = result_text[0..result_len];
                    } else if (id == CLEAR_BUTTON_ID) {
                        handleClear(&window);
                        window.labels.items[result_label_idx].text = result_text[0..result_len];
                    }
                },
                .textfield_submitted => |data| {
                    if (data.id == HEX_INPUT_ID or
                        data.id == R_INPUT_ID or
                        data.id == G_INPUT_ID or
                        data.id == B_INPUT_ID)
                    {
                        handleConvert(&window);
                        window.labels.items[result_label_idx].text = result_text[0..result_len];
                    }
                },
                else => {},
            }
        }
    }
}

fn handleConvert(window: *libquark.Window) void {
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
        const err = "Invalid R value (must be 0-255)";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    const g = std.fmt.parseInt(u8, g_field.getText(), 10) catch {
        const err = "Invalid G value (must be 0-255)";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    const b = std.fmt.parseInt(u8, b_field.getText(), 10) catch {
        const err = "Invalid B value (must be 0-255)";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };

    formatResult(.{ r, g, b });
}

fn handleClear(window: *libquark.Window) void {
    for (window.textfields.items) |*tf| {
        tf.clear();
    }

    const cleared = "Cleared! Enter new values.";
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
