const std = @import("std");

pub const target_query: std.Target.Query = .{
    .cpu_arch = .x86,
    .cpu_model = .{
        .explicit = &std.Target.x86.cpu.pentium3,
    },
    .os_tag = .windows,
};

var nxdk_dep: *std.Build.Dependency = undefined;
var extract_xiso_dep: *std.Build.Dependency = undefined;

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(target_query);
    const optimize = b.standardOptimizeOption(.{});

    nxdk_dep = b.dependency("nxdk", .{});
    extract_xiso_dep = b.dependency("extract-xiso", .{});
    const cxbe_exe = try buildCXBEBin(b, optimize);
    b.installArtifact(cxbe_exe);
    const extract_xiso_exe = try buildExtractXISOBin(b, optimize);
    b.installArtifact(extract_xiso_exe);

    const xboxkrnl_lib_path = genKernelLib(b);
    const xboxkrnl_mod = b.addModule("xboxkrnl", .{
        .root_source_file = b.path("src/xboxkrnl/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    xboxkrnl_mod.addObjectFile(xboxkrnl_lib_path);

    const libpdclib = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libpdclib",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                    "lib/xboxrt/vcruntime",
                    "lib/xboxrt/libc_extensions",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = &.{
                    "functions",
                    "platform/xbox",
                },
                .iter_paths = null,
            },
        },
    });
    _ = libpdclib;

    const libnxdk = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libnxdk",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/nxdk",
                    "lib/winapi",
                    "lib/net/nforceif/include",
                    "lib/xboxrt/vcruntime",
                },
                .walker_paths = null,
                .iter_paths = &.{
                    "lib/nxdk",
                },
            },
            .{
                .name = "lwip",
                .include_paths = &.{
                    "src/include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    _ = libnxdk;

    const libnxdk_hal = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libnxdk_hal",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                },
                .walker_paths = null,
                .iter_paths = &.{
                    "lib/hal",
                },
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    const nxdk_hal_mod = b.addModule("nxdk_hal", .{
        .root_source_file = b.path("src/hal/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "xboxkrnl",
            .module = xboxkrnl_mod,
        }},
    });
    nxdk_hal_mod.linkLibrary(libnxdk_hal);

    const libxboxrt = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libxboxrt",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                    "lib/xboxrt",
                    "lib/xboxrt/libc_extensions",
                    "lib/xboxrt/c_runtime",
                    "lib/xboxrt/vcruntime",
                },
                .walker_paths = &.{
                    "lib/xboxrt",
                },
                .iter_paths = null,
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    const libxboxrt_mod = b.addModule("xboxrt", .{
        .root_source_file = b.path("src/xboxrt/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "xboxkrnl",
            .module = xboxkrnl_mod,
        }},
    });
    libxboxrt_mod.linkLibrary(libxboxrt);

    const libpbkit = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libpbkit",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                },
                .walker_paths = null,
                .iter_paths = &.{
                    "lib/pbkit",
                },
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    const libpbkit_mod = b.addModule("pbkit", .{
        .root_source_file = b.path("src/pbkit/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "xboxkrnl",
            .module = xboxkrnl_mod,
        }},
    });
    libpbkit_mod.linkLibrary(libpbkit);

    // const libjpeg = try buildLib(.{
    //     .b = b,
    //     .target = target,
    //     .optimize = optimize,
    //     .lib_name = "libjpeg",
    //     .lib_deps = &.{
    //         .{
    //             .name = "libjpeg-turbo",
    //             .include_paths = &.{
    //                 ".",
    //             },
    //             .walker_paths = null,
    //             .iter_paths = &.{
    //                 ".",
    //             },
    //         },
    //         .{
    //             .name = "nxdk",
    //             .include_paths = &.{
    //                 "lib/libjpeg",
    //             },
    //             .walker_paths = null,
    //             .iter_paths = null,
    //         },
    //         .{
    //             .name = "nxdk-pdclib",
    //             .include_paths = &.{
    //                 "platform/xbox/include",
    //                 "include",
    //             },
    //             .walker_paths = null,
    //             .iter_paths = null,
    //         },
    //     },
    // });
    // _ = libjpeg;

    const winmm = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "winmm",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                    "lib/winapi/winmm",
                },
                .walker_paths = null,
                .iter_paths = &.{
                    "lib/winapi/winmm",
                },
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    _ = winmm;

    const libwinapi = try buildLib(.{
        .b = b,
        .target = target,
        .optimize = optimize,
        .lib_name = "libwinapi",
        .lib_deps = &.{
            .{
                .name = "nxdk",
                .include_paths = &.{
                    "lib",
                    "lib/winapi",
                    "lib/xboxrt/vcruntime",
                },
                .walker_paths = null,
                .iter_paths = &.{
                    "lib/winapi",
                },
            },
            .{
                .name = "nxdk-pdclib",
                .include_paths = &.{
                    "platform/xbox/include",
                    "include",
                },
                .walker_paths = null,
                .iter_paths = null,
            },
        },
    });
    const libwinapi_mod = b.addModule("winapi", .{
        .root_source_file = b.path("src/winapi/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "xboxkrnl",
                .module = xboxkrnl_mod,
            },
            .{
                .name = "xboxrt",
                .module = libxboxrt_mod,
            },
        },
    });
    libwinapi_mod.linkLibrary(libwinapi);
    libxboxrt_mod.addImport("winapi", libwinapi_mod);

    const mod_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test.zig"),
            .target = b.graph.host,
            .optimize = optimize,
        }),
        .use_llvm = true,
        .use_lld = true,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

