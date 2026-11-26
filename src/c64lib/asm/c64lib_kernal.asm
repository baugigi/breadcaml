;; ——————————————————————————————————————————————————————————————————————
;; C64.Hw.Kernal: thin wrappers around the Kernal I/O routines (through the
;; jump table at $FF81-$FFF3, so that alternative Kernals work too).
;;
;; Conventions as in c64lib_hw.asm: the arguments are not popped here, ACCU = 1st
;; argument, SP[0] = 2nd, ...; 8-bit values are taken modulo 256; every
;; primitive returns with Y = 0.  No primitive allocates, so no GC issue arises
;; (the name strings are read in place while the Kernal runs).
;;
;; A primitive that may fail returns the Kernal error code (0 = no error;
;; 1 too many files, 2 file open, 3 file not open, 4 file not found, 5 device
;; not present, 6 not input file, 7 not output file, 8 missing file name,
;; 9 illegal device number).  Most DOS errors (e.g. a missing file on OPEN) are
;; NOT reported here but by the drive error channel and the status byte (READST).
;;
;; Kernal messages (SEARCHING FOR, LOADING...) are switched off by LOAD/SAVE.
;; File names must be at most 255 characters long.
;; ——————————————————————————————————————————————————————————————————————

!zone caml_C64_KN {

!macro caml_kn_a8 {                     ;A := low 8 bits of Int_val(ACCU)
        LDA ACCU + 1
        LSR
        LDA ACCU
        ROR
}
!macro caml_kn_s8 .n {                  ;A := low 8 bits of Int_val(SP[.n])  {Y = 0}
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # 0
}
!macro caml_kn_ret8 {                   ;ACCU := Val_int(A)
        LDY # 0
        STY ACCU + 1
        SEC
        ROL
        STA ACCU
        ROL ACCU + 1
}
!macro caml_kn_ret_err {                ;after a Kernal call: Val_int(C ? A : 0)
        BCS +
        LDA # 0
+       +caml_kn_ret8
}
!macro caml_kn_ret_unit {
        LDY # 0
        LDX # <Val_unit
        STX ACCU
        STY ACCU + 1
}
!macro caml_kn_nameptr .n {             ;ACCU := string SP[.n]  {Y = 0}
        LDY # .n * 2                    ;(then the caller must JSR
        LDA (SP),Y                      ; caml_string_length_yx, which is
        STA ACCU                        ; not called here, otherwise mkdepends
        INY                             ; would not see the dependency)
        LDA (SP),Y
        STA ACCU + 1
        LDY # 0
}
!macro caml_kn_setnam {                 ;SETNAM for ACCU, .Y,.X = length
        TXA
        BEQ +
        LDY # 255                       ;longer than 255: truncated
+       TYA                             ;A := length
        LDX ACCU
        LDY ACCU + 1
        JSR C64_KSETNAM
}

;; open_file lfn dev sa name -> error code
!ifdef caml_PRIM__caml_nonstd_kn_open {
caml_nonstd_kn_open
        +caml_kn_s8 1                   ;secondary address
        STA TMP
        +caml_kn_s8 0                   ;device
        TAX
        +caml_kn_a8                     ;logical file number
        LDY TMP
        JSR C64_KSETLFS
        +caml_kn_nameptr 2
        JSR caml_string_length_yx
        +caml_kn_setnam
        JSR C64_KOPEN
        +caml_kn_ret_err
        RTS
}
;; close lfn -> unit
!ifdef caml_PRIM__caml_nonstd_kn_close {
caml_nonstd_kn_close
        +caml_kn_a8
        JSR C64_KCLOSE
        +caml_kn_ret_unit
        RTS
}
;; chkin lfn / chkout lfn -> error code
!ifdef caml_PRIM__caml_nonstd_kn_chkin {
caml_nonstd_kn_chkin
        +caml_kn_a8
        TAX
        JSR C64_KCHKIN
        +caml_kn_ret_err
        RTS
}
!ifdef caml_PRIM__caml_nonstd_kn_chkout {
caml_nonstd_kn_chkout
        +caml_kn_a8
        TAX
        JSR C64_KCHKOUT
        +caml_kn_ret_err
        RTS
}
;; clrchn () / clall () -> unit
!ifdef caml_PRIM__caml_nonstd_kn_clrchn {
caml_nonstd_kn_clrchn
        JSR C64_KCLRCHN
        +caml_kn_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_kn_clall {
caml_nonstd_kn_clall
        JSR C64_KCLALL
        +caml_kn_ret_unit
        RTS
}
;; chrin () -> byte (0..255); chrout byte -> unit; readst () -> status byte
!ifdef caml_PRIM__caml_nonstd_kn_chrin {
caml_nonstd_kn_chrin
        JSR C64_KCHRIN
        +caml_kn_ret8
        RTS
}
!ifdef caml_PRIM__caml_nonstd_kn_chrout {
caml_nonstd_kn_chrout
        +caml_kn_a8
        JSR C64_KCHROUT
        +caml_kn_ret_unit
        RTS
}
!ifdef caml_PRIM__caml_nonstd_kn_readst {
caml_nonstd_kn_readst
        JSR C64_KREADST
        +caml_kn_ret8
        RTS
}
;; load dev sa name page off -> error code.  The end address (last byte + 1) is
;; left in the Kernal variable EAL/EAH ($AE/$AF).  With sa = 0 the file is
;; loaded at page:off, otherwise at the address stored in the file.
!ifdef caml_PRIM__caml_nonstd_kn_load {
caml_nonstd_kn_load
        LDA # 0
        JSR C64_KSETMSG                 ;no Kernal messages
        +caml_kn_s8 0                   ;secondary address
        TAY
        +caml_kn_a8                     ;device
        TAX
        LDA # 1                         ;logical file number (not used)
        JSR C64_KSETLFS
        +caml_kn_s8 3                   ;off
        STA TMP
        +caml_kn_s8 2                   ;page
        STA TMP + 1
        +caml_kn_nameptr 1
        JSR caml_string_length_yx
        +caml_kn_setnam
        LDX TMP
        LDY TMP + 1
        LDA # 0                         ;0 = load
        JSR C64_KLOAD
        BCS +
        STX C64_EAL                     ;whichever the Kernal version,
        STY C64_EAL + 1                 ; the end address is in EAL/EAH
+       +caml_kn_ret_err
        RTS
}
;; set_range spage soff epage eoff -> unit:
;; STAL := start, EAL := end (= last byte + 1)
!ifdef caml_PRIM__caml_nonstd_kn_range {
caml_nonstd_kn_range
        +caml_kn_a8
        STA C64_STAL + 1
        +caml_kn_s8 0
        STA C64_STAL
        +caml_kn_s8 1
        STA C64_EAL + 1
        +caml_kn_s8 2
        STA C64_EAL
        +caml_kn_ret_unit
        RTS
}
;; save dev name -> error code: save STAL..EAL-1 (see set_range).
!ifdef caml_PRIM__caml_nonstd_kn_save {
caml_nonstd_kn_save
        LDA # 0
        JSR C64_KSETMSG                 ;no Kernal messages
        +caml_kn_a8                     ;device
        TAX
        LDA # 1                         ;logical file number (not used)
        LDY # 1                         ;secondary address (forced by Kernal)
        JSR C64_KSETLFS
        +caml_kn_nameptr 0
        JSR caml_string_length_yx
        +caml_kn_setnam
        LDA # C64_STAL                  ;zero page address of the start pointer
        LDX C64_EAL
        LDY C64_EAL + 1
        JSR C64_KSAVE
        +caml_kn_ret_err
        RTS
}

} ;!zone caml_C64_KN
