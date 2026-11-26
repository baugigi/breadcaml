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
;;                       C64.Sound - timing helpers (PAL / NTSC)
;; -----------------------------------------------------------------------------
;; Frame length in CPU cycles tells the video standard (hence the SID clock):
;;      PAL 312 x 63 = 19656   NTSC 263 x 65 = 17095 (old NTSC 262 x 64 = 16768)
;;      PAL-N 312 x 65 = 20280
!zone caml_C64_SND {

!ifdef caml_PRIM__caml_nonstd_snd_frame_cycles {
caml_nonstd_snd_frame_cycles
        ;; Measures a whole frame with CIA2 timer B (free-running, no IRQ).
        ;; IRQs are masked for ~3 frames (the jiffy clock loses 3 ticks).
        PHP
        SEI
        LDA # 0
        STA C64_CIA2_CRB                ;stop timer B
        LDA # $FF
        STA C64_CIA2_TBLO
        STA C64_CIA2_TBHI
        LDA # %00010000
        STA C64_CIA2_CRB                ;force load $FFFF (still stopped)
        JSR @sync
        LDA # %00000001
        STA C64_CIA2_CRB                ;start at raster line 0
        JSR @sync
        LDA # 0
        STA C64_CIA2_CRB                ;stop at the next raster line 0
        SEC
        LDA # $FF
        SBC C64_CIA2_TBLO
        STA ACCU
        LDA # $FF
        SBC C64_CIA2_TBHI
        STA ACCU + 1                    ;elapsed cycles (up to 20280)
        LSR ACCU + 1
        ROR ACCU                        ;halved: must fit 15 bits
        SEC
        ROL ACCU
        ROL ACCU + 1                    ;Val_int
        PLP
        LDY # 0
        RTS
@sync   LDA C64_VIC_RASTER              ;leave line 0 ...
        BEQ @sync
@w0     LDA C64_VIC_RASTER              ;... and wait for the next one (bit 8 = 0)
        BNE @w0
        LDA C64_VIC_CR1
        BMI @w0
        RTS
}

!ifdef caml_PRIM__caml_nonstd_snd_wait_frame {
caml_nonstd_snd_wait_frame
        ;; Returns when the raster reaches line 248 (once per frame).
@a      LDA C64_VIC_RASTER
        CMP # $F8
        BEQ @a
@b      LDA C64_VIC_RASTER
        CMP # $F8
        BNE @b
        LDX # <Val_unit
        STX ACCU
        LDY # 0
        STY ACCU + 1
        RTS
}

}       ;; !zone caml_C64_SND
