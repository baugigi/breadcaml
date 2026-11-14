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
let dg s got exp =
  if got <> exp then begin
    incr fails; print_string s; print_string " got="; print_int got;
    print_string " exp="; print_int exp; print_newline ()
  end
let dgb s b = dg s (if b then 1 else 0) 1
let ex s f = try f () with _ -> dg (s ^ " exn") 1 0
let () =
  let a = Array.make 0 1 in
  let b = Array.sub [|1; 2|] 1 0 in
  let c = Array.concat ([] : int array list) in
  let d = Array.append ([||] : int array) [||] in
  let e = Array.init 0 (fun i -> i) in
  let f = Array.copy ([||] : int array) in
  let l = ([||] : int array) in
  dg "len a" (Array.length a) 0;  dg "len b" (Array.length b) 0;
  dg "len c" (Array.length c) 0;  dg "len d" (Array.length d) 0;
  dg "len e" (Array.length e) 0;  dg "len f" (Array.length f) 0;
  dgb "a==b" (a == b); dgb "a==c" (a == c); dgb "a==d" (a == d);
  dgb "a==e" (a == e); dgb "a==f" (a == f); dgb "a==literal" (a == l);
  dg "Obj.size a" (Obj.size (Obj.repr a)) 0;
    dgb "new_block 0 0 == a" (Obj.new_block 0 0 == Obj.repr a);
  ex "blit n=0 same" (fun () -> Array.blit a 0 a 0 0);
  ex "blit n=0 other" (fun () -> let x = Array.make 3 0 in Array.blit a 0 x 0 0;
                         dg "x.(0) after blit 0" x.(0) 0; dg "x.(2) after blit 0" x.(2) 0);
  let keep = (a, [|b|]) in
  for i = 1 to 120 do
    ignore (String.make 200 'x'); ignore (Array.make 100 i); ignore (Array.make 255 [i])
  done;
  let (a1, ba) = keep in
  dgb "after gc a1==a" (a1 == a);
  dgb "after gc ba.(0)==a" (Array.length ba.(0) = 0 && ba.(0) == a);
  finish "d_atoms"
