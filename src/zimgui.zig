const std = @import("std");
const assert = std.debug.assert;

pub const zimage = @import("zimage.zig");

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
pub fn showDemoWindow(open: ?*bool) void {
    zimgui_showDemoWindow(open);
}
extern fn zimgui_showDemoWindow(?*bool) void;

// create Metrics/Debugger window. display Dear ImGui internals: windows, draw commands, various internal state, etc.
pub fn showMetricsWindow(open: ?*bool) void {
    zimgui_showMetricsWindow(open);
}
extern fn zimgui_showMetricsWindow(?*bool) void;

// create Stack Tool window. hover items with mouse to query information about the source of their unique ID.
pub fn showStackToolWindow(open: ?*bool) void {
    zimgui_showStackToolWindow(open);
}
extern fn zimgui_showStackToolWindow(?*bool) void;

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

// set next window position. call before Begin(). use pivot=(0.5f,0.5f) to center on given point, etc.
pub fn setNextWindowPos(pos: Vec2, cond: GuiCond, pivot: ?Vec2) void {
    if (pivot) |p| {
        zimgui_setNextWindowPos(pos.x, pos.y, @enumToInt(cond), p.x, p.y);
    } else {
        zimgui_setNextWindowPos(pos.x, pos.y, @enumToInt(cond), 0, 0);
    }
}
extern fn zimgui_setNextWindowPos(f32, f32, u32, f32, f32) void;

pub fn setNextWindowSize(size: Vec2, cond: GuiCond) void {
    zimgui_setNextWindowSize(size.x, size.y, @enumToInt(cond));
}
extern fn zimgui_setNextWindowSize(f32, f32, u32) void;

pub fn setNextWindowFocus() void {
    zimgui_setNextWindowFocus();
}
extern fn zimgui_setNextWindowFocus() void;

// set next window size. set axis to 0.0f to force an auto-fit on this axis. call before Begin()

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

pub fn image(textureId: u32, size: Vec2, uv0: ?Vec2, uv1: ?Vec2) void {
    var uv0_: Vec2 = if (uv0) |uv0u| uv0u else Vec2{.x=0, .y=0};
    var uv1_: Vec2 = if (uv1) |uv1u| uv1u else Vec2{.x=1, .y=1};
    zimgui_image(textureId, size.x, size.y, uv0_.x, uv0_.y, uv1_.x, uv1_.y);
}
extern fn zimgui_image(u32, f32, f32, f32, f32, f32, f32) void;

pub fn imageButton(textureId: u32, size: Vec2, uv0: ?Vec2, uv1: ?Vec2) bool {
    var uv0_: Vec2 = if (uv0) |uv0u| uv0u else Vec2{.x=0, .y=0};
    var uv1_: Vec2 = if (uv1) |uv1u| uv1u else Vec2{.x=1, .y=1};
    return zimgui_imageButton(textureId, size.x, size.y, uv0_.x, uv0_.y, uv1_.x, uv1_.y);
}
extern fn zimgui_imageButton(u32, f32, f32, f32, f32, f32, f32) bool;

pub fn imageButtonEx(im_id: u32, texture_id: u32, size: Vec2, uv0: ?Vec2, uv1: ?Vec2) bool {
    var uv0_: Vec2 = if (uv0) |uv0u| uv0u else Vec2{.x=0, .y=0};
    var uv1_: Vec2 = if (uv1) |uv1u| uv1u else Vec2{.x=1, .y=1};
    return zimgui_ext_imageButtonEx(im_id, texture_id, size.x, size.y, uv0_.x, uv0_.y, uv1_.x, uv1_.y);
}
extern fn zimgui_ext_imageButtonEx(u32, u32, f32, f32, f32, f32, f32, f32) bool;

///////////////////////////////////////////////////////////////////////////////

