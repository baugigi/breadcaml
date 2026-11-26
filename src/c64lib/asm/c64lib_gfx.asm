;; ——————————————————————————————————————————————————————————————————————
;; The BreadCaml Project / Progetto BreadCaml
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;; 
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
;; as specified in the LICENSE-en file in the project root folder.
;; 
;; Questo  programma  è software  libero;  può  essere ridistribuito  e/o
;; modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
;; 2, come specificato nel file  LICENZA-it nella cartella principale del
;; progetto.
;; ——————————————————————————————————————————————————————————————————————
;; -----------------------------------------------------------------------------
;;                 C64.Gfx - HIRES / MULTICOLOR BITMAP GRAPHICS
;; -----------------------------------------------------------------------------
;; The bitmap lives in the VIC bank selected by Gfx.init (bank 0..2; bank 3 is
;; not supported). Coordinates: hires 320 x 200, multicolor 160 x 200.
;; If the bitmap is in $A000-$BFFF (RAM under the BASIC ROM) the routines clear
;; LORAM in R6510 while they read/write it.
;; An optional "virtual window" maps user coordinates to the physical ones:
;;      p = floor(|v - org| * K / 65536),  K = ceil((size - 1) * 65536 / |span|)
;; Lines: Bresenham, with a fast self-modifying loop for lines that are fully
;; inside the screen, and a clipping (slower) loop for the others.

