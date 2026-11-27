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
let sg n = if n < 0 then -1 else if n > 0 then 1 else 0
let ck s a b e =
  check (s ^ " compare") (sg (compare a b) = e);
  check (s ^ " =") ((a = b) = (e = 0));
  check (s ^ " <>") ((a <> b) = (e <> 0));
  check (s ^ " <") ((a < b) = (e < 0));
  check (s ^ " <=") ((a <= b) = (e <= 0));
  check (s ^ " >") ((a > b) = (e > 0));
  check (s ^ " >=") ((a >= b) = (e >= 0))
type v = A | B of int | C of int | D of int * int
type tree = Leaf | Node of tree * int * tree
let rec build d i = if d = 0 then Leaf
  else Node (build (d - 1) (2 * i), i, build (d - 1) (2 * i + 1))
let rec build2 d i = if d = 0 then Leaf
  else Node (build2 (d - 1) (2 * i), (if d = 1 && i = 33 then i + 1 else i), build2 (d - 1) (2 * i + 1))
let lst n k = let rec go i acc = if i < 0 then acc else go (i - 1) ((k + i) :: acc) in go (n - 1) []
let lstx n k pos =
  let rec go i acc = if i < 0 then acc
    else go (i - 1) ((if i = pos then k + i + 1 else k + i) :: acc) in go (n - 1) []
let arrx n k pos = Array.init n (fun i -> if i = pos then k + i + 1 else k + i)
let z = ref 0
let tp2 x = (x + 0, x + 1)
let tp2_0 x = (x + 1, x + 1)
let tp2_1 x = (x + 0, x + 2)
let tp3 x = (x + 0, x + 1, x + 2)
let tp3_0 x = (x + 1, x + 1, x + 2)
let tp3_1 x = (x + 0, x + 2, x + 2)
let tp3_2 x = (x + 0, x + 1, x + 3)
let tp4 x = (x + 0, x + 1, x + 2, x + 3)
let tp4_0 x = (x + 1, x + 1, x + 2, x + 3)
let tp4_1 x = (x + 0, x + 2, x + 2, x + 3)
let tp4_2 x = (x + 0, x + 1, x + 3, x + 3)
let tp4_3 x = (x + 0, x + 1, x + 2, x + 4)
let tp5 x = (x + 0, x + 1, x + 2, x + 3, x + 4)
let tp5_0 x = (x + 1, x + 1, x + 2, x + 3, x + 4)
let tp5_1 x = (x + 0, x + 2, x + 2, x + 3, x + 4)
let tp5_2 x = (x + 0, x + 1, x + 3, x + 3, x + 4)
let tp5_3 x = (x + 0, x + 1, x + 2, x + 4, x + 4)
let tp5_4 x = (x + 0, x + 1, x + 2, x + 3, x + 5)
let tp8 x = (x + 0, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7)
let tp8_0 x = (x + 1, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7)
let tp8_1 x = (x + 0, x + 2, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7)
let tp8_2 x = (x + 0, x + 1, x + 3, x + 3, x + 4, x + 5, x + 6, x + 7)
let tp8_3 x = (x + 0, x + 1, x + 2, x + 4, x + 4, x + 5, x + 6, x + 7)
let tp8_4 x = (x + 0, x + 1, x + 2, x + 3, x + 5, x + 5, x + 6, x + 7)
let tp8_5 x = (x + 0, x + 1, x + 2, x + 3, x + 4, x + 6, x + 6, x + 7)
let tp8_6 x = (x + 0, x + 1, x + 2, x + 3, x + 4, x + 5, x + 7, x + 7)
let tp8_7 x = (x + 0, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 8)
let t_tup2 () =
  ck "tup2 eq" (tp2 10) (tp2 10) 0;
  ck "tup2 lt@0" (tp2 10) (tp2_0 10) (-1);
  ck "tup2 gt@0" (tp2_0 10) (tp2 10) 1;
  ck "tup2 lt@1" (tp2 10) (tp2_1 10) (-1);
  ck "tup2 gt@1" (tp2_1 10) (tp2 10) 1;
  ()
