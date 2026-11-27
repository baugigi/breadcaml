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
let boom n = if n > 0 then raise (Failure "b") else n
let () =
  let a = List.length ["x"] in
  let b = List.length ["x"; "y"] in
  let r =
    try
      let c = a + b in
      (try ignore (boom c); 0 with Failure _ -> c * 10)
    with _ -> -1 in
  check "nested" (r = 30);
  let r2 = try (try raise Not_found with Not_found -> raise Exit) with Exit -> a + b in
  check "reraise" (r2 = 3);
  finish "OC09"
