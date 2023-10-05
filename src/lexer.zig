const std = @import("std");
const Self = @This();
const Token = @import("token.zig");
const TokenType = Token.TokenType;

position: usize = 0,
next_position: usize = 0,
c: u8 = 0,
line: usize = 1,
last_line_position: usize = 0,
input: []const u8,

keywords: std.StringHashMap(void) = undefined,

pub fn init(input: []const u8, allocator: std.mem.Allocator) !Self {
    var lexer = Self{ .input = input };

    lexer.keywords = std.StringHashMap(void).init(allocator);

    try lexer.keywords.put("this", {});
    try lexer.keywords.put("fn", {});
    try lexer.keywords.put("struct", {});
    try lexer.keywords.put("let", {});
    try lexer.keywords.put("var", {});
    try lexer.keywords.put("if", {});
    try lexer.keywords.put("else", {});
    try lexer.keywords.put("for", {});
    try lexer.keywords.put("while", {});
    try lexer.keywords.put("eturn", {});
    try lexer.keywords.put("unless", {});
    try lexer.keywords.put("and", {});
    try lexer.keywords.put("or", {});

    lexer.advance();

    return lexer;
}

pub fn scan(self: *Self) Token {
    self.eat_whitespace();

    var token = Token.init(TokenType.Illegal, "", .{ .line = self.line, .column = self.position - self.last_line_position });

    switch (self.c) {
        'a'...'z', 'A'...'Z' => {
            const identifier = self.scan_identifier();

            if (self.keywords.contains(identifier)) {
                token.t = .{ .Keyword = identifier };
                token.literal = identifier;
            } else {
                token.t = .Identifier;
                token.literal = identifier;
            }
        },
        '0'...'9' => {
            const number = self.scan_number();

            token.t = .LiteralInt;
            token.literal = number;
        },
        0 => {
            token.t = .Eof;
        },
        '+' => {
            token.t = .Plus;
            token.literal = "+";
        },
        '-' => {
            token.t = .Minus;
            token.literal = "-";
        },
        '*' => {
            token.t = .Star;
            token.literal = "*";
        },
        '/' => {
            switch (self.peek()) {
                '/' => {
                    self.advance();
                    self.advance();

                    const comment = self.scan_single_line_comment();
                    token.t = .{ .CommentSingleLine = comment };
                    token.literal = comment;

                    return token;
                },
                '*' => {
                    self.advance();
                    self.advance();

                    const comment = self.scan_multi_line_comment();
                    token.t = .{ .CommentMultiLine = comment };
                    token.literal = comment;

                    self.advance();
                    self.advance();

                    return token;
                },
                else => {
                    token.t = .ForwardSlash;
                    token.literal = "/";
                },
            }
        },
        '\\' => {
            token.t = .BackSlash;
            token.literal = "\\";
        },
        '%' => {
            token.t = .Percent;
            token.literal = "%";
        },
        '^' => {
            token.t = .Caret;
            token.literal = "^";
        },
        '!' => {
            token.t = .Bang;
            token.literal = "!";
        },
        '&' => {
            token.t = .Ampersand;
            token.literal = "&";
        },
        '|' => {
            token.t = .Pipe;
            token.literal = "|";
        },
        '\'' => {
            token.t = .Quote;
            token.literal = "'";
        },
        '"' => {
            token.t = .DoubleQuote;
            token.literal = "\"";
        },
        '(' => {
            token.t = .LeftParen;
            token.literal = "(";
        },
        ')' => {
            token.t = .RightParen;
            token.literal = ")";
        },
        '[' => {
            token.t = .LeftBracket;
            token.literal = "[";
        },
        ']' => {
            token.t = .RightBracket;
            token.literal = "]";
        },
        '{' => {
            token.t = .LeftBrace;
            token.literal = "{";
        },
        '}' => {
            token.t = .RightBrace;
            token.literal = "}";
        },
        '=' => {
            token.t = .Equal;
            token.literal = "=";
        },
        '>' => {
            token.t = .GreaterThan;
            token.literal = ">";
        },
        '<' => {
            token.t = .LessThan;
            token.literal = "<";
        },
        '@' => {
            token.t = .At;
            token.literal = "@";
        },
        '_' => {
            token.t = .Underscore;
            token.literal = "_";
        },
        '.' => {
            token.t = .Dot;
            token.literal = ".";
        },
        ',' => {
            token.t = .Comma;
            token.literal = ",";
        },
        ';' => {
            token.t = .SemiColon;
            token.literal = ";";
        },
        ':' => {
            token.t = .Colon;
            token.literal = ":";
        },
        '#' => {
            token.t = .Pound;
            token.literal = "#";
        },
        '$' => {
            token.t = .Dollar;
            token.literal = "$";
        },
        '?' => {
            token.t = .Question;
            token.literal = "?";
        },
        '~' => {
            token.t = .Tilde;
            token.literal = "~";
        },
        else => {},
    }

    self.eat_newspace();
    self.advance();

    return token;
}

fn scan_identifier(self: *Self) []const u8 {
    const position = self.position;

    while (std.ascii.isAlphanumeric(self.c) or self.c == '_') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scan_number(self: *Self) []const u8 {
    const position = self.position;

    while (std.ascii.isDigit(self.c) or self.c == '_') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scan_single_line_comment(self: *Self) []const u8 {
    const position = self.position;

    while (true) {
        switch (self.c) {
            '\r', '\n' => {
                break;
            },
            else => {
                self.advance();
            },
        }
    }

    return self.input[position..self.position];
}

fn scan_multi_line_comment(self: *Self) []const u8 {
    const position = self.position;

    while (true) : (self.advance()) {
        if (self.c == '*' and self.peek() == '/') {
            break;
        }
    }

    return self.input[position..self.position];
}

fn scan_string_literal(self: *Self) []const u8 {
    const position = self.position;

    while (true) : (self.advance()) {
        if (self.c != '\\' and self.peek() == '"') {
            break;
        }
    }

    self.advance();

    return self.input[position..self.position];
}

fn eat_whitespace(self: *Self) void {
    while (true) : (self.advance()) {
        switch (self.c) {
            ' ',
            '\t',
            => {},
            '\r', '\n' => {
                self.*.line += 1;
                self.*.last_line_position = self.position;
            },
            else => {
                break;
            },
        }
    }
}
fn eat_newspace(self: *Self) void {
    while (true) : (self.advance()) {
        switch (self.c) {
            '\r', '\n' => {
                self.*.line += 1;
                self.*.last_line_position = self.position;
            },
            else => {
                break;
            },
        }
    }
}

fn advance(self: *Self) void {
    if (self.next_position >= self.input.len) {
        self.c = 0;
    } else {
        self.*.c = self.input[self.next_position];
    }

    self.*.position = self.next_position;
    self.*.next_position += 1;
}

fn peek(self: *Self) u8 {
    if (self.next_position >= self.input.len) {
        return 0;
    } else {
        return self.input[self.next_position];
    }
}
