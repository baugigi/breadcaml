;; -----------------------------------------------------------------------------
;;                                   FLOATS
;; -----------------------------------------------------------------------------

;; ZP locations used by the C64's BASIC ROM float routines and by Breadcaml:

;; Breadcaml Address BASIC float routines
;; --------- ------- ----------------------------------------------------------
;; XARGS     $02      <UNUSED>
;; <UNUSED>  $12     used by tan and, preparing tan, by sin/cos routines
;; <UNUSED>  $22-$23 used to move variables into FAC/ARG and back to memory
;; <UNUSED>  $24-$25 used during FP comparisons and PETSCII to FP conversion
;; <UNUSED>  $26-$2A result of multiplication or division
;; ENV       $2B-$2C  <UNUSED>
;; TRAPSP    $2D-$2E  <UNUSED>
;; Interpr.  $2F-$3D  <UNUSED>
;; GC        $3E-$45  <UNUSED>
;; <UNUSED>  $47     used by FOUT
;; HEAP      $49-$4A  <UNUSED>
;; BLK       $4B-$4C  <UNUSED>
;; TMP+0,8   $4D-$55  <UNUSED>
;; TMP+9     $56     used in addition, subtraction, and by the exp function
;; TMP+10,14 $57-$5B  <UNUSED>
;; TMP+15,19 $5C-$60 used by the PETSCII conversion routines
;; TMP+20    $61     FAC exponent
;; TMP+21,24 $62-$65 FAC mantissa
;; TMP+25    $66     FAC sign in bit 7
;; TMP+26    $67     used by trig, exp, log, and PETSCII to FP conversion
;; TMP+27    $68     used during normalisation and FP to integer conversion
;; TMP+28    $69     ARG exponent
;; TMP+29,32 $6A-$6D ARG mantissa
;; TMP+33    $6E     ARG sign in bit 7
;; TMP+34    $6F     sign result of arithm. operations, set when ARG is loaded
;; TMP+35    $70     FAC low order rounding byte, cleared when FAC is loaded
;; TMP+36,37 $71-$72 used for series eval and PETSCII to FP conversion
;; ACCU      $FB-$FC  <UNUSED>
;; SP        $FD-$FE  <UNUSED>


