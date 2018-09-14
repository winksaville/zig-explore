// [Benchmark information for X86 from Intel]
//   (https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf)
//
// [Intel 64 and IA-32 ARchitectures SDM]
//   (https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-manual-325462.html)
//
// [google/benchmark]
//   (https://github.com/google/benchmark)

const builtin = @import("builtin");

const std = @import("std");
const File = std.os.File;
const Timer = std.os.time.Timer;
const warn = std.debug.warn;
const assert = std.debug.assert;

/// Return the time stamp counter plus auxilliary information.
/// The auxilary information is an u32 unique to each cpu. If two
/// rdtsc_aux return two different values then the time stamp
/// maybe suspect.
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

/// Return the time stamp counter
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

/// A possible API for a systesm cycle counters
const CycleCounter = struct {
    const Self = @This();

    pub start_cpu_id: u32,
    pub start_cycle_counter: u64,
    pub cpu_id: u32,
    pub cycle_counter: u64,

    fn init(pSelf: *Self) void {
        pSelf.cpu_id = 0;
    }

    pub fn start(pSelf: *Self) u64 {
        pSelf.cycle_counter = pSelf.rdTsc(&pSelf.cpu_id);
        pSelf.start_cycle_counter = pSelf.cycle_counter;
        pSelf.start_cpu_id = pSelf.cpu_id;
        return pSelf.cycle_counter;
    }

    pub fn now(pSelf: *Self) u64 {
        var cpu_id: u32 = undefined;
        pSelf.cycle_counter = rdTsc(&cpu_id);
        return pSelf.cycle_counter;
    }

    /// TODO: For some reason in debug build mode the cpu_id's don't match
    /// and are large numbers.
    pub fn read(pSelf: *Self) !u64 {
        pSelf.cycle_counter = pSelf.rdTsc(&pSelf.cpu_id);
        switch (builtin.mode) {
            builtin.Mode.Debug, => {
                // Supress compile error in Debug mode:
                //   error: function with inferred error set must return at least one possible error
                if ((pSelf.cpu_id != pSelf.start_cpu_id) and false) return error.WillNotHappen;
            },
            builtin.Mode.ReleaseSafe, builtin.Mode.ReleaseFast, builtin.Mode.ReleaseSmall => {
                if (pSelf.cpu_id != pSelf.start_cpu_id) {
                    return error.UnexpectedCpuid;
                }
            },
        }
        return pSelf.cycle_counter;
    }

    // TODO: Add comptime code to determine appropriate code
    // See [google/benchmark/sysinfo.h GetCPUCyclesPerSecond()]
    //        (https://github.com/google/benchmark/blob/master/src/sysinfo.cc#L436)
    pub fn getCpuCyclesPerSecond(pSelf: *Self) !u64 {
        var freq_str_in_khz = try readFile(a,
                "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq", @alignOf(u8));
        defer a.free(freq_str_in_khz);

        var freq = stringToInteger(u64, freq_str_in_khz);
        freq *= 1000;
        return freq;
    }

    // Read time stamp counter
    //
    // TODO: Add comptime code to determine appropriate code
    // See [google/benchmark/cycleclock.h Now()]
    //        (https://github.com/google/benchmark/blob/master/src/cycleclock.h#L61)
    fn rdTsc(pSelf: *Self, pCpu_id: *u32) u64 {
        return rdtscp(pCpu_id);
    }

    // Slight modification of std/io.zig/readFileAllocAligned
    // changed the last 2 lines from:
    //    try adapter.stream.readNoEof(buf[0..size]);
    //    return buf;
    // to:
    //    var count = try adapter.stream.read(buf[0..size]);
    //    return buf[0..count];
    fn readFile(allocator: *mem.Allocator, path: []const u8, comptime A: u29) ![]align(A) u8 {
        var file = try File.openRead(path);
        defer file.close();

        const size = try file.getEndPos();
        const buf = try allocator.alignedAlloc(u8, A, size);
        errdefer allocator.free(buf);

        var adapter = std.io.FileInStream.init(file);
        var count = try adapter.stream.read(buf[0..size]);
        return buf[0..count];
    }

    // Convet numeric string to integer.
    //
    // TODO: Support negative numbers and radix like parseInt.
    fn stringToInteger(comptime T: type, str: []u8) T {
        var i: usize = 0;
        var val: T = 0;
        while (i < str.len) : (i += 1) {
            if ((str[i] < '0') or (str[i] > '9')) break;
            val *= 10;
            val += str[i] - '0';
        }
        return val;
    }
};


/// Tests

