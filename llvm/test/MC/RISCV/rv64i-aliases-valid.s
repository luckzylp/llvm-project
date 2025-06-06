# RUN: llvm-mc %s -triple=riscv64 -M no-aliases \
# RUN:     | FileCheck -check-prefixes=CHECK-EXPAND,CHECK-INST,CHECK-ASM-NOALIAS %s
# RUN: llvm-mc %s -triple=riscv64 \
# RUN:     | FileCheck -check-prefixes=CHECK-EXPAND,CHECK-ALIAS,CHECK-ASM %s
# RUN: llvm-mc -filetype=obj -triple riscv64 < %s \
# RUN:     | llvm-objdump --no-print-imm-hex -M no-aliases -d - \
# RUN:     | FileCheck -check-prefixes=CHECK-OBJ-NOALIAS,CHECK-EXPAND,CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv64 < %s \
# RUN:     | llvm-objdump --no-print-imm-hex -d - \
# RUN:     | FileCheck -check-prefixes=CHECK-EXPAND,CHECK-ALIAS %s

# The following check prefixes are used in this test:
# CHECK-INST.....Match the canonical instr (tests alias to instr. mapping)
# CHECK-ALIAS....Match the alias (tests instr. to alias mapping)
# CHECK-EXPAND...Match canonical instr. unconditionally (tests alias expansion)

# TODO ld
# TODO sd

# Needed for testing valid %pcrel_lo expressions
.Lpcrel_hi0: auipc a0, %pcrel_hi(foo)

# Needed for testing li with a symbol difference
.Lbuf: .skip 8
.Lbuf_end:

# CHECK-INST: addi a0, zero, 0
# CHECK-ALIAS: li a0, 0
li x10, 0
# CHECK-INST: addi a0, zero, 1
# CHECK-ALIAS: li a0, 1
li x10, 1
# CHECK-INST: addi a0, zero, -1
# CHECK-ALIAS: li a0, -1
li x10, -1
# CHECK-INST: addi a0, zero, 2047
# CHECK-ALIAS: li a0, 2047
li x10, 2047
# CHECK-INST: addi a0, zero, -2047
# CHECK-ALIAS: li a0, -2047
li x10, -2047
# CHECK-INST: addi a1, zero, 1
# CHECK-INST: slli a1, a1, 11
# CHECK-ALIAS: li a1, 1
# CHECK-ALIAS: slli a1, a1, 11
li x11, 2048
# CHECK-INST: addi a1, zero, -2048
# CHECK-ALIAS: li a1, -2048
li x11, -2048
# CHECK-EXPAND: lui a1, 1
# CHECK-EXPAND: addi a1, a1, -2047
li x11, 2049
# CHECK-EXPAND: lui a1, 1048575
# CHECK-EXPAND: addi a1, a1, 2047
li x11, -2049
# CHECK-EXPAND: lui a1, 1
# CHECK-EXPAND: addi a1, a1, -1
li x11, 4095
# CHECK-EXPAND: lui a1, 1048575
# CHECK-EXPAND: addi a1, a1, 1
li x11, -4095
# CHECK-EXPAND: lui a2, 1
li x12, 4096
# CHECK-EXPAND: lui a2, 1048575
li x12, -4096
# CHECK-EXPAND: lui a2, 1
# CHECK-EXPAND-NEXT: addi a2, a2, 1
li x12, 4097
# CHECK-EXPAND: lui a2, 1048575
# CHECK-EXPAND: addi a2, a2, -1
li x12, -4097
# CHECK-EXPAND: lui a2, 524288
# CHECK-EXPAND-NEXT: addiw a2, a2, -1
li x12, 2147483647
# CHECK-EXPAND: lui a2, 524288
# CHECK-EXPAND-NEXT: addi a2, a2, 1
li x12, -2147483647
# CHECK-EXPAND: lui a2, 524288
li x12, -2147483648
# CHECK-EXPAND: lui a2, 524288
li x12, -0x80000000

