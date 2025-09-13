const std = @import("std");
const lib = @import("utils/lib.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("Usage: jren <value>\n", .{});
        return;
    }

    const add_name = args[1];
    const rmv_name = if (args.len > 2) args[2] else null;

    lib.manipulationFile(.{ .add_name = add_name, .rmv_name = rmv_name }) catch |err| {
        std.debug.print("error: {s}\n", .{@errorName(err)});
    };
}
