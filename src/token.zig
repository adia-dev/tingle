const std = @import("std");
const Self = @This();

pub const TokenType = union(enum) {
    // Keywords
    // These are reserved words in the language.
    // Examples: fn, struct, let, if, else, for, while, return, etc.
    Keyword: []const u8,
    // Identifiers
    // Tokens representing user-defined names.
    Identifier,

    // Literals
    // These tokens represent literal values in the code.
    LiteralInt, // Integer literals, e.g., 42
    LiteralFloat, // Floating-point literals, e.g., 3.14
    LiteralChar, // String char, e.g., 'a'
    LiteralString, // String literals, e.g., "Hello, World!"

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
    Increment, // ++
    Decrement, // --
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
literal: []const u8,
line: ?usize = null,
column: ?usize = null,

pub const TokenOptions = struct {
    line: ?usize = null,
    column: ?usize = null,
};

pub fn init(t: TokenType, literal: []const u8, options: TokenOptions) Self {
    return Self{
        .t = t,
        .literal = literal,
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
        self.literal,
        self.line,
        self.column,
    });
}
