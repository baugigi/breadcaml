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
;;                                   LOADER
;; -----------------------------------------------------------------------------
;; ACME command-line arguments:
;;   -Dcaml_SHOWMEM=1                Show program memory usage
;;   -Dcaml_INTERP=1                 Bytecode interpretation
;; -----------------------------------------------------------------------------

!cpu 6502
!convtab pet

!zone   caml_LOADER {
.dummy = $1234                          ;dummy arg. for self-modifying
                                        ;code (SMC in comments)


        * = C64_BASRAM + 1

caml_loader
        !word +, 10                     ;10 SYS <caml_init>
        !byte C64_BAS_SYS
        !for @i, 4, 0 {
          !text '0' + (caml_init DIV 10 ^ @i) % 10
        }
        !byte 0                         ;End of line
+       !word +, 20                     ;20 REM <QUOTE><SH+CR><CLR><LO_CASE>
        !byte C64_BAS_REM, 34, 141, 147, 14                  
        !text 141, "         The BreadCaml Project"         ;<SH+CR> txt...
        !text 141, "        (C) 2026  Piero Furiesi"        ;<SH+CR> txt...
        !text 141, "  https://github.com/baugigi/breadcaml" ;<SH+CR> txt...
        !text 141                                           ;<SH+CR>
.zeroes !byte 0                         ;End of line
+       !byte 0, 0                      ;End of program


;; -----------------------------------------------------------------------------
;;      ZERO-PAGE RESERVED ADDRESSES
;; -----------------------------------------------------------------------------

!addr {
	ACCU	= C64_FREKZP     	; 	  2 by. Accumulator
        SP      = C64_FREKZP + 2 	; 	  2 by. Stack Pointer
        XARGS   = C64_UNUSZP     	; 	  1 by. Extra_args
        ENV     = $2B 			;-$2C     2 by. Environment
        TRAPSP  = $2D 			;-$2E     2 by. Trap Pointer
  !ifdef caml_INTERP {
        caml_interp_fetch = $2F 	;-$3D    15 by. FETCH-EXEC LOOP
        PC                = $30 	;-$31           Program Counter
  }
        GC      = $3E 			;-$46     9 by. caml_alloc
					;($47-$48       Used by C64_FOUT)
        HEAP    = $49 			;-$4A     2 by. Heap Pointer
        BLK     = $4B 			;-$4C     2 by. caml_alloc: New Block
        TMP     = $4D 			;Temp.area, towards the BASIC FLPT zone.
                                	;See stdlib_floats.asm for more info.

;; All ZP memory locations, except for C64_FREKZP (4 by.), C64_UNUSZP (1 by.),
;; and the FLPT area, must be saved and restored upon exit.
        .zpbase = $2B		;start
        .zpend  = $4E		;end + 1
}
      
;; -----------------------------------------------------------------------------
;;      Address symbols set by bcamlc/bcamlopt
;; -----------------------------------------------------------------------------

;; caml_glob_table                      ;global table
;; caml_glob_data                       ;global data
;; caml_glob_end                        ;end of globals + 1
;; caml_program                         ;object code
;; caml_externals_lo                    ;external jumptable, lo bytes
;; caml_externals_hi                    ;external jumptable, hi bytes
;; caml_stack_start                     ;stack start address
;; caml_stack_end                       ;stack end address + 1

!ifndef caml_basic_rom_overlap {
  !if caml_stack_end > C64_BASROM {
        caml_basic_rom_overlap = 1
        !info "BASIC ROM overlap: BASIC routine calls will be wrapped." 
  }
}


;; -----------------------------------------------------------------------------
;;      MEMORY REPRESENTATION OF OCaml VALUES: INTEGERS OR BLOCKS.
;; -----------------------------------------------------------------------------

;; INTEGERS:   .___1_word__.   15-bit signed integers, bit0=1
;;             |_lo_1¦±_hi_|

!macro  Val_Int ~.val, .int {           ;Set .val to repr(.int)
  !set  .val = (2 * .int) + 1
}
        +Val_Int ~Val_zero,     0       ;0 : int
        +Val_Int ~Val_one,      1       ;1 : int
        +Val_Int ~Val_false,    0       ;false : bool
        +Val_Int ~Val_true,     1       ;true : bool
        +Val_Int ~Val_unit,     0       ;() : unit


;; BLOCKS:     .__Pointer__.   16-bit word-aligned pointers, lsb=0
;;             |_lo_0¦__hi_|
;;            /
;; .__Header_*___Fld(0)__.___Fld(1)__._ _._Fld(Sz-1)_.
;; |Tag_¦_Sz_|___Value___|___Value___|···|___Value___|

        ;; BIT caml_is_block will set Z=1 <=> A is a block
!addr   caml_is_block   = .isblk + 1

        Custom_tag      = 255            ;custom block
        Double_array_tag= 254            ;array of unboxed floats
        Double_tag      = 253            ;float
        String_tag      = 252            ;string
        Abstract_tag    = 251            ;abstract
        No_scan_tag     = 251            ;tag >= No_scan_tag ==> no GC scan
        Forward_tag     = 250            ;lazy value, fwd ptr
        Infix_tag       = 249            ;rec.closuse; lsb=1 ==> no GC scan
        Object_tag      = 248            ;object/exception
        Closure_tag     = 247            ;closure
        Lazy_tag        = 246            ;lazy value


;; ATOM(0):    .Tag_Sz_*                 ;Atom(t) with t>0 not allowed, as no
;;             |_0_¦_0_|                 ; OCaml value is represented as such

        ;; Statically allocated, word-aligned
!addr   caml_atom0 = .zeroes + 2 + .zeroes % 2


;; FLOAT blocks: C64 MFLP representation, not IEEE!
;; .Tag_Sz_*_________._________._________.
;; |253¦_3_|Expo¦±M_a|_n_t¦_i_s|_s_a¦_Fl_|      Fl = special value flag
;;
;; Byte 5 (Fl) tells whether the float is finite or one of the IEEE special
;; values. The encoding allows a fast test (LDA/ORA + BNE) and makes the flag
;; the signed ordering key of the special values (nan < -inf < finite < +inf):
;;   $00 finite    $01 +infinity    $FF -infinity    $80 nan
;; Two's complement negation of the flag is the negation of the float (it
;; swaps +-inf, and keeps $00 and $80 unchanged). Bytes 0-4 of the special
;; values are canonical, so routines ignoring the flag degrade gracefully:
;;   +-infinity = largest magnitude ($FF, +-$FFFFFFFF), nan = 0.0 ($00...).

        Double_wosize   = 3
        Float_flag      = 5             ;offset of the flag byte in the block
        Fl_pinf         = $01
        Fl_ninf         = $FF
        Fl_nan          = $80

