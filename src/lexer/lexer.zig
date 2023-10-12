const std = @import("std");
const Self = @This();
const Token = @import("../token/token.zig");
const TokenType = Token.TokenType;
const Keyword = Token.Keyword;

position: usize = 0,
next_position: usize = 0,
c: u8 = 0,
line: usize = 1,
last_line_position: usize = 0,
input: []const u8,

keywords: std.StringHashMap(Keyword) = undefined,

pub fn init(input: []const u8, allocator: std.mem.Allocator) !Self {
    var lexer = Self{ .input = input };

    lexer.keywords = std.StringHashMap(Keyword).init(allocator);

    try lexer.keywords.put("this", .This);

    try lexer.keywords.put("fn", .Fn);
    try lexer.keywords.put("struct", .Struct);
    try lexer.keywords.put("enum", .Enum);
    try lexer.keywords.put("union", .Union);

    try lexer.keywords.put("let", .Let);
    try lexer.keywords.put("const", .Const);
    try lexer.keywords.put("var", .Var);

    try lexer.keywords.put("if", .If);
    try lexer.keywords.put("else", .Else);
    try lexer.keywords.put("unless", .Unless);

    try lexer.keywords.put("for", .For);
    try lexer.keywords.put("while", .While);

    try lexer.keywords.put("return", .Return);

    try lexer.keywords.put("and", .And);
    try lexer.keywords.put("or", .Or);

    try lexer.keywords.put("defer", .Defer);

    try lexer.keywords.put("match", .Match);

    try lexer.keywords.put("true", .True);
    try lexer.keywords.put("false", .False);

    lexer.advance();

    return lexer;
}

pub fn deinit(self: *Self) void {
    self.keywords.deinit();
}

