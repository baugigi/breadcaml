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
let h x = match x with
  | -2 -> 10 | -1 -> 11 | 0 -> 12 | 1 -> 13 | 2 -> 14 | 3 -> 15 | 4 -> 16 | _ -> 0
let th () =
  check "h" (h (-2) = 10 && h (-1) = 11 && h 0 = 12 && h 1 = 13 && h 4 = 16
             && h (-3) = 0 && h 5 = 0 && h 254 = 0 && h (-254) = 0)
let cls ch = match ch with 'a'..'z' -> 1 | 'A'..'Z' -> 2 | '0'..'9' -> 3 | _ -> 0
let pc = [| 0; 47; 48; 57; 58; 64; 65; 90; 91; 96; 97; 122; 128; 192; 193; 218; 219; 255 |]
let ec = [| 0; 0; 3; 3; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 2; 2; 0; 0 |]
let tcls () =
  for i = 0 to 17 do check2 "cls " pc.(i) i (cls (Char.chr pc.(i)) = ec.(i)) done
let () =
  run "h" th;
  run "cls" tcls;
  finish "T06R"