!zone caml_FLOATS {

.dummy = $1234                          ;dummy operand for self-modifying code
                                        ;(SMC in comments)

!ifdef caml_PRIM__caml_nonstd_sign_float {
caml_nonstd_sign_float
        ;; Stdlib.sign_float
        LDA (ACCU),Y                    ;Read byte #0 (exponent)
        BEQ @zero                       ;Exponent=0 <=> float=0.
        INY
        LDA (ACCU),Y                    ;Read byte #1 (mantissa, msb)
        BPL @pos                        ;If the mantissa is negative,
        LDY # $FF                       ; set ACCU=Val_Int(-1)
        STY ACCU + 1
        STY ACCU
        INY
        RTS
@pos    DEY                             ;else
        LDA # Val_one                   ; set ACCU=Val_Int(1)
        BNE @store                      ; BNE=JMP.
@zero   LDA # Val_zero                  ;Zero: set ACCU=Val_Int(0).
@store  STA ACCU
        STY ACCU + 1
        RTS                             ;Y=0 at exit.
}

!ifdef caml_PRIM__caml_neg_float {
caml_neg_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_NEGOP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_abs_float {
caml_abs_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_ABS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_exp_float {
caml_exp_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_EXP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_expm1_float {
caml_expm1_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_EXP
        LDA # <C64_M1
        LDY # >C64_M1
        +caml_JSR_BASROM C64_FADD
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log_float {
caml_log_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log1p_float {
caml_log1p_float
        JSR caml_float_unop
        LDA # <C64_ONE
        LDY # >C64_ONE
        +caml_JSR_BASROM C64_FADD
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log10_float {
.ln10m1 !h 7f 5e 5b d8 a9       ;(ln 10)^-1
caml_log10_float
        ;; log10 x = ln x / ln 10
        JSR caml_float_unop
        +caml_JSR_BASROM C64_LOG
  !if caml_log10_float <= C64_BASROM {
        LDA # <.ln10m1
        LDY # >.ln10m1
  } else {
        LDY # 5
-       LDA .ln10m1 - 1,Y
        STA TMP - 1,Y
        DEY
        BNE -
        LDA # TMP
  }
        +caml_JSR_BASROM C64_FMUL
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sin_float {
caml_sin_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_SIN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_cos_float {
caml_cos_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_COS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_tan_float {
caml_tan_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_TAN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sqrt_float {
caml_sqrt_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_SQR
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_atan_float {
caml_atan_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_ATN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_floor_float {
caml_floor_float
        JSR caml_float_unop
        +caml_JSR_BASROM C64_INT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ceil_float {
caml_ceil_float
        ;; let ceil x = -.(floor (-. x))
        JSR caml_float_unop
        +caml_JSR_BASROM C64_NEGOP
        +caml_JSR_BASROM C64_INT
        +caml_JSR_BASROM C64_NEGOP
+       JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_classify_float {
caml_classify_float
        +Val_Int ~@FP_normal,    0      ;order must match variants in
        +Val_Int ~@FP_subnormal, 1      ;type Float.fpclass
        +Val_Int ~@FP_zero,      2
        +Val_Int ~@FP_infinite,  3
        +Val_Int ~@FP_nan,       4
        LDA (ACCU),Y
        STY ACCU + 1                    ;.Y = 0
        BEQ +
        LDA # @FP_normal
        STA ACCU
        RTS
+       LDA # @FP_zero
        STA ACCU
        RTS
}

!ifdef caml_PRIM__caml_int_of_float {
caml_int_of_float
        JSR caml_float_unop
        LDA C64_FAC + 5                 ;FAC sign byte
        PHA                             ;save sign
        LDA # 0
        STA C64_FAC + 5                 ;FAC := |FAC| (FACINX floors, OCaml
        +caml_JSR_BASROM C64_FACINX     ; truncates) => result in Y(lo), A(hi)
        STY ACCU
        STA ACCU + 1
        PLA
        BPL +                           ;negative argument:
        SEC                             ; negate the (truncated) magnitude
        LDA # 0
        SBC ACCU
        STA ACCU
        LDA # 0
        SBC ACCU + 1
        STA ACCU + 1
+       SEC
        ROL ACCU                        ;OCaml int repr
        ROL ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_float_of_int {
caml_float_of_int
        LDA ACCU + 1
        CMP # $80                       ;CMP + ROR = arithm. shift right
        ROR
        TAX
        ROR ACCU
        LDY ACCU
        TXA
        +caml_JSR_BASROM C64_GIVAYF
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_copysign_float {
caml_copysign_float
        JSR caml_float_unop
        LDA (SP),Y
        STA ACCU
        INY
        LDA (SP),Y
        STA ACCU + 1
        LDA (ACCU),Y                    ;.Y = 1, load 1st mantissa byte
        STA C64_FAC + 5                 ;copy it to FAC sign byte
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_float_of_string {
caml_float_of_string
        LDA C64_CHRPTR
        STA TMP
        LDA C64_CHRPTR + 1
        STA TMP + 1
        LDA ACCU
        STA C64_CHRPTR
        LDA ACCU + 1
        STA C64_CHRPTR + 1
        JSR C64_CHRGOT                  ;not a BASIC ROM routine
        +caml_JSR_BASROM C64_FIN
        LDA TMP
        STA C64_CHRPTR
        LDA TMP + 1
        STA C64_CHRPTR + 1
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ldexp_float {
        ;; compute ACCU * 2 ^ N, -255 < N < 255.
        ;; SP[0] = Val_int(N) (usual tagged int, two's complement if N < 0)
caml_ldexp_float
        LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc                  ;{Y = 0}
        LDA (ACCU),Y                    ;(biased) exponent of the source
        BEQ @save                       ;0.0 * 2^N = 0.0: don't add N to exp 0
        STA TMP
        INY
        LDA (SP),Y                      ;hi byte of Val_int(N)
        TAX                             ;X: bit 7 = sign of N
        LSR                             ;C := bit 0 of hi byte
        DEY
        LDA (SP),Y
        ROR                             ;A := low byte of N (two's complement)
        STA TMP + 1
        TXA
        BMI @neg                        ;N < 0 ?
        LDA TMP + 1                     ;no: exp := exp + N
        CLC
        ADC TMP
        BCC @save
        LDX # C64_ERR_OVF               ; manage overflow (error)
        JMP (C64_IERROR)
@neg    LDA TMP + 1                     ;yes: exp := exp - |N| = exp + (256-|N|)
        CLC
        ADC TMP
        BCS @save                       ; if underflow,
        LDA # 0                         ;  set exp = 0 (result = 0.0)
@save   STA (BLK),Y                     ;save exp byte (Y = 0)
        BEQ +                           ;skip copy of mantissa if zero
        LDY # 4
-       LDA (ACCU),Y                    ;copy mantissa
        STA (BLK),Y
        DEY
        BNE -
+       JMP caml_load_newblk
}

!ifdef caml_PRIM__caml_frexp_float {
caml_frexp_float
        ;; allocate a new float with same mantissa and exp=0
        LDA # Double_tag                ;tag of new float
        LDX # Double_wosize             ;size of new float
        JSR caml_alloc                  ;alloc new float
        LDA (ACCU),Y                    ;load (biased) exponent
        PHA                             ;save it for later
        BNE @nz                         ;float is 0.0?
        STA (BLK),Y                     ;yes: set new float exp = 0
        BEQ @pair                       ; and go further
@nz     LDA # $80                       ;no: set new float exp = $80
        STA (BLK),Y
        LDY # 4                         ; then copy the mantissa
-       LDA (ACCU),Y
        STA (BLK),Y
        DEY
        BNE -
@pair   JSR caml_load_newblk            ;ACCU = new float
        ;; allocate a new pair (float * int)
        LDA # 0                         ;tag of new pair
        LDX # 2                         ;size of new pair
        JSR caml_alloc                  ;alloc new pair
        ;; set pair elements
        LDA ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y                     ;field0 := new float
        INY
        LDX # 0
        PLA                             ;reload biased exponent
        BNE @debias                     ;exp = 0?
        LDA # <Val_zero                 ;yes:
        STA (BLK),Y                     ; set field1,lo := <Val_int(0)
        LDA # >Val_zero
        BEQ @fld1h                      ; beq=jmp to set field1,hi
@debias SEC                             ;no:
        SBC # $80                       ; compute debiased exponent
        BCS @valint                     ; if negative,
        DEX                             ;  set hi byte = $FF
        SEC
@valint ROL                             ; compute <Val_int(exponent)
        STA (BLK),Y                     ; field1,lo := <Val_int(exponent)
        TXA
        ROL                             ; compute >Val_int(exponent)
@fld1h  INY
        STA (BLK),Y                     ;field1,hi := >Val_int(exponent)
        LDY # 0
        JMP caml_load_newblk   
}

!ifdef caml_PRIM__caml_add_float {
caml_add_float
        JSR caml_float_binop
        +caml_JSR_BASROM C64_FADDT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sub_float {
caml_sub_float
        JSR caml_float_binop
        +caml_JSR_BASROM C64_FSUBT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_mul_float {
caml_mul_float
        JSR caml_float_binop
        +caml_JSR_BASROM C64_FMULT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_div_float {
caml_div_float
        JSR caml_float_binop
        +caml_JSR_BASROM C64_FDIVT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_power_float {
caml_power_float
        JSR caml_float_binop
        +caml_JSR_BASROM C64_FPWRT
        JMP caml_float_alloc_result
}


;; Auxiliary routines

;; copy ACCU to FAC
!ifdef caml_AUX__caml_float_unop {
caml_float_unop
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JMP caml_float_loadFAC
}

;; copy SP[0] to FAC and ACCU to ARG
!ifdef caml_AUX__caml_float_binop {
caml_float_binop
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
       ;DEY                             ;caml_float_alloc_result will set Y=0
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JMP caml_float_loadARG
}

;; Copy FAC (operation result) to a new allocated float
!ifdef caml_AUX__caml_float_alloc_result {
caml_float_alloc_result
        LDA # Double_tag
        LDX # Double_wosize
        LDY # 0
        JSR caml_alloc
        LDX BLK
        LDY BLK + 1
        +caml_JSR_BASROM C64_MOVMF
        LDY # 0
        JMP caml_load_newblk   
}

;; FAC/ARG loading routines -- how to use: 1) write float address in
;; caml_float_loadFAC/ARG__addr; 2) JSR caml_float_loadFAC/ARG

!ifdef caml_AUX__caml_float_loadFAC {
caml_float_loadFAC
        LDX # 4
caml_float_loadFAC__addr = * + 1
-       LDA .dummy,X                    ;SMC: replaced with real address
        STA C64_FAC,X
        DEX
        BPL -
        LDA C64_FAC + 1                 ;copy 1st byte of mantissa
        STA C64_FAC + 5                 ;to FAC sign byte
        ORA # $80
        STA C64_FAC + 1                 ;set 1st bit of mantissa = 1
        INX
        STX C64_FACRND                  ;FAC round byte := 0
        RTS
}

!ifdef caml_AUX__caml_float_loadARG {
caml_float_loadARG
        LDX # 4
caml_float_loadARG__addr = * + 1
-       LDA .dummy,X                    ;SMC: replaced with real address
        STA C64_ARG,X
        DEX
        BPL -
        LDX C64_ARG + 1                 ;copy 1st byte of mantissa
        STX C64_ARG + 5                 ;to ARG sign byte
        TXA
        EOR C64_FAC + 5                 ;compare with FAC sign byte
        STA C64_ARISGN                  ;store result of comparison
        TXA
        ORA # $80
        STA C64_ARG + 1                 ;set 1st bit of mantissa = 1
        LDA C64_FAC                     ;.A := FAC exponent
        RTS
}

}      ;; !zone caml_FLOATS
