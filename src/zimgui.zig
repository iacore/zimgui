const std = @import("std");
const assert = std.debug.assert;

///////////////////////////////////////////////////////////////////////////////
// functions
//

pub fn init() void {
    if (getCurrentContext() == null) {
        _ = zimgui_createContext(null);
        fmt_buffer.resize(4096) catch unreachable;
    }
}

pub fn deinit() void {
    if (zimgui_getCurrentContext() != null) {
        fmt_buffer.deinit();
        zimgui_destoryContext(null);
    }
}

// Context creation and access
// - Each context create its own ImFontAtlas by default. You may instance one yourself and pass it to CreateContext() to share a font atlas between contexts.
pub fn createContext(shared_font_atlas: ?*const FontAtlas) Context {
    return zimgui_createContext(shared_font_atlas);
}
extern fn zimgui_createContext(shared_font_atlas: ?*const FontAtlas) Context;

// NULL = destroy current context
pub fn destoryContext(context: ?Context) void {
    zimgui_destoryContext(context);
}
extern fn zimgui_destoryContext(context: ?Context) void;

pub fn getCurrentContext() ?Context {
    return zimgui_getCurrentContext();
}
extern fn zimgui_getCurrentContext() ?Context;

///////////////////////////////////////////////////////////////////////////////

// start a new Dear ImGui frame, you can submit any command from this point until Render()/EndFrame().
pub fn newFrame() void {
    zimgui_newFrame();
}
extern fn zimgui_newFrame() void;

// ends the Dear ImGui frame. automatically called by Render(). If you don't need to render data (skipping rendering) you may call EndFrame() without Render()... but you'll have wasted CPU already! If you don't need to render, better to not create any windows and not call NewFrame() at all!
pub fn endFrame() void {
    zimgui_endFrame();
}
extern fn zimgui_endFrame() void;

// ends the Dear ImGui frame, finalize the draw data. You can then get call GetDrawData().
pub fn render() void {
    zimgui_render();
}
extern fn zimgui_render() void;

pub fn getDrawData() ?DrawData {
    return zimgui_getDrawData();
}
extern fn zimgui_getDrawData() ?DrawData;

///////////////////////////////////////////////////////////////////////////////

// create Demo window. demonstrate most ImGui features. call this to learn about the library! try to make it always available in your application!
pub fn showDemoWindow(open: *bool) void {
    zimgui_showDemoWindow(open);
}
extern fn zimgui_showDemoWindow(*bool) void;

// create Metrics/Debugger window. display Dear ImGui internals: windows, draw commands, various internal state, etc.
pub fn showMetricsWindow(open: *bool) void {
    zimgui_showMetricsWindow(open);
}
extern fn zimgui_showMetricsWindow(*bool) void;

// create Stack Tool window. hover items with mouse to query information about the source of their unique ID.
pub fn showStackToolWindow(open: *bool) void {
    zimgui_showStackToolWindow(open);
}
extern fn zimgui_showStackToolWindow(*bool) void;

pub fn getVersion() [*:0]const u8 {
    return zimgui_getVersion();
}
extern fn zimgui_getVersion() [*:0]const u8;

///////////////////////////////////////////////////////////////////////////////

// Windows
// - Begin() = push window to the stack and start appending to it. End() = pop window from the stack.
// - Passing 'bool* p_open != NULL' shows a window-closing widget in the upper-right corner of the window,
//   which clicking will set the boolean to false when clicked.
// - You may append multiple times to the same window during the same frame by calling Begin()/End() pairs multiple times.
//   Some information such as 'flags' or 'p_open' will only be considered by the first call to Begin().
// - Begin() return false to indicate the window is collapsed or fully clipped, so you may early out and omit submitting
//   anything to the window. Always call a matching End() for each Begin() call, regardless of its return value!
//   [Important: due to legacy reason, this is inconsistent with most other functions such as BeginMenu/EndMenu,
//    BeginPopup/EndPopup, etc. where the EndXXX call should only be called if the corresponding BeginXXX function
//    returned true. Begin and BeginChild are the only odd ones out. Will be fixed in a future update.]
// - Note that the bottom of window stack always contains a window called "Debug".
pub fn begin(name: [*:0]const u8, open: ?*bool, flags: WindowFlags) void {
    zimgui_begin(name, open, @bitCast(u32, flags));
}
extern fn zimgui_begin([*:0]const u8, ?*bool, u32) void;

