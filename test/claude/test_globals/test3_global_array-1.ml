(* TEST 3 - array globale ordinario (tag 0, campi-puntatore), con un
   elemento riassegnato a un blocco dinamico. Verifica che i blocchi
   array tra i globals (non No_scan_tag) vengano scansionati campo per
   campo correttamente dal nuovo passo, non solo i record semplici. *)

let churn_count = 1500
let rec build n acc = if n = 0 then acc else build (n - 1) (n :: acc)
let churn () = ignore (build churn_count [])
let sum l = List.fold_left (+) 0 l

let g = Array.make 5 []   (* array globale di liste, inizialmente vuote *)

let () =
  g.(2) <- build 30 [];     (* somma nota = 465, blocco dinamico *)
  churn ();
  let s1 = sum g.(2) in
  churn (); churn ();
  let s2 = sum g.(2) in
  print_string "T3 "; print_int s1; print_string " "; print_int s2;
  print_newline ();
  if s1 = 465 && s2 = 465
  then print_string "T3 OK\n"
  else print_string "T3 FAIL\n"
