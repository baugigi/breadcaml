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
let zero = List.length []
let () =
  (try let _ = 1 / zero in fail "div NOEXN" with Division_by_zero -> ());
  (try ignore (5 mod zero); fail "mod NOEXN" with Division_by_zero -> ());
  let cnt = ref 0 in
  let _ = (incr cnt; 3) in
  let _ = (incr cnt; "s") in
  check "side effects kept" (!cnt = 2);
  let arr = Array.make 3 0 in
  (try ignore arr.(3); fail "bounds NOEXN" with Invalid_argument _ -> ());
  finish "OC04"
