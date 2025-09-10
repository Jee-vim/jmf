const std = @import("std");
const rn = @import("utils/renamed.zig");

const Opt = struct {
    add_name: []const u8,
    rmv_name: []const u8,
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

        const rmv = opt.rmv_name;
        if (rmv.len > 0) {
            const size = std.mem.replacementSize(u8, file_name, rmv, "");
            const new_output = try allocator.alloc(u8, size);
            defer allocator.free(new_output);
            _ = std.mem.replace(u8, file_name, rmv, "", new_output);

            try rn.rename(.{ .file_name = file_name, .output = new_output });
        } else {
            try rn.rename(.{ .file_name = file_name, .output = new_name });
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    manipulationFile(.{ .add_name = args[1], .rmv_name = args[2] }) catch |err| {
        std.debug.print("error: {s}", .{@errorName(err)});
    };
}
