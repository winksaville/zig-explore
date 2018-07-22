const std = @import("std");
const BufferedInStreamCustom = std.io.BufferedInStreamCustom;
const BufferedOutStreamCustom = std.io.BufferedOutStreamCustom;

const File = std.os.File;
const InStreamError = File.ReadError;
const OutStreamError = File.WriteError;
const InStream = std.io.InStream(InStreamError);
const OutStream = std.io.OutStream(OutStreamError);

pub fn main() !void {
    // Get standard error
    var stderr_file: File = try std.io.getStdErr();
    var stderr: *OutStream = &std.io.FileOutStream.init(&stderr_file).stream;

    // Get a buffered stream for stdout and be sure we flush when done, error or not
    var stdout_file = try std.io.getStdOut();
    var stdout = &std.io.FileOutStream.init(&stdout_file).stream;
    const buffered_stdout = &BufferedOutStreamCustom(std.os.page_size, OutStreamError).init(stdout);
    var stdout_bs: *OutStream = &buffered_stdout.stream;
    defer buffered_stdout.flush() catch {};

    // Get a buffered stream for stdin
    var stdin_file = try std.io.getStdIn();
    var stdin: *InStream = &std.io.FileInStream.init(&stdin_file).stream;
    const buffered_stdin = &BufferedInStreamCustom(std.os.page_size, InStreamError).init(stdin);
    var stdin_bs = &buffered_stdin.stream;

    // Declare counter and then when the program ends, error or not we'll print the count
    var count: u64 = 0;
    defer stderr.print("count={}\n", count) catch {};

    // Loop to read/write a byte
    while (true) {
        if (true) {
            // A little faster, 303-312ms for 4M file, reading into an array
            var byte: [1]u8 = undefined;
            stdin_bs.readNoEof(byte[0..]) catch |err| switch (err) {
                error.EndOfStream => return, // I don't like the comma's here, should be semi-colon
                else => return err,
            };
            try stdout_bs.write(byte);
        } else {
            // A little slower 348-423ms for 4M file
            var byte = stdin_bs.readByte() catch |err| switch (err) {
                error.EndOfStream => return, // I don't like the comma's here, should be semi-colon
                else => return err,
            };
            try stdout_bs.writeByte(byte);
        }
        count += 1;
    }
}
