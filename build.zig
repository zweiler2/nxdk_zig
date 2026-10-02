const std = @import("std");

pub const target_query: std.Target.Query = .{
    .cpu_arch = .x86,
    .cpu_model = .{
        .explicit = &std.Target.x86.cpu.pentium3,
    },
    .os_tag = .windows,
    .abi = .msvc,
};

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(target_query);
    const optimize = b.standardOptimizeOption(.{});

    const lto = b.option(std.zig.LtoMode, "lto", "LTO mode for the libraries/examples");

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
        .lto = lto,
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
        .lto = lto,
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
        .lto = lto,
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
        .lto = lto,
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
        .lto = lto,
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
        .lto = lto,
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
        .lto = lto,
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
        try buildExample(b, optimize, example_step, name, lto, .{
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

pub fn createExe(
    nxdk_zig_dep: *std.Build.Dependency,
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    user_root_source_file: std.Build.LazyPath,
    /// NOTE: LTO on Debug builds disables `bundle_ubsan_rt`
    lto: ?std.zig.LtoMode,
) !*std.Build.Step.Compile {
    return createExeWithModules(b, optimize, name, user_root_source_file, nxdk_zig_dep.path("src/start/start.zig"), lto, .{
        .pdclib = nxdk_zig_dep.module("pdclib"),
        .nxdk = nxdk_zig_dep.module("nxdk"),
        .xboxrt = nxdk_zig_dep.module("xboxrt"),
        .winmm = nxdk_zig_dep.module("winmm"),
        .xboxkrnl = nxdk_zig_dep.module("xboxkrnl"),
        .nxdk_hal = nxdk_zig_dep.module("nxdk_hal"),
        .winapi = nxdk_zig_dep.module("winapi"),
        .pbkit = nxdk_zig_dep.module("pbkit"),
    });
}

fn createExeWithModules(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    user_root_source_file: std.Build.LazyPath,
    start_root_source_file: std.Build.LazyPath,
    /// NOTE: LTO on Debug builds disables `bundle_ubsan_rt`
    lto: ?std.zig.LtoMode,
    mods: struct {
        pdclib: *std.Build.Module,
        nxdk: *std.Build.Module,
        xboxrt: *std.Build.Module,
        winmm: *std.Build.Module,
        xboxkrnl: *std.Build.Module,
        nxdk_hal: *std.Build.Module,
        winapi: *std.Build.Module,
        pbkit: *std.Build.Module,
    },
) !*std.Build.Step.Compile {
    const user_mod = b.createModule(.{
        .root_source_file = user_root_source_file,
        .target = b.resolveTargetQuery(target_query),
        .optimize = optimize,
        .imports = &.{
            .{ .name = "winapi", .module = mods.winapi },
            .{ .name = "xboxkrnl", .module = mods.xboxkrnl },
            .{ .name = "nxdk_hal", .module = mods.nxdk_hal },
            .{ .name = "pbkit", .module = mods.pbkit },
            .{ .name = "pdclib", .module = mods.pdclib },
            .{ .name = "nxdk", .module = mods.nxdk },
            .{ .name = "xboxrt", .module = mods.xboxrt },
            .{ .name = "winmm", .module = mods.winmm },
        },
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .root_source_file = start_root_source_file,
            .target = b.resolveTargetQuery(target_query),
            .optimize = optimize,
            .imports = &.{
                .{ .name = "user", .module = user_mod },
                .{ .name = "winapi", .module = mods.winapi },
                .{ .name = "xboxkrnl", .module = mods.xboxkrnl },
                .{ .name = "nxdk_hal", .module = mods.nxdk_hal },
                .{ .name = "pbkit", .module = mods.pbkit },
                .{ .name = "pdclib", .module = mods.pdclib },
                .{ .name = "nxdk", .module = mods.nxdk },
                .{ .name = "xboxrt", .module = mods.xboxrt },
                .{ .name = "winmm", .module = mods.winmm },
            },
        }),
    });

    if (optimize == .Debug and (lto orelse .none) != .none) {
        exe.bundle_ubsan_rt = false;
    }
    exe.lto = lto;
    exe.image_base = 0x0001_0000;
    exe.stack_size = 65536;
    exe.subsystem = .windows;
    exe.entry = .{ .symbol_name = "WinMainCRTStartup" };
    exe.root_module.single_threaded = true;

    return exe;
}

