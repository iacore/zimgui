const std = @import("std");

pub const Glfw = struct {
    pub fn initForOpenGL(window: *anyopaque, install_callbacks: bool) bool {
        return zimgui_ImGui_ImplGlfw_InitForOpenGL(window, install_callbacks);
    }
    extern fn zimgui_ImGui_ImplGlfw_InitForOpenGL(*anyopaque, bool) bool;

    pub fn newFrame() void {
        zimgui_ImGui_ImplGlfw_NewFrame();
    }
    extern fn zimgui_ImGui_ImplGlfw_NewFrame() void;
};

pub const OpenGL3 = struct {
    pub fn init(glsl_version: [*c]const u8) bool {
        return zimgui_ImGui_ImplOpenGL3_Init(glsl_version);
    }
    extern fn zimgui_ImGui_ImplOpenGL3_Init([*c]const u8) bool;

    pub fn newFrame() void {
        zimgui_ImGui_ImplOpenGL3_NewFrame();
    }
    extern fn zimgui_ImGui_ImplOpenGL3_NewFrame() void;

    pub fn renderDrawData(draw_data: *anyopaque) void {
        zimgui_ImGui_ImplOpenGL3_RenderDrawData(draw_data);
    }
    extern fn zimgui_ImGui_ImplOpenGL3_RenderDrawData(*anyopaque) void;

    pub fn glViewport(x: c_int, y: c_int, width: usize, height: usize) void {
        zimgui_glViewport(x, y, width, height);
    }
    extern fn zimgui_glViewport(c_int, c_int, usize, usize) void;

    pub fn glClearColor(red: f32, green: f32, blue: f32, alpha: f32) void {
        zimgui_glClearColor(red, green, blue, alpha);
    }
    extern fn zimgui_glClearColor(f32, f32, f32, f32) void;

    pub fn glClear(mask: ClearMask) void {
        zimgui_glClear(mask);
    }
    extern fn zimgui_glClear(ClearMask) void;

    pub fn glGenTextures(textures: []TextureId) void {
        zimgui_glGenTextures(textures.len, textures.ptr);
    }
    extern fn zimgui_glGenTextures(usize, [*]u32) void;

    pub fn glBindTexture(target: GlEnum, texture: TextureId) void {
        zimgui_glBindTexture(target, texture);
    }
    extern fn zimgui_glBindTexture(GlEnum, TextureId) void;

    pub fn glDeleteTextures(textures: []const TextureId) void {
        zimgui_glDeleteTextures(textures.len, textures.ptr);
    }
    extern fn zimgui_glDeleteTextures(usize, [*]const u32) void;

    ///////////////////////////////////////////////////////////////////////////////
    // Types
    //

    const TextureId = u32;

    const GlEnum = enum(u32) {
        COLOR_BUFFER_BIT    = 0x00004000,
        TRIANGLES           = 0x0004,
        ONE                 = 1,
        SRC_ALPHA           = 0x0302,
        ONE_MINUS_SRC_ALPHA = 0x0303,
        FRONT_AND_BACK      = 0x0408,
        POLYGON_MODE        = 0x0B40,
        CULL_FACE           = 0x0B44,
        DEPTH_TEST          = 0x0B71,
        STENCIL_TEST        = 0x0B90,
        VIEWPORT            = 0x0BA2,
        BLEND               = 0x0BE2,
        SCISSOR_BOX         = 0x0C10,
        SCISSOR_TEST        = 0x0C11,
        UNPACK_ROW_LENGTH   = 0x0CF2,
        PACK_ALIGNMENT      = 0x0D05,
        TEXTURE_2D          = 0x0DE1,
        UNSIGNED_BYTE       = 0x1401,
        UNSIGNED_SHORT      = 0x1403,
        UNSIGNED_INT        = 0x1405,
        FLOAT               = 0x1406,
        RGBA                = 0x1908,
        FILL                = 0x1B02,
        VENDOR              = 0x1F00,
        RENDERER            = 0x1F01,
        VERSION             = 0x1F02,
        EXTENSIONS          = 0x1F03,
        LINEAR              = 0x2601,
        TEXTURE_MAG_FILTER  = 0x2800,
        TEXTURE_MIN_FILTER  = 0x2801,
    };
};

pub const ClearMask = enum(c_int) {
    GL_COLOR_BUFFER_BIT = 0x00004000,
};
