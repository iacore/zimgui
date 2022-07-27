const std = @import("std");

///////////////////////////////////////////////////////////////////////////////

// Context creation and access
// - Each context create its own ImFontAtlas by default. You may instance one yourself and pass it to CreateContext() to share a font atlas between contexts.
// - DLL users: heaps and globals are not shared across DLL boundaries! You will need to call SetCurrentContext() + SetAllocatorFunctions()
//   for each static/DLL boundary you are calling from. Read "Context and Memory Allocators" section of imgui.cpp for details.
pub const Context = struct {
    data: *anyopaque,

    pub fn init() Context {
        return Context{.data = ImGui_CreateContext(null)};
    }
    extern fn ImGui_CreateContext(shared_font_atlas: ?*anyopaque) *anyopaque;

    // TODO cgustafsson:
    pub fn initWithFontAtlas() Context {
        unreachable;
    }

    pub fn deinit(context: Context) void {
        ImGui_DestoryContext(context.data);
    }
    extern fn ImGui_DestoryContext(context: *anyopaque) void;

    pub fn deinitCurrent() void {
        ImGui_DestoryContext(null);
    }

    pub fn current() Context {
        return Context{.data = ImGui_GetCurrentContext()};
    }
    extern fn ImGui_GetCurrentContext() *anyopaque;

    pub fn setCurrent(context: Context) void {
        ImGui_SetCurrentContext(context.data);
    }
    extern fn ImGui_SetCurrentContext(context: *anyopaque) void;
};

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
pub fn begin(name: [*c]const u8, open: *bool, flags: WindowFlags) bool {
    return ImGui_Begin(name, open, flags);
}
pub extern fn ImGui_Begin(name: [*c]const u8, open: *bool, flags: WindowFlags) bool;

pub fn end() void {
    ImGui_End();
}
pub extern fn ImGui_End() void;

// NOTE: No formatting, unlike regular Imgui function.
pub fn text(txt: [*c]const u8) void {
    ImGui_Text(txt);
}
pub extern fn ImGui_Text(fmt: [*c]const u8) void;

pub const kNoWrap: f32 = -1.0;

// @param wrap_width Use kNoWrap to ignore word wrap.
pub fn calcTextSize(txt: []const u8, wrap_width: f32) Vec2 {
    return ImGui_CalcTextSize(@ptrCast([*c]const u8, txt), txt.len, wrap_width);
}
pub extern fn ImGui_CalcTextSize(text: [*c]const u8, text_len: usize, wrap_width: f32) Vec2;

pub fn button(label: [*c]const u8, size: ?Vec2) bool {
    if (size) |s| {
        return ImGui_Button(label, s);
    } else {
        return ImGui_Button(label, Vec2{.x = 0, .y = 0});
    }
}
pub extern fn ImGui_Button(label: [*c]const u8, size: Vec2) bool;

pub const DrawData = struct {
    data: *anyopaque,

    // valid after Render() and until the next call to newFrame(). this is what you have to render.
    pub fn get() DrawData {
        return DrawData{.data = ImGui_GetDrawData()};
    }

    extern fn ImGui_GetDrawData() *anyopaque;
};

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub fn add(a: Vec2, b: Vec2) void {
        a.x += b.x;
        a.y += b.y;
    }
};

pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

pub const IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 63;

// Load and rasterize multiple TTF/OTF fonts into a same texture. The font atlas will build a single texture holding:
//  - One or more fonts.
//  - Custom graphics data needed to render the shapes needed by Dear ImGui.
//  - Mouse cursor shapes for software cursor rendering (unless setting 'Flags |= ImFontAtlasFlags_NoMouseCursors' in the font atlas).
// It is the user-code responsibility to setup/build the atlas, then upload the pixel data into a texture accessible by your graphics api.
//  - Optionally, call any of the AddFont*** functions. If you don't call any, the default font embedded in the code will be loaded for you.
//  - Call GetTexDataAsAlpha8() or GetTexDataAsRGBA32() to build and retrieve pixels data.
//  - Upload the pixels data into a texture within your graphics system (see imgui_impl_xxxx.cpp examples)
//  - Call SetTexID(my_tex_id); and pass the pointer/identifier to your texture in a format natural to your graphics API.
//    This value will be passed back to you during rendering to identify the texture. Read FAQ entry about ImTextureID for more details.
// Common pitfalls:
// - If you pass a 'glyph_ranges' array to AddFont*** functions, you need to make sure that your array persist up until the
//   atlas is build (when calling GetTexData*** or Build()). We only copy the pointer, not the data.
// - Important: By default, AddFontFromMemoryTTF() takes ownership of the data. Even though we are not writing to it, we will free the pointer on destruction.
//   You can set font_cfg->FontDataOwnedByAtlas=false to keep ownership of your data and it won't be freed,
// - Even though many functions are suffixed with "TTF", OTF data is supported just as well.
// - This is an old API and it is currently awkward for those and and various other reasons! We will address them in the future!
pub const FontAtlas = extern struct {
    Flags: FontAtlasFlags,              // Build flags (see ImFontAtlasFlags_)
    TexID: *anyopaque,              // User data to refer to the texture once it has been uploaded to user's graphic systems. It is passed back to you during rendering via the ImDrawCmd structure.
    TexDesiredWidth: c_int,    // Texture width desired by user before Build(). Must be a power-of-two. If have many glyphs your graphics API have texture size restrictions you may want to increase texture width to decrease height.
    TexGlyphPadding: c_int,    // Padding between glyphs within texture in pixels. Defaults to 1. If your rendering method doesn't rely on bilinear filtering you may set this to 0 (will also need to set AntiAliasedLinesUseTex = false).
    Locked: bool,             // Marked as Locked by ImGui::NewFrame() so attempt to modify the atlas will assert.

    // [Internal]
    // NB: Access texture data via GetTexData*() calls! Which will setup a default font for you.
    TexReady: bool,           // Set when texture was built matching current font input
    TexPixelsUseColors: bool, // Tell whether our texture data is known to use colors (rather than just alpha channel), in order to help backend select a format.
    TexPixelsAlpha8: *u32,    // 1 component per pixel, each component is unsigned 8-bit. Total size = TexWidth * TexHeight
    TexPixelsRGBA32: *u32,    // 4 component per pixel, each component is unsigned 8-bit. Total size = TexWidth * TexHeight * 4
    TexWidth: c_int,           // Texture width calculated during Build().
    TexHeight: c_int,          // Texture height calculated during Build().
    TexUvScale: Vec2,         // = (1.0f/TexWidth, 1.0f/TexHeight)
    TexUvWhitePixel: Vec2,    // Texture coordinates to a white pixel
    Fonts: ImVector,              // Hold all the fonts returned by AddFont*. Fonts[0] is the default font upon calling ImGui::NewFrame(), use ImGui::PushFont()/PopFont() to change the current font.
    CustomRects: ImVector,    // Rectangles for packing custom texture data into the atlas.
    ConfigData: ImVector,         // Configuration data
    TexUvLines: [IM_DRAWLIST_TEX_LINES_WIDTH_MAX + 1]Vec4,  // UVs for baked anti-aliased lines

    // [Internal] Font builder
    FontBuilderIO: *const anyopaque,      // Opaque interface to a font builder (default to stb_truetype, can be changed to use FreeType by defining IMGUI_ENABLE_FREETYPE).
    FontBuilderFlags: u32,   // Shared flags (for all fonts) for custom font builder. THIS IS BUILD IMPLEMENTATION DEPENDENT. Per-font override is also available in ImFontConfig.

    // [Internal] Packing data
    PackIdMouseCursors: c_int, // Custom texture rectangle ID for white pixel and mouse cursors
    PackIdLines: c_int,        // Custom texture rectangle ID for baked anti-aliased lines

    pub fn addFontFromFileTTF(font_atlas: *FontAtlas, filename: [*c]const u8, size_pixels: f32, font_cfg: *FontConfig, glyph_ranges: *const u16) *Font {
        return ImGui_FontAtlas_AddFontFromFileTTF(font_atlas, filename, size_pixels, font_cfg, glyph_ranges);
    }
    extern fn ImGui_FontAtlas_AddFontFromFileTTF(font_atlas: *anyopaque, filename: [*c]const u8, size_pixels: f32, font_cfg: *FontConfig, glyph_ranges: *const u16) *Font;

    pub fn clearFonts(font_atlas: *FontAtlas) void {
        ImGui_FontAtlas_ClearFonts(font_atlas);
    }
    extern fn ImGui_FontAtlas_ClearFonts(font_atlas: *anyopaque) void;

    // Build pixels data. This is called automatically for you by the GetTexData*** functions.
    pub fn build(font_atlas: *FontAtlas) bool {
        return ImGui_FontAtlas_Build(font_atlas);
    }
    extern fn ImGui_FontAtlas_Build(font_atlas: *anyopaque) bool;

    // Helpers to retrieve list of common Unicode ranges (2 value per range, values are inclusive, zero-terminated list)
    // NB: Make sure that your string are UTF-8 and NOT in your local code page. In C++11, you can create UTF-8 string literal using the u8"Hello world" syntax. See FAQ for details.
    // NB: Consider using ImFontGlyphRangesBuilder to build glyph ranges from textual data.

    
    pub fn getGlyphRangesDefault(font_atlas: *FontAtlas) [*c]const u16 { // Basic Latin, Extended Latin
        return ImGui_FontAtlas_GetGlyphRangesDefault(font_atlas);
    }
    extern fn ImGui_FontAtlas_GetGlyphRangesDefault(font_atlas: *anyopaque) [*c]const u16;

    // 4 bytes-per-pixel
    pub fn getTexDataAsRGBA32(font_atlas: *FontAtlas, out_pixels: *[*c]u8, out_width: *c_int, out_height: *c_int, out_bytes_per_pixel: *c_int) void {
        ImGui_FontAtlas_GetTexDataAsRGBA32(font_atlas, out_pixels, out_width, out_height, out_bytes_per_pixel);
    }
    extern fn ImGui_FontAtlas_GetTexDataAsRGBA32(font_atlas: *anyopaque, out_pixels: *[*c]u8, out_width: *c_int, out_height: *c_int, out_bytes_per_pixel: *c_int) void;
};

