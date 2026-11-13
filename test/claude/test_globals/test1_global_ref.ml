(* TEST 1 - ref globale riassegnato a un blocco dinamico, attraverso piu'
   cicli di GC forzati da pressione sullo heap.
   Verifica mirata: il nuovo passo "scansiona i campi dei blocchi globals",
   nel caso piu' semplice possibile: una sola indirezione (ref -> lista). *)

let churn_count = 1500   (* aumenta se la GC non scatta con il tuo heap *)

let rec build n acc =
  if n = 0 then acc else build (n - 1) (n :: acc)

let churn () = ignore (build churn_count [])

let sum l = List.fold_left (+) 0 l

let g : int list ref = ref []   (* cella statica nell'area globals *)

let () =
  g := build 100 [];             (* 1+2+...+100 = 5050, blocco dinamico *)
  churn (); churn ();
  let s1 = sum !g in
  churn ();
  let s2 = sum !g in
  print_string "T1 "; print_int s1; print_string " "; print_int s2;
  print_newline ();
  if s1 = 5050 && s2 = 5050
  then print_string "T1 OK\n"
  else print_string "T1 FAIL\n"
