#include "asm.S"

.section .text
.global dct4x4dc_riscv

dct4x4dc_riscv:
    add             t2, x0, a0
    vsetivli        t0, 4, e16
    li              t1, 8
    vlsseg4e16.v    v2, (a0), t1
    SUMSUB_ABCD     v6, v7, v8, v9, v2, v3, v4, v5
    SUMSUB_ABCD     v2, v3, v5, v4, v6, v8, v7, v9
    vse16.v         v2, (t2)
    add             t2, t2, t1
    vse16.v         v3, (t2)
    add             t2, t2, t1
    vse16.v         v4, (t2)
    add             t2, t2, t1
    vse16.v         v5, (t2)
    vlsseg4e16.v    v2, (a0), t1
    SUMSUB_ABCD     v6, v7, v8, v9, v2, v3, v4, v5
    SUMSUB_ABCD     v2, v3, v5, v4, v6, v8, v7, v9
    vadd.vi         v2, v2, 1
    vadd.vi         v3, v3, 1
    vadd.vi         v4, v4, 1
    vadd.vi         v5, v5, 1
    vsra.vi         v2, v2, 1
    vsra.vi         v3, v3, 1
    vsra.vi         v4, v4, 1
    vsra.vi         v5, v5, 1
    vssseg4e16.v    v2, (a0), t1 
    ret

.global idct4x4dc_riscv
idct4x4dc_riscv:
    add             t2, x0, a0
    vsetivli        t0, 4, e16
    li              t1, 8
    vlsseg4e16.v    v2, (a0), t1
    SUMSUB_ABCD     v6, v7, v8, v9, v2, v3, v4, v5
    SUMSUB_ABCD     v2, v3, v5, v4, v6, v8, v7, v9
    vse16.v         v2, (t2)
    add             t2, t2, t1
    vse16.v         v3, (t2)
    add             t2, t2, t1
    vse16.v         v4, (t2)
    add             t2, t2, t1
    vse16.v         v5, (t2)
    vlsseg4e16.v    v2, (a0), t1
    SUMSUB_ABCD     v6, v7, v8, v9, v2, v3, v4, v5
    SUMSUB_ABCD     v2, v3, v5, v4, v6, v8, v7, v9
    vssseg4e16.v    v2, (a0), t1 
    ret

.global pixel_sub_wxh_riscv
pixel_sub_wxh_riscv:
    vsetvli         t0, a1, e8
    vlsseg4e8.v     v1, (a2), a3
    vlsseg4e8.v     v10, (a4), a5
    vwsub.vv        v20, v1, v10
    vwsub.vv        v22, v2, v11
    vwsub.vv        v24, v3, v12
    vwsub.vv        v26, v4, v13
    li              t1, 8
    vssseg4e16.v    v20, (a0), t1
    ret  

.global sub4x4_dct_riscv
sub4x4_dct_riscv:
    addi            sp, sp, -48
    sd              ra, 40(sp)
    sd              s0, 32(sp)
    addi            s0, sp, 48
    sd              a0, -24(s0)
    sd              a1, -32(s0)
    sd              a2, -40(s0)
    li              a1, 4
    ld              a2, -32(s0)              
    li              a3, FENC_STRIDE
    ld              a4, -40(s0)
    li              a5, FDEC_STRIDE
    call            ra, pixel_sub_wxh_riscv
    add             t2, x0, a0
    vsetivli        t0, 4, e16
    li              t1, 8
    vlsseg4e16.v    v2, (t2), t1
    DCT_1D          v6, v7, v8, v9, v2, v3, v4, v5
    vse16.v         v6, (t2)
    add             t2, t2, t1
    vse16.v         v7, (t2)
    add             t2, t2, t1
    vse16.v         v8, (t2)
    add             t2, t2, t1
    vse16.v         v9, (t2)
    vlsseg4e16.v    v2, (a0), t1
    DCT_1D          v6, v7, v8, v9, v2, v3, v4, v5
    vssseg4e16.v    v6, (a0), t1
    ld              ra, 40(sp)
    ld              s0, 32(sp)
    addi            sp, sp,48
    ret

.global sub8x8_dct_riscv
sub8x8_dct_riscv:
    addi            sp, sp, -48
    sd              ra, 40(sp)
    sd              s0, 32(sp)
    addi            s0, sp, 48
    sd              a0, -24(s0)
    sd              a1, -32(s0)
    sd              a2, -40(s0)
    call            sub4x4_dct_riscv
    ld              a0, -24(s0)
    addi            a0, a0, 32
    ld              a1, -32(s0)   
    addi            a1, a1, 4
    ld              a2, -40(s0)
    addi            a2, a2, 4
    call            sub4x4_dct_riscv
    li              t5, FENC_STRIDE
    li              t6, FDEC_STRIDE
    ld              a0, -24(s0)
    addi            a0, a0, 64
    ld              a1, -32(s0)   
    li              a6, 4
    mul             t5, t5, a6 
    add             a1, a1, t5
    ld              a2, -40(s0)
    mul             t6, t6, a6
    add             a2, a2, t6
    call            sub4x4_dct_riscv
    ld              a0, -24(s0)
    addi            a0, a0, 96
    li              t5, FENC_STRIDE
    li              t6, FDEC_STRIDE
    ld              a1, -32(s0)   
    li              a6, 4
    mul             t5, t5, a6 
    add             a1, a1, t5
    addi            a1, a1, 4
    ld              a2, -40(s0)
    mul             t6, t6, a6
    add             a2, a2, t6
    addi            a2, a2, 4
    call            sub4x4_dct_riscv
    ld              ra, 40(sp)
    ld              s0, 32(sp)
    addi            sp, sp,48
    ret

.global sub8x8_dct_riscv_1
sub8x8_dct_riscv_1:
    addi            sp, sp, -48
    sd              ra, 40(sp)
    sd              s0, 32(sp)
    addi            s0, sp, 48
    sd              a0, -24(s0)
    sd              a1, -32(s0)
    sd              a2, -40(s0)
    li              t5, FENC_STRIDE
    li              t6, FDEC_STRIDE
    call            sub4x4_dct_riscv
    ld              a0, -24(s0)
    addi            a0, a0, 32
    ld              a1, -32(s0)   
    addi            a1, a1, 4
    ld              a2, -40(s0)
    addi            a2, a2, 4
    call            sub4x4_dct_riscv 

    ld              ra, 40(sp)
    ld              s0, 32(sp)
    addi            sp, sp,48
    ret