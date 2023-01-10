const Builder = @import("std").build.Builder;
const std = @import("std");

pub const BuildOptions = struct {
    build_mode: ?std.builtin.Mode = null,
    target: ?std.zig.CrossTarget = null,
    impl_opengl3: bool = true,
    disable_obsolete_keyio: bool = true,
    disable_obsolete_functions: bool = true,
};

/// Build and link zig imgui bindings.
/// Usage: link(b, exe, .{});
///
/// Remeber to also call
/// `exe.addPackagePath("zimgui", "deps/zimgui/src/zimgui.zig");`
pub fn link(b: *Builder, exe: *std.build.LibExeObjStep, _opts: BuildOptions) *std.build.LibExeObjStep {
    var opts: BuildOptions = _opts;
    if (opts.build_mode == null) opts.build_mode = exe.build_mode;
    if (opts.target == null) opts.target = exe.target;
    if (opts.disable_obsolete_keyio) exe.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    if (opts.disable_obsolete_functions) exe.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);

    const lib = buildLibrary(b, opts);
    exe.linkLibrary(lib);
    
    return lib;
}

pub fn buildLibrary(b: *Builder, opts: BuildOptions) *std.build.LibExeObjStep {
    const lib = b.addStaticLibrary("zimgui", relativePath(b, "src/zimgui.zig"));
    if (opts.build_mode) |build_mode| lib.setBuildMode(build_mode);
    if (opts.target) |target| lib.setTarget(target);

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
    
    if (opts.impl_opengl3) {
        // In OpenGL3, this is our texture id, let imgui know.
        lib.defineCMacro("ImTextureID", "unsigned int");
    }

    lib.addIncludePath(relativePath(b, "deps/imgui"));
    lib.addIncludePath(relativePath(b, "deps/stb"));
    lib.linkLibCpp();

    lib.install();
    return lib;
}

/// Use OpenGL3 as rendering backend, and Glfw for windowing.
///
/// Remeber to also call
/// `exe.addPackagePath("zimgui_backend", "deps/zimgui/src/backend_glfw_opengl3.zig");`
///
pub fn addBackendGlfwOpenGl3(b: *Builder, exe: *std.build.LibExeObjStep, opts: BuildOptions) void {
    if (!opts.impl_opengl3) @panic("You must enable this: opts.impl_opengl3");
    exe.defineCMacro("IMGUI_IMPL_OPENGL_LOADER_GLAD", null);
    // In OpenGL3, this is our texture id, let imgui know.
    exe.defineCMacro("ImTextureID", "unsigned int");

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