pub fn convertExeToXboxExe(
    nxdk_zig_dep: *std.Build.Dependency,
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    previous_step: *std.Build.Step,
    exe: *std.Build.Step.Compile,
    /// Relative to prefix dir (zig-out)
    output_path: []const u8,
) !InstalledXbe {
    return convertExeToXboxExeWithDep(b, optimize, previous_step, exe, output_path, nxdk_zig_dep.builder.dependency("nxdk", .{}));
}

fn convertExeToXboxExeWithDep(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    previous_step: *std.Build.Step,
    exe: *std.Build.Step.Compile,
    /// Relative to prefix dir (zig-out)
    output_path: []const u8,
    nxdk_dep: *std.Build.Dependency,
) !InstalledXbe {
    if (exe.root_module.link_libc == true) {
        @panic("nxdk_zig is freestanding: link_libc must not be enabled. Use the pdclib instead.");
    }

    const cxbe_exe = try buildCXBEBin(b, optimize, nxdk_dep);
    cxbe_exe.step.dependOn(previous_step);

    const cmd = std.Build.Step.Run.create(b, "run cxbe_exe");
    cmd.addArtifactArg(cxbe_exe);
    const xbe_file_path = cmd.addPrefixedOutputFileArg("-OUT:", b.fmt("{s}.xbe", .{exe.name}));
    cmd.addArg(b.fmt("-TITLE:{s}", .{exe.name}));
    cmd.addArg(b.fmt("-MODE:{s}", .{if (optimize == .Debug) "debug" else "retail"}));
    if (exe.producesPdbFile()) {
        cmd.addArg("-DEBUGPATH:D:\\default.pdb");
    }
    cmd.addFileArg(exe.getEmittedBin());
    cmd.setCwd(b.path("."));
    cmd.expectExitCode(0);
    cmd.has_side_effects = true;

    const relative_install_path: []const u8 = b.fmt("{s}/xbin/{s}", .{
        output_path, exe.name,
    });
    const install_xbe = b.addInstallFileWithDir(
        xbe_file_path,
        .{ .custom = relative_install_path },
        "default.xbe",
    );
    install_xbe.step.dependOn(&cmd.step);
    if (exe.producesPdbFile()) {
        const pdb_file_path = exe.getEmittedPdb();
        const install_pdb = b.addInstallFileWithDir(
            pdb_file_path,
            .{ .custom = relative_install_path },
            "default.pdb",
        );
        install_xbe.step.dependOn(&install_pdb.step);
    }

    return .{
        .step = &install_xbe.step,
        .dir_path = .{ .cwd_relative = b.pathFromRoot(b.fmt("{s}/{s}", .{ b.install_prefix, relative_install_path })) },
    };
}

pub fn createXISO(
    nxdk_zig_dep: *std.Build.Dependency,
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    convert_step: *std.Build.Step,
    exe_name: []const u8,
    xbe_dir_path: std.Build.LazyPath,
    /// Relative to prefix dir (zig-out)
    output_path: []const u8,
) !*std.Build.Step {
    return createXISOWithDep(nxdk_zig_dep.builder.dependency("extract-xiso", .{}), b, optimize, convert_step, exe_name, xbe_dir_path, output_path);
}

