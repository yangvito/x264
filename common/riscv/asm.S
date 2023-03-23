
#define FENC_STRIDE 16
#define FDEC_STRIDE 32

.macro SUMSUB_AB sum, diff, a, b
    vadd.vv    \sum,  \a, \b
    vsub.vv    \diff, \a, \b
.endm

.macro SUMSUB_ABCD s1, d1, s2, d2, a, b, c, d
    SUMSUB_AB   \s1, \d1, \a, \b
    SUMSUB_AB   \s2, \d2, \c, \d
.endm

.macro DCT_1D d0 d1 d2 d3  d4 d5 d6 d7
    SUMSUB_AB       \d1, \d6, \d5, \d6
    SUMSUB_AB       \d3, \d7, \d4, \d7
    vadd.vv         \d0, \d3, \d1
    vadd.vv         \d4, \d7, \d7
    vadd.vv         \d5, \d6, \d6
    vsub.vv         \d2, \d3, \d1
    vadd.vv         \d1, \d4, \d6
    vsub.vv         \d3, \d7, \d5
.endm
