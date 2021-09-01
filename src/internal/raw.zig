pub usingnamespace @import("std").zig.c_builtins;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int,
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __suseconds64_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*c_void;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const clock_t = __clock_t;
pub const time_t = __time_t;
pub const struct_tm = extern struct {
    tm_sec: c_int,
    tm_min: c_int,
    tm_hour: c_int,
    tm_mday: c_int,
    tm_mon: c_int,
    tm_year: c_int,
    tm_wday: c_int,
    tm_yday: c_int,
    tm_isdst: c_int,
    tm_gmtoff: c_long,
    tm_zone: [*c]const u8,
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t,
    tv_nsec: __syscall_slong_t,
};
pub const clockid_t = __clockid_t;
pub const timer_t = __timer_t;
pub const struct_itimerspec = extern struct {
    it_interval: struct_timespec,
    it_value: struct_timespec,
};
pub const struct_sigevent = opaque {};
pub const pid_t = __pid_t;
pub const struct___locale_data = opaque {};
pub const struct___locale_struct = extern struct {
    __locales: [13]?*struct___locale_data,
    __ctype_b: [*c]const c_ushort,
    __ctype_tolower: [*c]const c_int,
    __ctype_toupper: [*c]const c_int,
    __names: [13][*c]const u8,
};
pub const __locale_t = [*c]struct___locale_struct;
pub const locale_t = __locale_t;
pub extern fn clock() clock_t;
pub extern fn time(__timer: [*c]time_t) time_t;
pub extern fn difftime(__time1: time_t, __time0: time_t) f64;
pub extern fn mktime(__tp: [*c]struct_tm) time_t;
pub extern fn strftime(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm) usize;
pub extern fn strftime_l(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm, __loc: locale_t) usize;
pub extern fn gmtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn localtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn gmtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn localtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn asctime(__tp: [*c]const struct_tm) [*c]u8;
pub extern fn ctime(__timer: [*c]const time_t) [*c]u8;
pub extern fn asctime_r(noalias __tp: [*c]const struct_tm, noalias __buf: [*c]u8) [*c]u8;
pub extern fn ctime_r(noalias __timer: [*c]const time_t, noalias __buf: [*c]u8) [*c]u8;
pub extern var __tzname: [2][*c]u8;
pub extern var __daylight: c_int;
pub extern var __timezone: c_long;
pub extern var tzname: [2][*c]u8;
pub extern fn tzset() void;
pub extern var daylight: c_int;
pub extern var timezone: c_long;
pub extern fn timegm(__tp: [*c]struct_tm) time_t;
pub extern fn timelocal(__tp: [*c]struct_tm) time_t;
pub extern fn dysize(__year: c_int) c_int;
pub extern fn nanosleep(__requested_time: [*c]const struct_timespec, __remaining: [*c]struct_timespec) c_int;
pub extern fn clock_getres(__clock_id: clockid_t, __res: [*c]struct_timespec) c_int;
pub extern fn clock_gettime(__clock_id: clockid_t, __tp: [*c]struct_timespec) c_int;
pub extern fn clock_settime(__clock_id: clockid_t, __tp: [*c]const struct_timespec) c_int;
pub extern fn clock_nanosleep(__clock_id: clockid_t, __flags: c_int, __req: [*c]const struct_timespec, __rem: [*c]struct_timespec) c_int;
pub extern fn clock_getcpuclockid(__pid: pid_t, __clock_id: [*c]clockid_t) c_int;
pub extern fn timer_create(__clock_id: clockid_t, noalias __evp: ?*struct_sigevent, noalias __timerid: [*c]timer_t) c_int;
pub extern fn timer_delete(__timerid: timer_t) c_int;
pub extern fn timer_settime(__timerid: timer_t, __flags: c_int, noalias __value: [*c]const struct_itimerspec, noalias __ovalue: [*c]struct_itimerspec) c_int;
pub extern fn timer_gettime(__timerid: timer_t, __value: [*c]struct_itimerspec) c_int;
pub extern fn timer_getoverrun(__timerid: timer_t) c_int;
pub extern fn timespec_get(__ts: [*c]struct_timespec, __base: c_int) c_int;
pub const wchar_t = c_int;
pub const _Float32 = f32;
pub const _Float64 = f64;
pub const _Float32x = f64;
pub const _Float64x = c_longdouble;
pub const div_t = extern struct {
    quot: c_int,
    rem: c_int,
};
pub const ldiv_t = extern struct {
    quot: c_long,
    rem: c_long,
};
pub const lldiv_t = extern struct {
    quot: c_longlong,
    rem: c_longlong,
};
pub extern fn __ctype_get_mb_cur_max() usize;
pub fn atof(arg___nptr: [*c]const u8) callconv(.C) f64 {
    var __nptr = arg___nptr;
    return strtod(__nptr, @ptrCast([*c][*c]u8, @alignCast(@import("std").meta.alignment([*c]u8), @intToPtr(?*c_void, @as(c_int, 0)))));
}
pub fn atoi(arg___nptr: [*c]const u8) callconv(.C) c_int {
    var __nptr = arg___nptr;
    return @bitCast(c_int, @truncate(c_int, strtol(__nptr, @ptrCast([*c][*c]u8, @alignCast(@import("std").meta.alignment([*c]u8), @intToPtr(?*c_void, @as(c_int, 0)))), @as(c_int, 10))));
}
pub fn atol(arg___nptr: [*c]const u8) callconv(.C) c_long {
    var __nptr = arg___nptr;
    return strtol(__nptr, @ptrCast([*c][*c]u8, @alignCast(@import("std").meta.alignment([*c]u8), @intToPtr(?*c_void, @as(c_int, 0)))), @as(c_int, 10));
}
pub fn atoll(arg___nptr: [*c]const u8) callconv(.C) c_longlong {
    var __nptr = arg___nptr;
    return strtoll(__nptr, @ptrCast([*c][*c]u8, @alignCast(@import("std").meta.alignment([*c]u8), @intToPtr(?*c_void, @as(c_int, 0)))), @as(c_int, 10));
}
pub extern fn strtod(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f64;
pub extern fn strtof(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f32;
pub extern fn strtold(__nptr: [*c]const u8, __endptr: [*c][*c]u8) c_longdouble;
pub extern fn strtol(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_long;
pub extern fn strtoul(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulong;
pub extern fn strtoq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtouq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn strtoll(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtoull(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn l64a(__n: c_long) [*c]u8;
pub extern fn a64l(__s: [*c]const u8) c_long;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const off_t = __off_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = __uint8_t;
pub const u_int16_t = __uint16_t;
pub const u_int32_t = __uint32_t;
pub const u_int64_t = __uint64_t;
pub const register_t = c_long;
pub fn __bswap_16(arg___bsx: __uint16_t) callconv(.C) __uint16_t {
    var __bsx = arg___bsx;
    return @bitCast(__uint16_t, @truncate(c_short, ((@bitCast(c_int, @as(c_uint, __bsx)) >> @intCast(@import("std").math.Log2Int(c_int), 8)) & @as(c_int, 255)) | ((@bitCast(c_int, @as(c_uint, __bsx)) & @as(c_int, 255)) << @intCast(@import("std").math.Log2Int(c_int), 8))));
}
pub fn __bswap_32(arg___bsx: __uint32_t) callconv(.C) __uint32_t {
    var __bsx = arg___bsx;
    return ((((__bsx & @as(c_uint, 4278190080)) >> @intCast(@import("std").math.Log2Int(c_uint), 24)) | ((__bsx & @as(c_uint, 16711680)) >> @intCast(@import("std").math.Log2Int(c_uint), 8))) | ((__bsx & @as(c_uint, 65280)) << @intCast(@import("std").math.Log2Int(c_uint), 8))) | ((__bsx & @as(c_uint, 255)) << @intCast(@import("std").math.Log2Int(c_uint), 24));
}
pub fn __bswap_64(arg___bsx: __uint64_t) callconv(.C) __uint64_t {
    var __bsx = arg___bsx;
    return @bitCast(__uint64_t, @truncate(c_ulong, ((((((((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 18374686479671623680)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 56)) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 71776119061217280)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 40))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 280375465082880)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 24))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 1095216660480)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 8))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 4278190080)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 8))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 16711680)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 24))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 65280)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 40))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, __bsx)) & @as(c_ulonglong, 255)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 56))));
}
pub fn __uint16_identity(arg___x: __uint16_t) callconv(.C) __uint16_t {
    var __x = arg___x;
    return __x;
}
pub fn __uint32_identity(arg___x: __uint32_t) callconv(.C) __uint32_t {
    var __x = arg___x;
    return __x;
}
pub fn __uint64_identity(arg___x: __uint64_t) callconv(.C) __uint64_t {
    var __x = arg___x;
    return __x;
}
pub const __sigset_t = extern struct {
    __val: [16]c_ulong,
};
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t,
    tv_usec: __suseconds_t,
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
pub const fd_set = extern struct {
    __fds_bits: [16]__fd_mask,
};
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]const struct_timespec, noalias __sigmask: [*c]const __sigset_t) c_int;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
pub const struct___pthread_internal_list = extern struct {
    __prev: [*c]struct___pthread_internal_list,
    __next: [*c]struct___pthread_internal_list,
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_internal_slist = extern struct {
    __next: [*c]struct___pthread_internal_slist,
};
pub const __pthread_slist_t = struct___pthread_internal_slist;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int,
    __count: c_uint,
    __owner: c_int,
    __nusers: c_uint,
    __kind: c_int,
    __spins: c_short,
    __elision: c_short,
    __list: __pthread_list_t,
};
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint,
    __writers: c_uint,
    __wrphase_futex: c_uint,
    __writers_futex: c_uint,
    __pad3: c_uint,
    __pad4: c_uint,
    __cur_writer: c_int,
    __shared: c_int,
    __rwelision: i8,
    __pad1: [7]u8,
    __pad2: c_ulong,
    __flags: c_uint,
};
const struct_unnamed_2 = extern struct {
    __low: c_uint,
    __high: c_uint,
};
const union_unnamed_1 = extern union {
    __wseq: c_ulonglong,
    __wseq32: struct_unnamed_2,
};
const struct_unnamed_4 = extern struct {
    __low: c_uint,
    __high: c_uint,
};
const union_unnamed_3 = extern union {
    __g1_start: c_ulonglong,
    __g1_start32: struct_unnamed_4,
};
pub const struct___pthread_cond_s = extern struct {
    unnamed_0: union_unnamed_1,
    unnamed_1: union_unnamed_3,
    __g_refs: [2]c_uint,
    __g_size: [2]c_uint,
    __g1_orig_size: c_uint,
    __wrefs: c_uint,
    __g_signals: [2]c_uint,
};
pub const __tss_t = c_uint;
pub const __thrd_t = c_ulong;
pub const __once_flag = extern struct {
    __data: c_int,
};
pub const pthread_t = c_ulong;
pub const pthread_mutexattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub extern fn random() c_long;
pub extern fn srandom(__seed: c_uint) void;
pub extern fn initstate(__seed: c_uint, __statebuf: [*c]u8, __statelen: usize) [*c]u8;
pub extern fn setstate(__statebuf: [*c]u8) [*c]u8;
pub const struct_random_data = extern struct {
    fptr: [*c]i32,
    rptr: [*c]i32,
    state: [*c]i32,
    rand_type: c_int,
    rand_deg: c_int,
    rand_sep: c_int,
    end_ptr: [*c]i32,
};
pub extern fn random_r(noalias __buf: [*c]struct_random_data, noalias __result: [*c]i32) c_int;
pub extern fn srandom_r(__seed: c_uint, __buf: [*c]struct_random_data) c_int;
pub extern fn initstate_r(__seed: c_uint, noalias __statebuf: [*c]u8, __statelen: usize, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn setstate_r(noalias __statebuf: [*c]u8, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn rand() c_int;
pub extern fn srand(__seed: c_uint) void;
pub extern fn rand_r(__seed: [*c]c_uint) c_int;
pub extern fn drand48() f64;
pub extern fn erand48(__xsubi: [*c]c_ushort) f64;
pub extern fn lrand48() c_long;
pub extern fn nrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn mrand48() c_long;
pub extern fn jrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn srand48(__seedval: c_long) void;
pub extern fn seed48(__seed16v: [*c]c_ushort) [*c]c_ushort;
pub extern fn lcong48(__param: [*c]c_ushort) void;
pub const struct_drand48_data = extern struct {
    __x: [3]c_ushort,
    __old_x: [3]c_ushort,
    __c: c_ushort,
    __init: c_ushort,
    __a: c_ulonglong,
};
pub extern fn drand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn erand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn lrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn nrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn mrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn jrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn srand48_r(__seedval: c_long, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn seed48_r(__seed16v: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn lcong48_r(__param: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn malloc(__size: c_ulong) ?*c_void;
pub extern fn calloc(__nmemb: c_ulong, __size: c_ulong) ?*c_void;
pub extern fn realloc(__ptr: ?*c_void, __size: c_ulong) ?*c_void;
pub extern fn reallocarray(__ptr: ?*c_void, __nmemb: usize, __size: usize) ?*c_void;
pub extern fn free(__ptr: ?*c_void) void;
pub extern fn alloca(__size: c_ulong) ?*c_void;
pub extern fn valloc(__size: usize) ?*c_void;
pub extern fn posix_memalign(__memptr: [*c]?*c_void, __alignment: usize, __size: usize) c_int;
pub extern fn aligned_alloc(__alignment: usize, __size: usize) ?*c_void;
pub extern fn abort() noreturn;
pub extern fn atexit(__func: ?fn () callconv(.C) void) c_int;
pub extern fn at_quick_exit(__func: ?fn () callconv(.C) void) c_int;
pub extern fn on_exit(__func: ?fn (c_int, ?*c_void) callconv(.C) void, __arg: ?*c_void) c_int;
pub extern fn exit(__status: c_int) noreturn;
pub extern fn quick_exit(__status: c_int) noreturn;
pub extern fn _Exit(__status: c_int) noreturn;
pub extern fn getenv(__name: [*c]const u8) [*c]u8;
pub extern fn putenv(__string: [*c]u8) c_int;
pub extern fn setenv(__name: [*c]const u8, __value: [*c]const u8, __replace: c_int) c_int;
pub extern fn unsetenv(__name: [*c]const u8) c_int;
pub extern fn clearenv() c_int;
pub extern fn mktemp(__template: [*c]u8) [*c]u8;
pub extern fn mkstemp(__template: [*c]u8) c_int;
pub extern fn mkstemps(__template: [*c]u8, __suffixlen: c_int) c_int;
pub extern fn mkdtemp(__template: [*c]u8) [*c]u8;
pub extern fn system(__command: [*c]const u8) c_int;
pub extern fn realpath(noalias __name: [*c]const u8, noalias __resolved: [*c]u8) [*c]u8;
pub const __compar_fn_t = ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int;
pub fn bsearch(arg___key: ?*const c_void, arg___base: ?*const c_void, arg___nmemb: usize, arg___size: usize, arg___compar: __compar_fn_t) callconv(.C) ?*c_void {
    var __key = arg___key;
    var __base = arg___base;
    var __nmemb = arg___nmemb;
    var __size = arg___size;
    var __compar = arg___compar;
    var __l: usize = undefined;
    var __u: usize = undefined;
    var __idx: usize = undefined;
    var __p: ?*const c_void = undefined;
    var __comparison: c_int = undefined;
    __l = 0;
    __u = __nmemb;
    while (__l < __u) {
        __idx = (__l +% __u) / @bitCast(c_ulong, @as(c_long, @as(c_int, 2)));
        __p = @intToPtr(?*c_void, @ptrToInt(@ptrCast([*c]const u8, @alignCast(@import("std").meta.alignment(u8), __base)) + (__idx *% __size)));
        __comparison = __compar.?(__key, __p);
        if (__comparison < @as(c_int, 0)) {
            __u = __idx;
        } else if (__comparison > @as(c_int, 0)) {
            __l = __idx +% @bitCast(c_ulong, @as(c_long, @as(c_int, 1)));
        } else return @intToPtr(?*c_void, @ptrToInt(__p));
    }
    return @intToPtr(?*c_void, @as(c_int, 0));
}
pub extern fn qsort(__base: ?*c_void, __nmemb: usize, __size: usize, __compar: __compar_fn_t) void;
pub extern fn abs(__x: c_int) c_int;
pub extern fn labs(__x: c_long) c_long;
pub extern fn llabs(__x: c_longlong) c_longlong;
pub extern fn div(__numer: c_int, __denom: c_int) div_t;
pub extern fn ldiv(__numer: c_long, __denom: c_long) ldiv_t;
pub extern fn lldiv(__numer: c_longlong, __denom: c_longlong) lldiv_t;
pub extern fn ecvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn fcvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn gcvt(__value: f64, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn qecvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qfcvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qgcvt(__value: c_longdouble, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn ecvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn fcvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qecvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qfcvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn mblen(__s: [*c]const u8, __n: usize) c_int;
pub extern fn mbtowc(noalias __pwc: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) c_int;
pub extern fn wctomb(__s: [*c]u8, __wchar: wchar_t) c_int;
pub extern fn mbstowcs(noalias __pwcs: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) usize;
pub extern fn wcstombs(noalias __s: [*c]u8, noalias __pwcs: [*c]const wchar_t, __n: usize) usize;
pub extern fn rpmatch(__response: [*c]const u8) c_int;
pub extern fn getsubopt(noalias __optionp: [*c][*c]u8, noalias __tokens: [*c]const [*c]u8, noalias __valuep: [*c][*c]u8) c_int;
pub extern fn getloadavg(__loadavg: [*c]f64, __nelem: c_int) c_int;
pub const int_least8_t = __int_least8_t;
pub const int_least16_t = __int_least16_t;
pub const int_least32_t = __int_least32_t;
pub const int_least64_t = __int_least64_t;
pub const uint_least8_t = __uint_least8_t;
pub const uint_least16_t = __uint_least16_t;
pub const uint_least32_t = __uint_least32_t;
pub const uint_least64_t = __uint_least64_t;
pub const int_fast8_t = i8;
pub const int_fast16_t = c_long;
pub const int_fast32_t = c_long;
pub const int_fast64_t = c_long;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = c_ulong;
pub const uint_fast32_t = c_ulong;
pub const uint_fast64_t = c_ulong;
pub const intmax_t = __intmax_t;
pub const uintmax_t = __uintmax_t;
pub const __gwchar_t = c_int;
pub const imaxdiv_t = extern struct {
    quot: c_long,
    rem: c_long,
};
pub extern fn imaxabs(__n: intmax_t) intmax_t;
pub extern fn imaxdiv(__numer: intmax_t, __denom: intmax_t) imaxdiv_t;
pub extern fn strtoimax(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) intmax_t;
pub extern fn strtoumax(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) uintmax_t;
pub extern fn wcstoimax(noalias __nptr: [*c]const __gwchar_t, noalias __endptr: [*c][*c]__gwchar_t, __base: c_int) intmax_t;
pub extern fn wcstoumax(noalias __nptr: [*c]const __gwchar_t, noalias __endptr: [*c][*c]__gwchar_t, __base: c_int) uintmax_t;
pub extern fn git_libgit2_version(major: [*c]c_int, minor: [*c]c_int, rev: [*c]c_int) c_int;
pub const GIT_FEATURE_THREADS: c_int = 1;
pub const GIT_FEATURE_HTTPS: c_int = 2;
pub const GIT_FEATURE_SSH: c_int = 4;
pub const GIT_FEATURE_NSEC: c_int = 8;
pub const git_feature_t = c_uint;
pub extern fn git_libgit2_features() c_int;
pub const GIT_OPT_GET_MWINDOW_SIZE: c_int = 0;
pub const GIT_OPT_SET_MWINDOW_SIZE: c_int = 1;
pub const GIT_OPT_GET_MWINDOW_MAPPED_LIMIT: c_int = 2;
pub const GIT_OPT_SET_MWINDOW_MAPPED_LIMIT: c_int = 3;
pub const GIT_OPT_GET_SEARCH_PATH: c_int = 4;
pub const GIT_OPT_SET_SEARCH_PATH: c_int = 5;
pub const GIT_OPT_SET_CACHE_OBJECT_LIMIT: c_int = 6;
pub const GIT_OPT_SET_CACHE_MAX_SIZE: c_int = 7;
pub const GIT_OPT_ENABLE_CACHING: c_int = 8;
pub const GIT_OPT_GET_CACHED_MEMORY: c_int = 9;
pub const GIT_OPT_GET_TEMPLATE_PATH: c_int = 10;
pub const GIT_OPT_SET_TEMPLATE_PATH: c_int = 11;
pub const GIT_OPT_SET_SSL_CERT_LOCATIONS: c_int = 12;
pub const GIT_OPT_SET_USER_AGENT: c_int = 13;
pub const GIT_OPT_ENABLE_STRICT_OBJECT_CREATION: c_int = 14;
pub const GIT_OPT_ENABLE_STRICT_SYMBOLIC_REF_CREATION: c_int = 15;
pub const GIT_OPT_SET_SSL_CIPHERS: c_int = 16;
pub const GIT_OPT_GET_USER_AGENT: c_int = 17;
pub const GIT_OPT_ENABLE_OFS_DELTA: c_int = 18;
pub const GIT_OPT_ENABLE_FSYNC_GITDIR: c_int = 19;
pub const GIT_OPT_GET_WINDOWS_SHAREMODE: c_int = 20;
pub const GIT_OPT_SET_WINDOWS_SHAREMODE: c_int = 21;
pub const GIT_OPT_ENABLE_STRICT_HASH_VERIFICATION: c_int = 22;
pub const GIT_OPT_SET_ALLOCATOR: c_int = 23;
pub const GIT_OPT_ENABLE_UNSAVED_INDEX_SAFETY: c_int = 24;
pub const GIT_OPT_GET_PACK_MAX_OBJECTS: c_int = 25;
pub const GIT_OPT_SET_PACK_MAX_OBJECTS: c_int = 26;
pub const GIT_OPT_DISABLE_PACK_KEEP_FILE_CHECKS: c_int = 27;
pub const GIT_OPT_ENABLE_HTTP_EXPECT_CONTINUE: c_int = 28;
pub const GIT_OPT_GET_MWINDOW_FILE_LIMIT: c_int = 29;
pub const GIT_OPT_SET_MWINDOW_FILE_LIMIT: c_int = 30;
pub const GIT_OPT_SET_ODB_PACKED_PRIORITY: c_int = 31;
pub const GIT_OPT_SET_ODB_LOOSE_PRIORITY: c_int = 32;
pub const git_libgit2_opt_t = c_uint;
pub extern fn git_libgit2_opts(option: c_int, ...) c_int;
pub const git_off_t = i64;
pub const git_time_t = i64;
pub const git_object_size_t = u64;
pub const git_buf = extern struct {
    ptr: [*c]u8,
    asize: usize,
    size: usize,
};
pub extern fn git_buf_dispose(buffer: [*c]git_buf) void;
pub extern fn git_buf_grow(buffer: [*c]git_buf, target_size: usize) c_int;
pub extern fn git_buf_set(buffer: [*c]git_buf, data: ?*const c_void, datalen: usize) c_int;
pub extern fn git_buf_is_binary(buf: [*c]const git_buf) c_int;
pub extern fn git_buf_contains_nul(buf: [*c]const git_buf) c_int;
pub const struct_git_oid = extern struct {
    id: [20]u8,
};
pub const git_oid = struct_git_oid;
pub extern fn git_oid_fromstr(out: [*c]git_oid, str: [*c]const u8) c_int;
pub extern fn git_oid_fromstrp(out: [*c]git_oid, str: [*c]const u8) c_int;
pub extern fn git_oid_fromstrn(out: [*c]git_oid, str: [*c]const u8, length: usize) c_int;
pub extern fn git_oid_fromraw(out: [*c]git_oid, raw: [*c]const u8) c_int;
pub extern fn git_oid_fmt(out: [*c]u8, id: [*c]const git_oid) c_int;
pub extern fn git_oid_nfmt(out: [*c]u8, n: usize, id: [*c]const git_oid) c_int;
pub extern fn git_oid_pathfmt(out: [*c]u8, id: [*c]const git_oid) c_int;
pub extern fn git_oid_tostr_s(oid: [*c]const git_oid) [*c]u8;
pub extern fn git_oid_tostr(out: [*c]u8, n: usize, id: [*c]const git_oid) [*c]u8;
pub extern fn git_oid_cpy(out: [*c]git_oid, src: [*c]const git_oid) c_int;
pub extern fn git_oid_cmp(a: [*c]const git_oid, b: [*c]const git_oid) c_int;
pub extern fn git_oid_equal(a: [*c]const git_oid, b: [*c]const git_oid) c_int;
pub extern fn git_oid_ncmp(a: [*c]const git_oid, b: [*c]const git_oid, len: usize) c_int;
pub extern fn git_oid_streq(id: [*c]const git_oid, str: [*c]const u8) c_int;
pub extern fn git_oid_strcmp(id: [*c]const git_oid, str: [*c]const u8) c_int;
pub extern fn git_oid_is_zero(id: [*c]const git_oid) c_int;
pub const struct_git_oid_shorten = opaque {};
pub const git_oid_shorten = struct_git_oid_shorten;
pub extern fn git_oid_shorten_new(min_length: usize) ?*git_oid_shorten;
pub extern fn git_oid_shorten_add(os: ?*git_oid_shorten, text_id: [*c]const u8) c_int;
pub extern fn git_oid_shorten_free(os: ?*git_oid_shorten) void;
pub const GIT_OBJECT_ANY: c_int = -2;
pub const GIT_OBJECT_INVALID: c_int = -1;
pub const GIT_OBJECT_COMMIT: c_int = 1;
pub const GIT_OBJECT_TREE: c_int = 2;
pub const GIT_OBJECT_BLOB: c_int = 3;
pub const GIT_OBJECT_TAG: c_int = 4;
pub const GIT_OBJECT_OFS_DELTA: c_int = 6;
pub const GIT_OBJECT_REF_DELTA: c_int = 7;
pub const git_object_t = c_int;
pub const struct_git_odb = opaque {};
pub const git_odb = struct_git_odb;
pub const struct_git_odb_backend = opaque {};
pub const git_odb_backend = struct_git_odb_backend;
pub const struct_git_odb_object = opaque {};
pub const git_odb_object = struct_git_odb_object;
pub const git_odb_stream = struct_git_odb_stream;
pub const struct_git_odb_stream = extern struct {
    backend: ?*git_odb_backend,
    mode: c_uint,
    hash_ctx: ?*c_void,
    declared_size: git_object_size_t,
    received_bytes: git_object_size_t,
    read: ?fn ([*c]git_odb_stream, [*c]u8, usize) callconv(.C) c_int,
    write: ?fn ([*c]git_odb_stream, [*c]const u8, usize) callconv(.C) c_int,
    finalize_write: ?fn ([*c]git_odb_stream, [*c]const git_oid) callconv(.C) c_int,
    free: ?fn ([*c]git_odb_stream) callconv(.C) void,
};
pub const git_odb_writepack = struct_git_odb_writepack;
pub const struct_git_indexer_progress = extern struct {
    total_objects: c_uint,
    indexed_objects: c_uint,
    received_objects: c_uint,
    local_objects: c_uint,
    total_deltas: c_uint,
    indexed_deltas: c_uint,
    received_bytes: usize,
};
pub const git_indexer_progress = struct_git_indexer_progress;
pub const struct_git_odb_writepack = extern struct {
    backend: ?*git_odb_backend,
    append: ?fn ([*c]git_odb_writepack, ?*const c_void, usize, [*c]git_indexer_progress) callconv(.C) c_int,
    commit: ?fn ([*c]git_odb_writepack, [*c]git_indexer_progress) callconv(.C) c_int,
    free: ?fn ([*c]git_odb_writepack) callconv(.C) void,
};
pub const struct_git_refdb = opaque {};
pub const git_refdb = struct_git_refdb;
pub const struct_git_refdb_backend = opaque {};
pub const git_refdb_backend = struct_git_refdb_backend;
pub const struct_git_commit_graph = opaque {};
pub const git_commit_graph = struct_git_commit_graph;
pub const struct_git_repository = opaque {};
pub const git_repository = struct_git_repository;
pub const struct_git_worktree = opaque {};
pub const git_worktree = struct_git_worktree;
pub const struct_git_object = opaque {};
pub const git_object = struct_git_object;
pub const struct_git_revwalk = opaque {};
pub const git_revwalk = struct_git_revwalk;
pub const struct_git_tag = opaque {};
pub const git_tag = struct_git_tag;
pub const struct_git_blob = opaque {};
pub const git_blob = struct_git_blob;
pub const struct_git_commit = opaque {};
pub const git_commit = struct_git_commit;
pub const struct_git_tree_entry = opaque {};
pub const git_tree_entry = struct_git_tree_entry;
pub const struct_git_tree = opaque {};
pub const git_tree = struct_git_tree;
pub const struct_git_treebuilder = opaque {};
pub const git_treebuilder = struct_git_treebuilder;
pub const struct_git_index = opaque {};
pub const git_index = struct_git_index;
pub const struct_git_index_iterator = opaque {};
pub const git_index_iterator = struct_git_index_iterator;
pub const struct_git_index_conflict_iterator = opaque {};
pub const git_index_conflict_iterator = struct_git_index_conflict_iterator;
pub const struct_git_config = opaque {};
pub const git_config = struct_git_config;
pub const struct_git_config_backend = opaque {};
pub const git_config_backend = struct_git_config_backend;
pub const struct_git_reflog_entry = opaque {};
pub const git_reflog_entry = struct_git_reflog_entry;
pub const struct_git_reflog = opaque {};
pub const git_reflog = struct_git_reflog;
pub const struct_git_note = opaque {};
pub const git_note = struct_git_note;
pub const struct_git_packbuilder = opaque {};
pub const git_packbuilder = struct_git_packbuilder;
pub const struct_git_time = extern struct {
    time: git_time_t,
    offset: c_int,
    sign: u8,
};
pub const git_time = struct_git_time;
pub const struct_git_signature = extern struct {
    name: [*c]u8,
    email: [*c]u8,
    when: git_time,
};
pub const git_signature = struct_git_signature;
pub const struct_git_reference = opaque {};
pub const git_reference = struct_git_reference;
pub const struct_git_reference_iterator = opaque {};
pub const git_reference_iterator = struct_git_reference_iterator;
pub const struct_git_transaction = opaque {};
pub const git_transaction = struct_git_transaction;
pub const struct_git_annotated_commit = opaque {};
pub const git_annotated_commit = struct_git_annotated_commit;
pub const struct_git_status_list = opaque {};
pub const git_status_list = struct_git_status_list;
pub const struct_git_rebase = opaque {};
pub const git_rebase = struct_git_rebase;
pub const GIT_REFERENCE_INVALID: c_int = 0;
pub const GIT_REFERENCE_DIRECT: c_int = 1;
pub const GIT_REFERENCE_SYMBOLIC: c_int = 2;
pub const GIT_REFERENCE_ALL: c_int = 3;
pub const git_reference_t = c_uint;
pub const GIT_BRANCH_LOCAL: c_int = 1;
pub const GIT_BRANCH_REMOTE: c_int = 2;
pub const GIT_BRANCH_ALL: c_int = 3;
pub const git_branch_t = c_uint;
pub const GIT_FILEMODE_UNREADABLE: c_int = 0;
pub const GIT_FILEMODE_TREE: c_int = 16384;
pub const GIT_FILEMODE_BLOB: c_int = 33188;
pub const GIT_FILEMODE_BLOB_EXECUTABLE: c_int = 33261;
pub const GIT_FILEMODE_LINK: c_int = 40960;
pub const GIT_FILEMODE_COMMIT: c_int = 57344;
pub const git_filemode_t = c_uint;
pub const struct_git_refspec = opaque {};
pub const git_refspec = struct_git_refspec;
pub const struct_git_remote = opaque {};
pub const git_remote = struct_git_remote;
pub const struct_git_transport = opaque {};
pub const git_transport = struct_git_transport;
pub const struct_git_push = opaque {};
pub const git_push = struct_git_push;
pub const struct_git_remote_head = extern struct {
    local: c_int,
    oid: git_oid,
    loid: git_oid,
    name: [*c]u8,
    symref_target: [*c]u8,
};
pub const git_remote_head = struct_git_remote_head;
pub const git_transport_message_cb = ?fn ([*c]const u8, c_int, ?*c_void) callconv(.C) c_int;
pub const GIT_REMOTE_COMPLETION_DOWNLOAD: c_int = 0;
pub const GIT_REMOTE_COMPLETION_INDEXING: c_int = 1;
pub const GIT_REMOTE_COMPLETION_ERROR: c_int = 2;
pub const enum_git_remote_completion_t = c_uint;
pub const git_remote_completion_t = enum_git_remote_completion_t;
pub const struct_git_credential = extern struct {
    credtype: git_credential_t,
    free: ?fn ([*c]git_credential) callconv(.C) void,
};
pub const git_credential = struct_git_credential;
pub const git_credential_acquire_cb = ?fn ([*c][*c]git_credential, [*c]const u8, [*c]const u8, c_uint, ?*c_void) callconv(.C) c_int;
pub const GIT_CERT_NONE: c_int = 0;
pub const GIT_CERT_X509: c_int = 1;
pub const GIT_CERT_HOSTKEY_LIBSSH2: c_int = 2;
pub const GIT_CERT_STRARRAY: c_int = 3;
pub const enum_git_cert_t = c_uint;
pub const git_cert_t = enum_git_cert_t;
pub const struct_git_cert = extern struct {
    cert_type: git_cert_t,
};
pub const git_cert = struct_git_cert;
pub const git_transport_certificate_check_cb = ?fn ([*c]git_cert, c_int, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const git_indexer_progress_cb = ?fn ([*c]const git_indexer_progress, ?*c_void) callconv(.C) c_int;
pub const git_packbuilder_progress = ?fn (c_int, u32, u32, ?*c_void) callconv(.C) c_int;
pub const git_push_transfer_progress_cb = ?fn (c_uint, c_uint, usize, ?*c_void) callconv(.C) c_int;
pub const git_push_update_reference_cb = ?fn ([*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const git_push_negotiation = ?fn ([*c][*c]const git_push_update, usize, ?*c_void) callconv(.C) c_int;
pub const git_transport_cb = ?fn ([*c]?*git_transport, ?*git_remote, ?*c_void) callconv(.C) c_int;
pub const git_url_resolve_cb = ?fn ([*c]git_buf, [*c]const u8, c_int, ?*c_void) callconv(.C) c_int;
pub const struct_git_remote_callbacks = extern struct {
    version: c_uint,
    sideband_progress: git_transport_message_cb,
    completion: ?fn (git_remote_completion_t, ?*c_void) callconv(.C) c_int,
    credentials: git_credential_acquire_cb,
    certificate_check: git_transport_certificate_check_cb,
    transfer_progress: git_indexer_progress_cb,
    update_tips: ?fn ([*c]const u8, [*c]const git_oid, [*c]const git_oid, ?*c_void) callconv(.C) c_int,
    pack_progress: git_packbuilder_progress,
    push_transfer_progress: git_push_transfer_progress_cb,
    push_update_reference: git_push_update_reference_cb,
    push_negotiation: git_push_negotiation,
    transport: git_transport_cb,
    payload: ?*c_void,
    resolve_url: git_url_resolve_cb,
};
pub const git_remote_callbacks = struct_git_remote_callbacks;
pub const struct_git_submodule = opaque {};
pub const git_submodule = struct_git_submodule;
pub const GIT_SUBMODULE_UPDATE_CHECKOUT: c_int = 1;
pub const GIT_SUBMODULE_UPDATE_REBASE: c_int = 2;
pub const GIT_SUBMODULE_UPDATE_MERGE: c_int = 3;
pub const GIT_SUBMODULE_UPDATE_NONE: c_int = 4;
pub const GIT_SUBMODULE_UPDATE_DEFAULT: c_int = 0;
pub const git_submodule_update_t = c_uint;
pub const GIT_SUBMODULE_IGNORE_UNSPECIFIED: c_int = -1;
pub const GIT_SUBMODULE_IGNORE_NONE: c_int = 1;
pub const GIT_SUBMODULE_IGNORE_UNTRACKED: c_int = 2;
pub const GIT_SUBMODULE_IGNORE_DIRTY: c_int = 3;
pub const GIT_SUBMODULE_IGNORE_ALL: c_int = 4;
pub const git_submodule_ignore_t = c_int;
pub const GIT_SUBMODULE_RECURSE_NO: c_int = 0;
pub const GIT_SUBMODULE_RECURSE_YES: c_int = 1;
pub const GIT_SUBMODULE_RECURSE_ONDEMAND: c_int = 2;
pub const git_submodule_recurse_t = c_uint;
pub const git_writestream = struct_git_writestream;
pub const struct_git_writestream = extern struct {
    write: ?fn ([*c]git_writestream, [*c]const u8, usize) callconv(.C) c_int,
    close: ?fn ([*c]git_writestream) callconv(.C) c_int,
    free: ?fn ([*c]git_writestream) callconv(.C) void,
};
pub const struct_git_mailmap = opaque {};
pub const git_mailmap = struct_git_mailmap;
pub extern fn git_repository_open(out: [*c]?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_repository_open_from_worktree(out: [*c]?*git_repository, wt: ?*git_worktree) c_int;
pub extern fn git_repository_wrap_odb(out: [*c]?*git_repository, odb: ?*git_odb) c_int;
pub extern fn git_repository_discover(out: [*c]git_buf, start_path: [*c]const u8, across_fs: c_int, ceiling_dirs: [*c]const u8) c_int;
pub const GIT_REPOSITORY_OPEN_NO_SEARCH: c_int = 1;
pub const GIT_REPOSITORY_OPEN_CROSS_FS: c_int = 2;
pub const GIT_REPOSITORY_OPEN_BARE: c_int = 4;
pub const GIT_REPOSITORY_OPEN_NO_DOTGIT: c_int = 8;
pub const GIT_REPOSITORY_OPEN_FROM_ENV: c_int = 16;
pub const git_repository_open_flag_t = c_uint;
pub extern fn git_repository_open_ext(out: [*c]?*git_repository, path: [*c]const u8, flags: c_uint, ceiling_dirs: [*c]const u8) c_int;
pub extern fn git_repository_open_bare(out: [*c]?*git_repository, bare_path: [*c]const u8) c_int;
pub extern fn git_repository_free(repo: ?*git_repository) void;
pub extern fn git_repository_init(out: [*c]?*git_repository, path: [*c]const u8, is_bare: c_uint) c_int;
pub const GIT_REPOSITORY_INIT_BARE: c_int = 1;
pub const GIT_REPOSITORY_INIT_NO_REINIT: c_int = 2;
pub const GIT_REPOSITORY_INIT_NO_DOTGIT_DIR: c_int = 4;
pub const GIT_REPOSITORY_INIT_MKDIR: c_int = 8;
pub const GIT_REPOSITORY_INIT_MKPATH: c_int = 16;
pub const GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE: c_int = 32;
pub const GIT_REPOSITORY_INIT_RELATIVE_GITLINK: c_int = 64;
pub const git_repository_init_flag_t = c_uint;
pub const GIT_REPOSITORY_INIT_SHARED_UMASK: c_int = 0;
pub const GIT_REPOSITORY_INIT_SHARED_GROUP: c_int = 1533;
pub const GIT_REPOSITORY_INIT_SHARED_ALL: c_int = 1535;
pub const git_repository_init_mode_t = c_uint;
pub const git_repository_init_options = extern struct {
    version: c_uint,
    flags: u32,
    mode: u32,
    workdir_path: [*c]const u8,
    description: [*c]const u8,
    template_path: [*c]const u8,
    initial_head: [*c]const u8,
    origin_url: [*c]const u8,
};
pub extern fn git_repository_init_options_init(opts: [*c]git_repository_init_options, version: c_uint) c_int;
pub extern fn git_repository_init_ext(out: [*c]?*git_repository, repo_path: [*c]const u8, opts: [*c]git_repository_init_options) c_int;
pub extern fn git_repository_head(out: [*c]?*git_reference, repo: ?*git_repository) c_int;
pub extern fn git_repository_head_for_worktree(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_repository_head_detached(repo: ?*git_repository) c_int;
pub extern fn git_repository_head_detached_for_worktree(repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_repository_head_unborn(repo: ?*git_repository) c_int;
pub extern fn git_repository_is_empty(repo: ?*git_repository) c_int;
pub const GIT_REPOSITORY_ITEM_GITDIR: c_int = 0;
pub const GIT_REPOSITORY_ITEM_WORKDIR: c_int = 1;
pub const GIT_REPOSITORY_ITEM_COMMONDIR: c_int = 2;
pub const GIT_REPOSITORY_ITEM_INDEX: c_int = 3;
pub const GIT_REPOSITORY_ITEM_OBJECTS: c_int = 4;
pub const GIT_REPOSITORY_ITEM_REFS: c_int = 5;
pub const GIT_REPOSITORY_ITEM_PACKED_REFS: c_int = 6;
pub const GIT_REPOSITORY_ITEM_REMOTES: c_int = 7;
pub const GIT_REPOSITORY_ITEM_CONFIG: c_int = 8;
pub const GIT_REPOSITORY_ITEM_INFO: c_int = 9;
pub const GIT_REPOSITORY_ITEM_HOOKS: c_int = 10;
pub const GIT_REPOSITORY_ITEM_LOGS: c_int = 11;
pub const GIT_REPOSITORY_ITEM_MODULES: c_int = 12;
pub const GIT_REPOSITORY_ITEM_WORKTREES: c_int = 13;
pub const GIT_REPOSITORY_ITEM__LAST: c_int = 14;
pub const git_repository_item_t = c_uint;
pub extern fn git_repository_item_path(out: [*c]git_buf, repo: ?*const git_repository, item: git_repository_item_t) c_int;
pub extern fn git_repository_path(repo: ?*const git_repository) [*c]const u8;
pub extern fn git_repository_workdir(repo: ?*const git_repository) [*c]const u8;
pub extern fn git_repository_commondir(repo: ?*const git_repository) [*c]const u8;
pub extern fn git_repository_set_workdir(repo: ?*git_repository, workdir: [*c]const u8, update_gitlink: c_int) c_int;
pub extern fn git_repository_is_bare(repo: ?*const git_repository) c_int;
pub extern fn git_repository_is_worktree(repo: ?*const git_repository) c_int;
pub extern fn git_repository_config(out: [*c]?*git_config, repo: ?*git_repository) c_int;
pub extern fn git_repository_config_snapshot(out: [*c]?*git_config, repo: ?*git_repository) c_int;
pub extern fn git_repository_odb(out: [*c]?*git_odb, repo: ?*git_repository) c_int;
pub extern fn git_repository_refdb(out: [*c]?*git_refdb, repo: ?*git_repository) c_int;
pub extern fn git_repository_index(out: [*c]?*git_index, repo: ?*git_repository) c_int;
pub extern fn git_repository_message(out: [*c]git_buf, repo: ?*git_repository) c_int;
pub extern fn git_repository_message_remove(repo: ?*git_repository) c_int;
pub extern fn git_repository_state_cleanup(repo: ?*git_repository) c_int;
pub const git_repository_fetchhead_foreach_cb = ?fn ([*c]const u8, [*c]const u8, [*c]const git_oid, c_uint, ?*c_void) callconv(.C) c_int;
pub extern fn git_repository_fetchhead_foreach(repo: ?*git_repository, callback: git_repository_fetchhead_foreach_cb, payload: ?*c_void) c_int;
pub const git_repository_mergehead_foreach_cb = ?fn ([*c]const git_oid, ?*c_void) callconv(.C) c_int;
pub extern fn git_repository_mergehead_foreach(repo: ?*git_repository, callback: git_repository_mergehead_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_repository_hashfile(out: [*c]git_oid, repo: ?*git_repository, path: [*c]const u8, @"type": git_object_t, as_path: [*c]const u8) c_int;
pub extern fn git_repository_set_head(repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_repository_set_head_detached(repo: ?*git_repository, commitish: [*c]const git_oid) c_int;
pub extern fn git_repository_set_head_detached_from_annotated(repo: ?*git_repository, commitish: ?*const git_annotated_commit) c_int;
pub extern fn git_repository_detach_head(repo: ?*git_repository) c_int;
pub const GIT_REPOSITORY_STATE_NONE: c_int = 0;
pub const GIT_REPOSITORY_STATE_MERGE: c_int = 1;
pub const GIT_REPOSITORY_STATE_REVERT: c_int = 2;
pub const GIT_REPOSITORY_STATE_REVERT_SEQUENCE: c_int = 3;
pub const GIT_REPOSITORY_STATE_CHERRYPICK: c_int = 4;
pub const GIT_REPOSITORY_STATE_CHERRYPICK_SEQUENCE: c_int = 5;
pub const GIT_REPOSITORY_STATE_BISECT: c_int = 6;
pub const GIT_REPOSITORY_STATE_REBASE: c_int = 7;
pub const GIT_REPOSITORY_STATE_REBASE_INTERACTIVE: c_int = 8;
pub const GIT_REPOSITORY_STATE_REBASE_MERGE: c_int = 9;
pub const GIT_REPOSITORY_STATE_APPLY_MAILBOX: c_int = 10;
pub const GIT_REPOSITORY_STATE_APPLY_MAILBOX_OR_REBASE: c_int = 11;
pub const git_repository_state_t = c_uint;
pub extern fn git_repository_state(repo: ?*git_repository) c_int;
pub extern fn git_repository_set_namespace(repo: ?*git_repository, nmspace: [*c]const u8) c_int;
pub extern fn git_repository_get_namespace(repo: ?*git_repository) [*c]const u8;
pub extern fn git_repository_is_shallow(repo: ?*git_repository) c_int;
pub extern fn git_repository_ident(name: [*c][*c]const u8, email: [*c][*c]const u8, repo: ?*const git_repository) c_int;
pub extern fn git_repository_set_ident(repo: ?*git_repository, name: [*c]const u8, email: [*c]const u8) c_int;
pub extern fn git_annotated_commit_from_ref(out: [*c]?*git_annotated_commit, repo: ?*git_repository, ref: ?*const git_reference) c_int;
pub extern fn git_annotated_commit_from_fetchhead(out: [*c]?*git_annotated_commit, repo: ?*git_repository, branch_name: [*c]const u8, remote_url: [*c]const u8, id: [*c]const git_oid) c_int;
pub extern fn git_annotated_commit_lookup(out: [*c]?*git_annotated_commit, repo: ?*git_repository, id: [*c]const git_oid) c_int;
pub extern fn git_annotated_commit_from_revspec(out: [*c]?*git_annotated_commit, repo: ?*git_repository, revspec: [*c]const u8) c_int;
pub extern fn git_annotated_commit_id(commit: ?*const git_annotated_commit) [*c]const git_oid;
pub extern fn git_annotated_commit_ref(commit: ?*const git_annotated_commit) [*c]const u8;
pub extern fn git_annotated_commit_free(commit: ?*git_annotated_commit) void;
pub extern fn git_object_lookup(object: [*c]?*git_object, repo: ?*git_repository, id: [*c]const git_oid, @"type": git_object_t) c_int;
pub extern fn git_object_lookup_prefix(object_out: [*c]?*git_object, repo: ?*git_repository, id: [*c]const git_oid, len: usize, @"type": git_object_t) c_int;
pub extern fn git_object_lookup_bypath(out: [*c]?*git_object, treeish: ?*const git_object, path: [*c]const u8, @"type": git_object_t) c_int;
pub extern fn git_object_id(obj: ?*const git_object) [*c]const git_oid;
pub extern fn git_object_short_id(out: [*c]git_buf, obj: ?*const git_object) c_int;
pub extern fn git_object_type(obj: ?*const git_object) git_object_t;
pub extern fn git_object_owner(obj: ?*const git_object) ?*git_repository;
pub extern fn git_object_free(object: ?*git_object) void;
pub extern fn git_object_type2string(@"type": git_object_t) [*c]const u8;
pub extern fn git_object_string2type(str: [*c]const u8) git_object_t;
pub extern fn git_object_typeisloose(@"type": git_object_t) c_int;
pub extern fn git_object_peel(peeled: [*c]?*git_object, object: ?*const git_object, target_type: git_object_t) c_int;
pub extern fn git_object_dup(dest: [*c]?*git_object, source: ?*git_object) c_int;
pub extern fn git_tree_lookup(out: [*c]?*git_tree, repo: ?*git_repository, id: [*c]const git_oid) c_int;
pub extern fn git_tree_lookup_prefix(out: [*c]?*git_tree, repo: ?*git_repository, id: [*c]const git_oid, len: usize) c_int;
pub extern fn git_tree_free(tree: ?*git_tree) void;
pub extern fn git_tree_id(tree: ?*const git_tree) [*c]const git_oid;
pub extern fn git_tree_owner(tree: ?*const git_tree) ?*git_repository;
pub extern fn git_tree_entrycount(tree: ?*const git_tree) usize;
pub extern fn git_tree_entry_byname(tree: ?*const git_tree, filename: [*c]const u8) ?*const git_tree_entry;
pub extern fn git_tree_entry_byindex(tree: ?*const git_tree, idx: usize) ?*const git_tree_entry;
pub extern fn git_tree_entry_byid(tree: ?*const git_tree, id: [*c]const git_oid) ?*const git_tree_entry;
pub extern fn git_tree_entry_bypath(out: [*c]?*git_tree_entry, root: ?*const git_tree, path: [*c]const u8) c_int;
pub extern fn git_tree_entry_dup(dest: [*c]?*git_tree_entry, source: ?*const git_tree_entry) c_int;
pub extern fn git_tree_entry_free(entry: ?*git_tree_entry) void;
pub extern fn git_tree_entry_name(entry: ?*const git_tree_entry) [*c]const u8;
pub extern fn git_tree_entry_id(entry: ?*const git_tree_entry) [*c]const git_oid;
pub extern fn git_tree_entry_type(entry: ?*const git_tree_entry) git_object_t;
pub extern fn git_tree_entry_filemode(entry: ?*const git_tree_entry) git_filemode_t;
pub extern fn git_tree_entry_filemode_raw(entry: ?*const git_tree_entry) git_filemode_t;
pub extern fn git_tree_entry_cmp(e1: ?*const git_tree_entry, e2: ?*const git_tree_entry) c_int;
pub extern fn git_tree_entry_to_object(object_out: [*c]?*git_object, repo: ?*git_repository, entry: ?*const git_tree_entry) c_int;
pub extern fn git_treebuilder_new(out: [*c]?*git_treebuilder, repo: ?*git_repository, source: ?*const git_tree) c_int;
pub extern fn git_treebuilder_clear(bld: ?*git_treebuilder) c_int;
pub extern fn git_treebuilder_entrycount(bld: ?*git_treebuilder) usize;
pub extern fn git_treebuilder_free(bld: ?*git_treebuilder) void;
pub extern fn git_treebuilder_get(bld: ?*git_treebuilder, filename: [*c]const u8) ?*const git_tree_entry;
pub extern fn git_treebuilder_insert(out: [*c]?*const git_tree_entry, bld: ?*git_treebuilder, filename: [*c]const u8, id: [*c]const git_oid, filemode: git_filemode_t) c_int;
pub extern fn git_treebuilder_remove(bld: ?*git_treebuilder, filename: [*c]const u8) c_int;
pub const git_treebuilder_filter_cb = ?fn (?*const git_tree_entry, ?*c_void) callconv(.C) c_int;
pub extern fn git_treebuilder_filter(bld: ?*git_treebuilder, filter: git_treebuilder_filter_cb, payload: ?*c_void) c_int;
pub extern fn git_treebuilder_write(id: [*c]git_oid, bld: ?*git_treebuilder) c_int;
pub const git_treewalk_cb = ?fn ([*c]const u8, ?*const git_tree_entry, ?*c_void) callconv(.C) c_int;
pub const GIT_TREEWALK_PRE: c_int = 0;
pub const GIT_TREEWALK_POST: c_int = 1;
pub const git_treewalk_mode = c_uint;
pub extern fn git_tree_walk(tree: ?*const git_tree, mode: git_treewalk_mode, callback: git_treewalk_cb, payload: ?*c_void) c_int;
pub extern fn git_tree_dup(out: [*c]?*git_tree, source: ?*git_tree) c_int;
pub const GIT_TREE_UPDATE_UPSERT: c_int = 0;
pub const GIT_TREE_UPDATE_REMOVE: c_int = 1;
pub const git_tree_update_t = c_uint;
pub const git_tree_update = extern struct {
    action: git_tree_update_t,
    id: git_oid,
    filemode: git_filemode_t,
    path: [*c]const u8,
};
pub extern fn git_tree_create_updated(out: [*c]git_oid, repo: ?*git_repository, baseline: ?*git_tree, nupdates: usize, updates: [*c]const git_tree_update) c_int;
pub const struct_git_strarray = extern struct {
    strings: [*c][*c]u8,
    count: usize,
};
pub const git_strarray = struct_git_strarray;
pub extern fn git_strarray_dispose(array: [*c]git_strarray) void;
pub extern fn git_strarray_copy(tgt: [*c]git_strarray, src: [*c]const git_strarray) c_int;
pub extern fn git_reference_lookup(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_reference_name_to_id(out: [*c]git_oid, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_reference_dwim(out: [*c]?*git_reference, repo: ?*git_repository, shorthand: [*c]const u8) c_int;
pub extern fn git_reference_symbolic_create_matching(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8, target: [*c]const u8, force: c_int, current_value: [*c]const u8, log_message: [*c]const u8) c_int;
pub extern fn git_reference_symbolic_create(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8, target: [*c]const u8, force: c_int, log_message: [*c]const u8) c_int;
pub extern fn git_reference_create(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8, id: [*c]const git_oid, force: c_int, log_message: [*c]const u8) c_int;
pub extern fn git_reference_create_matching(out: [*c]?*git_reference, repo: ?*git_repository, name: [*c]const u8, id: [*c]const git_oid, force: c_int, current_id: [*c]const git_oid, log_message: [*c]const u8) c_int;
pub extern fn git_reference_target(ref: ?*const git_reference) [*c]const git_oid;
pub extern fn git_reference_target_peel(ref: ?*const git_reference) [*c]const git_oid;
pub extern fn git_reference_symbolic_target(ref: ?*const git_reference) [*c]const u8;
pub extern fn git_reference_type(ref: ?*const git_reference) git_reference_t;
pub extern fn git_reference_name(ref: ?*const git_reference) [*c]const u8;
pub extern fn git_reference_resolve(out: [*c]?*git_reference, ref: ?*const git_reference) c_int;
pub extern fn git_reference_owner(ref: ?*const git_reference) ?*git_repository;
pub extern fn git_reference_symbolic_set_target(out: [*c]?*git_reference, ref: ?*git_reference, target: [*c]const u8, log_message: [*c]const u8) c_int;
pub extern fn git_reference_set_target(out: [*c]?*git_reference, ref: ?*git_reference, id: [*c]const git_oid, log_message: [*c]const u8) c_int;
pub extern fn git_reference_rename(new_ref: [*c]?*git_reference, ref: ?*git_reference, new_name: [*c]const u8, force: c_int, log_message: [*c]const u8) c_int;
pub extern fn git_reference_delete(ref: ?*git_reference) c_int;
pub extern fn git_reference_remove(repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_reference_list(array: [*c]git_strarray, repo: ?*git_repository) c_int;
pub const git_reference_foreach_cb = ?fn (?*git_reference, ?*c_void) callconv(.C) c_int;
pub const git_reference_foreach_name_cb = ?fn ([*c]const u8, ?*c_void) callconv(.C) c_int;
pub extern fn git_reference_foreach(repo: ?*git_repository, callback: git_reference_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_reference_foreach_name(repo: ?*git_repository, callback: git_reference_foreach_name_cb, payload: ?*c_void) c_int;
pub extern fn git_reference_dup(dest: [*c]?*git_reference, source: ?*git_reference) c_int;
pub extern fn git_reference_free(ref: ?*git_reference) void;
pub extern fn git_reference_cmp(ref1: ?*const git_reference, ref2: ?*const git_reference) c_int;
pub extern fn git_reference_iterator_new(out: [*c]?*git_reference_iterator, repo: ?*git_repository) c_int;
pub extern fn git_reference_iterator_glob_new(out: [*c]?*git_reference_iterator, repo: ?*git_repository, glob: [*c]const u8) c_int;
pub extern fn git_reference_next(out: [*c]?*git_reference, iter: ?*git_reference_iterator) c_int;
pub extern fn git_reference_next_name(out: [*c][*c]const u8, iter: ?*git_reference_iterator) c_int;
pub extern fn git_reference_iterator_free(iter: ?*git_reference_iterator) void;
pub extern fn git_reference_foreach_glob(repo: ?*git_repository, glob: [*c]const u8, callback: git_reference_foreach_name_cb, payload: ?*c_void) c_int;
pub extern fn git_reference_has_log(repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_reference_ensure_log(repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_reference_is_branch(ref: ?*const git_reference) c_int;
pub extern fn git_reference_is_remote(ref: ?*const git_reference) c_int;
pub extern fn git_reference_is_tag(ref: ?*const git_reference) c_int;
pub extern fn git_reference_is_note(ref: ?*const git_reference) c_int;
pub const GIT_REFERENCE_FORMAT_NORMAL: c_int = 0;
pub const GIT_REFERENCE_FORMAT_ALLOW_ONELEVEL: c_int = 1;
pub const GIT_REFERENCE_FORMAT_REFSPEC_PATTERN: c_int = 2;
pub const GIT_REFERENCE_FORMAT_REFSPEC_SHORTHAND: c_int = 4;
pub const git_reference_format_t = c_uint;
pub extern fn git_reference_normalize_name(buffer_out: [*c]u8, buffer_size: usize, name: [*c]const u8, flags: c_uint) c_int;
pub extern fn git_reference_peel(out: [*c]?*git_object, ref: ?*const git_reference, @"type": git_object_t) c_int;
pub extern fn git_reference_name_is_valid(valid: [*c]c_int, refname: [*c]const u8) c_int;
pub extern fn git_reference_shorthand(ref: ?*const git_reference) [*c]const u8;
pub const GIT_DIFF_NORMAL: c_int = 0;
pub const GIT_DIFF_REVERSE: c_int = 1;
pub const GIT_DIFF_INCLUDE_IGNORED: c_int = 2;
pub const GIT_DIFF_RECURSE_IGNORED_DIRS: c_int = 4;
pub const GIT_DIFF_INCLUDE_UNTRACKED: c_int = 8;
pub const GIT_DIFF_RECURSE_UNTRACKED_DIRS: c_int = 16;
pub const GIT_DIFF_INCLUDE_UNMODIFIED: c_int = 32;
pub const GIT_DIFF_INCLUDE_TYPECHANGE: c_int = 64;
pub const GIT_DIFF_INCLUDE_TYPECHANGE_TREES: c_int = 128;
pub const GIT_DIFF_IGNORE_FILEMODE: c_int = 256;
pub const GIT_DIFF_IGNORE_SUBMODULES: c_int = 512;
pub const GIT_DIFF_IGNORE_CASE: c_int = 1024;
pub const GIT_DIFF_INCLUDE_CASECHANGE: c_int = 2048;
pub const GIT_DIFF_DISABLE_PATHSPEC_MATCH: c_int = 4096;
pub const GIT_DIFF_SKIP_BINARY_CHECK: c_int = 8192;
pub const GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS: c_int = 16384;
pub const GIT_DIFF_UPDATE_INDEX: c_int = 32768;
pub const GIT_DIFF_INCLUDE_UNREADABLE: c_int = 65536;
pub const GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED: c_int = 131072;
pub const GIT_DIFF_INDENT_HEURISTIC: c_int = 262144;
pub const GIT_DIFF_FORCE_TEXT: c_int = 1048576;
pub const GIT_DIFF_FORCE_BINARY: c_int = 2097152;
pub const GIT_DIFF_IGNORE_WHITESPACE: c_int = 4194304;
pub const GIT_DIFF_IGNORE_WHITESPACE_CHANGE: c_int = 8388608;
pub const GIT_DIFF_IGNORE_WHITESPACE_EOL: c_int = 16777216;
pub const GIT_DIFF_SHOW_UNTRACKED_CONTENT: c_int = 33554432;
pub const GIT_DIFF_SHOW_UNMODIFIED: c_int = 67108864;
pub const GIT_DIFF_PATIENCE: c_int = 268435456;
pub const GIT_DIFF_MINIMAL: c_int = 536870912;
pub const GIT_DIFF_SHOW_BINARY: c_int = 1073741824;
pub const GIT_DIFF_IGNORE_BLANK_LINES: c_uint = 2147483648;
pub const git_diff_option_t = c_uint;
pub const struct_git_diff = opaque {};
pub const git_diff = struct_git_diff;
pub const GIT_DIFF_FLAG_BINARY: c_int = 1;
pub const GIT_DIFF_FLAG_NOT_BINARY: c_int = 2;
pub const GIT_DIFF_FLAG_VALID_ID: c_int = 4;
pub const GIT_DIFF_FLAG_EXISTS: c_int = 8;
pub const git_diff_flag_t = c_uint;
pub const GIT_DELTA_UNMODIFIED: c_int = 0;
pub const GIT_DELTA_ADDED: c_int = 1;
pub const GIT_DELTA_DELETED: c_int = 2;
pub const GIT_DELTA_MODIFIED: c_int = 3;
pub const GIT_DELTA_RENAMED: c_int = 4;
pub const GIT_DELTA_COPIED: c_int = 5;
pub const GIT_DELTA_IGNORED: c_int = 6;
pub const GIT_DELTA_UNTRACKED: c_int = 7;
pub const GIT_DELTA_TYPECHANGE: c_int = 8;
pub const GIT_DELTA_UNREADABLE: c_int = 9;
pub const GIT_DELTA_CONFLICTED: c_int = 10;
pub const git_delta_t = c_uint;
pub const git_diff_file = extern struct {
    id: git_oid,
    path: [*c]const u8,
    size: git_object_size_t,
    flags: u32,
    mode: u16,
    id_abbrev: u16,
};
pub const git_diff_delta = extern struct {
    status: git_delta_t,
    flags: u32,
    similarity: u16,
    nfiles: u16,
    old_file: git_diff_file,
    new_file: git_diff_file,
};
pub const git_diff_notify_cb = ?fn (?*const git_diff, [*c]const git_diff_delta, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const git_diff_progress_cb = ?fn (?*const git_diff, [*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const git_diff_options = extern struct {
    version: c_uint,
    flags: u32,
    ignore_submodules: git_submodule_ignore_t,
    pathspec: git_strarray,
    notify_cb: git_diff_notify_cb,
    progress_cb: git_diff_progress_cb,
    payload: ?*c_void,
    context_lines: u32,
    interhunk_lines: u32,
    id_abbrev: u16,
    max_size: git_off_t,
    old_prefix: [*c]const u8,
    new_prefix: [*c]const u8,
};
pub extern fn git_diff_options_init(opts: [*c]git_diff_options, version: c_uint) c_int;
pub const git_diff_file_cb = ?fn ([*c]const git_diff_delta, f32, ?*c_void) callconv(.C) c_int;
pub const GIT_DIFF_BINARY_NONE: c_int = 0;
pub const GIT_DIFF_BINARY_LITERAL: c_int = 1;
pub const GIT_DIFF_BINARY_DELTA: c_int = 2;
pub const git_diff_binary_t = c_uint;
pub const git_diff_binary_file = extern struct {
    type: git_diff_binary_t,
    data: [*c]const u8,
    datalen: usize,
    inflatedlen: usize,
};
pub const git_diff_binary = extern struct {
    contains_data: c_uint,
    old_file: git_diff_binary_file,
    new_file: git_diff_binary_file,
};
pub const git_diff_binary_cb = ?fn ([*c]const git_diff_delta, [*c]const git_diff_binary, ?*c_void) callconv(.C) c_int;
pub const git_diff_hunk = extern struct {
    old_start: c_int,
    old_lines: c_int,
    new_start: c_int,
    new_lines: c_int,
    header_len: usize,
    header: [128]u8,
};
pub const git_diff_hunk_cb = ?fn ([*c]const git_diff_delta, [*c]const git_diff_hunk, ?*c_void) callconv(.C) c_int;
pub const GIT_DIFF_LINE_CONTEXT: c_int = 32;
pub const GIT_DIFF_LINE_ADDITION: c_int = 43;
pub const GIT_DIFF_LINE_DELETION: c_int = 45;
pub const GIT_DIFF_LINE_CONTEXT_EOFNL: c_int = 61;
pub const GIT_DIFF_LINE_ADD_EOFNL: c_int = 62;
pub const GIT_DIFF_LINE_DEL_EOFNL: c_int = 60;
pub const GIT_DIFF_LINE_FILE_HDR: c_int = 70;
pub const GIT_DIFF_LINE_HUNK_HDR: c_int = 72;
pub const GIT_DIFF_LINE_BINARY: c_int = 66;
pub const git_diff_line_t = c_uint;
pub const git_diff_line = extern struct {
    origin: u8,
    old_lineno: c_int,
    new_lineno: c_int,
    num_lines: c_int,
    content_len: usize,
    content_offset: git_off_t,
    content: [*c]const u8,
};
pub const git_diff_line_cb = ?fn ([*c]const git_diff_delta, [*c]const git_diff_hunk, [*c]const git_diff_line, ?*c_void) callconv(.C) c_int;
pub const GIT_DIFF_FIND_BY_CONFIG: c_int = 0;
pub const GIT_DIFF_FIND_RENAMES: c_int = 1;
pub const GIT_DIFF_FIND_RENAMES_FROM_REWRITES: c_int = 2;
pub const GIT_DIFF_FIND_COPIES: c_int = 4;
pub const GIT_DIFF_FIND_COPIES_FROM_UNMODIFIED: c_int = 8;
pub const GIT_DIFF_FIND_REWRITES: c_int = 16;
pub const GIT_DIFF_BREAK_REWRITES: c_int = 32;
pub const GIT_DIFF_FIND_AND_BREAK_REWRITES: c_int = 48;
pub const GIT_DIFF_FIND_FOR_UNTRACKED: c_int = 64;
pub const GIT_DIFF_FIND_ALL: c_int = 255;
pub const GIT_DIFF_FIND_IGNORE_LEADING_WHITESPACE: c_int = 0;
pub const GIT_DIFF_FIND_IGNORE_WHITESPACE: c_int = 4096;
pub const GIT_DIFF_FIND_DONT_IGNORE_WHITESPACE: c_int = 8192;
pub const GIT_DIFF_FIND_EXACT_MATCH_ONLY: c_int = 16384;
pub const GIT_DIFF_BREAK_REWRITES_FOR_RENAMES_ONLY: c_int = 32768;
pub const GIT_DIFF_FIND_REMOVE_UNMODIFIED: c_int = 65536;
pub const git_diff_find_t = c_uint;
pub const git_diff_similarity_metric = extern struct {
    file_signature: ?fn ([*c]?*c_void, [*c]const git_diff_file, [*c]const u8, ?*c_void) callconv(.C) c_int,
    buffer_signature: ?fn ([*c]?*c_void, [*c]const git_diff_file, [*c]const u8, usize, ?*c_void) callconv(.C) c_int,
    free_signature: ?fn (?*c_void, ?*c_void) callconv(.C) void,
    similarity: ?fn ([*c]c_int, ?*c_void, ?*c_void, ?*c_void) callconv(.C) c_int,
    payload: ?*c_void,
};
pub const git_diff_find_options = extern struct {
    version: c_uint,
    flags: u32,
    rename_threshold: u16,
    rename_from_rewrite_threshold: u16,
    copy_threshold: u16,
    break_rewrite_threshold: u16,
    rename_limit: usize,
    metric: [*c]git_diff_similarity_metric,
};
pub extern fn git_diff_find_options_init(opts: [*c]git_diff_find_options, version: c_uint) c_int;
pub extern fn git_diff_free(diff: ?*git_diff) void;
pub extern fn git_diff_tree_to_tree(diff: [*c]?*git_diff, repo: ?*git_repository, old_tree: ?*git_tree, new_tree: ?*git_tree, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_tree_to_index(diff: [*c]?*git_diff, repo: ?*git_repository, old_tree: ?*git_tree, index: ?*git_index, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_index_to_workdir(diff: [*c]?*git_diff, repo: ?*git_repository, index: ?*git_index, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_tree_to_workdir(diff: [*c]?*git_diff, repo: ?*git_repository, old_tree: ?*git_tree, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_tree_to_workdir_with_index(diff: [*c]?*git_diff, repo: ?*git_repository, old_tree: ?*git_tree, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_index_to_index(diff: [*c]?*git_diff, repo: ?*git_repository, old_index: ?*git_index, new_index: ?*git_index, opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_merge(onto: ?*git_diff, from: ?*const git_diff) c_int;
pub extern fn git_diff_find_similar(diff: ?*git_diff, options: [*c]const git_diff_find_options) c_int;
pub extern fn git_diff_num_deltas(diff: ?*const git_diff) usize;
pub extern fn git_diff_num_deltas_of_type(diff: ?*const git_diff, @"type": git_delta_t) usize;
pub extern fn git_diff_get_delta(diff: ?*const git_diff, idx: usize) [*c]const git_diff_delta;
pub extern fn git_diff_is_sorted_icase(diff: ?*const git_diff) c_int;
pub extern fn git_diff_foreach(diff: ?*git_diff, file_cb: git_diff_file_cb, binary_cb: git_diff_binary_cb, hunk_cb: git_diff_hunk_cb, line_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_diff_status_char(status: git_delta_t) u8;
pub const GIT_DIFF_FORMAT_PATCH: c_int = 1;
pub const GIT_DIFF_FORMAT_PATCH_HEADER: c_int = 2;
pub const GIT_DIFF_FORMAT_RAW: c_int = 3;
pub const GIT_DIFF_FORMAT_NAME_ONLY: c_int = 4;
pub const GIT_DIFF_FORMAT_NAME_STATUS: c_int = 5;
pub const GIT_DIFF_FORMAT_PATCH_ID: c_int = 6;
pub const git_diff_format_t = c_uint;
pub extern fn git_diff_print(diff: ?*git_diff, format: git_diff_format_t, print_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_diff_to_buf(out: [*c]git_buf, diff: ?*git_diff, format: git_diff_format_t) c_int;
pub extern fn git_diff_blobs(old_blob: ?*const git_blob, old_as_path: [*c]const u8, new_blob: ?*const git_blob, new_as_path: [*c]const u8, options: [*c]const git_diff_options, file_cb: git_diff_file_cb, binary_cb: git_diff_binary_cb, hunk_cb: git_diff_hunk_cb, line_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_diff_blob_to_buffer(old_blob: ?*const git_blob, old_as_path: [*c]const u8, buffer: [*c]const u8, buffer_len: usize, buffer_as_path: [*c]const u8, options: [*c]const git_diff_options, file_cb: git_diff_file_cb, binary_cb: git_diff_binary_cb, hunk_cb: git_diff_hunk_cb, line_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_diff_buffers(old_buffer: ?*const c_void, old_len: usize, old_as_path: [*c]const u8, new_buffer: ?*const c_void, new_len: usize, new_as_path: [*c]const u8, options: [*c]const git_diff_options, file_cb: git_diff_file_cb, binary_cb: git_diff_binary_cb, hunk_cb: git_diff_hunk_cb, line_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_diff_from_buffer(out: [*c]?*git_diff, content: [*c]const u8, content_len: usize) c_int;
pub const struct_git_diff_stats = opaque {};
pub const git_diff_stats = struct_git_diff_stats;
pub const GIT_DIFF_STATS_NONE: c_int = 0;
pub const GIT_DIFF_STATS_FULL: c_int = 1;
pub const GIT_DIFF_STATS_SHORT: c_int = 2;
pub const GIT_DIFF_STATS_NUMBER: c_int = 4;
pub const GIT_DIFF_STATS_INCLUDE_SUMMARY: c_int = 8;
pub const git_diff_stats_format_t = c_uint;
pub extern fn git_diff_get_stats(out: [*c]?*git_diff_stats, diff: ?*git_diff) c_int;
pub extern fn git_diff_stats_files_changed(stats: ?*const git_diff_stats) usize;
pub extern fn git_diff_stats_insertions(stats: ?*const git_diff_stats) usize;
pub extern fn git_diff_stats_deletions(stats: ?*const git_diff_stats) usize;
pub extern fn git_diff_stats_to_buf(out: [*c]git_buf, stats: ?*const git_diff_stats, format: git_diff_stats_format_t, width: usize) c_int;
pub extern fn git_diff_stats_free(stats: ?*git_diff_stats) void;
pub const GIT_DIFF_FORMAT_EMAIL_NONE: c_int = 0;
pub const GIT_DIFF_FORMAT_EMAIL_EXCLUDE_SUBJECT_PATCH_MARKER: c_int = 1;
pub const git_diff_format_email_flags_t = c_uint;
pub const git_diff_format_email_options = extern struct {
    version: c_uint,
    flags: u32,
    patch_no: usize,
    total_patches: usize,
    id: [*c]const git_oid,
    summary: [*c]const u8,
    body: [*c]const u8,
    author: [*c]const git_signature,
};
pub extern fn git_diff_format_email(out: [*c]git_buf, diff: ?*git_diff, opts: [*c]const git_diff_format_email_options) c_int;
pub extern fn git_diff_commit_as_email(out: [*c]git_buf, repo: ?*git_repository, commit: ?*git_commit, patch_no: usize, total_patches: usize, flags: u32, diff_opts: [*c]const git_diff_options) c_int;
pub extern fn git_diff_format_email_options_init(opts: [*c]git_diff_format_email_options, version: c_uint) c_int;
pub const struct_git_diff_patchid_options = extern struct {
    version: c_uint,
};
pub const git_diff_patchid_options = struct_git_diff_patchid_options;
pub extern fn git_diff_patchid_options_init(opts: [*c]git_diff_patchid_options, version: c_uint) c_int;
pub extern fn git_diff_patchid(out: [*c]git_oid, diff: ?*git_diff, opts: [*c]git_diff_patchid_options) c_int;
pub const git_apply_delta_cb = ?fn ([*c]const git_diff_delta, ?*c_void) callconv(.C) c_int;
pub const git_apply_hunk_cb = ?fn ([*c]const git_diff_hunk, ?*c_void) callconv(.C) c_int;
pub const GIT_APPLY_CHECK: c_int = 1;
pub const git_apply_flags_t = c_uint;
pub const git_apply_options = extern struct {
    version: c_uint,
    delta_cb: git_apply_delta_cb,
    hunk_cb: git_apply_hunk_cb,
    payload: ?*c_void,
    flags: c_uint,
};
pub extern fn git_apply_options_init(opts: [*c]git_apply_options, version: c_uint) c_int;
pub extern fn git_apply_to_tree(out: [*c]?*git_index, repo: ?*git_repository, preimage: ?*git_tree, diff: ?*git_diff, options: [*c]const git_apply_options) c_int;
pub const GIT_APPLY_LOCATION_WORKDIR: c_int = 0;
pub const GIT_APPLY_LOCATION_INDEX: c_int = 1;
pub const GIT_APPLY_LOCATION_BOTH: c_int = 2;
pub const git_apply_location_t = c_uint;
pub extern fn git_apply(repo: ?*git_repository, diff: ?*git_diff, location: git_apply_location_t, options: [*c]const git_apply_options) c_int;
pub const GIT_ATTR_VALUE_UNSPECIFIED: c_int = 0;
pub const GIT_ATTR_VALUE_TRUE: c_int = 1;
pub const GIT_ATTR_VALUE_FALSE: c_int = 2;
pub const GIT_ATTR_VALUE_STRING: c_int = 3;
pub const git_attr_value_t = c_uint;
pub extern fn git_attr_value(attr: [*c]const u8) git_attr_value_t;
pub const git_attr_options = extern struct {
    version: c_uint,
    flags: c_uint,
    commit_id: [*c]git_oid,
};
pub extern fn git_attr_get(value_out: [*c][*c]const u8, repo: ?*git_repository, flags: u32, path: [*c]const u8, name: [*c]const u8) c_int;
pub extern fn git_attr_get_ext(value_out: [*c][*c]const u8, repo: ?*git_repository, opts: [*c]git_attr_options, path: [*c]const u8, name: [*c]const u8) c_int;
pub extern fn git_attr_get_many(values_out: [*c][*c]const u8, repo: ?*git_repository, flags: u32, path: [*c]const u8, num_attr: usize, names: [*c][*c]const u8) c_int;
pub extern fn git_attr_get_many_ext(values_out: [*c][*c]const u8, repo: ?*git_repository, opts: [*c]git_attr_options, path: [*c]const u8, num_attr: usize, names: [*c][*c]const u8) c_int;
pub const git_attr_foreach_cb = ?fn ([*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub extern fn git_attr_foreach(repo: ?*git_repository, flags: u32, path: [*c]const u8, callback: git_attr_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_attr_foreach_ext(repo: ?*git_repository, opts: [*c]git_attr_options, path: [*c]const u8, callback: git_attr_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_attr_cache_flush(repo: ?*git_repository) c_int;
pub extern fn git_attr_add_macro(repo: ?*git_repository, name: [*c]const u8, values: [*c]const u8) c_int;
pub extern fn git_blob_lookup(blob: [*c]?*git_blob, repo: ?*git_repository, id: [*c]const git_oid) c_int;
pub extern fn git_blob_lookup_prefix(blob: [*c]?*git_blob, repo: ?*git_repository, id: [*c]const git_oid, len: usize) c_int;
pub extern fn git_blob_free(blob: ?*git_blob) void;
pub extern fn git_blob_id(blob: ?*const git_blob) [*c]const git_oid;
pub extern fn git_blob_owner(blob: ?*const git_blob) ?*git_repository;
pub extern fn git_blob_rawcontent(blob: ?*const git_blob) ?*const c_void;
pub extern fn git_blob_rawsize(blob: ?*const git_blob) git_object_size_t;
pub const GIT_BLOB_FILTER_CHECK_FOR_BINARY: c_int = 1;
pub const GIT_BLOB_FILTER_NO_SYSTEM_ATTRIBUTES: c_int = 2;
pub const GIT_BLOB_FILTER_ATTRIBUTES_FROM_HEAD: c_int = 4;
pub const GIT_BLOB_FILTER_ATTRIBUTES_FROM_COMMIT: c_int = 8;
pub const git_blob_filter_flag_t = c_uint;
pub const git_blob_filter_options = extern struct {
    version: c_int,
    flags: u32,
    commit_id: [*c]git_oid,
};
pub extern fn git_blob_filter_options_init(opts: [*c]git_blob_filter_options, version: c_uint) c_int;
pub extern fn git_blob_filter(out: [*c]git_buf, blob: ?*git_blob, as_path: [*c]const u8, opts: [*c]git_blob_filter_options) c_int;
pub extern fn git_blob_create_from_workdir(id: [*c]git_oid, repo: ?*git_repository, relative_path: [*c]const u8) c_int;
pub extern fn git_blob_create_from_disk(id: [*c]git_oid, repo: ?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_blob_create_from_stream(out: [*c][*c]git_writestream, repo: ?*git_repository, hintpath: [*c]const u8) c_int;
pub extern fn git_blob_create_from_stream_commit(out: [*c]git_oid, stream: [*c]git_writestream) c_int;
pub extern fn git_blob_create_from_buffer(id: [*c]git_oid, repo: ?*git_repository, buffer: ?*const c_void, len: usize) c_int;
pub extern fn git_blob_is_binary(blob: ?*const git_blob) c_int;
pub extern fn git_blob_dup(out: [*c]?*git_blob, source: ?*git_blob) c_int;
pub const GIT_BLAME_NORMAL: c_int = 0;
pub const GIT_BLAME_TRACK_COPIES_SAME_FILE: c_int = 1;
pub const GIT_BLAME_TRACK_COPIES_SAME_COMMIT_MOVES: c_int = 2;
pub const GIT_BLAME_TRACK_COPIES_SAME_COMMIT_COPIES: c_int = 4;
pub const GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES: c_int = 8;
pub const GIT_BLAME_FIRST_PARENT: c_int = 16;
pub const GIT_BLAME_USE_MAILMAP: c_int = 32;
pub const GIT_BLAME_IGNORE_WHITESPACE: c_int = 64;
pub const git_blame_flag_t = c_uint;
pub const struct_git_blame_options = extern struct {
    version: c_uint,
    flags: u32,
    min_match_characters: u16,
    newest_commit: git_oid,
    oldest_commit: git_oid,
    min_line: usize,
    max_line: usize,
};
pub const git_blame_options = struct_git_blame_options;
pub extern fn git_blame_options_init(opts: [*c]git_blame_options, version: c_uint) c_int;
pub const struct_git_blame_hunk = extern struct {
    lines_in_hunk: usize,
    final_commit_id: git_oid,
    final_start_line_number: usize,
    final_signature: [*c]git_signature,
    orig_commit_id: git_oid,
    orig_path: [*c]const u8,
    orig_start_line_number: usize,
    orig_signature: [*c]git_signature,
    boundary: u8,
};
pub const git_blame_hunk = struct_git_blame_hunk;
pub const struct_git_blame = opaque {};
pub const git_blame = struct_git_blame;
pub extern fn git_blame_get_hunk_count(blame: ?*git_blame) u32;
pub extern fn git_blame_get_hunk_byindex(blame: ?*git_blame, index: u32) [*c]const git_blame_hunk;
pub extern fn git_blame_get_hunk_byline(blame: ?*git_blame, lineno: usize) [*c]const git_blame_hunk;
pub extern fn git_blame_file(out: [*c]?*git_blame, repo: ?*git_repository, path: [*c]const u8, options: [*c]git_blame_options) c_int;
pub extern fn git_blame_buffer(out: [*c]?*git_blame, reference: ?*git_blame, buffer: [*c]const u8, buffer_len: usize) c_int;
pub extern fn git_blame_free(blame: ?*git_blame) void;
pub extern fn git_branch_create(out: [*c]?*git_reference, repo: ?*git_repository, branch_name: [*c]const u8, target: ?*const git_commit, force: c_int) c_int;
pub extern fn git_branch_create_from_annotated(ref_out: [*c]?*git_reference, repository: ?*git_repository, branch_name: [*c]const u8, commit: ?*const git_annotated_commit, force: c_int) c_int;
pub extern fn git_branch_delete(branch: ?*git_reference) c_int;
pub const struct_git_branch_iterator = opaque {};
pub const git_branch_iterator = struct_git_branch_iterator;
pub extern fn git_branch_iterator_new(out: [*c]?*git_branch_iterator, repo: ?*git_repository, list_flags: git_branch_t) c_int;
pub extern fn git_branch_next(out: [*c]?*git_reference, out_type: [*c]git_branch_t, iter: ?*git_branch_iterator) c_int;
pub extern fn git_branch_iterator_free(iter: ?*git_branch_iterator) void;
pub extern fn git_branch_move(out: [*c]?*git_reference, branch: ?*git_reference, new_branch_name: [*c]const u8, force: c_int) c_int;
pub extern fn git_branch_lookup(out: [*c]?*git_reference, repo: ?*git_repository, branch_name: [*c]const u8, branch_type: git_branch_t) c_int;
pub extern fn git_branch_name(out: [*c][*c]const u8, ref: ?*const git_reference) c_int;
pub extern fn git_branch_upstream(out: [*c]?*git_reference, branch: ?*const git_reference) c_int;
pub extern fn git_branch_set_upstream(branch: ?*git_reference, branch_name: [*c]const u8) c_int;
pub extern fn git_branch_upstream_name(out: [*c]git_buf, repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_branch_is_head(branch: ?*const git_reference) c_int;
pub extern fn git_branch_is_checked_out(branch: ?*const git_reference) c_int;
pub extern fn git_branch_remote_name(out: [*c]git_buf, repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_branch_upstream_remote(buf: [*c]git_buf, repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_branch_upstream_merge(buf: [*c]git_buf, repo: ?*git_repository, refname: [*c]const u8) c_int;
pub extern fn git_branch_name_is_valid(valid: [*c]c_int, name: [*c]const u8) c_int;
pub const GIT_CERT_SSH_MD5: c_int = 1;
pub const GIT_CERT_SSH_SHA1: c_int = 2;
pub const GIT_CERT_SSH_SHA256: c_int = 4;
pub const GIT_CERT_SSH_RAW: c_int = 8;
pub const git_cert_ssh_t = c_uint;
pub const GIT_CERT_SSH_RAW_TYPE_UNKNOWN: c_int = 0;
pub const GIT_CERT_SSH_RAW_TYPE_RSA: c_int = 1;
pub const GIT_CERT_SSH_RAW_TYPE_DSS: c_int = 2;
pub const GIT_CERT_SSH_RAW_TYPE_KEY_ECDSA_256: c_int = 3;
pub const GIT_CERT_SSH_RAW_TYPE_KEY_ECDSA_384: c_int = 4;
pub const GIT_CERT_SSH_RAW_TYPE_KEY_ECDSA_521: c_int = 5;
pub const GIT_CERT_SSH_RAW_TYPE_KEY_ED25519: c_int = 6;
pub const git_cert_ssh_raw_type_t = c_uint;
pub const git_cert_hostkey = extern struct {
    parent: git_cert,
    type: git_cert_ssh_t,
    hash_md5: [16]u8,
    hash_sha1: [20]u8,
    hash_sha256: [32]u8,
    raw_type: git_cert_ssh_raw_type_t,
    hostkey: [*c]const u8,
    hostkey_len: usize,
};
pub const git_cert_x509 = extern struct {
    parent: git_cert,
    data: ?*c_void,
    len: usize,
};
pub const GIT_CHECKOUT_NONE: c_int = 0;
pub const GIT_CHECKOUT_SAFE: c_int = 1;
pub const GIT_CHECKOUT_FORCE: c_int = 2;
pub const GIT_CHECKOUT_RECREATE_MISSING: c_int = 4;
pub const GIT_CHECKOUT_ALLOW_CONFLICTS: c_int = 16;
pub const GIT_CHECKOUT_REMOVE_UNTRACKED: c_int = 32;
pub const GIT_CHECKOUT_REMOVE_IGNORED: c_int = 64;
pub const GIT_CHECKOUT_UPDATE_ONLY: c_int = 128;
pub const GIT_CHECKOUT_DONT_UPDATE_INDEX: c_int = 256;
pub const GIT_CHECKOUT_NO_REFRESH: c_int = 512;
pub const GIT_CHECKOUT_SKIP_UNMERGED: c_int = 1024;
pub const GIT_CHECKOUT_USE_OURS: c_int = 2048;
pub const GIT_CHECKOUT_USE_THEIRS: c_int = 4096;
pub const GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH: c_int = 8192;
pub const GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES: c_int = 262144;
pub const GIT_CHECKOUT_DONT_OVERWRITE_IGNORED: c_int = 524288;
pub const GIT_CHECKOUT_CONFLICT_STYLE_MERGE: c_int = 1048576;
pub const GIT_CHECKOUT_CONFLICT_STYLE_DIFF3: c_int = 2097152;
pub const GIT_CHECKOUT_DONT_REMOVE_EXISTING: c_int = 4194304;
pub const GIT_CHECKOUT_DONT_WRITE_INDEX: c_int = 8388608;
pub const GIT_CHECKOUT_UPDATE_SUBMODULES: c_int = 65536;
pub const GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED: c_int = 131072;
pub const git_checkout_strategy_t = c_uint;
pub const GIT_CHECKOUT_NOTIFY_NONE: c_int = 0;
pub const GIT_CHECKOUT_NOTIFY_CONFLICT: c_int = 1;
pub const GIT_CHECKOUT_NOTIFY_DIRTY: c_int = 2;
pub const GIT_CHECKOUT_NOTIFY_UPDATED: c_int = 4;
pub const GIT_CHECKOUT_NOTIFY_UNTRACKED: c_int = 8;
pub const GIT_CHECKOUT_NOTIFY_IGNORED: c_int = 16;
pub const GIT_CHECKOUT_NOTIFY_ALL: c_int = 65535;
pub const git_checkout_notify_t = c_uint;
pub const git_checkout_perfdata = extern struct {
    mkdir_calls: usize,
    stat_calls: usize,
    chmod_calls: usize,
};
pub const git_checkout_notify_cb = ?fn (git_checkout_notify_t, [*c]const u8, [*c]const git_diff_file, [*c]const git_diff_file, [*c]const git_diff_file, ?*c_void) callconv(.C) c_int;
pub const git_checkout_progress_cb = ?fn ([*c]const u8, usize, usize, ?*c_void) callconv(.C) void;
pub const git_checkout_perfdata_cb = ?fn ([*c]const git_checkout_perfdata, ?*c_void) callconv(.C) void;
pub const struct_git_checkout_options = extern struct {
    version: c_uint,
    checkout_strategy: c_uint,
    disable_filters: c_int,
    dir_mode: c_uint,
    file_mode: c_uint,
    file_open_flags: c_int,
    notify_flags: c_uint,
    notify_cb: git_checkout_notify_cb,
    notify_payload: ?*c_void,
    progress_cb: git_checkout_progress_cb,
    progress_payload: ?*c_void,
    paths: git_strarray,
    baseline: ?*git_tree,
    baseline_index: ?*git_index,
    target_directory: [*c]const u8,
    ancestor_label: [*c]const u8,
    our_label: [*c]const u8,
    their_label: [*c]const u8,
    perfdata_cb: git_checkout_perfdata_cb,
    perfdata_payload: ?*c_void,
};
pub const git_checkout_options = struct_git_checkout_options;
pub extern fn git_checkout_options_init(opts: [*c]git_checkout_options, version: c_uint) c_int;
pub extern fn git_checkout_head(repo: ?*git_repository, opts: [*c]const git_checkout_options) c_int;
pub extern fn git_checkout_index(repo: ?*git_repository, index: ?*git_index, opts: [*c]const git_checkout_options) c_int;
pub extern fn git_checkout_tree(repo: ?*git_repository, treeish: ?*const git_object, opts: [*c]const git_checkout_options) c_int;
pub const struct_git_oidarray = extern struct {
    ids: [*c]git_oid,
    count: usize,
};
pub const git_oidarray = struct_git_oidarray;
pub extern fn git_oidarray_free(array: [*c]git_oidarray) void;
pub const struct_git_indexer = opaque {};
pub const git_indexer = struct_git_indexer;
pub const struct_git_indexer_options = extern struct {
    version: c_uint,
    progress_cb: git_indexer_progress_cb,
    progress_cb_payload: ?*c_void,
    verify: u8,
};
pub const git_indexer_options = struct_git_indexer_options;
pub extern fn git_indexer_options_init(opts: [*c]git_indexer_options, version: c_uint) c_int;
pub extern fn git_indexer_new(out: [*c]?*git_indexer, path: [*c]const u8, mode: c_uint, odb: ?*git_odb, opts: [*c]git_indexer_options) c_int;
pub extern fn git_indexer_append(idx: ?*git_indexer, data: ?*const c_void, size: usize, stats: [*c]git_indexer_progress) c_int;
pub extern fn git_indexer_commit(idx: ?*git_indexer, stats: [*c]git_indexer_progress) c_int;
pub extern fn git_indexer_hash(idx: ?*const git_indexer) [*c]const git_oid;
pub extern fn git_indexer_free(idx: ?*git_indexer) void;
pub const git_index_time = extern struct {
    seconds: i32,
    nanoseconds: u32,
};
pub const struct_git_index_entry = extern struct {
    ctime: git_index_time,
    mtime: git_index_time,
    dev: u32,
    ino: u32,
    mode: u32,
    uid: u32,
    gid: u32,
    file_size: u32,
    id: git_oid,
    flags: u16,
    flags_extended: u16,
    path: [*c]const u8,
};
pub const git_index_entry = struct_git_index_entry;
pub const GIT_INDEX_ENTRY_EXTENDED: c_int = 16384;
pub const GIT_INDEX_ENTRY_VALID: c_int = 32768;
pub const git_index_entry_flag_t = c_uint;
pub const GIT_INDEX_ENTRY_INTENT_TO_ADD: c_int = 8192;
pub const GIT_INDEX_ENTRY_SKIP_WORKTREE: c_int = 16384;
pub const GIT_INDEX_ENTRY_EXTENDED_FLAGS: c_int = 24576;
pub const GIT_INDEX_ENTRY_UPTODATE: c_int = 4;
pub const git_index_entry_extended_flag_t = c_uint;
pub const GIT_INDEX_CAPABILITY_IGNORE_CASE: c_int = 1;
pub const GIT_INDEX_CAPABILITY_NO_FILEMODE: c_int = 2;
pub const GIT_INDEX_CAPABILITY_NO_SYMLINKS: c_int = 4;
pub const GIT_INDEX_CAPABILITY_FROM_OWNER: c_int = -1;
pub const git_index_capability_t = c_int;
pub const git_index_matched_path_cb = ?fn ([*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const GIT_INDEX_ADD_DEFAULT: c_int = 0;
pub const GIT_INDEX_ADD_FORCE: c_int = 1;
pub const GIT_INDEX_ADD_DISABLE_PATHSPEC_MATCH: c_int = 2;
pub const GIT_INDEX_ADD_CHECK_PATHSPEC: c_int = 4;
pub const git_index_add_option_t = c_uint;
pub const GIT_INDEX_STAGE_ANY: c_int = -1;
pub const GIT_INDEX_STAGE_NORMAL: c_int = 0;
pub const GIT_INDEX_STAGE_ANCESTOR: c_int = 1;
pub const GIT_INDEX_STAGE_OURS: c_int = 2;
pub const GIT_INDEX_STAGE_THEIRS: c_int = 3;
pub const git_index_stage_t = c_int;
pub extern fn git_index_open(out: [*c]?*git_index, index_path: [*c]const u8) c_int;
pub extern fn git_index_new(out: [*c]?*git_index) c_int;
pub extern fn git_index_free(index: ?*git_index) void;
pub extern fn git_index_owner(index: ?*const git_index) ?*git_repository;
pub extern fn git_index_caps(index: ?*const git_index) c_int;
pub extern fn git_index_set_caps(index: ?*git_index, caps: c_int) c_int;
pub extern fn git_index_version(index: ?*git_index) c_uint;
pub extern fn git_index_set_version(index: ?*git_index, version: c_uint) c_int;
pub extern fn git_index_read(index: ?*git_index, force: c_int) c_int;
pub extern fn git_index_write(index: ?*git_index) c_int;
pub extern fn git_index_path(index: ?*const git_index) [*c]const u8;
pub extern fn git_index_checksum(index: ?*git_index) [*c]const git_oid;
pub extern fn git_index_read_tree(index: ?*git_index, tree: ?*const git_tree) c_int;
pub extern fn git_index_write_tree(out: [*c]git_oid, index: ?*git_index) c_int;
pub extern fn git_index_write_tree_to(out: [*c]git_oid, index: ?*git_index, repo: ?*git_repository) c_int;
pub extern fn git_index_entrycount(index: ?*const git_index) usize;
pub extern fn git_index_clear(index: ?*git_index) c_int;
pub extern fn git_index_get_byindex(index: ?*git_index, n: usize) [*c]const git_index_entry;
pub extern fn git_index_get_bypath(index: ?*git_index, path: [*c]const u8, stage: c_int) [*c]const git_index_entry;
pub extern fn git_index_remove(index: ?*git_index, path: [*c]const u8, stage: c_int) c_int;
pub extern fn git_index_remove_directory(index: ?*git_index, dir: [*c]const u8, stage: c_int) c_int;
pub extern fn git_index_add(index: ?*git_index, source_entry: [*c]const git_index_entry) c_int;
pub extern fn git_index_entry_stage(entry: [*c]const git_index_entry) c_int;
pub extern fn git_index_entry_is_conflict(entry: [*c]const git_index_entry) c_int;
pub extern fn git_index_iterator_new(iterator_out: [*c]?*git_index_iterator, index: ?*git_index) c_int;
pub extern fn git_index_iterator_next(out: [*c][*c]const git_index_entry, iterator: ?*git_index_iterator) c_int;
pub extern fn git_index_iterator_free(iterator: ?*git_index_iterator) void;
pub extern fn git_index_add_bypath(index: ?*git_index, path: [*c]const u8) c_int;
pub extern fn git_index_add_from_buffer(index: ?*git_index, entry: [*c]const git_index_entry, buffer: ?*const c_void, len: usize) c_int;
pub extern fn git_index_remove_bypath(index: ?*git_index, path: [*c]const u8) c_int;
pub extern fn git_index_add_all(index: ?*git_index, pathspec: [*c]const git_strarray, flags: c_uint, callback: git_index_matched_path_cb, payload: ?*c_void) c_int;
pub extern fn git_index_remove_all(index: ?*git_index, pathspec: [*c]const git_strarray, callback: git_index_matched_path_cb, payload: ?*c_void) c_int;
pub extern fn git_index_update_all(index: ?*git_index, pathspec: [*c]const git_strarray, callback: git_index_matched_path_cb, payload: ?*c_void) c_int;
pub extern fn git_index_find(at_pos: [*c]usize, index: ?*git_index, path: [*c]const u8) c_int;
pub extern fn git_index_find_prefix(at_pos: [*c]usize, index: ?*git_index, prefix: [*c]const u8) c_int;
pub extern fn git_index_conflict_add(index: ?*git_index, ancestor_entry: [*c]const git_index_entry, our_entry: [*c]const git_index_entry, their_entry: [*c]const git_index_entry) c_int;
pub extern fn git_index_conflict_get(ancestor_out: [*c][*c]const git_index_entry, our_out: [*c][*c]const git_index_entry, their_out: [*c][*c]const git_index_entry, index: ?*git_index, path: [*c]const u8) c_int;
pub extern fn git_index_conflict_remove(index: ?*git_index, path: [*c]const u8) c_int;
pub extern fn git_index_conflict_cleanup(index: ?*git_index) c_int;
pub extern fn git_index_has_conflicts(index: ?*const git_index) c_int;
pub extern fn git_index_conflict_iterator_new(iterator_out: [*c]?*git_index_conflict_iterator, index: ?*git_index) c_int;
pub extern fn git_index_conflict_next(ancestor_out: [*c][*c]const git_index_entry, our_out: [*c][*c]const git_index_entry, their_out: [*c][*c]const git_index_entry, iterator: ?*git_index_conflict_iterator) c_int;
pub extern fn git_index_conflict_iterator_free(iterator: ?*git_index_conflict_iterator) void;
pub const git_merge_file_input = extern struct {
    version: c_uint,
    ptr: [*c]const u8,
    size: usize,
    path: [*c]const u8,
    mode: c_uint,
};
pub extern fn git_merge_file_input_init(opts: [*c]git_merge_file_input, version: c_uint) c_int;
pub const GIT_MERGE_FIND_RENAMES: c_int = 1;
pub const GIT_MERGE_FAIL_ON_CONFLICT: c_int = 2;
pub const GIT_MERGE_SKIP_REUC: c_int = 4;
pub const GIT_MERGE_NO_RECURSIVE: c_int = 8;
pub const git_merge_flag_t = c_uint;
pub const GIT_MERGE_FILE_FAVOR_NORMAL: c_int = 0;
pub const GIT_MERGE_FILE_FAVOR_OURS: c_int = 1;
pub const GIT_MERGE_FILE_FAVOR_THEIRS: c_int = 2;
pub const GIT_MERGE_FILE_FAVOR_UNION: c_int = 3;
pub const git_merge_file_favor_t = c_uint;
pub const GIT_MERGE_FILE_DEFAULT: c_int = 0;
pub const GIT_MERGE_FILE_STYLE_MERGE: c_int = 1;
pub const GIT_MERGE_FILE_STYLE_DIFF3: c_int = 2;
pub const GIT_MERGE_FILE_SIMPLIFY_ALNUM: c_int = 4;
pub const GIT_MERGE_FILE_IGNORE_WHITESPACE: c_int = 8;
pub const GIT_MERGE_FILE_IGNORE_WHITESPACE_CHANGE: c_int = 16;
pub const GIT_MERGE_FILE_IGNORE_WHITESPACE_EOL: c_int = 32;
pub const GIT_MERGE_FILE_DIFF_PATIENCE: c_int = 64;
pub const GIT_MERGE_FILE_DIFF_MINIMAL: c_int = 128;
pub const git_merge_file_flag_t = c_uint;
pub const git_merge_file_options = extern struct {
    version: c_uint,
    ancestor_label: [*c]const u8,
    our_label: [*c]const u8,
    their_label: [*c]const u8,
    favor: git_merge_file_favor_t,
    flags: u32,
    marker_size: c_ushort,
};
pub extern fn git_merge_file_options_init(opts: [*c]git_merge_file_options, version: c_uint) c_int;
pub const git_merge_file_result = extern struct {
    automergeable: c_uint,
    path: [*c]const u8,
    mode: c_uint,
    ptr: [*c]const u8,
    len: usize,
};
pub const git_merge_options = extern struct {
    version: c_uint,
    flags: u32,
    rename_threshold: c_uint,
    target_limit: c_uint,
    metric: [*c]git_diff_similarity_metric,
    recursion_limit: c_uint,
    default_driver: [*c]const u8,
    file_favor: git_merge_file_favor_t,
    file_flags: u32,
};
pub extern fn git_merge_options_init(opts: [*c]git_merge_options, version: c_uint) c_int;
pub const GIT_MERGE_ANALYSIS_NONE: c_int = 0;
pub const GIT_MERGE_ANALYSIS_NORMAL: c_int = 1;
pub const GIT_MERGE_ANALYSIS_UP_TO_DATE: c_int = 2;
pub const GIT_MERGE_ANALYSIS_FASTFORWARD: c_int = 4;
pub const GIT_MERGE_ANALYSIS_UNBORN: c_int = 8;
pub const git_merge_analysis_t = c_uint;
pub const GIT_MERGE_PREFERENCE_NONE: c_int = 0;
pub const GIT_MERGE_PREFERENCE_NO_FASTFORWARD: c_int = 1;
pub const GIT_MERGE_PREFERENCE_FASTFORWARD_ONLY: c_int = 2;
pub const git_merge_preference_t = c_uint;
pub extern fn git_merge_analysis(analysis_out: [*c]git_merge_analysis_t, preference_out: [*c]git_merge_preference_t, repo: ?*git_repository, their_heads: [*c]?*const git_annotated_commit, their_heads_len: usize) c_int;
pub extern fn git_merge_analysis_for_ref(analysis_out: [*c]git_merge_analysis_t, preference_out: [*c]git_merge_preference_t, repo: ?*git_repository, our_ref: ?*git_reference, their_heads: [*c]?*const git_annotated_commit, their_heads_len: usize) c_int;
pub extern fn git_merge_base(out: [*c]git_oid, repo: ?*git_repository, one: [*c]const git_oid, two: [*c]const git_oid) c_int;
pub extern fn git_merge_bases(out: [*c]git_oidarray, repo: ?*git_repository, one: [*c]const git_oid, two: [*c]const git_oid) c_int;
pub extern fn git_merge_base_many(out: [*c]git_oid, repo: ?*git_repository, length: usize, input_array: [*c]const git_oid) c_int;
pub extern fn git_merge_bases_many(out: [*c]git_oidarray, repo: ?*git_repository, length: usize, input_array: [*c]const git_oid) c_int;
pub extern fn git_merge_base_octopus(out: [*c]git_oid, repo: ?*git_repository, length: usize, input_array: [*c]const git_oid) c_int;
pub extern fn git_merge_file(out: [*c]git_merge_file_result, ancestor: [*c]const git_merge_file_input, ours: [*c]const git_merge_file_input, theirs: [*c]const git_merge_file_input, opts: [*c]const git_merge_file_options) c_int;
pub extern fn git_merge_file_from_index(out: [*c]git_merge_file_result, repo: ?*git_repository, ancestor: [*c]const git_index_entry, ours: [*c]const git_index_entry, theirs: [*c]const git_index_entry, opts: [*c]const git_merge_file_options) c_int;
pub extern fn git_merge_file_result_free(result: [*c]git_merge_file_result) void;
pub extern fn git_merge_trees(out: [*c]?*git_index, repo: ?*git_repository, ancestor_tree: ?*const git_tree, our_tree: ?*const git_tree, their_tree: ?*const git_tree, opts: [*c]const git_merge_options) c_int;
pub extern fn git_merge_commits(out: [*c]?*git_index, repo: ?*git_repository, our_commit: ?*const git_commit, their_commit: ?*const git_commit, opts: [*c]const git_merge_options) c_int;
pub extern fn git_merge(repo: ?*git_repository, their_heads: [*c]?*const git_annotated_commit, their_heads_len: usize, merge_opts: [*c]const git_merge_options, checkout_opts: [*c]const git_checkout_options) c_int;
pub const git_cherrypick_options = extern struct {
    version: c_uint,
    mainline: c_uint,
    merge_opts: git_merge_options,
    checkout_opts: git_checkout_options,
};
pub extern fn git_cherrypick_options_init(opts: [*c]git_cherrypick_options, version: c_uint) c_int;
pub extern fn git_cherrypick_commit(out: [*c]?*git_index, repo: ?*git_repository, cherrypick_commit: ?*git_commit, our_commit: ?*git_commit, mainline: c_uint, merge_options: [*c]const git_merge_options) c_int;
pub extern fn git_cherrypick(repo: ?*git_repository, commit: ?*git_commit, cherrypick_options: [*c]const git_cherrypick_options) c_int;
pub const GIT_DIRECTION_FETCH: c_int = 0;
pub const GIT_DIRECTION_PUSH: c_int = 1;
pub const git_direction = c_uint;
pub extern fn git_refspec_parse(refspec: [*c]?*git_refspec, input: [*c]const u8, is_fetch: c_int) c_int;
pub extern fn git_refspec_free(refspec: ?*git_refspec) void;
pub extern fn git_refspec_src(refspec: ?*const git_refspec) [*c]const u8;
pub extern fn git_refspec_dst(refspec: ?*const git_refspec) [*c]const u8;
pub extern fn git_refspec_string(refspec: ?*const git_refspec) [*c]const u8;
pub extern fn git_refspec_force(refspec: ?*const git_refspec) c_int;
pub extern fn git_refspec_direction(spec: ?*const git_refspec) git_direction;
pub extern fn git_refspec_src_matches(refspec: ?*const git_refspec, refname: [*c]const u8) c_int;
pub extern fn git_refspec_dst_matches(refspec: ?*const git_refspec, refname: [*c]const u8) c_int;
pub extern fn git_refspec_transform(out: [*c]git_buf, spec: ?*const git_refspec, name: [*c]const u8) c_int;
pub extern fn git_refspec_rtransform(out: [*c]git_buf, spec: ?*const git_refspec, name: [*c]const u8) c_int;
pub const GIT_CREDENTIAL_USERPASS_PLAINTEXT: c_int = 1;
pub const GIT_CREDENTIAL_SSH_KEY: c_int = 2;
pub const GIT_CREDENTIAL_SSH_CUSTOM: c_int = 4;
pub const GIT_CREDENTIAL_DEFAULT: c_int = 8;
pub const GIT_CREDENTIAL_SSH_INTERACTIVE: c_int = 16;
pub const GIT_CREDENTIAL_USERNAME: c_int = 32;
pub const GIT_CREDENTIAL_SSH_MEMORY: c_int = 64;
pub const git_credential_t = c_uint;
pub const struct_git_credential_userpass_plaintext = extern struct {
    parent: git_credential,
    username: [*c]u8,
    password: [*c]u8,
};
pub const git_credential_userpass_plaintext = struct_git_credential_userpass_plaintext;
pub const struct_git_credential_username = extern struct {
    parent: git_credential,
    username: [1]u8,
};
pub const git_credential_username = struct_git_credential_username;
pub const git_credential_default = struct_git_credential;
pub const struct_git_credential_ssh_key = extern struct {
    parent: git_credential,
    username: [*c]u8,
    publickey: [*c]u8,
    privatekey: [*c]u8,
    passphrase: [*c]u8,
};
pub const git_credential_ssh_key = struct_git_credential_ssh_key;
pub const struct__LIBSSH2_USERAUTH_KBDINT_PROMPT = opaque {};
pub const LIBSSH2_USERAUTH_KBDINT_PROMPT = struct__LIBSSH2_USERAUTH_KBDINT_PROMPT;
pub const struct__LIBSSH2_USERAUTH_KBDINT_RESPONSE = opaque {};
pub const LIBSSH2_USERAUTH_KBDINT_RESPONSE = struct__LIBSSH2_USERAUTH_KBDINT_RESPONSE;
pub const git_credential_ssh_interactive_cb = ?fn ([*c]const u8, c_int, [*c]const u8, c_int, c_int, ?*const LIBSSH2_USERAUTH_KBDINT_PROMPT, ?*LIBSSH2_USERAUTH_KBDINT_RESPONSE, [*c]?*c_void) callconv(.C) void;
pub const struct_git_credential_ssh_interactive = extern struct {
    parent: git_credential,
    username: [*c]u8,
    prompt_callback: git_credential_ssh_interactive_cb,
    payload: ?*c_void,
};
pub const git_credential_ssh_interactive = struct_git_credential_ssh_interactive;
pub const struct__LIBSSH2_SESSION = opaque {};
pub const LIBSSH2_SESSION = struct__LIBSSH2_SESSION;
pub const git_credential_sign_cb = ?fn (?*LIBSSH2_SESSION, [*c][*c]u8, [*c]usize, [*c]const u8, usize, [*c]?*c_void) callconv(.C) c_int;
pub const struct_git_credential_ssh_custom = extern struct {
    parent: git_credential,
    username: [*c]u8,
    publickey: [*c]u8,
    publickey_len: usize,
    sign_callback: git_credential_sign_cb,
    payload: ?*c_void,
};
pub const git_credential_ssh_custom = struct_git_credential_ssh_custom;
pub extern fn git_credential_free(cred: [*c]git_credential) void;
pub extern fn git_credential_has_username(cred: [*c]git_credential) c_int;
pub extern fn git_credential_get_username(cred: [*c]git_credential) [*c]const u8;
pub extern fn git_credential_userpass_plaintext_new(out: [*c][*c]git_credential, username: [*c]const u8, password: [*c]const u8) c_int;
pub extern fn git_credential_default_new(out: [*c][*c]git_credential) c_int;
pub extern fn git_credential_username_new(out: [*c][*c]git_credential, username: [*c]const u8) c_int;
pub extern fn git_credential_ssh_key_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, privatekey: [*c]const u8, passphrase: [*c]const u8) c_int;
pub extern fn git_credential_ssh_key_memory_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, privatekey: [*c]const u8, passphrase: [*c]const u8) c_int;
pub extern fn git_credential_ssh_interactive_new(out: [*c][*c]git_credential, username: [*c]const u8, prompt_callback: git_credential_ssh_interactive_cb, payload: ?*c_void) c_int;
pub extern fn git_credential_ssh_key_from_agent(out: [*c][*c]git_credential, username: [*c]const u8) c_int;
pub extern fn git_credential_ssh_custom_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, publickey_len: usize, sign_callback: git_credential_sign_cb, payload: ?*c_void) c_int;
pub const GIT_PACKBUILDER_ADDING_OBJECTS: c_int = 0;
pub const GIT_PACKBUILDER_DELTAFICATION: c_int = 1;
pub const git_packbuilder_stage_t = c_uint;
pub extern fn git_packbuilder_new(out: [*c]?*git_packbuilder, repo: ?*git_repository) c_int;
pub extern fn git_packbuilder_set_threads(pb: ?*git_packbuilder, n: c_uint) c_uint;
pub extern fn git_packbuilder_insert(pb: ?*git_packbuilder, id: [*c]const git_oid, name: [*c]const u8) c_int;
pub extern fn git_packbuilder_insert_tree(pb: ?*git_packbuilder, id: [*c]const git_oid) c_int;
pub extern fn git_packbuilder_insert_commit(pb: ?*git_packbuilder, id: [*c]const git_oid) c_int;
pub extern fn git_packbuilder_insert_walk(pb: ?*git_packbuilder, walk: ?*git_revwalk) c_int;
pub extern fn git_packbuilder_insert_recur(pb: ?*git_packbuilder, id: [*c]const git_oid, name: [*c]const u8) c_int;
pub extern fn git_packbuilder_write_buf(buf: [*c]git_buf, pb: ?*git_packbuilder) c_int;
pub extern fn git_packbuilder_write(pb: ?*git_packbuilder, path: [*c]const u8, mode: c_uint, progress_cb: git_indexer_progress_cb, progress_cb_payload: ?*c_void) c_int;
pub extern fn git_packbuilder_hash(pb: ?*git_packbuilder) [*c]const git_oid;
pub const git_packbuilder_foreach_cb = ?fn (?*c_void, usize, ?*c_void) callconv(.C) c_int;
pub extern fn git_packbuilder_foreach(pb: ?*git_packbuilder, cb: git_packbuilder_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_packbuilder_object_count(pb: ?*git_packbuilder) usize;
pub extern fn git_packbuilder_written(pb: ?*git_packbuilder) usize;
pub extern fn git_packbuilder_set_callbacks(pb: ?*git_packbuilder, progress_cb: git_packbuilder_progress, progress_cb_payload: ?*c_void) c_int;
pub extern fn git_packbuilder_free(pb: ?*git_packbuilder) void;
pub const GIT_PROXY_NONE: c_int = 0;
pub const GIT_PROXY_AUTO: c_int = 1;
pub const GIT_PROXY_SPECIFIED: c_int = 2;
pub const git_proxy_t = c_uint;
pub const git_proxy_options = extern struct {
    version: c_uint,
    type: git_proxy_t,
    url: [*c]const u8,
    credentials: git_credential_acquire_cb,
    certificate_check: git_transport_certificate_check_cb,
    payload: ?*c_void,
};
pub extern fn git_proxy_options_init(opts: [*c]git_proxy_options, version: c_uint) c_int;
pub extern fn git_remote_create(out: [*c]?*git_remote, repo: ?*git_repository, name: [*c]const u8, url: [*c]const u8) c_int;
pub const GIT_REMOTE_CREATE_SKIP_INSTEADOF: c_int = 1;
pub const GIT_REMOTE_CREATE_SKIP_DEFAULT_FETCHSPEC: c_int = 2;
pub const git_remote_create_flags = c_uint;
pub const struct_git_remote_create_options = extern struct {
    version: c_uint,
    repository: ?*git_repository,
    name: [*c]const u8,
    fetchspec: [*c]const u8,
    flags: c_uint,
};
pub const git_remote_create_options = struct_git_remote_create_options;
pub extern fn git_remote_create_options_init(opts: [*c]git_remote_create_options, version: c_uint) c_int;
pub extern fn git_remote_create_with_opts(out: [*c]?*git_remote, url: [*c]const u8, opts: [*c]const git_remote_create_options) c_int;
pub extern fn git_remote_create_with_fetchspec(out: [*c]?*git_remote, repo: ?*git_repository, name: [*c]const u8, url: [*c]const u8, fetch: [*c]const u8) c_int;
pub extern fn git_remote_create_anonymous(out: [*c]?*git_remote, repo: ?*git_repository, url: [*c]const u8) c_int;
pub extern fn git_remote_create_detached(out: [*c]?*git_remote, url: [*c]const u8) c_int;
pub extern fn git_remote_lookup(out: [*c]?*git_remote, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_remote_dup(dest: [*c]?*git_remote, source: ?*git_remote) c_int;
pub extern fn git_remote_owner(remote: ?*const git_remote) ?*git_repository;
pub extern fn git_remote_name(remote: ?*const git_remote) [*c]const u8;
pub extern fn git_remote_url(remote: ?*const git_remote) [*c]const u8;
pub extern fn git_remote_pushurl(remote: ?*const git_remote) [*c]const u8;
pub extern fn git_remote_set_url(repo: ?*git_repository, remote: [*c]const u8, url: [*c]const u8) c_int;
pub extern fn git_remote_set_pushurl(repo: ?*git_repository, remote: [*c]const u8, url: [*c]const u8) c_int;
pub extern fn git_remote_add_fetch(repo: ?*git_repository, remote: [*c]const u8, refspec: [*c]const u8) c_int;
pub extern fn git_remote_get_fetch_refspecs(array: [*c]git_strarray, remote: ?*const git_remote) c_int;
pub extern fn git_remote_add_push(repo: ?*git_repository, remote: [*c]const u8, refspec: [*c]const u8) c_int;
pub extern fn git_remote_get_push_refspecs(array: [*c]git_strarray, remote: ?*const git_remote) c_int;
pub extern fn git_remote_refspec_count(remote: ?*const git_remote) usize;
pub extern fn git_remote_get_refspec(remote: ?*const git_remote, n: usize) ?*const git_refspec;
pub extern fn git_remote_connect(remote: ?*git_remote, direction: git_direction, callbacks: [*c]const git_remote_callbacks, proxy_opts: [*c]const git_proxy_options, custom_headers: [*c]const git_strarray) c_int;
pub extern fn git_remote_ls(out: [*c][*c][*c]const git_remote_head, size: [*c]usize, remote: ?*git_remote) c_int;
pub extern fn git_remote_connected(remote: ?*const git_remote) c_int;
pub extern fn git_remote_stop(remote: ?*git_remote) c_int;
pub extern fn git_remote_disconnect(remote: ?*git_remote) c_int;
pub extern fn git_remote_free(remote: ?*git_remote) void;
pub extern fn git_remote_list(out: [*c]git_strarray, repo: ?*git_repository) c_int;
pub const git_push_update = extern struct {
    src_refname: [*c]u8,
    dst_refname: [*c]u8,
    src: git_oid,
    dst: git_oid,
};
pub extern fn git_remote_init_callbacks(opts: [*c]git_remote_callbacks, version: c_uint) c_int;
pub const GIT_FETCH_PRUNE_UNSPECIFIED: c_int = 0;
pub const GIT_FETCH_PRUNE: c_int = 1;
pub const GIT_FETCH_NO_PRUNE: c_int = 2;
pub const git_fetch_prune_t = c_uint;
pub const GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED: c_int = 0;
pub const GIT_REMOTE_DOWNLOAD_TAGS_AUTO: c_int = 1;
pub const GIT_REMOTE_DOWNLOAD_TAGS_NONE: c_int = 2;
pub const GIT_REMOTE_DOWNLOAD_TAGS_ALL: c_int = 3;
pub const git_remote_autotag_option_t = c_uint;
pub const git_fetch_options = extern struct {
    version: c_int,
    callbacks: git_remote_callbacks,
    prune: git_fetch_prune_t,
    update_fetchhead: c_int,
    download_tags: git_remote_autotag_option_t,
    proxy_opts: git_proxy_options,
    custom_headers: git_strarray,
};
pub extern fn git_fetch_options_init(opts: [*c]git_fetch_options, version: c_uint) c_int;
pub const git_push_options = extern struct {
    version: c_uint,
    pb_parallelism: c_uint,
    callbacks: git_remote_callbacks,
    proxy_opts: git_proxy_options,
    custom_headers: git_strarray,
};
pub extern fn git_push_options_init(opts: [*c]git_push_options, version: c_uint) c_int;
pub extern fn git_remote_download(remote: ?*git_remote, refspecs: [*c]const git_strarray, opts: [*c]const git_fetch_options) c_int;
pub extern fn git_remote_upload(remote: ?*git_remote, refspecs: [*c]const git_strarray, opts: [*c]const git_push_options) c_int;
pub extern fn git_remote_update_tips(remote: ?*git_remote, callbacks: [*c]const git_remote_callbacks, update_fetchhead: c_int, download_tags: git_remote_autotag_option_t, reflog_message: [*c]const u8) c_int;
pub extern fn git_remote_fetch(remote: ?*git_remote, refspecs: [*c]const git_strarray, opts: [*c]const git_fetch_options, reflog_message: [*c]const u8) c_int;
pub extern fn git_remote_prune(remote: ?*git_remote, callbacks: [*c]const git_remote_callbacks) c_int;
pub extern fn git_remote_push(remote: ?*git_remote, refspecs: [*c]const git_strarray, opts: [*c]const git_push_options) c_int;
pub extern fn git_remote_stats(remote: ?*git_remote) [*c]const git_indexer_progress;
pub extern fn git_remote_autotag(remote: ?*const git_remote) git_remote_autotag_option_t;
pub extern fn git_remote_set_autotag(repo: ?*git_repository, remote: [*c]const u8, value: git_remote_autotag_option_t) c_int;
pub extern fn git_remote_prune_refs(remote: ?*const git_remote) c_int;
pub extern fn git_remote_rename(problems: [*c]git_strarray, repo: ?*git_repository, name: [*c]const u8, new_name: [*c]const u8) c_int;
pub extern fn git_remote_name_is_valid(valid: [*c]c_int, remote_name: [*c]const u8) c_int;
pub extern fn git_remote_delete(repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_remote_default_branch(out: [*c]git_buf, remote: ?*git_remote) c_int;
pub const GIT_CLONE_LOCAL_AUTO: c_int = 0;
pub const GIT_CLONE_LOCAL: c_int = 1;
pub const GIT_CLONE_NO_LOCAL: c_int = 2;
pub const GIT_CLONE_LOCAL_NO_LINKS: c_int = 3;
pub const git_clone_local_t = c_uint;
pub const git_remote_create_cb = ?fn ([*c]?*git_remote, ?*git_repository, [*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const git_repository_create_cb = ?fn ([*c]?*git_repository, [*c]const u8, c_int, ?*c_void) callconv(.C) c_int;
pub const struct_git_clone_options = extern struct {
    version: c_uint,
    checkout_opts: git_checkout_options,
    fetch_opts: git_fetch_options,
    bare: c_int,
    local: git_clone_local_t,
    checkout_branch: [*c]const u8,
    repository_cb: git_repository_create_cb,
    repository_cb_payload: ?*c_void,
    remote_cb: git_remote_create_cb,
    remote_cb_payload: ?*c_void,
};
pub const git_clone_options = struct_git_clone_options;
pub extern fn git_clone_options_init(opts: [*c]git_clone_options, version: c_uint) c_int;
pub extern fn git_clone(out: [*c]?*git_repository, url: [*c]const u8, local_path: [*c]const u8, options: [*c]const git_clone_options) c_int;
pub extern fn git_commit_lookup(commit: [*c]?*git_commit, repo: ?*git_repository, id: [*c]const git_oid) c_int;
pub extern fn git_commit_lookup_prefix(commit: [*c]?*git_commit, repo: ?*git_repository, id: [*c]const git_oid, len: usize) c_int;
pub extern fn git_commit_free(commit: ?*git_commit) void;
pub extern fn git_commit_id(commit: ?*const git_commit) [*c]const git_oid;
pub extern fn git_commit_owner(commit: ?*const git_commit) ?*git_repository;
pub extern fn git_commit_message_encoding(commit: ?*const git_commit) [*c]const u8;
pub extern fn git_commit_message(commit: ?*const git_commit) [*c]const u8;
pub extern fn git_commit_message_raw(commit: ?*const git_commit) [*c]const u8;
pub extern fn git_commit_summary(commit: ?*git_commit) [*c]const u8;
pub extern fn git_commit_body(commit: ?*git_commit) [*c]const u8;
pub extern fn git_commit_time(commit: ?*const git_commit) git_time_t;
pub extern fn git_commit_time_offset(commit: ?*const git_commit) c_int;
pub extern fn git_commit_committer(commit: ?*const git_commit) [*c]const git_signature;
pub extern fn git_commit_author(commit: ?*const git_commit) [*c]const git_signature;
pub extern fn git_commit_committer_with_mailmap(out: [*c][*c]git_signature, commit: ?*const git_commit, mailmap: ?*const git_mailmap) c_int;
pub extern fn git_commit_author_with_mailmap(out: [*c][*c]git_signature, commit: ?*const git_commit, mailmap: ?*const git_mailmap) c_int;
pub extern fn git_commit_raw_header(commit: ?*const git_commit) [*c]const u8;
pub extern fn git_commit_tree(tree_out: [*c]?*git_tree, commit: ?*const git_commit) c_int;
pub extern fn git_commit_tree_id(commit: ?*const git_commit) [*c]const git_oid;
pub extern fn git_commit_parentcount(commit: ?*const git_commit) c_uint;
pub extern fn git_commit_parent(out: [*c]?*git_commit, commit: ?*const git_commit, n: c_uint) c_int;
pub extern fn git_commit_parent_id(commit: ?*const git_commit, n: c_uint) [*c]const git_oid;
pub extern fn git_commit_nth_gen_ancestor(ancestor: [*c]?*git_commit, commit: ?*const git_commit, n: c_uint) c_int;
pub extern fn git_commit_header_field(out: [*c]git_buf, commit: ?*const git_commit, field: [*c]const u8) c_int;
pub extern fn git_commit_extract_signature(signature: [*c]git_buf, signed_data: [*c]git_buf, repo: ?*git_repository, commit_id: [*c]git_oid, field: [*c]const u8) c_int;
pub extern fn git_commit_create(id: [*c]git_oid, repo: ?*git_repository, update_ref: [*c]const u8, author: [*c]const git_signature, committer: [*c]const git_signature, message_encoding: [*c]const u8, message: [*c]const u8, tree: ?*const git_tree, parent_count: usize, parents: [*c]?*const git_commit) c_int;
pub extern fn git_commit_create_v(id: [*c]git_oid, repo: ?*git_repository, update_ref: [*c]const u8, author: [*c]const git_signature, committer: [*c]const git_signature, message_encoding: [*c]const u8, message: [*c]const u8, tree: ?*const git_tree, parent_count: usize, ...) c_int;
pub extern fn git_commit_amend(id: [*c]git_oid, commit_to_amend: ?*const git_commit, update_ref: [*c]const u8, author: [*c]const git_signature, committer: [*c]const git_signature, message_encoding: [*c]const u8, message: [*c]const u8, tree: ?*const git_tree) c_int;
pub extern fn git_commit_create_buffer(out: [*c]git_buf, repo: ?*git_repository, author: [*c]const git_signature, committer: [*c]const git_signature, message_encoding: [*c]const u8, message: [*c]const u8, tree: ?*const git_tree, parent_count: usize, parents: [*c]?*const git_commit) c_int;
pub extern fn git_commit_create_with_signature(out: [*c]git_oid, repo: ?*git_repository, commit_content: [*c]const u8, signature: [*c]const u8, signature_field: [*c]const u8) c_int;
pub extern fn git_commit_dup(out: [*c]?*git_commit, source: ?*git_commit) c_int;
pub const git_commit_signing_cb = ?fn ([*c]git_buf, [*c]git_buf, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const GIT_CONFIG_LEVEL_PROGRAMDATA: c_int = 1;
pub const GIT_CONFIG_LEVEL_SYSTEM: c_int = 2;
pub const GIT_CONFIG_LEVEL_XDG: c_int = 3;
pub const GIT_CONFIG_LEVEL_GLOBAL: c_int = 4;
pub const GIT_CONFIG_LEVEL_LOCAL: c_int = 5;
pub const GIT_CONFIG_LEVEL_APP: c_int = 6;
pub const GIT_CONFIG_HIGHEST_LEVEL: c_int = -1;
pub const git_config_level_t = c_int;
pub const struct_git_config_entry = extern struct {
    name: [*c]const u8,
    value: [*c]const u8,
    include_depth: c_uint,
    level: git_config_level_t,
    free: ?fn ([*c]struct_git_config_entry) callconv(.C) void,
    payload: ?*c_void,
};
pub const git_config_entry = struct_git_config_entry;
pub extern fn git_config_entry_free([*c]git_config_entry) void;
pub const git_config_foreach_cb = ?fn ([*c]const git_config_entry, ?*c_void) callconv(.C) c_int;
pub const struct_git_config_iterator = opaque {};
pub const git_config_iterator = struct_git_config_iterator;
pub const GIT_CONFIGMAP_FALSE: c_int = 0;
pub const GIT_CONFIGMAP_TRUE: c_int = 1;
pub const GIT_CONFIGMAP_INT32: c_int = 2;
pub const GIT_CONFIGMAP_STRING: c_int = 3;
pub const git_configmap_t = c_uint;
pub const git_configmap = extern struct {
    type: git_configmap_t,
    str_match: [*c]const u8,
    map_value: c_int,
};
pub extern fn git_config_find_global(out: [*c]git_buf) c_int;
pub extern fn git_config_find_xdg(out: [*c]git_buf) c_int;
pub extern fn git_config_find_system(out: [*c]git_buf) c_int;
pub extern fn git_config_find_programdata(out: [*c]git_buf) c_int;
pub extern fn git_config_open_default(out: [*c]?*git_config) c_int;
pub extern fn git_config_new(out: [*c]?*git_config) c_int;
pub extern fn git_config_add_file_ondisk(cfg: ?*git_config, path: [*c]const u8, level: git_config_level_t, repo: ?*const git_repository, force: c_int) c_int;
pub extern fn git_config_open_ondisk(out: [*c]?*git_config, path: [*c]const u8) c_int;
pub extern fn git_config_open_level(out: [*c]?*git_config, parent: ?*const git_config, level: git_config_level_t) c_int;
pub extern fn git_config_open_global(out: [*c]?*git_config, config: ?*git_config) c_int;
pub extern fn git_config_snapshot(out: [*c]?*git_config, config: ?*git_config) c_int;
pub extern fn git_config_free(cfg: ?*git_config) void;
pub extern fn git_config_get_entry(out: [*c][*c]git_config_entry, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_int32(out: [*c]i32, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_int64(out: [*c]i64, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_bool(out: [*c]c_int, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_path(out: [*c]git_buf, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_string(out: [*c][*c]const u8, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_string_buf(out: [*c]git_buf, cfg: ?*const git_config, name: [*c]const u8) c_int;
pub extern fn git_config_get_multivar_foreach(cfg: ?*const git_config, name: [*c]const u8, regexp: [*c]const u8, callback: git_config_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_config_multivar_iterator_new(out: [*c]?*git_config_iterator, cfg: ?*const git_config, name: [*c]const u8, regexp: [*c]const u8) c_int;
pub extern fn git_config_next(entry: [*c][*c]git_config_entry, iter: ?*git_config_iterator) c_int;
pub extern fn git_config_iterator_free(iter: ?*git_config_iterator) void;
pub extern fn git_config_set_int32(cfg: ?*git_config, name: [*c]const u8, value: i32) c_int;
pub extern fn git_config_set_int64(cfg: ?*git_config, name: [*c]const u8, value: i64) c_int;
pub extern fn git_config_set_bool(cfg: ?*git_config, name: [*c]const u8, value: c_int) c_int;
pub extern fn git_config_set_string(cfg: ?*git_config, name: [*c]const u8, value: [*c]const u8) c_int;
pub extern fn git_config_set_multivar(cfg: ?*git_config, name: [*c]const u8, regexp: [*c]const u8, value: [*c]const u8) c_int;
pub extern fn git_config_delete_entry(cfg: ?*git_config, name: [*c]const u8) c_int;
pub extern fn git_config_delete_multivar(cfg: ?*git_config, name: [*c]const u8, regexp: [*c]const u8) c_int;
pub extern fn git_config_foreach(cfg: ?*const git_config, callback: git_config_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_config_iterator_new(out: [*c]?*git_config_iterator, cfg: ?*const git_config) c_int;
pub extern fn git_config_iterator_glob_new(out: [*c]?*git_config_iterator, cfg: ?*const git_config, regexp: [*c]const u8) c_int;
pub extern fn git_config_foreach_match(cfg: ?*const git_config, regexp: [*c]const u8, callback: git_config_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_config_get_mapped(out: [*c]c_int, cfg: ?*const git_config, name: [*c]const u8, maps: [*c]const git_configmap, map_n: usize) c_int;
pub extern fn git_config_lookup_map_value(out: [*c]c_int, maps: [*c]const git_configmap, map_n: usize, value: [*c]const u8) c_int;
pub extern fn git_config_parse_bool(out: [*c]c_int, value: [*c]const u8) c_int;
pub extern fn git_config_parse_int32(out: [*c]i32, value: [*c]const u8) c_int;
pub extern fn git_config_parse_int64(out: [*c]i64, value: [*c]const u8) c_int;
pub extern fn git_config_parse_path(out: [*c]git_buf, value: [*c]const u8) c_int;
pub extern fn git_config_backend_foreach_match(backend: ?*git_config_backend, regexp: [*c]const u8, callback: git_config_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_config_lock(tx: [*c]?*git_transaction, cfg: ?*git_config) c_int;
pub const GIT_DESCRIBE_DEFAULT: c_int = 0;
pub const GIT_DESCRIBE_TAGS: c_int = 1;
pub const GIT_DESCRIBE_ALL: c_int = 2;
pub const git_describe_strategy_t = c_uint;
pub const struct_git_describe_options = extern struct {
    version: c_uint,
    max_candidates_tags: c_uint,
    describe_strategy: c_uint,
    pattern: [*c]const u8,
    only_follow_first_parent: c_int,
    show_commit_oid_as_fallback: c_int,
};
pub const git_describe_options = struct_git_describe_options;
pub extern fn git_describe_options_init(opts: [*c]git_describe_options, version: c_uint) c_int;
pub const git_describe_format_options = extern struct {
    version: c_uint,
    abbreviated_size: c_uint,
    always_use_long_format: c_int,
    dirty_suffix: [*c]const u8,
};
pub extern fn git_describe_format_options_init(opts: [*c]git_describe_format_options, version: c_uint) c_int;
pub const struct_git_describe_result = opaque {};
pub const git_describe_result = struct_git_describe_result;
pub extern fn git_describe_commit(result: [*c]?*git_describe_result, committish: ?*git_object, opts: [*c]git_describe_options) c_int;
pub extern fn git_describe_workdir(out: [*c]?*git_describe_result, repo: ?*git_repository, opts: [*c]git_describe_options) c_int;
pub extern fn git_describe_format(out: [*c]git_buf, result: ?*const git_describe_result, opts: [*c]const git_describe_format_options) c_int;
pub extern fn git_describe_result_free(result: ?*git_describe_result) void;
pub const GIT_OK: c_int = 0;
pub const GIT_ERROR: c_int = -1;
pub const GIT_ENOTFOUND: c_int = -3;
pub const GIT_EEXISTS: c_int = -4;
pub const GIT_EAMBIGUOUS: c_int = -5;
pub const GIT_EBUFS: c_int = -6;
pub const GIT_EUSER: c_int = -7;
pub const GIT_EBAREREPO: c_int = -8;
pub const GIT_EUNBORNBRANCH: c_int = -9;
pub const GIT_EUNMERGED: c_int = -10;
pub const GIT_ENONFASTFORWARD: c_int = -11;
pub const GIT_EINVALIDSPEC: c_int = -12;
pub const GIT_ECONFLICT: c_int = -13;
pub const GIT_ELOCKED: c_int = -14;
pub const GIT_EMODIFIED: c_int = -15;
pub const GIT_EAUTH: c_int = -16;
pub const GIT_ECERTIFICATE: c_int = -17;
pub const GIT_EAPPLIED: c_int = -18;
pub const GIT_EPEEL: c_int = -19;
pub const GIT_EEOF: c_int = -20;
pub const GIT_EINVALID: c_int = -21;
pub const GIT_EUNCOMMITTED: c_int = -22;
pub const GIT_EDIRECTORY: c_int = -23;
pub const GIT_EMERGECONFLICT: c_int = -24;
pub const GIT_PASSTHROUGH: c_int = -30;
pub const GIT_ITEROVER: c_int = -31;
pub const GIT_RETRY: c_int = -32;
pub const GIT_EMISMATCH: c_int = -33;
pub const GIT_EINDEXDIRTY: c_int = -34;
pub const GIT_EAPPLYFAIL: c_int = -35;
pub const git_error_code = c_int;
pub const git_error = extern struct {
    message: [*c]u8,
    klass: c_int,
};
pub const GIT_ERROR_NONE: c_int = 0;
pub const GIT_ERROR_NOMEMORY: c_int = 1;
pub const GIT_ERROR_OS: c_int = 2;
pub const GIT_ERROR_INVALID: c_int = 3;
pub const GIT_ERROR_REFERENCE: c_int = 4;
pub const GIT_ERROR_ZLIB: c_int = 5;
pub const GIT_ERROR_REPOSITORY: c_int = 6;
pub const GIT_ERROR_CONFIG: c_int = 7;
pub const GIT_ERROR_REGEX: c_int = 8;
pub const GIT_ERROR_ODB: c_int = 9;
pub const GIT_ERROR_INDEX: c_int = 10;
pub const GIT_ERROR_OBJECT: c_int = 11;
pub const GIT_ERROR_NET: c_int = 12;
pub const GIT_ERROR_TAG: c_int = 13;
pub const GIT_ERROR_TREE: c_int = 14;
pub const GIT_ERROR_INDEXER: c_int = 15;
pub const GIT_ERROR_SSL: c_int = 16;
pub const GIT_ERROR_SUBMODULE: c_int = 17;
pub const GIT_ERROR_THREAD: c_int = 18;
pub const GIT_ERROR_STASH: c_int = 19;
pub const GIT_ERROR_CHECKOUT: c_int = 20;
pub const GIT_ERROR_FETCHHEAD: c_int = 21;
pub const GIT_ERROR_MERGE: c_int = 22;
pub const GIT_ERROR_SSH: c_int = 23;
pub const GIT_ERROR_FILTER: c_int = 24;
pub const GIT_ERROR_REVERT: c_int = 25;
pub const GIT_ERROR_CALLBACK: c_int = 26;
pub const GIT_ERROR_CHERRYPICK: c_int = 27;
pub const GIT_ERROR_DESCRIBE: c_int = 28;
pub const GIT_ERROR_REBASE: c_int = 29;
pub const GIT_ERROR_FILESYSTEM: c_int = 30;
pub const GIT_ERROR_PATCH: c_int = 31;
pub const GIT_ERROR_WORKTREE: c_int = 32;
pub const GIT_ERROR_SHA1: c_int = 33;
pub const GIT_ERROR_HTTP: c_int = 34;
pub const GIT_ERROR_INTERNAL: c_int = 35;
pub const git_error_t = c_uint;
pub extern fn git_error_last() [*c]const git_error;
pub extern fn git_error_clear() void;
pub extern fn git_error_set_str(error_class: c_int, string: [*c]const u8) c_int;
pub extern fn git_error_set_oom() void;
pub const GIT_FILTER_TO_WORKTREE: c_int = 0;
pub const GIT_FILTER_SMUDGE: c_int = 0;
pub const GIT_FILTER_TO_ODB: c_int = 1;
pub const GIT_FILTER_CLEAN: c_int = 1;
pub const git_filter_mode_t = c_uint;
pub const GIT_FILTER_DEFAULT: c_int = 0;
pub const GIT_FILTER_ALLOW_UNSAFE: c_int = 1;
pub const GIT_FILTER_NO_SYSTEM_ATTRIBUTES: c_int = 2;
pub const GIT_FILTER_ATTRIBUTES_FROM_HEAD: c_int = 4;
pub const GIT_FILTER_ATTRIBUTES_FROM_COMMIT: c_int = 8;
pub const git_filter_flag_t = c_uint;
pub const git_filter_options = extern struct {
    version: c_uint,
    flags: u32,
    commit_id: [*c]git_oid,
};
pub const struct_git_filter = opaque {};
pub const git_filter = struct_git_filter;
pub const struct_git_filter_list = opaque {};
pub const git_filter_list = struct_git_filter_list;
pub extern fn git_filter_list_load(filters: [*c]?*git_filter_list, repo: ?*git_repository, blob: ?*git_blob, path: [*c]const u8, mode: git_filter_mode_t, flags: u32) c_int;
pub extern fn git_filter_list_load_ext(filters: [*c]?*git_filter_list, repo: ?*git_repository, blob: ?*git_blob, path: [*c]const u8, mode: git_filter_mode_t, opts: [*c]git_filter_options) c_int;
pub extern fn git_filter_list_contains(filters: ?*git_filter_list, name: [*c]const u8) c_int;
pub extern fn git_filter_list_apply_to_buffer(out: [*c]git_buf, filters: ?*git_filter_list, in: [*c]const u8, in_len: usize) c_int;
pub extern fn git_filter_list_apply_to_file(out: [*c]git_buf, filters: ?*git_filter_list, repo: ?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_filter_list_apply_to_blob(out: [*c]git_buf, filters: ?*git_filter_list, blob: ?*git_blob) c_int;
pub extern fn git_filter_list_stream_buffer(filters: ?*git_filter_list, buffer: [*c]const u8, len: usize, target: [*c]git_writestream) c_int;
pub extern fn git_filter_list_stream_file(filters: ?*git_filter_list, repo: ?*git_repository, path: [*c]const u8, target: [*c]git_writestream) c_int;
pub extern fn git_filter_list_stream_blob(filters: ?*git_filter_list, blob: ?*git_blob, target: [*c]git_writestream) c_int;
pub extern fn git_filter_list_free(filters: ?*git_filter_list) void;
pub const git_rebase_options = extern struct {
    version: c_uint,
    quiet: c_int,
    inmemory: c_int,
    rewrite_notes_ref: [*c]const u8,
    merge_options: git_merge_options,
    checkout_options: git_checkout_options,
    signing_cb: git_commit_signing_cb,
    payload: ?*c_void,
};
pub const GIT_REBASE_OPERATION_PICK: c_int = 0;
pub const GIT_REBASE_OPERATION_REWORD: c_int = 1;
pub const GIT_REBASE_OPERATION_EDIT: c_int = 2;
pub const GIT_REBASE_OPERATION_SQUASH: c_int = 3;
pub const GIT_REBASE_OPERATION_FIXUP: c_int = 4;
pub const GIT_REBASE_OPERATION_EXEC: c_int = 5;
pub const git_rebase_operation_t = c_uint;
pub const git_rebase_operation = extern struct {
    type: git_rebase_operation_t,
    id: git_oid,
    exec: [*c]const u8,
};
pub extern fn git_rebase_options_init(opts: [*c]git_rebase_options, version: c_uint) c_int;
pub extern fn git_rebase_init(out: [*c]?*git_rebase, repo: ?*git_repository, branch: ?*const git_annotated_commit, upstream: ?*const git_annotated_commit, onto: ?*const git_annotated_commit, opts: [*c]const git_rebase_options) c_int;
pub extern fn git_rebase_open(out: [*c]?*git_rebase, repo: ?*git_repository, opts: [*c]const git_rebase_options) c_int;
pub extern fn git_rebase_orig_head_name(rebase: ?*git_rebase) [*c]const u8;
pub extern fn git_rebase_orig_head_id(rebase: ?*git_rebase) [*c]const git_oid;
pub extern fn git_rebase_onto_name(rebase: ?*git_rebase) [*c]const u8;
pub extern fn git_rebase_onto_id(rebase: ?*git_rebase) [*c]const git_oid;
pub extern fn git_rebase_operation_entrycount(rebase: ?*git_rebase) usize;
pub extern fn git_rebase_operation_current(rebase: ?*git_rebase) usize;
pub extern fn git_rebase_operation_byindex(rebase: ?*git_rebase, idx: usize) [*c]git_rebase_operation;
pub extern fn git_rebase_next(operation: [*c][*c]git_rebase_operation, rebase: ?*git_rebase) c_int;
pub extern fn git_rebase_inmemory_index(index: [*c]?*git_index, rebase: ?*git_rebase) c_int;
pub extern fn git_rebase_commit(id: [*c]git_oid, rebase: ?*git_rebase, author: [*c]const git_signature, committer: [*c]const git_signature, message_encoding: [*c]const u8, message: [*c]const u8) c_int;
pub extern fn git_rebase_abort(rebase: ?*git_rebase) c_int;
pub extern fn git_rebase_finish(rebase: ?*git_rebase, signature: [*c]const git_signature) c_int;
pub extern fn git_rebase_free(rebase: ?*git_rebase) void;
pub const GIT_TRACE_NONE: c_int = 0;
pub const GIT_TRACE_FATAL: c_int = 1;
pub const GIT_TRACE_ERROR: c_int = 2;
pub const GIT_TRACE_WARN: c_int = 3;
pub const GIT_TRACE_INFO: c_int = 4;
pub const GIT_TRACE_DEBUG: c_int = 5;
pub const GIT_TRACE_TRACE: c_int = 6;
pub const git_trace_level_t = c_uint;
pub const git_trace_cb = ?fn (git_trace_level_t, [*c]const u8) callconv(.C) void;
pub extern fn git_trace_set(level: git_trace_level_t, cb: git_trace_cb) c_int;
pub const git_revert_options = extern struct {
    version: c_uint,
    mainline: c_uint,
    merge_opts: git_merge_options,
    checkout_opts: git_checkout_options,
};
pub extern fn git_revert_options_init(opts: [*c]git_revert_options, version: c_uint) c_int;
pub extern fn git_revert_commit(out: [*c]?*git_index, repo: ?*git_repository, revert_commit: ?*git_commit, our_commit: ?*git_commit, mainline: c_uint, merge_options: [*c]const git_merge_options) c_int;
pub extern fn git_revert(repo: ?*git_repository, commit: ?*git_commit, given_opts: [*c]const git_revert_options) c_int;
pub extern fn git_revparse_single(out: [*c]?*git_object, repo: ?*git_repository, spec: [*c]const u8) c_int;
pub extern fn git_revparse_ext(object_out: [*c]?*git_object, reference_out: [*c]?*git_reference, repo: ?*git_repository, spec: [*c]const u8) c_int;
pub const GIT_REVSPEC_SINGLE: c_int = 1;
pub const GIT_REVSPEC_RANGE: c_int = 2;
pub const GIT_REVSPEC_MERGE_BASE: c_int = 4;
pub const git_revspec_t = c_uint;
pub const git_revspec = extern struct {
    from: ?*git_object,
    to: ?*git_object,
    flags: c_uint,
};
pub extern fn git_revparse(revspec: [*c]git_revspec, repo: ?*git_repository, spec: [*c]const u8) c_int;
pub const GIT_STASH_DEFAULT: c_int = 0;
pub const GIT_STASH_KEEP_INDEX: c_int = 1;
pub const GIT_STASH_INCLUDE_UNTRACKED: c_int = 2;
pub const GIT_STASH_INCLUDE_IGNORED: c_int = 4;
pub const git_stash_flags = c_uint;
pub extern fn git_stash_save(out: [*c]git_oid, repo: ?*git_repository, stasher: [*c]const git_signature, message: [*c]const u8, flags: u32) c_int;
pub const GIT_STASH_APPLY_DEFAULT: c_int = 0;
pub const GIT_STASH_APPLY_REINSTATE_INDEX: c_int = 1;
pub const git_stash_apply_flags = c_uint;
pub const GIT_STASH_APPLY_PROGRESS_NONE: c_int = 0;
pub const GIT_STASH_APPLY_PROGRESS_LOADING_STASH: c_int = 1;
pub const GIT_STASH_APPLY_PROGRESS_ANALYZE_INDEX: c_int = 2;
pub const GIT_STASH_APPLY_PROGRESS_ANALYZE_MODIFIED: c_int = 3;
pub const GIT_STASH_APPLY_PROGRESS_ANALYZE_UNTRACKED: c_int = 4;
pub const GIT_STASH_APPLY_PROGRESS_CHECKOUT_UNTRACKED: c_int = 5;
pub const GIT_STASH_APPLY_PROGRESS_CHECKOUT_MODIFIED: c_int = 6;
pub const GIT_STASH_APPLY_PROGRESS_DONE: c_int = 7;
pub const git_stash_apply_progress_t = c_uint;
pub const git_stash_apply_progress_cb = ?fn (git_stash_apply_progress_t, ?*c_void) callconv(.C) c_int;
pub const struct_git_stash_apply_options = extern struct {
    version: c_uint,
    flags: u32,
    checkout_options: git_checkout_options,
    progress_cb: git_stash_apply_progress_cb,
    progress_payload: ?*c_void,
};
pub const git_stash_apply_options = struct_git_stash_apply_options;
pub extern fn git_stash_apply_options_init(opts: [*c]git_stash_apply_options, version: c_uint) c_int;
pub extern fn git_stash_apply(repo: ?*git_repository, index: usize, options: [*c]const git_stash_apply_options) c_int;
pub const git_stash_cb = ?fn (usize, [*c]const u8, [*c]const git_oid, ?*c_void) callconv(.C) c_int;
pub extern fn git_stash_foreach(repo: ?*git_repository, callback: git_stash_cb, payload: ?*c_void) c_int;
pub extern fn git_stash_drop(repo: ?*git_repository, index: usize) c_int;
pub extern fn git_stash_pop(repo: ?*git_repository, index: usize, options: [*c]const git_stash_apply_options) c_int;
pub const GIT_STATUS_CURRENT: c_int = 0;
pub const GIT_STATUS_INDEX_NEW: c_int = 1;
pub const GIT_STATUS_INDEX_MODIFIED: c_int = 2;
pub const GIT_STATUS_INDEX_DELETED: c_int = 4;
pub const GIT_STATUS_INDEX_RENAMED: c_int = 8;
pub const GIT_STATUS_INDEX_TYPECHANGE: c_int = 16;
pub const GIT_STATUS_WT_NEW: c_int = 128;
pub const GIT_STATUS_WT_MODIFIED: c_int = 256;
pub const GIT_STATUS_WT_DELETED: c_int = 512;
pub const GIT_STATUS_WT_TYPECHANGE: c_int = 1024;
pub const GIT_STATUS_WT_RENAMED: c_int = 2048;
pub const GIT_STATUS_WT_UNREADABLE: c_int = 4096;
pub const GIT_STATUS_IGNORED: c_int = 16384;
pub const GIT_STATUS_CONFLICTED: c_int = 32768;
pub const git_status_t = c_uint;
pub const git_status_cb = ?fn ([*c]const u8, c_uint, ?*c_void) callconv(.C) c_int;
pub const GIT_STATUS_SHOW_INDEX_AND_WORKDIR: c_int = 0;
pub const GIT_STATUS_SHOW_INDEX_ONLY: c_int = 1;
pub const GIT_STATUS_SHOW_WORKDIR_ONLY: c_int = 2;
pub const git_status_show_t = c_uint;
pub const GIT_STATUS_OPT_INCLUDE_UNTRACKED: c_int = 1;
pub const GIT_STATUS_OPT_INCLUDE_IGNORED: c_int = 2;
pub const GIT_STATUS_OPT_INCLUDE_UNMODIFIED: c_int = 4;
pub const GIT_STATUS_OPT_EXCLUDE_SUBMODULES: c_int = 8;
pub const GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS: c_int = 16;
pub const GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH: c_int = 32;
pub const GIT_STATUS_OPT_RECURSE_IGNORED_DIRS: c_int = 64;
pub const GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX: c_int = 128;
pub const GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR: c_int = 256;
pub const GIT_STATUS_OPT_SORT_CASE_SENSITIVELY: c_int = 512;
pub const GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY: c_int = 1024;
pub const GIT_STATUS_OPT_RENAMES_FROM_REWRITES: c_int = 2048;
pub const GIT_STATUS_OPT_NO_REFRESH: c_int = 4096;
pub const GIT_STATUS_OPT_UPDATE_INDEX: c_int = 8192;
pub const GIT_STATUS_OPT_INCLUDE_UNREADABLE: c_int = 16384;
pub const GIT_STATUS_OPT_INCLUDE_UNREADABLE_AS_UNTRACKED: c_int = 32768;
pub const git_status_opt_t = c_uint;
pub const git_status_options = extern struct {
    version: c_uint,
    show: git_status_show_t,
    flags: c_uint,
    pathspec: git_strarray,
    baseline: ?*git_tree,
};
pub extern fn git_status_options_init(opts: [*c]git_status_options, version: c_uint) c_int;
pub const git_status_entry = extern struct {
    status: git_status_t,
    head_to_index: [*c]git_diff_delta,
    index_to_workdir: [*c]git_diff_delta,
};
pub extern fn git_status_foreach(repo: ?*git_repository, callback: git_status_cb, payload: ?*c_void) c_int;
pub extern fn git_status_foreach_ext(repo: ?*git_repository, opts: [*c]const git_status_options, callback: git_status_cb, payload: ?*c_void) c_int;
pub extern fn git_status_file(status_flags: [*c]c_uint, repo: ?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_status_list_new(out: [*c]?*git_status_list, repo: ?*git_repository, opts: [*c]const git_status_options) c_int;
pub extern fn git_status_list_entrycount(statuslist: ?*git_status_list) usize;
pub extern fn git_status_byindex(statuslist: ?*git_status_list, idx: usize) [*c]const git_status_entry;
pub extern fn git_status_list_free(statuslist: ?*git_status_list) void;
pub extern fn git_status_should_ignore(ignored: [*c]c_int, repo: ?*git_repository, path: [*c]const u8) c_int;
pub const GIT_SUBMODULE_STATUS_IN_HEAD: c_int = 1;
pub const GIT_SUBMODULE_STATUS_IN_INDEX: c_int = 2;
pub const GIT_SUBMODULE_STATUS_IN_CONFIG: c_int = 4;
pub const GIT_SUBMODULE_STATUS_IN_WD: c_int = 8;
pub const GIT_SUBMODULE_STATUS_INDEX_ADDED: c_int = 16;
pub const GIT_SUBMODULE_STATUS_INDEX_DELETED: c_int = 32;
pub const GIT_SUBMODULE_STATUS_INDEX_MODIFIED: c_int = 64;
pub const GIT_SUBMODULE_STATUS_WD_UNINITIALIZED: c_int = 128;
pub const GIT_SUBMODULE_STATUS_WD_ADDED: c_int = 256;
pub const GIT_SUBMODULE_STATUS_WD_DELETED: c_int = 512;
pub const GIT_SUBMODULE_STATUS_WD_MODIFIED: c_int = 1024;
pub const GIT_SUBMODULE_STATUS_WD_INDEX_MODIFIED: c_int = 2048;
pub const GIT_SUBMODULE_STATUS_WD_WD_MODIFIED: c_int = 4096;
pub const GIT_SUBMODULE_STATUS_WD_UNTRACKED: c_int = 8192;
pub const git_submodule_status_t = c_uint;
pub const git_submodule_cb = ?fn (?*git_submodule, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const struct_git_submodule_update_options = extern struct {
    version: c_uint,
    checkout_opts: git_checkout_options,
    fetch_opts: git_fetch_options,
    allow_fetch: c_int,
};
pub const git_submodule_update_options = struct_git_submodule_update_options;
pub extern fn git_submodule_update_options_init(opts: [*c]git_submodule_update_options, version: c_uint) c_int;
pub extern fn git_submodule_update(submodule: ?*git_submodule, init: c_int, options: [*c]git_submodule_update_options) c_int;
pub extern fn git_submodule_lookup(out: [*c]?*git_submodule, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_submodule_dup(out: [*c]?*git_submodule, source: ?*git_submodule) c_int;
pub extern fn git_submodule_free(submodule: ?*git_submodule) void;
pub extern fn git_submodule_foreach(repo: ?*git_repository, callback: git_submodule_cb, payload: ?*c_void) c_int;
pub extern fn git_submodule_add_setup(out: [*c]?*git_submodule, repo: ?*git_repository, url: [*c]const u8, path: [*c]const u8, use_gitlink: c_int) c_int;
pub extern fn git_submodule_clone(out: [*c]?*git_repository, submodule: ?*git_submodule, opts: [*c]const git_submodule_update_options) c_int;
pub extern fn git_submodule_add_finalize(submodule: ?*git_submodule) c_int;
pub extern fn git_submodule_add_to_index(submodule: ?*git_submodule, write_index: c_int) c_int;
pub extern fn git_submodule_owner(submodule: ?*git_submodule) ?*git_repository;
pub extern fn git_submodule_name(submodule: ?*git_submodule) [*c]const u8;
pub extern fn git_submodule_path(submodule: ?*git_submodule) [*c]const u8;
pub extern fn git_submodule_url(submodule: ?*git_submodule) [*c]const u8;
pub extern fn git_submodule_resolve_url(out: [*c]git_buf, repo: ?*git_repository, url: [*c]const u8) c_int;
pub extern fn git_submodule_branch(submodule: ?*git_submodule) [*c]const u8;
pub extern fn git_submodule_set_branch(repo: ?*git_repository, name: [*c]const u8, branch: [*c]const u8) c_int;
pub extern fn git_submodule_set_url(repo: ?*git_repository, name: [*c]const u8, url: [*c]const u8) c_int;
pub extern fn git_submodule_index_id(submodule: ?*git_submodule) [*c]const git_oid;
pub extern fn git_submodule_head_id(submodule: ?*git_submodule) [*c]const git_oid;
pub extern fn git_submodule_wd_id(submodule: ?*git_submodule) [*c]const git_oid;
pub extern fn git_submodule_ignore(submodule: ?*git_submodule) git_submodule_ignore_t;
pub extern fn git_submodule_set_ignore(repo: ?*git_repository, name: [*c]const u8, ignore: git_submodule_ignore_t) c_int;
pub extern fn git_submodule_update_strategy(submodule: ?*git_submodule) git_submodule_update_t;
pub extern fn git_submodule_set_update(repo: ?*git_repository, name: [*c]const u8, update: git_submodule_update_t) c_int;
pub extern fn git_submodule_fetch_recurse_submodules(submodule: ?*git_submodule) git_submodule_recurse_t;
pub extern fn git_submodule_set_fetch_recurse_submodules(repo: ?*git_repository, name: [*c]const u8, fetch_recurse_submodules: git_submodule_recurse_t) c_int;
pub extern fn git_submodule_init(submodule: ?*git_submodule, overwrite: c_int) c_int;
pub extern fn git_submodule_repo_init(out: [*c]?*git_repository, sm: ?*const git_submodule, use_gitlink: c_int) c_int;
pub extern fn git_submodule_sync(submodule: ?*git_submodule) c_int;
pub extern fn git_submodule_open(repo: [*c]?*git_repository, submodule: ?*git_submodule) c_int;
pub extern fn git_submodule_reload(submodule: ?*git_submodule, force: c_int) c_int;
pub extern fn git_submodule_status(status: [*c]c_uint, repo: ?*git_repository, name: [*c]const u8, ignore: git_submodule_ignore_t) c_int;
pub extern fn git_submodule_location(location_status: [*c]c_uint, submodule: ?*git_submodule) c_int;
pub extern fn git_worktree_list(out: [*c]git_strarray, repo: ?*git_repository) c_int;
pub extern fn git_worktree_lookup(out: [*c]?*git_worktree, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_worktree_open_from_repository(out: [*c]?*git_worktree, repo: ?*git_repository) c_int;
pub extern fn git_worktree_free(wt: ?*git_worktree) void;
pub extern fn git_worktree_validate(wt: ?*const git_worktree) c_int;
pub const struct_git_worktree_add_options = extern struct {
    version: c_uint,
    lock: c_int,
    ref: ?*git_reference,
};
pub const git_worktree_add_options = struct_git_worktree_add_options;
pub extern fn git_worktree_add_options_init(opts: [*c]git_worktree_add_options, version: c_uint) c_int;
pub extern fn git_worktree_add(out: [*c]?*git_worktree, repo: ?*git_repository, name: [*c]const u8, path: [*c]const u8, opts: [*c]const git_worktree_add_options) c_int;
pub extern fn git_worktree_lock(wt: ?*git_worktree, reason: [*c]const u8) c_int;
pub extern fn git_worktree_unlock(wt: ?*git_worktree) c_int;
pub extern fn git_worktree_is_locked(reason: [*c]git_buf, wt: ?*const git_worktree) c_int;
pub extern fn git_worktree_name(wt: ?*const git_worktree) [*c]const u8;
pub extern fn git_worktree_path(wt: ?*const git_worktree) [*c]const u8;
pub const GIT_WORKTREE_PRUNE_VALID: c_int = 1;
pub const GIT_WORKTREE_PRUNE_LOCKED: c_int = 2;
pub const GIT_WORKTREE_PRUNE_WORKING_TREE: c_int = 4;
pub const git_worktree_prune_t = c_uint;
pub const struct_git_worktree_prune_options = extern struct {
    version: c_uint,
    flags: u32,
};
pub const git_worktree_prune_options = struct_git_worktree_prune_options;
pub extern fn git_worktree_prune_options_init(opts: [*c]git_worktree_prune_options, version: c_uint) c_int;
pub extern fn git_worktree_is_prunable(wt: ?*git_worktree, opts: [*c]git_worktree_prune_options) c_int;
pub extern fn git_worktree_prune(wt: ?*git_worktree, opts: [*c]git_worktree_prune_options) c_int;
pub const struct_git_credential_userpass_payload = extern struct {
    username: [*c]const u8,
    password: [*c]const u8,
};
pub const git_credential_userpass_payload = struct_git_credential_userpass_payload;
pub extern fn git_credential_userpass(out: [*c][*c]git_credential, url: [*c]const u8, user_from_url: [*c]const u8, allowed_types: c_uint, payload: ?*c_void) c_int;
pub const git_attr_t = git_attr_value_t;
pub extern fn git_blob_create_fromworkdir(id: [*c]git_oid, repo: ?*git_repository, relative_path: [*c]const u8) c_int;
pub extern fn git_blob_create_fromdisk(id: [*c]git_oid, repo: ?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_blob_create_fromstream(out: [*c][*c]git_writestream, repo: ?*git_repository, hintpath: [*c]const u8) c_int;
pub extern fn git_blob_create_fromstream_commit(out: [*c]git_oid, stream: [*c]git_writestream) c_int;
pub extern fn git_blob_create_frombuffer(id: [*c]git_oid, repo: ?*git_repository, buffer: ?*const c_void, len: usize) c_int;
pub extern fn git_blob_filtered_content(out: [*c]git_buf, blob: ?*git_blob, as_path: [*c]const u8, check_for_binary_data: c_int) c_int;
pub extern fn git_filter_list_stream_data(filters: ?*git_filter_list, data: [*c]git_buf, target: [*c]git_writestream) c_int;
pub extern fn git_filter_list_apply_to_data(out: [*c]git_buf, filters: ?*git_filter_list, in: [*c]git_buf) c_int;
pub extern fn git_treebuilder_write_with_buffer(oid: [*c]git_oid, bld: ?*git_treebuilder, tree: [*c]git_buf) c_int;
pub extern fn git_buf_free(buffer: [*c]git_buf) void;
pub const git_cvar_map = git_configmap;
pub extern fn giterr_last() [*c]const git_error;
pub extern fn giterr_clear() void;
pub extern fn giterr_set_str(error_class: c_int, string: [*c]const u8) void;
pub extern fn giterr_set_oom() void;
pub extern fn git_index_add_frombuffer(index: ?*git_index, entry: [*c]const git_index_entry, buffer: ?*const c_void, len: usize) c_int;
pub extern fn git_object__size(@"type": git_object_t) usize;
pub extern fn git_remote_is_valid_name(remote_name: [*c]const u8) c_int;
pub extern fn git_reference_is_valid_name(refname: [*c]const u8) c_int;
pub extern fn git_tag_create_frombuffer(oid: [*c]git_oid, repo: ?*git_repository, buffer: [*c]const u8, force: c_int) c_int;
pub const git_revparse_mode_t = git_revspec_t;
pub const git_cred = git_credential;
pub const git_cred_userpass_plaintext = git_credential_userpass_plaintext;
pub const git_cred_username = git_credential_username;
pub const git_cred_default = git_credential_default;
pub const git_cred_ssh_key = git_credential_ssh_key;
pub const git_cred_ssh_interactive = git_credential_ssh_interactive;
pub const git_cred_ssh_custom = git_credential_ssh_custom;
pub const git_cred_acquire_cb = git_credential_acquire_cb;
pub const git_cred_sign_callback = git_credential_sign_cb;
pub const git_cred_sign_cb = git_credential_sign_cb;
pub const git_cred_ssh_interactive_callback = git_credential_ssh_interactive_cb;
pub const git_cred_ssh_interactive_cb = git_credential_ssh_interactive_cb;
pub extern fn git_cred_free(cred: [*c]git_credential) void;
pub extern fn git_cred_has_username(cred: [*c]git_credential) c_int;
pub extern fn git_cred_get_username(cred: [*c]git_credential) [*c]const u8;
pub extern fn git_cred_userpass_plaintext_new(out: [*c][*c]git_credential, username: [*c]const u8, password: [*c]const u8) c_int;
pub extern fn git_cred_default_new(out: [*c][*c]git_credential) c_int;
pub extern fn git_cred_username_new(out: [*c][*c]git_credential, username: [*c]const u8) c_int;
pub extern fn git_cred_ssh_key_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, privatekey: [*c]const u8, passphrase: [*c]const u8) c_int;
pub extern fn git_cred_ssh_key_memory_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, privatekey: [*c]const u8, passphrase: [*c]const u8) c_int;
pub extern fn git_cred_ssh_interactive_new(out: [*c][*c]git_credential, username: [*c]const u8, prompt_callback: git_credential_ssh_interactive_cb, payload: ?*c_void) c_int;
pub extern fn git_cred_ssh_key_from_agent(out: [*c][*c]git_credential, username: [*c]const u8) c_int;
pub extern fn git_cred_ssh_custom_new(out: [*c][*c]git_credential, username: [*c]const u8, publickey: [*c]const u8, publickey_len: usize, sign_callback: git_credential_sign_cb, payload: ?*c_void) c_int;
pub const git_cred_userpass_payload = git_credential_userpass_payload;
pub extern fn git_cred_userpass(out: [*c][*c]git_credential, url: [*c]const u8, user_from_url: [*c]const u8, allowed_types: c_uint, payload: ?*c_void) c_int;
pub const git_trace_callback = git_trace_cb;
pub extern fn git_oid_iszero(id: [*c]const git_oid) c_int;
pub const git_transfer_progress = git_indexer_progress;
pub const git_transfer_progress_cb = git_indexer_progress_cb;
pub const git_push_transfer_progress = git_push_transfer_progress_cb;
pub const git_headlist_cb = ?fn ([*c]git_remote_head, ?*c_void) callconv(.C) c_int;
pub extern fn git_strarray_free(array: [*c]git_strarray) void;
pub extern fn git_blame_init_options(opts: [*c]git_blame_options, version: c_uint) c_int;
pub extern fn git_checkout_init_options(opts: [*c]git_checkout_options, version: c_uint) c_int;
pub extern fn git_cherrypick_init_options(opts: [*c]git_cherrypick_options, version: c_uint) c_int;
pub extern fn git_clone_init_options(opts: [*c]git_clone_options, version: c_uint) c_int;
pub extern fn git_describe_init_options(opts: [*c]git_describe_options, version: c_uint) c_int;
pub extern fn git_describe_init_format_options(opts: [*c]git_describe_format_options, version: c_uint) c_int;
pub extern fn git_diff_init_options(opts: [*c]git_diff_options, version: c_uint) c_int;
pub extern fn git_diff_find_init_options(opts: [*c]git_diff_find_options, version: c_uint) c_int;
pub extern fn git_diff_format_email_init_options(opts: [*c]git_diff_format_email_options, version: c_uint) c_int;
pub extern fn git_diff_patchid_init_options(opts: [*c]git_diff_patchid_options, version: c_uint) c_int;
pub extern fn git_fetch_init_options(opts: [*c]git_fetch_options, version: c_uint) c_int;
pub extern fn git_indexer_init_options(opts: [*c]git_indexer_options, version: c_uint) c_int;
pub extern fn git_merge_init_options(opts: [*c]git_merge_options, version: c_uint) c_int;
pub extern fn git_merge_file_init_input(input: [*c]git_merge_file_input, version: c_uint) c_int;
pub extern fn git_merge_file_init_options(opts: [*c]git_merge_file_options, version: c_uint) c_int;
pub extern fn git_proxy_init_options(opts: [*c]git_proxy_options, version: c_uint) c_int;
pub extern fn git_push_init_options(opts: [*c]git_push_options, version: c_uint) c_int;
pub extern fn git_rebase_init_options(opts: [*c]git_rebase_options, version: c_uint) c_int;
pub extern fn git_remote_create_init_options(opts: [*c]git_remote_create_options, version: c_uint) c_int;
pub extern fn git_repository_init_init_options(opts: [*c]git_repository_init_options, version: c_uint) c_int;
pub extern fn git_revert_init_options(opts: [*c]git_revert_options, version: c_uint) c_int;
pub extern fn git_stash_apply_init_options(opts: [*c]git_stash_apply_options, version: c_uint) c_int;
pub extern fn git_status_init_options(opts: [*c]git_status_options, version: c_uint) c_int;
pub extern fn git_submodule_update_init_options(opts: [*c]git_submodule_update_options, version: c_uint) c_int;
pub extern fn git_worktree_add_init_options(opts: [*c]git_worktree_add_options, version: c_uint) c_int;
pub extern fn git_worktree_prune_init_options(opts: [*c]git_worktree_prune_options, version: c_uint) c_int;
pub extern fn git_libgit2_init() c_int;
pub extern fn git_libgit2_shutdown() c_int;
pub extern fn git_graph_ahead_behind(ahead: [*c]usize, behind: [*c]usize, repo: ?*git_repository, local: [*c]const git_oid, upstream: [*c]const git_oid) c_int;
pub extern fn git_graph_descendant_of(repo: ?*git_repository, commit: [*c]const git_oid, ancestor: [*c]const git_oid) c_int;
pub extern fn git_graph_reachable_from_any(repo: ?*git_repository, commit: [*c]const git_oid, descendant_array: [*c]const git_oid, length: usize) c_int;
pub extern fn git_ignore_add_rule(repo: ?*git_repository, rules: [*c]const u8) c_int;
pub extern fn git_ignore_clear_internal_rules(repo: ?*git_repository) c_int;
pub extern fn git_ignore_path_is_ignored(ignored: [*c]c_int, repo: ?*git_repository, path: [*c]const u8) c_int;
pub extern fn git_mailmap_new(out: [*c]?*git_mailmap) c_int;
pub extern fn git_mailmap_free(mm: ?*git_mailmap) void;
pub extern fn git_mailmap_add_entry(mm: ?*git_mailmap, real_name: [*c]const u8, real_email: [*c]const u8, replace_name: [*c]const u8, replace_email: [*c]const u8) c_int;
pub extern fn git_mailmap_from_buffer(out: [*c]?*git_mailmap, buf: [*c]const u8, len: usize) c_int;
pub extern fn git_mailmap_from_repository(out: [*c]?*git_mailmap, repo: ?*git_repository) c_int;
pub extern fn git_mailmap_resolve(real_name: [*c][*c]const u8, real_email: [*c][*c]const u8, mm: ?*const git_mailmap, name: [*c]const u8, email: [*c]const u8) c_int;
pub extern fn git_mailmap_resolve_signature(out: [*c][*c]git_signature, mm: ?*const git_mailmap, sig: [*c]const git_signature) c_int;
pub extern fn git_message_prettify(out: [*c]git_buf, message: [*c]const u8, strip_comments: c_int, comment_char: u8) c_int;
pub const git_message_trailer = extern struct {
    key: [*c]const u8,
    value: [*c]const u8,
};
pub const git_message_trailer_array = extern struct {
    trailers: [*c]git_message_trailer,
    count: usize,
    _trailer_block: [*c]u8,
};
pub extern fn git_message_trailers(arr: [*c]git_message_trailer_array, message: [*c]const u8) c_int;
pub extern fn git_message_trailer_array_free(arr: [*c]git_message_trailer_array) void;
pub const git_note_foreach_cb = ?fn ([*c]const git_oid, [*c]const git_oid, ?*c_void) callconv(.C) c_int;
pub const struct_git_iterator = opaque {};
pub const git_note_iterator = struct_git_iterator;
pub extern fn git_note_iterator_new(out: [*c]?*git_note_iterator, repo: ?*git_repository, notes_ref: [*c]const u8) c_int;
pub extern fn git_note_commit_iterator_new(out: [*c]?*git_note_iterator, notes_commit: ?*git_commit) c_int;
pub extern fn git_note_iterator_free(it: ?*git_note_iterator) void;
pub extern fn git_note_next(note_id: [*c]git_oid, annotated_id: [*c]git_oid, it: ?*git_note_iterator) c_int;
pub extern fn git_note_read(out: [*c]?*git_note, repo: ?*git_repository, notes_ref: [*c]const u8, oid: [*c]const git_oid) c_int;
pub extern fn git_note_commit_read(out: [*c]?*git_note, repo: ?*git_repository, notes_commit: ?*git_commit, oid: [*c]const git_oid) c_int;
pub extern fn git_note_author(note: ?*const git_note) [*c]const git_signature;
pub extern fn git_note_committer(note: ?*const git_note) [*c]const git_signature;
pub extern fn git_note_message(note: ?*const git_note) [*c]const u8;
pub extern fn git_note_id(note: ?*const git_note) [*c]const git_oid;
pub extern fn git_note_create(out: [*c]git_oid, repo: ?*git_repository, notes_ref: [*c]const u8, author: [*c]const git_signature, committer: [*c]const git_signature, oid: [*c]const git_oid, note: [*c]const u8, force: c_int) c_int;
pub extern fn git_note_commit_create(notes_commit_out: [*c]git_oid, notes_blob_out: [*c]git_oid, repo: ?*git_repository, parent: ?*git_commit, author: [*c]const git_signature, committer: [*c]const git_signature, oid: [*c]const git_oid, note: [*c]const u8, allow_note_overwrite: c_int) c_int;
pub extern fn git_note_remove(repo: ?*git_repository, notes_ref: [*c]const u8, author: [*c]const git_signature, committer: [*c]const git_signature, oid: [*c]const git_oid) c_int;
pub extern fn git_note_commit_remove(notes_commit_out: [*c]git_oid, repo: ?*git_repository, notes_commit: ?*git_commit, author: [*c]const git_signature, committer: [*c]const git_signature, oid: [*c]const git_oid) c_int;
pub extern fn git_note_free(note: ?*git_note) void;
pub extern fn git_note_default_ref(out: [*c]git_buf, repo: ?*git_repository) c_int;
pub extern fn git_note_foreach(repo: ?*git_repository, notes_ref: [*c]const u8, note_cb: git_note_foreach_cb, payload: ?*c_void) c_int;
pub const git_odb_foreach_cb = ?fn ([*c]const git_oid, ?*c_void) callconv(.C) c_int;
pub extern fn git_odb_new(out: [*c]?*git_odb) c_int;
pub extern fn git_odb_open(out: [*c]?*git_odb, objects_dir: [*c]const u8) c_int;
pub extern fn git_odb_add_disk_alternate(odb: ?*git_odb, path: [*c]const u8) c_int;
pub extern fn git_odb_free(db: ?*git_odb) void;
pub extern fn git_odb_read(out: [*c]?*git_odb_object, db: ?*git_odb, id: [*c]const git_oid) c_int;
pub extern fn git_odb_read_prefix(out: [*c]?*git_odb_object, db: ?*git_odb, short_id: [*c]const git_oid, len: usize) c_int;
pub extern fn git_odb_read_header(len_out: [*c]usize, type_out: [*c]git_object_t, db: ?*git_odb, id: [*c]const git_oid) c_int;
pub extern fn git_odb_exists(db: ?*git_odb, id: [*c]const git_oid) c_int;
pub extern fn git_odb_exists_prefix(out: [*c]git_oid, db: ?*git_odb, short_id: [*c]const git_oid, len: usize) c_int;
pub const struct_git_odb_expand_id = extern struct {
    id: git_oid,
    length: c_ushort,
    type: git_object_t,
};
pub const git_odb_expand_id = struct_git_odb_expand_id;
pub extern fn git_odb_expand_ids(db: ?*git_odb, ids: [*c]git_odb_expand_id, count: usize) c_int;
pub extern fn git_odb_refresh(db: ?*struct_git_odb) c_int;
pub extern fn git_odb_foreach(db: ?*git_odb, cb: git_odb_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_odb_write(out: [*c]git_oid, odb: ?*git_odb, data: ?*const c_void, len: usize, @"type": git_object_t) c_int;
pub extern fn git_odb_open_wstream(out: [*c][*c]git_odb_stream, db: ?*git_odb, size: git_object_size_t, @"type": git_object_t) c_int;
pub extern fn git_odb_stream_write(stream: [*c]git_odb_stream, buffer: [*c]const u8, len: usize) c_int;
pub extern fn git_odb_stream_finalize_write(out: [*c]git_oid, stream: [*c]git_odb_stream) c_int;
pub extern fn git_odb_stream_read(stream: [*c]git_odb_stream, buffer: [*c]u8, len: usize) c_int;
pub extern fn git_odb_stream_free(stream: [*c]git_odb_stream) void;
pub extern fn git_odb_open_rstream(out: [*c][*c]git_odb_stream, len: [*c]usize, @"type": [*c]git_object_t, db: ?*git_odb, oid: [*c]const git_oid) c_int;
pub extern fn git_odb_write_pack(out: [*c][*c]git_odb_writepack, db: ?*git_odb, progress_cb: git_indexer_progress_cb, progress_payload: ?*c_void) c_int;
pub extern fn git_odb_hash(out: [*c]git_oid, data: ?*const c_void, len: usize, @"type": git_object_t) c_int;
pub extern fn git_odb_hashfile(out: [*c]git_oid, path: [*c]const u8, @"type": git_object_t) c_int;
pub extern fn git_odb_object_dup(dest: [*c]?*git_odb_object, source: ?*git_odb_object) c_int;
pub extern fn git_odb_object_free(object: ?*git_odb_object) void;
pub extern fn git_odb_object_id(object: ?*git_odb_object) [*c]const git_oid;
pub extern fn git_odb_object_data(object: ?*git_odb_object) ?*const c_void;
pub extern fn git_odb_object_size(object: ?*git_odb_object) usize;
pub extern fn git_odb_object_type(object: ?*git_odb_object) git_object_t;
pub extern fn git_odb_add_backend(odb: ?*git_odb, backend: ?*git_odb_backend, priority: c_int) c_int;
pub extern fn git_odb_add_alternate(odb: ?*git_odb, backend: ?*git_odb_backend, priority: c_int) c_int;
pub extern fn git_odb_num_backends(odb: ?*git_odb) usize;
pub extern fn git_odb_get_backend(out: [*c]?*git_odb_backend, odb: ?*git_odb, pos: usize) c_int;
pub extern fn git_odb_set_commit_graph(odb: ?*git_odb, cgraph: ?*git_commit_graph) c_int;
pub extern fn git_odb_backend_pack(out: [*c]?*git_odb_backend, objects_dir: [*c]const u8) c_int;
pub extern fn git_odb_backend_loose(out: [*c]?*git_odb_backend, objects_dir: [*c]const u8, compression_level: c_int, do_fsync: c_int, dir_mode: c_uint, file_mode: c_uint) c_int;
pub extern fn git_odb_backend_one_pack(out: [*c]?*git_odb_backend, index_file: [*c]const u8) c_int;
pub const GIT_STREAM_RDONLY: c_int = 2;
pub const GIT_STREAM_WRONLY: c_int = 4;
pub const GIT_STREAM_RW: c_int = 6;
pub const git_odb_stream_t = c_uint;
pub const struct_git_patch = opaque {};
pub const git_patch = struct_git_patch;
pub extern fn git_patch_owner(patch: ?*const git_patch) ?*git_repository;
pub extern fn git_patch_from_diff(out: [*c]?*git_patch, diff: ?*git_diff, idx: usize) c_int;
pub extern fn git_patch_from_blobs(out: [*c]?*git_patch, old_blob: ?*const git_blob, old_as_path: [*c]const u8, new_blob: ?*const git_blob, new_as_path: [*c]const u8, opts: [*c]const git_diff_options) c_int;
pub extern fn git_patch_from_blob_and_buffer(out: [*c]?*git_patch, old_blob: ?*const git_blob, old_as_path: [*c]const u8, buffer: ?*const c_void, buffer_len: usize, buffer_as_path: [*c]const u8, opts: [*c]const git_diff_options) c_int;
pub extern fn git_patch_from_buffers(out: [*c]?*git_patch, old_buffer: ?*const c_void, old_len: usize, old_as_path: [*c]const u8, new_buffer: ?*const c_void, new_len: usize, new_as_path: [*c]const u8, opts: [*c]const git_diff_options) c_int;
pub extern fn git_patch_free(patch: ?*git_patch) void;
pub extern fn git_patch_get_delta(patch: ?*const git_patch) [*c]const git_diff_delta;
pub extern fn git_patch_num_hunks(patch: ?*const git_patch) usize;
pub extern fn git_patch_line_stats(total_context: [*c]usize, total_additions: [*c]usize, total_deletions: [*c]usize, patch: ?*const git_patch) c_int;
pub extern fn git_patch_get_hunk(out: [*c][*c]const git_diff_hunk, lines_in_hunk: [*c]usize, patch: ?*git_patch, hunk_idx: usize) c_int;
pub extern fn git_patch_num_lines_in_hunk(patch: ?*const git_patch, hunk_idx: usize) c_int;
pub extern fn git_patch_get_line_in_hunk(out: [*c][*c]const git_diff_line, patch: ?*git_patch, hunk_idx: usize, line_of_hunk: usize) c_int;
pub extern fn git_patch_size(patch: ?*git_patch, include_context: c_int, include_hunk_headers: c_int, include_file_headers: c_int) usize;
pub extern fn git_patch_print(patch: ?*git_patch, print_cb: git_diff_line_cb, payload: ?*c_void) c_int;
pub extern fn git_patch_to_buf(out: [*c]git_buf, patch: ?*git_patch) c_int;
pub const struct_git_pathspec = opaque {};
pub const git_pathspec = struct_git_pathspec;
pub const struct_git_pathspec_match_list = opaque {};
pub const git_pathspec_match_list = struct_git_pathspec_match_list;
pub const GIT_PATHSPEC_DEFAULT: c_int = 0;
pub const GIT_PATHSPEC_IGNORE_CASE: c_int = 1;
pub const GIT_PATHSPEC_USE_CASE: c_int = 2;
pub const GIT_PATHSPEC_NO_GLOB: c_int = 4;
pub const GIT_PATHSPEC_NO_MATCH_ERROR: c_int = 8;
pub const GIT_PATHSPEC_FIND_FAILURES: c_int = 16;
pub const GIT_PATHSPEC_FAILURES_ONLY: c_int = 32;
pub const git_pathspec_flag_t = c_uint;
pub extern fn git_pathspec_new(out: [*c]?*git_pathspec, pathspec: [*c]const git_strarray) c_int;
pub extern fn git_pathspec_free(ps: ?*git_pathspec) void;
pub extern fn git_pathspec_matches_path(ps: ?*const git_pathspec, flags: u32, path: [*c]const u8) c_int;
pub extern fn git_pathspec_match_workdir(out: [*c]?*git_pathspec_match_list, repo: ?*git_repository, flags: u32, ps: ?*git_pathspec) c_int;
pub extern fn git_pathspec_match_index(out: [*c]?*git_pathspec_match_list, index: ?*git_index, flags: u32, ps: ?*git_pathspec) c_int;
pub extern fn git_pathspec_match_tree(out: [*c]?*git_pathspec_match_list, tree: ?*git_tree, flags: u32, ps: ?*git_pathspec) c_int;
pub extern fn git_pathspec_match_diff(out: [*c]?*git_pathspec_match_list, diff: ?*git_diff, flags: u32, ps: ?*git_pathspec) c_int;
pub extern fn git_pathspec_match_list_free(m: ?*git_pathspec_match_list) void;
pub extern fn git_pathspec_match_list_entrycount(m: ?*const git_pathspec_match_list) usize;
pub extern fn git_pathspec_match_list_entry(m: ?*const git_pathspec_match_list, pos: usize) [*c]const u8;
pub extern fn git_pathspec_match_list_diff_entry(m: ?*const git_pathspec_match_list, pos: usize) [*c]const git_diff_delta;
pub extern fn git_pathspec_match_list_failed_entrycount(m: ?*const git_pathspec_match_list) usize;
pub extern fn git_pathspec_match_list_failed_entry(m: ?*const git_pathspec_match_list, pos: usize) [*c]const u8;
pub extern fn git_refdb_new(out: [*c]?*git_refdb, repo: ?*git_repository) c_int;
pub extern fn git_refdb_open(out: [*c]?*git_refdb, repo: ?*git_repository) c_int;
pub extern fn git_refdb_compress(refdb: ?*git_refdb) c_int;
pub extern fn git_refdb_free(refdb: ?*git_refdb) void;
pub extern fn git_reflog_read(out: [*c]?*git_reflog, repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_reflog_write(reflog: ?*git_reflog) c_int;
pub extern fn git_reflog_append(reflog: ?*git_reflog, id: [*c]const git_oid, committer: [*c]const git_signature, msg: [*c]const u8) c_int;
pub extern fn git_reflog_rename(repo: ?*git_repository, old_name: [*c]const u8, name: [*c]const u8) c_int;
pub extern fn git_reflog_delete(repo: ?*git_repository, name: [*c]const u8) c_int;
pub extern fn git_reflog_entrycount(reflog: ?*git_reflog) usize;
pub extern fn git_reflog_entry_byindex(reflog: ?*const git_reflog, idx: usize) ?*const git_reflog_entry;
pub extern fn git_reflog_drop(reflog: ?*git_reflog, idx: usize, rewrite_previous_entry: c_int) c_int;
pub extern fn git_reflog_entry_id_old(entry: ?*const git_reflog_entry) [*c]const git_oid;
pub extern fn git_reflog_entry_id_new(entry: ?*const git_reflog_entry) [*c]const git_oid;
pub extern fn git_reflog_entry_committer(entry: ?*const git_reflog_entry) [*c]const git_signature;
pub extern fn git_reflog_entry_message(entry: ?*const git_reflog_entry) [*c]const u8;
pub extern fn git_reflog_free(reflog: ?*git_reflog) void;
pub const GIT_RESET_SOFT: c_int = 1;
pub const GIT_RESET_MIXED: c_int = 2;
pub const GIT_RESET_HARD: c_int = 3;
pub const git_reset_t = c_uint;
pub extern fn git_reset(repo: ?*git_repository, target: ?*const git_object, reset_type: git_reset_t, checkout_opts: [*c]const git_checkout_options) c_int;
pub extern fn git_reset_from_annotated(repo: ?*git_repository, commit: ?*const git_annotated_commit, reset_type: git_reset_t, checkout_opts: [*c]const git_checkout_options) c_int;
pub extern fn git_reset_default(repo: ?*git_repository, target: ?*const git_object, pathspecs: [*c]const git_strarray) c_int;
pub const GIT_SORT_NONE: c_int = 0;
pub const GIT_SORT_TOPOLOGICAL: c_int = 1;
pub const GIT_SORT_TIME: c_int = 2;
pub const GIT_SORT_REVERSE: c_int = 4;
pub const git_sort_t = c_uint;
pub extern fn git_revwalk_new(out: [*c]?*git_revwalk, repo: ?*git_repository) c_int;
pub extern fn git_revwalk_reset(walker: ?*git_revwalk) c_int;
pub extern fn git_revwalk_push(walk: ?*git_revwalk, id: [*c]const git_oid) c_int;
pub extern fn git_revwalk_push_glob(walk: ?*git_revwalk, glob: [*c]const u8) c_int;
pub extern fn git_revwalk_push_head(walk: ?*git_revwalk) c_int;
pub extern fn git_revwalk_hide(walk: ?*git_revwalk, commit_id: [*c]const git_oid) c_int;
pub extern fn git_revwalk_hide_glob(walk: ?*git_revwalk, glob: [*c]const u8) c_int;
pub extern fn git_revwalk_hide_head(walk: ?*git_revwalk) c_int;
pub extern fn git_revwalk_push_ref(walk: ?*git_revwalk, refname: [*c]const u8) c_int;
pub extern fn git_revwalk_hide_ref(walk: ?*git_revwalk, refname: [*c]const u8) c_int;
pub extern fn git_revwalk_next(out: [*c]git_oid, walk: ?*git_revwalk) c_int;
pub extern fn git_revwalk_sorting(walk: ?*git_revwalk, sort_mode: c_uint) c_int;
pub extern fn git_revwalk_push_range(walk: ?*git_revwalk, range: [*c]const u8) c_int;
pub extern fn git_revwalk_simplify_first_parent(walk: ?*git_revwalk) c_int;
pub extern fn git_revwalk_free(walk: ?*git_revwalk) void;
pub extern fn git_revwalk_repository(walk: ?*git_revwalk) ?*git_repository;
pub const git_revwalk_hide_cb = ?fn ([*c]const git_oid, ?*c_void) callconv(.C) c_int;
pub extern fn git_revwalk_add_hide_cb(walk: ?*git_revwalk, hide_cb: git_revwalk_hide_cb, payload: ?*c_void) c_int;
pub extern fn git_signature_new(out: [*c][*c]git_signature, name: [*c]const u8, email: [*c]const u8, time: git_time_t, offset: c_int) c_int;
pub extern fn git_signature_now(out: [*c][*c]git_signature, name: [*c]const u8, email: [*c]const u8) c_int;
pub extern fn git_signature_default(out: [*c][*c]git_signature, repo: ?*git_repository) c_int;
pub extern fn git_signature_from_buffer(out: [*c][*c]git_signature, buf: [*c]const u8) c_int;
pub extern fn git_signature_dup(dest: [*c][*c]git_signature, sig: [*c]const git_signature) c_int;
pub extern fn git_signature_free(sig: [*c]git_signature) void;
pub extern fn git_tag_lookup(out: [*c]?*git_tag, repo: ?*git_repository, id: [*c]const git_oid) c_int;
pub extern fn git_tag_lookup_prefix(out: [*c]?*git_tag, repo: ?*git_repository, id: [*c]const git_oid, len: usize) c_int;
pub extern fn git_tag_free(tag: ?*git_tag) void;
pub extern fn git_tag_id(tag: ?*const git_tag) [*c]const git_oid;
pub extern fn git_tag_owner(tag: ?*const git_tag) ?*git_repository;
pub extern fn git_tag_target(target_out: [*c]?*git_object, tag: ?*const git_tag) c_int;
pub extern fn git_tag_target_id(tag: ?*const git_tag) [*c]const git_oid;
pub extern fn git_tag_target_type(tag: ?*const git_tag) git_object_t;
pub extern fn git_tag_name(tag: ?*const git_tag) [*c]const u8;
pub extern fn git_tag_tagger(tag: ?*const git_tag) [*c]const git_signature;
pub extern fn git_tag_message(tag: ?*const git_tag) [*c]const u8;
pub extern fn git_tag_create(oid: [*c]git_oid, repo: ?*git_repository, tag_name: [*c]const u8, target: ?*const git_object, tagger: [*c]const git_signature, message: [*c]const u8, force: c_int) c_int;
pub extern fn git_tag_annotation_create(oid: [*c]git_oid, repo: ?*git_repository, tag_name: [*c]const u8, target: ?*const git_object, tagger: [*c]const git_signature, message: [*c]const u8) c_int;
pub extern fn git_tag_create_from_buffer(oid: [*c]git_oid, repo: ?*git_repository, buffer: [*c]const u8, force: c_int) c_int;
pub extern fn git_tag_create_lightweight(oid: [*c]git_oid, repo: ?*git_repository, tag_name: [*c]const u8, target: ?*const git_object, force: c_int) c_int;
pub extern fn git_tag_delete(repo: ?*git_repository, tag_name: [*c]const u8) c_int;
pub extern fn git_tag_list(tag_names: [*c]git_strarray, repo: ?*git_repository) c_int;
pub extern fn git_tag_list_match(tag_names: [*c]git_strarray, pattern: [*c]const u8, repo: ?*git_repository) c_int;
pub const git_tag_foreach_cb = ?fn ([*c]const u8, [*c]git_oid, ?*c_void) callconv(.C) c_int;
pub extern fn git_tag_foreach(repo: ?*git_repository, callback: git_tag_foreach_cb, payload: ?*c_void) c_int;
pub extern fn git_tag_peel(tag_target_out: [*c]?*git_object, tag: ?*const git_tag) c_int;
pub extern fn git_tag_dup(out: [*c]?*git_tag, source: ?*git_tag) c_int;
pub extern fn git_tag_name_is_valid(valid: [*c]c_int, name: [*c]const u8) c_int;
pub extern fn git_transaction_new(out: [*c]?*git_transaction, repo: ?*git_repository) c_int;
pub extern fn git_transaction_lock_ref(tx: ?*git_transaction, refname: [*c]const u8) c_int;
pub extern fn git_transaction_set_target(tx: ?*git_transaction, refname: [*c]const u8, target: [*c]const git_oid, sig: [*c]const git_signature, msg: [*c]const u8) c_int;
pub extern fn git_transaction_set_symbolic_target(tx: ?*git_transaction, refname: [*c]const u8, target: [*c]const u8, sig: [*c]const git_signature, msg: [*c]const u8) c_int;
pub extern fn git_transaction_set_reflog(tx: ?*git_transaction, refname: [*c]const u8, reflog: ?*const git_reflog) c_int;
pub extern fn git_transaction_remove(tx: ?*git_transaction, refname: [*c]const u8) c_int;
pub extern fn git_transaction_commit(tx: ?*git_transaction) c_int;
pub extern fn git_transaction_free(tx: ?*git_transaction) void;
pub const __GLIBC_USE = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/features.h:179:9
pub const __NTH = @compileError("unable to translate C expr: unexpected token .Identifier"); // /usr/include/sys/cdefs.h:57:11
pub const __NTHNL = @compileError("unable to translate C expr: unexpected token .Identifier"); // /usr/include/sys/cdefs.h:58:11
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/sys/cdefs.h:109:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token .Hash"); // /usr/include/sys/cdefs.h:110:9
pub const __warnattr = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:144:10
pub const __errordecl = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // /usr/include/sys/cdefs.h:145:10
pub const __flexarr = @compileError("unable to translate C expr: unexpected token .LBracket"); // /usr/include/sys/cdefs.h:153:10
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token .Hash"); // /usr/include/sys/cdefs.h:184:10
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token .Hash"); // /usr/include/sys/cdefs.h:191:11
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token .Hash"); // /usr/include/sys/cdefs.h:193:11
pub const __ASMNAME2 = @compileError("unable to translate C expr: unexpected token .Identifier"); // /usr/include/sys/cdefs.h:197:10
pub const __attribute_alloc_size__ = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:229:10
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // /usr/include/sys/cdefs.h:356:11
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // /usr/include/sys/cdefs.h:357:11
pub const __attribute_copy__ = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:451:10
pub const __LDBL_REDIR2_DECL = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:522:10
pub const __LDBL_REDIR_DECL = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:523:10
pub const __glibc_macro_warning1 = @compileError("unable to translate C expr: unexpected token .Hash"); // /usr/include/sys/cdefs.h:537:10
pub const __attr_access = @compileError("unable to translate C expr: unexpected token .Eof"); // /usr/include/sys/cdefs.h:569:11
pub const __STD_TYPE = @compileError("unable to translate C expr: unexpected token .Keyword_typedef"); // /usr/include/bits/types.h:137:10
pub const __FSID_T_TYPE = @compileError("unable to translate C expr: expected Identifier instead got: LBrace"); // /usr/include/bits/typesizes.h:73:9
pub const __f32 = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/bits/floatn-common.h:91:12
pub const __f64x = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/bits/floatn-common.h:120:13
pub const __CFLOAT32 = @compileError("unable to translate: TODO _Complex"); // /usr/include/bits/floatn-common.h:149:12
pub const __CFLOAT64 = @compileError("unable to translate: TODO _Complex"); // /usr/include/bits/floatn-common.h:160:13
pub const __CFLOAT32X = @compileError("unable to translate: TODO _Complex"); // /usr/include/bits/floatn-common.h:169:12
pub const __CFLOAT64X = @compileError("unable to translate: TODO _Complex"); // /usr/include/bits/floatn-common.h:178:13
pub const __builtin_nansf32 = @compileError("TODO implement function '__builtin_nansf' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:221:12
pub const __builtin_huge_valf64 = @compileError("TODO implement function '__builtin_huge_val' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:255:13
pub const __builtin_inff64 = @compileError("TODO implement function '__builtin_inf' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:256:13
pub const __builtin_nanf64 = @compileError("TODO implement function '__builtin_nan' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:257:13
pub const __builtin_nansf64 = @compileError("TODO implement function '__builtin_nans' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:258:13
pub const __builtin_huge_valf32x = @compileError("TODO implement function '__builtin_huge_val' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:272:12
pub const __builtin_inff32x = @compileError("TODO implement function '__builtin_inf' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:273:12
pub const __builtin_nanf32x = @compileError("TODO implement function '__builtin_nan' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:274:12
pub const __builtin_nansf32x = @compileError("TODO implement function '__builtin_nans' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:275:12
pub const __builtin_huge_valf64x = @compileError("TODO implement function '__builtin_huge_vall' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:289:13
pub const __builtin_inff64x = @compileError("TODO implement function '__builtin_infl' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:290:13
pub const __builtin_nanf64x = @compileError("TODO implement function '__builtin_nanl' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:291:13
pub const __builtin_nansf64x = @compileError("TODO implement function '__builtin_nansl' in std.zig.c_builtins"); // /usr/include/bits/floatn-common.h:292:13
pub const __FD_ZERO = @compileError("unable to translate C expr: unexpected token .Keyword_do"); // /usr/include/bits/select.h:25:9
pub const __FD_SET = @compileError("unable to translate C expr: expected ')' instead got: PipeEqual"); // /usr/include/bits/select.h:32:9
pub const __FD_CLR = @compileError("unable to translate C expr: expected ')' instead got: AmpersandEqual"); // /usr/include/bits/select.h:34:9
pub const __PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token .LBrace"); // /usr/include/bits/struct_mutex.h:56:10
pub const __PTHREAD_RWLOCK_ELISION_EXTRA = @compileError("unable to translate C expr: unexpected token .LBrace"); // /usr/include/bits/struct_rwlock.h:40:11
pub const __ONCE_FLAG_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // /usr/include/bits/thread-shared-types.h:127:9
pub const __INT64_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:106:11
pub const __UINT64_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:107:11
pub const INT64_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:252:11
pub const UINT32_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:260:10
pub const UINT64_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:262:11
pub const INTMAX_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:269:11
pub const UINTMAX_C = @compileError("unable to translate C expr: unexpected token .HashHash"); // /usr/include/stdint.h:270:11
pub const GIT_EXTERN = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // ./git2/common.h:39:10
pub const GIT_DEPRECATED = @compileError("unable to translate C expr: unexpected token .Identifier"); // ./git2/common.h:57:10
pub const GIT_BUF_INIT_CONST = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/buffer.h:66:9
pub const GIT_REPOSITORY_INIT_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/repository.h:357:9
pub const GIT_DIFF_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/diff.h:456:9
pub const GIT_DIFF_FIND_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/diff.h:790:9
pub const GIT_DIFF_FORMAT_EMAIL_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/diff.h:1420:9
pub const GIT_DIFF_PATCHID_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/diff.h:1484:9
pub const GIT_APPLY_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/apply.h:90:9
pub const GIT_ATTR_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/attr.h:158:9
pub const GIT_BLOB_FILTER_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/blob.h:146:9
pub const GIT_BLAME_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/blame.h:126:9
pub const GIT_CHECKOUT_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/checkout.h:339:9
pub const GIT_INDEXER_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/indexer.h:76:9
pub const GIT_INDEX_ENTRY_STAGE_SET = @compileError("unable to translate C expr: unexpected token .Keyword_do"); // ./git2/index.h:95:9
pub const GIT_MERGE_FILE_INPUT_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/merge.h:49:9
pub const GIT_MERGE_FILE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/merge.h:203:9
pub const GIT_MERGE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/merge.h:298:9
pub const GIT_CHERRYPICK_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/cherrypick.h:37:9
pub const GIT_PROXY_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/proxy.h:82:9
pub const GIT_REMOTE_CREATE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/remote.h:85:9
pub const GIT_REMOTE_CALLBACKS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/remote.h:592:9
pub const GIT_FETCH_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/remote.h:695:9
pub const GIT_PUSH_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/remote.h:746:9
pub const GIT_CLONE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/clone.h:167:9
pub const GIT_DESCRIBE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/describe.h:67:9
pub const GIT_DESCRIBE_FORMAT_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/describe.h:114:9
pub const GIT_FILTER_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/filter.h:77:10
pub const GIT_REBASE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/rebase.h:135:9
pub const GIT_REVERT_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/revert.h:37:9
pub const GIT_STASH_APPLY_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/stash.h:141:9
pub const GIT_STATUS_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/status.h:256:9
pub const GIT_SUBMODULE_UPDATE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/submodule.h:156:9
pub const GIT_WORKTREE_ADD_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/worktree.h:92:9
pub const GIT_WORKTREE_PRUNE_OPTIONS_INIT = @compileError("unable to translate C expr: unexpected token .LBrace"); // ./git2/worktree.h:206:9
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 12);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 1);
pub const __clang_version__ = "12.0.1 (git@github.com:ziglang/zig-bootstrap.git 39314a97a5d81d46a584397158d7ec8bbbef9214)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 12.0.1 (git@github.com:ziglang/zig-bootstrap.git 39314a97a5d81d46a584397158d7ec8bbbef9214)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __OPTIMIZE__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __INTMAX_C_SUFFIX__ = L;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_TYPE__ = c_int;
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_TYPE__ = c_uint;
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = L;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = U;
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = UL;
pub const __UINT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_FMTd__ = "ld";
pub const __INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_LEAST64_FMTo__ = "lo";
pub const __UINT_LEAST64_FMTu__ = "lu";
pub const __UINT_LEAST64_FMTx__ = "lx";
pub const __UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_FMTd__ = "ld";
pub const __INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_FAST64_FMTo__ = "lo";
pub const __UINT_FAST64_FMTu__ = "lu";
pub const __UINT_FAST64_FMTx__ = "lx";
pub const __UINT_FAST64_FMTX__ = "lX";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = @as(c_int, 2);
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = __attribute__(address_space(@as(c_int, 256)));
pub const __seg_fs = __attribute__(address_space(@as(c_int, 257)));
pub const __znver1 = @as(c_int, 1);
pub const __znver1__ = @as(c_int, 1);
pub const __tune_znver1__ = @as(c_int, 1);
pub const __NO_MATH_INLINES = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MWAITX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __SSE4A__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __CLZERO__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE2_MATH__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __gnu_linux__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const _DEBUG = @as(c_int, 1);
pub const _TIME_H = @as(c_int, 1);
pub const _FEATURES_H = @as(c_int, 1);
pub inline fn __GNUC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    return ((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub inline fn __glibc_clang_prereq(maj: anytype, min: anytype) @TypeOf(((__clang_major__ << @as(c_int, 16)) + __clang_minor__) >= ((maj << @as(c_int, 16)) + min)) {
    return ((__clang_major__ << @as(c_int, 16)) + __clang_minor__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _DEFAULT_SOURCE = @as(c_int, 1);
pub const __GLIBC_USE_ISOC2X = @as(c_int, 0);
pub const __USE_ISOC11 = @as(c_int, 1);
pub const __USE_ISOC99 = @as(c_int, 1);
pub const __USE_ISOC95 = @as(c_int, 1);
pub const __USE_POSIX_IMPLICITLY = @as(c_int, 1);
pub const _POSIX_SOURCE = @as(c_int, 1);
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __USE_POSIX = @as(c_int, 1);
pub const __USE_POSIX2 = @as(c_int, 1);
pub const __USE_POSIX199309 = @as(c_int, 1);
pub const __USE_POSIX199506 = @as(c_int, 1);
pub const __USE_XOPEN2K = @as(c_int, 1);
pub const __USE_XOPEN2K8 = @as(c_int, 1);
pub const _ATFILE_SOURCE = @as(c_int, 1);
pub const __USE_MISC = @as(c_int, 1);
pub const __USE_ATFILE = @as(c_int, 1);
pub const __USE_FORTIFY_LEVEL = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_GETS = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_SCANF = @as(c_int, 0);
pub const _STDC_PREDEF_H = @as(c_int, 1);
pub const __STDC_IEC_559__ = @as(c_int, 1);
pub const __STDC_IEC_559_COMPLEX__ = @as(c_int, 1);
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __GNU_LIBRARY__ = @as(c_int, 6);
pub const __GLIBC__ = @as(c_int, 2);
pub const __GLIBC_MINOR__ = @as(c_int, 33);
pub inline fn __GLIBC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    return ((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _SYS_CDEFS_H = @as(c_int, 1);
pub const __THROW = __attribute__(__nothrow__ ++ __LEAF);
pub const __THROWNL = __attribute__(__nothrow__);
pub inline fn __glibc_clang_has_extension(ext: anytype) @TypeOf(__has_extension(ext)) {
    return __has_extension(ext);
}
pub inline fn __P(args: anytype) @TypeOf(args) {
    return args;
}
pub inline fn __PMT(args: anytype) @TypeOf(args) {
    return args;
}
pub const __ptr_t = ?*c_void;
pub inline fn __bos(ptr: anytype) @TypeOf(__builtin_object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1))) {
    return __builtin_object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1));
}
pub inline fn __bos0(ptr: anytype) @TypeOf(__builtin_object_size(ptr, @as(c_int, 0))) {
    return __builtin_object_size(ptr, @as(c_int, 0));
}
pub inline fn __glibc_objsize0(__o: anytype) @TypeOf(__bos0(__o)) {
    return __bos0(__o);
}
pub inline fn __glibc_objsize(__o: anytype) @TypeOf(__bos(__o)) {
    return __bos(__o);
}
pub const __glibc_c99_flexarr_available = @as(c_int, 1);
pub inline fn __ASMNAME(cname: anytype) @TypeOf(__ASMNAME2(__USER_LABEL_PREFIX__, cname)) {
    return __ASMNAME2(__USER_LABEL_PREFIX__, cname);
}
pub const __attribute_malloc__ = __attribute__(__malloc__);
pub const __attribute_pure__ = __attribute__(__pure__);
pub const __attribute_const__ = __attribute__(__const__);
pub const __attribute_used__ = __attribute__(__used__);
pub const __attribute_noinline__ = __attribute__(__noinline__);
pub const __attribute_deprecated__ = __attribute__(__deprecated__);
pub inline fn __attribute_deprecated_msg__(msg: anytype) @TypeOf(__attribute__(__deprecated__(msg))) {
    return __attribute__(__deprecated__(msg));
}
pub inline fn __attribute_format_arg__(x: anytype) @TypeOf(__attribute__(__format_arg__(x))) {
    return __attribute__(__format_arg__(x));
}
pub inline fn __attribute_format_strfmon__(a: anytype, b: anytype) @TypeOf(__attribute__(__format__(__strfmon__, a, b))) {
    return __attribute__(__format__(__strfmon__, a, b));
}
pub inline fn __nonnull(params: anytype) @TypeOf(__attribute__(__nonnull__ ++ params)) {
    return __attribute__(__nonnull__ ++ params);
}
pub const __attribute_warn_unused_result__ = __attribute__(__warn_unused_result__);
pub const __always_inline = __inline ++ __attribute__(__always_inline__);
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub const __restrict_arr = __restrict;
pub inline fn __glibc_unlikely(cond: anytype) @TypeOf(__builtin_expect(cond, @as(c_int, 0))) {
    return __builtin_expect(cond, @as(c_int, 0));
}
pub inline fn __glibc_likely(cond: anytype) @TypeOf(__builtin_expect(cond, @as(c_int, 1))) {
    return __builtin_expect(cond, @as(c_int, 1));
}
pub inline fn __glibc_has_attribute(attr: anytype) @TypeOf(__has_attribute(attr)) {
    return __has_attribute(attr);
}
pub const __WORDSIZE = @as(c_int, 64);
pub const __WORDSIZE_TIME64_COMPAT32 = @as(c_int, 1);
pub const __SYSCALL_WORDSIZE = @as(c_int, 64);
pub const __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = @as(c_int, 0);
pub inline fn __LDBL_REDIR1(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto) {
    _ = alias;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR(name: anytype, proto: anytype) @TypeOf(name ++ proto) {
    return name ++ proto;
}
pub inline fn __LDBL_REDIR1_NTH(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = alias;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR_NTH(name: anytype, proto: anytype) @TypeOf(name ++ proto ++ __THROW) {
    return name ++ proto ++ __THROW;
}
pub inline fn __REDIRECT_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT(name, proto, alias)) {
    return __REDIRECT(name, proto, alias);
}
pub inline fn __REDIRECT_NTH_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    return __REDIRECT_NTH(name, proto, alias);
}
pub inline fn __glibc_macro_warning(message: anytype) @TypeOf(__glibc_macro_warning1(GCC ++ warning ++ message)) {
    return __glibc_macro_warning1(GCC ++ warning ++ message);
}
pub const __HAVE_GENERIC_SELECTION = @as(c_int, 1);
pub const __attribute_returns_twice__ = __attribute__(__returns_twice__);
pub const __USE_EXTERN_INLINES = @as(c_int, 1);
pub const NULL = @import("std").zig.c_translation.cast(?*c_void, @as(c_int, 0));
pub const _BITS_TIME_H = @as(c_int, 1);
pub const _BITS_TYPES_H = @as(c_int, 1);
pub const __TIMESIZE = __WORDSIZE;
pub const __S16_TYPE = c_short;
pub const __U16_TYPE = c_ushort;
pub const __S32_TYPE = c_int;
pub const __U32_TYPE = c_uint;
pub const __SLONGWORD_TYPE = c_long;
pub const __ULONGWORD_TYPE = c_ulong;
pub const __SQUAD_TYPE = c_long;
pub const __UQUAD_TYPE = c_ulong;
pub const __SWORD_TYPE = c_long;
pub const __UWORD_TYPE = c_ulong;
pub const __SLONG32_TYPE = c_int;
pub const __ULONG32_TYPE = c_uint;
pub const __S64_TYPE = c_long;
pub const __U64_TYPE = c_ulong;
pub const _BITS_TYPESIZES_H = @as(c_int, 1);
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SUSECONDS64_T_TYPE = __SQUAD_TYPE;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __TIMER_T_TYPE = ?*c_void;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __OFF_T_MATCHES_OFF64_T = @as(c_int, 1);
pub const __INO_T_MATCHES_INO64_T = @as(c_int, 1);
pub const __RLIM_T_MATCHES_RLIM64_T = @as(c_int, 1);
pub const __STATFS_MATCHES_STATFS64 = @as(c_int, 1);
pub const __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = @as(c_int, 1);
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _BITS_TIME64_H = @as(c_int, 1);
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const CLOCKS_PER_SEC = @import("std").zig.c_translation.cast(__clock_t, @import("std").zig.c_translation.promoteIntLiteral(c_int, 1000000, .decimal));
pub const CLOCK_REALTIME = @as(c_int, 0);
pub const CLOCK_MONOTONIC = @as(c_int, 1);
pub const CLOCK_PROCESS_CPUTIME_ID = @as(c_int, 2);
pub const CLOCK_THREAD_CPUTIME_ID = @as(c_int, 3);
pub const CLOCK_MONOTONIC_RAW = @as(c_int, 4);
pub const CLOCK_REALTIME_COARSE = @as(c_int, 5);
pub const CLOCK_MONOTONIC_COARSE = @as(c_int, 6);
pub const CLOCK_BOOTTIME = @as(c_int, 7);
pub const CLOCK_REALTIME_ALARM = @as(c_int, 8);
pub const CLOCK_BOOTTIME_ALARM = @as(c_int, 9);
pub const CLOCK_TAI = @as(c_int, 11);
pub const TIMER_ABSTIME = @as(c_int, 1);
pub const __clock_t_defined = @as(c_int, 1);
pub const __time_t_defined = @as(c_int, 1);
pub const __struct_tm_defined = @as(c_int, 1);
pub const _STRUCT_TIMESPEC = @as(c_int, 1);
pub const _BITS_ENDIAN_H = @as(c_int, 1);
pub const __LITTLE_ENDIAN = @as(c_int, 1234);
pub const __BIG_ENDIAN = @as(c_int, 4321);
pub const __PDP_ENDIAN = @as(c_int, 3412);
pub const _BITS_ENDIANNESS_H = @as(c_int, 1);
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub inline fn __LONG_LONG_PAIR(HI: anytype, LO: anytype) @TypeOf(HI) {
    return blk: {
        _ = LO;
        break :blk HI;
    };
}
pub const __clockid_t_defined = @as(c_int, 1);
pub const __timer_t_defined = @as(c_int, 1);
pub const __itimerspec_defined = @as(c_int, 1);
pub const _BITS_TYPES_LOCALE_T_H = @as(c_int, 1);
pub const _BITS_TYPES___LOCALE_T_H = @as(c_int, 1);
pub const TIME_UTC = @as(c_int, 1);
pub inline fn __isleap(year: anytype) @TypeOf(((year % @as(c_int, 4)) == @as(c_int, 0)) and (((year % @as(c_int, 100)) != @as(c_int, 0)) or ((year % @as(c_int, 400)) == @as(c_int, 0)))) {
    return ((year % @as(c_int, 4)) == @as(c_int, 0)) and (((year % @as(c_int, 100)) != @as(c_int, 0)) or ((year % @as(c_int, 400)) == @as(c_int, 0)));
}
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C2X = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C2X = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const _STDLIB_H = @as(c_int, 1);
pub const WNOHANG = @as(c_int, 1);
pub const WUNTRACED = @as(c_int, 2);
pub const WSTOPPED = @as(c_int, 2);
pub const WEXITED = @as(c_int, 4);
pub const WCONTINUED = @as(c_int, 8);
pub const WNOWAIT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x01000000, .hexadecimal);
pub const __WNOTHREAD = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x20000000, .hexadecimal);
pub const __WALL = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x40000000, .hexadecimal);
pub const __WCLONE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x80000000, .hexadecimal);
pub inline fn __WEXITSTATUS(status: anytype) @TypeOf((status & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xff00, .hexadecimal)) >> @as(c_int, 8)) {
    return (status & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xff00, .hexadecimal)) >> @as(c_int, 8);
}
pub inline fn __WTERMSIG(status: anytype) @TypeOf(status & @as(c_int, 0x7f)) {
    return status & @as(c_int, 0x7f);
}
pub inline fn __WSTOPSIG(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    return __WEXITSTATUS(status);
}
pub inline fn __WIFEXITED(status: anytype) @TypeOf(__WTERMSIG(status) == @as(c_int, 0)) {
    return __WTERMSIG(status) == @as(c_int, 0);
}
pub inline fn __WIFSIGNALED(status: anytype) @TypeOf((@import("std").zig.c_translation.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0)) {
    return (@import("std").zig.c_translation.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0);
}
pub inline fn __WIFSTOPPED(status: anytype) @TypeOf((status & @as(c_int, 0xff)) == @as(c_int, 0x7f)) {
    return (status & @as(c_int, 0xff)) == @as(c_int, 0x7f);
}
pub inline fn __WIFCONTINUED(status: anytype) @TypeOf(status == __W_CONTINUED) {
    return status == __W_CONTINUED;
}
pub inline fn __WCOREDUMP(status: anytype) @TypeOf(status & __WCOREFLAG) {
    return status & __WCOREFLAG;
}
pub inline fn __W_EXITCODE(ret: anytype, sig: anytype) @TypeOf((ret << @as(c_int, 8)) | sig) {
    return (ret << @as(c_int, 8)) | sig;
}
pub inline fn __W_STOPCODE(sig: anytype) @TypeOf((sig << @as(c_int, 8)) | @as(c_int, 0x7f)) {
    return (sig << @as(c_int, 8)) | @as(c_int, 0x7f);
}
pub const __W_CONTINUED = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffff, .hexadecimal);
pub const __WCOREFLAG = @as(c_int, 0x80);
pub inline fn WEXITSTATUS(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    return __WEXITSTATUS(status);
}
pub inline fn WTERMSIG(status: anytype) @TypeOf(__WTERMSIG(status)) {
    return __WTERMSIG(status);
}
pub inline fn WSTOPSIG(status: anytype) @TypeOf(__WSTOPSIG(status)) {
    return __WSTOPSIG(status);
}
pub inline fn WIFEXITED(status: anytype) @TypeOf(__WIFEXITED(status)) {
    return __WIFEXITED(status);
}
pub inline fn WIFSIGNALED(status: anytype) @TypeOf(__WIFSIGNALED(status)) {
    return __WIFSIGNALED(status);
}
pub inline fn WIFSTOPPED(status: anytype) @TypeOf(__WIFSTOPPED(status)) {
    return __WIFSTOPPED(status);
}
pub inline fn WIFCONTINUED(status: anytype) @TypeOf(__WIFCONTINUED(status)) {
    return __WIFCONTINUED(status);
}
pub const __HAVE_FLOAT128 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT128 = @as(c_int, 0);
pub const __HAVE_FLOAT64X = @as(c_int, 1);
pub const __HAVE_FLOAT64X_LONG_DOUBLE = @as(c_int, 1);
pub const __HAVE_FLOAT16 = @as(c_int, 0);
pub const __HAVE_FLOAT32 = @as(c_int, 1);
pub const __HAVE_FLOAT64 = @as(c_int, 1);
pub const __HAVE_FLOAT32X = @as(c_int, 1);
pub const __HAVE_FLOAT128X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT16 = __HAVE_FLOAT16;
pub const __HAVE_DISTINCT_FLOAT32 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT32X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT128X = __HAVE_FLOAT128X;
pub const __HAVE_FLOAT128_UNLIKE_LDBL = (__HAVE_DISTINCT_FLOAT128 != 0) and (__LDBL_MANT_DIG__ != @as(c_int, 113));
pub const __HAVE_FLOATN_NOT_TYPEDEF = @as(c_int, 0);
pub inline fn __f64(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __f32x(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __builtin_huge_valf32() @TypeOf(__builtin_huge_valf()) {
    return __builtin_huge_valf();
}
pub inline fn __builtin_inff32() @TypeOf(__builtin_inff()) {
    return __builtin_inff();
}
pub inline fn __builtin_nanf32(x: anytype) @TypeOf(__builtin_nanf(x)) {
    return __builtin_nanf(x);
}
pub const __ldiv_t_defined = @as(c_int, 1);
pub const __lldiv_t_defined = @as(c_int, 1);
pub const RAND_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const EXIT_FAILURE = @as(c_int, 1);
pub const EXIT_SUCCESS = @as(c_int, 0);
pub const MB_CUR_MAX = __ctype_get_mb_cur_max();
pub const _SYS_TYPES_H = @as(c_int, 1);
pub const _BITS_STDINT_INTN_H = @as(c_int, 1);
pub const __BIT_TYPES_DEFINED__ = @as(c_int, 1);
pub const _ENDIAN_H = @as(c_int, 1);
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const _BITS_BYTESWAP_H = @as(c_int, 1);
pub inline fn __bswap_constant_16(x: anytype) __uint16_t {
    return @import("std").zig.c_translation.cast(__uint16_t, ((x >> @as(c_int, 8)) & @as(c_int, 0xff)) | ((x & @as(c_int, 0xff)) << @as(c_int, 8)));
}
pub inline fn __bswap_constant_32(x: anytype) @TypeOf(((((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff000000, .hexadecimal)) >> @as(c_int, 24)) | ((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff0000, .hexadecimal)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24))) {
    return ((((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff000000, .hexadecimal)) >> @as(c_int, 24)) | ((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff0000, .hexadecimal)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24));
}
pub inline fn __bswap_constant_64(x: anytype) @TypeOf(((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56))) {
    return ((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56));
}
pub const _BITS_UINTN_IDENTITY_H = @as(c_int, 1);
pub inline fn htobe16(x: anytype) @TypeOf(__bswap_16(x)) {
    return __bswap_16(x);
}
pub inline fn htole16(x: anytype) @TypeOf(__uint16_identity(x)) {
    return __uint16_identity(x);
}
pub inline fn be16toh(x: anytype) @TypeOf(__bswap_16(x)) {
    return __bswap_16(x);
}
pub inline fn le16toh(x: anytype) @TypeOf(__uint16_identity(x)) {
    return __uint16_identity(x);
}
pub inline fn htobe32(x: anytype) @TypeOf(__bswap_32(x)) {
    return __bswap_32(x);
}
pub inline fn htole32(x: anytype) @TypeOf(__uint32_identity(x)) {
    return __uint32_identity(x);
}
pub inline fn be32toh(x: anytype) @TypeOf(__bswap_32(x)) {
    return __bswap_32(x);
}
pub inline fn le32toh(x: anytype) @TypeOf(__uint32_identity(x)) {
    return __uint32_identity(x);
}
pub inline fn htobe64(x: anytype) @TypeOf(__bswap_64(x)) {
    return __bswap_64(x);
}
pub inline fn htole64(x: anytype) @TypeOf(__uint64_identity(x)) {
    return __uint64_identity(x);
}
pub inline fn be64toh(x: anytype) @TypeOf(__bswap_64(x)) {
    return __bswap_64(x);
}
pub inline fn le64toh(x: anytype) @TypeOf(__uint64_identity(x)) {
    return __uint64_identity(x);
}
pub const _SYS_SELECT_H = @as(c_int, 1);
pub inline fn __FD_ISSET(d: anytype, s: anytype) @TypeOf((__FDS_BITS(s)[__FD_ELT(d)] & __FD_MASK(d)) != @as(c_int, 0)) {
    return (__FDS_BITS(s)[__FD_ELT(d)] & __FD_MASK(d)) != @as(c_int, 0);
}
pub const __sigset_t_defined = @as(c_int, 1);
pub const _SIGSET_NWORDS = @as(c_int, 1024) / (@as(c_int, 8) * @import("std").zig.c_translation.sizeof(c_ulong));
pub const __timeval_defined = @as(c_int, 1);
pub const __NFDBITS = @as(c_int, 8) * @import("std").zig.c_translation.cast(c_int, @import("std").zig.c_translation.sizeof(__fd_mask));
pub inline fn __FD_ELT(d: anytype) @TypeOf(d / __NFDBITS) {
    return d / __NFDBITS;
}
pub inline fn __FD_MASK(d: anytype) __fd_mask {
    return @import("std").zig.c_translation.cast(__fd_mask, @as(c_ulong, 1) << (d % __NFDBITS));
}
pub inline fn __FDS_BITS(set: anytype) @TypeOf(set.*.__fds_bits) {
    return set.*.__fds_bits;
}
pub const FD_SETSIZE = __FD_SETSIZE;
pub const NFDBITS = __NFDBITS;
pub inline fn FD_SET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_SET(fd, fdsetp)) {
    return __FD_SET(fd, fdsetp);
}
pub inline fn FD_CLR(fd: anytype, fdsetp: anytype) @TypeOf(__FD_CLR(fd, fdsetp)) {
    return __FD_CLR(fd, fdsetp);
}
pub inline fn FD_ISSET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_ISSET(fd, fdsetp)) {
    return __FD_ISSET(fd, fdsetp);
}
pub inline fn FD_ZERO(fdsetp: anytype) @TypeOf(__FD_ZERO(fdsetp)) {
    return __FD_ZERO(fdsetp);
}
pub const _BITS_PTHREADTYPES_COMMON_H = @as(c_int, 1);
pub const _THREAD_SHARED_TYPES_H = @as(c_int, 1);
pub const _BITS_PTHREADTYPES_ARCH_H = @as(c_int, 1);
pub const __SIZEOF_PTHREAD_MUTEX_T = @as(c_int, 40);
pub const __SIZEOF_PTHREAD_ATTR_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_RWLOCK_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_BARRIER_T = @as(c_int, 32);
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_COND_T = @as(c_int, 48);
pub const __SIZEOF_PTHREAD_CONDATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = @as(c_int, 8);
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = @as(c_int, 4);
pub const _THREAD_MUTEX_INTERNAL_H = @as(c_int, 1);
pub const __PTHREAD_MUTEX_HAVE_PREV = @as(c_int, 1);
pub inline fn __PTHREAD_RWLOCK_INITIALIZER(__flags: anytype) @TypeOf(__flags) {
    return blk: {
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = __PTHREAD_RWLOCK_ELISION_EXTRA;
        _ = @as(c_int, 0);
        break :blk __flags;
    };
}
pub const __have_pthread_attr_t = @as(c_int, 1);
pub const _ALLOCA_H = @as(c_int, 1);
pub const _INTTYPES_H = @as(c_int, 1);
pub const _STDINT_H = @as(c_int, 1);
pub const _BITS_WCHAR_H = @as(c_int, 1);
pub const __WCHAR_MAX = __WCHAR_MAX__;
pub const __WCHAR_MIN = -__WCHAR_MAX - @as(c_int, 1);
pub const _BITS_STDINT_UINTN_H = @as(c_int, 1);
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT64_MIN = -__INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = __INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT64_MAX = __UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_LEAST8_MIN = -@as(c_int, 128);
pub const INT_LEAST16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT_LEAST32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT_LEAST64_MIN = -__INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_LEAST8_MAX = @as(c_int, 127);
pub const INT_LEAST16_MAX = @as(c_int, 32767);
pub const INT_LEAST32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT_LEAST64_MAX = __INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_LEAST8_MAX = @as(c_int, 255);
pub const UINT_LEAST16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST64_MAX = __UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_FAST8_MIN = -@as(c_int, 128);
pub const INT_FAST16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST64_MIN = -__INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_FAST8_MAX = @as(c_int, 127);
pub const INT_FAST16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST64_MAX = __INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_FAST8_MAX = @as(c_int, 255);
pub const UINT_FAST16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_MAX = __UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INTPTR_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const UINTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const INTMAX_MIN = -__INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INTMAX_MAX = __INT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINTMAX_MAX = __UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const PTRDIFF_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const PTRDIFF_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const SIG_ATOMIC_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const SIG_ATOMIC_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const SIZE_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const WCHAR_MIN = __WCHAR_MIN;
pub const WCHAR_MAX = __WCHAR_MAX;
pub const WINT_MIN = @as(c_uint, 0);
pub const WINT_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub inline fn INT8_C(c: anytype) @TypeOf(c) {
    return c;
}
pub inline fn INT16_C(c: anytype) @TypeOf(c) {
    return c;
}
pub inline fn INT32_C(c: anytype) @TypeOf(c) {
    return c;
}
pub inline fn UINT8_C(c: anytype) @TypeOf(c) {
    return c;
}
pub inline fn UINT16_C(c: anytype) @TypeOf(c) {
    return c;
}
pub const ____gwchar_t_defined = @as(c_int, 1);
pub const __PRI64_PREFIX = "l";
pub const __PRIPTR_PREFIX = "l";
pub const PRId8 = "d";
pub const PRId16 = "d";
pub const PRId32 = "d";
pub const PRId64 = __PRI64_PREFIX ++ "d";
pub const PRIdLEAST8 = "d";
pub const PRIdLEAST16 = "d";
pub const PRIdLEAST32 = "d";
pub const PRIdLEAST64 = __PRI64_PREFIX ++ "d";
pub const PRIdFAST8 = "d";
pub const PRIdFAST16 = __PRIPTR_PREFIX ++ "d";
pub const PRIdFAST32 = __PRIPTR_PREFIX ++ "d";
pub const PRIdFAST64 = __PRI64_PREFIX ++ "d";
pub const PRIi8 = "i";
pub const PRIi16 = "i";
pub const PRIi32 = "i";
pub const PRIi64 = __PRI64_PREFIX ++ "i";
pub const PRIiLEAST8 = "i";
pub const PRIiLEAST16 = "i";
pub const PRIiLEAST32 = "i";
pub const PRIiLEAST64 = __PRI64_PREFIX ++ "i";
pub const PRIiFAST8 = "i";
pub const PRIiFAST16 = __PRIPTR_PREFIX ++ "i";
pub const PRIiFAST32 = __PRIPTR_PREFIX ++ "i";
pub const PRIiFAST64 = __PRI64_PREFIX ++ "i";
pub const PRIo8 = "o";
pub const PRIo16 = "o";
pub const PRIo32 = "o";
pub const PRIo64 = __PRI64_PREFIX ++ "o";
pub const PRIoLEAST8 = "o";
pub const PRIoLEAST16 = "o";
pub const PRIoLEAST32 = "o";
pub const PRIoLEAST64 = __PRI64_PREFIX ++ "o";
pub const PRIoFAST8 = "o";
pub const PRIoFAST16 = __PRIPTR_PREFIX ++ "o";
pub const PRIoFAST32 = __PRIPTR_PREFIX ++ "o";
pub const PRIoFAST64 = __PRI64_PREFIX ++ "o";
pub const PRIu8 = "u";
pub const PRIu16 = "u";
pub const PRIu32 = "u";
pub const PRIu64 = __PRI64_PREFIX ++ "u";
pub const PRIuLEAST8 = "u";
pub const PRIuLEAST16 = "u";
pub const PRIuLEAST32 = "u";
pub const PRIuLEAST64 = __PRI64_PREFIX ++ "u";
pub const PRIuFAST8 = "u";
pub const PRIuFAST16 = __PRIPTR_PREFIX ++ "u";
pub const PRIuFAST32 = __PRIPTR_PREFIX ++ "u";
pub const PRIuFAST64 = __PRI64_PREFIX ++ "u";
pub const PRIx8 = "x";
pub const PRIx16 = "x";
pub const PRIx32 = "x";
pub const PRIx64 = __PRI64_PREFIX ++ "x";
pub const PRIxLEAST8 = "x";
pub const PRIxLEAST16 = "x";
pub const PRIxLEAST32 = "x";
pub const PRIxLEAST64 = __PRI64_PREFIX ++ "x";
pub const PRIxFAST8 = "x";
pub const PRIxFAST16 = __PRIPTR_PREFIX ++ "x";
pub const PRIxFAST32 = __PRIPTR_PREFIX ++ "x";
pub const PRIxFAST64 = __PRI64_PREFIX ++ "x";
pub const PRIX8 = "X";
pub const PRIX16 = "X";
pub const PRIX32 = "X";
pub const PRIX64 = __PRI64_PREFIX ++ "X";
pub const PRIXLEAST8 = "X";
pub const PRIXLEAST16 = "X";
pub const PRIXLEAST32 = "X";
pub const PRIXLEAST64 = __PRI64_PREFIX ++ "X";
pub const PRIXFAST8 = "X";
pub const PRIXFAST16 = __PRIPTR_PREFIX ++ "X";
pub const PRIXFAST32 = __PRIPTR_PREFIX ++ "X";
pub const PRIXFAST64 = __PRI64_PREFIX ++ "X";
pub const PRIdMAX = __PRI64_PREFIX ++ "d";
pub const PRIiMAX = __PRI64_PREFIX ++ "i";
pub const PRIoMAX = __PRI64_PREFIX ++ "o";
pub const PRIuMAX = __PRI64_PREFIX ++ "u";
pub const PRIxMAX = __PRI64_PREFIX ++ "x";
pub const PRIXMAX = __PRI64_PREFIX ++ "X";
pub const PRIdPTR = __PRIPTR_PREFIX ++ "d";
pub const PRIiPTR = __PRIPTR_PREFIX ++ "i";
pub const PRIoPTR = __PRIPTR_PREFIX ++ "o";
pub const PRIuPTR = __PRIPTR_PREFIX ++ "u";
pub const PRIxPTR = __PRIPTR_PREFIX ++ "x";
pub const PRIXPTR = __PRIPTR_PREFIX ++ "X";
pub const SCNd8 = "hhd";
pub const SCNd16 = "hd";
pub const SCNd32 = "d";
pub const SCNd64 = __PRI64_PREFIX ++ "d";
pub const SCNdLEAST8 = "hhd";
pub const SCNdLEAST16 = "hd";
pub const SCNdLEAST32 = "d";
pub const SCNdLEAST64 = __PRI64_PREFIX ++ "d";
pub const SCNdFAST8 = "hhd";
pub const SCNdFAST16 = __PRIPTR_PREFIX ++ "d";
pub const SCNdFAST32 = __PRIPTR_PREFIX ++ "d";
pub const SCNdFAST64 = __PRI64_PREFIX ++ "d";
pub const SCNi8 = "hhi";
pub const SCNi16 = "hi";
pub const SCNi32 = "i";
pub const SCNi64 = __PRI64_PREFIX ++ "i";
pub const SCNiLEAST8 = "hhi";
pub const SCNiLEAST16 = "hi";
pub const SCNiLEAST32 = "i";
pub const SCNiLEAST64 = __PRI64_PREFIX ++ "i";
pub const SCNiFAST8 = "hhi";
pub const SCNiFAST16 = __PRIPTR_PREFIX ++ "i";
pub const SCNiFAST32 = __PRIPTR_PREFIX ++ "i";
pub const SCNiFAST64 = __PRI64_PREFIX ++ "i";
pub const SCNu8 = "hhu";
pub const SCNu16 = "hu";
pub const SCNu32 = "u";
pub const SCNu64 = __PRI64_PREFIX ++ "u";
pub const SCNuLEAST8 = "hhu";
pub const SCNuLEAST16 = "hu";
pub const SCNuLEAST32 = "u";
pub const SCNuLEAST64 = __PRI64_PREFIX ++ "u";
pub const SCNuFAST8 = "hhu";
pub const SCNuFAST16 = __PRIPTR_PREFIX ++ "u";
pub const SCNuFAST32 = __PRIPTR_PREFIX ++ "u";
pub const SCNuFAST64 = __PRI64_PREFIX ++ "u";
pub const SCNo8 = "hho";
pub const SCNo16 = "ho";
pub const SCNo32 = "o";
pub const SCNo64 = __PRI64_PREFIX ++ "o";
pub const SCNoLEAST8 = "hho";
pub const SCNoLEAST16 = "ho";
pub const SCNoLEAST32 = "o";
pub const SCNoLEAST64 = __PRI64_PREFIX ++ "o";
pub const SCNoFAST8 = "hho";
pub const SCNoFAST16 = __PRIPTR_PREFIX ++ "o";
pub const SCNoFAST32 = __PRIPTR_PREFIX ++ "o";
pub const SCNoFAST64 = __PRI64_PREFIX ++ "o";
pub const SCNx8 = "hhx";
pub const SCNx16 = "hx";
pub const SCNx32 = "x";
pub const SCNx64 = __PRI64_PREFIX ++ "x";
pub const SCNxLEAST8 = "hhx";
pub const SCNxLEAST16 = "hx";
pub const SCNxLEAST32 = "x";
pub const SCNxLEAST64 = __PRI64_PREFIX ++ "x";
pub const SCNxFAST8 = "hhx";
pub const SCNxFAST16 = __PRIPTR_PREFIX ++ "x";
pub const SCNxFAST32 = __PRIPTR_PREFIX ++ "x";
pub const SCNxFAST64 = __PRI64_PREFIX ++ "x";
pub const SCNdMAX = __PRI64_PREFIX ++ "d";
pub const SCNiMAX = __PRI64_PREFIX ++ "i";
pub const SCNoMAX = __PRI64_PREFIX ++ "o";
pub const SCNuMAX = __PRI64_PREFIX ++ "u";
pub const SCNxMAX = __PRI64_PREFIX ++ "x";
pub const SCNdPTR = __PRIPTR_PREFIX ++ "d";
pub const SCNiPTR = __PRIPTR_PREFIX ++ "i";
pub const SCNoPTR = __PRIPTR_PREFIX ++ "o";
pub const SCNuPTR = __PRIPTR_PREFIX ++ "u";
pub const SCNxPTR = __PRIPTR_PREFIX ++ "x";
pub inline fn GIT_CALLBACK(name: anytype) @TypeOf(name.*) {
    return name.*;
}
pub inline fn GIT_FORMAT_PRINTF(a: anytype, b: anytype) @TypeOf(__attribute__(format(printf, a, b))) {
    return __attribute__(format(printf, a, b));
}
pub const GIT_PATH_LIST_SEPARATOR = ':';
pub const GIT_PATH_MAX = @as(c_int, 4096);
pub const GIT_OID_HEX_ZERO = "0000000000000000000000000000000000000000";
pub const GIT_OID_RAWSZ = @as(c_int, 20);
pub const GIT_OID_HEXSZ = GIT_OID_RAWSZ * @as(c_int, 2);
pub const GIT_OID_MINPREFIXLEN = @as(c_int, 4);
pub const GIT_REPOSITORY_INIT_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_OBJECT_SIZE_MAX = UINT64_MAX;
pub const GIT_DIFF_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DIFF_HUNK_HEADER_SIZE = @as(c_int, 128);
pub const GIT_DIFF_FIND_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DIFF_FORMAT_EMAIL_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DIFF_PATCHID_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_APPLY_OPTIONS_VERSION = @as(c_int, 1);
pub inline fn GIT_ATTR_IS_TRUE(attr: anytype) @TypeOf(git_attr_value(attr) == GIT_ATTR_VALUE_TRUE) {
    return git_attr_value(attr) == GIT_ATTR_VALUE_TRUE;
}
pub inline fn GIT_ATTR_IS_FALSE(attr: anytype) @TypeOf(git_attr_value(attr) == GIT_ATTR_VALUE_FALSE) {
    return git_attr_value(attr) == GIT_ATTR_VALUE_FALSE;
}
pub inline fn GIT_ATTR_IS_UNSPECIFIED(attr: anytype) @TypeOf(git_attr_value(attr) == GIT_ATTR_VALUE_UNSPECIFIED) {
    return git_attr_value(attr) == GIT_ATTR_VALUE_UNSPECIFIED;
}
pub inline fn GIT_ATTR_HAS_VALUE(attr: anytype) @TypeOf(git_attr_value(attr) == GIT_ATTR_VALUE_STRING) {
    return git_attr_value(attr) == GIT_ATTR_VALUE_STRING;
}
pub const GIT_ATTR_CHECK_FILE_THEN_INDEX = @as(c_int, 0);
pub const GIT_ATTR_CHECK_INDEX_THEN_FILE = @as(c_int, 1);
pub const GIT_ATTR_CHECK_INDEX_ONLY = @as(c_int, 2);
pub const GIT_ATTR_CHECK_NO_SYSTEM = @as(c_int, 1) << @as(c_int, 2);
pub const GIT_ATTR_CHECK_INCLUDE_HEAD = @as(c_int, 1) << @as(c_int, 3);
pub const GIT_ATTR_CHECK_INCLUDE_COMMIT = @as(c_int, 1) << @as(c_int, 4);
pub const GIT_ATTR_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_BLOB_FILTER_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_BLAME_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_CHECKOUT_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_INDEXER_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_INDEX_ENTRY_NAMEMASK = @as(c_int, 0x0fff);
pub const GIT_INDEX_ENTRY_STAGEMASK = @as(c_int, 0x3000);
pub const GIT_INDEX_ENTRY_STAGESHIFT = @as(c_int, 12);
pub inline fn GIT_INDEX_ENTRY_STAGE(E: anytype) @TypeOf((E.*.flags & GIT_INDEX_ENTRY_STAGEMASK) >> GIT_INDEX_ENTRY_STAGESHIFT) {
    return (E.*.flags & GIT_INDEX_ENTRY_STAGEMASK) >> GIT_INDEX_ENTRY_STAGESHIFT;
}
pub const GIT_MERGE_FILE_INPUT_VERSION = @as(c_int, 1);
pub const GIT_MERGE_CONFLICT_MARKER_SIZE = @as(c_int, 7);
pub const GIT_MERGE_FILE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_MERGE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_CHERRYPICK_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DEFAULT_PORT = "9418";
pub const GIT_PROXY_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_REMOTE_CREATE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_REMOTE_CALLBACKS_VERSION = @as(c_int, 1);
pub const GIT_FETCH_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_PUSH_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_CLONE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DESCRIBE_DEFAULT_MAX_CANDIDATES_TAGS = @as(c_int, 10);
pub const GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE = @as(c_int, 7);
pub const GIT_DESCRIBE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_DESCRIBE_FORMAT_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_FILTER_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_REBASE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_REBASE_NO_OPERATION = SIZE_MAX;
pub const GIT_REVERT_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_STASH_APPLY_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_STATUS_OPT_DEFAULTS = (GIT_STATUS_OPT_INCLUDE_IGNORED | GIT_STATUS_OPT_INCLUDE_UNTRACKED) | GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS;
pub const GIT_STATUS_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_SUBMODULE_STATUS__IN_FLAGS = @as(c_uint, 0x000F);
pub const GIT_SUBMODULE_STATUS__INDEX_FLAGS = @as(c_uint, 0x0070);
pub const GIT_SUBMODULE_STATUS__WD_FLAGS = @as(c_uint, 0x3F80);
pub inline fn GIT_SUBMODULE_STATUS_IS_UNMODIFIED(S: anytype) @TypeOf((S & ~GIT_SUBMODULE_STATUS__IN_FLAGS) == @as(c_int, 0)) {
    return (S & ~GIT_SUBMODULE_STATUS__IN_FLAGS) == @as(c_int, 0);
}
pub inline fn GIT_SUBMODULE_STATUS_IS_INDEX_UNMODIFIED(S: anytype) @TypeOf((S & GIT_SUBMODULE_STATUS__INDEX_FLAGS) == @as(c_int, 0)) {
    return (S & GIT_SUBMODULE_STATUS__INDEX_FLAGS) == @as(c_int, 0);
}
pub inline fn GIT_SUBMODULE_STATUS_IS_WD_UNMODIFIED(S: anytype) @TypeOf((S & (GIT_SUBMODULE_STATUS__WD_FLAGS & ~GIT_SUBMODULE_STATUS_WD_UNINITIALIZED)) == @as(c_int, 0)) {
    return (S & (GIT_SUBMODULE_STATUS__WD_FLAGS & ~GIT_SUBMODULE_STATUS_WD_UNINITIALIZED)) == @as(c_int, 0);
}
pub inline fn GIT_SUBMODULE_STATUS_IS_WD_DIRTY(S: anytype) @TypeOf((S & ((GIT_SUBMODULE_STATUS_WD_INDEX_MODIFIED | GIT_SUBMODULE_STATUS_WD_WD_MODIFIED) | GIT_SUBMODULE_STATUS_WD_UNTRACKED)) != @as(c_int, 0)) {
    return (S & ((GIT_SUBMODULE_STATUS_WD_INDEX_MODIFIED | GIT_SUBMODULE_STATUS_WD_WD_MODIFIED) | GIT_SUBMODULE_STATUS_WD_UNTRACKED)) != @as(c_int, 0);
}
pub const GIT_SUBMODULE_UPDATE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_WORKTREE_ADD_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_WORKTREE_PRUNE_OPTIONS_VERSION = @as(c_int, 1);
pub const GIT_ATTR_UNSPECIFIED_T = GIT_ATTR_VALUE_UNSPECIFIED;
pub const GIT_ATTR_TRUE_T = GIT_ATTR_VALUE_TRUE;
pub const GIT_ATTR_FALSE_T = GIT_ATTR_VALUE_FALSE;
pub const GIT_ATTR_VALUE_T = GIT_ATTR_VALUE_STRING;
pub inline fn GIT_ATTR_TRUE(attr: anytype) @TypeOf(GIT_ATTR_IS_TRUE(attr)) {
    return GIT_ATTR_IS_TRUE(attr);
}
pub inline fn GIT_ATTR_FALSE(attr: anytype) @TypeOf(GIT_ATTR_IS_FALSE(attr)) {
    return GIT_ATTR_IS_FALSE(attr);
}
pub inline fn GIT_ATTR_UNSPECIFIED(attr: anytype) @TypeOf(GIT_ATTR_IS_UNSPECIFIED(attr)) {
    return GIT_ATTR_IS_UNSPECIFIED(attr);
}
pub const GIT_BLOB_FILTER_ATTTRIBUTES_FROM_HEAD = GIT_BLOB_FILTER_ATTRIBUTES_FROM_HEAD;
pub const GIT_CVAR_FALSE = GIT_CONFIGMAP_FALSE;
pub const GIT_CVAR_TRUE = GIT_CONFIGMAP_TRUE;
pub const GIT_CVAR_INT32 = GIT_CONFIGMAP_INT32;
pub const GIT_CVAR_STRING = GIT_CONFIGMAP_STRING;
pub const GITERR_NONE = GIT_ERROR_NONE;
pub const GITERR_NOMEMORY = GIT_ERROR_NOMEMORY;
pub const GITERR_OS = GIT_ERROR_OS;
pub const GITERR_INVALID = GIT_ERROR_INVALID;
pub const GITERR_REFERENCE = GIT_ERROR_REFERENCE;
pub const GITERR_ZLIB = GIT_ERROR_ZLIB;
pub const GITERR_REPOSITORY = GIT_ERROR_REPOSITORY;
pub const GITERR_CONFIG = GIT_ERROR_CONFIG;
pub const GITERR_REGEX = GIT_ERROR_REGEX;
pub const GITERR_ODB = GIT_ERROR_ODB;
pub const GITERR_INDEX = GIT_ERROR_INDEX;
pub const GITERR_OBJECT = GIT_ERROR_OBJECT;
pub const GITERR_NET = GIT_ERROR_NET;
pub const GITERR_TAG = GIT_ERROR_TAG;
pub const GITERR_TREE = GIT_ERROR_TREE;
pub const GITERR_INDEXER = GIT_ERROR_INDEXER;
pub const GITERR_SSL = GIT_ERROR_SSL;
pub const GITERR_SUBMODULE = GIT_ERROR_SUBMODULE;
pub const GITERR_THREAD = GIT_ERROR_THREAD;
pub const GITERR_STASH = GIT_ERROR_STASH;
pub const GITERR_CHECKOUT = GIT_ERROR_CHECKOUT;
pub const GITERR_FETCHHEAD = GIT_ERROR_FETCHHEAD;
pub const GITERR_MERGE = GIT_ERROR_MERGE;
pub const GITERR_SSH = GIT_ERROR_SSH;
pub const GITERR_FILTER = GIT_ERROR_FILTER;
pub const GITERR_REVERT = GIT_ERROR_REVERT;
pub const GITERR_CALLBACK = GIT_ERROR_CALLBACK;
pub const GITERR_CHERRYPICK = GIT_ERROR_CHERRYPICK;
pub const GITERR_DESCRIBE = GIT_ERROR_DESCRIBE;
pub const GITERR_REBASE = GIT_ERROR_REBASE;
pub const GITERR_FILESYSTEM = GIT_ERROR_FILESYSTEM;
pub const GITERR_PATCH = GIT_ERROR_PATCH;
pub const GITERR_WORKTREE = GIT_ERROR_WORKTREE;
pub const GITERR_SHA1 = GIT_ERROR_SHA1;
pub const GIT_IDXENTRY_NAMEMASK = GIT_INDEX_ENTRY_NAMEMASK;
pub const GIT_IDXENTRY_STAGEMASK = GIT_INDEX_ENTRY_STAGEMASK;
pub const GIT_IDXENTRY_STAGESHIFT = GIT_INDEX_ENTRY_STAGESHIFT;
pub const GIT_IDXENTRY_EXTENDED = GIT_INDEX_ENTRY_EXTENDED;
pub const GIT_IDXENTRY_VALID = GIT_INDEX_ENTRY_VALID;
pub inline fn GIT_IDXENTRY_STAGE(E: anytype) @TypeOf(GIT_INDEX_ENTRY_STAGE(E)) {
    return GIT_INDEX_ENTRY_STAGE(E);
}
pub inline fn GIT_IDXENTRY_STAGE_SET(E: anytype, S: anytype) @TypeOf(GIT_INDEX_ENTRY_STAGE_SET(E, S)) {
    return GIT_INDEX_ENTRY_STAGE_SET(E, S);
}
pub const GIT_IDXENTRY_INTENT_TO_ADD = GIT_INDEX_ENTRY_INTENT_TO_ADD;
pub const GIT_IDXENTRY_SKIP_WORKTREE = GIT_INDEX_ENTRY_SKIP_WORKTREE;
pub const GIT_IDXENTRY_EXTENDED_FLAGS = GIT_INDEX_ENTRY_INTENT_TO_ADD | GIT_INDEX_ENTRY_SKIP_WORKTREE;
pub const GIT_IDXENTRY_EXTENDED2 = @as(c_int, 1) << @as(c_int, 15);
pub const GIT_IDXENTRY_UPDATE = @as(c_int, 1) << @as(c_int, 0);
pub const GIT_IDXENTRY_REMOVE = @as(c_int, 1) << @as(c_int, 1);
pub const GIT_IDXENTRY_UPTODATE = @as(c_int, 1) << @as(c_int, 2);
pub const GIT_IDXENTRY_ADDED = @as(c_int, 1) << @as(c_int, 3);
pub const GIT_IDXENTRY_HASHED = @as(c_int, 1) << @as(c_int, 4);
pub const GIT_IDXENTRY_UNHASHED = @as(c_int, 1) << @as(c_int, 5);
pub const GIT_IDXENTRY_WT_REMOVE = @as(c_int, 1) << @as(c_int, 6);
pub const GIT_IDXENTRY_CONFLICTED = @as(c_int, 1) << @as(c_int, 7);
pub const GIT_IDXENTRY_UNPACKED = @as(c_int, 1) << @as(c_int, 8);
pub const GIT_IDXENTRY_NEW_SKIP_WORKTREE = @as(c_int, 1) << @as(c_int, 9);
pub const GIT_INDEXCAP_IGNORE_CASE = GIT_INDEX_CAPABILITY_IGNORE_CASE;
pub const GIT_INDEXCAP_NO_FILEMODE = GIT_INDEX_CAPABILITY_NO_FILEMODE;
pub const GIT_INDEXCAP_NO_SYMLINKS = GIT_INDEX_CAPABILITY_NO_SYMLINKS;
pub const GIT_INDEXCAP_FROM_OWNER = GIT_INDEX_CAPABILITY_FROM_OWNER;
pub const git_otype = git_object_t;
pub const GIT_OBJ_ANY = GIT_OBJECT_ANY;
pub const GIT_OBJ_BAD = GIT_OBJECT_INVALID;
pub const GIT_OBJ__EXT1 = @as(c_int, 0);
pub const GIT_OBJ_COMMIT = GIT_OBJECT_COMMIT;
pub const GIT_OBJ_TREE = GIT_OBJECT_TREE;
pub const GIT_OBJ_BLOB = GIT_OBJECT_BLOB;
pub const GIT_OBJ_TAG = GIT_OBJECT_TAG;
pub const GIT_OBJ__EXT2 = @as(c_int, 5);
pub const GIT_OBJ_OFS_DELTA = GIT_OBJECT_OFS_DELTA;
pub const GIT_OBJ_REF_DELTA = GIT_OBJECT_REF_DELTA;
pub const git_ref_t = git_reference_t;
pub const git_reference_normalize_t = git_reference_format_t;
pub const GIT_REF_INVALID = GIT_REFERENCE_INVALID;
pub const GIT_REF_OID = GIT_REFERENCE_DIRECT;
pub const GIT_REF_SYMBOLIC = GIT_REFERENCE_SYMBOLIC;
pub const GIT_REF_LISTALL = GIT_REFERENCE_ALL;
pub const GIT_REF_FORMAT_NORMAL = GIT_REFERENCE_FORMAT_NORMAL;
pub const GIT_REF_FORMAT_ALLOW_ONELEVEL = GIT_REFERENCE_FORMAT_ALLOW_ONELEVEL;
pub const GIT_REF_FORMAT_REFSPEC_PATTERN = GIT_REFERENCE_FORMAT_REFSPEC_PATTERN;
pub const GIT_REF_FORMAT_REFSPEC_SHORTHAND = GIT_REFERENCE_FORMAT_REFSPEC_SHORTHAND;
pub const GIT_REVPARSE_SINGLE = GIT_REVSPEC_SINGLE;
pub const GIT_REVPARSE_RANGE = GIT_REVSPEC_RANGE;
pub const GIT_REVPARSE_MERGE_BASE = GIT_REVSPEC_MERGE_BASE;
pub const git_credtype_t = git_credential_t;
pub const GIT_CREDTYPE_USERPASS_PLAINTEXT = GIT_CREDENTIAL_USERPASS_PLAINTEXT;
pub const GIT_CREDTYPE_SSH_KEY = GIT_CREDENTIAL_SSH_KEY;
pub const GIT_CREDTYPE_SSH_CUSTOM = GIT_CREDENTIAL_SSH_CUSTOM;
pub const GIT_CREDTYPE_DEFAULT = GIT_CREDENTIAL_DEFAULT;
pub const GIT_CREDTYPE_SSH_INTERACTIVE = GIT_CREDENTIAL_SSH_INTERACTIVE;
pub const GIT_CREDTYPE_USERNAME = GIT_CREDENTIAL_USERNAME;
pub const GIT_CREDTYPE_SSH_MEMORY = GIT_CREDENTIAL_SSH_MEMORY;
pub const git_remote_completion_type = git_remote_completion_t;
pub const LIBGIT2_VERSION = "1.1.0";
pub const LIBGIT2_VER_MAJOR = @as(c_int, 1);
pub const LIBGIT2_VER_MINOR = @as(c_int, 1);
pub const LIBGIT2_VER_REVISION = @as(c_int, 0);
pub const LIBGIT2_VER_PATCH = @as(c_int, 0);
pub const LIBGIT2_SOVERSION = "1.1";
pub const tm = struct_tm;
pub const timespec = struct_timespec;
pub const itimerspec = struct_itimerspec;
pub const sigevent = struct_sigevent;
pub const __locale_data = struct___locale_data;
pub const __locale_struct = struct___locale_struct;
pub const timeval = struct_timeval;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const random_data = struct_random_data;
pub const drand48_data = struct_drand48_data;
pub const _LIBSSH2_USERAUTH_KBDINT_PROMPT = struct__LIBSSH2_USERAUTH_KBDINT_PROMPT;
pub const _LIBSSH2_USERAUTH_KBDINT_RESPONSE = struct__LIBSSH2_USERAUTH_KBDINT_RESPONSE;
pub const _LIBSSH2_SESSION = struct__LIBSSH2_SESSION;
pub const git_iterator = struct_git_iterator;
