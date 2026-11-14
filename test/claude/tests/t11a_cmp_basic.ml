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
let t_basic () =
  ck "int" 3 4 (-1);
  ck "int=" 3 3 0;
  ck "int>" 9 (-9) 1;
  ck "int ext" 16383 (-16384) 1;
  ck "low-byte-equal" 133 5 1;
  ck "low-byte-equal2" 5 133 (-1);
  ck "low-byte-equal3" (-123) 5 (-1);
  ck "low-byte-equal4" 261 5 1;
  ck "chr" 'a' 'b' (-1);
  ck "bool" false true (-1);
  ck "unit" () () 0;
  ck "A<B" A (B !z) (-1);
  ck "B>A" (B 1) A 1;
  ck "B<B" (B 1) (B (1 + !z)) 0;
  ck "B1<B2" (B 1) (B (2 + !z)) (-1);
  ck "B<C tag" (B 5) (C !z) (-1);
  ck "D>C tag" (D (1, 2)) (C 9) 1;
  ck "D<D" (D (1, 2 + !z)) (D (1, 3)) (-1);
  ck "D=D" (D (1, 2 + !z)) (D (1, 2)) 0;
  ck "None<Some" None (Some (1 + !z)) (-1);
  ck "Some<Some" (Some 1) (Some (2 + !z)) (-1);
  ck "Some str" (Some "a") (Some ("b" ^ "")) (-1);
  ck "ref" (ref 1) (ref (2 + !z)) (-1);
  ck "ref=" (ref (5 + !z)) (ref 5) 0;
  ck "str in tup" ("a", 1) ("a" ^ "", 2) (-1);
  ck "str in tup2" ("ab", 1) ("a" ^ "", 2) 1;
  ck "flt in tup" (1.5, 2) (1.5 +. 0.0, 3) (-1);
  ck "flt in tup2" (1.5, 2) (2.5, 1) (-1);
  ck "flt in tup=" (1.5 +. 0.0, 2) (1.5, 2) 0;
  ck "nested" [(1, "a"); (2, "b")] [(1, "a"); (2, "c" ^ "")] (-1);
  ck "nested=" [(1, "a"); (2, "b")] [(1, "a" ^ ""); (2, "b")] 0;
  ck "str" "abc" ("ab" ^ "d") (-1);
  ck "str 509" (String.make 509 'a') (String.make 509 'a') 0;
  ()
let () =
  run "basic" t_basic;
  finish "T11A"
