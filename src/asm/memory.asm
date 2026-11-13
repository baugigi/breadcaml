;; =============================================================================
;;           MEMORY MANAGEMENT - HEAP ALLOCATION AND GARBAGE COLLECTION
;; =============================================================================
                                                
!zone caml_MEMORY {
caml_memory

.dummy = $1234                          ;dummy operand for self-modifying
                                        ;code (SMC in comments)

;; GLOBALS - Two possible strategies:
;; caml_globals_on_heap = 1
;;   Treat globals as pre-allocated in the heap, setting .heap_start to
;;   caml_glob_data and initializing HEAP at caml_glob_end. During a GC cycle,
;;   globals are moved from one heap semi-space to the other. However, scanning
;;   pointers inside the blocks remains straightforward, as it is already
;;   handled by Cheney's algorithm.
;; caml_globals_on_heap = <undef> -- DEFAULT
;;   Treat globals as statically allocated outside the heap, setting .heap_start
;;   to caml_glob_end. This prevents globals from being copied during every GC
;;   cycle (which can be expensive). On the other hand, the GC must scan every
;;   global and treat each internal pointer as a root. While the GC
;;   implementation becomes more complex, this approach avoids repeatedly moving
;;   globals between the two semi-spaces and frees up G/2 bytes of heap space
;;   (where G is the size of the globals).


!ifndef caml_globals_on_heap {
  .hs = caml_glob_end
} else {
  .hs = caml_glob_data
}
  .heap_start = .hs                     ;start of heap
  .heap_end = caml_stack_start          ;end of heap + 1
  .halfsz = ((.heap_end-.hs) div 4) * 2 ;heap halfsize; ensure it's even

;; VARIABLE DATA
.CUR_START      !word .hs               ;current half
.CUR_END        !word .hs + .halfsz     ;end of current half
.OTH_START      !word .hs + .halfsz     ;other half of the heap
.OTH_END        !word .hs + .halfsz * 2 ;end of other half

        ;; Initialize the heap pointer. Called by caml_init.
caml_heap_init
        LDA # <caml_glob_end
        STA HEAP
        LDA # >caml_glob_end
        STA HEAP + 1
        RTS

        ;; Allocate a block (NOT FOR ATOMS!); params: A=tag, X=size>0
        ;; Return BLK=block's address, A=X=size, Y=0; or raise Out_of_memory
        ;; C = 1 iif a GC occurred
caml_alloc
@SZ     = GC                            ;1 by - block size
@TAG    = GC + 1                        ;1 by - block tag
@SCN    = GC + 2                        ;2 by scanned block
@PTR    = GC + 4                        ;2 by aux pointer
@CNT    = GC + 6                        ;2 by field counter
        ;; C=0: gc not tried yet; C=1: alloc failed, GC done, retrying)
        CLC
        STX @SZ
        STA @TAG
@retry  PHP                             ;save GC-done flag on HW stack
        LDA HEAP
        STA BLK
        LDA HEAP + 1
        STA BLK + 1
        ;; Increment HEAP by the # of bytes to be allocated
        INX                             ;perform HEAP:=HEAP+2*(size+1):
        BNE +                           ;  if size + 1 = 256
        INC HEAP + 1                    ;  then incr. HEAPh
        INC HEAP + 1                    ;    twice (512 bytes)
        BNE @limits                     ;    BNE=JMP
+       TXA                             ;  else
        ASL                             ;    C:A := 2*(size+1),
        BCC +                           ;    if carry set then
        INC HEAP + 1                    ;      add it to HEAPh,
        CLC
+       ADC HEAP                        ;    add 2*(size+1)
        STA HEAP                        ;    to HEAPl
        BCC @limits
        INC HEAP + 1
        ;; If there's enough room, write tag and size into the header and exit
