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
let t_tree () =
  ck "tree eq" (build 6 1) (build 6 1) 0;
  ck "tree lt" (build 6 1) (build2 6 1) (-1);
  ck "tree gt" (build2 6 1) (build 6 1) 1;
  ck "tree leaf" Leaf (build 1 1) (-1)
let t_fun () =
  raises_inv "compare fun" (fun () -> compare (fun x -> x + 1) (fun x -> x + 2));
  raises_inv "equal fun" (fun () -> (fun x -> x + 1) = (fun x -> x + 2))
let t_custom () =
  ck "i32 lt" (Int32.of_int (1 + !z)) (Int32.of_int 2) (-1);
  ck "i32 eq" (Int32.of_int (5 + !z)) (Int32.of_int 5) 0;
  ck "i32 gt" 2147483647l (-2147483648l) 1;
  ck "i32 neg" (-5l) 3l (-1);
  ck "i64 lt" (Int64.of_int (1 + !z)) (Int64.of_int 2) (-1);
  ck "i64 eq" (Int64.of_int (5 + !z)) (Int64.of_int 5) 0;
  ck "i64 big" 9223372036854775807L (-9223372036854775808L) 1;
  ck "i64 hi" 4294967296L 4294967295L 1;
  ck "i64 lo" 4294967295L 4294967296L (-1);
  ck "i32 in tuple" (1, Int32.of_int (2 + !z)) (1, Int32.of_int 3) (-1)
let t_farr () =
  ck "farr lt" [| 1.0; 2.0 |] [| 1.0; 3.0 |] (-1);
  ck "farr eq" [| 1.0; 2.0 |] [| 1.0; 2.0 |] 0;
  ck "farr size" [| 1.0 |] [| 1.0; 2.0 |] (-1)
let () =
  run "tree" t_tree;
  run "fun" t_fun;
  run "custom" t_custom;
  run "farr" t_farr;
  finish "T11D"
