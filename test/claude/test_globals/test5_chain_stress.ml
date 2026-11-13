(* TEST 5 - stress: il campo del ref globale viene riassegnato ad OGNI
   iterazione a un blocco dinamico nuovo, intercalato da pressione GC.
   E' il pattern piu' comune nel codice OCaml reale (stato mutabile
   top-level aggiornato funzionalmente) e mette alla prova la ripetuta
   riscoperta/forwarding dello stesso campo globals attraverso molti
   cicli di GC consecutivi, non solo uno o due. *)

let churn_count = 800
let rec build n acc = if n = 0 then acc else build (n - 1) (n :: acc)
let churn () = ignore (build churn_count [])
let sum l = List.fold_left (+) 0 l
let len l = List.length l

let g : int list ref = ref []

let () =
  let rec loop i =
    if i = 0 then ()
    else begin
      g := i :: !g;              (* riassegna il campo ad OGNI iterazione *)
      churn ();
      loop (i - 1)
    end
  in
  loop 200;
  let s = sum !g and n = len !g in
  print_string "T5 "; print_int s; print_string " "; print_int n;
  print_newline ();
  if s = 20100 && n = 200         (* 1+2+...+200 = 20100 *)
  then print_string "T5 OK\n"
  else print_string "T5 FAIL\n"