pub fn end() void {
    zimgui_end();
}
extern fn zimgui_end() void;

///////////////////////////////////////////////////////////////////////////////

// modify a style color. always use this if you modify the style after NewFrame().
pub fn pushStyleColor(style_col: StyleCol, color: u32) void {
    zimgui_pushStyleColor(@enumToInt(style_col), color);
}
extern fn zimgui_pushStyleColor(u32, u32) void;

pub fn popStyleColor(count: i32) void {
    zimgui_popStyleColor(count);
}
extern fn zimgui_popStyleColor(i32) void;

///////////////////////////////////////////////////////////////////////////////

pub fn separator() void {
    zimgui_separator();
}
extern fn zimgui_separator() void;

/// @param offset_from_start_x Default 0.0
/// @param spacing Default 0.0
pub fn sameLine(offset_from_start_x: f32, spacing: f32) void {
    zimgui_sameLine(offset_from_start_x, spacing);
}
extern fn zimgui_sameLine(f32, f32) void;

pub fn text(comptime fmt: []const u8, args: anytype) void {
    const res = format(fmt, args);
    zimgui_textUnformatted(res.ptr, res.len);
}
extern fn zimgui_textUnformatted([*]const u8, usize) void;

pub fn textColored(color: Vec4, comptime fmt: []const u8, args: anytype) void {
    const res = formatZ(fmt, args);
    zimgui_textColored(color.x, color.y, color.z, color.w, res.ptr, res.len);
}
extern fn zimgui_textColored(f32, f32, f32, f32, [*]const u8, usize) void;

pub fn button(comptime fmt: []const u8, args: anytype, size: ?Vec2) bool {
    var res = formatZ(fmt, args);

    if (size) |s| {
        return zimgui_button(res.ptr, s.x, s.y);
    } else {
        return zimgui_button(res.ptr, 0, 0);
    }
}
extern fn zimgui_button([*:0]const u8, f32, f32) bool;

pub fn sliderInt(comptime fmt: []const u8, args: anytype, v: *i32, min: i32, max: i32) bool {
    var res = formatZ(fmt, args);
    return zimgui_sliderInt(res.ptr, v, min, max);
}
extern fn zimgui_sliderInt([*]const u8, *i32, i32, i32) bool;

///////////////////////////////////////////////////////////////////////////////

/// @param wrap_width Default -1.0
pub fn calcTextSize(txt: []const u8, wrap_width: f32) Vec2 {
    var out: Vec2 = undefined;
    zimgui_calcTextSize(txt.ptr, txt.len, wrap_width, &out.x, &out.y);
    return out;
}
extern fn zimgui_calcTextSize([*]const u8, usize, f32, *f32, *f32) void;

///////////////////////////////////////////////////////////////////////////////

/// Convert f32: [0.0, 1.0] -> u8: [0, 255]
pub fn colorF32ToU8(in: f32) u8 {
    return @floatToInt(u8, (std.math.clamp(in, 0.0, 1.0) * 255.0 + 0.5));
}

///////////////////////////////////////////////////////////////////////////////
// Structs
//