/// Widgets: Combo Box
/// - The BeginCombo()/EndCombo() api allows you to manage your contents and selection state however you want it, by creating e.g. Selectable() items.
pub fn beginCombo(label: []const u8, preview_value: []const u8, flags: ComboFlags) bool {
    var b1: [1024]u8 = undefined;
    var l = copyZ(&b1, label);

    var b2: [1024]u8 = undefined;
    var pv = copyZ(&b2, preview_value);

    return zimgui_beginCombo(l.ptr, pv.ptr, @enumToInt(flags));
}
extern fn zimgui_beginCombo([*]const u8, [*]const u8, u32) bool;

/// only call EndCombo() if BeginCombo() returns true!
pub fn endCombo() void {
    zimgui_endCombo();
}
extern fn zimgui_endCombo() void;

pub fn selectable(label: []const u8, selected: bool, flags: SelectableFlags, size: ?Vec2) bool {
    var b: [1024]u8 = undefined;
    var l = copyZ(&b, label);

    if (size) |s| {
        return zimgui_selectable(l.ptr, selected, @enumToInt(flags), s.x, s.y);
    } else {
        return zimgui_selectable(l.ptr, selected, @enumToInt(flags), 0, 0);
    }
}
extern fn zimgui_selectable([*]const u8, bool, u32, f32, f32) bool;

///////////////////////////////////////////////////////////////////////////////

pub fn sliderInt(comptime fmt: []const u8, args: anytype, v: *i32, min: i32, max: i32) bool {
    var res = formatZ(fmt, args);
    return zimgui_sliderInt(res.ptr, v, min, max);
}
extern fn zimgui_sliderInt([*]const u8, *i32, i32, i32) bool;

pub fn sliderFloat(comptime fmt: []const u8, args: anytype, v: *f32, min: f32, max: f32) bool {
    var res = formatZ(fmt, args);
    return zimgui_sliderFloat(res.ptr, v, min, max);
}
extern fn zimgui_sliderFloat([*]const u8, *f32, f32, f32) bool;

///////////////////////////////////////////////////////////////////////////////

/// Tables
/// - Full-featured replacement for old Columns API.
/// - See Demo->Tables for demo code. See top of imgui_tables.cpp for general commentary.
/// - See ImGuiTableFlags_ and ImGuiTableColumnFlags_ enums for a description of available flags.
/// The typical call flow is:
/// - 1. Call BeginTable(), early out if returning false.
/// - 2. Optionally call TableSetupColumn() to submit column name/flags/defaults.
/// - 3. Optionally call TableSetupScrollFreeze() to request scroll freezing of columns/rows.
/// - 4. Optionally call TableHeadersRow() to submit a header row. Names are pulled from TableSetupColumn() data.
/// - 5. Populate contents:
///    - In most situations you can use TableNextRow() + TableSetColumnIndex(N) to start appending into a column.
///    - If you are using tables as a sort of grid, where every columns is holding the same type of contents,
///      you may prefer using TableNextColumn() instead of TableNextRow() + TableSetColumnIndex().
///      TableNextColumn() will automatically wrap-around into the next row if needed.
///    - IMPORTANT: Comparatively to the old Columns() API, we need to call TableNextColumn() for the first column!
///    - Summary of possible call flow:
///    - Summary of possible call flow:
///        --------------------------------------------------------------------------------------------------------
///        TableNextColumn() -> Text("Hello 0") -> TableNextColumn() -> Text("Hello 1")  // OK: TableNextColumn() automatically gets to next row!
///        --------------------------------------------------------------------------------------------------------
/// - 5. Call EndTable()
pub fn beginTable(comptime fmt: []const u8, args: anytype, column: i32, flags: TableFlags, outer_size: ?Vec2, inner_width: f32) bool {
    var l = formatZ(fmt, args);

    if (outer_size) |s| {
        return zimgui_beginTable(l.ptr, column, @enumToInt(flags), s.x, s.y, inner_width);
    } else {
        return zimgui_beginTable(l.ptr, column, @enumToInt(flags), 0, 0, inner_width);
    }
}
extern fn zimgui_beginTable([*]const u8, i32, u32, f32, f32, f32) bool;

