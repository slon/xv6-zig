
comptime {
    @export(_start, .{ .name = "_start" });
}

fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ jal main
    );

    while (true) {}
}