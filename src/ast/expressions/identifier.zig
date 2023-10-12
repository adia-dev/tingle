const Self = @This();

const Expressions = @import("expression.zig");
const Node = @import("../node.zig");

const Token = @import("../../token/token.zig");

token: Token,
value: []const u8,

pub fn init(token: *Token) Self {
    return Self{ .token = token.*, .value = token.literal() };
}

pub fn tokenLiteral(self: *Self) []const u8 {
    return self.token.literal();
}
