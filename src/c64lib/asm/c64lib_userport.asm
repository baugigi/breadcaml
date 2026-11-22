;; -----------------------------------------------------------------------------
;;              C64.Hw.Userport and C64.Mcu - USER PORT PRIMITIVES
;; -----------------------------------------------------------------------------
;; The user port is wired to CIA 2:
;;      PB0-PB7   port B ($DD01, direction $DD03); PB6/PB7 can be driven by the
;;                timer A / timer B outputs
;;      PA2       port A bit 2 ($DD00, direction $DD02): the other bits of port
;;                A are the VIC bank (0-1) and the serial bus (3-7): never touched
;;      /FLAG2    negative edge sets bit 4 of ICR ($DD0D) (reading ICR clears it)
;;      /PC2      pulses low for 1 cycle after each read/write of port B
;;      CNT2,SP2  shift register ($DD0C)
;; Timers: CIA2 timer B is used by the Mcu.Time primitives (delay, clock, pulse
;; measurement); timer A by the UART and by the tone generator. Sound.frame_cycles
;; (c64lib_snd.asm) also uses timer B, and Hw.Nmi.block uses timer A and the ICR
;; mask: do not mix them with these primitives while they run.
;;
;; Conventions as in c64lib_hw.asm: the arguments are not popped here, ACCU = 1st
;; argument, SP[0] = 2nd, ...; masks and values are 8 bit (Int_val masked);
;; every primitive returns with Y = 0.
;;
;; Cycle counts quoted below are CPU cycles (1 cycle = 1.015 us on PAL).