pub fn pushFont(font: *Font) void {
    ImGui_PushFont(font);
}
extern fn ImGui_PushFont(*anyopaque) void;

pub fn popFont() void {
    ImGui_PopFont();
}
extern fn ImGui_PopFont() void;

//-----------------------------------------------------------------------------
// [SECTION] Font API (ImFontConfig, ImFontGlyph, ImFontAtlasFlags, ImFontAtlas, ImFontGlyphRangesBuilder, ImFont)
//-----------------------------------------------------------------------------

pub const FontConfig = extern struct {
    FontData: *anyopaque,               //          // TTF/OTF data
    FontDataSize: c_int,           //          // TTF/OTF data size
    FontDataOwnedByAtlas: bool,   // true     // TTF/OTF data ownership taken by the container ImFontAtlas (will delete memory itself).
    FontNo: c_int,                 // 0        // Index of font within TTF/OTF file
    SizePixels: f32,             //          // Size in pixels for rasterizer (more or less maps to the resulting font height).
    OversampleH: c_int,            // 3        // Rasterize at higher quality for sub-pixel positioning. Note the difference between 2 and 3 is minimal so you can reduce this to 2 to save memory. Read https://github.com/nothings/stb/blob/master/tests/oversample/README.md for details.
    OversampleV: c_int,            // 1        // Rasterize at higher quality for sub-pixel positioning. This is not really useful as we don't use sub-pixel positions on the Y axis.
    PixelSnapH: bool,             // false    // Align every glyph to pixel boundary. Useful e.g. if you are merging a non-pixel aligned font with the default font. If enabled, you can set OversampleH/V to 1.
    GlyphExtraSpacing: Vec2,      // 0, 0     // Extra spacing (in pixels) between glyphs. Only X axis is supported for now.
    GlyphOffset: Vec2,            // 0, 0     // Offset all glyphs from this font input.
    GlyphRanges: *const u16,            // NULL     // Pointer to a user-provided list of Unicode range (2 value per range, values are inclusive, zero-terminated list). THE ARRAY DATA NEEDS TO PERSIST AS LONG AS THE FONT IS ALIVE.
    GlyphMinAdvanceX: f32,       // 0        // Minimum AdvanceX for glyphs, set Min to align font icons, set both Min/Max to enforce mono-space font
    GlyphMaxAdvanceX: f32,       // FLT_MAX  // Maximum AdvanceX for glyphs
    MergeMode: bool,              // false    // Merge into previous ImFont, so you can combine multiple inputs font into one ImFont (e.g. ASCII font + icons + Japanese glyphs). You may want to use GlyphOffset.y when merge font of different heights.
    FontBuilderFlags: u32,       // 0        // Settings for custom font builder. THIS IS BUILDER IMPLEMENTATION DEPENDENT. Leave as zero if unsure.
    RasterizerMultiply: f32,     // 1.0f     // Brighten (>1.0f) or darken (<1.0f) font output. Brightening small fonts may be a good workaround to make them more readable.
    EllipsisChar: u16,           // -1       // Explicitly specify unicode codepoint of ellipsis character. When fonts are being merged first specified ellipsis will be used.

    // [Internal]
    Name: [40]u8,               // Name (strictly to ease debugging)
    DstFont: *Font,

    pub fn init() FontConfig {
        return ImGui_FontConfig_FontConfig();
    }
    extern fn ImGui_FontConfig_FontConfig() FontConfig;
};

pub const FontGlyph = extern struct {
    // 0: Colored        // Flag to indicate glyph is colored and should generally ignore tinting (make it usable with no shift on little-endian as this is used in loops)
    // 1: Visible        // Flag to indicate glyph has no visible pixels (e.g. space). Allow early out when rendering.
    // 2 - 31: codepoint // 0x0000..0x10FFFF
    encoded_codepoint: u32,
    advance_x: f32, // Distance to next character (= data from font + ImFontConfig::GlyphExtraSpacing.x baked in)
    x0: f32, // Glyph corners
    y0: f32,
    x1: f32,
    y1: f32,

    u0: f32, // Texture coordinates
    v0: f32,
    u1: f32,
    v1: f32,
};

const IM_UNICODE_CODEPOINT_MAX = 0xFFFF;