!macro  caml_move_float .from, .to {     ;Copy float block fields and set Y = 0
        LDY # 2 * Double_wosize - 1      ; at exit
-       LDA (.from),Y
        STA (.to),Y
        DEY
        BPL -
        INY
}


;; STRING blocks: length = 2 * Sz - 1 - last byte;
;; .Tag_Sz_*___________.___________.___________.
;; |252¦_3_|_'O'_¦_'C'_|_'a'_¦_'m'_|_'l'_¦__0__| "OCaml" length=2*3-1-0=5
;; .Tag_Sz_*___________.___________.___________.
;; |252¦_3_|_'C'_¦_'='_|_'6'_¦_'4'_|__0__¦__1__| "C=64"  length=2*3-1-1=4

!macro  caml_string .str {              ;Assemble the string .str with proper
        !text .str, 0                   ; trailing byte(s)
        !if len(.str) % 2 = 0 { !byte 1 }
}


;; CLOSURE/RECURSIVE CLOSURE blocks: Sz = 2 * nfun - 1 + nvar
;; .Tag_Sz_*0______.Tag_Sz_*1______.Tag_Sz_*2______._ _.______.______._
;; |247¦Sz_|_code0_|249¦_2_|_code1_|249¦_4_|_code2_|···|_Var0_|_Var1_|_···
;;                  /    \___________/___\___ # of words from *0 to *i = 2i
;; Infix_tag_______/________________/


;; EXCEPTION blocks:
;; .Tag_Sz_*____________._____.
;; |248¦_2_|_string_blk_|_oid_|         ;Standard exceptions: oid = -exn_no - 1 
;;          /
;; .Tag_Sz_*_.______···_______.
;; |252¦Sz_|_"Exception_name"_|

        ;; Statically allocate the standard exceptions and initialize the
        ;; caml_std_exn[] pointer array
