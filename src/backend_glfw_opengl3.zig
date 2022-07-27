const std = @import("std");

pub const Glfw = struct {
    pub fn initForOpenGL(window: *anyopaque, install_callbacks: bool) bool {
        return Z_ImGui_ImplGlfw_InitForOpenGL(window, install_callbacks);
    }
    extern fn Z_ImGui_ImplGlfw_InitForOpenGL(*anyopaque, bool) bool;

    pub fn newFrame() void {
        Z_ImGui_ImplGlfw_NewFrame();
    }
    extern fn Z_ImGui_ImplGlfw_NewFrame() void;
};

pub const OpenGL3 = struct {
    pub fn init(glsl_version: [*c]const u8) bool {
        return Z_ImGui_ImplOpenGL3_Init(glsl_version);
    }
    extern fn Z_ImGui_ImplOpenGL3_Init([*c]const u8) bool;

    pub fn newFrame() void {
        Z_ImGui_ImplOpenGL3_NewFrame();
    }
    extern fn Z_ImGui_ImplOpenGL3_NewFrame() void;

    pub fn renderDrawData(draw_data: *anyopaque) void {
        Z_ImGui_ImplOpenGL3_RenderDrawData(draw_data);
    }
    extern fn Z_ImGui_ImplOpenGL3_RenderDrawData(*anyopaque) void;

    pub fn glViewport(x: c_int, y: c_int, width: usize, height: usize) void {
        Z_glViewport(x, y, width, height);
    }
    extern fn Z_glViewport(c_int, c_int, usize, usize) void;

    pub fn glClearColor(red: f32, green: f32, blue: f32, alpha: f32) void {
        Z_glClearColor(red, green, blue, alpha);
    }
    extern fn Z_glClearColor(f32, f32, f32, f32) void;

    pub fn glClear(mask: ClearMask) void {
        Z_glClear(mask);
    }
    extern fn Z_glClear(ClearMask) void;
};

pub const ClearMask = enum(c_int) {
    GL_COLOR_BUFFER_BIT = 0x00004000,
};
