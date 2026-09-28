const xboxkrnl = @import("xboxkrnl");
const pbkit = @import("pbkit");

fn MASK(mask: xboxkrnl.xboxdef.DWORD, val: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.DWORD {
    return ((val) << @as(u5, @intCast(@ctz(mask)))) & mask;
}

pub fn run(p: *[*]u32) void {
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW + 0 * 4,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_A_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_A_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_A_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_B_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_B_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_B_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_C_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_C_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_C_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_D_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_D_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_ICW_D_MAP, 0x0),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW + 0 * 4,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_AB_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_CD_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_SUM_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_MUX_ENABLE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_AB_DOT_ENABLE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_CD_DOT_ENABLE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_OP, pbkit.nvregs.NV097_SET_COMBINER_COLOR_OCW_OP_NOSHIFT),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW + 0 * 4,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_A_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_A_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_A_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_B_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_B_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_B_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_C_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_C_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_C_MAP, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_D_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_D_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_ICW_D_MAP, 0x0),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW + 0 * 4,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_AB_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_CD_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_SUM_DST, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_MUX_ENABLE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_OP, pbkit.nvregs.NV097_SET_COMBINER_ALPHA_OCW_OP_NOSHIFT),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_CONTROL,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_CONTROL_FACTOR0, pbkit.nvregs.NV097_SET_COMBINER_CONTROL_FACTOR0_SAME_FACTOR_ALL) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_CONTROL_FACTOR1, pbkit.nvregs.NV097_SET_COMBINER_CONTROL_FACTOR1_SAME_FACTOR_ALL) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_CONTROL_ITERATION_COUNT, 1),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_A_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_A_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_A_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_B_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_B_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_B_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_C_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_C_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_C_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_D_SOURCE, 0x4) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_D_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW0_D_INVERSE, 0),
    );
    p.* += 2;
    _ = pbkit.pbkit_pushbuffer.pb_push1(
        p.*,
        pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1,
        MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_E_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_E_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_E_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_F_SOURCE, 0x0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_F_ALPHA, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_F_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_G_SOURCE, 0x4) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_G_ALPHA, 1) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_G_INVERSE, 0) |
            MASK(pbkit.nvregs.NV097_SET_COMBINER_SPECULAR_FOG_CW1_SPECULAR_CLAMP, 0),
    );
    p.* += 2;
}
