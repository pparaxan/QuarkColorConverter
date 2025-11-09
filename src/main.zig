const std = @import("std");
const quark = @import("quark");
const cmyk = @import("colors/cmyk.zig");
const hex = @import("colors/hex.zig");
const hsl = @import("colors/hsl.zig");
const hsv = @import("colors/hsv.zig");

const CONVERT_BUTTON_ID = 1;
const CLEAR_BUTTON_ID = 2;
const constant = @import("colors/const.zig");

var result_text: [256]u8 = undefined;
var result_len: usize = 0;

pub fn main() !void {
    var window = try quark.Window.init("QuarkColorConverter", 550, 650, .{
        .app_icon = @embedFile("icon.png"),
    });
    defer window.deinit();

    const initial = "Enter the values for one of the color codes and \"Convert\"";
    @memcpy(result_text[0..initial.len], initial);
    result_len = initial.len;

    try window.setLayout(.{ .column = try mainLayout(window.allocator) });

    while (window.update()) |event| {
        if (event) |e| {
            switch (e) {
                .button_clicked => |id| {
                    if (id == CONVERT_BUTTON_ID) {
                        hex.convert(&window); // comment about this below.
                    } else if (id == CLEAR_BUTTON_ID) {
                        clearColors(&window);
                    }
                },
                .textfield_submitted => |data| {
                    if (data.id == constant.HEX_INPUT_ID or
                        data.id == constant.H_INPUT_ID or
                        data.id == constant.S_INPUT_ID or
                        data.id == constant.V_INPUT_ID or
                        data.id == constant.HSL_H_INPUT_ID or
                        data.id == constant.HSL_S_INPUT_ID or
                        data.id == constant.HSL_L_INPUT_ID or
                        data.id == constant.C_INPUT_ID or
                        data.id == constant.M_INPUT_ID or
                        data.id == constant.Y_INPUT_ID or
                        data.id == constant.K_INPUT_ID)
                    {
                        hex.convert(&window); // temporary, make it auto detect which color code to use.
                    }
                },
                else => continue,
            }
        }
    }
}