@limits LDA .CUR_END
        CMP HEAP
        LDA .CUR_END + 1
        SBC HEAP + 1                    ;.CUR_END < HEAP?
        BCC @gctry                      ;yes: try a garbage collection
        LDA @TAG                        ;no: write tag and size  
        LDY # 0
        STA (BLK),Y                     ;  header's 1st by. := tag
        INC BLK                         ;  (safe, BLK is even)
        LDA @SZ
        STA (BLK),Y                     ;  header's 2nd by. := size
        INC BLK
        BNE +
        INC BLK + 1                     ;  BLK=address of field(0)
+       PLP                             ;  pop GC-done flag
        TAX                             ;  RETURN A=X=size, BLK=addr,
        RTS                             ;    C=GC-done flag.
        ;; else try a GC or, if already done, raise OOM
@gctry  PLP                             ;get GC-done flag from HW stack
        BCS @oom                        ;check if GC done yet:
        JSR .caml_garbage_collect       ;no: call the garbage collector
        LDX @SZ                         ; X := size
        SEC                             ; set GC-done flag
        BCS @retry                      ; then try to allocate again.
@oom    +caml_raise Out_of_memory       ;yes: raise OOM.


        ;; Stop-and-copy garbage collector, based on C. J. Cheney's algorithm.
.caml_garbage_collect
        
        ;; === STEP 1 ===
        ;; Swap the current half of the heap with the other one.

!macro .swap .a, .b {
        LDA .a
        LDX .b
        STA .b
        STX .a
}
        +.swap .OTH_END, .CUR_END
        +.swap .OTH_START, .CUR_START
        STA HEAP
        +.swap .OTH_END + 1, .CUR_END + 1
        +.swap .OTH_START + 1, .CUR_START + 1
        STA HEAP + 1

        ;; === STEP 2 ===
        ;; Scan all roots, copy each pointed block to the fresh half, update
        ;; each pointer to reference the copy.

        ;; --- Accumulator ---
        LDA ACCU
        BIT caml_is_block               ;Is it a pointer?
        BNE +                           ;Skip if not
        STA @SCN
        LDA ACCU + 1
        STA @SCN + 1
        JSR .caml_gc_fwdptr             ;Get fwd ptr (maybe copy blk)
        BCC +                           ;Skip if not a ptr in heap
        STA ACCU                        ;Save fwd pointer, lo
        STX ACCU + 1                    ;     and hi byte.
+
        ;; --- Environment ---
        LDA ENV
        BIT caml_is_block
        BNE +
        STA @SCN
        LDA ENV + 1
        STA @SCN + 1
        JSR .caml_gc_fwdptr
        BCC +
        STA ENV
        STX ENV + 1
+
        ;; --- Stack ---
        LDA SP                          ;scan only the LIVE part of the stack:
        STA @testlo + 1                 ; [SP, caml_stack_end). The area below
        LDA SP + 1                      ; SP is dead and may hold stale or
        STA @testhi + 1                 ; uninitialized (non-pointer) words.
        LDA # <caml_stack_end
        STA @PTR
        LDA # >caml_stack_end
        STA @PTR + 1
        JSR .caml_gc_scnroots

        ;; --- Global table ---
        LDA # <caml_glob_table
        STA @testlo + 1
        LDA # >caml_glob_table
        STA @testhi + 1
        LDA # <caml_glob_data
        STA @PTR
        LDA # >caml_glob_data
        STA @PTR + 1
        JSR .caml_gc_scnroots

        ;; --- Global data ---
!ifndef caml_globals_on_heap {
        LDA # $38                       ;$38 = SEC opcode
        STA @switch                     ;SMC: see .caml_gc_scnblks
        LDA # <caml_glob_data
        STA @PTR
        LDA # >caml_glob_data
        STA @PTR + 1
        JSR .caml_gc_scnblks
}
        ;; === STEP 3 ===
        ;; Scan all pointers in blocks that have been copied to the fresh half
        ;; of the heap, copy their pointed blocks to the fresh half, update each
        ;; pointer to reference the copy.
        
