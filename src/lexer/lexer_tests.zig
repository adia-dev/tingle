const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const Lexer = @import("lexer.zig");
const Token = @import("../token/token.zig");
const TokenType = Token.TokenType;

const TokenTypeLiteral = struct { t: TokenType, literal: []const u8 };

test "Lexer - scan()" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const input =
        \\ let five = 5;
        \\ let ten = 10;
        \\ let add = fn(x, y) {
        \\ x + y
        \\ };
        \\ let result = add(five, ten);
    ;

    var expected_tokens = ArrayList(TokenTypeLiteral).init(arena.allocator());

    try expected_tokens.append(.{ .t = .{ .Keyword = .Let }, .literal = "let" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "five" }, .literal = "five" });
    try expected_tokens.append(.{ .t = .Equal, .literal = "=" });
    try expected_tokens.append(.{ .t = .{ .Number = "5" }, .literal = "5" });
    try expected_tokens.append(.{ .t = .SemiColon, .literal = ";" });
    try expected_tokens.append(.{ .t = .{ .Keyword = .Let }, .literal = "let" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "ten" }, .literal = "ten" });
    try expected_tokens.append(.{ .t = .Equal, .literal = "=" });
    try expected_tokens.append(.{ .t = .{ .Number = "10" }, .literal = "10" });
    try expected_tokens.append(.{ .t = .SemiColon, .literal = ";" });
    try expected_tokens.append(.{ .t = .{ .Keyword = .Let }, .literal = "let" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "add" }, .literal = "add" });
    try expected_tokens.append(.{ .t = .Equal, .literal = "=" });
    try expected_tokens.append(.{ .t = .{ .Keyword = .Fn }, .literal = "fn" });
    try expected_tokens.append(.{ .t = .LeftParen, .literal = "(" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "x" }, .literal = "x" });
    try expected_tokens.append(.{ .t = .Comma, .literal = "," });
    try expected_tokens.append(.{ .t = .{ .Identifier = "y" }, .literal = "y" });
    try expected_tokens.append(.{ .t = .RightParen, .literal = ")" });
    try expected_tokens.append(.{ .t = .LeftBrace, .literal = "{" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "x" }, .literal = "x" });
    try expected_tokens.append(.{ .t = .Plus, .literal = "+" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "y" }, .literal = "y" });
    try expected_tokens.append(.{ .t = .RightBrace, .literal = "}" });
    try expected_tokens.append(.{ .t = .SemiColon, .literal = ";" });
    try expected_tokens.append(.{ .t = .{ .Keyword = .Let }, .literal = "let" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "result" }, .literal = "result" });
    try expected_tokens.append(.{ .t = .Equal, .literal = "=" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "add" }, .literal = "add" });
    try expected_tokens.append(.{ .t = .LeftParen, .literal = "(" });
    try expected_tokens.append(.{ .t = .{ .Identifier = "five" }, .literal = "five" });
    try expected_tokens.append(.{ .t = .Comma, .literal = "," });
    try expected_tokens.append(.{ .t = .{ .Identifier = "ten" }, .literal = "ten" });
    try expected_tokens.append(.{ .t = .RightParen, .literal = ")" });
    try expected_tokens.append(.{ .t = .SemiColon, .literal = ";" });

    var lexer = try Lexer.init(input, arena.allocator());

    for (expected_tokens.items) |e| {
        var token = lexer.scan();

        try std.testing.expectEqualStrings(e.literal, token.literal());
        try std.testing.expectEqual(@intFromEnum(e.t), @intFromEnum(token.t));
    }
}
