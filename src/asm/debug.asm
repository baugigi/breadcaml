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

;; ----------------------------------------------------------------------------
;;	MACRO ALIASES EMITTED BY o64ml
;; ----------------------------------------------------------------------------

!macro	dbg .opc {
  !ifdef DEBUG {
	!set caml_debug_len = + - * 		; for GRAB
	JSR caml_debug
	!text .opc
+
  }
}

!macro	i00		{+dbg "00":+acc 0}
!macro	i01		{+dbg "01":+acc 1}
!macro	i02		{+dbg "02":+acc 2}
!macro	i03		{+dbg "03":+acc 3}
!macro	i04		{+dbg "04":+acc 4}
!macro	i05		{+dbg "05":+acc 5}
!macro	i06		{+dbg "06":+acc 6}
!macro	i07		{+dbg "07":+acc 7}
!macro	i08 .n		{+dbg "08":+acc .n}
!macro	i09		{+dbg "09":+push}
!macro	i0a		{+dbg "0a":+push}	;PUSHACC0 = PUSH
!macro	i0b		{+dbg "0b":+push
			 +dbg " >":+acc 1}
!macro	i0c		{+dbg "0c":+push
			 +dbg " >":+acc 2}
!macro	i0d		{+dbg "0d":+push
			 +dbg " >":+acc 3}
!macro	i0e		{+dbg "0e":+push
			 +dbg " >":+acc 4}
!macro	i0f		{+dbg "0f":+push
			 +dbg " >":+acc 5}
!macro	i10		{+dbg "10":+push
			 +dbg " >":+acc 6}
!macro	i11		{+dbg "11":+push
			 +dbg " >":+acc 7}
!macro	i12 .n		{+dbg "12":+push
			 +dbg " >":+acc .n}
!macro	i13 .n		{+dbg "13":+pop .n}
!macro	i14 .n		{+dbg "14":+assign .n}
!macro	i15		{+dbg "15":+envacc 1}
!macro	i16		{+dbg "16":+envacc 2}
!macro	i17		{+dbg "17":+envacc 3}
!macro	i18		{+dbg "18":+envacc 4}
!macro	i19 .n		{+dbg "19":+envacc .n}
!macro	i1a		{+dbg "1a":+push
			 +dbg " >":+envacc 1}
!macro	i1b		{+dbg "1b":+push
			 +dbg " >":+envacc 2}
!macro	i1c		{+dbg "1c":+push
			 +dbg " >":+envacc 3}
!macro	i1d		{+dbg "1d":+push
			 +dbg " >":+envacc 4}
!macro	i1e .n		{+dbg "1e":+push
			 +dbg " >":+envacc .n}
!macro	i1f .p		{+dbg "1f":+pushretaddr .p}
!macro	i20 .n		{+dbg "20":+apply .n}
!macro	i21		{+dbg "21":+apply 1}
!macro	i22		{+dbg "22":+apply 2}
!macro	i23		{+dbg "23":+apply 3}
!macro	i24 .n,.s	{+dbg "24":+appterm .n,.s}
!macro	i25 .s		{+dbg "25":+appterm 1,.s}
!macro	i26 .s		{+dbg "26":+appterm 2,.s}
!macro	i27 .s		{+dbg "27":+appterm 3,.s}
!macro	i28 .n		{+dbg "28":+return .n}
!macro	i29		{+dbg "29":+restart}
!macro	i2a .n		{+dbg "2a":+grab .n}
!macro	i2b .n,.p	{+dbg "2b":+closure .n,.p}
!macro	i2c .f,.v,.o,.t	{+dbg "2c":+closurerec .f,.v,.o,.t}
!macro	i2d		{+dbg "2d":+offsetclosure -2}
!macro	i2e		{+dbg "2e":+offsetclosure 0}
!macro	i2f		{+dbg "2f":+offsetclosure 2}
!macro	i30 .n		{+dbg "30":+offsetclosure .n}
!macro	i31		{+dbg "31":+push
			 +dbg " >":+offsetclosure -2}
!macro	i32		{+dbg "32":+push
			 +dbg " >":+offsetclosure 0}
!macro	i33		{+dbg "33":+push
			 +dbg " >":+offsetclosure 2}
!macro	i34 .n		{+dbg "34":+push
			 +dbg " >":+offsetclosure .n}
!macro	i35 .n		{+dbg "35":+getglobal .n}
!macro	i36 .n		{+dbg "36":+push
			 +dbg " >":+getglobal .n}
!macro	i37 .n,.m	{+dbg "37":+getglobal .n
			 +dbg " >":+getfield .m}
!macro	i38 .n,.m	{+dbg "38":+push
			 +dbg " >":+getglobal .n
			 +dbg " >":+getfield .m}
