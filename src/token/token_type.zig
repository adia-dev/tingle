const std = @import("std");

pub const TokenType = union(enum) {
    illegal, // illegal or Unsupported token
    eof, // End of file
    identifier: []const u8, // e.g: name, age, i, ...
    keyword: Keyword, // e.g: name, age, i, ...
    number: Number, // e.g: name, age, i, ...

    // Punctuation
    plus, // +
    minus, // -
    star, // *
    forwardSlash, // /
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
    semi, // ;
    colon, // :
    pound, // #
    dollar, // $
    question, // ?
    tilde, // ~

    bitAnd, // &&
    bitOr, // ||
    shiftLeft, // <<
    shiftRight, // >>
    piped, // |>
    plusEq, // +=
    minusEq, // -=
    starEq, // *=
    forwardSlashEq, // /=
    percentEq, // %=
    caretEq, // ^=
    andEq, // &=
    orEq, // |=
    shiftLeftEq, // <<=
    shiftRightEq, // >>=
    equal, // ==
    neq, // !=
    geq, // >=
    leq, // <=
    dotDot, // ..
    dotDotDot, // ...
    dotDotEq, // ..=
    pathSep, // ::
    rArrow, // ->
    fatArrow, // =>

    pub fn to_string(self: TokenType) []const u8 {
        switch (self) {
            .keyword => |case| return case.to_string(),
            .number => |case| return case.to_string(),
            .identifier => |ident| return ident,
            else => |case| return @tagName(case),
        }
    }
};

pub const Number = union(enum) {
    char: u8,
    signed_char: i8,
    int: i32,
    unsigned_int: u32,
    short: i16,
    unsigned_short: u16,
    long: i64,
    unsigned_long: u64,

    pub fn to_string(self: Number) []const u8 {
        return @tagName(self);
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
