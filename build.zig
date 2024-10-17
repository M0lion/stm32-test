const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = std.Target.Query{
            .cpu_arch = .thumb,
            .cpu_model = std.zig.CrossTarget.CpuModel{ .explicit = &std.Target.arm.cpu.cortex_m4 },
            .abi = .eabihf,
            .os_tag = .freestanding,
            .cpu_features_add = std.Target.arm.featureSet(&.{
                std.Target.arm.Feature.vfp4d16sp,
            }),
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "firmware",
        .root_source_file = b.path("src/start.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.setLinkerScript(b.path("src/linker.ld"));
    b.installArtifact(exe);

    const make_image_command = b.addSystemCommand(&.{
        "arm-none-eabi-objcopy",
        "-O",
        "binary",
    });
    make_image_command.addArtifactArg(exe);
    const image = make_image_command.addOutputFileArg("firmware.bin");
    const make_image_step = b.step("image", "Build binary from elf");
    make_image_step.dependOn(&make_image_command.step);

    const flash_command = b.addSystemCommand(&.{
        "st-flash",
        "--reset",
        "write",
    });
    flash_command.addFileArg(image);
    flash_command.addArg("0x8000000");
    flash_command.step.dependOn(&make_image_command.step);
    const flash_step = b.step("flash", "Flash to device");
    flash_step.dependOn(&flash_command.step);
}