# CHECK-INST: addi a2, zero, 1
# CHECK-INST-NEXT: slli a2, a2, 31
# CHECK-ALIAS: li a2, 1
# CHECK-ALIAS-NEXT: slli a2, a2, 31
li x12, 0x80000000
# CHECK-INST: addi a2, zero, -1
# CHECK-INST-NEXT: srli a2, a2, 32
# CHECK-ALIAS: li a2, -1
# CHECK-ALIAS-NEXT: srli a2, a2, 32
li x12, 0xFFFFFFFF

# CHECK-INST: addi t0, zero, 1
# CHECK-INST-NEXT: slli t0, t0, 32
# CHECK-ALIAS: li t0, 1
# CHECK-ALIAS-NEXT: slli t0, t0, 32
li t0, 0x100000000
# CHECK-INST: addi t1, zero, -1
# CHECK-INST-NEXT: slli t1, t1, 63
# CHECK-ALIAS: li t1, -1
# CHECK-ALIAS-NEXT: slli t1, t1, 63
li t1, 0x8000000000000000
# CHECK-INST: addi t1, zero, -1
# CHECK-INST-NEXT: slli t1, t1, 63
# CHECK-ALIAS: li t1, -1
# CHECK-ALIAS-NEXT: slli t1, t1, 63
li t1, -0x8000000000000000
# CHECK-EXPAND: lui t2, 9321
# CHECK-EXPAND-NEXT: addi t2, t2, -1329
# CHECK-EXPAND-NEXT: slli t2, t2, 35
li t2, 0x1234567800000000
# CHECK-INST: addi t3, zero, 7
# CHECK-INST-NEXT: slli t3, t3, 36
# CHECK-INST-NEXT: addi t3, t3, 11
# CHECK-INST-NEXT: slli t3, t3, 24
# CHECK-INST-NEXT: addi t3, t3, 15
# CHECK-ALIAS: li t3, 7
# CHECK-ALIAS-NEXT: slli t3, t3, 36
# CHECK-ALIAS-NEXT: addi t3, t3, 11
# CHECK-ALIAS-NEXT: slli t3, t3, 24
# CHECK-ALIAS-NEXT: addi t3, t3, 15
li t3, 0x700000000B00000F
# CHECK-EXPAND: lui t4, 583
# CHECK-EXPAND-NEXT: addi t4, t4, -1875
# CHECK-EXPAND-NEXT: slli t4, t4, 14
# CHECK-EXPAND-NEXT: addi t4, t4, -947
# CHECK-EXPAND-NEXT: slli t4, t4, 12
# CHECK-EXPAND-NEXT: addi t4, t4, 1511
# CHECK-EXPAND-NEXT: slli t4, t4, 13
# CHECK-EXPAND-NEXT: addi t4, t4, -272
li t4, 0x123456789abcdef0
# CHECK-INST: addi t5, zero, -1
# CHECK-ALIAS: li t5, -1
li t5, 0xFFFFFFFFFFFFFFFF
# CHECK-EXPAND: lui t6, 262145
# CHECK-EXPAND-NEXT: slli t6, t6, 1
li t6, 0x80002000
# CHECK-EXPAND: lui t0, 262145
# CHECK-EXPAND-NEXT: slli t0, t0, 2
li x5, 0x100004000
# CHECK-EXPAND: lui t1, 4097
# CHECK-EXPAND-NEXT: slli t1, t1, 20
li x6, 0x100100000000
# CHECK-EXPAND: lui t2, 983056
# CHECK-EXPAND-NEXT: srli t2, t2, 16
li x7, 0xFFFFFFFFF001
# CHECK-EXPAND: lui s0, 1044481
# CHECK-EXPAND-NEXT: slli s0, s0, 12
# CHECK-EXPAND-NEXT: srli s0, s0, 24
li x8, 0xFFFFFFF001
# CHECK-EXPAND: lui s1, 4097
# CHECK-EXPAND-NEXT: slli s1, s1, 20
# CHECK-EXPAND-NEXT: addi s1, s1, -3
li x9, 0x1000FFFFFFFD
# CHECK-INST: lui a0, 983040
# CHECK-INST-NEXT: srli a0, a0, 3
# CHECK-INST-NEXT: xori a0, a0, -1
# CHECK-ALIAS: lui a0, 983040
# CHECK-ALIAS-NEXT: srli a0, a0, 3
# CHECK-ALIAS-NEXT: not a0, a0
li x10, 0xE000000001FFFFFF
# CHECK-INST: addi a1, zero, -2047
# CHECK-INST-NEXT: slli a1, a1, 39
# CHECK-INST-NEXT: addi a1, a1, -2048
# CHECK-INST-NEXT: addi a1, a1, -1
# CHECK-ALIAS: li a1, -2047
# CHECK-ALIAS-NEXT: slli a1, a1, 39
# CHECK-ALIAS-NEXT: addi a1, a1, -2048
# CHECK-ALIAS-NEXT: addi a1, a1, -1
li x11, 0xFFFC007FFFFFF7FF

