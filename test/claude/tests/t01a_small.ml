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
type r1 = { mutable x1_0: int }
let mk1 a = { x1_0 = a + 0 }
let sum1 r = r.x1_0
let t1 () =
  let r = mk1 5 in
  check "r1 size" (Obj.size (Obj.repr r) = 1);
  check "r1 tag" (Obj.tag (Obj.repr r) = 0);
  check "r1 sum0" (sum1 r = 5);
  check "r1.x0" (r.x1_0 = 5);
  r.x1_0 <- 100;
  check "r1 sum1" (sum1 r = 100);
  check "r1.x0 b" (r.x1_0 = 100)
type r2 = { mutable x2_0: int; mutable x2_1: int }
let mk2 a = { x2_0 = a + 0; x2_1 = a + 1 }
let sum2 r = r.x2_0 + r.x2_1
let t2 () =
  let r = mk2 5 in
  check "r2 size" (Obj.size (Obj.repr r) = 2);
  check "r2 tag" (Obj.tag (Obj.repr r) = 0);
  check "r2 sum0" (sum2 r = 11);
  check "r2.x0" (r.x2_0 = 5);
  check "r2.x1" (r.x2_1 = 6);
  r.x2_0 <- 100;
  r.x2_1 <- 101;
  check "r2 sum1" (sum2 r = 201);
  check "r2.x0 b" (r.x2_0 = 100);
  check "r2.x1 b" (r.x2_1 = 101)
type r3 = { mutable x3_0: int; mutable x3_1: int; mutable x3_2: int }
let mk3 a = { x3_0 = a + 0; x3_1 = a + 1; x3_2 = a + 2 }
let sum3 r = r.x3_0 + r.x3_1 + r.x3_2
let t3 () =
  let r = mk3 5 in
  check "r3 size" (Obj.size (Obj.repr r) = 3);
  check "r3 tag" (Obj.tag (Obj.repr r) = 0);
  check "r3 sum0" (sum3 r = 18);
  check "r3.x0" (r.x3_0 = 5);
  check "r3.x1" (r.x3_1 = 6);
  check "r3.x2" (r.x3_2 = 7);
  r.x3_0 <- 100;
  r.x3_1 <- 101;
  r.x3_2 <- 102;
  check "r3 sum1" (sum3 r = 303);
  check "r3.x0 b" (r.x3_0 = 100);
  check "r3.x1 b" (r.x3_1 = 101);
  check "r3.x2 b" (r.x3_2 = 102)
type r4 = { mutable x4_0: int; mutable x4_1: int; mutable x4_2: int; mutable x4_3: int }
let mk4 a = { x4_0 = a + 0; x4_1 = a + 1; x4_2 = a + 2; x4_3 = a + 3 }
let sum4 r = r.x4_0 + r.x4_1 + r.x4_2 + r.x4_3
let t4 () =
  let r = mk4 5 in
  check "r4 size" (Obj.size (Obj.repr r) = 4);
  check "r4 tag" (Obj.tag (Obj.repr r) = 0);
  check "r4 sum0" (sum4 r = 26);
  check "r4.x0" (r.x4_0 = 5);
  check "r4.x1" (r.x4_1 = 6);
  check "r4.x2" (r.x4_2 = 7);
  check "r4.x3" (r.x4_3 = 8);
  r.x4_0 <- 100;
  r.x4_1 <- 101;
  r.x4_2 <- 102;
  r.x4_3 <- 103;
  check "r4 sum1" (sum4 r = 406);
  check "r4.x0 b" (r.x4_0 = 100);
  check "r4.x1 b" (r.x4_1 = 101);
  check "r4.x2 b" (r.x4_2 = 102);
  check "r4.x3 b" (r.x4_3 = 103)
