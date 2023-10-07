const std = @import("std");
const Self = @This();

pub const TokenType = union(enum) {
    // Keywords
    // These are reserved words in the language.
    // Examples: fn, struct, let, if, else, for, while, return, etc.
    Keyword: []const u8,
    // Identifiers
    // Tokens representing user-defined names.
    Identifier: []const u8,

    // Literals
    // These tokens represent literal values in the code.
    Number: []const u8,

    LiteralChar: []const u8, // String char, e.g., 'a'
    LiteralString: []const u8, // String literals, e.g., "Hello, World!"

    Plus, // +
    Minus, // -
    Star, // *
    ForwardSlash, // /
    BackSlash, // \
    Percent, // %
    Caret, // ^
    Bang, // !
    Ampersand, // &
    Pipe, // |
    Quote, // '
    DoubleQuote, // "
    LeftParen, // (
    RightParen, // )
    LeftBracket, // [
    RightBracket, // ]
    LeftBrace, // {
    RightBrace, // }
    LogicalAnd, // &&
    LogicalOr, // ||
    PlusPlus, // ++
    MinusMinus, // --
    StarStar, // **
    ShiftLeft, // <<
    ShiftRight, // >>
    PlusEqual, // +=
    MinusEqual, // -=
    StarEqual, // *=
    SlashEqual, // /=
    PercentEqual, // %=
    CaretEqual, // ^=
    AndEqual, // &=
    OrEqual, // |=
    ShiftLeftEqual, // <<=
    ShiftRightEqual, // >>=
    Equal, // =
    EqualEqual, // ==
    NotEqual, // !=
    GreaterThan, // >
    LessThan, // <
    GreaterEqual, // >=
    LessEqual, // <=
    At, // @
    Underscore, // _
    Dot, // .
    DotDot, // ..
    DotDotDot, // ...
    DotDotEq, // ..=
    Comma, // ,
    SemiColon, // ;
    Colon, // :
    PathSep, // ::
    RightArrow, // ->
    ObeseArrow, // =>
    Pound, // #
    Dollar, // $
    Question, // ?
    NullCoalesce, // ??
    Elvis, // ?:
    Piped, // |>
    Tilde, // ~

    // Comments
    CommentSingleLine: []const u8, // //
    CommentMultiLine: []const u8, // /*

    Eof, // End of File
    Illegal, // Illegal tokens
};

t: TokenType,
line: ?usize = null,
column: ?usize = null,

pub const TokenOptions = struct {
    line: ?usize = null,
    column: ?usize = null,
};

pub fn init(t: TokenType, options: TokenOptions) Self {
    return Self{
        .t = t,
        .line = options.line,
        .column = options.column,
    };
}

pub fn print(self: *Self) void {
    std.debug.print(
        \\ Token:
        \\     - type: {s}
        \\     - literal: {s}
        \\     - line: {?d}
        \\     - column: {?d}
        \\
    , .{
        @tagName(self.t),
        self.literal(),
        self.line,
        self.column,
    });
}

pub fn literal(self: *Self) []const u8 {
    switch (self.t) {
        .Keyword => |kw| return kw,
        .Identifier => |ident| return ident,
        .Number => |number| return number,
        .LiteralString => |string| return string,
        .LiteralChar => |c| return c,
        .CommentSingleLine => |comment| return comment,
        .CommentMultiLine => |comment| return comment,
        .Plus => return "+",
        .Minus => return "-",
        .Star => return "*",
        .ForwardSlash => return "/",
        .BackSlash => return "\\",
        .Percent => return "%",
        .Caret => return "^",
        .Bang => return "!",
        .Ampersand => return "&",
        .Pipe => return "|",
        .Quote => return "'",
        .DoubleQuote => return "\"",
        .LeftParen => return "(",
        .RightParen => return ")",
        .LeftBracket => return "[",
        .RightBracket => return "]",
        .LeftBrace => return "{",
        .RightBrace => return "}",
        .LogicalAnd => return "&&",
        .LogicalOr => return "||",
        .PlusPlus => return "++",
        .MinusMinus => return "--",
        .StarStar => return "**",
        .ShiftLeft => return "<<",
        .ShiftRight => return ">>",
        .PlusEqual => return "+=",
        .MinusEqual => return "-=",
        .StarEqual => return "*=",
        .SlashEqual => return "/=",
        .PercentEqual => return "%=",
        .CaretEqual => return "^=",
        .AndEqual => return "&=",
        .OrEqual => return "|=",
        .ShiftLeftEqual => return "<<=",
        .ShiftRightEqual => return ">>=",
        .Equal => return "=",
        .EqualEqual => return "==",
        .NotEqual => return "!=",
        .GreaterThan => return ">",
        .LessThan => return "<",
        .GreaterEqual => return ">=",
        .LessEqual => return "<=",
        .At => return "@",
        .Underscore => return "_",
        .Dot => return ".",
        .DotDot => return "..",
        .DotDotDot => return "...",
        .DotDotEq => return "..=",
        .Comma => return ",",
        .SemiColon => return ";",
        .Colon => return ":",
        .PathSep => return "::",
        .RightArrow => return "->",
        .ObeseArrow => return "=>",
        .Pound => return "#",
        .Dollar => return "$",
        .Question => return "?",
        .NullCoalesce => return "??",
        .Elvis => return "?:",
        .Piped => return "|>",
        .Tilde => return "~",
        .Eof => return "End Of File",
        .Illegal => return "Illegal",
    }
}