# CHECK-INST: lui a2, 349525
# CHECK-INST-NEXT: addi a2, a2, 1365
# CHECK-INST-NEXT: slli a2, a2, 1
# CHECK-ALIAS: lui a2, 349525
# CHECK-ALIAS-NEXT: addi a2, a2, 1365
# CHECK-ALIAS-NEXT: slli a2, a2, 1
li x12, 0xaaaaaaaa

# CHECK-INST: lui a3, 699051
# CHECK-INST-NEXT: addi a3, a3, -1365
# CHECK-INST-NEXT: slli a3, a3, 1
# CHECK-ALIAS: lui a3, 699051
# CHECK-ALIAS-NEXT: addi a3, a3, -1365
# CHECK-ALIAS-NEXT: slli a3, a3, 1
li x13, 0xffffffff55555556

# CHECK-S-OBJ-NOALIAS: lui t0, 524288
# CHECK-S-OBJ-NOALIAS-NEXT: addi t0, t0, -1365
# CHECK-S-OBJ: lui t0, 524288
# CHECK-S-OBJ-NEXT: addi t0, t0, -1365
li x5, -2147485013

# CHECK-ASM: addi a0, zero, %lo(1193046)
# CHECK-OBJ: addi a0, zero, %lo(1193046)
li a0, %lo(0x123456)

# CHECK-OBJ-NOALIAS: addi a0, zero, 0
# CHECK-OBJ: R_RISCV_LO12
li a0, %lo(foo)
# CHECK-OBJ-NOALIAS: addi a0, zero, 0
# CHECK-OBJ: R_RISCV_PCREL_LO12
li a0, %pcrel_lo(.Lpcrel_hi0)

.equ CONST, 0x123456
# CHECK-EXPAND: lui a0, 291
# CHECK-EXPAND: addi a0, a0, 1110
li a0, CONST

.equ CONST, 0x654321
# CHECK-EXPAND: lui a0, 1620
# CHECK-EXPAND: addi a0, a0, 801
li a0, CONST

.equ CONST, .Lbuf_end - .Lbuf
# CHECK-ASM: li a0, CONST
# CHECK-ASM-NOALIAS: addi a0, zero, CONST
# CHECK-OBJ-NOALIAS: addi a0, zero, 8
li a0, CONST

# CHECK-ASM: addi a0, zero, .Lbuf_end-.Lbuf
# CHECK-ASM-NOALIAS: addi a0, zero, .Lbuf_end-.Lbuf
# CHECK-OBJ-NOALIAS: addi a0, zero, 8
li a0, .Lbuf_end - .Lbuf

