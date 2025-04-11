const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ace_eval_dep = b.dependency("ACE_eval", .{});
    const ace_eval_mod = b.createModule(.{ .target = target, .optimize = optimize });
    ace_eval_mod.addCSourceFile(.{ .file = ace_eval_dep.path("ace_eval_golf.c") });

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ace_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "AceEval",
        .root_module = ace_eval_mod,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "HandEvaluator",
        .root_module = lib_mod,
    });
    lib.addIncludePath(ace_eval_dep.path(""));
    lib.linkLibrary(ace_lib);
    lib.installHeadersDirectory(ace_eval_dep.path("."), "", .{});

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
