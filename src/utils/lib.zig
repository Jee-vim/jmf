const std = @import("std");

const SRename = struct {
    old_name: []const u8,
    new_name: []const u8,
};

const SOpt = struct {
    add_name: ?[]const u8,
    rmv_name: ?[]const u8,
};

fn rename(opt: SRename) !void {
    try std.fs.cwd().rename(opt.old_name, opt.new_name);
    std.debug.print("{s} -> {s}\n", .{ opt.old_name, opt.new_name });
}

pub fn manipulationFile(opt: SOpt) !void {
    const allocator = std.heap.page_allocator;

    var dir = try std.fs.cwd().openDir("./", .{ .iterate = true });
    defer dir.close();
    var dir_iterator = dir.iterate();

    var file_list = std.array_list.Managed([]const u8).init(allocator);
    defer file_list.deinit();

    while (try dir_iterator.next()) |val| {
        try file_list.append(val.name);
    }

    for (file_list.items) |file_name| {
        if (opt.add_name) |val| {
            const new_name = try std.fmt.allocPrint(allocator, "{s}{s}", .{ val, file_name });
            defer allocator.free(new_name);

            try rename(.{ .old_name = file_name, .new_name = new_name });
        }
        if (opt.rmv_name) |val| {
            const size = std.mem.replacementSize(u8, file_name, val, "");
            const removed_name = try allocator.alloc(u8, size);
            defer allocator.free(removed_name);
            _ = std.mem.replace(u8, file_name, val, "", removed_name);

            try rename(.{ .old_name = file_name, .new_name = removed_name });
        }
    }
}
