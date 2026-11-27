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
let () =
  let a = Array.make 10 0 in
  Array.fill a 2 5 7;
  check "fill mid" (a.(1) = 0 && a.(2) = 7 && a.(6) = 7 && a.(7) = 0);
  let b = Array.make 255 1 in
  Array.fill b 0 255 9;
  let ok = ref true in
  for i = 0 to 254 do if b.(i) <> 9 then ok := false done;
  check "fill 255" !ok;
  Array.fill b 127 2 3;
  check "fill 127..128" (b.(126) = 9 && b.(127) = 3 && b.(128) = 3 && b.(129) = 9);
  Array.fill b 0 0 5;
  check "fill 0" (b.(0) = 9);
  let f = Array.make 40 1.5 in
  Array.fill f 3 30 2.5;
  check "fill float" (f.(2) = 1.5 && f.(3) = 2.5 && f.(32) = 2.5 && f.(33) = 1.5);
  raises_inv "fill bad" (fun () -> Array.fill b 200 100 0);
  finish "T90"