// Font runtime data and rendering
// ImFontAtlas automatically loads a default embedded font for you when you call GetTexDataAsAlpha8() or GetTexDataAsRGBA32().
pub const Font = extern struct {
    // Members: Hot ~20/24 bytes (for CalcTextSize)
    index_advance_x: ImVector,      // 12-16 // out //            // Sparse. Glyphs->AdvanceX in a directly indexable way (cache-friendly for CalcTextSize functions which only this this info, and are often bottleneck in large UI).
    fallback_Advance_x: f32,   // 4     // out // = FallbackGlyph->AdvanceX
    font_size: f32,           // 4     // in  //            // Height of characters/line, set during loading (don't change after loading)

    // Members: Hot ~28/40 bytes (for CalcTextSize + render loop)
    index_lookup: ImVector,        // 12-16 // out //            // Sparse. Index glyphs by Unicode code-point.
    glyphs: ImVector,             // 12-16 // out //            // All glyphs.
    fallback_glyph: *const FontGlyph,      // 4-8   // out // = FindGlyph(FontFallbackChar)

    // Members: Cold ~32/40 bytes
    container_atlas: *FontAtlas,     // 4-8   // out //            // What we has been loaded into
    config_data: *anyopaque,         // 4-8   // in  //            // Pointer within ContainerAtlas->ConfigData
    config_data_count: i16,    // 2     // in  // ~ 1        // Number of ImFontConfig involved in creating this font. Bigger than 1 when merging multiple font sources into one ImFont.
    FallbackChar: u16,       // 2     // out // = FFFD/'?' // Character used if a glyph isn't found.
    EllipsisChar: u16,       // 2     // out // = '...'    // Character used for ellipsis rendering.
    DotChar: u16,            // 2     // out // = '.'      // Character used for ellipsis rendering (if a single '...' character isn't found)
    DirtyLookupTables: bool,  // 1     // out //
    Scale: f32,              // 4     // in  // = 1.f      // Base font scale, multiplied by the per-window font scale which you can adjust with SetWindowFontScale()
    Ascent: f32, Descent: f32,    // 4+4   // out //            // Ascent: distance from top to bottom of e.g. 'A' [0..FontSize]
    MetricsTotalSurface: c_int,// 4     // out //            // Total surface in pixels to get an idea of the font rasterization/texture cost (not exact, we approximate the cost of padding between glyphs)
    Used4kPagesMap: [(IM_UNICODE_CODEPOINT_MAX+1)/4096/8]u8, // 2 bytes if ImWchar=ImWchar16, 34 bytes if ImWchar==ImWchar32. Store 1-bit for each block of 4K codepoints that has one active glyph. This is mainly used to facilitate iterations across all used codepoints.

    // Methods
    //IMGUI_API ImFont();
    //IMGUI_API ~ImFont();
    //IMGUI_API const ImFontGlyph*FindGlyph(ImWchar c) const;
    //IMGUI_API const ImFontGlyph*FindGlyphNoFallback(ImWchar c) const;
    //float                       GetCharAdvance(ImWchar c) const     { return ((int)c < IndexAdvanceX.Size) ? IndexAdvanceX[(int)c] : FallbackAdvanceX; }
    //bool                        IsLoaded() const                    { return ContainerAtlas != NULL; }
    //const char*                 GetDebugName() const                { return ConfigData ? ConfigData->Name : "<unknown>"; }

    // 'max_width' stops rendering after a certain width (could be turned into a 2d size). FLT_MAX to disable.
    // 'wrap_width' enable automatic word-wrapping across multiple lines to fit into given width. 0.0f to disable.
    //IMGUI_API ImVec2            CalcTextSizeA(float size, float max_width, float wrap_width, const char* text_begin, const char* text_end = NULL, const char** remaining = NULL) const; // utf8
    //IMGUI_API const char*       CalcWordWrapPositionA(float scale, const char* text, const char* text_end, float wrap_width) const;
    //IMGUI_API void              RenderChar(ImDrawList* draw_list, float size, const ImVec2& pos, ImU32 col, ImWchar c) const;
    //IMGUI_API void              RenderText(ImDrawList* draw_list, float size, const ImVec2& pos, ImU32 col, const ImVec4& clip_rect, const char* text_begin, const char* text_end, float wrap_width = 0.0f, bool cpu_fine_clip = false) const;

    // [Internal] Don't use!
    //IMGUI_API void              BuildLookupTable();
    //IMGUI_API void              ClearOutputData();
    //IMGUI_API void              GrowIndex(int new_size);
    //IMGUI_API void              AddGlyph(const ImFontConfig* src_cfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advance_x);
    //IMGUI_API void              AddRemapChar(ImWchar dst, ImWchar src, bool overwrite_dst = true); // Makes 'dst' character/glyph points to 'src' character/glyph. Currently needs to be called AFTER fonts have been built.
    //IMGUI_API void              SetGlyphVisible(ImWchar c, bool visible);
    //IMGUI_API bool              IsGlyphRangeUnused(unsigned int c_begin, unsigned int c_last);
};

// Flags for ImFontAtlas build
pub const FontAtlasFlags = enum(c_int) {
    None               = 0,
    NoPowerOfTwoHeight = 1 << 0,   // Don't round the height to next power of two
    NoMouseCursors     = 1 << 1,   // Don't build software mouse cursors into the atlas (save a little texture memory)
    NoBakedLines       = 1 << 2,   // Don't build thick line textures into the atlas (save a little texture memory, allow support for point/nearest filtering). The AntiAliasedLinesUseTex features uses them, otherwise they will be rendered using polygons (more expensive for CPU/GPU).
};

// Flags for ImGui::Begin()
pub const WindowFlags = enum(c_int) {
    None                   = 0,
    NoTitleBar             = 1 << 0,   // Disable title-bar
    NoResize               = 1 << 1,   // Disable user resizing with the lower-right grip
    NoMove                 = 1 << 2,   // Disable user moving the window
    NoScrollbar            = 1 << 3,   // Disable scrollbars (window can still scroll with mouse or programmatically)
    NoScrollWithMouse      = 1 << 4,   // Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
    NoCollapse             = 1 << 5,   // Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).
    AlwaysAutoResize       = 1 << 6,   // Resize every window to its content every frame
    NoBackground           = 1 << 7,   // Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
    NoSavedSettings        = 1 << 8,   // Never load/save settings in .ini file
    NoMouseInputs          = 1 << 9,   // Disable catching mouse, hovering test with pass through.
    MenuBar                = 1 << 10,  // Has a menu-bar
    HorizontalScrollbar    = 1 << 11,  // Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
    NoFocusOnAppearing     = 1 << 12,  // Disable taking focus when transitioning from hidden to visible state
    NoBringToFrontOnFocus  = 1 << 13,  // Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
    AlwaysVerticalScrollbar= 1 << 14,  // Always show vertical scrollbar (even if ContentSize.y < Size.y)
    AlwaysHorizontalScrollbar=1 << 15,  // Always show horizontal scrollbar (even if ContentSize.x < Size.x)
    AlwaysUseWindowPadding = 1 << 16,  // Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
    NoNavInputs            = 1 << 18,  // No gamepad/keyboard navigation within the window
    NoNavFocus             = 1 << 19,  // No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
    UnsavedDocument        = 1 << 20,  // Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
    //NoNav                  = WindowFlags.NoNavInputs | WindowFlags.NoNavFocus,
    NoNav = 1 << 18 | 1 << 19,
    //NoDecoration           = WindowFlags.NoTitleBar | WindowFlags.NoResize | WindowFlags.NoScrollbar | WindowFlags.NoCollapse,
    NoDecoration = 1 << 0 | 1 << 1 | 1 << 3 | 1 << 5,
    //NoInputs               = WindowFlags.NoMouseInputs | WindowFlags.NoNavInputs | WindowFlags.NoNavFocus,
    NoInputs = 1 << 9 | 1 << 18 | 1 << 19 ,

    // [Internal]
    NavFlattened           = 1 << 23,  // [BETA] On child window: allow gamepad/keyboard navigation to cross over parent border to this child or between sibling child windows.
    ChildWindow            = 1 << 24,  // Don't use! For internal use by BeginChild()
    Tooltip                = 1 << 25,  // Don't use! For internal use by BeginTooltip()
    Popup                  = 1 << 26,  // Don't use! For internal use by BeginPopup()
    Modal                  = 1 << 27,  // Don't use! For internal use by BeginPopupModal()
    ChildMenu              = 1 << 28,  // Don't use! For internal use by BeginMenu()
};

