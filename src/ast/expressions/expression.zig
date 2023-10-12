pub const Identifier = @import("identifier.zig");

pub const Expression = union(enum) { Identifier: *Identifier };

pub fn tokenLiteral(exp: *const Expression) []const u8 {
    _ = exp;
    return "Expression";
}
