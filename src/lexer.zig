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

pub fn init(input: []const u8) Self {
    var lexer = Self{ .input = input };

    lexer.advance();

    return lexer;
}

pub fn scan(self: *Self) Token {
    self.eat_whitespace();

    var token = Token.init(TokenType.Illegal, "", .{ .line = self.line, .column = self.position - self.last_line_position });

    switch (self.c) {
        'a'...'z', 'A'...'Z' => {
            const identifier = self.scan_identifier();

            token.t = .Identifier;
            token.literal = identifier;
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
                    const comment = self.scan_single_line_comment();
                    token.t = .{ .CommentSingleLine = comment };
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

fn scan_single_line_comment(self: *Self) []const u8 {
    const position = self.position;

    while (self.c != 0 or self.c != '\n' or self.c != '\r') : (self.advance()) {}

    return self.input[position..self.position];
}

fn scan_multi_line_comment(self: *Self) []const u8 {
    const position = self.position;

    while (self.c != 0 or (self.c != '*' and self.peek() != '/')) : (self.advance()) {}

    return self.input[position..self.position];
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
