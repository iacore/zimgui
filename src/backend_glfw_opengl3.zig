const std = @import("std");

pub const Glfw = struct {
    pub fn initForOpenGL(window: *anyopaque, install_callbacks: bool) bool {
        return zimgui_ImGui_ImplGlfw_InitForOpenGL(window, install_callbacks);
    }
    extern fn zimgui_ImGui_ImplGlfw_InitForOpenGL(*anyopaque, bool) bool;

    pub fn newFrame() void {
        zimgui_ImGui_ImplGlfw_NewFrame();
    }
    extern fn zimgui_ImGui_ImplGlfw_NewFrame() void;
};

pub const OpenGl3 = struct {
    pub fn init(glsl_version: [*c]const u8) bool {
        return zimgui_ImGui_ImplOpenGl3_Init(glsl_version);
    }
    extern fn zimgui_ImGui_ImplOpenGl3_Init([*c]const u8) bool;

    pub fn newFrame() void {
        zimgui_ImGui_ImplOpenGl3_NewFrame();
    }
    extern fn zimgui_ImGui_ImplOpenGl3_NewFrame() void;

    pub fn renderDrawData(draw_data: *anyopaque) void {
        zimgui_ImGui_ImplOpenGl3_RenderDrawData(draw_data);
    }
    extern fn zimgui_ImGui_ImplOpenGl3_RenderDrawData(*anyopaque) void;

    /// x, y
    ///   Specify the lower left corner of the viewport rectangle, in pixels. The initial value is (0,0).
    /// width, height
    ///   Specify the width and height of the viewport. When a GL context is first attached to a window, width and height are set to the dimensions of that window.
    /// glViewport specifies the affine transformation of x and y from normalized device coordinates to window coordinates. Let (xnd,ynd) be normalized device coordinates. Then the window coordinates (xw,yw)
    /// are computed as follows:
    ///    xw=(xnd+1)(width2)+x
    ///    yw=(ynd+1)(height2)+y
    /// Viewport width and height are silently clamped to a range that depends on the implementation. To query this range, call glGet with argument GL_MAX_VIEWPORT_DIMS.
    /// GL_INVALID_VALUE is generated if either width or height is negative.
    pub fn viewport(x: i32, y: i32, width: i32, height: i32) error{InvalidOperation}!void {
        zimgui_glViewport(x, y, width, height);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glViewport(i32, i32, i32, i32) void;

    /// red, green, blue, alpha
    ///  Specify the red, green, blue, and alpha values used when the color buffers are cleared. The initial values are all 0.
    /// glClearColor specifies the red, green, blue, and alpha values used by glClear to clear the color buffers. Values specified by glClearColor are clamped to the range [0,1].
    pub fn clearColor(red: f32, green: f32, blue: f32, alpha: f32) void {
        zimgui_glClearColor(red, green, blue, alpha);
    }
    extern fn zimgui_glClearColor(f32, f32, f32, f32) void;

    /// mask
    ///  Bitwise OR of masks that indicate the buffers to be cleared. The three masks are GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT, and GL_STENCIL_BUFFER_BIT.
    /// glClear sets the bitplane area of the window to values previously selected by glClearColor, glClearDepth, and glClearStencil. Multiple color buffers can be cleared simultaneously by selecting more than one buffer at a time using glDrawBuffer.
    /// The pixel ownership test, the scissor test, dithering, and the buffer writemasks affect the operation of glClear. The scissor box bounds the cleared region. Alpha function, blend function, logical operation, stenciling, texture mapping, and depth-buffering are ignored by glClear.
    /// glClear takes a single argument that is the bitwise OR of several values indicating which buffer is to be cleared.
    /// The values are as follows:
    ///    GL_COLOR_BUFFER_BIT
    /// Indicates the buffers currently enabled for color writing.
    ///    GL_DEPTH_BUFFER_BIT
    /// Indicates the depth buffer.
    ///    GL_STENCIL_BUFFER_BIT
    /// Indicates the stencil buffer.
    /// The value to which each buffer is cleared depends on the setting of the clear value for that buffer.
    /// GL_INVALID_VALUE is generated if any bit other than the three defined bits is set in mask.
    pub fn clear(mask: ValueType) error{InvalidValue}!void {
        zimgui_glClear(mask);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glClear(ValueType) void;

    /// textures
    ///   Specifies an array in which the generated texture names are stored.
    /// glGenTextures returns n texture names in textures. There is no guarantee that the names form a contiguous set of integers; however, it is guaranteed that none of the returned names was in use immediately before the call to glGenTextures.
    /// The generated textures have no dimensionality; they assume the dimensionality of the texture target to which they are first bound (see glBindTexture).
    /// Texture names returned by a call to glGenTextures are not returned by subsequent calls, unless they are first deleted with glDeleteTextures.
    /// GL_INVALID_VALUE is generated if n is negative.
    pub fn genTextures(textures: []TextureId) error{InvalidValue}!void {
        zimgui_glGenTextures(textures.len, textures.ptr);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glGenTextures(usize, [*]u32) void;

    /// target
    ///  Specifies the target to which the texture is bound. Must be one of GL_TEXTURE_1D, GL_TEXTURE_2D, GL_TEXTURE_3D, GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D_ARRAY, GL_TEXTURE_RECTANGLE, GL_TEXTURE_CUBE_MAP, GL_TEXTURE_CUBE_MAP_ARRAY, GL_TEXTURE_BUFFER, GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY.
    /// texture
    ///   Specifies the name of a texture.
    ///
    /// glBindTexture lets you create or use a named texture. Calling glBindTexture with target set to GL_TEXTURE_1D, GL_TEXTURE_2D, GL_TEXTURE_3D, GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D_ARRAY, GL_TEXTURE_RECTANGLE, GL_TEXTURE_CUBE_MAP, GL_TEXTURE_CUBE_MAP_ARRAY, GL_TEXTURE_BUFFER, GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY and texture set to the name of the new texture binds the texture name to the target. When a texture is bound to a target, the previous binding for that target is automatically broken.
    /// Texture names are unsigned integers. The value zero is reserved to represent the default texture for each texture target. Texture names and the corresponding texture contents are local to the shared object space of the current GL rendering context; two rendering contexts share texture names only if they explicitly enable sharing between contexts through the appropriate GL windows interfaces functions.
    /// You must use glGenTextures to generate a set of new texture names.
    /// When a texture is first bound, it assumes the specified target: A texture first bound to GL_TEXTURE_1D becomes one-dimensional texture, a texture first bound to GL_TEXTURE_2D becomes two-dimensional texture, a texture first bound to GL_TEXTURE_3D becomes three-dimensional texture, a texture first bound to GL_TEXTURE_1D_ARRAY becomes one-dimensional array texture, a texture first bound to GL_TEXTURE_2D_ARRAY becomes two-dimensional array texture, a texture first bound to GL_TEXTURE_RECTANGLE becomes rectangle texture, a texture first bound to GL_TEXTURE_CUBE_MAP becomes a cube-mapped texture, a texture first bound to GL_TEXTURE_CUBE_MAP_ARRAY becomes a cube-mapped array texture, a texture first bound to GL_TEXTURE_BUFFER becomes a buffer texture, a texture first bound to GL_TEXTURE_2D_MULTISAMPLE becomes a two-dimensional multisampled texture, and a texture first bound to GL_TEXTURE_2D_MULTISAMPLE_ARRAY becomes a two-dimensional multisampled array texture. The state of a one-dimensional texture immediately after it is first bound is equivalent to the state of the default GL_TEXTURE_1D at GL initialization, and similarly for the other texture types.
    /// While a texture is bound, GL operations on the target to which it is bound affect the bound texture, and queries of the target to which it is bound return state from the bound texture. In effect, the texture targets become aliases for the textures currently bound to them, and the texture name zero refers to the default textures that were bound to them at initialization.
    /// A texture binding created with glBindTexture remains active until a different texture is bound to the same target, or until the bound texture is deleted with glDeleteTextures.
    /// Once created, a named texture may be re-bound to its same original target as often as needed. It is usually much faster to use glBindTexture to bind an existing named texture to one of the texture targets than it is to reload the texture image using glTexImage1D, glTexImage2D, glTexImage3D or another similar function.
    /// GL_INVALID_ENUM is generated if target is not one of the allowable values.
    /// GL_INVALID_VALUE is generated if texture is not a name returned from a previous call to glGenTextures.
    /// GL_INVALID_OPERATION is generated if texture was previously created with a target that doesn't match that of target.
    pub fn bindTexture(target: ValueType, texture: TextureId) error{ InvalidEnum, InvalidValue, InvalidOperation }!void {
        zimgui_glBindTexture(target, texture);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glBindTexture(ValueType, TextureId) void;

    /// glDeleteTextures deletes n textures named by the elements of the array textures. After a texture is deleted, it has no contents or dimensionality, and its name is free for reuse (for example by glGenTextures). If a texture that is currently bound is deleted, the binding reverts to 0 (the default texture).
    /// glDeleteTextures silently ignores 0's and names that do not correspond to existing textures.
    pub fn deleteTextures(textures: []const TextureId) void {
        zimgui_glDeleteTextures(@as(i32, @intCast(textures.len)), textures.ptr);
    }
    extern fn zimgui_glDeleteTextures(i32, [*]const u32) void;

    /// glTexParameter and glTextureParameter assign the value or values in params to the texture parameter specified as pname. For glTexParameter, target defines the target texture, either GL_TEXTURE_1D, GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D, GL_TEXTURE_2D_ARRAY, GL_TEXTURE_2D_MULTISAMPLE, GL_TEXTURE_2D_MULTISAMPLE_ARRAY, GL_TEXTURE_3D, GL_TEXTURE_CUBE_MAP, GL_TEXTURE_CUBE_MAP_ARRAY, or GL_TEXTURE_RECTANGLE. The following symbols are accepted in pname:
    /// Errors
    /// GL_INVALID_ENUM is generated by glTexParameter if target is not one of the accepted defined values.
    /// GL_INVALID_ENUM is generated if pname is not one of the accepted defined values.
    /// GL_INVALID_ENUM is generated if params should have a defined constant value (based on the value of pname) and does not.
    /// GL_INVALID_ENUM is generated if glTexParameter{if} or glTextureParameter{if} is called for a non-scalar parameter (pname GL_TEXTURE_BORDER_COLOR or GL_TEXTURE_SWIZZLE_RGBA).
    /// GL_INVALID_ENUM is generated if the effective target is either GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY, and pname is any of the sampler states.
    /// GL_INVALID_ENUM is generated if the effective target is GL_TEXTURE_RECTANGLE and either of pnames GL_TEXTURE_WRAP_S or GL_TEXTURE_WRAP_T is set to either GL_MIRROR_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT or GL_REPEAT.
    /// GL_INVALID_ENUM is generated if the effective target is GL_TEXTURE_RECTANGLE and pname GL_TEXTURE_MIN_FILTER is set to a value other than GL_NEAREST or GL_LINEAR (no mipmap filtering is permitted).
    /// GL_INVALID_OPERATION is generated if the effective target is either GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY, and pname GL_TEXTURE_BASE_LEVEL is set to a value other than zero.
    /// GL_INVALID_OPERATION is generated by glTextureParameter if texture is not the name of an existing texture object.
    /// GL_INVALID_OPERATION is generated if the effective target is GL_TEXTURE_RECTANGLE and pname GL_TEXTURE_BASE_LEVEL is set to any value other than zero.
    /// GL_INVALID_VALUE is generated if pname is GL_TEXTURE_BASE_LEVEL or GL_TEXTURE_MAX_LEVEL, and param or params is negative.
    pub fn textureParameteri(id: TextureId, pname: ValueType, param: ValueType) error{ InvalidEnum, InvalidOperation, InvalidValue }!void {
        zimgui_glTextureParameteri(id, pname, param);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_OPERATION => return error.InvalidOperation,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glTextureParameteri(TextureId, ValueType, ValueType) void;

    /// glTexParameter and glTextureParameter assign the value or values in params to the texture parameter specified as pname. For glTexParameter, target defines the target texture, either GL_TEXTURE_1D, GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D, GL_TEXTURE_2D_ARRAY, GL_TEXTURE_2D_MULTISAMPLE, GL_TEXTURE_2D_MULTISAMPLE_ARRAY, GL_TEXTURE_3D, GL_TEXTURE_CUBE_MAP, GL_TEXTURE_CUBE_MAP_ARRAY, or GL_TEXTURE_RECTANGLE. The following symbols are accepted in pname:
    /// Errors
    /// GL_INVALID_ENUM is generated by glTexParameter if target is not one of the accepted defined values.
    /// GL_INVALID_ENUM is generated if pname is not one of the accepted defined values.
    /// GL_INVALID_ENUM is generated if params should have a defined constant value (based on the value of pname) and does not.
    /// GL_INVALID_ENUM is generated if glTexParameter{if} or glTextureParameter{if} is called for a non-scalar parameter (pname GL_TEXTURE_BORDER_COLOR or GL_TEXTURE_SWIZZLE_RGBA).
    /// GL_INVALID_ENUM is generated if the effective target is either GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY, and pname is any of the sampler states.
    /// GL_INVALID_ENUM is generated if the effective target is GL_TEXTURE_RECTANGLE and either of pnames GL_TEXTURE_WRAP_S or GL_TEXTURE_WRAP_T is set to either GL_MIRROR_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT or GL_REPEAT.
    /// GL_INVALID_ENUM is generated if the effective target is GL_TEXTURE_RECTANGLE and pname GL_TEXTURE_MIN_FILTER is set to a value other than GL_NEAREST or GL_LINEAR (no mipmap filtering is permitted).
    /// GL_INVALID_OPERATION is generated if the effective target is either GL_TEXTURE_2D_MULTISAMPLE or GL_TEXTURE_2D_MULTISAMPLE_ARRAY, and pname GL_TEXTURE_BASE_LEVEL is set to a value other than zero.
    /// GL_INVALID_OPERATION is generated by glTextureParameter if texture is not the name of an existing texture object.
    /// GL_INVALID_OPERATION is generated if the effective target is GL_TEXTURE_RECTANGLE and pname GL_TEXTURE_BASE_LEVEL is set to any value other than zero.
    /// GL_INVALID_VALUE is generated if pname is GL_TEXTURE_BASE_LEVEL or GL_TEXTURE_MAX_LEVEL, and param or params is negative.
    pub fn textureParameterfv(id: TextureId, pname: ValueType, params: [*]const f32) error{ InvalidEnum, InvalidOperation, InvalidValue }!void {
        zimgui_glTextureParameterfv(id, pname, params);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_OPERATION => return error.InvalidOperation,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glTextureParameterfv(TextureId, ValueType, [*]const f32) void;

    /// glTexStorage2D and glTextureStorage2D specify the storage requirements for all levels of a two-dimensional texture or one-dimensional texture array simultaneously. Once a texture is specified with this command, the format and dimensions of all levels become immutable unless it is a proxy texture. The contents of the image may still be modified, however, its storage requirements may not change. Such a texture is referred to as an immutable-format texture.
    /// Errors
    /// GL_INVALID_OPERATION is generated by glTexStorage2D if zero is bound to target.
    /// GL_INVALID_OPERATION is generated by glTextureStorage2D if texture is not the name of an existing texture object.
    /// GL_INVALID_ENUM is generated if internalformat is not a valid sized internal format.
    /// GL_INVALID_ENUM is generated if target or the effective target of texture is not one of the accepted targets described above.
    /// GL_INVALID_VALUE is generated if width, height or levels are less than 1.
    /// GL_INVALID_OPERATION is generated if target is GL_TEXTURE_1D_ARRAY or GL_PROXY_TEXTURE_1D_ARRAY and levels is greater than |log2(width)|+1
    /// GL_INVALID_OPERATION is generated if target is not GL_TEXTURE_1D_ARRAY or GL_PROXY_TEXTURE_1D_ARRAY and levels is greater than |log2(max(width,height))|+1
    pub fn textureStorage2D(texture: TextureId, levels: i32, format: ValueType, width: i32, height: i32) error{ InvalidOperation, InvalidEnum, InvalidValue }!void {
        zimgui_glTextureStorage2D(texture, levels, format, width, height);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_OPERATION => return error.InvalidOperation,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glTextureStorage2D(TextureId, i32, ValueType, i32, i32) void;

    /// Texturing maps a portion of a specified texture image onto each graphical primitive for which texturing is enabled.
    /// glTexSubImage2D and glTextureSubImage2D redefine a contiguous subregion of an existing two-dimensional or one-dimensional array texture image. The texels referenced by pixels replace the portion of the existing texture array with x indices xoffset and xoffset+width-1
    /// , inclusive, and y indices yoffset and yoffset+height-1
    /// , inclusive. This region may not include any texels outside the range of the texture array as it was originally specified. It is not an error to specify a subtexture with zero width or height, but such a specification has no effect.
    /// If a non-zero named buffer object is bound to the GL_PIXEL_UNPACK_BUFFER target (see glBindBuffer) while a texture image is specified, pixels is treated as a byte offset into the buffer object's data store.
    /// Errors
    /// GL_INVALID_ENUM is generated if target or the effective target of texture is not GL_TEXTURE_2D, GL_TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, or GL_TEXTURE_1D_ARRAY.
    /// GL_INVALID_OPERATION is generated by glTextureSubImage2D if texture is not the name of an existing texture object.
    /// GL_INVALID_ENUM is generated if format is not an accepted format constant.
    /// GL_INVALID_ENUM is generated if type is not a type constant.
    /// GL_INVALID_VALUE is generated if level is less than 0.
    /// GL_INVALID_VALUE may be generated if level is greater than log2
    ///    max, where max is the returned value of GL_MAX_TEXTURE_SIZE.
    /// GL_INVALID_VALUE is generated if xoffset<-b
    ///    , (xoffset+width)>(w-b), yoffset<-b, or (yoffset+height)>(h-b), where w is the GL_TEXTURE_WIDTH, h is the GL_TEXTURE_HEIGHT, and b is the border width of the texture image being modified. Note that w and h include twice the border width.
    /// GL_INVALID_VALUE is generated if width or height is less than 0.
    /// GL_INVALID_OPERATION is generated if the texture array has not been defined by a previous glTexImage2D operation.
    /// GL_INVALID_OPERATION is generated if type is one of GL_UNSIGNED_BYTE_3_3_2, GL_UNSIGNED_BYTE_2_3_3_REV, GL_UNSIGNED_SHORT_5_6_5, or GL_UNSIGNED_SHORT_5_6_5_REV and format is not GL_RGB.
    /// GL_INVALID_OPERATION is generated if type is one of GL_UNSIGNED_SHORT_4_4_4_4, GL_UNSIGNED_SHORT_4_4_4_4_REV, GL_UNSIGNED_SHORT_5_5_5_1, GL_UNSIGNED_SHORT_1_5_5_5_REV, GL_UNSIGNED_INT_8_8_8_8, GL_UNSIGNED_INT_8_8_8_8_REV, GL_UNSIGNED_INT_10_10_10_2, or GL_UNSIGNED_INT_2_10_10_10_REV and format is neither GL_RGBA nor GL_BGRA.
    /// GL_INVALID_OPERATION is generated if format is GL_STENCIL_INDEX and the base internal format is not GL_STENCIL_INDEX.
    /// GL_INVALID_OPERATION is generated if a non-zero buffer object name is bound to the GL_PIXEL_UNPACK_BUFFER target and the buffer object's data store is currently mapped.
    /// GL_INVALID_OPERATION is generated if a non-zero buffer object name is bound to the GL_PIXEL_UNPACK_BUFFER target and the data would be unpacked from the buffer object such that the memory reads required would exceed the data store size.
    /// GL_INVALID_OPERATION is generated if a non-zero buffer object name is bound to the GL_PIXEL_UNPACK_BUFFER target and pixels is not evenly divisible into the number of bytes needed to store in memory a datum indicated by type.
    pub fn textureSubImage2D(texture: TextureId, level: i32, xoffset: i32, yoffset: i32, width: i32, height: i32, format: ValueType, type_: ValueType, pixels: *const anyopaque) error{ InvalidEnum, InvalidOperation, InvalidValue }!void {
        zimgui_glTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, type_, pixels);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glTextureSubImage2D(TextureId, i32, i32, i32, i32, i32, ValueType, ValueType, *const anyopaque) void;

    pub fn getError() ValueType {
        return zimgui_glGetError();
    }
    extern fn zimgui_glGetError() i32;

    /// glGenerateMipmap and glGenerateTextureMipmap generates mipmaps for the specified texture object. For glGenerateMipmap, the texture object that is bound to target. For glGenerateTextureMipmap, texture is the name of the texture object.
    /// For cube map and cube map array textures, the texture object must be cube complete or cube array complete respectively.
    /// Mipmap generation replaces texel image levels levelbase+1 through q with images derived from the levelbase image, regardless of their previous contents. All other mimap images, including the levelbase+1 image, are left unchanged by this computation.
    /// The internal formats of the derived mipmap images all match those of the levelbase
    /// image. The contents of the derived images are computed by repeated, filtered reduction of the levelbase+1 image. For one- and two-dimensional array and cube map array textures, each layer is filtered independently.
    /// Errors
    /// GL_INVALID_ENUM is generated by glGenerateMipmap if target is not one of the accepted texture targets.
    /// GL_INVALID_OPERATION is generated by glGenerateTextureMipmap if texture is not the name of an existing texture object.
    /// GL_INVALID_OPERATION is generated if target is GL_TEXTURE_CUBE_MAP or GL_TEXTURE_CUBE_MAP_ARRAY, and the specified texture object is not cube complete or cube array complete, respectively.
    pub fn generateTextureMipmap(id: TextureId) error{ InvalidEnum, InvalidOperation }!void {
        zimgui_glGenerateTextureMipmap(id);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glGenerateTextureMipmap(TextureId) void;

    /// glPixelStorei sets pixel storage modes that affect the operation of subsequent glReadPixels as well as the unpacking of texture patterns (see glTexImage2D, glTexImage3D, glTexSubImage2D, glTexSubImage3D).
    /// pname is a symbolic constant indicating the parameter to be set, and param is the new value. Four of the ten storage parameters affect how pixel data is returned to client memory. They are as follows:
    /// Errors
    /// GL_INVALID_ENUM is generated if pname is not an accepted value.
    /// GL_INVALID_VALUE is generated if a negative row length, pixel skip, or row skip value is specified, or if alignment is specified as other than 1, 2, 4, or 8.
    pub fn pixelStorei(pname: ValueType, param: i32) error{ InvalidEnum, InvalidValue }!void {
        zimgui_glPixelStorei(pname, param);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glPixelStorei(ValueType, i32) void;

    /// glUseProgram installs the program object specified by program as part of current rendering state. One or more executables are created in a program object by successfully attaching shader objects to it with glAttachShader, successfully compiling the shader objects with glCompileShader, and successfully linking the program object with glLinkProgram.
    /// A program object will contain an executable that will run on the vertex processor if it contains one or more shader objects of type GL_VERTEX_SHADER that have been successfully compiled and linked. A program object will contain an executable that will run on the geometry processor if it contains one or more shader objects of type GL_GEOMETRY_SHADER that have been successfully compiled and linked. Similarly, a program object will contain an executable that will run on the fragment processor if it contains one or more shader objects of type GL_FRAGMENT_SHADER that have been successfully compiled and linked.
    /// While a program object is in use, applications are free to modify attached shader objects, compile attached shader objects, attach additional shader objects, and detach or delete shader objects. None of these operations will affect the executables that are part of the current state. However, relinking the program object that is currently in use will install the program object as part of the current rendering state if the link operation was successful (see glLinkProgram ). If the program object currently in use is relinked unsuccessfully, its link status will be set to GL_FALSE, but the executables and associated state will remain part of the current state until a subsequent call to glUseProgram removes it from use. After it is removed from use, it cannot be made part of current state until it has been successfully relinked.
    /// If program is zero, then the current rendering state refers to an invalid program object and the results of shader execution are undefined. However, this is not an error.
    /// If program does not contain shader objects of type GL_FRAGMENT_SHADER, an executable will be installed on the vertex, and possibly geometry processors, but the results of fragment shader execution will be undefined.
    /// Errors
    /// GL_INVALID_VALUE is generated if program is neither 0 nor a value generated by OpenGL.
    /// GL_INVALID_OPERATION is generated if program is not a program object.
    /// GL_INVALID_OPERATION is generated if program could not be made part of current state.
    /// GL_INVALID_OPERATION is generated if transform feedback mode is active.
    pub fn useProgram(program: u32) error{ InvalidValue, InvalidOperation }!void {
        zimgui_glUseProgram(program);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glUseProgram(u32) void;

    /// glDrawElements specifies multiple geometric primitives with very few subroutine calls. Instead of calling a GL function to pass each individual vertex, normal, texture coordinate, edge flag, or color, you can prespecify separate arrays of vertices, normals, and so on, and use them to construct a sequence of primitives with a single call to glDrawElements.
    /// When glDrawElements is called, it uses count sequential elements from an enabled array, starting at indices to construct a sequence of geometric primitives. mode specifies what kind of primitives are constructed and how the array elements construct these primitives. If more than one array is enabled, each is used.
    /// Vertex attributes that are modified by glDrawElements have an unspecified value after glDrawElements returns. Attributes that aren't modified maintain their previous values.
    /// Errors
    /// GL_INVALID_ENUM is generated if mode is not an accepted value.
    /// GL_INVALID_VALUE is generated if count is negative.
    /// GL_INVALID_OPERATION is generated if a geometry shader is active and mode is incompatible with the input primitive type of the geometry shader in the currently installed program object.
    /// GL_INVALID_OPERATION is generated if a non-zero buffer object name is bound to an enabled array or the element array and the buffer object's data store is currently mapped.
    pub fn drawElements(mode: ValueType, count: i32, type_: ValueType, indicies: *const anyopaque) error{ InvalidEnum, InvalidValue, InvalidOperation }!void {
        zimgui_glDrawElements(mode, count, type_, indicies);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glDrawElements(ValueType, i32, ValueType, *const anyopaque) void;

    /// glBindVertexArray binds the vertex array object with name array. array is the name of a vertex array object previously returned from a call to glGenVertexArrays, or zero to break the existing vertex array object binding.
    /// If no vertex array object with name array exists, one is created when array is first bound. If the bind is successful no change is made to the state of the vertex array object, and any previous vertex array object binding is broken.
    /// GL_INVALID_OPERATION is generated if array is not zero or the name of a vertex array object previously returned from a call to glGenVertexArrays.
    pub fn bindVertexArray(array: u32) error.InvalidOperation!void {
        zimgui_glBindVertexArray(array);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glBindVertexArray(u32) void;

    /// glUniform modifies the value of a uniform variable or a uniform variable array. The location of the uniform variable to be modified is specified by location, which should be a value returned by glGetUniformLocation. glUniform operates on the program object that was made part of current state by calling glUseProgram.
    /// Errors
    /// GL_INVALID_OPERATION is generated if there is no current program object.
    /// GL_INVALID_OPERATION is generated if the size of the uniform variable declared in the shader does not match the size indicated by the glUniform command.
    /// GL_INVALID_OPERATION is generated if one of the signed or unsigned integer variants of this function is used to load a uniform variable of type float, vec2, vec3, vec4, or an array of these, or if one of the floating-point variants of this function is used to load a uniform variable of type int, ivec2, ivec3, ivec4, unsigned int, uvec2, uvec3, uvec4, or an array of these.
    /// GL_INVALID_OPERATION is generated if one of the signed integer variants of this function is used to load a uniform variable of type unsigned int, uvec2, uvec3, uvec4, or an array of these.
    /// GL_INVALID_OPERATION is generated if one of the unsigned integer variants of this function is used to load a uniform variable of type int, ivec2, ivec3, ivec4, or an array of these.
    /// GL_INVALID_OPERATION is generated if location is an invalid uniform location for the current program object and location is not equal to -1.
    /// GL_INVALID_VALUE is generated if count is less than 0.
    /// GL_INVALID_OPERATION is generated if count is greater than 1 and the indicated uniform variable is not an array variable.
    /// GL_INVALID_OPERATION is generated if a sampler is loaded using a command other than glUniform1i and glUniform1iv.
    pub fn uniform4fv(location: i32, value: [4]f32) error{ InvalidOperation, InvalidValue }!void {
        zimgui_glUniform4fv(location, @as(i32, @intCast(value.len)), value.ptr);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
    }
    extern fn zimgui_glUniform4fv(i32, i32, [*]const f32) void;

    /// glGetUniformLocation returns an integer that represents the location of a specific uniform variable within a program object. name must be a null terminated string that contains no white space. name must be an active uniform variable name in program that is not a structure, an array of structures, or a subcomponent of a vector or a matrix. This function returns -1 if name does not correspond to an active uniform variable in program, if name starts with the reserved prefix "gl_", or if name is associated with an atomic counter or a named uniform block.
    /// Uniform variables that are structures or arrays of structures may be queried by calling glGetUniformLocation for each field within the structure. The array element operator "[]" and the structure field operator "." may be used in name in order to select elements within an array or fields within a structure. The result of using these operators is not allowed to be another structure, an array of structures, or a subcomponent of a vector or a matrix. Except if the last part of name indicates a uniform variable array, the location of the first element of an array can be retrieved by using the name of the array, or by using the name appended by "[0]".
    /// The actual locations assigned to uniform variables are not known until the program object is linked successfully. After linking has occurred, the command glGetUniformLocation can be used to obtain the location of a uniform variable. This location value can then be passed to glUniform to set the value of the uniform variable or to glGetUniform in order to query the current value of the uniform variable. After a program object has been linked successfully, the index values for uniform variables remain fixed until the next link command occurs. Uniform variable locations and values can only be queried after a link if the link was successful.
    /// Errors
    /// GL_INVALID_VALUE is generated if program is not a value generated by OpenGL.
    /// GL_INVALID_OPERATION is generated if program is not a program object.
    /// GL_INVALID_OPERATION is generated if program has not been successfully linked.
    pub fn getUniformLocation(program: u32, name: []const u8) error{ InvalidValue, InvalidOperation }!i32 {
        var buf: [256]u8 = undefined;
        var slice = copyZ(&buf, name);
        const res = zimgui_glGetUniformLocation(program, slice.ptr);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            else => unreachable,
        }
        return res;
    }
    extern fn zimgui_glGetUniformLocation(u32, [*]const u8) i32;

    /// Pixels can be drawn using a function that blends the incoming (source) RGBA values with the RGBA values that are already in the frame buffer (the destination values). Blending is initially disabled. Use glEnable and glDisable with argument GL_BLEND to enable and disable blending.
    /// Errors
    /// GL_INVALID_ENUM is generated if either sfactor or dfactor is not an accepted value.
    /// GL_INVALID_VALUE is generated by glBlendFunci if buf is greater than or equal to the value of GL_MAX_DRAW_BUFFERS.
    pub fn blendFunc(sfactor: ValueType, dfactor: ValueType) error{ InvalidEnum, InvalidValue }!void {
        zimgui_glBlendFunc(sfactor, dfactor);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glBlendFunc() void;

    /// glCreateBuffers returns n previously unused buffer names in buffers, each representing a new buffer object initialized as if it had been bound to an unspecified target.
    /// Errors
    /// GL_INVALID_VALUE is generated if n is negative.
    pub fn createBuffers(buffers: []u32) error.InvalidValue!void {
        zimgui_glCreateBuffers(@as(i32, @intCast(buffers.len)), buffers.ptr);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glCreateBuffers(i32, [*]const u32) void;

    /// glBindBuffer binds a buffer object to the specified buffer binding point. Calling glBindBuffer with target set to one of the accepted symbolic constants and buffer set to the name of a buffer object binds that buffer object name to the target. If no buffer object with name buffer exists, one is created with that name. When a buffer object is bound to a target, the previous binding for that target is automatically broken.
    /// Errors
    /// GL_INVALID_ENUM is generated if target is not one of the allowable values.
    /// GL_INVALID_VALUE is generated if buffer is not a name previously returned from a call to glGenBuffers.
    pub fn bindBuffer(target: ValueType, buffer: u32) error{ InvalidEnum, InvalidValue }!void {
        zimgui_glBindBuffer(target, buffer);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glBindBuffer(ValueType, u32) void;

    /// glBufferData and glNamedBufferData create a new data store for a buffer object. In case of glBufferData, the buffer object currently bound to target is used. For glNamedBufferData, a buffer object associated with ID specified by the caller in buffer will be used instead.
    /// While creating the new storage, any pre-existing data store is deleted. The new data store is created with the specified size in bytes and usage. If data is not NULL, the data store is initialized with data from this pointer. In its initial state, the new data store is not mapped, it has a NULL mapped pointer, and its mapped access is GL_READ_WRITE.
    /// Errors
    /// GL_INVALID_ENUM is generated by glBufferData if target is not one of the accepted buffer targets.
    /// GL_INVALID_ENUM is generated if usage is not GL_STREAM_DRAW, GL_STREAM_READ, GL_STREAM_COPY, GL_STATIC_DRAW, GL_STATIC_READ, GL_STATIC_COPY, GL_DYNAMIC_DRAW, GL_DYNAMIC_READ, or GL_DYNAMIC_COPY.
    /// GL_INVALID_VALUE is generated if size is negative.
    /// GL_INVALID_OPERATION is generated by glBufferData if the reserved buffer object name 0 is bound to target.
    /// GL_INVALID_OPERATION is generated by glNamedBufferData if buffer is not the name of an existing buffer object.
    /// GL_INVALID_OPERATION is generated if the GL_BUFFER_IMMUTABLE_STORAGE flag of the buffer object is GL_TRUE.
    /// GL_OUT_OF_MEMORY is generated if the GL is unable to create a data store with the specified size.
    pub fn bufferData(target: ValueType, comptime T: type, data: []const T, usage: ValueType) error{ InvalidEnum, InvalidValue, InvalidOperation, OutOfMemory }!void {
        zimgui_glBufferData(target, @sizeOf(T), data.ptr, usage);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            INVALID_OPERATION => return error.InvalidOperation,
            OUT_OF_MEMORY => return error.OutOfMemory,
            else => unreachable,
        }
    }
    extern fn zimgui_glBufferData(ValueType, usize, *const anyopaque, ValueType) void;

    /// glCreateVertexArrays returns n previously unused vertex array object names in arrays, each representing a new vertex array object initialized to the default state.
    /// Errors
    /// GL_INVALID_VALUE is generated if n is negative.
    pub fn createVertexArrays(arrays: []u32) error.InvalidValue!void {
        zimgui_glCreateVertexArrays(@as(i32, @intCast(arrays.len)), arrays.ptr);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glCreateVertexArrays(i32, [*]u32) void;

    /// Remeber to call `enable` to enable debug output.
    ///
    /// Example usage:
    ///
    /// fn onOpenGl3DebugMessage(source: gl.ValueType, type_: gl.ValueType, id: u32, severity: gl.ValueType, length: i32, message: [*c]const u8, user_param: *const anyopaque) void {
    ///     _ = length;
    ///     _ = user_param;
    ///     var msg = message[0..@intCast(usize, length)];
    ///     std.debug.print("OpenGL3: {{id: {}, severity: {}, message: {s}, source: {}, type: {}}}\n", .{id, severity, msg, source, type_});
    /// }
    ///
    ///
    /// var not_user_param: usize = undefined;
    /// gl.debugMessageCallback(onOpenGl3DebugMessage, @ptrCast(*const anyopaque, &not_user_param));
    ///
    pub fn debugMessageCallback(callback: *const fn (source: ValueType, type_: ValueType, id: u32, severity: ValueType, length: i32, message: [*c]const u8, user_param: *const anyopaque) void, user_param: *const anyopaque) void {
        zimgui_glDebugMessageCallback(callback, user_param);
    }
    extern fn zimgui_glDebugMessageCallback(callback: *const anyopaque, user_param: *const anyopaque) void;

    /// Use to turn on features, such as debug output:
    ///
    /// gl.enable(.{.value = gl.DEBUG_OUTPUT});
    ///
    /// Errors
    /// GL_INVALID_ENUM is generated if cap is not one of the values listed previously.
    /// GL_INVALID_VALUE is generated by glEnablei and glDisablei if index is greater than or equal to the number of indexed capabilities for cap.
    pub fn enable(cap: ValueType) error{ InvalidEnum, InvalidValue }!void {
        zimgui_glEnable(cap);
        switch (getError()) {
            NO_ERROR => {},
            INVALID_ENUM => return error.InvalidEnum,
            INVALID_VALUE => return error.InvalidValue,
            else => unreachable,
        }
    }
    extern fn zimgui_glEnable(cap: ValueType) void;

    /// Pass glad the OpenGL loader function `getProcAddress`.
    /// Example using glfw:
    ///  gladLoadGLLoader(glfw.getProcAddress)
    pub fn gladLoadGLLoader(func: *const anyopaque) i32 {
        return zimgui_gladLoadGLLoader(func);
    }
    extern fn zimgui_gladLoadGLLoader(*const anyopaque) i32;

    ///////////////////////////////////////////////////////////////////////////////
    // Types
    //

    const Error = error{
        InvalidValue,
        InvalidOperation,
        InvalidEnum,
        OutOfMemory,
    };

    pub const TextureId = u32;

    pub const ValueType = i32;

    pub const DEPTH_BUFFER_BIT: ValueType = 0x00000100;
    pub const STENCIL_BUFFER_BIT: ValueType = 0x00000400;
    pub const COLOR_BUFFER_BIT: ValueType = 0x00004000;
    pub const FALSE: ValueType = 0;
    pub const TRUE: ValueType = 1;
    pub const POINTS: ValueType = 0x0000;
    pub const LINES: ValueType = 0x0001;
    pub const LINE_LOOP: ValueType = 0x0002;
    pub const LINE_STRIP: ValueType = 0x0003;
    pub const TRIANGLES: ValueType = 0x0004;
    pub const TRIANGLE_STRIP: ValueType = 0x0005;
    pub const TRIANGLE_FAN: ValueType = 0x0006;
    pub const NEVER: ValueType = 0x0200;
    pub const LESS: ValueType = 0x0201;
    pub const EQUAL: ValueType = 0x0202;
    pub const LEQUAL: ValueType = 0x0203;
    pub const GREATER: ValueType = 0x0204;
    pub const NOTEQUAL: ValueType = 0x0205;
    pub const GEQUAL: ValueType = 0x0206;
    pub const ALWAYS: ValueType = 0x0207;
    pub const ZERO: ValueType = 0;
    pub const ONE: ValueType = 1;
    pub const SRC_COLOR: ValueType = 0x0300;
    pub const ONE_MINUS_SRC_COLOR: ValueType = 0x0301;
    pub const SRC_ALPHA: ValueType = 0x0302;
    pub const ONE_MINUS_SRC_ALPHA: ValueType = 0x0303;
    pub const DST_ALPHA: ValueType = 0x0304;
    pub const ONE_MINUS_DST_ALPHA: ValueType = 0x0305;
    pub const DST_COLOR: ValueType = 0x0306;
    pub const ONE_MINUS_DST_COLOR: ValueType = 0x0307;
    pub const SRC_ALPHA_SATURATE: ValueType = 0x0308;
    pub const NONE: ValueType = 0;
    pub const FRONT_LEFT: ValueType = 0x0400;
    pub const FRONT_RIGHT: ValueType = 0x0401;
    pub const BACK_LEFT: ValueType = 0x0402;
    pub const BACK_RIGHT: ValueType = 0x0403;
    pub const FRONT: ValueType = 0x0404;
    pub const BACK: ValueType = 0x0405;
    pub const LEFT: ValueType = 0x0406;
    pub const RIGHT: ValueType = 0x0407;
    pub const FRONT_AND_BACK: ValueType = 0x0408;
    pub const NO_ERROR: ValueType = 0;
    pub const INVALID_ENUM: ValueType = 0x0500;
    pub const INVALID_VALUE: ValueType = 0x0501;
    pub const INVALID_OPERATION: ValueType = 0x0502;
    pub const OUT_OF_MEMORY: ValueType = 0x0505;
    pub const CW: ValueType = 0x0900;
    pub const CCW: ValueType = 0x0901;
    pub const POINT_SIZE: ValueType = 0x0B11;
    pub const POINT_SIZE_RANGE: ValueType = 0x0B12;
    pub const POINT_SIZE_GRANULARITY: ValueType = 0x0B13;
    pub const LINE_SMOOTH: ValueType = 0x0B20;
    pub const LINE_WIDTH: ValueType = 0x0B21;
    pub const LINE_WIDTH_RANGE: ValueType = 0x0B22;
    pub const LINE_WIDTH_GRANULARITY: ValueType = 0x0B23;
    pub const POLYGON_MODE: ValueType = 0x0B40;
    pub const POLYGON_SMOOTH: ValueType = 0x0B41;
    pub const CULL_FACE: ValueType = 0x0B44;
    pub const CULL_FACE_MODE: ValueType = 0x0B45;
    pub const FRONT_FACE: ValueType = 0x0B46;
    pub const DEPTH_RANGE: ValueType = 0x0B70;
    pub const DEPTH_TEST: ValueType = 0x0B71;
    pub const DEPTH_WRITEMASK: ValueType = 0x0B72;
    pub const DEPTH_CLEAR_VALUE: ValueType = 0x0B73;
    pub const DEPTH_FUNC: ValueType = 0x0B74;
    pub const STENCIL_TEST: ValueType = 0x0B90;
    pub const STENCIL_CLEAR_VALUE: ValueType = 0x0B91;
    pub const STENCIL_FUNC: ValueType = 0x0B92;
    pub const STENCIL_VALUE_MASK: ValueType = 0x0B93;
    pub const STENCIL_FAIL: ValueType = 0x0B94;
    pub const STENCIL_PASS_DEPTH_FAIL: ValueType = 0x0B95;
    pub const STENCIL_PASS_DEPTH_PASS: ValueType = 0x0B96;
    pub const STENCIL_REF: ValueType = 0x0B97;
    pub const STENCIL_WRITEMASK: ValueType = 0x0B98;
    pub const VIEWPORT: ValueType = 0x0BA2;
    pub const DITHER: ValueType = 0x0BD0;
    pub const BLEND_DST: ValueType = 0x0BE0;
    pub const BLEND_SRC: ValueType = 0x0BE1;
    pub const BLEND: ValueType = 0x0BE2;
    pub const LOGIC_OP_MODE: ValueType = 0x0BF0;
    pub const DRAW_BUFFER: ValueType = 0x0C01;
    pub const READ_BUFFER: ValueType = 0x0C02;
    pub const SCISSOR_BOX: ValueType = 0x0C10;
    pub const SCISSOR_TEST: ValueType = 0x0C11;
    pub const COLOR_CLEAR_VALUE: ValueType = 0x0C22;
    pub const COLOR_WRITEMASK: ValueType = 0x0C23;
    pub const DOUBLEBUFFER: ValueType = 0x0C32;
    pub const STEREO: ValueType = 0x0C33;
    pub const LINE_SMOOTH_HINT: ValueType = 0x0C52;
    pub const POLYGON_SMOOTH_HINT: ValueType = 0x0C53;
    pub const UNPACK_SWAP_BYTES: ValueType = 0x0CF0;
    pub const UNPACK_LSB_FIRST: ValueType = 0x0CF1;
    pub const UNPACK_ROW_LENGTH: ValueType = 0x0CF2;
    pub const UNPACK_SKIP_ROWS: ValueType = 0x0CF3;
    pub const UNPACK_SKIP_PIXELS: ValueType = 0x0CF4;
    pub const UNPACK_ALIGNMENT: ValueType = 0x0CF5;
    pub const PACK_SWAP_BYTES: ValueType = 0x0D00;
    pub const PACK_LSB_FIRST: ValueType = 0x0D01;
    pub const PACK_ROW_LENGTH: ValueType = 0x0D02;
    pub const PACK_SKIP_ROWS: ValueType = 0x0D03;
    pub const PACK_SKIP_PIXELS: ValueType = 0x0D04;
    pub const PACK_ALIGNMENT: ValueType = 0x0D05;
    pub const MAX_TEXTURE_SIZE: ValueType = 0x0D33;
    pub const MAX_VIEWPORT_DIMS: ValueType = 0x0D3A;
    pub const SUBPIXEL_BITS: ValueType = 0x0D50;
    pub const TEXTURE_1D: ValueType = 0x0DE0;
    pub const TEXTURE_2D: ValueType = 0x0DE1;
    pub const TEXTURE_WIDTH: ValueType = 0x1000;
    pub const TEXTURE_HEIGHT: ValueType = 0x1001;
    pub const TEXTURE_BORDER_COLOR: ValueType = 0x1004;
    pub const DONT_CARE: ValueType = 0x1100;
    pub const FASTEST: ValueType = 0x1101;
    pub const NICEST: ValueType = 0x1102;
    pub const BYTE: ValueType = 0x1400;
    pub const UNSIGNED_BYTE: ValueType = 0x1401;
    pub const SHORT: ValueType = 0x1402;
    pub const UNSIGNED_SHORT: ValueType = 0x1403;
    pub const INT: ValueType = 0x1404;
    pub const UNSIGNED_INT: ValueType = 0x1405;
    pub const FLOAT: ValueType = 0x1406;
    pub const CLEAR: ValueType = 0x1500;
    pub const AND: ValueType = 0x1501;
    pub const AND_REVERSE: ValueType = 0x1502;
    pub const COPY: ValueType = 0x1503;
    pub const AND_INVERTED: ValueType = 0x1504;
    pub const NOOP: ValueType = 0x1505;
    pub const XOR: ValueType = 0x1506;
    pub const OR: ValueType = 0x1507;
    pub const NOR: ValueType = 0x1508;
    pub const EQUIV: ValueType = 0x1509;
    pub const INVERT: ValueType = 0x150A;
    pub const OR_REVERSE: ValueType = 0x150B;
    pub const COPY_INVERTED: ValueType = 0x150C;
    pub const OR_INVERTED: ValueType = 0x150D;
    pub const NAND: ValueType = 0x150E;
    pub const SET: ValueType = 0x150F;
    pub const TEXTURE: ValueType = 0x1702;
    pub const COLOR: ValueType = 0x1800;
    pub const DEPTH: ValueType = 0x1801;
    pub const STENCIL: ValueType = 0x1802;
    pub const STENCIL_INDEX: ValueType = 0x1901;
    pub const DEPTH_COMPONENT: ValueType = 0x1902;
    pub const RED: ValueType = 0x1903;
    pub const GREEN: ValueType = 0x1904;
    pub const BLUE: ValueType = 0x1905;
    pub const ALPHA: ValueType = 0x1906;
    pub const RGB: ValueType = 0x1907;
    pub const RGBA: ValueType = 0x1908;
    pub const POINT: ValueType = 0x1B00;
    pub const LINE: ValueType = 0x1B01;
    pub const FILL: ValueType = 0x1B02;
    pub const KEEP: ValueType = 0x1E00;
    pub const REPLACE: ValueType = 0x1E01;
    pub const INCR: ValueType = 0x1E02;
    pub const DECR: ValueType = 0x1E03;
    pub const VENDOR: ValueType = 0x1F00;
    pub const RENDERER: ValueType = 0x1F01;
    pub const VERSION: ValueType = 0x1F02;
    pub const EXTENSIONS: ValueType = 0x1F03;
    pub const NEAREST: ValueType = 0x2600;
    pub const LINEAR: ValueType = 0x2601;
    pub const NEAREST_MIPMAP_NEAREST: ValueType = 0x2700;
    pub const LINEAR_MIPMAP_NEAREST: ValueType = 0x2701;
    pub const NEAREST_MIPMAP_LINEAR: ValueType = 0x2702;
    pub const LINEAR_MIPMAP_LINEAR: ValueType = 0x2703;
    pub const TEXTURE_MAG_FILTER: ValueType = 0x2800;
    pub const TEXTURE_MIN_FILTER: ValueType = 0x2801;
    pub const TEXTURE_WRAP_S: ValueType = 0x2802;
    pub const TEXTURE_WRAP_T: ValueType = 0x2803;
    pub const REPEAT: ValueType = 0x2901;
    pub const COLOR_LOGIC_OP: ValueType = 0x0BF2;
    pub const POLYGON_OFFSET_UNITS: ValueType = 0x2A00;
    pub const POLYGON_OFFSET_POINT: ValueType = 0x2A01;
    pub const POLYGON_OFFSET_LINE: ValueType = 0x2A02;
    pub const POLYGON_OFFSET_FILL: ValueType = 0x8037;
    pub const POLYGON_OFFSET_FACTOR: ValueType = 0x8038;
    pub const TEXTURE_BINDING_1D: ValueType = 0x8068;
    pub const TEXTURE_BINDING_2D: ValueType = 0x8069;
    pub const TEXTURE_INTERNAL_FORMAT: ValueType = 0x1003;
    pub const TEXTURE_RED_SIZE: ValueType = 0x805C;
    pub const TEXTURE_GREEN_SIZE: ValueType = 0x805D;
    pub const TEXTURE_BLUE_SIZE: ValueType = 0x805E;
    pub const TEXTURE_ALPHA_SIZE: ValueType = 0x805F;
    pub const DOUBLE: ValueType = 0x140A;
    pub const PROXY_TEXTURE_1D: ValueType = 0x8063;
    pub const PROXY_TEXTURE_2D: ValueType = 0x8064;
    pub const R3_G3_B2: ValueType = 0x2A10;
    pub const RGB4: ValueType = 0x804F;
    pub const RGB5: ValueType = 0x8050;
    pub const RGB8: ValueType = 0x8051;
    pub const RGB10: ValueType = 0x8052;
    pub const RGB12: ValueType = 0x8053;
    pub const RGB16: ValueType = 0x8054;
    pub const RGBA2: ValueType = 0x8055;
    pub const RGBA4: ValueType = 0x8056;
    pub const RGB5_A1: ValueType = 0x8057;
    pub const RGBA8: ValueType = 0x8058;
    pub const RGB10_A2: ValueType = 0x8059;
    pub const RGBA12: ValueType = 0x805A;
    pub const RGBA16: ValueType = 0x805B;
    pub const UNSIGNED_BYTE_3_3_2: ValueType = 0x8032;
    pub const UNSIGNED_SHORT_4_4_4_4: ValueType = 0x8033;
    pub const UNSIGNED_SHORT_5_5_5_1: ValueType = 0x8034;
    pub const UNSIGNED_INT_8_8_8_8: ValueType = 0x8035;
    pub const UNSIGNED_INT_10_10_10_2: ValueType = 0x8036;
    pub const TEXTURE_BINDING_3D: ValueType = 0x806A;
    pub const PACK_SKIP_IMAGES: ValueType = 0x806B;
    pub const PACK_IMAGE_HEIGHT: ValueType = 0x806C;
    pub const UNPACK_SKIP_IMAGES: ValueType = 0x806D;
    pub const UNPACK_IMAGE_HEIGHT: ValueType = 0x806E;
    pub const TEXTURE_3D: ValueType = 0x806F;
    pub const PROXY_TEXTURE_3D: ValueType = 0x8070;
    pub const TEXTURE_DEPTH: ValueType = 0x8071;
    pub const TEXTURE_WRAP_R: ValueType = 0x8072;
    pub const MAX_3D_TEXTURE_SIZE: ValueType = 0x8073;
    pub const UNSIGNED_BYTE_2_3_3_REV: ValueType = 0x8362;
    pub const UNSIGNED_SHORT_5_6_5: ValueType = 0x8363;
    pub const UNSIGNED_SHORT_5_6_5_REV: ValueType = 0x8364;
    pub const UNSIGNED_SHORT_4_4_4_4_REV: ValueType = 0x8365;
    pub const UNSIGNED_SHORT_1_5_5_5_REV: ValueType = 0x8366;
    pub const UNSIGNED_INT_8_8_8_8_REV: ValueType = 0x8367;
    pub const UNSIGNED_INT_2_10_10_10_REV: ValueType = 0x8368;
    pub const BGR: ValueType = 0x80E0;
    pub const BGRA: ValueType = 0x80E1;
    pub const MAX_ELEMENTS_VERTICES: ValueType = 0x80E8;
    pub const MAX_ELEMENTS_INDICES: ValueType = 0x80E9;
    pub const CLAMP_TO_EDGE: ValueType = 0x812F;
    pub const TEXTURE_MIN_LOD: ValueType = 0x813A;
    pub const TEXTURE_MAX_LOD: ValueType = 0x813B;
    pub const TEXTURE_BASE_LEVEL: ValueType = 0x813C;
    pub const TEXTURE_MAX_LEVEL: ValueType = 0x813D;
    pub const SMOOTH_POINT_SIZE_RANGE: ValueType = 0x0B12;
    pub const SMOOTH_POINT_SIZE_GRANULARITY: ValueType = 0x0B13;
    pub const SMOOTH_LINE_WIDTH_RANGE: ValueType = 0x0B22;
    pub const SMOOTH_LINE_WIDTH_GRANULARITY: ValueType = 0x0B23;
    pub const ALIASED_LINE_WIDTH_RANGE: ValueType = 0x846E;
    pub const TEXTURE0: ValueType = 0x84C0;
    pub const TEXTURE1: ValueType = 0x84C1;
    pub const TEXTURE2: ValueType = 0x84C2;
    pub const TEXTURE3: ValueType = 0x84C3;
    pub const TEXTURE4: ValueType = 0x84C4;
    pub const TEXTURE5: ValueType = 0x84C5;
    pub const TEXTURE6: ValueType = 0x84C6;
    pub const TEXTURE7: ValueType = 0x84C7;
    pub const TEXTURE8: ValueType = 0x84C8;
    pub const TEXTURE9: ValueType = 0x84C9;
    pub const TEXTURE10: ValueType = 0x84CA;
    pub const TEXTURE11: ValueType = 0x84CB;
    pub const TEXTURE12: ValueType = 0x84CC;
    pub const TEXTURE13: ValueType = 0x84CD;
    pub const TEXTURE14: ValueType = 0x84CE;
    pub const TEXTURE15: ValueType = 0x84CF;
    pub const TEXTURE16: ValueType = 0x84D0;
    pub const TEXTURE17: ValueType = 0x84D1;
    pub const TEXTURE18: ValueType = 0x84D2;
    pub const TEXTURE19: ValueType = 0x84D3;
    pub const TEXTURE20: ValueType = 0x84D4;
    pub const TEXTURE21: ValueType = 0x84D5;
    pub const TEXTURE22: ValueType = 0x84D6;
    pub const TEXTURE23: ValueType = 0x84D7;
    pub const TEXTURE24: ValueType = 0x84D8;
    pub const TEXTURE25: ValueType = 0x84D9;
    pub const TEXTURE26: ValueType = 0x84DA;
    pub const TEXTURE27: ValueType = 0x84DB;
    pub const TEXTURE28: ValueType = 0x84DC;
    pub const TEXTURE29: ValueType = 0x84DD;
    pub const TEXTURE30: ValueType = 0x84DE;
    pub const TEXTURE31: ValueType = 0x84DF;
    pub const ACTIVE_TEXTURE: ValueType = 0x84E0;
    pub const MULTISAMPLE: ValueType = 0x809D;
    pub const SAMPLE_ALPHA_TO_COVERAGE: ValueType = 0x809E;
    pub const SAMPLE_ALPHA_TO_ONE: ValueType = 0x809F;
    pub const SAMPLE_COVERAGE: ValueType = 0x80A0;
    pub const SAMPLE_BUFFERS: ValueType = 0x80A8;
    pub const SAMPLES: ValueType = 0x80A9;
    pub const SAMPLE_COVERAGE_VALUE: ValueType = 0x80AA;
    pub const SAMPLE_COVERAGE_INVERT: ValueType = 0x80AB;
    pub const TEXTURE_CUBE_MAP: ValueType = 0x8513;
    pub const TEXTURE_BINDING_CUBE_MAP: ValueType = 0x8514;
    pub const TEXTURE_CUBE_MAP_POSITIVE_X: ValueType = 0x8515;
    pub const TEXTURE_CUBE_MAP_NEGATIVE_X: ValueType = 0x8516;
    pub const TEXTURE_CUBE_MAP_POSITIVE_Y: ValueType = 0x8517;
    pub const TEXTURE_CUBE_MAP_NEGATIVE_Y: ValueType = 0x8518;
    pub const TEXTURE_CUBE_MAP_POSITIVE_Z: ValueType = 0x8519;
    pub const TEXTURE_CUBE_MAP_NEGATIVE_Z: ValueType = 0x851A;
    pub const PROXY_TEXTURE_CUBE_MAP: ValueType = 0x851B;
    pub const MAX_CUBE_MAP_TEXTURE_SIZE: ValueType = 0x851C;
    pub const COMPRESSED_RGB: ValueType = 0x84ED;
    pub const COMPRESSED_RGBA: ValueType = 0x84EE;
    pub const TEXTURE_COMPRESSION_HINT: ValueType = 0x84EF;
    pub const TEXTURE_COMPRESSED_IMAGE_SIZE: ValueType = 0x86A0;
    pub const TEXTURE_COMPRESSED: ValueType = 0x86A1;
    pub const NUM_COMPRESSED_TEXTURE_FORMATS: ValueType = 0x86A2;
    pub const COMPRESSED_TEXTURE_FORMATS: ValueType = 0x86A3;
    pub const CLAMP_TO_BORDER: ValueType = 0x812D;
    pub const BLEND_DST_RGB: ValueType = 0x80C8;
    pub const BLEND_SRC_RGB: ValueType = 0x80C9;
    pub const BLEND_DST_ALPHA: ValueType = 0x80CA;
    pub const BLEND_SRC_ALPHA: ValueType = 0x80CB;
    pub const POINT_FADE_THRESHOLD_SIZE: ValueType = 0x8128;
    pub const DEPTH_COMPONENT16: ValueType = 0x81A5;
    pub const DEPTH_COMPONENT24: ValueType = 0x81A6;
    pub const DEPTH_COMPONENT32: ValueType = 0x81A7;
    pub const MIRRORED_REPEAT: ValueType = 0x8370;
    pub const MAX_TEXTURE_LOD_BIAS: ValueType = 0x84FD;
    pub const TEXTURE_LOD_BIAS: ValueType = 0x8501;
    pub const INCR_WRAP: ValueType = 0x8507;
    pub const DECR_WRAP: ValueType = 0x8508;
    pub const TEXTURE_DEPTH_SIZE: ValueType = 0x884A;
    pub const TEXTURE_COMPARE_MODE: ValueType = 0x884C;
    pub const TEXTURE_COMPARE_FUNC: ValueType = 0x884D;
    pub const BLEND_COLOR: ValueType = 0x8005;
    pub const BLEND_EQUATION: ValueType = 0x8009;
    pub const CONSTANT_COLOR: ValueType = 0x8001;
    pub const ONE_MINUS_CONSTANT_COLOR: ValueType = 0x8002;
    pub const CONSTANT_ALPHA: ValueType = 0x8003;
    pub const ONE_MINUS_CONSTANT_ALPHA: ValueType = 0x8004;
    pub const FUNC_ADD: ValueType = 0x8006;
    pub const FUNC_REVERSE_SUBTRACT: ValueType = 0x800B;
    pub const FUNC_SUBTRACT: ValueType = 0x800A;
    pub const MIN: ValueType = 0x8007;
    pub const MAX: ValueType = 0x8008;
    pub const BUFFER_SIZE: ValueType = 0x8764;
    pub const BUFFER_USAGE: ValueType = 0x8765;
    pub const QUERY_COUNTER_BITS: ValueType = 0x8864;
    pub const CURRENT_QUERY: ValueType = 0x8865;
    pub const QUERY_RESULT: ValueType = 0x8866;
    pub const QUERY_RESULT_AVAILABLE: ValueType = 0x8867;
    pub const ARRAY_BUFFER: ValueType = 0x8892;
    pub const ELEMENT_ARRAY_BUFFER: ValueType = 0x8893;
    pub const ARRAY_BUFFER_BINDING: ValueType = 0x8894;
    pub const ELEMENT_ARRAY_BUFFER_BINDING: ValueType = 0x8895;
    pub const VERTEX_ATTRIB_ARRAY_BUFFER_BINDING: ValueType = 0x889F;
    pub const READ_ONLY: ValueType = 0x88B8;
    pub const WRITE_ONLY: ValueType = 0x88B9;
    pub const READ_WRITE: ValueType = 0x88BA;
    pub const BUFFER_ACCESS: ValueType = 0x88BB;
    pub const BUFFER_MAPPED: ValueType = 0x88BC;
    pub const BUFFER_MAP_POINTER: ValueType = 0x88BD;
    pub const STREAM_DRAW: ValueType = 0x88E0;
    pub const STREAM_READ: ValueType = 0x88E1;
    pub const STREAM_COPY: ValueType = 0x88E2;
    pub const STATIC_DRAW: ValueType = 0x88E4;
    pub const STATIC_READ: ValueType = 0x88E5;
    pub const STATIC_COPY: ValueType = 0x88E6;
    pub const DYNAMIC_DRAW: ValueType = 0x88E8;
    pub const DYNAMIC_READ: ValueType = 0x88E9;
    pub const DYNAMIC_COPY: ValueType = 0x88EA;
    pub const SAMPLES_PASSED: ValueType = 0x8914;
    pub const SRC1_ALPHA: ValueType = 0x8589;
    pub const BLEND_EQUATION_RGB: ValueType = 0x8009;
    pub const VERTEX_ATTRIB_ARRAY_ENABLED: ValueType = 0x8622;
    pub const VERTEX_ATTRIB_ARRAY_SIZE: ValueType = 0x8623;
    pub const VERTEX_ATTRIB_ARRAY_STRIDE: ValueType = 0x8624;
    pub const VERTEX_ATTRIB_ARRAY_TYPE: ValueType = 0x8625;
    pub const CURRENT_VERTEX_ATTRIB: ValueType = 0x8626;
    pub const VERTEX_PROGRAM_POINT_SIZE: ValueType = 0x8642;
    pub const VERTEX_ATTRIB_ARRAY_POINTER: ValueType = 0x8645;
    pub const STENCIL_BACK_FUNC: ValueType = 0x8800;
    pub const STENCIL_BACK_FAIL: ValueType = 0x8801;
    pub const STENCIL_BACK_PASS_DEPTH_FAIL: ValueType = 0x8802;
    pub const STENCIL_BACK_PASS_DEPTH_PASS: ValueType = 0x8803;
    pub const MAX_DRAW_BUFFERS: ValueType = 0x8824;
    pub const DRAW_BUFFER0: ValueType = 0x8825;
    pub const DRAW_BUFFER1: ValueType = 0x8826;
    pub const DRAW_BUFFER2: ValueType = 0x8827;
    pub const DRAW_BUFFER3: ValueType = 0x8828;
    pub const DRAW_BUFFER4: ValueType = 0x8829;
    pub const DRAW_BUFFER5: ValueType = 0x882A;
    pub const DRAW_BUFFER6: ValueType = 0x882B;
    pub const DRAW_BUFFER7: ValueType = 0x882C;
    pub const DRAW_BUFFER8: ValueType = 0x882D;
    pub const DRAW_BUFFER9: ValueType = 0x882E;
    pub const DRAW_BUFFER10: ValueType = 0x882F;
    pub const DRAW_BUFFER11: ValueType = 0x8830;
    pub const DRAW_BUFFER12: ValueType = 0x8831;
    pub const DRAW_BUFFER13: ValueType = 0x8832;
    pub const DRAW_BUFFER14: ValueType = 0x8833;
    pub const DRAW_BUFFER15: ValueType = 0x8834;
    pub const BLEND_EQUATION_ALPHA: ValueType = 0x883D;
    pub const MAX_VERTEX_ATTRIBS: ValueType = 0x8869;
    pub const VERTEX_ATTRIB_ARRAY_NORMALIZED: ValueType = 0x886A;
    pub const MAX_TEXTURE_IMAGE_UNITS: ValueType = 0x8872;
    pub const FRAGMENT_SHADER: ValueType = 0x8B30;
    pub const VERTEX_SHADER: ValueType = 0x8B31;
    pub const MAX_FRAGMENT_UNIFORM_COMPONENTS: ValueType = 0x8B49;
    pub const MAX_VERTEX_UNIFORM_COMPONENTS: ValueType = 0x8B4A;
    pub const MAX_VARYING_FLOATS: ValueType = 0x8B4B;
    pub const MAX_VERTEX_TEXTURE_IMAGE_UNITS: ValueType = 0x8B4C;
    pub const MAX_COMBINED_TEXTURE_IMAGE_UNITS: ValueType = 0x8B4D;
    pub const SHADER_TYPE: ValueType = 0x8B4F;
    pub const FLOAT_VEC2: ValueType = 0x8B50;
    pub const FLOAT_VEC3: ValueType = 0x8B51;
    pub const FLOAT_VEC4: ValueType = 0x8B52;
    pub const INT_VEC2: ValueType = 0x8B53;
    pub const INT_VEC3: ValueType = 0x8B54;
    pub const INT_VEC4: ValueType = 0x8B55;
    pub const BOOL: ValueType = 0x8B56;
    pub const BOOL_VEC2: ValueType = 0x8B57;
    pub const BOOL_VEC3: ValueType = 0x8B58;
    pub const BOOL_VEC4: ValueType = 0x8B59;
    pub const FLOAT_MAT2: ValueType = 0x8B5A;
    pub const FLOAT_MAT3: ValueType = 0x8B5B;
    pub const FLOAT_MAT4: ValueType = 0x8B5C;
    pub const SAMPLER_1D: ValueType = 0x8B5D;
    pub const SAMPLER_2D: ValueType = 0x8B5E;
    pub const SAMPLER_3D: ValueType = 0x8B5F;
    pub const SAMPLER_CUBE: ValueType = 0x8B60;
    pub const SAMPLER_1D_SHADOW: ValueType = 0x8B61;
    pub const SAMPLER_2D_SHADOW: ValueType = 0x8B62;
    pub const DELETE_STATUS: ValueType = 0x8B80;
    pub const COMPILE_STATUS: ValueType = 0x8B81;
    pub const LINK_STATUS: ValueType = 0x8B82;
    pub const VALIDATE_STATUS: ValueType = 0x8B83;
    pub const INFO_LOG_LENGTH: ValueType = 0x8B84;
    pub const ATTACHED_SHADERS: ValueType = 0x8B85;
    pub const ACTIVE_UNIFORMS: ValueType = 0x8B86;
    pub const ACTIVE_UNIFORM_MAX_LENGTH: ValueType = 0x8B87;
    pub const SHADER_SOURCE_LENGTH: ValueType = 0x8B88;
    pub const ACTIVE_ATTRIBUTES: ValueType = 0x8B89;
    pub const ACTIVE_ATTRIBUTE_MAX_LENGTH: ValueType = 0x8B8A;
    pub const FRAGMENT_SHADER_DERIVATIVE_HINT: ValueType = 0x8B8B;
    pub const SHADING_LANGUAGE_VERSION: ValueType = 0x8B8C;
    pub const CURRENT_PROGRAM: ValueType = 0x8B8D;
    pub const POINT_SPRITE_COORD_ORIGIN: ValueType = 0x8CA0;
    pub const LOWER_LEFT: ValueType = 0x8CA1;
    pub const UPPER_LEFT: ValueType = 0x8CA2;
    pub const STENCIL_BACK_REF: ValueType = 0x8CA3;
    pub const STENCIL_BACK_VALUE_MASK: ValueType = 0x8CA4;
    pub const STENCIL_BACK_WRITEMASK: ValueType = 0x8CA5;
    pub const PIXEL_PACK_BUFFER: ValueType = 0x88EB;
    pub const PIXEL_UNPACK_BUFFER: ValueType = 0x88EC;
    pub const PIXEL_PACK_BUFFER_BINDING: ValueType = 0x88ED;
    pub const PIXEL_UNPACK_BUFFER_BINDING: ValueType = 0x88EF;
    pub const FLOAT_MAT2x3: ValueType = 0x8B65;
    pub const FLOAT_MAT2x4: ValueType = 0x8B66;
    pub const FLOAT_MAT3x2: ValueType = 0x8B67;
    pub const FLOAT_MAT3x4: ValueType = 0x8B68;
    pub const FLOAT_MAT4x2: ValueType = 0x8B69;
    pub const FLOAT_MAT4x3: ValueType = 0x8B6A;
    pub const SRGB: ValueType = 0x8C40;
    pub const SRGB8: ValueType = 0x8C41;
    pub const SRGB_ALPHA: ValueType = 0x8C42;
    pub const SRGB8_ALPHA8: ValueType = 0x8C43;
    pub const COMPRESSED_SRGB: ValueType = 0x8C48;
    pub const COMPRESSED_SRGB_ALPHA: ValueType = 0x8C49;
    pub const COMPARE_REF_TO_TEXTURE: ValueType = 0x884E;
    pub const CLIP_DISTANCE0: ValueType = 0x3000;
    pub const CLIP_DISTANCE1: ValueType = 0x3001;
    pub const CLIP_DISTANCE2: ValueType = 0x3002;
    pub const CLIP_DISTANCE3: ValueType = 0x3003;
    pub const CLIP_DISTANCE4: ValueType = 0x3004;
    pub const CLIP_DISTANCE5: ValueType = 0x3005;
    pub const CLIP_DISTANCE6: ValueType = 0x3006;
    pub const CLIP_DISTANCE7: ValueType = 0x3007;
    pub const MAX_CLIP_DISTANCES: ValueType = 0x0D32;
    pub const MAJOR_VERSION: ValueType = 0x821B;
    pub const MINOR_VERSION: ValueType = 0x821C;
    pub const NUM_EXTENSIONS: ValueType = 0x821D;
    pub const CONTEXT_FLAGS: ValueType = 0x821E;
    pub const COMPRESSED_RED: ValueType = 0x8225;
    pub const COMPRESSED_RG: ValueType = 0x8226;
    pub const CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT: ValueType = 0x00000001;
    pub const RGBA32F: ValueType = 0x8814;
    pub const RGB32F: ValueType = 0x8815;
    pub const RGBA16F: ValueType = 0x881A;
    pub const RGB16F: ValueType = 0x881B;
    pub const VERTEX_ATTRIB_ARRAY_INTEGER: ValueType = 0x88FD;
    pub const MAX_ARRAY_TEXTURE_LAYERS: ValueType = 0x88FF;
    pub const MIN_PROGRAM_TEXEL_OFFSET: ValueType = 0x8904;
    pub const MAX_PROGRAM_TEXEL_OFFSET: ValueType = 0x8905;
    pub const CLAMP_READ_COLOR: ValueType = 0x891C;
    pub const FIXED_ONLY: ValueType = 0x891D;
    pub const MAX_VARYING_COMPONENTS: ValueType = 0x8B4B;
    pub const TEXTURE_1D_ARRAY: ValueType = 0x8C18;
    pub const PROXY_TEXTURE_1D_ARRAY: ValueType = 0x8C19;
    pub const TEXTURE_2D_ARRAY: ValueType = 0x8C1A;
    pub const PROXY_TEXTURE_2D_ARRAY: ValueType = 0x8C1B;
    pub const TEXTURE_BINDING_1D_ARRAY: ValueType = 0x8C1C;
    pub const TEXTURE_BINDING_2D_ARRAY: ValueType = 0x8C1D;
    pub const R11F_G11F_B10F: ValueType = 0x8C3A;
    pub const UNSIGNED_INT_10F_11F_11F_REV: ValueType = 0x8C3B;
    pub const RGB9_E5: ValueType = 0x8C3D;
    pub const UNSIGNED_INT_5_9_9_9_REV: ValueType = 0x8C3E;
    pub const TEXTURE_SHARED_SIZE: ValueType = 0x8C3F;
    pub const TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH: ValueType = 0x8C76;
    pub const TRANSFORM_FEEDBACK_BUFFER_MODE: ValueType = 0x8C7F;
    pub const MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS: ValueType = 0x8C80;
    pub const TRANSFORM_FEEDBACK_VARYINGS: ValueType = 0x8C83;
    pub const TRANSFORM_FEEDBACK_BUFFER_START: ValueType = 0x8C84;
    pub const TRANSFORM_FEEDBACK_BUFFER_SIZE: ValueType = 0x8C85;
    pub const PRIMITIVES_GENERATED: ValueType = 0x8C87;
    pub const TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN: ValueType = 0x8C88;
    pub const RASTERIZER_DISCARD: ValueType = 0x8C89;
    pub const MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS: ValueType = 0x8C8A;
    pub const MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS: ValueType = 0x8C8B;
    pub const INTERLEAVED_ATTRIBS: ValueType = 0x8C8C;
    pub const SEPARATE_ATTRIBS: ValueType = 0x8C8D;
    pub const TRANSFORM_FEEDBACK_BUFFER: ValueType = 0x8C8E;
    pub const TRANSFORM_FEEDBACK_BUFFER_BINDING: ValueType = 0x8C8F;
    pub const RGBA32UI: ValueType = 0x8D70;
    pub const RGB32UI: ValueType = 0x8D71;
    pub const RGBA16UI: ValueType = 0x8D76;
    pub const RGB16UI: ValueType = 0x8D77;
    pub const RGBA8UI: ValueType = 0x8D7C;
    pub const RGB8UI: ValueType = 0x8D7D;
    pub const RGBA32I: ValueType = 0x8D82;
    pub const RGB32I: ValueType = 0x8D83;
    pub const RGBA16I: ValueType = 0x8D88;
    pub const RGB16I: ValueType = 0x8D89;
    pub const RGBA8I: ValueType = 0x8D8E;
    pub const RGB8I: ValueType = 0x8D8F;
    pub const RED_INTEGER: ValueType = 0x8D94;
    pub const GREEN_INTEGER: ValueType = 0x8D95;
    pub const BLUE_INTEGER: ValueType = 0x8D96;
    pub const RGB_INTEGER: ValueType = 0x8D98;
    pub const RGBA_INTEGER: ValueType = 0x8D99;
    pub const BGR_INTEGER: ValueType = 0x8D9A;
    pub const BGRA_INTEGER: ValueType = 0x8D9B;
    pub const SAMPLER_1D_ARRAY: ValueType = 0x8DC0;
    pub const SAMPLER_2D_ARRAY: ValueType = 0x8DC1;
    pub const SAMPLER_1D_ARRAY_SHADOW: ValueType = 0x8DC3;
    pub const SAMPLER_2D_ARRAY_SHADOW: ValueType = 0x8DC4;
    pub const SAMPLER_CUBE_SHADOW: ValueType = 0x8DC5;
    pub const UNSIGNED_INT_VEC2: ValueType = 0x8DC6;
    pub const UNSIGNED_INT_VEC3: ValueType = 0x8DC7;
    pub const UNSIGNED_INT_VEC4: ValueType = 0x8DC8;
    pub const INT_SAMPLER_1D: ValueType = 0x8DC9;
    pub const INT_SAMPLER_2D: ValueType = 0x8DCA;
    pub const INT_SAMPLER_3D: ValueType = 0x8DCB;
    pub const INT_SAMPLER_CUBE: ValueType = 0x8DCC;
    pub const INT_SAMPLER_1D_ARRAY: ValueType = 0x8DCE;
    pub const INT_SAMPLER_2D_ARRAY: ValueType = 0x8DCF;
    pub const UNSIGNED_INT_SAMPLER_1D: ValueType = 0x8DD1;
    pub const UNSIGNED_INT_SAMPLER_2D: ValueType = 0x8DD2;
    pub const UNSIGNED_INT_SAMPLER_3D: ValueType = 0x8DD3;
    pub const UNSIGNED_INT_SAMPLER_CUBE: ValueType = 0x8DD4;
    pub const UNSIGNED_INT_SAMPLER_1D_ARRAY: ValueType = 0x8DD6;
    pub const UNSIGNED_INT_SAMPLER_2D_ARRAY: ValueType = 0x8DD7;
    pub const QUERY_WAIT: ValueType = 0x8E13;
    pub const QUERY_NO_WAIT: ValueType = 0x8E14;
    pub const QUERY_BY_REGION_WAIT: ValueType = 0x8E15;
    pub const QUERY_BY_REGION_NO_WAIT: ValueType = 0x8E16;
    pub const BUFFER_ACCESS_FLAGS: ValueType = 0x911F;
    pub const BUFFER_MAP_LENGTH: ValueType = 0x9120;
    pub const BUFFER_MAP_OFFSET: ValueType = 0x9121;
    pub const DEPTH_COMPONENT32F: ValueType = 0x8CAC;
    pub const DEPTH32F_STENCIL8: ValueType = 0x8CAD;
    pub const FLOAT_32_UNSIGNED_INT_24_8_REV: ValueType = 0x8DAD;
    pub const INVALID_FRAMEBUFFER_OPERATION: ValueType = 0x0506;
    pub const FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING: ValueType = 0x8210;
    pub const FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE: ValueType = 0x8211;
    pub const FRAMEBUFFER_ATTACHMENT_RED_SIZE: ValueType = 0x8212;
    pub const FRAMEBUFFER_ATTACHMENT_GREEN_SIZE: ValueType = 0x8213;
    pub const FRAMEBUFFER_ATTACHMENT_BLUE_SIZE: ValueType = 0x8214;
    pub const FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE: ValueType = 0x8215;
    pub const FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE: ValueType = 0x8216;
    pub const FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE: ValueType = 0x8217;
    pub const FRAMEBUFFER_DEFAULT: ValueType = 0x8218;
    pub const FRAMEBUFFER_UNDEFINED: ValueType = 0x8219;
    pub const DEPTH_STENCIL_ATTACHMENT: ValueType = 0x821A;
    pub const MAX_RENDERBUFFER_SIZE: ValueType = 0x84E8;
    pub const DEPTH_STENCIL: ValueType = 0x84F9;
    pub const UNSIGNED_INT_24_8: ValueType = 0x84FA;
    pub const DEPTH24_STENCIL8: ValueType = 0x88F0;
    pub const TEXTURE_STENCIL_SIZE: ValueType = 0x88F1;
    pub const TEXTURE_RED_TYPE: ValueType = 0x8C10;
    pub const TEXTURE_GREEN_TYPE: ValueType = 0x8C11;
    pub const TEXTURE_BLUE_TYPE: ValueType = 0x8C12;
    pub const TEXTURE_ALPHA_TYPE: ValueType = 0x8C13;
    pub const TEXTURE_DEPTH_TYPE: ValueType = 0x8C16;
    pub const UNSIGNED_NORMALIZED: ValueType = 0x8C17;
    pub const FRAMEBUFFER_BINDING: ValueType = 0x8CA6;
    pub const DRAW_FRAMEBUFFER_BINDING: ValueType = 0x8CA6;
    pub const RENDERBUFFER_BINDING: ValueType = 0x8CA7;
    pub const READ_FRAMEBUFFER: ValueType = 0x8CA8;
    pub const DRAW_FRAMEBUFFER: ValueType = 0x8CA9;
    pub const READ_FRAMEBUFFER_BINDING: ValueType = 0x8CAA;
    pub const RENDERBUFFER_SAMPLES: ValueType = 0x8CAB;
    pub const FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: ValueType = 0x8CD0;
    pub const FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: ValueType = 0x8CD1;
    pub const FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL: ValueType = 0x8CD2;
    pub const FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE: ValueType = 0x8CD3;
    pub const FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER: ValueType = 0x8CD4;
    pub const FRAMEBUFFER_COMPLETE: ValueType = 0x8CD5;
    pub const FRAMEBUFFER_INCOMPLETE_ATTACHMENT: ValueType = 0x8CD6;
    pub const FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: ValueType = 0x8CD7;
    pub const FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: ValueType = 0x8CDB;
    pub const FRAMEBUFFER_INCOMPLETE_READ_BUFFER: ValueType = 0x8CDC;
    pub const FRAMEBUFFER_UNSUPPORTED: ValueType = 0x8CDD;
    pub const MAX_COLOR_ATTACHMENTS: ValueType = 0x8CDF;
    pub const COLOR_ATTACHMENT0: ValueType = 0x8CE0;
    pub const COLOR_ATTACHMENT1: ValueType = 0x8CE1;
    pub const COLOR_ATTACHMENT2: ValueType = 0x8CE2;
    pub const COLOR_ATTACHMENT3: ValueType = 0x8CE3;
    pub const COLOR_ATTACHMENT4: ValueType = 0x8CE4;
    pub const COLOR_ATTACHMENT5: ValueType = 0x8CE5;
    pub const COLOR_ATTACHMENT6: ValueType = 0x8CE6;
    pub const COLOR_ATTACHMENT7: ValueType = 0x8CE7;
    pub const COLOR_ATTACHMENT8: ValueType = 0x8CE8;
    pub const COLOR_ATTACHMENT9: ValueType = 0x8CE9;
    pub const COLOR_ATTACHMENT10: ValueType = 0x8CEA;
    pub const COLOR_ATTACHMENT11: ValueType = 0x8CEB;
    pub const COLOR_ATTACHMENT12: ValueType = 0x8CEC;
    pub const COLOR_ATTACHMENT13: ValueType = 0x8CED;
    pub const COLOR_ATTACHMENT14: ValueType = 0x8CEE;
    pub const COLOR_ATTACHMENT15: ValueType = 0x8CEF;
    pub const COLOR_ATTACHMENT16: ValueType = 0x8CF0;
    pub const COLOR_ATTACHMENT17: ValueType = 0x8CF1;
    pub const COLOR_ATTACHMENT18: ValueType = 0x8CF2;
    pub const COLOR_ATTACHMENT19: ValueType = 0x8CF3;
    pub const COLOR_ATTACHMENT20: ValueType = 0x8CF4;
    pub const COLOR_ATTACHMENT21: ValueType = 0x8CF5;
    pub const COLOR_ATTACHMENT22: ValueType = 0x8CF6;
    pub const COLOR_ATTACHMENT23: ValueType = 0x8CF7;
    pub const COLOR_ATTACHMENT24: ValueType = 0x8CF8;
    pub const COLOR_ATTACHMENT25: ValueType = 0x8CF9;
    pub const COLOR_ATTACHMENT26: ValueType = 0x8CFA;
    pub const COLOR_ATTACHMENT27: ValueType = 0x8CFB;
    pub const COLOR_ATTACHMENT28: ValueType = 0x8CFC;
    pub const COLOR_ATTACHMENT29: ValueType = 0x8CFD;
    pub const COLOR_ATTACHMENT30: ValueType = 0x8CFE;
    pub const COLOR_ATTACHMENT31: ValueType = 0x8CFF;
    pub const DEPTH_ATTACHMENT: ValueType = 0x8D00;
    pub const STENCIL_ATTACHMENT: ValueType = 0x8D20;
    pub const FRAMEBUFFER: ValueType = 0x8D40;
    pub const RENDERBUFFER: ValueType = 0x8D41;
    pub const RENDERBUFFER_WIDTH: ValueType = 0x8D42;
    pub const RENDERBUFFER_HEIGHT: ValueType = 0x8D43;
    pub const RENDERBUFFER_INTERNAL_FORMAT: ValueType = 0x8D44;
    pub const STENCIL_INDEX1: ValueType = 0x8D46;
    pub const STENCIL_INDEX4: ValueType = 0x8D47;
    pub const STENCIL_INDEX8: ValueType = 0x8D48;
    pub const STENCIL_INDEX16: ValueType = 0x8D49;
    pub const RENDERBUFFER_RED_SIZE: ValueType = 0x8D50;
    pub const RENDERBUFFER_GREEN_SIZE: ValueType = 0x8D51;
    pub const RENDERBUFFER_BLUE_SIZE: ValueType = 0x8D52;
    pub const RENDERBUFFER_ALPHA_SIZE: ValueType = 0x8D53;
    pub const RENDERBUFFER_DEPTH_SIZE: ValueType = 0x8D54;
    pub const RENDERBUFFER_STENCIL_SIZE: ValueType = 0x8D55;
    pub const FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: ValueType = 0x8D56;
    pub const MAX_SAMPLES: ValueType = 0x8D57;
    pub const FRAMEBUFFER_SRGB: ValueType = 0x8DB9;
    pub const HALF_FLOAT: ValueType = 0x140B;
    pub const MAP_READ_BIT: ValueType = 0x0001;
    pub const MAP_WRITE_BIT: ValueType = 0x0002;
    pub const MAP_INVALIDATE_RANGE_BIT: ValueType = 0x0004;
    pub const MAP_INVALIDATE_BUFFER_BIT: ValueType = 0x0008;
    pub const MAP_FLUSH_EXPLICIT_BIT: ValueType = 0x0010;
    pub const MAP_UNSYNCHRONIZED_BIT: ValueType = 0x0020;
    pub const COMPRESSED_RED_RGTC1: ValueType = 0x8DBB;
    pub const COMPRESSED_SIGNED_RED_RGTC1: ValueType = 0x8DBC;
    pub const COMPRESSED_RG_RGTC2: ValueType = 0x8DBD;
    pub const COMPRESSED_SIGNED_RG_RGTC2: ValueType = 0x8DBE;
    pub const RG: ValueType = 0x8227;
    pub const RG_INTEGER: ValueType = 0x8228;
    pub const R8: ValueType = 0x8229;
    pub const R16: ValueType = 0x822A;
    pub const RG8: ValueType = 0x822B;
    pub const RG16: ValueType = 0x822C;
    pub const R16F: ValueType = 0x822D;
    pub const R32F: ValueType = 0x822E;
    pub const RG16F: ValueType = 0x822F;
    pub const RG32F: ValueType = 0x8230;
    pub const R8I: ValueType = 0x8231;
    pub const R8UI: ValueType = 0x8232;
    pub const R16I: ValueType = 0x8233;
    pub const R16UI: ValueType = 0x8234;
    pub const R32I: ValueType = 0x8235;
    pub const R32UI: ValueType = 0x8236;
    pub const RG8I: ValueType = 0x8237;
    pub const RG8UI: ValueType = 0x8238;
    pub const RG16I: ValueType = 0x8239;
    pub const RG16UI: ValueType = 0x823A;
    pub const RG32I: ValueType = 0x823B;
    pub const RG32UI: ValueType = 0x823C;
    pub const VERTEX_ARRAY_BINDING: ValueType = 0x85B5;
    pub const SAMPLER_2D_RECT: ValueType = 0x8B63;
    pub const SAMPLER_2D_RECT_SHADOW: ValueType = 0x8B64;
    pub const SAMPLER_BUFFER: ValueType = 0x8DC2;
    pub const INT_SAMPLER_2D_RECT: ValueType = 0x8DCD;
    pub const INT_SAMPLER_BUFFER: ValueType = 0x8DD0;
    pub const UNSIGNED_INT_SAMPLER_2D_RECT: ValueType = 0x8DD5;
    pub const UNSIGNED_INT_SAMPLER_BUFFER: ValueType = 0x8DD8;
    pub const TEXTURE_BUFFER: ValueType = 0x8C2A;
    pub const MAX_TEXTURE_BUFFER_SIZE: ValueType = 0x8C2B;
    pub const TEXTURE_BINDING_BUFFER: ValueType = 0x8C2C;
    pub const TEXTURE_BUFFER_DATA_STORE_BINDING: ValueType = 0x8C2D;
    pub const TEXTURE_RECTANGLE: ValueType = 0x84F5;
    pub const TEXTURE_BINDING_RECTANGLE: ValueType = 0x84F6;
    pub const PROXY_TEXTURE_RECTANGLE: ValueType = 0x84F7;
    pub const MAX_RECTANGLE_TEXTURE_SIZE: ValueType = 0x84F8;
    pub const R8_SNORM: ValueType = 0x8F94;
    pub const RG8_SNORM: ValueType = 0x8F95;
    pub const RGB8_SNORM: ValueType = 0x8F96;
    pub const RGBA8_SNORM: ValueType = 0x8F97;
    pub const R16_SNORM: ValueType = 0x8F98;
    pub const RG16_SNORM: ValueType = 0x8F99;
    pub const RGB16_SNORM: ValueType = 0x8F9A;
    pub const RGBA16_SNORM: ValueType = 0x8F9B;
    pub const SIGNED_NORMALIZED: ValueType = 0x8F9C;
    pub const PRIMITIVE_RESTART: ValueType = 0x8F9D;
    pub const PRIMITIVE_RESTART_INDEX: ValueType = 0x8F9E;
    pub const COPY_READ_BUFFER: ValueType = 0x8F36;
    pub const COPY_WRITE_BUFFER: ValueType = 0x8F37;
    pub const UNIFORM_BUFFER: ValueType = 0x8A11;
    pub const UNIFORM_BUFFER_BINDING: ValueType = 0x8A28;
    pub const UNIFORM_BUFFER_START: ValueType = 0x8A29;
    pub const UNIFORM_BUFFER_SIZE: ValueType = 0x8A2A;
    pub const MAX_VERTEX_UNIFORM_BLOCKS: ValueType = 0x8A2B;
    pub const MAX_GEOMETRY_UNIFORM_BLOCKS: ValueType = 0x8A2C;
    pub const MAX_FRAGMENT_UNIFORM_BLOCKS: ValueType = 0x8A2D;
    pub const MAX_COMBINED_UNIFORM_BLOCKS: ValueType = 0x8A2E;
    pub const MAX_UNIFORM_BUFFER_BINDINGS: ValueType = 0x8A2F;
    pub const MAX_UNIFORM_BLOCK_SIZE: ValueType = 0x8A30;
    pub const MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS: ValueType = 0x8A31;
    pub const MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS: ValueType = 0x8A32;
    pub const MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS: ValueType = 0x8A33;
    pub const UNIFORM_BUFFER_OFFSET_ALIGNMENT: ValueType = 0x8A34;
    pub const ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH: ValueType = 0x8A35;
    pub const ACTIVE_UNIFORM_BLOCKS: ValueType = 0x8A36;
    pub const UNIFORM_TYPE: ValueType = 0x8A37;
    pub const UNIFORM_SIZE: ValueType = 0x8A38;
    pub const UNIFORM_NAME_LENGTH: ValueType = 0x8A39;
    pub const UNIFORM_BLOCK_INDEX: ValueType = 0x8A3A;
    pub const UNIFORM_OFFSET: ValueType = 0x8A3B;
    pub const UNIFORM_ARRAY_STRIDE: ValueType = 0x8A3C;
    pub const UNIFORM_MATRIX_STRIDE: ValueType = 0x8A3D;
    pub const UNIFORM_IS_ROW_MAJOR: ValueType = 0x8A3E;
    pub const UNIFORM_BLOCK_BINDING: ValueType = 0x8A3F;
    pub const UNIFORM_BLOCK_DATA_SIZE: ValueType = 0x8A40;
    pub const UNIFORM_BLOCK_NAME_LENGTH: ValueType = 0x8A41;
    pub const UNIFORM_BLOCK_ACTIVE_UNIFORMS: ValueType = 0x8A42;
    pub const UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES: ValueType = 0x8A43;
    pub const UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER: ValueType = 0x8A44;
    pub const UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER: ValueType = 0x8A45;
    pub const UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER: ValueType = 0x8A46;
    pub const INVALID_INDEX: ValueType = 0xFFFFFFFF;
    pub const CONTEXT_CORE_PROFILE_BIT: ValueType = 0x00000001;
    pub const CONTEXT_COMPATIBILITY_PROFILE_BIT: ValueType = 0x00000002;
    pub const LINES_ADJACENCY: ValueType = 0x000A;
    pub const LINE_STRIP_ADJACENCY: ValueType = 0x000B;
    pub const TRIANGLES_ADJACENCY: ValueType = 0x000C;
    pub const TRIANGLE_STRIP_ADJACENCY: ValueType = 0x000D;
    pub const PROGRAM_POINT_SIZE: ValueType = 0x8642;
    pub const MAX_GEOMETRY_TEXTURE_IMAGE_UNITS: ValueType = 0x8C29;
    pub const FRAMEBUFFER_ATTACHMENT_LAYERED: ValueType = 0x8DA7;
    pub const FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: ValueType = 0x8DA8;
    pub const GEOMETRY_SHADER: ValueType = 0x8DD9;
    pub const GEOMETRY_VERTICES_OUT: ValueType = 0x8916;
    pub const GEOMETRY_INPUT_TYPE: ValueType = 0x8917;
    pub const GEOMETRY_OUTPUT_TYPE: ValueType = 0x8918;
    pub const MAX_GEOMETRY_UNIFORM_COMPONENTS: ValueType = 0x8DDF;
    pub const MAX_GEOMETRY_OUTPUT_VERTICES: ValueType = 0x8DE0;
    pub const MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS: ValueType = 0x8DE1;
    pub const MAX_VERTEX_OUTPUT_COMPONENTS: ValueType = 0x9122;
    pub const MAX_GEOMETRY_INPUT_COMPONENTS: ValueType = 0x9123;
    pub const MAX_GEOMETRY_OUTPUT_COMPONENTS: ValueType = 0x9124;
    pub const MAX_FRAGMENT_INPUT_COMPONENTS: ValueType = 0x9125;
    pub const CONTEXT_PROFILE_MASK: ValueType = 0x9126;
    pub const DEPTH_CLAMP: ValueType = 0x864F;
    pub const QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION: ValueType = 0x8E4C;
    pub const FIRST_VERTEX_CONVENTION: ValueType = 0x8E4D;
    pub const LAST_VERTEX_CONVENTION: ValueType = 0x8E4E;
    pub const PROVOKING_VERTEX: ValueType = 0x8E4F;
    pub const TEXTURE_CUBE_MAP_SEAMLESS: ValueType = 0x884F;
    pub const MAX_SERVER_WAIT_TIMEOUT: ValueType = 0x9111;
    pub const OBJECT_TYPE: ValueType = 0x9112;
    pub const SYNC_CONDITION: ValueType = 0x9113;
    pub const SYNC_STATUS: ValueType = 0x9114;
    pub const SYNC_FLAGS: ValueType = 0x9115;
    pub const SYNC_FENCE: ValueType = 0x9116;
    pub const SYNC_GPU_COMMANDS_COMPLETE: ValueType = 0x9117;
    pub const UNSIGNALED: ValueType = 0x9118;
    pub const SIGNALED: ValueType = 0x9119;
    pub const ALREADY_SIGNALED: ValueType = 0x911A;
    pub const TIMEOUT_EXPIRED: ValueType = 0x911B;
    pub const CONDITION_SATISFIED: ValueType = 0x911C;
    pub const WAIT_FAILED: ValueType = 0x911D;
    pub const TIMEOUT_IGNORED: ValueType = 0xFFFFFFFFFFFFFFFF;
    pub const SYNC_FLUSH_COMMANDS_BIT: ValueType = 0x00000001;
    pub const SAMPLE_POSITION: ValueType = 0x8E50;
    pub const SAMPLE_MASK: ValueType = 0x8E51;
    pub const SAMPLE_MASK_VALUE: ValueType = 0x8E52;
    pub const MAX_SAMPLE_MASK_WORDS: ValueType = 0x8E59;
    pub const TEXTURE_2D_MULTISAMPLE: ValueType = 0x9100;
    pub const PROXY_TEXTURE_2D_MULTISAMPLE: ValueType = 0x9101;
    pub const TEXTURE_2D_MULTISAMPLE_ARRAY: ValueType = 0x9102;
    pub const PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY: ValueType = 0x9103;
    pub const TEXTURE_BINDING_2D_MULTISAMPLE: ValueType = 0x9104;
    pub const TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY: ValueType = 0x9105;
    pub const TEXTURE_SAMPLES: ValueType = 0x9106;
    pub const TEXTURE_FIXED_SAMPLE_LOCATIONS: ValueType = 0x9107;
    pub const SAMPLER_2D_MULTISAMPLE: ValueType = 0x9108;
    pub const INT_SAMPLER_2D_MULTISAMPLE: ValueType = 0x9109;
    pub const UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE: ValueType = 0x910A;
    pub const SAMPLER_2D_MULTISAMPLE_ARRAY: ValueType = 0x910B;
    pub const INT_SAMPLER_2D_MULTISAMPLE_ARRAY: ValueType = 0x910C;
    pub const UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY: ValueType = 0x910D;
    pub const MAX_COLOR_TEXTURE_SAMPLES: ValueType = 0x910E;
    pub const MAX_DEPTH_TEXTURE_SAMPLES: ValueType = 0x910F;
    pub const MAX_INTEGER_SAMPLES: ValueType = 0x9110;
    pub const VERTEX_ATTRIB_ARRAY_DIVISOR: ValueType = 0x88FE;
    pub const SRC1_COLOR: ValueType = 0x88F9;
    pub const ONE_MINUS_SRC1_COLOR: ValueType = 0x88FA;
    pub const ONE_MINUS_SRC1_ALPHA: ValueType = 0x88FB;
    pub const MAX_DUAL_SOURCE_DRAW_BUFFERS: ValueType = 0x88FC;
    pub const ANY_SAMPLES_PASSED: ValueType = 0x8C2F;
    pub const SAMPLER_BINDING: ValueType = 0x8919;
    pub const RGB10_A2UI: ValueType = 0x906F;
    pub const TEXTURE_SWIZZLE_R: ValueType = 0x8E42;
    pub const TEXTURE_SWIZZLE_G: ValueType = 0x8E43;
    pub const TEXTURE_SWIZZLE_B: ValueType = 0x8E44;
    pub const TEXTURE_SWIZZLE_A: ValueType = 0x8E45;
    pub const TEXTURE_SWIZZLE_RGBA: ValueType = 0x8E46;
    pub const TIME_ELAPSED: ValueType = 0x88BF;
    pub const TIMESTAMP: ValueType = 0x8E28;
    pub const INT_2_10_10_10_REV: ValueType = 0x8D9F;
    pub const SAMPLE_SHADING: ValueType = 0x8C36;
    pub const MIN_SAMPLE_SHADING_VALUE: ValueType = 0x8C37;
    pub const MIN_PROGRAM_TEXTURE_GATHER_OFFSET: ValueType = 0x8E5E;
    pub const MAX_PROGRAM_TEXTURE_GATHER_OFFSET: ValueType = 0x8E5F;
    pub const TEXTURE_CUBE_MAP_ARRAY: ValueType = 0x9009;
    pub const TEXTURE_BINDING_CUBE_MAP_ARRAY: ValueType = 0x900A;
    pub const PROXY_TEXTURE_CUBE_MAP_ARRAY: ValueType = 0x900B;
    pub const SAMPLER_CUBE_MAP_ARRAY: ValueType = 0x900C;
    pub const SAMPLER_CUBE_MAP_ARRAY_SHADOW: ValueType = 0x900D;
    pub const INT_SAMPLER_CUBE_MAP_ARRAY: ValueType = 0x900E;
    pub const UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY: ValueType = 0x900F;
    pub const DRAW_INDIRECT_BUFFER: ValueType = 0x8F3F;
    pub const DRAW_INDIRECT_BUFFER_BINDING: ValueType = 0x8F43;
    pub const GEOMETRY_SHADER_INVOCATIONS: ValueType = 0x887F;
    pub const MAX_GEOMETRY_SHADER_INVOCATIONS: ValueType = 0x8E5A;
    pub const MIN_FRAGMENT_INTERPOLATION_OFFSET: ValueType = 0x8E5B;
    pub const MAX_FRAGMENT_INTERPOLATION_OFFSET: ValueType = 0x8E5C;
    pub const FRAGMENT_INTERPOLATION_OFFSET_BITS: ValueType = 0x8E5D;
    pub const MAX_VERTEX_STREAMS: ValueType = 0x8E71;
    pub const DOUBLE_VEC2: ValueType = 0x8FFC;
    pub const DOUBLE_VEC3: ValueType = 0x8FFD;
    pub const DOUBLE_VEC4: ValueType = 0x8FFE;
    pub const DOUBLE_MAT2: ValueType = 0x8F46;
    pub const DOUBLE_MAT3: ValueType = 0x8F47;
    pub const DOUBLE_MAT4: ValueType = 0x8F48;
    pub const DOUBLE_MAT2x3: ValueType = 0x8F49;
    pub const DOUBLE_MAT2x4: ValueType = 0x8F4A;
    pub const DOUBLE_MAT3x2: ValueType = 0x8F4B;
    pub const DOUBLE_MAT3x4: ValueType = 0x8F4C;
    pub const DOUBLE_MAT4x2: ValueType = 0x8F4D;
    pub const DOUBLE_MAT4x3: ValueType = 0x8F4E;
    pub const ACTIVE_SUBROUTINES: ValueType = 0x8DE5;
    pub const ACTIVE_SUBROUTINE_UNIFORMS: ValueType = 0x8DE6;
    pub const ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS: ValueType = 0x8E47;
    pub const ACTIVE_SUBROUTINE_MAX_LENGTH: ValueType = 0x8E48;
    pub const ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH: ValueType = 0x8E49;
    pub const MAX_SUBROUTINES: ValueType = 0x8DE7;
    pub const MAX_SUBROUTINE_UNIFORM_LOCATIONS: ValueType = 0x8DE8;
    pub const NUM_COMPATIBLE_SUBROUTINES: ValueType = 0x8E4A;
    pub const COMPATIBLE_SUBROUTINES: ValueType = 0x8E4B;
    pub const PATCHES: ValueType = 0x000E;
    pub const PATCH_VERTICES: ValueType = 0x8E72;
    pub const PATCH_DEFAULT_INNER_LEVEL: ValueType = 0x8E73;
    pub const PATCH_DEFAULT_OUTER_LEVEL: ValueType = 0x8E74;
    pub const TESS_CONTROL_OUTPUT_VERTICES: ValueType = 0x8E75;
    pub const TESS_GEN_MODE: ValueType = 0x8E76;
    pub const TESS_GEN_SPACING: ValueType = 0x8E77;
    pub const TESS_GEN_VERTEX_ORDER: ValueType = 0x8E78;
    pub const TESS_GEN_POINT_MODE: ValueType = 0x8E79;
    pub const ISOLINES: ValueType = 0x8E7A;
    pub const QUADS: ValueType = 0x0007;
    pub const FRACTIONAL_ODD: ValueType = 0x8E7B;
    pub const FRACTIONAL_EVEN: ValueType = 0x8E7C;
    pub const MAX_PATCH_VERTICES: ValueType = 0x8E7D;
    pub const MAX_TESS_GEN_LEVEL: ValueType = 0x8E7E;
    pub const MAX_TESS_CONTROL_UNIFORM_COMPONENTS: ValueType = 0x8E7F;
    pub const MAX_TESS_EVALUATION_UNIFORM_COMPONENTS: ValueType = 0x8E80;
    pub const MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS: ValueType = 0x8E81;
    pub const MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS: ValueType = 0x8E82;
    pub const MAX_TESS_CONTROL_OUTPUT_COMPONENTS: ValueType = 0x8E83;
    pub const MAX_TESS_PATCH_COMPONENTS: ValueType = 0x8E84;
    pub const MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS: ValueType = 0x8E85;
    pub const MAX_TESS_EVALUATION_OUTPUT_COMPONENTS: ValueType = 0x8E86;
    pub const MAX_TESS_CONTROL_UNIFORM_BLOCKS: ValueType = 0x8E89;
    pub const MAX_TESS_EVALUATION_UNIFORM_BLOCKS: ValueType = 0x8E8A;
    pub const MAX_TESS_CONTROL_INPUT_COMPONENTS: ValueType = 0x886C;
    pub const MAX_TESS_EVALUATION_INPUT_COMPONENTS: ValueType = 0x886D;
    pub const MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS: ValueType = 0x8E1E;
    pub const MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS: ValueType = 0x8E1F;
    pub const UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER: ValueType = 0x84F0;
    pub const UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER: ValueType = 0x84F1;
    pub const TESS_EVALUATION_SHADER: ValueType = 0x8E87;
    pub const TESS_CONTROL_SHADER: ValueType = 0x8E88;
    pub const TRANSFORM_FEEDBACK: ValueType = 0x8E22;
    pub const TRANSFORM_FEEDBACK_BUFFER_PAUSED: ValueType = 0x8E23;
    pub const TRANSFORM_FEEDBACK_BUFFER_ACTIVE: ValueType = 0x8E24;
    pub const TRANSFORM_FEEDBACK_BINDING: ValueType = 0x8E25;
    pub const MAX_TRANSFORM_FEEDBACK_BUFFERS: ValueType = 0x8E70;
    pub const FIXED: ValueType = 0x140C;
    pub const IMPLEMENTATION_COLOR_READ_TYPE: ValueType = 0x8B9A;
    pub const IMPLEMENTATION_COLOR_READ_FORMAT: ValueType = 0x8B9B;
    pub const LOW_FLOAT: ValueType = 0x8DF0;
    pub const MEDIUM_FLOAT: ValueType = 0x8DF1;
    pub const HIGH_FLOAT: ValueType = 0x8DF2;
    pub const LOW_INT: ValueType = 0x8DF3;
    pub const MEDIUM_INT: ValueType = 0x8DF4;
    pub const HIGH_INT: ValueType = 0x8DF5;
    pub const SHADER_COMPILER: ValueType = 0x8DFA;
    pub const SHADER_BINARY_FORMATS: ValueType = 0x8DF8;
    pub const NUM_SHADER_BINARY_FORMATS: ValueType = 0x8DF9;
    pub const MAX_VERTEX_UNIFORM_VECTORS: ValueType = 0x8DFB;
    pub const MAX_VARYING_VECTORS: ValueType = 0x8DFC;
    pub const MAX_FRAGMENT_UNIFORM_VECTORS: ValueType = 0x8DFD;
    pub const RGB565: ValueType = 0x8D62;
    pub const PROGRAM_BINARY_RETRIEVABLE_HINT: ValueType = 0x8257;
    pub const PROGRAM_BINARY_LENGTH: ValueType = 0x8741;
    pub const NUM_PROGRAM_BINARY_FORMATS: ValueType = 0x87FE;
    pub const PROGRAM_BINARY_FORMATS: ValueType = 0x87FF;
    pub const VERTEX_SHADER_BIT: ValueType = 0x00000001;
    pub const FRAGMENT_SHADER_BIT: ValueType = 0x00000002;
    pub const GEOMETRY_SHADER_BIT: ValueType = 0x00000004;
    pub const TESS_CONTROL_SHADER_BIT: ValueType = 0x00000008;
    pub const TESS_EVALUATION_SHADER_BIT: ValueType = 0x00000010;
    pub const ALL_SHADER_BITS: ValueType = 0xFFFFFFFF;
    pub const PROGRAM_SEPARABLE: ValueType = 0x8258;
    pub const ACTIVE_PROGRAM: ValueType = 0x8259;
    pub const PROGRAM_PIPELINE_BINDING: ValueType = 0x825A;
    pub const MAX_VIEWPORTS: ValueType = 0x825B;
    pub const VIEWPORT_SUBPIXEL_BITS: ValueType = 0x825C;
    pub const VIEWPORT_BOUNDS_RANGE: ValueType = 0x825D;
    pub const LAYER_PROVOKING_VERTEX: ValueType = 0x825E;
    pub const VIEWPORT_INDEX_PROVOKING_VERTEX: ValueType = 0x825F;
    pub const UNDEFINED_VERTEX: ValueType = 0x8260;
    pub const COPY_READ_BUFFER_BINDING: ValueType = 0x8F36;
    pub const COPY_WRITE_BUFFER_BINDING: ValueType = 0x8F37;
    pub const TRANSFORM_FEEDBACK_ACTIVE: ValueType = 0x8E24;
    pub const TRANSFORM_FEEDBACK_PAUSED: ValueType = 0x8E23;
    pub const UNPACK_COMPRESSED_BLOCK_WIDTH: ValueType = 0x9127;
    pub const UNPACK_COMPRESSED_BLOCK_HEIGHT: ValueType = 0x9128;
    pub const UNPACK_COMPRESSED_BLOCK_DEPTH: ValueType = 0x9129;
    pub const UNPACK_COMPRESSED_BLOCK_SIZE: ValueType = 0x912A;
    pub const PACK_COMPRESSED_BLOCK_WIDTH: ValueType = 0x912B;
    pub const PACK_COMPRESSED_BLOCK_HEIGHT: ValueType = 0x912C;
    pub const PACK_COMPRESSED_BLOCK_DEPTH: ValueType = 0x912D;
    pub const PACK_COMPRESSED_BLOCK_SIZE: ValueType = 0x912E;
    pub const NUM_SAMPLE_COUNTS: ValueType = 0x9380;
    pub const MIN_MAP_BUFFER_ALIGNMENT: ValueType = 0x90BC;
    pub const ATOMIC_COUNTER_BUFFER: ValueType = 0x92C0;
    pub const ATOMIC_COUNTER_BUFFER_BINDING: ValueType = 0x92C1;
    pub const ATOMIC_COUNTER_BUFFER_START: ValueType = 0x92C2;
    pub const ATOMIC_COUNTER_BUFFER_SIZE: ValueType = 0x92C3;
    pub const ATOMIC_COUNTER_BUFFER_DATA_SIZE: ValueType = 0x92C4;
    pub const ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTERS: ValueType = 0x92C5;
    pub const ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTER_INDICES: ValueType = 0x92C6;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_VERTEX_SHADER: ValueType = 0x92C7;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_CONTROL_SHADER: ValueType = 0x92C8;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_EVALUATION_SHADER: ValueType = 0x92C9;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_GEOMETRY_SHADER: ValueType = 0x92CA;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_FRAGMENT_SHADER: ValueType = 0x92CB;
    pub const MAX_VERTEX_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92CC;
    pub const MAX_TESS_CONTROL_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92CD;
    pub const MAX_TESS_EVALUATION_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92CE;
    pub const MAX_GEOMETRY_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92CF;
    pub const MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92D0;
    pub const MAX_COMBINED_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92D1;
    pub const MAX_VERTEX_ATOMIC_COUNTERS: ValueType = 0x92D2;
    pub const MAX_TESS_CONTROL_ATOMIC_COUNTERS: ValueType = 0x92D3;
    pub const MAX_TESS_EVALUATION_ATOMIC_COUNTERS: ValueType = 0x92D4;
    pub const MAX_GEOMETRY_ATOMIC_COUNTERS: ValueType = 0x92D5;
    pub const MAX_FRAGMENT_ATOMIC_COUNTERS: ValueType = 0x92D6;
    pub const MAX_COMBINED_ATOMIC_COUNTERS: ValueType = 0x92D7;
    pub const MAX_ATOMIC_COUNTER_BUFFER_SIZE: ValueType = 0x92D8;
    pub const MAX_ATOMIC_COUNTER_BUFFER_BINDINGS: ValueType = 0x92DC;
    pub const ACTIVE_ATOMIC_COUNTER_BUFFERS: ValueType = 0x92D9;
    pub const UNIFORM_ATOMIC_COUNTER_BUFFER_INDEX: ValueType = 0x92DA;
    pub const UNSIGNED_INT_ATOMIC_COUNTER: ValueType = 0x92DB;
    pub const VERTEX_ATTRIB_ARRAY_BARRIER_BIT: ValueType = 0x00000001;
    pub const ELEMENT_ARRAY_BARRIER_BIT: ValueType = 0x00000002;
    pub const UNIFORM_BARRIER_BIT: ValueType = 0x00000004;
    pub const TEXTURE_FETCH_BARRIER_BIT: ValueType = 0x00000008;
    pub const SHADER_IMAGE_ACCESS_BARRIER_BIT: ValueType = 0x00000020;
    pub const COMMAND_BARRIER_BIT: ValueType = 0x00000040;
    pub const PIXEL_BUFFER_BARRIER_BIT: ValueType = 0x00000080;
    pub const TEXTURE_UPDATE_BARRIER_BIT: ValueType = 0x00000100;
    pub const BUFFER_UPDATE_BARRIER_BIT: ValueType = 0x00000200;
    pub const FRAMEBUFFER_BARRIER_BIT: ValueType = 0x00000400;
    pub const TRANSFORM_FEEDBACK_BARRIER_BIT: ValueType = 0x00000800;
    pub const ATOMIC_COUNTER_BARRIER_BIT: ValueType = 0x00001000;
    pub const ALL_BARRIER_BITS: ValueType = 0xFFFFFFFF;
    pub const MAX_IMAGE_UNITS: ValueType = 0x8F38;
    pub const MAX_COMBINED_IMAGE_UNITS_AND_FRAGMENT_OUTPUTS: ValueType = 0x8F39;
    pub const IMAGE_BINDING_NAME: ValueType = 0x8F3A;
    pub const IMAGE_BINDING_LEVEL: ValueType = 0x8F3B;
    pub const IMAGE_BINDING_LAYERED: ValueType = 0x8F3C;
    pub const IMAGE_BINDING_LAYER: ValueType = 0x8F3D;
    pub const IMAGE_BINDING_ACCESS: ValueType = 0x8F3E;
    pub const IMAGE_1D: ValueType = 0x904C;
    pub const IMAGE_2D: ValueType = 0x904D;
    pub const IMAGE_3D: ValueType = 0x904E;
    pub const IMAGE_2D_RECT: ValueType = 0x904F;
    pub const IMAGE_CUBE: ValueType = 0x9050;
    pub const IMAGE_BUFFER: ValueType = 0x9051;
    pub const IMAGE_1D_ARRAY: ValueType = 0x9052;
    pub const IMAGE_2D_ARRAY: ValueType = 0x9053;
    pub const IMAGE_CUBE_MAP_ARRAY: ValueType = 0x9054;
    pub const IMAGE_2D_MULTISAMPLE: ValueType = 0x9055;
    pub const IMAGE_2D_MULTISAMPLE_ARRAY: ValueType = 0x9056;
    pub const INT_IMAGE_1D: ValueType = 0x9057;
    pub const INT_IMAGE_2D: ValueType = 0x9058;
    pub const INT_IMAGE_3D: ValueType = 0x9059;
    pub const INT_IMAGE_2D_RECT: ValueType = 0x905A;
    pub const INT_IMAGE_CUBE: ValueType = 0x905B;
    pub const INT_IMAGE_BUFFER: ValueType = 0x905C;
    pub const INT_IMAGE_1D_ARRAY: ValueType = 0x905D;
    pub const INT_IMAGE_2D_ARRAY: ValueType = 0x905E;
    pub const INT_IMAGE_CUBE_MAP_ARRAY: ValueType = 0x905F;
    pub const INT_IMAGE_2D_MULTISAMPLE: ValueType = 0x9060;
    pub const INT_IMAGE_2D_MULTISAMPLE_ARRAY: ValueType = 0x9061;
    pub const UNSIGNED_INT_IMAGE_1D: ValueType = 0x9062;
    pub const UNSIGNED_INT_IMAGE_2D: ValueType = 0x9063;
    pub const UNSIGNED_INT_IMAGE_3D: ValueType = 0x9064;
    pub const UNSIGNED_INT_IMAGE_2D_RECT: ValueType = 0x9065;
    pub const UNSIGNED_INT_IMAGE_CUBE: ValueType = 0x9066;
    pub const UNSIGNED_INT_IMAGE_BUFFER: ValueType = 0x9067;
    pub const UNSIGNED_INT_IMAGE_1D_ARRAY: ValueType = 0x9068;
    pub const UNSIGNED_INT_IMAGE_2D_ARRAY: ValueType = 0x9069;
    pub const UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY: ValueType = 0x906A;
    pub const UNSIGNED_INT_IMAGE_2D_MULTISAMPLE: ValueType = 0x906B;
    pub const UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY: ValueType = 0x906C;
    pub const MAX_IMAGE_SAMPLES: ValueType = 0x906D;
    pub const IMAGE_BINDING_FORMAT: ValueType = 0x906E;
    pub const IMAGE_FORMAT_COMPATIBILITY_TYPE: ValueType = 0x90C7;
    pub const IMAGE_FORMAT_COMPATIBILITY_BY_SIZE: ValueType = 0x90C8;
    pub const IMAGE_FORMAT_COMPATIBILITY_BY_CLASS: ValueType = 0x90C9;
    pub const MAX_VERTEX_IMAGE_UNIFORMS: ValueType = 0x90CA;
    pub const MAX_TESS_CONTROL_IMAGE_UNIFORMS: ValueType = 0x90CB;
    pub const MAX_TESS_EVALUATION_IMAGE_UNIFORMS: ValueType = 0x90CC;
    pub const MAX_GEOMETRY_IMAGE_UNIFORMS: ValueType = 0x90CD;
    pub const MAX_FRAGMENT_IMAGE_UNIFORMS: ValueType = 0x90CE;
    pub const MAX_COMBINED_IMAGE_UNIFORMS: ValueType = 0x90CF;
    pub const COMPRESSED_RGBA_BPTC_UNORM: ValueType = 0x8E8C;
    pub const COMPRESSED_SRGB_ALPHA_BPTC_UNORM: ValueType = 0x8E8D;
    pub const COMPRESSED_RGB_BPTC_SIGNED_FLOAT: ValueType = 0x8E8E;
    pub const COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT: ValueType = 0x8E8F;
    pub const TEXTURE_IMMUTABLE_FORMAT: ValueType = 0x912F;
    pub const NUM_SHADING_LANGUAGE_VERSIONS: ValueType = 0x82E9;
    pub const VERTEX_ATTRIB_ARRAY_LONG: ValueType = 0x874E;
    pub const COMPRESSED_RGB8_ETC2: ValueType = 0x9274;
    pub const COMPRESSED_SRGB8_ETC2: ValueType = 0x9275;
    pub const COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2: ValueType = 0x9276;
    pub const COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2: ValueType = 0x9277;
    pub const COMPRESSED_RGBA8_ETC2_EAC: ValueType = 0x9278;
    pub const COMPRESSED_SRGB8_ALPHA8_ETC2_EAC: ValueType = 0x9279;
    pub const COMPRESSED_R11_EAC: ValueType = 0x9270;
    pub const COMPRESSED_SIGNED_R11_EAC: ValueType = 0x9271;
    pub const COMPRESSED_RG11_EAC: ValueType = 0x9272;
    pub const COMPRESSED_SIGNED_RG11_EAC: ValueType = 0x9273;
    pub const PRIMITIVE_RESTART_FIXED_INDEX: ValueType = 0x8D69;
    pub const ANY_SAMPLES_PASSED_CONSERVATIVE: ValueType = 0x8D6A;
    pub const MAX_ELEMENT_INDEX: ValueType = 0x8D6B;
    pub const COMPUTE_SHADER: ValueType = 0x91B9;
    pub const MAX_COMPUTE_UNIFORM_BLOCKS: ValueType = 0x91BB;
    pub const MAX_COMPUTE_TEXTURE_IMAGE_UNITS: ValueType = 0x91BC;
    pub const MAX_COMPUTE_IMAGE_UNIFORMS: ValueType = 0x91BD;
    pub const MAX_COMPUTE_SHARED_MEMORY_SIZE: ValueType = 0x8262;
    pub const MAX_COMPUTE_UNIFORM_COMPONENTS: ValueType = 0x8263;
    pub const MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS: ValueType = 0x8264;
    pub const MAX_COMPUTE_ATOMIC_COUNTERS: ValueType = 0x8265;
    pub const MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS: ValueType = 0x8266;
    pub const MAX_COMPUTE_WORK_GROUP_INVOCATIONS: ValueType = 0x90EB;
    pub const MAX_COMPUTE_WORK_GROUP_COUNT: ValueType = 0x91BE;
    pub const MAX_COMPUTE_WORK_GROUP_SIZE: ValueType = 0x91BF;
    pub const COMPUTE_WORK_GROUP_SIZE: ValueType = 0x8267;
    pub const UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER: ValueType = 0x90EC;
    pub const ATOMIC_COUNTER_BUFFER_REFERENCED_BY_COMPUTE_SHADER: ValueType = 0x90ED;
    pub const DISPATCH_INDIRECT_BUFFER: ValueType = 0x90EE;
    pub const DISPATCH_INDIRECT_BUFFER_BINDING: ValueType = 0x90EF;
    pub const COMPUTE_SHADER_BIT: ValueType = 0x00000020;
    pub const DEBUG_OUTPUT_SYNCHRONOUS: ValueType = 0x8242;
    pub const DEBUG_NEXT_LOGGED_MESSAGE_LENGTH: ValueType = 0x8243;
    pub const DEBUG_CALLBACK_FUNCTION: ValueType = 0x8244;
    pub const DEBUG_CALLBACK_USER_PARAM: ValueType = 0x8245;
    pub const DEBUG_SOURCE_API: ValueType = 0x8246;
    pub const DEBUG_SOURCE_WINDOW_SYSTEM: ValueType = 0x8247;
    pub const DEBUG_SOURCE_SHADER_COMPILER: ValueType = 0x8248;
    pub const DEBUG_SOURCE_THIRD_PARTY: ValueType = 0x8249;
    pub const DEBUG_SOURCE_APPLICATION: ValueType = 0x824A;
    pub const DEBUG_SOURCE_OTHER: ValueType = 0x824B;
    pub const DEBUG_TYPE_ERROR: ValueType = 0x824C;
    pub const DEBUG_TYPE_DEPRECATED_BEHAVIOR: ValueType = 0x824D;
    pub const DEBUG_TYPE_UNDEFINED_BEHAVIOR: ValueType = 0x824E;
    pub const DEBUG_TYPE_PORTABILITY: ValueType = 0x824F;
    pub const DEBUG_TYPE_PERFORMANCE: ValueType = 0x8250;
    pub const DEBUG_TYPE_OTHER: ValueType = 0x8251;
    pub const MAX_DEBUG_MESSAGE_LENGTH: ValueType = 0x9143;
    pub const MAX_DEBUG_LOGGED_MESSAGES: ValueType = 0x9144;
    pub const DEBUG_LOGGED_MESSAGES: ValueType = 0x9145;
    pub const DEBUG_SEVERITY_HIGH: ValueType = 0x9146;
    pub const DEBUG_SEVERITY_MEDIUM: ValueType = 0x9147;
    pub const DEBUG_SEVERITY_LOW: ValueType = 0x9148;
    pub const DEBUG_TYPE_MARKER: ValueType = 0x8268;
    pub const DEBUG_TYPE_PUSH_GROUP: ValueType = 0x8269;
    pub const DEBUG_TYPE_POP_GROUP: ValueType = 0x826A;
    pub const DEBUG_SEVERITY_NOTIFICATION: ValueType = 0x826B;
    pub const MAX_DEBUG_GROUP_STACK_DEPTH: ValueType = 0x826C;
    pub const DEBUG_GROUP_STACK_DEPTH: ValueType = 0x826D;
    pub const BUFFER: ValueType = 0x82E0;
    pub const SHADER: ValueType = 0x82E1;
    pub const PROGRAM: ValueType = 0x82E2;
    pub const VERTEX_ARRAY: ValueType = 0x8074;
    pub const QUERY: ValueType = 0x82E3;
    pub const PROGRAM_PIPELINE: ValueType = 0x82E4;
    pub const SAMPLER: ValueType = 0x82E6;
    pub const MAX_LABEL_LENGTH: ValueType = 0x82E8;
    pub const DEBUG_OUTPUT: ValueType = 0x92E0;
    pub const CONTEXT_FLAG_DEBUG_BIT: ValueType = 0x00000002;
    pub const MAX_UNIFORM_LOCATIONS: ValueType = 0x826E;
    pub const FRAMEBUFFER_DEFAULT_WIDTH: ValueType = 0x9310;
    pub const FRAMEBUFFER_DEFAULT_HEIGHT: ValueType = 0x9311;
    pub const FRAMEBUFFER_DEFAULT_LAYERS: ValueType = 0x9312;
    pub const FRAMEBUFFER_DEFAULT_SAMPLES: ValueType = 0x9313;
    pub const FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS: ValueType = 0x9314;
    pub const MAX_FRAMEBUFFER_WIDTH: ValueType = 0x9315;
    pub const MAX_FRAMEBUFFER_HEIGHT: ValueType = 0x9316;
    pub const MAX_FRAMEBUFFER_LAYERS: ValueType = 0x9317;
    pub const MAX_FRAMEBUFFER_SAMPLES: ValueType = 0x9318;
    pub const INTERNALFORMAT_SUPPORTED: ValueType = 0x826F;
    pub const INTERNALFORMAT_PREFERRED: ValueType = 0x8270;
    pub const INTERNALFORMAT_RED_SIZE: ValueType = 0x8271;
    pub const INTERNALFORMAT_GREEN_SIZE: ValueType = 0x8272;
    pub const INTERNALFORMAT_BLUE_SIZE: ValueType = 0x8273;
    pub const INTERNALFORMAT_ALPHA_SIZE: ValueType = 0x8274;
    pub const INTERNALFORMAT_DEPTH_SIZE: ValueType = 0x8275;
    pub const INTERNALFORMAT_STENCIL_SIZE: ValueType = 0x8276;
    pub const INTERNALFORMAT_SHARED_SIZE: ValueType = 0x8277;
    pub const INTERNALFORMAT_RED_TYPE: ValueType = 0x8278;
    pub const INTERNALFORMAT_GREEN_TYPE: ValueType = 0x8279;
    pub const INTERNALFORMAT_BLUE_TYPE: ValueType = 0x827A;
    pub const INTERNALFORMAT_ALPHA_TYPE: ValueType = 0x827B;
    pub const INTERNALFORMAT_DEPTH_TYPE: ValueType = 0x827C;
    pub const INTERNALFORMAT_STENCIL_TYPE: ValueType = 0x827D;
    pub const MAX_WIDTH: ValueType = 0x827E;
    pub const MAX_HEIGHT: ValueType = 0x827F;
    pub const MAX_DEPTH: ValueType = 0x8280;
    pub const MAX_LAYERS: ValueType = 0x8281;
    pub const MAX_COMBINED_DIMENSIONS: ValueType = 0x8282;
    pub const COLOR_COMPONENTS: ValueType = 0x8283;
    pub const DEPTH_COMPONENTS: ValueType = 0x8284;
    pub const STENCIL_COMPONENTS: ValueType = 0x8285;
    pub const COLOR_RENDERABLE: ValueType = 0x8286;
    pub const DEPTH_RENDERABLE: ValueType = 0x8287;
    pub const STENCIL_RENDERABLE: ValueType = 0x8288;
    pub const FRAMEBUFFER_RENDERABLE: ValueType = 0x8289;
    pub const FRAMEBUFFER_RENDERABLE_LAYERED: ValueType = 0x828A;
    pub const FRAMEBUFFER_BLEND: ValueType = 0x828B;
    pub const READ_PIXELS: ValueType = 0x828C;
    pub const READ_PIXELS_FORMAT: ValueType = 0x828D;
    pub const READ_PIXELS_TYPE: ValueType = 0x828E;
    pub const TEXTURE_IMAGE_FORMAT: ValueType = 0x828F;
    pub const TEXTURE_IMAGE_TYPE: ValueType = 0x8290;
    pub const GET_TEXTURE_IMAGE_FORMAT: ValueType = 0x8291;
    pub const GET_TEXTURE_IMAGE_TYPE: ValueType = 0x8292;
    pub const MIPMAP: ValueType = 0x8293;
    pub const MANUAL_GENERATE_MIPMAP: ValueType = 0x8294;
    pub const AUTO_GENERATE_MIPMAP: ValueType = 0x8295;
    pub const COLOR_ENCODING: ValueType = 0x8296;
    pub const SRGB_READ: ValueType = 0x8297;
    pub const SRGB_WRITE: ValueType = 0x8298;
    pub const FILTER: ValueType = 0x829A;
    pub const VERTEX_TEXTURE: ValueType = 0x829B;
    pub const TESS_CONTROL_TEXTURE: ValueType = 0x829C;
    pub const TESS_EVALUATION_TEXTURE: ValueType = 0x829D;
    pub const GEOMETRY_TEXTURE: ValueType = 0x829E;
    pub const FRAGMENT_TEXTURE: ValueType = 0x829F;
    pub const COMPUTE_TEXTURE: ValueType = 0x82A0;
    pub const TEXTURE_SHADOW: ValueType = 0x82A1;
    pub const TEXTURE_GATHER: ValueType = 0x82A2;
    pub const TEXTURE_GATHER_SHADOW: ValueType = 0x82A3;
    pub const SHADER_IMAGE_LOAD: ValueType = 0x82A4;
    pub const SHADER_IMAGE_STORE: ValueType = 0x82A5;
    pub const SHADER_IMAGE_ATOMIC: ValueType = 0x82A6;
    pub const IMAGE_TEXEL_SIZE: ValueType = 0x82A7;
    pub const IMAGE_COMPATIBILITY_CLASS: ValueType = 0x82A8;
    pub const IMAGE_PIXEL_FORMAT: ValueType = 0x82A9;
    pub const IMAGE_PIXEL_TYPE: ValueType = 0x82AA;
    pub const SIMULTANEOUS_TEXTURE_AND_DEPTH_TEST: ValueType = 0x82AC;
    pub const SIMULTANEOUS_TEXTURE_AND_STENCIL_TEST: ValueType = 0x82AD;
    pub const SIMULTANEOUS_TEXTURE_AND_DEPTH_WRITE: ValueType = 0x82AE;
    pub const SIMULTANEOUS_TEXTURE_AND_STENCIL_WRITE: ValueType = 0x82AF;
    pub const TEXTURE_COMPRESSED_BLOCK_WIDTH: ValueType = 0x82B1;
    pub const TEXTURE_COMPRESSED_BLOCK_HEIGHT: ValueType = 0x82B2;
    pub const TEXTURE_COMPRESSED_BLOCK_SIZE: ValueType = 0x82B3;
    pub const CLEAR_BUFFER: ValueType = 0x82B4;
    pub const TEXTURE_VIEW: ValueType = 0x82B5;
    pub const VIEW_COMPATIBILITY_CLASS: ValueType = 0x82B6;
    pub const FULL_SUPPORT: ValueType = 0x82B7;
    pub const CAVEAT_SUPPORT: ValueType = 0x82B8;
    pub const IMAGE_CLASS_4_X_32: ValueType = 0x82B9;
    pub const IMAGE_CLASS_2_X_32: ValueType = 0x82BA;
    pub const IMAGE_CLASS_1_X_32: ValueType = 0x82BB;
    pub const IMAGE_CLASS_4_X_16: ValueType = 0x82BC;
    pub const IMAGE_CLASS_2_X_16: ValueType = 0x82BD;
    pub const IMAGE_CLASS_1_X_16: ValueType = 0x82BE;
    pub const IMAGE_CLASS_4_X_8: ValueType = 0x82BF;
    pub const IMAGE_CLASS_2_X_8: ValueType = 0x82C0;
    pub const IMAGE_CLASS_1_X_8: ValueType = 0x82C1;
    pub const IMAGE_CLASS_11_11_10: ValueType = 0x82C2;
    pub const IMAGE_CLASS_10_10_10_2: ValueType = 0x82C3;
    pub const VIEW_CLASS_128_BITS: ValueType = 0x82C4;
    pub const VIEW_CLASS_96_BITS: ValueType = 0x82C5;
    pub const VIEW_CLASS_64_BITS: ValueType = 0x82C6;
    pub const VIEW_CLASS_48_BITS: ValueType = 0x82C7;
    pub const VIEW_CLASS_32_BITS: ValueType = 0x82C8;
    pub const VIEW_CLASS_24_BITS: ValueType = 0x82C9;
    pub const VIEW_CLASS_16_BITS: ValueType = 0x82CA;
    pub const VIEW_CLASS_8_BITS: ValueType = 0x82CB;
    pub const VIEW_CLASS_S3TC_DXT1_RGB: ValueType = 0x82CC;
    pub const VIEW_CLASS_S3TC_DXT1_RGBA: ValueType = 0x82CD;
    pub const VIEW_CLASS_S3TC_DXT3_RGBA: ValueType = 0x82CE;
    pub const VIEW_CLASS_S3TC_DXT5_RGBA: ValueType = 0x82CF;
    pub const VIEW_CLASS_RGTC1_RED: ValueType = 0x82D0;
    pub const VIEW_CLASS_RGTC2_RG: ValueType = 0x82D1;
    pub const VIEW_CLASS_BPTC_UNORM: ValueType = 0x82D2;
    pub const VIEW_CLASS_BPTC_FLOAT: ValueType = 0x82D3;
    pub const UNIFORM: ValueType = 0x92E1;
    pub const UNIFORM_BLOCK: ValueType = 0x92E2;
    pub const PROGRAM_INPUT: ValueType = 0x92E3;
    pub const PROGRAM_OUTPUT: ValueType = 0x92E4;
    pub const BUFFER_VARIABLE: ValueType = 0x92E5;
    pub const SHADER_STORAGE_BLOCK: ValueType = 0x92E6;
    pub const VERTEX_SUBROUTINE: ValueType = 0x92E8;
    pub const TESS_CONTROL_SUBROUTINE: ValueType = 0x92E9;
    pub const TESS_EVALUATION_SUBROUTINE: ValueType = 0x92EA;
    pub const GEOMETRY_SUBROUTINE: ValueType = 0x92EB;
    pub const FRAGMENT_SUBROUTINE: ValueType = 0x92EC;
    pub const COMPUTE_SUBROUTINE: ValueType = 0x92ED;
    pub const VERTEX_SUBROUTINE_UNIFORM: ValueType = 0x92EE;
    pub const TESS_CONTROL_SUBROUTINE_UNIFORM: ValueType = 0x92EF;
    pub const TESS_EVALUATION_SUBROUTINE_UNIFORM: ValueType = 0x92F0;
    pub const GEOMETRY_SUBROUTINE_UNIFORM: ValueType = 0x92F1;
    pub const FRAGMENT_SUBROUTINE_UNIFORM: ValueType = 0x92F2;
    pub const COMPUTE_SUBROUTINE_UNIFORM: ValueType = 0x92F3;
    pub const TRANSFORM_FEEDBACK_VARYING: ValueType = 0x92F4;
    pub const ACTIVE_RESOURCES: ValueType = 0x92F5;
    pub const MAX_NAME_LENGTH: ValueType = 0x92F6;
    pub const MAX_NUM_ACTIVE_VARIABLES: ValueType = 0x92F7;
    pub const MAX_NUM_COMPATIBLE_SUBROUTINES: ValueType = 0x92F8;
    pub const NAME_LENGTH: ValueType = 0x92F9;
    pub const TYPE: ValueType = 0x92FA;
    pub const ARRAY_SIZE: ValueType = 0x92FB;
    pub const OFFSET: ValueType = 0x92FC;
    pub const BLOCK_INDEX: ValueType = 0x92FD;
    pub const ARRAY_STRIDE: ValueType = 0x92FE;
    pub const MATRIX_STRIDE: ValueType = 0x92FF;
    pub const IS_ROW_MAJOR: ValueType = 0x9300;
    pub const ATOMIC_COUNTER_BUFFER_INDEX: ValueType = 0x9301;
    pub const BUFFER_BINDING: ValueType = 0x9302;
    pub const BUFFER_DATA_SIZE: ValueType = 0x9303;
    pub const NUM_ACTIVE_VARIABLES: ValueType = 0x9304;
    pub const ACTIVE_VARIABLES: ValueType = 0x9305;
    pub const REFERENCED_BY_VERTEX_SHADER: ValueType = 0x9306;
    pub const REFERENCED_BY_TESS_CONTROL_SHADER: ValueType = 0x9307;
    pub const REFERENCED_BY_TESS_EVALUATION_SHADER: ValueType = 0x9308;
    pub const REFERENCED_BY_GEOMETRY_SHADER: ValueType = 0x9309;
    pub const REFERENCED_BY_FRAGMENT_SHADER: ValueType = 0x930A;
    pub const REFERENCED_BY_COMPUTE_SHADER: ValueType = 0x930B;
    pub const TOP_LEVEL_ARRAY_SIZE: ValueType = 0x930C;
    pub const TOP_LEVEL_ARRAY_STRIDE: ValueType = 0x930D;
    pub const LOCATION: ValueType = 0x930E;
    pub const LOCATION_INDEX: ValueType = 0x930F;
    pub const IS_PER_PATCH: ValueType = 0x92E7;
    pub const SHADER_STORAGE_BUFFER: ValueType = 0x90D2;
    pub const SHADER_STORAGE_BUFFER_BINDING: ValueType = 0x90D3;
    pub const SHADER_STORAGE_BUFFER_START: ValueType = 0x90D4;
    pub const SHADER_STORAGE_BUFFER_SIZE: ValueType = 0x90D5;
    pub const MAX_VERTEX_SHADER_STORAGE_BLOCKS: ValueType = 0x90D6;
    pub const MAX_GEOMETRY_SHADER_STORAGE_BLOCKS: ValueType = 0x90D7;
    pub const MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS: ValueType = 0x90D8;
    pub const MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS: ValueType = 0x90D9;
    pub const MAX_FRAGMENT_SHADER_STORAGE_BLOCKS: ValueType = 0x90DA;
    pub const MAX_COMPUTE_SHADER_STORAGE_BLOCKS: ValueType = 0x90DB;
    pub const MAX_COMBINED_SHADER_STORAGE_BLOCKS: ValueType = 0x90DC;
    pub const MAX_SHADER_STORAGE_BUFFER_BINDINGS: ValueType = 0x90DD;
    pub const MAX_SHADER_STORAGE_BLOCK_SIZE: ValueType = 0x90DE;
    pub const SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT: ValueType = 0x90DF;
    pub const SHADER_STORAGE_BARRIER_BIT: ValueType = 0x00002000;
    pub const MAX_COMBINED_SHADER_OUTPUT_RESOURCES: ValueType = 0x8F39;
    pub const DEPTH_STENCIL_TEXTURE_MODE: ValueType = 0x90EA;
    pub const TEXTURE_BUFFER_OFFSET: ValueType = 0x919D;
    pub const TEXTURE_BUFFER_SIZE: ValueType = 0x919E;
    pub const TEXTURE_BUFFER_OFFSET_ALIGNMENT: ValueType = 0x919F;
    pub const TEXTURE_VIEW_MIN_LEVEL: ValueType = 0x82DB;
    pub const TEXTURE_VIEW_NUM_LEVELS: ValueType = 0x82DC;
    pub const TEXTURE_VIEW_MIN_LAYER: ValueType = 0x82DD;
    pub const TEXTURE_VIEW_NUM_LAYERS: ValueType = 0x82DE;
    pub const TEXTURE_IMMUTABLE_LEVELS: ValueType = 0x82DF;
    pub const VERTEX_ATTRIB_BINDING: ValueType = 0x82D4;
    pub const VERTEX_ATTRIB_RELATIVE_OFFSET: ValueType = 0x82D5;
    pub const VERTEX_BINDING_DIVISOR: ValueType = 0x82D6;
    pub const VERTEX_BINDING_OFFSET: ValueType = 0x82D7;
    pub const VERTEX_BINDING_STRIDE: ValueType = 0x82D8;
    pub const MAX_VERTEX_ATTRIB_RELATIVE_OFFSET: ValueType = 0x82D9;
    pub const MAX_VERTEX_ATTRIB_BINDINGS: ValueType = 0x82DA;
    pub const VERTEX_BINDING_BUFFER: ValueType = 0x8F4F;
    pub const DISPLAY_LIST: ValueType = 0x82E7;
    pub const STACK_UNDERFLOW: ValueType = 0x0504;
    pub const STACK_OVERFLOW: ValueType = 0x0503;
    pub const MAX_VERTEX_ATTRIB_STRIDE: ValueType = 0x82E5;
    pub const PRIMITIVE_RESTART_FOR_PATCHES_SUPPORTED: ValueType = 0x8221;
    pub const TEXTURE_BUFFER_BINDING: ValueType = 0x8C2A;
    pub const MAP_PERSISTENT_BIT: ValueType = 0x0040;
    pub const MAP_COHERENT_BIT: ValueType = 0x0080;
    pub const DYNAMIC_STORAGE_BIT: ValueType = 0x0100;
    pub const CLIENT_STORAGE_BIT: ValueType = 0x0200;
    pub const CLIENT_MAPPED_BUFFER_BARRIER_BIT: ValueType = 0x00004000;
    pub const BUFFER_IMMUTABLE_STORAGE: ValueType = 0x821F;
    pub const BUFFER_STORAGE_FLAGS: ValueType = 0x8220;
    pub const CLEAR_TEXTURE: ValueType = 0x9365;
    pub const LOCATION_COMPONENT: ValueType = 0x934A;
    pub const TRANSFORM_FEEDBACK_BUFFER_INDEX: ValueType = 0x934B;
    pub const TRANSFORM_FEEDBACK_BUFFER_STRIDE: ValueType = 0x934C;
    pub const QUERY_BUFFER: ValueType = 0x9192;
    pub const QUERY_BUFFER_BARRIER_BIT: ValueType = 0x00008000;
    pub const QUERY_BUFFER_BINDING: ValueType = 0x9193;
    pub const QUERY_RESULT_NO_WAIT: ValueType = 0x9194;
    pub const MIRROR_CLAMP_TO_EDGE: ValueType = 0x8743;
    pub const CONTEXT_LOST: ValueType = 0x0507;
    pub const NEGATIVE_ONE_TO_ONE: ValueType = 0x935E;
    pub const ZERO_TO_ONE: ValueType = 0x935F;
    pub const CLIP_ORIGIN: ValueType = 0x935C;
    pub const CLIP_DEPTH_MODE: ValueType = 0x935D;
    pub const QUERY_WAIT_INVERTED: ValueType = 0x8E17;
    pub const QUERY_NO_WAIT_INVERTED: ValueType = 0x8E18;
    pub const QUERY_BY_REGION_WAIT_INVERTED: ValueType = 0x8E19;
    pub const QUERY_BY_REGION_NO_WAIT_INVERTED: ValueType = 0x8E1A;
    pub const MAX_CULL_DISTANCES: ValueType = 0x82F9;
    pub const MAX_COMBINED_CLIP_AND_CULL_DISTANCES: ValueType = 0x82FA;
    pub const TEXTURE_TARGET: ValueType = 0x1006;
    pub const QUERY_TARGET: ValueType = 0x82EA;
    pub const GUILTY_CONTEXT_RESET: ValueType = 0x8253;
    pub const INNOCENT_CONTEXT_RESET: ValueType = 0x8254;
    pub const UNKNOWN_CONTEXT_RESET: ValueType = 0x8255;
    pub const RESET_NOTIFICATION_STRATEGY: ValueType = 0x8256;
    pub const LOSE_CONTEXT_ON_RESET: ValueType = 0x8252;
    pub const NO_RESET_NOTIFICATION: ValueType = 0x8261;
    pub const CONTEXT_FLAG_ROBUST_ACCESS_BIT: ValueType = 0x00000004;
    pub const COLOR_TABLE: ValueType = 0x80D0;
    pub const POST_CONVOLUTION_COLOR_TABLE: ValueType = 0x80D1;
    pub const POST_COLOR_MATRIX_COLOR_TABLE: ValueType = 0x80D2;
    pub const PROXY_COLOR_TABLE: ValueType = 0x80D3;
    pub const PROXY_POST_CONVOLUTION_COLOR_TABLE: ValueType = 0x80D4;
    pub const PROXY_POST_COLOR_MATRIX_COLOR_TABLE: ValueType = 0x80D5;
    pub const CONVOLUTION_1D: ValueType = 0x8010;
    pub const CONVOLUTION_2D: ValueType = 0x8011;
    pub const SEPARABLE_2D: ValueType = 0x8012;
    pub const HISTOGRAM: ValueType = 0x8024;
    pub const PROXY_HISTOGRAM: ValueType = 0x8025;
    pub const MINMAX: ValueType = 0x802E;
    pub const CONTEXT_RELEASE_BEHAVIOR: ValueType = 0x82FB;
    pub const CONTEXT_RELEASE_BEHAVIOR_FLUSH: ValueType = 0x82FC;
};

///////////////////////////////////////////////////////////////////////////////

/// Null terminate `source` into `dest` buffer, potentially clamping it to fit.
fn copyZ(dest: []u8, source: []const u8) [:0]const u8 {
    std.mem.copy(u8, dest, if (source.len > dest.len) source[0 .. dest.len - 1] else source);
    var slice: []u8 = dest[0..if (source.len > dest.len) dest.len else source.len + 1];
    dest[slice.len - 1] = 0;

    var a = slice[0 .. slice.len - 1 :0];
    return a;
}
