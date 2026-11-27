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
let () =
  let s = ref 0 in
  for i = 1 to 10 do s := !s + i done;
  check "sum" (!s = 55);
  let i = ref 0 and acc = ref 1 in
  while !i < 5 do acc := !acc * 2; incr i done;
  check "pow" (!acc = 32);
  let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2) in
  check "fib" (fib 10 = 55);
  let k = List.length ["a"; "b"; "c"] in
  let rec cnt n = if n = 0 then k else cnt (n - 1) in
  check "rec-env" (cnt 4 = 3);
  finish "OC06"
