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
let f =
  let a = List.length ["x"] in
  let b = List.length ["x"; "y"] in
  fun x -> x + a * 10 + b * 100
let g =
  let c = List.length ["x"] in
  ((fun x -> x + c), (fun x -> x - c))
let () =
  check "f" (f 1 = 211);
  let (p, q) = g in
  check "g" (p 5 = 6 && q 5 = 4);
  finish "OC05"
