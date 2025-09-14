const std = @import("std");

const Srename = struct { old_name: []const u8, new_name: []const u8 };
const SmF = struct { add_name: ?[]const u8, rmv_name: ?[]const u8 };

fn rename(opt: Srename) !void {
    try std.fs.cwd().rename(opt.old_name, opt.new_name);
    std.debug.print("{s} -> {s}\n", .{ opt.old_name, opt.new_name });
}

pub fn manipulationFile(opt: SmF) !void {
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
        var current_name = file_name;
        var allocated: ?[]u8 = null;

        if (opt.add_name) |val| {
            const added = try std.fmt.allocPrint(allocator, "{s}{s}", .{ val, current_name });
            if (allocated) |old| allocator.free(old);
            allocated = added;
            current_name = added;
        }

        if (opt.rmv_name) |val| {
            const size = std.mem.replacementSize(u8, current_name, val, "");
            const removed = try allocator.alloc(u8, size);

            _ = std.mem.replace(u8, current_name, val, "", removed);
            if (allocated) |old| allocator.free(old);
            allocated = removed;
            current_name = removed;
        }

        if (!std.mem.eql(u8, file_name, current_name)) {
            try rename(.{ .old_name = file_name, .new_name = current_name });
        }
        if (allocated) |val| allocator.free(val);
    }
}
