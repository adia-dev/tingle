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
    try lexer.keywords.put("return", {});
    try lexer.keywords.put("unless", {});
    try lexer.keywords.put("and", {});
    try lexer.keywords.put("or", {});
    try lexer.keywords.put("defer", {});
    try lexer.keywords.put("match", {});
    try lexer.keywords.put("true", {});
    try lexer.keywords.put("false", {});

    lexer.advance();

    return lexer;
}

pub fn scan(self: *Self) Token {
    self.eat_whitespace();

    var token = Token.init(TokenType.Illegal, .{ .line = self.line, .column = self.position - self.last_line_position });

    switch (self.c) {
        'a'...'z', 'A'...'Z' => {
            const identifier = self.scan_identifier();

            if (self.keywords.contains(identifier)) {
                token.t = .{ .Keyword = identifier };
            } else {
                token.t = .{ .Identifier = identifier };
            }

            return token;
        },
        '0'...'9' => {
            const number = self.scan_number();

            token.t = .{ .Number = number };
            return token;
        },
        0 => {
            token.t = .Eof;
        },
        '+' => {
            if (self.scan_expected_compound_token(&token, "=", .PlusEqual)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, "+", .PlusPlus)) {
                return token;
            }
            token.t = .Plus;
        },
        '-' => {
            if (self.scan_expected_compound_token(&token, "=", .MinusEqual)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, "-", .MinusMinus)) {
                return token;
            }
            token.t = .Minus;
        },
        '*' => {
            if (self.scan_expected_compound_token(&token, "=", .StarEqual)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, "*", .StarStar)) {
                return token;
            }
            token.t = .Star;
        },
        '/' => {
            switch (self.peek()) {
                '/' => {
                    self.advance();
                    self.advance();

                    const comment = self.scan_single_line_comment();
                    token.t = .{ .CommentSingleLine = comment };

                    return token;
                },
                '*' => {
                    self.advance();
                    self.advance();

                    const comment = self.scan_multi_line_comment();
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
            if (self.scan_expected_compound_token(&token, "=", .PercentEqual)) {
                return token;
            }
            token.t = .Percent;
        },
        '^' => {
            if (self.scan_expected_compound_token(&token, "=", .CaretEqual)) {
                return token;
            }
            token.t = .Caret;
        },
        '!' => {
            if (self.scan_expected_compound_token(&token, "=", .NotEqual)) {
                return token;
            }
            token.t = .Bang;
        },
        '&' => {
            if (self.scan_expected_compound_token(&token, "&", .LogicalAnd)) {
                return token;
            }
            token.t = .Ampersand;
        },
        '|' => {
            if (self.scan_expected_compound_token(&token, "|", .LogicalOr)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, ">", .Piped)) {
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
            if (self.scan_expected_compound_token(&token, "=", .EqualEqual)) {
                return token;
            }
            token.t = .Equal;
        },
        '>' => {
            if (self.scan_expected_compound_token(&token, "=", .GreaterEqual)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, ">", .ShiftRight)) {
                return token;
            }
            token.t = .GreaterThan;
        },
        '<' => {
            if (self.scan_expected_compound_token(&token, "=", .LessEqual)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, "<", .ShiftLeft)) {
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
            if (self.scan_expected_compound_token(&token, "..", .DotDotDot)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, ".", .DotDot)) {
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
            if (self.scan_expected_compound_token(&token, ":", .PathSep)) {
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
            if (self.scan_expected_compound_token(&token, ":", .Elvis)) {
                return token;
            } else if (self.scan_expected_compound_token(&token, "?", .NullCoalesce)) {
                return token;
            }
            token.t = .Question;
        },
        '~' => {
            token.t = .Tilde;
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

fn scan_expected_compound_token(self: *Self, token: *Token, expected_literal: []const u8, expected_type: TokenType) bool {
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
