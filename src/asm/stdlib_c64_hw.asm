;; -----------------------------------------------------------------------------
;;                       C64.Hw.Mem - LOW LEVEL MEMORY ACCESS
;; -----------------------------------------------------------------------------
;; Address encodings (OCaml ints are 15 bit, addresses are 16 bit):
;;  - short form  (peek, poke):         the tagged int, sign-extended, IS the
;;      address: 0..$3FFF -> $0000-$3FFF, -16384..-1 -> $C000-$FFFF.
;;  - page form   (peek_at, poke_at):   address = page * 256 + off, both 0..255.
;; poke/poke_at refuse addresses in [$0000, caml_stack_end) (Invalid_argument);
;; unsafe_poke/unsafe_poke_at do not check anything. The value is masked to 8 bits.
;; peek_ram/peek_at_ram read the RAM under the ROMs/I/O (interrupts disabled).

;; short form: ACCU := sign-extended Int_val(ACCU)
!zone caml_C64_HW {

!macro caml_hw_addr_short {
        LDA ACCU + 1
        CMP # $80
        ROR ACCU + 1
        ROR ACCU
}
;; page form: ACCU = page, SP[0] = off -> ACCU := page * 256 + off   {Y = 0}
!macro caml_hw_addr_page {
        LSR ACCU + 1
        ROR ACCU
        LDX ACCU                        ;X := page
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR                             ;A := off
        STA ACCU
        STX ACCU + 1
}
;; C := 1 iff ACCU (address) >= caml_stack_end (unsigned 16 bit compare)
!macro caml_hw_check {
        LDA ACCU
        CMP # <caml_stack_end
        LDA ACCU + 1
        SBC # >caml_stack_end
}
;; A := low 8 bits of Int_val(SP[.n])   {leaves Y = 0}
!macro caml_hw_value .n {
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # 0
}
!macro caml_hw_ret_int {                ;ACCU := Val_int(A)
        STY ACCU + 1
        SEC
        ROL
        STA ACCU
        ROL ACCU + 1
}
!macro caml_hw_ret_unit {
        LDX # <Val_unit
        STX ACCU
        STY ACCU + 1
}
!macro caml_hw_read_ram {               ;A := RAM[ACCU], I flag preserved
        PHP
        SEI
        LDA C64_R6510
        PHA
        AND # $F8
        STA C64_R6510
        LDA (ACCU),Y
        TAX
        PLA
        STA C64_R6510
        PLP
        TXA
}

!ifdef caml_PRIM__caml_nonstd_hw_peek {
caml_nonstd_hw_peek
        +caml_hw_addr_short
        LDA (ACCU),Y
        +caml_hw_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_peek_ram {
caml_nonstd_hw_peek_ram
        +caml_hw_addr_short
        +caml_hw_read_ram
        +caml_hw_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_peek_at {
caml_nonstd_hw_peek_at
        +caml_hw_addr_page
        LDY # 0
        LDA (ACCU),Y
        +caml_hw_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_peek_at_ram {
caml_nonstd_hw_peek_at_ram
        +caml_hw_addr_page
        LDY # 0
        +caml_hw_read_ram
        +caml_hw_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_unsafe_poke {
caml_nonstd_hw_unsafe_poke
        +caml_hw_addr_short
        +caml_hw_value 0
        STA (ACCU),Y
        +caml_hw_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_poke {
caml_nonstd_hw_poke
        +caml_hw_addr_short
        +caml_hw_check
        BCC @err
        +caml_hw_value 0
        STA (ACCU),Y
        +caml_hw_ret_unit
        RTS
@err    +caml_raise Invalid_argument, "C64.Hw.Mem.poke"
}

!ifdef caml_PRIM__caml_nonstd_hw_unsafe_poke_at {
caml_nonstd_hw_unsafe_poke_at
        +caml_hw_addr_page
        +caml_hw_value 1
        STA (ACCU),Y
        +caml_hw_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_hw_poke_at {
caml_nonstd_hw_poke_at
        +caml_hw_addr_page
        LDY # 0
        +caml_hw_check
        BCC @err
        +caml_hw_value 1
        STA (ACCU),Y
        +caml_hw_ret_unit
        RTS
@err    +caml_raise Invalid_argument, "C64.Hw.Mem.poke_at"
}

}
