#include "stb_image.h"

#define ZIMAGE_API extern "C"

ZIMAGE_API bool zimage_load(const char* filename, int* x, int* y, int* channels_in_file, int desired_channels, unsigned char** out)
{
  *out = stbi_load(filename, x, y, channels_in_file, desired_channels);
  return out != NULL;
}

ZIMAGE_API void zimage_free(unsigned char* returned_slice_from_load)
{
  stbi_image_free(returned_slice_from_load);
}

// end
