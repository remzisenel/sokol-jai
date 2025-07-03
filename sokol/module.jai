// we don't technically need to import all of these, so if it becomes a problem we can add module parameters or something

app :: #import,dir "app";
audio :: #import,dir "audio";
debugtext :: #import,dir "debugtext";
fontstash :: #import,dir "fontstash";
gfx :: #import,dir "gfx";
gl :: #import,dir "gl";
glue :: #import,dir "glue";
imgui :: #import,dir "imgui";
log :: #import,dir "log";
shape :: #import,dir "shape";
spine :: #import,dir "spine";
time :: #import,dir "time";

#if OS == .MACOS || OS == .IOS {
    // clang compiler generates calls to __isPlatformVersionAtLeast() when Objective-C's @available
    // function is invoked. @available instruction is used within sokol in multiple locations, especially
    // for figuring out Metal backend capabilities. This results in undefined symbol errors as we don't
    // have clang-rt available.
    //
    // The following solution is ported from zig compiler
    //
    // https://github.com/ziglang/zig/pull/10232/files#diff-273822c0bc75bbaa3289f4ff577c35e2de1a9fab721e19cd9e5cf3ae436486f3
    //
    // which in turn was ported from llvm-project 13.0.0 d7b669b3a30345cfcdb2fde2af6f48aa4b94845d
    //
    // https://github.com/llvm/llvm-project/blob/llvmorg-13.0.0/compiler-rt/lib/builtins/os_version_check.c
    //
    // Old versions of clang would instead emit calls to __isOSVersionAtLeast(), which is still
    // supported in clang's compiler-rt implementation today in case anyone tries to link an object file
    // produced with an old clang version. However, this requires dynamically loading frameworks, parsing a
    // system plist file, and generally adds a fair amount of complexity to the implementation and so
    // our implementation differs by simply removing that backwards compatability support. We only use
    // the newer codepath, which merely calls out to the Darwin _availability_version_check API which is
    // available on macOS 10.15+, iOS 13+, tvOS 13+ and watchOS 6+.

    dyld_platform_t :: u32;
    dyld_build_version_t :: struct {
        platform: dyld_platform_t;
        version: u32;
    };

    #program_export
    __isPlatformVersionAtLeast :: (platform: u32, major: u32, minor: u32, subminor: u32) -> s32 #c_call {
        ver := dyld_build_version_t.{
            platform = platform,
            version = ((major & 0xffff) << 16) | ((minor & 0xff) << 8) | (subminor & 0xff),
        };
        return xx _availability_version_check(1, *ver);
    }

    _availability_version_check :: (count: u32, versions: *dyld_build_version_t) -> bool #foreign libc;

    libc :: #system_library "libc";
}

