const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

const Parser = @import("parser.zig");
const Lexer = @import("./../lexer/lexer.zig");
const ast = @import("./../ast/ast.zig");
const Token = @import("./../token/token.zig");
const TokenType = Token.TokenType;

test "Lexer - scan()" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const input =
        \\ let five = 5;
        \\ const ten = 10;
        \\ var add = fn(x, y) {
        \\ x + y
        \\ };
        \\ let result = add(five, ten);
        \\ let name: string = "Abdoulaye Dia";
    ;

    const ExpectedDeclaration = struct { name: []const u8, value: ?ast.Expressions.Expression };
    const expected_declarations = [5]ExpectedDeclaration{
        .{ .name = "let", .value = null },
        .{ .name = "const", .value = null },
        .{ .name = "var", .value = null },
        .{ .name = "let", .value = null },
        .{ .name = "let", .value = null },
    };

    var lexer = try Lexer.init(input, arena.allocator());
    var parser = Parser.init(&lexer, arena.allocator());

    var program = try parser.parse();

    try std.testing.expectEqual(program.statements.items.len, 5);

    for (expected_declarations, 0..) |expected, i| {
        var stmt = program.statements.items[i];

        try std.testing.expect(try testDeclarationStatement(&stmt, expected.name));
    }
}

fn testDeclarationStatement(stmt: *ast.Statements.Statement, expected_name: []const u8) !bool {
    _ = expected_name;
    switch (stmt.*) {
        .Declaration => |*decl| {
            // try std.testing.expectEqualSlices(u8, expected_name, decl.name.value);
            const ta = std.testing.allocator;

            var decl_str = try decl.toString(ta);
            std.debug.print("declaration: {s}\n", .{decl_str});
            defer ta.free(decl_str);
        },
        else => {
            std.debug.print("Expected a Declaraction Statement, got: {s}\n", .{@tagName(stmt.*)});
            return false;
        },
    }

    return true;
}
