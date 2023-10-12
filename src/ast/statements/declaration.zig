const std = @import("std");
const Self = @This();

const Statements = @import("statement.zig");
const Expressions = @import("../expressions/expression.zig");
const Statement = Statements.Statement;
const Node = @import("../node.zig");
const Token = @import("../../token/token.zig");

token: Token = undefined,
name: Expressions.Identifier = undefined,
type_specifier: ?Expressions.Identifier = null,
value: Expressions.Expression = undefined,

pub fn init(token: *Token) Self {
    return Self{ .token = token.* };
}

pub fn tokenLiteral(self: *Self) []const u8 {
    return self.token.literal();
}

pub fn toString(self: *Self, allocator: std.mem.Allocator) ![]u8 {
    if (self.type_specifier) |type_specifier| {
        return try std.fmt.allocPrint(allocator, "{s} {s}: {s} = {s};", .{ self.token.literal(), self.name.value, type_specifier.value, "null" });
    }
    return try std.fmt.allocPrint(allocator, "{s} {s} = {s};", .{ self.token.literal(), self.name.value, "null" });
}
