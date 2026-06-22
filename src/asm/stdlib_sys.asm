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

;;; -----------------
;;;       SYS
;;; -----------------

!ifdef caml_PRIM__caml_nonstd_mem_peek {
caml_nonstd_mem_peek
	;; Sys.mem_peek lo hi returns the content of memory location at address
	;; 256*hi+lo as an integer; lo, hi are taken modulo 256.
	LSR ACCU + 1
	ROR ACCU
	INY
	LDA (SP),Y
	LSR
	DEY
	LDA (SP),Y
	ROR
	STA ACCU + 1
	LDA (ACCU),Y
	SEC
	ROL
	STA ACCU
	STY ACCU + 1
	ROL ACCU + 1
	RTS
}