# CHECK-INST: addi a0, zero, 0
# CHECK-ALIAS: li a0, 0
la x10, 0
lla x10, 0
# CHECK-INST: addi a0, zero, 1
# CHECK-ALIAS: li a0, 1
la x10, 1
lla x10, 1
# CHECK-INST: addi a0, zero, -1
# CHECK-ALIAS: li a0, -1
la x10, -1
lla x10, -1
# CHECK-INST: addi a0, zero, 2047
# CHECK-ALIAS: li a0, 2047
la x10, 2047
lla x10, 2047
# CHECK-INST: addi a0, zero, -2047
# CHECK-ALIAS: li a0, -2047
la x10, -2047
lla x10, -2047
# CHECK-INST: addi a1, zero, 1
# CHECK-INST: slli a1, a1, 11
# CHECK-ALIAS: li a1, 1
# CHECK-ALIAS: slli a1, a1, 11
la x11, 2048
lla x11, 2048
# CHECK-INST: addi a1, zero, -2048
# CHECK-ALIAS: li a1, -2048
la x11, -2048
lla x11, -2048
# CHECK-EXPAND: lui a1, 1
# CHECK-EXPAND: addi a1, a1, -2047
la x11, 2049
lla x11, 2049
# CHECK-EXPAND: lui a1, 1048575
# CHECK-EXPAND: addi a1, a1, 2047
la x11, -2049
lla x11, -2049
# CHECK-EXPAND: lui a1, 1
# CHECK-EXPAND: addi a1, a1, -1
la x11, 4095
lla x11, 4095
# CHECK-EXPAND: lui a1, 1048575
# CHECK-EXPAND: addi a1, a1, 1
la x11, -4095
lla x11, -4095
# CHECK-EXPAND: lui a2, 1
la x12, 4096
lla x12, 4096
# CHECK-EXPAND: lui a2, 1048575
la x12, -4096
lla x12, -4096
# CHECK-EXPAND: lui a2, 1
# CHECK-EXPAND: addi a2, a2, 1
la x12, 4097
lla x12, 4097
# CHECK-EXPAND: lui a2, 1048575
# CHECK-EXPAND: addiw a2, a2, -1
la x12, -4097
lla x12, -4097
# CHECK-EXPAND: lui a2, 524288
# CHECK-EXPAND: addiw a2, a2, -1
la x12, 2147483647
lla x12, 2147483647
# CHECK-EXPAND: lui a2, 524288
# CHECK-EXPAND: addi a2, a2, 1
la x12, -2147483647
lla x12, -2147483647
# CHECK-EXPAND: lui a2, 524288
la x12, -2147483648
lla x12, -2147483648
# CHECK-EXPAND: lui a2, 524288
la x12, -0x80000000
lla x12, -0x80000000

# CHECK-INST: addi a2, zero, 1
# CHECK-INST-NEXT: slli a2, a2, 31
# CHECK-ALIAS: li a2, 1
# CHECK-ALIAS-NEXT: slli a2, a2, 31
la x12, 0x80000000
lla x12, 0x80000000
# CHECK-INST: addi a2, zero, -1
# CHECK-INST-NEXT: srli a2, a2, 32
# CHECK-ALIAS: li a2, -1
# CHECK-ALIAS-NEXT: srli a2, a2, 32
la x12, 0xFFFFFFFF
lla x12, 0xFFFFFFFF

