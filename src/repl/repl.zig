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

    c.rl_attempted_completion_function = &custom_completion;

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

    _ = c.add_history(self.*.input);

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

pub export fn custom_completion_generator(arg_text: [*c]const u8, arg_state: c_int) [*c]u8 {
    var text = arg_text;
    var state = arg_state;

    const list_index = struct {
        var static: usize = 0;
    };

    const len = struct {
        var static: usize = 0;
    };

    var completions: [2][*c]const u8 = [2][*c]const u8{
        "apple",
        "banana",
    };

    if (state == @as(c_int, 0)) {
        list_index.static = 0;
        len.static = @sizeOf([2][*c]const u8) / @sizeOf([*c]const u8);
    }
    while (list_index.static < len.static) {
        if (c.strncmp(completions[list_index.static], text, c.strlen(text)) == @as(c_int, 0)) {
            return c.strdup(completions[
                blk: {
                    const ref = &list_index.static;
                    const tmp = ref.*;
                    ref.* +%= 1;
                    break :blk tmp;
                }
            ]);
        }
        list_index.static +%= 1;
    }
    return null;
}

pub export fn custom_completion(arg_text: [*c]const u8, arg_start: c_int, arg_end: c_int) [*c][*c]u8 {
    var end = arg_end;
    var completions: [2][*c]const u8 = [2][*c]const u8{
        "apple",
        "banana",
    };
    var matches: [*c][*c]u8 = null;
    {
        var i: usize = 0;
        while (i < (@sizeOf([2][*c]const u8) / @sizeOf([*c]const u8))) : (i +%= 1) {
            if (c.strncmp(completions[i], arg_text, @as(c_ulong, @bitCast(@as(c_long, end - arg_start)))) == @as(c_int, 0)) {
                matches = c.rl_completion_matches(arg_text, &custom_completion_generator);
                break;
            }
        }
    }
    return matches;
}
