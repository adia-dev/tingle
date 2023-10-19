const std = @import("std");
const ArrayList = std.ArrayList;
const Lexer = @import("lexer.zig");
const Token = @import("../token/token.zig");

test "Lexer - advance (with punctiation)" {
    const ta = std.testing.allocator;
    const input = "=+(){}[],;";
    var lexer = Lexer.init(input);

    var expected = ArrayList(struct { type: Token.TokenType, literal: []const u8 }).init(ta);
    defer expected.deinit();

    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .plus, .literal = "+" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .lbrace, .literal = "{" });
    try expected.append(.{ .type = .rbrace, .literal = "}" });
    try expected.append(.{ .type = .lbrack, .literal = "[" });
    try expected.append(.{ .type = .rbrack, .literal = "]" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    for (expected.items) |e| {
        const token = try lexer.scan();

        try std.testing.expectEqual(@intFromEnum(e.type), @intFromEnum(token.type));
        try std.testing.expectEqualStrings(e.literal, token.type.to_string());
    }
}

test "Lexer - advance (with code sample)" {
    const ta = std.testing.allocator;
    const input =
        \\ let ten = 10;
        \\
        \\ const User = struct {
        \\      firstname: String,
        \\      lastname: String,
        \\      email: Optional<String>,
        \\      username: &str,
        \\      age: u8
        \\ }; 
        \\
        \\ var new_user = User { 
        \\      firstname: String::new("Abdoulaye"),
        \\      lastname: String::new("Dia"),
        \\      email: null,
        \\      username: "adia-dev",
        \\      age: 23
        \\  };
        \\ 
        \\ let add = fn(...) {
        \\      const args = arguments();
        \\      var sum = 0;
        \\
        \\      for arg in args {
        \\          sum += arg;
        \\      }
        \\
        \\      return sum;
        \\ };
        \\
        \\ let result = add(1, 2, 3, 4, 5, ten, user.age);
    ;
    var lexer = Lexer.init(input);

    var expected = ArrayList(struct { type: Token.TokenType, literal: []const u8 }).init(ta);
    defer expected.deinit();

    try expected.append(.{ .type = .{ .keyword = .let }, .literal = "let" });
    try expected.append(.{ .type = .{ .identifier = "ten" }, .literal = "ten" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .number = "10" }, .literal = "10" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    // Add tokens for the struct definition
    try expected.append(.{ .type = .{ .keyword = .@"const" }, .literal = "const" });
    try expected.append(.{ .type = .{ .identifier = "User" }, .literal = "User" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .keyword = .@"struct" }, .literal = "struct" });
    try expected.append(.{ .type = .lbrace, .literal = "{" });
    try expected.append(.{ .type = .{ .identifier = "firstname" }, .literal = "firstname" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "String" }, .literal = "String" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "lastname" }, .literal = "lastname" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "String" }, .literal = "String" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "email" }, .literal = "email" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "Optional" }, .literal = "Optional" });
    try expected.append(.{ .type = .lt, .literal = "<" });
    try expected.append(.{ .type = .{ .identifier = "String" }, .literal = "String" });
    try expected.append(.{ .type = .gt, .literal = ">" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "username" }, .literal = "username" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .ampersand, .literal = "&" });
    try expected.append(.{ .type = .{ .identifier = "str" }, .literal = "str" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "age" }, .literal = "age" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "u8" }, .literal = "u8" });
    try expected.append(.{ .type = .rbrace, .literal = "}" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    // ... add more tokens for struct fields and the closing semicolon

    // Add tokens for the variable declaration
    try expected.append(.{ .type = .{ .keyword = .@"var" }, .literal = "var" });
    try expected.append(.{ .type = .{ .identifier = "new_user" }, .literal = "new_user" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .identifier = "User" }, .literal = "User" });
    try expected.append(.{ .type = .lbrace, .literal = "{" });
    try expected.append(.{ .type = .{ .identifier = "firstname" }, .literal = "firstname" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "String" }, .literal = "String" });
    try expected.append(.{ .type = .pathSep, .literal = "::" });
    try expected.append(.{ .type = .{ .identifier = "new" }, .literal = "new" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .{ .string = "\"Abdoulaye\"" }, .literal = "Abdoulaye" });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "lastname" }, .literal = "lastname" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .identifier = "String" }, .literal = "String" });
    try expected.append(.{ .type = .pathSep, .literal = "::" });
    try expected.append(.{ .type = .{ .identifier = "new" }, .literal = "new" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .{ .string = "Dia" }, .literal = "Dia" });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "email" }, .literal = "email" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .keyword = .null }, .literal = "null" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "username" }, .literal = "username" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .string = "adia-dev" }, .literal = "adia-dev" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "age" }, .literal = "age" });
    try expected.append(.{ .type = .colon, .literal = ":" });
    try expected.append(.{ .type = .{ .number = "23" }, .literal = "23" });
    try expected.append(.{ .type = .rbrace, .literal = "}" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    // Add tokens for the function definition
    try expected.append(.{ .type = .{ .keyword = .let }, .literal = "let" });
    try expected.append(.{ .type = .{ .identifier = "add" }, .literal = "add" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .keyword = .@"fn" }, .literal = "fn" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .dotDotDot, .literal = "..." });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .lbrace, .literal = "{" });
    try expected.append(.{ .type = .{ .keyword = .@"const" }, .literal = "const" });
    try expected.append(.{ .type = .{ .identifier = "args" }, .literal = "args" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .identifier = "arguments" }, .literal = "arguments" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });
    try expected.append(.{ .type = .{ .keyword = .@"var" }, .literal = "var" });
    try expected.append(.{ .type = .{ .identifier = "sum" }, .literal = "sum" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .number = "0" }, .literal = "0" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });
    try expected.append(.{ .type = .{ .keyword = .@"for" }, .literal = "for" });
    try expected.append(.{ .type = .{ .identifier = "arg" }, .literal = "arg" });
    try expected.append(.{ .type = .{ .keyword = .in }, .literal = "in" });
    try expected.append(.{ .type = .{ .identifier = "args" }, .literal = "args" });
    try expected.append(.{ .type = .lbrace, .literal = "{" });
    try expected.append(.{ .type = .{ .identifier = "sum" }, .literal = "sum" });
    try expected.append(.{ .type = .plusEq, .literal = "+=" });
    try expected.append(.{ .type = .{ .identifier = "arg" }, .literal = "arg" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });
    try expected.append(.{ .type = .rbrace, .literal = "}" });
    try expected.append(.{ .type = .{ .keyword = .@"return" }, .literal = "return" });
    try expected.append(.{ .type = .{ .identifier = "sum" }, .literal = "sum" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });
    try expected.append(.{ .type = .rbrace, .literal = "}" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    // Add tokens for the function call
    try expected.append(.{ .type = .{ .keyword = .let }, .literal = "let" });
    try expected.append(.{ .type = .{ .identifier = "result" }, .literal = "result" });
    try expected.append(.{ .type = .eq, .literal = "=" });
    try expected.append(.{ .type = .{ .identifier = "add" }, .literal = "add" });
    try expected.append(.{ .type = .lparen, .literal = "(" });
    try expected.append(.{ .type = .{ .number = "1" }, .literal = "1" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .number = "2" }, .literal = "2" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .number = "3" }, .literal = "3" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .number = "4" }, .literal = "4" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .number = "5" }, .literal = "5" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "ten" }, .literal = "ten" });
    try expected.append(.{ .type = .comma, .literal = "," });
    try expected.append(.{ .type = .{ .identifier = "user" }, .literal = "user" });
    try expected.append(.{ .type = .dot, .literal = "." });
    try expected.append(.{ .type = .{ .identifier = "age" }, .literal = "age" });
    try expected.append(.{ .type = .rparen, .literal = ")" });
    try expected.append(.{ .type = .semicolon, .literal = ";" });

    for (expected.items) |e| {
        const token = try lexer.scan();

        std.testing.expectEqual(@intFromEnum(e.type), @intFromEnum(token.type)) catch {
            std.debug.print("UnexpectedTokenError({d}:{d}): Expected {s}, got {s}\n", .{ token.row, token.column, e.type.to_string(), token.type.to_string() });
            return;
        };

        std.testing.expectEqualStrings(e.literal, token.type.to_string()) catch {
            std.debug.print("UnexpectedTokenLiteralError({d}:{d}): Expected {s}, got {s}\n", .{ token.row, token.column, e.literal, token.type.to_string() });
            return;
        };
    }
}
