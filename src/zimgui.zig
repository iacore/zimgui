const std = @import("std");

///////////////////////////////////////////////////////////////////////////////

// Context creation and access
// - Each context create its own ImFontAtlas by default. You may instance one yourself and pass it to CreateContext() to share a font atlas between contexts.
// - DLL users: heaps and globals are not shared across DLL boundaries! You will need to call SetCurrentContext() + SetAllocatorFunctions()
//   for each static/DLL boundary you are calling from. Read "Context and Memory Allocators" section of imgui.cpp for details.
pub const Context = struct {
    data: *anyopaque,

    pub fn init() Context {
        return .Context{.data = ImGui_CreateContext(null)};
    }

    // TODO cgustafsson:
    pub fn initWithFontAtlas() Context {
        unreachable;
    }

    pub fn deinit(context: Context) void {
        ImGui_DestoryContext(context.data);
    }

    pub fn deinitCurrent() void {
        ImGui_DestoryContext(null);
    }

    pub fn current() Context {
        return Context{.data = ImGui_GetCurrentContext()};
    }

    pub fn setCurrent(context: Context) void {
        ImGui_SetCurrentContext(context.data);
    }

    extern fn ImGui_CreateContext(shared_font_atlas: *anyopaque) *anyopaque;
    extern fn ImGui_DestoryContext(context: *anyopaque) void;
    extern fn ImGui_GetCurrentContext() *anyopaque;
    extern fn ImGui_SetCurrentContext(context: *anyopaque) void;
};

pub const IO = struct {
    
};

pub const Style = struct {
    
};

pub const Font = struct {
    
};

pub const DrawData = struct {
    data: *anyopaque,

    // valid after Render() and until the next call to newFrame(). this is what you have to render.
    pub fn get() *DrawData {
        return DrawData{.data = ImGui_GetDrawData()};
    }

    extern fn ImGui_GetDrawData() *anyopaque;
};

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn add(a: Vec2, b: Vec2) void {
        a.x += b.x;
        a.y += b.y;
    }
};

///////////////////////////////////////////////////////////////////////////////
// Main
//

// start a new Dear ImGui frame, you can submit any command from this point until Render()/EndFrame().
pub fn newFrame() void {
    ImGui_NewFrame();
}

// ends the Dear ImGui frame. automatically called by Render(). If you don't need to render data (skipping rendering) you may call EndFrame() without Render()... but you'll have wasted CPU already! If you don't need to render, better to not create any windows and not call NewFrame() at all!
pub fn endFrame() void {
    ImGui_EndFrame();
}

// ends the Dear ImGui frame, finalize the draw data. You can then get call GetDrawData().
pub fn render() void {
    ImGui_Render();
}

extern fn ImGui_NewFrame() void;
extern fn ImGui_EndFrame() void;
extern fn ImGui_Render() void;

///////////////////////////////////////////////////////////////////////////////
// Demo, Debug
//

// create Demo window. demonstrate most ImGui features. call this to learn about the library! try to make it always available in your application!
pub fn showDemoWindow(open: *bool) void {
    ImGui_ShowDemoWindow(open);
}

pub fn getVersion() [*c]const u8 {
    return ImGui_GetVersion();
}

extern fn ImGui_ShowDemoWindow(open: *bool) void;
extern fn ImGui_GetVersion() [*c]const u8;