pub fn setupExe(b: *std.Build, optimize: std.builtin.OptimizeMode, exe: *std.Build.Step.Compile) !void {
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;
    exe.subsystem = .windows;
    exe.entry = .{ .symbol_name = "WinMainCRTStartup" };
    exe.root_module.resolved_target = b.resolveTargetQuery(target_query);

    const this = b.dependencyFromBuildZig(@This(), .{
        .optimize = optimize,
    });

    exe.root_module.linkLibrary(this.artifact("libpdclib"));
    exe.root_module.linkLibrary(this.artifact("libnxdk"));
    // exe.root_module.linkLibrary(this.artifact("libnxdk_hal"));
    // exe.root_module.linkLibrary(this.artifact("libwinapi"));
    exe.root_module.linkLibrary(this.artifact("libxboxrt"));
    exe.root_module.linkLibrary(this.artifact("libpbkit"));
    exe.root_module.linkLibrary(this.artifact("winmm"));

    // exe.root_module.addObjectFile(this.namedLazyPath("libxboxkrnl").path(b, "libxboxkrnl.lib"));

    const convert_step = try convertEXE(b, optimize, &exe.step, exe.name, exe.getEmittedBin());
    try createXISO(b, optimize, convert_step, exe.name);
}

fn convertEXE(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    prevoius_step: *std.Build.Step,
    app_title: []const u8,
    app_path: std.Build.LazyPath,
) !*std.Build.Step {
    const cxbe_exe = try buildCXBEBin(b, optimize);
    const cmd = std.Build.Step.Run.create(b, b.fmt("run cxbe_exe", .{}));
    cmd.addArtifactArg(cxbe_exe);
    const xbe = cmd.addPrefixedOutputFileArg("-OUT:", b.fmt("{s}.xbe", .{app_title}));
    cmd.addArg(b.fmt("-TITLE:{s}", .{app_title}));
    cmd.setCwd(b.path("."));
    cmd.addFileArg(app_path);
    cmd.expectExitCode(0);
    cmd.has_side_effects = true;
    cmd.step.dependOn(&cxbe_exe.step);
    cmd.step.dependOn(prevoius_step);

    const install_xbe = b.addInstallFileWithDir(
        xbe,
        .{ .custom = b.fmt("xbin/{s}", .{app_title}) },
        "default.xbe",
    );
    install_xbe.step.dependOn(&cmd.step);

    return &install_xbe.step;
}

