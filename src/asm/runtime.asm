;; -----------------------------------------------------------------------------
;; INDENTATION MATTERS!
;;      XXX...         Code to assemble for native code (caml_INTERP = <undef>)
;;          XXX...     Code to assemble for both native code and bytecode
;;              XXX... Code to assemble for bytecode (caml_INTERP = 1)
;; -----------------------------------------------------------------------------
;; The native-code and common-code sections of the following routines are
;; annotated with (sort of!) Hoare Triples to highlight which conditions must be
;; met at entry by the CPU register and status flags, and which will stand at
;; exit (beware of Y<>0 in postconditions, see the comment at caml_init in
;; loader.asm).
;; -----------------------------------------------------------------------------

!zone caml_RUNTIME {
caml_runtime
	    .dummy = $1234              ;dummy arg. for self-modifying code
					;(SMC in comments)

!macro caml_NEXT {                      ;process next instruction
  !ifdef caml_INTERP {
                JMP caml_interp_fetch
  } else {
        RTS
}}

!macro caml_JMP_CODEPTR @code {         ;jump to @code pointer
  !ifdef caml_INTERP {
                JMP caml_interp_fetch
  } else {
        JMP (@code)
}}

!macro caml_grow_stack .w {             ;Increase stack by .w<128 words
            LDA SP
  !if .w = 1 {
            BNE +
            DEC SP + 1
            LDA SP + 1
            CMP # >caml_stack_start
            BCS +
            JMP caml_stack_overflow
+           DEC SP
            DEC SP
  } else {
            SEC
            SBC # 2 * .w
            STA SP
            BCS +
            DEC SP + 1
            LDA SP + 1
            CMP # >caml_stack_start
            BCS +
            JMP caml_stack_overflow
+ }}

caml_stack_overflow
            +caml_raise Stack_overflow

caml_ACCH
!ifdef caml_gen_ACCH {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                LDY TMP
  }                                     ;PRE: {A = >2n, Y = <2n}
            LDX SP + 1                  ;Save SP+1
            CLC                         ;Prepare ADC
            ADC SP + 1                  ;Add >2n to SP+1
            STA SP + 1                  ;Save result
            LDA (SP),Y                  ;Read SP[n], lo byte
            STA ACCU                    ;and save it in ACCU
            INY                         ;Increment index
            LDA (SP),Y                  ;Read SP[n], hi byte
            STA ACCU + 1                ;and save it in ACCU+1
            LDY # 0                     ;Reset Y
            STX SP + 1                  ;Restore SP+1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_ACCL
!ifdef caml_gen_ACCL {                  ;PRE:{Y = <2n}
            LDA (SP),Y                  ;Read SP[n], lo byte
            STA ACCU                    ;and save it in ACCU
            INY                         ;Increment index
            LDA (SP),Y                  ;Read SP[n], hi byte
            STA ACCU + 1                ;and save it in ACCU+1
            LDY # 0                     ;Reset Y
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_PUSH
!ifdef caml_gen_PUSH {                  ;PRE:{Y = 0}
            LDA SP                      ;Read the stack pointer, lo
            BNE +                       ;If zero then
            DEC SP + 1                  ;decrement the stack ptr, hi
            LDA SP + 1
            CMP # >caml_stack_start
            BCS +
            JMP caml_stack_overflow
+           DEC SP                      ;Decrement the stack pointer, lo
            LDA ACCU + 1                ;Copy ACCU + 1
            STA (SP),Y                  ;to SP[0], hi byte
            DEC SP                      ;Decrement the stack pointer, lo
            LDA ACCU                    ;Copy ACCU
            STA (SP),Y                  ;to SP[0], lo byte
            ;; No +caml_NEXT here! Always called by JSR
            RTS                         ;POST:{X = x, Y = 0}
}

caml_PHACC
!ifdef caml_gen_PHACC {
                JSR caml_PUSH
                JMP caml_ACCH
}

caml_POP1
!ifdef caml_gen_POP1 {                  ;PRE:{Y = y}
        INC SP                          ;Increment stack pointer, lo
        INC SP                          ;twice (n.b. word aligned)
        BNE +                           ;If page has been crossed
        INC SP + 1                      ;then increment pointer, hi
+       +caml_NEXT                      ;POST:{Y = y}
}

caml_POPN
!ifdef caml_gen_POPN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
  }                                     ;PRE:{A = <2n, Y = >2n}
            CLC                         ;Prepare ADC
            ADC SP                      ;Increment the stack pointer, lo
            STA SP                      ;by <2n
            TYA                         ;Set A to >2n
            ADC SP + 1                  ;Increment the stackpointer, hi
            STA SP + 1                  ;by >2n
            LDY # 0                     ;Reset Y
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_ASSIGNH
!ifdef caml_gen_ASSIGNH {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                LDY TMP
  }                                     ;PRE:{A = >2n, Y = <2n, SP+1 = s}
            LDX SP + 1                  ;Save SP+1, caller will restore it
            CLC                         ;Prepare ADC
            ADC SP + 1                  ;Add >2n to SP+1
            STA SP + 1                  ;and save it
            ;; fallthrough caml_ASSIGNL
}                                       ;POST:{X = s, Y = <2n, SP+1 = s + >2n}

caml_ASSIGNL
!ifdef caml_gen_ASSIGNL {               ;PRE:{X = s, Y = <2n}
            LDA ACCU                    ;Copy ACCU
            STA (SP),Y                  ;to SP[n], lo byte
            INY                         ;Increment index
            LDA ACCU + 1                ;Copy ACCU+1
            STA (SP),Y                  ;to SP[n], hi byte
            LDA # <Val_unit             ;Set ACCU
            STA ACCU                    ;to Val_unit, lo byte
            LDY # 0                     ;Set ACCU+1
            STY ACCU + 1                ;to Val_unit, hi byte
  !ifdef caml_INTERP {
                STX SP + 1
  }
            +caml_NEXT                  ;POST:{X = s, Y = 0}
}

caml_ENVACC      
!ifdef caml_gen_ENVACC {                ;PRE:{Y = <2n}
            LDA (ENV),Y
            STA ACCU
            INY
            LDA (ENV),Y
            STA ACCU + 1
            LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

;; PUSHRETADDR and caml_APPLY n, APPLY1, APPLY2, APPLY3:
;;
;; A closure application to n arguments is usually compiled by ocamlc by
;; emitting a PUSHRETADDR (which pushes the return address onto the stack),
;; followed by instructions that compute and push the arguments, and finally an
;; APPLY n instruction that jump to the closure code; but when n < 4, ocamlc
;; skips the PUSHRETADDR: its work is left up to APPLY1 (or APPLY2, or APPLY3).

caml_PHRET      
!ifdef caml_gen_PHRET {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                TAX
  } else {                              ;PRE:{A = <adr, X = >adr, Y = 0}
        STA TMP
  }
            +caml_grow_stack 3
            LDA TMP
            STA (SP),Y                  ;STACK[0] := return address
            INY
            TXA
            STA (SP),Y
            INY
            LDA ENV                     ;STACK[1] := ENV
            STA (SP),Y
            INY
            LDA ENV + 1
            STA (SP),Y
            INY
            LDA XARGS                   ;STACK[2] := XARGS
            STA (SP),Y
            LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_APPLY13
!ifdef caml_gen_APPLY13 {
  !ifdef caml_INTERP {
                SBC # $41 -1            ;-1 as C=0; A:=2n-1=2*opc-$41
                TAY
  }                                     ;PRE:{Y = 2n-1}
            @SP = TMP
            @N2M1 = TMP + 2
            STY @N2M1
            LDA SP                      ;Save current SP value
            STA @SP
            LDA SP + 1
            STA @SP + 1
            +caml_grow_stack 3
-           LDA (@SP),Y                 ;Slide n arguments by 3 slots (it's safe
            STA (SP),Y                  ;to copy backwards because n <= 3)
            DEY
            BPL -
            LDY @N2M1
            INY
  !ifdef caml_INTERP {
                LDA PC
  } else {
        PLA                             ;get return address from hw stack
        CLC
        ADC # 1
  }
            STA (SP),Y                  ;STACK[n] := return address
            INY
  !ifdef caml_INTERP {
                LDA PC + 1
  } else {
        PLA
        ADC # 0
  }
            STA (SP),Y
            INY
            LDA ENV                     ;STACK[n+1] := ENV
            STA (SP),Y
            INY
            LDA ENV + 1
            STA (SP),Y
            INY
            LDA XARGS                   ;STACK[n+2] := XARGS
            STA (SP),Y
            LDY @N2M1                   ;POST:{Y = 2n-1}
            ;; fallthrough caml_APPLY
}

caml_APPLY
!ifdef caml_gen_APPLY {
  !ifdef caml_INTERP {
                @PC = PC
  } else {
        @PC = TMP
  }                                     ;PRE:{Y = 2n-1}
            STY XARGS                   ;XARGS := Val_Int(n-1)
            LDA ACCU                    ;ENV := ACCU (&closure)
            STA ENV
            LDA ACCU + 1
            STA ENV + 1
            LDY # 1                     ;@PC := Code(ACCU)
            LDA (ACCU),Y
            STA @PC + 1
            DEY
            LDA (ACCU),Y
            STA @PC
            +caml_JMP_CODEPTR @PC
}                                       ;POST:{Y = 0}

caml_APPTRMN
!ifdef caml_gen_APPTRMN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
  }                                     ;PRE:{A=2(n-1), X=2(s-n)}
            TAY
            INY                         ;Y=2n-1
            CLC
            ADC XARGS                   ;XARGS :=
            STA XARGS                   ;  Val_Int(Int_Val(XARGS)+n-1)
            ;; fallthrough caml_APPTRM1
}

caml_APPTRM1
!ifdef caml_gen_APPTRM1 {
  !ifdef caml_INTERP {
                @PC = PC
  } else {
        @PC = TMP
  }
            LDA SP                      ;PRE:{X=2(s-n), Y=2n-1}
            STA TMP
            LDA SP + 1
            STA TMP + 1                 ;save stack pointer
            TXA                         ;A := 2 * (.s - .n)
            CLC
            ADC SP                      ;Pop s elements, push n
            STA SP
            BCC +
            INC SP + 1
+:-         LDA (TMP),Y                 ;move n elements from old top
            STA (SP),Y                  ;to new one
            DEY
            BNE -
            LDA (TMP),Y
            STA (SP),Y
            LDA ACCU
            STA ENV
            LDA ACCU + 1
            STA ENV + 1                 ;ENV := ACCU (closure)
            LDA (ACCU),Y
            STA @PC
            INY
            LDA (ACCU),Y
            STA @PC + 1                 ;@PC := ACCU[0] (closure code)
            DEY
            +caml_JMP_CODEPTR @PC       ;POST:{Y = 0}
}

