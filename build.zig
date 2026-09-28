const std = @import("std");

pub const target_query: std.Target.Query = .{
    .cpu_arch = .x86,
    .cpu_model = .{
        .explicit = &std.Target.x86.cpu.pentium3,
    },
    .os_tag = .windows,
};

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(target_query);
    const optimize = b.standardOptimizeOption(.{});

    const panic_mod = b.addModule("panic", .{
        .root_source_file = b.path("src/panic.zig"),
        .target = target,
        .optimize = optimize,
    });

    const nxdk_dep = b.dependency("nxdk", .{});
    const cxbe_exe = try buildCXBEBin(b, optimize, nxdk_dep);
    b.installArtifact(cxbe_exe);

    const extract_xiso_dep = b.dependency("extract-xiso", .{});
    const extract_xiso_exe = try buildExtractXISOBin(b, optimize, extract_xiso_dep);
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
    const pdclib_mod = b.addModule("pdclib", .{
        .root_source_file = b.path("src/pdclib/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    pdclib_mod.linkLibrary(libpdclib);

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
    const nxdk_mod = b.addModule("nxdk", .{
        .root_source_file = b.path("src/nxdk/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    nxdk_mod.linkLibrary(libnxdk);

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
    panic_mod.addImport("nxdk_hal", nxdk_hal_mod);

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
    const xboxrt_mod = b.addModule("xboxrt", .{
        .root_source_file = b.path("src/xboxrt/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "xboxkrnl",
            .module = xboxkrnl_mod,
        }},
    });
    xboxrt_mod.linkLibrary(libxboxrt);

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
    const pbkit_mod = b.addModule("pbkit", .{
        .root_source_file = b.path("src/pbkit/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "xboxkrnl",
            .module = xboxkrnl_mod,
        }},
    });
    pbkit_mod.linkLibrary(libpbkit);

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

    const libwinmm = try buildLib(.{
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
    const winmm_mod = b.addModule("winmm", .{
        .root_source_file = b.path("src/winmm/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    winmm_mod.linkLibrary(libwinmm);

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
    const winapi_mod = b.addModule("winapi", .{
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
                .module = xboxrt_mod,
            },
        },
    });
    winapi_mod.linkLibrary(libwinapi);
    xboxrt_mod.addImport("winapi", winapi_mod);

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

    const example_step = b.step("examples", "Build the examples");
    const examples: []const []const u8 = &.{
        "hello", "gamma", "gamma-fade", "led", "triangle",
    };
    for (examples) |name| {
        try buildExample(b, target, optimize, example_step, name, .{
            .panic = panic_mod,
            .pdclib = pdclib_mod,
            .nxdk = nxdk_mod,
            .xboxrt = xboxrt_mod,
            .winmm = winmm_mod,
            .xboxkrnl = xboxkrnl_mod,
            .nxdk_hal = nxdk_hal_mod,
            .winapi = winapi_mod,
            .pbkit = pbkit_mod,
        });
    }
}

pub fn setupExe(nxdk_zig_dep: *std.Build.Dependency, b: *std.Build, optimize: std.builtin.OptimizeMode, exe: *std.Build.Step.Compile) !void {
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;
    exe.subsystem = .windows;
    exe.entry = .{ .symbol_name = "WinMainCRTStartup" };
    exe.root_module.resolved_target = b.resolveTargetQuery(target_query);
    exe.root_module.single_threaded = true;

    const nxdk_dep = nxdk_zig_dep.builder.dependency("nxdk", .{});
    const convert_step = try convertEXE(b, optimize, &exe.step, nxdk_dep, exe.name, exe.getEmittedBin(), ".");

    const extract_xiso_dep = nxdk_zig_dep.builder.dependency("extract-xiso", .{});
    const create_xiso = try createXISO(b, optimize, convert_step, extract_xiso_dep, exe.name, ".");

    b.getInstallStep().dependOn(create_xiso);
}

fn convertEXE(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    prevoius_step: *std.Build.Step,
    nxdk_dep: *std.Build.Dependency,
    app_title: []const u8,
    app_path: std.Build.LazyPath,
    output_path: []const u8,
) !*std.Build.Step {
    const cxbe_exe = try buildCXBEBin(b, optimize, nxdk_dep);
    const cmd = std.Build.Step.Run.create(b, b.fmt("run cxbe_exe", .{}));
    cmd.addArtifactArg(cxbe_exe);
    const xbe = cmd.addPrefixedOutputFileArg("-OUT:", b.fmt("{s}.xbe", .{app_title}));
    cmd.addArg(b.fmt("-TITLE:{s}", .{app_title}));
    cmd.addArg(b.fmt("-MODE:{s}", .{if (optimize == .Debug) "debug" else "retail"}));
    cmd.setCwd(b.path("."));
    cmd.addFileArg(app_path);
    cmd.expectExitCode(0);
    cmd.has_side_effects = true;
    cmd.step.dependOn(&cxbe_exe.step);
    cmd.step.dependOn(prevoius_step);

    const install_xbe = b.addInstallFileWithDir(
        xbe,
        .{ .custom = b.fmt("{s}/xbin/{s}", .{ output_path, app_title }) },
        "default.xbe",
    );
    install_xbe.step.dependOn(&cmd.step);

    return &install_xbe.step;
}

fn createXISO(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    prevoius_step: *std.Build.Step,
    extract_xiso_dep: *std.Build.Dependency,
    app_title: []const u8,
    output_path: []const u8,
) !*std.Build.Step {
    const extract_xiso_exe = try buildExtractXISOBin(b, optimize, extract_xiso_dep);
    const cmd = std.Build.Step.Run.create(b, b.fmt("run cxbe_exe", .{}));
    cmd.addArtifactArg(extract_xiso_exe);
    cmd.addArgs(&.{
        "-c",
        b.fmt("zig-out/{s}/xbin/{s}", .{ output_path, app_title }),
        b.fmt("zig-out/{s}/{s}.iso", .{ output_path, app_title }),
    });
    cmd.setCwd(b.path("."));
    cmd.expectExitCode(0);
    cmd.has_side_effects = true;
    cmd.step.dependOn(&extract_xiso_exe.step);
    cmd.step.dependOn(prevoius_step);

    return &cmd.step;
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

fn buildCXBEBin(b: *std.Build, optimize: std.builtin.OptimizeMode, nxdk_dep: *std.Build.Dependency) !*std.Build.Step.Compile {
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

fn buildExtractXISOBin(b: *std.Build, optimize: std.builtin.OptimizeMode, extract_xiso_dep: *std.Build.Dependency) !*std.Build.Step.Compile {
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

fn buildExample(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    example_step: *std.Build.Step,
    name: []const u8,
    example_deps: struct {
        panic: *std.Build.Module,
        pdclib: *std.Build.Module,
        nxdk: *std.Build.Module,
        xboxrt: *std.Build.Module,
        winmm: *std.Build.Module,
        xboxkrnl: *std.Build.Module,
        nxdk_hal: *std.Build.Module,
        winapi: *std.Build.Module,
        pbkit: *std.Build.Module,
    },
) !void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("examples/{s}/main.zig", .{name})),
            .target = target,
            .optimize = optimize,
            .single_threaded = true,
        }),
    });
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;
    exe.subsystem = .windows;
    exe.entry = .{ .symbol_name = "WinMainCRTStartup" };
    exe.root_module.resolved_target = b.resolveTargetQuery(target_query);
    const install_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "examples/bin" } },
        .pdb_dir = .{ .override = .{ .custom = "examples/bin" } },
    });

    exe.root_module.addImport("panic", example_deps.panic);
    exe.root_module.addImport("pdclib", example_deps.pdclib);
    exe.root_module.addImport("nxdk", example_deps.nxdk);
    exe.root_module.addImport("xboxrt", example_deps.xboxrt);
    exe.root_module.addImport("winmm", example_deps.winmm);
    exe.root_module.addImport("xboxkrnl", example_deps.xboxkrnl);
    exe.root_module.addImport("nxdk_hal", example_deps.nxdk_hal);
    exe.root_module.addImport("winapi", example_deps.winapi);
    exe.root_module.addImport("pbkit", example_deps.pbkit);

    const nxdk_dep = b.dependency("nxdk", .{});
    const convert_step = try convertEXE(b, optimize, &install_exe.step, nxdk_dep, exe.name, exe.getEmittedBin(), "examples");

    const extract_xiso_dep = b.dependency("extract-xiso", .{});
    const create_xiso = try createXISO(b, optimize, convert_step, extract_xiso_dep, exe.name, "examples");

    example_step.dependOn(create_xiso);
}

const LibInfo = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
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
