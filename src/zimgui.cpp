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

extern "C" void ImGui_Text(const char* fmt)
{
	ImGui::TextUnformatted(fmt);
}

extern "C" ImVec2 ImGui_CalcTextSize(const char* text, size_t text_len, float wrap_width)
{
	return ImGui::CalcTextSize(text, text + text_len, false, wrap_width);
}

extern "C" bool ImGui_Button(const char* text, const ImVec2* size)
{
	if (size) return ImGui::Button(text, *size);

	const ImVec2 _size(0, 0);
	return ImGui::Button(text, _size);
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

extern "C" ImFont* ImGui_FontAtlas_AddFontFromFileTTF(void* font_atlas, const char* filename, float size_pixels, const ImFontConfig* font_cfg = NULL, const ImWchar* glyph_ranges = NULL)
{
	auto* font_atlas_typed = reinterpret_cast<ImFontAtlas*>(font_atlas);
	return font_atlas_typed->AddFontFromFileTTF(filename, size_pixels, font_cfg, glyph_ranges);
}

extern "C" bool ImGui_FontAtlas_Build(void* font_atlas)
{
	auto* typed_font_atlas = reinterpret_cast<ImFontAtlas*>(font_atlas);
	return typed_font_atlas->Build();
}

extern "C" void ImGui_FontAtlas_GetTexDataAsRGBA32(void* font_atlas, unsigned char** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = NULL) {
	auto* typed_font_atlas = reinterpret_cast<ImFontAtlas*>(font_atlas);
	typed_font_atlas->GetTexDataAsRGBA32(out_pixels, out_width, out_height, out_bytes_per_pixel);
}

//
