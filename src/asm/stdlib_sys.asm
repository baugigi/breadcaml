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
;;                                    SYS
;; -----------------------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_mem_peek {
caml_nonstd_mem_peek
        ;; Sys.mem_peek lo hi returns the content of memory location at address
        ;; 256*hi+lo as an integer; lo, hi are taken modulo 256.
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        ROR ACCU + 1
        STA ACCU + 1
        ROR ACCU
        LDA (ACCU),Y
        ROL
        STA ACCU
        STY ACCU + 1
        ROL ACCU + 1
        RTS
}