type r5 = { mutable x5_0: int; mutable x5_1: int; mutable x5_2: int; mutable x5_3: int; mutable x5_4: int }
let mk5 a = { x5_0 = a + 0; x5_1 = a + 1; x5_2 = a + 2; x5_3 = a + 3; x5_4 = a + 4 }
let sum5 r = r.x5_0 + r.x5_1 + r.x5_2 + r.x5_3 + r.x5_4
let t5 () =
  let r = mk5 5 in
  check "r5 size" (Obj.size (Obj.repr r) = 5);
  check "r5 tag" (Obj.tag (Obj.repr r) = 0);
  check "r5 sum0" (sum5 r = 35);
  check "r5.x0" (r.x5_0 = 5);
  check "r5.x1" (r.x5_1 = 6);
  check "r5.x2" (r.x5_2 = 7);
  check "r5.x3" (r.x5_3 = 8);
  check "r5.x4" (r.x5_4 = 9);
  r.x5_0 <- 100;
  r.x5_1 <- 101;
  r.x5_2 <- 102;
  r.x5_3 <- 103;
  r.x5_4 <- 104;
  check "r5 sum1" (sum5 r = 510);
  check "r5.x0 b" (r.x5_0 = 100);
  check "r5.x1 b" (r.x5_1 = 101);
  check "r5.x2 b" (r.x5_2 = 102);
  check "r5.x3 b" (r.x5_3 = 103);
  check "r5.x4 b" (r.x5_4 = 104)
type r6 = { mutable x6_0: int; mutable x6_1: int; mutable x6_2: int; mutable x6_3: int; mutable x6_4: int; mutable x6_5: int }
let mk6 a = { x6_0 = a + 0; x6_1 = a + 1; x6_2 = a + 2; x6_3 = a + 3; x6_4 = a + 4; x6_5 = a + 5 }
let sum6 r = r.x6_0 + r.x6_1 + r.x6_2 + r.x6_3 + r.x6_4 + r.x6_5
let t6 () =
  let r = mk6 5 in
  check "r6 size" (Obj.size (Obj.repr r) = 6);
  check "r6 tag" (Obj.tag (Obj.repr r) = 0);
  check "r6 sum0" (sum6 r = 45);
  check "r6.x0" (r.x6_0 = 5);
  check "r6.x1" (r.x6_1 = 6);
  check "r6.x2" (r.x6_2 = 7);
  check "r6.x3" (r.x6_3 = 8);
  check "r6.x4" (r.x6_4 = 9);
  check "r6.x5" (r.x6_5 = 10);
  r.x6_0 <- 100;
  r.x6_1 <- 101;
  r.x6_2 <- 102;
  r.x6_3 <- 103;
  r.x6_4 <- 104;
  r.x6_5 <- 105;
  check "r6 sum1" (sum6 r = 615);
  check "r6.x0 b" (r.x6_0 = 100);
  check "r6.x1 b" (r.x6_1 = 101);
  check "r6.x2 b" (r.x6_2 = 102);
  check "r6.x3 b" (r.x6_3 = 103);
  check "r6.x4 b" (r.x6_4 = 104);
  check "r6.x5 b" (r.x6_5 = 105)
type r7 = { mutable x7_0: int; mutable x7_1: int; mutable x7_2: int; mutable x7_3: int; mutable x7_4: int; mutable x7_5: int; mutable x7_6: int }
let mk7 a = { x7_0 = a + 0; x7_1 = a + 1; x7_2 = a + 2; x7_3 = a + 3; x7_4 = a + 4; x7_5 = a + 5; x7_6 = a + 6 }
let sum7 r = r.x7_0 + r.x7_1 + r.x7_2 + r.x7_3 + r.x7_4 + r.x7_5 + r.x7_6
let t7 () =
  let r = mk7 5 in
  check "r7 size" (Obj.size (Obj.repr r) = 7);
  check "r7 tag" (Obj.tag (Obj.repr r) = 0);
  check "r7 sum0" (sum7 r = 56);
  check "r7.x0" (r.x7_0 = 5);
  check "r7.x1" (r.x7_1 = 6);
  check "r7.x2" (r.x7_2 = 7);
  check "r7.x3" (r.x7_3 = 8);
  check "r7.x4" (r.x7_4 = 9);
  check "r7.x5" (r.x7_5 = 10);
  check "r7.x6" (r.x7_6 = 11);
  r.x7_0 <- 100;
  r.x7_1 <- 101;
  r.x7_2 <- 102;
  r.x7_3 <- 103;
  r.x7_4 <- 104;
  r.x7_5 <- 105;
  r.x7_6 <- 106;
  check "r7 sum1" (sum7 r = 721);
  check "r7.x0 b" (r.x7_0 = 100);
  check "r7.x1 b" (r.x7_1 = 101);
  check "r7.x2 b" (r.x7_2 = 102);
  check "r7.x3 b" (r.x7_3 = 103);
  check "r7.x4 b" (r.x7_4 = 104);
  check "r7.x5 b" (r.x7_5 = 105);
  check "r7.x6 b" (r.x7_6 = 106)
