;; -----------------------------------------------------------------------------
;;                                   ARRAYS
;; -----------------------------------------------------------------------------

!zone caml_ARRAYS {

!ifndef caml_arrays_warn {
!set caml_arrays_warn = 1
  !warn "TODO: caml_array_fill"
  !warn "TODO: caml_floatarray_blit"
  !warn "BUG: GC-invalidated pointers in caml_array_concat"
}
        
!ifdef caml_PRIM__caml_make_vect {
caml_make_vect
        ;; allocate and initialize an array
        ;; ACCU = length
        ;; SP[0] = init
@NFLO2  = TMP                           ;set by caml_floatarray_create
@INIT   = TMP + 1
        ;; check init type
        LDA (SP),Y
        STA @INIT
        INY
        LDA (SP),Y
        STA @INIT + 1                   ;hi byte needed also if init is an int
        LDY # 0
        LDA @INIT
        LSR
        BCS @chklen
        ;; block: check if float
        LDY # -2
        DEC @INIT + 1
        LDA (@INIT),Y
        INC @INIT + 1
        LDY # 0
        CMP # Double_tag
        BEQ @float
        ;; check array length
@chklen LDA ACCU + 1
        LSR
        BNE @error
        LDA ACCU
        ROR
        BNE @noflo
        JMP caml_mkatom0
@error  +caml_raise Invalid_argument, "Array.make"
        ;; init is a float
@float  JSR caml_floatarray_create      ;allocate a floatarray, set @NFLO2
        BCC +
        ;; GC occurred, reload SP[0]
        LDA (SP),Y
        STA @INIT
        INY
        LDA (SP),Y
        STA @INIT + 1
+       LSR @NFLO2
        BEQ +                           ;exit if empty array
        LDX @NFLO2                      ;X = no. of array elements
        ;; initialize the floatarray
-       +caml_move_float @INIT, BLK
        DEX
        BEQ +
        LDA BLK
        CLC
        ADC # 2 * Double_wosize        ;next float = 6 bytes ahead
        STA BLK
        BCC -
        INC BLK + 1
        BCS -
+       LDY # 0
        RTS
        ;; init is int or non-float block
@noflo  TAX                             ;X = Int_val(lenght)
        TYA                             ;A = tag = 0
        JSR caml_alloc                  ;allocate a non-float array
        JSR caml_load_newblk   
        LDA (SP),Y
        BCC +                           ;branch if no GC occurred
        BIT caml_is_block
        BNE +                           ;branch if init is int
        ;; GC occurred and init is a block, reload SP[0]
        STA @INIT
        INY
        LDA (SP),Y
        STA @INIT + 1
        DEY
        ;; initialize the array
-       LDA @INIT
+       STA (BLK),Y
        INY
        LDA @INIT + 1
        STA (BLK),Y
        DEX
        BEQ +
        INY
        BNE -
        INC BLK + 1
        BNE -
+       LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_floatarray_create {
        ;; allocate an array of floats
        ;; ACCU = length
caml_floatarray_create
@NFLO2 = TMP                            ;shared with caml_make_vect
        LDA ACCU + 1                    ;load and check length
        BNE @error
        LDA ACCU
        AND # $FE
        STA @NFLO2                      ;@NFLO2 = 2 * no. of array elements
        BNE +
        CLC                             ;atom0 => no GC, tell caml_make_vect
        JMP caml_mkatom0
+       LSR
       ;CLC
        ADC @NFLO2
        BCS @error
        TAX                             ;X = size = length * 3
        LDA # Double_array_tag          ;Allocate a floatarray
        JSR caml_alloc
        JMP caml_load_newblk   
@error  +caml_raise Invalid_argument, "Float.Array.create"
}

!ifdef caml_PRIM__caml_make_array {
        ;; If ACCU is a block of floats, unbox all elements, else do nothing
caml_make_array
@FLD = TMP
@NFL = TMP + 2
@OFS = TMP + 3
@RES = TMP + 4
        LDA ACCU
        BIT caml_is_block
        BNE @exit                       ;exit if !is_block(ACCU)
        CMP # <caml_atom0
        BNE +
        LDA ACCU + 1
        CMP # >caml_atom0
        BEQ @exit                       ;exit if size(ACCU)=0
+       LDA (ACCU),Y
        BIT caml_is_block
        BNE @exit                       ;exit if !is_block(Field0)
        STA @FLD
        SEC
        SBC # < caml_heap_start
        INY
        LDA (ACCU),Y
        CMP # > caml_heap_start
        BCC @exit0                      ;exit if out_of_heap(Field0)
        STA @FLD + 1
        LDY # -2
        DEC @FLD + 1
        LDA (@FLD),Y
        CMP # Double_tag
        BEQ +                           ;exit if tag(Field0)<>Double_tag
@exit0  LDY # 0
@exit   RTS
+       INY                             ;Y = -1
        DEC ACCU + 1
        LDA (ACCU),Y                    ;size of the source array
        INC ACCU + 1
        INY                             ;Y = 0
        CMP # 255 DIV Double_wosize + 1  ;check length
        BCC +
        +caml_raise Out_of_memory
        ;; size is lenght * 3
+       STA @NFL
        ASL
        ;CLC
        ADC @NFL
        TAX                              ;X = @NFL * 3 = @NFL * Double_wosize 
        LDA # Double_array_tag           ;A = tag
        JSR caml_alloc                   ;allocate array of floats; ACCU (the
                                         ; source array) is a GC root, so it
                                         ; stays valid. {Y = 0}
        LDA BLK
        STA @RES
        LDA BLK + 1
        STA @RES + 1                     ;save result address
        STY @OFS                         ;offset of the source field (Y = 0)
        ;; for each element: unbox Field(ACCU,i) into the new block
@loop   LDY @OFS
        LDA (ACCU),Y
        STA @FLD
        INY
        LDA (ACCU),Y
        STA @FLD + 1
        INY
        STY @OFS
        +caml_move_float @FLD, BLK       ;{Y = 0}
        DEC @NFL
        BEQ @end
        LDA BLK
        CLC
        ADC # Double_wosize * 2
        STA BLK
        BCC @loop
        INC BLK + 1
        BCS @loop                        ;C is still set
@end    LDA @RES                         ;ACCU := new array
        STA ACCU
        LDA @RES + 1
        STA ACCU + 1
        RTS                              ;{Y = 0}
}

!ifdef caml_PRIM__caml_array_get {
caml_array_get
        ;; return an array element
        ;; ACCU = array
        ;; SP[0] = index
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INY
        CMP # Double_array_tag
        BNE caml_array_get_addr__loadsize
        JMP caml_floatarray_get__loadsize   ;{Y=-1, ACCU+1 already decremented}
}

!ifdef caml_PRIM__caml_array_get_addr {
        ;; return an array element (no-float version)
        ;; ACCU = array
        ;; SP[0] = index
caml_array_get_addr
        DEY
        DEC ACCU + 1
caml_array_get_addr__loadsize
@SZ     = TMP
        ;; load size
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1                    ;restore ACCU+1
        LDY # 1
        LDA (SP),Y                      ;load index, hi
        LSR
        BNE @error                      ;exn if index>255 or index<0
        BCC +
        INC ACCU + 1                    ;inc ACCU if index > 127
+       DEY
        LDA (SP),Y                      ;load index, lo
        TAY                             ;now ACCU+Y points to elt, hi
        ROR
        CMP @SZ
        BCS @error                      ;exn if index >= size
        LDA (ACCU),Y                    ;get array elt, hi
        TAX
        DEY
        LDA (ACCU),Y                    ;get array elt, lo
        STA ACCU                        ;ACCU <- array[index]
        STX ACCU + 1
        LDY # 0
        RTS
@error  JMP caml_err_index_oob
}

!ifdef caml_PRIM__caml_floatarray_get {
        ;; return an array element (floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
caml_floatarray_get
        DEY
        DEC ACCU + 1
caml_floatarray_get__loadsize
@SZ     = TMP
@IDX    = TMP + 1
        ;; load size
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1                    ;restore ACCU+1
        ;; allocate float
        LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc
        ;; load index, hi
        LDY # 1
        LDA (SP),Y
        BNE @error                      ;exn if hi > 0
        ;; load index, lo
        DEY
        LDA (SP),Y
        ;; exn if 3 * index >= size
        JSR caml_IntValx3
        BCS @error
        CMP @SZ
        BCS @error
        ;; ACCU <- &array[index]
        LDX # ACCU
        JSR caml_ptr_add2A
        ;; copy float
        +caml_move_float ACCU, BLK
        ;; return float
        JMP caml_load_newblk
@error  JMP caml_err_index_oob
}

!ifdef caml_PRIM__caml_array_unsafe_get {
caml_array_unsafe_get
        ;; return an array element (unsafe version)
        ;; ACCU = array
        ;; SP[0] = index
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y                    ;load tag
        INC ACCU + 1                    ;restore ptr
        LDY # 0
        CMP # Double_array_tag          ;check if float
        BEQ caml_floatarray_unsafe_get  ;yes: special case
        LDA (SP),Y                      ;Val_int(index), lo
        STA TMP
        INY
        LDA (SP),Y                      ;Val_int(index), hi
        BEQ +
        INC ACCU + 1
+       LDY TMP
        ;; get array element
        LDA (ACCU),Y                    ;array[index], hi
        TAX
        DEY
        LDA (ACCU),Y                    ;array[index], lo
        STA ACCU
        STX ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_floatarray_unsafe_get {
        ;; return an array element (unsafe, floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
caml_floatarray_unsafe_get
        ;; allocate float
        LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc
        ;; load index, lo (ignore hi byte)
        LDA (SP),Y                      ;2*i+1
        ;; calc 3 * i
        JSR caml_IntValx3
        ;; ACCU <- &array[index]
        LDX # ACCU
        JSR caml_ptr_add2A
        ;; copy float
        +caml_move_float ACCU, BLK
        ;; return float
        JMP caml_load_newblk   
}

!ifdef caml_PRIM__caml_array_set {
caml_array_set
        ;; set an array element to given value
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval

        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INY
        ;; check if float
        CMP # Double_array_tag
        BNE caml_array_set_addr__loadsize
        JMP caml_floatarray_set__loadsize   ;{Y=-1, ACCU+1 already decremented}
}

!ifdef caml_PRIM__caml_array_set_addr {
        ;; set an array element to given value (no-float version)
        ;; ACCU = array
        ;; SP[0] = Val_int(index)
        ;; SP[1] = newval
caml_array_set_addr
        ;; load size
        DEY
        DEC ACCU + 1
caml_array_set_addr__loadsize
@SZ     = TMP
@NEW    = TMP + 1
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1
        ;; load newval
        LDY # 3
        LDA (SP),Y
        STA @NEW + 1
        DEY
        LDA (SP),Y
        STA @NEW
        ;; load index, hi
        DEY
        LDA (SP),Y
        ;; exn if index > 255 or index < 0
        LSR
        BNE @error
        ;; load index, lo
        DEY
        LDA (SP),Y
        ROR
        ;; exn if index >= size
        CMP @SZ
        BCS @error
        ;; array[index] <- newval
        ASL
        BCC +
        INC ACCU + 1
+       TAY
        LDA @NEW
        STA (ACCU),Y
        INY
        LDA @NEW + 1
        STA (ACCU),Y
        ;; ACCU <- ()
        LDY # <Val_unit                 ;Y := 1
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
@error  JMP caml_err_index_oob
}

!ifdef caml_PRIM__caml_floatarray_set {
        ;; set an array element to given value (floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_floatarray_set
        ;; load size
        DEY
        DEC ACCU + 1
caml_floatarray_set__loadsize
@SZ     = TMP
@IDX    = TMP + 1
@NEW    = TMP + 2
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1
        ;; load newval
        LDY # 3
        LDA (SP),Y
        STA @NEW + 1
        DEY
        LDA (SP),Y
        STA @NEW
        ;; load index, hi
        DEY
        LDA (SP),Y
        ;; exn if hi > 0
        BNE @error
        ;; load index, lo
        DEY
        LDA (SP),Y
        ;; exn if 3 * index >= size
        JSR caml_IntValx3
        BCS @error
        CMP @SZ
        BCS @error
        ;; ACCU <- &array[index]
        LDX # ACCU
        JSR caml_ptr_add2A
        ;; copy float
        +caml_move_float @NEW, ACCU
        ;; ACCU <- ()
        STY ACCU + 1
        INY
        STY ACCU
        DEY
        RTS
@error  JMP caml_err_index_oob
}

!ifdef caml_PRIM__caml_array_unsafe_set {
caml_array_unsafe_set
        ;; set an array element to given value (unsafe version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval

        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        LDY # 0
        ;; check if float
        CMP # Double_array_tag
        BEQ caml_floatarray_unsafe_set
        ;; FALLTHROUGH caml_array_unsafe_set_addr
}

!ifdef caml_PRIM__caml_array_unsafe_set_addr {
        ;; set an array element to given value (unsafe, no-float version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_array_unsafe_set_addr
        ;; load index
        LDA (SP),Y                      ;Val_int(index), lo
        STA TMP
        INY
        LDA (SP),Y                      ;Val_int(index), hi
        BEQ +
        INC ACCU + 1
        ;; load newval
+       INY
        LDA (SP),Y
        TAX
        INY
        LDA (SP),Y
        ;; array[index] <- newval
        LDY TMP
        STA (ACCU),Y
        DEY
        TXA
        STA (ACCU),Y
        ;; ACCU <- ()
        LDY # <Val_unit                 ;Y := 1
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_floatarray_unsafe_set {
        ;; set an array element to given value (unsafe, floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_floatarray_unsafe_set
        ;; load index, lo (ignore hi byte)
        LDA (SP),Y                      ;2*i+1
        ;; calc 3 * i
        JSR caml_IntValx3
        ;; ACCU <- &array[index]
        LDX # ACCU
        JSR caml_ptr_add2A
        ;; load newval
        LDY # 2
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        ;; copy float
        +caml_move_float TMP, ACCU
        ;; ACCU <- ()
        LDA # <Val_unit
        STA ACCU
        STY ACCU + 1                    ;Y = 0
        RTS
}

!ifdef caml_PRIM__caml_array_blit {
caml_array_blit
        ;; copy a subarray to other one (source and dest may overlap)
        ;; ACCU = arr1
        ;; SP[0] = ofs1
        ;; SP[1] = arr2
        ;; SP[2] = ofs2
        ;; SP[3] = n
@NBY    = TMP + 2
        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        ;; check if float
        CMP # Double_array_tag
        BNE @no_float
        ;; array of floats, compute source start address
        LDY # 0
        STY @NBY + 1
        LDA (SP),Y                      ;ofs1, ignore hi byte
        JSR caml_IntValx3
        ;; ACCU <- &arr1[ofs1]
        LDX # ACCU                      ;A = 6 * ofs1
        JSR caml_ptr_add2A
        ;; compute destination start address
        LDY # 4
        LDA (SP),Y                      ;ofs2, ignore hi byte
        ;; calc 3 * index
        JSR caml_IntValx3
        STA TMP
        ;; TMP <- &arr2[ofs2]
        TAX                             ;X = 3 * ofs2
        DEY
        LDA (SP),Y
        STA TMP + 1
        TXA
        ASL                             ;A = 6 * ofs2
        BCC +
        INC TMP + 1
        CLC
+       DEY
        ADC (SP),Y
        STA TMP
        BCC +
        INC TMP + 1
        ;; @NBY = 6 * n (no. of bytes to be moved)
+       LDY # 6
        LDA (SP),Y                      ;ignore hi byte
        JSR caml_IntValx3
        ASL
        STA @NBY
        BCC +
        INC @NBY + 1
+       JMP @copy
@no_float
        ;; ordinary array, compute source start address
        LDY # 0
        CLC
        LDA (SP),Y
        ADC ACCU
        STA ACCU
        INY
        LDA (SP),Y
        ADC ACCU + 1
        STA ACCU + 1
        LDA ACCU
        BNE +
        DEC ACCU + 1
+       DEC ACCU
        ;; compute destination start address
        INY
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        INY
        CLC
        LDA TMP
        ADC (SP),Y
        STA TMP
        INY
        LDA TMP + 1
        ADC (SP),Y
        STA TMP + 1
        LDA TMP
        BNE +
        DEC TMP + 1
+       DEC TMP
        ;; compute no. of bytes to be copied: @NBY = 2n (n = SP[3] = 2n+1 - 1)
        INY
        LDA (SP),Y
        STA @NBY
        INY
        LDA (SP),Y
        STA @NBY + 1
        LDA @NBY
        BNE +
        DEC @NBY + 1
+       DEC @NBY
        ;; ACCU = source, TMP = destination, @NBY = no. of bytes (exact)
@copy   LDA @NBY
        ORA @NBY + 1
        BEQ @done0                      ;nothing to copy
        LDA ACCU
        CMP TMP
        LDA ACCU + 1
        SBC TMP + 1
        BCS @cpydn
        ;; source < dest: copy from the end (safe if the ranges overlap).
        ;; (blkcpy is not used: it copies to BLK, not to TMP)
        CLC
        LDA ACCU + 1
        ADC @NBY + 1
        STA ACCU + 1
        CLC
        LDA TMP + 1
        ADC @NBY + 1
        STA TMP + 1
        LDY @NBY
        BEQ @uppg
-       DEY
        LDA (ACCU),Y
        STA (TMP),Y
        CPY # 0
        BNE -
@uppg   LDX @NBY + 1                    ;Y = 0 here
        BEQ @done0
--      DEC ACCU + 1
        DEC TMP + 1
-       DEY                             ;Y: 0 -> 255 -> ... -> 0
        LDA (ACCU),Y
        STA (TMP),Y
        CPY # 0
        BNE -
        DEX
        BNE --
@done0  LDY # 0
@done   STY ACCU + 1                    ;Y = 0
        LDA # <Val_unit
        STA ACCU
        RTS                             ;Exit.
        ;; source >= dest: copy from the start
@cpydn  LDY # 0
        LDX @NBY + 1
        BEQ @dnlo
-       LDA (ACCU),Y                    ;a whole page
        STA (TMP),Y
        INY
        BNE -
        INC ACCU + 1
        INC TMP + 1
        DEX
        BNE -
@dnlo   LDX @NBY
        BEQ @done0
-       LDA (ACCU),Y                    ;the remaining bytes
        STA (TMP),Y
        INY
        DEX
        BNE -
        BEQ @done0
}

!ifdef caml_PRIM__caml_array_sub {
caml_array_sub
        ;; allocate and return a subarray
        ;; ACCU = a
        ;; SP[0] = ofs
        ;; SP[1] = n
        ;; GC-safe: while caml_alloc may run a GC, ACCU is kept equal to the
        ;; array's start (a root) and the source address is computed after it.
@NB     = TMP                           ;no. of bytes to be copied
@TG     = TMP + 2                       ;tag of the new array
        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        STA @TG
        CMP # Double_array_tag
        BNE @ordinary
        ;; array of floats: @NB = 6 * n
        LDY # 2
        LDA (SP),Y                      ;ignore hi byte
        JSR caml_IntValx3
        ASL
        STA @NB
        LDA # 0
        ROL
        STA @NB + 1
        JMP @alloc
@ordinary
        LDA # 0
        STA @TG
        LDY # 2
        LDA (SP),Y
        STA @NB
        INY
        LDA (SP),Y
        STA @NB + 1
        LDA @NB
        BNE +
        DEC @NB + 1
+       DEC @NB                         ;@NB = 2 * n
        ;; allocate subarray (an empty one is the atom 0)
@alloc  LDA @NB + 1
        LSR
        LDA @NB
        ROR
        TAX
        BNE +
        LDY # 0
        JMP caml_mkatom0
+       LDA @TG
        JSR caml_alloc                  ;ACCU = a is still a valid root
        ;; compute source address (ACCU may have been moved by the GC)
        LDY # 0
        LDA @TG
        CMP # Double_array_tag
        BEQ @floats
        CLC
        LDA ACCU
        ADC (SP),Y
        STA ACCU
        INY
        LDA ACCU + 1
        ADC (SP),Y
        STA ACCU + 1
        LDA ACCU
        BNE +
        DEC ACCU + 1
+       DEC ACCU                        ;ACCU := a + 2 * ofs
        JMP @copy
@floats LDA (SP),Y                      ;ofs, ignore hi byte
        JSR caml_IntValx3
        LDX # ACCU
        JSR caml_ptr_add2A              ;ACCU := &a[ofs] (6 * ofs bytes)
        ;; copy bytes from source to destination
@copy   LSR @NB + 1
        LDY @NB
        JSR caml_blkcpy
        ;; ACCU <- subarray
        JMP caml_load_newblk
}

!ifdef caml_PRIM__caml_array_append {
caml_array_append
        ;; append two arrays
        ;; ACCU = arr1
        ;; SP[0] = arr2
        ;; GC-safe: ACCU and SP[0] are roots; arr2 is reloaded from the stack
        ;; after caml_alloc, and no cached/internal pointer lives across it.
@AUX    = TMP
@SIZE1  = TMP + 2
@SIZE2  = TMP + 4
        ;; load sizes and tag
        LDA (SP),Y                      ;{Y = 0}
        STA @AUX
        INY
        LDA (SP),Y
        STA @AUX + 1
        LDY # -1
        DEC ACCU + 1
        DEC @AUX + 1
        LDA (ACCU),Y
        STA @SIZE1
        LDA (@AUX),Y
        STA @SIZE2
        DEY
        LDA (ACCU),Y                    ;tag
        INC ACCU + 1                    ;ACCU = arr1 again (valid pointer)
        PHA
        LDA @SIZE2
        CLC
        ADC @SIZE1
        BCC +
        ;; exception if total size > 255
        PLA
        LDY # 0
        JMP @error
+       TAX                             ;size
        BNE +
        PLA
        LDY # 0
        JMP caml_mkatom0                ;both arrays empty
+       PLA                             ;tag
        JSR caml_alloc                  ;ACCU and SP[0] updated if GC
        LDA BLK
        STA @AUX                        ;save ptr to result
        LDA BLK + 1
        STA @AUX + 1
        ;; copy arr1 to dest
        LDA @SIZE1
        BEQ +
        ASL
        TAY
        JSR caml_blkcpy                 ;{BLK unchanged, Y = 0}
        ;; BLK <- &BLK[SIZE1]
+       LDA @SIZE1
        LDX # BLK
        JSR caml_ptr_add2A
        ;; ACCU <- arr2 (reloaded from the stack)
        LDY # 0
        LDA (SP),Y
        STA ACCU
        INY
        LDA (SP),Y
        STA ACCU + 1
        ;; copy arr2 to dest
        LDA @SIZE2
        BEQ +
        ASL
        TAY
        JSR caml_blkcpy
        ;; ACCU <- result
+       LDY # 0
        LDA @AUX
        STA ACCU
        LDA @AUX + 1
        STA ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "Array.append"
}

!ifdef caml_PRIM__caml_array_concat {
caml_array_concat
        ;; concatenate all arrays in a list
        ;; ACCU = list
@TAG    = TMP
@SIZE   = TMP + 1
@HEAD   = TMP + 2
@TAIL   = TMP + 4
@RESULT = TMP + 2
        DEY
        STY @TAG                        ;@TAG = -1
        INY
        STY @SIZE
        ;; return caml_atom0 if list = []
        LDA ACCU
        BIT caml_is_block
        BEQ +
        JMP caml_mkatom0
        ;; scan list and sum all arrays sizes
+       LDA (ACCU),Y
        STA @HEAD
        INY
        LDA (ACCU),Y
        STA @HEAD + 1
        INY
        LDA (ACCU),Y
        STA @TAIL
        INY
        LDA (ACCU),Y
        STA @TAIL + 1
        ;; get current array size and add it to @SIZE
-       LDY # -1
        DEC @HEAD + 1
        LDA (@HEAD),Y
        BEQ +
        CLC
        ADC @SIZE
        BCC ++
        +caml_raise Invalid_argument, "Array.concat"
++      STA @SIZE
        ;; only once: set @TAG from first non-empty array
        CPY @TAG                        ;test if @TAG = -1
        BNE +
        DEY
        LDA (@HEAD),Y
        STA @TAG
        INY
        ;; set @HEAD to next list element, @TAIL to rest
+       INY
        LDA @TAIL
        BIT caml_is_block               ;end of list?
        BEQ @alloc                      ;yes:  exit loop
        LDA (@TAIL),Y                   ;no:   continue
        STA @HEAD
        INY
        LDA (@TAIL),Y
        STA @HEAD + 1
        INY
        LDA (@TAIL),Y
        TAX
        INY
        LDA (@TAIL),Y
        STX @TAIL
        STA @TAIL + 1
        JMP -
        ;; allocate destination array
@alloc  LDX @SIZE
        BNE +
        JMP caml_mkatom0
+       LDA @TAG
        JSR caml_alloc                  ;OK: ACCU (list) is a root, @TAIL reloaded below
        LDA BLK
        STA @RESULT
        LDA BLK + 1
        STA @RESULT + 1                 ;save dest address
        ;; scan list again and append all arrays
        LDY # 3
        LDA (ACCU),Y
        STA @TAIL + 1
        DEY
        LDA (ACCU),Y
        STA @TAIL
        DEY
        LDA (ACCU),Y
        TAX
        DEY
        LDA (ACCU),Y
        STX ACCU + 1
        STA ACCU
        ;; get current array size
-       LDY # -1
        DEC ACCU + 1
        LDA (ACCU),Y
        BEQ +                           ;skip if zero
        INC ACCU + 1
        TAX
        ASL
        TAY
        ;; copy array elements to destination
        JSR caml_blkcpy
        TXA
        ;; set BLK pointer to first element to be copied next
        LDX # BLK
        JSR caml_ptr_add2A
        ;; set ACCU to next list element, @TAIL to rest
+       LDY # 0
        LDA @TAIL
        BIT caml_is_block               ;end of list?
        BEQ @eol                        ;yes:  exit
        LDA (@TAIL),Y                   ;no:   continue
        STA ACCU
        INY
        LDA (@TAIL),Y
        STA ACCU + 1
        INY
        LDA (@TAIL),Y
        TAX
        INY
        LDA (@TAIL),Y
        STX @TAIL
        STA @TAIL + 1
        JMP -
        ;; set ACCU = destination array and return
@eol    LDA @RESULT
        STA ACCU
        LDA @RESULT + 1
        STA ACCU + 1
        RTS
}

}      ;; !zone caml_ARRAYS
