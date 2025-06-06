; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=riscv64 -mattr=+m,+c,+v  < %s | FileCheck --check-prefix=RV64V %s

declare void @llvm.va_copy.p0(ptr, ptr)
declare void @llvm.va_end.p0(ptr)

define dso_local void @_Z3fooPKcz(ptr noundef %0, ...) "frame-pointer"="all" {
; RV64V-LABEL: _Z3fooPKcz:
; RV64V:       # %bb.0:
; RV64V-NEXT:    addi sp, sp, -496
; RV64V-NEXT:    .cfi_def_cfa_offset 496
; RV64V-NEXT:    sd ra, 424(sp) # 8-byte Folded Spill
; RV64V-NEXT:    sd s0, 416(sp) # 8-byte Folded Spill
; RV64V-NEXT:    .cfi_offset ra, -72
; RV64V-NEXT:    .cfi_offset s0, -80
; RV64V-NEXT:    addi s0, sp, 432
; RV64V-NEXT:    .cfi_def_cfa s0, 64
; RV64V-NEXT:    lui t0, 2
; RV64V-NEXT:    addi t0, t0, -576
; RV64V-NEXT:    sub sp, sp, t0
; RV64V-NEXT:    sd a5, 40(s0)
; RV64V-NEXT:    sd a6, 48(s0)
; RV64V-NEXT:    sd a7, 56(s0)
; RV64V-NEXT:    sd a1, 8(s0)
; RV64V-NEXT:    sd a2, 16(s0)
; RV64V-NEXT:    sd a3, 24(s0)
; RV64V-NEXT:    sd a4, 32(s0)
; RV64V-NEXT:    sd a0, -32(s0)
; RV64V-NEXT:    addi a0, s0, 8
; RV64V-NEXT:    sd a0, -40(s0)
; RV64V-NEXT:    addi sp, s0, -432
; RV64V-NEXT:    .cfi_def_cfa sp, 496
; RV64V-NEXT:    ld ra, 424(sp) # 8-byte Folded Reload
; RV64V-NEXT:    ld s0, 416(sp) # 8-byte Folded Reload
; RV64V-NEXT:    .cfi_restore ra
; RV64V-NEXT:    .cfi_restore s0
; RV64V-NEXT:    addi sp, sp, 496
; RV64V-NEXT:    .cfi_def_cfa_offset 0
; RV64V-NEXT:    ret
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  %4 = alloca [8000 x i8], align 1
  store ptr %0, ptr %2, align 8
  call void @llvm.va_start.p0(ptr %3)
  %5 = getelementptr inbounds [8000 x i8], ptr %4, i64 0, i64 0
  %6 = load ptr, ptr %2, align 8
  %7 = load ptr, ptr %3, align 8
  call void @llvm.va_end.p0(ptr %3)
  ret void
}