type r8 = { mutable x8_0: int; mutable x8_1: int; mutable x8_2: int; mutable x8_3: int; mutable x8_4: int; mutable x8_5: int; mutable x8_6: int; mutable x8_7: int }
let mk8 a = { x8_0 = a + 0; x8_1 = a + 1; x8_2 = a + 2; x8_3 = a + 3; x8_4 = a + 4; x8_5 = a + 5; x8_6 = a + 6; x8_7 = a + 7 }
let sum8 r = r.x8_0 + r.x8_1 + r.x8_2 + r.x8_3 + r.x8_4 + r.x8_5 + r.x8_6 + r.x8_7
let t8 () =
  let r = mk8 5 in
  check "r8 size" (Obj.size (Obj.repr r) = 8);
  check "r8 tag" (Obj.tag (Obj.repr r) = 0);
  check "r8 sum0" (sum8 r = 68);
  check "r8.x0" (r.x8_0 = 5);
  check "r8.x1" (r.x8_1 = 6);
  check "r8.x2" (r.x8_2 = 7);
  check "r8.x3" (r.x8_3 = 8);
  check "r8.x4" (r.x8_4 = 9);
  check "r8.x5" (r.x8_5 = 10);
  check "r8.x6" (r.x8_6 = 11);
  check "r8.x7" (r.x8_7 = 12);
  r.x8_0 <- 100;
  r.x8_1 <- 101;
  r.x8_2 <- 102;
  r.x8_3 <- 103;
  r.x8_4 <- 104;
  r.x8_5 <- 105;
  r.x8_6 <- 106;
  r.x8_7 <- 100;
  check "r8 sum1" (sum8 r = 821);
  check "r8.x0 b" (r.x8_0 = 100);
  check "r8.x1 b" (r.x8_1 = 101);
  check "r8.x2 b" (r.x8_2 = 102);
  check "r8.x3 b" (r.x8_3 = 103);
  check "r8.x4 b" (r.x8_4 = 104);
  check "r8.x5 b" (r.x8_5 = 105);
  check "r8.x6 b" (r.x8_6 = 106);
  check "r8.x7 b" (r.x8_7 = 100)
type r9 = { mutable x9_0: int; mutable x9_1: int; mutable x9_2: int; mutable x9_3: int; mutable x9_4: int; mutable x9_5: int; mutable x9_6: int; mutable x9_7: int; mutable x9_8: int }
let mk9 a = { x9_0 = a + 0; x9_1 = a + 1; x9_2 = a + 2; x9_3 = a + 3; x9_4 = a + 4; x9_5 = a + 5; x9_6 = a + 6; x9_7 = a + 7; x9_8 = a + 8 }
let sum9 r = r.x9_0 + r.x9_1 + r.x9_2 + r.x9_3 + r.x9_4 + r.x9_5 + r.x9_6 + r.x9_7 + r.x9_8
let t9 () =
  let r = mk9 5 in
  check "r9 size" (Obj.size (Obj.repr r) = 9);
  check "r9 tag" (Obj.tag (Obj.repr r) = 0);
  check "r9 sum0" (sum9 r = 81);
  check "r9.x0" (r.x9_0 = 5);
  check "r9.x1" (r.x9_1 = 6);
  check "r9.x2" (r.x9_2 = 7);
  check "r9.x3" (r.x9_3 = 8);
  check "r9.x4" (r.x9_4 = 9);
  check "r9.x6" (r.x9_6 = 11);
  check "r9.x7" (r.x9_7 = 12);
  check "r9.x8" (r.x9_8 = 13);
  r.x9_0 <- 100;
  r.x9_1 <- 101;
  r.x9_2 <- 102;
  r.x9_3 <- 103;
  r.x9_4 <- 104;
  r.x9_6 <- 106;
  r.x9_7 <- 100;
  r.x9_8 <- 101;
  check "r9 sum1" (sum9 r = 827);
  check "r9.x0 b" (r.x9_0 = 100);
  check "r9.x1 b" (r.x9_1 = 101);
  check "r9.x2 b" (r.x9_2 = 102);
  check "r9.x3 b" (r.x9_3 = 103);
  check "r9.x4 b" (r.x9_4 = 104);
  check "r9.x6 b" (r.x9_6 = 106);
  check "r9.x7 b" (r.x9_7 = 100);
  check "r9.x8 b" (r.x9_8 = 101)
