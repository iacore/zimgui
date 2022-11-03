#include "glad/glad.h"
#include "backends/imgui_impl_glfw.h"
#include "backends/imgui_impl_opengl3.h"

#define ZIMGUI_API extern "C"

using uint = unsigned int;

ZIMGUI_API bool zimgui_ImGui_ImplGlfw_InitForOpenGL(void* window, bool install_callbacks)
{
  return ImGui_ImplGlfw_InitForOpenGL(reinterpret_cast<GLFWwindow*>(window), install_callbacks);
}

ZIMGUI_API void zimgui_ImGui_ImplGlfw_NewFrame()
{
  ImGui_ImplGlfw_NewFrame();
}

ZIMGUI_API bool zimgui_ImGui_ImplOpenGl3_Init(const char* glsl_version)
{
  return ImGui_ImplOpenGL3_Init(glsl_version);
}

ZIMGUI_API void zimgui_ImGui_ImplOpenGl3_NewFrame()
{
  ImGui_ImplOpenGL3_NewFrame();
}

ZIMGUI_API void zimgui_ImGui_ImplOpenGl3_RenderDrawData(void* draw_data)
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

ZIMGUI_API void zimgui_glGenTextures(size_t count, uint* textures)
{
  glGenTextures(static_cast<int>(count), textures);
}

ZIMGUI_API void zimgui_glBindTexture(uint target, uint texture)
{
  glBindTexture(target, texture);
}

ZIMGUI_API void zimgui_glDeleteTextures(size_t count, const uint* textures)
{
  glDeleteTextures(count, textures);
}

ZIMGUI_API void zimgui_glTextureParameteri(uint id, int pname, int param)
{
  glTextureParameteri(id, pname, param);
}

ZIMGUI_API void zimgui_glTextureParameterfv(uint id, int pname, const float* params)
{
  glTextureParameterfv(id, pname, params);
}

ZIMGUI_API void zimgui_glTextureStorage2D(uint texture, int levels, int format, int width, int height)
{
  glTextureStorage2D(texture, levels, format, width, height);
}

ZIMGUI_API void zimgui_glTextureSubImage2D(uint texture, uint level, int xoffset, int yoffset, int width, int height, int format, int type_, const void* pixels)
{
  glTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, type_, pixels);
}

ZIMGUI_API int zimgui_glGetError()
{
  return glGetError();
}

ZIMGUI_API void zimgui_glDebugMessageCallback(GLDEBUGPROC callback, const void *user_param)
{
  glDebugMessageCallback(callback, user_param);
}

ZIMGUI_API void zimgui_glEnable(int cap)
{
  glEnable(cap);
}

ZIMGUI_API void zimgui_gladLoadGLLoader(GLADloadproc fn)
{
  gladLoadGLLoader(fn);
}
