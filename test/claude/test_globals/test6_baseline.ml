(* TEST 6 - BASELINE: nessun global mutato, solo pressione sullo heap
   dinamico puro. Serve a isolare un'eventuale regressione generale
   (es. .heap_start/.halfsz ricalcolati male) da un bug specifico del
   nuovo passo di scansione dei campi dei globals: se T6 fallisce ma gli
   altri test coinvolgono comunque i globals, il problema e' nel
   ricalcolo dei bound dello heap, non nella logica di scansione. *)

let rec build n acc = if n = 0 then acc else build (n - 1) (n :: acc)
let sum l = List.fold_left (+) 0 l

let () =
  let rec loop i acc =
    if i = 0 then acc
    else loop (i - 1) (sum (build 500 []) + acc)
  in
  let total = loop 20 0 in
  print_string "T6 "; print_int total;
  print_newline ();
  if total = 2505000               (* (sum 1..500 = 125250) * 20 *)
  then print_string "T6 OK\n"
  else print_string "T6 FAIL\n"
