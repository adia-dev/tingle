const Self = @This();
const Statements = @import("statements/statement.zig");
const Expressions = @import("expressions/expression.zig");

pub const Node = union(enum) {
    Statement: *Statements.Statement,
    Expression: *Expressions.Expression,
};

pub fn tokenLiteral(node: Node) []const u8 {
    switch (node) {
        .Statement => |stmt| return Statements.tokenLiteral(stmt),
        .Expression => |exp| return Expressions.tokenLiteral(exp),
    }
}
