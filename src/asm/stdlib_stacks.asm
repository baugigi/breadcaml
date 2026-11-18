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
;;                                   STACK
;; -----------------------------------------------------------------------------

!zone caml_STACK {

!ifndef caml_stack_warn {
!set caml_stack_warn = 1
  !warn "TODO: caml_ensure_stack_capacity"
}

!ifdef caml_PRIM__caml_ensure_stack_capacity {
;; TODO: raise  Stack_overflow if stack space is not enough."
        ;; ACCU = required space (ignored)
caml_ensure_stack_capacity
        ;; do nothing and return Val_unit
        LDA # < Val_unit
        STA ACCU
        ;LDY # 0
        STY ACCU + 1
        RTS
}

}       ;; !zone caml_STACK