!convtab raw {
        !align  $01, $00
        @ot = Object_tag
        @st = String_tag
        ;;  Exn_hdr:Exn      F0, F1:    Str_hdr:Str      F0
        !byte @ot,2:@x0 !word +, -1:!byte @st,7:+ !text "Out_of_memory",0
        !byte @ot,2:@x1 !word +, -2:!byte @st,5:+ !text "Sys_error",0
        !byte @ot,2:@x2 !word +, -3:!byte @st,4:+ !text "Failure",0
        !byte @ot,2:@x3 !word +, -4:!byte @st,9:+ !text "Invalid_argument",0,1
        !byte @ot,2:@x4 !word +, -5:!byte @st,6:+ !text "End_of_file",0
        !byte @ot,2:@x5 !word +, -6:!byte @st,9:+ !text "Division_by_zero",0,1
        !byte @ot,2:@x6 !word +, -7:!byte @st,5:+ !text "Not_found",0
        !byte @ot,2:@x7 !word +, -8:!byte @st,7:+ !text "Match_failure",0
        !byte @ot,2:@x8 !word +, -9:!byte @st,8:+ !text "Stack_overflow",0,1
        !byte @ot,2:@x9 !word +,-10:!byte @st,8:+ !text "Sys_blocked_io",0,1
        !byte @ot,2:@xa !word +,-11:!byte @st,8:+ !text "Assert_failure",0,1
        !byte @ot,2:@xb !word +,-12:!byte @st,9:+ !text "Undef_rec_module",0,1
}
        caml_exn_no = 12
        caml_std_exn = [@x0,@x1,@x2,@x3,@x4,@x5,@x6,@x7,@x8,@x9,@xa,@xb]

        Out_of_memory   =  0 :  End_of_file     =  4 :  Stack_overflow  =  8
        Sys_error       =  1 :  Division_by_zero=  5 :  Sys_blocked_io  =  9
        Failure         =  2 :  Not_found       =  6 :  Assert_failure  = 10
        Invalid_argument=  3 :  Match_failure   =  7 :  Undef_rec_module= 11

!macro  caml_raise .exn {               ;Raise a standard exception with no
        LDA # <caml_std_exn[.exn]       ; arguments.
        STA ACCU
        LDA # >caml_std_exn[.exn]
        STA ACCU + 1
        JMP caml_RAISE
}
!macro  caml_raise .exn, .str {         ;Raise a standard exception with a
        LDA # <.blk                     ; string argument.
        STA ACCU
        LDA # >.blk
        STA ACCU + 1
        JMP caml_RAISE
        !align $01, $00
        !byte String_tag, (.h - .s) div 2
.s      +caml_string .str
.h      !byte 0, 2
.blk    !word caml_std_exn[.exn], .s
}

        
;; -----------------------------------------------------------------------------
;;      INITIALIZATION
;; -----------------------------------------------------------------------------

caml_init
        LDX # .zpend - .zpbase          ;Save: used ZP area,
-       LDA .zpbase - 1,X
        STA .zpsave - 1,X
        DEX
        BNE -
        LDA C64_VIC_VMCB                ;  VIC memory control,
        STA .vicctl + 1
        LDA C64_VIC_EC                  ;  border color,
        STA .bdcol + 1
        LDA C64_VIC_B0C                 ;  background color,
        STA .bgcol + 1
        LDA C64_COLOR                   ;  character color,
        STA .chcol + 1
        LDA C64_CHRPTR                  ;  BASIC program pointer.
        STA .bptrl + 1
        LDA C64_CHRPTR + 1
        STA .bptrh + 1
        TSX                             ;Save the CPU stack ptr; see caml_RAISE
        STX caml_hw_stack_ptr           ; in runtime.asm.
        LDA # <caml_syserr              ;Redirect C64_IERROR vector.
        STA C64_IERROR
        LDA # >caml_syserr
        STA C64_IERROR + 1
        LDA # 14
        JSR C64_CHROUT                  ;Select upper+lowercase charset.

        ;; Y is set to 0 here and, if not stated elsewhere, each routine/macro
        ;; assumes Y = 0 when invoked and ensures Y = 0 stands again upon exit.
        LDY # 0
        
        JSR caml_heap_init              ;Init heap (see memory.asm).