;; RESTART and GRAB:
;;
;; GRAB checks that the caller passed enough arguments onto the stack. If not,
;; it creates a closure, stores all the available arguments in it, points the
;; closure code to the instruction just before GRAB (which is assumed to be a
;; RESTART), then returns to the caller, as if executing a RETURN instruction.
;; When the new closure is called, RESTART will push the arguments onto the
;; stack again and fallthrough GRAB.

caml_RESTART
!ifdef caml_gen_RESTART {               ;PRE:{}
            @ENV0 = TMP
            LDA ENV                     ;@ENV0 := ENV
            STA @ENV0
            LDA ENV + 1
            STA @ENV0 + 1
            LDY # 2
            LDA (@ENV0),Y               ;ENV := ENV[1]
            STA ENV
            INY
            LDA (@ENV0),Y
            STA ENV + 1
            LDY # -1
            DEC @ENV0 + 1
            LDA (@ENV0),Y               ;Get size(@ENV0)
            SEC
            SBC # 2                     ;A := size(@ENV0)-2
            BCC +
            BNE @pharg                  ;push args
+           INY                         ;Exit if size(@ENV0)-2 <= 0
            +caml_NEXT                  ;POST:{Y = 0}
@pharg      INC @ENV0 + 1
            ASL
            TAY                         ;Y := 2 * (size(@ENV0)-2)
            ;CLC                        ;(C clear as size(@ENV0)-2<128)
            ADC XARGS                   ;Incr. XARGS by size(@ENV0)-2
            STA XARGS
            LDA SP
            STY SP
            SEC
            SBC SP
            STA SP                      ;SP := SP - 2 * (size(@ENV0)-2)
            BCS +
            DEC SP + 1
            LDA SP + 1
            CMP # >caml_stack_start
            BCS +
            JMP caml_stack_overflow
+           CLC
            LDA # 4                     ;@ENV0 := &Field(@ENV0, 2)
            ADC @ENV0
            STA @ENV0
            BCC +
            INC @ENV0 + 1
+           DEY
-           LDA (@ENV0),Y               ;push args onto the stack
            STA (SP),Y
            DEY
            BNE -
            LDA (@ENV0),Y
            STA (SP),Y
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_GRAB
!ifdef caml_gen_GRAB {
            @offset = caml_restart_len + caml_grab_len
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;PRE:{A = v = 2n+1, Y = 0}
            EOR # $FF
            SEC
            ADC XARGS                   ;A := XARGS - v = ~A + 1 + XARGS
            BMI @mkclos                 ;If XARGS >= v then
            ORA # 1                     ; set XARGS's lsb
            STA XARGS                   ; XARGS := XARGS - v and exit
            +caml_NEXT                  ;POST:{Y = 0}
@mkclos     LDA XARGS                   ;Compute size = Int_Val(XARGS)
            LSR                         ; + 3wo (CODE, ENV, and Arg1)
            ADC # 3 -1                  ; (-1 as carry set by LSR)
            TAX     
            LDA # Closure_tag           ;BLK := new closure
            JSR caml_alloc
  !ifdef caml_INTERP {
                LDA PC                  ;Compute previous RESTART addr
                SEC                     ; as PC - (RESTART len + GRAB len).
                SBC # @offset
  } else {
        PLA                             ;Compute previous RESTART addr
        SEC                             ; from the ret addr on hw stack
        SBC # @offset - 1               ; (-1 because of how JSR works).
  }
            STA (BLK),Y                 ;Field(BLK,0) := CODE
  !ifdef caml_INTERP {
                LDA PC + 1
  } else {
        PLA
        SBC # 0
  }
            INY
            STA (BLK),Y
            INY
            LDA ENV                     ;Field(BLK,1) := ENV
            STA (BLK),Y
            INY
            LDA ENV + 1
            STA (BLK),Y
            LDA BLK + 1                 ;ACCU := BLK
            STA ACCU + 1
            LDA BLK 
            STA ACCU
            CLC                         ;BLK := &Field(BLK,2)
            ADC # 4
            STA BLK
            BCC +
            INC BLK + 1
+           LDY XARGS                   ;Y := 2 * Int_Val(XARGS) + 1
-           LDA (SP),Y                  ;Field(ACCU, i+2) := SP[i],
            STA (BLK),Y                 ;  0 <= i <= XARGS
            DEY
            BNE -
            LDA (SP),Y
            STA (BLK),Y
            LDA SP                      ;pop XARGS + 1 elements
            SEC                         ;  (SEC = +1)
            ADC XARGS
            STA SP
            BCC +
            INC SP + 1                  ;POST:{Y = 0}
+           ;; fallthrough caml_GORETURN
}

caml_GORETURN
!ifdef caml_gen_GORETURN {
  !ifdef caml_INTERP {
                @PC = PC
  } else {                              ;PRE:{}
        @PC = TMP
  }
            LDY # 4                     ;get return frame:
            LDA (SP),Y
            STA XARGS                   ;XARGS := STACK[2]
            DEY
            LDA (SP),Y                  ;ENV := STACK[1]
            STA ENV + 1
            DEY
            LDA (SP),Y
            STA ENV
            DEY
            LDA (SP),Y                  ;@PC := STACK[0] = ret.addr.
            STA @PC + 1
            DEY
            LDA (SP),Y
            STA @PC
            LDA # 6                     ;pop 3 elements
            CLC
            ADC SP
            STA SP
            BCC +
            INC SP + 1
+           +caml_JMP_CODEPTR @PC
}

;; RETURN:
;;
;; A function might be called with more arguments on the stack than expected. If
;; there is any extra argument, RETURN does not give control back to the caller:
;; instead, it assumes that there is a closure in the accumulator and gives it
;; immediate control.

caml_RETURN
!ifdef caml_gen_RETURN {
  !ifdef caml_INTERP {
                @PC = PC
                JSR caml_interp_getarg
                ORA # 0                 ;set N flag according to A
                BEQ +
  } else {                              ;PRE:{A = 2n}
        @PC = TMP
        BEQ +
        CLC
  }
            ADC SP                      ;pop n elements
            STA SP
            BCC +
            INC SP + 1
            CLC
+           LDA XARGS                   ;If XARGS - Val_one < Val_zero
            SBC # (Val_one & $FE) -1    ; (-1 as C is clear)
            BCC caml_GORETURN           ;then get return frame
            STA XARGS                   ;else XARGS := XARGS - Val_one
            LDA ACCU
            STA ENV                     ; ENV := ACCU
            LDA ACCU + 1
            STA ENV + 1
            LDA (ACCU),Y                ; TMP := Code(ACCU)
            STA @PC
            INY
            LDA (ACCU),Y
            STA @PC + 1
            DEY                         ; reset Y
            +caml_JMP_CODEPTR @PC       ;POST:{Y = 0}
}

caml_CLOSURE
!ifdef caml_gen_CLOSURE {
            @CODE   = TMP
            @NM1    = TMP + 2
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                STA @CODE
                JSR caml_interp_getarg
                STA @CODE + 1
  } else {                              ;PRE:{X = n, A = <ptr, Y = >ptr}
        STA @CODE                       ;save code pointer
        STY @CODE + 1
  }
            INX                         ;allocate a closure block with n + 1
            LDA # Closure_tag           ;fields
            JSR caml_alloc
            LDA @CODE                   ;Field(BLK,0) := code pointer
            STA (BLK),Y                 ;Y=0 by caml_alloc
            INY
            LDA @CODE + 1
            STA (BLK),Y
            DEX                         ;X := n
            BEQ +                       ;if n > 0 then
            INY
            LDA ACCU                    ; Field(BLK,1) := ACCU
            STA (BLK),Y
            INY
            LDA ACCU + 1
            STA (BLK),Y
+           LDA BLK + 1                 ;ACCU := block address, A:=BLK
            STA ACCU + 1
            LDA BLK
            STA ACCU
            CPX # 2
            BCC ++                      ;If n <= 1 then exit
            ADC # 4 - 1                 ;(-1 as carry is set)
            STA BLK                     ;BLK := &Field(BLK,2)
            BCC +
            INC BLK + 1
+           DEX
            STX @NM1
            LDY # 0                     ;for i := 0 to n - 2
-           LDA (SP),Y                  ; Field(BLK,2+i) := SP[i]
            STA (BLK),Y
            INY
            LDA (SP),Y
            STA (BLK),Y
            INY
            DEX
            BNE -
            LDA @NM1                    ;Pop n - 1 elements
            ASL
            ;CLC                        ;C clear as 2*@NM1 < 256
            ADC SP
            STA SP
            BCC ++
            INC SP + 1
++          LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_CLOSREC
!ifdef caml_gen_CLOSREC {
            @NVAR   = TMP               ;PRE:{A=.f, X:Y = .data, TMP=.v}
            @NFUN   = TMP + 1
            @ADR    = TMP + 2
  !ifdef caml_INTERP {                  ;$2c .v .f .data
                @DATA = PC
                JSR caml_interp_getarg
                STA @NVAR
                JSR caml_interp_getarg  ;Now @DATA=PC points to .data
                STA @NFUN
  } else {
        @DATA = TMP + 4
        STY @DATA
        STX @DATA + 1                   ;Now @DATA points to .data
        STA @NFUN
  }
            ASL                         ;Compute the size of the closure block
            CLC                         ; as 2f + v - 1 words
            ADC @NVAR
            TAX                         ; (here X=A=0 if f=128 & v=0)
            DEX                         ; (last step, X=255 if f=128 & v=0)
            LDA # Closure_tag           ;Load appropriate tag
            JSR caml_alloc              ; and allocate the closure
            LDA @NVAR                   ;If @NVAR>0 then push ACCU on the stack
            BEQ +                       ; (it'll be popped out and inserted into
            JSR caml_PUSH               ; the closure)
+           LDA BLK
            STA ACCU                    ;ACCU := closure address
            STA @ADR                    ;@ADR := closure address
            LDA BLK + 1
            STA ACCU + 1
            STA @ADR + 1
            LDX @NFUN                   ;Set loop counter
            BNE @code                   ;JMP @code (loop entry)
@ifx        LDA # Infix_tag             ; Put an infix tag in lo byte of
            STA (BLK),Y                 ;  Field(BLK,2i-1), i=@NFUN-X+1
            INY
            TYA                         ; Compute the offset: Y is odd,
            LSR                         ;  LSR:ADC is (Y+1)/2="distance"
            ADC # 0                     ;  in word from main closure;
            STA (BLK),Y                 ;  write it into hi byte.
            INY                         ; An Y overflow may occur here:
            BNE +                       ;  if so,
            INC BLK + 1                 ;  increment hi bytes of
            INC @DATA + 1               ;  both pointers.
+           LDA @DATA                   ; Decrement DATA by 2 as only 2 bytes
            SEC                         ;  from the .t tab will be copied
            SBC # 2                     ;  every 4 increments of Y index.
            STA @DATA
            BCS @code
            DEC @DATA + 1
@code       LDA (@DATA),Y               ;Loop entry: populate fun fields
            STA (BLK),Y                 ; Load code ptr, lo by; store it in
            INY                         ; Field(BLK,2i-2),i=@NFUN-X+1
            LDA (@DATA),Y
            STA (BLK),Y                 ; As above, hi byte
            INY
            DEX                         ; Decrement loop counter (i++)
            BNE @ifx                    ;Loop until X = 0 (i > @NFUN)
  !ifdef caml_INTERP {
                TYA
                CLC
                ADC PC
                STA PC                  ;PC:=@DATA+Y=PC+Y=.data+2×f
                BCC +
                INC PC + 1
+ }
            TYA                         ;Set BLK to point to next field
            CLC
            ADC BLK
            STA BLK
            BCC +
            INC BLK + 1
+           LDX @NVAR
            BEQ @grwstk                 ;If @NVAR = 0 then exit
            LDY # 0
@vars       LDA (SP),Y                  ;Loop: copy vars from stack to
            STA (BLK),Y                 ; Fld(2f-1), ..., Fld(2f+v-2)
            INY
            LDA (SP),Y
            STA (BLK),Y
            INY
            BNE +
            INC SP + 1
            INC BLK + 1
+           DEX
            BNE @vars
            TYA                         ;Pop @NVAR elts
            CLC
            ADC SP
            STA SP
            BCC @grwstk
            INC SP + 1
@grwstk     LDA @NFUN
            ASL
            TAY
            BCS +                       ;branch if @NFUN=128
            EOR # $FF
            SEC
            ADC SP
            STA SP                      ;SP := SP-2*@NFUN
            BCS ++
+           DEC SP + 1
            LDA SP + 1
            CMP # >caml_stack_start
            BCS ++
            JMP caml_stack_overflow
++          DEY                         ;Init counter: Y=2*@NFUN-1
@pshadr     LDA @ADR + 1                ;Loop: push onto the stack each function
            STA (SP),Y                  ; address; the 1st one is in @ADR,
            DEY                         ; the others are 4 bytes far each other,
            BEQ +
            LDA @ADR
            STA (SP),Y
            DEY
            CLC
            ADC # 4                     ; so add 4 to @ADR at each step
            STA @ADR
            BCC @pshadr
            INC @ADR + 1
            BCS @pshadr                 ;JMP @pshadr
+           LDA @ADR                    ;Last byte
            STA (SP),Y
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_OFSCL0
!ifdef caml_gen_OFSCL0 {
            LDA ENV                     ;PRE:{Y = y}
            STA ACCU
            LDA ENV + 1
            STA ACCU + 1                ;ACCU := ENV
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_OFSCLN
!ifdef caml_gen_OFSCLN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;PRE:{A = <2n, X = >2n, Y = y}
            CLC                         ;ACCU := ENV + 2 * .n (signed)
            ADC ENV
            STA ACCU
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  } else {
        TXA
  }
            ADC ENV + 1
            STA ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_SETGLB
!ifdef caml_gen_SETGLB {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                STA TMP + 1
  } else {                              ;PRE:{A = <&global, X = >&global, Y = 0}
        STA TMP
        STX TMP + 1
  }
            LDA ACCU
            STA (TMP),Y
            INY
            LDA ACCU + 1
            STA (TMP),Y
            LDA # <Val_unit
            STA ACCU
            DEY
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}       

caml_MKBLK
!ifdef caml_gen_MKBLK {                 ;PRE:{A = tag, X = size, Y = 0}
            JSR caml_alloc
            LDA ACCU
            STA (BLK),Y
            INY
            LDA ACCU + 1
            STA (BLK),Y                 ;Field(newblock,0) := ACCU
            DEY                         ;Y := 0
            LDA BLK
            STA ACCU
            LDA BLK + 1
            STA ACCU + 1                ;ACCU := newblock
            DEX
            BEQ ++
            INC BLK                     ;BLK -> Field(newblock,1)
            INC BLK
            BNE +
            INC BLK + 1
+:-         LDA (SP),Y                  ;copy .sz-1 elts from stack
            STA (BLK),Y
            INY
            LDA (SP),Y
            STA (BLK),Y
            INY
            BNE +
            INC SP + 1
            INC BLK + 1
+           DEX                         ;to newblock's fields
            BNE -   
            TYA                         ;and pop them
            BEQ ++
            CLC
            ADC SP
            STA SP
            BCC +
            INC SP + 1
+           LDY # 0
++          +caml_NEXT                  ;POST:{Y = 0}
}

caml_MKFBLK
!ifdef caml_gen_MKFBLK {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
  }                                     ;PRE:{X = wosize, Y = 0}
            LDA # Double_array_tag      ;set tag and allocate new block
            JSR caml_alloc
            +caml_move_float ACCU, BLK  ;Float(BLK):=Float(ACCU)
            LDA BLK
            STA ACCU
            LDA BLK + 1
            STA ACCU + 1                ;ACCU := newblock
            ;; Field(ACCU,1+i...3+i):=Float(SP[i]), 0 <= i < size/Double_wosize
-           TXA
            SEC
            SBC # Double_wosize
            BEQ ++                      ;no elements to pop
            TAX
            LDA BLK                     ;TMP := addr of next float field
            CLC
            ADC # Double_wosize
            BCC +
            INC BLK + 1
+           LDA (SP),Y
            STA TMP
            INC SP
            LDA (SP),Y
            STA TMP + 1                 ;pop from stack
            INC SP
            BNE +
            INC SP + 1
+           +caml_move_float TMP, BLK   ;Float(BLK):=Float(TMP)
            JMP -
++          +caml_NEXT                  ;POST:{Y = 0}
}