// Configuration flags stored in io.ConfigFlags. Set by user/application.
pub const ConfigFlags = enum(c_int) {
    none = 0,
    nav_enable_keyboard      = 1 << 0,   // Master keyboard navigation enable flag.
    nav_enable_gamepad       = 1 << 1,   // Master gamepad navigation enable flag. Backend also needs to set ImGuiBackendFlags_HasGamepad.
    nav_enable_set_mouse_pos   = 1 << 2,   // Instruct navigation to move the mouse cursor. May be useful on TV/console systems where moving a virtual mouse is awkward. Will update io.MousePos and set io.WantSetMousePos=true. If enabled you MUST honor io.WantSetMousePos requests in your backend, otherwise ImGui will react as if the mouse is jumping around back and forth.
    nav_no_capture_keyboard   = 1 << 3,   // Instruct navigation to not set the io.WantCaptureKeyboard flag when io.NavActive is set.
    no_mouse                = 1 << 4,   // Instruct imgui to clear mouse position/buttons in NewFrame(). This allows ignoring the mouse information set by the backend.
    no_mouse_cursor_change    = 1 << 5,   // Instruct backend to not alter mouse cursor shape and visibility. Use if the backend cursor changes are interfering with yours and you don't want to use SetMouseCursor() to change mouse cursor. You may want to honor requests from imgui by reading GetMouseCursor() yourself instead.

    // User storage (to allow your backend/engine to communicate to code that may be shared between multiple projects. Those flags are NOT used by core Dear ImGui)
    is_SRGB                 = 1 << 20,  // Application is SRGB-aware.
    is_touch_screen          = 1 << 21,  // Application is using a touch screen instead of a mouse.
};

// Backend capabilities flags stored in io.BackendFlags. Set by imgui_impl_xxx or custom backend.
pub const BackendFlags = enum(c_int) {
    none                  = 0,
    has_gamepad            = 1 << 0,   // Backend Platform supports gamepad and currently has one connected.
    has_mouse_cursors       = 1 << 1,   // Backend Platform supports honoring GetMouseCursor() value to change the OS cursor shape.
    has_set_mouse_pos        = 1 << 2,   // Backend Platform supports io.WantSetMousePos requests to reposition the OS mouse position (only used if ImGuiConfigFlags_NavEnableSetMousePos is set).
    renderer_has_vtx_offset  = 1 << 3,   // Backend Renderer supports ImDrawCmd::VtxOffset. This enables output of large meshes (64K+ vertices) while still using 16-bit indices.
};

// Helper "flags" version of key-mods to store and compare multiple key-mods easily. Sometimes used for storage (e.g. io.KeyMods) but otherwise not much used in public API.
pub const ModFlags = enum(c_int) {
    none              = 0,
    ctrl              = 1 << 0,
    shift             = 1 << 1,
    alt               = 1 << 2,   // Option/Menu key
    super             = 1 << 3,   // Cmd/Super/Windows key
    all               = 0x0F
};

// Enumeration for PushStyleColor() / PopStyleColor()
pub const Col = enum(c_int) {
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
    COUNT
};

// A cardinal direction
pub const Dir = enum(c_int) {
        None    = -1,
        Left    = 0,
        Right   = 1,
        Up      = 2,
        Down    = 3,
        COUNT
};


//-----------------------------------------------------------------------------
// [SECTION] ImGuiStyle
//-----------------------------------------------------------------------------
// You may modify the ImGui::GetStyle() main instance during initialization and before NewFrame().
// During the frame, use ImGui::PushStyleVar(ImGuiStyleVar_XXXX)/PopStyleVar() to alter the main style values,
// and ImGui::PushStyleColor(ImGuiCol_XXX)/PopStyleColor() for colors.
//-----------------------------------------------------------------------------
pub const Style = extern struct {
    Alpha: f32,                      // Global alpha applies to everything in Dear ImGui.
    DisabledAlpha: f32,              // Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha.
    WindowPadding: Vec2,              // Padding within a window.
    WindowRounding: f32,             // Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.
    WindowBorderSize: f32,           // Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    WindowMinSize: Vec2,              // Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().
    WindowTitleAlign: Vec2,           // Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.
    WindowMenuButtonPosition: Dir,   // Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.
    ChildRounding: f32,              // Radius of child window corners rounding. Set to 0.0f to have rectangular windows.
    ChildBorderSize: f32,            // Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    PopupRounding: f32,              // Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)
    PopupBorderSize: f32,            // Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    FramePadding: Vec2,               // Padding within a framed rectangle (used by most widgets).
    FrameRounding: f32,              // Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).
    FrameBorderSize: f32,            // Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    ItemSpacing: Vec2,                // Horizontal and vertical spacing between widgets/lines.
    ItemInnerSpacing: Vec2,           // Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
    CellPadding: Vec2,                // Padding within a table cell
    TouchExtraPadding: Vec2,          // Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
    IndentSpacing: f32,              // Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
    ColumnsMinSpacing: f32,          // Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).
    ScrollbarSize: f32,              // Width of the vertical scrollbar, Height of the horizontal scrollbar.
    ScrollbarRounding: f32,          // Radius of grab corners for scrollbar.
    GrabMinSize: f32,                // Minimum width/height of a grab box for slider/scrollbar.
    GrabRounding: f32,               // Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
    LogSliderDeadzone: f32,          // The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero.
    TabRounding: f32,                // Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.
    TabBorderSize: f32,              // Thickness of border around tabs.
    TabMinWidthForCloseButton: f32,  // Minimum width for close button to appears on an unselected tab when hovered. Set to 0.0f to always show when hovering, set to FLT_MAX to never show close button unless selected.
    ColorButtonPosition: Dir,        // Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.
    ButtonTextAlign: Vec2,            // Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).
    SelectableTextAlign: Vec2,        // Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.
    DisplayWindowPadding: Vec2,       // Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows.
    DisplaySafeAreaPadding: Vec2,     // If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!
    MouseCursorScale: f32,           // Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.
    AntiAliasedLines: bool,           // Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
    AntiAliasedLinesUseTex: bool,     // Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). Latched at the beginning of the frame (copied to ImDrawList).
    AntiAliasedFill: bool,            // Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
    CurveTessellationTol: f32,       // Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
    CircleTessellationMaxError: f32, // Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry.
    Colors: [@enumToInt(Col.COUNT)]Vec4,

    //IMGUI_API ImGuiStyle();
    //IMGUI_API void ScaleAllSizes(float scale_factor);

    pub fn get() *Style {
        return ImGui_GetStyle();
    }

    pub extern fn ImGui_GetStyle() *Style;
};

pub const KeyData = extern struct {
    down: bool,               // True for if key is down
    down_duration: f32,       // Duration the key has been down (<0.0f: not pressed, 0.0f: just pressed, >0.0f: time held)
    down_duration_prev: f32,   // Last frame duration the key has been down
    analog_value: f32,        // 0.0f..1.0f for gamepad values
};