.isblk  LDA # <Val_zero                 ;Init the ZAM2 registers.
        STA ACCU
        STY ACCU + 1
        STA TRAPSP
        STY TRAPSP + 1
        STA XARGS
        LDA # <caml_stack_end
        STA SP
        LDA # >caml_stack_end
        STA SP + 1
        LDA # <caml_atom0
        STA ENV
        LDA # >caml_atom0
        STA ENV + 1
!ifdef  caml_basic_rom_overlap {
        JSR caml_BASROM_off
}

!ifndef caml_INTERP {
        JMP caml_program                ;START COMPILED PROGRAM
} else {
                LDX # 15                ;Copy the fetch-exec routine to ZP
-               LDA @fe_start - 1,X
                STA caml_interp_fetch - 1,X
                DEX
                BNE -
                LDX # <caml_program     ;PC will be set to A:X
                LDA # >caml_program
                JMP caml_interp_start   ;START BYTECODE INTERPRETATION
@fe_start
!pseudopc caml_interp_fetch {           ;FETCH-EXEC ROUTINE:
@fetch          LDA .dummy              ; SMC: LDA PC
                INC+1 @fetch + 1        ; SMC: INC PC
                BNE +
                INC+1 @fetch + 2        ; SMC: INC PC+1
+               ASL                     ; C:A = 2 * opcode
                STA+1 @exec + 1         ; SMC: overwrite JMP() argument
@exec           JMP (caml_interp_jmptbl); SMC: JMP(A + >jmptbl)
  }
}


;; -----------------------------------------------------------------------------
;;      TERMINATION
;; -----------------------------------------------------------------------------

caml_end
        LDA # <C64_ERROR                ;Restore IERROR vector.
        STA C64_IERROR
        LDA # >C64_ERROR
        STA C64_IERROR + 1
        LDX # .zpend - .zpbase          ;Restore ZP values.
-       LDA .zpsave - 1,X
        STA .zpbase - 1,X
        DEX
        BNE -
        JSR C64_RESTOR                  ;Restore system vectors.
        JSR C64_IOINIT                  ;Reset I/O devices.
        LDA C64_CIA2_ICR                ;Acknowledge a pending CIA2 NMI
        LDA # 0                         ; (see Nmi.block).
        LDX # $18
-       STA C64_SID_V1FL,X              ;Reset SID.
        DEX
        BNE -
        JSR C64_VICINIT                 ;Reset VIC.
        LDX # $00
        STX C64_VIC_IRQEN               ;Disable VIC IRQs and
        DEX
        STX C64_VIC_IRQST               ; acknowledge pending requests.
.vicctl LDA # <.dummy
        STA C64_VIC_VMCB                ;Restore VIC memory control,
.bdcol  LDA # <.dummy
        STA C64_VIC_EC                  ; border color,
.bgcol  LDA # <.dummy
        STA C64_VIC_B0C                 ; background color, and
.chcol  LDA # <.dummy
        STA C64_COLOR                   ; character color.
.bptrl  LDA # <.dummy
        STA C64_CHRPTR                  ;Reset BASIC program pointer.
.bptrh  LDA # >.dummy
        STA C64_CHRPTR + 1
        JSR C64_CLRCHN                  ;Reset I/O channels.
        LDA # 0
        STA C64_NDX                     ;Clear keyboard buffer.
        STA C64_QTSW                    ;Switch off quote mode,
        STA C64_RVS                     ; reverse mode, and
        STA C64_INSRT                   ; insert mode.
        LDA C64_BLNON
        BEQ +                           ;If cursor is inverted,
        LDA C64_GDBLN                   ; get the character under it
        LDY C64_PNTR                    ; and its position,
        STA (C64_PNT),Y                 ; print it on screen, and
        LDA C64_GDCOL
        STA (C64_USER),Y                ; restore its background color;
        LDA # 0         
        STA C64_BLNON                   ; then adjust the blink flag.
+       LDA # $FF                       ;Set blinking off (BASIC will
        STA C64_BLNSW                   ; reactivate it by itself).
