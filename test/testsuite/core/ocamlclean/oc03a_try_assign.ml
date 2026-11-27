(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f = try f () with _ -> fail (s ^ " EXN")
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
(* probes Step2 PUSHTRAP: handler sees the stack as at PUSHTRAP, ignoring ASSIGN *)
let () =
  let r = ref 0 in
  (try
     r := 1;
     if List.length ["x"] = 1 then raise Exit;
     r := 2
   with Exit -> ());
  check "r after try (expect 1)" (!r = 1);
  let n = ref 0 in
  let m = ref 0 in
  (try
     n := 10;
     m := 20;
     if List.length ["x"] = 1 then raise Not_found;
     n := 11
   with Not_found -> m := !m + !n);
  check "handler reads assigned" (!m = 30 && !n = 10);
  finish "OC03A"
