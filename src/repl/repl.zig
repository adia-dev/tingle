const std = @import("std");
const Lexer = @import("../lexer/lexer.zig");
const Self = @This();

const c = @cImport({
    @cInclude("readline/readline.h");
    @cInclude("readline/history.h");
    @cInclude("memory.h");
    @cInclude("stdlib.h");
});

allocator: std.mem.Allocator,
input: [*c]u8 = undefined,
i: usize = 1,
prompt_buf: []u8 = undefined,
process: bool = true,

pub fn init(allocator: std.mem.Allocator) Self {
    _ = c.rl_initialize();
    return Self{ .allocator = allocator };
}

pub fn deinit(self: *Self) void {
    _ = self;
    c.rl_cleanup_after_signal();
}

pub fn start(self: *Self) !void {
    while (self.process) {
        defer c.free(self.*.input);

        try self.read();
        try self.eval();
    }
}

fn read(self: *Self) !void {
    _ = try std.io.getStdOut().writer().print("Tingle({d})> ", .{self.i});
    self.*.input = c.readline("");

    self.*.i += 1;
}

fn eval(self: *Self) !void {
    const len = @as(usize, c.strlen(self.input));
    var lexer = try Lexer.init(self.input[0..len], self.allocator);
    defer lexer.deinit();

    var token = lexer.scan();
    while (token.t != .Eof and token.t != .Illegal) : (token = lexer.scan()) {
        try token.print();
    }
}
