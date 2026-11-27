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
;;      MEMORY MANAGEMENT - HEAP ALLOCATION AND GARBAGE COLLECTION
;;      MARK-AND-COMPACT GARBAGE COLLECTOR
;; -----------------------------------------------------------------------------

!ifndef caml_gc_mark_and_compact !eof

;; HEAP LAYOUT (one single space, blocks allocated by bumping HEAP)
;;
;;   .DS                                                              .DE
;;   |<------------------------ data --------------------------------->|
;;   | blocks .......................................... | free        |
;;   '--------------------------------------------------------------'
;;   .BAMS = .DE  [ BAM: 1 bit per 2-byte word of data, + 1 spare byte ] .BAME
;;   .TBL         [ one 16-bit entry per .CHUNK bytes of data          ]
;;
;; BAM (block allocation map), built by the mark phase: the bit of a word is
;; 1 iff the word is a FIELD of a live block; the header words (and every dead
;; word) are 0. Bit 7 of a BAM byte is the lowest address. Since a block has at
;; least 1 field, every run of 1s is preceded by exactly one 0 that is the
;; header of the first live block of the run, thus
;;
;;     live words up to A, included = (# of 1s up to A) + (# of 0->1 steps
;;                                    up to A)
;;
;; is computed from the BAM alone (see .newaddr), and the new address of the
;; block pointed to by A is DS + 2 * (that number - 1). The headers are never
;; modified, nor is any pointer stored in the heap during marking apart from
;; the inverted ones, which are restored.
;;
;; INFIX blocks. A pointer to a closure can point into the middle of it (an
;; infix header followed by the code pointer of a mutually recursive function;
;; Infix_tag, size = distance in words from the start of the closure). The
;; whole closure is marked; when it is entered through an infix pointer the BAM
;; bit of the infix header word is cleared, to remember through which infix
;; the closure was entered (the inverted pointer must be restored to the
;; original value). Fields are never pointers to header words, so this is
;; safe. In the live-word count the cleared bit is counted as a live word by
;; the 0->1 rule.
;;
;; PHASES
;;  1. MARK     Deutsch-Schorr-Waite pointer reversal, with no stack: while
;;              descending the pointer in the parent field is replaced by the
;;              address of the parent's parent field (chain PP). Fields are
;;              scanned from the last to the first one, so that the end of the
;;              block is recognised by its header's 0 bit in the BAM.
;;  2. TABLE    .TBL[k] := # of live words before chunk k (.CHUNK bytes),
;;              bit 15 = last BAM bit before the chunk.
;;  3. UPDATE   every pointer into the heap (roots, global data, live blocks)
;;              is replaced by .newaddr(pointer).
;;  4. SLIDE    live blocks are moved down, in address order.
;;
;; MARKING PROTOCOL (pointer reversal). While a block is being scanned, FP is
;; the field under examination, BP/X its BAM bit, PP the chain of the "parent
;; fields" (the fields through which we descended). When a field points to an
;; unmarked child, the field is overwritten with the old PP (so it now points
;; to the parent's parent field), PP := that field and the child is scanned.
;; When the child's header (a 0 bit) is reached the child is done: the original
;; pointer is restored in the field PP designates, PP is popped and the scan of
;; the parent resumes from the field before it. The root has no parent (PP=0).
;;
;; ZERO PAGE: GC .. GC+8, BLK, HEAP and $47-$48 are used as scratch (HEAP is
;; restored at the end); TMP is NOT touched.

!zone caml_MEMORY {
caml_memory

.hs     = (caml_glob_end + 15) AND $FFF0        ;heap start, multiple of 16
.L      = caml_stack_start - .hs
.CHUNK  = 32                                    ;bytes of data per table entry
.D      = (((.L * 8) DIV 9) DIV .CHUNK) * .CHUNK
.DS     = .hs                                   ;start of data
.DE     = .hs + .D                              ;end of data + 1
.BAMS   = .DE                                   ;start of BAM
.BAME   = .BAMS + .D / 16 + 1                   ;end of BAM + 1 (+1: sentinel)
.TBL    = (.BAME + 1) AND $FFFE                 ;table (even address)
.TBLE   = .TBL + (.D / .CHUNK) * 2
.K      = .BAMS - .DS / 16                      ;(addr >> 4) + .K = BAM byte

;!info .hs, .L, .CHUNK, .D, .DS, .DE, .BAMS, .BAME, .TBL, .TBLE, .K

!ifdef .TBLE {
  !if .TBLE > caml_stack_start {
    !error "heap too small"
  }
}

;; Scratch zero page
.FP     = GC                                    ;2 by. field pointer (scan)
.BP     = GC + 2                                ;2 by. BAM byte of .FP
.PP     = GC + 4                                ;2 by. inverted-pointer chain
.WP     = GC + 6                                ;2 by. working pointer
.EBP    = BLK                                   ;2 by. BAM byte (work)
.IBP    = $47                                   ;2 by. misc. pointer
.RP     = HEAP                                  ;2 by. root pointer (HEAP saved)

;; Variables (RAM)
.USED   !word .DS               ;(HEAP at the beginning of the collection)
.ASZ    !byte 0                 ;caml_alloc: block size
.ATAG   !byte 0                 ;caml_alloc: block tag
.TAG    !byte 0
.SIZE   !byte 0
.N      !byte 0
.CX     !byte 0
.IX     !byte 0
.BX     !byte 0
.T1     !byte 0
.T2     !byte 0
.T3     !byte 0
.ACC    !word 0
.PREV   !byte 0
.AREAHI !word 0
.BCNT   !byte 0

;; Tables
.BIT    !byte $80, $40, $20, $10, $08, $04, $02, $01    ;bit idx -> mask
.NBIT   !byte $7F, $BF, $DF, $EF, $F7, $FB, $FD, $FE
.MFROM  !byte $FF, $7F, $3F, $1F, $0F, $07, $03, $01    ;bits idx..7
.MTO    !byte $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF    ;bits 0..idx
;; .LV[b] = popcount(b) + # of 0->1 steps in b, as if the bit before b were 0
.LV
!for .b, 0, 255 {
  !set .c = 0
  !set .p = 0
  !for .i, 0, 7 {
    !set .bit = (.b >> (7 - .i)) AND 1
    !set .c = .c + .bit
    !if .bit = 1 {
      !if .p = 0 {
        !set .c = .c + 1
      }
    }
    !set .p = .bit
  }
  !byte .c
}

;; -----------------------------------------------------------------------------
;;      INITIALIZATION AND ALLOCATION
;; -----------------------------------------------------------------------------

        ;; Initialize the heap pointer; called by caml_init.
caml_heap_init
        ;; A previous run left in the global table pointers to its heap, that
        ;; the GC would take as roots: reset them to Val_unit.
        LDA # <caml_glob_table
        STA TMP
        LDA # >caml_glob_table
        STA TMP + 1
        LDY # 0
@next_caml_heap_init
        LDA TMP                         ;end of table?
        CMP # <caml_glob_data
        LDA TMP + 1
        SBC # >caml_glob_data
        BCS @done_caml_heap_init
        LDA (TMP),Y
        TAX
        LSR
        BCS @skip_caml_heap_init        ;odd: integer
        INY
        LDA (TMP),Y
        DEY
        CPX # <caml_glob_end            ;address >= caml_glob_end?
        SBC # >caml_glob_end
        BCC @skip_caml_heap_init
        LDA # <Val_unit                 ;yes (heap pointer): reset it
        STA (TMP),Y
        INY
        LDA # >Val_unit
        STA (TMP),Y
        DEY
@skip_caml_heap_init
        INC TMP
        INC TMP
        BNE @next_caml_heap_init
        INC TMP + 1
        BNE @next_caml_heap_init        ;BNE = JMP
@done_caml_heap_init
        LDA # <.DS
        STA HEAP
        LDA # >.DS
        STA HEAP + 1
        RTS

        ;; Allocate a block (NOT FOR ATOMS!); params: A=tag, X=size>0.
        ;; Return BLK=address of field 0, A=X=size, Y=0; or raise
        ;; Out_of_memory. C=1 iff a GC occurred.
        ;; Bump allocation: when the heap is full the old HEAP is restored,
        ;; the GC runs once and the allocation is retried; a second failure
        ;; raises Out_of_memory. The "GC already done" flag travels in C on
        ;; the hw stack.
caml_alloc
        CLC
        STX .ASZ
        STA .ATAG
@retry_caml_alloc
        PHP                             ;save the GC-done flag (C)
        LDA HEAP
        STA BLK
        LDA HEAP + 1
        STA BLK + 1
        INX                             ;HEAP := HEAP + 2 * (size + 1)
        BNE +                           ;size + 1 = 256 words: 512 bytes
        INC HEAP + 1
        INC HEAP + 1
        BNE @limits_caml_alloc
+       TXA
        ASL
        BCC +
        INC HEAP + 1
        CLC
+       ADC HEAP
        STA HEAP
        BCC @limits_caml_alloc
        INC HEAP + 1
        ;; If there's enough room, write tag and size into the header and exit
@limits_caml_alloc
        LDA # <.DE
        CMP HEAP
        LDA # >.DE
        SBC HEAP + 1                    ;.DE < HEAP?
        BCC @gctry_caml_alloc           ;yes: try a garbage collection
        LDA .ATAG                       ;room: write the header (tag, size)
        LDY # 0
        STA (BLK),Y
        INC BLK
        LDA .ASZ
        STA (BLK),Y
        INC BLK
        BNE +
        INC BLK + 1                     ;BLK = address of field 0
+       PLP                             ;  pop GC-done flag
        TAX                             ;  RETURN A=X=size, BLK=addr,
        RTS                             ;    C=GC-done flag.
        ;; else try a GC or, if already done, raise OOM
@gctry_caml_alloc
        LDA BLK                         ;undo the HEAP increment: BLK is
        STA HEAP                        ; the old value, i.e. the true end
        LDA BLK + 1                     ; of the used heap
        STA HEAP + 1
        PLP                             ;get GC-done flag from HW stack
        BCS @oom_caml_alloc             ;check if GC done yet:
        LDY # 0                         ;(callers may pass Y<>0, e.g. CLOSURE)
        JSR .caml_garbage_collect       ;no: call the garbage collector
        LDX .ASZ                        ; X := size
        SEC                             ; set GC-done flag
        BCS @retry_caml_alloc           ; then try to allocate again.
@oom_caml_alloc
        +caml_raise Out_of_memory       ;yes: raise OOM.

;; -----------------------------------------------------------------------------
;;      GARBAGE COLLECTION
;; -----------------------------------------------------------------------------

        ;; Entry point of the collector, called by caml_alloc when the heap
        ;; is full. USED := the true end of the heap; then the four phases
        ;; (see above).
.caml_garbage_collect
        LDA HEAP
        STA .USED
        LDA HEAP + 1
        STA .USED + 1
        JSR .mark_all
        JSR .build_table
        JSR .update_all
        JSR .slide                      ;HEAP := new end of the used heap
        RTS

;; -------------------------------- UTILITIES ----------------------------------

        ;; Map the heap address in WP to its BAM bit: EBP = address of the
        ;; BAM byte, X = bit index in it (0 = MSB = lowest address). BAM byte
        ;; = (addr >> 4) + K, bit = (addr >> 1) AND 7. Clobbers A, T1, T2; Y
        ;; unchanged.
.bamloc LDA .WP
        LSR
        AND # 7
        TAX
        LDA .WP + 1
        LSR
        LSR
        LSR
        LSR
        STA .T2
        LDA .WP + 1
        ASL
        ASL
        ASL
        ASL
        STA .T1
        LDA .WP
        LSR
        LSR
        LSR
        LSR
        ORA .T1
        CLC
        ADC # <.K
        STA .EBP
        LDA .T2
        ADC # >.K
        STA .EBP + 1
        RTS

        ;; Set to 1 the N (1..255) consecutive BAM bits starting at (EBP, X):
        ;; partial first byte, whole middle bytes, partial last byte. Return
        ;; EBP, X = location of the last bit set, Y = 0. Clobbers A, T1-T3.
.mark_range
        STX .T1
        LDA .N
        SEC
        SBC # 1
        CLC
        ADC .T1
        STA .T2
        ROR
        LSR
        LSR
        STA .T3
        LDA .T2
        AND # 7
        STA .T2
        LDY # 0
        LDA .T3
        BNE @multi_mark_range
        LDX .T1                         ;all in one byte
        LDA .MFROM,X
        LDX .T2
        AND .MTO,X
        ORA (.EBP),Y
        STA (.EBP),Y
        RTS                             ;X = last bit index
@multi_mark_range
        LDX .T1                         ;first byte
        LDA .MFROM,X
        ORA (.EBP),Y
        STA (.EBP),Y
        DEC .T3
        BEQ @last_mark_range
        LDA # $FF                       ;middle bytes
-       INC .EBP
        BNE +
        INC .EBP + 1
+       STA (.EBP),Y
        DEC .T3
        BNE -
@last_mark_range
        INC .EBP                        ;last byte
        BNE +
        INC .EBP + 1
+       LDX .T2
        LDA .MTO,X
        ORA (.EBP),Y
        STA (.EBP),Y
        RTS

        ;; Range test of the pointer in .w: branch to .out unless DS <= .w < DE.
!macro .inheap .w, .ds, .de, .out {
        LDA .w
        CMP # <.ds
        LDA .w + 1
        SBC # >.ds
        BCC .out
        LDA .w
        CMP # <.de
        LDA .w + 1
        SBC # >.de
        BCS .out
}

;; ----------------------------------- MARK ------------------------------------

        ;; Phase 1. Clear the BAM, then mark everything reachable from the
        ;; roots: ACCU, ENV, the live part of the stack, the global table and
        ;; the fields of the global data blocks (outside the heap, never
        ;; moved).
.mark_all
        ;; clear the BAM
        LDA # <.BAMS
        STA .FP
        LDA # >.BAMS
        STA .FP + 1
        LDY # 0
        TYA
        LDX # >(.BAME - .BAMS)          ;whole pages
        BEQ @part_mark_all
-       STA (.FP),Y
        INY
        BNE -
        INC .FP + 1
        DEX
        BNE -
@part_mark_all
        CPY # <(.BAME - .BAMS)
        BEQ @cleared_mark_all
-       STA (.FP),Y
        INY
        CPY # <(.BAME - .BAMS)
        BNE -
@cleared_mark_all
        ;; roots: ACCU, ENV
        LDA # ACCU
        STA .RP
        LDA # 0
        STA .RP + 1
        JSR .rootwd
        LDA # ENV
        STA .RP
        JSR .rootwd
        ;; stack: [SP, caml_stack_end)
        LDA SP
        STA .RP
        LDA SP + 1
        STA .RP + 1
        LDA # <caml_stack_end
        STA .AREAHI
        LDA # >caml_stack_end
        STA .AREAHI + 1
        JSR .rootarea
        ;; global table: [caml_glob_table, caml_glob_data)
        LDA # <caml_glob_table
        STA .RP
        LDA # >caml_glob_table
        STA .RP + 1
        LDA # <caml_glob_data
        STA .AREAHI
        LDA # >caml_glob_data
        STA .AREAHI + 1
        JSR .rootarea
        ;; global data: blocks [caml_glob_data, caml_glob_end)
        LDA # <caml_glob_data
        STA .RP
        LDA # >caml_glob_data
        STA .RP + 1
@gblk_mark_all
        LDA .RP                         ;end of global data?
        CMP # <caml_glob_end
        LDA .RP + 1
        SBC # >caml_glob_end
        BCS @gdone_mark_all
        LDY # 0
        LDA (.RP),Y
        TAX
        INY
        LDA (.RP),Y
        STA .N
        INC .RP
        INC .RP
        BNE +
        INC .RP + 1
+       LDA .N                          ;AREAHI := end of the block's fields
        ASL
        STA .AREAHI
        LDA # 0
        ROL
        STA .AREAHI + 1
        LDA .AREAHI
        CLC
        ADC .RP
        STA .AREAHI
        LDA .AREAHI + 1
        ADC .RP + 1
        STA .AREAHI + 1
        CPX # No_scan_tag
        BCS @gskip_mark_all
        JSR .rootarea                   ;RP := AREAHI
        JMP @gblk_mark_all
@gskip_mark_all
        LDA .AREAHI
        STA .RP
        LDA .AREAHI + 1
        STA .RP + 1
        JMP @gblk_mark_all
@gdone_mark_all
        RTS

        ;; Scan the words from RP to AREAHI - 1; on return RP = AREAHI.
.rootarea
-       LDA .RP
        CMP .AREAHI
        LDA .RP + 1
        SBC .AREAHI + 1
        BCS @end_rootarea
        JSR .rootwd
        INC .RP
        INC .RP
        BNE -
        INC .RP + 1
        BNE -                           ;(always)
@end_rootarea
        RTS

        ;; The word at (RP) is a root: mark all that is reachable from it.
.rootwd LDY # 0
        LDA (.RP),Y
        AND # 1
        BNE @ret_rootwd                 ;integer
        LDA (.RP),Y
        STA .WP
        INY
        LDA (.RP),Y
        STA .WP + 1
        DEY
        +.inheap .WP, .DS, .DE, @ret_rootwd
        JMP .traverse                   ;(tail call)
@ret_rootwd
        RTS

        ;; Mark everything reachable from the heap pointer in WP:
        ;; depth-first, with pointer reversal instead of a stack (see MARKING
        ;; PROTOCOL).
.traverse
        JSR .enter
        BCS +
        RTS
+       LDA # 0
        STA .PP                         ;no parent
        STA .PP + 1
        LDA .WP
        STA .FP
        LDA .WP + 1
        STA .FP + 1
        LDA .EBP
        STA .BP
        LDA .EBP + 1
        STA .BP + 1
        ;; FALLTHROUGH .scan (X = bit index)
        ;; Scan loop, from the last field to the first. A 0 bit means we have
        ;; gone past the first field onto the block's header: the block is
        ;; finished. Otherwise, if the field is a pointer to an unmarked
        ;; block of the heap, descend into it.
.scan   LDY # 0
        LDA (.BP),Y
        AND .BIT,X
        BEQ @hdr_scan                   ;0 bit: header of the block
        LDA (.FP),Y
        LSR
        BCS @next_scan                  ;integer
        LDA (.FP),Y
        STA .WP
        INY
        LDA (.FP),Y
        STA .WP + 1
        +.inheap .WP, .DS, .DE, @next_scan
        STX .BX
        JSR .enter
        BCC @back_scan                  ;leaf or already marked
        ;; Descend: the field takes the old PP (it now points to the parent's
        ;; parent field), PP := this field, and the scan continues from the
        ;; child's last field.
        LDY # 0
        LDA .PP
        STA (.FP),Y
        INY
        LDA .PP + 1
        STA (.FP),Y
        LDA .FP
        STA .PP
        LDA .FP + 1
        STA .PP + 1
        LDA .WP
        STA .FP
        LDA .WP + 1
        STA .FP + 1
        LDA .EBP
        STA .BP
        LDA .EBP + 1
        STA .BP + 1
        JMP .scan
@back_scan
        LDX .BX
@next_scan
        LDA .FP                         ;go to the previous field
        SEC
        SBC # 2
        STA .FP
        BCS +
        DEC .FP + 1
+       DEX
        BPL .scan
        LDX # 7
        LDA .BP
        BNE +
        DEC .BP + 1
+       DEC .BP
        JMP .scan
        ;; Bit 0: FP is the header of the finished block, or the header of
        ;; the infix through which a closure was entered (skipped: it is not
        ;; a field).
@hdr_scan
        LDA (.FP),Y
        CMP # Infix_tag
        BEQ @next_scan
        STA .TAG
        LDA .FP                         ;WP := pointer to the finished block
        CLC
        ADC # 2
        STA .WP
        LDA .FP + 1
        ADC # 0
        STA .WP + 1
        LDA .TAG
        CMP # Closure_tag
        BNE @up_scan
        JSR .findinfix                  ;closure: WP := infix pointer, if any
@up_scan
        LDA .PP                         ;no parent: done
        ORA .PP + 1
        BNE @ascend_scan
        RTS
        ;; Ascend: pop PP, put the original pointer back in the parent field
        ;; and resume the scan of the parent from the field before it.
@ascend_scan
        LDA .PP
        STA .FP
        LDA .PP + 1
        STA .FP + 1
        LDY # 0
        LDA (.FP),Y
        STA .PP
        LDA .WP
        STA (.FP),Y
        INY
        LDA (.FP),Y
        STA .PP + 1
        LDA .WP + 1
        STA (.FP),Y
        LDA .FP
        SEC
        SBC # 2
        STA .FP
        STA .WP
        LDA .FP + 1
        SBC # 0
        STA .FP + 1
        STA .WP + 1
        JSR .bamloc
        LDA .EBP
        STA .BP
        LDA .EBP + 1
        STA .BP + 1
        JMP .scan

        ;; End of a closure: if it was entered through an infix, the BAM bit
        ;; of that infix header was cleared on entry. Find it (the only 0
        ;; among the fields) and set WP to the infix pointer (address of the
        ;; code pointer after the header), so that the parent field gets its
        ;; original value back. No 0 bit: the closure was entered directly
        ;; and WP is unchanged.
.findinfix
        LDA .BP
        STA .EBP
        LDA .BP + 1
        STA .EBP + 1
        INX
        CPX # 8
        BNE +
        LDX # 0
        INC .EBP
        BNE +
        INC .EBP + 1
+       LDY # 1
        LDA (.FP),Y
        STA .SIZE
        STA .N
        LDY # 0
-       LDA (.EBP),Y
        AND .BIT,X
        BEQ @found_findinfix
        INX
        CPX # 8
        BNE +
        LDX # 0
        INC .EBP
        BNE +
        INC .EBP + 1
+       DEC .N
        BNE -
        RTS                             ;not found: entered directly
@found_findinfix
        LDA .SIZE
        SEC
        SBC .N
        CLC
        ADC # 1
        ASL
        STA .T1
        LDA # 0
        ROL
        STA .T2
        LDA .WP
        CLC
        ADC .T1
        STA .WP
        LDA .WP + 1
        ADC .T2
        STA .WP + 1
        RTS

        ;; Visit the block pointed to by WP. Already marked: nothing to do.
        ;; Otherwise mark all its fields in the BAM (the header bit stays 0).
        ;; A pointer to an infix block marks the whole enclosing closure and
        ;; clears the bit of the infix header (see INFIX). Return C=1 if the
        ;; fields have to be scanned (WP = last field, (EBP, X) = its BAM
        ;; bit), C=0 for already marked or pointer-free (tag >= No_scan_tag)
        ;; blocks. FP, BP, PP are untouched.
.enter  JSR .bamloc
        STX .CX
        LDY # 0
        LDA (.EBP),Y
        AND .BIT,X
        BNE @no_enter                   ;already marked
        DEC .WP + 1                     ;read the header
        LDY # $FE
        LDA (.WP),Y
        STA .TAG
        INY
        LDA (.WP),Y
        STA .SIZE
        INC .WP + 1
        LDY # 0
        LDA .TAG
        CMP # Infix_tag
        BEQ @infix_enter
        LDA .SIZE
        STA .N
        JSR .mark_range
        LDA .TAG
        CMP # No_scan_tag
        BCS @no_enter                   ;no fields to scan
@last_enter
        LDA .SIZE
        SEC
        SBC # 1
        ASL
        BCC +
        INC .WP + 1
        CLC
+       ADC .WP
        STA .WP
        BCC +
        INC .WP + 1
+       SEC
        RTS
@no_enter
        CLC
        RTS
        ;; Pointer to an infix block: its size is the distance from the start
        ;; of the closure. Find the closure, mark it all, clear the infix
        ;; header's bit.
@infix_enter
        LDA .EBP
        STA .IBP
        LDA .EBP + 1
        STA .IBP + 1
        LDX .CX
        STX .IX
        LDA .SIZE
        ASL
        STA .T1
        LDA # 0
        ROL
        STA .T2
        LDA .WP
        SEC
        SBC .T1
        STA .WP
        LDA .WP + 1
        SBC .T2
        STA .WP + 1
        DEC .WP + 1
        LDY # $FF
        LDA (.WP),Y
        STA .SIZE
        INC .WP + 1
        LDY # 0
        JSR .bamloc
        LDA .SIZE
        STA .N
        JSR .mark_range
        STX .CX
        LDX .IX
        BNE +
        LDA .IBP
        BNE ++
        DEC .IBP + 1
++      DEC .IBP
        LDX # 8
+       DEX
        LDA .NBIT,X
        LDY # 0
        AND (.IBP),Y
        STA (.IBP),Y
        LDX .CX
        JMP @last_enter

;; ---------------------------------- TABLE ------------------------------------

        ;; Phase 2. One pass over the BAM. For each chunk (2 BAM bytes =
        ;; .CHUNK bytes of data) store the number of live words before it;
        ;; bit 15 holds the last BAM bit before the chunk. Per byte:
        ;; .LV[byte], minus 1 when a run of 1s continues across the byte
        ;; boundary (the 0->1 step is not there). Table end: .TBLE.
.build_table
        LDA # <.BAMS
        STA .BP
        LDA # >.BAMS
        STA .BP + 1
        LDA # <.TBL
        STA .IBP
        LDA # >.TBL
        STA .IBP + 1
        LDA # 0
        STA .ACC
        STA .ACC + 1
        STA .PREV
        STA .BCNT
        LDY # 0
@loop_build_table
        LDA .BCNT                       ;start of a chunk: store its entry
        BNE @byte_build_table
        LDA .ACC
        STA (.IBP),Y
        INY
        LDA .ACC + 1
        ORA .PREV
        STA (.IBP),Y
        DEY
        INC .IBP
        BNE +
        INC .IBP + 1
+       INC .IBP
        BNE +
        INC .IBP + 1
+
@byte_build_table
        LDA (.BP),Y
        BEQ @zero_build_table
        STA .T3
        TAX
        LDA .LV,X
        CLC
        ADC .ACC
        STA .ACC
        BCC +
        INC .ACC + 1
+       LDA .T3
        AND .PREV                       ;run of 1s continues across bytes:
        BPL +                           ;no 0->1 step, undo the +1 of .LV
        LDA .ACC
        BNE ++
        DEC .ACC + 1
++      DEC .ACC
+       LDA .T3
        LSR
        LDA # 0
        ROR
        STA .PREV
        JMP @adv_build_table
@zero_build_table
        STA .PREV
@adv_build_table
        LDA .BCNT
        EOR # 1
        STA .BCNT
        INC .BP
        BNE +
        INC .BP + 1
+       LDA .BP                         ;end of the BAM (sentinel byte
        CMP # <(.BAME - 1)              ; excluded)?
        BNE @loop_build_table
        LDA .BP + 1
        CMP # >(.BAME - 1)
        BNE @loop_build_table
        RTS

        ;; New address of the live block pointed to by WP, after the slide:
        ;; DS + 2 * (live words up to the pointer's own bit - 1). The count
        ;; starts from the chunk's table entry and adds the (at most 2) BAM
        ;; bytes up to the target. Clobbers WP, EBP, IBP, A, X, Y, T1-T3,
        ;; ACC, PREV.
.newaddr
        LDA .WP
        SEC
        SBC # <.DS
        STA .T1
        LDA .WP + 1
        SBC # >.DS
        STA .T2
        LDA .T1
        LSR
        LSR
        LSR
        LSR
        STA .T3
        LDA .T2
        ASL
        ASL
        ASL
        ASL
        ORA .T3
        STA .WP
        LDA .T2
        LSR
        LSR
        LSR
        LSR
        STA .WP + 1
        LDA .T1
        LSR
        AND # 7
        STA .T1
        LDA .WP
        CLC
        ADC # <.BAMS
        STA .EBP
        LDA .WP + 1
        ADC # >.BAMS
        STA .EBP + 1
        LDA .WP
        AND # $FE
        CLC
        ADC # <.TBL
        STA .IBP
        LDA .WP + 1
        ADC # >.TBL
        STA .IBP + 1
        LDY # 0
        LDA (.IBP),Y
        STA .ACC
        INY
        LDA (.IBP),Y
        TAX
        AND # $7F
        STA .ACC + 1
        TXA
        AND # $80
        STA .PREV
        LDY # 0
        LDA .WP                         ;odd n: the chunk's first byte
        LSR                             ;comes before the target one
        BCC @target_newaddr
        LDA .EBP
        BNE +
        DEC .EBP + 1
+       DEC .EBP
        LDA (.EBP),Y
        JSR .addbyte
        INC .EBP
        BNE @target_newaddr
        INC .EBP + 1
@target_newaddr
        LDX .T1                         ;target byte, bits up to the target
        LDA (.EBP),Y
        AND .MTO,X
        JSR .addbyte
        ;; WP := (DS - 2) + 2 * ACC   (-2 = -1 word: the target's own bit)
        ;; (-2: the target's own word is counted but must not be)
        LDA .ACC
        ASL
        STA .WP
        LDA .ACC + 1
        ROL
        STA .WP + 1
        LDA .WP
        CLC
        ADC # <(.DS - 2)
        STA .WP
        LDA .WP + 1
        ADC # >(.DS - 2)
        STA .WP + 1
        RTS

        ;; ACC += live words in byte A, given PREV (bit before: $80 if 1);
        ;; then PREV := last bit of A. Preserves Y.
.addbyte
        TAX
        BEQ @zero_addbyte
        LDA .LV,X
        CLC
        ADC .ACC
        STA .ACC
        BCC +
        INC .ACC + 1
+       TXA
        AND .PREV
        BPL +
        LDA .ACC
        BNE ++
        DEC .ACC + 1
++      DEC .ACC
+       TXA
        LSR
        LDA # 0
        ROR
        STA .PREV
        RTS
@zero_addbyte
        STX .PREV
        RTS

;; ---------------------------------- UPDATE -----------------------------------

        ;; Phase 3. Rewrite every pointer into the heap with .newaddr: the
        ;; same roots as the mark phase, then the fields of the live heap
        ;; blocks. Global data are updated in place (they never move).
.update_all
        ;; roots: ACCU, ENV
        LDA # ACCU
        STA .RP
        LDA # 0
        STA .RP + 1
        JSR .updwd
        LDA # ENV
        STA .RP
        JSR .updwd
        ;; stack
        LDA SP
        STA .RP
        LDA SP + 1
        STA .RP + 1
        LDA # <caml_stack_end
        STA .AREAHI
        LDA # >caml_stack_end
        STA .AREAHI + 1
        JSR .updarea
        ;; global table
        LDA # <caml_glob_table
        STA .RP
        LDA # >caml_glob_table
        STA .RP + 1
        LDA # <caml_glob_data
        STA .AREAHI
        LDA # >caml_glob_data
        STA .AREAHI + 1
        JSR .updarea
        ;; global data
        LDA # <caml_glob_data
        STA .RP
        LDA # >caml_glob_data
        STA .RP + 1
@gblk_update_all
        LDA .RP
        CMP # <caml_glob_end
        LDA .RP + 1
        SBC # >caml_glob_end
        BCS @gdone_update_all
        LDY # 0
        LDA (.RP),Y
        TAX
        INY
        LDA (.RP),Y
        STA .N
        INC .RP
        INC .RP
        BNE +
        INC .RP + 1
+       LDA .N
        ASL
        STA .AREAHI
        LDA # 0
        ROL
        STA .AREAHI + 1
        LDA .AREAHI
        CLC
        ADC .RP
        STA .AREAHI
        LDA .AREAHI + 1
        ADC .RP + 1
        STA .AREAHI + 1
        CPX # No_scan_tag
        BCS @gskip_update_all
        JSR .updarea
        JMP @gblk_update_all
@gskip_update_all
        LDA .AREAHI
        STA .RP
        LDA .AREAHI + 1
        STA .RP + 1
        JMP @gblk_update_all
@gdone_update_all
        JMP .upd_heap                   ;live blocks of the heap

        ;; Update the pointers in the words [RP, AREAHI).
.updarea
-       LDA .RP
        CMP .AREAHI
        LDA .RP + 1
        SBC .AREAHI + 1
        BCS @end_updarea
        JSR .updwd
        INC .RP
        INC .RP
        BNE -
        INC .RP + 1
        BNE -
@end_updarea
        RTS

        ;; Update the word at (RP) if it is a pointer into the heap. Keeps
        ;; RP.
.updwd  LDY # 0
        LDA (.RP),Y
        AND # 1
        BNE @ret_updwd
        LDA (.RP),Y
        STA .WP
        INY
        LDA (.RP),Y
        STA .WP + 1
        +.inheap .WP, .DS, .DE, @ret_updwd
        JSR .newaddr
        LDY # 0
        LDA .WP
        STA (.RP),Y
        INY
        LDA .WP + 1
        STA (.RP),Y
@ret_updwd
        RTS

        ;; Move (BP, X, PP) to the next 1 bit at or after the current one,
        ;; i.e. to field 0 of the next live block (PP = address of the bit's
        ;; word). Dead areas are skipped a BAM byte at a time. A sentinel 1
        ;; bit at USED ends the search: C=1 when reached. Y=0.
.find1  LDY # 0
        LDA (.BP),Y
        AND .MFROM,X
        BNE @got_find1
        ;; no 1 in the rest of this byte: next byte
        TXA
        EOR # 7
        CLC
        ADC # 1
        ASL
        CLC
        ADC .PP
        STA .PP
        BCC +
        INC .PP + 1
+       LDX # 0
        INC .BP
        BNE @bytes_find1
        INC .BP + 1
@bytes_find1
        LDA (.BP),Y
        BNE @byte_find1
        LDA .PP
        CLC
        ADC # 16
        STA .PP
        BCC +
        INC .PP + 1
+       INC .BP
        BNE @bytes_find1
        INC .BP + 1
        BNE @bytes_find1
@byte_find1
        ;; A = byte (not 0), X = 0: find the first 1 bit
        BMI @got2_find1
-       INX
        ASL
        BPL -
        TXA
        ASL
        CLC
        ADC .PP
        STA .PP
        BCC @got2_find1
        INC .PP + 1
@got2_find1
        LDA .PP                         ;sentinel reached?
        CMP .USED
        BNE @ok_find1
        LDA .PP + 1
        CMP .USED + 1
        BNE @ok_find1
        SEC
        RTS
@ok_find1
        CLC
        RTS
@got_find1
        ;; a 1 bit at or after X in this byte: find it
        STA .T1
        LDA .BIT,X
-       BIT .T1
        BNE @got2_find1
        INX
        INC .PP
        INC .PP
        BNE +
        INC .PP + 1
+       LSR
        JMP -

        ;; Advance (BP, X, PP) by A words (A = 1..255): jump over a block's
        ;; fields.
.advance
        STA .T1
        ASL
        STA .T2
        LDA # 0
        ROL
        TAY
        LDA .PP
        CLC
        ADC .T2
        STA .PP
        TYA
        ADC .PP + 1
        STA .PP + 1
        TXA
        CLC
        ADC .T1
        PHP
        TAX
        LSR
        LSR
        LSR
        STA .T1
        PLP
        BCC +
        LDA .T1
        ADC # 31
        STA .T1
+       TXA
        AND # 7
        TAX
        LDA .BP
        CLC
        ADC .T1
        STA .BP
        BCC +
        INC .BP + 1
+       LDY # 0
        RTS

        ;; Walk the live blocks in address order and update the pointers in
        ;; their fields; pointer-free blocks (tag >= No_scan_tag) are
        ;; skipped.
.upd_heap
        LDA # <.BAMS
        STA .BP
        LDA # >.BAMS
        STA .BP + 1
        LDA # <.DS
        STA .PP
        LDA # >.DS
        STA .PP + 1
        LDX # 0
        JSR .set_sentinel
@next_upd_heap
        JSR .find1
        BCC @blk_upd_heap
        RTS
        ;; PP = field(0) of a live block; header at PP-2
@blk_upd_heap
        LDA .PP
        STA .FP
        LDA .PP + 1
        STA .FP + 1
        DEC .FP + 1
        LDY # $FE
        LDA (.FP),Y
        STA .TAG
        INY
        LDA (.FP),Y
        STA .SIZE
        STX .BX
        LDA .TAG
        CMP # No_scan_tag
        BCS @skip_upd_heap
        ;; scan SIZE fields at PP
        LDA .PP
        STA .RP
        LDA .PP + 1
        STA .RP + 1
        LDA .SIZE
        ASL
        STA .AREAHI
        LDA # 0
        ROL
        STA .AREAHI + 1
        LDA .AREAHI
        CLC
        ADC .RP
        STA .AREAHI
        LDA .AREAHI + 1
        ADC .RP + 1
        STA .AREAHI + 1
        JSR .updarea                    ;(preserves BP, PP, BX)
@skip_upd_heap
        LDX .BX
        LDA .SIZE
        JSR .advance
        JMP @next_upd_heap

        ;; Put the sentinel 1 bit at the word at USED.
.set_sentinel
        LDA .USED
        STA .WP
        LDA .USED + 1
        STA .WP + 1
        JSR .bamloc
        LDY # 0
        LDA (.EBP),Y
        ORA .BIT,X
        STA (.EBP),Y
        LDX # 0
        RTS

;; ----------------------------------- SLIDE -----------------------------------

        ;; Phase 4. Slide the live blocks down to DS, in address order (FP =
        ;; destination; blocks already in place are not copied). Headers
        ;; travel with their blocks.
.slide
        LDA # <.BAMS
        STA .BP
        LDA # >.BAMS
        STA .BP + 1
        LDA # <.DS
        STA .PP
        LDA # >.DS
        STA .PP + 1
        LDX # 0
        LDA # <.DS
        STA .FP
        LDA # >.DS
        STA .FP + 1
@next_slide
        JSR .find1
        BCC @go_slide
        JMP @done_slide
@go_slide
        LDA .PP                         ;source: the block's header is at PP - 2
        SEC
        SBC # 2
        STA .WP
        LDA .PP + 1
        SBC # 0
        STA .WP + 1
        LDY # 1
        LDA (.WP),Y
        STA .SIZE
        STX .BX
        ;; bytes to move: n = 2*(size+1)
        LDA .WP
        CMP .FP
        BNE @move_slide
        LDA .WP + 1
        CMP .FP + 1
        BEQ @nomove_slide               ;already in place
@move_slide
        LDA .SIZE
        CLC
        ADC # 1
        PHP
        ASL
        STA .T1
        LDA # 0
        ROL
        STA .T2
        PLP
        BCC +
        INC .T2
        INC .T2
        ;; copy n = 2 * (size + 1) bytes, up to 512: whole pages, then the
        ;; tail
+       LDA .WP
        STA .EBP
        LDA .WP + 1
        STA .EBP + 1
        LDA .FP
        STA .IBP
        LDA .FP + 1
        STA .IBP + 1
        LDY # 0
        LDX .T2
        BEQ @tail_slide
-       LDA (.EBP),Y
        STA (.IBP),Y
        INY
        BNE -
        INC .EBP + 1
        INC .IBP + 1
        DEX
        BNE -
@tail_slide
        CPY .T1
        BEQ @nomove_slide
-       LDA (.EBP),Y
        STA (.IBP),Y
        INY
        CPY .T1
        BNE -
@nomove_slide
        ;; next destination: FP += n
        ;; FP += n = 2*(size+1)
        LDA .SIZE
        CLC
        ADC # 1
        PHP
        ASL
        STA .T1
        LDA # 0
        ROL
        STA .T2
        PLP
        BCC +
        INC .T2
        INC .T2
+       LDA .FP
        CLC
        ADC .T1
        STA .FP
        LDA .FP + 1
        ADC .T2
        STA .FP + 1
        LDX .BX
        LDA .SIZE
        JSR .advance
        JMP @next_slide
@done_slide
        LDA .FP                         ;HEAP := end of the live data
        STA HEAP
        LDA .FP + 1
        STA HEAP + 1
        RTS

        ;; Copy BLK to ACCU.
caml_load_newblk
        LDA BLK + 1
        STA ACCU + 1
        LDA BLK
        STA ACCU
        RTS

        ;; ACCU := Atom(0)
caml_mkatom0
        LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS

caml_shrink_latest_alloc
        ;; Reduce the size of the latest allocated block; new size MUST BE less
        ;; than the original one (no check) and NO GARBAGE COLLECTION occurred
        ;; since the block allocation. Params: X=size>0, Y=0, BLK=address.
        ;; Shrinking is done by updating the new size in the block's header and
        ;; the HEAP pointer. Return: A=X=size, Y=0.
        @SZ2 = GC                       ;2 by - block size in bytes
        DEC BLK + 1                     ;Prepare access to the 'size'
        DEY                             ; byte in block's header
        LDA (BLK),Y                     ;Read original size from header
        STA @SZ2                        ; and save it
        TXA                             ;A := new size
        STA (BLK),Y                     ;Write new size into header
        INC BLK + 1                     ;Restore block pointer
        INY                             ; and Y register
        EOR # $FF                       ;Do an inverse subtraction:
        SEC                             ; A := @SZ2 - A
        ADC @SZ2                        ;    = orig.size - new size
        ASL                             ;Compute 2 * A
        STA @SZ2                        ;Store result, lo byte, in @SZ2
        STY @SZ2 + 1                    ;Set @SZ2 + 1 to 0
        ROL @SZ2 + 1                    ;Store result, MSB, in @SZ2 + 1
        LDA HEAP                        ;Recover unused block bytes by
        SEC                             ; decrementing the heap pointer
        SBC @SZ2                        ; by 2 * (orig.size - new size)
        STA HEAP                        ;Store new value, lo byte
        LDA HEAP + 1
        SBC @SZ2 + 1
        STA HEAP + 1                    ;Store new value, hi byte
        RTS                             ;Return.

caml_memory_end
} ;!zone caml_MEMORY
