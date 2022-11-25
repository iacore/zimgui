const Builder = @import("std").build.Builder;
const std = @import("std");

/// Build and link zig imgui bindings.
///
/// Remeber to also call
/// `exe.addPackagePath("zimgui", "deps/zimgui/src/zimgui.zig");`
///
pub fn link(b: *Builder, step: *std.build.LibExeObjStep, opts: BuildOptions) *std.build.LibExeObjStep {
    const lib = buildLibrary(b, step, opts);
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

    exe.addIncludePath(relativePath(b, "deps/imgui"));
    exe.addIncludePath(relativePath(b, "deps/glad/include"));
    exe.linkLibCpp();
}

fn relativePath(b: *Builder, local_path: []const u8) []const u8 {
    return std.fs.path.join(b.allocator, &.{ (comptime std.fs.path.dirname(@src().file) orelse "."), local_path }) catch unreachable;
}

pub const BuildOptions = struct {
    link_imgui: bool = true,
    link_stb_image: bool = true,
    link_zimgui_draw: bool = true,
    custom_TextureID_type: ?[]const u8 = null,
};

pub fn buildLibrary(b: *Builder, step: *std.build.LibExeObjStep, opts: BuildOptions) *std.build.LibExeObjStep {
    const lib = b.addStaticLibrary("zimgui", relativePath(b, "src/zimgui.zig"));
    lib.setBuildMode(step.build_mode);
    lib.setTarget(step.target);

    lib.addCSourceFiles(&.{
        relativePath(b, "src/zimgui.cpp"),
        relativePath(b, "src/zimage.cpp"),
    }, &.{});
    if (opts.link_zimgui_draw) {
        lib.addCSourceFiles(&.{
            relativePath(b, "src/zimgui_draw.cpp"),
        }, &.{});
    }
    if (opts.link_imgui) {
        lib.addCSourceFiles(&.{
            relativePath(b, "deps/imgui/imgui.cpp"),
            // relativePath(b, "deps/imgui/imgui_draw.cpp"),
            relativePath(b, "deps/imgui/imgui_tables.cpp"),
            relativePath(b, "deps/imgui/imgui_widgets.cpp"),
            relativePath(b, "deps/imgui/imgui_demo.cpp"),
        }, &.{});
    }
    if (opts.link_stb_image) {
        lib.addCSourceFiles(&.{
            relativePath(b, "deps/stb/stb_image.c"),
        }, &.{});
    }

    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    step.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);
    step.defineCMacro("IMGUI_IMPL_OPENGL_LOADER_GLAD", null);

    // In OpenGL3, this is our texture id, let imgui know.
    if (opts.custom_TextureID_type) |typedef| {
        // "unsigned int" for OpenGL3
        lib.defineCMacro("ImTextureID", typedef);
    }

    lib.addIncludePath(relativePath(b, "deps/imgui"));
    lib.addIncludePath(relativePath(b, "deps/stb"));
    lib.linkLibCpp();

    lib.install();
    return lib;
}
