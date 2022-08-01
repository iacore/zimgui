const std = @import("std");

///////////////////////////////////////////////////////////////////////////////

pub const ID = u32; // A unique ID used by widgets (typically the result of hashing a stack of string)

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

// Flags for ImDrawList instance. Those are set automatically by ImGui:: functions from ImGuiIO settings, and generally not manipulated directly.
// It is however possible to temporarily alter flags between calls to ImDrawList:: functions.
pub const DrawListFlags = enum(c_int) {
    None                    = 0,
    AntiAliasedLines        = 1 << 0,  // Enable anti-aliased lines/borders (*2 the number of triangles for 1.0f wide line or lines thin enough to be drawn using textures, otherwise *3 the number of triangles)
    AntiAliasedLinesUseTex  = 1 << 1,  // Enable anti-aliased lines/borders using textures when possible. Require backend to render with bilinear filtering (NOT point/nearest filtering).
    AntiAliasedFill         = 1 << 2,  // Enable anti-aliased edge around filled shapes (rounded rectangles, circles).
    AllowVtxOffset          = 1 << 3,  // Can emit 'VtxOffset > 0' to allow large meshes. Set when 'ImGuiBackendFlags_RendererHasVtxOffset' is enabled.
};

// ImDrawList: Lookup table size for adaptive arc drawing, cover full circle.
pub const IM_DRAWLIST_ARCFAST_TABLE_SIZE = 48; // Number of samples in lookup table.