caml_GETFLDN
!ifdef  caml_gen_GETFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;PRE:{A = n}
            ASL
            BCC +
            INC ACCU + 1
+           TAY                         ;POST:{Y = <2n}
            ;; fallthrough caml_GETFLD0
}

caml_GETFLD0
!ifdef caml_gen_GETFLD0 {               ;PRE:{Y = <2n}
            LDA (ACCU),Y
            TAX
            INY
            LDA (ACCU),Y
            STX ACCU
            STA ACCU + 1
            LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_SETFLDN
!ifdef caml_gen_SETFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;PRE:{A = n, Y = 0}
            ASL
            BCC +
            INC ACCU + 1
            CLC
+           ADC ACCU
            STA ACCU
            BCC caml_SETFLD0
            INC ACCU + 1
            ;; fallthrough caml_SETFLD0
}

caml_SETFLD0
!ifdef caml_gen_SETFLD0 {               ;PRE:{Y = 0}
            LDA (SP),Y
            STA (ACCU),Y
            INY
            LDA (SP),Y
            STA (ACCU),Y
            DEY
            INC SP
            INC SP
            BNE +
            INC SP + 1
+           LDA # <Val_unit
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_GETFFLDN
!ifdef caml_gen_GETFFLDN {
  !ifndef caml_INTERP {                 ;PRE:{A = n * Double_wosize, Y = y}
        STA TMP
  }
            LDX # Double_wosize
            LDA # Double_tag
            JSR caml_alloc              ;address of new block in BLK
  !ifndef caml_INTERP {
        LDA TMP
  } else {      
                JSR caml_interp_getarg
                TAX                     ;set flags according to A
                BEQ .mov
  }
            ASL
            BCC +
            INC ACCU + 1
            CLC
+           ADC ACCU
            STA ACCU
            BCC .mov
            INC ACCU + 1
.mov        +caml_move_float ACCU, BLK  ;Float(BLK):=Float(ACCU)
            LDA BLK
            STA ACCU
            LDA BLK + 1
            STA ACCU + 1                ;ACCU := BLK
            +caml_NEXT                  ;POST:{Y = 0}

  !ifndef caml_INTERP {
caml_GETFFLDN__0                        ;shortcut for native code if n=0
        LDX # Double_wosize
        LDA # Double_tag
        JSR caml_alloc                  ;address of new block in BLK
        BNE .mov                        ;BNE = JMP
  }
}

caml_GETFFLD0
!ifdef caml_gen_GETFFLD0 {              ;PRE:{Y = y}
        LDX # Double_wosize
        LDA # Double_tag
        JSR caml_alloc                  ;address of new block in BLK
        +caml_move_float ACCU, BLK      ;Float(BLK):=Float(ACCU)
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                    ;ACCU := BLK
        +caml_NEXT                      ;POST:{Y = 0}
}

caml_SETFFLDN
!ifdef caml_gen_SETFFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX                     ;set flags according to A
                BEQ caml_SETFFLD0
                ASL
                BCC +
                INC ACCU + 1
+ }                                     ;PRE:{A=<2n, ACCU+1= >&Fld(ACCU,n), Y=0}
            CLC
            ADC ACCU
            STA ACCU                    ;ACCU := &Field(ACCU, n)
            BCC caml_SETFFLD0
            INC ACCU + 1                ;POST:{ACCU+1:ACCU = &Fld(ACCU,n), Y=0}
            ;; fallthrough caml_SETFFLD0
}

caml_SETFFLD0
!ifdef caml_gen_SETFFLD0 {              ;PRE:{ACCU+1:ACCU = &Fld(ACCU,n), Y=0}
            LDA (SP),Y
            STA TMP
            INC SP
            LDA (SP),Y
            STA TMP + 1                 ;TMP := SP[0]
            INC SP
            BNE +
            INC SP + 1
+           +caml_move_float TMP, ACCU  ;Float(ACCU):=Float(TMP)
            LDA # <Val_unit             ;ACCU := ()
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{ACCU+1:ACCU=Fld(ACCU,n), Y=0}
}

