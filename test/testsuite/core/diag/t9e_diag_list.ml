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
let scr n = (n * 37 + 11) mod 211
let cmpi (a : int) b = compare a b
let () =
  let l = ref [] in
  run "init 50" (fun () -> check "i" (List.length (List.init 50 scr) = 50));
  run "init 100" (fun () -> check "i" (List.length (List.init 100 scr) = 100));
  run "init 200" (fun () -> l := List.init 200 scr; check "i" (List.length !l = 200));
  let l = !l in
  run "nth" (fun () -> check "nth" (List.nth l 199 = 200 && List.nth l 0 = 11));
  run "sort" (fun () -> let s = List.sort cmpi l in check "s" (List.hd s = 1 && List.nth s 199 = 210));
  run "stable_sort" (fun () -> let s = List.stable_sort cmpi (List.rev l) in check "s" (List.hd s = 1));
  run "rev" (fun () -> check "rev" (List.rev (List.rev l) = l));
  run "map" (fun () -> check "map" (List.nth (List.map (fun x -> x + 1) l) 5 = 197));
  run "filter" (fun () -> check "f" (List.length (List.filter (fun x -> x mod 2 = 0) l) = 100));
  run "mem" (fun () -> check "mem" (List.mem 59 l && not (List.mem 1000 l)));
  run "exists" (fun () -> check "e" (List.exists (fun x -> x = 70) l && List.for_all (fun x -> x >= 0) l));
  run "assoc" (fun () -> check "a" (List.assoc 3 [(1, 10); (3, 30)] = 30));
  run "nth exn" (fun () -> (try ignore (List.nth l 200); fail "nth NOEXN" with Failure _ -> ()));
  run "fold_right" (fun () -> check "fr" (List.fold_right (fun x a -> x + a) [1; 2; 3] 0 = 6));
  run "concat" (fun () -> check "c" (List.length (List.concat [l; l]) = 400));
  run "append" (fun () -> check "ap" (List.length (l @ l) = 400));
  run "sort_uniq" (fun () -> check "su" (List.length (List.sort_uniq cmpi (l @ l)) = 200));
  finish "D_LIST"
