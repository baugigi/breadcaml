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
let t_list () =
  ck "list0 eq" (lst 0 1) (lst 0 1) 0;
  ck "list0 prefix" (lst 0 1) (lst 1 1) (-1);
  ck "list0 prefix2" (lst 1 1) (lst 0 1) 1;
  ck "list1 eq" (lst 1 1) (lst 1 1) 0;
  ck "list1 prefix" (lst 1 1) (lst 2 1) (-1);
  ck "list1 prefix2" (lst 2 1) (lst 1 1) 1;
  ck "list1 last" (lst 1 1) (lstx 1 1 0) (-1);
  ck "list1 first" (lstx 1 1 0) (lst 1 1) 1;
  ck "list2 eq" (lst 2 1) (lst 2 1) 0;
  ck "list2 prefix" (lst 2 1) (lst 3 1) (-1);
  ck "list2 prefix2" (lst 3 1) (lst 2 1) 1;
  ck "list2 last" (lst 2 1) (lstx 2 1 1) (-1);
  ck "list2 first" (lstx 2 1 0) (lst 2 1) 1;
  ck "list3 eq" (lst 3 1) (lst 3 1) 0;
  ck "list3 prefix" (lst 3 1) (lst 4 1) (-1);
  ck "list3 prefix2" (lst 4 1) (lst 3 1) 1;
  ck "list3 last" (lst 3 1) (lstx 3 1 2) (-1);
  ck "list3 first" (lstx 3 1 0) (lst 3 1) 1;
  ck "list10 eq" (lst 10 1) (lst 10 1) 0;
  ck "list10 prefix" (lst 10 1) (lst 11 1) (-1);
  ck "list10 prefix2" (lst 11 1) (lst 10 1) 1;
  ck "list10 last" (lst 10 1) (lstx 10 1 9) (-1);
  ck "list10 first" (lstx 10 1 0) (lst 10 1) 1;
  ck "list100 eq" (lst 100 1) (lst 100 1) 0;
  ck "list100 prefix" (lst 100 1) (lst 101 1) (-1);
  ck "list100 prefix2" (lst 101 1) (lst 100 1) 1;
  ck "list100 last" (lst 100 1) (lstx 100 1 99) (-1);
  ck "list100 first" (lstx 100 1 0) (lst 100 1) 1;
  ck "list200 eq" (lst 200 1) (lst 200 1) 0;
  ck "list200 prefix" (lst 200 1) (lst 201 1) (-1);
  ck "list200 prefix2" (lst 201 1) (lst 200 1) 1;
  ck "list200 last" (lst 200 1) (lstx 200 1 199) (-1);
  ck "list200 first" (lstx 200 1 0) (lst 200 1) 1;
  ()
