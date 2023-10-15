const std = @import("std");
const Token = @import("token/token.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var token = Token{ .column = 0, .row = 0, .type = .{ .keyword = .as } };
    std.debug.print("{!s}\n\n", .{token.to_string(arena.allocator())});

    var keyword_str = "struct";

    if (Token.Keyword.from_str(keyword_str)) |kw| {
        std.debug.print("Keyword: {any}\n", .{kw});
    } else {
        std.debug.print("Keyword not found for: {s}\n", .{keyword_str});
    }
}
