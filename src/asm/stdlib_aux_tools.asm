;; -----------------------------------------------------------------------------
;;                              AUXILIARY TOOLS
;; -----------------------------------------------------------------------------

!zone AUX_TOOLS {

.dummy = $1234                          ;dummy operand for self-modifying
                                        ;code (SMC in comments)

!ifdef caml_AUX__caml_memcpy {
        ;; Copy a contiguous memory area.  Start address in TMP (wo.),
        ;; destination address in TMP + 2 (wo.), size in TMP + 4 (wo.).
        ;; Source and destination areas may overlap.
        ;; Used registers: A, X, Y. Return Y = 0.
caml_memcpy
        @FROM = TMP                     ;source address
        @TO = TMP + 2                   ;destination address
        @NUM = TMP + 4                  ;num bytes
        LDA @FROM + 1
        CMP @TO + 1
        BCC .caml_memcpy__up
        BNE .caml_memcpy__dn
        LDA @FROM
        CMP @TO
        BCC .caml_memcpy__up
        BNE .caml_memcpy__dn
        RTS                             ;just in case @FROM = @TO
.caml_memcpy__dn
        ;; copy from a higher address to a lower one
        LDY # 0
        LDX @NUM + 1
        BEQ +
-       LDA (@FROM),Y                   ;move a page at a time
        STA (@TO),Y
        INY
        BNE -
        INC @FROM + 1
        INC @TO + 1
        DEX
        BNE -
+       LDX @NUM
        BEQ +
-       LDA (@FROM),Y                   ;move the remaining bytes
        STA (@TO),Y
        INY
        DEX
        BNE -
+       LDY # 0
        RTS
.caml_memcpy__up
        ;; copy from a lower address to a higher one
        LDX @NUM + 1                    ;the last byte must be moved first
        CLC                             ;start at the final pages of from & to
        TXA
        ADC @FROM + 1
        STA @FROM + 1
        CLC
        TXA
        ADC @TO + 1
        STA @TO + 1
        INX                             ;allows use of BNE after DEX below
        LDY @NUM
        BEQ ++
        DEY                             ;move bytes on the last page first
        BEQ +
-       LDA (@FROM),Y
        STA (@TO),Y
        DEY
        BNE -
+       LDA (@FROM),Y                   ;handle Y = 0 separately
        STA (@TO),Y
++      DEY
        DEC @FROM + 1                   ;move the next page (if any)
        DEC @TO + 1
        DEX
        BNE -
        LDY # 0
        RTS
}

!ifdef  caml_AUX__caml_blkcpy {
        ;; Copy all fields from ACCU to BLK; C:Y = 2 * #fields.
        ;; The block's header is not copied!
caml_blkcpy
        BCC +                           ; less than 256 bytes (<128 fields)
        BEQ ++                          ; exactly 256 bytes   (=128 fields)
        INC ACCU + 1                    ; more than 256 bytes (>128 fields)
        INC BLK + 1
--
+       DEY
-       LDA (ACCU),Y
        STA (BLK),Y
        DEY
        BNE -
        LDA (ACCU),Y                    ; handle Y = 0 apart
        STA (BLK),Y
        BCC +
        DEC ACCU + 1
        DEC BLK + 1
++      CLC
        BCC --
+       RTS
}

!ifdef  caml_AUX__caml_err_index_oob {
caml_err_index_oob
        ;; Raise the exn below.
        +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef  caml_AUX__caml_ptr_add2A {
        ;; Add 2 * A to a ZP pointer.
caml_ptr_add2A
        ASL                             ;{X = ptr addr, A = n}
        BCC +
        INC 1,X
        CLC
+       ADC 0,X
        STA 0,X
        BCC +
        INC 1,X
+       RTS                             ;{X = ptr addr, A = <2n, ptr += 2n}
}

!ifdef  caml_AUX__caml_IntValx3 {
        ;; A := 3 * Int_Val(A)
        ;; E.g.: A = %00010001 (value 8) ==> A := %00011000 (int 24)
caml_IntValx3                           ;{A = v : int}
        LSR
        STA @adc + 1                    ;SMC: set arg for ADC# below
        ASL
       ;CLC
@adc    ADC # <.dummy                   ;SMC: ADC # Int_Val(v)
        RTS                             ;{A = 3 * IntVal(v), C = overflow}
}

!ifdef  caml_AUX__caml_block_fill0 {
        ;; Fill in the first X fields of the block in BLK with Val_Int(0).
        ;; No checks on X nor BLK.
caml_block_fill0                        ;{X = #fields, Y = 0}
        LDA BLK + 1
        PHA
-       LDA # < Val_zero
        STA (BLK),Y
        INY
        LDA # > Val_zero
        STA (BLK),Y
        INY
        BNE +
        INC BLK + 1
+       DEX
        BNE -
        PLA
        STA BLK + 1
        LDY # 0
        RTS                             ;{A = BLK + 1, X = 0, Y = 0}
}

!ifdef  caml_AUX__caml_mkatom0 {
        ;; ACCU := Atom(0)
caml_mkatom0
        LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
}

}       ;; !zone AUX_TOOLS