!ifdef  caml_basic_rom_overlap {
        JSR caml_BASROM_on
}
        LDA # 14                        ;Select upper+lowercase charset
        JMP C64_CHROUT                  ; and return to BASIC.
.zpsave !fill .zpend - .zpbase
        

;; -----------------------------------------------------------------------------
;;      ROM/RAM OVERLAP - WAPPER FOR CALLS TO BASIC ROUTINES
;; -----------------------------------------------------------------------------

        ;; Macro: call a BASIC ROM routine
!macro caml_JSR_BASROM .routine {
  !ifndef caml_basic_rom_overlap {      ;Best case: code never overlaps
        JSR .routine                    ; BASIC ROM.
  } else {
    !if * + 9 < C64_BASROM {            ;BASROM is disabled but this part of
        JSR caml_BASROM_on              ; of code doesn't overlap it.
        JSR .routine
        JSR caml_BASROM_off
    } else {                            ;Worst case: this part of code overlaps 
        PHP                             ; BASIC ROM. Pass the routine address to 
        PHA                             ; a wrapper in a safe zone and call it.
        LDA # <.routine
        STA caml_BASROM_wrapper__addr
        LDA # >.routine
        STA caml_BASROM_wrapper__addr + 1
        JSR caml_BASROM_wrapper
    }
  }
}

!ifdef caml_basic_rom_overlap {
caml_BASROM_wrapper                     ;Wrapper for 'Worst case' above
        SEI
        LDA C64_R6510
        ORA # %00000011
        STA C64_R6510
        CLI
        PLA
        PLP
caml_BASROM_wrapper__addr = * + 1
        JSR .dummy                      ;SMC: JSR .routine
        ;; fallthrough caml_BASROM_off
caml_BASROM_off                         ;Deactivate BASIC ROM
        PHP
        PHA
        SEI
        LDA C64_R6510
        AND # %11111110
        STA C64_R6510
        CLI
        PLA
        PLP
        RTS
caml_BASROM_on                          ;Activate BASIC ROM
        PHP
        PHA
        SEI
        LDA C64_R6510
        ORA # %00000011
        STA C64_R6510
        CLI
        PLA
        PLP
        RTS
}


;; -----------------------------------------------------------------------------
;;      ERROR HANDLER FOR SYSTEM FAILURES
;; -----------------------------------------------------------------------------

caml_syserr
!ifdef caml_basic_rom_overlap {JSR caml_BASROM_off}
        LDY # 0
        CPX # C64_ERR_DBZ               ;If the system error matches an
        BNE +                           ; OCaml standard exception,
        +caml_raise Division_by_zero    ; raise it.
+       CPX # C64_ERR_IQN
        BNE +
        +caml_raise Invalid_argument, "ILLEGAL QUANTITY"
+       CPX # C64_ERR_OOM
        BNE +
        +caml_raise Out_of_memory
+
!ifdef caml_AUX__caml_float_overflow {
        CPX # C64_ERR_OVF               ;A floating-point primitive overflowed:
        BNE +                           ; it returns +-infinity (no return here)
        JSR caml_float_overflow         ; unless it doesn't know how to, and
        LDY # 0                         ; then Sys_error "OVERFLOW" is raised.
        LDX # C64_ERR_OVF
+
}
        DEX
        TXA
        PHA                             ;Push error no. - 1 on hw stack.
        LDX # 2                         ;Allocate a 0-tagged, 2-field 
        LDA # 0                         ; block for the exception and
        JSR caml_alloc                  ; its string arg.
        LDA # <Val_zero                 ;Make both (still uninitialized) fields
        STA (BLK),Y                     ; look like ints (lsb = 1): the next
        LDY # 2                         ; caml_alloc may run a GC that scans
        STA (BLK),Y                     ; this block (it is in ACCU).
        LDY # 0
        JSR caml_load_newblk
        LDX # 11                        ;Max error string length (wo.)
        LDA # String_tag                ;Allocate the string.
        JSR caml_alloc
        LDY # 3                         ;Fill in the 0-tagged block
        LDA BLK + 1
        STA (ACCU),Y
        DEY
        LDA BLK
        STA (ACCU),Y
        DEY
        LDA # >caml_std_exn[Sys_error]
        STA (ACCU),Y
        DEY
        LDA # <caml_std_exn[Sys_error]
        STA (ACCU),Y
        PLA                             ;Pop error no. - 1, double it, then use
        ASL                             ; it to read the error message address 
        TAX                             ; from the address table in ROM and save
