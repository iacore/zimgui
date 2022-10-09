#include "backends/imgui_impl_glfw.h"
#include "backends/imgui_impl_opengl3.h"
#include "backends/imgui_impl_opengl3_loader.h"

#define ZIMGUI_API extern "C"

ZIMGUI_API bool zimgui_ImGui_ImplGlfw_InitForOpenGL(void* window, bool install_callbacks)
{
  return ImGui_ImplGlfw_InitForOpenGL(reinterpret_cast<GLFWwindow*>(window), install_callbacks);
}

ZIMGUI_API void zimgui_ImGui_ImplGlfw_NewFrame()
{
  ImGui_ImplGlfw_NewFrame();
}

ZIMGUI_API bool zimgui_ImGui_ImplOpenGL3_Init(const char* glsl_version)
{
  return ImGui_ImplOpenGL3_Init(glsl_version);
}

ZIMGUI_API void zimgui_ImGui_ImplOpenGL3_NewFrame()
{
  ImGui_ImplOpenGL3_NewFrame();
}

ZIMGUI_API void zimgui_ImGui_ImplOpenGL3_RenderDrawData(void* draw_data)
{
  ImGui_ImplOpenGL3_RenderDrawData(reinterpret_cast<ImDrawData*>(draw_data));
}

ZIMGUI_API void zimgui_glViewport(int x, int y, size_t width, size_t height)
{
  glViewport(x, y, width, height);
}

ZIMGUI_API void zimgui_glClearColor(float red, float green, float blue, float alpha)
{
  glClearColor(red, green, blue, alpha);
}

ZIMGUI_API void zimgui_glClear(int mask)
{
  glClear(mask);
}

ZIMGUI_API void zimgui_glGenTextures(size_t count, unsigned int* textures)
{
  glGenTextures(count, textures);
}

ZIMGUI_API void zimgui_glBindTexture(unsigned int target, unsigned int texture)
{
  glBindTexture(target, texture);
}

ZIMGUI_API void zimgui_glDeleteTextures(size_t count, const unsigned int* textures)
{
  glDeleteTextures(count, textures);
}

//