pub fn mainLayout(allocator: std.mem.Allocator) !quark.widget.Column {
    var root = quark.widget.Column.init(allocator);
    root.alignment = .start;
    root.spacing = 15;
    root.padding = 30;

    _ = try root.add(.{ .label = quark.widget.Label.init("QuarkColorConverter") });
    _ = try root.add(.{ .label = quark.widget.Label.init("Effortlessly convert color codes to RGB values") });
    _ = try root.add(.{ .spacer = quark.widget.Spacer.fixedHeight(10) });

    _ = try root.add(.{ .label = quark.widget.Label.init("Hex Color:") });
    var hex_field = quark.widget.TextField.init(constant.HEX_INPUT_ID, "#");
    hex_field.width = quark.size.SizeConstraint.expanding(250, null);
    hex_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try root.add(.{ .textfield = hex_field });

    _ = try root.add(.{ .label = quark.widget.Label.init("HSV Color:") });

    var hsv_row = quark.widget.Row.init(allocator);
    hsv_row.spacing = 15;
    hsv_row.alignment = .start;

    _ = try hsv_row.add(.{ .label = quark.widget.Label.init("H°") });
    var h_field = quark.widget.TextField.init(constant.H_INPUT_ID, "0");
    h_field.width = quark.size.SizeConstraint.expanding(80, 300);
    h_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsv_row.add(.{ .textfield = h_field });

    _ = try hsv_row.add(.{ .spacer = quark.widget.Spacer.fixedWidth(10) });

    _ = try hsv_row.add(.{ .label = quark.widget.Label.init("S%") });
    var s_field = quark.widget.TextField.init(constant.S_INPUT_ID, "0");
    s_field.width = quark.size.SizeConstraint.expanding(80, 300);
    s_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsv_row.add(.{ .textfield = s_field });

    _ = try hsv_row.add(.{ .spacer = quark.widget.Spacer.fixedWidth(10) });

    _ = try hsv_row.add(.{ .label = quark.widget.Label.init("V%") });
    var v_field = quark.widget.TextField.init(constant.V_INPUT_ID, "0");
    v_field.width = quark.size.SizeConstraint.expanding(80, 300);
    v_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsv_row.add(.{ .textfield = v_field });

    _ = try root.add(.{ .row = hsv_row });

    _ = try root.add(.{ .label = quark.widget.Label.init("HSL Color:") });

    var hsl_row = quark.widget.Row.init(allocator);
    hsl_row.spacing = 15;
    hsl_row.alignment = .start;

    _ = try hsl_row.add(.{ .label = quark.widget.Label.init("H°") });
    var hsl_h_field = quark.widget.TextField.init(constant.HSL_H_INPUT_ID, "0");
    hsl_h_field.width = quark.size.SizeConstraint.expanding(80, 300);
    hsl_h_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsl_row.add(.{ .textfield = hsl_h_field });

    _ = try hsl_row.add(.{ .spacer = quark.widget.Spacer.fixedWidth(10) });

    _ = try hsl_row.add(.{ .label = quark.widget.Label.init("S%") });
    var hsl_s_field = quark.widget.TextField.init(constant.HSL_S_INPUT_ID, "0");
    hsl_s_field.width = quark.size.SizeConstraint.expanding(80, 300);
    hsl_s_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsl_row.add(.{ .textfield = hsl_s_field });

    _ = try hsl_row.add(.{ .spacer = quark.widget.Spacer.fixedWidth(10) });

    _ = try hsl_row.add(.{ .label = quark.widget.Label.init("L%") });
    var hsl_l_field = quark.widget.TextField.init(constant.HSL_L_INPUT_ID, "0");
    hsl_l_field.width = quark.size.SizeConstraint.expanding(80, 300);
    hsl_l_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try hsl_row.add(.{ .textfield = hsl_l_field });

    _ = try root.add(.{ .row = hsl_row });

    _ = try root.add(.{ .label = quark.widget.Label.init("CMYK Color:") });

    var cmyk_row = quark.widget.Row.init(allocator);
    cmyk_row.spacing = 15;
    cmyk_row.alignment = .start;

    _ = try cmyk_row.add(.{ .label = quark.widget.Label.init("C%") });
    var c_field = quark.widget.TextField.init(constant.C_INPUT_ID, "0");
    c_field.width = quark.size.SizeConstraint.expanding(60, 200);
    c_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try cmyk_row.add(.{ .textfield = c_field });

    _ = try cmyk_row.add(.{ .label = quark.widget.Label.init("M%") });
    var m_field = quark.widget.TextField.init(constant.M_INPUT_ID, "0");
    m_field.width = quark.size.SizeConstraint.expanding(60, 200);
    m_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try cmyk_row.add(.{ .textfield = m_field });

    _ = try cmyk_row.add(.{ .label = quark.widget.Label.init("Y%") });
    var y_field = quark.widget.TextField.init(constant.Y_INPUT_ID, "0");
    y_field.width = quark.size.SizeConstraint.expanding(60, 200);
    y_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try cmyk_row.add(.{ .textfield = y_field });

    _ = try cmyk_row.add(.{ .label = quark.widget.Label.init("K%") });
    var k_field = quark.widget.TextField.init(constant.K_INPUT_ID, "0");
    k_field.width = quark.size.SizeConstraint.expanding(60, 200);
    k_field.height = quark.size.SizeConstraint.fixed(40);
    _ = try cmyk_row.add(.{ .textfield = k_field });

    _ = try root.add(.{ .row = cmyk_row });

    var button_row = quark.widget.Row.init(allocator);
    button_row.spacing = 15;
    button_row.alignment = .start;

    var convert_btn = quark.widget.Button.init("Convert", CONVERT_BUTTON_ID);
    convert_btn.width = quark.size.SizeConstraint.flexible(100, 90, 150);
    _ = try button_row.add(.{ .button = convert_btn });

    var clear_btn = quark.widget.Button.init("Clear", CLEAR_BUTTON_ID);
    clear_btn.width = quark.size.SizeConstraint.flexible(100, 90, 150);
    _ = try button_row.add(.{ .button = clear_btn });

    _ = try root.add(.{ .row = button_row });

    _ = try root.add(.{ .label = quark.widget.Label.init(result_text[0..result_len]) });

    return root;
}

fn clearColors(window: *quark.Window) void {
    for (window.textfields.items) |*tf| {
        tf.clear();
    }

    const cleared = "Cleared! Enter your new values";
    @memcpy(result_text[0..cleared.len], cleared);
    result_len = cleared.len;
    window.setLayout(.{ .column = mainLayout(window.allocator) catch return }) catch return;
}

pub fn formatResult(rgb: [3]u8) void {
    const formatted = std.fmt.bufPrint(&result_text, "[..].theme.WidgetTheme.rgb({d}, {d}, {d}),", .{ rgb[0], rgb[1], rgb[2] }) catch {
        const err = "Error formatting result";
        @memcpy(result_text[0..err.len], err);
        result_len = err.len;
        return;
    };
    result_len = formatted.len;
}

// Simple helper function to set error message in the result text field
pub fn setError(msg: []const u8) void {
    @memcpy(result_text[0..msg.len], msg);
    result_len = msg.len;
}