// Keys value 0 to 511 are left unused as legacy native/opaque key values (< 1.87)
// Keys value >= 512 are named keys (>= 1.87)
pub const Key = enum(c_int) {
    // Keyboard
    None = 0,
    Tab = 512,             // == ImGuiKey_NamedKey_BEGIN
    LeftArrow,
    RightArrow,
    UpArrow,
    DownArrow,
    PageUp,
    PageDown,
    Home,
    End,
    Insert,
    Delete,
    Backspace,
    Space,
    Enter,
    Escape,
    LeftCtrl, LeftShift, LeftAlt, LeftSuper,
    RightCtrl, RightShift, RightAlt, RightSuper,
    Menu,
    k0, k1, k2, k3, k4, k5, k6, k7, k8, k9,
    A, B, C, D, E, F, G, H, I, J,
    K, L, M, N, O, P, Q, R, S, T,
    U, V, W, X, Y, Z,
    F1, F2, F3, F4, F5, F6,
    F7, F8, F9, F10, F11, F12,
    Apostrophe,        // '
    Comma,             // ,
    Minus,             // -
    Period,            // .
    Slash,             // /
    Semicolon,         // ;
    Equal,             // =
    LeftBracket,       // [
    Backslash,         // \ (this text inhibit multiline comment caused by backslash)
    RightBracket,      // ]
    GraveAccent,       // `
    CapsLock,
    ScrollLock,
    NumLock,
    PrintScreen,
    Pause,
    Keypad0, Keypad1, Keypad2, Keypad3, Keypad4,
    Keypad5, Keypad6, Keypad7, Keypad8, Keypad9,
    KeypadDecimal,
    KeypadDivide,
    KeypadMultiply,
    KeypadSubtract,
    KeypadAdd,
    KeypadEnter,
    KeypadEqual,

    // Gamepad (some of those are analog values, 0.0f to 1.0f)                          // GAME NAVIGATION ACTION
    // (download controller mapping PNG/PSD at http://dearimgui.org/controls_sheets)
    GamepadStart,          // Menu (Xbox)      + (Switch)   Start/Options (PS)
    GamepadBack,           // View (Xbox)      - (Switch)   Share (PS)
    GamepadFaceLeft,       // X (Xbox)         Y (Switch)   Square (PS)        // Tap: Toggle Menu. Hold: Windowing mode (Focus/Move/Resize windows)
    GamepadFaceRight,      // B (Xbox)         A (Switch)   Circle (PS)        // Cancel / Close / Exit
    GamepadFaceUp,         // Y (Xbox)         X (Switch)   Triangle (PS)      // Text Input / On-screen Keyboard
    GamepadFaceDown,       // A (Xbox)         B (Switch)   Cross (PS)         // Activate / Open / Toggle / Tweak
    GamepadDpadLeft,       // D-pad Left                                       // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadRight,      // D-pad Right                                      // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadUp,         // D-pad Up                                         // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadDown,       // D-pad Down                                       // Move / Tweak / Resize Window (in Windowing mode)
    GamepadL1,             // L Bumper (Xbox)  L (Switch)   L1 (PS)            // Tweak Slower / Focus Previous (in Windowing mode)
    GamepadR1,             // R Bumper (Xbox)  R (Switch)   R1 (PS)            // Tweak Faster / Focus Next (in Windowing mode)
    GamepadL2,             // L Trig. (Xbox)   ZL (Switch)  L2 (PS) [Analog]
    GamepadR2,             // R Trig. (Xbox)   ZR (Switch)  R2 (PS) [Analog]
    GamepadL3,             // L Stick (Xbox)   L3 (Switch)  L3 (PS)
    GamepadR3,             // R Stick (Xbox)   R3 (Switch)  R3 (PS)
    GamepadLStickLeft,     // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickRight,    // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickUp,       // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickDown,     // [Analog]                                         // Move Window (in Windowing mode)
    GamepadRStickLeft,     // [Analog]
    GamepadRStickRight,    // [Analog]
    GamepadRStickUp,       // [Analog]
    GamepadRStickDown,     // [Analog]

    // Keyboard Modifiers (explicitly submitted by backend via AddKeyEvent() calls)
    // - This is mirroring the data also written to io.KeyCtrl, io.KeyShift, io.KeyAlt, io.KeySuper, in a format allowing
    //   them to be accessed via standard key API, allowing calls such as IsKeyPressed(), IsKeyReleased(), querying duration etc.
    // - Code polling every keys (e.g. an interface to detect a key press for input mapping) might want to ignore those
    //   and prefer using the real keys (e.g. LeftCtrl, RightCtrl instead of ModCtrl).
    // - In theory the value of keyboard modifiers should be roughly equivalent to a logical or of the equivalent left/right keys.
    //   In practice: it's complicated; mods are often provided from different sources. Keyboard layout, IME, sticky keys and
    //   backends tend to interfere and break that equivalence. The safer decision is to relay that ambiguity down to the end-user...
    ModCtrl, ModShift, ModAlt, ModSuper,

    // Mouse Buttons (auto-submitted from AddMouseButtonEvent() calls)
    // - This is mirroring the data also written to io.MouseDown[], io.MouseWheel, in a format allowing them to be accessed via standard key API.
    MouseLeft, MouseRight, MouseMiddle, MouseX1, MouseX2, MouseWheelX, MouseWheelY,

    // End of list
    COUNT,                 // No valid ImGuiKey is ever greater than this value

    // [Internal] Prior to 1.87 we required user to fill io.KeysDown[512] using their own native index + a io.KeyMap[] array.
    // We are ditching this method but keeping a legacy path for user code doing e.g. IsKeyPressed(MY_NATIVE_KEY_CODE)
    // defined outside of enum due to https://github.com/ziglang/zig/issues/2115
    //NamedKey_BEGIN         = 512,
    //NamedKey_END           = Key.COUNT,
    //NamedKey_COUNT         = Key.NamedKey_END - Key.NamedKey_BEGIN,
    //KeysData_SIZE          = Key.NamedKey_COUNT,          // Size of KeysData[]: only hold named keys
    //KeysData_OFFSET        = Key.NamedKey_BEGIN,          // First key stored in io.KeysData[0]. Accesses to io.KeysData[] must use (key - KeysData_OFFSET).
};

// enum(c_int) cannot have same values: https://github.com/ziglang/zig/issues/2115
pub const Key_NamedKey_BEGIN: c_int = 512; // this clashes with Key.Tab, has to be defined outside enum
pub const Key_NamedKey_END: c_int           = @enumToInt(Key.COUNT);
pub const Key_NamedKey_COUNT: c_int         = Key_NamedKey_END - Key_NamedKey_BEGIN;
pub const Key_KeysData_SIZE: c_int          = Key_NamedKey_COUNT;          // Size of KeysData[]: only hold named keys
pub const Key_KeysData_OFFSET: c_int        = Key_NamedKey_BEGIN;          // First key stored in io.KeysData[0]. Accesses to io.KeysData[] must use (key - KeysData_OFFSET).

