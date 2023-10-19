const std = @import("std");
const REPL = @import("repl/repl.zig");
const Token = @import("token/token.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var repl = REPL.init(arena.allocator());
    try repl.start();
}