let t_arr () =
  ck "arr1 eq" (arrx 1 1 (-1)) (arrx 1 1 (-1)) 0;
  ck "arr1 lt@0" (arrx 1 1 (-1)) (arrx 1 1 0) (-1);
  ck "arr1 gt@0" (arrx 1 1 1) (arrx 0 1 (-1)) 1;
  ck "arr1 size" (arrx 1 1 (-1)) (arrx 2 1 (-1)) (-1);
  ck "arr2 eq" (arrx 2 1 (-1)) (arrx 2 1 (-1)) 0;
  ck "arr2 lt@0" (arrx 2 1 (-1)) (arrx 2 1 0) (-1);
  ck "arr2 gt@0" (arrx 2 1 2) (arrx 0 1 (-1)) 1;
  ck "arr2 lt@1" (arrx 2 1 (-1)) (arrx 2 1 1) (-1);
  ck "arr2 gt@1" (arrx 2 1 2) (arrx 1 1 (-1)) 1;
  ck "arr2 size" (arrx 2 1 (-1)) (arrx 3 1 (-1)) (-1);
  ck "arr3 eq" (arrx 3 1 (-1)) (arrx 3 1 (-1)) 0;
  ck "arr3 lt@0" (arrx 3 1 (-1)) (arrx 3 1 0) (-1);
  ck "arr3 gt@0" (arrx 3 1 3) (arrx 0 1 (-1)) 1;
  ck "arr3 lt@1" (arrx 3 1 (-1)) (arrx 3 1 1) (-1);
  ck "arr3 gt@1" (arrx 3 1 3) (arrx 1 1 (-1)) 1;
  ck "arr3 lt@2" (arrx 3 1 (-1)) (arrx 3 1 2) (-1);
  ck "arr3 gt@2" (arrx 3 1 3) (arrx 2 1 (-1)) 1;
  ck "arr3 size" (arrx 3 1 (-1)) (arrx 4 1 (-1)) (-1);
  ck "arr126 eq" (arrx 126 1 (-1)) (arrx 126 1 (-1)) 0;
  ck "arr126 lt@0" (arrx 126 1 (-1)) (arrx 126 1 0) (-1);
  ck "arr126 gt@0" (arrx 126 1 126) (arrx 0 1 (-1)) 1;
  ck "arr126 lt@63" (arrx 126 1 (-1)) (arrx 126 1 63) (-1);
  ck "arr126 gt@63" (arrx 126 1 126) (arrx 63 1 (-1)) 1;
  ck "arr126 lt@125" (arrx 126 1 (-1)) (arrx 126 1 125) (-1);
  ck "arr126 gt@125" (arrx 126 1 126) (arrx 125 1 (-1)) 1;
  ck "arr126 size" (arrx 126 1 (-1)) (arrx 127 1 (-1)) (-1);
  ck "arr127 eq" (arrx 127 1 (-1)) (arrx 127 1 (-1)) 0;
  ck "arr127 lt@0" (arrx 127 1 (-1)) (arrx 127 1 0) (-1);
  ck "arr127 gt@0" (arrx 127 1 127) (arrx 0 1 (-1)) 1;
  ck "arr127 lt@63" (arrx 127 1 (-1)) (arrx 127 1 63) (-1);
  ck "arr127 gt@63" (arrx 127 1 127) (arrx 63 1 (-1)) 1;
  ck "arr127 lt@126" (arrx 127 1 (-1)) (arrx 127 1 126) (-1);
  ck "arr127 gt@126" (arrx 127 1 127) (arrx 126 1 (-1)) 1;
  ck "arr127 size" (arrx 127 1 (-1)) (arrx 128 1 (-1)) (-1);
  ck "arr128 eq" (arrx 128 1 (-1)) (arrx 128 1 (-1)) 0;
  ck "arr128 lt@0" (arrx 128 1 (-1)) (arrx 128 1 0) (-1);
  ck "arr128 gt@0" (arrx 128 1 128) (arrx 0 1 (-1)) 1;
  ck "arr128 lt@64" (arrx 128 1 (-1)) (arrx 128 1 64) (-1);
  ck "arr128 gt@64" (arrx 128 1 128) (arrx 64 1 (-1)) 1;
  ck "arr128 lt@127" (arrx 128 1 (-1)) (arrx 128 1 127) (-1);
  ck "arr128 gt@127" (arrx 128 1 128) (arrx 127 1 (-1)) 1;
  ck "arr128 size" (arrx 128 1 (-1)) (arrx 129 1 (-1)) (-1);
  ck "arr129 eq" (arrx 129 1 (-1)) (arrx 129 1 (-1)) 0;
  ck "arr129 lt@0" (arrx 129 1 (-1)) (arrx 129 1 0) (-1);
  ck "arr129 gt@0" (arrx 129 1 129) (arrx 0 1 (-1)) 1;
  ck "arr129 lt@64" (arrx 129 1 (-1)) (arrx 129 1 64) (-1);
  ck "arr129 gt@64" (arrx 129 1 129) (arrx 64 1 (-1)) 1;
  ck "arr129 lt@128" (arrx 129 1 (-1)) (arrx 129 1 128) (-1);
  ck "arr129 gt@128" (arrx 129 1 129) (arrx 128 1 (-1)) 1;
  ck "arr129 size" (arrx 129 1 (-1)) (arrx 130 1 (-1)) (-1);
  ck "arr254 eq" (arrx 254 1 (-1)) (arrx 254 1 (-1)) 0;
  ck "arr254 lt@0" (arrx 254 1 (-1)) (arrx 254 1 0) (-1);
  ck "arr254 gt@0" (arrx 254 1 254) (arrx 0 1 (-1)) 1;
  ck "arr254 lt@127" (arrx 254 1 (-1)) (arrx 254 1 127) (-1);
  ck "arr254 gt@127" (arrx 254 1 254) (arrx 127 1 (-1)) 1;
  ck "arr254 lt@253" (arrx 254 1 (-1)) (arrx 254 1 253) (-1);
  ck "arr254 gt@253" (arrx 254 1 254) (arrx 253 1 (-1)) 1;
  ck "arr254 size" (arrx 254 1 (-1)) (arrx 255 1 (-1)) (-1);
  ck "arr255 eq" (arrx 255 1 (-1)) (arrx 255 1 (-1)) 0;
  ck "arr255 lt@0" (arrx 255 1 (-1)) (arrx 255 1 0) (-1);
  ck "arr255 gt@0" (arrx 255 1 255) (arrx 0 1 (-1)) 1;
  ck "arr255 lt@127" (arrx 255 1 (-1)) (arrx 255 1 127) (-1);
  ck "arr255 gt@127" (arrx 255 1 255) (arrx 127 1 (-1)) 1;
  ck "arr255 lt@254" (arrx 255 1 (-1)) (arrx 255 1 254) (-1);
  ck "arr255 gt@254" (arrx 255 1 255) (arrx 254 1 (-1)) 1;
  ck "arr empty" ([||] : int array) [||] 0;
  ()
let () =
  run "list" t_list;
  run "arr" t_arr;
  finish "T11C"