type r10 = { mutable x10_0: int; mutable x10_1: int; mutable x10_2: int; mutable x10_3: int; mutable x10_4: int; mutable x10_5: int; mutable x10_6: int; mutable x10_7: int; mutable x10_8: int; mutable x10_9: int }
let mk10 a = { x10_0 = a + 0; x10_1 = a + 1; x10_2 = a + 2; x10_3 = a + 3; x10_4 = a + 4; x10_5 = a + 5; x10_6 = a + 6; x10_7 = a + 7; x10_8 = a + 8; x10_9 = a + 9 }
let sum10 r = r.x10_0 + r.x10_1 + r.x10_2 + r.x10_3 + r.x10_4 + r.x10_5 + r.x10_6 + r.x10_7 + r.x10_8 + r.x10_9
let t10 () =
  let r = mk10 5 in
  check "r10 size" (Obj.size (Obj.repr r) = 10);
  check "r10 tag" (Obj.tag (Obj.repr r) = 0);
  check "r10 sum0" (sum10 r = 95);
  check "r10.x0" (r.x10_0 = 5);
  check "r10.x1" (r.x10_1 = 6);
  check "r10.x2" (r.x10_2 = 7);
  check "r10.x3" (r.x10_3 = 8);
  check "r10.x4" (r.x10_4 = 9);
  check "r10.x5" (r.x10_5 = 10);
  check "r10.x7" (r.x10_7 = 12);
  check "r10.x8" (r.x10_8 = 13);
  check "r10.x9" (r.x10_9 = 14);
  r.x10_0 <- 100;
  r.x10_1 <- 101;
  r.x10_2 <- 102;
  r.x10_3 <- 103;
  r.x10_4 <- 104;
  r.x10_5 <- 105;
  r.x10_7 <- 100;
  r.x10_8 <- 101;
  r.x10_9 <- 102;
  check "r10 sum1" (sum10 r = 929);
  check "r10.x0 b" (r.x10_0 = 100);
  check "r10.x1 b" (r.x10_1 = 101);
  check "r10.x2 b" (r.x10_2 = 102);
  check "r10.x3 b" (r.x10_3 = 103);
  check "r10.x4 b" (r.x10_4 = 104);
  check "r10.x5 b" (r.x10_5 = 105);
  check "r10.x7 b" (r.x10_7 = 100);
  check "r10.x8 b" (r.x10_8 = 101);
  check "r10.x9 b" (r.x10_9 = 102)
type tv =
  | K0 of int * int * int * int
  | K1 of int * int * int * int * int
  | K2 of int * int * int * int
  | K3 of int * int * int * int * int * int * int
  | K4 of int * int * int * int * int
  | K5 of int * int * int * int
  | K6 of int * int * int * int * int * int
  | K7 of int * int * int * int * int * int * int * int
  | K8 of int * int * int * int
  | K9 of int * int * int * int * int * int * int * int * int * int * int * int
let mkv t a = match t with
  | 0 -> K0 (a + 0, a + 1, a + 2, a + 3)
  | 1 -> K1 (a + 0, a + 1, a + 2, a + 3, a + 4)
  | 2 -> K2 (a + 0, a + 1, a + 2, a + 3)
  | 3 -> K3 (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5, a + 6)
  | 4 -> K4 (a + 0, a + 1, a + 2, a + 3, a + 4)
  | 5 -> K5 (a + 0, a + 1, a + 2, a + 3)
  | 6 -> K6 (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5)
  | 7 -> K7 (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5, a + 6, a + 7)
  | 8 -> K8 (a + 0, a + 1, a + 2, a + 3)
  | 9 -> K9 (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5, a + 6, a + 7, a + 8, a + 9, a + 10, a + 11)
  | _ -> K0 (a, a, a, a)