!ifdef caml_basic_rom_overlap {JSR caml_BASROM_on}
        LDA C64_ERRTAB,X                ; it in TMP.
        STA TMP
        LDA C64_ERRTAB + 1,X
        STA TMP + 1
-       LDA (TMP),Y                     ;Copy the err. msg. from ROM to the
        BMI +                           ; allocated string block; last char has 
        STA (BLK),Y                     ; its msb set.
        INY
        BNE -                           ;BNE=JMP
+
!ifdef caml_basic_rom_overlap {JSR caml_BASROM_off}
        EOR # $80                       ;Last char: reset the msb and save it.
        STA (BLK),Y
        INY
        LDA # 0                         ;OCaml terminator, 1st (maybe unique) 
        STA (BLK),Y                     ; byte.
        INY
        TYA
        LSR
        TAX                             ;X=string block length (wo.)
        BCC +                           ;If C=0, no need of 2nd byte.
        LDA # 1                         ;OCaml terminator, 2nd byte.
        STA (BLK),Y
        INX
+       LDY # 0
        JSR caml_shrink_latest_alloc    ;Reduce the string block size.
        JMP caml_RAISE                  ;Raise the exception.


;; ----------------------------------------------------------------------------
;;      UNCAUGHT EXCEPTIONS
;; ----------------------------------------------------------------------------
;; Arguments: only integer values ​​and blocks with String_tag are printed. Other
;; blocks are printed as "_", except for the ONE block argument to the "special"
;; exceptions Match_failure, Assert_failure, and Undef_rec_module, which has
;; type (string * int * int) and is printed in full.
;;
;; Exception with no arguments:
;;   { Object_tag; 2 | { String_tag; n | ASCII_chars } | oid } = EXN_BLOCK
;; Exception with k>0 arguments:
;;   { 0; k | EXN_BLOCK | arg1 | ... | argk }
;; Special exceptions:
;;   { 0; 2 | EXN_BLOCK | { 0; 3 | string | int | int } }

        ;; Print the uncaught exception in ACCU with its arguments, if any.
caml_uncaught_exn
        @tmp    = TMP                   ;@get_tag_sz, @get_field, @pr_exn
        @fld1   = TMP + 2               ;main routine
        @sz     = TMP + 4               ;main routine
        @arg    = TMP + 2               ;@pr_arg
        @out    = TMP + 4               ;@pr_arg
        @count  = TMP + 6               ;@pr_arg
        LDX # 0
-       LDA @uncght,X                   ;Print "\rException: "
        BEQ +
        JSR C64_CHROUT
        INX
        BNE -
+       LDA ACCU + 1
        LDX ACCU
        JSR @get_tag_size               ;A:=tag(ACCU); X:=size(ACCU)
        STX @sz    
        CMP # Object_tag                ;if tag(ACCU) = Object_tag
        BNE @args                       ;then
        JSR @get_ACCU_field0            ;  /* no args */
        JSR @pr_exn                     ;  print Field(ACCU,0) /* exn_name */
        JMP caml_end                    ;  exit
@uncght !text 13, "Exception: ", 0

@args   JSR @get_ACCU_field0            ;else /* one or more args */
        LDY # 0
        JSR @get_field
        JSR @pr_exn                     ;  print Field(Field(ACCU,0),0)
        LDA @sz    
        CMP # 2                         ;  if size(ACCU) = 2
        BNE @norm
        LDA ACCU + 1
        LDX ACCU
        LDY # 2
        JSR @get_field
        STA @fld1 + 1
        STX @fld1
        TXA
        BIT caml_is_block               ;    && is_block(Field(ACCU,1))
        BNE @norm
        LDA @fld1 + 1
        JSR @get_tag_size
        BNE @norm                       ;    && tag(Field(ACCU,1)) = 0
        JSR @get_ACCU_field0            ;    && is_special_exn(Field(ACCU,0))
        CMP # 1 + >caml_std_exn[caml_exn_no - 1]
        BCS @norm