fn createXISO(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    prevoius_step: *std.Build.Step,
    app_title: []const u8,
) !void {
    const extract_xiso_exe = try buildExtractXISOBin(b, optimize);
    const cmd = std.Build.Step.Run.create(b, b.fmt("run cxbe_exe", .{}));
    cmd.addArtifactArg(extract_xiso_exe);
    cmd.addArgs(&.{
        "-c",
        b.fmt("zig-out/xbin/{s}", .{app_title}),
        b.fmt("zig-out/{s}.iso", .{app_title}),
    });
    cmd.setCwd(b.path("."));
    cmd.expectExitCode(0);
    cmd.has_side_effects = true;
    cmd.step.dependOn(&extract_xiso_exe.step);
    cmd.step.dependOn(prevoius_step);

    b.getInstallStep().dependOn(&cmd.step);
}

fn buildLib(info: LibInfo) !*std.Build.Step.Compile {
    const lib = info.b.addLibrary(.{
        .name = info.lib_name,
        .root_module = info.b.createModule(.{
            .target = info.target,
            .optimize = info.optimize,
            .sanitize_c = .off,
        }),
    });
    info.b.installArtifact(lib);
    lib.image_base = 0x0001_0000;
    lib.stack_size = 65536;
    lib.subsystem = .windows;

    for (info.lib_deps) |lib_dep| {
        const dep = info.b.dependency(lib_dep.name, .{});

        for (lib_dep.include_paths) |path| {
            lib.root_module.addIncludePath(dep.path(path));
            lib.installHeadersDirectory(dep.path(path), "", .{});
        }

        if (lib_dep.walker_paths) |paths| {
            for (paths) |path| {
                try gatherCFilesWalker(info.b, dep, path, lib, null);
            }
        }
        if (lib_dep.iter_paths) |paths| {
            for (paths) |path| {
                try gatherCFilesIter(info.b, dep, path, lib, null);
            }
        }
    }

    return lib;
}

fn genKernelLib(b: *std.Build) std.Build.LazyPath {
    const dll_tool_cmd = b.addSystemCommand(&.{
        b.graph.zig_exe, "dlltool", "-m", "i386", "-l", ".zig-cache/libxboxkrnl.lib", "-k", "-d",
    });
    dll_tool_cmd.expectExitCode(0);
    dll_tool_cmd.addFileArg(b.dependency("nxdk", .{}).path("lib/xboxkrnl/xboxkrnl.exe.def"));
    dll_tool_cmd.setCwd(b.path("."));

    // b.addNamedLazyPath("libxboxkrnl", b.path(".zig-cache"));
    const install_kernellib = b.addInstallLibFile(
        b.path(".zig-cache/libxboxkrnl.lib"),
        "libxboxkrnl.lib",
    );
    install_kernellib.step.dependOn(&dll_tool_cmd.step);
    b.getInstallStep().dependOn(&install_kernellib.step);

    return b.path(".zig-cache/libxboxkrnl.lib");
}

fn buildCXBEBin(b: *std.Build, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "cxbe",
        .root_module = b.createModule(.{
            .target = b.graph.host,
            .optimize = optimize,
            .sanitize_c = .off,
            .link_libcpp = true,
        }),
    });
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;

    exe.root_module.addIncludePath(nxdk_dep.path("tools/cxbe"));
    try gatherCPPFilesIter(b, nxdk_dep, "tools/cxbe", exe, &.{});

    return exe;
}

fn buildExtractXISOBin(b: *std.Build, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "extract-xiso",
        .root_module = b.createModule(.{
            .target = b.graph.host,
            .optimize = optimize,
            .sanitize_c = .off,
            .link_libc = true,
        }),
    });
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;

    try gatherCFilesIter(b, extract_xiso_dep, ".", exe, &.{
        switch (b.graph.host.result.os.tag) {
            .macos => "-D__DARWIN__",
            .linux => "-D__LINUX__",
            .openbsd => "-D__OPENBSD__",
            .windows => "-D_WIN32",
            .freebsd => "-D__FREEBSD__",
            else => "",
        },
    });

    return exe;
}

