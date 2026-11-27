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
let f0 x = x + 0
let f1 x = x + 1
let f2 x = x + 2
let f3 x = x + 3
let f4 x = x + 4
let f5 x = x + 5
let f6 x = x + 6
let f7 x = x + 7
let f8 x = x + 8
let f9 x = x + 9
let f10 x = x + 10
let f11 x = x + 11
let f12 x = x + 12
let f13 x = x + 13
let g1 = f1
let g3 = f3
let g5 = f5
let g7 = f7
let g9 = f9
let g11 = f11
let g13 = f13
let () =
  let s = f0 0 + f1 0 + f2 0 + f3 0 + f4 0 + f5 0 + f6 0 + f7 0 + f8 0 + f9 0 + f10 0 + f11 0 + f12 0 + f13 0 in
  check "sum f" (s = 91);
  check "alias g" (g1 0 + g3 0 + g5 0 + g7 0 + g9 0 + g11 0 + g13 0 = 49);
  finish "OC08"
