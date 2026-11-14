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
type v = A | B of int | D of int * int
let z = ref 0
let sgn c = if c < 0 then -1 else if c > 0 then 1 else 0
let ci (a : int) (b : int) = sgn (compare a b)
let pc a b = sgn (compare a b)
let () =
  let pairs = [| (3, 4, -1); (3, 3, 0); (4, 3, 1); (9, -9, 1); (-9, 9, -1);
                 (16383, -16384, 1); (-16384, 16383, -1); (133, 5, 1); (5, 133, -1);
                 (-123, 5, -1); (261, 5, 1); (0, 0, 0) |] in
  for i = 0 to Array.length pairs - 1 do
    let (a, b, e) = pairs.(i) in
    dg ("ci " ^ string_of_int a ^ "," ^ string_of_int b) (ci a b) e;
    dg ("pc " ^ string_of_int a ^ "," ^ string_of_int b) (pc a b) e
  done;
  ex "c0" (fun () -> dg "float lt" (pc 1.5 2.5) (-1));
  ex "c1" (fun () -> dg "float eq" (pc 1.5 1.5) 0);
  ex "c2" (fun () -> dg "string lt" (pc "a" "b") (-1));
  ex "c3" (fun () -> dg "string eq" (pc "ab" ("a" ^ "b")) 0);
  ex "c4" (fun () -> dg "tup lt" (pc (1, 2) (1, 3 + !z)) (-1));
  ex "c5" (fun () -> dg "tup eq" (pc (1, 2) (1, 2 + !z)) 0);
  ex "c6" (fun () -> dg "tup gt" (pc (1, 3) (1, 2 + !z)) 1);
  ex "c7" (fun () -> dg "tup lt@0" (pc (1, 2) (2 + !z, 2)) (-1));
  ex "c8" (fun () -> dgb "tup =" ((1, 2) = (1, 2 + !z)));
  ex "c9" (fun () -> dgb "tup <>" ((1, 2) <> (1, 3 + !z)));
  ex "c10" (fun () -> dg "list lt" (pc [1; 2] [1; 3 + !z]) (-1));
  ex "c11" (fun () -> dg "list eq" (pc [1; 2] [1; 2 + !z]) 0);
  ex "c12" (fun () -> dg "some lt" (pc (Some 1) (Some (2 + !z))) (-1));
  ex "c13" (fun () -> dg "B lt" (pc (B 1) (B (2 + !z))) (-1));
  ex "c14" (fun () -> dg "D lt" (pc (D (1, 2)) (D (1, 3 + !z))) (-1));
  ex "c15" (fun () -> dg "D eq" (pc (D (1, 2)) (D (1, 2 + !z))) 0);
  ex "c16" (fun () -> dg "arr lt" (pc [|1; 2|] [|1; 3 + !z|]) (-1));
  finish "d_cmp"