pub const IO = extern struct {
    //------------------------------------------------------------------
    // Configuration                            // Default value
    //------------------------------------------------------------------

    config_flags: ConfigFlags,             // = 0              // See ImGuiConfigFlags_ enum. Set by user/application. Gamepad/keyboard navigation options, etc.
    backend_flags: BackendFlags,            // = 0              // See ImGuiBackendFlags_ enum. Set by backend (imgui_impl_xxx files or custom backend) to communicate features supported by the backend.
    display_size: Vec2,                    // <unset>          // Main display size, in pixels (generally == GetMainViewport()->Size). May change every frame.
    delta_time: f32,                      // = 1.0f/60.0f     // Time elapsed since last frame, in seconds. May change every frame.
    ini_saving_rate: f32,                  // = 5.0f           // Minimum time between saving positions/sizes to .ini file, in seconds.
    ini_filename: [*c]const u8,                    // = "imgui.ini"    // Path to .ini file (important: default "imgui.ini" is relative to current working dir!). Set NULL to disable automatic .ini loading/saving or if you want to manually call LoadIniSettingsXXX() / SaveIniSettingsXXX() functions.
    log_filename: [*c]const u8,                    // = "imgui_log.txt"// Path to .log file (default parameter to ImGui::LogToFile when no file is specified).
    mouse_double_click_time: f32,           // = 0.30f          // Time for a double-click, in seconds.
    mouse_double_click_max_dist: f32,        // = 6.0f           // Distance threshold to stay in to validate a double-click, in pixels.
    mouse_drag_threshold: f32,             // = 6.0f           // Distance threshold before considering we are dragging.
    key_repeat_delay: f32,                 // = 0.250f         // When holding a key/button, time before it starts repeating, in seconds (for buttons in Repeat mode, etc.).
    key_repeat_rate: f32,                  // = 0.050f         // When holding a key/button, rate at which it repeats, in seconds.
    user_data: *anyopaque,                       // = NULL           // Store your own data for retrieval by callbacks.

    fonts: *FontAtlas,                          // <auto>           // Font atlas: load, rasterize and pack one or more fonts into a single texture.
    font_global_scale: f32,                // = 1.0f           // Global scale all fonts
    font_allow_user_scaling: bool,           // = false          // Allow user scaling text of individual window with CTRL+Wheel.
    font_default: *Font,                    // = NULL           // Font to use on NewFrame(). Use NULL to uses Fonts->Fonts[0].
    display_framebuffer_scale: Vec2,        // = (1, 1)         // For retina display or other situations where window coordinates are different from framebuffer coordinates. This generally ends up in ImDrawData::FramebufferScale.

    // Miscellaneous options
    mouse_draw_cursor: bool,                // = false          // Request ImGui to draw a mouse cursor for you (if you are on a platform without a mouse cursor). Cannot be easily renamed to 'io.ConfigXXX' because this is frequently used by backend implementations.
    config_mac_osx_behaviors: bool,          // = defined(__APPLE__) // OS X style: Text editing cursor movement using Alt instead of Ctrl, Shortcuts using Cmd/Super instead of Ctrl, Line/Text Start and End using Cmd+Arrows instead of Home/End, Double click selects by word instead of selecting whole text, Multi-selection in lists uses Cmd/Super instead of Ctrl.
    config_input_trickle_event_queue: bool,   // = true           // Enable input queue trickling: some types of events submitted during the same frame (e.g. button down + up) will be spread over multiple frames, improving interactions with low framerates.
    config_input_text_cursor_blink: bool,     // = true           // Enable blinking cursor (optional as some users consider it to be distracting).
    config_input_text_enter_keep_active: bool, // = false          // [BETA] Pressing Enter will keep item active and select contents (single-line only).
    config_drag_click_to_input_text: bool,     // = false          // [BETA] Enable turning DragXXX widgets into text input with a simple mouse click-release (without moving). Not desirable on devices without a keyboard.
    config_windows_resize_from_edges: bool,   // = true           // Enable resizing of windows from their edges and from the lower-left corner. This requires (io.BackendFlags & ImGuiBackendFlags_HasMouseCursors) because it needs mouse cursor feedback. (This used to be a per-window ImGuiWindowFlags_ResizeFromAnySide flag)
    config_windows_move_from_title_bar_only: bool, // = false       // Enable allowing to move windows only when clicking on their title bar. Does not apply to windows without a title bar.
    config_memory_compact_timer: f32,       // = 60.0f          // Timer (in seconds) to free transient windows/tables memory buffers when unused. Set to -1.0f to disable.

    //------------------------------------------------------------------
    // Platform Functions
    // (the imgui_impl_xxxx backend files are setting those up for you)
    //------------------------------------------------------------------

    // Optional: Platform/Renderer backend name (informational only! will be displayed in About Window) + User data for backend/wrappers to store their own stuff.
    backend_platform_name: [*c]const u8,            // = NULL
    backend_renderer_name: [*c]const u8,            // = NULL
    backend_platform_user_data: *anyopaque,        // = NULL           // User data for platform backend
    backend_renderer_user_data: *anyopaque,        // = NULL           // User data for renderer backend
    backend_language_user_data: *anyopaque,        // = NULL           // User data for non C++ programming language backend

    // Optional: Access OS clipboard
    // (default to use native Win32 clipboard on Windows, otherwise uses a private clipboard. Override to access OS clipboard on other architectures)

    //extern fn SetClipboardTextFnDecl(user_data: *anyopaque, text: [*c]const u8) void;
    //extern fn GetClipboardTextFnDecl(user_data: *anyopaque) [*c]const u8;
    //extern fn SetPlatformImeDataFnDecl(viewport: *Viewport, data: *PlatformImeData) void;
    
    getClipboardTextFn: fn (*anyopaque, [*c]const u8) callconv(.C) void,
    SetClipboardTextFn: fn (*anyopaque) callconv(.C) void,
    //GetClipboardTextFn: GetClipboardTextFnDecl,
    //SetClipboardTextFn: SetClipboardTextFnDecl,
    clipboard_user_data: *anyopaque,

    // Optional: Notify OS Input Method Editor of the screen position of your cursor for text input position (e.g. when using Japanese/Chinese IME on Windows)
    // (default to use native imm32 api on Windows)
    setPlatformImeDataFn: fn (*Viewport, *PlatformImeData) callconv(.C) void,
    //SetPlatformImeDataFn: SetPlatformImeDataFnDecl,
    _UnusedPadding: *anyopaque,                                     // Unused field to keep data structure the same size.

    //------------------------------------------------------------------
    // Input - Call before calling NewFrame()
    //------------------------------------------------------------------

    // Input Functions
    //IMGUI_API void  AddKeyEvent(ImGuiKey key, bool down);                   // Queue a new key down/up event. Key should be "translated" (as in, generally ImGuiKey_A matches the key end-user would use to emit an 'A' character)
    //IMGUI_API void  AddKeyAnalogEvent(ImGuiKey key, bool down, float v);    // Queue a new key down/up event for analog values (e.g. ImGuiKey_Gamepad_ values). Dead-zones should be handled by the backend.
    //IMGUI_API void  AddMousePosEvent(float x, float y);                     // Queue a mouse position update. Use -FLT_MAX,-FLT_MAX to signify no mouse (e.g. app not focused and not hovered)
    //IMGUI_API void  AddMouseButtonEvent(int button, bool down);             // Queue a mouse button change
    //IMGUI_API void  AddMouseWheelEvent(float wh_x, float wh_y);             // Queue a mouse wheel update
    //IMGUI_API void  AddFocusEvent(bool focused);                            // Queue a gain/loss of focus for the application (generally based on OS/platform focus of your window)
    //IMGUI_API void  AddInputCharacter(unsigned int c);                      // Queue a new character input
    //IMGUI_API void  AddInputCharacterUTF16(ImWchar16 c);                    // Queue a new character input from an UTF-16 character, it can be a surrogate
    //IMGUI_API void  AddInputCharactersUTF8(const char* str);                // Queue a new characters input from an UTF-8 string

    //IMGUI_API void  SetKeyEventNativeData(ImGuiKey key, int native_keycode, int native_scancode, int native_legacy_index = -1); // [Optional] Specify index for legacy <1.87 IsKeyXXX() functions with native indices + specify native keycode, scancode.
    //IMGUI_API void  SetAppAcceptingEvents(bool accepting_events);           // Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.
    //IMGUI_API void  ClearInputCharacters();                                 // [Internal] Clear the text input buffer manually
    //IMGUI_API void  ClearInputKeys();                                       // [Internal] Release all keys

    //------------------------------------------------------------------
    // Output - Updated by NewFrame() or EndFrame()/Render()
    // (when reading from the io.WantCaptureMouse, io.WantCaptureKeyboard flags to dispatch your inputs, it is
    //  generally easier and more correct to use their state BEFORE calling NewFrame(). See FAQ for details!)
    //------------------------------------------------------------------

    want_capture_mouse: bool,                   // Set when Dear ImGui will use mouse inputs, in this case do not dispatch them to your main game/application (either way, always pass on mouse inputs to imgui). (e.g. unclicked mouse is hovering over an imgui window, widget is active, mouse was clicked over an imgui window, etc.).
    WantCaptureKeyboard: bool,                // Set when Dear ImGui will use keyboard inputs, in this case do not dispatch them to your main game/application (either way, always pass keyboard inputs to imgui). (e.g. InputText active, or an imgui window is focused and navigation is enabled, etc.).
    WantTextInput: bool,                      // Mobile/console: when set, you may display an on-screen keyboard. This is set by Dear ImGui when it wants textual keyboard input to happen (e.g. when a InputText widget is active).
    WantSetMousePos: bool,                    // MousePos has been altered, backend should reposition mouse on next frame. Rarely used! Set only when ImGuiConfigFlags_NavEnableSetMousePos flag is enabled.
    WantSaveIniSettings: bool,                // When manual .ini load/save is active (io.IniFilename == NULL), this will be set to notify your application that you can call SaveIniSettingsToMemory() and save yourself. Important: clear io.WantSaveIniSettings yourself after saving!
    NavActive: bool,                          // Keyboard/Gamepad navigation is currently allowed (will handle ImGuiKey_NavXXX events) = a window is focused and it doesn't use the ImGuiWindowFlags_NoNavInputs flag.
    NavVisible: bool,                         // Keyboard/Gamepad navigation is visible and allowed (will handle ImGuiKey_NavXXX events).
    Framerate: f32,                          // Estimate of application framerate (rolling average over 60 frames, based on io.DeltaTime), in frame per second. Solely for convenience. Slow applications may not want to use a moving average or may want to reset underlying buffers occasionally.
    MetricsRenderVertices: c_int,              // Vertices output during last call to Render()
    MetricsRenderIndices: c_int,               // Indices output during last call to Render() = number of triangles * 3
    MetricsRenderWindows: c_int,               // Number of visible windows
    MetricsActiveWindows: c_int,               // Number of active windows
    MetricsActiveAllocations: c_int,           // Number of active allocations, updated by MemAlloc/MemFree based on current context. May be off if you have multiple imgui contexts.
    MouseDelta: Vec2,                         // Mouse delta. Note that this is zero if either current or previous position are invalid (-FLT_MAX,-FLT_MAX), so a disappearing/reappearing mouse won't have a huge delta.

    //------------------------------------------------------------------
    // [Internal] Dear ImGui will maintain those fields. Forward compatibility not guaranteed!
    //------------------------------------------------------------------

    // Main Input State
    // (this block used to be written by backend, since 1.87 it is best to NOT write to those directly, call the AddXXX functions above instead)
    // (reading from those variables is fair game, as they are extremely unlikely to be moving anywhere)
    MousePos: Vec2,                           // Mouse position, in pixels. Set to ImVec2(-FLT_MAX, -FLT_MAX) if mouse is unavailable (on another screen, etc.)
    MouseDown: [5]bool,                       // Mouse buttons: 0=left, 1=right, 2=middle + extras (ImGuiMouseButton_COUNT == 5). Dear ImGui mostly uses left and right buttons. Others buttons allows us to track if the mouse is being used by your application + available to user as a convenience via IsMouse** API.
    MouseWheel: f32,                         // Mouse wheel Vertical: 1 unit scrolls about 5 lines text.
    MouseWheelH: f32,                        // Mouse wheel Horizontal. Most users don't have a mouse with an horizontal wheel, may not be filled by all backends.
    KeyCtrl: bool,                            // Keyboard modifier down: Control
    KeyShift: bool,                           // Keyboard modifier down: Shift
    KeyAlt: bool,                             // Keyboard modifier down: Alt
    KeySuper: bool,                           // Keyboard modifier down: Cmd/Super/Windows

    // Other state maintained from data above + IO function calls
    key_mods: ModFlags,                          // Key mods flags (same as io.KeyCtrl/KeyShift/KeyAlt/KeySuper but merged into flags), updated by NewFrame()
    KeysData: [Key_KeysData_SIZE]KeyData,  // Key state for all known keys. Use IsKeyXXX() functions to access this.
    WantCaptureMouseUnlessPopupClose: bool,   // Alternative to WantCaptureMouse: (WantCaptureMouse == true && WantCaptureMouseUnlessPopupClose == false) when a click over void is expected to close a popup.
    MousePosPrev: Vec2,                       // Previous mouse position (note that MouseDelta is not necessary == MousePos-MousePosPrev, in case either position is invalid)
    MouseClickedPos: [5]Vec2,                 // Position at time of clicking
    MouseClickedTime: [5]f64,                // Time of last click (used to figure out double-click)
    MouseClicked: [5]bool,                    // Mouse button went from !Down to Down (same as MouseClickedCount[x] != 0)
    MouseDoubleClicked: [5]bool,              // Has mouse button been double-clicked? (same as MouseClickedCount[x] == 2)
    MouseClickedCount: [5]u16,               // == 0 (not clicked), == 1 (same as MouseClicked[]), == 2 (double-clicked), == 3 (triple-clicked) etc. when going from !Down to Down
    MouseClickedLastCount: [5]u16,           // Count successive number of clicks. Stays valid after mouse release. Reset after another click is done.
    MouseReleased: [5]bool,                   // Mouse button went from Down to !Down
    MouseDownOwned: [5]bool,                  // Track if button was clicked inside a dear imgui window or over void blocked by a popup. We don't request mouse capture from the application if click started outside ImGui bounds.
    MouseDownOwnedUnlessPopupClose: [5]bool,  // Track if button was clicked inside a dear imgui window.
    MouseDownDuration: [5]f32,               // Duration the mouse button has been down (0.0f == just clicked)
    MouseDownDurationPrev: [5]f32,           // Previous time the mouse button has been down
    MouseDragMaxDistanceSqr: [5]f32,         // Squared maximum distance of how much mouse has traveled from the clicking point (used for moving thresholds)
    PenPressure: f32,                        // Touch/Pen pressure (0.0f to 1.0f, should be >0.0f only when MouseDown[0] == true). Helper storage currently unused by Dear ImGui.
    AppFocusLost: bool,                       // Only modify via AddFocusEvent()
    AppAcceptingEvents: bool,                 // Only modify via SetAppAcceptingEvents()
    BackendUsingLegacyKeyArrays: i8,        // -1: unknown, 0: using AddKeyEvent(), 1: using legacy io.KeysDown[]
    BackendUsingLegacyNavInputArray: bool,    // 0: using AddKeyAnalogEvent(), 1: writing to legacy io.NavInputs[] directly
    InputQueueSurrogate: u16,                // For AddInputCharacterUTF16()
    InputQueueCharacters: ImVector,         // Queue of _characters_ input (obtained by platform backend). Fill using AddInputCharacter() helper.

    pub fn init() IO {
        var io = ImGui_ImGuiIO();
        var our_io = @ptrCast(*IO, &io).*;
        return our_io;
    }

    pub fn get() *IO {
        return ImGui_GetIO();
    }

    pub extern fn ImGui_ImGuiIO() IO;
    pub extern fn ImGui_GetIO() *IO;

    // cannot declare it inline when using extern / 2022-07-26
    extern fn SetClipboardTextFnDecl(user_data: *anyopaque, text: [*c]const u8) void;
    extern fn GetClipboardTextFnDecl(user_data: *anyopaque) [*c]const u8;
    extern fn SetPlatformImeDataFnDecl(viewport: *Viewport, data: *PlatformImeData) void;
};