!zone caml_C64_GFX {

;; TMP area map ($4D-$6A; all of it is free while a primitive runs)
caml_gfx_X1     = TMP                   ;endpoints: X1,Y1,X2,Y2 (16 bit, signed)
caml_gfx_Y1     = TMP + 2
caml_gfx_X2     = TMP + 4
caml_gfx_Y2     = TMP + 6
caml_gfx_DX     = TMP + 8               ;line: |dx|
caml_gfx_DY     = TMP + 10              ;      |dy|
caml_gfx_E      = TMP + 12              ;      error term (signed 16 bit)
caml_gfx_CNT    = TMP + 14              ;      pixels left
caml_gfx_PTR    = TMP + 16              ;      byte address of the pixel
caml_gfx_MAJ    = TMP + 18              ;      major delta
caml_gfx_MIN    = TMP + 20              ;      minor delta
caml_gfx_SXN    = TMP + 22              ;      fast line: x/y step is negative
caml_gfx_SYN    = TMP + 23
caml_gfx_SXL    = TMP + 22              ;      slow line: x step as 16 bit
caml_gfx_SXH    = TMP + 23
caml_gfx_SYL    = TMP + 24              ;                 y step as 16 bit
caml_gfx_SYH    = TMP + 25
caml_gfx_T      = TMP + 26              ;locate: temporary (3 bytes)
caml_gfx_XM     = TMP + 29              ;slow line: major axis is x
caml_gfx_V      = TMP + 8               ;tx: value (16 bit)
caml_gfx_D      = TMP + 10              ;    d
caml_gfx_P      = TMP + 12              ;    product (5 bytes)
caml_gfx_SG     = TMP + 17              ;    sign
caml_gfx_N      = TMP + 8               ;div32: dividend / quotient (4 bytes)
caml_gfx_DV     = TMP + 12              ;       divisor (16 bit)
caml_gfx_R      = TMP + 14              ;       remainder (16 bit)

;; ACCU := Int_val(ACCU), sign extended, stored in .dst (16 bit)
!macro caml_gfx_arg_acc .dst {
        LDA ACCU + 1
        CMP # $80
        ROR
        STA .dst + 1
        LDA ACCU
        ROR
        STA .dst
}
;; .dst := Int_val(SP[.n]), sign extended   {Y = 0}
!macro caml_gfx_arg_sp .n, .dst {
        LDY # .n * 2 + 1
        LDA (SP),Y
        CMP # $80
        ROR
        STA .dst + 1
        DEY
        LDA (SP),Y
        ROR
        STA .dst
        LDY # 0
}
!macro caml_gfx_ret_int {               ;ACCU := Val_int(A)   {Y = 0}
        STY ACCU + 1
        SEC
        ROL
        STA ACCU
        ROL ACCU + 1
}
!macro caml_gfx_ret_unit {              ;{Y = 0}
        LDX # <Val_unit
        STX ACCU
        STY ACCU + 1
}
;; Negate a 16 bit zero-page variable
!macro caml_gfx_neg16 .v {
        SEC
        LDA # 0
        SBC .v
        STA .v
        LDA # 0
        SBC .v + 1
        STA .v + 1
}

;; ---- data ---------------------------------------------------------------------

!ifdef caml_AUX__caml_gfx_data {
caml_gfx_data
caml_gfx_data__npos     !byte 8         ;pixels per byte-cell: 8 hires, 4 multicolor
caml_gfx_data__pmask    !byte 7         ;npos - 1
caml_gfx_data__mc       !byte 0         ;1 = multicolor
caml_gfx_data__pat      !byte $FF       ;pen pattern ($FF, $AA, $55, $00 ...)
caml_gfx_data__romoff   !byte 0         ;1 = bitmap under the BASIC ROM
caml_gfx_data__r6510    !byte 0         ;saved R6510
caml_gfx_data__win      !byte 0         ;1 = virtual window active
caml_gfx_data__wlo      !byte <320      ;physical width
caml_gfx_data__whi      !byte >320
caml_gfx_data__bmphi    !byte 0         ;bitmap start page
caml_gfx_data__msk      !fill 8, 0      ;pixel masks within a byte
caml_gfx_data__nmsk     !fill 8, 0      ;inverted masks
caml_gfx_data__val      !fill 8, 0      ;masks & pen pattern
caml_gfx_data__rowlo    !fill 25, 0     ;address of each cell row (bitmap + 320 * r)
caml_gfx_data__rowhi    !fill 25, 0
caml_gfx_data__orglo    !byte 0, 0      ;window, one entry per axis (0 = x, 1 = y)
caml_gfx_data__orghi    !byte 0, 0
caml_gfx_data__neg      !byte 0, 0      ;1 = axis is reversed
caml_gfx_data__k0       !byte 0, 0      ;K, 24 bit
caml_gfx_data__k1       !byte 0, 0
caml_gfx_data__k2       !byte 0, 0
}

;; ---- helpers --------------------------------------------------------------------

!ifdef caml_AUX__caml_gfx_tabs {
caml_gfx_tabs
        ;; Rebuild msk/nmsk/val from mc and pat
        LDA caml_gfx_data__mc
        BNE @mc
        LDX # 7
@h      LDA @hmask,X
        STA caml_gfx_data__msk,X
        DEX
        BPL @h
        BMI @vals                       ;(always)
@mc     LDX # 3
@m      LDA @mmask,X
        STA caml_gfx_data__msk,X
        DEX
        BPL @m
@vals   LDX caml_gfx_data__npos
        DEX
@v      LDA caml_gfx_data__msk,X
        EOR # $FF
        STA caml_gfx_data__nmsk,X
        LDA caml_gfx_data__msk,X
        AND caml_gfx_data__pat
        STA caml_gfx_data__val,X
        DEX
        BPL @v
        RTS
@hmask  !byte $80, $40, $20, $10, $08, $04, $02, $01
@mmask  !byte $C0, $30, $0C, $03
}

!ifdef caml_AUX__caml_gfx_rom_off {
caml_gfx_rom_off
        ;; Save R6510; if the bitmap is under the BASIC ROM, switch it off.
        LDA C64_R6510
        STA caml_gfx_data__r6510
        LDX caml_gfx_data__romoff
        BEQ @x
        AND # $FE
        STA C64_R6510
@x      RTS
}

!ifdef caml_AUX__caml_gfx_rom_restore {
caml_gfx_rom_restore
        LDA caml_gfx_data__r6510
        STA C64_R6510
        RTS
}

!ifdef caml_AUX__caml_gfx_inside {
caml_gfx_inside
        ;; Carry clear if 0 <= X1 < width and 0 <= Y1 < 200, else carry set.
        LDA caml_gfx_Y1 + 1
        BNE @no
        LDA caml_gfx_Y1
        CMP # 200
        BCS @no
        LDA caml_gfx_X1
        CMP caml_gfx_data__wlo
        LDA caml_gfx_X1 + 1
        SBC caml_gfx_data__whi          ;carry set if X1 >= width (or negative)
        RTS
@no     SEC
        RTS
}

!ifdef caml_AUX__caml_gfx_outcode {
caml_gfx_outcode
        ;; X = 0 for (X1,Y1), 4 for (X2,Y2). A := %YYXX outcode:
        ;; 1 = x < 0, 2 = x >= width, 4 = y < 0, 8 = y >= 200
        LDA # 0
        STA caml_gfx_T
        LDA caml_gfx_X1 + 1,X
        BPL @xpos
        LDA # 1
        STA caml_gfx_T
        BNE @y
@xpos   LDA caml_gfx_X1,X
        CMP caml_gfx_data__wlo
        LDA caml_gfx_X1 + 1,X
        SBC caml_gfx_data__whi
        BCC @y
        LDA # 2
        STA caml_gfx_T
@y      LDA caml_gfx_Y1 + 1,X
        BPL @ypos
        LDA caml_gfx_T
        ORA # 4
        STA caml_gfx_T
        BNE @e
@ypos   LDA caml_gfx_Y1 + 1,X
        BNE @ybig
        LDA caml_gfx_Y1,X
        CMP # 200
        BCC @e
@ybig   LDA caml_gfx_T
        ORA # 8
        STA caml_gfx_T
@e      LDA caml_gfx_T
        RTS
}

!ifdef caml_AUX__caml_gfx_locate {
caml_gfx_locate
        ;; In: X1 in 0..width-1, Y1 in 0..199.
        ;; Out: PTR = address of the cell line, X = pixel position in the cell
        ;;      (0..npos-1), Y = line in the cell (0..7).
        ;; The column offset is built directly in PTR: hires x & $F8 (+256 if
        ;; x >= 256), multicolor (x & $FC) * 2 (x < 160), then added to the
        ;; address of the cell row.
        LDA caml_gfx_Y1
        AND # 7
        TAY                             ;Y := line in the cell
        LDA caml_gfx_Y1
        LSR
        LSR
        LSR
        TAX                             ;X := cell row
        LDA caml_gfx_data__mc
        BNE @mc
        LDA caml_gfx_X1                 ;hires: column * 8
        AND # $F8
        STA caml_gfx_PTR
        LDA caml_gfx_X1 + 1
        STA caml_gfx_PTR + 1
@add    CLC
        LDA caml_gfx_PTR
        ADC caml_gfx_data__rowlo,X
        STA caml_gfx_PTR
        LDA caml_gfx_PTR + 1
        ADC caml_gfx_data__rowhi,X
        STA caml_gfx_PTR + 1
        LDA caml_gfx_X1
        AND caml_gfx_data__pmask
        TAX                             ;X := position in the cell
        RTS
@mc     LDA caml_gfx_X1                 ;multicolor: column * 8
        AND # $FC                       ; = (x & $FC) * 2, carry = bit 7
        ASL
        STA caml_gfx_PTR
        LDA # 0
        ROL
        STA caml_gfx_PTR + 1
        JMP @add
}

;; ---- virtual window -------------------------------------------------------------

!ifdef caml_AUX__caml_gfx_tx {
caml_gfx_tx
        ;; V := transform(V) for axis Y (0 = x, 1 = y); saturated to +-16383.
        LDA caml_gfx_data__neg,Y
        BNE @flip
        SEC
        LDA caml_gfx_V
        SBC caml_gfx_data__orglo,Y
        STA caml_gfx_D
        LDA caml_gfx_V + 1
        SBC caml_gfx_data__orghi,Y
        STA caml_gfx_D + 1
        JMP @sign
@flip   SEC
        LDA caml_gfx_data__orglo,Y
        SBC caml_gfx_V
        STA caml_gfx_D
        LDA caml_gfx_data__orghi,Y
        SBC caml_gfx_V + 1
        STA caml_gfx_D + 1
@sign   LDA caml_gfx_D + 1
        STA caml_gfx_SG                 ;bit 7 = sign
        BPL @mag
        +caml_gfx_neg16 caml_gfx_D      ;D := |D|
@mag    LDA # 0
        STA caml_gfx_P
        STA caml_gfx_P + 1
        STA caml_gfx_P + 2
        STA caml_gfx_P + 3
        STA caml_gfx_P + 4
        LDX # 16
@mul    LSR caml_gfx_D + 1
        ROR caml_gfx_D
        BCC @shift
        CLC
        LDA caml_gfx_P + 2
        ADC caml_gfx_data__k0,Y
        STA caml_gfx_P + 2
        LDA caml_gfx_P + 3
        ADC caml_gfx_data__k1,Y
        STA caml_gfx_P + 3
        LDA caml_gfx_P + 4
        ADC caml_gfx_data__k2,Y
        STA caml_gfx_P + 4
@shift  ROR caml_gfx_P + 4
        ROR caml_gfx_P + 3
        ROR caml_gfx_P + 2
        ROR caml_gfx_P + 1
        ROR caml_gfx_P
        DEX
        BNE @mul
        ;; product = P4:P3:P2:P1:P0; integer part = P4:P3:P2
        LDA caml_gfx_SG
        BPL @sat
        LDA caml_gfx_P                  ;negative: floor => add 1 if fractional
        ORA caml_gfx_P + 1
        BEQ @sat
        INC caml_gfx_P + 2
        BNE @sat
        INC caml_gfx_P + 3
        BNE @sat
        INC caml_gfx_P + 4
@sat    LDA caml_gfx_P + 4
        BNE @big
        LDA caml_gfx_P + 3
        CMP # $40
        BCC @fit
@big    LDA # $FF
        STA caml_gfx_P + 2
        LDA # $3F
        STA caml_gfx_P + 3
@fit    LDA caml_gfx_SG
        BPL @store
        SEC
        LDA # 0
        SBC caml_gfx_P + 2
        STA caml_gfx_V
        LDA # 0
        SBC caml_gfx_P + 3
        STA caml_gfx_V + 1
        RTS
@store  LDA caml_gfx_P + 2
        STA caml_gfx_V
        LDA caml_gfx_P + 3
        STA caml_gfx_V + 1
        RTS
}

!ifdef caml_AUX__caml_gfx_xf {
caml_gfx_xf
        ;; Transform the 16 bit value at TMP + X (X = 0, 2, 4, 6) with axis Y.
        LDA TMP,X
        STA caml_gfx_V
        LDA TMP + 1,X
        STA caml_gfx_V + 1
        TXA
        PHA
        JSR caml_gfx_tx
        PLA
        TAX
        LDA caml_gfx_V
        STA TMP,X
        LDA caml_gfx_V + 1
        STA TMP + 1,X
        RTS
}

!ifdef caml_AUX__caml_gfx_xfall {
caml_gfx_xfall
        ;; Transform X1,Y1,X2,Y2.
        LDX # 0
        LDY # 0
        JSR caml_gfx_xf
        LDX # 2
        LDY # 1
        JSR caml_gfx_xf
        LDX # 4
        LDY # 0
        JSR caml_gfx_xf
        LDX # 6
        LDY # 1
        JMP caml_gfx_xf
}

!ifdef caml_AUX__caml_gfx_div32 {
caml_gfx_div32
        ;; N (32 bit) := N / DV (16 bit); R := remainder.
        LDA # 0
        STA caml_gfx_R
        STA caml_gfx_R + 1
        LDX # 32
@l      ASL caml_gfx_N
        ROL caml_gfx_N + 1
        ROL caml_gfx_N + 2
        ROL caml_gfx_N + 3
        ROL caml_gfx_R
        ROL caml_gfx_R + 1
        BCS @sub
        LDA caml_gfx_R
        CMP caml_gfx_DV
        LDA caml_gfx_R + 1
        SBC caml_gfx_DV + 1
        BCC @nx
@sub    SEC
        LDA caml_gfx_R
        SBC caml_gfx_DV
        STA caml_gfx_R
        LDA caml_gfx_R + 1
        SBC caml_gfx_DV + 1
        STA caml_gfx_R + 1
        INC caml_gfx_N
@nx     DEX
        BNE @l
        RTS
}

!ifdef caml_AUX__caml_gfx_winaxis {
caml_gfx_winaxis
        ;; X = 0 / 2 and Y = 0 / 1 for the x / y axis. The window is
        ;; [TMP + X, TMP + 4 + X] (16 bit each: origin, other end).
        SEC
        LDA TMP + 4,X
        SBC TMP,X
        STA caml_gfx_DV
        LDA TMP + 5,X
        SBC TMP + 1,X
        STA caml_gfx_DV + 1
        LDA # 0
        STA caml_gfx_data__neg,Y
        LDA caml_gfx_DV + 1
        BPL @pos
        LDA # 1
        STA caml_gfx_data__neg,Y
        +caml_gfx_neg16 caml_gfx_DV     ;DV := |span|
@pos    LDA caml_gfx_DV + 1
        BNE @ok
        LDA caml_gfx_DV
        CMP # 2
        BCS @ok
        +caml_raise Invalid_argument, "C64.Gfx.window"
@ok     LDA TMP,X
        STA caml_gfx_data__orglo,Y
        LDA TMP + 1,X
        STA caml_gfx_data__orghi,Y
        ;; N := ((size - 1) << 16) + (|span| - 1)   =>  N / |span| = K
        SEC
        LDA caml_gfx_DV
        SBC # 1
        STA caml_gfx_N
        LDA caml_gfx_DV + 1
        SBC # 0
        STA caml_gfx_N + 1
        CPY # 0
        BNE @yaxis
        SEC
        LDA caml_gfx_data__wlo
        SBC # 1
        STA caml_gfx_N + 2
        LDA caml_gfx_data__whi
        SBC # 0
        STA caml_gfx_N + 3
        JMP @div
@yaxis  LDA # 199
        STA caml_gfx_N + 2
        LDA # 0
        STA caml_gfx_N + 3
@div    TXA
        PHA
        TYA
        PHA
        JSR caml_gfx_div32
        PLA
        TAY
        PLA
        TAX
        LDA caml_gfx_N
        STA caml_gfx_data__k0,Y
        LDA caml_gfx_N + 1
        STA caml_gfx_data__k1,Y
        LDA caml_gfx_N + 2
        STA caml_gfx_data__k2,Y
        RTS
}

;; ---- init / exit / pen ---------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_gfx_init {
caml_nonstd_gfx_init
        ;; Gfx.init bank screen bitmap mode  (offsets are within the VIC bank)
        +caml_gfx_arg_acc caml_gfx_X1   ;bank 0..2
        +caml_gfx_arg_sp 0, caml_gfx_Y1 ;screen offset: multiple of $400
        +caml_gfx_arg_sp 1, caml_gfx_X2 ;bitmap offset: 0 or $2000
        +caml_gfx_arg_sp 2, caml_gfx_Y2 ;mode: 0 hires, 1 multicolor
        JMP @check
@bad    +caml_raise Invalid_argument, "C64.Gfx.init"
@check  LDA caml_gfx_X1 + 1
        BNE @bad
        LDA caml_gfx_X1
        CMP # 3
        BCS @bad                        ;bank must be 0..2
        LDA caml_gfx_X2
        BNE @bad
        LDA caml_gfx_X2 + 1
        BEQ @bm0
        CMP # $20
        BNE @bad                        ;bitmap offset must be 0 or $2000
        BEQ @bmok
@bm0    LDA caml_gfx_X1
        CMP # 1
        BNE @bad                        ;offset 0 of banks 0, 2 overlaps the char ROM image
@bmok   LDA caml_gfx_Y1
        BNE @bad
        LDA caml_gfx_Y1 + 1
        AND # 3
        BNE @bad                        ;screen offset must be a multiple of $400
        LDA caml_gfx_Y1 + 1
        CMP # $40
        BCS @bad
        LDX caml_gfx_X1
        CPX # 1
        BEQ @scrok                      ;bank 1 has no char ROM image
        CMP # $10
        BCC @scrok
        CMP # $20
        BCC @bad                        ;screen in the char ROM image ($1000-$1FFF)
@scrok  LDA caml_gfx_Y2 + 1
        BNE @bad
        LDA caml_gfx_Y2
        CMP # 2
        BCS @bad
        STA caml_gfx_data__mc
        ;; bitmap start page = bank * $40 + (bitmap offset >> 8)
        LDA caml_gfx_X1
        ASL
        ASL
        ASL
        ASL
        ASL
        ASL
        CLC
        ADC caml_gfx_X2 + 1
        STA caml_gfx_data__bmphi
        AND # $E0
        LDX # 0
        CMP # $A0
        BNE +
        INX
+       STX caml_gfx_data__romoff
        ;; mode dependent data
        LDA caml_gfx_data__mc
        BNE @mcdat
        LDA # 8
        STA caml_gfx_data__npos
        LDA # 7
        STA caml_gfx_data__pmask
        LDA # <320
        STA caml_gfx_data__wlo
        LDA # >320
        STA caml_gfx_data__whi
        LDA # $FF
        STA caml_gfx_data__pat
        BNE @rows                       ;(always)
@mcdat  LDA # 4
        STA caml_gfx_data__npos
        LDA # 3
        STA caml_gfx_data__pmask
        LDA # <160
        STA caml_gfx_data__wlo
        LDA # >160
        STA caml_gfx_data__whi
        LDA # $55
        STA caml_gfx_data__pat
@rows   LDA # 0
        STA caml_gfx_data__win
        STA caml_gfx_PTR
        LDA caml_gfx_data__bmphi
        STA caml_gfx_PTR + 1
        LDX # 0
@row    LDA caml_gfx_PTR
        STA caml_gfx_data__rowlo,X
        LDA caml_gfx_PTR + 1
        STA caml_gfx_data__rowhi,X
        CLC
        LDA caml_gfx_PTR
        ADC # <320
        STA caml_gfx_PTR
        LDA caml_gfx_PTR + 1
        ADC # >320
        STA caml_gfx_PTR + 1
        INX
        CPX # 25
        BNE @row
        JSR caml_gfx_tabs
        ;; VIC: memory control, bitmap mode, multicolor, bank
        LDA caml_gfx_Y1 + 1
        LSR
        LSR                             ;screen offset / $400
        ASL
        ASL
        ASL
        ASL
        STA caml_gfx_T
        LDA caml_gfx_X2 + 1
        BEQ +
        LDA caml_gfx_T
        ORA # %00001000                 ;bitmap at offset $2000
        STA caml_gfx_T
+       LDA caml_gfx_T
        STA C64_VIC_VMCB
        LDA C64_VIC_CR1
        ORA # %00100000                 ;BMM
        STA C64_VIC_CR1
        LDA C64_VIC_CR2
        AND # %11101111
        LDX caml_gfx_data__mc
        BEQ +
        ORA # %00010000                 ;MCM
+       STA C64_VIC_CR2
        LDA C64_CIA2_PRA
        AND # %11111100
        STA caml_gfx_T
        LDA # 3
        SEC
        SBC caml_gfx_X1
        ORA caml_gfx_T
        STA C64_CIA2_PRA                ;VIC bank (inverted bits)
        LDY # 0
        +caml_gfx_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_gfx_exit {
caml_nonstd_gfx_exit
        ;; Gfx.exit: back to the text mode, bank 0, standard memory control
        LDA C64_VIC_CR1
        AND # %11011111
        STA C64_VIC_CR1
        LDA C64_VIC_CR2
        AND # %11101111
        STA C64_VIC_CR2
        LDA # $15
        STA C64_VIC_VMCB
        LDA C64_CIA2_PRA
        ORA # %00000011
        STA C64_CIA2_PRA
        LDY # 0
        +caml_gfx_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_gfx_pen {
caml_nonstd_gfx_pen
        ;; Gfx.pen p: hires 0 / 1; multicolor 0..3
        LDA ACCU
        LSR                             ;A := p (low byte)
        LDX caml_gfx_data__mc
        BNE @mc
        AND # 1
        BEQ @set
        LDA # $FF
        BNE @set
@mc     AND # 3
        TAX
        LDA @pats,X
@set    STA caml_gfx_data__pat
        JSR caml_gfx_tabs
        LDY # 0
        +caml_gfx_ret_unit
        RTS
@pats   !byte $00, $55, $AA, $FF
}

;; ---- plot / point ---------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_gfx_plot {
caml_nonstd_gfx_plot
        ;; Gfx.plot x y
        +caml_gfx_arg_acc caml_gfx_X1
        +caml_gfx_arg_sp 0, caml_gfx_Y1
        LDA caml_gfx_data__win
        BEQ @nowin
        LDX # 0
        LDY # 0
        JSR caml_gfx_xf
        LDX # 2
        LDY # 1
        JSR caml_gfx_xf
@nowin  JSR caml_gfx_inside
        BCS @done
        JSR caml_gfx_rom_off
        JSR caml_gfx_locate
        LDA (caml_gfx_PTR),Y
        AND caml_gfx_data__nmsk,X
        ORA caml_gfx_data__val,X
        STA (caml_gfx_PTR),Y
        JSR caml_gfx_rom_restore
@done   LDY # 0
        +caml_gfx_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_gfx_point {
caml_nonstd_gfx_point
        ;; Gfx.point x y: pen value of the pixel (0..3), or -1 if outside
        +caml_gfx_arg_acc caml_gfx_X1
        +caml_gfx_arg_sp 0, caml_gfx_Y1
        LDA caml_gfx_data__win
        BEQ @nowin
        LDX # 0
        LDY # 0
        JSR caml_gfx_xf
        LDX # 2
        LDY # 1
        JSR caml_gfx_xf
@nowin  JSR caml_gfx_inside
        BCC @in
        LDA # $FF
        STA ACCU
        STA ACCU + 1                    ;ACCU := Val_int(-1)
        LDY # 0
        RTS
@in     JSR caml_gfx_rom_off
        JSR caml_gfx_locate
        LDA (caml_gfx_PTR),Y
        AND caml_gfx_data__msk,X
        STA caml_gfx_T
        JSR caml_gfx_rom_restore
        LDA caml_gfx_data__mc
        BNE @mc
        LDA caml_gfx_T
        BEQ @ret
        LDA # 1
        BNE @ret
@mc     TXA
        EOR # 3
        ASL
        TAX                             ;X := 2 * (3 - position)
        LDA caml_gfx_T
@sh     CPX # 0
        BEQ @ret
        LSR
        DEX
        JMP @sh
@ret    LDY # 0
        +caml_gfx_ret_int
        RTS
}

;; ---- line -----------------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_gfx_line {
caml_nonstd_gfx_line
        ;; Gfx.line x1 y1 x2 y2
        +caml_gfx_arg_acc caml_gfx_X1
        +caml_gfx_arg_sp 0, caml_gfx_Y1
        +caml_gfx_arg_sp 1, caml_gfx_X2
        +caml_gfx_arg_sp 2, caml_gfx_Y2
        LDA caml_gfx_data__win
        BEQ @nowin
        JSR caml_gfx_xfall
@nowin  LDX # 0
        JSR caml_gfx_outcode
        STA caml_gfx_T + 1
        LDX # 4
        JSR caml_gfx_outcode
        STA caml_gfx_T + 2
        AND caml_gfx_T + 1
        BNE @done                       ;both ends on the same outer side
        LDA caml_gfx_T + 1
        ORA caml_gfx_T + 2
        BNE @slow
        JMP caml_gfx_fastline
@slow   JMP caml_gfx_slowline
@done   LDY # 0
        +caml_gfx_ret_unit
        RTS
}

!ifdef caml_AUX__caml_gfx_fastline {
caml_gfx_fastline
        ;; Both endpoints are inside the screen. Self-modifying Bresenham:
        ;; the step routines @xstep and @ystep and the JSRs to them are patched
        ;; for the direction and for the major axis.
        JSR caml_gfx_rom_off
        JSR caml_gfx_locate             ;PTR, X, Y := start pixel
        SEC
        LDA caml_gfx_X2
        SBC caml_gfx_X1
        STA caml_gfx_DX
        LDA caml_gfx_X2 + 1
        SBC caml_gfx_X1 + 1
        STA caml_gfx_DX + 1
        LDA # 0
        STA caml_gfx_SXN
        STA caml_gfx_SYN
        LDA caml_gfx_DX + 1
        BPL @dxp
        INC caml_gfx_SXN
        +caml_gfx_neg16 caml_gfx_DX     ;DX := |dx|
@dxp    SEC
        LDA caml_gfx_Y2
        SBC caml_gfx_Y1
        BCS @dyp
        INC caml_gfx_SYN
        EOR # $FF
        ADC # 1                         ;(carry is clear) A := |dy|
@dyp    STA caml_gfx_DY
        ;; major axis: x if dx >= dy
        LDA caml_gfx_DX + 1
        BNE @xmaj
        LDA caml_gfx_DX
        CMP caml_gfx_DY
        BCS @xmaj
        ;; y-major: MAJ = dy, MIN = dx
        LDA caml_gfx_DY
        STA caml_gfx_MAJ
        LDA # 0
        STA caml_gfx_MAJ + 1
        LDA caml_gfx_DX
        STA caml_gfx_MIN
        LDA # <@ystep
        STA @jmaj + 1
        LDA # >@ystep
        STA @jmaj + 2
        LDA # <@xstep
        STA @jmin + 1
        LDA # >@xstep
        STA @jmin + 2
        JMP @common
@xmaj   LDA caml_gfx_DX
        STA caml_gfx_MAJ
        LDA caml_gfx_DX + 1
        STA caml_gfx_MAJ + 1
        LDA caml_gfx_DY
        STA caml_gfx_MIN
        LDA # <@xstep
        STA @jmaj + 1
        LDA # >@xstep
        STA @jmaj + 2
        LDA # <@ystep
        STA @jmin + 1
        LDA # >@ystep
        STA @jmin + 2
@common ;; E := -((MAJ + 1) >> 1); CNT := MAJ
        LDA caml_gfx_MAJ
        STA caml_gfx_CNT
        CLC
        ADC # 1
        STA caml_gfx_E
        LDA caml_gfx_MAJ + 1
        STA caml_gfx_CNT + 1
        ADC # 0
        STA caml_gfx_E + 1
        LSR caml_gfx_E + 1
        ROR caml_gfx_E
        +caml_gfx_neg16 caml_gfx_E
        ;; x direction
        LDA caml_gfx_SXN
        BNE @xneg
        LDA # $E8                       ;INX
        STA @xinc
        LDA caml_gfx_data__npos
        STA @xchk + 1                   ;CPX #npos
        LDA # 0
        STA @xld + 1                    ;LDX #0
        LDA # 8
        STA @xwlo + 1                   ;ADC #8
        LDA # 0
        STA @xwhi + 1                   ;ADC #0
        JMP @ydir
@xneg   LDA # $CA                       ;DEX
        STA @xinc
        LDA # $FF
        STA @xchk + 1                   ;CPX #$FF
        LDX caml_gfx_data__npos
        DEX
        STX @xld + 1                    ;LDX #npos-1
        LDA # $F8
        STA @xwlo + 1                   ;ADC #-8
        LDA # $FF
        STA @xwhi + 1
@ydir   LDA caml_gfx_SYN
        BNE @yneg
        LDA # $C8                       ;INY
        STA @yinc
        LDA # 8
        STA @ychk + 1                   ;CPY #8
        LDA # 0
        STA @yld + 1                    ;LDY #0
        LDA # <320
        STA @ywlo + 1                   ;ADC #<320
        LDA # >320
        STA @ywhi + 1                   ;ADC #>320
        JMP @go
@yneg   LDA # $88                       ;DEY
        STA @yinc
        LDA # $FF
        STA @ychk + 1                   ;CPY #$FF
        LDA # 7
        STA @yld + 1                    ;LDY #7
        LDA # <(-320)
        STA @ywlo + 1
        LDA # >(-320 & $FFFF)
        STA @ywhi + 1
@go     JSR caml_gfx_locate             ;PTR, X, Y := start pixel (again)
@loop   LDA (caml_gfx_PTR),Y            ;plot
        AND caml_gfx_data__nmsk,X
        ORA caml_gfx_data__val,X
        STA (caml_gfx_PTR),Y
        LDA caml_gfx_CNT
        ORA caml_gfx_CNT + 1
        BEQ @end
        LDA caml_gfx_CNT
        BNE +
        DEC caml_gfx_CNT + 1
+       DEC caml_gfx_CNT
@jmaj   JSR @xstep                      ;(patched) major axis step
        CLC
        LDA caml_gfx_E
        ADC caml_gfx_MIN
        STA caml_gfx_E
        BCC +
        INC caml_gfx_E + 1
+       LDA caml_gfx_E + 1
        BMI @loop                       ;E < 0: no minor step
        SEC
        LDA caml_gfx_E
        SBC caml_gfx_MAJ
        STA caml_gfx_E
        LDA caml_gfx_E + 1
        SBC caml_gfx_MAJ + 1
        STA caml_gfx_E + 1
@jmin   JSR @ystep                      ;(patched) minor axis step
        JMP @loop
@end    JSR caml_gfx_rom_restore
        LDY # 0
        +caml_gfx_ret_unit
        RTS
@xstep
@xinc   INX                             ;(patched INX / DEX)
@xchk   CPX # 8                         ;(patched) npos / $FF
        BNE @xr
@xld    LDX # 0                         ;(patched) 0 / npos-1
        LDA caml_gfx_PTR
        CLC
@xwlo   ADC # 8                         ;(patched) +8 / -8
        STA caml_gfx_PTR
        LDA caml_gfx_PTR + 1
@xwhi   ADC # 0                         ;(patched)
        STA caml_gfx_PTR + 1
@xr     RTS
@ystep
@yinc   INY                             ;(patched INY / DEY)
@ychk   CPY # 8                         ;(patched) 8 / $FF
        BNE @yr
@yld    LDY # 0                         ;(patched) 0 / 7
        LDA caml_gfx_PTR
        CLC
@ywlo   ADC # <320                      ;(patched) +320 / -320
        STA caml_gfx_PTR
        LDA caml_gfx_PTR + 1
@ywhi   ADC # >320                      ;(patched)
        STA caml_gfx_PTR + 1
@yr     RTS
}

!ifdef caml_AUX__caml_gfx_slowline {
caml_gfx_slowline
        ;; At least one endpoint is outside the screen: clip pixel by pixel.
        JSR caml_gfx_rom_off
        SEC
        LDA caml_gfx_X2
        SBC caml_gfx_X1
        STA caml_gfx_DX
        LDA caml_gfx_X2 + 1
        SBC caml_gfx_X1 + 1
        STA caml_gfx_DX + 1
        LDA # 1
        STA caml_gfx_SXL
        LDA # 0
        STA caml_gfx_SXH
        LDA caml_gfx_DX + 1
        BPL @dxp
        LDA # $FF
        STA caml_gfx_SXL
        STA caml_gfx_SXH
        +caml_gfx_neg16 caml_gfx_DX
@dxp    SEC
        LDA caml_gfx_Y2
        SBC caml_gfx_Y1
        STA caml_gfx_DY
        LDA caml_gfx_Y2 + 1
        SBC caml_gfx_Y1 + 1
        STA caml_gfx_DY + 1
        LDA # 1
        STA caml_gfx_SYL
        LDA # 0
        STA caml_gfx_SYH
        LDA caml_gfx_DY + 1
        BPL @dyp
        LDA # $FF
        STA caml_gfx_SYL
        STA caml_gfx_SYH
        +caml_gfx_neg16 caml_gfx_DY
@dyp    ;; major axis: x if DX >= DY (16 bit)
        LDA caml_gfx_DX
        CMP caml_gfx_DY
        LDA caml_gfx_DX + 1
        SBC caml_gfx_DY + 1
        BCC @ymaj
        LDA # 1
        STA caml_gfx_XM
        LDA caml_gfx_DX
        STA caml_gfx_MAJ
        LDA caml_gfx_DX + 1
        STA caml_gfx_MAJ + 1
        LDA caml_gfx_DY
        STA caml_gfx_MIN
        LDA caml_gfx_DY + 1
        STA caml_gfx_MIN + 1
        JMP @init
@ymaj   LDA # 0
        STA caml_gfx_XM
        LDA caml_gfx_DY
        STA caml_gfx_MAJ
        LDA caml_gfx_DY + 1
        STA caml_gfx_MAJ + 1
        LDA caml_gfx_DX
        STA caml_gfx_MIN
        LDA caml_gfx_DX + 1
        STA caml_gfx_MIN + 1
@init   LDA caml_gfx_MAJ
        STA caml_gfx_CNT
        CLC
        ADC # 1
        STA caml_gfx_E
        LDA caml_gfx_MAJ + 1
        STA caml_gfx_CNT + 1
        ADC # 0
        STA caml_gfx_E + 1
        LSR caml_gfx_E + 1
        ROR caml_gfx_E
        +caml_gfx_neg16 caml_gfx_E
@loop   JSR caml_gfx_inside
        BCS @np
        JSR caml_gfx_locate
        LDA (caml_gfx_PTR),Y
        AND caml_gfx_data__nmsk,X
        ORA caml_gfx_data__val,X
        STA (caml_gfx_PTR),Y
@np     LDA caml_gfx_CNT
        ORA caml_gfx_CNT + 1
        BEQ @end
        LDA caml_gfx_CNT
        BNE +
        DEC caml_gfx_CNT + 1
+       DEC caml_gfx_CNT
        LDA caml_gfx_XM
        BEQ @majy
        JSR @addx
        JMP @err
@majy   JSR @addy
@err    CLC
        LDA caml_gfx_E
        ADC caml_gfx_MIN
        STA caml_gfx_E
        LDA caml_gfx_E + 1
        ADC caml_gfx_MIN + 1
        STA caml_gfx_E + 1
        BMI @loop
        SEC
        LDA caml_gfx_E
        SBC caml_gfx_MAJ
        STA caml_gfx_E
        LDA caml_gfx_E + 1
        SBC caml_gfx_MAJ + 1
        STA caml_gfx_E + 1
        LDA caml_gfx_XM
        BEQ @minx
        JSR @addy
        JMP @loop
@minx   JSR @addx
        JMP @loop
@end    JSR caml_gfx_rom_restore
        LDY # 0
        +caml_gfx_ret_unit
        RTS
@addx   CLC
        LDA caml_gfx_X1
        ADC caml_gfx_SXL
        STA caml_gfx_X1
        LDA caml_gfx_X1 + 1
        ADC caml_gfx_SXH
        STA caml_gfx_X1 + 1
        RTS
@addy   CLC
        LDA caml_gfx_Y1
        ADC caml_gfx_SYL
        STA caml_gfx_Y1
        LDA caml_gfx_Y1 + 1
        ADC caml_gfx_SYH
        STA caml_gfx_Y1 + 1
        RTS
}

;; ---- virtual window primitives --------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_gfx_window {
caml_nonstd_gfx_window
        ;; Gfx.window x0 y0 x1 y1: (x0,y0) -> (0,0), (x1,y1) -> (width-1, 199)
        +caml_gfx_arg_acc caml_gfx_X1
        +caml_gfx_arg_sp 0, caml_gfx_Y1
        +caml_gfx_arg_sp 1, caml_gfx_X2
        +caml_gfx_arg_sp 2, caml_gfx_Y2
        LDX # 0
        LDY # 0
        JSR caml_gfx_winaxis
        LDX # 2
        LDY # 1
        JSR caml_gfx_winaxis
        LDA # 1
        STA caml_gfx_data__win
        LDY # 0
        +caml_gfx_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_gfx_unwindow {
caml_nonstd_gfx_unwindow
        LDA # 0
        STA caml_gfx_data__win
        LDY # 0
        +caml_gfx_ret_unit
        RTS
}

}       ;; !zone caml_C64_GFX
