const std = @import("std");

fn renamed(i_name: []const u8) !void {
    const allocator = std.heap.page_allocator;

    var dir = try std.fs.cwd().openDir("./", .{ .iterate = true });
    defer dir.close();
    var dir_iterator = dir.iterate();

    var file_list = std.ArrayList([]const u8).init(allocator);
    defer file_list.deinit();

    while (try dir_iterator.next()) |val| {
        try file_list.append(val.name);
    }

    for (file_list.items) |name| {
        const new_name = try std.fmt.allocPrint(allocator, "{s}-{s}", .{ i_name, name });
        defer allocator.free(new_name);

        try std.fs.cwd().rename(name, new_name);
        std.debug.print("old name: {s}, new name: {s}\n", .{ name, new_name });
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("Usage: jren <renamed>\n", .{});
        return;
    }

    try renamed(args[1]);
}
