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

fn relativePath(b: *Builder, local_path: []const u8) []const u8 {
    return std.fs.path.join(b.allocator, &.{ (comptime std.fs.path.dirname(@src().file) orelse "."), local_path }) catch unreachable;
}

fn buildLibrary(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = b.addStaticLibrary("zimgui", relativePath(b, "src/zimgui.zig"));
    lib.setBuildMode(step.build_mode);
    lib.setTarget(step.target);

    lib.addCSourceFiles(&[_][]const u8{
        relativePath(b, "src/zimgui.cpp"),

        relativePath(b, "deps/imgui/imgui.cpp"),
        relativePath(b, "deps/imgui/imgui_draw.cpp"),
        relativePath(b, "deps/imgui/imgui_tables.cpp"),
        relativePath(b, "deps/imgui/imgui_widgets.cpp"),
        relativePath(b, "deps/imgui/imgui_demo.cpp"),
        }, &[_][]const u8{});

    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);

    lib.linkLibCpp();
    lib.addIncludeDir("deps/imgui");

    lib.install();
    return lib;
}

/// Remeber to also call
/// `exe.addPackagePath("zimgui_backend", "deps/zimgui/src/backend_glfw_opengl3.zig");`
/// 
pub fn addBackendGlfwOpenGl3(b: *Builder, exe: *std.build.LibExeObjStep) void {
    exe.addCSourceFiles(&[_][]const u8{
        relativePath(b, "src/backend_glfw_opengl3.cpp"),
        relativePath(b, "deps/imgui/backends/imgui_impl_glfw.cpp"),
        relativePath(b, "deps/imgui/backends/imgui_impl_opengl3.cpp"),
        }, &[_][]const u8{});

    exe.linkLibCpp();
    exe.addIncludeDir(relativePath(b, "deps/imgui"));
}