/// only call EndTable() if BeginTable() returns true!
pub fn endTable() void {
    zimgui_endTable();
}
extern fn zimgui_endTable() void;

/// append into the next column (or first column of next row if currently in last column). Return true when column is visible.
pub fn tableNextColumn() void {
    zimgui_tableNextColumn();
}
extern fn zimgui_tableNextColumn() void;

const GuiId = u32;

/// Tables: Headers & Columns declaration
/// - Use TableSetupColumn() to specify label, resizing policy, default width/weight, id, various other flags etc.
/// - Use TableHeadersRow() to create a header row and automatically submit a TableHeader() for each column.
///   Headers are required to perform: reordering, sorting, and opening the context menu.
///   The context menu can also be made available in columns body using ImGuiTableFlags_ContextMenuInBody.
/// - You may manually submit headers using TableNextRow() + TableHeader() calls, but this is only useful in
///   some advanced use cases (e.g. adding custom widgets in header row).
/// - Use TableSetupScrollFreeze() to lock columns/rows so they stay visible when scrolled.
pub fn tableSetupColumn(comptime fmt: []const u8, args: anytype, flags: TableColumnFlags, init_width_or_weight: f32, user_id: GuiId) void {
    var l = formatZ(fmt, args);

    zimgui_tableSetupColumn(l.ptr, @enumToInt(flags), init_width_or_weight, user_id);
}
extern fn zimgui_tableSetupColumn([*]const u8, u32, f32, GuiId) void;

/// lock columns/rows so they stay visible when scrolled.
pub fn tableSetupScrollFreeze(cols: i32, rows: i32) void {
    zimgui_tableSetupScrollFreeze(cols, rows);
}
extern fn zimgui_tableSetupScrollFreeze(i32, i32) void;

/// submit all headers cells based on data provided to TableSetupColumn() + submit context menu
pub fn tableHeadersRow() void {
    zimgui_tableHeadersRow();
}
extern fn zimgui_tableHeadersRow() void;

///////////////////////////////////////////////////////////////////////////////

/// Popups, Modals
///  - They block normal mouse hovering detection (and therefore most mouse interactions) behind them.
///  - If not modal: they can be closed by clicking anywhere outside them, or by pressing ESCAPE.
///  - Their visibility state (~bool) is held internally instead of being held by the programmer as we are used to with regular Begin*() calls.
///  - The 3 properties above are related: we need to retain popup visibility state in the library because popups may be closed as any time.
///  - You can bypass the hovering restriction by using ImGuiHoveredFlags_AllowWhenBlockedByPopup when calling IsItemHovered() or IsWindowHovered().
///  - IMPORTANT: Popup identifiers are relative to the current ID stack, so OpenPopup and BeginPopup generally needs to be at the same level of the stack.
///    This is sometimes leading to confusing mistakes. May rework this in the future.

/// Popups: begin/end functions
///  - BeginPopup(): query popup state, if open start appending into the window. Call EndPopup() afterwards. ImGuiWindowFlags are forwarded to the window.
///  - BeginPopupModal(): block every interactions behind the window, cannot be closed by user, add a dimming background, has a title bar.

/// return true if the popup is open, and you can start outputting to it.
pub fn beginPopup(str_id: []const u8, flags: WindowFlags) bool {
    var buf: [1024]u8 = undefined;
    var str_id_ = copyZ(&buf, str_id);
    return zimgui_beginPopup(str_id_.ptr, @bitCast(u32, flags));
}
extern fn zimgui_beginPopup([*]const u8, u32) bool;

/// only call EndPopup() if BeginPopupXXX() returns true!
pub fn endPopup() void {
    zimgui_endPopup();
}
extern fn zimgui_endPopup() void;

