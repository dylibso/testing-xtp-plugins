const std = @import("std");
const plugin_allocator = std.heap.wasm_allocator;

const schema = @import("schema.zig");
const Host = schema.Host;

/// takes a LogRequest input to do some inspection and
/// aggregate some stats to be returned
/// It takes LogRequest as input (the data provided by a log event)
/// And returns LogStats (an object indicating the log handling status)
pub fn handleLogEvent(input: schema.LogRequest) ![]const u8 {
    // write the log into the KV store
    const write = schema.WriteParams{ .key = input.source, .value = try input.timestamp.toRfc3339(plugin_allocator) };
    const res = try Host.KvWriteAppend(write);
    if (res.code != 0) {
        return error.WriteAppendFailed;
    }

    // read the data from the KV for each of the source options
    // aggregate the data into the log stats, where keys are sources and values
    // are the count of each log entries
    // e.g. { 'cli': 2, 'api': 100, ... }
    var stats_map = std.StringHashMap(u32).init(plugin_allocator);
    defer stats_map.deinit();
    const sources = [4]schema.SourceSystem{ .webapp, .postgres, .api, .cli };
    for (sources) |source| {
        const key = @tagName(source);
        const logs = try Host.KvRead(key);
        try stats_map.put(key, @intCast(logs.len));
    }

    return try stringifyHashMap(plugin_allocator, stats_map);
}

fn stringifyHashMap(allocator: std.mem.Allocator, map: std.StringHashMap(u32)) ![]const u8 {
    const T = u32; // Define the type of values stored in the map
    const JsonArrayHashMap = std.json.ArrayHashMap(T);
    var json_map = JsonArrayHashMap{
        .map = try std.StringArrayHashMapUnmanaged(T).init(allocator, &[_][]const u8{}, &[_]T{}),
    };
    defer json_map.deinit(allocator);

    // Iterate through the StringHashMap and add entries to the ArrayHashMap
    var it = map.iterator();
    while (it.next()) |entry| {
        try json_map.map.put(allocator, entry.key_ptr.*, entry.value_ptr.*);
    }

    return try std.json.stringifyAlloc(allocator, json_map, .{});
}
