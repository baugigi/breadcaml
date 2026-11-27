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
let a = List.length ["x"]
let b = List.length ["x"; "y"]
let c = List.length ["x"; "y"; "z"]
let add3 x = x + a + b + c
let k = List.length ["x"; "y"; "z"; "w"]
let rec f n = if n = 0 then k else g (n - 1)
and g n = f n + 0
let mk =
  let p = List.length ["x"; "y"; "z"; "w"; "v"] in
  let q = List.length ["x"; "y"; "z"; "w"; "v"; "u"; "t"] in
  fun x -> x * p + q
let () =
  check "env3" (add3 10 = 16);
  check "rec env" (f 5 = 4);
  check "mk" (mk 2 = 17);
  finish "OC02"
