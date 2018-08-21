// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const builtin = @import("builtin");

const std = @import("std");
const Timer = std.os.time.Timer;
const warn = std.debug.warn;
const assert = std.debug.assert;

/// Return the time stamp counter plus auxilliary information.
/// The auxilary information is an u32 unique to each cpu. If two
/// rdtsc_aux return two different values then the time stamp
/// maybe suspect.
//fn rdtsc_aux(u32* aux) u64 {
//  // Execute the rdtscp, read Time Stamp Counter, instruction
//  // returns the 64 bit TSC value and writes ecx to tscAux value.
//  // The tscAux value is the logical cpu number and can be used
//  // to determine if the thread migrated to a different cpu and
//  // thus the returned value is suspect.
//  u32 lo, hi;
//  ams volatile (
//      "rdtscp\n\t"
//      :"=a"(lo), "=d"(hi), "=rm"(*aux));
//  // tscAux = aux
//  return (u64(hi) << 32) | u64(lo);
//}

/// Return the time stack counter
fn rdtscp(pAux: *u32) u64 {
    var lo: u32 = undefined;
    var hi: u32 = undefined;
    var aux: u32 = undefined;
    asm volatile ("rdtsc\n"
        : [lo] "={eax}" (lo),
          [hi] "={edx}" (hi),
          [aux] "={ecx}" (aux));
    //warn("rdtscp: aux={}\n", aux);
    pAux.* = aux;
    return (u64(hi) << 32) | u64(lo);
}

/// Return the time stack counter
fn rdtsc() u64 {
  var lo: u32 = undefined;
  var hi: u32 = undefined;
  asm volatile ("rdtsc\n"
      : [lo] "={eax}" (lo),
        [hi] "={edx}" (hi));
  return (u64(hi) << 32) | u64(lo);
}

/// mfence instruction
fn mfence() void {
  asm volatile ("mfence": : :"memory");
}

/// lfence instruction
fn lfence() void {
  asm volatile ("lfence": : :"memory");
}

/// sfence instruction
fn sfence() void {
  asm volatile ("sfence": : :"memory");
}


/// Tests

fn loops(
    comptime readTimeAndAux: fn(*u32) u64,
    comptime name: [] const u8,
    comptime loop_count: usize,
    comptime inner_loop_count: usize,
) void {

    mfence();
    var start_time = timer.read();
    var i: usize = 0;
    while (i < loop_count) : (i += 1) {
        comptime var j = 0;
        var aux_start: u32 = undefined;
        var aux: u32 = undefined;
        var cur_time = readTimeAndAux(&aux_start);
        inline while(j < inner_loop_count) : (j += 1) {
            cur_time = readTimeAndAux(&aux);
        }
        if (aux != aux_start) {
            warn("aux:{} != aux_start:{}\n", aux, aux_start);
        }
    }
    var end_time = timer.read();
    mfence();
    var duration = end_time - start_time;
    var seconds = @intToFloat(f64, end_time - start_time) / @intToFloat(f64, std.os.time.ns_per_s);
    var ops_per_sec = @intToFloat(f64, (loop_count * inner_loop_count)) / seconds;
    var ns_per_op = (seconds / @intToFloat(f64, (loop_count * inner_loop_count))) * 1000000000;
    warn("test {}: time={.6} ns/op={.4} ops/sec={}\n", name[0..], seconds, ns_per_op, ops_per_sec);
}

var timer: Timer = undefined;

fn timerRead(aux: *u32) u64 {
    aux.* = 0x123;
    return timer.read();
}

fn readTsc(aux: *u32) u64 {
    aux.* = 0x456;
    return rdtsc();
}

var gCc: CycleCounter = undefined;
fn readCc(aux: *u32) u64 {
    aux.* = 0x789;
    return gCc.now();
}

const a = std.debug.global_allocator;

const File = std.os.File;
const mem = std.mem;

// Slight modification of std/io.zig/readFileAllocAligned
// changed the last 2 lines from:
//    try adapter.stream.readNoEof(buf[0..size]);
//    return buf;
// to:
//    var count = try adapter.stream.read(buf[0..size]);
//    return buf[0..count];
pub fn readFile(allocator: *mem.Allocator, path: []const u8, comptime A: u29) ![]align(A) u8 {
    var file = try File.openRead(allocator, path);
    defer file.close();

    const size = try file.getEndPos();
    const buf = try allocator.alignedAlloc(u8, A, size);
    errdefer allocator.free(buf);

    var adapter = std.io.FileInStream.init(&file);
    var count = try adapter.stream.read(buf[0..size]);
    return buf[0..count];
}

fn numStrLen(str: []u8) usize {
    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        if ((str[i] < '0') or (str[i] > '9')) break;
    }
    return i;
}

