pub fn Register(comptime Reg: type) type {
    return packed struct {
        const Self = @This();

        raw: u32,

        pub inline fn read(addr: *volatile Self) Reg {
            return @bitCast(addr.raw);
        }

        pub inline fn write(addr: *volatile Self, val: Reg) void {
            addr.raw = @bitCast(val);
        }
    };
}
