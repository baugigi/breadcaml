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
(* ---- fine prelude ---- *)
let rec cnt n = if n = 0 then 0 else 1 + cnt (n - 1)
let over1 a = if a > 1000 then (fun b -> 0) else (fun b -> a + b)
let over3 a = if a > 1000 then (fun b c d -> 0) else (fun b c d -> a + b + c + d)
let rec evn n = if n = 0 then true else odd (n - 1)
and odd n = if n = 0 then false else evn (n - 1)
let () =
  run "over" (fun () -> check "over1" (over1 1 2 = 3); check "over3" (over3 1 2 3 4 = 10); let f = over3 1 2 in check "over3 partial" (f 3 4 = 10 && f 10 20 = 33));
  run "cnt" (fun () -> check "cnt50" (cnt 50 = 50); check "cnt100" (cnt 100 = 100));
  run "evodd" (fun () -> check "evn 100" (evn 100); check "odd 101" (odd 101); check "evn 101" (not (evn 101)));
  finish "T07N"
