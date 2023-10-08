const std = @import("std");
const Lexer = @import("../lexer/lexer.zig");
const Self = @This();

const MAX_BUFFER_LEN: usize = 1024;

pub fn start() !void {
    var buffer: [MAX_BUFFER_LEN]u8 = undefined;
    var allocator = std.heap.page_allocator;
    var i: usize = 1;

    std.debug.print("Tingle/OTP  [v0.1.0] [main] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:0] [jit] [dtrace]\n", .{});

    while (true) {
        try read(&buffer, &i);
        if (evalCommand(&buffer)) continue;
        try eval(&buffer, allocator);
    }
}

fn read(buffer: *[MAX_BUFFER_LEN]u8, i: *usize) !void {
    const stdIn = std.io.getStdIn();
    const stdOut = std.io.getStdOut();
    const stdInReader = stdIn.reader();
    const stdOutWriter = stdOut.writer();

    try stdOutWriter.print("tingle({d})> ", .{i.*});

    @memset(buffer, 0);
    var buffer_fbs = std.io.fixedBufferStream(buffer);
    const writer = buffer_fbs.writer();

    try stdInReader.streamUntilDelimiter(writer, '\n', MAX_BUFFER_LEN);

    i.* += 1;
}

fn eval(input: []const u8, allocator: std.mem.Allocator) !void {
    var lexer = try Lexer.init(input, allocator);
    defer lexer.deinit();

    var token = lexer.scan();
    while (token.t != .Eof and token.t != .Illegal) : (token = lexer.scan()) {
        token.print();
    }
}

fn evalCommand(input: []const u8) bool {
    if (std.mem.eql(u8, "exit", input[0..4])) {
        std.debug.print(
            \\ BREAK: (a)bort (A)bort with dump (c)ontinue (p)roc info (i)nfo
            \\       (l)oaded (v)ersion (k)ill (D)b-tables (d)istribution
            \\
        , .{});
        return true;
    }

    return false;
}

fn print() void {}