// Somewhat more efficient than using numStrLen and regular
// parseInt as we only make one pass over the data.
//
// TODO: Support negative number and radix like parseInt.
fn myParseInt(comptime T: type, str: []u8) T {
    var i: usize = 0;
    var val: T = 0;
    while (i < str.len) : (i += 1) {
        if ((str[i] < '0') or (str[i] > '9')) break;
        val *= 10;
        val += str[i] - '0';
    }
    return val;
}

fn getCpuCyclesPerSecond() !u64 {
    var freq_str_in_khz = try readFile(a, "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq", @alignOf(u8));
    defer a.free(freq_str_in_khz);

    //var freq = try std.fmt.parseInt(u64, freq_str_in_khz[0..numStrLen(freq_str_in_khz[0..])], 10);
    var freq = myParseInt(u64, freq_str_in_khz);
    freq *= 1000;
    return freq;
}

const CycleCounter = struct {
    const Self = this;

    cpu_id: u32,

    fn init(pSelf: *Self) void {
        pSelf.cpu_id = 0;
    }

    fn rdTsc(pSelf: *Self, pCpu_id: *u32) u64 {
        return rdtscp(pCpu_id);
    }

    pub fn start(pSelf: *Self) u64 {
        return pSelf.rdTsc(&pSelf.cpu_id);
    }

    pub fn now(pSelf: *Self) u64 {
        var cpu_id: u32 = undefined;
        return pSelf.rdTsc(&cpu_id);
    }

    /// TODO: For some reason in debug build mode the cpu_id's don't match
    /// and are large numbers. Conversely for none debug builds I always
    /// see 1 for cpu_id??
    pub fn read(pSelf: *Self) !u64 {
        var cpu_id: u32 = undefined;
        var cycle_counter = pSelf.rdTsc(&cpu_id);
        switch (builtin.mode) {
            // TODO: This Mode.Debug causes an compile error that there must be an
            // error path, so I've hacked one in for now.
            builtin.Mode.Debug, => if (cpu_id == pSelf.cpu_id) return error.ExpectedCpuIdToDiffer, //{},
            builtin.Mode.ReleaseSafe, builtin.Mode.ReleaseFast, builtin.Mode.ReleaseSmall => {
                if (cpu_id != pSelf.cpu_id) {
                    //warn("cpu_id={} pSelf.cpu_id={}\n", cpu_id, pSelf.cpu_id);
                    return error.UnexpectedCpuid;
                }
            },
        }
        return cycle_counter;
    }
};

test "Timer" {
    var aux1: u32 = undefined;
    var aux2: u32 = undefined;
    _ = rdtscp(&aux1);
    _ = rdtscp(&aux2);
    warn("\naux1={} aux2={}\n", aux1, aux2);

    var freq: u64 = try getCpuCyclesPerSecond();
    warn("freq={}\n", freq);

    var cc : CycleCounter = undefined;
    cc.init();

    var cc_start: u64 = cc.start();
    //var cc_end: u64 = cc.now();
    var cc_end: u64 = try cc.read(); //causes error in debug build mode
    var duration_cc = cc_end - cc_start;
    assert(cc_end > cc_start);
    assert(duration_cc == (cc_end - cc_start));
    warn("duration_cc:{}  = cc_end:{} - cc_start:{}\n", duration_cc, cc_end, cc_start);

    var tsc_start: u64 = rdtsc();
    //lfence();
    var tsc_end: u64 = rdtsc();
    var duration_rdtsc = tsc_end - tsc_start;
    assert(tsc_end > tsc_start);
    assert(duration_rdtsc == (tsc_end - tsc_start));
    warn("duration_rdtsc:{}  = tsc_end:{} - tsc_start:{}\n", duration_rdtsc, tsc_end, tsc_start);

    var aux_start: u32 = 0x123;
    tsc_start = rdtscp(&aux_start);
    var aux_end: u32 = 0x456;
    tsc_end = rdtscp(&aux_end);
    var duration_rdtscp = tsc_end - tsc_start;
    //mfence();
    assert(tsc_end > tsc_start);
    assert(duration_rdtscp == (tsc_end - tsc_start));
    warn("duration_rdtscp:{} = tsc_end:{} - tsc_start:{} aux_start={} aux_end={}\n", duration_rdtscp, tsc_end, tsc_start,
        aux_start, aux_end);

    // Initialize timer
    timer = try Timer.start();
    gCc.init();

    const loop_count: usize = 2000000;
    const inner_loop_count = 100;
    loops(timerRead, "timer.read()"[0..], loop_count, inner_loop_count);
    loops(readTsc, "rdstc()"[0..], loop_count, inner_loop_count);
    loops(rdtscp, "rdstcp()"[0..], loop_count, inner_loop_count);
    loops(readCc, "readCc()"[0..], loop_count, inner_loop_count);
}