pub const Context = *opaque{
    pub fn getIo(context: Context) Io {
        return zimgui_Context_getIo(context);
    }
    extern fn zimgui_Context_getIo(Context) Io;

    pub fn getStyle(context: Context) Style {
        return zimgui_Context_getStyle(context);
    }
    extern fn zimgui_Context_getStyle(Context) Style;

    pub fn getCurrentWindow(context: Context) Window {
        return zimgui_Context_getCurrentWindow(context);
    }
    extern fn zimgui_Context_getCurrentWindow(Context) Window;

    pub fn getFont(context: Context) Font {
        return zimgui_Context_getFont(context);
    }
    extern fn zimgui_Context_getFont(Context) Font;

    ///////////////////////
    // Extension to imgui used in project Zinc, src in /src/zimgui_draw.cpp

    // Add text, with the posiblility of coloring subsections of it.
    pub fn Ext_addText(context: Context, font_size: f32, pos: Vec2, txt: []const u8, wrap_width: f32, cpu_fine_clip_rect: ?*const Vec4, colorlen: []const u32) void {
        if (cpu_fine_clip_rect) |clip_rect| {
            zimgui_Ext_addText(context, font_size, pos.x, pos.y, txt.ptr, txt.len, wrap_width, &clip_rect.x, &clip_rect.y, &clip_rect.z, &clip_rect.w, colorlen.ptr, colorlen.len);
        } else {
            zimgui_Ext_addText(context, font_size, pos.x, pos.y, txt.ptr, txt.len, wrap_width, null, null, null, null, colorlen.ptr, colorlen.len);
        }
    }
    extern fn zimgui_Ext_addText(Context, f32, f32, f32, [*]const u8, usize, f32, ?*const f32, ?*const f32, ?*const f32, ?*const f32, [*]const u32, usize) void;

    pub fn Ext_calcBbForCharInText(context: Context, font_size: f32, pos: Vec2, txt: []const u8, wrap_width: f32, char_index: usize) ?Rect {
        var out = Rect{.min = Vec2{.x = -1, .y = -1}, .max = Vec2{.x = -1, .y = -1}};
        zimgui_Ext_calcBbForCharInText(context, font_size, pos.x, pos.y, txt.ptr, txt.len, wrap_width, char_index, &out.min.x, &out.min.y, &out.max.x, &out.max.y);
        if (out.min.x == -1 or out.min.y == -1 or out.max.x == -1 or out.max.y == -1) {
            return null;
        }
        return out;
    }
    extern fn zimgui_Ext_calcBbForCharInText(Context, f32, f32, f32, [*]const u8, usize, f32, usize, *f32, *f32, *f32, *f32) void;
};

pub const Font = *opaque{
    pub fn getFallbackAdvanceX(font: Font) f32 {
        return zimgui_Font_getFallbackAdvanceX(font);
    }
    extern fn zimgui_Font_getFallbackAdvanceX(Font) f32;

    pub fn getFontSize(font: Font) f32 {
        return zimgui_Font_getFontSize(font);
    }
    extern fn zimgui_Font_getFontSize(Font) f32;
};

pub const DrawData = *opaque{};

pub const Io = *opaque{
    pub fn getFontAtlas(io: Io) FontAtlas {
        return zimgui_Io_getFontAtlas(io);
    }
    extern fn zimgui_Io_getFontAtlas(Io) FontAtlas;

    pub fn setDisplaySize(io: Io, display_size: Vec2) void {
        zimgui_Io_setDisplaySize(io, display_size.x, display_size.y);
    }
    extern fn zimgui_Io_setDisplaySize(Io, f32, f32) void;
};

pub const FontAtlas = *opaque{
    pub fn getTexDataAsRGBA32(font_atlas: FontAtlas, text_pixels: *[*:0]u8, text_w: *i32, text_h: *i32, bytes_per_pixel: *i32) void {
        zimgui_FontAtlas_getTexDataAsRGBA32(font_atlas, text_pixels, text_w, text_h, bytes_per_pixel);
    }
    extern fn zimgui_FontAtlas_getTexDataAsRGBA32(font_atlas: FontAtlas, text_pixels: *[*:0]u8, text_w: *i32, text_h: *i32, bytes_per_pixel: *i32) void;

    pub fn addFontFromFileTTF(font_atlas: FontAtlas, filename: [*:0]const u8, size_pixels: f32) void {
        zimgui_FontAtlas_addFontFromFileTTF(font_atlas, filename, size_pixels);
    }
    extern fn zimgui_FontAtlas_addFontFromFileTTF(font_atlas: FontAtlas, filename: [*:0]const u8, size_pixels: f32) void;

    pub fn build(font_atlas: FontAtlas) bool {
        return zimgui_FontAtlas_build(font_atlas);
    }
    extern fn zimgui_FontAtlas_build(FontAtlas) bool;
};