caml_VECLEN
!ifdef caml_gen_VECLEN {                ;PRE:{}
            LDY # -2
            DEC ACCU + 1
            LDA (ACCU),Y                ;load Tag(ACCU)
            TAX
            INY
            LDA (ACCU),Y                ;load size(ACCU)
            INY                         ;reset Y
            CPX # Double_array_tag      ;float array?
            BEQ @floats
            SEC                         ;  no: ACCU := Val_Int(size)
            ROL
            STA ACCU
            STY ACCU + 1
            ROL ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
@floats     STA ACCU                    ;  yes: compute A := A/3
            LSR                         ;    (start of A/3)
            ADC # 21
            LSR
            ADC ACCU
            ROR
            LSR
            ADC ACCU
            ROR
            LSR
            ADC ACCU
            ROR
            ;LSR                        ;    (end of A/3)
            ;ASL                        ;    ACCU := Val_Int(size/3)
            ORA # 1                     ;    = 2 * A/3 + 1 
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_GETVEC
!ifdef caml_gen_GETVEC {                ;PRE:{Y = 0}
            LDA (SP),Y                  ;Val_Int(index), lo
            STA TMP
            INC SP
            LDA (SP),Y                  ;Val_Int(index), hi
            BNE +
            INC ACCU + 1
+           INC SP
            BNE +
            INC SP + 1
+           LDY TMP
            LDA (ACCU),Y                ;array[index], hi
            TAX
            DEY
            LDA (ACCU),Y                ;array[index], lo
            STA ACCU
            STX ACCU + 1
            LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_SETVEC
!ifdef caml_gen_SETVEC {                ;PRE:{Y = 0}
            LDA (SP),Y                  ;Val_Int(index), lo
            STA TMP
            INC SP
            LDA (SP),Y                  ;Val_Int(index), hi
            BNE +
            INC ACCU + 1
+           INC SP
            BNE +
            INC SP + 1
+           LDA (SP),Y                  ;value, lo
            TAX
            INC SP
            LDA (SP),Y                  ;value, hi
            INC SP
            BNE +
            INC SP + 1
+           LDY TMP
            STA (ACCU),Y                ;set array[index], hi
            DEY
            TXA
            STA (ACCU),Y                ;set array[index], lo
            LDY # 0                     ;reset Y
            LDA # <Val_unit             ;ACCU := ()
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_GETCHR
!ifdef caml_gen_GETCHR {                ;PRE:{Y = 0}
            INY
            LDA (SP),Y
            LSR
            TAX
            DEY     
            LDA (SP),Y
            ROR
            TAY                         ;Y := <Int_Val(SP[0])
            TXA
            CLC
            ADC ACCU + 1
            STA ACCU + 1                ;ACCU + 1 += >Int_Val(SP[0])
            LDA (ACCU),Y                ;A := Char
            SEC
            ROL
            STA ACCU
            LDY # 0
            TYA
            ROL
            STA ACCU + 1                ;ACCU := Val_char(Char)
            INC SP                      ;pop
            INC SP
            BNE +
            INC SP + 1
+           +caml_NEXT                  ;POST:{Y = 0}
}

caml_SETCHR
!ifdef caml_gen_SETCHR {                ;PRE:{Y = 0}
            LDY # 3
            LDA (SP),Y
            LSR
            DEY
            LDA (SP),Y
            ROR
            STA TMP                     ;TMP := Char_val(SP[1])
            DEY
            LDA (SP),Y
            LSR
            TAX
            DEY
            LDA (SP),Y
            ROR
            TAY                         ;Y := <Int_Val(SP[0])
            TXA
            CLC
            ADC ACCU + 1
            STA ACCU + 1                ;ACCU + 1 += >Int_Val(SP[0])
            LDA TMP
            STA (ACCU),Y                ;*ACCU := TMP
            LDA # <Val_unit
            STA ACCU
            LDY # 0
            STY ACCU + 1                ;ACCU := ()
            LDA # 4                     ;pop(2)
            CLC
            ADC SP
            BCC +
            INC SP + 1
+           +caml_NEXT                  ;POST:{Y = 0}
}

caml_SWITCHP      
!ifdef caml_gen_SWITCHP {
  !ifdef caml_INTERP {
                @adr = PC
  } else {
        @adr = @jmp + 1
  }                                     ;PRE:{A = <p, X = >p}
            STA TMP                     ;X:A is adr + 2n
            DEC ACCU + 1
            LDY # -2
            LDA (ACCU),Y                ;Tag(ACCU) is i
            INC ACCU + 1
            ASL                         ;compute adr + 2n + 2i
            BCC +
            INX
            CLC
+           ADC TMP
            STA @adr                    ;and save it as JMP() arg
            BCC +
            INX
+           STX @adr + 1
            LDY # 0                     ;reset Y
@jmp        +caml_JMP_CODEPTR .dummy    ;SMC: JMP (adr + 2n + 2i)
}                                       ;POST:{Y = 0}

caml_SWITCHI      
!ifdef caml_gen_SWITCHI {
  !ifdef caml_INTERP {
                @adr = PC
  } else {
        @adr = @jmp + 1
  }                                     ;PRE:{A = <p, X = >p, Y = y}
            CLC                         ;X:A = adr-1, compute adr+2i
            ADC ACCU                    ;(ACCU is 2i+1)
            STA @adr                    ;and save it as JMP() arg
            TXA
            ADC ACCU + 1
            STA @adr + 1
@jmp        +caml_JMP_CODEPTR .dummy    ;SMC: JMP (adr+2i)
}                                       ;POST:{Y = y}

caml_BOOLNOT
!ifdef caml_gen_BOOLNOT {               ;PRE:{Y = y}
            LDA ACCU
            EOR # %00000010             ;Invert bit #1
            STA ACCU
            +caml_NEXT                  ;POST:{Y = y}
}

caml_PHTRP      
!ifdef caml_gen_PHTRP {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                STA TMP + 1
  } else {                              ;PRE:{A = <ptr, X = >ptr}
        STA TMP                         ;save address
        STX TMP + 1
  }
            +caml_grow_stack 4
            LDY # 6
            LDA XARGS                   ;push trap frame on stack:
            STA (SP),Y                  ;SP[3] := XARGS
            DEY
            LDA ENV + 1
            STA (SP),Y
            DEY
            LDA ENV
            STA (SP),Y                  ;SP[2] := ENV
            DEY
            LDA TRAPSP + 1
            STA (SP),Y
            DEY
            LDA TRAPSP
            STA (SP),Y                  ;SP[1] := TRAPSP
            DEY
            LDA TMP + 1
            STA (SP),Y
            DEY
            LDA TMP
            STA (SP),Y                  ;SP[0] := address
            LDA SP + 1
            STA TRAPSP + 1
            LDA SP
            STA TRAPSP                  ;TRAPSP := SP
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_POPTRP      
!ifdef caml_gen_POPTRP {                ;PRE:{}
            LDY # 2
            LDA (SP),Y
            STA TRAPSP
            INY
            LDA (SP),Y
            STA TRAPSP + 1              ;get TRAPSP from SP[1]
            LDA # 8                     ;POP trap frame
            CLC
            ADC SP
            STA SP
            BCC +
            INC SP + 1
+           LDY # 0                     ;reset Y
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_RAISE      
;; !ifdef caml_gen_RAISE                ;Always assembled
!ifdef caml_INTERP {
                @PC = PC
} else {                                ;PRE:{}
        @PC = TMP
}
caml_hw_stack_ptr = * + 1
            LDX # <.dummy               ;SMC, see caml_init in loader.asm
            TXS                         ;Clean exit from all JSRs
            LDA TRAPSP
            BIT caml_is_block           ;is TRAPSP a pointer?
            BEQ +
            JMP caml_uncaught_exn       ;no: failure - exit
+           STA SP                      ;yes: restore stack pointer
            LDA TRAPSP + 1
            STA SP + 1
            LDY # 6                     ;ignore hi byte
            LDA (SP),Y                  ;get XARGS from stack
            STA XARGS
            DEY
            LDA (SP),Y
            STA ENV + 1
            DEY
            LDA (SP),Y
            STA ENV                     ;get ENV from stack
            DEY
            LDA (SP),Y
            STA TRAPSP + 1
            DEY
            LDA (SP),Y
            STA TRAPSP                  ;get TRAPSP from stack
            DEY
            LDA (SP),Y
            STA @PC + 1
            DEY
            LDA (SP),Y
            STA @PC                     ;get address from stack
            CLC
            LDA # 8                     ;pop 4 elements
            ADC SP
            STA SP
            BCC +
            INC SP + 1
+           +caml_JMP_CODEPTR @PC       ;POST:{Y = 0 or HALT}

caml_CCALL
!ifdef caml_gen_CCALL {
  !ifdef caml_INTERP {
                SBC # $BA -1            ;-1 as C=0; A:=2(n-1)=2*opc-$BA
                LSR                     ;A:=n-1
                CMP # 5
                BCC +
                JSR caml_interp_getarg  ;if caml_CCALL n, get n - 1
+               PHA                     ;save #args_on_stack
                JSR caml_interp_getarg  ;get prim.idx
                TAX
  } else {                              ;PRE:{A=#args_on_stack, X=prim.idx, Y=0}
        PHA                             ;save #args_on_stack
  }
            LDA caml_externals_lo,X     ;get routine's address, lo by.
            STA @jsr + 1                ;write following JSR operand
            LDA caml_externals_hi,X     ;as above, hi by.
            STA @jsr + 2
@jsr        JSR .dummy                  ;SMC: JSR &routine
            LDY # 0                     ;better safe than sorry
            PLA                         ;reload #args
            BEQ ++
            ASL
            BCC +
            INC SP + 1
            CLC
+           ADC SP                      ;pop args from stack
            STA SP
            BCC ++
            INC SP + 1
++          +caml_NEXT                  ;POST:{Y = 0}
}

caml_NEGINT
        ;; Val_Int(-n) = Val_Int(0) + 1 - Val_Int(n)
!ifdef caml_gen_NEGINT {                ;PRE:{Y = 0}
            LDA # Val_zero + 1          ;Load <Val_Int(0)+1 in A
            SEC                         ;Prepare SBC
            SBC ACCU                    ;Subtract ACCU from A
            STA ACCU                    ;Save result in ACCU
            TYA                         ;Load >Val_Int(0)+1=0 in A
            SBC ACCU + 1                ;Subtract ACCU+1 from A
            STA ACCU + 1                ;Save result in ACCU+1
            +caml_NEXT                  ;POST:{Y = 0}
}

;; Macro for ADDINT, SUBINT, ANDINT, ORINT, XORINT
!macro caml_ALU_op @OP {                ;PRE:{Y = 0}
            LDA ACCU
  !if    @OP = '+' { AND # $FE : CLC : ADC (SP),Y
  } elif @OP = '-' { SEC : SBC (SP),Y : ORA # 1
  } elif @OP = '&' { AND (SP),Y
  } elif @OP = '|' { ORA (SP),Y
  } elif @OP = 'X' { EOR (SP),Y : ORA # 1
  } else {!serious "caml_ALU_op: Invalid argument"}
            STA ACCU
            INC SP
            LDA ACCU + 1
  !if    @OP = '+' { ADC (SP),Y
  } elif @OP = '-' { SBC (SP),Y
  } elif @OP = '&' { AND (SP),Y
  } elif @OP = '|' { ORA (SP),Y
  } elif @OP = 'X' { EOR (SP),Y
  } else {!serious "caml_ALU_op: Invalid argument"}
            STA ACCU + 1
            INC SP
            BNE +
            INC SP + 1
+           +caml_NEXT                  ;POST:{Y = 0}
}

caml_ADDINT  !ifdef caml_gen_ADDINT { +caml_ALU_op '+' }
caml_SUBINT  !ifdef caml_gen_SUBINT { +caml_ALU_op '-' }
caml_ANDINT  !ifdef caml_gen_ANDINT { +caml_ALU_op '&' }
caml_ORINT   !ifdef caml_gen_ORINT  { +caml_ALU_op '|' }
caml_XORINT  !ifdef caml_gen_XORINT { +caml_ALU_op 'X' }

;; Macro for LSLINT, LSRINT, ASRINT
!macro caml_SHF_op @OP {                ;PRE:{Y = 0}
            LDA (SP),Y                  ;load Val_Int(b)
            INC SP                      ;pop(1)
            INC SP
            BNE +
            INC SP + 1
+           LSR                         ;compute b from Val_Int(b)
            AND # $0F                   ;extract lo nibble
            BEQ +                       ;=0? nothing to be shifted
            TAX                         ;bit counter
            LDA ACCU
  !if    @OP = "<<"  { AND # $FE }      ;clear lsb
- !if    @OP = "<<"  { ASL : ROL ACCU + 1
  } elif @OP = ">>"  { LSR ACCU + 1 : ROR
  } elif @OP = "->>" { SEC : ROR ACCU + 1 : ROR
  } else {!serious "caml_SHF_op: Invalid argument"}
            DEX
            BNE -
            ORA # 1
            STA ACCU
+           +caml_NEXT                  ;POST:{Y = 0}
}

caml_LSLINT  !ifdef caml_gen_LSLINT { +caml_SHF_op "<<" }
caml_LSRINT  !ifdef caml_gen_LSRINT { +caml_SHF_op ">>" }
caml_ASRINT
!ifdef caml_gen_ASRINT {
            BIT ACCU + 1                ;test sign
            BPL caml_LSRINT             ;+: do caml_LSRINT
            +caml_SHF_op "->>"          ;-: shift preserving sign
}

caml_MULINT
        ;; Val_Int(m * n) = (Val_Int(m) >> 1) * (Val_Int(n) - 1) + 1
!ifdef caml_gen_MULINT {        	;PRE:{Y = 0}
            @N      = TMP               ;Multiplicator
            @P      = TMP + 2           ;P+1:P:ACCU+1:ACCU=Product
            STY @P
            STY @P + 1
            LSR ACCU + 1                ;ACCU := Val_Int(m) >> 1
            ROR ACCU
            LDA (SP),Y
            AND # $FE                   ;N := Val_Int(n) - 1
            STA @N
            INC SP                      ;pop lo byte
            LDA (SP),Y
            STA @N + 1
            INC SP                      ;pop hi byte
            BNE +
            INC SP + 1
            ;; Compute only the two least significative bytes of the product
+           LSR ACCU + 1                ;prepare ACCU_0 test
            ROR ACCU
            LDX # 8                     ;repeat 8 times {
-           BCC +                       ;       if ACCU_0 was 1
            CLC                         ;       then    P += N
            LDA @N
            ADC @P
            STA @P
            LDA @N + 1
            ADC @P + 1
            STA @P + 1
+           LSR @P + 1                  ;       P:ACCU >>1
            ROR @P
            ROR ACCU + 1
            ROR ACCU
            DEX     
            BNE -                       ;}
            LDX # 8                     ;repeat 8 times {
-           BCC +                       ;       if ACCU_0 was 1
            CLC                         ;       then    Plo += Nlo
            LDA @P
            ADC @N
            STA @P
+           LSR @P                      ;       Plo:ACCU >>1
            ROR ACCU + 1
            ROR ACCU
            DEX     
            BNE -                       ;}
            INC ACCU                    ;Add 1 (set LSB)
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_DIVMOD
!ifdef caml_gen_DIVMOD {                ;PRE:{Y = 0}
            .REM    = TMP               ;Remainder. SHARED W/caml_MODINT
            @DSR    = TMP + 2           ;Divisor. Dividend in ACCU.
            @SIGNS  = TMP + 4           ;bit 7,6 = quot,rem signs flags
            LDA ACCU
            LSR
            ORA ACCU + 1                ;set N,Z as dividend value
            BNE @not0                   ;Dividend = 0?
            INC SP                      ;Yes: pop divisor out
            INC SP
            BNE +
            INC SP + 1
+           CLC                         ;and exit returning C = 0
            RTS

@not0       STY .REM                    ;No: init Remainder
            STY .REM + 1
            BMI @negdvd                 ;Check dividend sign:
            LDX # %00......             ;+: unset quot & rem signs flags
            BEQ @lddsr                  ;   and JMP to divisor section
@negdvd     LDX # %11......             ;-: set quot & rem signs flags
            SEC                         ;   and negate the dividend:
            LDA # 2
            SBC ACCU
            STA ACCU
            LDA # 0
            SBC ACCU + 1
            STA ACCU + 1                ;   Val_Int(-n) = 2 - Val_Int(n)
@lddsr      LDA (SP),Y                  ;load divisor, lo byte
            STA @DSR                    ;and save it
            INC SP                      ;pop
            LDA (SP),Y                  ;load hi byte
            PHP                         ;save CPU status for later
            BPL @intval                 ;check divisor sign
            EOR # $FF                   ;-: negate hi byte
@intval     LSR                         ;Compute |Int_Val(divisor)|:
            STA @DSR + 1                ;save shifted hi byte
            ROR @DSR                    ;shift lo byte
            INC SP
            BNE +
            INC SP + 1                  ;pop
+           PLP                         ;get saved CPU status
            BMI @negdsr                 ;and check divisor sign again:
            ORA @DSR                    ;+: divisor = 0?
            BNE @divide                 ;   no: start division
            +caml_raise Division_by_zero;   yes: raise exception
@negdsr     TXA                         ;-: get quot & rem signs flags
            EOR # %10......             ;   invert quotient sign flag
            TAX                         ;   save flags in X
            LDA @DSR                    ;   negate divisor's lo byte
            EOR # $7F                   ;   (bits 6-0 only, as bit7 was
            STA @DSR                    ;   negated and RORed before)
            INC @DSR                    ;   add 1 to get the 2's 
            BNE @divide                 ;   complement of divisor
            INC @DSR + 1                ;   (adj. hi byte if necessary)
        ;; Division routine: 15 bits, start from dividend's MSB
@divide     STX @SIGNS                  ;save flags in S.
            LDX # 15
-           ASL ACCU                    ;shortcut: skip all initial 0s
            ROL ACCU + 1                ; of dividend
            BCS +                       ;first 1 found: enter div loop
            DEX
            BNE -                       ;check next bit
            BRK                         ;NOT REACHED as ACCU <> Val_zero
-           ASL ACCU                    ;ACCU_0 := 0, shift the
            ROL ACCU + 1                ;   highest bit of ACCU into
+           ROL .REM                    ;   R and make room in ACCU
            ROL .REM + 1                ;   for next quotient's bit
            SEC     
            LDA .REM
            SBC @DSR                    ;  Try subtraction R - N
            TAY
            LDA .REM + 1
            SBC @DSR + 1
            BCC +   
            STA .REM + 1                ;  If subtraction succeeds
            STY .REM                    ;   then save result in R
            INC ACCU                    ;   and record a 1 in ACCU
+           DEX
            BNE -                       ;Continue loop
            LDY # 0                     ;reset Y
            BIT @SIGNS                  ;return N = Q sign, V = R sign,
            SEC                         ;C = 1 (Dividend <> 0),
            RTS                         ;POST:{.REM=|Remainder|, CNV=flags, Y=0,
}                                       ;      ACCU=|Quotient|}

caml_DIVINT
!ifdef caml_gen_DIVINT {                ;PRE:{Y = 0}
            JSR caml_DIVMOD             ;Compute Q = |A| div |B|
            BCC ++                      ;ACCU=Dividend=Val_zero, exit
            BMI +                       ;Need to negate Quotient?
            ;SEC                        ;no: ACCU := Val_Int(Q) = 2Q+1
            ROL ACCU
            ROL ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
+           ASL ACCU                    ;yes: ACCU := Val_Int(-Q) = 1-2Q
            ROL ACCU + 1
            SEC
            LDA # 1
            SBC ACCU
            STA ACCU
            LDA # 0
            SBC ACCU + 1
            STA ACCU + 1
++          +caml_NEXT                  ;POST:{Y = 0}
}

caml_MODINT
!ifdef caml_gen_MODINT {                ;PRE:{Y = 0}
            ;.REM = TMP                 ;Remainder. SHARED W/caml_DIVMOD
            JSR caml_DIVMOD             ;Compute R = |A| mod |B|
            BCC ++                      ;ACCU=Dividend=Val_zero, exit
            BVS +                       ;Need to negate Remainder?
            LDA .REM                    ;no: ACCU := Val_Int(R) = 2R+1
            ;SEC
            ROL
            STA ACCU
            LDA .REM + 1
            ROL
            STA ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
+           ASL .REM                    ;yes: ACCU := Val_Int(-R) = 1-2R
            ROL .REM + 1
            SEC
            LDA # 1
            SBC .REM
            STA ACCU
            LDA # 0
            SBC .REM + 1
            STA ACCU + 1
++          +caml_NEXT                  ;POST:{Y = 0}
}

caml_EQ      
!ifdef caml_gen_EQ {                    ;PRE:{Y = 0}
            LDA (SP),Y
            INC SP
            CMP ACCU
            BNE caml_CMP_RES_F
            LDA (SP),Y
            CMP ACCU + 1
            BNE caml_CMP_RES_F
            BEQ caml_CMP_RES_T
}                                       ;POST:{Y = 0}

caml_NEQ      
!ifdef caml_gen_NEQ {                   ;PRE:{Y = 0}
            LDA (SP),Y
            INC SP
            CMP ACCU
            BNE caml_CMP_RES_T
            LDA (SP),Y
            CMP ACCU + 1
            BNE caml_CMP_RES_T
            BEQ caml_CMP_RES_F
}                                       ;POST:{Y = 0}

;; Macro for LTINT, GEINT, LEINT, GEINT
!macro caml_CMP @CMP  {                 ;PRE:{Y = 0}
  !if @CMP = "<" | @CMP = ">=" {
            LDA ACCU
            CMP (SP),Y
            INC SP
            LDA ACCU + 1
            SBC (SP),Y
  } elif @CMP = "<=" | @CMP = ">" {
            LDA (SP),Y
            CMP ACCU
            INC SP
            LDA (SP),Y
            SBC ACCU + 1
  } else {!serious "caml_CMP: invalid arg"}
            BVC +
            EOR # $80
+ !if @CMP = "<" | @CMP = ">" {
            BMI caml_CMP_RES_T
            BPL caml_CMP_RES_F
  } else {
            BPL caml_CMP_RES_T
            BMI caml_CMP_RES_F
  }
}                                       ;POST:{Y = 0}

caml_LTINT  !ifdef caml_gen_LTINT { +caml_CMP "<" }
caml_GEINT  !ifdef caml_gen_GEINT { +caml_CMP ">=" }
caml_LEINT  !ifdef caml_gen_LEINT { +caml_CMP "<=" }
caml_GTINT  !ifdef caml_gen_GTINT { +caml_CMP ">" }     

;; tail for EQINT, NEQINT, [LG][ET]INT
caml_CMP_RES
!ifdef caml_gen_CMP_RES {               ;PRE:{Y = 0}
caml_CMP_RES_T
            LDA # Val_true
            BNE +                       ;JMP +
caml_CMP_RES_F
            LDA # Val_false
+           STA ACCU
            STY ACCU + 1
            INC SP
            BNE +
            INC SP + 1
+           +caml_NEXT                  ;POST:{Y = 0}
}

caml_OFSINT      
!ifdef caml_gen_OFSINT {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
  }                                     ;PRE:{A = <2n, Y = >2n}
            CLC
            ADC ACCU
            STA ACCU
            TYA
            ADC ACCU + 1
            STA ACCU + 1
            LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_OFSREF      
!ifdef caml_gen_OFSREF {
  !ifdef caml_INTERP {
            JSR caml_interp_getarg
            TAX
            JSR caml_interp_getarg
            STA TMP
            TXA
  } else {                              ;PRE:{A = <2n, Y = >2n}
            STY TMP
  }
            LDY # 0
            CLC
            ADC (ACCU),Y
            STA (ACCU),Y
            INY
            LDA TMP
            ADC (ACCU),Y
            STA (ACCU),Y
            DEY
            LDA # <Val_unit
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_ISINT      
!ifdef caml_gen_ISINT {                 ;PRE:{Y = 0}
            LDA ACCU
            AND # %00000001
            SEC
            ROL
            STA ACCU
            STY ACCU + 1
            +caml_NEXT                  ;POST:{Y = 0}
}

;; BEQ, BNEQ, BLTINT, BLEINT, BGTINT, BGEINT
;; native code: inlined
;; bytecode: see "BYTECODE INTERPRETER SPECIFIC" section below.

caml_CMP_SGN
        ;; Branches on signed-integer comparison - shared code
!ifdef caml_gen_CMP_SGN {               ;PRE:{A = <v, Y = >v}
            CMP ACCU                    ;Signed comparison, result is
            TYA                         ;N=1:>= / N=0:<
            LDY # 0
            SBC ACCU + 1
            BVC +
            EOR # $80
+           RTS                         ;POST:{Y = 0}
}

!macro caml_UCMP @CMP {                 ;PRE:{Y = 0}
            INY
  !if @CMP = "<" {
            LDA ACCU + 1
            CMP (SP),Y
  } elif @CMP = ">=" {
            LDA (SP),Y
            CMP ACCU + 1
  } else {!serious "caml_UCMP: invalid arg"}
            BCC ++
            BNE +
            DEY
            LDA ACCU
            CMP (SP),Y
  !if @CMP = "<" {
            BCC ++
  } else {
            BCS ++
  }
+           LDA # Val_false
            BNE +                       ;JMP +
++          LDA # Val_true
+           STA ACCU
            STY ACCU + 1
            INC SP
            INC SP
            BNE +
            INC SP + 1
+           LDY # 0
            +caml_NEXT                  ;POST:{Y = 0}
}

caml_ULTINT  !ifdef caml_gen_ULTINT { +caml_UCMP "<" }
caml_UGEINT  !ifdef caml_gen_UGEINT { +caml_UCMP ">=" }       

;; BULTINT, BUGEINT:
;; native code: inlined
;; bytecode: see "BYTECODE INTERPRETER SPECIFIC" section below.

caml_STOP = caml_end                    ;See loader.asm

;; ----------------------------------------------------------------------------
;;       UNCAUGHT EXCEPTIONS
;; ----------------------------------------------------------------------------

        ;; Print an uncaught exception with its arguments, if any.
!ifndef caml_uncaught_exn_warn {
caml_uncaught_exn_warn
        !warn "TODO: caml_uncaught_exn should reset VIC, SID, (more?)"
}
caml_uncaught_exn
            @VAL = TMP                  ;current value
            @PRFLD = TMP + 2            ;print blk fields: =0 yes/<>0 no
            @SIZE  = TMP + 3            ;for @pr_val: block size
            @SKP0  = TMP + 4            ;for @pr_int: skip leading 0s
            @DGT  =  TMP + 5            ;for @pr_int: digit to print
            LDY # 0
            STY @PRFLD                  ;flag: print fields=yes
            LDX # 0                     ;print error message
-           LDA @err,X
            BEQ +
            JSR C64_CHROUT
            INX
            BNE -
+           DEC ACCU + 1                ;prepare access to tag(ACCU)
            LDY # -2
            LDA (ACCU),Y                ;load tag(ACCU)
            INC ACCU + 1                ;restore ptr
            CMP # 0                     ;Is exn boxed with its arg(s)?
            BNE @unbxd
            TAY                         ;Yes: ACCU={tag=0|EXN_BLK|arg}
            LDA (ACCU),Y
            STA @VAL
            INY
            LDA (ACCU),Y
            STA @VAL + 1                ;  VAL := EXN_BLK
            LDA (@VAL),Y                ;  load EXN_BLK[0], hi
            TAX
            DEY
            LDA (@VAL),Y                ;  load EXN_BLK[0], lo
            STX @VAL + 1                ;  VAL := EXN_BLK[0] (exn name)
            STA @VAL
            JSR @pr_exn                 ;  print exn name
            LDA # ' '
            JSR C64_CHROUT
            LDY # 3
            LDA (ACCU),Y
            STA @VAL + 1
            DEY
            LDA (ACCU),Y
            STA @VAL                    ;  VAL := ACCU[1] (exn arg)
            JSR @pr_val                 ;  print argument(s)
            JMP caml_STOP               ;  exit.
@unbxd      LDY # 1                     ;No: ACCU={obj_tag|"name"|oid}
            LDA (ACCU),Y
            STA @VAL + 1
            DEY
            LDA (ACCU),Y
            STA @VAL                    ;  VAL := ACCU[0] (exn name)
            JSR @pr_exn                 ;  print exn name, petscii conv.
            JMP caml_STOP               ;  exit.
            !convtab pet
@err        !text 13, "Exception: ", 0

        ;; Print VAL if int or string, or its fields if tag(VAL)=0 & PRFLD=0
@pr_val     BIT caml_is_block           ;Is VAL a block?
            BEQ +                       ;No: print integer & return.
            JMP @pr_int                 ; JMP=JSR+RTS
+           DEC @VAL + 1                ;Yes: prepare access to tag(VAL)
            LDY # -2
            LDA (@VAL),Y                ; Get tag(VAL)
            BEQ @tag0                   ; branch if tag=0
            CMP # String_tag
            BNE @othblk                 ; branch if tag <> String_tag
            INC @VAL + 1                ; Restore pointer
            LDA # '"'                   ;== STRING BLOCK ==
            JSR C64_CHROUT              ; Print '"'
            JSR @pr_str                 ; Print the string
            LDA # '"'                   ; Print '"'
            JMP C64_CHROUT              ; JMP=JSR+RTS
@othblk     LDX # 0                     ;== BLOCK WITH TAG<>0 ==
-           LDA @msg,X                  ; Print "<BLOCK>"
            BEQ +
            JSR C64_CHROUT
            INX
            BNE -
+           RTS                         ; Return.
@msg        !text "<BLOCK>", 0
@tag0       BIT @PRFLD                  ;== BLOCK WITH TAG=0 ==
            BMI @othblk                 ; If @PRFLD=$FF, do as above.
            LDA # '('                   ; Print '('
            JSR C64_CHROUT
            INY
            LDA (@VAL),Y                ; Get size(VAL)
            STA @SIZE                   ;  and save it
            INC @VAL + 1                ; Restore pointer
            DEC @PRFLD                  ; PRFLD := $FF
-           LDA @VAL + 1                ; Loop on size(VAL):
            PHA                         ;  Push VAL,hi onto h/w stack
            LDA @VAL
            PHA                         ;  Push VAL,lo onto h/w stack
            INY
            LDA (@VAL),Y                ;  Get current Field(VAL), lo
            TAX
            INY
            LDA (@VAL),Y                ;   and hi byte
            STX @VAL                    ;  VAL := Field(VAL)
            STA @VAL + 1
            TYA
            PHA                         ;  Push Y onto h/w stack
            JSR @pr_val                 ;  Recall pr_val(VAL,PRFLD=$FF)
            PLA                         ;  Pop Y register from h/w stack
            TAY
            PLA                         ;  Pop VAL,lo from h/w stack
            STA @VAL
            PLA                         ;  Pop VAL,hi from h/w stack 
            STA @VAL + 1
            DEC @SIZE                   ;  Decrement counter
            BEQ +                       ; Exit if all fields are printed
            LDA # ','                   ;  Print ','
            JSR C64_CHROUT
            LDA # ' '                   ;  Print ' '
            JSR C64_CHROUT
            JMP -                       ; Continue loop
+           LDA # ')'                   ; Print ')'
            JSR C64_CHROUT
            RTS                         ; Return.

        ;; Convert the exn name ptd by VAL to PETSCII and print it
@pr_exn     LDY # 0
-           LDA (@VAL),Y                ;A := VAL[Y]
            BEQ +++                     ;Exit if null
            CMP # $5F                   ;test for underscore
            BNE +
            LDA # $A4
            BNE ++                      ;JMP
+           CMP # $61                   ;test for lowercase letter
            BCC +
            SBC # $20
            BNE ++                      ;JMP
+           CMP # $41                   ;test for uppercase letter
            BCC ++
            EOR # $80
++          JSR C64_CHROUT              ;Print VAL[Y]
            INY
            BNE -
            INC @VAL + 1
            BNE -
+++         RTS

        ;; Print the string pointed by VAL
@pr_str     LDY # 0
-           LDA (@VAL),Y                ;A := VAL[Y]
            BEQ +                       ;Exit if null
            JSR C64_CHROUT              ;Print VAL[Y]
            INY
            BNE -
            INC @VAL + 1
            BNE -
+           RTS

        ;; Print the integer in VAL
@pr_int     BIT @VAL + 1
            BPL +
            SEC                         ;If VAL < 0,
            LDA # Val_zero + 1
            SBC @VAL                    ; negate it
            STA @VAL
            LDA # 0
            SBC @VAL + 1
            STA @VAL + 1
            LDA # '-'                   ; and print '-'.
            JSR C64_CHROUT
+           LSR @VAL + 1                ;Get rid of trailing 1
            ROR @VAL
            LDA # '0'
            STA @SKP0                   ;Ignore initial 0s
            LDX # 3                     ;For X := 3 downto 0
--          STA @DGT                    ; DGT := '0'
-           LDA @VAL                    ; Loop
            SEC
            SBC @lo10,X                 ;  A:Y := VAL - 10^(X+1)
            TAY
            LDA @VAL + 1
            SBC @hi10,X
            BCC +                       ; Exit_loop if A:Y < 0
            STY @VAL                    ;  VAL := A:Y
            STA @VAL + 1
            INC @DGT                    ;  DGT :=nxt(DGT) ('1','2',...)
            BNE -                       ; End_Loop
+           LDA @DGT                    ; If not(DGT = '0' & SKP0 = '0')
            CMP @SKP0
            BEQ +
            DEC @SKP0                   ;  SKP0 := <non_digit_char>
            JSR C64_CHROUT              ;  Print DGT
            LDA # '0'                   ;  Set A for next iteration
+           DEX                         ;  Decrement counter
            BPL --                      ;End_For
            ORA @VAL                    ;A := '0'|VAL  (last digit)
            ;JSR C64_CHROUT             ;Print it
            ;RTS                        ; and return.
            JMP C64_CHROUT              ;JMP=JSR+RTS
@lo10       !byte <10, <100, <1000, <10000
@hi10       !byte >10, >100, >1000, >10000


!ifdef caml_INTERP {
;; ----------------------------------------------------------------------------
;;       BYTECODE INTERPRETER SPECIFIC ROUTINES
;; ----------------------------------------------------------------------------

caml_PHENVACC
!ifdef caml_gen_PHENVACC {
                JSR caml_PUSH
                JMP caml_ENVACCN
}

caml_ENVACCN
!ifdef caml_gen_ENVACCN {
                JSR caml_interp_getarg
                TAY
                JMP caml_ENVACC
}

caml_PHENVACC14
!ifdef caml_gen_PHENVACC14 {
                SBC # $34 -1            ;-1 as C=0; A:=2n=2*opc-$34
                STA TMP
                JSR caml_PUSH
                LDY TMP
                JMP caml_ENVACC
}

caml_ENVACC14
!ifdef caml_gen_ENVACC14 {
                SBC # $2A -1            ;-1 as C=0; A:=2n=2*opc-$2A
                TAY
                JMP caml_ENVACC
}

caml_APPLYN
!ifdef caml_gen_APPLYN {
                JSR caml_interp_getarg
                TAY
                JMP caml_APPLY
}

caml_APPTRM13
!ifdef caml_gen_APPTRM13 {
                SBC # $4A -1            ;-1 as C=0; A:=2(n-1)=2*opc-$4A
                BEQ +
                TAY
                CLC
                ADC XARGS               ;XARGS :=
                STA XARGS               ;  Val_Int(Int_Val(XARGS)+n-1)
+               JSR caml_interp_getarg
                TAX                     ;X:=2(s-n)
                INY                     ;Y:=2n-1
                JMP caml_APPTRM1
}

caml_PHOFSCLM2
!ifdef caml_gen_PHOFSCLM2 {
                JSR caml_PUSH
                CLC
                JMP caml_OFSCLM2
}

caml_OFSCLM2
!ifdef caml_gen_OFSCLM2 {
                LDA ENV
                SBC # 4 -1              ;-1 as C=0
                STA ACCU
                LDA ENV + 1
                SBC # 0
                STA ACCU + 1
                +caml_NEXT
}

caml_PHOFSCL0
!ifdef caml_gen_PHOFSCL0 {
                JSR caml_PUSH
                JMP caml_OFSCL0
}

caml_PHOFSCL2
!ifdef caml_gen_PHOFSCL2 {
                JSR caml_PUSH
                CLC
                JMP caml_OFSCL2
}

caml_OFSCL2
!ifdef caml_gen_OFSCL2 {
                LDA ENV
                ADC # 4                 ;C=0
                STA ACCU
                LDA ENV + 1
                ADC # 0
                STA ACCU + 1
                +caml_NEXT
}

caml_PHOFSCLN
!ifdef caml_gen_PHOFSCLN {
                JSR caml_PUSH
                JMP caml_OFSCLN
}

caml_PHGETGLB
!ifdef caml_gen_PHGETGLB {
                JSR caml_PUSH
                JMP caml_GETGLB
}

caml_GETGLB
!ifdef caml_gen_GETGLB {
                JSR caml_GETGLBSUB
                +caml_NEXT
caml_GETGLBSUB                          ;called by [PH]caml_GETGLB[FLD]
                JSR caml_interp_getarg
                STA ACCU
                JSR caml_interp_getarg
                STA ACCU + 1
                CMP # >caml_glob_table  ;return if ACCU is an address
                BCC +                   ; of a standard exception blk
                INY                     ;else ACCU points to the global
                LDA (ACCU),Y            ; table: access it and get the
                TAX                     ; value
                DEY
                LDA (ACCU),Y
                STA ACCU
                STX ACCU + 1
+               RTS
}

caml_PHGETGLBFLD
!ifdef caml_gen_PHGETGLBFLD {
                JSR caml_PUSH
                JMP caml_GETGLBFLD
}

caml_GETGLBFLD
!ifdef caml_gen_GETGLBFLD {
                JSR caml_GETGLBSUB
                JSR caml_interp_getarg
                ASL
                BCC +
                INC ACCU + 1
+               TAY
                LDA (ACCU),Y
                TAX
                INY
                LDA (ACCU),Y
                STX ACCU
                STA ACCU + 1
                LDY #0
                +caml_NEXT
}

caml_PHATOM0
!ifdef caml_gen_PHATOM0 {
                JSR caml_PUSH
                JMP caml_ATOM0
}

caml_ATOM0
!ifdef caml_gen_ATOM0 {
                LDA # <caml_atom0
                STA ACCU
                LDA # >caml_atom0
                STA ACCU + 1
                +caml_NEXT
}

caml_MKBLKN
!ifdef caml_gen_MKBLKN {
                JSR caml_interp_getarg
                TAX                     ;X = size
                JSR caml_interp_getarg  ;A = tag
                JMP caml_MKBLK
}

caml_MKBLK13
!ifdef caml_gen_MKBLK13 {
                SBC # $7C -1            ;-1 as C=0; A:=2n=2*opc-$7C
                LSR
                TAX                     ;X = size
                JSR caml_interp_getarg  ;A = tag
                JMP caml_MKBLK
}

caml_GETFLD13
!ifdef caml_gen_GETFLD13 {
                SBC # $86 -1            ;-1 as C=0; A:=2n=2*opc-$86
                TAY
                JMP caml_GETFLD0
}

caml_SETFLD13
!ifdef caml_gen_SETFLD13 {
                SBC # $93 -1            ;-1 as C=0; A:=2n-1=2*opc-$93
                ADC ACCU                ;A:=2n-1+ACCU +1 as C=1
                STA ACCU                ;ACCU:=2n+ACCU
                BCC caml_SETFLD0
                INC ACCU + 1
                JMP caml_SETFLD0
}

caml_BIF
!ifdef caml_gen_BIF {
                LDA ACCU
                LSR
                ORA ACCU + 1
                BEQ +
                JMP caml_BRANCH
+               CLC:JMP caml_interp_skip2or3by
}

caml_BIFNOT
!ifdef caml_gen_BIFNOT {
                LDA ACCU
                LSR
                ORA ACCU + 1
                BNE +
                JMP caml_BRANCH
+               CLC:JMP caml_interp_skip2or3by
}

caml_SWITCH
!ifdef caml_gen_SWITCH {
                LDA (PC),Y              ;A := n
                STA TMP
                BEQ @pptrs
                LDA ACCU
                AND # 1
                BEQ @pptrs
                LDA PC
                LDX PC + 1
                JMP caml_SWITCHI
@pptrs          LDX PC + 1
                ASL TMP
                BCC +
                INX
+               LDA PC
                SEC                     ;+1
                ADC TMP
                BCC +
                INX
+               JMP caml_SWITCHP
}

caml_PHCST03
!ifdef caml_gen_PHCST03 {
                SBC # $CF -1            ;-1 as C=0; A:=2n+1=2*opc-$CF
                TAX
                JSR caml_PUSH
                STX ACCU                ;ACCU:=Val_int(opcode-$CF)
                STY ACCU + 1
                +caml_NEXT
}

caml_CST03
!ifdef caml_gen_CST03 {
                SBC # $C5 -1            ;-1 as C=0; A:=2n+1=2*opc-$C5
                STA ACCU                ;ACCU:=Val_int(opcode-$63)
                STY ACCU + 1
                +caml_NEXT
}

caml_PHCSTN
!ifdef caml_gen_PHCSTN {
                TAX
                JSR caml_PUSH
                TXA
                JMP caml_CSTN
}

caml_CSTN
!ifdef caml_gen_CSTN {
                JSR caml_interp_getarg
                STA ACCU
                JSR caml_interp_getarg
                STA ACCU + 1
                +caml_NEXT
}

;; "PAIRED OPCODES" DISAMBIGUATION ROUTINES.
;; Two opcodes are "paired" when their bits are equal but the msb, which is
;; assigned to the C flag by the fetch routine.
        
;; N.b.: the routines placement below guarantees that conditional branches
;; targets stay in range [-128, +127]

!set caml_PUSH_ULTINT = *
!ifdef caml_gen_PUSH_ULTINT {
  !ifdef caml_gen_PUSH {
    !ifdef caml_gen_ULTINT {
                BCS +
                JSR caml_PUSH
                +caml_NEXT
+               JMP caml_ULTINT
    } else {
                JSR caml_PUSH
                +caml_NEXT
    }
  } else { !set caml_PUSH_ULTINT = caml_ULTINT }
}

caml_PHACC5_STOP
!ifdef caml_gen_PHACC5_STOP {
                BCC caml_PHACC17
                JMP caml_STOP
}
caml_PHACC17
!ifdef caml_gen_PHACC17 {
                SBC # $14 -1            ;-1 as C=0; A:=2n=2*opc-$14
                STA TMP
                JSR caml_PUSH
                LDY TMP                 ;Y:=2n
                JMP caml_ACCL
}

!set caml_ACC_BGEINT = *
!ifdef caml_gen_ACC_BGEINT {
  !ifdef caml_gen_ACCH {
    !ifdef caml_gen_BGTGEINT {
                BCS caml_BGTGEINT
                JMP caml_ACCH
    } else { !set caml_ACC_BGEINT = caml_ACCH }
  } else { !set caml_ACC_BGEINT = caml_BGTGEINT }
}

!set caml_ACC7_BGTINT = *
!ifdef caml_gen_ACC7_BGTINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BGTGEINT {
                BCC caml_ACC07
                ;; fallthrough caml_BGTGEINT
    } else { !set caml_ACC7_BGTINT = caml_ACC07 }
  } else { !set caml_ACC7_BGTINT = caml_BGTGEINT }
}
caml_BGTGEINT
!ifdef caml_gen_BGTGEINT {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
                JSR caml_CMP_SGN
                BPL caml_BRANCH
                CLC:JMP caml_interp_skip2or3by  ;BCC would be out-of-range
}

!set caml_PHACC1_BULTINT = *
!ifdef caml_gen_PHACC1_BULTINT {
  !ifdef caml_gen_PHACC17 {
    !ifdef caml_gen_BULTINT {
                BCC caml_PHACC17
                ;; fallthrough caml_BULTINT
    } else { !set caml_PHACC1_BULTINT = caml_PHACC17 }
  } else { !set caml_PHACC1_BULTINT = caml_BULTINT }
}
caml_BULTINT
!ifdef caml_gen_BULTINT {
                JSR caml_interp_getarg
                CMP ACCU
                JSR caml_interp_getarg
                SBC ACCU + 1
                BCC caml_BRANCH
                CLC:BCC caml_interp_skip2or3by  ;OK: BCC +116
}

!set caml_PHACC2_BUGEINT = *
!ifdef caml_gen_PHACC2_BUGEINT {
  !ifdef caml_gen_PHACC17 {
    !ifdef caml_gen_BUGEINT {
                BCC caml_PHACC17
                ;; fallthrough caml_BUGEINT 
    } else { !set caml_PHACC2_BUGEINT = caml_PHACC17 }
  } else { !set caml_PHACC2_BUGEINT = caml_BUGEINT }
}
caml_BUGEINT
!ifdef caml_gen_BUGEINT {
                JSR caml_interp_getarg
                CMP ACCU
                JSR caml_interp_getarg
                SBC ACCU + 1
                BCS caml_BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set caml_ACC0_OFSREF = *
!ifdef caml_gen_ACC0_OFSREF {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_OFSREF {
                BCC caml_ACC07
                JMP caml_OFSREF
    } else { !set caml_ACC0_OFSREF = caml_ACC07 }
  } else { !set caml_ACC0_OFSREF = caml_OFSREF }
}

!set caml_ACC1_ISINT = *
!ifdef caml_gen_ACC1_ISINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_ISINT {
                BCC caml_ACC07
                JMP caml_ISINT
    } else { !set caml_ACC1_ISINT = caml_ACC07 }
  } else { !set caml_ACC1_ISINT = caml_ISINT }
}

!set caml_ACC3_BEQ = *
!ifdef caml_gen_ACC3_BEQ {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BEQ {
                BCC caml_ACC07
                ;; fallthrough caml_BEQ
    } else { !set caml_ACC3_BEQ = caml_ACC07 }
  } else { !set caml_ACC3_BEQ = caml_BEQ }
}
caml_BEQ
!ifdef caml_gen_BEQ {
                JSR caml_interp_getarg
                CMP ACCU
                BEQ +
                SEC:BCS caml_interp_skip2or3by
+               JSR caml_interp_getarg
                CMP ACCU + 1
                BEQ caml_BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set caml_ACC4_BNEQ = *
!ifdef caml_gen_ACC4_BNEQ {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BNEQ {
                BCC caml_ACC07
                ;; fallthrough caml_BNEQ
    } else { !set caml_ACC4_BNEQ = caml_ACC07 }
  } else { !set caml_ACC4_BNEQ = caml_BNEQ }
}
caml_BNEQ
!ifdef caml_gen_BNEQ {
                JSR caml_interp_getarg
                CMP ACCU
                BNE +
                SEC:BCS caml_interp_skip2or3by
+               JSR caml_interp_getarg
                CMP ACCU + 1
                BNE caml_BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set caml_ACC5_BLTINT = *
!ifdef caml_gen_ACC5_BLTINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BLTLEINT {
                BCS caml_BLTLEINT
                ;; fallthrough caml_ACC07
    } else { !set caml_ACC5_BLTINT = caml_ACC07 }
  } else { !set caml_ACC5_BLTINT = caml_BLTLEINT }
}
caml_ACC07
!ifdef caml_gen_ACC07 {
                TAY                     ;Y=2n
                JMP caml_ACCL
}

