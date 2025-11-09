// I'll prob refactor this again later
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libquark = b.dependency("quark", .{});
    const libquarka = libquark.artifact("quark");

    const exe = b.addExecutable(.{
        .name = "QuarkColorConverter",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "quark", .module = libquarka.root_module },
            },
        }),
    });

    exe.linkLibrary(libquarka);

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

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Execute Quark's color converter tool");
    run_step.dependOn(&run_cmd.step);
}
