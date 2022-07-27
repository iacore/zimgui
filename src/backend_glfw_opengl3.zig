const std = @import("std");
const c = @cImport({
    @cInclude("backends/imgui_impl_glfw.h");
    @cInclude("backends/imgui_impl_opengl3.h");
});

pub const Glfw = struct {
    pub fn initForOpenGL(window: *anyopaque) bool {
        return c.ImGui_ImplGlfw_InitForOpenGL(@ptrCast(c.GLFWwindow, window));
    }

    pub fn newFrame() void {
        c.ImGui_ImplGlfw_NewFrame();
    }
};

pub const OpenGL3 = struct {
    pub fn init(glsl_version: [*c]const u8) bool {
        return c.ImGui_ImplOpenGL3_Init(glsl_version);
    }

    pub fn newFrame() void {
        c.ImGui_ImplOpenGL3_NewFrame();
    }

    pub fn renderDrawData(draw_data: *anyopaque) void {
        c.ImGui_ImplOpenGL3_RenderDrawData(draw_data);
    }
};