pub const Style = *opaque{
    pub fn setColor(style: Style, style_col: StyleCol, color: Vec4) void {
        zimgui_Style_setColor(style, @enumToInt(style_col), color.x, color.y, color.z, color.w);
    }
    extern fn zimgui_Style_setColor(Style, u32, f32, f32, f32, f32) void;

    pub fn getColor(style: Style, style_col: StyleCol) Vec4 {
        var out: Vec4 = undefined;
        zimgui_Style_getColor(style, @enumToInt(style_col), &out.x, &out.y, &out.z, &out.w);
        return out;
    }
    extern fn zimgui_Style_getColor(Style, u32, *f32, *f32, *f32, *f32) void;

    // Padding within a framed rectangle (used by most widgets).
    pub fn getFramePadding(style: Style) Vec2 {
        var frame_padding: Vec2 = undefined;
        zimgui_Style_getFramePadding(style, &frame_padding.x, &frame_padding.y);
        return frame_padding;
    }
    extern fn zimgui_Style_getFramePadding(Style, *f32, *f32) void;

    // Horizontal and vertical spacing between widgets/lines.
    pub fn getItemSpacing(style: Style) Vec2 {
        var item_spacing: Vec2 = undefined;
        zimgui_Style_getItemSpacing(style, &item_spacing.x, &item_spacing.y);
        return item_spacing;
    }
    extern fn zimgui_Style_getItemSpacing(Style, *f32, *f32) void;

    // Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
    pub fn getItemInnerSpacing(style: Style) Vec2 {
        var item_inner_spacing: Vec2 = undefined;
        zimgui_Style_getItemInnerSpacing(style, &item_inner_spacing.x, &item_inner_spacing.y);
        return item_inner_spacing;
    }
    extern fn zimgui_Style_getItemInnerSpacing(Style, *f32, *f32) void;
};

pub const Window = *opaque{
    pub fn getDrawList(window: Window) DrawList {
        return zimgui_Window_getDrawList(window);
    }
    extern fn zimgui_Window_getDrawList(Window) DrawList;

    pub fn getPos(window: Window) Vec2 {
        var pos: Vec2 = undefined;
        zimgui_Window_getPos(window, &pos.x, &pos.y);
        return pos;
    }
    extern fn zimgui_Window_getPos(Window, *f32, *f32) void;

    pub fn getSize(window: Window) Vec2 {
        var size: Vec2 = undefined;
        zimgui_Window_getSize(window, &size.x, &size.y);
        return size;
    }
    extern fn zimgui_Window_getSize(Window, *f32, *f32) void;
};

pub const DrawList = *opaque{
    // Primitives
    // - Filled shapes must always use clockwise winding order. The anti-aliasing fringe depends on it. Counter-clockwise shapes will have "inward" anti-aliasing.
    // - For rectangular primitives, "p_min" and "p_max" represent the upper-left and lower-right corners.
    // - For circle primitives, use "num_segments == 0" to automatically calculate tessellation (preferred).
    //   In older versions (until Dear ImGui 1.77) the AddCircle functions defaulted to num_segments == 12.
    //   In future versions we will use textures to provide cheaper and higher-quality circles.
    //   Use AddNgon() and AddNgonFilled() functions if you need to guaranteed a specific number of sides.
    /// @param thickness Default 1.0
    pub fn addLine(draw_list: DrawList, p1: Vec2, p2: Vec2, color: u32, thickness: f32) void {
        zimgui_DrawList_addLine(draw_list, p1.x, p1.y, p2.x, p2.y, color, thickness);
    }
    extern fn zimgui_DrawList_addLine(DrawList, f32, f32, f32, f32, u32, f32) void;

    pub fn addRectFilled(draw_list: DrawList, rect: Rect, color: u32, rounding: f32, flags: DrawFlags) void {
        zimgui_DrawList_addRectFilled(draw_list, rect.min.x, rect.min.y, rect.max.x, rect.max.y, color, rounding, @enumToInt(flags));
    }
    extern fn zimgui_DrawList_addRectFilled(DrawList, f32, f32, f32, f32, u32, f32, u32) void;
};

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn add(this: *Vec2, other: Vec2) void {
        this.x += other.x;
        this.y += other.y;
    }

    // Immutable version of `add`, creates a new copy instead of reusing first arg.
    pub fn newAdd(a: Vec2, b: Vec2) Vec2 {
        return Vec2{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }
};

pub const Vec4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    /// If the Vec4 is used to store color, convert it to same representation in u32.
    pub fn colorConvert(color: Vec4) u32 {
        var out: u32 = @intCast(u32, colorF32ToU8(color.x)) << col32_r_shift;
        out |= @intCast(u32, colorF32ToU8(color.y)) << col32_g_shift;
        out |= @intCast(u32, colorF32ToU8(color.z)) << col32_b_shift;
        out |= @intCast(u32, colorF32ToU8(color.w)) << col32_a_shift;
        return out;
    }
};

