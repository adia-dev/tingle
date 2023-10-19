const std = @import("std");

pub const TokenType = union(enum) {
    illegal, // illegal or Unsupported token
    eof, // End of file
    identifier: []const u8, // e.g: name, age, i, ...
    string: []const u8, // e.g: "Abdoulaye Dia wrote\n this code.", "eheh", "", ...
    keyword: Keyword, // e.g: var, struct, defer, ...
    number: []const u8, // e.g: 1, 999_999, 1.0, ...

    // Punctuation
    plus, // +
    minus, // -
    star, // *
    fSlash, // /
    percent, // %
    caret, // ^
    bang, // !
    ampersand, // &
    pipe, // |
    eq, // =
    gt, // >
    lt, // <
    at, // @
    underscore, // _
    dot, // .
    comma, // ,
    semicolon, // ;
    colon, // :
    pound, // #
    dollar, // $
    question, // ?
    tilde, // ~

    lparen, // (
    rparen, // )
    lbrace, // {
    rbrace, // }
    lbrack, // [
    rbrack, // ]

    quote, // '
    dquote, // "

    bitAnd, // &&
    bitOr, // ||
    shiftLeft, // <<
    shiftRight, // >>
    piped, // |>
    plusEq, // +=
    minusEq, // -=
    starEq, // *=
    fSlashEq, // /=
    percentEq, // %=
    caretEq, // ^=
    andEq, // &=
    orEq, // |=
    shiftLeftEq, // <<=
    shiftRightEq, // >>=
    eqEq, // ==
    neq, // !=
    geq, // >=
    leq, // <=
    plusPlus, // ++
    minusMinus, // --
    starStar, // **
    fSlashFSlash, // //
    dotDot, // ..
    dotDotDot, // ...
    dotDotEq, // ..=
    pathSep, // ::
    rArrow, // ->
    fatArrow, // =>

    pub fn to_string(self: TokenType) []const u8 {
        switch (self) {
            .illegal, .eof => return "",

            .keyword => |case| return case.to_string(),
            .number => |number| return number,
            .string => |string| return string,
            .identifier => |ident| return ident,

            .plus => return "+",
            .minus => return "-",
            .star => return "*",
            .fSlash => return "/",
            .percent => return "%",
            .caret => return "^",
            .bang => return "!",
            .ampersand => return "&",
            .pipe => return "|",
            .eq => return "=",
            .gt => return ">",
            .lt => return "<",
            .at => return "@",
            .underscore => return "_",
            .dot => return ".",
            .comma => return ",",
            .semicolon => return ";",
            .colon => return ":",
            .pound => return "#",
            .dollar => return "$",
            .question => return "?",
            .tilde => return "~",

            .lparen => return "(",
            .rparen => return ")",
            .lbrace => return "{",
            .rbrace => return "}",
            .lbrack => return "[",
            .rbrack => return "]",

            .quote => return "'",
            .dquote => return "\"",

            .bitAnd => return "&&",
            .bitOr => return "||",
            .shiftLeft => return "<<",
            .shiftRight => return ">>",
            .piped => return "|>",
            .plusEq => return "+=",
            .minusEq => return "-=",
            .starEq => return "*=",
            .fSlashEq => return "/=",
            .percentEq => return "%=",
            .caretEq => return "^=",
            .andEq => return "&=",
            .orEq => return "|=",
            .shiftLeftEq => return "<<=",
            .shiftRightEq => return ">>=",
            .eqEq => return "==",
            .neq => return "!=",
            .geq => return ">=",
            .leq => return "<=",

            .plusPlus => return "++",
            .minusMinus => return "--",
            .starStar => return "**",
            .fSlashFSlash => return "//",
            .dotDot => return "..",
            .dotDotDot => return "...",
            .dotDotEq => return "..=",
            .pathSep => return "::",
            .rArrow => return "->",
            .fatArrow => return "=>",
        }
    }
};

pub const Keyword = enum {
    as,
    @"break",
    @"const",
    @"continue",
    crate,
    @"else",
    @"enum",
    @"export",
    @"extern",
    false,
    @"fn",
    @"for",
    @"if",
    impl,
    import,
    in,
    let,
    loop,
    match,
    mod,
    move,
    mut,
    null,
    @"pub",
    ref,
    @"return",
    self,
    static,
    @"struct",
    super,
    trait,
    true,
    type,
    unsafe,
    use,
    @"var",
    where,
    @"while",

    pub fn from_str(kw_str: []const u8) ?Keyword {
        inline for (@typeInfo(Keyword).Enum.fields) |f| {
            if (std.mem.eql(u8, kw_str, f.name)) {
                return @field(Keyword, f.name);
            }
        }

        return null;
    }

    pub fn to_string(self: Keyword) []const u8 {
        return @tagName(self);
    }
};
