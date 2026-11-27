;; Primitiva di test per t_bk05: external addr : 'a -> int = "bk_addr"
;; Restituisce Val_int(indirizzo / 2) del blocco in ACCU, cioe' la parola del
;; puntatore con il bit 0 impostato (l'indirizzo e' pari). Il risultato e' un
;; intero a 15 bit con segno: $A000-$BFFF -> -12288 .. -8193.
bk_addr
        LDA ACCU
        ORA # 1
        STA ACCU
        LDY # 0                         ;Y = 0 on exit
        RTS
