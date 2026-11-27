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
(* t_bk03: pila OCaml e pila hardware con BASIC ROM spenta. Ricorsione non in
   coda (frame OCaml sopra $A000 con -mem 0xCFFF) con chiamate FP e stampa
   (CHROUT) alla massima profondita', ed eccezioni che risalgono i frame. *)
let burn k = for i = 1 to k do ignore (List.init 20 (fun j -> j + i)) done
let near a b = abs_float (a -. b) <= 1e-5 *. (1.0 +. abs_float b)
let rec deep n = if n = 0 then sqrt 16.0 else deep (n - 1) +. 0.0
let rec deep_sum n = if n = 0 then 0 else n + deep_sum (n - 1)
let rec deep_fp n acc = if n = 0 then acc else sqrt (deep_fp (n - 1) acc *. 1.0)
exception Bottom of int
let rec deep_exn n = if n = 0 then raise (Bottom 7) else 1 + deep_exn (n - 1)
let keep = List.init 30 (fun i -> i * 11)
let t_deep () =
  for r = 1 to 6 do
    burn (60 + r * 29);
    check2 "deep " r 0 (near (deep (150 + r * 10)) 4.0);
    check2 "deep_sum " r 0 (deep_sum 200 = 20100);
    check2 "deep_fp " r 0 (near (deep_fp 100 16.0) 1.0);
    check2 "keep " r 0 (List.nth keep 29 = 319 && List.length keep = 30)
  done
let t_exn () =
  for r = 1 to 6 do
    burn (70 + r * 31);
    (try ignore (deep_exn (200 + r)); fail "exn NOEXN"
     with Bottom 7 -> () | _ -> fail "exn BADEXN");
    check2 "keep " r 0 (List.nth keep 29 = 319)
  done
let t_io () =
  (* stampa con dati vivi: una riga sola, poi riga di esito *)
  print_newline ();
  for r = 1 to 6 do
    burn (40 + r * 47);
    print_string (string_of_int (r * 111));
    print_string " ";
    print_string (string_of_float (float_of_int r *. 0.5));
    print_string ";";
    check2 "keep " r 0 (List.nth keep 15 = 165)
  done;
  print_newline ()
let () =
  run "deep" t_deep;
  run "exn" t_exn;
  run "io" t_io;
  finish "BK03"
