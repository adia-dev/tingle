const Self = @This();
const std = @import("std");
const ArrayList = std.ArrayList;
const Statements = @import("statement.zig");
const Statement = Statements.Statement;
const Node = @import("../node.zig");

statements: ArrayList(Statement) = undefined,

pub fn init(allocator: std.mem.Allocator) Self {
    var program = Self{};

    program.statements = ArrayList(Statement).init(allocator);

    return program;
}

pub fn deinit(self: *Self) void {
    self.statements.deinit();
}

pub fn tokenLiteral(self: *Self) []const u8 {
    if (self.statements.len > 0) {
        return Node.token_literal(self);
    }

    return "";
}
