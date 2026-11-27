(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f =
  try f () with
  | Stack_overflow -> fail (s ^ " STACK")
  | Out_of_memory -> fail (s ^ " OOM")
  | Not_found -> fail (s ^ " NOTFOUND")
  | Failure m -> fail (s ^ " FAILURE " ^ m)
  | Invalid_argument m -> fail (s ^ " INVARG " ^ m)
  | _ -> fail (s ^ " EXN")
let raises_inv s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Invalid_argument _ -> () | _ -> fail (s ^ " BADEXN")
let raises_dz s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Division_by_zero -> () | _ -> fail (s ^ " BADEXN")
let finish t =
  print_string t;
  if !fails = 0 then print_string " OK" else print_string " FAIL";
  print_newline ()
(* ---- fine prelude ---- *)
(* t_bk04: errori di sistema BASIC (caml_syserr) con BASIC ROM spenta.
   sqrt di un negativo, log 0, conversioni fuori intervallo: il gestore
   riaccende/spegne la ROM e solleva eccezioni OCaml. Il risultato esatto
   (eccezione o valore) dipende dal runtime; qui conta che il programma
   non vada fuori controllo e che i dati in heap restino intatti. *)
let burn k = for i = 1 to k do ignore (List.init 20 (fun j -> j + i)) done
let keep = List.init 40 (fun i -> i * 5 + 2)
let fa = Array.init 20 (fun i -> float_of_int i +. 0.25)
let verify r =
  check2 "keep " r 0 (List.nth keep 39 = 197 && List.hd keep = 2);
  check2 "fa " r 0 (let ok = ref true in
    Array.iteri (fun i x -> if x <> float_of_int i +. 0.25 then ok := false) fa; !ok)
let swallow f = try ignore (f ()) with _ -> ()
let t_sys () =
  for r = 1 to 8 do
    burn (60 + r * 43);
    swallow (fun () -> sqrt (-1.0));
    swallow (fun () -> log 0.0);
    swallow (fun () -> int_of_float 1e30);
    swallow (fun () -> 1.0 /. 0.0);
    swallow (fun () -> exp 1000.0);
    swallow (fun () -> float_of_string "abc");
    verify r
  done
let t_msg () =
  (* messaggio di errore BASIC copiato dalla ROM in una stringa OCaml *)
  for r = 1 to 4 do
    burn (90 + r * 33);
    (try ignore (exp 1000.0)
     with Sys_error m -> check2 "msg len " r 0 (String.length m > 0 && String.length m < 23)
        | _ -> ());
    verify r
  done
let t_after () =
  (* dopo gli errori le routine FP funzionano ancora *)
  burn 300;
  check "sqrt after" (abs_float (sqrt 16.0 -. 4.0) < 1e-6);
  check "exp after" (abs_float (exp 0.0 -. 1.0) < 1e-6);
  check "dz int" (try ignore (1 / (List.length keep - 40)); false with Division_by_zero -> true);
  verify 99
let () =
  run "sys" t_sys;
  run "msg" t_msg;
  run "after" t_after;
  finish "BK04"
