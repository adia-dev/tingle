const std = @import("std");
const REPL = @import("./repl/repl.zig");
const Lexer = @import("./lexer/lexer.zig");

pub fn main() !void {
    try REPL.start();
}

test {
    @import("std").testing.refAllDecls(@This());
}
