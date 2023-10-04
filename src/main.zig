const std = @import("std");
const input = @embedFile("./examples/sample_1.tin");

const Lexer = @import("lexer.zig");

pub fn main() !void {
    var lexer = Lexer.init(input);

    var token = lexer.scan();

    while (token.t != .Eof) : (token = lexer.scan()) {
        token.print();
    }
}
