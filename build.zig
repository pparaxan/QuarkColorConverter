const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const quark_dep = b.dependency("quark", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "quark_color_converter",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "quark", .module = quark_dep.module("quark") },
            },
        }),
    });

    const quark_lib = quark_dep.artifact("quark");
    exe.linkLibrary(quark_lib);
    exe.linkLibC();

    const vulkan_sdk = std.process.getEnvVarOwned(b.allocator, "VULKAN_SDK") catch |err| {
        std.debug.print("Vulkan SDK wasn't found.\n", .{});
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    defer b.allocator.free(vulkan_sdk);

    const vulkan_lib = std.fs.path.join(b.allocator, &.{ vulkan_sdk, "Lib" }) catch unreachable;
    defer b.allocator.free(vulkan_lib);

    exe.addLibraryPath(.{ .cwd_relative = vulkan_lib });
    exe.linkSystemLibrary("vulkan-1");

    if (@import("builtin").os.tag == .windows) {
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("kernel32");
    }

    const quark_shaders = quark_dep.namedWriteFiles("shaders");
    const install_shaders = b.addInstallDirectory(.{
        .source_dir = quark_shaders.getDirectory(),
        .install_dir = .bin,
        .install_subdir = "shaders",
    });
    b.getInstallStep().dependOn(&install_shaders.step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the color converter");
    run_step.dependOn(&run_cmd.step);
}
