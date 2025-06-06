# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c < %s \
# RUN:     | llvm-objdump -d -M no-aliases - | FileCheck --check-prefix=INSTR %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,+relax < %s \
# RUN:     | llvm-objdump -d -M no-aliases - | FileCheck --check-prefix=RELAX-INSTR %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,+relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=RELAX-RELOC %s

FAR_JUMP_NEGATIVE:
  c.nop
.space 2000

FAR_BRANCH_NEGATIVE:
  c.nop
.space 256

NEAR_NEGATIVE:
  c.nop
  call relax

start:
  c.bnez a0, NEAR
#INSTR: c.bnez a0, 0x92e
#RELAX-INSTR: c.bnez a0, 0
#RELAX-RELOC: R_RISCV_RVC_BRANCH
  c.bnez a0, NEAR_NEGATIVE
#INSTR: c.bnez a0, 0x8d4
#RELAX-INSTR: c.bnez a0, 0
#RELAX-RELOC: R_RISCV_RVC_BRANCH
  c.bnez a0, FAR_BRANCH
#INSTR-NEXT: bne a0, zero, 0xa30
#RELAX-INSTR-NEXT: bne a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.bnez a0, FAR_BRANCH_NEGATIVE
#INSTR-NEXT: bne a0, zero, 0x7d2
#RELAX-INSTR-NEXT: bne a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.bnez a0, FAR_JUMP
#INSTR-NEXT: bne a0, zero, 0x1202
#RELAX-INSTR-NEXT: bne a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.bnez a0, FAR_JUMP_NEGATIVE
#INSTR-NEXT: bne a0, zero, 0x0
#RELAX-INSTR-NEXT: bne a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH

  c.beqz a0, NEAR
#INSTR-NEXT: c.beqz a0, 0x92e
#RELAX-INSTR-NEXT: c.beqz a0, 0
#RELAX-RELOC: R_RISCV_RVC_BRANCH
  c.beqz a0, NEAR_NEGATIVE
#INSTR-NEXT: c.beqz a0, 0x8d4
#RELAX-INSTR-NEXT: c.beqz a0, 0
#RELAX-RELOC: R_RISCV_RVC_BRANCH
  c.beqz a0, FAR_BRANCH
#INSTR-NEXT: beq a0, zero, 0xa30
#RELAX-INSTR-NEXT: beq a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.beqz a0, FAR_BRANCH_NEGATIVE
#INSTR-NEXT: beq a0, zero, 0x7d2
#RELAX-INSTR-NEXT: beq a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.beqz a0, FAR_JUMP
#INSTR-NEXT: beq a0, zero, 0x1202
#RELAX-INSTR-NEXT: beq a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH
  c.beqz a0, FAR_JUMP_NEGATIVE
#INSTR-NEXT: beq a0, zero, 0x0
#RELAX-INSTR-NEXT: beq a0, zero, 0
#RELAX-RELOC: R_RISCV_BRANCH

  c.j NEAR
#INSTR-NEXT: c.j 0x92e
#RELAX-INSTR-NEXT: c.j 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.j NEAR_NEGATIVE
#INSTR-NEXT: c.j 0x8d4
#RELAX-INSTR-NEXT: c.j 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.j FAR_BRANCH
#INSTR-NEXT: c.j 0xa30
#RELAX-INSTR-NEXT: c.j 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.j FAR_BRANCH_NEGATIVE
#INSTR-NEXT: c.j 0x7d2
#RELAX-INSTR-NEXT: c.j 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.j FAR_JUMP
#INSTR-NEXT: jal zero, 0x1202
#RELAX-INSTR-NEXT: jal zero, 0
#RELAX-RELOC: R_RISCV_JAL
  c.j FAR_JUMP_NEGATIVE
#INSTR-NEXT: jal zero, 0x0
#RELAX-INSTR-NEXT: jal zero, 0
#RELAX-RELOC: R_RISCV_JAL

  c.jal NEAR
#INSTR: c.jal 0x92e
#RELAX-INSTR: c.jal 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.jal NEAR_NEGATIVE
#INSTR: c.jal 0x8d4
#RELAX-INSTR: c.jal 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.jal FAR_BRANCH
#INSTR-NEXT: c.jal 0xa30
#RELAX-INSTR-NEXT: c.jal 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.jal FAR_BRANCH_NEGATIVE
#INSTR-NEXT: c.jal 0x7d2
#RELAX-INSTR-NEXT: c.jal 0
#RELAX-RELOC: R_RISCV_RVC_JUMP
  c.jal FAR_JUMP
#INSTR-NEXT: jal ra, 0x1202
#RELAX-INSTR-NEXT: jal ra, 0
#RELAX-RELOC: R_RISCV_JAL
  c.jal FAR_JUMP_NEGATIVE
#INSTR-NEXT: jal ra, 0x0
#RELAX-INSTR-NEXT: jal ra, 0
#RELAX-RELOC: R_RISCV_JAL

  call relax
NEAR:
  c.nop
.space 256
FAR_BRANCH:
  c.nop
.space 2000
FAR_JUMP:
  c.nop
