// THIS FILE WAS GENERATED BY `xtp-zig-bindgen`. DO NOT EDIT.
const std = @import("std");
const extism = @import("extism-pdk");
const DateTime = @import("datetime").DateTime;

const _host = struct {
    extern "extism:host/user" fn KvRead(u64) u64;
    extern "extism:host/user" fn KvWriteAppend(u64) u64;
};

const _plugin = extism.Plugin.init(std.heap.wasm_allocator);

/// Host contains all of the provided import functions made available to
/// plugins by the host platform where your plugin will run.
pub const Host = struct {
    /// read a value from the KV based on the provided key
    /// It takes input of []const u8 (the 'key' to lookup in the KV database)
    /// And it returns an output []DateTime (the 'value' (if present) at the 'key' provided)
    pub fn KvRead(input: []const u8) ![]DateTime {
        const inMem = _plugin.allocateBytes(input);
        if (inMem.offset == 0) {
            return error.ExtismBadMemory;
        }
        defer inMem.free();

        const ptr = _host.KvRead(inMem.offset);
        if (ptr == 0) {
            return error.ExtismBadMemory;
        }
        const outMem = _plugin.findMemory(ptr);
        defer outMem.free();
        const buffer = try _plugin.allocator.alloc(u8, @intCast(outMem.length));
        outMem.load(buffer);
        const out = try std.json.parseFromSlice([]DateTime, _plugin.allocator, buffer, .{ .allocate = .alloc_always });
        return out.value;
    }

    /// append a value at a key to the KV database
    /// It takes input of WriteParams (a JSON object with a 'key' and 'value' to be inserted to the KV database)
    /// And it returns an output WriteReturns (a JSON object with a 'message' and 'code' indicating the outcome of the write. Non-zero code indicates an error.)
    pub fn KvWriteAppend(input: WriteParams) !WriteReturns {
        const b = try std.json.stringifyAlloc(_plugin.allocator, input, .{});
        const inMem = _plugin.allocateBytes(b);
        if (inMem.offset == 0) {
            return error.ExtismBadMemory;
        }
        defer inMem.free();

        const ptr = _host.KvWriteAppend(inMem.offset);
        if (ptr == 0) {
            return error.ExtismBadMemory;
        }
        const outMem = _plugin.findMemory(ptr);
        defer outMem.free();
        const buffer = try _plugin.allocator.alloc(u8, @intCast(outMem.length));
        outMem.load(buffer);
        const out = try std.json.parseFromSlice(WriteReturns, _plugin.allocator, buffer, .{ .allocate = .alloc_always });
        return out.value;
    }
};

/// the data provided by a log event
pub const LogRequest = struct {
    /// arbitrary JSON object with values representing the event
    payload: std.json.Value,
    /// the system where this log originated
    source: SourceSystem,
    /// the time of the log event
    timestamp: DateTime,
};

/// an object indicating the log handling status
pub const LogStats = struct {
    /// the aggregate count of logs written from a SourceSystem
    count: i64,
    /// the system where this log originated
    source: SourceSystem,
};

/// the system where this log originated
pub const SourceSystem = enum {
    webapp,
    postgres,
    api,
    cli,
};

/// a JSON object with a 'key' and 'value' to be inserted to the KV database
pub const WriteParams = struct {
    /// the system where this log originated
    key: SourceSystem,
    /// the value to be written at the key
    value: []const u8,
};

/// a JSON object with a 'message' and 'code' indicating the outcome of the write.
/// Non-zero code indicates an error.
pub const WriteReturns = struct {
    /// non-zero code indicates an error
    code: i32,
    /// a message about the operation
    message: []const u8,
};