!set caml_ACC6_BLEINT = *
!ifdef caml_gen_ACC6_BLEINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BLTLEINT {
                BCC caml_ACC07
                ;; fallthrough caml_BLTLEINT
    } else { !set caml_ACC6_BLEINT = caml_ACC07 }
  } else { !set caml_ACC6_BLEINT = caml_BLTLEINT }
}
caml_BLTLEINT
!ifdef caml_gen_BLTLEINT {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
                JSR caml_CMP_SGN
                BMI caml_BRANCH
                CLC:BCC caml_interp_skip2or3by
}
                ;; caml_BRANCH, START, FETCH ARG, SKIP ARG.

caml_BRANCH                             ;Branch to *PC
                LDA (PC),Y
                TAX
                INC PC
                BNE +
                INC PC + 1
+               LDA (PC),Y
                ;; fallthrough caml_interp_start
caml_interp_start                       ;ENTRYPOINT: start interpreter
                STX PC
                STA PC + 1
                JMP caml_interp_fetch

caml_interp_skip2or3by                  ;Skip next 2 + Carry bytes
                LDA # 2
                ADC PC
                STA PC
                BCC +
                INC PC + 1
+               JMP caml_interp_fetch

caml_interp_getarg                      ;Fetch a 1-byte argument
                LDA (PC),Y
                INC PC
                BNE +
                INC PC + 1
