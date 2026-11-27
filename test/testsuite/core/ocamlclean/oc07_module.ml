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
module M = struct
  let a = ref 0
  let f () = incr a; !a
  let c = "x"
  let d = 5
  let g = f
  let unused1 () = 42
  let unused2 = [1; 2; 3]
end
let () =
  check "M.f" (M.f () = 1 && M.f () = 2);
  check "M.g" (M.g () = 3);
  check "M.d" (M.d = 5 && String.length M.c = 1);
  finish "OC07"