let t_tup3 () =
  ck "tup3 eq" (tp3 10) (tp3 10) 0;
  ck "tup3 lt@0" (tp3 10) (tp3_0 10) (-1);
  ck "tup3 gt@0" (tp3_0 10) (tp3 10) 1;
  ck "tup3 lt@1" (tp3 10) (tp3_1 10) (-1);
  ck "tup3 gt@1" (tp3_1 10) (tp3 10) 1;
  ck "tup3 lt@2" (tp3 10) (tp3_2 10) (-1);
  ck "tup3 gt@2" (tp3_2 10) (tp3 10) 1;
  ()
let t_tup4 () =
  ck "tup4 eq" (tp4 10) (tp4 10) 0;
  ck "tup4 lt@0" (tp4 10) (tp4_0 10) (-1);
  ck "tup4 gt@0" (tp4_0 10) (tp4 10) 1;
  ck "tup4 lt@1" (tp4 10) (tp4_1 10) (-1);
  ck "tup4 gt@1" (tp4_1 10) (tp4 10) 1;
  ck "tup4 lt@2" (tp4 10) (tp4_2 10) (-1);
  ck "tup4 gt@2" (tp4_2 10) (tp4 10) 1;
  ck "tup4 lt@3" (tp4 10) (tp4_3 10) (-1);
  ck "tup4 gt@3" (tp4_3 10) (tp4 10) 1;
  ()
let t_tup5 () =
  ck "tup5 eq" (tp5 10) (tp5 10) 0;
  ck "tup5 lt@0" (tp5 10) (tp5_0 10) (-1);
  ck "tup5 gt@0" (tp5_0 10) (tp5 10) 1;
  ck "tup5 lt@1" (tp5 10) (tp5_1 10) (-1);
  ck "tup5 gt@1" (tp5_1 10) (tp5 10) 1;
  ck "tup5 lt@2" (tp5 10) (tp5_2 10) (-1);
  ck "tup5 gt@2" (tp5_2 10) (tp5 10) 1;
  ck "tup5 lt@3" (tp5 10) (tp5_3 10) (-1);
  ck "tup5 gt@3" (tp5_3 10) (tp5 10) 1;
  ck "tup5 lt@4" (tp5 10) (tp5_4 10) (-1);
  ck "tup5 gt@4" (tp5_4 10) (tp5 10) 1;
  ()
let t_tup8 () =
  ck "tup8 eq" (tp8 10) (tp8 10) 0;
  ck "tup8 lt@0" (tp8 10) (tp8_0 10) (-1);
  ck "tup8 gt@0" (tp8_0 10) (tp8 10) 1;
  ck "tup8 lt@1" (tp8 10) (tp8_1 10) (-1);
  ck "tup8 gt@1" (tp8_1 10) (tp8 10) 1;
  ck "tup8 lt@2" (tp8 10) (tp8_2 10) (-1);
  ck "tup8 gt@2" (tp8_2 10) (tp8 10) 1;
  ck "tup8 lt@3" (tp8 10) (tp8_3 10) (-1);
  ck "tup8 gt@3" (tp8_3 10) (tp8 10) 1;
  ck "tup8 lt@4" (tp8 10) (tp8_4 10) (-1);
  ck "tup8 gt@4" (tp8_4 10) (tp8 10) 1;
  ck "tup8 lt@5" (tp8 10) (tp8_5 10) (-1);
  ck "tup8 gt@5" (tp8_5 10) (tp8 10) 1;
  ck "tup8 lt@6" (tp8 10) (tp8_6 10) (-1);
  ck "tup8 gt@6" (tp8_6 10) (tp8 10) 1;
  ck "tup8 lt@7" (tp8 10) (tp8_7 10) (-1);
  ck "tup8 gt@7" (tp8_7 10) (tp8 10) 1;
  ()
let () =
  run "t_tup2" t_tup2;
  run "t_tup3" t_tup3;
  run "t_tup4" t_tup4;
  run "t_tup5" t_tup5;
  run "t_tup8" t_tup8;
  finish "T11B"
