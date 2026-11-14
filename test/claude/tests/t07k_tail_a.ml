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
let rec lp2 i acc  = if i = 0 then acc else lp2 (i - 1) (acc + 1) 
let rec lp3 i acc b3 = if i = 0 then acc + b3 else lp3 (i - 1) (acc + 1) b3
let rec lp4 i acc b3 b4 = if i = 0 then acc + b3 + b4 else lp4 (i - 1) (acc + 1) b3 b4
let rec lp5 i acc b3 b4 b5 = if i = 0 then acc + b3 + b4 + b5 else lp5 (i - 1) (acc + 1) b3 b4 b5
let rec lp6 i acc b3 b4 b5 b6 = if i = 0 then acc + b3 + b4 + b5 + b6 else lp6 (i - 1) (acc + 1) b3 b4 b5 b6
let rec lp10 i acc b3 b4 b5 b6 b7 b8 b9 b10 = if i = 0 then acc + b3 + b4 + b5 + b6 + b7 + b8 + b9 + b10 else lp10 (i - 1) (acc + 1) b3 b4 b5 b6 b7 b8 b9 b10
let () =
  run "lp2" (fun () -> checkn "tailcall " 2 (lp2 5 0  = 5); checkn "tailcall300 " 2 (lp2 300 0  = 300));
  run "lp3" (fun () -> checkn "tailcall " 3 (lp3 5 0 3 = 8); checkn "tailcall300 " 3 (lp3 300 0 3 = 303));
  run "lp4" (fun () -> checkn "tailcall " 4 (lp4 5 0 3 4 = 12); checkn "tailcall300 " 4 (lp4 300 0 3 4 = 307));
  run "lp5" (fun () -> checkn "tailcall " 5 (lp5 5 0 3 4 5 = 17); checkn "tailcall300 " 5 (lp5 300 0 3 4 5 = 312));
  run "lp6" (fun () -> checkn "tailcall " 6 (lp6 5 0 3 4 5 6 = 23); checkn "tailcall300 " 6 (lp6 300 0 3 4 5 6 = 318));
  run "lp10" (fun () -> checkn "tailcall " 10 (lp10 5 0 3 4 5 6 7 8 9 10 = 57); checkn "tailcall300 " 10 (lp10 300 0 3 4 5 6 7 8 9 10 = 352));
  finish "T07K"
