const std = @import("std");

const SRename = struct {
    file_name: []const u8,
    output: []const u8,
};

const Opt = struct {
    add_name: []const u8,
    rmv_name: ?[]const u8,
};

pub fn rename(opt: SRename) !void {
    try std.fs.cwd().rename(opt.file_name, opt.output);
    std.debug.print("{s} -> {s}\n", .{ opt.file_name, opt.output });
}

pub fn manipulationFile(opt: Opt) !void {
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
        const new_name = try std.fmt.allocPrint(allocator, "{s}{s}", .{ opt.add_name, file_name });
        defer allocator.free(new_name);

        if (opt.rmv_name) |rmv| {
            const size = std.mem.replacementSize(u8, file_name, rmv, "");
            const removed_name = try allocator.alloc(u8, size);
            defer allocator.free(removed_name);
            _ = std.mem.replace(u8, file_name, rmv, "", removed_name);

            try rename(.{ .file_name = file_name, .output = removed_name });
        } else {
            try rename(.{ .file_name = file_name, .output = new_name });
        }
    }
}
