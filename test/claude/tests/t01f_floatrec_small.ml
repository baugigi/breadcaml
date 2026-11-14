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
type f1 = { mutable y1_0: float }
let mk1 a = { y1_0 = a +. 0.0 }
let sum1 r = r.y1_0
let mka1 a = [| a +. 0.0 |]
let suma1 x = x.(0)
let t1 () =
  let r = mk1 2.0 in
  check "f1 sum0" (sum1 r = 2.0);
  check "f1.y0" (r.y1_0 = 2.0);
  r.y1_0 <- 100.5;
  check "f1 sum1" (sum1 r = 100.5);
  check "f1.y0 b" (r.y1_0 = 100.5);
  for it = 1 to 40 do checkn "f1 sum loop " it (sum1 r = 100.5) done;
  let x = mka1 2.0 in
  check "arrlit len 1" (Array.length x = 1);
  check "arrlit sum0 1" (suma1 x = 2.0);
  x.(0) <- 100.5;
  check "arrlit sum1 1" (suma1 x = 100.5);
  for it = 1 to 40 do checkn "arrlit loop " it (suma1 x = 100.5) done
type f2 = { mutable y2_0: float; mutable y2_1: float }
let mk2 a = { y2_0 = a +. 0.0; y2_1 = a +. 1.0 }
let sum2 r = r.y2_0 +. r.y2_1
let mka2 a = [| a +. 0.0; a +. 1.0 |]
let suma2 x = x.(0) +. x.(1)
let t2 () =
  let r = mk2 2.0 in
  check "f2 sum0" (sum2 r = 5.0);
  check "f2.y0" (r.y2_0 = 2.0);
  check "f2.y1" (r.y2_1 = 3.0);
  r.y2_0 <- 100.5;
  r.y2_1 <- 101.5;
  check "f2 sum1" (sum2 r = 202.0);
  check "f2.y0 b" (r.y2_0 = 100.5);
  check "f2.y1 b" (r.y2_1 = 101.5);
  for it = 1 to 40 do checkn "f2 sum loop " it (sum2 r = 202.0) done;
  let x = mka2 2.0 in
  check "arrlit len 2" (Array.length x = 2);
  check "arrlit sum0 2" (suma2 x = 5.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  check "arrlit sum1 2" (suma2 x = 202.0);
  for it = 1 to 40 do checkn "arrlit loop " it (suma2 x = 202.0) done
type f3 = { mutable y3_0: float; mutable y3_1: float; mutable y3_2: float }
let mk3 a = { y3_0 = a +. 0.0; y3_1 = a +. 1.0; y3_2 = a +. 2.0 }
let sum3 r = r.y3_0 +. r.y3_1 +. r.y3_2
let mka3 a = [| a +. 0.0; a +. 1.0; a +. 2.0 |]
let suma3 x = x.(0) +. x.(1) +. x.(2)
let t3 () =
  let r = mk3 2.0 in
  check "f3 sum0" (sum3 r = 9.0);
  check "f3.y0" (r.y3_0 = 2.0);
  check "f3.y1" (r.y3_1 = 3.0);
  check "f3.y2" (r.y3_2 = 4.0);
  r.y3_0 <- 100.5;
  r.y3_1 <- 101.5;
  r.y3_2 <- 102.5;
  check "f3 sum1" (sum3 r = 304.5);
  check "f3.y0 b" (r.y3_0 = 100.5);
  check "f3.y1 b" (r.y3_1 = 101.5);
  check "f3.y2 b" (r.y3_2 = 102.5);
  for it = 1 to 40 do checkn "f3 sum loop " it (sum3 r = 304.5) done;
  let x = mka3 2.0 in
  check "arrlit len 3" (Array.length x = 3);
  check "arrlit sum0 3" (suma3 x = 9.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  x.(2) <- 102.5;
  check "arrlit sum1 3" (suma3 x = 304.5);
  for it = 1 to 40 do checkn "arrlit loop " it (suma3 x = 304.5) done
type f4 = { mutable y4_0: float; mutable y4_1: float; mutable y4_2: float; mutable y4_3: float }
let mk4 a = { y4_0 = a +. 0.0; y4_1 = a +. 1.0; y4_2 = a +. 2.0; y4_3 = a +. 3.0 }
let sum4 r = r.y4_0 +. r.y4_1 +. r.y4_2 +. r.y4_3
let mka4 a = [| a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0 |]
let suma4 x = x.(0) +. x.(1) +. x.(2) +. x.(3)
let t4 () =
  let r = mk4 2.0 in
  check "f4 sum0" (sum4 r = 14.0);
  check "f4.y0" (r.y4_0 = 2.0);
  check "f4.y1" (r.y4_1 = 3.0);
  check "f4.y2" (r.y4_2 = 4.0);
  check "f4.y3" (r.y4_3 = 5.0);
  r.y4_0 <- 100.5;
  r.y4_1 <- 101.5;
  r.y4_2 <- 102.5;
  r.y4_3 <- 103.5;
  check "f4 sum1" (sum4 r = 408.0);
  check "f4.y0 b" (r.y4_0 = 100.5);
  check "f4.y1 b" (r.y4_1 = 101.5);
  check "f4.y2 b" (r.y4_2 = 102.5);
  check "f4.y3 b" (r.y4_3 = 103.5);
  for it = 1 to 40 do checkn "f4 sum loop " it (sum4 r = 408.0) done;
  let x = mka4 2.0 in
  check "arrlit len 4" (Array.length x = 4);
  check "arrlit sum0 4" (suma4 x = 14.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  x.(2) <- 102.5;
  x.(3) <- 103.5;
  check "arrlit sum1 4" (suma4 x = 408.0);
  for it = 1 to 40 do checkn "arrlit loop " it (suma4 x = 408.0) done
type f10 = { mutable y10_0: float; mutable y10_1: float; mutable y10_2: float; mutable y10_3: float; mutable y10_4: float; mutable y10_5: float; mutable y10_6: float; mutable y10_7: float; mutable y10_8: float; mutable y10_9: float }
let mk10 a = { y10_0 = a +. 0.0; y10_1 = a +. 1.0; y10_2 = a +. 2.0; y10_3 = a +. 3.0; y10_4 = a +. 4.0; y10_5 = a +. 5.0; y10_6 = a +. 6.0; y10_7 = a +. 7.0; y10_8 = a +. 8.0; y10_9 = a +. 9.0 }
let sum10 r = r.y10_0 +. r.y10_1 +. r.y10_2 +. r.y10_3 +. r.y10_4 +. r.y10_5 +. r.y10_6 +. r.y10_7 +. r.y10_8 +. r.y10_9
let mka10 a = [| a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0 |]
let suma10 x = x.(0) +. x.(1) +. x.(2) +. x.(3) +. x.(4) +. x.(5) +. x.(6) +. x.(7) +. x.(8) +. x.(9)
let t10 () =
  let r = mk10 2.0 in
  check "f10 sum0" (sum10 r = 65.0);
  check "f10.y0" (r.y10_0 = 2.0);
  check "f10.y1" (r.y10_1 = 3.0);
  check "f10.y2" (r.y10_2 = 4.0);
  check "f10.y3" (r.y10_3 = 5.0);
  check "f10.y4" (r.y10_4 = 6.0);
  check "f10.y5" (r.y10_5 = 7.0);
  check "f10.y7" (r.y10_7 = 9.0);
  check "f10.y8" (r.y10_8 = 10.0);
  check "f10.y9" (r.y10_9 = 11.0);
  r.y10_0 <- 100.5;
  r.y10_1 <- 101.5;
  r.y10_2 <- 102.5;
  r.y10_3 <- 103.5;
  r.y10_4 <- 104.5;
  r.y10_5 <- 105.5;
  r.y10_7 <- 100.5;
  r.y10_8 <- 101.5;
  r.y10_9 <- 102.5;
  check "f10 sum1" (sum10 r = 930.5);
  check "f10.y0 b" (r.y10_0 = 100.5);
  check "f10.y1 b" (r.y10_1 = 101.5);
  check "f10.y2 b" (r.y10_2 = 102.5);
  check "f10.y3 b" (r.y10_3 = 103.5);
  check "f10.y4 b" (r.y10_4 = 104.5);
  check "f10.y5 b" (r.y10_5 = 105.5);
  check "f10.y7 b" (r.y10_7 = 100.5);
  check "f10.y8 b" (r.y10_8 = 101.5);
  check "f10.y9 b" (r.y10_9 = 102.5);
  for it = 1 to 40 do checkn "f10 sum loop " it (sum10 r = 930.5) done;
  let x = mka10 2.0 in
  check "arrlit len 10" (Array.length x = 10);
  check "arrlit sum0 10" (suma10 x = 65.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  x.(2) <- 102.5;
  x.(3) <- 103.5;
  x.(4) <- 104.5;
  x.(5) <- 105.5;
  x.(7) <- 100.5;
  x.(8) <- 101.5;
  x.(9) <- 102.5;
  check "arrlit sum1 10" (suma10 x = 930.5);
  for it = 1 to 40 do checkn "arrlit loop " it (suma10 x = 930.5) done
let () =
  run "f1" t1;
  run "f2" t2;
  run "f3" t3;
  run "f4" t4;
  run "f10" t10;
  finish "T01F"
