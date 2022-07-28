# (incomplete) Zig Imgui bindings
Bindings in zig for [Dear ImGui](https://github.com/ocornut/imgui). These are hand written and incomplete for now, while I work on a c++ parser in a side project.
## Usage
For complete example, see usage in [zig-imgui-template](https://github.com/dumheter/zig-imgui-template/tree/zimgui).
### Backend
Imgui doesnt do much on it own, it relies on a backend to handle rendering, and something to handle windows (and more). This repro has some code prepared for OpenGL3 as backend, and Glfw to handle windowing, via `addBackendGlfwOpenGl3`.
### Example

``` zig
const zimgui = @import("deps/zimgui/build.zig");

pub fn build(b: *Builder) void {
    var exe = ...;

    exe.addPackagePath("zimgui", "deps/zimgui/src/zimgui.zig");
    _ = zimgui.link(b, exe);

    exe.addPackagePath("zimgui_backend", "deps/zimgui/src/backend_glfw_opengl3.zig");
    addBackendGlfwOpenGl3(b, exe);

    ...
}
```
