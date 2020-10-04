const std = @import("std");
const fmt = std.fmt;
const syscall = @import("syscall.zig");

const syscall_stub =
    \\.section .text
    \\.global {0}
    \\{0}:
    \\ li a7, {1}
    \\ ecall
    \\ ret
;

comptime {
    @setEvalBranchQuota(10000);

    var buf: [1024]u8 = undefined;

    // Generate the stubs for syscalls.
    inline for (syscall.table) |call| {
        var stub = try fmt.bufPrint(&buf, syscall_stub, .{call.name, call.number});

        asm (
            stub
        );
    }
}
