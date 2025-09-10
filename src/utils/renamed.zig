const std = @import("std");

const SRename = struct {
    file_name: []const u8,
    output: []const u8,
};

pub fn rename(opt: SRename) !void {
    try std.fs.cwd().rename(opt.file_name, opt.output);
    std.debug.print("{s} -> {s}\n", .{ opt.file_name, opt.output });
}
