# fin-proto-sse-bin-zig

上交所流式二进制协议 v0.57 的 Zig 消息库(模块名 `sse_binary`),
基于 [fin-proto-runtime-bin-zig](../fin-proto-runtime-bin-zig) 运行时。
对应 Rust 版本:[fin-proto-sse-bin-rs](https://github.com/xinchentechnote/fin-proto-sse-bin-rs)。

`src/` 下的全部 `.zig` 文件由 [fin-protoc](https://github.com/xinchentechnote/fin-protoc)
从 `proto/sse_bin_v0.57.pdsl` 生成(`-z` 指定输出目录),请勿手改:

```bash
make compile    # fin-protoc -f proto/sse_bin_v0.57.pdsl -z src/
```

## 线上格式(全部大端)

```
SseBinary:
┌──────────────┬────┬────────────────────────────────────────────────┐
│ MsgType u32  │ 4B │ 消息类型,决定 Body 的具体消息                      │
│ MsgSeqNum u64│ 8B │ 序列号                                          │
│ MsgBodyLen u32│ 4B│ Body 字节数(不含头部与校验和)                     │
│ Body         │变长│ 14 种消息之一;多数字段定长,ExecRptInfo/           │
│              │    │ ExecRptSync/ExecRptSyncRsp 含 repeat 列表        │
│ Checksum u32 │ 4B │ SSE_BIN 算法(除校验和外全部字节累加和 & 0xFF)      │
└──────────────┴────┴────────────────────────────────────────────────┘
```

## 使用

```bash
zig build test      # 运行生成代码自带的 round-trip 测试
zig build example   # 编码一条 Logon 报文写入 message.bin 并回读解码
```

依赖通过 `build.zig.zon` 的 path 依赖引入运行时:

```zig
.dependencies = .{
    .binary_codec = .{ .path = "../fin-proto-runtime-bin-zig" },
},
```
