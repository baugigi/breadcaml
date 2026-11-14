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
let test_atoms () =
  let a = Array.make 0 1 in
  let b = Array.sub [|1; 2|] 1 0 in
  let c = Array.concat ([] : int array list) in
  let d = Array.append ([||] : int array) [||] in
  let e = Array.init 0 (fun i -> i) in
  let f = Array.copy ([||] : int array) in
  check "atoms len" (Array.length a = 0 && Array.length b = 0 && Array.length c = 0
                     && Array.length d = 0 && Array.length e = 0 && Array.length f = 0);
  check "atoms phys" (a == b && b == c && c == d && d == e && e == f);
  check "atoms obj" (Obj.size (Obj.repr a) = 0);
  check "atom new_block" (Obj.new_block 0 0 == Obj.repr a);
  let lit1 = ([||] : int array) and lit2 = ([||] : int array) in
  check "atoms lit" (lit1 == lit2 && lit1 == a);
  let fa = Array.make 0 1.5 in
  check "float atom" (Array.length fa = 0 && Obj.repr fa == Obj.repr a);
  let keep = (a, [|b|], [c], ref d) in
  for i = 1 to 120 do
    ignore (String.make 200 'x');
    ignore (Array.make 100 i);
    ignore (Array.make 255 [i])
  done;
  let (a1, ba, cl, rd) = keep in
  check "atoms survive gc" (a1 == a && Array.length ba.(0) = 0 && ba.(0) == a
                            && (match cl with [x] -> x == a | _ -> false) && !rd == a);
  check "empty string" (String.length "" = 0 && String.length (String.make 0 'x') = 0
                        && Bytes.length (Bytes.create 0) = 0);
  check "empty string cmp" (String.equal "" (String.make 0 'a') && compare "" (String.make 0 'a') = 0
                            && "" < "a" && not ("a" < "") && "" <= String.make 0 'z'
                            && "" >= String.make 0 'z');
  raises_inv "empty get" (fun () -> a.(0));
  raises_inv "empty set" (fun () -> a.(0) <- 1);
  raises_inv "empty sub" (fun () -> Array.sub a 0 1);
  raises_inv "empty string get" (fun () -> String.get "" 0);
  check "atoms blit" (Array.blit a 0 b 0 0; true);
  check "atoms fill" (let x = Array.make 3 0 in Array.blit a 0 x 0 0; x.(0) = 0 && x.(2) = 0)
let () =
  run "atoms" test_atoms;
  finish "T03F"
