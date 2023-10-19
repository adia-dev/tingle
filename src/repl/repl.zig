const Lexer = @import("../lexer/lexer.zig");
const Token = @import("../token/token.zig");
const c = @cImport({
    @cInclude("readline/readline.h");
    @cInclude("readline/history.h");
    @cInclude("stdlib.h");
    @cInclude("memory.h");
});
const std = @import("std");
const StringHashMap = std.StringHashMap;
const Self = @This();

pub const Command = struct { name: []const u8, fun: *const fn () void, doc: ?[]const u8 };

commands: StringHashMap(Command) = undefined,
i: usize = 1,
input: []const u8 = undefined,
c_input: [*c]u8 = undefined,
allocator: std.mem.Allocator,
prompt_buf: [256]u8 = undefined,
done: bool = false,

pub fn init(allocator: std.mem.Allocator) Self {
    var repl = Self{ .allocator = allocator };

    repl.commands = StringHashMap(Command).init(allocator);

    return repl;
}

pub fn deinit(self: *Self) void {
    self.commands.deinit();
}

pub fn start(self: *Self) !void {
    while (!self.done) {
        defer c.free(self.c_input);

        @memset(self.prompt_buf[0..], 0);
        _ = try std.fmt.bufPrint(self.prompt_buf[0..], "tingle({d})> ", .{self.i});

        try self.read();
        try self.eval();

        self.i += 1;
    }
}

fn read(self: *Self) !void {
    self.c_input = c.readline(self.prompt_buf[0..]);
    self.input = std.mem.span(self.c_input);

    if (self.input.len > 0) {
        _ = c.add_history(self.c_input);
    }
}

fn eval(self: *Self) !void {
    var lexer = Lexer.init(self.input);
    var token = try lexer.scan();
    while (token.type != .eof and token.type != .illegal) : (token = try lexer.scan()) {
        const token_str = try token.to_string(self.allocator);
        defer self.allocator.free(token_str);

        std.debug.print("{s}\n", .{token_str});
    }
}
