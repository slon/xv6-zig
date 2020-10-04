pub const Syscall = struct{
    name: []const u8,
    number: u64,
};

pub const table = [_]Syscall{
    .{.name="fork", .number=1},
    .{.name="exit", .number=2},
    .{.name="wait", .number=3},
    .{.name="pipe", .number=4},
    .{.name="read", .number=5},
    .{.name="kill", .number=6},
    .{.name="exec", .number=7},
    .{.name="fstat", .number=8},
    .{.name="chdir", .number=9},
    .{.name="dup", .number=10},
    .{.name="getpid", .number=11},
    .{.name="sbrk", .number=12},
    .{.name="sleep", .number=13},
    .{.name="uptime", .number=14},
    .{.name="open", .number=15},
    .{.name="write", .number=16},
    .{.name="mknod", .number=17},
    .{.name="unlink", .number=18},
    .{.name="link", .number=19},
    .{.name="mkdir", .number=20},
    .{.name="close", .number=21},
};
