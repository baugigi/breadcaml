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
  let a = Float.Array.create 10 in
  Float.Array.fill a 0 10 1.5;
  check "fill" (Float.Array.get a 0 = 1.5 && Float.Array.get a 9 = 1.5);
  Float.Array.set a 3 2.5;
  check "set" (Float.Array.get a 3 = 2.5 && Float.Array.length a = 10);
  let b = Float.Array.make 85 0.5 in
  check "make 85" (Float.Array.length b = 85 && Float.Array.get b 84 = 0.5);
  Float.Array.blit a 0 b 80 5;
  check "blit" (Float.Array.get b 80 = 1.5 && Float.Array.get b 83 = 2.5 && Float.Array.get b 79 = 0.5);
  let c = Float.Array.append a a in
  check "append" (Float.Array.length c = 20 && Float.Array.get c 13 = 2.5);
  let d = Float.Array.sub b 80 5 in
  check "sub" (Float.Array.length d = 5 && Float.Array.get d 3 = 2.5);
  let e = Float.Array.copy a in
  Float.Array.set e 0 9.0;
  check "copy" (Float.Array.get a 0 = 1.5);
  raises_inv "oob" (fun () -> Float.Array.get b 85);
  finish "T94"