!zone caml_C64_UP {

!macro caml_up_a8 {                     ;A := low 8 bits of Int_val(ACCU)
        LDA ACCU + 1
        LSR
        LDA ACCU
        ROR
}
!macro caml_up_s8 .n {                  ;A := low 8 bits of Int_val(SP[.n])  {Y = 0}
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # 0
}
!macro caml_up_s16 .n, .dst {           ;.dst:.dst+1 := Int_val(SP[.n])  {Y = 0}
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        STA .dst + 1
        DEY
        LDA (SP),Y
        ROR
        STA .dst
        LDY # 0
}
!macro caml_up_acc16 .dst {             ;.dst:.dst+1 := Int_val(ACCU)
        LDA ACCU + 1
        LSR
        STA .dst + 1
        LDA ACCU
        ROR
        STA .dst
}
!macro caml_up_ret8 {                   ;ACCU := Val_int(A)  {Y = 0}
        STY ACCU + 1
        SEC
        ROL
        STA ACCU
        ROL ACCU + 1
}
!macro caml_up_ret_bool {               ;ACCU := Val_bool(A <> 0)  {Y = 0}
        CMP # 1                         ;C := (A >= 1)
        LDA # 0
        ROL
        +caml_up_ret8
}
!macro caml_up_ret_unit {
        LDX # <Val_unit
        STX ACCU
        STY ACCU + 1
}
!macro caml_up_ret_16 {                 ;ACCU := Val_int(X:A)  (X:A < $4000)
        STA ACCU
        STX ACCU + 1
        SEC
        ROL ACCU
        ROL ACCU + 1
}

;; ----- Port B ----------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_up_read {
caml_nonstd_up_read
        LDA C64_CIA2_PRB
        +caml_up_ret8
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_write {
caml_nonstd_up_write
        +caml_up_a8
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_ddr {
caml_nonstd_up_ddr
        LDA C64_CIA2_DDRB
        +caml_up_ret8
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_set_ddr {
caml_nonstd_up_set_ddr
        +caml_up_a8
        STA C64_CIA2_DDRB
        +caml_up_ret_unit
        RTS
}
;; Bit operations on the output latch: PRB := PRB op mask
!ifdef caml_PRIM__caml_nonstd_up_set {
caml_nonstd_up_set
        +caml_up_a8
        ORA C64_CIA2_PRB
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_clear {
caml_nonstd_up_clear
        +caml_up_a8
        EOR # $FF
        AND C64_CIA2_PRB
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_toggle {
caml_nonstd_up_toggle
        +caml_up_a8
        EOR C64_CIA2_PRB
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
}
;; Direction bit operations: DDRB := DDRB | mask (outputs) / & ~mask (inputs)
!ifdef caml_PRIM__caml_nonstd_up_dir_out {
caml_nonstd_up_dir_out
        +caml_up_a8
        ORA C64_CIA2_DDRB
        STA C64_CIA2_DDRB
        +caml_up_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_dir_in {
caml_nonstd_up_dir_in
        +caml_up_a8
        EOR # $FF
        AND C64_CIA2_DDRB
        STA C64_CIA2_DDRB
        +caml_up_ret_unit
        RTS
}

;; ----- PA2, /FLAG2 ------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_up_pa2_read {
caml_nonstd_up_pa2_read
        LDA C64_CIA2_PRA
        AND # %00000100
        +caml_up_ret_bool
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_pa2_write {
caml_nonstd_up_pa2_write
        +caml_up_a8
        AND # 1
        BEQ @low
        LDA C64_CIA2_PRA
        ORA # %00000100
        BNE @sta                        ;BNE = JMP
@low    LDA C64_CIA2_PRA
        AND # %11111011
@sta    STA C64_CIA2_PRA
        +caml_up_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_pa2_dir {
caml_nonstd_up_pa2_dir
        +caml_up_a8                     ;1 = output
        AND # 1
        BEQ @in
        LDA C64_CIA2_DDRA
        ORA # %00000100
        BNE @sta                        ;BNE = JMP
@in     LDA C64_CIA2_DDRA
        AND # %11111011
@sta    STA C64_CIA2_DDRA
        +caml_up_ret_unit
        RTS
}
;; Reads ICR: returns the /FLAG2 flag, but clears ALL the CIA2 flags
!ifdef caml_PRIM__caml_nonstd_up_flag2 {
caml_nonstd_up_flag2
        LDA C64_CIA2_ICR
        AND # C64_CIA_ICR_FLG
        +caml_up_ret_bool
        RTS
}

;; ----- Timing ------------------------------------------------------------------

;; Waits TMP:TMP+1 cycles with timer B, one shot. The time spent between the
;; start of the timer and the return is TMP:TMP+1 + 1 + (0..8) cycles.
;; Clobbers A.
!ifdef caml_AUX__caml_up_wait {
caml_up_wait
        LDA # 0
        STA C64_CIA2_CRB                ;stop timer B, input mode = phi2
        LDA TMP
        STA C64_CIA2_TBLO
        LDA TMP + 1
        STA C64_CIA2_TBHI
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_ONESHOT | C64_CIA_CR_START
        STA C64_CIA2_CRB                ;load and start
-       LDA C64_CIA2_CRB
        LSR
        BCS -                           ;START bit clears at the underflow
        RTS
}

;; delay cycles: waits for Int_val(ACCU) cycles, 0 <= n <= 16383
!ifdef caml_PRIM__caml_nonstd_up_delay {
caml_nonstd_up_delay
        +caml_up_acc16 TMP
        JSR caml_up_wait
        +caml_up_ret_unit
        RTS
}

;; clock_start: timer B free running from $FFFF, counting cycles (wraps at 65536)
!ifdef caml_PRIM__caml_nonstd_up_clock_start {
caml_nonstd_up_clock_start
        LDA # 0
        STA C64_CIA2_CRB
        LDA # $FF
        STA C64_CIA2_TBLO
        STA C64_CIA2_TBHI
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_START
        STA C64_CIA2_CRB
        +caml_up_ret_unit
        RTS
}
;; clock_read: elapsed cycles since clock_start, in units of 4 cycles (0..16383)
!ifdef caml_PRIM__caml_nonstd_up_clock_read {
caml_nonstd_up_clock_read
-       LDX C64_CIA2_TBHI
        LDA C64_CIA2_TBLO
        CPX C64_CIA2_TBHI
        BNE -                           ;consistent read
        EOR # $FF                       ;elapsed = $FFFF - counter = ~counter
        STA TMP
        TXA
        EOR # $FF
        LSR
        ROR TMP
        LSR
        ROR TMP                         ;(elapsed >> 2): A = hi, TMP = lo
        TAX
        LDA TMP
        +caml_up_ret_16
        RTS
}

;; pulse_out mask level cycles: drives the pins in mask to level (0/1) for the
;; given cycles (16 bit, same limits as delay), then to the opposite level. The
;; pins must already be outputs.
!ifdef caml_PRIM__caml_nonstd_up_pulse_out {
caml_nonstd_up_pulse_out
        +caml_up_s16 1, TMP             ;TMP:TMP+1 = cycles
        +caml_up_s8 0
        AND # 1
        STA TMP + 2                     ;level
        +caml_up_a8
        STA TMP + 3                     ;mask
        EOR # $FF
        STA TMP + 4                     ;~mask
        LDA TMP + 2
        BEQ @low
        LDA C64_CIA2_PRB                ;level 1: high, wait, low
        ORA TMP + 3
        STA C64_CIA2_PRB
        JSR caml_up_wait
        LDA C64_CIA2_PRB
        AND TMP + 4
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
@low    LDA C64_CIA2_PRB                ;level 0: low, wait, high
        AND TMP + 4
        STA C64_CIA2_PRB
        JSR caml_up_wait
        LDA C64_CIA2_PRB
        ORA TMP + 3
        STA C64_CIA2_PRB
        +caml_up_ret_unit
        RTS
}

;; pulse_width mask level timeout: measures a complete pulse: waits (at most
;; timeout * 256 cycles in all) for the pins in mask to be NOT at level, then to be
;; at level (a rising/falling edge), then measures for how many cycles they stay so
;; (at most 16383). Returns the width in cycles, or -1 on timeout or if the pulse
;; is longer. With several pins in mask, "at level" means "any pin at level".
;; Resolution: about 12 cycles (polling).  Uses timer B.
!macro caml_up_tmo .bad {               ;one 256-cycle block of timeout gone
        LDA TMP
        BNE ++
        LDA TMP + 1
        BNE +
        JMP .bad
+       DEC TMP + 1
++      DEC TMP
}
!ifdef caml_PRIM__caml_nonstd_up_pulse_width {
caml_nonstd_up_pulse_width
        +caml_up_a8
        STA TMP + 2                     ;mask
        +caml_up_s8 0
        AND # 1
        BEQ @lv0
        LDA # 0                         ;level 1: inv = 0
        BEQ @sinv                       ;BEQ = JMP
@lv0    LDA TMP + 2                     ;level 0: inv = mask
@sinv   STA TMP + 3
        +caml_up_s16 1, TMP             ;TMP:TMP+1 = timeout (256-cycle blocks)
        LDA # 0
        STA C64_CIA2_CRB                ;timer B: free running from $FFFF
        LDA # $FF
        STA C64_CIA2_TBLO
        STA C64_CIA2_TBHI
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_START
        STA C64_CIA2_CRB
        LDA C64_CIA2_TBHI
        STA TMP + 4                     ;last hi byte seen
@w0     LDA C64_CIA2_PRB                ;PHASE 0: wait for "not at level"
        AND TMP + 2
        EOR TMP + 3
        BEQ @w1
        LDA C64_CIA2_TBHI
        CMP TMP + 4
        BEQ @w0
        STA TMP + 4
        +caml_up_tmo @bad
        JMP @w0
@w1     LDA C64_CIA2_PRB                ;PHASE 1: wait for "at level"
        AND TMP + 2
        EOR TMP + 3
        BNE @start
        LDA C64_CIA2_TBHI
        CMP TMP + 4
        BEQ @w1
        STA TMP + 4                     ;256 more cycles gone
        +caml_up_tmo @bad
        JMP @w1
@start  LDX C64_CIA2_TBHI               ;timestamp (consistent read)
        LDA C64_CIA2_TBLO
        CPX C64_CIA2_TBHI
        BNE @start
        STA TMP + 5
        STX TMP + 6
        STX TMP + 4
        LDA # 65
        STA TMP + 7                     ;at most 64 blocks of 256 cycles
@w2     LDA C64_CIA2_PRB                ;PHASE 2: wait for the end of the level
        AND TMP + 2
        EOR TMP + 3
        BEQ @end
        LDA C64_CIA2_TBHI
        CMP TMP + 4
        BEQ @w2
        STA TMP + 4
        DEC TMP + 7
        BNE @w2
        BEQ @bad                        ;too long
@end    LDX C64_CIA2_TBHI
        LDA C64_CIA2_TBLO
        CPX C64_CIA2_TBHI
        BNE @end
        STA TMP + 8
        STX TMP + 9
        SEC                             ;width = start - end (down counter)
        LDA TMP + 5
        SBC TMP + 8
        PHA
        LDA TMP + 6
        SBC TMP + 9
        TAX
        PLA
        CPX # $40
        BCS @bad
        LDY # 0
        STY C64_CIA2_CRB                ;stop timer B
        +caml_up_ret_16
        RTS
@bad    LDY # 0
        STY C64_CIA2_CRB
        LDA # $FF
        STA ACCU                        ;Val_int(-1) = $FFFF
        STA ACCU + 1
        RTS
}

;; ----- Clock rate -> cycles ---------------------------------------------------

;; TMP:TMP+2 := round(clock / d), d in TMP+3:TMP+4 (<> 0); the clock is the CPU
;; clock for the current video standard (C64_PALNTS): PAL 985248 Hz, NTSC
;; 1022727 Hz. Clobbers A, X, TMP..TMP+7.
!ifdef caml_AUX__caml_up_clock_div {
caml_up_clock_div
        LDA C64_PALNTS
        BEQ @ntsc
        LDA # <985248
        STA TMP
        LDA # >985248 & $FF
        STA TMP + 1
        LDA # 985248 >> 16
        BNE @half                       ;BNE = JMP
@ntsc   LDA # <1022727
        STA TMP
        LDA # >1022727 & $FF
        STA TMP + 1
        LDA # 1022727 >> 16
@half   STA TMP + 2
        LDA TMP + 4                     ;dividend := clock + d / 2 (rounding)
        LSR
        STA TMP + 6
        LDA TMP + 3
        ROR
        CLC
        ADC TMP
        STA TMP
        LDA TMP + 6
        ADC TMP + 1
        STA TMP + 1
        BCC +
        INC TMP + 2
+       LDA # 0
        STA TMP + 5                     ;remainder R = TMP+5:TMP+6
        STA TMP + 6
        LDX # 24
-       ASL TMP                         ;dividend (becomes quotient) <<= 1,
        ROL TMP + 1
        ROL TMP + 2
        ROL TMP + 5                     ;R := R << 1 | carry
        ROL TMP + 6
        BCS @sub                        ;17 bits: R >= d
        LDA TMP + 5
        CMP TMP + 3
        LDA TMP + 6
        SBC TMP + 4
        BCC @next
@sub    SEC
        LDA TMP + 5
        SBC TMP + 3
        STA TMP + 5
        LDA TMP + 6
        SBC TMP + 4
        STA TMP + 6
        INC TMP                         ;quotient bit
@next   DEX
        BNE -
        RTS
}

;; cycles_of_rate hz: CPU cycles in a period of a signal of hz Hz (1 <= hz <= 16383):
;; round(clock / hz), or -1 if hz = 0 or the result is >= 16384.
!ifdef caml_PRIM__caml_nonstd_up_cycles_of_rate {
caml_nonstd_up_cycles_of_rate
        +caml_up_acc16 TMP + 3
        LDA TMP + 3
        ORA TMP + 4
        BEQ @bad
        JSR caml_up_clock_div
        LDA TMP + 2
        BNE @bad
        LDX TMP + 1
        CPX # $40
        BCS @bad
        LDA TMP
        LDY # 0
        +caml_up_ret_16
        RTS
@bad    LDY # 0
        LDA # $FF
        STA ACCU
        STA ACCU + 1
        RTS
}

;; ----- Bit masks --------------------------------------------------------------

!ifdef caml_AUX__caml_up_masks {
caml_up_masks
        !byte $01, $02, $04, $08, $10, $20, $40, $80
}

;; ----- SPI (master, bit banged, MSB first) ------------------------------------
;; cfg (15 bit) = sck | mosi << 3 | miso << 6 (PB numbers 0..7), | cpol << 9
;;      | cpha << 10 | nomiso << 12 (bit 11 is reserved)
;; delay: busy loop of 5 * delay cycles at each half clock period (0..255)

!macro caml_up_spi_half {               ;delay, preserves C
        LDX TMP + 6
        BEQ +
-       DEX
        BNE -
+
}
!macro caml_up_spi_clk {                ;toggle SCK, preserves C
        LDA TMP + 7
        EOR TMP + 0
        STA TMP + 7
        STA C64_CIA2_PRB
}
!macro caml_up_spi_put {                ;MOSI := C
        LDA TMP + 7
        AND TMP + 3
        BCC +
        ORA TMP + 1
+       STA TMP + 7
        STA C64_CIA2_PRB
}
!macro caml_up_spi_get {                ;IN := IN << 1 | MISO
        LDA C64_CIA2_PRB
        AND TMP + 2
        CMP # 1                         ;C := (MISO <> 0)
        ROL TMP + 9
}

;; in: cfg in TMP+20:TMP+21, delay in TMP+6.  Computes TMP+0 = SCK mask,
;; TMP+1 = MOSI mask, TMP+2 = MISO mask (0 if none), TMP+3 = ~MOSI mask,
;; TMP+4 = SCK mask if cpol else 0, TMP+5 = cpha; puts SCK in its idle state
;; (shadow of PRB in TMP+7).  Clobbers A, X, TMP+22.
!ifdef caml_AUX__caml_up_spi_setup {
caml_up_spi_setup
        LDA TMP + 20
        AND # 7
        TAX
        LDA caml_up_masks,X
        STA TMP                         ;SCK mask
        LDA TMP + 20
        LSR
        LSR
        LSR
        AND # 7
        TAX
        LDA caml_up_masks,X
        STA TMP + 1                     ;MOSI mask
        EOR # $FF
        STA TMP + 3
        LDA TMP + 21                    ;miso = (cfg >> 6) & 7
        AND # 1
        ASL
        ASL
        STA TMP + 22
        LDA TMP + 20
        ASL
        ROL
        ROL
        AND # 3
        ORA TMP + 22
        TAX
        LDA caml_up_masks,X
        STA TMP + 2                     ;MISO mask
        LDA TMP + 21
        AND # %00010000                 ;nomiso
        BEQ +
        LDA # 0
        STA TMP + 2
+       LDA TMP + 21
        AND # %00000010                 ;cpol
        BEQ +
        LDA TMP
+       STA TMP + 4
        LDA TMP + 21
        LSR
        LSR
        AND # 1
        STA TMP + 5                     ;cpha
        LDA TMP
        EOR # $FF
        AND C64_CIA2_PRB
        ORA TMP + 4                     ;SCK := idle level (cpol)
        STA TMP + 7
        STA C64_CIA2_PRB
        RTS
}

;; A = byte to send -> A = byte received  (after caml_up_spi_setup)
!ifdef caml_AUX__caml_up_spi_byte {
caml_up_spi_byte
        STA TMP + 8
        LDA # 0
        STA TMP + 9
        LDA # 8
        STA TMP + 10
@bit    ASL TMP + 8                     ;C := next bit to send
        LDA TMP + 5
        BNE @cpha1
        +caml_up_spi_put                ;CPHA 0: data, leading edge (sample),
        +caml_up_spi_half
        +caml_up_spi_clk
        +caml_up_spi_get
        +caml_up_spi_half
        +caml_up_spi_clk                ;trailing edge
        JMP @next
@cpha1  +caml_up_spi_clk                ;CPHA 1: leading edge, data,
        +caml_up_spi_put
        +caml_up_spi_half
        +caml_up_spi_clk                ;trailing edge (sample)
        +caml_up_spi_get
        +caml_up_spi_half
@next   DEC TMP + 10
        BNE @bit
        LDA TMP + 9
        RTS
}

;; spi_xfer cfg delay byte -> byte
!ifdef caml_PRIM__caml_nonstd_up_spi_xfer {
caml_nonstd_up_spi_xfer
        +caml_up_acc16 TMP + 20
        +caml_up_s8 0
        STA TMP + 6                     ;delay
        +caml_up_s8 1
        PHA                             ;byte
        JSR caml_up_spi_setup
        PLA
        JSR caml_up_spi_byte
        LDY # 0
        +caml_up_ret8
        RTS
}

;; spi_buf cfg delay buf ofs len: full duplex in place on len bytes of buf
;; (a Bytes), starting at ofs. NO CHECKS: the OCaml wrapper validates the range.
!ifdef caml_PRIM__caml_nonstd_up_spi_buf {
caml_nonstd_up_spi_buf
        +caml_up_acc16 TMP + 20
        +caml_up_s8 0
        STA TMP + 6                     ;delay
        LDY # 2
        LDA (SP),Y                      ;buf: the block address
        STA TMP + 24
        INY
        LDA (SP),Y
        STA TMP + 25
        +caml_up_s16 2, TMP + 26        ;ofs
        CLC
        LDA TMP + 24
        ADC TMP + 26
        STA TMP + 24
        LDA TMP + 25
        ADC TMP + 27
        STA TMP + 25
        +caml_up_s16 3, TMP + 26        ;len
        JSR caml_up_spi_setup
@loop   LDA TMP + 26
        ORA TMP + 27
        BEQ @done
        LDY # 0
        LDA (TMP + 24),Y
        JSR caml_up_spi_byte
        LDY # 0
        STA (TMP + 24),Y
        INC TMP + 24
        BNE +
        INC TMP + 25
+       LDA TMP + 26
        BNE +
        DEC TMP + 27
+       DEC TMP + 26
        JMP @loop
@done   LDY # 0
        +caml_up_ret_unit
        RTS
}

;; ----- UART (8N1, bit banged on PB0-PB7, timer A) ------------------------------
;; cfg (15 bit) = pin | cycles_per_bit << 3  (cycles_per_bit <= 4095)
;; uart_tx cfg byte; uart_rx cfg timeout -> byte, or -1 (timeout) or -2 (framing
;; error). Interrupts are disabled while a frame is sent/received.

!macro caml_up_wait_ta {                ;wait for the timer A underflow
-       LDA C64_CIA2_ICR
        LSR
        BCC -
}

;; in: TMP+20:TMP+21 = cfg.  out: TMP+2 = pin mask, TMP+4 = ~mask,
;; TMP+20:TMP+21 = cycles per bit
!ifdef caml_AUX__caml_up_uart_cfg {
caml_up_uart_cfg
        LDA TMP + 20
        AND # 7
        TAX
        LDA caml_up_masks,X
        STA TMP + 2
        EOR # $FF
        STA TMP + 4
        LDX # 3
-       LSR TMP + 21
        ROR TMP + 20
        DEX
        BNE -
        RTS
}

;; Timing: the timer is started 6 cycles (LDA #, STA) after the start bit edge, so
;; its first interval is shortened by KS+1 cycles.
caml_up_KS = 6

!ifdef caml_PRIM__caml_nonstd_up_uart_tx {
caml_nonstd_up_uart_tx
        +caml_up_acc16 TMP + 20
        +caml_up_s8 0
        STA TMP + 3                     ;byte
        JSR caml_up_uart_cfg
        PHP
        SEI
        LDA # 0
        STA C64_CIA2_CRA                ;stop timer A
        LDA # C64_CIA_ICR_ALL
        STA C64_CIA2_ICR                ;no CIA2 interrupt source
        LDA C64_CIA2_ICR                ;acknowledge
        SEC                             ;counter := cpb - 1 - KS (first interval)
        LDA TMP + 20
        SBC # caml_up_KS + 1
        STA C64_CIA2_TALO
        LDA TMP + 21
        SBC # 0
        STA C64_CIA2_TAHI
        LDA # C64_CIA_CR_LOAD
        STA C64_CIA2_CRA
        SEC                             ;latch := cpb - 1
        LDA TMP + 20
        SBC # 1
        STA C64_CIA2_TALO
        LDA TMP + 21
        SBC # 0
        STA C64_CIA2_TAHI
        LDA C64_CIA2_PRB                ;start bit
        AND TMP + 4
        STA C64_CIA2_PRB
        LDA # C64_CIA_CR_START
        STA C64_CIA2_CRA
        LDX # 9                         ;8 data bits + stop bit
@bit    +caml_up_wait_ta
        SEC
        ROR TMP + 3                     ;C := next bit (the stop bit is a 1)
        LDA C64_CIA2_PRB
        AND TMP + 4
        BCC +
        ORA TMP + 2
+       STA C64_CIA2_PRB
        DEX
        BNE @bit
        +caml_up_wait_ta                ;end of the stop bit
        LDA # 0
        STA C64_CIA2_CRA
        PLP
        +caml_up_ret_unit
        RTS
}

;; rx: the sample point is 1.5 bit times after the start bit edge; the edge is
;; detected within ~10 cycles, then the timer starts 6 cycles later (KR).
caml_up_KR = 16

!ifdef caml_PRIM__caml_nonstd_up_uart_rx {
caml_nonstd_up_uart_rx
        +caml_up_acc16 TMP + 20
        +caml_up_s16 0, TMP             ;timeout, in 256-cycle blocks
        JSR caml_up_uart_cfg
        PHP
        SEI
        LDA # 0
        STA C64_CIA2_CRA
        LDA # C64_CIA_ICR_ALL
        STA C64_CIA2_ICR
        LDA C64_CIA2_ICR
        LDA TMP + 21                    ;TMP+22:TMP+23 := 1.5 * cpb
        LSR
        STA TMP + 23
        LDA TMP + 20
        ROR
        CLC
        ADC TMP + 20
        STA TMP + 22
        LDA TMP + 23
        ADC TMP + 21
        STA TMP + 23
        SEC                             ;counter := 1.5 cpb - 1 - KR
        LDA TMP + 22
        SBC # caml_up_KR + 1
        STA C64_CIA2_TALO
        LDA TMP + 23
        SBC # 0
        STA C64_CIA2_TAHI
        LDA # C64_CIA_CR_LOAD
        STA C64_CIA2_CRA
        SEC                             ;latch := cpb - 1
        LDA TMP + 20
        SBC # 1
        STA C64_CIA2_TALO
        LDA TMP + 21
        SBC # 0
        STA C64_CIA2_TAHI
        LDA # 0
        STA C64_CIA2_CRB                ;timer B: free running, the timeout clock
        LDA # $FF
        STA C64_CIA2_TBLO
        STA C64_CIA2_TBHI
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_START
        STA C64_CIA2_CRB
        LDA C64_CIA2_TBHI
        STA TMP + 4
@wait   LDA C64_CIA2_PRB                ;wait for the start bit (low)
        AND TMP + 2
        BEQ @edge
        LDA C64_CIA2_TBHI
        CMP TMP + 4
        BEQ @wait
        STA TMP + 4
        LDA TMP
        BNE +
        LDA TMP + 1
        BEQ @tmout
        DEC TMP + 1
+       DEC TMP
        JMP @wait
@edge   LDA # C64_CIA_CR_START
        STA C64_CIA2_CRA
        LDX # 8
@bit    +caml_up_wait_ta
        LDA C64_CIA2_PRB
        AND TMP + 2
        CMP # 1                         ;C := bit
        ROR TMP + 3                     ;LSB first
        DEX
        BNE @bit
        +caml_up_wait_ta                ;middle of the stop bit
        LDA C64_CIA2_PRB
        AND TMP + 2
        BEQ @frame                      ;stop bit low: framing error
        LDA # 0
        STA C64_CIA2_CRA
        STA C64_CIA2_CRB
        PLP
        LDA TMP + 3
        LDY # 0
        +caml_up_ret8
        RTS
@frame  LDA # 0
        STA C64_CIA2_CRA
        STA C64_CIA2_CRB
        PLP
        LDY # 0
        LDA # $FE                       ;Val_int(-2) = $FFFD
        STA ACCU
        LDA # $FF
        STA ACCU + 1
        LDA # $FD
        STA ACCU
        RTS
@tmout  LDA # 0
        STA C64_CIA2_CRA
        STA C64_CIA2_CRB
        PLP
        LDY # 0
        LDA # $FF
        STA ACCU                        ;Val_int(-1) = $FFFF
        STA ACCU + 1
        RTS
}

;; ----- Tone: square wave on PB6 (timer A) or PB7 (timer B) ---------------------
;; tone pin hz: half period = round(clock / (2 hz)) cycles, 8 <= hz <= 16383.
;; tone_stop pin. Returns false if hz is out of range or pin is not 6 or 7.

!ifdef caml_PRIM__caml_nonstd_up_tone {
caml_nonstd_up_tone
        +caml_up_s16 0, TMP + 3         ;hz
        LDA TMP + 4
        BNE @hzok
        LDA TMP + 3
        CMP # 8
        BCC @bad
@hzok   ASL TMP + 3                     ;d := 2 hz (<= 32766)
        ROL TMP + 4
        +caml_up_a8                     ;pin
        STA TMP + 12
        CMP # 6
        BEQ +
        CMP # 7
        BNE @bad
+       JSR caml_up_clock_div
        LDA TMP + 2
        BNE @bad                        ;(not reached: hz >= 8)
        LDA TMP                         ;latch := half - 1
        BNE +
        DEC TMP + 1
+       DEC TMP
        LDA TMP + 12
        CMP # 7
        BEQ @tb
        LDA # 0                         ;timer A on PB6
        STA C64_CIA2_CRA
        LDA TMP
        STA C64_CIA2_TALO
        LDA TMP + 1
        STA C64_CIA2_TAHI
        LDA C64_CIA2_DDRB
        ORA # %01000000
        STA C64_CIA2_DDRB
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_PBON | C64_CIA_CR_TOGGLE | C64_CIA_CR_START
        STA C64_CIA2_CRA
        BNE @ok                         ;BNE = JMP
@tb     LDA # 0                         ;timer B on PB7
        STA C64_CIA2_CRB
        LDA TMP
        STA C64_CIA2_TBLO
        LDA TMP + 1
        STA C64_CIA2_TBHI
        LDA C64_CIA2_DDRB
        ORA # %10000000
        STA C64_CIA2_DDRB
        LDA # C64_CIA_CR_LOAD | C64_CIA_CR_PBON | C64_CIA_CR_TOGGLE | C64_CIA_CR_START
        STA C64_CIA2_CRB
@ok     LDY # 0
        LDA # 1
        +caml_up_ret_bool
        RTS
@bad    LDY # 0
        LDA # 0
        +caml_up_ret_bool
        RTS
}
!ifdef caml_PRIM__caml_nonstd_up_tone_stop {
caml_nonstd_up_tone_stop
        +caml_up_a8
        CMP # 7
        BEQ @tb
        LDA # 0
        STA C64_CIA2_CRA                ;timer A stopped, PB6 back to port B
        BEQ @end                        ;BEQ = JMP
@tb     LDA # 0
        STA C64_CIA2_CRB
@end    +caml_up_ret_unit
        RTS
}

} ;end of zone
