// zig bindings for stb_image


// DOCUMENTATION
//
// Limitations:
//    - no 12-bit-per-channel JPEG
//    - no JPEGs with arithmetic coding
//    - GIF always returns *comp=4
//
// Basic usage (see HDR discussion below for HDR usage):
//    int x,y,n;
//    unsigned char *data = stbi_load(filename, &x, &y, &n, 0);
//    // ... process data if not NULL ...
//    // ... x = width, y = height, n = # 8-bit components per pixel ...
//    // ... replace '0' with '1'..'4' to force that many components per pixel
//    // ... but 'n' will always be the number that it would have been if you said 0
//    stbi_image_free(data)
//
// Standard parameters:
//    int *x                 -- outputs image width in pixels
//    int *y                 -- outputs image height in pixels
//    int *channels_in_file  -- outputs # of image components in image file
//    int desired_channels   -- if non-zero, # of image components requested in result
//
// The return value from an image loader is an 'unsigned char *' which points
// to the pixel data, or NULL on an allocation failure or if the image is
// corrupt or invalid. The pixel data consists of *y scanlines of *x pixels,
// with each pixel consisting of N interleaved 8-bit components; the first
// pixel pointed to is top-left-most in the image. There is no padding between
// image scanlines or between pixels, regardless of format. The number of
// components N is 'desired_channels' if desired_channels is non-zero, or
// *channels_in_file otherwise. If desired_channels is non-zero,
// *channels_in_file has the number of components that _would_ have been
// output otherwise. E.g. if you set desired_channels to 4, you will always
// get RGBA output, but you can check *channels_in_file to see if it's trivially
// opaque because e.g. there were only 3 channels in the source image.
//
// An output image with N components has the following components interleaved
// in this order in each pixel:
//
//     N=#comp     components
//       1           grey
//       2           grey, alpha
//       3           red, green, blue
//       4           red, green, blue, alpha
//
// If image loading fails for any reason, the return value will be NULL,
// and *x, *y, *channels_in_file will be unchanged. The function
// stbi_failure_reason() can be queried for an extremely brief, end-user
// unfriendly explanation of why the load failed. Define STBI_NO_FAILURE_STRINGS
// to avoid compiling these strings at all, and STBI_FAILURE_USERMSG to get slightly
// more user-friendly ones.
//
// Paletted PNG, BMP, GIF, and PIC images are automatically depalettized.
//
// To query the width, height and component count of an image without having to
// decode the full file, you can use the stbi_info family of functions:
//
//   int x,y,n,ok;
//   ok = stbi_info(filename, &x, &y, &n);
//   // returns ok=1 and sets x, y, n if image is a supported format,
//   // 0 otherwise.
//
// Note that stb_image pervasively uses ints in its public API for sizes,
// including sizes of memory buffers. This is now part of the API and thus
// hard to change without causing breakage. As a result, the various image
// loaders all have certain limits on image size; these differ somewhat
// by format but generally boil down to either just under 2GB or just under
// 1GB. When the decoded image would be larger than this, stb_image decoding
// will fail.
//
// Additionally, stb_image will reject image files that have any of their
// dimensions set to a larger value than the configurable STBI_MAX_DIMENSIONS,
// which defaults to 2**24 = 16777216 pixels. Due to the above memory limit,
// the only way to have an image with such dimensions load correctly
// is for it to have a rather extreme aspect ratio. Either way, the
// assumption here is that such larger images are likely to be malformed
// or malicious. If you do need to load an image with individual dimensions
// larger than that, and it still fits in the overall size limit, you can
// #define STBI_MAX_DIMENSIONS on your own to be something larger.
pub fn load(filename: [:0]const u8, x: *i32, y: *i32, channels_in_file: *i32, desired_channels: i32) ?[]u8 {
    var ptr: [*]u8 = undefined;
    if (zimage_load(filename.ptr, x, y, channels_in_file, desired_channels, &ptr)) {
        if (x.* <= 0 and y.* <= 0) return null;
        var pixels = @intCast(usize, x.*) * @intCast(usize, y.*);
        var bytes = if (desired_channels == 0) @intCast(usize, channels_in_file.*) else @intCast(usize, desired_channels);
        var len = pixels * bytes;
        var slice: []u8 = ptr[0..len];
        return slice;
    }
    return null;
}
extern fn zimage_load([*]const u8, *i32, *i32, *i32, i32, *[*]u8) bool;

pub fn load_from_memory(data: []const u8, x: *i32, y: *i32, channels_in_file: *i32, desired_channels: i32) ?[]u8 {
    var ptr: [*]u8 = undefined;
    if (zimage_load_from_memory(data.ptr, data.len, x, y, channels_in_file, desired_channels, &ptr)) {
        if (x.* <= 0 and y.* <= 0) return null;
        var pixels = @intCast(usize, x.*) * @intCast(usize, y.*);
        var bytes = if (desired_channels == 0) @intCast(usize, channels_in_file.*) else @intCast(usize, desired_channels);
        var len = pixels * bytes;
        var slice: []u8 = ptr[0..len];
        return slice;
    }
    return null;
}
extern fn zimage_load_from_memory([*]const u8, usize, *i32, *i32, *i32, i32, *[*]u8) bool;

pub fn free(returned_slice_from_load: []u8) void {
    zimage_free(returned_slice_from_load.ptr);
}
extern fn zimage_free([*]u8) void;

///////////////////////////////////////////////////////////////////////////////

const std = @import("std");

gpa: std.heap.GeneralPurposeAllocator(.{.thread_safe = true}) = std.heap.GeneralPurposeAllocator(.{.thread_safe = true}){},
const Self = @This();

fn zimgui_malloc(size: usize) callconv(.C) *u8 {
    var allocator = Self.gpa.allocator();
    var res = allocator.alloc(size);
    return res.ptr;
}

fn zimgui_realloc(ptr: *u8, size: usize) callconv(.C) *u8 {
    var allocator = Self.gpa.allocator();
    var res = allocator.realloc(ptr, size);
    return res.ptr;
}

fn zimgui_free(ptr: *u8) callconv(.C) void {
    var allocator = Self.gpa.allocator();
    allocator.free(ptr);
}

//