pub const Rect = struct {
    min: Vec2,
    max: Vec2,
};

///////////////////////////////////////////////////////////////////////////////
// Constants
//

pub const col32_r_shift = 16;
pub const col32_g_shift = 8;
pub const col32_b_shift = 0;
pub const col32_a_shift = 24;
pub const col32_a_mask = 0xFF000000;

///////////////////////////////////////////////////////////////////////////////
// Enums
//

// Flags for ImGui::Begin()
pub const WindowFlags = packed struct {
    NoTitleBar: bool = false,   // Disable title-bar
    NoResize: bool = false,   // Disable user resizing with the lower-right grip
    NoMove: bool = false,   // Disable user moving the window
    NoScrollbar: bool = false,   // Disable scrollbars (window can still scroll with mouse or programmatically)
    NoScrollWithMouse: bool = false,   // Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
    NoCollapse: bool = false,   // Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).
    AlwaysAutoResize: bool = false,   // Resize every window to its content every frame
    NoBackground: bool = false,   // Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
    NoSavedSettings: bool = false,   // Never load/save settings in .ini file
    NoMouseInputs: bool = false,   // Disable catching mouse, hovering test with pass through.
    MenuBar: bool = false,  // Has a menu-bar
    HorizontalScrollbar: bool = false,  // Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
    NoFocusOnAppearing: bool = false,  // Disable taking focus when transitioning from hidden to visible state
    NoBringToFrontOnFocus: bool = false,  // Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
    AlwaysVerticalScrollbar: bool = false,  // Always show vertical scrollbar (even if ContentSize.y < Size.y)
    AlwaysHorizontalScrollbar: bool = false,  // Always show horizontal scrollbar (even if ContentSize.x < Size.x)
    AlwaysUseWindowPadding: bool = false,  // Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
    NoNavInputs: bool = false,  // No gamepad/keyboard navigation within the window
    NoNavFocus: bool = false,  // No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
    UnsavedDocument: bool = false,  // Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
    _padding: u12 = 0,

    pub const NoNav = WindowFlags{.NoNavInputs = true, .NoNavFocus = true};
    pub const NoDecoration = WindowFlags{.NoTitleBar = true, .NoResize = true, .NoScrollbar = true, .NoCollapse = true};
    pub const NoInputs = WindowFlags{.NoMouseInputs = true, .NoNavInputs = true, .NoNavFocus= true};

    comptime {
        assert(@sizeOf(@This()) == @sizeOf(u32) and @bitSizeOf(@This()) == @bitSizeOf(u32));
    }
};

// Enumeration for PushStyleColor() / PopStyleColor()
pub const StyleCol = enum(u32) {
    Text,
    TextDisabled,
    WindowBg,              // Background of normal windows
    ChildBg,               // Background of child windows
    PopupBg,               // Background of popups, menus, tooltips windows
    Border,
    BorderShadow,
    FrameBg,               // Background of checkbox, radio button, plot, slider, text input
    FrameBgHovered,
    FrameBgActive,
    TitleBg,
    TitleBgActive,
    TitleBgCollapsed,
    MenuBarBg,
    ScrollbarBg,
    ScrollbarGrab,
    ScrollbarGrabHovered,
    ScrollbarGrabActive,
    CheckMark,
    SliderGrab,
    SliderGrabActive,
    Button,
    ButtonHovered,
    ButtonActive,
    Header,                // Header* colors are used for CollapsingHeader, TreeNode, Selectable, MenuItem
    HeaderHovered,
    HeaderActive,
    Separator,
    SeparatorHovered,
    SeparatorActive,
    ResizeGrip,            // Resize grip in lower-right and lower-left corners of windows.
    ResizeGripHovered,
    ResizeGripActive,
    Tab,                   // TabItem in a TabBar
    TabHovered,
    TabActive,
    TabUnfocused,
    TabUnfocusedActive,
    PlotLines,
    PlotLinesHovered,
    PlotHistogram,
    PlotHistogramHovered,
    TableHeaderBg,         // Table header background
    TableBorderStrong,     // Table outer and header borders (prefer using Alpha=1.0 here)
    TableBorderLight,      // Table inner borders (prefer using Alpha=1.0 here)
    TableRowBg,            // Table row background (even rows)
    TableRowBgAlt,         // Table row background (odd rows)
    TextSelectedBg,
    DragDropTarget,        // Rectangle highlighting a drop target
    NavHighlight,          // Gamepad/keyboard: current highlighted item
    NavWindowingHighlight, // Highlight window when using CTRL+TAB
    NavWindowingDimBg,     // Darken/colorize entire screen behind the CTRL+TAB window list, when active
    ModalWindowDimBg,      // Darken/colorize entire screen behind a modal window, when one is active
    COUNT,
};

