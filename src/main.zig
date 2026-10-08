const std = @import("std");
const lib = @import("consonants");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len < 2) {
        std.debug.print("usage: {s} <text>...\n", .{args[0]});
        std.process.exit(1);
    }

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    // Each argument is processed on its own line.
    for (args[1..]) |arg| {
        const result = try lib.onlyConsonants(gpa, arg);
        defer gpa.free(result);
        try stdout.print("{s}\n", .{result});
    }
    try stdout.flush();
}