!ifndef caml_globals_on_heap {
        LDA # $18                       ;$18 = CLC opcode
        STA @switch                     ;SMC: see .caml_gc_scnblks
}
        LDA .CUR_START
        STA @PTR
        LDA .CUR_START + 1
        STA @PTR + 1
        ;; FALLTHROUGH .caml_gc_scnblks

.caml_gc_scnblks
        ;; When caml_globals_on_heap is <undef>, this routine is patched to
        ;; reuse it also for internal pointers in global data.
--      LDA @PTR                        ;Loop: scan blocks

!ifndef caml_globals_on_heap {          ;Patch for globals
@switch CLC                             ;SMC: CLC=heap scan, SEC=glob scan
        BCC @heap
        ;; --- glob ---
        CMP # <caml_glob_end
        LDA @PTR + 1
        SBC # >caml_glob_end
        BCS +++
        BCC @go
}
        ;; --- heap ---
@heap   CMP HEAP
        LDA @PTR + 1
        SBC HEAP + 1
        BCS +++                         ;Exit loop if @PTR reached the end addr
@go     LDA (@PTR),Y                    ; Load tag (Y=0 here)
        TAX                             ; Save it in X
        INC @PTR                        ; Safe, @PTR is even before INC
        LDA (@PTR),Y                    ; Load block size
        INC @PTR                        ; Set @PTR to point to Field(0)
        BNE +
        INC @PTR + 1
+       CPX # No_scan_tag               ; Is tag >= No_scan_tag?
        BCC @scan
        ASL                             ; Yes: compute A := 2*size and
        BCC +                           ;  add it to @PTR.
        INC @PTR + 1
        CLC
+       ADC @PTR
        STA @PTR
        BCC --
        INC @PTR + 1                    ;  Now @PTR->next block's header
        BCS --                          ;  Continue the outer loop.
@scan   STA @CNT                        ; No: set @CNT = # of fields
-       LDA (@PTR),Y                    ; Loop: scan fields
        BIT caml_is_block               ;  Is current field a block?
        BNE @next                       ;  Skip it if not.
        STA @SCN                        ;  Yes: store it in @SCN, lo by.
        INY
        LDA (@PTR),Y
        STA @SCN + 1                    ;  and hi by.
        DEY
        JSR .caml_gc_fwdptr             ;  Get fwd ptr (maybe copy blk)
        BCC @next                       ;  Skip if block is out_of_heap
        STA (@PTR),Y                    ;  Save fwd ptr, lo byte
        TXA                             ;  A := fwd ptr, hi byte
        INY
        STA (@PTR),Y                    ;  Save fwd ptr, hi byte.
        DEY                             ;  Y=0 now.
@next   INC @PTR                        ;  Increment @PTR twice to let
        INC @PTR                        ;  it point to next field.
        BNE +
        INC @PTR + 1
+       DEC @CNT                        ;  Decrement loop counter
        BNE -                           ; End of loop: scan fields.
        BEQ --                          ;End of loop: scan blocks.
+++     RTS

.caml_gc_scnroots
        ;; Scan all roots in a contiguous memory area (starting from the address
        ;; stored in pointer @PTR down to the address stored in @testlo+1 and
        ;; @testhi+1) and call .caml_gc_fwdptr for each of them.
-       LDA @PTR
        BNE +
        DEC @PTR + 1
+       DEC @PTR                        ;@PTR points to curr elt, hi by.
@testlo LDA # <.dummy                   ;SMC: real arg is <last_address
        CMP @PTR
@testhi LDA # >.dummy                   ;SMC: real arg is >last_address
        SBC @PTR + 1
        BCS +                           ;Exit loop if all elts scanned
        LDA (@PTR),Y                    ;Get hi byte (Y=0 here)
        TAX                             ;Save it in X
        DEC @PTR                        ;Safe, @PTR is odd before DEC
        LDA (@PTR),Y                    ;Get lo byte
        BIT caml_is_block               ;Is it a pointer?
        BNE -                           ;If not, skip it
        STA @SCN                        ;Save the pointer, lo byte
        STX @SCN + 1                    ;and hi byte
        JSR .caml_gc_fwdptr             ;Get fwd ptr (maybe copy blk)
        BCC -                           ;Skip if out_of_heap
        STA (@PTR),Y                    ;Save fwd pointer, lo byte
        TXA                             ;(prepare to save hi by: A := X
        INY                             ; and adjust Y)
        STA (@PTR),Y                    ;Save hi byte
        DEY                             ;Y=0 now
        BEQ -                           ;BEQ=JMP, continue loop