/// Popups: open/close functions
///  - OpenPopup(): set popup state to open. ImGuiPopupFlags are available for opening options.
///  - If not modal: they can be closed by clicking anywhere outside them, or by pressing ESCAPE.
///  - CloseCurrentPopup(): use inside the BeginPopup()/EndPopup() scope to close manually.
///  - CloseCurrentPopup() is called by default by Selectable()/MenuItem() when activated (FIXME: need some options).
///  - Use ImGuiPopupFlags_NoOpenOverExistingPopup to avoid opening a popup if there's already one at the same level. This is equivalent to e.g. testing for !IsAnyPopupOpen() prior to OpenPopup().
///  - Use IsWindowAppearing() after BeginPopup() to tell if a window just opened.
///  - IMPORTANT: Notice that for OpenPopupOnItemClick() we exceptionally default flags to 1 (== ImGuiPopupFlags_MouseButtonRight) for backward compatibility with older API taking 'int mouse_button = 1' parameter

/// call to mark popup as open (don't call every frame!).
pub fn openPopup(str_id: []const u8, flags: PopupFlags) void {
    var buf: [1024]u8 = undefined;
    var str_id_ = copyZ(&buf, str_id);
    zimgui_openPopup(str_id_.ptr, @enumToInt(flags));
}
extern fn zimgui_openPopup([*]const u8, u32) void;