fn createXISOWithDep(
    extract_xiso_dep: *std.Build.Dependency,
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    convert_step: *std.Build.Step,
    exe_name: []const u8,
    xbe_dir_path: std.Build.LazyPath,
    /// Relative to prefix dir (zig-out)
    output_path: []const u8,
) !*std.Build.Step {
    const extract_xiso_exe = try buildExtractXISOBin(b, optimize, extract_xiso_dep);
    extract_xiso_exe.step.dependOn(convert_step);

    const cmd = std.Build.Step.Run.create(b, b.fmt("run extract_xiso_exe", .{}));
    cmd.addArtifactArg(extract_xiso_exe);
    cmd.addPrefixedDirectoryArg("-c", xbe_dir_path);
    const iso_file_path = cmd.addOutputFileArg(exe_name);
    cmd.setCwd(b.path("."));
    cmd.expectExitCode(0);
    cmd.step.dependOn(&extract_xiso_exe.step);
    cmd.has_side_effects = true;

    const install_xbe = b.addInstallFileWithDir(
        iso_file_path,
        .{ .custom = output_path },
        b.fmt("{s}.iso", .{exe_name}),
    );
    install_xbe.step.dependOn(&cmd.step);

    return &install_xbe.step;
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
    if (info.optimize == .Debug and (info.lto orelse .none) != .none) {
        lib.bundle_ubsan_rt = false;
    }
    lib.lto = info.lto;
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
    const dlltool_cmd = b.addSystemCommand(&.{
        b.graph.zig_exe, "dlltool", "-m", "i386", "-k",
    });
    const lib_path = dlltool_cmd.addPrefixedOutputFileArg("-l", "libxboxkrnl.lib");
    dlltool_cmd.addPrefixedFileArg("-d", b.dependency("nxdk", .{}).path("lib/xboxkrnl/xboxkrnl.exe.def"));
    dlltool_cmd.setName("dlltool_gen_xboxkrnl");
    dlltool_cmd.setCwd(b.path("."));
    dlltool_cmd.expectExitCode(0);

    const install_kernellib = b.addInstallLibFile(
        lib_path,
        "libxboxkrnl.lib",
    );
    install_kernellib.step.dependOn(&dlltool_cmd.step);
    b.getInstallStep().dependOn(&install_kernellib.step);

    return lib_path;
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
    optimize: std.builtin.OptimizeMode,
    example_step: *std.Build.Step,
    name: []const u8,
    lto: ?std.zig.LtoMode,
    mods: struct {
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
    const exe = try createExeWithModules(
        b,
        optimize,
        name,
        b.path(b.fmt("examples/{s}/main.zig", .{name})),
        b.path("src/start/start.zig"),
        lto,
        .{
            .pdclib = mods.pdclib,
            .nxdk = mods.nxdk,
            .xboxrt = mods.xboxrt,
            .winmm = mods.winmm,
            .winapi = mods.winapi,
            .xboxkrnl = mods.xboxkrnl,
            .nxdk_hal = mods.nxdk_hal,
            .pbkit = mods.pbkit,
        },
    );

    const install_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "examples/bin" } },
    });

    const convertion = try convertExeToXboxExeWithDep(
        b,
        optimize,
        &install_exe.step,
        exe,
        "examples",
        b.dependency("nxdk", .{}),
    );

    const create_xiso = try createXISOWithDep(
        b.dependency("extract-xiso", .{}),
        b,
        optimize,
        convertion.step,
        exe.name,
        convertion.dir_path,
        "examples",
    );

    example_step.dependOn(create_xiso);
}

const LibInfo = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    /// NOTE: LTO on Debug builds disables `bundle_ubsan_rt`
    lto: ?std.zig.LtoMode,
    lib_name: []const u8,
    lib_deps: []const struct {
        name: []const u8,
        include_paths: []const []const u8,
        walker_paths: ?[]const []const u8,
        iter_paths: ?[]const []const u8,
    },
};

const InstalledXbe = struct {
    step: *std.Build.Step,
    dir_path: std.Build.LazyPath,
};

pub const asm_flags: []const []const u8 = &.{};

pub const c_flags: []const []const u8 = &.{
    "-ffreestanding",
    "-nostdlib",
    "-fno-builtin",
    "-Wno-builtin-macro-redefined",
    "-DNXDK",
    "-D__STDC__=1",
    "-U__STDC_NO_THREADS__",
};

pub const cpp_flags: []const []const u8 = &.{
    "-ffreestanding",
    "-nostdlib",
    "-fno-builtin",
    "-Wno-builtin-macro-redefined",
    "-DNXDK",
    "-D__STDC__=1",
    "-U__STDC_NO_THREADS__",
    "-fno-exceptions",
};
