const Builder = @import("std").build.Builder;
const std = @import("std");

/// Build and link zig imgui bindings.
///
/// Remeber to also call
/// `exe.addPackagePath("zimgui", "deps/zimgui/src/zimgui.zig");`
///
pub fn link(b: *Builder, step: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = buildLibrary(b, step);
    step.linkLibrary(lib);
    return lib;
}

/// Use OpenGL3 as rendering backend, and Glfw for windowing.
///
/// Remeber to also call
/// `exe.addPackagePath("zimgui_backend", "deps/zimgui/src/backend_glfw_opengl3.zig");`
///
pub fn addBackendGlfwOpenGl3(b: *Builder, exe: *std.build.LibExeObjStep) void {
    exe.addCSourceFiles(&[_][]const u8{
        relativePath(b, "src/backend_glfw_opengl3.cpp"),
        relativePath(b, "deps/imgui/backends/imgui_impl_glfw.cpp"),
        relativePath(b, "deps/imgui/backends/imgui_impl_opengl3.cpp"),
        relativePath(b, "deps/glad/src/glad.c"),
        }, &[_][]const u8{});

    exe.addIncludeDir(relativePath(b, "deps/imgui"));
    exe.addIncludeDir(relativePath(b, "deps/glad/include"));
    exe.linkLibCpp();
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
        relativePath(b, "src/zimage.cpp"),

        relativePath(b, "deps/imgui/imgui.cpp"),
        //relativePath(b, "deps/imgui/imgui_draw.cpp"),
        relativePath(b, "src/zimgui_draw.cpp"), // TODO this should be an option
        relativePath(b, "deps/imgui/imgui_tables.cpp"),
        relativePath(b, "deps/imgui/imgui_widgets.cpp"),
        relativePath(b, "deps/imgui/imgui_demo.cpp"),
        relativePath(b, "deps/stb/stb_image.c"),
        }, &[_][]const u8{});

    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);
    step.defineCMacro("IMGUI_IMPL_OPENGL_LOADER_GLAD", null);

    // In OpenGL3, this is our texture id, let imgui know.
    step.defineCMacro("ImTextureID", "unsigned int");
    lib.defineCMacro("ImTextureID", "unsigned int"); // TODO cgustafsson: should be behind OpenGL3 option

    lib.addIncludePath(relativePath(b, "deps/imgui"));
    lib.addIncludePath(relativePath(b, "deps/stb"));
    lib.linkLibCpp();

    lib.install();
    return lib;
}