pub fn scan(self: *Self) Token {
    self.eatWhitespace();

    var token = Token.init(TokenType.Illegal, .{ .line = self.line, .column = self.position - self.last_line_position });

    switch (self.c) {
        'a'...'z', 'A'...'Z' => {
            const identifier = self.scanIdentifier();

            if (self.keywords.get(identifier)) |kw| {
                token.t = .{ .Keyword = kw };
            } else {
                token.t = .{ .Identifier = identifier };
            }

            return token;
        },
        '0'...'9' => {
            const number = self.scanNumber();

            token.t = .{ .Number = number };
            return token;
        },
        0 => {
            token.t = .Eof;
        },
        '+' => {
            if (self.scanExpectedCompoundToken(&token, "=", .PlusEqual)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, "+", .PlusPlus)) {
                return token;
            }
            token.t = .Plus;
        },
        '-' => {
            if (self.scanExpectedCompoundToken(&token, "=", .MinusEqual)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, "-", .MinusMinus)) {
                return token;
            }
            token.t = .Minus;
        },
        '*' => {
            if (self.scanExpectedCompoundToken(&token, "=", .StarEqual)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, "*", .StarStar)) {
                return token;
            }
            token.t = .Star;
        },
        '/' => {
            switch (self.peek()) {
                '/' => {
                    self.advance();
                    self.advance();

                    const comment = self.scanSingleLineComment();
                    token.t = .{ .CommentSingleLine = comment };

                    return token;
                },
                '*' => {
                    self.advance();
                    self.advance();

                    const comment = self.scanMultiLineComment();
                    token.t = .{ .CommentMultiLine = comment };

                    self.advance();
                    self.advance();

                    return token;
                },
                else => {
                    token.t = .ForwardSlash;
                },
            }
        },
        '\\' => {
            token.t = .BackSlash;
        },
        '%' => {
            if (self.scanExpectedCompoundToken(&token, "=", .PercentEqual)) {
                return token;
            }
            token.t = .Percent;
        },
        '^' => {
            if (self.scanExpectedCompoundToken(&token, "=", .CaretEqual)) {
                return token;
            }
            token.t = .Caret;
        },
        '!' => {
            if (self.scanExpectedCompoundToken(&token, "=", .NotEqual)) {
                return token;
            }
            token.t = .Bang;
        },
        '&' => {
            if (self.scanExpectedCompoundToken(&token, "&", .LogicalAnd)) {
                return token;
            }
            token.t = .Ampersand;
        },
        '|' => {
            if (self.scanExpectedCompoundToken(&token, "|", .LogicalOr)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, ">", .Piped)) {
                return token;
            }
            token.t = .Pipe;
        },
        '\'' => {
            token.t = .Quote;
        },
        '"' => {
            token.t = .DoubleQuote;
        },
        '(' => {
            token.t = .LeftParen;
        },
        ')' => {
            token.t = .RightParen;
        },
        '[' => {
            token.t = .LeftBracket;
        },
        ']' => {
            token.t = .RightBracket;
        },
        '{' => {
            token.t = .LeftBrace;
        },
        '}' => {
            token.t = .RightBrace;
        },
        '=' => {
            if (self.scanExpectedCompoundToken(&token, "=", .EqualEqual)) {
                return token;
            }
            token.t = .Equal;
        },
        '>' => {
            if (self.scanExpectedCompoundToken(&token, "=", .GreaterEqual)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, ">", .ShiftRight)) {
                return token;
            }
            token.t = .GreaterThan;
        },
        '<' => {
            if (self.scanExpectedCompoundToken(&token, "=", .LessEqual)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, "<", .ShiftLeft)) {
                return token;
            }
            token.t = .LessThan;
        },
        '@' => {
            token.t = .At;
        },
        '_' => {
            token.t = .Underscore;
        },
        '.' => {
            if (self.scanExpectedCompoundToken(&token, "..", .DotDotDot)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, ".", .DotDot)) {
                return token;
            }
            token.t = .Dot;
        },
        ',' => {
            token.t = .Comma;
        },
        ';' => {
            token.t = .SemiColon;
        },
        ':' => {
            if (self.scanExpectedCompoundToken(&token, ":", .PathSep)) {
                return token;
            }
            token.t = .Colon;
        },
        '#' => {
            token.t = .Pound;
        },
        '$' => {
            token.t = .Dollar;
        },
        '?' => {
            if (self.scanExpectedCompoundToken(&token, ":", .Elvis)) {
                return token;
            } else if (self.scanExpectedCompoundToken(&token, "?", .NullCoalesce)) {
                return token;
            }
            token.t = .Question;
        },
        '~' => {
            token.t = .Tilde;
        },
        else => {},
    }

    self.eatNewspace();
    self.advance();

    return token;
}

fn scanIdentifier(self: *Self) []const u8 {
    const position = self.position;

    while (std.ascii.isAlphanumeric(self.c) or self.c == '_') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scanNumber(self: *Self) []const u8 {
    const position = self.position;

    while (std.ascii.isDigit(self.c) or self.c == '_') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scanSingleLineComment(self: *Self) []const u8 {
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

fn scanMultiLineComment(self: *Self) []const u8 {
    const position = self.position;

    while (true) : (self.advance()) {
        if (self.c == '*' and self.peek() == '/') {
            break;
        }
    }

    return self.input[position..self.position];
}

fn scanStringLiteral(self: *Self) []const u8 {
    const position = self.position;

    while (true) : (self.advance()) {
        if (self.c != '\\' and self.peek() == '"') {
            break;
        }
    }

    self.advance();

    return self.input[position..self.position];
}

fn eatWhitespace(self: *Self) void {
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
fn eatNewspace(self: *Self) void {
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

fn scanExpectedCompoundToken(self: *Self, token: *Token, expected_literal: []const u8, expected_type: TokenType) bool {
    const position = self.position;
    const next_position = self.next_position;

    for (0..expected_literal.len) |i| {
        if (self.peek() != expected_literal[i]) {
            self.*.position = position;
            self.*.next_position = next_position;
            return false;
        }

        self.advance();
    }

    self.advance();

    token.*.t = expected_type;

    return true;
}
