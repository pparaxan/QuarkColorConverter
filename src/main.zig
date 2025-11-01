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
    var window = try quark.Window.init("QuarkColorConverter", 500, 530, .{
        .app_icon = @embedFile("icon.png"),
    });
    defer window.deinit();

    const initial = "Enter your HEX values and click \"Convert\"";
    @memcpy(result_text[0..initial.len], initial);
    result_len = initial.len;

    try window.setLayout(.{ .column = try mainLayout(window.allocator) });

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

fn mainLayout(allocator: std.mem.Allocator) !quark.Widget.Column {
    var root = quark.Widget.Column.init(allocator);
    root.alignment = .start;
    root.spacing = 15;
    root.padding = 30;

    _ = try root.add(.{ .label = quark.Widget.Label.init("QuarkColorConverter") });
    _ = try root.add(.{ .label = quark.Widget.Label.init("Effortlessly convert color codes to RGB values") });
    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(20) });

    _ = try root.add(.{ .label = quark.Widget.Label.init("Hex Color:") });
    var hex_field = quark.Widget.TextField.init(HEX_INPUT_ID, "#");

    hex_field.width = quark.size.SizeConstraint.expanding(250, null);
    hex_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try root.add(.{ .textfield = hex_field });

    // _ = try root.add(.{ .label = quark.Widget.Label.init("RGB Values:") });

    // Add other color fields
    // var rgb_row = quark.Widget.Row.init(allocator);
    // rgb_row.spacing = 15;
    // rgb_row.alignment = .start;

    // _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("R:") });
    // var r_field = quark.Widget.TextField.init(R_INPUT_ID, "0");
    // // Expandable: shares extra width with siblings
    // r_field.width = quark.size.SizeConstraint.expanding(80, 300);
    // r_field.height = quark.size.SizeConstraint.fixed(40);
    // _ = try rgb_row.add(.{ .textfield = r_field });

    // _ = try rgb_row.add(.{ .spacer = quark.Widget.Spacer.fixedWidth(10) });

    // _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("G:") });
    // var g_field = quark.Widget.TextField.init(G_INPUT_ID, "0");
    // g_field.width = quark.size.SizeConstraint.expanding(80, 300);
    // g_field.height = quark.size.SizeConstraint.fixed(40);
    // _ = try rgb_row.add(.{ .textfield = g_field });

    // _ = try rgb_row.add(.{ .spacer = quark.Widget.Spacer.fixedWidth(10) });

    // _ = try rgb_row.add(.{ .label = quark.Widget.Label.init("B:") });
    // var b_field = quark.Widget.TextField.init(B_INPUT_ID, "0");
    // b_field.width = quark.size.SizeConstraint.expanding(80, 300);
    // b_field.height = quark.size.SizeConstraint.fixed(40);
    // _ = try rgb_row.add(.{ .textfield = b_field });

    // _ = try root.add(.{ .row = rgb_row });

    var button_row = quark.Widget.Row.init(allocator);
    button_row.spacing = 15;
    button_row.alignment = .start;

    var convert_btn = quark.Widget.Button.init("Convert", CONVERT_BUTTON_ID);
    convert_btn.width = quark.size.SizeConstraint.flexible(100, 90, 150);
    _ = try button_row.add(.{ .button = convert_btn });

    var clear_btn = quark.Widget.Button.init("Clear", CLEAR_BUTTON_ID);
    clear_btn.width = quark.size.SizeConstraint.flexible(100, 90, 150);
    _ = try button_row.add(.{ .button = clear_btn });

    _ = try root.add(.{ .row = button_row });

    _ = try root.add(.{ .spacer = quark.Widget.Spacer.fixedHeight(20) });
    // _ = try root.add(.{ .label = quark.Widget.Label.init("Quark Float Values:") });
    _ = try root.add(.{ .label = quark.Widget.Label.init(result_text[0..result_len]) });

    return root;
}

fn handleConvert(window: *quark.Window) void {
    const hex_field = &window.textfields.items[0];
    const hex_text = hex_field.getText();

    if (hex_text.len > 0 and hex_text[0] != '#') {
        if (parseHexColor(hex_text)) |rgb| {
            formatResult(rgb);
            window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
            return;
        }
    } else if (hex_text.len > 1) {
        if (parseHexColor(hex_text[1..])) |rgb| {
            formatResult(rgb);
            window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
            return;
        }
    }

    // const r_field = &window.textfields.items[1];
    // const g_field = &window.textfields.items[2];
    // const b_field = &window.textfields.items[3];

    // const r = std.fmt.parseInt(u8, r_field.getText(), 10) catch {
    //     const err = "Invalid R value, it must be between 0 and 255";
    //     @memcpy(result_text[0..err.len], err);
    //     result_len = err.len;
    //     window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
    //     return;
    // };
    // const g = std.fmt.parseInt(u8, g_field.getText(), 10) catch {
    //     const err = "Invalid G value, it must be between 0 and 255";
    //     @memcpy(result_text[0..err.len], err);
    //     result_len = err.len;
    //     window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
    //     return;
    // };
    // const b = std.fmt.parseInt(u8, b_field.getText(), 10) catch {
    //     const err = "Invalid B value, it must be between 0 and 255";
    //     @memcpy(result_text[0..err.len], err);
    //     result_len = err.len;
    //     window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
    //     return;
    // };

    // formatResult(.{ r, g, b });
    window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
}

fn handleClear(window: *quark.Window) void {
    for (window.textfields.items) |*tf| {
        tf.clear();
    }

    const cleared = "Cleared! Enter your new values";
    @memcpy(result_text[0..cleared.len], cleared);
    result_len = cleared.len;
    window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
}

fn parseHexColor(hex: []const u8) ?[3]u8 {
    if (hex.len != 6) return null;

    const r = std.fmt.parseInt(u8, hex[0..2], 16) catch return undefined;
    const g = std.fmt.parseInt(u8, hex[2..4], 16) catch return undefined;
    const b = std.fmt.parseInt(u8, hex[4..6], 16) catch return undefined;

    return .{ r, g, b };
}

fn formatResult(rgb: [3]u8) void {
    const formatted = std.fmt.bufPrint(&result_text, "[..].theme.WidgetTheme.rgb({d}, {d}, {d}),", .{ rgb[0], rgb[1], rgb[2] }) catch {
        const err = "Error formatting result";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    result_len = formatted.len;
}