pub const NavLayer = enum(c_int) {
        Main  = 0,    // Main scrolling layer
        Menu  = 1,    // Menu layer (access with Alt)
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

pub const InputSource = enum(c_int) {
    None = 0,
    Mouse,
    Keyboard,
    Gamepad,
    Clipboard,     // Currently only used by InputText()
    Nav,           // Stored in g.ActiveIdSource only
    COUNT
};

pub const ActivateFlags = enum(c_int) {
    None                 = 0,
    PreferInput          = 1 << 0,       // Favor activation that requires keyboard text input (e.g. for Slider/Drag). Default if keyboard is available.
    PreferTweak          = 1 << 1,       // Favor activation for tweaking with arrows or gamepad (e.g. for Slider/Drag). Default if keyboard is not available.
    TryToPreserveState   = 1 << 2,       // Request widget to preserve state if it can (e.g. InputText will try to preserve cursor/selection)
};

pub const ScrollFlags = enum(c_int) {
    None                   = 0,
    KeepVisibleEdgeX       = 1 << 0,       // If item is not visible: scroll as little as possible on X axis to bring item back into view [default for X axis]
    KeepVisibleEdgeY       = 1 << 1,       // If item is not visible: scroll as little as possible on Y axis to bring item back into view [default for Y axis for windows that are already visible]
    KeepVisibleCenterX     = 1 << 2,       // If item is not visible: scroll to make the item centered on X axis [rarely used]
    KeepVisibleCenterY     = 1 << 3,       // If item is not visible: scroll to make the item centered on Y axis
    AlwaysCenterX          = 1 << 4,       // Always center the result item on X axis [rarely used]
    AlwaysCenterY          = 1 << 5,       // Always center the result item on Y axis [default for Y axis for appearing window)
    NoScrollParent         = 1 << 6,       // Disable forwarding scrolling to parent window if required to keep item/rect visible (only scroll window the function was applied to).
    //MaskX_                 = KeepVisibleEdgeX | KeepVisibleCenterX | AlwaysCenterX,
    MaskX_ = 1 << 0 | 1 << 2 | 1 << 4,
    //MaskY_                 = KeepVisibleEdgeY | KeepVisibleCenterY | AlwaysCenterY,
    MaskY_ = 1 << 1 | 1 << 3 | 1 << 5,
};

pub const NavHighlightFlags = enum(c_int) {
    None             = 0,
    TypeDefault      = 1 << 0,
    TypeThin         = 1 << 1,
    AlwaysDraw       = 1 << 2,       // Draw rectangular highlight if (g.NavId == id) _even_ when using the mouse.
    NoRounding       = 1 << 3,
};

pub const NavMoveFlags = enum(c_int) {
    None                  = 0,
    LoopX                 = 1 << 0,   // On failed request, restart from opposite side
    LoopY                 = 1 << 1,
    WrapX                 = 1 << 2,   // On failed request, request from opposite side one line down (when NavDir==right) or one line up (when NavDir==left)
    WrapY                 = 1 << 3,   // This is not super useful but provided for completeness
    AllowCurrentNavId     = 1 << 4,   // Allow scoring and considering the current NavId as a move target candidate. This is used when the move source is offset (e.g. pressing PageDown actually needs to send a Up move request, if we are pressing PageDown from the bottom-most item we need to stay in place)
    AlsoScoreVisibleSet   = 1 << 5,   // Store alternate result in NavMoveResultLocalVisible that only comprise elements that are already fully visible (used by PageUp/PageDown)
    ScrollToEdgeY         = 1 << 6,   // Force scrolling to min/max (used by Home/End) // FIXME-NAV: Aim to remove or reword, probably unnecessary
    Forwarded             = 1 << 7,
    DebugNoResult         = 1 << 8,   // Dummy scoring for debug purpose, don't apply result
    FocusApi              = 1 << 9,
    Tabbing               = 1 << 10,  // == Focus + Activate if item is Inputable + DontChangeNavHighlight
    Activate              = 1 << 11,
    DontSetNavHighlight   = 1 << 12,  // Do not alter the visible state of keyboard vs mouse nav highlight
};

// Data shared between all ImDrawList instances
// You may want to create your own instance of this if you want to use ImDrawList completely without ImGui. In that case, watch out for future changes to this structure.
pub const DrawListSharedData = extern struct {
    TexUvWhitePixel: Vec2,            // UV of white pixel in the atlas
    font: *Font,                       // Current/default font (optional, for simplified AddText overload)
    FontSize: f32,                   // Current/default font size (optional, for simplified AddText overload)
    CurveTessellationTol: f32,       // Tessellation tolerance when using PathBezierCurveTo()
    CircleSegmentMaxError: f32,      // Number of circle segments to use per pixel of radius for AddCircle() etc
    ClipRectFullscreen: Vec4,         // Value for PushClipRectFullscreen()
    InitialFlags: DrawListFlags,               // Initial flags at the beginning of the frame (it is possible to alter flags on a per-drawlist basis afterwards)

    // [Internal] Lookup tables
    ArcFastVtx: [IM_DRAWLIST_ARCFAST_TABLE_SIZE]Vec2, // Sample points on the quarter of the circle.
    ArcFastRadiusCutoff: f32,                        // Cutoff radius after which arc drawing will fallback to slower PathArcTo()
    CircleSegmentCounts: [64]u8,    // Precomputed segment count for given radius before we calculate it dynamically (to avoid calculation overhead)
    TexUvLines: *const Vec4;                 // UV of anti-aliased lines in the atlas

    //ImDrawListSharedData();
    //void SetCircleTessellationMaxError(float max_error);
};

pub const MouseCursor = enum(c_int) {
    None = -1,
    Arrow = 0,
    TextInput,         // When hovering over InputText, etc.
    ResizeAll,         // (Unused by Dear ImGui functions)
    ResizeNS,          // When hovering over an horizontal border
    ResizeEW,          // When hovering over a vertical border or a column
    ResizeNESW,        // When hovering over the bottom-left corner of a window
    ResizeNWSE,        // When hovering over the bottom-right corner of a window
    Hand,              // (Unused by Dear ImGui functions. Use for e.g. hyperlinks)
    NotAllowed,        // When hovering something with disallowed interaction. Usually a crossed circle.
    COUNT
};

// Flags for ImGui::BeginDragDropSource(), ImGui::AcceptDragDropPayload()
pub const DragDropFlags = enum(c_int) {
    None                         = 0,
    // BeginDragDropSource() flags
    SourceNoPreviewTooltip       = 1 << 0,   // By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disable this behavior.
    SourceNoDisableHover         = 1 << 1,   // By default, when dragging we clear data so that IsItemHovered() will return false, to avoid subsequent user code submitting tooltips. This flag disable this behavior so you can still call IsItemHovered() on the source item.
    SourceNoHoldToOpenOthers     = 1 << 2,   // Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item.
    SourceAllowNullID            = 1 << 3,   // Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit.
    SourceExtern                 = 1 << 4,   // External source (from outside of dear imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously.
    SourceAutoExpirePayload      = 1 << 5,   // Automatically expire the payload if the source cease to be submitted (otherwise payloads are persisting while being dragged)
    // AcceptDragDropPayload() flags
    AcceptBeforeDelivery         = 1 << 10,  // AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered.
    AcceptNoDrawDefaultRect      = 1 << 11,  // Do not draw the default highlight rectangle when hovering over target.
    AcceptNoPreviewTooltip       = 1 << 12,  // Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site.
    //AcceptPeekOnly               = AcceptBeforeDelivery | AcceptNoDrawDefaultRect, // For peeking ahead and inspecting the payload before delivery.
    AcceptPeekOnly = 1 << 10 | 1 << 11, // For peeking ahead and inspecting the payload before delivery.
};

// Data payload for Drag and Drop operations: AcceptDragDropPayload(), GetDragDropPayload()
pub const Payload = extern struct {
    // Members
    Data: *anyopaque,               // Data (copied and owned by dear imgui)
    DataSize: c_int,           // Data size

    // [Internal]
    SourceId: ID;           // Source item id
    SourceParentId: ID,     // Source parent id (if available)
    DataFrameCount: c_int,     // Data timestamp
    DataType: [32 + 1]u8,   // Data type tag (short user-supplied string, 32 characters max)
    Preview: bool,            // Set when AcceptDragDropPayload() was called and mouse has been hovering the target item (nb: handle overlapping drag targets)
    Delivery: bool,           // Set when AcceptDragDropPayload() was called and mouse button is released over the target item.

    //ImGuiPayload()  { Clear(); }
    //void Clear()    { SourceId = SourceParentId = 0; Data = NULL; DataSize = 0; memset(DataType, 0, sizeof(DataType)); DataFrameCount = -1; Preview = Delivery = false; }
    //bool IsDataType(const char* type) const { return DataFrameCount != -1 && strcmp(type, DataType) == 0; }
    //bool IsPreview() const                  { return Preview; }
    //bool IsDelivery() const                 { return Delivery; }
};

// Flags for ColorEdit3() / ColorEdit4() / ColorPicker3() / ColorPicker4() / ColorButton()
pub const ColorEditFlags = enum(c_int)
{
    None            = 0,
    NoAlpha         = 1 << 1,   //              // ColorEdit, ColorPicker, ColorButton: ignore Alpha component (will only read 3 components from the input pointer).
    NoPicker        = 1 << 2,   //              // ColorEdit: disable picker when clicking on color square.
    NoOptions       = 1 << 3,   //              // ColorEdit: disable toggling options menu when right-clicking on inputs/small preview.
    NoSmallPreview  = 1 << 4,   //              // ColorEdit, ColorPicker: disable color square preview next to the inputs. (e.g. to show only the inputs)
    NoInputs        = 1 << 5,   //              // ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview color square).
    NoTooltip       = 1 << 6,   //              // ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview.
    NoLabel         = 1 << 7,   //              // ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker).
    NoSidePreview   = 1 << 8,   //              // ColorPicker: disable bigger color preview on right side of the picker, use small color square preview instead.
    NoDragDrop      = 1 << 9,   //              // ColorEdit: disable drag and drop target. ColorButton: disable drag and drop source.
    NoBorder        = 1 << 10,  //              // ColorButton: disable border (which is enforced by default)

    // User Options (right-click on widget to change some of them).
    AlphaBar        = 1 << 16,  //              // ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker.
    AlphaPreview    = 1 << 17,  //              // ColorEdit, ColorPicker, ColorButton: display preview as a transparent color over a checkerboard, instead of opaque.
    AlphaPreviewHalf= 1 << 18,  //              // ColorEdit, ColorPicker, ColorButton: display half opaque / half checkerboard, instead of opaque.
    HDR             = 1 << 19,  //              // (WIP) ColorEdit: Currently only disable 0.0f..1.0f limits in RGBA edition (note: you probably want to use Float flag as well).
    DisplayRGB      = 1 << 20,  // [Display]    // ColorEdit: override _display_ type among RGB/HSV/Hex. ColorPicker: select any combination using one or more of RGB/HSV/Hex.
    DisplayHSV      = 1 << 21,  // [Display]    // "
    DisplayHex      = 1 << 22,  // [Display]    // "
    Uint8           = 1 << 23,  // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255.
    Float           = 1 << 24,  // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
    PickerHueBar    = 1 << 25,  // [Picker]     // ColorPicker: bar for Hue, rectangle for Sat/Value.
    PickerHueWheel  = 1 << 26,  // [Picker]     // ColorPicker: wheel for Hue, triangle for Sat/Value.
    InputRGB        = 1 << 27,  // [Input]      // ColorEdit, ColorPicker: input and output data in RGB format.
    InputHSV        = 1 << 28,  // [Input]      // ColorEdit, ColorPicker: input and output data in HSV format.

    // Defaults Options. You can set application defaults using SetColorEditOptions(). The intent is that you probably don't want to
    // override them in most of your calls. Let the user choose via the option menu and/or call SetColorEditOptions() once during startup.
    //DefaultOptions_ = Uint8 | DisplayRGB | InputRGB | PickerHueBar,
    DefaultOptions_ = 1 << 23 | 1 << 20 | 1 << 27 | 1 << 25,

    // [Internal] Masks
    //DisplayMask_    = DisplayRGB | DisplayHSV | DisplayHex,
    DisplayMask_    = 1 << 20 | 1 << 21 | 1 << 22,
    //DataTypeMask_   = Uint8 | Float,
    DataTypeMask_   = 1 << 23 | 1 << 24,
    //PickerMask_     = PickerHueWheel | PickerHueBar,
    PickerMask_     = 1 << 26 | 1 << 25,
    // InputMask_      = InputRGB | InputHSV,
    InputMask_      = 1 << 27 | 1 << 28,
};

// Enumeration for ImGui::SetWindow***(), SetNextWindow***(), SetNextItem***() functions
// Represent a condition.
// Important: Treat as a regular enum! Do NOT combine multiple values using binary operators! All the functions above treat 0 as a shortcut to ImGuiCond_Always.
pub const Cond = enum(c_int){
    None          = 0,        // No condition (always set the variable), same as _Always
    Always        = 1 << 0,   // No condition (always set the variable)
    Once          = 1 << 1,   // Set the variable once per runtime session (only the first call will succeed)
    FirstUseEver  = 1 << 2,   // Set the variable if the object/window has no persistently saved data (no entry in .ini file)
    Appearing     = 1 << 3,   // Set the variable if the object/window is appearing after being hidden/inactive (or the first time)
};

pub const NextItemData = extern struct {
    Flags: ItemDataFlags,
    Width: f32,          // Set by SetNextItemWidth()
    FocusScopeId: ID,   // Set by SetNextItemMultiSelectData() (!= 0 signify value has been set, so it's an alternate version of HasSelectionData, we don't use Flags for this because they are cleared too early. This is mostly used for debugging)
    OpenCond: Cond,
    OpenVal: bool,        // Set by SetNextItemOpen()

    //ImGuiNextItemData()         { memset(this, 0, sizeof(*this)); }
    //inline void ClearFlags()    { Flags = ImGuiNextItemDataFlags_None; } // Also cleared manually by ItemAdd()!
};

// Storage for LastItem data
pub const ItemStatusFlags = enum(c_int) {
    None               = 0,
    HoveredRect        = 1 << 0,   // Mouse position is within item rectangle (does NOT mean that the window is in correct z-order and can be hovered!, this is only one part of the most-common IsItemHovered test)
    HasDisplayRect     = 1 << 1,   // g.LastItemData.DisplayRect is valid
    Edited             = 1 << 2,   // Value exposed by item was edited in the current frame (should match the bool return value of most widgets)
    ToggledSelection   = 1 << 3,   // Set when Selectable(), TreeNode() reports toggling a selection. We can't report "Selected", only state changes, in order to easily handle clipping with less issues.
    ToggledOpen        = 1 << 4,   // Set when TreeNode() reports toggling their open state.
    HasDeactivated     = 1 << 5,   // Set if the widget/group is able to provide data for the Deactivated flag.
    Deactivated        = 1 << 6,   // Only valid if HasDeactivated is set.
    HoveredWindow      = 1 << 7,   // Override the HoveredWindow test to allow cross-window hover testing.
    FocusedByTabbing   = 1 << 8,   // Set when the Focusable item just got focused by Tabbing (FIXME: to be removed soon)
};

// Status storage for the last submitted item
pub const LastItemData = extern struct {
    id: ID,
    InFlags: ItemFlags;            // See ImGuiItemFlags_
    StatusFlags: ItemStatusFlags,        // See ImGuiItemStatusFlags_
    rect: Rect,               // Full rectangle
    NavRect: Rect,            // Navigation scoring rectangle (not displayed)
    DisplayRect: Rect,        // Display rectangle (only if ImGuiItemStatusFlags_HasDisplayRect is set)

    //ImGuiLastItemData()     { memset(this, 0, sizeof(*this)); }
};

pub const NextWindowDataFlags = enum(c_int) {
    None               = 0,
    HasPos             = 1 << 0,
    HasSize            = 1 << 1,
    HasContentSize     = 1 << 2,
    HasCollapsed       = 1 << 3,
    HasSizeConstraint  = 1 << 4,
    HasFocus           = 1 << 5,
    HasBgAlpha         = 1 << 6,
    HasScroll          = 1 << 7,
};

pub extern fn ImGuiSizeCallback(*anyopaque) callconv(.C) void;

// Storage for SetNexWindow** functions
pub const NextWindowData = extern struct {
    Flags: NextWindowDataFlags,
    PosCond: Cond,
    SizeCond: Cond,
    CollapsedCond: Cond,
    PosVal: Vec2,
    PosPivotVal: Vec2,
    SizeVal: Vec2,
    ContentSizeVal: Vec2,
    ScrollVal: Vec2,
    CollapsedVal: bool,
    SizeConstraintRect: Rect,
    SizeCallback: ImGuiSizeCallback,
    SizeCallbackUserData: *anyopaque,
    BgAlphaVal: f32,             // Override background alpha
    MenuBarOffsetMinVal: Vec2,    // (Always on) This is not exposed publicly, so we don't clear it and it doesn't have a corresponding flag (could we? for consistency?)

    //ImGuiNextWindowData()       { memset(this, 0, sizeof(*this)); }
    //inline void ClearFlags()    { Flags = ImGuiNextWindowDataFlags_None; }
};

pub const NextItemDataFlags = enum(c_int) {
    None     = 0,
    HasWidth = 1 << 0,
    HasOpen  = 1 << 1,
};

pub const STB_TexteditState = extern struct {
   /////////////////////
   //
   // public data
   //

    cursor: c_int,
   // position of the text cursor within the string

    select_start: c_int,          // selection start point
    select_end: c_int,
   // selection start and end point in characters; if equal, no selection.
   // note that start may be less than or greater than end (e.g. when
   // dragging the mouse, start is where the initial click was, and you
   // can drag in either direction)

    insert_mode: u8,
   // each textfield keeps its own insert mode state. to keep an app-wide
   // insert mode, copy this value in/out of the app state

    row_count_per_page: c_int,
   // page size in number of row.
   // this value MUST be set to >0 for pageup or pagedown in multilines documents.

   /////////////////////
   //
   // private data
   //
    cursor_at_end_of_line: u8, // not implemented yet
    initialized: u8,
    has_preferred_x: u8,
    single_line: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    preferred_x: f32, // this determines where the cursor up/down tries to seek to along x
   StbUndoState undostate;
};

const STB_TEXTEDIT_POSITIONTYPE = c_int;

pub const StbUndoRecord = extern struct {
    // private data
    where: STB_TEXTEDIT_POSITIONTYPE,
    insert_length: STB_TEXTEDIT_POSITIONTYPE,
    delete_length: STB_TEXTEDIT_POSITIONTYPE,
    char_storage: c_int,
};

const STB_TEXTEDIT_UNDOSTATECOUNT = 99;
const STB_TEXTEDIT_UNDOCHARCOUNT = 999;
const STB_TEXTEDIT_CHARTYPE = c_int;

pub const StbUndoState = extern struct {
    // private data
    undo_rec: [STB_TEXTEDIT_UNDOSTATECOUNT]StbUndoRecord,
    undo_char: [STB_TEXTEDIT_UNDOCHARCOUNT]STB_TEXTEDIT_CHARTYPE;
    undo_point: u16,
    redo_point: u16,
    undo_char_point: c_int,
    redo_char_point: c_int,
};

// FIXME: this is in development, not exposed/functional as a generic feature yet.
// Horizontal/Vertical enums are fixed to 0/1 so they may be used to index ImVec2
pub const LayoutType = enum(c_int) {
    Horizontal = 0,
    Vertical = 1
};

// Storage data for BeginComboPreview()/EndComboPreview()
pub const ComboPreviewData = extern struct {
    PreviewRect: Rect,
    BackupCursorPos: Vec2,
    BackupCursorMaxPos: Vec2,
    BackupCursorPosPrevLine: Vec2,
    BackupPrevLineTextBaseOffset: f32,
    BackupLayout: LayoutType,

    //ImGuiComboPreviewData() { memset(this, 0, sizeof(*this)); }
};

// Internal state of the currently focused/edited text input box
// For a given item ID, access with ImGui::GetInputTextState()
pub const InputTextState = extern struct {
    id: ID,                     // widget id owning the text state
    CurLenW: c_int,
    CurLenA: c_int,       // we need to maintain our buffer length in both UTF-8 and wchar format. UTF-8 length is valid even if TextA is not.
    TextW: ImVector,                  // edit buffer, we need to persist but can't guarantee the persistence of the user-provided buffer. so we copy into own buffer.
    TextA: ImVector,                  // temporary UTF8 buffer for callbacks and other operations. this is not updated in every code-path! size=capacity.
    InitialTextA: ImVector,           // backup of end-user buffer at the time of focus (in UTF-8, unaltered)
    TextAIsValid: bool,           // temporary UTF8 buffer is not initially valid before we make the widget active (until then we pull the data from user argument)
    BufCapacityA: c_int,           // end-user buffer capacity
    ScrollX: f32,                // horizontal scrolling/offset
    Stb: STB_TexteditState,                   // state for stb_textedit.h
    CursorAnim: f32,             // timer for cursor blink, reset on every user action so the cursor reappears immediately
    CursorFollow: bool,           // set when we want scrolling to follow the current cursor position (not always!)
    SelectedAllMouseLock: bool,   // after a double-click to select all, we ignore further mouse drags to update selection
    Edited: bool,                 // edited this frame
    Flags: InputTextFlags,                  // copy of InputText() flags

    //ImGuiInputTextState()                   { memset(this, 0, sizeof(*this)); }
    //void        ClearText()                 { CurLenW = CurLenA = 0; TextW[0] = 0; TextA[0] = 0; CursorClamp(); }
    //void        ClearFreeMemory()           { TextW.clear(); TextA.clear(); InitialTextA.clear(); }
    //int         GetUndoAvailCount() const   { return Stb.undostate.undo_point; }
    //int         GetRedoAvailCount() const   { return STB_TEXTEDIT_UNDOSTATECOUNT - Stb.undostate.redo_point; }
    //void        OnKeyPressed(int key);      // Cannot be inline because we call in code in stb_textedit.h implementation

    // Cursor & Selection
    //void        CursorAnimReset()           { CursorAnim = -0.30f; }                                   // After a user-input the cursor stays on for a while without blinking
    //void        CursorClamp()               { Stb.cursor = ImMin(Stb.cursor, CurLenW); Stb.select_start = ImMin(Stb.select_start, CurLenW); Stb.select_end = ImMin(Stb.select_end, CurLenW); }
    //bool        HasSelection() const        { return Stb.select_start != Stb.select_end; }
    //void        ClearSelection()            { Stb.select_start = Stb.select_end = Stb.cursor; }
    //int         GetCursorPos() const        { return Stb.cursor; }
    //int         GetSelectionStart() const   { return Stb.select_start; }
    //int         GetSelectionEnd() const     { return Stb.select_end; }
    //void        SelectAll()                 { Stb.select_start = 0; Stb.cursor = Stb.select_end = CurLenW; Stb.has_preferred_x = 0; }
};

pub const Context = extern struct {
    Initialized: bool,
    FontAtlasOwnedByContext: bool,            // IO.Fonts-> is owned by the ImGuiContext and will be destructed along with it.
    io: IO,
    InputEventsQueue: ImVector,                 // Input events which will be tricked/written into IO structure.
    InputEventsTrail: ImVector,                 // Past input events processed in NewFrame(). This is to allow domain-specific application to access e.g mouse/pen trail.
    style: Style,
    font: *Font,                               // (Shortcut) == FontStack.empty() ? IO.Font : FontStack.back()
    FontSize: f32,                           // (Shortcut) == FontBaseSize * g.CurrentWindow->FontWindowScale == window->FontSize(). Text height for current window.
    FontBaseSize: f32,                       // (Shortcut) == IO.FontGlobalScale * Font->Scale * Font->FontSize. Base text height.
    DrawListSharedData: ListSharedData,
    Time: f64,
    FrameCount: c_int,
    FrameCountEnded: c_int,
    FrameCountRendered: c_int,
    WithinFrameScope: bool,                   // Set by NewFrame(), cleared by EndFrame()
    WithinFrameScopeWithImplicitWindow: bool, // Set by NewFrame(), cleared by EndFrame() when the implicit debug window has been pushed
    WithinEndChild: bool,                     // Set within EndChild()
    GcCompactAll: bool,                       // Request full GC
    TestEngineHookItems: bool,                // Will call test engine hooks: ImGuiTestEngineHook_ItemAdd(), ImGuiTestEngineHook_ItemInfo(), ImGuiTestEngineHook_Log()
    TestEngine: *anyopaque,                         // Test engine user data

    // Windows state
    Windows: ImVector,                            // Windows, sorted in display order, back to front
    WindowsFocusOrder: ImVector,                  // Root windows, sorted in focus order, back to front.
    WindowsTempSortBuffer: ImVector,              // Temporary buffer used in EndFrame() to reorder windows so parents are kept before their child
    CurrentWindowStack: ImVector,
    WindowsById: Storage,                        // Map window's ImGuiID to ImGuiWindow*
    WindowsActiveCount: c_int,                 // Number of unique windows submitted by frame
    WindowsHoverPadding: Vec2,                // Padding around resizable windows for which hovering on counts as hovering the window == ImMax(style.TouchExtraPadding, WINDOWS_HOVER_PADDING)
    CurrentWindow: *Window,                      // Window being drawn into
    HoveredWindow: *Window,                      // Window the mouse is hovering. Will typically catch mouse inputs.
    HoveredWindowUnderMovingWindow: *Window,     // Hovered window ignoring MovingWindow. Only set if MovingWindow is set.
    MovingWindow: *Window,                       // Track the window we clicked on (in order to preserve focus). The actual window that is moved is generally MovingWindow->RootWindow.
    WheelingWindow: *Window,                     // Track the window we started mouse-wheeling on. Until a timer elapse or mouse has moved, generally keep scrolling the same window even if during the course of scrolling the mouse ends up hovering a child window.
    WheelingWindowRefMousePos: Vec2,
    WheelingWindowTimer: f32,

    // Item/widgets state and tracking information
    DebugHookIdInfo: ID,                    // Will call core hooks: DebugHookIdInfo() from GetID functions, used by Stack Tool [next HoveredId/ActiveId to not pull in an extra cache-line]
    HoveredId: ID,                          // Hovered widget, filled during the frame
    HoveredIdPreviousFrame: ID,
    HoveredIdAllowOverlap: bool,
    HoveredIdUsingMouseWheel: bool,           // Hovered widget will use mouse wheel. Blocks scrolling the underlying window.
    HoveredIdPreviousFrameUsingMouseWheel: bool,
    HoveredIdDisabled: bool,                  // At least one widget passed the rect test, but has been discarded by disabled flag or popup inhibit. May be true even if HoveredId == 0.
    HoveredIdTimer: f32,                     // Measure contiguous hovering time
    HoveredIdNotActiveTimer: f32,            // Measure contiguous hovering time where the item has not been active
    ActiveId: ID,                           // Active widget
    ActiveIdIsAlive: ID,                    // Active widget has been seen this frame (we can't use a as the ActiveId may change within the frame)
    ActiveIdTimer: f32,
    ActiveIdIsJustActivated: bool,            // Set at the time of activation for one frame
    ActiveIdAllowOverlap: bool,               // Active widget allows another widget to steal active id (generally for overlapping widgets, but not always)
    ActiveIdNoClearOnFocusLoss: bool,         // Disable losing active id if the active id window gets unfocused.
    ActiveIdHasBeenPressedBefore: bool,       // Track whether the active id led to a press (this is to allow changing between PressOnClick and PressOnRelease without pressing twice). Used by range_select branch.
    ActiveIdHasBeenEditedBefore: bool,        // Was the value associated to the widget Edited over the course of the Active state.
    ActiveIdHasBeenEditedThisFrame: bool,
    ActiveIdClickOffset: Vec2,                // Clicked offset from upper-left corner, if applicable (currently only set by ButtonBehavior)
    ActiveIdWindow: *Window,
    ActiveIdSource: InputSource,                     // Activating with mouse or nav (gamepad/keyboard)
    ActiveIdMouseButton: c_int,
    ActiveIdPreviousFrame: ID,
    ActiveIdPreviousFrameIsAlive: bool,
    ActiveIdPreviousFrameHasBeenEditedBefore: bool,
    ActiveIdPreviousFrameWindow: *Window,
    LastActiveId: ID,                       // Store the last non-zero ActiveId, useful for animation.
    LastActiveIdTimer: f32,                  // Store the last non-zero ActiveId timer since the beginning of activation, useful for animation.

    // Input Ownership
    ActiveIdUsingNavDirMask: u32,            // Active widget will want to read those nav move requests (e.g. can activate a button and move away from it)
    ImBitArrayForNamedKeys  ActiveIdUsingKeyInputMask;          // Active widget will want to read those key inputs. When we grow the ImGuiKey enum we'll need to either to order the enum to make useful keys come first, either redesign this into e.g. a small array.

    // Next window/item data
    CurrentItemFlags: ItemFlags,                   // == g.ItemFlagsStack.back()
    NextItemData: NextItemData,                       // Storage for SetNextItem** functions
    LastItemData: LastItemData,                       // Storage for last submitted item (setup by ItemAdd)
    NextWindowData: NextWindowData,                     // Storage for SetNextWindow** functions

    // Shared stacks
    ColorStack: ImVector,                         // Stack for PushStyleColor()/PopStyleColor() - inherited by Begin()
    StyleVarStack: ImVector,                      // Stack for PushStyleVar()/PopStyleVar() - inherited by Begin()
    FontStack: ImVector,                          // Stack for PushFont()/PopFont() - inherited by Begin()
    FocusScopeStack: ImVector,                    // Stack for PushFocusScope()/PopFocusScope() - not inherited by Begin(), unless child window
    ItemFlagsStack: ImVector,                     // Stack for PushItemFlag()/PopItemFlag() - inherited by Begin()
    GroupStack: ImVector,                         // Stack for BeginGroup()/EndGroup() - not inherited by Begin()
    OpenPopupStack: ImVector,                     // Which popups are open (persistent)
    BeginPopupStack: ImVector,                    // Which level of BeginPopup() we are in (reset every frame)
    BeginMenuCount: c_int,

    // Viewports
    Viewports: ImVector,                        // Active viewports (Size==1 in 'master' branch). Each viewports hold their copy of ImDrawData.

    // Gamepad/keyboard Navigation
    NavWindow: *Window,                          // Focused window for navigation. Could be called 'FocusedWindow'
    NavId: ID,                              // Focused item for navigation
    NavFocusScopeId: ID,                    // Identify a selection scope (selection code often wants to "clear other items" when landing on an item of the selection set)
    NavActivateId: ID,                      // ~~ (g.ActiveId == 0) && (IsKeyPressed(ImGuiKey_Space) || IsKeyPressed(ImGuiKey_NavGamepadActivate)) ? NavId : 0, also set when calling ActivateItem()
    NavActivateDownId: ID,                  // ~~ IsKeyDown(ImGuiKey_Space) || IsKeyDown(ImGuiKey_NavGamepadActivate) ? NavId : 0
    NavActivatePressedId: ID,               // ~~ IsKeyPressed(ImGuiKey_Space) || IsKeyPressed(ImGuiKey_NavGamepadActivate) ? NavId : 0 (no repeat)
    NavActivateInputId: ID,                 // ~~ IsKeyPressed(ImGuiKey_Enter) || IsKeyPressed(ImGuiKey_NavGamepadInput) ? NavId : 0; ImGuiActivateFlags_PreferInput will be set and NavActivateId will be 0.
    NavActivateFlags: ActivateFlags,
    NavJustMovedToId: ID,                   // Just navigated to this id (result of a successfully MoveRequest).
    NavJustMovedToFocusScopeId: ID,         // Just navigated to this focus scope id (result of a successfully MoveRequest).
    NavJustMovedToKeyMods: ModFlags,
    NavNextActivateId: ID,                  // Set by ActivateItem(), queued until next frame.
    NavNextActivateFlags: ActivateFlags,
    NavInputSource: InputSource,                     // Keyboard or Gamepad mode? THIS WILL ONLY BE None or NavGamepad or NavKeyboard.
    NavLayer: NavLayer,                           // Layer we are navigating on. For now the system is hard-coded for 0=main contents and 1=menu/title bar, may expose layers later.
    NavIdIsAlive: bool,                       // Nav widget has been seen this frame ~~ NavRectRel is valid
    NavMousePosDirty: bool,                   // When set we will update mouse position if (io.ConfigFlags & ImGuiConfigFlags_NavEnableSetMousePos) if set (NB: this not enabled by default)
    NavDisableHighlight: bool,                // When user starts using mouse, we hide gamepad/keyboard highlight (NB: but they are still available, which is why NavDisableHighlight isn't always != NavDisableMouseHover)
    NavDisableMouseHover: bool,               // When user starts using gamepad/keyboard, we hide mouse hovering highlight until mouse is touched again.

    // Navigation: Init & Move Requests
    NavAnyRequest: bool,                      // ~~ NavMoveRequest || NavInitRequest this is to perform early out in ItemAdd()
    NavInitRequest: bool,                     // Init request for appearing window to select first item
    NavInitRequestFromMove: bool,
    NavInitResultId: ID,                    // Init request result (first item of the window, or one for which SetItemDefaultFocus() was called)
    NavInitResultRectRel: Rect,               // Init request result rectangle (relative to parent window)
    NavMoveSubmitted: bool,                   // Move request submitted, will process result on next NewFrame()
    NavMoveScoringItems: bool,                // Move request submitted, still scoring incoming items
    NavMoveForwardToNextFrame: bool,
    nav_move_flags: NavMoveFlags,
    NavMoveScrollFlags: ScrollFlags,
    NavMoveKeyMods: ModFlags,
    NavMoveDir: Dir,                         // Direction of the move request (left/right/up/down)
    NavMoveDirForDebug: Dir,
    NavMoveClipDir: Dir,                     // FIXME-NAV: Describe the purpose of this better. Might want to rename?
    NavScoringRect: Rect,                     // Rectangle used for scoring, in screen space. Based of window->NavRectRel[], modified for directional navigation scoring.
    NavScoringNoClipRect: Rect,               // Some nav operations (such as PageUp/PageDown) enforce a region which clipper will attempt to always keep submitted
    NavScoringDebugCount: c_int,               // Metrics for debugging
    NavTabbingDir: c_int,                      // Generally -1 or +1, 0 when tabbing without a nav id
    NavTabbingCounter: c_int,                  // >0 when counting items for tabbing
    NavMoveResultLocal: NavItemData,                 // Best move request candidate within NavWindow
    NavMoveResultLocalVisible: NavItemData,          // Best move request candidate within NavWindow that are mostly visible (when using ImGuiNavMoveFlags_AlsoScoreVisibleSet flag)
    NavMoveResultOther: NavItemData,                 // Best move request candidate within NavWindow's flattened hierarchy (when using ImGuiWindowFlags_NavFlattened flag)
    NavTabbingResultFirst: NavItemData,              // First tabbing request candidate within NavWindow and flattened hierarchy

    // Navigation: Windowing (CTRL+TAB for list, or Menu button + keys or directional pads to move/resize)
    NavWindowingTarget: *Window,                 // Target window when doing CTRL+Tab (or Pad Menu + FocusPrev/Next), this window is temporarily displayed top-most!
    NavWindowingTargetAnim: *Window,             // Record of last valid NavWindowingTarget until DimBgRatio and NavWindowingHighlightAlpha becomes 0.0f, so the fade-out can stay on it.
    NavWindowingListWindow: *Window,             // Internal window actually listing the CTRL+Tab contents
    NavWindowingTimer: f32,
    NavWindowingHighlightAlpha: f32,
    NavWindowingToggleLayer: bool,
    NavWindowingAccumDeltaPos: Vec2,
    NavWindowingAccumDeltaSize: Vec2,

    // Render
    DimBgRatio: f32,                         // 0.0..1.0 animation when fading in a dimming background (for modal window and CTRL+TAB list)
    MouseCursor: MouseCursor,

    // Drag and Drop
    DragDropActive: bool,
    DragDropWithinSource: bool,               // Set when within a BeginDragDropXXX/EndDragDropXXX block for a drag source.
    DragDropWithinTarget: bool,               // Set when within a BeginDragDropXXX/EndDragDropXXX block for a drag target.
    DragDropSourceFlags: DragDropFlags,
    DragDropSourceFrameCount: c_int,
    DragDropMouseButton: c_int,
    DragDropPayload: Payload,
    DragDropTargetRect: Rect,                 // Store rectangle of current target candidate (we favor small targets when overlapping)
    DragDropTargetId: ID,
    DragDropAcceptFlags: DragDropFlags,
    DragDropAcceptIdCurrRectSurface: f32,    // Target item surface (we resolve overlapping targets by prioritizing the smaller surface)
    DragDropAcceptIdCurr: ID,               // Target item id (set at the time of accepting the payload)
    DragDropAcceptIdPrev: ID,               // Target item id from previous frame (we need to store this to allow for overlapping drag and drop targets)
    DragDropAcceptFrameCount: c_int,           // Last time a target expressed a desire to accept the source
    DragDropHoldJustPressedId: ID,          // Set when holding a payload just made ButtonBehavior() return a press.
    DragDropPayloadBufHeap: ImVector,             // We don't expose the ImGuiPayload only holds pointer+size
    DragDropPayloadBufLocal: [16]u8,        // Local buffer for small payloads

    // Clipper
    ClipperTempDataStacked: c_int,
    ClipperTempData: ImVector,

    // Tables
    //ImGuiTable*                     CurrentTable;
    CurrentTable: *anyopaque,
    TablesTempDataStacked: c_int,      // Temporary table data size (because we leave previous instances undestructed, we generally don't use TablesTempData.Size)
    TablesTempData: ImVector,             // Temporary table data (buffers reused/shared across instances, support nesting)
    Tables: ImPool,                     // Persistent table data
    TablesLastTimeActive: ImVector,       // Last used timestamp of each tables (SOA, for efficient GC)
    DrawChannelsTempMergeBuffer: ImVector,

    // Tab bars
    //ImGuiTabBar*                    CurrentTabBar;
    CurrentTabBar: *anyopaque,
    TabBars: ImPool,
    CurrentTabBarStack: ImVector,
    ShrinkWidthBuffer: ImVector,

    // Widget state
    MouseLastValidPos: Vec2,
    InputTextState: InputTextState,
    InputTextPasswordFont: Font,
    TempInputId: ID,                        // Temporary text input when CTRL+clicking on a slider, etc.
    ColorEditOptions: ColorEditFlags,                   // Store user options for color edit widgets
    ColorEditLastHue: f32,                   // Backup of last Hue associated to LastColor, so we can restore Hue in lossy RGB<>HSV round trips
    ColorEditLastSat: f32,                   // Backup of last Saturation associated to LastColor, so we can restore Saturation in lossy RGB<>HSV round trips
    ColorEditLastColor: u32,                 // RGB value with alpha set to 0.
    ColorPickerRef: Vec4,                     // Initial/reference color at the time of opening the color picker.
    combo_preview_data: ComboPreviewData,
    SliderGrabClickOffset: f32,
    SliderCurrentAccum: f32,                 // Accumulated slider delta when using navigation controls.
    SliderCurrentAccumDirty: bool,            // Has the accumulated slider delta changed since last time we tried to apply it?
    DragCurrentAccumDirty: bool,
    DragCurrentAccum: f32,                   // Accumulator for dragging modification. Always high-precision, not rounded by end-user precision settings
    DragSpeedDefaultRatio: f32,              // If speed == 0.0f, uses (max-min) * DragSpeedDefaultRatio
    ScrollbarClickDeltaToGrabCenter: f32,    // Distance between mouse and center of grab box, normalized in parent space. Use storage?
    DisabledAlphaBackup: f32,                // Backup for style.Alpha for BeginDisabled()
    DisabledStackSize: u16,
    TooltipOverrideCount: u16,
    TooltipSlowDelay: f32,                   // Time before slow tooltips appears (FIXME: This is temporary until we merge in tooltip timer+priority work)
    ClipboardHandlerData: ImVector,               // If no custom clipboard handler is defined
    MenusIdSubmittedThisFrame: ImVector,          // A list of menu IDs that were rendered at least once

    // Platform support
    ImGuiPlatformImeData    PlatformImeData;                    // Data updated by current frame
    ImGuiPlatformImeData    PlatformImeDataPrev;                // Previous frame data (when changing we will call io.SetPlatformImeDataFn
    char                    PlatformLocaleDecimalPoint;         // '.' or *localeconv()->decimal_point

    // Settings
    SettingsLoaded: bool,
    SettingsDirtyTimer: f32,                 // Save .ini Settings to memory when time reaches zero
    ImGuiTextBuffer         SettingsIniData;                    // In memory .ini settings
    SettingsHandlers: ImVector,       // List of .ini settings handlers
    ImChunkStream<ImGuiWindowSettings>  SettingsWindows;        // ImGuiWindow .ini settings entries
    ImChunkStream<ImGuiTableSettings>   SettingsTables;         // ImGuiTable .ini settings entries
    Hooks: ImVector,                  // Hooks for extensions (e.g. test engine)
    HookIdNext: ID,             // Next available HookId

    // Capture/Logging
    LogEnabled: bool,                         // Currently capturing
    ImGuiLogType            LogType;                            // Capture target
    ImFileHandle            LogFile;                            // If != NULL log to stdout/ file
    ImGuiTextBuffer         LogBuffer;                          // Accumulation buffer when log to clipboard. This is pointer so our GImGui static constructor doesn't call heap allocators.
    const char*             LogNextPrefix;
    const char*             LogNextSuffix;
    LogLinePosY: f32,
    LogLineFirstItem: bool,
    LogDepthRef: c_int,
    LogDepthToExpand: c_int,
    LogDepthToExpandDefault: c_int,            // Default/stored value for LogDepthMaxExpand if not specified in the LogXXX function call.

    // Debug Tools
    ImGuiDebugLogFlags      DebugLogFlags;
    ImGuiTextBuffer         DebugLogBuf;
    DebugItemPickerActive: bool,              // Item picker is active (started with DebugStartItemPicker())
    ImU8                    DebugItemPickerMouseButton;
    DebugItemPickerBreakId: ID,             // Will call IM_DEBUG_BREAK() when encountering this ID
    ImGuiMetricsConfig      DebugMetricsConfig;
    ImGuiStackTool          DebugStackTool;

    // Misc
    FramerateSecPerFrame: [60]f32,           // Calculate estimate of framerate for user over the last 60 frames..
    FramerateSecPerFrameIdx: c_int,
    FramerateSecPerFrameCount: c_int,
    FramerateSecPerFrameAccum: f32,
    WantCaptureMouseNextFrame: c_int,          // Explicit capture override via SetNextFrameWantCaptureMouse()/SetNextFrameWantCaptureKeyboard(). Default to -1.
    WantCaptureKeyboardNextFrame: c_int,       // "
    WantTextInputNextFrame: c_int,
    TempBuffer: ImVector,                         // Temporary text buffer
};

pub const Storage = extern struct {
    data: ImVector,
};

pub const NavItemData = extern struct {
    window: *Window,         // Init,Move    // Best candidate window (result->ItemWindow->RootWindowForNav == request->Window)
    id: ID,             // Init,Move    // Best candidate item ID
    FocusScopeId: ID,   // Init,Move    // Best candidate focus scope ID
    RectRel: Rect,        // Init,Move    // Best candidate bounding box in window relative space
    InFlags: ItemFlags,        // ????,Move    // Best candidate item flags
    DistBox: f32,        //      Move    // Best candidate box distance to current NavId
    DistCenter: f32,     //      Move    // Best candidate center distance to current NavId
    DistAxial: f32,      //      Move    // Best candidate axial distance to current NavId

    //ImGuiNavItemData()  { Clear(); }
    //void Clear()        { Window = NULL; ID = FocusScopeId = 0; InFlags = 0; DistBox = DistCenter = DistAxial = FLT_MAX; }
};

// Storage for one window
pub const Window = extern struct {
    char*                   Name;                               // Window name, owned by the window.
    ID: ID,                                 // == ImHashStr(Name)
    ImGuiWindowFlags        Flags;                              // See enum ImGuiWindowFlags_
    ImGuiViewportP*         Viewport;                           // Always set in Begin(). Inactive windows may have a NULL value here if their viewport was discarded.
    Pos: Vec2,                                // Position (always rounded-up to nearest pixel)
    Size: Vec2,                               // Current size (==SizeFull or collapsed title bar size)
    SizeFull: Vec2,                           // Size when non collapsed
    ContentSize: Vec2,                        // Size of contents/scrollable client area (calculated from the extents reach of the cursor) from previous frame. Does not include window decoration or window padding.
    ContentSizeIdeal: Vec2,
    ContentSizeExplicit: Vec2,                // Size of contents/scrollable client area explicitly request by the user via SetNextWindowContentSize().
    WindowPadding: Vec2,                      // Window padding at the time of Begin().
    WindowRounding: f32,                     // Window rounding at the time of Begin(). May be clamped lower to avoid rendering artifacts with title bar, menu bar etc.
    WindowBorderSize: f32,                   // Window border size at the time of Begin().
    NameBufLen: c_int,                         // Size of buffer storing Name. May be larger than strlen(Name)!
    MoveId: ID,                             // == window->GetID("#MOVE")
    ChildId: ID,                            // ID of corresponding item in parent window (for navigation to return from child window to parent window)
    Scroll: Vec2,
    ScrollMax: Vec2,
    ScrollTarget: Vec2,                       // target scroll position. stored as cursor position with scrolling canceled out, so the highest point is always 0.0f. (FLT_MAX for no change)
    ScrollTargetCenterRatio: Vec2,            // 0.0f = scroll so that target position is at top, 0.5f = scroll so that target position is centered
    ScrollTargetEdgeSnapDist: Vec2,           // 0.0f = no snapping, >0.0f snapping threshold
    ScrollbarSizes: Vec2,                     // Size taken by each scrollbars on their smaller axis. Pay attention! ScrollbarSizes.x == width of the vertical scrollbar, ScrollbarSizes.y = height of the horizontal scrollbar.
    ScrollbarX: bool, ScrollbarY;             // Are scrollbars visible?
    Active: bool,                             // Set to true on Begin(), unless Collapsed
    WasActive: bool,
    WriteAccessed: bool,                      // Set to true when any widget access the current window
    Collapsed: bool,                          // Set when collapsing window to become only title-bar
    WantCollapseToggle: bool,
    SkipItems: bool,                          // Set when items can safely be all clipped (e.g. window not visible or collapsed)
    Appearing: bool,                          // Set during the frame where the window is appearing (or re-appearing)
    Hidden: bool,                             // Do not display (== HiddenFrames*** > 0)
    IsFallbackWindow: bool,                   // Set on the "Debug##Default" window.
    IsExplicitChild: bool,                    // Set when passed _ChildWindow, left to false by BeginDocked()
    HasCloseButton: bool,                     // Set when the window has a close button (p_open != NULL)
    signed char             ResizeBorderHeld;                   // Current border being held for resize (-1: none, otherwise 0-3)
    BeginCount: u16,                         // Number of Begin() during the current frame (generally 0 or 1, 1+ if appending via multiple Begin/End pairs)
    BeginOrderWithinParent: u16,             // Begin() order within immediate parent window, if we are a child window. Otherwise 0.
    BeginOrderWithinContext: u16,            // Begin() order within entire imgui context. This is mostly used for debugging submission order related issues.
    FocusOrder: u16,                         // Order within WindowsFocusOrder[], altered when windows are focused.
    PopupId: ID,                            // ID in the popup stack when this window is used as a popup/menu (because we use generic Name/ID for recycling)
    AutoFitFramesX: s8,
    AutoFitFramesY: s8,
    AutoFitChildAxises: s8,
    AutoFitOnlyGrows: bool,
    AutoPosLastDirection: Dir,
    HiddenFramesCanSkipItems: s8,           // Hide the window for N frames
    HiddenFramesCannotSkipItems: s8,        // Hide the window for N frames while allowing items to be submitted so we can measure their size
    HiddenFramesForRenderOnly: s8,          // Hide the window until frame N at Render() time only
    DisableInputsFrames: s8,                // Disable window interactions for N frames
    ImGuiCond               SetWindowPosAllowFlags : 8;         // store acceptable condition flags for SetNextWindowPos() use.
    ImGuiCond               SetWindowSizeAllowFlags : 8;        // store acceptable condition flags for SetNextWindowSize() use.
    ImGuiCond               SetWindowCollapsedAllowFlags : 8;   // store acceptable condition flags for SetNextWindowCollapsed() use.
    SetWindowPosVal: Vec2,                    // store window position when using a non-zero Pivot (position set needs to be processed when we know the window size)
    SetWindowPosPivot: Vec2,                  // store window pivot for positioning. ImVec2(0, 0) when positioning from top-left corner; ImVec2(0.5f, 0.5f) for centering; ImVec2(1, 1) for bottom right.

    IDStack: ImVector,                            // ID stack. ID are hashes seeded with the value at the top of the stack. (In theory this should be in the TempData structure)
    ImGuiWindowTempData     DC;                                 // Temporary per-window data, reset at the beginning of the frame. This used to be called ImGuiDrawContext, hence the "DC" variable name.

    // The best way to understand what those rectangles are is to use the 'Metrics->Tools->Show Windows Rectangles' viewer.
    // The main 'OuterRect', omitted as a field, is window->Rect().
    OuterRectClipped: Rect,                   // == Window->Rect() just after setup in Begin(). == window->Rect() for root window.
    InnerRect: Rect,                          // Inner rectangle (omit title bar, menu bar, scroll bar)
    InnerClipRect: Rect,                      // == InnerRect shrunk by WindowPadding*0.5f on each side, clipped within viewport or parent clip rect.
    WorkRect: Rect,                           // Initially covers the whole scrolling region. Reduced by containers e.g columns/tables when active. Shrunk by WindowPadding*1.0f on each side. This is meant to replace ContentRegionRect over time (from 1.71+ onward).
    ParentWorkRect: Rect,                     // Backup of WorkRect before entering a container such as columns/tables. Used by e.g. SpanAllColumns functions to easily access. Stacked containers are responsible for maintaining this. // FIXME-WORKRECT: Could be a stack?
    ClipRect: Rect,                           // Current clipping/scissoring rectangle, evolve as we are using PushClipRect(), etc. == DrawList->clip_rect_stack.back().
    ContentRegionRect: Rect,                  // FIXME: This is currently confusing/misleading. It is essentially WorkRect but not handling of scrolling. We currently rely on it as right/bottom aligned sizing operation need some size to rely on.
    HitTestHoleSize: Vec2ih,                    // Define an optional rectangular hole where mouse will pass-through the window.
    HitTestHoleOffset: Vec2ih,

    LastFrameActive: c_int,                    // Last frame number the window was Active.
    LastTimeActive: f32,                     // Last timestamp the window was Active (using as: f32,we don't need high precision there)
    ItemWidthDefault: f32,
    StateStorage: Storage,
    ColumnsStorage: ImVector,
    FontWindowScale: f32,                    // User scale multiplier per-window, via SetWindowFontScale()
    SettingsOffset: c_int,                     // into SettingsWindows[] (offsets are always valid as we only grow the array from the back)

    DrawList: *DrawList,                           // == &DrawListInst (for backward compatibility reason with code using internal.h we keep this a pointer)
    DrawListInst: DrawList,
    ParentWindow: *Window,                       // If we are a child _or_ popup _or_ docked window, this is pointing to our parent. Otherwise NULL.
    ParentWindowInBeginStack: *Window,
    RootWindow: *Window,                         // Point to ourself or first ancestor that is not a child window. Doesn't cross through popups/dock nodes.
    RootWindowPopupTree: *Window,                // Point to ourself or first ancestor that is not a child window. Cross through popups parent<>child.
    RootWindowForTitleBarHighlight: *Window,     // Point to ourself or first ancestor which will display TitleBgActive color when this window is active.
    RootWindowForNav: *Window,                   // Point to ourself or first ancestor which doesn't have the NavFlattened flag.

    NavLastChildNavWindow: *Window,              // When going to the menu bar, we remember the child window we came from. (This could probably be made implicit if we kept g.Windows sorted by last focused including child window.)
    NavLastIds: [NavLayer.COUNT]ID,    // Last known NavId for this window, per layer (0/1)
    NavRectRel: [NavLayer.COUNT]Rect,    // Reference rectangle, in window relative space

    MemoryDrawListIdxCapacity: c_int,          // Backup of last idx/vtx count, so when waking up the window we can preallocate and avoid iterative alloc/copy
    MemoryDrawListVtxCapacity: c_int,
    MemoryCompacted: bool,                    // Set when window extraneous data have been garbage collected

    //ImGuiWindow(ImGuiContext* context, const char* name);
    //~ImGuiWindow();

    //ImGuiID     GetID(const char* str, const char* str_end = NULL);
    //ImGuiID     GetID(const void* ptr);
    //ImGuiID     GetID(int n);
    //ImGuiID     GetIDFromRectangle(const ImRect& r_abs);

    // We don't use g.FontSize because the window may be != g.CurrentWidow.
    //ImRect      Rect() const            { return ImRect(Pos.x, Pos.y, Pos.x + Size.x, Pos.y + Size.y); }
    //float       CalcFontSize() const    { ImGuiContext& g = *GImGui; float scale = g.FontBaseSize * FontWindowScale; if (ParentWindow) scale *= ParentWindow->FontWindowScale; return scale; }
    //float       TitleBarHeight() const  { ImGuiContext& g = *GImGui; return (Flags & ImGuiWindowFlags_NoTitleBar) ? 0.0f : CalcFontSize() + g.Style.FramePadding.y * 2.0f; }
    //ImRect      TitleBarRect() const    { return ImRect(Pos, ImVec2(Pos.x + SizeFull.x, Pos.y + TitleBarHeight())); }
    //float       MenuBarHeight() const   { ImGuiContext& g = *GImGui; return (Flags & ImGuiWindowFlags_MenuBar) ? DC.MenuBarOffset.y + CalcFontSize() + g.Style.FramePadding.y * 2.0f : 0.0f; }
    //ImRect      MenuBarRect() const     { float y1 = Pos.y + TitleBarHeight(); return ImRect(Pos.x, y1, Pos.x + SizeFull.x, y1 + MenuBarHeight()); }
};

// Flags for ImDrawList instance. Those are set automatically by ImGui:: functions from ImGuiIO settings, and generally not manipulated directly.
// It is however possible to temporarily alter flags between calls to ImDrawList:: functions.
pub const DrawListFlags = enum(c_int) {
    None                    = 0,
    AntiAliasedLines        = 1 << 0,  // Enable anti-aliased lines/borders (*2 the number of triangles for 1.0f wide line or lines thin enough to be drawn using textures, otherwise *3 the number of triangles)
    AntiAliasedLinesUseTex  = 1 << 1,  // Enable anti-aliased lines/borders using textures when possible. Require backend to render with bilinear filtering (NOT point/nearest filtering).
    AntiAliasedFill         = 1 << 2,  // Enable anti-aliased edge around filled shapes (rounded rectangles, circles).
    AllowVtxOffset          = 1 << 3,  // Can emit 'VtxOffset > 0' to allow large meshes. Set when 'ImGuiBackendFlags_RendererHasVtxOffset' is enabled.
};

pub const TextureId = *anyopaque;

// [Internal] For use by ImDrawList
pub const DrawCmdHeader = extern struct {
    ClipRect: Vec4,
    TextureId: TextureId,
    VtxOffset: u32,
};

// Split/Merge functions are used to split the draw list into different layers which can be drawn into out of order.
// This is used by the Columns/Tables API, so items of each column can be batched together in a same draw call.
pub const DrawListSplitter = extern struct {
    _Current: c_int,    // Current channel number (0)
    _Count: c_int,      // Number of active channels (1+)
    _Channels: ImVector,   // Draw channels (not resized down so _Count might be < Channels.Size)

    //inline ImDrawListSplitter()  { memset(this, 0, sizeof(*this)); }
    //inline ~ImDrawListSplitter() { ClearFreeMemory(); }
    //inline void                 Clear() { _Current = 0; _Count = 1; } // Do not clear Channels[] so our allocations are reused next frame
    //IMGUI_API void              ClearFreeMemory();
    //IMGUI_API void              Split(ImDrawList* draw_list, int count);
    //IMGUI_API void              Merge(ImDrawList* draw_list);
    //IMGUI_API void              SetCurrentChannel(ImDrawList* draw_list, int channel_idx);
};

// Draw command list
// This is the low-level list of polygons that ImGui:: functions are filling. At the end of the frame,
// all command lists are passed to your ImGuiIO::RenderDrawListFn function for rendering.
// Each dear imgui window contains its own ImDrawList. You can use ImGui::GetWindowDrawList() to
// access the current window draw list and draw custom primitives.
// You can interleave normal ImGui:: calls and adding primitives to the current draw list.
// In single viewport mode, top-left is == GetMainViewport()->Pos (generally 0,0), bottom-right is == GetMainViewport()->Pos+Size (generally io.DisplaySize).
// You are totally free to apply whatever transformation matrix to want to the data (depending on the use of the transformation you may want to apply it to ClipRect as well!)
// Important: Primitives are always added to the list and not culled (culling is done at higher-level by ImGui:: functions), if you use this API a lot consider coarse culling your drawn objects.
pub const DrawList = extern struct {
    // This is what you have to render
    CmdBuffer: ImVector,          // Draw commands. Typically 1 command = 1 GPU draw call, unless the command is a callback.
    IdxBuffer: ImVector,          // Index buffer. Each command consume ImDrawCmd::ElemCount of those
    VtxBuffer: ImVector,          // Vertex buffer.
    Flags: DrawListFlags;              // Flags, you may poke into these to adjust anti-aliasing settings per-primitive.

    // [Internal, used while building lists]
    _VtxCurrentIdx: u32;     // [Internal] generally == VtxBuffer.Size unless we are past 64K vertices, in which case this gets reset to 0.
    _Data: *const DrawListSharedData,          // Pointer to shared draw data (you can use ImGui::GetDrawListSharedData() to get the one from current ImGui context)
    _OwnerName: [*c]const u8,         // Pointer to owner window's name for debugging
    _VtxWritePtr: *anyopaque,       // [Internal] point within VtxBuffer.Data after each add command (to avoid using the ImVector<> operators too much)
    _IdxWritePtr: *anyopaque,       // [Internal] point within IdxBuffer.Data after each add command (to avoid using the ImVector<> operators too much)
    ClipRectStack: ImVector,     // [Internal]
    TextureIdStack: ImVector,    // [Internal]
    Path: ImVector,              // [Internal] current path building
    _CmdHeader: DrawCmdHeader,         // [Internal] template of active commands. Fields should match those of CmdBuffer.back().
    _Splitter: DrawListSplitter,          // [Internal] for channels api (note: prefer using your own persistent instance of ImDrawListSplitter!)
    _FringeScale: f32,       // [Internal] anti-alias fringe is scaled by this value, this helps to keep things sharp while zooming at vertex buffer content

    // If you want to create ImDrawList instances, pass them ImGui::GetDrawListSharedData() or create and use your own ImDrawListSharedData (so you can use ImDrawList without ImGui)
    //ImDrawList(const ImDrawListSharedData* shared_data) { memset(this, 0, sizeof(*this)); _Data = shared_data; }

    //~ImDrawList() { _ClearFreeMemory(); }
    //IMGUI_API void  PushClipRect(const ImVec2& clip_rect_min, const ImVec2& clip_rect_max, bool intersect_with_current_clip_rect = false);  // Render-level scissoring. This is passed down to your render function but not used for CPU-side coarse clipping. Prefer using higher-level ImGui::PushClipRect() to affect logic (hit-testing and widget culling)
    //IMGUI_API void  PushClipRectFullScreen();
    //IMGUI_API void  PopClipRect();
    //IMGUI_API void  PushTextureID(ImTextureID texture_id);
    //IMGUI_API void  PopTextureID();
    //inline ImVec2   GetClipRectMin() const { const ImVec4& cr = _ClipRectStack.back(); return ImVec2(cr.x, cr.y); }
    //inline ImVec2   GetClipRectMax() const { const ImVec4& cr = _ClipRectStack.back(); return ImVec2(cr.z, cr.w); }

    // Primitives
    // - Filled shapes must always use clockwise winding order. The anti-aliasing fringe depends on it. Counter-clockwise shapes will have "inward" anti-aliasing.
    // - For rectangular primitives, "p_min" and "p_max" represent the upper-left and lower-right corners.
    // - For circle primitives, use "num_segments == 0" to automatically calculate tessellation (preferred).
    //   In older versions (until Dear ImGui 1.77) the AddCircle functions defaulted to num_segments == 12.
    //   In future versions we will use textures to provide cheaper and higher-quality circles.
    //   Use AddNgon() and AddNgonFilled() functions if you need to guaranteed a specific number of sides.
    //IMGUI_API void  AddLine(const ImVec2& p1, const ImVec2& p2, ImU32 col, float thickness = 1.0f);
    //IMGUI_API void  AddRect(const ImVec2& p_min, const ImVec2& p_max, ImU32 col, float rounding = 0.0f, ImDrawFlags flags = 0, float thickness = 1.0f);   // a: upper-left, b: lower-right (== upper-left + size)
    //IMGUI_API void  AddRectFilled(const ImVec2& p_min, const ImVec2& p_max, ImU32 col, float rounding = 0.0f, ImDrawFlags flags = 0);                     // a: upper-left, b: lower-right (== upper-left + size)
    //IMGUI_API void  AddRectFilledMultiColor(const ImVec2& p_min, const ImVec2& p_max, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left);
    //IMGUI_API void  AddQuad(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, const ImVec2& p4, ImU32 col, float thickness = 1.0f);
    //IMGUI_API void  AddQuadFilled(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, const ImVec2& p4, ImU32 col);
    //IMGUI_API void  AddTriangle(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, ImU32 col, float thickness = 1.0f);
    //IMGUI_API void  AddTriangleFilled(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, ImU32 col);
    //IMGUI_API void  AddCircle(const ImVec2& center, float radius, ImU32 col, int num_segments = 0, float thickness = 1.0f);
    //IMGUI_API void  AddCircleFilled(const ImVec2& center, float radius, ImU32 col, int num_segments = 0);
    //IMGUI_API void  AddNgon(const ImVec2& center, float radius, ImU32 col, int num_segments, float thickness = 1.0f);
    //IMGUI_API void  AddNgonFilled(const ImVec2& center, float radius, ImU32 col, int num_segments);
    //IMGUI_API void  AddText(const ImVec2& pos, ImU32 col, const char* text_begin, const char* text_end = NULL);
    //IMGUI_API void  AddText(const ImFont* font, float font_size, const ImVec2& pos, ImU32 col, const char* text_begin, const char* text_end = NULL, float wrap_width = 0.0f, const ImVec4* cpu_fine_clip_rect = NULL);
    //IMGUI_API void  AddPolyline(const ImVec2* points, int num_points, ImU32 col, ImDrawFlags flags, float thickness);
    //IMGUI_API void  AddConvexPolyFilled(const ImVec2* points, int num_points, ImU32 col);
    //IMGUI_API void  AddBezierCubic(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, const ImVec2& p4, ImU32 col, float thickness, int num_segments = 0); // Cubic Bezier (4 control points)
    //IMGUI_API void  AddBezierQuadratic(const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, ImU32 col, float thickness, int num_segments = 0);               // Quadratic Bezier (3 control points)

    // Image primitives
    // - Read FAQ to understand what ImTextureID is.
    // - "p_min" and "p_max" represent the upper-left and lower-right corners of the rectangle.
    // - "uv_min" and "uv_max" represent the normalized texture coordinates to use for those corners. Using (0,0)->(1,1) texture coordinates will generally display the entire texture.
    //IMGUI_API void  AddImage(ImTextureID user_texture_id, const ImVec2& p_min, const ImVec2& p_max, const ImVec2& uv_min = ImVec2(0, 0), const ImVec2& uv_max = ImVec2(1, 1), ImU32 col = IM_COL32_WHITE);
    //IMGUI_API void  AddImageQuad(ImTextureID user_texture_id, const ImVec2& p1, const ImVec2& p2, const ImVec2& p3, const ImVec2& p4, const ImVec2& uv1 = ImVec2(0, 0), const ImVec2& uv2 = ImVec2(1, 0), const ImVec2& uv3 = ImVec2(1, 1), const ImVec2& uv4 = ImVec2(0, 1), ImU32 col = IM_COL32_WHITE);
    //IMGUI_API void  AddImageRounded(ImTextureID user_texture_id, const ImVec2& p_min, const ImVec2& p_max, const ImVec2& uv_min, const ImVec2& uv_max, ImU32 col, float rounding, ImDrawFlags flags = 0);

    // Stateful path API, add points then finish with PathFillConvex() or PathStroke()
    // - Filled shapes must always use clockwise winding order. The anti-aliasing fringe depends on it. Counter-clockwise shapes will have "inward" anti-aliasing.
    //inline    void  PathClear()                                                 { _Path.Size = 0; }
    //inline    void  PathLineTo(const ImVec2& pos)                               { _Path.push_back(pos); }
    //inline    void  PathLineToMergeDuplicate(const ImVec2& pos)                 { if (_Path.Size == 0 || memcmp(&_Path.Data[_Path.Size - 1], &pos, 8) != 0) _Path.push_back(pos); }
    //inline    void  PathFillConvex(ImU32 col)                                   { AddConvexPolyFilled(_Path.Data, _Path.Size, col); _Path.Size = 0; }
    //inline    void  PathStroke(ImU32 col, ImDrawFlags flags = 0, float thickness = 1.0f) { AddPolyline(_Path.Data, _Path.Size, col, flags, thickness); _Path.Size = 0; }
    //IMGUI_API void  PathArcTo(const ImVec2& center, float radius, float a_min, float a_max, int num_segments = 0);
    //IMGUI_API void  PathArcToFast(const ImVec2& center, float radius, int a_min_of_12, int a_max_of_12);                // Use precomputed angles for a 12 steps circle
    //IMGUI_API void  PathBezierCubicCurveTo(const ImVec2& p2, const ImVec2& p3, const ImVec2& p4, int num_segments = 0); // Cubic Bezier (4 control points)
    //IMGUI_API void  PathBezierQuadraticCurveTo(const ImVec2& p2, const ImVec2& p3, int num_segments = 0);               // Quadratic Bezier (3 control points)
    //IMGUI_API void  PathRect(const ImVec2& rect_min, const ImVec2& rect_max, float rounding = 0.0f, ImDrawFlags flags = 0);

    // Advanced
    //IMGUI_API void  AddCallback(ImDrawCallback callback, void* callback_data);  // Your rendering function must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles.
    //IMGUI_API void  AddDrawCmd();                                               // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible
    //IMGUI_API ImDrawList* CloneOutput() const;                                  // Create a clone of the CmdBuffer/IdxBuffer/VtxBuffer.

    // Advanced: Channels
    // - Use to split render into layers. By switching channels to can render out-of-order (e.g. submit FG primitives before BG primitives)
    // - Use to minimize draw calls (e.g. if going back-and-forth between multiple clipping rectangles, prefer to append into separate channels then merge at the end)
    // - FIXME-OBSOLETE: This API shouldn't have been in ImDrawList in the first place!
    //   Prefer using your own persistent instance of ImDrawListSplitter as you can stack them.
    //   Using the ImDrawList::ChannelsXXXX you cannot stack a split over another.
    //inline void     ChannelsSplit(int count)    { _Splitter.Split(this, count); }
    //inline void     ChannelsMerge()             { _Splitter.Merge(this); }
    //inline void     ChannelsSetCurrent(int n)   { _Splitter.SetCurrentChannel(this, n); }

    // Advanced: Primitives allocations
    // - We render triangles (three vertices)
    // - All primitives needs to be reserved via PrimReserve() beforehand.
    //IMGUI_API void  PrimReserve(int idx_count, int vtx_count);
    //IMGUI_API void  PrimUnreserve(int idx_count, int vtx_count);
    //IMGUI_API void  PrimRect(const ImVec2& a, const ImVec2& b, ImU32 col);      // Axis aligned rectangle (composed of two triangles)
    //IMGUI_API void  PrimRectUV(const ImVec2& a, const ImVec2& b, const ImVec2& uv_a, const ImVec2& uv_b, ImU32 col);
    //IMGUI_API void  PrimQuadUV(const ImVec2& a, const ImVec2& b, const ImVec2& c, const ImVec2& d, const ImVec2& uv_a, const ImVec2& uv_b, const ImVec2& uv_c, const ImVec2& uv_d, ImU32 col);
    //inline    void  PrimWriteVtx(const ImVec2& pos, const ImVec2& uv, ImU32 col)    { _VtxWritePtr->pos = pos; _VtxWritePtr->uv = uv; _VtxWritePtr->col = col; _VtxWritePtr++; _VtxCurrentIdx++; }
    //inline    void  PrimWriteIdx(ImDrawIdx idx)                                     { *_IdxWritePtr = idx; _IdxWritePtr++; }
    //inline    void  PrimVtx(const ImVec2& pos, const ImVec2& uv, ImU32 col)         { PrimWriteIdx((ImDrawIdx)_VtxCurrentIdx); PrimWriteVtx(pos, uv, col); } // Write vertex with unique index

    // [Internal helpers]
    //IMGUI_API void  _ResetForNewFrame();
    //IMGUI_API void  _ClearFreeMemory();
    //IMGUI_API void  _PopUnusedDrawCmd();
    //IMGUI_API void  _TryMergeDrawCmds();
    //IMGUI_API void  _OnChangedClipRect();
    //IMGUI_API void  _OnChangedTextureID();
    //IMGUI_API void  _OnChangedVtxOffset();
    //IMGUI_API int   _CalcCircleAutoSegmentCount(float radius) const;
    //IMGUI_API void  _PathArcToFastEx(const ImVec2& center, float radius, int a_min_sample, int a_max_sample, int a_step);
    //IMGUI_API void  _PathArcToN(const ImVec2& center, float radius, float a_min, float a_max, int num_segments);
};

// Transient per-window flags, reset at the beginning of the frame. For child window, inherited from parent on first Begin().
// This is going to be exposed in imgui.h when stabilized enough.
pub const ItemFlags = enum(c_int) {
    // Controlled by user
    None                     = 0,
    NoTabStop                = 1 << 0,  // false     // Disable keyboard tabbing (FIXME: should merge with _NoNav)
    ButtonRepeat             = 1 << 1,  // false     // Button() will return true multiple times based on io.KeyRepeatDelay and io.KeyRepeatRate settings.
    Disabled                 = 1 << 2,  // false     // Disable interactions but doesn't affect visuals. See BeginDisabled()/EndDisabled(). See github.com/ocornut/imgui/issues/211
    NoNav                    = 1 << 3,  // false     // Disable keyboard/gamepad directional navigation (FIXME: should merge with _NoTabStop)
    NoNavDefaultFocus        = 1 << 4,  // false     // Disable item being a candidate for default focus (e.g. used by title bar items)
    SelectableDontClosePopup = 1 << 5,  // false     // Disable MenuItem/Selectable() automatically closing their popup window
    MixedValue               = 1 << 6,  // false     // [BETA] Represent a mixed/indeterminate value, generally multi-selection where values differ. Currently only supported by Checkbox() (later should support all sorts of widgets)
    ReadOnly                 = 1 << 7,  // false     // [ALPHA] Allow hovering interactions but underlying value is not changed.

    // Controlled by widget code
    Inputable                = 1 << 8,  // false     // [WIP] Auto-activate input mode when tab focused. Currently only used and supported by a few items before it becomes a generic feature.
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
extern fn ImGui_Begin(name: [*c]const u8, open: *bool, flags: WindowFlags) bool;

pub fn end() void {
    ImGui_End();
}
extern fn ImGui_End() void;

// NOTE: No formatting, unlike regular Imgui function.
pub fn text(txt: []const u8) void {
    ImGui_Text(txt.ptr, txt.len);
}
extern fn ImGui_Text(fmt: [*c]const u8, usize) void;

pub fn textColored(color: Vec4, txt: [*c]const u8) void {
    ImGui_TextColored(&color, txt);
}
extern fn ImGui_TextColored(Vec4, [*c]const u8) void;

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
extern fn ImGui_Button(label: [*c]const u8, size: Vec2) bool;

/// @param fmt Default = "%d"
pub fn sliderInt(label: [*c]const u8, v: *c_int, v_min: c_int, v_max: c_int, fmt: [*c]const u8, flags: SliderFlags) bool {
    return ImGui_SliderInt(label, v, v_min, v_max, fmt, flags);
}
extern fn ImGui_SliderInt([*c]const u8, *c_int, c_int, c_int, [*c]const u8, SliderFlags) bool;

pub fn inputText(label: [*c]const u8, buf: []u8, flags: InputTextFlags) bool {
    return ImGui_InputText(label, buf.ptr, buf.len, flags);
}
extern fn ImGui_InputText([*c]const u8, []u8, InputTextFlags) bool;

// separator, generally horizontal. inside a menu bar or in horizontal layout mode, this becomes a vertical separator.
pub fn separator() void {
    ImGui_Separator();
}
extern fn ImGui_Separator() void;

// call between widgets or groups to layout them horizontally. X position given in window coordinates.
// @param offset_from_start Default = 0
// @param spacing Default = -1
pub fn sameLine(offset_from_start: f32, spacing: f32) void {
    ImGui_SameLine(offset_from_start, spacing);
}
extern fn ImGui_SameLine(f32, f32) void;

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

pub const Vec2ih = extern struct {
    x: u16,
    y: u16,
};

pub const Rect = extern struct {
    min: Vec2,
    max: Vec2,

    //ImVec2      GetCenter() const                   { return ImVec2((Min.x + Max.x) * 0.5f, (Min.y + Max.y) * 0.5f); }
    //ImVec2      GetSize() const                     { return ImVec2(Max.x - Min.x, Max.y - Min.y); }
    //float       GetWidth() const                    { return Max.x - Min.x; }
    //float       GetHeight() const                   { return Max.y - Min.y; }
    //float       GetArea() const                     { return (Max.x - Min.x) * (Max.y - Min.y); }
    //ImVec2      GetTL() const                       { return Min; }                   // Top-left
    //ImVec2      GetTR() const                       { return ImVec2(Max.x, Min.y); }  // Top-right
    //ImVec2      GetBL() const                       { return ImVec2(Min.x, Max.y); }  // Bottom-left
    //ImVec2      GetBR() const                       { return Max; }                   // Bottom-right
    //bool        Contains(const ImVec2& p) const     { return p.x     >= Min.x && p.y     >= Min.y && p.x     <  Max.x && p.y     <  Max.y; }
    //bool        Contains(const ImRect& r) const     { return r.Min.x >= Min.x && r.Min.y >= Min.y && r.Max.x <= Max.x && r.Max.y <= Max.y; }
    //bool        Overlaps(const ImRect& r) const     { return r.Min.y <  Max.y && r.Max.y >  Min.y && r.Min.x <  Max.x && r.Max.x >  Min.x; }
    //void        Add(const ImVec2& p)                { if (Min.x > p.x)     Min.x = p.x;     if (Min.y > p.y)     Min.y = p.y;     if (Max.x < p.x)     Max.x = p.x;     if (Max.y < p.y)     Max.y = p.y; }
    //void        Add(const ImRect& r)                { if (Min.x > r.Min.x) Min.x = r.Min.x; if (Min.y > r.Min.y) Min.y = r.Min.y; if (Max.x < r.Max.x) Max.x = r.Max.x; if (Max.y < r.Max.y) Max.y = r.Max.y; }
    //void        Expand(const float amount)          { Min.x -= amount;   Min.y -= amount;   Max.x += amount;   Max.y += amount; }
    //void        Expand(const ImVec2& amount)        { Min.x -= amount.x; Min.y -= amount.y; Max.x += amount.x; Max.y += amount.y; }
    //void        Translate(const ImVec2& d)          { Min.x += d.x; Min.y += d.y; Max.x += d.x; Max.y += d.y; }
    //void        TranslateX(float dx)                { Min.x += dx; Max.x += dx; }
    //void        TranslateY(float dy)                { Min.y += dy; Max.y += dy; }
    //void        ClipWith(const ImRect& r)           { Min = ImMax(Min, r.Min); Max = ImMin(Max, r.Max); }                   // Simple version, may lead to an inverted rectangle, which is fine for Contains/Overlaps test but not for display.
    //void        ClipWithFull(const ImRect& r)       { Min = ImClamp(Min, r.Min, r.Max); Max = ImClamp(Max, r.Min, r.Max); } // Full version, ensure both points are fully clipped.
    //void        Floor()                             { Min.x = IM_FLOOR(Min.x); Min.y = IM_FLOOR(Min.y); Max.x = IM_FLOOR(Max.x); Max.y = IM_FLOOR(Max.y); }
    //bool        IsInverted() const                  { return Min.x > Max.x || Min.y > Max.y; }
    //ImVec4      ToVec4() const                      { return ImVec4(Min.x, Min.y, Max.x, Max.y); }
}

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

pub fn pushStyleColor(slot: Col, color: Vec4) void {
    ImGui_PushStyleColor(slot, color);
}
extern fn ImGui_PushStyleColor(Col, Vec4) void;

pub fn popStyleColor(count: c_int) void {
    ImGui_PopStyleColor(count);
}
extern fn ImGui_PopStyleColor(c_int) void;

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
    NoCollapse             = 1 << 5,   // Disable user collapsing window by clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).
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

// Flags for DragFloat(), DragInt(), SliderFloat(), SliderInt() etc.
// We use the same sets of flags for DragXXX() and SliderXXX() functions as the features are the same and it makes it easier to swap them.
pub const SliderFlags = enum(c_int)
{
    None                   = 0,
    AlwaysClamp            = 1 << 4,       // Clamp value to min/max bounds when input manually with CTRL+Click. By default CTRL+Click allows going out of bounds.
    Logarithmic            = 1 << 5,       // Make the widget logarithmic (linear otherwise). Consider using NoRoundToFormat with this if using a format-string with small amount of digits.
    NoRoundToFormat        = 1 << 6,       // Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits)
    NoInput                = 1 << 7,       // Disable CTRL+Click or Enter key allowing to input text directly into the widget
    InvalidMask_           = 0x7000000F,   // [Internal] We treat using those bits as being potentially a 'float power' argument from the previous API that has got miscast to this enum, and will trigger an assert if needed.
};

// Flags for ImGui::InputText()
pub const InputTextFlags = enum(c_int)
{
    None                = 0,
    CharsDecimal        = 1 << 0,   // Allow 0123456789.+-*/
    CharsHexadecimal    = 1 << 1,   // Allow 0123456789ABCDEFabcdef
    CharsUppercase      = 1 << 2,   // Turn a..z into A..Z
    CharsNoBlank        = 1 << 3,   // Filter out spaces, tabs
    AutoSelectAll       = 1 << 4,   // Select entire text when first taking mouse focus
    EnterReturnsTrue    = 1 << 5,   // Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider looking at the IsItemDeactivatedAfterEdit() function.
    CallbackCompletion  = 1 << 6,   // Callback on pressing TAB (for completion handling)
    CallbackHistory     = 1 << 7,   // Callback on pressing Up/Down arrows (for history handling)
    CallbackAlways      = 1 << 8,   // Callback on each iteration. User code may query cursor position, modify text buffer.
    CallbackCharFilter  = 1 << 9,   // Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard.
    AllowTabInput       = 1 << 10,  // Pressing TAB input a '\t' character into the text field
    CtrlEnterForNewLine = 1 << 11,  // In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter).
    NoHorizontalScroll  = 1 << 12,  // Disable following the cursor horizontally
    AlwaysOverwrite     = 1 << 13,  // Overwrite mode
    ReadOnly            = 1 << 14,  // Read-only mode
    Password            = 1 << 15,  // Password mode, display all characters as '*'
    NoUndoRedo          = 1 << 16,  // Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
    CharsScientific     = 1 << 17,  // Allow 0123456789.+-*/eE (Scientific notation input)
    CallbackResize      = 1 << 18,  // Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow. Notify when the string wants to be resized (for string types which hold a cache of their Size). You will be provided a new BufSize in the callback and NEED to honor it. (see misc/cpp/imgui_stdlib.h for an example of using this)
    CallbackEdit        = 1 << 19,  // Callback on any edit (note that InputText() already returns true on edit, the callback is useful mainly to manipulate the underlying buffer while focus is active)
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
    WindowMenuButtonPosition: Dir,   // Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to Left.
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

// Helper: ImPool<>
// Basic keyed storage for contiguous instances, slow/amortized insertion, O(1) indexable, O(Log N) queries by ID over a dense/hot buffer,
// Honor constructor/destructor. Add/remove invalidate all pointers. Indexes have the same lifetime as the associated object.
pub const ImPoolIdx = c_int;

pub const ImPool = extern struct {
    Buf: ImVector,        // Contiguous data
    Map: Storage,        // ID->Index
    FreeIdx: ImPoolIdx,    // Next free idx to use
    AliveCount: ImPoolIdx, // Number of active/alive items (for display purpose)
};

///////////////////////////////////////////////////////////////////////////////
// Main
//

// start a new Dear ImGui frame, you can submit any command from this point until Render()/EndFrame().
pub fn newFrame() void {
    ImGui_NewFrame();
}
extern fn ImGui_NewFrame() void;

// ends the Dear ImGui frame. automatically called by Render(). If you don't need to render data (skipping rendering) you may call EndFrame() without Render()... but you'll have wasted CPU already! If you don't need to render, better to not create any windows and not call NewFrame() at all!
pub fn endFrame() void {
    ImGui_EndFrame();
}
extern fn ImGui_EndFrame() void;

// ends the Dear ImGui frame, finalize the draw data. You can then get call GetDrawData().
pub fn render() void {
    ImGui_Render();
}
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
