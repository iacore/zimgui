#include "imgui.h"

extern "C" void* ImGui_CreateContext(void* shared_font_atlas)
{
	return ImGui::CreateContext(reinterpret_cast<ImFontAtlas*>(shared_font_atlas));
}

extern "C" void ImGui_DestoryContext(void* context)
{
	ImGui::DestroyContext(reinterpret_cast<ImGuiContext*>(context));
}

extern "C" void* ImGui_GetCurrentContext()
{
	return ImGui::GetCurrentContext();
}

extern "C" void ImGui_SetCurrentContext(void* context)
{
	ImGui::SetCurrentContext(reinterpret_cast<ImGuiContext*>(context));
}

extern "C" bool ImGui_Begin(const char* name, bool* open = NULL, ImGuiWindowFlags flags = 0)
{
	return ImGui::Begin(name, open, flags);
}

extern "C" void ImGui_End()
{
	ImGui::End();
}

extern "C" void ImGui_Text(const char* text, size_t len)
{
	ImGui::TextUnformatted(text, text + len);
}

extern "C" void ImGui_TextColored(const ImVec4* color, const char* text)
{
	ImGui::TextColoredV(*color, text, {});
}

extern "C" ImVec2 ImGui_CalcTextSize(const char* text, size_t text_len, float wrap_width)
{
	return ImGui::CalcTextSize(text, text + text_len, false, wrap_width);
}

extern "C" bool ImGui_Button(const char* text, const ImVec2 size)
{
	return ImGui::Button(text, size);
}

extern "C" bool ImGui_SliderInt(const char* label, int* v, int v_min, int v_max, const char* fmt, ImGuiSliderFlags flags)
{
	return ImGui::SliderInt(label, v, v_min, v_max, fmt, flags);
}

extern "C" bool ImGui_InputText(const char* label, char* buf, size_t buflen, ImGuiInputTextFlags flags)
{
	return ImGui::InputText(label, buf, buflen, flags);
}

extern "C" void ImGui_Seprator()
{
	ImGui::Separator();
}

extern "C" void ImGui_SameLine(float offset_from_start, float spacing)
{
	ImGui::SameLine(offset_from_start, spacing);
}

extern "C" void ImGui_NewFrame()
{
	ImGui::NewFrame();
}

extern "C" void ImGui_EndFrame()
{
	ImGui::EndFrame();
}
extern "C" void ImGui_Render()
{
	ImGui::Render();
}

extern "C" void ImGui_ShowDemoWindow(bool* open)
{
	ImGui::ShowDemoWindow(open);
}

extern "C" void* ImGui_GetDrawData()
{
	return ImGui::GetDrawData();
}

extern "C" const char* ImGui_GetVersion()
{
	return ImGui::GetVersion();
}

extern "C" ImGuiIO ImGui_ImGuiIO()
{
	return ImGuiIO();
}

extern "C" ImGuiStyle* ImGui_GetStyle()
{
	return &ImGui::GetStyle();
}

extern "C" ImGuiIO* ImGui_GetIO()
{
	return &ImGui::GetIO();
}

extern "C" ImFont* ImGui_FontAtlas_AddFontFromFileTTF(void* font_atlas, const char* filename, float size_pixels, const ImFontConfig* font_cfg, const ImWchar* glyph_ranges)
{
	auto* font_atlas_typed = reinterpret_cast<ImFontAtlas*>(font_atlas);
	return font_atlas_typed->AddFontFromFileTTF(filename, size_pixels, font_cfg, glyph_ranges);
}

extern "C" void ImGui_FontAtlas_ClearFonts(void* font_atlas)
{
	auto* font_atlas_typed = reinterpret_cast<ImFontAtlas*>(font_atlas);
	font_atlas_typed->ClearFonts();
}

extern "C" bool ImGui_FontAtlas_Build(void* font_atlas)
{
	auto* typed_font_atlas = reinterpret_cast<ImFontAtlas*>(font_atlas);
	return typed_font_atlas->Build();
}

extern "C" const ImWchar* ImGui_FontAtlas_GetGlyphRangesDefault(void* font_atlas)
{
	auto* typed_font_atlas = reinterpret_cast<ImFontAtlas*>(font_atlas);
	return typed_font_atlas->GetGlyphRangesDefault();
}

extern "C" void ImGui_FontAtlas_GetTexDataAsRGBA32(void* font_atlas, unsigned char** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = NULL) {
	auto* typed_font_atlas = reinterpret_cast<ImFontAtlas*>(font_atlas);
	typed_font_atlas->GetTexDataAsRGBA32(out_pixels, out_width, out_height, out_bytes_per_pixel);
}

extern "C" void ImGui_PushFont(void* font) {
	ImGui::PushFont(reinterpret_cast<ImFont*>(font));
}

extern "C" void ImGui_PopFont() {
	ImGui::PopFont();
}

extern "C" void ImGui_PushStyleColor(ImGuiCol slot, ImVec4 color)
{
	ImGui::PushStyleColor(slot, color);
}

extern "C" void ImGui_PopStyleColor(int count)
{
	ImGui::PopStyleColor(count);
}

extern "C" ImFontConfig ImGui_FontConfig_FontConfig()
{
	return ImFontConfig();
}

//