@spec   LDA @fld1 + 1                   ;  then /* special exn */
        LDX @fld1                       ;    A:X := Field(ACCU,1)
        LDY # 3                         ;    Y := 3
        BNE @pr_arg
@norm   LDA ACCU                        ;  else /* normal exn */
        CLC                             ;    A:X := ACCU + 2 = &Field(ACCU,1)
        ADC # 2                         ;    start from field 1
        TAX
        LDA ACCU + 1
        ADC # 0
        LDY @sz    
        DEY                             ;    Y := size(ACCU) - 1

@pr_arg STA @arg + 1                    ;Print all args:
        STX @arg
        STY @count
        LDA # '('                       ;Print left paren
        JSR C64_CHROUT
@loop   LDY # 0                         ;Loop on all args:
        LDA (@arg),Y
        TAX
        INY
        BIT caml_is_block
        BEQ @block
        LDA (@arg),Y
@pr_int CMP # $80                       ; Arg is int, print it
        ROR
        PHA
        TXA
        ROR
        TAY
        PLA
!ifdef caml_basic_rom_overlap {JSR caml_BASROM_on}
        JSR C64_GIVAYF
        JSR C64_FOUT
        JSR C64_STROUT
!ifdef caml_basic_rom_overlap {JSR caml_BASROM_off}
        JMP @next                       ;  then process next arg.
@block  LDA (@arg),Y                    ; Arg is a block, check if string
        STA @out + 1
        STX @out
        JSR @get_tag_size
        CMP # String_tag
        BNE @under
        LDA # $22                       ; String: print quote char;
        JSR C64_CHROUT
        LDY # 0
@pr_str LDA (@out),Y                    ;  Print the PETSCII string @out until a
        BEQ +                           ;  0 is encountered. Valid strings can
        JSR C64_CHROUT                  ;  contain '\000' and non-printable
        INY                             ;  characters, which should be escaped;
        BNE @pr_str                     ;  here, however, we keep things short;
        INC @out + 1
        BNE @pr_str
+       LDA # $22                       ;  Print quote char;
        JSR C64_CHROUT
        JMP @next                       ;  Process next arg.
@under  LDA # $A4                       ; Not string: print underscore
        JSR C64_CHROUT                  ;  then process next arg.
@next   DEC @count
        BEQ @endl
        LDA # ','                       ; Print comma
        JSR C64_CHROUT
        INC @arg
        INC @arg
        BNE @loop
        INC @arg + 1
        BNE @loop                       ;BNE=JMP, continue loop
@endl   LDA # ')'                       ;Print right paren
        JSR C64_CHROUT
        JMP caml_end                    ;Exit

        ;; A := tag(A:X), X := size(A:X), Y := $FE
@get_tag_size
        STA @tmp + 1
        DEC @tmp + 1
        STX @tmp
        LDY # -1
        LDA (@tmp),Y
        TAX
        DEY
        LDA (@tmp),Y
        RTS

        ;; A:X := Field(ACCU,0), Y := 1
@get_ACCU_field0
        LDA ACCU + 1
        LDX ACCU
        LDY # 0
        ;; A:X := Field(A:X, Y/2), Y += 1
@get_field
        STA @tmp + 1
        STX @tmp
        LDA (@tmp),Y
        TAX
        INY
        LDA (@tmp),Y
        RTS

        ;; Convert to PETSCII and print the exn name in A:X
@pr_exn STX @tmp
        STA @tmp + 1
        LDY # 0
-       LDA (@tmp),Y                    ;Loop on all chars, A := @tmp[Y]
        BEQ +++                         ;Exit if null.
        CMP # $5F                       ;Underscore conversion.
        BNE +
        LDA # $A4
        BNE ++
+       CMP # $61                       ;Lowercase letters conversion.
        BCC +
        SBC # $20
        BNE ++
+       CMP # $41                       ;Uppercase letters conversion.
        BCC ++
        EOR # $80
++      JSR C64_CHROUT                  ;Print converted character.
        INY
        BNE -
        INC @tmp + 1
        BNE -                           ;Continue loop until A=0.
+++     RTS

caml_loader_end
} ;zone caml_LOADER
