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
let ap1 a1 = a1
let ap2 a1 a2 = a1 + a2
let ap3 a1 a2 a3 = a1 + a2 + a3
let ap4 a1 a2 a3 a4 = a1 + a2 + a3 + a4
let ap5 a1 a2 a3 a4 a5 = a1 + a2 + a3 + a4 + a5
let ap6 a1 a2 a3 a4 a5 a6 = a1 + a2 + a3 + a4 + a5 + a6
let ap7 a1 a2 a3 a4 a5 a6 a7 = a1 + a2 + a3 + a4 + a5 + a6 + a7
let ap8 a1 a2 a3 a4 a5 a6 a7 a8 = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8
let ap16 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16
let ap31 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 + a21 + a22 + a23 + a24 + a25 + a26 + a27 + a28 + a29 + a30 + a31
let ap32 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 + a21 + a22 + a23 + a24 + a25 + a26 + a27 + a28 + a29 + a30 + a31 + a32
let () =
  run "ap1" (fun () -> checkn "apply " 1 (ap1 1 = 1); ());
  run "ap2" (fun () -> checkn "apply " 2 (ap2 1 2 = 3); let p = ap2 1 in checkn "papply " 2 (p 2 = 3); ());
  run "ap3" (fun () -> checkn "apply " 3 (ap3 1 2 3 = 6); let p = ap3 1 in checkn "papply " 3 (p 2 3 = 6); let q = ap3 1 in let r = q 2 in checkn "papply2 " 3 (r 3 = 6); ());
  run "ap4" (fun () -> checkn "apply " 4 (ap4 1 2 3 4 = 10); let p = ap4 1 2 in checkn "papply " 4 (p 3 4 = 10); let q = ap4 1 in let r = q 2 in checkn "papply2 " 4 (r 3 4 = 10); ());
  run "ap5" (fun () -> checkn "apply " 5 (ap5 1 2 3 4 5 = 15); let p = ap5 1 2 in checkn "papply " 5 (p 3 4 5 = 15); let q = ap5 1 in let r = q 2 in checkn "papply2 " 5 (r 3 4 5 = 15); ());
  run "ap6" (fun () -> checkn "apply " 6 (ap6 1 2 3 4 5 6 = 21); let p = ap6 1 2 3 in checkn "papply " 6 (p 4 5 6 = 21); let q = ap6 1 in let r = q 2 in checkn "papply2 " 6 (r 3 4 5 6 = 21); ());
  run "ap7" (fun () -> checkn "apply " 7 (ap7 1 2 3 4 5 6 7 = 28); let p = ap7 1 2 3 in checkn "papply " 7 (p 4 5 6 7 = 28); let q = ap7 1 in let r = q 2 in checkn "papply2 " 7 (r 3 4 5 6 7 = 28); ());
  run "ap8" (fun () -> checkn "apply " 8 (ap8 1 2 3 4 5 6 7 8 = 36); let p = ap8 1 2 3 4 in checkn "papply " 8 (p 5 6 7 8 = 36); let q = ap8 1 in let r = q 2 in checkn "papply2 " 8 (r 3 4 5 6 7 8 = 36); ());
  run "ap16" (fun () -> checkn "apply " 16 (ap16 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 = 136); let p = ap16 1 2 3 4 5 6 7 8 in checkn "papply " 16 (p 9 10 11 12 13 14 15 16 = 136); let q = ap16 1 in let r = q 2 in checkn "papply2 " 16 (r 3 4 5 6 7 8 9 10 11 12 13 14 15 16 = 136); ());
  run "ap31" (fun () -> checkn "apply " 31 (ap31 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 = 496); let p = ap31 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 in checkn "papply " 31 (p 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 = 496); let q = ap31 1 in let r = q 2 in checkn "papply2 " 31 (r 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 = 496); ());
  run "ap32" (fun () -> checkn "apply " 32 (ap32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 = 528); let p = ap32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 in checkn "papply " 32 (p 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 = 528); let q = ap32 1 in let r = q 2 in checkn "papply2 " 32 (r 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 = 528); ());
  finish "T07G"
