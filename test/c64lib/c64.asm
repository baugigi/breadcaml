;; ——————————————————————————————————————————————————————————————————————
;; Progetto O64ml / The O64ml Project
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
;;;       C64
;;; -----------------

;;; To be assembled with -irqsupport option
!ifndef caml_IRQSUPPORT {
	!serious "Module C64 needs -irqsupport option."
}

!zone "IRQ" {
	.dummy = $1234				;for SMC
	.standard_irq_handler = $EA31		;address of standard IRQ handler
	
	;; ogni sezione critica degli opcode deve stare tra
	;;    SEI
	;; e
	;; !ifdef caml_IRQSUPPORT {
	;;    BIT caml_irq_flag
	;;    BMI +
	;;    CLI
	;; +
	;; }

caml_irq_flag					;$FF=handler is running, else 0
	!byte 0

!ifdef	caml_PRIM__caml_irq_set_callback_handler {
caml_irq_set_callback_handler
	SEI
	LDA # <@handlr
	STA C64_CINV
	LDA # >@handlr
	STA C64_CINV + 1
	LDA (ACCU),Y
	STA @code + 1
	INY
	LDA (ACCU),Y
	STA @code + 2
	DEY
	LDA # <Val_unit
	STA ACCU
	LDA # >Val_unit
	STA ACCU + 1
	CLI
	RTS
@handlr	LDA ACCU + 1				;Save ACCU
	PHA
	LDA ACCU
	PHA
	+caml_grow_stack 4
	LDY # 6					;Push the return frame:
	LDA XARGS				; XARGS
	STA (SP),Y
	DEY
	LDA # ENV + 1				; ENV
	STA (SP),Y
	DEY
	LDA # ENV
	STA (SP),Y
	DEY
	LDA # >+				; Return address
	STA (SP),Y
	DEY
	LDA # <+
	DEY
	STA (SP),Y
	DEY
	LDA # >Val_unit				;Push arg = ()
	STA (SP),Y
	STA ENV + 1				;Set ENV = ()
	DEY
	LDA # <Val_unit
	STA (SP),Y
	STA ENV
	STA XARGS				;Set XARGS = 0
	DEC caml_irq_flag			;Set flag to $FF: handling IRQ
@code	JMP .dummy				;SMC: JMP to function code
	INC caml_irq_flag		 	;Set flag to $00: IRQ handled
+	PLA					;Restore ACCU
	STA ACCU
	PLA
	STA ACCU + 1
	JMP .standard_irq_handler
}

!ifdef	caml_PRIM__caml_irq_set_custom_handler {
caml_irq_set_custom_handler
  !ifdef caml_irq_custom_handler {
    !set @addr = caml_irq_custom_handler
  } else {
    !set @addr = .standard_irq_handler
  }
	SEI
	LDA # <@addr
	STA C64_CINV
	LDA # >@addr
	STA C64_CINV + 1
	LDA # <Val_unit
	STA ACCU
	LDA # >Val_unit
	STA ACCU + 1
	CLI
	RTS
}

!ifdef	caml_PRIM__caml_irq_set_standard_handler {
caml_irq_set_standard_handler
	SEI
	LDA # <.standard_irq_handler
	STA C64_CINV
	LDA # >.standard_irq_handler
	STA C64_CINV + 1
	LDA # <Val_unit
	STA ACCU
	LDA # >Val_unit
	STA ACCU + 1
	CLI
	RTS
}

}	;; !zone "IRQ"
					
