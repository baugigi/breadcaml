;; -----------------------------------------------------------------------------
;;                  OBJ - INTERNAL REPRESENTATION OF VALUES
;; -----------------------------------------------------------------------------

!zone caml_OBJ {

;; UNIMPLEMENTED:
;; CAMLprim value caml_obj_raw_field(value arg, value pos)
;; CAMLprim value caml_obj_set_raw_field(value arg, value pos, value bits)
;; CAMLprim value caml_obj_with_tag(value new_tag_v, value arg)
;; CAMLprim value caml_get_public_method (value obj, value tag)

caml_OOID
        !word Val_zero                  ; init value for OOID

!ifdef caml_PRIM__caml_obj_tag {
        ;; ACCU = value
        ;; return tag(value)
caml_obj_tag
        LDA ACCU
        BIT caml_is_block
        BNE @int
        LDX ACCU + 1
        CPX # > caml_glob_end           ; = heap start address
        BCC @ooh
        BNE +
        CMP # < caml_glob_end
        BCC @ooh
+       CPX # > caml_stack_start        ; = heap end address + 1
        BCC +
        BNE @ooh
        CMP # < caml_stack_start
        BCS @ooh
        ;; Val_int(tag(ACCU))
+       LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        SEC
        ROL
        STA ACCU
        LDY # 0
        STY ACCU + 1
        ROL ACCU + 1
        RTS
@ooh    +Val_Int ~@oohtag, 1001         ;Out_of_heap_tag
        LDA # > @oohtag
        LDX # < @oohtag
        BNE @res                        ;BNE = JMP
@int    +Val_Int ~@inttag, 1000         ; Int_tag
        LDA # > @inttag
        LDX # < @inttag
@res    STA ACCU + 1
        STX ACCU
        RTS
}

!ifdef caml_PRIM__caml_obj_set_tag {
        ;; ACCU = value, SP[0] = new tag
caml_obj_set_tag
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # -2
        DEC ACCU + 1
        STA (ACCU),Y
        LDY # <Val_unit
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
}

;; camlinternalLazy.ml:
;; external make_forward : Obj.t -> Obj.t -> unit = "caml_obj_make_forward"
!ifdef caml_PRIM__caml_obj_make_forward {
        ;; CAMLprim value caml_obj_make_forward (value blk, value fwd)
        ;; {    
        ;;   caml_modify(&Field(blk, 0), fwd);
        ;;   Tag_val (blk) = Forward_tag;
        ;;   return Val_unit;
        ;; }
caml_obj_make_forward
        LDA (SP),Y
        STA (ACCU),Y
        INY
        LDA (SP),Y
        STA (ACCU),Y
        LDY # -2
        DEC ACCU + 1
        LDA # Forward_tag
        STA (ACCU),Y
        LDY # 0
        STY ACCU + 1
        LDA # < Val_unit
        STA ACCU
        RTS
}


!ifdef caml_PRIM__caml_obj_block {
        ;; ACCU = tag, SP[0] = size
caml_obj_block
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        BNE +
        JMP caml_mkatom0
        ;; allocate a new block if size > 0
+       TAX
        LSR ACCU + 1
        LDA ACCU
        ROR
        JSR caml_alloc
        JSR caml_load_newblk
        JMP caml_block_fill0
}

!ifdef caml_PRIM__caml_obj_dup {
        ;; ACCU = arg
caml_obj_dup
        DEY
        DEC ACCU + 1
        LDA (ACCU),Y                    ; A := size
        BEQ @atom                       ; exit if size = 0
        TAX                             ; X := size
        DEY
        LDA (ACCU),Y                    ; A := tag
        INC ACCU + 1                    ; restore pointer
        LDY # 0                         ;   and Y register
        JSR caml_alloc                  ; allocate a new block
        TXA                             ; A := size
        ASL
        TAY                             ; Y,C := 2 * size
        JSR caml_blkcpy                 ; copy the blk pointed by ACCU
        JMP caml_load_newblk   
@atom   INC ACCU + 1
        INY
        RTS
}

!ifdef caml_PRIM__caml_obj_truncate {
        ;; truncate a block to newsize; ACCU = value, SP[0] = newsize
        ;; Obj.truncate is deprecated!
        ;; WARNING: Obj.truncate o s when Obj.size o = s + 1 will leave an atom
        ;; on the heap, which could cause the garbage collector to crash if it
        ;; is reachable from some root!

caml_obj_truncate
        @NEWSZ = TMP
        ;; load tag and size
        DEY
        DEC ACCU + 1
        LDA (ACCU),Y
        TAX                             ;X := size
        DEY
        LDA (ACCU),Y
        CMP # Double_array_tag
        BEQ @floatarray
        ;; calculate Int_val(newsize)
        LDY # 1
        LDA (SP),Y
        DEY
        LSR
        BNE @error                      ;error if newsize > 255 or < 0
        LDA (SP),Y
        ROR
        BEQ @error                      ;error if newsize = 0
        STA @NEWSZ
        CPX @NEWSZ
        BEQ @exit                       ;exit if newsize = size
        BCC @error                      ;error if newsize > size
        ;; 0 < NEWSZ < size, write NEWSZ into header
@trunc  DEY
        STA (ACCU),Y
        INC ACCU + 1
        ;; set (ACCU),Y to point to Field(ACCU, newsize)
        ASL
        BCC +
        INC ACCU + 1
+       TAY
        ;; header for the leftovers: tag = No_scan_tag, sz = size-1-newsize
        ;; WARNING: sz could be 0, the GC won't be happy if block is reachable!
        LDA # No_scan_tag
        STA (ACCU),Y                    ;tag = No_scan_tag
        INY
        DEX
        TXA
        SEC
        SBC @NEWSZ                      ;sz = size-1-NEWSZ
        STA (ACCU),Y
@exit   LDY # <Val_unit
        STY ACCU                        ;ACCU := ()
        DEY
        STY ACCU + 1
        RTS
        ;; calculate Int_val(newsize) * Double_wosize
@floatarray
        LDY # 1
        LDA (SP),Y
        BNE @error                      ;error if newsize > 127 or < 0
        DEY
        LDA (SP),Y
        AND # %11111110                 ;A = 2 * newsize
        BEQ @error                      ;error if newsize = 0
        STA @NEWSZ                      ;NEWSZ = 2 * newsize
        LSR
        ;CLC                            ;C=0 because of previous AND
        ADC @NEWSZ                      ;A = Double_wosize * newsize
        BCS @error                      ;error if > 255
        STA @NEWSZ                      ;NEWSZ=Double_wosize * newsize
        CPX @NEWSZ
        BEQ @exit                       ;exit if NEWSZ = size
        BCS @trunc                      ;error if NEWSZ > size
@error  +caml_raise Invalid_argument, "Obj.truncate"
}

!ifdef caml_PRIM__caml_obj_add_offset {
        ;; ACCU = value, SP[0] = offset
caml_obj_add_offset
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        DEY
        LSR TMP + 1
        ROR TMP
        CLC
        LDA TMP
        ADC ACCU
        STA ACCU
        LDA TMP + 1
        ADC ACCU + 1
        STA ACCU + 1
        RTS
}

;; lazy.ml:
;; external make_forward : 'a -> 'a lazy_t = "caml_lazy_make_forward"
!ifdef caml_PRIM__caml_lazy_make_forward {
        ;; CAMLprim value caml_lazy_make_forward (value v)
        ;; {
        ;;   CAMLparam1 (v);
        ;;   CAMLlocal1 (res);
        ;;   res = caml_alloc_small (1, Forward_tag);
        ;;   Field (res, 0) = v;
        ;;   CAMLreturn (res);
        ;; }
caml_lazy_make_forward
        LDA # Forward_tag
        LDX # 1
        JSR caml_alloc
        LDA ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y
        DEY
        JMP caml_load_newblk   
}

!ifdef caml_PRIM__caml_set_oo_id {
caml_set_oo_id
        LDY # 3
        LDA caml_OOID + 1
        STA (ACCU),Y
        DEY
        LDA caml_OOID
        STA (ACCU),Y
        LDY # 0
        CLC
        ADC # 2
        STA caml_OOID
        BCC +
        INC caml_OOID + 1
+       RTS
}

!ifdef caml_PRIM__caml_fresh_oo_id {
caml_fresh_oo_id
        LDA caml_OOID + 1
        STA ACCU + 1
        LDA caml_OOID
        STA ACCU
        CLC
        ADC # 2
        STA caml_OOID
        BCC +
        INC caml_OOID + 1
+       RTS
}

!ifdef caml_PRIM__caml_int_as_pointer {
        ;; ACCU = n
caml_int_as_pointer
        DEC ACCU
        RTS
}

}      ;; !zone caml_OBJ
