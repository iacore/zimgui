#include "backends/imgui_impl_glfw.h"
#include "backends/imgui_impl_opengl3.h"
#include "backends/imgui_impl_opengl3_loader.h"

extern "C" bool Z_ImGui_ImplGlfw_InitForOpenGL(void* window, bool install_callbacks)
{
	return ImGui_ImplGlfw_InitForOpenGL(reinterpret_cast<GLFWwindow*>(window), install_callbacks);
}

extern "C" void Z_ImGui_ImplGlfw_NewFrame()
{
	ImGui_ImplGlfw_NewFrame();
}

extern "C" bool Z_ImGui_ImplOpenGL3_Init(const char* glsl_version)
{
	return ImGui_ImplOpenGL3_Init(glsl_version);
}

extern "C" void Z_ImGui_ImplOpenGL3_NewFrame()
{
	ImGui_ImplOpenGL3_NewFrame();
}

extern "C" void Z_ImGui_ImplOpenGL3_RenderDrawData(void* draw_data)
{
	ImGui_ImplOpenGL3_RenderDrawData(reinterpret_cast<ImDrawData*>(draw_data));
}

extern "C" void Z_glViewport(int x, int y, size_t width, size_t height)
{
	glViewport(x, y, width, height);
}

extern "C" void Z_glClearColor(float red, float green, float blue, float alpha)
{
	glClearColor(red, green, blue, alpha);
}

extern "C" void Z_glClear(int mask)
{
	glClear(mask);
}

//
