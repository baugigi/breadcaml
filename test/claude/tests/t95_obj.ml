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
  check "tag int" (Obj.tag (Obj.repr 5) = Obj.int_tag);
  check "tag string" (Obj.tag (Obj.repr ("a" ^ "b")) = Obj.string_tag);
  check "tag double" (Obj.tag (Obj.repr (1.5 +. 0.0)) = Obj.double_tag);
  check "tag closure" (Obj.tag (Obj.repr (fun x -> x + 1)) = Obj.closure_tag);
  check "tag farray" (Obj.tag (Obj.repr (Array.make 3 1.5)) = Obj.double_array_tag);
  check "tag tuple" (Obj.tag (Obj.repr (ref 0)) = 0);
  List.iter (fun n ->
    let b = Obj.new_block 0 n in
    check2 "new_block size " n 0 (Obj.size b = n);
    let ok = ref true in
    for i = 0 to n - 1 do if not (Obj.field b i == Obj.repr 0) then ok := false done;
    check2 "new_block init " n 0 !ok) [1; 2; 3; 126; 127; 128; 129; 254; 255];
  List.iter (fun n ->
    let b = Obj.new_block 0 n in
    for i = 0 to n - 1 do Obj.set_field b i (Obj.repr (i + 1)) done;
    let d = Obj.dup b in
    check2 "dup size " n 0 (Obj.size d = n && not (d == b));
    let ok = ref true in
    for i = 0 to n - 1 do if not (Obj.field d i == Obj.repr (i + 1)) then ok := false done;
    check2 "dup fields " n 0 !ok;
    Obj.set_field d 0 (Obj.repr 99);
    check2 "dup indep " n 0 (Obj.field b 0 == Obj.repr 1)) [1; 2; 127; 128; 255];
  let b = Obj.new_block 7 3 in
  check "tag 7" (Obj.tag b = 7 && Obj.size b = 3);
  Obj.set_tag b 9;
  check "set_tag" (Obj.tag b = 9);
  check "is_block/is_int" (Obj.is_block (Obj.repr "x") && Obj.is_int (Obj.repr 3));
  finish "T95"
