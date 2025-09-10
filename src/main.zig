const std = @import("std");
const lib = @import("utils/lib.zig");

const Opt = struct {
    add_name: []const u8,
    rmv_name: ?[]const u8,
};

fn manipulationFile(opt: Opt) !void {
    const allocator = std.heap.page_allocator;

    var dir = try std.fs.cwd().openDir("./", .{ .iterate = true });
    defer dir.close();
    var dir_iterator = dir.iterate();

    var file_list = std.ArrayList([]const u8).init(allocator);
    defer file_list.deinit();

    while (try dir_iterator.next()) |val| {
        try file_list.append(val.name);
    }

    for (file_list.items) |file_name| {
        const new_name = try std.fmt.allocPrint(allocator, "{s}{s}", .{ opt.add_name, file_name });
        defer allocator.free(new_name);

        if (opt.rmv_name) |rmv| {
            const size = std.mem.replacementSize(u8, file_name, rmv, "");
            const removed_name = try allocator.alloc(u8, size);
            defer allocator.free(removed_name);
            _ = std.mem.replace(u8, file_name, rmv, "", removed_name);

            try lib.rename(.{ .file_name = file_name, .output = removed_name });
        } else {
            try lib.rename(.{ .file_name = file_name, .output = new_name });
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("usage: jren <added_name> [removed_name]\n", .{});
        return;
    }

    const add_name = args[1];
    const rmv_name = if (args.len > 2) args[2] else null;

    manipulationFile(.{ .add_name = add_name, .rmv_name = rmv_name }) catch |err| {
        std.debug.print("error: {s}\n", .{@errorName(err)});
    };
}
