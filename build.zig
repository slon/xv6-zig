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

const c_files = &[_][]const u8{
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

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // const target = b.standardTargetOptions(.{});

    const target = std.zig.CrossTarget {
        .cpu_arch = std.Target.Cpu.Arch.riscv64,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("xv6-zig", "src/main.zig");
    exe.addIncludeDir(".");

    exe.setLinkerScriptPath("kernel/kernel.ld");

    for (s_files) |file| {
        exe.addAssemblyFile(file);
    }
    for (c_files) |file| {
        exe.addCSourceFile(file, c_flags);
    }

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