/// manually close the popup we have begin-ed into.
pub fn closeCurrentPopup() void {
    zimgui_closeCurrentPopup();
}
extern fn zimgui_closeCurrentPopup() void;

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

    /// Add two Vec2's together and return the sum.
    pub fn sum(a: Vec2, b: Vec2) Vec2 {
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

/// Flags for ImGui::Begin()
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

pub const GuiCond = enum(u32) {
        None          = 0,        // No condition (always set the variable), same as _Always
        Always        = 1 << 0,   // No condition (always set the variable)
        Once          = 1 << 1,   // Set the variable once per runtime session (only the first call will succeed)
        FirstUseEver  = 1 << 2,   // Set the variable if the object/window has no persistently saved data (no entry in .ini file)
        Appearing     = 1 << 3,   // Set the variable if the object/window is appearing after being hidden/inactive (or the first time)
};

/// Enumeration for PushStyleColor() / PopStyleColor()
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

/// Flags for ImDrawList functions
/// (Legacy: bit 0 must always correspond to ImDrawFlags_Closed to be backward compatible with old API using a bool. Bits 1..3 must be unused)
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

/// Flags for OpenPopup*(), BeginPopupContext*(), IsPopupOpen() functions.
/// - To be backward compatible with older API which took an 'int mouse_button = 1' argument, we need to treat
///   small flags values as a mouse button index, so we encode the mouse button in the first few bits of the flags.
///   It is therefore guaranteed to be legal to pass a mouse button index in ImGuiPopupFlags.
/// - For the same reason, we exceptionally default the ImGuiPopupFlags argument of BeginPopupContextXXX functions to 1 instead of 0.
///   IMPORTANT: because the default parameter is 1 (==ImGuiPopupFlags_MouseButtonRight), if you rely on the default parameter
///   and want to another another flag, you need to pass in the ImGuiPopupFlags_MouseButtonRight flag.
/// - Multiple buttons currently cannot be combined/or-ed in those functions (we could allow it later).
const PopupFlags = enum(u32) {
    MouseButtonLeft         = 0,        // For BeginPopupContext*(): open on Left Mouse release. Guaranteed to always be == 0 (same as ImGuiMouseButton_Left)
    MouseButtonRight        = 1,        // For BeginPopupContext*(): open on Right Mouse release. Guaranteed to always be == 1 (same as ImGuiMouseButton_Right)
    MouseButtonMiddle       = 2,        // For BeginPopupContext*(): open on Middle Mouse release. Guaranteed to always be == 2 (same as ImGuiMouseButton_Middle)
    MouseButtonMask_        = 0x1F,
    //MouseButtonDefault_     = 1,
    NoOpenOverExistingPopup = 1 << 5,   // For OpenPopup*(), BeginPopupContext*(): don't open if there's already a popup at the same level of the popup stack
    NoOpenOverItems         = 1 << 6,   // For BeginPopupContextWindow(): don't return true when hovering items, only when hovering empty space
    AnyPopupId              = 1 << 7,   // For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup.
    AnyPopupLevel           = 1 << 8,   // For IsPopupOpen(): search/test at any level of the popup stack (default test in the current level)
    AnyPopup                = 1 << 7 | 1 << 8,
};

/// Flags for ImGui::Selectable()
const SelectableFlags = enum(u32) {
    None               = 0,
    DontClosePopups    = 1 << 0,   // Clicking this don't close parent popup window
    SpanAllColumns     = 1 << 1,   // Selectable frame can span all columns (text will still fit in current column)
    AllowDoubleClick   = 1 << 2,   // Generate press events on double clicks too
    Disabled           = 1 << 3,   // Cannot be selected, display grayed out text
    AllowItemOverlap   = 1 << 4,   // (WIP) Hit testing to allow subsequent widgets to overlap this one
};

/// Flags for ImGui::BeginCombo()
const ComboFlags = enum(u32) {
    None                    = 0,
    PopupAlignLeft          = 1 << 0,   // Align the popup toward the left by default
    HeightSmall             = 1 << 1,   // Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
    HeightRegular           = 1 << 2,   // Max ~8 items visible (default)
    HeightLarge             = 1 << 3,   // Max ~20 items visible
    HeightLargest           = 1 << 4,   // As many fitting items as possible
    NoArrowButton           = 1 << 5,   // Display on the preview box without the square arrow button
    NoPreview               = 1 << 6,   // Display only a square arrow button
};

// Flags for ImGui::BeginTable()
// - Important! Sizing policies have complex and subtle side effects, much more so than you would expect.
//   Read comments/demos carefully + experiment with live demos to get acquainted with them.
// - The DEFAULT sizing policies are:
//    - Default to ImGuiTableFlags_SizingFixedFit    if ScrollX is on, or if host window has ImGuiWindowFlags_AlwaysAutoResize.
//    - Default to ImGuiTableFlags_SizingStretchSame if ScrollX is off.
// - When ScrollX is off:
//    - Table defaults to ImGuiTableFlags_SizingStretchSame -> all Columns defaults to ImGuiTableColumnFlags_WidthStretch with same weight.
//    - Columns sizing policy allowed: Stretch (default), Fixed/Auto.
//    - Fixed Columns (if any) will generally obtain their requested width (unless the table cannot fit them all).
//    - Stretch Columns will share the remaining width according to their respective weight.
//    - Mixed Fixed/Stretch columns is possible but has various side-effects on resizing behaviors.
//      The typical use of mixing sizing policies is: any number of LEADING Fixed columns, followed by one or two TRAILING Stretch columns.
//      (this is because the visible order of columns have subtle but necessary effects on how they react to manual resizing).
// - When ScrollX is on:
//    - Table defaults to ImGuiTableFlags_SizingFixedFit -> all Columns defaults to ImGuiTableColumnFlags_WidthFixed
//    - Columns sizing policy allowed: Fixed/Auto mostly.
//    - Fixed Columns can be enlarged as needed. Table will show an horizontal scrollbar if needed.
//    - When using auto-resizing (non-resizable) fixed columns, querying the content width to use item right-alignment e.g. SetNextItemWidth(-FLT_MIN) doesn't make sense, would create a feedback loop.
//    - Using Stretch columns OFTEN DOES NOT MAKE SENSE if ScrollX is on, UNLESS you have specified a value for 'inner_width' in BeginTable().
//      If you specify a value for 'inner_width' then effectively the scrolling space is known and Stretch or mixed Fixed/Stretch columns become meaningful again.
// - Read on documentation at the top of imgui_tables.cpp for details.
const TableFlags = enum(u32) {
    // Features
    None                       = 0,
    Resizable                  = 1 << 0,   // Enable resizing columns.
    Reorderable                = 1 << 1,   // Enable reordering columns in header row (need calling TableSetupColumn() + TableHeadersRow() to display headers)
    Hideable                   = 1 << 2,   // Enable hiding/disabling columns in context menu.
    Sortable                   = 1 << 3,   // Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see SortMulti and SortTristate.
    NoSavedSettings            = 1 << 4,   // Disable persisting columns order, width and sort settings in the .ini file.
    ContextMenuInBody          = 1 << 5,   // Right-click on columns body/contents will display table context menu. By default it is available in TableHeadersRow().
    // Decorations
    RowBg                      = 1 << 6,   // Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually)
    BordersInnerH              = 1 << 7,   // Draw horizontal borders between rows.
    BordersOuterH              = 1 << 8,   // Draw horizontal borders at the top and bottom.
    BordersInnerV              = 1 << 9,   // Draw vertical borders between columns.
    BordersOuterV              = 1 << 10,  // Draw vertical borders on the left and right sides.
    BordersH                   = 1 << 7 | 1 << 8, // Draw horizontal borders.
    BordersV                   = 1 << 9 | 1 << 10, // Draw vertical borders.
    BordersInner               = 1 << 9 | 1 << 7, // Draw inner borders.
    BordersOuter               = 1 << 10 | 1 << 8, // Draw outer borders.
    Borders                    = 1 << 9 | 1 << 7 | 1 << 10 | 1 << 8,   // Draw all borders.
    NoBordersInBody            = 1 << 11,  // [ALPHA] Disable vertical borders in columns Body (borders will always appears in Headers). -> May move to style
    NoBordersInBodyUntilResize = 1 << 12,  // [ALPHA] Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers). -> May move to style
    // Sizing Policy (read above for defaults)
    SizingFixedFit             = 1 << 13,  // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching contents width.
    SizingFixedSame            = 2 << 13,  // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching the maximum contents width of all columns. Implicitly enable NoKeepColumnsVisible.
    SizingStretchProp          = 3 << 13,  // Columns default to _WidthStretch with default weights proportional to each columns contents widths.
    SizingStretchSame          = 4 << 13,  // Columns default to _WidthStretch with default weights all equal, unless overridden by TableSetupColumn().
    // Sizing Extra Options
    NoHostExtendX              = 1 << 16,  // Make outer width auto-fit to columns, overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used.
    NoHostExtendY              = 1 << 17,  // Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.
    NoKeepColumnsVisible       = 1 << 18,  // Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable.
    PreciseWidths              = 1 << 19,  // Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.
    // Clipping
    NoClip                     = 1 << 20,  // Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze().
    // Padding
    PadOuterX                  = 1 << 21,  // Default if BordersOuterV is on. Enable outer-most padding. Generally desirable if you have headers.
    NoPadOuterX                = 1 << 22,  // Default if BordersOuterV is off. Disable outer-most padding.
    NoPadInnerX                = 1 << 23,  // Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off).
    // Scrolling
    ScrollX                    = 1 << 24,  // Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this create a child window, ScrollY is currently generally recommended when using ScrollX.
    ScrollY                    = 1 << 25,  // Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size.
    // Sorting
    SortMulti                  = 1 << 26,  // Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).
    SortTristate               = 1 << 27,  // Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).
};

// Flags for ImGui::TableSetupColumn()
const TableColumnFlags = enum (u32) {
    // Input configuration flags
    None                  = 0,
    Disabled              = 1 << 0,   // Overriding/master disable flag: hide column, won't show in context menu (unlike calling TableSetColumnEnabled() which manipulates the user accessible state)
    DefaultHide           = 1 << 1,   // Default as a hidden/disabled column.
    DefaultSort           = 1 << 2,   // Default as a sorting column.
    WidthStretch          = 1 << 3,   // Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp).
    WidthFixed            = 1 << 4,   // Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable).
    NoResize              = 1 << 5,   // Disable manual resizing.
    NoReorder             = 1 << 6,   // Disable manual reordering this column, this will also prevent other columns from crossing over this column.
    NoHide                = 1 << 7,   // Disable ability to hide/disable this column.
    NoClip                = 1 << 8,   // Disable clipping for this column (all NoClip columns will render in a same draw command).
    NoSort                = 1 << 9,   // Disable ability to sort on this field (even if Sortable is set on the table).
    NoSortAscending       = 1 << 10,  // Disable ability to sort in the ascending direction.
    NoSortDescending      = 1 << 11,  // Disable ability to sort in the descending direction.
    NoHeaderLabel         = 1 << 12,  // TableHeadersRow() will not submit label for this column. Convenient for some small columns. Name will still appear in context menu.
    NoHeaderWidth         = 1 << 13,  // Disable header text width contribution to automatic column width.
    PreferSortAscending   = 1 << 14,  // Make the initial sort direction Ascending when first sorting on this column (default).
    PreferSortDescending  = 1 << 15,  // Make the initial sort direction Descending when first sorting on this column.
    IndentEnable          = 1 << 16,  // Use current Indent value when entering cell (default for column 0).
    IndentDisable         = 1 << 17,  // Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored.

    // Output status flags, read-only via TableGetColumnFlags()
    IsEnabled             = 1 << 24,  // Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags.
    IsVisible             = 1 << 25,  // Status: is visible == is enabled AND not clipped by scrolling.
    IsSorted              = 1 << 26,  // Status: is currently part of the sort specs
    IsHovered             = 1 << 27,  // Status: is hovered by mouse
};

// Flags for ImGui::TableNextRow()
const TableRowFlags = enum (u32) {
    None                     = 0,
    Headers                  = 1 << 0,   // Identify header row (set default background color + width of its contents accounted differently for auto column width)
};

// Enum for ImGui::TableSetBgColor()
// Background colors are rendering in 3 layers:
//  - Layer 0: draw with RowBg0 color if set, otherwise draw with ColumnBg0 if set.
//  - Layer 1: draw with RowBg1 color if set, otherwise draw with ColumnBg1 if set.
//  - Layer 2: draw with CellBg color if set.
// The purpose of the two row/columns layers is to let you decide if a background color changes should override or blend with the existing color.
// When using RowBg on the table, each row has the RowBg0 color automatically set for odd/even rows.
// If you set the color of RowBg0 target, your color will override the existing RowBg0 color.
// If you set the color of RowBg1 or ColumnBg1 target, your color will blend over the RowBg0 color.
const TableBgTarget = enum(u32) {
    None                     = 0,
    RowBg0                   = 1,        // Set row background color 0 (generally used for background, automatically set when RowBg is used)
    RowBg1                   = 2,        // Set row background color 1 (generally used for selection marking)
    CellBg                   = 3,        // Set cell background color (top-most color)
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
pub fn format(comptime fmt: []const u8, args: anytype) []const u8 {
    const len = std.fmt.count(fmt, args);
    if (len > fmt_buffer.items.len) fmt_buffer.resize(len + 64) catch unreachable;
    return std.fmt.bufPrint(fmt_buffer.items, fmt, args) catch unreachable;
}

/// @return Memory only valid until next call to format. Not thread safe.
pub fn formatZ(comptime fmt: []const u8, args: anytype) [:0]const u8 {
    const len = std.fmt.count(fmt, args);
    if (len > fmt_buffer.items.len) fmt_buffer.resize(len + 64) catch unreachable;
    return std.fmt.bufPrintZ(fmt_buffer.items, fmt, args) catch unreachable;
}

///////////////////////////////////////////////////////////////////////////////

/// Null terminate `source` into `dest` buffer, potentially clamping it to fit.
fn copyZ(dest: []u8, source: []const u8) [:0]const u8 {
    std.mem.copy(u8, dest, if (source.len > dest.len) source[0..dest.len-1] else source);
    var slice: []u8 = dest[0.. if (source.len > dest.len) dest.len else source.len+1];
    dest[slice.len-1] = 0;

    var a = slice[0..slice.len-1 :0];
    return a;
}
