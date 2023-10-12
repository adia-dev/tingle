const std = @import("std");
pub const Program = @import("program.zig");
pub const Declaration = @import("declaration.zig");

pub const Statement = union(enum) {
    Program: Program,
    Declaration: Declaration,
};

pub fn tokenLiteral(stmt: *const Statement) []const u8 {
    switch (stmt.*) {
        // .Program => return "Program",
        // .Declaration => return "Declaration",
        else => |case| return @tagName(case),
    }
}

pub fn toString(stmt: *const Statement, allocator: std.mem.Allocator) ![]u8 {
    switch (stmt.*) {
        // .Program => return "Program",
        .Declaration => |decl| return try decl.toString(allocator),
        else => unreachable,
    }
}
