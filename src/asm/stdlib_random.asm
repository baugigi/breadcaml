;; ——————————————————————————————————————————————————————————————————————
;; Progetto BreadCaml / The BreadCaml Project
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;;
;; Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
;; modificarlo secondo i  termini della GNU General  Public License (GPL)
;; versione  2,  come specificato  nel  file  LICENZA-it nella  directory
;; principale del progetto.
;;
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the  GNU General Public License (GPL) version 2,
;; as specified in the LICENSE-en file in the project root.
;; ——————————————————————————————————————————————————————————————————————

;;; --------------------
;;;        RANDOM
;;; --------------------

;; X ABC Algorithm Pseudo-Random Number Generator for 8-Bit Devices.
;; Quite fast, but not good for cryptographic/security purposes.
;; From EternityForest, https://www.electro-tech-online.com/threads/
;;      ultra-fast-pseudorandom-number-generator-for-8-bit.124249/
;; With modifications by Stix:
;;      https://www.stix.id.au/wiki/Fast_8-bit_pseudorandom_number_generator
;; Stix's statistics about the cycles of this PRNG:
;;     Length   Count   Seeds (a,b,c,x)
;; 2826386176    1      00,00,00,00
;;  653676288    1      10,00,00,00
;;  630179072    1      11,00,00,00
;;  136099072    1      2A,00,00,00
;;   19772672    2      7B,00,00,00  41,02,00,00
;;    3474944    2      5E,02,00,00  BC,04,00,00
;;     647936    1      E2,34,00,00
;;     401152    1      52,27,00,00
;;     224512    1      3E,19,00,00
;;     196864    1      2B,38,00,00
;;     156160    2      70,27,00,00  03,83,01,00
;;      90112    2      FE,3A,00,00  D1,CE,00,00
;;      66048    2      1A,0B,01,00  EA,8D,01,00
;;       9472    2      65,1D,06,00  53,7E,15,00
;;       5376    2      E8,19,01,00  5D,9D,0C,00
;;       2048    2      F0,D3,0D,00  7A,F9,54,00
;;        512    4      4C,95,3A,00  CF,EC,55,00  97,F6,70,00  E6,26,D3,00
;;        256    2      00,02,01,00  7A,9D,21,00
;; ----------   --
;; 4294967296   30
;;
;; Please note that those statistics are about 8-bit random numbers (returned in
;; caml_nonstd_random_int__a); for BreadCaml purposes, I take a 15-bit OCaml
;; integer from caml_nonstd_random_int__a (lo bits) and caml_nonstd_random_int__b
;; (hi bits, discarding bit #7): this may affect the whole algorithm strength.

!zone caml_RANDOM {

!ifdef caml_PRIM__caml_nonstd_random_int {
caml_nonstd_random_int
        INC caml_nonstd_random_int__x
caml_nonstd_random_int__x = * + 1
        LDA # $00                               ;SMC: LDA __x
        EOR caml_nonstd_random_int__c
caml_nonstd_random_int__a = * + 1
        EOR # $00                               ;SMC: EOR __a
        STA caml_nonstd_random_int__a
        CLC
caml_nonstd_random_int__b = * + 1
        ADC # $00                               ;SMC: ADC __b
        STA caml_nonstd_random_int__b
        LSR
        BCC +                                   ;Stix's mod: LSR changed with
        ORA # $80                               ;8-bit right rotate
+       EOR caml_nonstd_random_int__a
caml_nonstd_random_int__c = * + 1
        ADC # $00                               ;SMC: ADC __c
        STA caml_nonstd_random_int__c
        LDA caml_nonstd_random_int__a           ;__a is the 8-bit random number
        ;; end of PRNG algo
        SEC
        ROL                                     ;Return a 15-bit OCaml integer
        STA ACCU                                ;from __a and __b, discarding
        LDA caml_nonstd_random_int__b           ;bit#7 of __b
        ROL
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_nonstd_random_self_init {
caml_nonstd_random_self_init
        ;; ARG0 is (), returned as is
        LDA C64_TIME + 2                        ;Use the jiffy clock and the
        STA caml_nonstd_random_int__x           ;current raster line no. to
        EOR C64_VIC_RASTER                      ;generate a "random" seed
        STA caml_nonstd_random_int__a
-       ASL                                     ;"random" delay
        BNE -
        LDA caml_nonstd_random_int__x
        EOR C64_VIC_RASTER
        STA caml_nonstd_random_int__b
-       LSR                                     ;"random" delay
        BNE -
        LDA C64_VIC_RASTER
        STA caml_nonstd_random_int__c
        RTS
}

!ifdef caml_PRIM__caml_nonstd_random_set_state {
caml_nonstd_random_set_state
        ;; ARG0 is a 4-char string "xabc"
        LDY #3
        LDA (ACCU),Y
        STA caml_nonstd_random_int__c
        DEY
        LDA (ACCU),Y
        STA caml_nonstd_random_int__b
        DEY
        LDA (ACCU),Y
        STA caml_nonstd_random_int__a
        DEY
        LDA (ACCU),Y
        STA caml_nonstd_random_int__x
        STY ACCU + 1
        LDA #<Val_unit
        STA ACCU
        RTS
}

!ifdef caml_PRIM__caml_nonstd_random_get_state {
caml_nonstd_random_get_state
        ;; return a 4-char string "xabc"
        LDX # 3
        LDA # String_tag
        JSR caml_alloc
        LDY # 5
        LDA # 1                                 ;OCaml string padding \001
        STA (BLK),Y
        DEY
        LDA # 0                                 ;OCaml string padding \000
        STA (BLK),Y
        DEY
        LDA caml_nonstd_random_int__c
        STA (BLK),Y
        DEY
        LDA caml_nonstd_random_int__b
        STA (BLK),Y
        DEY
        LDA caml_nonstd_random_int__a
        STA (BLK),Y
        DEY
        LDA caml_nonstd_random_int__x
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}
}       ;; !zone caml_RANDOM
