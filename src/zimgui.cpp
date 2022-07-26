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

//