!macro	i39 .n		{+dbg "39":+setglobal .n}
!macro	i3a		{+dbg "3a":+atom 0}
!macro	i3b .n		{+dbg "3b":+atom .n}
!macro	i3c		{+dbg "3c":+push
			 +dbg " >":+atom 0}
!macro	i3d .n		{+dbg "3d":+push
			 +dbg " >":+atom .n}
!macro	i3e .t,.s	{+dbg "3e":+makeblock .s,.t}
!macro	i3f .t		{+dbg "3f":+makeblock 1,.t}
!macro	i40 .t		{+dbg "40":+makeblock 2,.t}
!macro	i41 .t		{+dbg "41":+makeblock 3,.t}
!macro	i42 .s		{+dbg "42":+makefloatblock .s}
!macro	i43		{+dbg "43":+getfield 0}
!macro	i44		{+dbg "44":+getfield 1}
!macro	i45		{+dbg "45":+getfield 2}
!macro	i46		{+dbg "46":+getfield 3}
!macro	i47 .n		{+dbg "47":+getfield .n}
!macro	i48 .n		{+dbg "48":+getfloatfield .n}
!macro	i49		{+dbg "49":+setfield 0}
!macro	i4a		{+dbg "4a":+setfield 1}
!macro	i4b		{+dbg "4b":+setfield 2}
!macro	i4c		{+dbg "4c":+setfield 3}
!macro	i4d .n		{+dbg "4d":+setfield .n}
!macro	i4e .n		{+dbg "4e":+setfloatfield .n}
!macro	i4f		{+dbg "4f":+vectlength}
!macro	i50		{+dbg "50":+getvectitem}
!macro	i51		{+dbg "51":+setvectitem}
!macro	i52		{+dbg "52":+getbyteschar}
!macro	i53		{+dbg "53":+setbyteschar}
!macro	i54 .p		{+dbg "54":+branch .p}
!macro	i55 .p		{+dbg "55":+branchif .p}
!macro	i56 .p		{+dbg "56":+branchifnot .p}
!macro	i57 .n,.t	{+dbg "57":+switch .n,.t}
!macro	i58		{+dbg "58":+boolnot}
!macro	i59 .p		{+dbg "59":+pushtrap .p}
!macro	i5a		{+dbg "5a":+poptrap}
!macro	i5b		{+dbg "5b":+raise}
!macro	i5c		{}			;CHECKSIGNALS = NOP
!macro	i5d .p		{+dbg "5d":+ccall .p,1}
!macro	i5e .p		{+dbg "5e":+ccall .p,2}
!macro	i5f .p		{+dbg "5f":+ccall .p,3}
!macro	i60 .p		{+dbg "60":+ccall .p,4}
!macro	i61 .p		{+dbg "61":+ccall .p,5}
!macro	i62 .p,.n	{+dbg "62":+ccall .p,.n}
!macro	i63		{+dbg "63":+constint 0}
!macro	i64		{+dbg "64":+constint 1}
!macro	i65		{+dbg "65":+constint 2}
!macro	i66		{+dbg "66":+constint 3}
!macro	i67 .n		{+dbg "67":+constint .n}
!macro	i68		{+dbg "68":+push
			 +dbg " >":+constint 0}
!macro	i69		{+dbg "69":+push
			 +dbg " >":+constint 1}
!macro	i6a		{+dbg "6a":+push
			 +dbg " >":+constint 2}
!macro	i6b		{+dbg "6b":+push
			 +dbg " >":+constint 3}
!macro	i6c .n		{+dbg "6c":+push
			 +dbg " >":+constint .n}
