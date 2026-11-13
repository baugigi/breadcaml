(* TEST 7 - dimostra un blocco che la strategia 1 (globals dentro lo
   heap) rifiuta con Out_of_memory, mentre la strategia 2 (globals
   fuori dallo heap) lo accetta, a parita' di top_of_mem/stack_pages.

   MECCANISMO: la strategia 1 riserva G byte (area globals) dentro
   OGNI meta' dello heap, perche' vengono ricopiati ad ogni GC. La
   strategia 2 li tiene fuori da entrambe le meta'. Lo spazio dinamico
   utilizzabile per meta' e' quindi:

       utilizzabile_1 = T/2 - G
       utilizzabile_2 = T/2 - G/2 = utilizzabile_1 + G/2

   dove T = caml_stack_start - caml_glob_data, G = caml_glob_end -
   caml_glob_data (dimensione dell'area globals).

   Le sei stringhe letterali sotto sono riconosciute come costanti da
   ocamlc e finiscono quindi nell'area globals statica (caml_glob_data).
   Ciascuna ha 508 caratteri -> size = 508/2+1 = 255 parole, il MASSIMO
   consentito per un singolo blocco (limite: il campo 'size' nell'header
   e' un byte). Bytes per blocco = 2 (header) + 2*255 = 512.
   6 stringhe ~ G aggiuntivo di ~3072 byte -> margine G/2 ~ 1536 byte:
   ampio, cosi' non serve calcolare N al byte esatto. *)

let s1 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
let s2 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
let s3 = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
let s4 = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
let s5 = "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
let s6 = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

let () =
  let g_size =
    String.length s1 + String.length s2 + String.length s3
    + String.length s4 + String.length s5 + String.length s6 in
  print_string "G~"; print_int g_size; print_newline ()

(* ===== Blocco dinamico "al limite" =====
   Modifica SOLO questa costante per cercare il punto di rottura:
   ogni elemento occupa 1 parola (2 byte); il blocco intero occupa
   2 + 2*n byte (header + campi). Il massimo per un singolo blocco e'
   n = 255 (2 + 510 = 512 byte): se non basta a far scattare la
   differenza, dividi il blocco in due Array.make consecutivi tenuti
   entrambi vivi, oppure riduci il top_of_mem in compilazione. *)
let n = 200

let () =
  try
    let a = Array.make n 0 in
    a.(0) <- 1; a.(n - 1) <- 2;        (* tocca il blocco, niente ottimizzazioni *)
    print_string "ALLOC OK n="; print_int n; print_newline ();
    print_string "check="; print_int (a.(0) + a.(n - 1)); print_newline ()
  with Out_of_memory ->
    print_string "OUT OF MEMORY n="; print_int n; print_newline ()
