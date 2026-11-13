(* TEST 2 - record globale con due campi mutabili, riassegnati a momenti
   diversi. Il campo 'b' e' a sua volta un ref dinamico: mette alla prova
   la raggiungibilita' transitiva a profondita' 2 (globals -> record
   statico -> campo mutato -> ref dinamico -> intero), che richiede sia
   il nuovo passo sui campi dei globals sia il normale scan dinamico dello
   heap, in sequenza, nello stesso ciclo di GC. *)

type t = { mutable a : int list; mutable b : int ref }

let churn_count = 1500
let rec build n acc = if n = 0 then acc else build (n - 1) (n :: acc)
let churn () = ignore (build churn_count [])
let sum l = List.fold_left (+) 0 l

let g = { a = []; b = ref 0 }   (* blocco statico nell'area globals *)

let () =
  g.a <- build 50 [];              (* somma nota = 1275, blocco dinamico *)
  g.b <- ref 999;                  (* ref dinamico: profondita' 2 *)
  churn ();
  let sa1 = sum g.a in
  let sb1 = !(g.b) in
  churn (); churn ();
  let sa2 = sum g.a in
  let sb2 = !(g.b) in
  print_string "T2 "; print_int sa1; print_string " "; print_int sb1;
  print_string " "; print_int sa2; print_string " "; print_int sb2;
  print_newline ();
  if sa1 = 1275 && sb1 = 999 && sa2 = 1275 && sb2 = 999
  then print_string "T2 OK\n"
  else print_string "T2 FAIL\n"
