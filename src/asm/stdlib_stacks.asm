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

;;; -----------------------------------------------------------
;;; STACK (ocaml-4.04.1/byterun/stacks.c)
;;; -----------------------------------------------------------

!zone caml_STACK {

!ifndef caml_stack_warn {
caml_stack_warn
  !warn "\nbreadcaml> TODO: caml_ensure_stack_capacity"
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

}	;; !zone caml_STACK