// Flags for ImDrawList functions
// (Legacy: bit 0 must always correspond to ImDrawFlags_Closed to be backward compatible with old API using a bool. Bits 1..3 must be unused)
pub const DrawFlags = enum(u32) {
    None                        = 0,
    Closed                      = 1 << 0, // PathStroke(), AddPolyline(): specify that shape should be closed (Important: this is always == 1 for legacy reason)
    RoundCornersTopLeft         = 1 << 4, // AddRect(), AddRectFilled(), PathRect(): enable rounding top-left corner only (when rounding > 0.0f, we default to all corners). Was 0x01.
    RoundCornersTopRight        = 1 << 5, // AddRect(), AddRectFilled(), PathRect(): enable rounding top-right corner only (when rounding > 0.0f, we default to all corners). Was 0x02.
    RoundCornersBottomLeft      = 1 << 6, // AddRect(), AddRectFilled(), PathRect(): enable rounding bottom-left corner only (when rounding > 0.0f, we default to all corners). Was 0x04.
    RoundCornersBottomRight     = 1 << 7, // AddRect(), AddRectFilled(), PathRect(): enable rounding bottom-right corner only (when rounding > 0.0f, we default to all corners). Wax 0x08.
    RoundCornersNone            = 1 << 8, // AddRect(), AddRectFilled(), PathRect(): disable rounding on all corners (when rounding > 0.0f). This is NOT zero, NOT an implicit flag!
    RoundCornersTop             = 1 << 4 | 1 << 5,
    RoundCornersBottom          = 1 << 6 | 1 << 7,
    RoundCornersLeft            = 1 << 6 | 1 << 4,
    RoundCornersRight           = 1 << 7 | 1 << 5,
    RoundCornersAll             = 1 << 4 | 1 << 5 | 1 << 6 | 1 << 7,

    // NOTE cannot have same value as other enum in zig
    //RoundCornersDefault_        = RoundCornersAll, // Default to ALL corners if none of the _RoundCornersXX flags are specified.
    RoundCornersMask_           = 1 << 4 | 1 << 5 | 1 << 6 | 1 << 7 | 1 << 8,
};

///////////////////////////////////////////////////////////////////////////////
// Zinc Extensions
//

/// -*- Solarized Light/Dark -*-
/// http://www.zovirl.com/2011/07/22/solarized_cheat_sheet/
pub const ColorSolarized = struct {
    /// light:
    ///  base 01 - emphasized content
    ///  base 00 - body text / primary content
    ///  base 1  - comments / secondary content
    ///  base 2  - background highlights
    ///  base 3  - background
    pub const base03 = Vec4{ .x = 0.00, .y = 0.17, .z = 0.21, .w = 1.00 };
    pub const base02 = Vec4{ .x = 0.03, .y = 0.21, .z = 0.26, .w = 1.00 };
    pub const base01 = Vec4{ .x = 0.35, .y = 0.43, .z = 0.46, .w = 1.00 };
    pub const base00 = Vec4{ .x = 0.40, .y = 0.48, .z = 0.51, .w = 1.00 };
    pub const base0 = Vec4{ .x = 0.51, .y = 0.58, .z = 0.59, .w = 1.00 };
    pub const base1 = Vec4{ .x = 0.58, .y = 0.63, .z = 0.63, .w = 1.00 };
    pub const base2 = Vec4{ .x = 0.93, .y = 0.91, .z = 0.84, .w = 1.00 };
    pub const base3 = Vec4{ .x = 0.99, .y = 0.96, .z = 0.89, .w = 1.00 };
    pub const yellow = Vec4{ .x = 0.71, .y = 0.54, .z = 0.00, .w = 1.00 };
    pub const orange = Vec4{ .x = 0.80, .y = 0.29, .z = 0.09, .w = 1.00 };
    pub const red = Vec4{ .x = 0.86, .y = 0.20, .z = 0.18, .w = 1.00 };
    pub const magenta = Vec4{ .x = 0.83, .y = 0.21, .z = 0.51, .w = 1.00 };
    pub const violet = Vec4{ .x = 0.42, .y = 0.44, .z = 0.77, .w = 1.00 };
    pub const blue = Vec4{ .x = 0.15, .y = 0.55, .z = 0.82, .w = 1.00 };
    pub const cyan = Vec4{ .x = 0.16, .y = 0.63, .z = 0.60, .w = 1.00 };
    pub const green = Vec4{ .x = 0.52, .y = 0.60, .z = 0.00, .w = 1.00 };

    /// RGBA
    pub const rgbabase03 = 0xFF36_2B00;
    pub const rgbabase02 = 0xFF42_3607;
    pub const rgbabase01 = 0xFF75_6E58;
    pub const rgbabase00 = 0xFF83_7B65;
    pub const rgbabase0 = 0xFF96_9483;
    pub const rgbabase1 = 0xFFA1_A193;
    pub const rgbabase2 = 0xFFD5_E8EE;
    pub const rgbabase3 = 0xFFE3_F6FD;
    pub const rgbayellow = 0xFF00_89B5;
    pub const rgbaorange = 0xFF16_4BCB;
    pub const rgbared = 0xFF2F_32DC;
    pub const rgbamagenta = 0xFF82_36D3;
    pub const rgbaviolet = 0xFFC4_716C;
    pub const rgbablue = 0xFFD2_8B26;
    pub const rgbacyan = 0xFF98_A12A;
    pub const rgbagreen = 0xFF00_9985;

};

