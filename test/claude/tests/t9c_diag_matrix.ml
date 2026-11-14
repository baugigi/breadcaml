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
let l a = Array.length a
let () =
  run "mk16 int" (fun () -> check "len" (l (Array.make 16 0) = 16));
  run "mk16 atom" (fun () -> check "len" (l (Array.make 16 [||]) = 16));
  run "mk16 blk" (fun () -> check "len" (l (Array.make 16 (Array.make 3 0)) = 16));
  run "mk0 atom" (fun () -> check "len" (l (Array.make 0 [||]) = 0));
  run "uset" (fun () ->
    let r = Array.make 4 [||] in
    Array.unsafe_set r 0 (Array.make 3 0);
    check "uset" (l (Array.unsafe_get r 0) = 3));
  run "set" (fun () ->
    let r = Array.make 4 [||] in
    r.(1) <- Array.make 3 7;
    check "set" (r.(1).(2) = 7));
  run "mat 1x1" (fun () -> check "m" ((Array.make_matrix 1 1 5).(0).(0) = 5));
  run "mat 2x2" (fun () -> check "m" ((Array.make_matrix 2 2 5).(1).(1) = 5));
  run "mat 4x4" (fun () -> check "m" ((Array.make_matrix 4 4 5).(3).(3) = 5));
  run "mat 8x8" (fun () -> check "m" ((Array.make_matrix 8 8 5).(7).(7) = 5));
  run "mat 16x16" (fun () -> check "m" ((Array.make_matrix 16 16 5).(15).(15) = 5));
  run "mat 16x16 float" (fun () -> check "m" ((Array.make_matrix 4 4 1.5).(3).(3) = 1.5));
  finish "D_MAT"
