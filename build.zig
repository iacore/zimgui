const Builder = @import("std").build.Builder;
const std = @import("std");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const main_tests = b.addTest("src/zimgui.zig");
    main_tests.setBuildMode(mode);
    link(b, main_tests, .{});

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn link(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = buildLibrary(b, step);
    step.linkLibrary(lib);
}

fn buildLibrary(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const root = std.fs.path.join(b.allocator, &.{ (comptime thisDir()), "src/zimgui.zig" }) catch unreachable;
    const lib = b.addStaticLibrary("zimgui", root);
    lib.setBuildMode(step.build_mode);
    lib.setTarget(step.target);
    lib.install();
    return lib;
}