pub fn setImguiTheme() void {
    // If you crash here you are calling this before creating a context.
    var ctx = getCurrentContext() orelse unreachable;
    var style = ctx.getStyle();

    style.setColor(StyleCol.Text, ColorSolarized.base00);
    style.setColor(StyleCol.TextDisabled, ColorSolarized.base1);
    style.setColor(StyleCol.WindowBg, ColorSolarized.base3);
    style.setColor(StyleCol.ChildBg, ColorSolarized.base3);
    style.setColor(StyleCol.PopupBg, ColorSolarized.base3);
    style.setColor(StyleCol.Border, ColorSolarized.base2);
    style.setColor(StyleCol.BorderShadow, Vec4{ .x = 0.00, .y = 0.00, .z = 0.00, .w = 0.00 });
    style.setColor(StyleCol.FrameBg, ColorSolarized.base3);
    style.setColor(StyleCol.FrameBgHovered, ColorSolarized.base3);
    style.setColor(StyleCol.FrameBgActive, ColorSolarized.base3);
    style.setColor(StyleCol.TitleBg, ColorSolarized.base2);
    style.setColor(StyleCol.TitleBgActive, ColorSolarized.base2);
    style.setColor(StyleCol.TitleBgCollapsed, ColorSolarized.base3);
    style.setColor(StyleCol.MenuBarBg, ColorSolarized.base2);
    style.setColor(StyleCol.ScrollbarBg, Vec4{ .x = 0.98, .y = 0.98, .z = 0.98, .w = 0.53 });
    style.setColor(StyleCol.ScrollbarGrab, Vec4{ .x = 0.69, .y = 0.69, .z = 0.69, .w = 0.80 });
    style.setColor(StyleCol.ScrollbarGrabHovered, Vec4{ .x = 0.49, .y = 0.49, .z = 0.49, .w = 0.80 });
    style.setColor(StyleCol.ScrollbarGrabActive, Vec4{ .x = 0.49, .y = 0.49, .z = 0.49, .w = 1.00 });
    style.setColor(StyleCol.CheckMark, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 });
    style.setColor(StyleCol.SliderGrab, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.78 });
    style.setColor(StyleCol.SliderGrabActive, Vec4{ .x = 0.46, .y = 0.54, .z = 0.80, .w = 0.60 });
    style.setColor(StyleCol.Button, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.40 });
    style.setColor(StyleCol.ButtonHovered, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 });
    style.setColor(StyleCol.ButtonActive, Vec4{ .x = 0.06, .y = 0.53, .z = 0.98, .w = 1.00 });
    style.setColor(StyleCol.Header, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.31 });
    style.setColor(StyleCol.HeaderHovered, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 });
    style.setColor(StyleCol.HeaderActive, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 });
    style.setColor(StyleCol.Separator, Vec4{ .x = 0.39, .y = 0.39, .z = 0.39, .w = 0.62 });
    style.setColor(StyleCol.SeparatorHovered, Vec4{ .x = 0.14, .y = 0.44, .z = 0.80, .w = 0.78 });
    style.setColor(StyleCol.SeparatorActive, Vec4{ .x = 0.14, .y = 0.44, .z = 0.80, .w = 1.00 });
    style.setColor(StyleCol.ResizeGrip, Vec4{ .x = 0.35, .y = 0.35, .z = 0.35, .w = 0.17 });
    style.setColor(StyleCol.ResizeGripHovered, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.67 });
    style.setColor(StyleCol.ResizeGripActive, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.95 });
    style.setColor(StyleCol.Tab, Vec4{ .x = 0.76, .y = 0.80, .z = 0.84, .w = 0.93 });
    style.setColor(StyleCol.TabHovered, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 });
    style.setColor(StyleCol.TabActive, Vec4{ .x = 0.60, .y = 0.73, .z = 0.88, .w = 1.00 });
    style.setColor(StyleCol.TabUnfocused, Vec4{ .x = 0.92, .y = 0.93, .z = 0.94, .w = 0.99 });
    style.setColor(StyleCol.TabUnfocusedActive, Vec4{ .x = 0.74, .y = 0.82, .z = 0.91, .w = 1.00 });
    style.setColor(StyleCol.PlotLines, Vec4{ .x = 0.39, .y = 0.39, .z = 0.39, .w = 1.00 });
    style.setColor(StyleCol.PlotLinesHovered, Vec4{ .x = 1.00, .y = 0.43, .z = 0.35, .w = 1.00 });
    style.setColor(StyleCol.PlotHistogram, Vec4{ .x = 0.90, .y = 0.70, .z = 0.00, .w = 1.00 });
    style.setColor(StyleCol.PlotHistogramHovered, Vec4{ .x = 1.00, .y = 0.45, .z = 0.00, .w = 1.00 });
    style.setColor(StyleCol.TableHeaderBg, Vec4{ .x = 0.78, .y = 0.87, .z = 0.98, .w = 1.00 });
    style.setColor(StyleCol.TableBorderStrong, Vec4{ .x = 0.57, .y = 0.57, .z = 0.64, .w = 1.00 });
    style.setColor(StyleCol.TableBorderLight, Vec4{ .x = 0.68, .y = 0.68, .z = 0.74, .w = 1.00 });
    style.setColor(StyleCol.TableRowBg, Vec4{ .x = 0.00, .y = 0.00, .z = 0.00, .w = 0.00 });
    style.setColor(StyleCol.TableRowBgAlt, Vec4{ .x = 0.30, .y = 0.30, .z = 0.30, .w = 0.09 });
    style.setColor(StyleCol.TextSelectedBg, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.35 });
    style.setColor(StyleCol.DragDropTarget, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.95 });
    style.setColor(StyleCol.NavHighlight, Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 });
    style.setColor(StyleCol.NavWindowingHighlight, Vec4{ .x = 0.70, .y = 0.70, .z = 0.70, .w = 0.70 });
    style.setColor(StyleCol.NavWindowingDimBg, Vec4{ .x = 0.20, .y = 0.20, .z = 0.20, .w = 0.20 });
    style.setColor(StyleCol.ModalWindowDimBg, Vec4{ .x = 0.20, .y = 0.20, .z = 0.20, .w = 0.35 });
}

///////////////////////////////////////////////////////////////////////////////
// Helper - make it seamless to format text
//

var fmt_buffer: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.c_allocator);

/// @return Memory only valid until next call to format. Not thread safe.
fn format(comptime fmt: []const u8, args: anytype) []const u8 {
    const len = std.fmt.count(fmt, args);
    if (len > fmt_buffer.items.len) fmt_buffer.resize(len + 64) catch unreachable;
    return std.fmt.bufPrint(fmt_buffer.items, fmt, args) catch unreachable;
}

fn formatZ(comptime fmt: []const u8, args: anytype) [:0]const u8 {
    const len = std.fmt.count(fmt, args);
    if (len > fmt_buffer.items.len) fmt_buffer.resize(len + 64) catch unreachable;
    return std.fmt.bufPrintZ(fmt_buffer.items, fmt, args) catch unreachable;
}