+       RTS

.caml_gc_fwdptr
        ;; Subroutine: if @SCN is allocated in the old half of the heap, copy it
        ;; in the fresh one, set Field(0)=forward pointer, set size=0, then
        ;; return C=1, X:A=fwd ptr, Y=0; if already copied, return C=0, Y=0.
        LDA @SCN                        ;Check if out-of-heap ptr:
        CMP .OTH_START
        LDA @SCN + 1
        SBC .OTH_START + 1              ;@SCN < lower bound?
        BCC +                           ;yes: exit
        LDA @SCN
        CMP .OTH_END
        LDA @SCN + 1
        SBC .OTH_END + 1                ;@SCN >= higher bound?
        BCC ++                          ;no:  go ahead
        CLC                             ;yes: clear carry and exit
+       RTS                             ;RETURN C=0, Y=0.
++      DEC @SCN + 1                    ;decrement ptr's hi byte
        LDY # -1                        ; and set Y in order to
@again  LDA (@SCN),Y                    ; get block size
        BNE @copy                       ;if size = 0
        INC @SCN + 1                    ;then restore the pointer,
        LDY # 1                         ;  get fwd ptr from Field(0):
        LDA (@SCN),Y                    ;    get hi byte
        TAX                             ;    and save it in X
        DEY                             ;    get lo byte
        LDA (@SCN),Y                    ;    and save it in A
        SEC                             ;  set C=1
        RTS                             ;  RETURN C=1, X:A=fwdptr, Y=0.
@copy   TAX                             ;else X := size
        DEY                             ;  Y := $FE
        LDA (@SCN),Y                    ;  A := tag
        CMP # Infix_tag                 ;  is it an infix block?
        BEQ @infix                      ;  yes: skip to proper section. An infix
                                        ;  block is NOT marked as visited: its
                                        ;  size is the offset from the main
                                        ;  block, needed by any other pointer
                                        ;  to it (only the main block is copied
                                        ;  and gets a forward pointer).
        INY                             ;  no: mark this block as visited,
        LDA # 0                         ;    setting its size = 0
        STA (@SCN),Y
        DEY                             ;  Y := $FE
        LDA (@SCN),Y                    ;  A := tag
        INC @SCN + 1                    ;  restore the pointer
        LDY # 0                         ;  and Y register
        STA (HEAP),Y                    ;  write tag in new block
        INC HEAP
        TXA
        STA (HEAP),Y                    ;  write size
        INC HEAP                        ;  now HEAP->Field(0)
        BNE +
        INC HEAP + 1
+       LDA HEAP
        STA BLK                         ;  BLK := &Field(0)
        LDA HEAP + 1
        STA BLK + 1
        TXA                             ;  Add 2*size to HEAP
        ASL
        BCC +
        INC HEAP + 1
        CLC
+       ADC HEAP
        STA HEAP
        BCC +
        INC HEAP + 1
+       TXA                             ;  Prepare to copy all fields:
        ASL
        TAY                             ;  C:Y := 2*size
        BCC @lt256                      ;   2*size < 256by (<128 fields)
        BEQ @eq256                      ;   2*size = 256by (=128 fields)
        INC @SCN + 1                    ;   2*size > 256by (>128 fields)
        INC BLK + 1
