const Builder = @import("std").build.Builder;
const std = @import("std");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const main_tests = b.addTest("src/zimgui.zig");
    main_tests.setBuildMode(mode);
    main_tests.linkLibrary(link(b, main_tests));

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn link(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = buildLibrary(b, step);
    step.linkLibrary(lib);
    return lib;
}

fn buildLibrary(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const root = std.fs.path.join(b.allocator, &.{ (comptime std.fs.path.dirname(@src().file) orelse "."), "src/zimgui.zig" }) catch unreachable;
    const lib = b.addStaticLibrary("zimgui", root);
    lib.setBuildMode(step.build_mode);
    lib.setTarget(step.target);

    lib.addCSourceFiles(&[_][]const u8{
        "src/zimgui.cpp",

        "deps/imgui/imgui.cpp",
        "deps/imgui/imgui_draw.cpp",
        "deps/imgui/imgui_tables.cpp",
        "deps/imgui/imgui_widgets.cpp",
        "deps/imgui/imgui_demo.cpp",
        //"deps/imgui/backends/imgui_impl_glfw.cpp",
        //"deps/imgui/backends/imgui_impl_opengl3.cpp",
        }, &[_][]const u8{});

    lib.linkLibCpp();
    lib.addIncludeDir("deps/imgui");

    lib.install();
    return lib;
}
