const std = @import("std");
const Self = @This();
const Lexer = @import("./../lexer/lexer.zig");
const Token = @import("./../token/token.zig");
const ast = @import("../ast/ast.zig");

lexer: *Lexer = undefined,
current_token: Token = undefined,
next_token: Token = undefined,
allocator: std.mem.Allocator = undefined,

pub fn init(lexer: *Lexer, allocator: std.mem.Allocator) Self {
    var parser = Self{};

    parser.lexer = lexer;
    parser.allocator = allocator;

    parser.advance();
    parser.advance();

    return parser;
}

pub fn parse(self: *Self) !ast.Statements.Program {
    var program = ast.Statements.Program.init(self.allocator);

    while (self.current_token.t != .Eof) : (self.advance()) {
        if (self.parseStatement()) |stmt| {
            try program.statements.append(stmt);
        }
    }

    return program;
}

fn parseStatement(self: *Self) ?ast.Statements.Statement {
    switch (self.current_token.t) {
        .Keyword => |kw| {
            switch (kw) {
                .Let, .Const, .Var => return self.parseDeclarationStatement(),
                else => return null,
            }
        },
        else => return null,
    }
}

fn parseDeclarationStatement(self: *Self) ?ast.Statements.Statement {
    var declaration = ast.Statements.Declaration.init(&self.current_token);

    if (!self.nextTokenIs(.{ .Identifier = "" })) {
        return null;
    }

    self.advance();

    declaration.name = ast.Expressions.Identifier.init(&self.current_token);

    if (self.nextTokenIs(.Colon)) {
        self.advance();
        if (!self.nextTokenIs(.{ .Identifier = "" })) {
            std.debug.print("Expected a type identifier. (e.g: `let age: u32 = 23;`)\n", .{});
            return null;
        }

        self.advance();
        declaration.type_specifier = ast.Expressions.Identifier.init(&self.current_token);
    }

    if (!self.nextTokenIs(.Equal)) {
        std.debug.print("Expected Equal, found: {s}\n", .{@tagName(self.next_token.t)});
        return null;
    }

    self.advance();

    while (!self.currentTokenIs(.SemiColon)) : (self.advance()) {}

    return ast.Statements.Statement{ .Declaration = declaration };
}

pub fn advance(self: *Self) void {
    self.current_token = self.next_token;
    self.next_token = self.lexer.scan();
}

pub fn currentTokenIs(self: *Self, t: Token.TokenType) bool {
    return @intFromEnum(self.current_token.t) == @intFromEnum(t);
}

pub fn nextTokenIs(self: *Self, t: Token.TokenType) bool {
    return @intFromEnum(self.next_token.t) == @intFromEnum(t);
}
