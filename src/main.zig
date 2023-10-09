const std = @import("std");
const REPL = @import("./repl/repl.zig");
const Lexer = @import("./lexer/lexer.zig");

pub fn main() !void {
    var repl = REPL.init(std.heap.page_allocator);
    try repl.start();
}

test {
    @import("std").testing.refAllDecls(@This());
}