+               RTS

caml_INVALID                            ;invalid/unused opcode -> reset
                JMP C64_RESET

                ;; OPCODES JUMPTABLE.
                ;; The table is page-aligned. The fetch-exec routine sets C=bit7
                ;; of fetched opcode, then accesses the table using 2*opcode as
                ;; an index.  

                !align  $FF, $00
caml_interp_jmptbl
                ;; $00...$0f/$80...$8f  (unused opcodes: $0a, $82, $8d, $8e)
                !wo caml_ACC0_OFSREF, caml_ACC1_ISINT, caml_ACC07, caml_ACC3_BEQ
                !wo caml_ACC4_BNEQ, caml_ACC5_BLTINT, caml_ACC6_BLEINT
                !wo caml_ACC7_BGTINT, caml_ACC_BGEINT, caml_PUSH_ULTINT
                !wo caml_UGEINT, caml_PHACC1_BULTINT, caml_PHACC2_BUGEINT
                !wo caml_PHACC17, caml_PHACC17, caml_PHACC5_STOP
                ;; $10...$1f/$90...$94  (unused opcodes: $90...$94)
                !wo caml_PHACC17, caml_PHACC17, caml_PHACC, caml_POPN
                !wo caml_ASSIGNH, caml_ENVACC14, caml_ENVACC14, caml_ENVACC14
                !wo caml_ENVACC14, caml_ENVACCN, caml_PHENVACC14
                !wo caml_PHENVACC14, caml_PHENVACC14, caml_PHENVACC14
                !wo caml_PHENVACC, caml_PHRET
                ;; $20...$2f
                !wo caml_APPLYN, caml_APPLY13, caml_APPLY13, caml_APPLY13
                !wo caml_APPTRMN, caml_APPTRM13, caml_APPTRM13, caml_APPTRM13
                !wo caml_RETURN, caml_RESTART, caml_GRAB, caml_CLOSURE
                !wo caml_CLOSREC, caml_OFSCLM2, caml_OFSCL0, caml_OFSCL2
                ;; $30...$3f            (unused opcodes: $3b, $3d)
                !wo caml_OFSCLN, caml_PHOFSCLM2, caml_PHOFSCL0, caml_PHOFSCL2
                !wo caml_PHOFSCLN, caml_GETGLB, caml_PHGETGLB, caml_GETGLBFLD
                !wo caml_PHGETGLBFLD, caml_SETGLB, caml_ATOM0, caml_INVALID
                !wo caml_PHATOM0, caml_INVALID, caml_MKBLKN, caml_MKBLK13
                ;; $40...$4f
                !wo caml_MKBLK13, caml_MKBLK13, caml_MKFBLK, caml_GETFLD0
                !wo caml_GETFLD13, caml_GETFLD13, caml_GETFLD13, caml_GETFLDN
                !wo caml_GETFFLDN, caml_SETFLD0, caml_SETFLD13, caml_SETFLD13
                !wo caml_SETFLD13, caml_SETFLDN, caml_SETFFLDN, caml_VECLEN
                ;; $50...$5f            (unused opcode: $5c)
                !wo caml_GETVEC, caml_SETVEC, caml_GETCHR, caml_SETCHR
                !wo caml_BRANCH, caml_BIF, caml_BIFNOT, caml_SWITCH
                !wo caml_BOOLNOT, caml_PHTRP, caml_POPTRP, caml_RAISE
                !wo caml_INVALID, caml_CCALL, caml_CCALL, caml_CCALL
                ;; $60...$6f
                !wo caml_CCALL, caml_CCALL, caml_CCALL, caml_CST03, caml_CST03
                !wo caml_CST03, caml_CST03, caml_CSTN, caml_PHCST03
                !wo caml_PHCST03, caml_PHCST03, caml_PHCST03, caml_PHCSTN
                !wo caml_NEGINT, caml_ADDINT, caml_SUBINT
                ;; $70...$7f
                !wo caml_MULINT, caml_DIVINT, caml_MODINT, caml_ANDINT
                !wo caml_ORINT, caml_XORINT, caml_LSLINT, caml_LSRINT
                !wo caml_ASRINT, caml_EQ, caml_NEQ, caml_LTINT, caml_LEINT
                !wo caml_GTINT, caml_GEINT, caml_OFSINT
} ;ifdef caml_INTERP

caml_runtime_end
} ;zone caml_RUNTIME
