const std = @import("std");
const jmf = @import("root.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    var add_name: ?[]const u8 = null;
    var rmv_name: ?[]const u8 = null;
    var i: u8 = 1;

    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "-a")) {
            i += 1;
            if (i < args.len) add_name = args[i];
        } else if (std.mem.eql(u8, args[i], "-r")) {
            i += 1;
            if (i < args.len) rmv_name = args[i];
        }
    }

    if (args.len < 2) {
        std.debug.print("Usage: jmf <command> <value>\n", .{});
        std.debug.print("Ex: jmf -a test-\n", .{});
        return;
    }

    jmf.manipulationFile(.{ .add_name = add_name, .rmv_name = rmv_name }) catch |err| {
        std.debug.print("error: {s}\n", .{@errorName(err)});
    };
}
