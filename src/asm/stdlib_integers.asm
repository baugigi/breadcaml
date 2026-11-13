;; -----------------------------------------------------------------------------
;;                                  INTEGERS
;; -----------------------------------------------------------------------------

;; - Each primitive is a stub that loads parameters and jumps to a shared core.
;; - The NB parameter (4 or 8) is passed in X. The core stores it within the
;;   operand of an LDX # inside caml_i_alloc.
;; - For add, sub, and, or, and xor operations, the core patches their opcode
;;   and sets the C flag using CMP #$80, which results in C=1 only for SBC.
;; - caml_i_alloc allocates the block and writes the custom pointer to
;;   Field(0).
;; - A 27-byte scratch area (.MZ) is used, it starts from TMP + 6 to keep
;;   caml_compare's SAVE_SP and COMPARE intact.

!zone caml_INTEGERS {

.MZ = TMP + 6                           ;27 bytes of scratch area 
.ORA_OPC = $11                          ;opcode for ORA (zp),Y
.AND_OPC = $31                          ;opcode for AND (zp),Y
.EOR_OPC = $51                          ;opcode for EOR (zp),Y
.ADC_OPC = $71                          ;opcode for ADC (zp),Y
.SBC_OPC = $F1                          ;opcode for SBC (zp),Y -- negative
.L_SHIFT = $00                          ;flag: logical shift
.A_SHIFT = $80                          ;flag: arithmetic shift

!macro caml_i_stub .a, .nb, .core {
        LDA # .a
        LDX # .nb
        BNE .core                       ;BNE=JMP
}
!macro caml_i_stub .nb, .core {
        LDX # .nb
        BNE .core                       ;BNE=JMP
}

        ;; -----------------------------------------
        ;; allocation / common prologue and epilogue
        ;; -----------------------------------------

!ifdef caml_AUX__caml_i_custom {
!align $01, $00
caml_i_custom
caml_i_custom__int32
        !word caml_int32_compare, caml_int32_hash
caml_i_custom__int64
        !word caml_int64_compare, caml_int64_hash
}

!ifdef caml_AUX__caml_i_alloc {
caml_i_alloc                          ;{X = NB}
        STX caml_i_alloc__nb          ;SMC: NB = operand of the LDX # below
        TXA
        LSR
        TAX
        INX                             ;X := size in words = NB / 2 + 1
        LDA # Custom_tag
        JSR caml_alloc                  ;BLK := new block, Y = 0
        LDA caml_i_alloc__nb
        CLC
        ADC # < (caml_i_custom - 4)
        STA (BLK),Y                     ;Field(0) := caml_int32/64_custom
        LDA # > (caml_i_custom - 4)
        ADC # 0
        INY
        STA (BLK),Y
        DEY
caml_i_alloc__nb = * + 1
        LDX # 0                         ;SMC: X := NB
        RTS                             ;{X = NB, Y = 0}
}

!ifdef caml_AUX__caml_i_ret {
caml_i_ret
        LDY # 0
        JMP caml_load_newblk   
}

        ;; --------------------------
        ;;   add, sub, and, or, xor
        ;; --------------------------

!ifdef caml_PRIM__caml_int32_add {
caml_int32_add
        +caml_i_stub .ADC_OPC, 4, caml_i_alu
}
!ifdef caml_PRIM__caml_int32_sub {
caml_int32_sub
        +caml_i_stub .SBC_OPC, 4, caml_i_alu
}
!ifdef caml_PRIM__caml_int32_and {
caml_int32_and
        +caml_i_stub .AND_OPC, 4, caml_i_alu
}
!ifdef caml_PRIM__caml_int32_or  {
caml_int32_or 
        +caml_i_stub .ORA_OPC, 4, caml_i_alu
}
!ifdef caml_PRIM__caml_int32_xor {
caml_int32_xor
        +caml_i_stub .EOR_OPC, 4, caml_i_alu
}
!ifdef caml_PRIM__caml_int64_add {
caml_int64_add
        +caml_i_stub .ADC_OPC, 8, caml_i_alu
}
!ifdef caml_PRIM__caml_int64_sub {
caml_int64_sub
        +caml_i_stub .SBC_OPC, 8, caml_i_alu
}
!ifdef caml_PRIM__caml_int64_and {
caml_int64_and
        +caml_i_stub .AND_OPC, 8, caml_i_alu
}
!ifdef caml_PRIM__caml_int64_or  {
caml_int64_or 
        +caml_i_stub .ORA_OPC, 8, caml_i_alu
}
!ifdef caml_PRIM__caml_int64_xor {
caml_int64_xor
        +caml_i_stub .EOR_OPC, 8, caml_i_alu
}

!ifdef caml_AUX__caml_i_bin {
caml_i_bin                            ;{X = NB}
        JSR caml_i_alloc
        LDA (SP),Y
        STA TMP                         ;TMP := ptr to the 2nd operand
        INY
        LDA (SP),Y
        STA TMP + 1
        DEY
        RTS                             ;{X = NB, Y = 0}
}

!ifdef caml_AUX__caml_i_alu {
caml_i_alu                            ;{A = opcode of "op (TMP),Y", X = NB}
        STA @opc                        ;SMC: patch the opcode
        JSR caml_i_bin
        LDY # 2
        LDA @opc
        CMP # $80                       ;C=1 only for SBC ($F1); ADC needs 0
-       LDA (ACCU),Y
@opc    ADC (TMP),Y                     ;SMC: ADC, SBC, AND, ORA, or EOR.
        STA (BLK),Y
        INY
        DEX
        BNE -
        JMP caml_i_ret
}

        ;; -------
        ;;   neg
        ;; -------

!ifdef caml_PRIM__caml_int32_neg {
caml_int32_neg
        +caml_i_stub 4, caml_i_neg
}
!ifdef caml_PRIM__caml_int64_neg {
caml_int64_neg
        +caml_i_stub 8, caml_i_neg
}

!ifdef caml_AUX__caml_i_neg {
caml_i_neg
        JSR caml_i_alloc
        LDY # 2
        SEC
-       LDA # 0
        SBC (ACCU),Y
        STA (BLK),Y
        INY
        DEX
        BNE -
        JMP caml_i_ret
}

        ;; -----------------------------------
        ;; shifts -- count is taken modulo 64,
        ;; n >= NB * 8 is unspecified in OCaml
        ;; -----------------------------------

!ifdef caml_PRIM__caml_int32_shift_left {
caml_int32_shift_left
        +caml_i_stub 4, caml_i_shl
}
!ifdef caml_PRIM__caml_int32_shift_right {
caml_int32_shift_right
        +caml_i_stub .A_SHIFT, 4, caml_i_shr
}
!ifdef caml_PRIM__caml_int32_shift_right_unsigned {
caml_int32_shift_right_unsigned
        +caml_i_stub .L_SHIFT, 4, caml_i_shr
}
!ifdef caml_PRIM__caml_int64_shift_left {
caml_int64_shift_left
        +caml_i_stub 8, caml_i_shl
}
!ifdef caml_PRIM__caml_int64_shift_right_unsigned {
caml_int64_shift_right_unsigned
        +caml_i_stub .L_SHIFT, 8, caml_i_shr
}
!ifdef caml_PRIM__caml_int64_shift_right {
caml_int64_shift_right
        +caml_i_stub .A_SHIFT, 8, caml_i_shr
}

!ifdef caml_AUX__caml_i_shp {
caml_i_shp                            ;{X = NB}
        JSR caml_i_alloc
        LDY # 2
-       LDA (ACCU),Y
        STA (BLK),Y
        INY
        DEX
        BNE -
        LDY # 0
        LDA (SP),Y                      ;low byte of Val_int(count)
        LSR
        AND # %00111111
        RTS                             ;{BLK = copy of ACCU; A = count}
}

!ifdef caml_AUX__caml_i_shl {
caml_i_shl
        JSR caml_i_shp
        BEQ @done
        STA TMP
-       LDY # 2
        LDX caml_i_alloc__nb
        CLC
@l      LDA (BLK),Y
        ROL
        STA (BLK),Y
        INY
        DEX
        BNE @l
        DEC TMP
        BNE -
@done   JMP caml_i_ret
}

!ifdef caml_AUX__caml_i_shr {
caml_i_shr                            ;{A=$80 arithmetic|0 logical, X = NB}
        STA TMP + 1
        JSR caml_i_shp
        BEQ @done
        STA TMP
-       LDY caml_i_alloc__nb
        INY                             ;Y := index of the top byte
        LDX caml_i_alloc__nb
        LDA (BLK),Y
        AND TMP + 1
        CMP # $80                       ;C = sign (arithmetic) or 0 (logical)
@l      LDA (BLK),Y
        ROR
        STA (BLK),Y
        DEY
        DEX
        BNE @l
        DEC TMP
        BNE -
@done   JMP caml_i_ret
}

        ;; --------------------------------------------
        ;; multiplication (low NB bytes of the product)
        ;; --------------------------------------------

!ifdef caml_PRIM__caml_int32_mul {
caml_int32_mul
        +caml_i_stub 4, caml_i_mul
}
!ifdef caml_PRIM__caml_int64_mul {
caml_int64_mul
        +caml_i_stub 8, caml_i_mul
}

!ifdef caml_AUX__caml_i_mul {
caml_i_mul
@P      = .MZ                           ;8 by: partial product
@N      = .MZ + 8                       ;8 by: 2nd operand
@B      = .MZ + 16                      ;multiplier byte, then result byte
@CNT    = .MZ + 17
@J      = .MZ + 18                      ;index (2...) of current multiplier byte
@W      = .MZ + 19                      ;P/N signific. by. in this pass (NB...1)
        JSR caml_i_bin
        STX @W
        LDY # 2
-       LDA (TMP),Y
        STA @N - 2,Y
        INY
        DEX
        BNE -
        LDX @W
        LDA # 0
-       DEX
        STA @P,X
        BNE -
        LDA # 2
        STA @J
@pass   LDY @J
        LDA (ACCU),Y
        LSR                             ;bit 0 -> C
        STA @B
        LDA # 8
        STA @CNT
@step   BCC @shift
        LDX # 0                         ;P += N (W bytes)
        LDY @W
        CLC
-       LDA @P,X
        ADC @N,X
        STA @P,X
        INX
        DEY
        BNE -
@shift  LDX @W                          ;(P:B) >>= 1, carry in from ADC
        DEX
-       ROR @P,X
        DEX
        BPL -
        ROR @B
        DEC @CNT
        BNE @step
        LDY @J
        LDA @B
        STA (BLK),Y
        INC @J
        DEC @W
        BNE @pass
        JMP caml_i_ret
}

        ;; -----------------------------------------
        ;; div / mod (truncated towards zero, exact)
        ;; -----------------------------------------

!ifdef caml_PRIM__caml_int32_div {
caml_int32_div
        +caml_i_stub 0, 4, caml_i_div
}
!ifdef caml_PRIM__caml_int32_mod {
caml_int32_mod
        +caml_i_stub 8, 4, caml_i_div
}
!ifdef caml_PRIM__caml_int64_div {
caml_int64_div
        +caml_i_stub 0, 8, caml_i_div
}
!ifdef caml_PRIM__caml_int64_mod {
caml_int64_mod
        +caml_i_stub 8, 8, caml_i_div
}

!ifdef caml_AUX__caml_i_div {
caml_i_div                            ;{A=result idx: 0 quot.|8 rem., X = NB}
@D      = .MZ                           ;dividend, then quotient (8 by)
@R      = .MZ + 8                       ;remainder (8 by)
@S      = .MZ + 16                      ;divisor (8 by)
@BASE   = .MZ + 24
@SGN    = .MZ + 25
@CNT    = .MZ + 26
        STA @BASE
        JSR caml_i_bin
        STY @SGN                        ;OR of the divisor bytes
        LDY # 2
-       LDA (ACCU),Y
        STA @D - 2,Y
        LDA (TMP),Y
        STA @S - 2,Y
        ORA @SGN
        STA @SGN
        INY
        DEX
        BNE -
        LDA @SGN
        BNE +
        +caml_raise Division_by_zero
+       LDX caml_i_alloc__nb
        LDA @D - 1,X
        STA @SGN                        ;bit 7 := sign of the dividend
        LDA @BASE
        BNE +                           ;rem.: sign of the dividend
        LDA @SGN
        EOR @S - 1,X                    ;quot.: dividend sign EOR divisor sign
        STA @SGN
+       LDA @D - 1,X
        BPL +
        LDX # 0
        JSR @neg                        ;D := |D|
        LDX caml_i_alloc__nb
+       LDA @S - 1,X
        BPL +
        LDX # 16
        JSR @neg                        ;S := |S|
+       LDA # 0                         ;R := 0
        LDY # 7
-       STA @R,Y
        DEY
        BPL -
        LDA caml_i_alloc__nb
        ASL
        ASL
        ASL
        STA @CNT                        ;8 * NB steps
@bit    CLC                             ;(D:R) <<= 1
        LDX # 0
        JSR @rol
        LDX # 8
        JSR @rol
        SEC                             ;BLK := R - S (scratch)
        LDY # 2
        LDX caml_i_alloc__nb
-       LDA @R - 2,Y
        SBC @S - 2,Y
        STA (BLK),Y
        INY
        DEX
        BNE -
        BCC @next                       ;R < S
        LDY # 2                         ;R := R - S, quotient bit := 1
        LDX caml_i_alloc__nb
-       LDA (BLK),Y
        STA @R - 2,Y
        INY
        DEX
        BNE -
        INC @D
@next   DEC @CNT
        BNE @bit
        BIT @SGN
        BPL +
        LDX @BASE
        JSR @neg                        ;negate the selected result
+       LDA caml_i_alloc__nb
        CLC
        ADC # 2
        STA @CNT
        LDX @BASE
        LDY # 2
-       LDA @D,X
        STA (BLK),Y
        INX
        INY
        CPY @CNT
        BNE -
        JMP caml_i_ret
@neg    SEC                             ;negate NB bytes at @D + X
        LDY caml_i_alloc__nb
-       LDA # 0
        SBC @D,X
        STA @D,X
        INX
        DEY
        BNE -
        RTS
@rol    LDY caml_i_alloc__nb          ;ROL NB bytes at @D + X
-       ROL @D,X
        INX
        DEY
        BNE -
        RTS
}

        ;; -----------
        ;; conversions
        ;; -----------

!ifdef caml_PRIM__caml_int32_of_int {
caml_int32_of_int
        +caml_i_stub 4, caml_i_of_int
}
!ifdef caml_PRIM__caml_int32_to_int {
caml_int32_to_int = caml_i_to_int
}
!ifdef caml_PRIM__caml_int32_bswap {
caml_int32_bswap
        +caml_i_stub 4, caml_i_bswap
}
!ifdef caml_PRIM__caml_int64_of_int {
caml_int64_of_int
        +caml_i_stub 8, caml_i_of_int
}
!ifdef caml_PRIM__caml_int64_of_int32 {
caml_int64_of_int32
        +caml_i_stub 8, caml_i_conv
}
!ifdef caml_PRIM__caml_int64_to_int32 {
caml_int64_to_int32
        +caml_i_stub 4, caml_i_conv
}
!ifdef caml_PRIM__caml_int64_to_int {
caml_int64_to_int = caml_i_to_int
}
!ifdef caml_PRIM__caml_int64_bswap {
caml_int64_bswap
        +caml_i_stub 8, caml_i_bswap
}

!ifdef caml_AUX__caml_i_of_int {
caml_i_of_int                         ;ACCU = Val_int(n), 15-bit signed
        JSR caml_i_alloc
        LDA ACCU + 1
        CMP # $80                       ;C := sign
        ROR                             ;arithmetic shift of Val_int
        STA TMP
        LDA ACCU
        ROR
        LDY # 2
        STA (BLK),Y
        INY
        LDA TMP
        STA (BLK),Y
        INY
        JMP caml_i_sext               ;fill the upper bytes with the sign
}

!ifdef caml_AUX__caml_i_sext {
caml_i_sext                           ;{Y=1st byte to fill}:
                                        ;BLK[Y...NB+1] := sign of BLK[Y-1]
        LDA caml_i_alloc__nb
        CLC
        ADC # 2
        STA TMP                         ;TMP := index past the last byte
        DEY
        LDA (BLK),Y
        INY
        ASL                             ;C := sign
        LDA # 0
        SBC # 0
        EOR # $FF                       ;A := $FF if negative, else 0
-       CPY TMP
        BEQ +
        STA (BLK),Y
        INY
        BNE -
+       JMP caml_i_ret
}

!ifdef caml_AUX__caml_i_conv {
caml_i_conv                           ;{X = NB of the result}
        JSR caml_i_alloc              ;copy the low 4 bytes, sign-extend
        LDY # 2
-       LDA (ACCU),Y
        STA (BLK),Y
        INY
        CPY # 6
        BNE -
        JMP caml_i_sext
}

!ifdef caml_AUX__caml_i_to_int {
caml_i_to_int                         ;only the low 15 bits matter
        LDY # 2
        LDA (ACCU),Y
        SEC
        ROL
        TAX
        INY
        LDA (ACCU),Y
        ROL
        STA ACCU + 1
        STX ACCU
        LDY # 0
        RTS
}

!ifdef caml_AUX__caml_i_bswap {
caml_i_bswap                          ;push NB bytes, pop them back
        JSR caml_i_alloc
        LDY # 2
-       LDA (ACCU),Y
        PHA
        INY
        DEX
        BNE -
        LDX caml_i_alloc__nb
        LDY # 2
-       PLA
        STA (BLK),Y
        INY
        DEX
        BNE -
        JMP caml_i_ret
}

;; float -> int, truncated towards zero, without C64_QINT because it's bugged.  
;; The 32-bit mantissa is copied MSB first at the top of a big-endian NB-byte
;; magnitude M, shifted right by 8*NB - e bits (e = exponent - 128), then
;; negated if needed.

!ifdef caml_PRIM__caml_int32_of_float {
caml_int32_of_float
        +caml_i_stub 4, caml_i_of_float
}
!ifdef caml_PRIM__caml_int64_of_float {
caml_int64_of_float
        +caml_i_stub 8, caml_i_of_float
}

!ifdef caml_AUX__caml_i_of_float {
caml_i_of_float
        JSR caml_i_alloc
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA # 0                         ;M := 0 (.MZ[0...7])
        LDX # 7
-       STA .MZ,X
        DEX
        BPL -
        LDA C64_FAC                     ;biased exponent
        CMP # 129
        BCC @store                      ;|x| < 1, or x = 0
        SBC # 128                       ;C = 1: A := e
        STA TMP
        LDA caml_i_alloc__nb
        ASL
        ASL
        ASL                             ;8 * NB
        SEC
        SBC TMP                         ;A := s = 8*NB - e
        BCC @store                      ;out of range: unspecified, return 0
        STA TMP
        LDX # 3
-       LDA C64_FAC + 1,X
        STA .MZ,X                       ;mantissa, MSB first
        DEX
        BPL -
        LDA TMP
        BEQ @sign
@shr    CLC                             ;M >>= 1
        LDX # 0
        LDY caml_i_alloc__nb
-       ROR .MZ,X
        INX
        DEY
        BNE -
        DEC TMP
        BNE @shr
@sign   BIT C64_FAC + 5
        BPL @store
        LDX caml_i_alloc__nb          ;M := -M, from the last byte
        DEX
        SEC
-       LDA # 0
        SBC .MZ,X
        STA .MZ,X
        DEX
        BPL -
@store  LDX caml_i_alloc__nb          ;BLK := M, little endian
        DEX
        LDY # 2
-       LDA .MZ,X
        STA (BLK),Y
        INY
        DEX
        BPL -
        JMP caml_i_ret
}

        ;; -------------------------
        ;; custom ops: compare, hash
        ;; -------------------------

!ifdef caml_PRIM__caml_int32_compare {
caml_int32_compare
        +caml_i_stub 4, caml_i_compare
}
!ifdef caml_PRIM__caml_int32_hash {
caml_int32_hash
        +caml_i_stub 4, caml_i_hash
}
!ifdef caml_PRIM__caml_int64_compare {
caml_int64_compare
        +caml_i_stub 8, caml_i_compare
}
!ifdef caml_PRIM__caml_int64_hash {
caml_int64_hash
        +caml_i_stub 8, caml_i_hash
}

!ifdef caml_AUX__caml_i_compare {
caml_i_compare                        ;{X = NB, Y = 0}
        DEX                             ;NB-1 uns. bytes, then the signed one
        STY .MZ + 2                     ;OR of the differences
        LDA (SP),Y
        STA .MZ
        INY
        LDA (SP),Y
        STA .MZ + 1
        SEC
-       INY
        LDA (ACCU),Y
        SBC (.MZ),Y
        ORA .MZ + 2
        STA .MZ + 2
        DEX
        BNE -
        INY
        LDA (ACCU),Y
        SBC (.MZ),Y                     ;top byte: signed difference
        TAX                             ;X := raw difference (EOR below may
        ORA .MZ + 2                     ; turn a non-zero one into 0, e.g. $80)
        STA .MZ + 2                     ;OR of all raw differences
        TXA                             ;(TAX/ORA/STA/TXA leave V untouched)
        BVC +
        EOR # $80                       ;overflow: true sign is inverted
+       BMI @lt
        LDY # 0
        STY ACCU + 1
        LDA .MZ + 2
        BNE +                           ;greater
        LDA # <Val_zero
        STA ACCU
        RTS
+       LDA # <Val_one
        STA ACCU
        RTS
@lt     LDY # $FF
        STY ACCU
        STY ACCU + 1
        INY
        RTS
}

!ifdef caml_AUX__caml_i_hash {
caml_i_hash                           ;{X = NB, Y = 0}:
                                        ;Val_int(xor(hi half):xor(lo half))
        TXA
        TAY
        INY                             ;Y := last data byte
        TXA
        LSR
        STA .MZ                         ;.MZ := NB / 2
        JSR @fold
        PHA
        JSR @fold
        SEC
        ROL
        STA ACCU
        PLA
        ROL
        STA ACCU + 1
        LDY # 0
        RTS
@fold   LDX .MZ
        LDA # 0
-       EOR (ACCU),Y
        DEY
        DEX
        BNE -
        RTS
}

}       ;; !zone caml_INTEGERS
