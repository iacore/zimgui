#include <cstddef>

#define ZIMAGE_API extern "C"

extern void* zimgui_malloc(size_t size);
extern void* zimgui_realloc(void* ptr, size_t size);
extern void zimgui_free(void* ptr);

#define STBI_MALLOC zimgui_malloc
#define STBI_REALLOC zimgui_realloc
#define STBI_FREE zimgui_free

#include "stb_image.h"

ZIMAGE_API bool zimage_load(const char* filename, int* x, int* y, int* channels_in_file, int desired_channels, unsigned char** out)
{
  *out = stbi_load(filename, x, y, channels_in_file, desired_channels);
  return out != NULL;
}

ZIMAGE_API bool zimage_load_from_memory(const unsigned char* data, size_t data_len, int* x, int* y, int* channels_in_file, int desired_channels, unsigned char** out)
{
  *out = stbi_load_from_memory(data, data_len, x, y, channels_in_file, desired_channels);
  return out != NULL;
}

ZIMAGE_API void zimage_free(unsigned char* returned_slice_from_load)
{
  stbi_image_free(returned_slice_from_load);
}

// end