# CHECK-INST: addi t0, zero, 1
# CHECK-INST-NEXT: slli t0, t0, 32
# CHECK-ALIAS: li t0, 1
# CHECK-ALIAS-NEXT: slli t0, t0, 32
la t0, 0x100000000
lla t0, 0x100000000
# CHECK-INST: addi t1, zero, -1
# CHECK-INST-NEXT: slli t1, t1, 63
# CHECK-ALIAS: li t1, -1
# CHECK-ALIAS-NEXT: slli t1, t1, 63
la t1, 0x8000000000000000
lla t1, 0x8000000000000000
# CHECK-INST: addi t1, zero, -1
# CHECK-INST-NEXT: slli t1, t1, 63
# CHECK-ALIAS: li t1, -1
# CHECK-ALIAS-NEXT: slli t1, t1, 63
la t1, -0x8000000000000000
lla t1, -0x8000000000000000
# CHECK-EXPAND: lui t2, 9321
# CHECK-EXPAND-NEXT: addi t2, t2, -1329
# CHECK-EXPAND-NEXT: slli t2, t2, 35
la t2, 0x1234567800000000
lla t2, 0x1234567800000000
# CHECK-INST: addi t3, zero, 7
# CHECK-INST-NEXT: slli t3, t3, 36
# CHECK-INST-NEXT: addi t3, t3, 11
# CHECK-INST-NEXT: slli t3, t3, 24
# CHECK-INST-NEXT: addi t3, t3, 15
# CHECK-ALIAS: li t3, 7
# CHECK-ALIAS-NEXT: slli t3, t3, 36
# CHECK-ALIAS-NEXT: addi t3, t3, 11
# CHECK-ALIAS-NEXT: slli t3, t3, 24
# CHECK-ALIAS-NEXT: addi t3, t3, 15
la t3, 0x700000000B00000F
lla t3, 0x700000000B00000F
# CHECK-EXPAND: lui t4, 583
# CHECK-EXPAND-NEXT: addi t4, t4, -1875
# CHECK-EXPAND-NEXT: slli t4, t4, 14
# CHECK-EXPAND-NEXT: addi t4, t4, -947
# CHECK-EXPAND-NEXT: slli t4, t4, 12
# CHECK-EXPAND-NEXT: addi t4, t4, 1511
# CHECK-EXPAND-NEXT: slli t4, t4, 13
# CHECK-EXPAND-NEXT: addi t4, t4, -272
la t4, 0x123456789abcdef0
lla t4, 0x123456789abcdef0
# CHECK-INST: addi t5, zero, -1
# CHECK-ALIAS: li t5, -1
la t5, 0xFFFFFFFFFFFFFFFF
lla t5, 0xFFFFFFFFFFFFFFFF
# CHECK-EXPAND: lui t6, 262145
# CHECK-EXPAND-NEXT: slli t6, t6, 1
la t6, 0x80002000
lla t6, 0x80002000
# CHECK-EXPAND: lui t0, 262145
# CHECK-EXPAND-NEXT: slli t0, t0, 2
la x5, 0x100004000
lla x5, 0x100004000
# CHECK-EXPAND: lui t1, 4097
# CHECK-EXPAND-NEXT: slli t1, t1, 20
la x6, 0x100100000000
lla x6, 0x100100000000
# CHECK-EXPAND: lui t2, 983056
# CHECK-EXPAND-NEXT: srli t2, t2, 16
la x7, 0xFFFFFFFFF001
lla x7, 0xFFFFFFFFF001
# CHECK-EXPAND: lui s0, 1044481
# CHECK-EXPAND-NEXT: slli s0, s0, 12
# CHECK-EXPAND-NEXT: srli s0, s0, 24
la x8, 0xFFFFFFF001
lla x8, 0xFFFFFFF001
# CHECK-EXPAND: lui s1, 4097
# CHECK-EXPAND-NEXT: slli s1, s1, 20
# CHECK-EXPAND-NEXT: addi s1, s1, -3
la x9, 0x1000FFFFFFFD
lla x9, 0x1000FFFFFFFD
# CHECK-INST: lui a0, 983040
# CHECK-INST-NEXT: srli a0, a0, 3
# CHECK-INST-NEXT: xori a0, a0, -1
# CHECK-ALIAS: lui a0, 983040
# CHECK-ALIAS-NEXT: srli a0, a0, 3
# CHECK-ALIAS-NEXT: not a0, a0
la x10, 0xE000000001FFFFFF
lla x10, 0xE000000001FFFFFF
# CHECK-INST: addi a1, zero, -2047
# CHECK-INST-NEXT: slli a1, a1, 39
# CHECK-INST-NEXT: addi a1, a1, -2048
# CHECK-INST-NEXT: addi a1, a1, -1
# CHECK-ALIAS: li a1, -2047
# CHECK-ALIAS-NEXT: slli a1, a1, 39
# CHECK-ALIAS-NEXT: addi a1, a1, -2048
# CHECK-ALIAS-NEXT: addi a1, a1, -1
la x11, 0xFFFC007FFFFFF7FF
lla x11, 0xFFFC007FFFFFF7FF