pub const Viewport = anyopaque;
pub const PlatformImeData = anyopaque;

// Don't use directly.
pub const ImVector = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: *anyopaque,
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

///////////////////////////////////////////////////////////////////////////////

// -*- Solarized Light/Dark -*-
// http://www.zovirl.com/2011/07/22/solarized_cheat_sheet/
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

pub fn setImguiTheme() void {
    var cl = &Style.get().Colors;

    // light:
    //  base 01 - emphasized content
    //  base 00 - body text / primary content
    //  base 1  - comments / secondary content
    //  base 2  - background highlights
    //  base 3  - background
    cl[@enumToInt(Col.Text)] = base00;
    cl[@enumToInt(Col.TextDisabled)] = base1;
    cl[@enumToInt(Col.WindowBg)] = base3;
    cl[@enumToInt(Col.ChildBg)] = base3;
    cl[@enumToInt(Col.PopupBg)] = base3;
    cl[@enumToInt(Col.Border)] = base2;
    cl[@enumToInt(Col.BorderShadow)] = Vec4{ .x = 0.00, .y = 0.00, .z = 0.00, .w = 0.00 };
    cl[@enumToInt(Col.FrameBg)] = base3;
    cl[@enumToInt(Col.FrameBgHovered)] = base3;
    cl[@enumToInt(Col.FrameBgActive)] = base3;
    cl[@enumToInt(Col.TitleBg)] = base2;
    cl[@enumToInt(Col.TitleBgActive)] = base2;
    cl[@enumToInt(Col.TitleBgCollapsed)] = base3;
    cl[@enumToInt(Col.MenuBarBg)] = base2;
    cl[@enumToInt(Col.ScrollbarBg)] = Vec4{ .x = 0.98, .y = 0.98, .z = 0.98, .w = 0.53 };
    cl[@enumToInt(Col.ScrollbarGrab)] = Vec4{ .x = 0.69, .y = 0.69, .z = 0.69, .w = 0.80 };
    cl[@enumToInt(Col.ScrollbarGrabHovered)] = Vec4{ .x = 0.49, .y = 0.49, .z = 0.49, .w = 0.80 };
    cl[@enumToInt(Col.ScrollbarGrabActive)] = Vec4{ .x = 0.49, .y = 0.49, .z = 0.49, .w = 1.00 };
    cl[@enumToInt(Col.CheckMark)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 };
    cl[@enumToInt(Col.SliderGrab)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.78 };
    cl[@enumToInt(Col.SliderGrabActive)] = Vec4{ .x = 0.46, .y = 0.54, .z = 0.80, .w = 0.60 };
    cl[@enumToInt(Col.Button)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.40 };
    cl[@enumToInt(Col.ButtonHovered)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 };
    cl[@enumToInt(Col.ButtonActive)] = Vec4{ .x = 0.06, .y = 0.53, .z = 0.98, .w = 1.00 };
    cl[@enumToInt(Col.Header)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.31 };
    cl[@enumToInt(Col.HeaderHovered)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 };
    cl[@enumToInt(Col.HeaderActive)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 1.00 };
    cl[@enumToInt(Col.Separator)] = Vec4{ .x = 0.39, .y = 0.39, .z = 0.39, .w = 0.62 };
    cl[@enumToInt(Col.SeparatorHovered)] = Vec4{ .x = 0.14, .y = 0.44, .z = 0.80, .w = 0.78 };
    cl[@enumToInt(Col.SeparatorActive)] = Vec4{ .x = 0.14, .y = 0.44, .z = 0.80, .w = 1.00 };
    cl[@enumToInt(Col.ResizeGrip)] = Vec4{ .x = 0.35, .y = 0.35, .z = 0.35, .w = 0.17 };
    cl[@enumToInt(Col.ResizeGripHovered)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.67 };
    cl[@enumToInt(Col.ResizeGripActive)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.95 };
    cl[@enumToInt(Col.Tab)] = Vec4{ .x = 0.76, .y = 0.80, .z = 0.84, .w = 0.93 };
    cl[@enumToInt(Col.TabHovered)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 };
    cl[@enumToInt(Col.TabActive)] = Vec4{ .x = 0.60, .y = 0.73, .z = 0.88, .w = 1.00 };
    cl[@enumToInt(Col.TabUnfocused)] = Vec4{ .x = 0.92, .y = 0.93, .z = 0.94, .w = 0.99 };
    cl[@enumToInt(Col.TabUnfocusedActive)] = Vec4{ .x = 0.74, .y = 0.82, .z = 0.91, .w = 1.00 };
    cl[@enumToInt(Col.PlotLines)] = Vec4{ .x = 0.39, .y = 0.39, .z = 0.39, .w = 1.00 };
    cl[@enumToInt(Col.PlotLinesHovered)] = Vec4{ .x = 1.00, .y = 0.43, .z = 0.35, .w = 1.00 };
    cl[@enumToInt(Col.PlotHistogram)] = Vec4{ .x = 0.90, .y = 0.70, .z = 0.00, .w = 1.00 };
    cl[@enumToInt(Col.PlotHistogramHovered)] = Vec4{ .x = 1.00, .y = 0.45, .z = 0.00, .w = 1.00 };
    cl[@enumToInt(Col.TableHeaderBg)] = Vec4{ .x = 0.78, .y = 0.87, .z = 0.98, .w = 1.00 };
    cl[@enumToInt(Col.TableBorderStrong)] = Vec4{ .x = 0.57, .y = 0.57, .z = 0.64, .w = 1.00 };
    cl[@enumToInt(Col.TableBorderLight)] = Vec4{ .x = 0.68, .y = 0.68, .z = 0.74, .w = 1.00 };
    cl[@enumToInt(Col.TableRowBg)] = Vec4{ .x = 0.00, .y = 0.00, .z = 0.00, .w = 0.00 };
    cl[@enumToInt(Col.TableRowBgAlt)] = Vec4{ .x = 0.30, .y = 0.30, .z = 0.30, .w = 0.09 };
    cl[@enumToInt(Col.TextSelectedBg)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.35 };
    cl[@enumToInt(Col.DragDropTarget)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.95 };
    cl[@enumToInt(Col.NavHighlight)] = Vec4{ .x = 0.26, .y = 0.59, .z = 0.98, .w = 0.80 };
    cl[@enumToInt(Col.NavWindowingHighlight)] = Vec4{ .x = 0.70, .y = 0.70, .z = 0.70, .w = 0.70 };
    cl[@enumToInt(Col.NavWindowingDimBg)] = Vec4{ .x = 0.20, .y = 0.20, .z = 0.20, .w = 0.20 };
    cl[@enumToInt(Col.ModalWindowDimBg)] = Vec4{ .x = 0.20, .y = 0.20, .z = 0.20, .w = 0.35 };
}
