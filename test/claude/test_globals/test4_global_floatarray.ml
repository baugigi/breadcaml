(* TEST 4 - array di float globale (Double_array_tag >= No_scan_tag).
   Il nuovo passo deve SALTARE la scansione campo-per-campo per questo
   blocco (come gia' fa lo step 3 per lo heap dinamico) e avanzare solo
   in base alla size. Se i bound del salto fossero sbagliati di un byte,
   qui si manifesterebbe come corruzione dei valori dopo ripetute GC. *)

let churn_count = 1500
let rec build n acc = if n = 0 then acc else build (n - 1) (n :: acc)
let churn () = ignore (build churn_count [])

let fa = [| 1.5; 2.25; -3.75; 100.0; 0.0; 42.0 |]

let check () =
  fa.(0) = 1.5 && fa.(1) = 2.25 && fa.(2) = -3.75
  && fa.(3) = 100.0 && fa.(4) = 0.0 && fa.(5) = 42.0

let () =
  let rec loop i =
    if i = 0 then ()
    else (churn (); loop (i - 1))
  in
  loop 10;                        (* 10 cicli di pressione GC consecutivi *)
  if check ()
  then print_string "T4 OK\n"
  else print_string "T4 FAIL\n"
