const std = @import("std");
const Self = @This();
const Token = @import("../token/token.zig");
const Keyword = Token.Keyword;

input: []const u8,
position: usize = 0,
next_position: usize = 0,
last_line_position: usize = 0,
line: usize = 1,
c: u8 = 0,

pub fn init(input: []const u8) Self {
    var lexer = Self{ .input = input };

    lexer.advance();

    return lexer;
}

pub fn scan(self: *Self) !Token {
    self.skip_whitespaces();

    var token = Token{ .row = self.line, .column = self.position - self.last_line_position };

    switch (self.c) {
        0 => {
            token.type = .eof;
        },
        '+' => {
            if (self.scan_compound_token("+")) {
                token.type = .plusPlus;
            } else if (self.scan_compound_token("=")) {
                token.type = .plusEq;
            } else {
                token.type = .plus;
            }
        },
        '-' => {
            if (self.scan_compound_token("-")) {
                token.type = .minusMinus;
            } else if (self.scan_compound_token(">")) {
                token.type = .rArrow;
            } else if (self.scan_compound_token("=")) {
                token.type = .minusEq;
            } else {
                token.type = .minus;
            }
        },
        '*' => {
            if (self.scan_compound_token("*")) {
                token.type = .starStar;
            } else if (self.scan_compound_token("=")) {
                token.type = .starEq;
            } else {
                token.type = .star;
            }
        },
        '/' => {
            if (self.scan_compound_token("/")) {
                token.type = .fSlashFSlash;
            } else if (self.scan_compound_token("=")) {
                token.type = .fSlashEq;
            } else {
                token.type = .fSlash;
            }
        },
        '%' => {
            token.type = .percent;
        },
        '^' => {
            if (self.scan_compound_token("=")) {
                token.type = .caretEq;
            } else {
                token.type = .caret;
            }
        },
        '!' => {
            if (self.scan_compound_token("=")) {
                token.type = .neq;
            } else {
                token.type = .bang;
            }
        },
        '&' => {
            if (self.scan_compound_token("&")) {
                token.type = .bitAnd;
            } else {
                token.type = .ampersand;
            }
        },
        '|' => {
            if (self.scan_compound_token(">")) {
                token.type = .piped;
            } else if (self.scan_compound_token("|")) {
                token.type = .bitOr;
            } else {
                token.type = .pipe;
            }
        },
        '=' => {
            if (self.scan_compound_token("=")) {
                token.type = .eqEq;
            } else if (self.scan_compound_token(">")) {
                token.type = .fatArrow;
            } else {
                token.type = .eq;
            }
        },
        '>' => {
            if (self.scan_compound_token(">=")) {
                token.type = .shiftRightEq;
            } else if (self.scan_compound_token("=")) {
                token.type = .geq;
            } else if (self.scan_compound_token(">")) {
                token.type = .shiftRight;
            } else {
                token.type = .gt;
            }
        },
        '<' => {
            if (self.scan_compound_token("<=")) {
                token.type = .shiftLeftEq;
            } else if (self.scan_compound_token("<")) {
                token.type = .leq;
            } else if (self.scan_compound_token("<")) {
                token.type = .shiftLeft;
            } else {
                token.type = .lt;
            }
        },
        '@' => {
            token.type = .at;
        },
        '_' => {
            token.type = .underscore;
        },
        '.' => {
            if (self.scan_compound_token("..")) {
                token.type = .dotDotDot;
            } else if (self.scan_compound_token(".=")) {
                token.type = .dotDotEq;
            } else if (self.scan_compound_token(".")) {
                token.type = .dotDot;
            } else {
                token.type = .dot;
            }
        },
        ',' => {
            token.type = .comma;
        },
        ';' => {
            token.type = .semicolon;
        },
        ':' => {
            if (self.scan_compound_token(":")) {
                token.type = .pathSep;
            } else {
                token.type = .colon;
            }
        },
        '#' => {
            token.type = .pound;
        },
        '$' => {
            token.type = .dollar;
        },
        '?' => {
            token.type = .question;
        },
        '~' => {
            token.type = .tilde;
        },
        '(' => {
            token.type = .lparen;
        },
        ')' => {
            token.type = .rparen;
        },
        '{' => {
            token.type = .lbrace;
        },
        '}' => {
            token.type = .rbrace;
        },
        '[' => {
            token.type = .lbrack;
        },
        ']' => {
            token.type = .rbrack;
        },
        '\'' => {
            token.type = .quote;
        },
        '"' => {
            var string = self.scan_string();

            token.type = .{ .string = string };
        },
        'a'...'z', 'A'...'Z' => {
            var identifier = self.scan_identifier();

            if (Keyword.from_str(identifier)) |kw| {
                token.type = .{ .keyword = kw };
            } else {
                token.type = .{ .identifier = identifier };
            }

            return token;
        },
        '0'...'9' => {
            var number = self.scan_number();
            token.type = .{ .number = number };
            return token;
        },
        else => {},
    }

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

fn scan_string(self: *Self) []const u8 {
    // skip first quote
    self.advance();

    const position = self.position;

    while (self.c != 0 and self.c != '\"') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scan_compound_token(self: *Self, expected_sequence: []const u8) bool {
    const position = self.position;
    const next_position = self.next_position;

    for (0..expected_sequence.len) |i| {
        if (self.peek() != expected_sequence[i]) {
            self.position = position;
            self.next_position = next_position;

            return false;
        }

        self.advance();
    }

    return true;
}

fn peek(self: *Self) u8 {
    if (self.next_position >= self.input.len) {
        return 0;
    }

    return self.input[self.next_position];
}

fn skip_whitespaces(self: *Self) void {
    while (true) : (self.advance()) {
        switch (self.c) {
            ' ', '\t' => {},
            '\n', '\r' => {
                self.last_line_position = self.position;
                self.line += 1;
            },
            else => break,
        }
    }
}

fn advance(self: *Self) void {
    if (self.next_position >= self.input.len) {
        self.c = 0;
    } else {
        self.c = self.input[self.next_position];
    }

    self.position = self.next_position;
    self.next_position += 1;
}
