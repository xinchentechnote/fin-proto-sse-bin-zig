//! Basic example: build a SseBinary carrying a Logon body, encode it to
//! message.bin, then decode the file back and print the round trip.

const std = @import("std");
const codec = @import("binary_codec");
const sse = @import("sse_binary");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    const msg = sse.SseBinary{
        .msg_type = 40, // Logon
        .msg_seq_num = 1,
        .msg_body_len = 0,
        .body = .{ .logon = .{
            .sender_comp_id = "SENDER00000000000000000000000001",
            .target_comp_id = "TARGET00000000000000000000000001",
            .heart_bt_int = 30,
            .prtcl_version = "0.57",
            .trade_date = 20260101,
            .q_size = 256,
        } },
        .checksum = 0,
    };

    var buf = codec.Buffer.init(allocator, .big);
    defer buf.deinit();
    try msg.encode(&buf);

    const dir = std.Io.Dir.cwd();
    {
        var out = try dir.createFile(io, "message.bin", .{});
        defer out.close(io);
        try out.writeStreamingAll(io, buf.written());
    }
    std.debug.print("wrote {} bytes to message.bin\n", .{buf.len});

    const contents = try dir.readFileAlloc(io, "message.bin", allocator, .limited(1 << 20));
    var reader = codec.Reader.init(contents, .big);
    const decoded = try sse.SseBinary.decode(allocator, &reader);

    std.debug.print("msg_type={} seq={} body_len={} checksum={} sender={s}\n", .{
        decoded.msg_type,
        decoded.msg_seq_num,
        decoded.msg_body_len,
        decoded.checksum,
        decoded.body.logon.sender_comp_id,
    });
}
