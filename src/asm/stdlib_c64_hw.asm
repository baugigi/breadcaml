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

caml_hw_CIA2TAL = $DD04
caml_hw_CIA2TAH = $DD05
caml_hw_CIA2ICR = $DD0D
caml_hw_CIA2CRA = $DD0E
caml_hw_NMI_DEF = $FE47                 ;default Kernal NMI vector

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
!macro caml_hw_int16 .n {               ;TMP,TMP+1 := Int_val(SP[.n])  {Y = 0}
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        STA TMP + 1
        DEY
        LDA (SP),Y
        ROR
        STA TMP
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

;; ---- block operations --------------------------------------------------------
;; fill_at page off len v / blit_at spage soff dpage doff len
;; len is 0..16383. The checked versions raise Invalid_argument if the (first)
;; destination address is below caml_stack_end, if len is negative, or if the
;; destination range wraps around $FFFF. A range ending exactly at $FFFF is ok.
;; blit_at works also if source and destination overlap.

!ifdef caml_AUX__caml_hw_fill {
caml_hw_fill
        ;; ACCU = destination, TMP,TMP+1 = count, A = value
        LDX TMP + 1                     ;X := number of full pages
        BEQ @rem
@page   LDY # 0
@byte   STA (ACCU),Y
        INY
        BNE @byte
        INC ACCU + 1
        DEX
        BNE @page
@rem    LDY TMP                         ;Y := remaining bytes
        BEQ @done
@rbyte  DEY
        STA (ACCU),Y
        BNE @rbyte
@done   LDY # 0
        +caml_hw_ret_unit
        RTS
}

!ifdef caml_AUX__caml_hw_blit {
caml_hw_blit
        ;; ACCU = source, TMP+4,TMP+5 = destination, TMP,TMP+1 = count
        LDA TMP + 4
        CMP ACCU
        LDA TMP + 5
        SBC ACCU + 1
        BCS @bwd                        ;destination >= source: copy backwards
        LDX TMP + 1                     ;forward copy: X := full pages
        BEQ @frem
@fpage  LDY # 0
@fbyte  LDA (ACCU),Y
        STA (TMP + 4),Y
        INY
        BNE @fbyte
        INC ACCU + 1
        INC TMP + 5
        DEX
        BNE @fpage
@frem   LDY # 0
        CPY TMP
        BEQ @done
@frbyte LDA (ACCU),Y
        STA (TMP + 4),Y
        INY
        CPY TMP
        BNE @frbyte
@done   LDY # 0
        +caml_hw_ret_unit
        RTS
@bwd    CLC                             ;backward copy: point both addresses
        LDA ACCU + 1                    ; to the end of the last full page,
        ADC TMP + 1                     ; copy the remainder first, then the
        STA ACCU + 1                    ; full pages from the top.
        CLC
        LDA TMP + 5
        ADC TMP + 1
        STA TMP + 5
        LDY TMP
        BEQ @bpages
        DEY
@brbyte LDA (ACCU),Y
        STA (TMP + 4),Y
        DEY
        CPY # $FF
        BNE @brbyte
@bpages LDX TMP + 1
        BEQ @bdone
@bpage  DEC ACCU + 1
        DEC TMP + 5
        LDY # $FF
@bbyte  LDA (ACCU),Y
        STA (TMP + 4),Y
        DEY
        CPY # $FF
        BNE @bbyte
        DEX
        BNE @bpage
@bdone  JMP @done
}

!ifdef caml_PRIM__caml_nonstd_hw_unsafe_fill_at {
caml_nonstd_hw_unsafe_fill_at
        +caml_hw_addr_page
        +caml_hw_int16 1
        +caml_hw_value 2
        JMP caml_hw_fill
}

!ifdef caml_PRIM__caml_nonstd_hw_fill_at {
caml_nonstd_hw_fill_at
        +caml_hw_addr_page
        +caml_hw_int16 1
        LDA ACCU
        CMP # <caml_stack_end
        LDA ACCU + 1
        SBC # >caml_stack_end
        BCC @err                        ;destination below caml_stack_end
        LDA TMP + 1
        CMP # $40
        BCS @err                        ;negative length
        LDA ACCU
        CLC
        ADC TMP
        STA TMP + 2
        LDA ACCU + 1
        ADC TMP + 1
        BCC @ok
        ORA TMP + 2
        BNE @err                        ;wraps around $FFFF
@ok     +caml_hw_value 2
        JMP caml_hw_fill
@err    +caml_raise Invalid_argument, "C64.Hw.Mem.fill_at"
}

!ifdef caml_PRIM__caml_nonstd_hw_unsafe_blit_at {
caml_nonstd_hw_unsafe_blit_at
        +caml_hw_addr_page
        +caml_hw_value 1
        STA TMP + 5
        +caml_hw_value 2
        STA TMP + 4
        +caml_hw_int16 3
        JMP caml_hw_blit
}

!ifdef caml_PRIM__caml_nonstd_hw_blit_at {
caml_nonstd_hw_blit_at
        +caml_hw_addr_page
        +caml_hw_value 1
        STA TMP + 5
        +caml_hw_value 2
        STA TMP + 4
        +caml_hw_int16 3
        LDA TMP + 4
        CMP # <caml_stack_end
        LDA TMP + 5
        SBC # >caml_stack_end
        BCC @err                        ;destination below caml_stack_end
        LDA TMP + 1
        CMP # $40
        BCS @err                        ;negative length
        LDA TMP + 4
        CLC
        ADC TMP
        STA TMP + 2
        LDA TMP + 5
        ADC TMP + 1
        BCC @ok
        ORA TMP + 2
        BNE @err                        ;wraps around $FFFF
@ok     JMP caml_hw_blit
@err    +caml_raise Invalid_argument, "C64.Hw.Mem.blit_at"
}

;; ---- NMI blocking ------------------------------------------------------------
;; Nmi.block: the Kernal NMI vector is pointed to an RTI and a CIA2 timer NMI is
;; forced. The RTI does not read $DD0D (no ACK): CIA2 keeps /NMI low, no further
;; edge can occur (RESTORE key included) until Nmi.unblock (or program exit).
;; Needed by peek_ram/peek_at_ram, which run with all ROMs switched off.

!ifdef caml_PRIM__caml_nonstd_hw_nmi_block {
caml_nonstd_hw_nmi_block
        PHP
        SEI
        LDA # <@rti
        STA C64_NMINV
        LDA # >@rti
        STA C64_NMINV + 1
        LDA # $7F
        STA caml_hw_CIA2ICR             ;disable all CIA2 interrupt sources
        LDA caml_hw_CIA2ICR             ; and acknowledge pending ones
        LDA # 1
        STA caml_hw_CIA2TAL
        STY caml_hw_CIA2TAH             ;timer A latch := 1
        LDA # $81
        STA caml_hw_CIA2ICR             ;enable NMI on timer A underflow
        LDA # %00011001
        STA caml_hw_CIA2CRA             ;force load, one shot, start
        NOP
        NOP
        NOP
        NOP                             ;the NMI occurs here (and is ignored)
        PLP
        +caml_hw_ret_unit
        RTS
@rti    RTI
}

!ifdef caml_PRIM__caml_nonstd_hw_nmi_unblock {
caml_nonstd_hw_nmi_unblock
        PHP
        SEI
        LDA # $7F
        STA caml_hw_CIA2ICR             ;disable all CIA2 interrupt sources
        LDA caml_hw_CIA2ICR             ; and acknowledge pending ones
        LDA # <caml_hw_NMI_DEF
        STA C64_NMINV
        LDA # >caml_hw_NMI_DEF
        STA C64_NMINV + 1
        PLP
        +caml_hw_ret_unit
        RTS
}

}       ;; !zone caml_C64_HW