fn gatherCFilesWalker(
    b: *std.Build,
    dep: *std.Build.Dependency,
    path: []const u8,
    lib: *std.Build.Step.Compile,
    custom_flags: ?[]const []const u8,
) !void {
    const dep_path = try dep.path(path).getPath4(b, null);
    var dir = try dep_path.openDir(b.graph.io, ".", .{ .iterate = true });
    defer dir.close(b.graph.io);

    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    while (try walker.next(b.graph.io)) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        if (std.mem.endsWith(u8, entry.basename, ".c")) {
            lib.root_module.addCSourceFile(.{
                .language = .c,
                .file = dep.path(b.pathJoin(&.{ path, entry.path })),
                .flags = if (custom_flags) |cf|
                    cf
                else
                    c_flags,
            });
        } else if (std.mem.endsWith(u8, entry.basename, ".s")) {
            lib.root_module.addCSourceFile(.{
                .language = .assembly,
                .file = dep.path(b.pathJoin(&.{ path, entry.path })),
                .flags = asm_flags,
            });
        }
    }
}

fn gatherCFilesIter(
    b: *std.Build,
    dep: *std.Build.Dependency,
    path: []const u8,
    lib: *std.Build.Step.Compile,
    custom_flags: ?[]const []const u8,
) !void {
    const dep_path = try dep.path(path).getPath4(b, null);
    var dir = try dep_path.openDir(b.graph.io, ".", .{ .iterate = true });
    defer dir.close(b.graph.io);

    var iter = dir.iterate();
    while (try iter.next(b.graph.io)) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        if (std.mem.endsWith(u8, entry.name, ".c")) {
            lib.root_module.addCSourceFile(.{
                .language = .c,
                .file = dep.path(b.pathJoin(&.{ path, entry.name })),
                .flags = if (custom_flags) |cf|
                    cf
                else
                    c_flags,
            });
        } else if (std.mem.endsWith(u8, entry.name, ".s")) {
            lib.root_module.addCSourceFile(.{
                .language = .assembly,
                .file = dep.path(b.pathJoin(&.{ path, entry.name })),
                .flags = asm_flags,
            });
        }
    }
}

fn gatherCPPFilesIter(
    b: *std.Build,
    dep: *std.Build.Dependency,
    path: []const u8,
    lib: *std.Build.Step.Compile,
    custom_flags: ?[]const []const u8,
) !void {
    const dep_path = try dep.path(path).getPath4(b, null);
    var dir = try dep_path.openDir(b.graph.io, ".", .{ .iterate = true });
    defer dir.close(b.graph.io);

    var iter = dir.iterate();
    while (try iter.next(b.graph.io)) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        if (std.mem.endsWith(u8, entry.name, ".cpp")) {
            lib.root_module.addCSourceFile(.{
                .language = .cpp,
                .file = dep.path(b.pathJoin(&.{ path, entry.name })),
                .flags = if (custom_flags) |cf|
                    cf
                else
                    cpp_flags,
            });
        } else if (std.mem.endsWith(u8, entry.name, ".s")) {
            lib.root_module.addCSourceFile(.{
                .language = .assembly,
                .file = dep.path(b.pathJoin(&.{ path, entry.name })),
                .flags = asm_flags,
            });
        }
    }
}

const LibInfo = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    // nxdk_dep: *std.Build.Dependency,
    // nxdk_dep_include_paths: []const []const u8,
    lib_name: []const u8,
    lib_deps: []const struct {
        name: []const u8,
        include_paths: []const []const u8,
        walker_paths: ?[]const []const u8,
        iter_paths: ?[]const []const u8,
    },
};

pub const asm_flags: []const []const u8 = &.{
    "-target", "i386-pc-win32",
};

pub const c_flags: []const []const u8 = &.{
    "-target",
    "i386-pc-win32",
    "-ffreestanding",
    "-nostdlib",
    "-fno-builtin",
    "-Wno-builtin-macro-redefined",
    "-DNXDK",
    "-D__STDC__=1",
    "-U__STDC_NO_THREADS__",

    "-fshort-wchar",
    "-fdeclspec",
    "-fms-extensions",
    "-Wno-ignored-attributes",
};

pub const cpp_flags: []const []const u8 = &.{
    "-target",
    "i386-pc-win32",
    "-ffreestanding",
    "-nostdlib",
    "-fno-builtin",
    "-Wno-builtin-macro-redefined",
    "-DNXDK",
    "-D__STDC__=1",
    "-U__STDC_NO_THREADS__",
    "-fno-exceptions",

    "-fshort-wchar",
    "-fdeclspec",
    "-fms-extensions",
    "-Wno-ignored-attributes",
};