let which v = match v with
  | K0 _ -> 0
  | K1 _ -> 1
  | K2 _ -> 2
  | K3 _ -> 3
  | K4 _ -> 4
  | K5 _ -> 5
  | K6 _ -> 6
  | K7 _ -> 7
  | K8 _ -> 8
  | K9 _ -> 9
let vsum v = match v with
  | K0 (p0,p1,p2,p3) -> p0 + p1 + p2 + p3
  | K1 (p0,p1,p2,p3,p4) -> p0 + p1 + p2 + p3 + p4
  | K2 (p0,p1,p2,p3) -> p0 + p1 + p2 + p3
  | K3 (p0,p1,p2,p3,p4,p5,p6) -> p0 + p1 + p2 + p3 + p4 + p5 + p6
  | K4 (p0,p1,p2,p3,p4) -> p0 + p1 + p2 + p3 + p4
  | K5 (p0,p1,p2,p3) -> p0 + p1 + p2 + p3
  | K6 (p0,p1,p2,p3,p4,p5) -> p0 + p1 + p2 + p3 + p4 + p5
  | K7 (p0,p1,p2,p3,p4,p5,p6,p7) -> p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7
  | K8 (p0,p1,p2,p3) -> p0 + p1 + p2 + p3
  | K9 (p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11) -> p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 + p11
let tv () =
  for t = 0 to 9 do
    let v = mkv t 10 in
    checkn "variant which " t (which v = t);
    checkn "variant tag " t (Obj.tag (Obj.repr v) = t);
    checkn "variant size " t (Obj.size (Obj.repr v) = (match t with 0 -> 4 | 1 -> 5 | 2 -> 4 | 3 -> 7 | 4 -> 5 | 5 -> 4 | 6 -> 6 | 7 -> 8 | 8 -> 4 | 9 -> 12 | _ -> 0));
    checkn "variant sum " t (vsum v = (match t with 0 -> 46 | 1 -> 60 | 2 -> 46 | 3 -> 91 | 4 -> 60 | 5 -> 46 | 6 -> 75 | 7 -> 108 | 8 -> 46 | 9 -> 186 | _ -> 0))
  done
let tup4 a = (a + 0, a + 1, a + 2, a + 3)
let tup5 a = (a + 0, a + 1, a + 2, a + 3, a + 4)
let tup8 a = (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5, a + 6, a + 7)
let tup20 a = (a + 0, a + 1, a + 2, a + 3, a + 4, a + 5, a + 6, a + 7, a + 8, a + 9, a + 10, a + 11, a + 12, a + 13, a + 14, a + 15, a + 16, a + 17, a + 18, a + 19)
let tt4 () =
  let (p0, p1, p2, p3) = tup4 3 in
  check "tuple4" (p0 = 3 && p1 = 4 && p2 = 5 && p3 = 6)
let tt5 () =
  let (p0, p1, p2, p3, p4) = tup5 3 in
  check "tuple5" (p0 = 3 && p1 = 4 && p2 = 5 && p3 = 6 && p4 = 7)
let tt8 () =
  let (p0, p1, p2, p3, p4, p5, p6, p7) = tup8 3 in
  check "tuple8" (p0 = 3 && p1 = 4 && p2 = 5 && p3 = 6 && p4 = 7 && p5 = 8 && p6 = 9 && p7 = 10)
let tt20 () =
  let (p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19) = tup20 3 in
  check "tuple20" (p0 = 3 && p1 = 4 && p2 = 5 && p3 = 6 && p4 = 7 && p5 = 8 && p6 = 9 && p7 = 10 && p8 = 11 && p9 = 12 && p10 = 13 && p11 = 14 && p12 = 15 && p13 = 16 && p14 = 17 && p15 = 18 && p16 = 19 && p17 = 20 && p18 = 21 && p19 = 22)
let () =
  run "r1" t1;
  run "r2" t2;
  run "r3" t3;
  run "r4" t4;
  run "r5" t5;
  run "r6" t6;
  run "r7" t7;
  run "r8" t8;
  run "r9" t9;
  run "r10" t10;
  run "variants" tv;
  run "tuple4" tt4;
  run "tuple5" tt5;
  run "tuple8" tt8;
  run "tuple20" tt20;
  finish "T01A"
