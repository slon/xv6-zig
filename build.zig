const std = @import("std");
const Builder = @import("std").build.Builder;

const c_flags = &[_][]const u8{
    "-mcmodel=medany",
    "-mno-relax",
};

const s_files = &[_][]const u8{
    "kernel/entry.S",
    "kernel/swtch.S",
    "kernel/trampoline.S",
    "kernel/kernelvec.S",
};

const kernel_c_files = &[_][]const u8{
    "kernel/start.c",
    "kernel/console.c",
    "kernel/printf.c",
    "kernel/uart.c",
    "kernel/kalloc.c",
    "kernel/spinlock.c",
    "kernel/string.c",
    "kernel/main.c",
    "kernel/vm.c",
    "kernel/proc.c",
    "kernel/trap.c",
    "kernel/syscall.c",
    "kernel/sysproc.c",
    "kernel/bio.c",
    "kernel/fs.c",
    "kernel/log.c",
    "kernel/sleeplock.c",
    "kernel/file.c",
    "kernel/pipe.c",
    "kernel/exec.c",
    "kernel/sysfile.c",
    "kernel/plic.c",
    "kernel/virtio_disk.c",
};

const uprogs = &[_][]const u8{
    "cat",
    "echo",
    "forktest",
    "grep",
    "init",
    "kill",
    "ln",
    "ls",
    "mkdir",
    "rm",
    "sh",
    "stressfs",
    "usertests",
    "grind",
    "wc",
    "zombie",
};

pub fn build(b: *Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const target = std.zig.CrossTarget {
        .cpu_arch = std.Target.Cpu.Arch.riscv64,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
    };

    const kernel = b.addExecutable("kernel", "src/main.zig");
    kernel.addIncludeDir(".");
    kernel.setLinkerScriptPath("kernel/kernel.ld");
    for (s_files) |file| {
        kernel.addAssemblyFile(file);
    }
    for (kernel_c_files) |file| {
        kernel.addCSourceFile(file, c_flags);
    }
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.install();

    const ulib = b.addStaticLibrary("ulib", "src/ulib.zig");
    ulib.addIncludeDir(".");
    ulib.addCSourceFile("user/ulib.c", c_flags);
    ulib.addCSourceFile("user/printf.c", c_flags);
    ulib.addCSourceFile("user/umalloc.c", c_flags);

    ulib.setTarget(target);
    ulib.setBuildMode(mode);
    ulib.install();

    const ulib_slim = b.addStaticLibrary("ulibslim", "src/ulib.zig");
    ulib_slim.addIncludeDir(".");
    ulib_slim.addCSourceFile("user/ulib.c", c_flags);

    ulib_slim.setTarget(target);
    ulib_slim.setBuildMode(mode);
    ulib_slim.install();

    const mkfs = b.addExecutable("mkfs", null);
    mkfs.addIncludeDir(".");
    mkfs.addCSourceFile("mkfs/mkfs.c", &[_][]const u8{});
    mkfs.linkLibC();
    mkfs.setBuildMode(mode);
    mkfs.install();

    const fs = mkfs.run();
    fs.step.dependOn(&mkfs.step);
    fs.addArg("fs.img");

    b.getInstallStep().dependOn(&fs.step);

    inline for (uprogs) |uprog| {
        const c_file = "user/" ++ uprog ++ ".c";

        const uprog_bin = b.addExecutable(uprog, "src/rt.zig");
        uprog_bin.addIncludeDir(".");
        uprog_bin.addCSourceFile(c_file, c_flags);

        uprog_bin.linkLibrary(if (!std.mem.eql(u8, uprog, "forktest")) ulib else ulib_slim);

        uprog_bin.setTarget(target);
        uprog_bin.setBuildMode(mode);
        uprog_bin.install();

        fs.addArtifactArg(uprog_bin);
    }
}
