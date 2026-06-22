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
;;; INT32, INT64
;;; -----------------------------------------------------------

!zone caml_INT32_64 {

	;; Int32
	;; header: tag Custom_tag, size 3
	;; field0: ptr to caml_int32_custom
	;; field1, field2: 32-bit number, little-endian

!macro caml_int32_alloc {
	LDA # Custom_tag
	LDX # 3
	JSR caml_alloc
}

!ifdef	caml_PRIM__caml_int32_neg {
caml_int32_neg
	+caml_int32_alloc
	LDX # 0
	SEC
	LDA # < caml_int32_custom
	STA (BLK),Y
	INY
	LDA # > caml_int32_custom
	STA (BLK),Y
  !for @i, 1, 4 {
	INY
	TXA
	SBC (ACCU),Y
	STA (BLK),Y
  }
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	LDY # 0
	RTS
}

!ifdef	caml_PRIM__caml_int32_add {
caml_int32_add
	+caml_int32_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
	CLC
  !for @i, 1, 4 {
	INY
	LDA (ACCU),Y
	ADC (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_sub {
caml_int32_sub
	+caml_int32_alloc
	LDA (SP),Y
	STA TMP
	ONY
	LDA (SP),Y
	STA TMP + 1
	SEC
  !for @i, 1, 4 {
	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_and {
caml_int32_and
	+caml_int32_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 4 {
	INY
	LDA (ACCU),Y
	AND (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_or {
caml_int32_or
	+caml_int32_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 4 {
	INY
	LDA (ACCU),Y
	ORA (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_xor {
caml_int32_xor
	+caml_int32_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 4 {
	INY
	LDA (ACCU),Y
	EOR (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_shift_left {
caml_int32_shift_left
	+caml_int32_alloc
	LDA (SP),Y
	LSR
	AND # 31
	BNE +
	LDY # 5
  !for @i, 1, 4 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 2
	LDA (ACCU),Y
	ASL
	STA (BLK),Y
  !for @i, 1, 3 {
	INY
	LDA (ACCU),Y
	ROL
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int32_shift_right {
caml_int32_shift_right
	+caml_int32_alloc
	LDA (SP),Y
	LSR
	AND # 31
	BNE +
	LDY # 5
  !for @i, 1, 4 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 5
	LDA (ACCU),Y
	CMP # $80
	ROR
	STA (BLK),Y
  !for @i, 1, 3 {
	DEY
	LDA (ACCU),Y
	ROR
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int32_shift_right_unsigned {
caml_int32_shift_right_unsigned
	+caml_int32_alloc
	LDA (SP),Y
	LSR
	AND # 31
	BNE +
	LDY # 5
  !for @i, 1, 4 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int32_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int32_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 5
	LDA (ACCU),Y
	LSR
	STA (BLK),Y
  !for @i, 1, 3 {
	DEY
	LDA (ACCU),Y
	ROR
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int32_mul {
caml_int32_mul
@M 	= TMP					;4 bytes
@P 	= TMP + 4				;4 bytes
@NPTR	= TMP + 8				;2 bytes
	+caml_int32_alloc
	SEC
	LDA (SP),Y
	SBC # $FF - 5			:!warn "COS'E'? COMMENTARE!"
	STA @NPTR
	INY
	LDA (SP),Y
	SBC # 0
	STA @NPTR + 1
	LDX # 0
	LDY # 5
	LDA (ACCU),Y
	LSR
	STA @M + 3
	STX @P + 3
  !for @i, 2, 0 {
	DEY
	LDA (ACCU),Y
	ROR
	STA @M + @i
	STX @P + @i
  }
;; 	ldx #32
;; --	bcc +
;; 	clc
;; 	ldy #$FF - 3
;; -	lda (@NPTR),Y
;; 	adc @P - $FF + 3,Y
;; 	sta @P - $FF + 3,Y
;; 	iny
;; 	bne -
;; +	lsr @P + 3
;;  !for @i, 2, 0 {ror @P + @i}
;;  !for @i, 3, 0 {ror @M + @i}
;; 	dex
;; 	bne --
	LDX # 8
--	BCC +
	CLC
	LDY # $FF-3
-	LDA (@NPTR),Y
	ADC @P - $FF + 3,Y
	STA @P - $FF + 3,Y
	INY
	BNE -
+	LSR @P + 3
  !for @i, 2, 0 {
	ROR @P + @i
  }
  !for @i, 3, 0 {
	ROR @M + @i
  }
	DEX
	BNE --
	LDA @NPTR
	BNE +
	DEC @NPTR + 1
+	DEC @NPTR
	LDX # 8
--	BCC +
	CLC
	LDY # $FF-2
-	LDA (@NPTR),Y
	ADC @P - $FF + 2,Y
	STA @P - $FF + 2,Y
	INY
	BNE -
+	LSR @P + 2
  !for @i, 1, 0 {
	ROR @P + @i
  }
  !for @i, 3, 0 {
	ROR @M + @i
  }
	DEX
	BNE --
	LDA @NPTR
	BNE +
	DEC @NPTR + 1
+	DEC @NPTR
	LDX # 8
--	BCC +
	CLC
	LDY # $FF - 1
-	LDA (@NPTR),Y
	ADC @P - $FF + 1,Y
	STA @P - $FF + 1,Y
	INY
	BNE -
+	LSR @P + 1
	ROR @P
  !for @i, 3, 0 {
	ROR @M + @i
  }
	DEX
	BNE --
	LDA @NPTR
	BNE +
	DEC @NPTR + 1
+	DEC @NPTR
	LDX # 8
--	BCC +
	CLC
	LDY # $FF
	LDA (@NPTR),Y
	ADC @P - $FF,Y
	STA @P - $FF,Y
+	LSR @P
  !for @i, 3, 0 {
	ROR @M + @i
  }
	DEX
	BNE --
	LDY # 5
-	LDA @M - 2,Y
	STA (BLK),Y
	DEY
	CPY # 2
	BCS -
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	LDY # 0
	RTS
}

!ifdef	caml_PRIM__caml_int32_of_float {
caml_int32_of_float
	+caml_int32_alloc
	LDA ACCU
	STA caml_float_loadFAC_addr
	LDA ACCU + 1
	STA caml_float_loadFAC_addr + 1
	JSR caml_float_loadFAC
	+caml_JSR_BASROM C64_QINT
	LDY # 2
	LDX # 3
-	LDA C64_FAC + 1,X
	STA (BLK),Y
	INY
	DEX
	BPL -
	LDY # 0
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_to_float {
caml_int32_to_float
	STY C64_FAC + 5			;clear FAC sign
	STY C64_FACRND			;clear FAC round byte
	LDA # 32 + $80			;set exponent
	STA C64_FAC
	LDY # 2
	LDX # 3
-	LDA (ACCU),Y			;copy int32 into FAC mantissa
	STA C64_FAC + 1,X
	INY
	DEX
	BPL -
	EOR # $80
	CMP # $80			;set carry if int32 is positive
	+caml_JSR_BASROM C64_FADFLT	;normalize
	JMP caml_float_alloc_result
}

!ifdef	caml_PRIM__caml_int32_of_int {
caml_int32_of_int
	+caml_int32_alloc
	LDY # 5
	LDA # 0
	STA (BLK),Y
	DEY
	STA (BLK),Y
	DEY
	LDA ACCU + 1
	LSR
	STA (BLK),Y
	DEY
	LDA ACCU
	ROR
	STA (BLK),Y
	LDY # 0
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int32_to_int {
caml_int32_to_int
	LDY # 2
	LDA (ACCU),Y
	SEC
	ROL
	TAX
	INY
	LDA (ACCU),Y
	ROL
	STA ACCU + 1
	STX ACCU
	LDY # 0
	RTS
}

	;; Conversion from IEEE754 binary32 to C64FLP and vice-versa.
	;; See en.wikipedia.org/wiki/Single-precision_floating-point_format
	;; &   www.c64-wiki.com/wiki/Floating_point_arithmetic
	;;
	;; IEEE754:      |±¦e07_e01|e00¦m22_m16|m15_m08|m07_m00|
	;; little-endian |m07_m00|m15_m08|e00¦m22_m16|±¦e07_e01| Int32.t
	;; exponent representation: excess-127
	;; 	exp = $01...$FE -> ± (2^(exp-127) * 1.mantissa)
	;; 	exp = $FF -> special numbers: NaN, +infinity, -infinity
	;; 	exp = $00, mantissa =  0 -> +0.0, -0.0
	;; 	exp = $00, mantissa <> 0 ->  ± (2^(-126) * 0.mantissa)
	;; range:   ±1.17549435E-38 ... ±3.40282346E+38 (normal)
	;;          ±1.40129846E-45 ... ±1.17549421E-38 (subnormal)
	;; example: 1.0= |0¦0111111|1¦0000000|00000000|00000000|
	;; little-endian |00000000|00000000|1¦0000000|0¦0111111| Int32.t
	;;
	;; C64 (in RAM): |E07_E00|±¦M30_M24|M23_M16|M15_M08|M07_M00|
	;; C64 (in FAC): |E07_E00|1¦M30_M24|M23_M16|M15_M08|M07_M00|±///////|
	;; exponent representation: excess-128
	;; 	exp = $01...$FF -> ± (2^(exp-128) * 0.1mantissa)
	;; 	exp = $00 -> 0.0
	;; range:   ±2.93873588E-39 ... ±1.70141183E+38
	;; example: 1.0= |10000001|0¦0000000|00000000|00000000|00000000|  (RAM)
	;;          1.0= |10000001|1¦0000000|00000000|00000000|00000000|0|(FAC)

!ifdef	caml_PRIM__caml_int32_bits_of_float {
caml_int32_bits_of_float
	+caml_int32_alloc
	LDA ACCU
	STA caml_float_loadFAC_addr
	LDA ACCU + 1
	STA caml_float_loadFAC_addr + 1
	JSR caml_float_loadFAC
	LDY # 5				; (BLK),Y points to int32 last byte
	LDX C64_FAC			; load c64 exponent
	BEQ @exp0			; switch
	DEX
	BEQ @exp1
	DEX
	BEQ @exp2
	;; c64 exponent > 2:
	;; ieee_exp = c64_exp - 2, ieee_mant = asl c64_mant (drop leftmost 1)
	;; normal representation - rounding may increment exponent by one
	CLC				;flag: .C=1 if called from @exp2
@round	BIT C64_FAC + 4			;round mantissa
 	BPL +
 	INC C64_FAC + 3
 	BNE +
 	INC C64_FAC + 2
 	BNE +
 	INC C64_FAC + 1
 	BNE +
 	INX				;increment exponent if needed
+	BCS @exp2r			;return if called from @exp2
	ASL C64_FAC + 1			;remove leftmost 1 from mantissa
	ASL C64_FAC + 5			;.C := sign bit
	TXA				;.A := exponent |e07_e00|
	ROR				;.A := |±¦e07_e01|, .C := e00
	STA (BLK),Y			;store |±¦e07_e01|
	LDA C64_FAC + 1			;.A := |m22_m16¦0|
	ROR				;.A := |e00¦m22_m16|
	DEY
	STA (BLK),Y			;store |e00¦m22_m16|
	LDA C64_FAC + 2			;.A := |m15_m08|
	DEY
	STA (BLK),Y			;store |m15_m08|
	LDA C64_FAC + 3			;.A := |m07_m00|
@end	DEY
	STA (BLK),Y			;store |m07_m00|
	LDY # 0
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	;ACCU := int32
	RTS				;return
	;; c64_exp = 0: ieee_exp = 0, ieee_mant = 0
@exp0	TXA				;.A := 0
	STA (BLK),Y			;store zero into all bytes
	DEY
	STA (BLK),Y
	DEY
	STA (BLK),Y
	JMP @end			;...continue
	;; c64_exp = 1: ieee_exp = 0, ieee_mant = lsr c64_mant (subnormal)
	;; rounding doesn't affect exponent, as mantissa is 0.0mmm...
@exp1	LSR C64_FAC + 1			;lsr mantissa
	ROR C64_FAC + 2
	ROR C64_FAC + 3
	ROR C64_FAC + 4			;fallthrough @exp2
	;; c64_exp = 2: ieee_exp = 0, ieee_mant = c64_mant (subnormal)
	;; rounding may incr. exponent and cause a switch from
	;; subnormal repr. (2^(-126) * 0.mantissa, 0 implicit)
	;; to normal one (2^(-126) * 1.rnd_mantissa, 1 implicit)
@exp2	SEC				;use .C as a return flag
	BCS @round			;round mantissa
@exp2r	TXA				;.A := exponent |e07_e00|
	ASL C64_FAC + 5			;.C := sign bit
	ROR				;.A := |±¦e07_e01|, .C := e00
	STA (BLK),Y			;store |±¦e07_e01|
	LDA C64_FAC + 1
	ROR
	DEY
	STA (BLK),Y			;store |e00¦m22_m16|
	LDA C64_FAC + 2
	ROR
	DEY
	STA (BLK),Y			;store |m15_m08|
	LDA C64_FAC + 3
	ROR
	JMP @end			;...continue
}

!ifdef	caml_PRIM__caml_int32_float_of_bits {
caml_int32_float_of_bits
	LDY # 4
	LDA (ACCU),Y			;.A <- e00¦m22_m16
	CMP # $80			;.C <- e00
	ORA # $80			;.A <- 1¦m22_m16
	STA C64_FAC + 1			;store into FAC
	INY
	LDA (ACCU),Y			;.A <- sign¦e07_e01
	ROL				;.C <- sign, .A <- e07_e00
	ROR C64_FAC + 5			;put sign into FAC sign byte
	CMP # $FE			;raise exn if NaN, +-infinity, or
	BCS @exn			;if conversion would overflow
	TAX				;.X <- exp
	LDY # 3
	LDA (ACCU),Y		       	;.A <- m15_m08
	STA C64_FAC + 2			;store into FAC
	DEY
	LDA (ACCU),Y			;.A <- m07_m00
	STA C64_FAC + 3			;store into FAC
	LDY # 0
	STY C64_FAC + 4			;clear FAC unused mantissa bits
	STY C64_FACRND			;and FAC round byte
	CPX # 1
	BCC @zero			;jump if +0.0, -0.0 or subnormal
	INX
	INX				;adjust exp bias
-	STX C64_FAC			;set FAC exp
	JMP caml_float_alloc_result	;allocate float and return
@zero	LDA C64_FAC + 3			;check if +0.0 or -0.0
	BNE @subnrm			;jump if subnormal
	LDA C64_FAC + 2
	BNE @subnrm			;jump if subnormal
	LDA C64_FAC + 1
	AND # $7F			;ignore leftmost bit of mantissa (1)
	BNE @subnrm			;jump if subnormal
	STA C64_FAC + 1
	STA C64_FAC + 5			;clear minus sign, if any
	BEQ -				;set FAC exp, allocate float and return
@subnrm	LDX # 2				;subnormal: set biased exp = -126
	STX C64_FAC
-	ASL C64_FAC + 3			;try to normalize (FAC+4 ignored as null)
	ROL C64_FAC + 2
	ROL C64_FAC + 1
	BMI +				;ok, leftmost bit is 1
	DEC C64_FAC
	BNE -
	LDY # 0				;ko, result is zero
	STY C64_FAC + 5			;clear minus sign, if any
+	JMP caml_float_alloc_result	;allocate float and return
@exn	+caml_raise Invalid_argument, "Int32.float_of_bits"
}

; caml_int32_div(value v1, value v2)
; caml_int32_mod(value v1, value v2)
; caml_int32_bswap(value v)

!ifdef	caml_PRIM__caml_int32_custom 	{
!align $01, $00
caml_int32_custom
	!word caml_int32_compare
	!word caml_int32_hash
caml_int32_compare
	STY TMP + 2
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
	SEC
	LDX # 3
-	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	ORA TMP + 2
	STA TMP + 2
	DEX
	BNE -
	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	BVC +
	EOR # $80
+	BMI ++				;jump if <
	LDY # 0
	STY ACCU + 1
	ORA TMP + 2
	BNE +				;jump if >
	LDA # <Val_zero
	STA ACCU
	RTS
+	LDA # <Val_one
	STA ACCU
	RTS
++	LDY # $FF
	STY ACCU
	STY ACCU + 1
	INY
	RTS
caml_int32_hash
	LDY # 5
	LDA (ACCU),Y
	DEY
	EOR (ACCU),Y
	TAX
	DEY
	LDA (ACCU),Y
	DEY
	EOR (ACCU),Y
	SEC
	ROL
	STA ACCU
	TXA
	ROL
	STA ACCU + 1
	LDY # 0
	RTS
}

	;; Int64
	;; header: tag Custom_tag, size 5
	;; field0: ptr to caml_int64_custom
	;; field1 ... field4: 64-bit number, little-endian

!macro caml_int64_alloc {
	LDA # Custom_tag
	LDX # 5
	JSR caml_alloc
}

!ifdef	caml_PRIM__caml_int64_neg {
caml_int64_neg
	+caml_int64_alloc
	LDX # 0
	SEC
	LDA # < caml_int64_custom
	STA (BLK),Y
	INY
	LDA # > caml_int64_custom
	STA (BLK),Y
  !for @i, 1, 8 {
	INY
	TXA
	SBC (ACCU),Y
	STA (BLK),Y
  }
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	LDY # 0
	RTS
}

!ifdef	caml_PRIM__caml_int64_add {
caml_int64_add
	+caml_int64_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
	CLC
  !for @i, 1, 8 {
	INY
	LDA (ACCU),Y
	ADC (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int64_sub {
caml_int64_sub
	+caml_int64_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
	SEC
  !for @i, 1, 8 {
	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int64_and {
caml_int64_and
	+caml_int64_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 8 {
	INY
	LDA (ACCU),Y
	AND (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int64_or {
caml_int64_or
	+caml_int64_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 8 {
	INY
	LDA (ACCU),Y
	ORA (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int64_xor {
caml_int64_xor
	+caml_int64_alloc
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
  !for @i, 1, 8 {
	INY
	LDA (ACCU),Y
	EOR (TMP),Y
	STA (BLK),Y
  }
	LDY # 1
	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
}

!ifdef	caml_PRIM__caml_int64_shift_left {
caml_int64_shift_left
	+caml_int64_alloc
	LDA (SP),Y
	LSR
	AND # 63
	BNE +
	LDY # 9
  !for @i, 1, 8 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 2
	LDA (ACCU),Y
	ASL
	STA (BLK),Y
  !for @i, 1, 7 {
	INY
	LDA (ACCU),Y
	ROL
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int64_shift_right {
caml_int64_shift_right
	+caml_int64_alloc
	LDA (SP),Y
	LSR
	AND # 63
	BNE +
	LDY # 9
  !for @i, 1, 8 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 9
	LDA (ACCU),Y
	CMP # $80
	ROR
	STA (BLK),Y
  !for @i, 1, 7 {
	DEY
	LDA (ACCU),Y
	ROR
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int64_shift_right_unsigned {
caml_int64_shift_right_unsigned
	+caml_int64_alloc
	LDA (SP),Y
	LSR
	AND # 63
	BNE +
	LDY # 9
  !for @i, 1, 8 {
	LDA (ACCU),Y
	STA (BLK),Y
	DEY
  }
--	LDA # > caml_int64_custom
	STA (BLK),Y
	DEY
	LDA # < caml_int64_custom
	STA (BLK),Y
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	RTS
+	TAX
-	LDY # 9
	LDA (ACCU),Y
	LSR
	STA (BLK),Y
  !for @i, 1, 7 {
	DEY
	LDA (ACCU),Y
	ROR
	STA (BLK),Y
  }
	DEX
	BNE -
	LDY # 1
	BNE --				;jmp
}

!ifdef	caml_PRIM__caml_int64_mul {
caml_int64_mul
@M 	= TMP					;8 bytes
@P 	= TMP + 8				;8 bytes
@NPTR 	= TMP + 16				;2 bytes
	+caml_int64_alloc
	SEC
	LDA (SP),Y
	SBC # $FF - 9			:!warn "COS'E'? COMMENTARE!"
	STA @NPTR
	INY
	LDA (SP),Y
	SBC # 0
	STA @NPTR + 1
	LDX # 0
	LDY # 9
	LDA (ACCU),Y
	LSR
	STA @M + 7
	STX @P + 7
  !for @i, 6, 0 {
	DEY
	LDA (ACCU),Y
	ROR
	STA @M + @i
	STX @P + @i
  }
	LDX # 64
--	BCC +
	CLC
	LDY # $FF - 7
-	LDA (@NPTR),Y
	ADC @P - $FF + 7,Y
	STA @P - $FF + 7,Y
	INY
	BNE -
+	LSR @P + 7
  !for @i, 6, 0 {
	ROR @P + @i
  }
  !for @i, 7, 0 {
	ROR @M + @i
  }
	DEX
	BNE --
	LDY # 9
-	LDA @M - 2,Y
	STA (BLK),Y
	DEY
	CPY # 2
	BCS -
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
	LDY # 0
	RTS
}

!ifdef	caml_PRIM__caml_int64_to_float {
caml_int64_to_float
	STY C64_FAC + 5			;clear FAC sign
	STY C64_FACRND			;clear FAC round byte
	LDA # 64 + $80
	STA C64_FAC			;set exponent (64)
	LDY # 6
	LDX # 3
-	LDA (ACCU),Y			;copy int64 hi bytes into FAC mantissa
	STA C64_FAC + 1,X
	INY
	DEX
	BPL -
	EOR # $80
	CMP # $80			;set carry if int64 is positive
	+caml_JSR_BASROM C64_FADFLT	;normalize
	LDX # <TMP
	LDY # >TMP
	+caml_JSR_BASROM C64_MOVMF	;copy FAC to TMP
;	ldy #0				;Y = 0 by MOVMF
	STY C64_FAC + 5			;clear FAC sign
	STY C64_FACRND			;clear FAC round byte
	LDA # 32 + $80
	STA C64_FAC			;set exponent (32)
	LDY # 2
	LDX # 3
-	LDA (ACCU),Y			;copy int64 lo bytes into FAC mantissa
	STA C64_FAC + 1,X
	INY
	DEX
	BPL -
	SEC				;set carry (positive)
	+caml_JSR_BASROM C64_FADFLT	;normalize
	LDA # <TMP
	LDY # >TMP
	+caml_JSR_BASROM C64_FADD	;FAC := TMP + FAC
	JMP caml_float_alloc_result
}

	;; Conversion from IEEE754 binary64 to C64FLP and vice-versa.
	;; See en.wikipedia.org/wiki/Double-precision_floating-point_format
	;; &   www.c64-wiki.com/wiki/Floating_point_arithmetic
	;;
	;; IEEE754:      |±¦e10_e04|e03_e00¦m51_m48|m47_m40|...|m07_m00|
	;; little-endian |m07_m00|...|m47_m40|e03_e00¦m51_m48|±¦e10_e04| Int64.t
	;; exponent representation: excess-1023
	;; 	exp = $001...$7FE -> ± (2^(exp-1023) * 1.mantissa)
	;; 	exp = $7FF -> special numbers: NaN, +infinity, -infinity
	;; 	exp = $000, mantissa =  0 -> +0.0, -0.0
	;; 	exp = $000, mantissa <> 0 ->  ± (2^(-1022) * 0.mantissa)
	;; range:   ±2.22507386E-308 ... ±1.79769313E+308 (normal)
	;;          ±4.94065646E-324 ... ±2.22507386E-308 (subnormal)
	;; example: 1.0= |0¦0111111|1111¦0000|00000000|...|00000000|
	;; little-endian |00000000|...|00000000|1111¦0000|0¦0111111| Int64.t
	;;
	;; C64 (in RAM): |E07_E00|±¦M30_M24|M23_M16|M15_M08|M07_M00|
	;; C64 (in FAC): |E07_E00|1¦M30_M24|M23_M16|M15_M08|M07_M00|±///////|
	;; exponent representation: excess-128
	;; 	exp = $01...$FF -> ± (2^(exp-128) * 0.1mantissa)
	;; 	exp = $00 -> 0.0
	;; range:   ±2.93873588E-39 ... ±1.70141183E+38
	;; example: 1.0= |10000001|0¦0000000|00000000|00000000|00000000|  (RAM)
	;;          1.0= |10000001|1¦0000000|00000000|00000000|00000000|0|(FAC)

!ifdef	caml_PRIM__caml_int64_bits_of_float {
caml_int64_bits_of_float
@EXPHI 	= TMP
	+caml_int64_alloc
	LDA ACCU
	STA caml_float_loadFAC_addr
	LDA ACCU + 1
	STA caml_float_loadFAC_addr + 1
	JSR caml_float_loadFAC
	LDA C64_FAC			;load exp
	CLC
	ADC # <(1023 - 128 - 1)		;adjust bias, lo bits
	STA C64_FAC			;save
	LDA # 0
	ADC # >(1023 - 128 - 1)		;idem, hi bits
	LDX # 3				;shift left exp 4 times
-	ASL C64_FAC
	ROL
	DEX
	BPL -
	STA @EXPHI
	LDA C64_FAC + 5			;load sign byte
	AND # %10000000			;get bit 7
	ORA @EXPHI			;merge with exp
	LDY # 9
	STA (BLK),Y			;save |±¦e10_e04|
	LDX # 4				;shift left mantissa 5 times
-	ASL C64_FAC + 4
  !for @i, 3, 1 {
	ROL C64_FAC + @i
  }
	ROL
	DEX
	BPL -
	AND # %00001111			;merge m51_m48
	ORA C64_FAC			;with e03_e00
	DEY
  !for @i, 1, 4 {
	STA (BLK),Y
	LDA C64_FAC + @i
	DEY
  }
	LDA # 0
	STA (BLK),Y			;put 0 in last 3 bytes
	DEY
	STA (BLK),Y
	DEY
	STA (BLK),Y
	TAY
	LDA BLK
	STA ACCU
	LDA BLK + 1
	STA ACCU + 1
 	;return result
	RTS
}

!ifdef	caml_PRIM__caml_int64_float_of_bits {
caml_int64_float_of_bits
	LDY # 9
	LDA (ACCU),Y			;.A <- sign¦e10_e04
	STA C64_FAC + 5			;put sign into FAC sign byte
	AND # %01111111			;clear sign bit
	TAX
	DEY
	LDA (ACCU),Y			;.A <- e03_e00¦m51_m48
	STA C64_FAC + 1
	SEC
	SBC # <((1023-128-1) << 4) 	;adjust exp bias, lo bits
	STA C64_FAC
	TXA
	SBC # >((1023-128-1) << 4) 	;idem, hi bits
	BCS +
	LDA # 0				;treat floats under C64 repr.
	STA C64_FAC			;lower limit as zero:
@zero	STA C64_FAC + 5		    	;clear minus sign, if any;
	JMP caml_float_alloc_result	;allocate float and return
@exn	+caml_raise Invalid_argument, "Int64.float_of_bits"
@mask  !byte %11110000
+	BIT @mask
	BNE @exn			;if NaN, ±inf or overflow, raise exn
  !for @i, 1, 4 {
	LSR				;shift result into FAC exp byte
	ROR C64_FAC
  }
	BEQ @zero			;if zero skip mantissa loading
	DEY
	LDA (ACCU),Y			;load significative part of mantissa
	STA C64_FAC + 2
	DEY
	LDA (ACCU),Y
	STA C64_FAC + 3
	DEY
	LDA (ACCU),Y
	STA C64_FAC + 4
	DEY
	LDA (ACCU),Y
	STA C64_FACRND
	LDX # 2				;shift left 3 times
-	ASL C64_FACRND
  !for @i, 4, 1 {
	ROL C64_FAC + @i
  }
	DEX
	BPL -
	LDA C64_FAC + 1
	ORA # $80		    	;set leftmost bit of mantissa
	STA C64_FAC + 1
	JMP caml_float_alloc_result	;allocate float and return
}

; caml_int64_bits_of_float(value vd)
; caml_int64_div(value v1, value v2)
; caml_int64_mod(value v1, value v2)
; caml_int64_bswap(value v)
; caml_int64_of_int(value v)
; caml_int64_to_int(value v)
; caml_int64_of_float
; caml_int64_of_int32(value v)
; caml_int64_to_int32(value v)

!ifdef	caml_PRIM__caml_int64_custom 	{
!align $01, $00
caml_int64_custom
	!word caml_int64_compare
	!word caml_int64_hash
caml_int64_compare
	STY TMP + 2
	LDA (SP),Y
	STA TMP
	INY
	LDA (SP),Y
	STA TMP + 1
	SEC
	LDX # 7
-	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	ORA TMP + 2
	STA TMP + 2
	DEX
	BNE -
	INY
	LDA (ACCU),Y
	SBC (TMP),Y
	BVC +
	EOR # $80
+	BMI ++				;jump if <
	LDY # 0
	STY ACCU + 1
	ORA TMP + 2
	BNE +				;jump if >
	LDA # <Val_zero
	STA ACCU
	RTS
+	LDA # <Val_one
	STA ACCU
	RTS
++	LDY # $FF
	STY ACCU
	STY ACCU + 1
	INY
	RTS
caml_int64_hash
	LDY # 9
	LDA (ACCU),Y
  !for @i, 1, 3 {
	DEY
	EOR (ACCU),Y
  }
	TAX
	DEY
	LDA (ACCU),Y
  !for @i, 1, 3 {
	DEY
	EOR (ACCU),Y
  }
	SEC
	ROL
	STA ACCU
	TXA
	ROL
	STA ACCU + 1
	LDY # 0
	RTS
}

}	;; zone caml_INT32_64