fn loops(
    comptime readTimeAndAux: fn(*u32) u64,
    comptime name: [] const u8,
    comptime loop_count: usize,
    comptime inner_loop_count: usize,
    log: bool,
) void {

    var i: usize = 0;
    var aux_start: u32 = undefined;
    var once: bool = true;
    var start_time = timer.read();
    while (i < loop_count) : (i += 1) {
        comptime var j = 0;
        var aux: u32 = undefined;
        var cur_time = readTimeAndAux(&aux_start);
        inline while(j < inner_loop_count) : (j += 1) {
            cur_time = readTimeAndAux(&aux);
        }
        if (aux != aux_start and once) {
            once = false;
            warn("aux:{} != aux_start:{}\n", aux, aux_start);
        }
    }
    var end_time = timer.read();

    var duration = end_time - start_time;
    var seconds = @intToFloat(f64, end_time - start_time) / @intToFloat(f64, std.os.time.ns_per_s);
    var ops_per_sec = @intToFloat(f64, (loop_count * inner_loop_count)) / seconds;
    var ns_per_op = (seconds / @intToFloat(f64, (loop_count * inner_loop_count))) * 1000000000;
    if (log) {
        warn("test {}: cpu_id={} time={.4}s time/op={.4}ns ops/sec={.0}\n",
            name[0..], aux_start, seconds, ns_per_op, ops_per_sec);
    }
}

var timer: Timer = undefined;

fn timerRead(pAux: *u32) u64 {
    pAux.* = 0;
    return timer.read();
}

fn readTsc(pAux: *u32) u64 {
    return rdtscp(pAux);
}

var gCc: CycleCounter = undefined;
fn readCc(pAux: *u32) u64 {
    var x: u64 = gCc.read() catch 0;
    pAux.* = gCc.cpu_id;
    return gCc.cycle_counter;
}

const a = std.debug.global_allocator;

const mem = std.mem;

test "fences" {
    lfence();
    sfence();
    mfence();
}

test "Timer" {
    var aux1: u32 = undefined;
    var aux2: u32 = undefined;
    _ = rdtscp(&aux1);
    _ = rdtscp(&aux2);
    warn("\naux1={} aux2={}\n", aux1, aux2);

    var cc : CycleCounter = undefined;
    cc.init();

    var freq: u64 = try cc.getCpuCyclesPerSecond();
    warn("freq={}\n", freq);

    var cc_start: u64 = cc.start();
    assert(cc.start_cycle_counter == cc_start);
    var cc_end: u64 = try cc.read();
    //assert(cc.start_cpu_id == cc.cpu_id); // TODO: was passing previously but not now, why?
    assert(cc.cycle_counter == cc_end);
    var duration_cc = cc_end - cc_start;
    assert(cc_end > cc_start);
    assert(duration_cc == (cc_end - cc_start));
    warn("    duration_cc:{} =  cc_end:{} -  cc_start:{}\n", duration_cc, cc_end, cc_start);

    var tsc_start: u64 = rdtsc();
    var tsc_end: u64 = rdtsc();
    var duration_rdtsc = tsc_end - tsc_start;
    assert(tsc_end > tsc_start);
    assert(duration_rdtsc == (tsc_end - tsc_start));
    warn(" duration_rdtsc:{} = tsc_end:{} - tsc_start:{}\n", duration_rdtsc, tsc_end, tsc_start);

    var aux_start: u32 = 0x123;
    tsc_start = rdtscp(&aux_start);
    var aux_end: u32 = 0x456;
    tsc_end = rdtscp(&aux_end);
    var duration_rdtscp = tsc_end - tsc_start;
    assert(tsc_end > tsc_start);
    assert(duration_rdtscp == (tsc_end - tsc_start));
    warn("duration_rdtscp:{} = tsc_end:{} - tsc_start:{} aux_start={} aux_end={}\n",
        duration_rdtscp, tsc_end, tsc_start, aux_start, aux_end);

    // Initialize timer
    timer = try Timer.start();
    gCc.init();

    const loop_count: usize = 2000000;
    const inner_loop_count = 100;
    // Warm up CPU, don't log
    warn("Warm up CPU\n");
    loops(timerRead, "timer.read()"[0..], loop_count, inner_loop_count, false);

    warn("Running loops\n");
    loops(timerRead, "timer.read()", loop_count, inner_loop_count, true);
    loops(readCc,    "    readCc()", loop_count, inner_loop_count, true);
    loops(readTsc,   "     rdtsc()", loop_count, inner_loop_count, true);
    loops(rdtscp,    "    rdstcp()", loop_count, inner_loop_count, true);
}
