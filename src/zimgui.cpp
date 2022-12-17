#include "zimgui_imgui_ext.h"
#include "imgui_internal.h"

#define ZIMGUI_API extern "C"

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API ImGuiContext* zimgui_createContext(ImFontAtlas* shared_font_atlas)
{
  return ImGui::CreateContext(shared_font_atlas);
}

ZIMGUI_API void zimgui_destoryContext(ImGuiContext* context)
{
  ImGui::DestroyContext(context);
}

ZIMGUI_API ImGuiContext* zimgui_getCurrentContext()
{
  return ImGui::GetCurrentContext();
}

ZIMGUI_API ImDrawData* zimgui_getDrawData()
{
  return ImGui::GetDrawData();
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_newFrame()
{
  ImGui::NewFrame();
}

ZIMGUI_API void zimgui_endFrame()
{
  ImGui::EndFrame();
}

ZIMGUI_API void zimgui_render()
{
  ImGui::Render();
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_showDemoWindow(bool* open)
{
  ImGui::ShowDemoWindow(open);
}

ZIMGUI_API void zimgui_showMetricsWindow(bool* open)
{
  ImGui::ShowMetricsWindow(open);
}

ZIMGUI_API void zimgui_showStackToolWindow(bool* open)
{
  ImGui::ShowStackToolWindow(open);
}

ZIMGUI_API const char* zimgui_getVersion()
{
  return ImGui::GetVersion();
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_begin(const char* name, bool* open, ImGuiWindowFlags_ flags)
{
  ImGui::Begin(name, open, flags);
}

ZIMGUI_API void zimgui_end()
{
  ImGui::End();
}

ZIMGUI_API void zimgui_setNextWindowPos(float posx, float posy, unsigned int cond, float pivotx, float pivoty)
{
  ImGui::SetNextWindowPos({posx, posy}, cond, {pivotx, pivoty});
}

ZIMGUI_API void zimgui_setNextWindowSize(float sizex, float sizey, unsigned int cond)
{
  ImGui::SetNextWindowSize({sizex, sizey}, cond);
}

ZIMGUI_API void zimgui_setNextWindowFocus()
{
  ImGui::SetNextWindowFocus();
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_pushStyleColor(ImGuiCol_ style_col, unsigned int color)
{
  ImGui::PushStyleColor(style_col, color);
}

ZIMGUI_API void zimgui_popStyleColor(int count)
{
  ImGui::PopStyleColor(count);
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_separator()
{
  ImGui::Separator();
}

ZIMGUI_API void zimgui_sameLine(float offset_from_start_x, float spacing)
{
  ImGui::SameLine(offset_from_start_x, spacing);
}

ZIMGUI_API void zimgui_textUnformatted(const char* text, size_t len)
{
  ImGui::TextUnformatted(text, text + len);
}

ZIMGUI_API void zimgui_textColored(float r, float g, float b, float a, const char* text)
{
  ImGui::TextColored({r, g, b, a}, "%s", text);
}

ZIMGUI_API bool zimgui_button(const char* text, float x, float y)
{
  return ImGui::Button(text, {x, y});
}

ZIMGUI_API void zimgui_image(unsigned int texture_id, float x, float y, float uv0x, float uv0y, float uv1x, float uv1y)
{
  ImGui::Image(texture_id, {x, y}, {uv0x, uv0y}, {uv1x, uv1y});
}

ZIMGUI_API bool zimgui_imageButton(unsigned int texture_id, float x, float y, float uv0x, float uv0y, float uv1x, float uv1y)
{
  return ImGui::ImageButton(texture_id, {x, y}, {uv0x, uv0y}, {uv1x, uv1y});
}

ZIMGUI_API bool zimgui_ext_imageButtonEx(unsigned int im_id, unsigned int texture_id, float x, float y, float uv0x, float uv0y, float uv1x, float uv1y)
{
	return ImGui::ImageButtonEx(im_id, texture_id, {x, y}, {uv0x, uv0y}, {uv1x, uv1y}, {1, 1}, {0, 0, 0, 0}, {1, 1, 1, 1});
}

ZIMGUI_API bool zimgui_beginCombo(const char* label, const char* preview_value, ImGuiComboFlags flag)
{
  return ImGui::BeginCombo(label, preview_value, flag);
}

ZIMGUI_API void zimgui_endCombo()
{
  ImGui::EndCombo();
}

ZIMGUI_API bool zimgui_selectable(const char* label, bool selected, ImGuiSelectableFlags flags, float x, float y)
{
  return ImGui::Selectable(label, selected, flags, {x, y});
}

ZIMGUI_API bool zimgui_sliderInt(const char* label, int* v, int min, int max)
{
  return ImGui::SliderInt(label, v, min, max);
}

ZIMGUI_API bool zimgui_sliderFloat(const char* label, float* v, float min, float max)
{
	return ImGui::SliderFloat(label, v, min, max);
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_calcTextSize(const char* text, size_t len, float wrap_width, float* x, float* y)
{
  auto vec = ImGui::CalcTextSize(text, text + len, false, wrap_width);
  *x = vec.x;
  *y = vec.y;
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API ImGuiIO* zimgui_Context_getIo(ImGuiContext* context)
{
  return &context->IO;
}

ZIMGUI_API ImGuiStyle* zimgui_Context_getStyle(ImGuiContext* context)
{
  return &context->Style;
}

ZIMGUI_API ImGuiWindow* zimgui_Context_getCurrentWindow(ImGuiContext* context)
{
  return context->CurrentWindow;
}

ZIMGUI_API ImFont* zimgui_Context_getFont(ImGuiContext* context)
{
  return context->Font;
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API ImFontAtlas* zimgui_Io_getFontAtlas(ImGuiIO* io)
{
  return io->Fonts;
}

ZIMGUI_API void zimgui_Io_setDisplaySize(ImGuiIO* io, float width, float height)
{
  io->DisplaySize.x = width;
  io->DisplaySize.y = height;
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_Style_setColor(ImGuiStyle* style, ImGuiCol_ style_col, float x, float y, float z, float w)
{
  auto& color = style->Colors[style_col];
  color.x = x;
  color.y = y;
  color.z = z;
  color.w = w;
}

ZIMGUI_API void zimgui_Style_getColor(ImGuiStyle* style, ImGuiCol_ style_col, float* x, float* y, float* z, float* w)
{
  auto& color = style->Colors[style_col];
  *x = color.x;
  *y = color.y;
  *z = color.z;
  *w = color.w;
}

ZIMGUI_API void zimgui_Style_getFramePadding(ImGuiStyle* style, float* x, float* y)
{
  *x = style->FramePadding.x;
  *y = style->FramePadding.y;
}

ZIMGUI_API void zimgui_Style_getItemSpacing(ImGuiStyle* style, float* x, float* y)
{
  *x = style->ItemSpacing.x;
  *y = style->ItemSpacing.y;
}

ZIMGUI_API void zimgui_Style_getItemInnerSpacing(ImGuiStyle* style, float* x, float* y)
{
  *x = style->ItemInnerSpacing.x;
  *y = style->ItemInnerSpacing.y;
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API ImDrawList* zimgui_Window_getDrawList(ImGuiWindow* window)
{
  return window->DrawList;
}

ZIMGUI_API void zimgui_Window_getPos(ImGuiWindow* window, float* x, float* y)
{
  *x = window->Pos.x;
  *y = window->Pos.y;
}

ZIMGUI_API void zimgui_Window_getSize(ImGuiWindow* window, float* x, float* y)
{
  *x = window->Size.x;
  *y = window->Size.y;
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_DrawList_addLine(ImDrawList* draw_list, float p1_x, float p1_y, float p2_x, float p2_y, unsigned int color, float thickness)
{
  draw_list->AddLine({p1_x, p1_y}, {p2_x, p2_y}, color, thickness);
}

ZIMGUI_API void zimgui_DrawList_addRectFilled(ImDrawList* draw_list, float min_x, float min_y, float max_x, float max_y, unsigned int color, float rounding, ImDrawFlags_ flags)
{
  draw_list->AddRectFilled({min_x, min_y}, {max_x, max_y}, color, rounding, flags);
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API void zimgui_FontAtlas_getTexDataAsRGBA32(ImFontAtlas* font_atlas, unsigned char** text_pixels, int* text_w, int* text_h, int* bytes_per_pixel)
{
  return font_atlas->GetTexDataAsRGBA32(text_pixels, text_w, text_h, bytes_per_pixel);
}

ZIMGUI_API void zimgui_FontAtlas_addFontFromFileTTF(ImFontAtlas* font_atlas, const char* filename, float size_pixels)
{
  font_atlas->AddFontFromFileTTF(filename, size_pixels);
}

ZIMGUI_API bool zimgui_FontAtlas_build(ImFontAtlas* font_atlas)
{
  return font_atlas->Build();
}

///////////////////////////////////////////////////////////////////////////////

ZIMGUI_API float zimgui_Font_getFallbackAdvanceX(ImFont* font)
{
  return font->FallbackAdvanceX;
}

ZIMGUI_API float zimgui_Font_getFontSize(ImFont* font)
{
  return font->FontSize;
}

///////////////////////////////////////////////////////////////////////////////

//ZIMGUI_API void zimgui_Ext_addText(ImGuiContext* context, float font_size, float pos_x, float pos_y, const char* text, size_t textlen, float wrap_width, const float* clip_rect_min_x, const float* clip_rect_min_y, const float* clip_rect_max_x, const float* clip_rect_max_y, const unsigned int* colorlen, size_t colorlen_len);

//ZIMGUI_API void zimgui_Ext_calcBbForCharInText(ImGuiContext* context, float font_size, float x, float y, const char* text, size_t len, float wrap_width, size_t char_index, float* min_x, float* min_y, float* max_x, float* max_y);

//
