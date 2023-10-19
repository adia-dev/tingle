const std = @import("std");
const Self = @This();
const _TokenType = @import("token_type.zig");
pub const TokenType = _TokenType.TokenType;
pub const Keyword = _TokenType.Keyword;
pub const Number = _TokenType.Number;

type: TokenType = .illegal,
row: usize = 1,
column: usize = 1,

pub fn to_string(self: *const Self, allocator: std.mem.Allocator) ![]u8 {
    return try std.fmt.allocPrint(allocator,
        \\ Token: 
        \\     - type: {s} ({s})
        \\     - literal: {s}
        \\     - row: {d}
        \\     - column: {d}
        \\
    , .{ self.type.to_string(), @tagName(self.type), self.type.to_string(), self.row, self.column });
}
