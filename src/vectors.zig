pub const InterruptHandler = *const fn () callconv(.C) void;

pub fn unhandled() void {}

pub const VectorTable = extern struct {
    initial_stack_pointer: u32,
    Reset: InterruptHandler,
    reserved: [105]u32 = undefined,
};