# CHECK-INST: lui a2, 349525
# CHECK-INST-NEXT: addi a2, a2, 1365
# CHECK-INST-NEXT: slli a2, a2, 1
# CHECK-ALIAS: lui a2, 349525
# CHECK-ALIAS-NEXT: addi a2, a2, 1365
# CHECK-ALIAS-NEXT: slli a2, a2, 1
la x12, 0xaaaaaaaa
lla x12, 0xaaaaaaaa

# CHECK-INST: lui a3, 699051
# CHECK-INST-NEXT: addi a3, a3, -1365
# CHECK-INST-NEXT: slli a3, a3, 1
# CHECK-ALIAS: lui a3, 699051
# CHECK-ALIAS-NEXT: addi a3, a3, -1365
# CHECK-ALIAS-NEXT: slli a3, a3, 1
la x13, 0xffffffff55555556
lla x13, 0xffffffff55555556

# CHECK-S-OBJ-NOALIAS: lui t0, 524288
# CHECK-S-OBJ-NOALIAS-NEXT: addi t0, t0, -1365
# CHECK-S-OBJ: lui t0, 524288
# CHECK-S-OBJ-NEXT: addi t0, t0, -1365
la x5, -2147485013
lla x5, -2147485013

.equ CONSTANT, 0x123456
# CHECK-EXPAND: lui a0, 291
# CHECK-EXPAND: addi a0, a0, 1110
la a0, CONSTANT
lla a0, CONSTANT

.equ CONSTANT, 0x654321
# CHECK-EXPAND: lui a0, 1620
# CHECK-EXPAND: addi a0, a0, 801
la a0, CONSTANT
lla a0, CONSTANT

# CHECK-INST: subw t6, zero, ra
# CHECK-ALIAS: negw t6, ra
negw x31, x1
# CHECK-INST: addiw t6, ra, 0
# CHECK-ALIAS: sext.w t6, ra
sext.w x31, x1

# The following aliases are accepted as input but the canonical form
# of the instruction will always be printed.
# CHECK-INST: addiw a2, a3, 4
# CHECK-ALIAS: addiw a2, a3, 4
addw a2,a3,4

# CHECK-INST: slliw a2, a3, 4
# CHECK-ALIAS: slliw a2, a3, 4
sllw a2,a3,4

# CHECK-INST: srliw a2, a3, 4
# CHECK-ALIAS: srliw a2, a3, 4
srlw a2,a3,4

# CHECK-INST: sraiw a2, a3, 4
# CHECK-ALIAS: sraiw a2, a3, 4
sraw a2,a3,4

# CHECK-EXPAND: lwu a0, 0(a1)
lwu x10, (x11)
# CHECK-EXPAND: ld a0, 0(a1)
ld x10, (x11)
# CHECK-EXPAND: sd a0, 0(a1)
sd x10, (x11)

# CHECK-EXPAND: slli a0, a1, 56
# CHECK-EXPAND: srai a0, a0, 56
sext.b x10, x11

# CHECK-EXPAND: slli a0, a1, 48
# CHECK-EXPAND: srai a0, a0, 48
sext.h x10, x11

# CHECK-INST: andi a0, a1, 255
# CHECK-ALIAS: zext.b a0, a1
zext.b x10, x11

# CHECK-EXPAND: slli a0, a1, 48
# CHECK-EXPAND: srli a0, a0, 48
zext.h x10, x11

# CHECK-EXPAND: slli a0, a1, 32
# CHECK-EXPAND: srli a0, a0, 32
zext.w x10, x11