!macro	i6d		{+dbg "6d":+negint}
!macro	i6e		{+dbg "6e":+addint}
!macro	i6f		{+dbg "6f":+subint}
!macro	i70		{+dbg "70":+mulint}
!macro	i71		{+dbg "71":+divint}
!macro	i72		{+dbg "72":+modint}
!macro	i73		{+dbg "73":+andint}
!macro	i74		{+dbg "74":+orint}
!macro	i75		{+dbg "75":+xorint}
!macro	i76		{+dbg "76":+lslint}
!macro	i77		{+dbg "77":+lsrint}
!macro	i78		{+dbg "78":+asrint}
!macro	i79		{+dbg "79":+eq}
!macro	i7a		{+dbg "7a":+neq}
!macro	i7b		{+dbg "7b":+ltint}
!macro	i7c		{+dbg "7c":+leint}
!macro	i7d		{+dbg "7d":+gtint}
!macro	i7e		{+dbg "7e":+geint}
!macro	i7f .n		{+dbg "7f":+offsetint .n}
!macro	i80 .n		{+dbg "80":+offsetref .n}
!macro	i81		{+dbg "81":+isint}
!macro	i82		{+dbg "82":+getmethod}
!macro	i83 .n,.p	{+dbg "83":+beq_ .n,.p}
!macro	i84 .n,.p	{+dbg "84":+bneq .n,.p}
!macro	i85 .n,.p	{+dbg "85":+bltint .n,.p}
!macro	i86 .n,.p	{+dbg "86":+bleint .n,.p}
!macro	i87 .n,.p	{+dbg "87":+bgtint .n,.p}
!macro	i88 .n,.p	{+dbg "88":+bgeint .n,.p}
!macro	i89		{+dbg "89":+ultint}
!macro	i8a		{+dbg "8a":+ugeint}
!macro	i8b .n,.p	{+dbg "8b":+bultint .n,.p}
!macro	i8c .n,.p	{+dbg "8c":+bugeint .n,.p}
!macro	i8d .t		{+dbg "8d":+getpubmet .t}
!macro	i8e		{+dbg "8e":+getdynmet}
!macro	i8f		{+dbg "8f":+stop}
!macro	i90		{}			;EVENT = NOP
!macro	i91		{}			;BREAK = NOP
!macro	i92		{+dbg "92":+raise}	;RERAISE = RAISE
!macro	i93		{+dbg "93":+raise}	;RAISENOTRACE = RAISE
!macro	i94		{+dbg "94":+getbyteschar}

!ifdef	DEBUG {
caml_debug_header
	@RevOn	= $12
	@RevOff	= $92
	@Cyan	= $9F
	@LBlue	= $9A
	@CR	= $0D
	LDA # @CR
	JSR C64_CHROUT
	LDX # @txt - @end			;negative number
-	LDA @end - $100,X
	JSR C64_CHROUT
	INX
	BNE -
	RTS
@txt	!text @RevOn, "addr", @RevOff, "oc",   @Cyan,  "accu", @RevOn, "stk0"
	!text @LBlue, "   1", @Cyan,   "   2", @LBlue, "   3", @Cyan,  "   4"
	!text @LBlue, "   5", @RevOff, " env", @RevOn, "xa",   @RevOff
@end

caml_debug
	@RevOn	= $12
	@RevOff	= $92
	@Cyan	= $9F
	@LBlue	= $9A
	@CR	= $0D
	PHP:PHA:TXA:PHA:TYA:PHA
	DEC @count
	BPL +
	JSR caml_debug_header
	LDA #20					;print HEADER every 20 lines
	STA @count
+	TSX
	LDA $0105,X				;A <- return address-1, lo byte
	STA @getopc + 1				;save it to get the opc later
	CLC
	ADC # 2					;add 2 to skip data after JSR
	STA $0105,X
	TAY
	LDA $0106,X				;same as above, for hi byte
	STA @getopc + 2
	ADC # 0
	STA $0106,X
	TAX
	INY
	BNE +
	INX
+	LDA # @CR	:JSR C64_CHROUT
	TXA		:JSR @pr_hex		;ADDRESS
	TYA		:JSR @pr_hex
	LDA # @RevOn	:JSR C64_CHROUT
	LDY # 1
@getopc	LDA $1234,Y	:JSR C64_CHROUT		;OPCODE
	INY
	CPY # 2
	BEQ @getopc
	LDA # @Cyan	:JSR C64_CHROUT
	LDA ACCU + 1	:JSR @pr_hex		;ACCU
	LDA ACCU	:JSR @pr_hex
	LDA # @RevOff	:JSR C64_CHROUT
	LDY # 0					;print first 6 stack elements
-	TYA
	PHA
	LSR
	LSR
	LDA # @LBlue
	BCS +					;switch Cyan/LBlue
	LDA # @Cyan
+	JSR C64_CHROUT
	PLA
	TAY
	LDA (SP),Y
	TAX
	INY
	LDA (SP),Y	:JSR @pr_hex		;STACK[i]
	TXA		:JSR @pr_hex
	INY
	CPY # 12
	BNE -
	LDA # @RevOn	:JSR C64_CHROUT
	LDA ENV + 1	:JSR @pr_hex		;ENV
	LDA ENV		:JSR @pr_hex
	LDA # @RevOff	:JSR C64_CHROUT
	LDA XARGS :LSR	:JSR @pr_hex		;XARGS
	PLA:TAY:PLA:TAX:PLA:PLP
	RTS
@count	!byte 0
@pr_hex	PHA
	LSR
	LSR
	LSR
	LSR
	LDX # 2
	BNE +
-	PLA
	AND # $0F
+	CLC
	ADC # '0'
	CMP # '9' + 1
	BCC +
	ADC # 6					;Add 7
+	JSR C64_CHROUT
	DEX
	BNE -
	RTS
} ;; !ifdef DEBUG

} ;zone caml_LOADER