--                                      ;  loop: copy @SCN fields to BLK
@lt256  DEY
-       LDA (@SCN),Y
        STA (BLK),Y
        DEY
        BNE -
        LDA (@SCN),Y                    ;   handle Y = 0 apart
        STA (BLK),Y
        BCC @wrtfwd                     ;  exit loop
        DEC @SCN + 1
        DEC BLK + 1
@eq256  CLC
        BCC --
@wrtfwd INY                             ;  Y:=1
        LDA BLK + 1                     ;  load fwd pointer, hi
        STA (@SCN),Y                    ;  write it in field(0), hi
        TAX                             ;  and move it in X
        DEY                             ;  Y := 0
        LDA BLK                         ;  load fwd pointer, lo
        STA (@SCN),Y                    ;  and write it in field(0),lo
        SEC                             ;  set carry before exit
        RTS                             ;  RETURN (X:A=fwdptr, Y=0)
@infix  TXA                             ;A:=X=size=dist.from main blk
        STX @dst + 1                    ;save it for later
        ASL                             ;C:A := 2*dist.
        STA @dst2lo + 1                 ;write next SBC's arg.
        BCC +                           ;perform @SCN:=@SCN-.DST:
        DEC @SCN + 1                    ;  decr @SCN_hi if C set
+       LDA @SCN                        ;  load @SCN_lo
        SEC
@dst2lo SBC # <.dummy                   ;  SMC: subtract <2*dist.
        STA @SCN                        ;  save result, lo by.
        BCS +
        DEC @SCN + 1                    ;  adjust hi by.
+       INY                             ;(@SCN),Y = main block's size
        JSR @again                      ;get main block's fwdptr in X:A
        STA @fwdlo + 1                  ;write next ADC's arg.
@dst    LDA # <.dummy                   ;SMC: get infix's SIZE
        ASL                             ;A := <SIZE*2, C := >SIZE*2 
        BCC @fwdlo                      ;perform X:A:=X:A+main fwd ptr:
        INX                             ;  incr X if SIZE*2>255
        CLC
@fwdlo  ADC # <.dummy                   ;  SMC: add forward ptr, lo byte
        BCC +
        INX                             ;  adjust X
+       SEC                             ;set carry before exit
        RTS                             ;RETURN(X:A=infix forward ptr)

caml_shrink_latest_alloc
        ;; Reduce the size of the latest allocated block; new size MUST BE less
        ;; than the original one (no check) and NO GARBAGE COLLECTION occurred
        ;; since the block allocation. Params: X=size>0, Y=0, BLK=address.
        ;; Shrinking is done by updating the new size in the block's header and
        ;; the HEAP pointer. Return: A=X=size, Y=0.
@SZ     = GC                            ;2 by - block size in bytes
        DEC BLK + 1                     ;Prepare access to the 'size'
        DEY                             ; byte in block's header
        LDA (BLK),Y                     ;Read original size from header
        STA @SZ                         ; and save it
        TXA                             ;A := new size
        STA (BLK),Y                     ;Write new size into header
        INC BLK + 1                     ;Restore block pointer
        INY                             ; and Y register
        EOR # $FF                       ;Do an inverse subtraction:
        SEC                             ; A := @SZ - A
        ADC @SZ                         ;    = orig.size - new size
        ASL                             ;Compute 2 * A
        STA @SZ                         ;Store result, lo byte, in @SZ
        STY @SZ + 1                     ;Set @SZ + 1 to 0
        ROL @SZ + 1                     ;Store result, MSB, in @SZ + 1
        LDA HEAP                        ;Recover unused block bytes by
        SEC                             ; decrementing the heap pointer
        SBC @SZ                         ; by 2 * (orig.size - new size)
        STA HEAP                        ;Store new value, lo byte
        LDA HEAP + 1
        SBC @SZ + 1
        STA HEAP + 1                    ;Store new value, hi byte
        RTS                             ;Return.

	;; Copy BLK to ACCU.
caml_load_newblk
        LDA BLK + 1
        STA ACCU + 1
        LDA BLK
        STA ACCU
        RTS

caml_memory_end
} ;!zone caml_MEMORY
