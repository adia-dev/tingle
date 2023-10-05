const std = @import("std");
const input = @embedFile("./examples/sample_1.tin");

const Lexer = @import("lexer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var lexer = try Lexer.init(input, arena.allocator());

    var token = lexer.scan();

    while (token.t != .Eof) : (token = lexer.scan()) {
        token.print();
    }
}
